import 'package:flutter_test/flutter_test.dart';
import 'package:mclash/app/clash/clash_http_api.dart';
import 'package:mclash/app/modules/clash_setting_manager.dart';
import 'package:mclash/mf/mclash_kernel_sync.dart';
import 'package:mclash/mf/mclash_mode_selection.dart';
import 'package:mclash/mf/mclash_node_autopick.dart';
import 'package:mclash/mf/mclash_nodes_store.dart';

/// 固定节点 vs 自动模式的语义（用户要求）：
///  1. 顶部「切换」和节点列表选节点 → 固定（写 setting.json 的 fixed_node）；
///  2. 主页「自动最优」→ 回到自动模式（不许把自己锁死在一台上），并且**要真的生效**
///     （不能被"用户刚手动选过"挡住）；
///  3. 后台流程（测速结束/订阅刷新/重连）绝不能顺手把固定节点清掉。
void main() {
  late List<(String group, String node)> switched;
  late List<String> fixedWrites;

  ClashProxiesNode group(String name, List<String> all, {String now = ""}) =>
      ClashProxiesNode()
        ..name = name
        ..type = "Selector"
        ..all = all
        ..now = now;

  ClashProxiesNode node(String name) => ClashProxiesNode()
    ..name = name
    ..type = "Vless";

  setUp(() {
    switched = [];
    fixedWrites = [];
    ClashSettingManager.debugSetMode("rule");
    MclashNodeAutoPick.debugFixedNodeValue = "";
    MclashNodeAutoPick.debugSetFixedNodeOverride = (name) async {
      fixedWrites.add(name);
    };
    MclashNodeAutoPick.debugSwitchOverride = (g, n) async {
      switched.add((g, n));
      return true;
    };
    MclashNodeAutoPick.debugGroupDelayOverride = (g) async => {
      "慢节点": 480,
      "快节点": 42,
    };
    MclashNodeAutoPick.debugProbeOverride = (name) async =>
        name == "快节点" ? 42 : -1;
    MclashNodeSelector.debugResetManualPick();
  });

  tearDown(() {
    MclashNodeAutoPick.debugProxiesOverride = null;
    MclashNodeAutoPick.debugProbeOverride = null;
    MclashNodeAutoPick.debugGroupDelayOverride = null;
    MclashNodeAutoPick.debugSwitchOverride = null;
    MclashNodeAutoPick.debugSetFixedNodeOverride = null;
    MclashNodeAutoPick.debugFixedNodeValue = null;
    MclashNodeSelector.debugResetManualPick();
    ClashSettingManager.debugSetMode("rule");
  });

  group('主页「自动最优」= 全量选优 + 回到自动模式', () {
    test('用户主动点：真的切到延迟最低的节点，但不把自己固定住', () async {
      MclashNodeAutoPick.debugProxiesOverride = () async => [
        group("🚀 节点选择", ["慢节点", "快节点"], now: "慢节点"),
      ];

      final picked = await MclashNodeAutoPick.selectBestOnConnect(
        force: true,
        persist: false,
      );

      expect(picked, "快节点");
      expect(
        switched,
        [("🚀 节点选择", "快节点")],
        reason: '「自动最优」必须真的切过去',
      );
      expect(
        fixedWrites,
        isEmpty,
        reason: '自动模式下不存在"用户固定的节点"：下次连接要重新挑最优',
      );
    });

    test('连接后的自动选路仍然固定结果（既有语义不变，别把用户丢来丢去）', () async {
      MclashNodeAutoPick.debugProxiesOverride = () async => [
        group("🚀 节点选择", ["慢节点", "快节点"], now: "慢节点"),
      ];

      expect(await MclashNodeAutoPick.selectBestOnConnect(), "快节点");
      expect(fixedWrites, ["快节点"]);
    });

    test('刚手动选过节点 → 后台自动选路不动；用户主动点「自动最优」则强制生效', () async {
      MclashNodeAutoPick.debugProxiesOverride = () async => [
        group("🚀 节点选择", ["慢节点", "快节点"], now: "慢节点"),
      ];
      MclashNodeSelector.lastManualPickAt = DateTime.now();

      expect(
        await MclashNodeAutoPick.selectBestOnConnect(),
        isNull,
        reason: '后台流程不能抢用户刚手动选的节点',
      );
      expect(switched, isEmpty);

      expect(
        await MclashNodeAutoPick.selectBestOnConnect(
          force: true,
          persist: false,
        ),
        "快节点",
        reason: '用户点「自动最优」是主动操作，不能被上一次手动选择挡住（点了没反应）',
      );
      expect(switched, [("🚀 节点选择", "快节点")]);
    });

    test('固定节点仍有效 → 沿用，不自动换（固定优先）', () async {
      MclashNodeAutoPick.debugFixedNodeValue = "慢节点";
      MclashNodeAutoPick.debugProxiesOverride = () async => [
        group("🚀 节点选择", ["慢节点", "快节点"], now: "慢节点"),
      ];

      expect(await MclashNodeAutoPick.selectBestOnConnect(), isNull);
      expect(switched, isEmpty);
      expect(
        fixedWrites,
        isEmpty,
        reason: '固定节点还在，后台绝不许改它',
      );
    });

    test('固定节点已下架（换订阅）→ 清掉固定并重新自动选（只有这种情况才允许清）', () async {
      MclashNodeAutoPick.debugFixedNodeValue = "已下架的节点";
      MclashNodeAutoPick.debugProxiesOverride = () async => [
        group("🚀 节点选择", ["慢节点", "快节点"], now: "慢节点"),
      ];

      expect(await MclashNodeAutoPick.selectBestOnConnect(), "快节点");
      expect(
        fixedWrites,
        contains(""),
        reason: '固定节点真的不存在了才清',
      );
      expect(fixedWrites.last, "快节点");
    });

    test('组名不会被当成节点固定（自动组名不能进 fixed_node）', () async {
      MclashNodeAutoPick.debugProxiesOverride = () async => [
        group("🚀 节点选择", ["♻️ 自动选择", "真实节点"], now: "♻️ 自动选择"),
        ClashProxiesNode()
          ..name = "♻️ 自动选择"
          ..type = "URLTest"
          ..all = ["真实节点"]
          ..now = "真实节点",
        node("真实节点"),
      ];
      MclashNodeAutoPick.debugGroupDelayOverride = (g) async => {
        "♻️ 自动选择": 10,
        "真实节点": 200,
      };

      expect(await MclashNodeAutoPick.selectBestOnConnect(), "真实节点");
      expect(switched, [("🚀 节点选择", "真实节点")]);
      expect(
        fixedWrites,
        ["真实节点"],
        reason: 'fixed_node 必须是真实节点名，否则下次连接没法按候选校验',
      );
    });
  });

  group('当前节点名（内核读不到时保留上一次，不许刷成空白）', () {
    test('空值不覆盖上一次的值，也不白刷 UI', () {
      final store = MclashNodesStore.instance;
      store.debugResetCurrentNode();
      var notified = 0;
      void onNotify() => notified++;
      store.addListener(onNotify);
      addTearDown(() {
        store.removeListener(onNotify);
        store.debugResetCurrentNode();
      });

      store.setCurrentNodeName("香港线路7");
      expect(store.currentNodeName, "香港线路7");
      expect(notified, 1);

      store.setCurrentNodeName("");
      store.setCurrentNodeName("   ");
      expect(
        store.currentNodeName,
        "香港线路7",
        reason: '内核暂时读不到时保留上一次的节点名（真机：闪一下就空白）',
      );
      expect(notified, 1, reason: '值没变就不该刷 UI');

      store.setCurrentNodeName(" 美国线路7 ");
      expect(store.currentNodeName, "美国线路7");
      expect(notified, 2);
    });
  });

  group('内核同步（跟随内核，但别拿"随便一个节点"覆盖固定节点）', () {
    test('当前节点取生效组的 now，而不是列表里最后一个节点名', () {
      final proxies = [
        group("🚀 节点选择", ["美国线路7", "香港线路7"], now: "美国线路7"),
        node("美国线路7"),
        node("香港线路7"),
      ];
      expect(
        MclashKernelSync.currentNodeName(proxies),
        "美国线路7",
        reason: '旧实现返回列表里最后一个名字（随机节点），会把固定节点改坏',
      );
    });

    test('内核停在内置目标（DIRECT）→ 返回空串，不覆盖固定节点', () {
      final proxies = [
        ClashProxiesNode()
          ..name = "GLOBAL"
          ..type = "Selector"
          ..all = ["DIRECT"]
          ..now = "DIRECT",
        ClashProxiesNode()..name = "DIRECT"..type = "Direct",
      ];
      expect(MclashKernelSync.currentNodeName(proxies), "");
    });

    test('没有策略组的退化输入 → 仍取最后一个真实节点（不崩、不返回内置名）', () {
      expect(
        MclashKernelSync.currentNodeName([node("GLOBAL"), node("香港01")]),
        "香港01",
      );
      expect(MclashKernelSync.currentNodeName([node("DIRECT")]), "");
      expect(MclashKernelSync.currentNodeName([]), "");
    });
  });
}
