import 'package:flutter_test/flutter_test.dart';
import 'package:mclash/app/clash/clash_http_api.dart';
import 'package:mclash/mf/mclash_node_autopick.dart';

/// 「连接后自动挑一个真能用的节点」的选择逻辑测试（**不依赖网络与内核**）。
///
/// ## 背景（实测同一份订阅）
///
///   * `RedMouse-香港-A1`：TCP 连通、延迟正常，但 `google`/`youtube` 全失败；
///   * `日本东京(YouTube,…)` / `美国线路1` / `新加坡优质(…)`：同时 200/302。
///
/// 内核的 url-test 组也按**延迟**挑，一样会踩到这类节点 —— 用户看到的是
/// 「已连接、baidu 能开、google 打不开」，在他眼里就是「这软件不能用」。
/// 所以连接后要按**真实探活**挑节点。这里把选择规则逐条钉死。
void main() {
  late List<String> probed;
  late List<(String group, String node)> switched;

  setUp(() {
    probed = [];
    switched = [];
    MclashNodeAutoPick.debugProxiesOverride = null;
    MclashNodeAutoPick.debugProbeOverride = (node) async {
      probed.add(node);
      return node == "好节点" ? 60 : -1; // 只有"好节点"可用
    };
    MclashNodeAutoPick.debugSwitchOverride = (group, node) async {
      switched.add((group, node));
      return true;
    };
  });

  tearDown(() {
    MclashNodeAutoPick.debugProxiesOverride = null;
    MclashNodeAutoPick.debugProbeOverride = null;
    MclashNodeAutoPick.debugSwitchOverride = null;
    MclashNodeAutoPick.debugGroupDelayOverride = null;
  });

  ClashProxiesNode proxyGroup(String now, List<String> all) =>
      ClashProxiesNode()
        ..name = "🚀 节点选择"
        ..type = "Selector"
        ..now = now
        ..all = all;

  ClashProxiesNode node(String name) => ClashProxiesNode()
    ..name = name
    ..type = "Vless";

  test('当前节点可用 → 不切换、不打扰用户', () async {
    MclashNodeAutoPick.debugProxiesOverride = () async => [
      proxyGroup("好节点", ["好节点", "坏节点"]),
      node("好节点"),
      node("坏节点"),
    ];

    final picked = await MclashNodeAutoPick.ensureUsable();

    expect(picked, isNull);
    expect(switched, isEmpty, reason: '当前节点能用就不该动用户的选择');
    expect(probed, ["好节点"], reason: '只需要探活当前节点');
  });

  test('当前节点不可用 → 切到第一个可用候选，并真的调用切换', () async {
    MclashNodeAutoPick.debugProxiesOverride = () async => [
      proxyGroup("坏节点", ["坏节点", "另一个坏节点", "好节点"]),
      node("坏节点"),
      node("另一个坏节点"),
      node("好节点"),
    ];

    final picked = await MclashNodeAutoPick.ensureUsable();

    expect(picked, "好节点");
    expect(switched, [("🚀 节点选择", "好节点")]);
    expect(probed.first, "坏节点", reason: '先探当前节点');
  });

  test('DIRECT / REJECT / 伪节点不参与候选', () async {
    MclashNodeAutoPick.debugProxiesOverride = () async => [
      proxyGroup("坏节点", ["坏节点", "DIRECT", "REJECT", "📢 官网: x", "好节点"]),
      node("坏节点"),
    ];

    final picked = await MclashNodeAutoPick.ensureUsable();

    expect(picked, "好节点");
    expect(probed, isNot(contains("DIRECT")));
    expect(probed, isNot(contains("REJECT")));
    expect(probed, isNot(contains("📢 官网: x")));
  });

  test('探测次数有上限（连接后不能让用户一直等）', () async {
    final many = [for (var i = 0; i < 50; i++) "坏节点$i"];
    MclashNodeAutoPick.debugProxiesOverride = () async => [
      proxyGroup("坏节点0", many),
    ];

    final picked = await MclashNodeAutoPick.ensureUsable();

    expect(picked, isNull);
    // 1 次探当前节点 + 上限次候选
    expect(probed.length, lessThanOrEqualTo(MclashNodeAutoPick.probeLimit + 1));
  });

  test('全都不行 → 明确告知，不假装成功', () async {
    var note = "";
    MclashNodeAutoPick.debugProxiesOverride = () async => [
      proxyGroup("坏节点A", ["坏节点A", "坏节点B"]),
    ];

    final picked = await MclashNodeAutoPick.ensureUsable(onNote: (n) => note = n);

    expect(picked, isNull);
    expect(switched, isEmpty);
    expect(note, contains("没有找到"), reason: '要给出可执行的下一步，而不是静默失败');
  });

  test('没有可识别的选择组 → 安全返回 null', () async {
    MclashNodeAutoPick.debugProxiesOverride = () async => [
      ClashProxiesNode()
        ..name = "GLOBAL"
        ..type = "Selector"
        ..all = ["a", "b"],
    ];
    expect(await MclashNodeAutoPick.ensureUsable(), isNull);
  });

  test('组内嵌套组：探它的当前成员，而不是组名本身', () async {
    MclashNodeAutoPick.debugProbeOverride = (n) async {
      probed.add(n);
      return n == "好节点" ? 60 : -1;
    };
    MclashNodeAutoPick.debugProxiesOverride = () async => [
      proxyGroup("坏节点", ["坏节点", "♻️ 自动选择"]),
      node("坏节点"),
      ClashProxiesNode()
        ..name = "♻️ 自动选择"
        ..type = "URLTest"
        ..now = "好节点"
        ..all = ["好节点"],
    ];

    final picked = await MclashNodeAutoPick.ensureUsable();

    expect(picked, "好节点", reason: '嵌套组应落到它当前选中的真实节点上');
    expect(probed, contains("好节点"));
    expect(probed, isNot(contains("♻️ 自动选择")), reason: '组名不可作为代理名切换');
  });

  group('连接后自动选最优节点（用户要求：连接就自动连延迟最低）', () {
    ClashProxiesNode selGroup(String now, List<String> all) => ClashProxiesNode()
      ..name = "🚀 节点选择"
      ..type = "Selector"
      ..now = now
      ..all = all;

    test('整组测速 → 切到延迟最低的那个', () async {
      var switchedTo = "";
      MclashNodeAutoPick.debugProxiesOverride = () async => [
        selGroup("慢节点", ["慢节点", "快节点", "中节点"]),
      ];
      MclashNodeAutoPick.debugGroupDelayOverride = (g) async => {
        "慢节点": 480,
        "快节点": 42,
        "中节点": 180,
      };
      MclashNodeAutoPick.debugSwitchOverride = (g, n) async {
        switchedTo = n;
        return true;
      };

      final picked = await MclashNodeAutoPick.selectBestOnConnect();

      expect(picked, "快节点");
      expect(switchedTo, "快节点", reason: '必须真的切过去，而不只是算出来');
    });

    test('最优就是当前节点 → 不切换（不做无谓动作）', () async {
      var switched = false;
      MclashNodeAutoPick.debugProxiesOverride = () async => [
        selGroup("快节点", ["快节点", "慢节点"]),
      ];
      MclashNodeAutoPick.debugGroupDelayOverride = (g) async => {
        "快节点": 30,
        "慢节点": 500,
      };
      MclashNodeAutoPick.debugSwitchOverride = (g, n) async {
        switched = true;
        return true;
      };

      expect(await MclashNodeAutoPick.selectBestOnConnect(), isNull);
      expect(switched, isFalse);
    });

    test('跳过 DIRECT / REJECT / 伪节点 / 测不通(<=0) 的条目', () async {
      String switchedTo = "";
      MclashNodeAutoPick.debugProxiesOverride = () async => [
        selGroup("当前", ["当前", "DIRECT", "REJECT", "📢 官网: x", "死节点", "可用节点"]),
      ];
      MclashNodeAutoPick.debugGroupDelayOverride = (g) async => {
        "DIRECT": 1, // 直连当然"最快"，但绝不能当节点选
        "REJECT": 1,
        "📢 官网: x": 1,
        "死节点": 0, // 测不通
        "可用节点": 260,
      };
      MclashNodeAutoPick.debugSwitchOverride = (g, n) async {
        switchedTo = n;
        return true;
      };

      expect(await MclashNodeAutoPick.selectBestOnConnect(), "可用节点");
      expect(switchedTo, "可用节点");
    });

    test('超过 5000ms 视为不可用，不参与选优', () async {
      MclashNodeAutoPick.debugProxiesOverride = () async => [
        selGroup("当前", ["当前", "超时节点"]),
      ];
      MclashNodeAutoPick.debugGroupDelayOverride = (g) async => {
        "超时节点": 5001,
      };
      var note = "";
      final picked = await MclashNodeAutoPick.selectBestOnConnect(
        onNote: (n) => note = n,
      );
      expect(picked, isNull);
      expect(note, contains("没有找到"), reason: '没有可用节点要说清楚');
    });

    test('整组测速没结果 → 退回「保证当前节点可用」，不把用户丢在坏节点', () async {
      MclashNodeAutoPick.debugProxiesOverride = () async => [
        selGroup("坏节点", ["坏节点", "好节点"]),
      ];
      MclashNodeAutoPick.debugGroupDelayOverride = (g) async => {}; // 整组测速失败
      MclashNodeAutoPick.debugProbeOverride = (n) async => n == "好节点" ? 60 : -1;
      MclashNodeAutoPick.debugSwitchOverride = (g, n) async => true;

      expect(await MclashNodeAutoPick.selectBestOnConnect(), "好节点");
    });
  });
}
