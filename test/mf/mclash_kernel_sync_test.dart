import 'package:flutter_test/flutter_test.dart';
import 'package:mclash/app/clash/clash_config.dart';
import 'package:mclash/app/clash/clash_http_api.dart';
import 'package:mclash/app/modules/clash_setting_manager.dart';
import 'package:mclash/mf/mclash_kernel_sync.dart';
import 'package:mclash/mf/mclash_mode_selection.dart';
import 'package:mclash/mf/mclash_node_autopick.dart';
import 'package:mclash/mf/mclash_nodes_store.dart';

void main() {
  final store = MclashNodesStore.instance;

  ClashProxiesNode node(String name, {List<String> all = const []}) {
    final n = ClashProxiesNode();
    n.name = name;
    n.type = all.isEmpty ? "Vmess" : "Selector";
    n.all = all;
    n.now = all.isEmpty ? "" : (all.last);
    return n;
  }

  setUp(() {
    MclashKernelSync.debugReset();
    MclashKernelSync.debugProxiesOverride = null;
    MclashKernelSync.debugKernelModeOverride = null;
    MclashNodeAutoPick.debugSetFixedNodeOverride = (v) async {
      MclashNodeAutoPick.debugFixedNodeValue = v;
    };
    MclashNodeAutoPick.debugFixedNodeValue = "";
    ClashSettingManager.debugSetMode(ClashConfigsMode.rule.name);
    store.clearAutoPickNote();
  });

  tearDown(() {
    MclashKernelSync.debugReset();
    MclashKernelSync.debugProxiesOverride = null;
    MclashKernelSync.debugKernelModeOverride = null;
    MclashNodeAutoPick.debugSetFixedNodeOverride = null;
    MclashNodeAutoPick.debugFixedNodeValue = "";
    ClashSettingManager.debugSetMode(ClashConfigsMode.rule.name);
  });

  test('当前节点名取链路里最后一个真实节点（跳过 GLOBAL 这类内置名）', () {
    expect(
      MclashKernelSync.currentNodeName([node("GLOBAL"), node("香港01")]),
      "香港01",
    );
    expect(MclashKernelSync.currentNodeName([node("DIRECT")]), "");
    expect(MclashKernelSync.currentNodeName([]), "");
  });

  test('面板里把模式改成全局 → App 的模式跟着变（规则/全局/直连那排）', () async {
    MclashKernelSync.debugKernelModeOverride = () async => "global";
    MclashKernelSync.debugProxiesOverride = () async => [node("香港01")];

    await MclashKernelSync.syncFromKernel();

    expect(
      ClashSettingManager.getConfigsMode(),
      ClashConfigsMode.global,
      reason: '面板切了全局，App 必须跟着显示全局（用户说「切了没反应」就是这个）',
    );
  });

  test('面板里换了节点：固定节点跟随内核，不再和内核对着干', () async {
    MclashNodeAutoPick.debugFixedNodeValue = "日本02";
    MclashKernelSync.debugProxiesOverride = () async => [node("香港01")];

    await MclashKernelSync.syncFromKernel();
    expect(MclashNodeAutoPick.debugFixedNodeValue, "日本02");

    MclashKernelSync.debugProxiesOverride = () async => [node("美国03")];
    await MclashKernelSync.syncFromKernel();

    expect(
      MclashNodeAutoPick.debugFixedNodeValue,
      "美国03",
      reason: '不跟随的话，下次连接会被「固定节点」改回去，用户在面板里等于白切',
    );
  });

  test('面板换了节点 → 过期的「已回到固定节点 xxx」提示被清掉', () async {
    store.autoPickNote = "已回到固定节点：日本02";
    MclashKernelSync.debugProxiesOverride = () async => [node("香港01")];
    await MclashKernelSync.syncFromKernel(); 

    MclashKernelSync.debugProxiesOverride = () async => [node("美国03")];
    await MclashKernelSync.syncFromKernel();

    expect(
      store.autoPickNote,
      isEmpty,
      reason: '提示还在的话，屏幕上写着旧节点名，和刚切完的节点自相矛盾',
    );
  });

  test('内核节点没变 → 什么都不动（提示保留、固定节点不动）', () async {
    MclashNodeAutoPick.debugFixedNodeValue = "香港01";
    store.autoPickNote = "订阅里有 3 个新节点还没进内核，正在重载…";
    MclashKernelSync.debugProxiesOverride = () async => [node("香港01")];

    await MclashKernelSync.syncFromKernel();
    await MclashKernelSync.syncFromKernel();

    expect(MclashNodeAutoPick.debugFixedNodeValue, "香港01");
    expect(store.autoPickNote, isNotEmpty, reason: '与节点无关的提示不该被误清');
  });

  test('用户手动切节点后，过期的自动选路提示立即清掉（不用等 5 秒）', () async {
    store.autoPickNote = "已回到固定节点：日本02";
    MclashNodeSelector.debugSetNodeOverride = (group, name) async => null;
    MclashNodeSelector.debugProxiesOverride = () async => [node("香港01")];

    await MclashNodeSelector.select("香港01", manual: true);

    expect(store.autoPickNote, isEmpty);
    MclashNodeSelector.debugSetNodeOverride = null;
    MclashNodeSelector.debugProxiesOverride = null;
  });
}
