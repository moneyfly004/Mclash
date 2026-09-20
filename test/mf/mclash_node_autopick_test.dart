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

  group('自动选 vs 固定节点（用户问的「什么时候自动、什么时候固定」）', () {
    test('没固定过 → 自动选择', () {
      expect(
        MclashNodeAutoPick.shouldAutoSelect(
          fixed: "",
          candidates: const ["香港 01", "日本 01"],
        ),
        isTrue,
        reason: '首次连接/点过「自动最优」之后应当自动选最优',
      );
    });

    test('固定了且节点仍在 → 沿用，不自动切换', () {
      expect(
        MclashNodeAutoPick.shouldAutoSelect(
          fixed: "香港 01",
          candidates: const ["香港 01", "日本 01"],
        ),
        isFalse,
        reason: '用户选过的节点必须被尊重，不能每次连接都换掉',
      );
    });

    test('固定的节点已不存在（换订阅/下架）→ 回到自动选择', () {
      expect(
        MclashNodeAutoPick.shouldAutoSelect(
          fixed: "已下架的节点",
          candidates: const ["香港 01", "日本 01"],
        ),
        isTrue,
      );
    });

    test('固定节点名前后的空格不影响判断', () {
      expect(
        MclashNodeAutoPick.shouldAutoSelect(
          fixed: "  香港 01  ",
          candidates: const ["香港 01"],
        ),
        isFalse,
      );
    });
  });

  group('并发保护（竞态回归）', () {
    test('同时触发两次自动选路，只真正跑一次（复用同一个 Future）', () async {
      var groupDelayCalls = 0;
      final proxies = [
        ClashProxiesNode()
          ..name = "🚀 节点选择"
          ..type = "Selector"
          ..all = ["香港 01", "日本 01"]
          ..now = "香港 01",
      ];
      MclashNodeAutoPick.debugProxiesOverride = () async => proxies;
      MclashNodeAutoPick.debugGroupDelayOverride = (group) async {
        groupDelayCalls++;
        await Future<void>.delayed(const Duration(milliseconds: 30));
        return {"香港 01": 200, "日本 01": 50};
      };
      MclashNodeAutoPick.debugSwitchOverride = (g, n) async => true;

      final a = MclashNodeAutoPick.selectBestOnConnect();
      final b = MclashNodeAutoPick.selectBestOnConnect();
      await Future.wait([a, b]);

      expect(
        groupDelayCalls,
        1,
        reason: '两次并发选路只该测一次组延迟（否则会各自切换、节点跳来跳去）',
      );

      MclashNodeAutoPick.debugProxiesOverride = null;
      MclashNodeAutoPick.debugGroupDelayOverride = null;
      MclashNodeAutoPick.debugSwitchOverride = null;
    });
  });

  group('连接后不整组测速（连接后卡顿回归）', connectTimeGroupDelayTests);
}

/// 连接后**不再**让内核整组测速（用户实测「连接之后非常卡，根本点不动」）。
///
/// 旧行为：连接成功 → 自动选路 → `ClashHttpApi.getGroupDelay(组名)` —— 那是让
/// **内核一次性并发测整组**（订阅动辄 300~400 个节点）。内核此刻正在服务真实流量，
/// 再被自家测速压满，控制和界面请求全部排队，用户点什么都点不动。
///
/// 现在的口径：小组照旧整组测；大组优先用延迟缓存；没有缓存时只测极少数候选。
void connectTimeGroupDelayTests() {
  late int groupDelayCalls;
  late List<String> probed;

  setUp(() {
    groupDelayCalls = 0;
    probed = [];
    MclashNodeAutoPick.debugGroupDelayOverride = (group) async {
      groupDelayCalls++;
      return {"从来没测过": 1};
    };
    MclashNodeAutoPick.debugProbeOverride = (node) async {
      probed.add(node);
      return 80;
    };
    MclashNodeAutoPick.debugSwitchOverride = (group, node) async => true;
    MclashNodeAutoPick.debugFixedNodeValue = "";
  });

  tearDown(() {
    MclashNodeAutoPick.debugGroupDelayOverride = null;
    MclashNodeAutoPick.debugProbeOverride = null;
    MclashNodeAutoPick.debugSwitchOverride = null;
    MclashNodeAutoPick.debugFixedNodeValue = null;
  });

  ClashProxiesNode group(String now, List<String> all) => ClashProxiesNode()
    ..name = "🚀 节点选择"
    ..type = "Selector"
    ..now = now
    ..all = all;

  test('大组（>16 个候选）+ 有延迟缓存 → 一次都不整组测速', () async {
    final names = [for (var i = 0; i < 40; i++) "节点$i"];
    MclashNodeAutoPick.debugProxiesOverride = () async => [
      group("节点0", names),
      for (final n in names)
        ClashProxiesNode()
          ..name = n
          ..type = "Vless",
    ];

    final cached = <String, int>{"节点7": 30, "节点8": 300};
    final picked = await MclashNodeAutoPick.selectBestOnConnect(
      cachedLatency: cached,
    );

    expect(
      groupDelayCalls,
      0,
      reason: '整组测速会让内核并发测 40 个节点 —— 连接后卡死的元凶',
    );
    expect(picked, "节点7", reason: '应当用缓存里延迟最低的那个');
  });

  test('大组 + 没有缓存 → 只测少数候选，绝不整组', () async {
    final names = [for (var i = 0; i < 40; i++) "节点$i"];
    MclashNodeAutoPick.debugProxiesOverride = () async => [
      group("节点0", names),
      for (final n in names)
        ClashProxiesNode()
          ..name = n
          ..type = "Vless",
    ];

    await MclashNodeAutoPick.selectBestOnConnect(cachedLatency: const {});

    expect(groupDelayCalls, 0);
    expect(
      probed.length,
      lessThanOrEqualTo(MclashNodeAutoPick.probeLimit),
      reason: '最多测 ${MclashNodeAutoPick.probeLimit} 个候选（而不是整组）',
    );
  });

  test('小组（≤16 个候选）仍然整组测速（结果最准，内核压力可控）', () async {
    final names = [for (var i = 0; i < 6; i++) "小组节点$i"];
    MclashNodeAutoPick.debugProxiesOverride = () async => [
      group("小组节点0", names),
      for (final n in names)
        ClashProxiesNode()
          ..name = n
          ..type = "Vless",
    ];

    await MclashNodeAutoPick.selectBestOnConnect(cachedLatency: const {});

    expect(groupDelayCalls, 1, reason: '小组不受影响，仍走整组测速');
    expect(probed, isEmpty);
  });
}
