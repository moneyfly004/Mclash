import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mclash/app/clash/clash_http_api.dart';
import 'package:mclash/app/modules/clash_setting_manager.dart';
import 'package:mclash/mf/mclash_mode_selection.dart';
import 'package:mclash/mf/mclash_node_autopick.dart';
import 'package:mclash/mf/mclash_nodes_store.dart';

/// 连点节点（A→B）的时序回归测试。
///
/// 缺陷：`select()` 先把固定节点/界面状态落下，然后各自 `await` 组查询和内核
/// PUT，两次调用之间没有顺序保证 —— 先点的 A 可能最后才把 PUT 落到内核上，
/// 结果「内核 = A，界面/固定节点 = B」。另外 `lastSelectDeferred` 是共享的
/// static，谁最后写谁说了算，调用方会读到另一次调用的结论。
///
/// 修复：同步段领取单调序号，只有最新选择能写内核；写入串行化；deferred
/// 等 per-call 结果由 `selectDetailed()` 返回。
void main() {
  List<ClashProxiesNode> proxies() => [
    ClashProxiesNode()
      ..name = "🚀 节点选择"
      ..type = "Selector"
      ..all = const ["节点A", "节点B", "节点C"]
      ..now = "节点A",
  ];

  setUp(() {
    ClashSettingManager.debugSetMode("rule");
    MclashNodesStore.instance.debugResetCurrentNode();
    MclashNodeAutoPick.debugFixedNodeValue = "";
    MclashNodeAutoPick.debugSetFixedNodeOverride = (name) async {};
    MclashNodeSelector.debugProxiesOverride = () async => proxies();
    MclashNodeSelector.debugSetNodeOverride = (group, node) async => null;
    MclashNodeSelector.lastSelectDeferred = false;
  });

  tearDown(() {
    MclashNodeSelector.debugProxiesOverride = null;
    MclashNodeSelector.debugSetNodeOverride = null;
    MclashNodeAutoPick.debugSetFixedNodeOverride = null;
    MclashNodeAutoPick.debugFixedNodeValue = null;
    MclashNodesStore.instance.debugResetCurrentNode();
    ClashSettingManager.debugSetMode("rule");
  });

  test('A→B 连点且 A 的组查询被拖慢：内核只写 B，A 不碰共享提示位', () async {
    final writes = <String>[];
    final fixed = <String>[];
    final gateA = Completer<void>();
    var lookups = 0;
    MclashNodeSelector.debugProxiesOverride = () async {
      lookups++;
      if (lookups == 1) {
        // 第一次是 A：卡在"查组"这一拍（真机是全量测速把控制口挤到超时）。
        await gateA.future;
        // 而且等它回来时内核已经"不可用"了 —— 旧实现会因此写
        // lastSelectDeferred = true，把 B 那次成功应用的事实盖掉。
        return <ClashProxiesNode>[];
      }
      return proxies();
    };
    MclashNodeSelector.debugSetNodeOverride = (group, node) async {
      writes.add(node);
      return null;
    };
    MclashNodeAutoPick.debugSetFixedNodeOverride = (name) async {
      fixed.add(name);
    };

    final aFuture = MclashNodeSelector.selectDetailed("节点A");
    // 让 A 同步段跑完、走到组查询并卡住。
    await Future<void>.delayed(Duration.zero);
    final bFuture = MclashNodeSelector.selectDetailed("节点B");

    final b = await bFuture;
    expect(writes, ["节点B"], reason: 'B 是当前最新选择，内核必须切到 B');
    expect(b.superseded, isFalse);
    expect(b.deferred, isFalse);
    expect(b.applied, isTrue);
    expect(MclashNodeSelector.lastSelectDeferred, isFalse);

    gateA.complete();
    final a = await aFuture;

    expect(writes, ["节点B"], reason: 'A 已经是旧选择：绝不能再把内核 PUT 到 A 上（缺陷本体）');
    expect(a.superseded, isTrue, reason: 'per-call 结果要能告诉调用方"这次已过期"');
    expect(a.deferred, isFalse, reason: '过期调用不得把"连接后生效"写到共享位');
    expect(
      MclashNodeSelector.lastSelectDeferred,
      isFalse,
      reason: '共享位必须仍描述最新一次（B），不能被迟到的 A 改写',
    );
    expect(MclashNodesStore.instance.currentNodeName, "节点B");
    expect(fixed.last, "节点B", reason: '固定节点必须是用户最后点的那个');
  });

  test('A 的内核写入被拖慢、B 随后点选：写入串行，内核最终停在 B', () async {
    final writes = <String>[];
    final fixed = <String>[];
    final gateA = Completer<void>();
    MclashNodeSelector.debugSetNodeOverride = (group, node) async {
      if (node == "节点A") {
        // A 的 PUT 已经在飞，无法取消（模拟控制口被占住）。
        await gateA.future;
      }
      writes.add(node);
      return null;
    };
    MclashNodeAutoPick.debugSetFixedNodeOverride = (name) async {
      fixed.add(name);
    };

    final aFuture = MclashNodeSelector.selectDetailed("节点A");
    // A 已经进入内核写入，但被 gateA 卡住。
    await Future<void>.delayed(Duration.zero);
    expect(writes, isEmpty, reason: '夹具前提：A 的写入还没落地');

    final bFuture = MclashNodeSelector.selectDetailed("节点B");
    await Future<void>.delayed(Duration.zero);
    expect(
      writes,
      isEmpty,
      reason: 'B 的 PUT 必须排在 A 之后：否则先发但很慢的 A 写入会反超，把内核改回 A',
    );

    gateA.complete();
    final a = await aFuture;
    final b = await bFuture;

    expect(writes, ["节点A", "节点B"], reason: '串行化后最新选择最后落子，内核最终状态 = B（不是先点的 A）');
    expect(a.superseded, isTrue, reason: 'A 被 B 取代，调用方不该再弹旧提示');
    expect(b.superseded, isFalse);
    expect(b.applied, isTrue);
    expect(MclashNodeSelector.lastSelectDeferred, isFalse);
    expect(fixed.last, "节点B");
  });

  test('老入口 select() 同样守序：A→B 连点后内核只能停在 B', () async {
    final writes = <String>[];
    final gateA = Completer<void>();
    var lookups = 0;
    MclashNodeSelector.debugProxiesOverride = () async {
      lookups++;
      if (lookups == 1) {
        await gateA.future;
      }
      return proxies();
    };
    MclashNodeSelector.debugSetNodeOverride = (group, node) async {
      writes.add(node);
      return null;
    };

    final aFuture = MclashNodeSelector.select("节点A");
    await Future<void>.delayed(Duration.zero);
    final bErr = await MclashNodeSelector.select("节点B");

    expect(bErr, isNull);
    expect(writes, ["节点B"]);

    gateA.complete();
    final aErr = await aFuture;
    expect(aErr, isNull, reason: '被取代不是错误：内核已由最新选择接管（老 API 必须保持这个语义）');
    expect(writes, ["节点B"], reason: '旧调用的 PUT 不能再落到内核上');
    expect(MclashNodeSelector.lastSelectDeferred, isFalse);
    expect(MclashNodesStore.instance.currentNodeName, "节点B");
  });

  test('deferred 是 per-call：B 已应用不会改写 A 的「连接后生效」结果', () async {
    ClashSettingManager.debugSetMode("rule");
    final fixed = <String>[];
    MclashNodeAutoPick.debugSetFixedNodeOverride = (name) async {
      fixed.add(name);
    };

    // A：内核没跑 → 这次调用的结论是"连接后生效"。
    MclashNodeSelector.debugProxiesOverride = () async => <ClashProxiesNode>[];
    final a = await MclashNodeSelector.selectDetailed("节点C");
    expect(a.deferred, isTrue);
    expect(a.superseded, isFalse);
    expect(a.applied, isFalse);
    expect(MclashNodeSelector.lastSelectDeferred, isTrue);

    // B：内核可用 → 真正切成功。
    final writes = <String>[];
    MclashNodeSelector.debugProxiesOverride = () async => proxies();
    MclashNodeSelector.debugSetNodeOverride = (group, node) async {
      writes.add(node);
      return null;
    };
    final b = await MclashNodeSelector.selectDetailed("节点B");

    expect(writes, ["节点B"]);
    expect(b.deferred, isFalse);
    expect(b.applied, isTrue);
    expect(
      MclashNodeSelector.lastSelectDeferred,
      isFalse,
      reason: '共享位只描述最新一次调用',
    );
    expect(
      a.deferred,
      isTrue,
      reason: 'A 的结果必须留在 A 的返回值里（旧实现读共享 static 时这里会是 false）',
    );
    expect(fixed, ["节点C", "节点B"], reason: '两次的固定节点都按点击顺序写下');
  });
}
