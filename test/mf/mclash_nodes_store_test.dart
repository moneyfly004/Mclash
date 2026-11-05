import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mclash/mf/mclash_node.dart';
import 'package:mclash/mf/mclash_nodes_store.dart';
import 'package:mclash/mf/mclash_speed_tester.dart';

/// 回归：测速与节点载入/单节点测速之间的竞态。
///
/// 三个已确认的缺陷：
/// 1. 测速中 load() 直接把 _nodes 换掉 → 正在写入的测量结果全丢，却仍记「新鲜」并
///    把没有延迟数据的新列表写进缓存；
/// 2. testOne() 走 testAll([node])，推进批次代际 → 取消正在跑的全量测速，并把
///    _testing/_testTotal 改成 1/1；
/// 3. 被连接会话中止的全量测速仍被记为「新鲜」。
void main() {
  final store = MclashNodesStore.instance;

  List<MclashNode> makeNodes(List<String> names) => [
    for (var i = 0; i < names.length; i++)
      MclashNode(
        name: names[i],
        type: "ss",
        server: "10.0.0.${i + 1}",
        port: 1000 + i,
      ),
  ];

  setUp(() {
    store.debugResetLoadState();
    store.debugResetCurrentNode();
    store.debugResetLastFullTestAt();
    store.debugSetNodes([], loading: false);
    store.clearAutoPickNote();
    MclashSpeedTester.instance.inFlight.clear();
    MclashSpeedTester.debugKernelAvailableOverride = () async => false;
    MclashSpeedTester.debugProbeOverride = (n) async => 50;
    MclashSpeedTester.debugKernelDelayOverride = null;
    MclashNodesStore.debugLoadNodesOverride = null;
    MclashNodesStore.debugCacheSaveOverride = null;
  });

  tearDown(() {
    MclashNodesStore.debugLoadNodesOverride = null;
    MclashNodesStore.debugCacheSaveOverride = null;
    MclashSpeedTester.debugProbeOverride = null;
    MclashSpeedTester.debugKernelAvailableOverride = null;
    MclashSpeedTester.debugKernelDelayOverride = null;
    MclashSpeedTester.instance.inFlight.clear();
    store.debugSetNodes([], loading: false);
    store.debugResetLoadState();
    store.debugResetLastFullTestAt();
  });

  test('测速中 load() 延后执行：不换列表、不丢测量结果，结束后再载入', () async {
    final oldNodes = makeNodes(["旧-a", "旧-b"]);
    store.debugSetNodes(oldNodes);

    final gate = Completer<void>();
    MclashSpeedTester.debugProbeOverride = (n) async {
      await gate.future;
      return 100;
    };

    final newNodes = makeNodes(["新-x", "新-y"]);
    var loads = 0;
    var savedBeforeLoad = false;
    final saved = <List<MclashNode>>[];
    MclashNodesStore.debugLoadNodesOverride = () async {
      loads++;
      savedBeforeLoad = saved.isNotEmpty;
      return newNodes;
    };
    MclashNodesStore.debugCacheSaveOverride = (nodes) async {
      saved.add(nodes.toList());
    };

    final batch = store.testAll();
    await Future<void>.delayed(Duration.zero);
    expect(store.isTesting, isTrue);

    var loadCompleted = false;
    final pendingLoad = store.load().then((_) => loadCompleted = true);

    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(loads, 0, reason: '测速进行中不能执行 load');
    expect(
      identical(store.nodes, oldNodes),
      isTrue,
      reason: '测速中换列表会把正在写入的测量结果整批丢掉',
    );
    expect(loadCompleted, isFalse, reason: '被延后的 load 应该等测速收尾');

    gate.complete();
    await batch.timeout(const Duration(seconds: 5));
    await pendingLoad.timeout(const Duration(seconds: 5));

    expect(loads, 1, reason: '测速结束后必须补跑被延后的 load');
    expect(
      savedBeforeLoad,
      isTrue,
      reason: '必须先落盘这一轮结果，再载入新列表，新列表才能从缓存里套上测量值',
    );
    expect(identical(store.nodes, newNodes), isTrue);
    expect(store.isTesting, isFalse);
    expect(store.debugLastFullTestAt, isNotNull, reason: '跑完的一轮才算新鲜');

    expect(saved, isNotEmpty);
    expect(saved.last.map((n) => n.name).toList(), [
      "旧-a",
      "旧-b",
    ], reason: '缓存必须写刚测完的列表，而不是换上去的新列表');
    expect(
      saved.last.every((n) => n.latencyMs == 100 && n.online),
      isTrue,
      reason: '缓存里必须带这一轮的真实测量值',
    );
  });

  test('单节点测速期间 load() 同样延后到测速结束，不会卡住', () async {
    final oldNodes = makeNodes(["单-旧"]);
    store.debugSetNodes(oldNodes);

    final gate = Completer<void>();
    MclashSpeedTester.debugProbeOverride = (n) async {
      await gate.future;
      return 77;
    };

    final newNodes = makeNodes(["单-新"]);
    var loads = 0;
    MclashNodesStore.debugLoadNodesOverride = () async {
      loads++;
      return newNodes;
    };
    final saved = <List<MclashNode>>[];
    MclashNodesStore.debugCacheSaveOverride = (nodes) async {
      saved.add(nodes.toList());
    };

    final single = store.testOne(oldNodes.first);
    await Future<void>.delayed(Duration.zero);
    expect(store.isTesting, isTrue);

    var loadCompleted = false;
    final pendingLoad = store.load().then((_) => loadCompleted = true);
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(loads, 0, reason: '单节点测速进行中不能执行 load');
    expect(loadCompleted, isFalse);
    expect(identical(store.nodes, oldNodes), isTrue);

    gate.complete();
    await single.timeout(const Duration(seconds: 5));
    await pendingLoad.timeout(const Duration(seconds: 5));

    expect(loads, 1, reason: '单节点测速收尾后必须补跑被延后的 load');
    expect(identical(store.nodes, newNodes), isTrue);
    expect(saved, isNotEmpty);
    expect(
      saved.last.single.latencyMs,
      77,
      reason: '必须先落盘这次测量，再载入新列表',
    );
    expect(store.isTesting, isFalse);
  });

  test('连接会话中止的全量测速不记为新鲜，且进度必须归零', () async {
    final nodes = makeNodes(List.generate(12, (i) => "中止-$i"));
    store.debugSetNodes(nodes);
    MclashNodesStore.debugCacheSaveOverride = (nodes) async {};

    final gate = Completer<void>();
    final concurrentStarted = Completer<void>();
    var started = 0;
    MclashSpeedTester.debugProbeOverride = (n) async {
      started++;
      if (started == MclashSpeedTester.maxConcurrent &&
          !concurrentStarted.isCompleted) {
        concurrentStarted.complete();
      }
      await gate.future;
      return 100;
    };

    final batch = store.testAll();
    await concurrentStarted.future.timeout(const Duration(seconds: 5));
    expect(store.isTesting, isTrue);

    // 模拟连接会话结束（断开/内核被撤）：worker 下一轮循环就会收工。
    store.debugBumpConnectEpoch();
    gate.complete();
    await batch.timeout(const Duration(seconds: 5));

    expect(store.isTesting, isFalse);
    expect(store.testing, 0);
    expect(
      store.debugLastFullTestAt,
      isNull,
      reason: '被中止的半轮不能冒充「3 分钟内的新鲜全量结果」',
    );
    expect(
      nodes.where((n) => n.latencyMs > 0).length,
      lessThan(nodes.length),
      reason: '必须真的提前中止，而不是把 12 个节点跑完',
    );
  });

  test('testOne() 不取消进行中的全量测速，也不清空进度计数', () async {
    final nodes = makeNodes(List.generate(8, (i) => "批量-$i"));
    store.debugSetNodes(nodes);
    MclashNodesStore.debugCacheSaveOverride = (nodes) async {};

    final gate = Completer<void>();
    final concurrentStarted = Completer<void>();
    final startedNames = <String>{};
    MclashSpeedTester.debugProbeOverride = (n) async {
      if (n.name == "single") {
        return 42;
      }
      startedNames.add(n.name);
      if (startedNames.length == MclashSpeedTester.maxConcurrent &&
          !concurrentStarted.isCompleted) {
        concurrentStarted.complete();
      }
      await gate.future;
      return 100;
    };

    final batch = store.testAll();
    await concurrentStarted.future.timeout(const Duration(seconds: 5));
    expect(store.testTotal, 8);
    expect(store.testing, 8);

    await store
        .testOne(
          MclashNode(name: "single", type: "ss", server: "9.9.9.9", port: 443),
        )
        .timeout(const Duration(seconds: 5));

    expect(store.isTesting, isTrue, reason: '全量测速必须还在跑');
    expect(store.testTotal, 8, reason: '单节点测速不能把总计数改成 1');
    expect(store.testing, 8, reason: '单节点测速不能把进行中计数清零');
    expect(
      store.isNodeInFlight(startedNames.first),
      isTrue,
      reason: '单节点测速不能清掉全量测速正在探测的节点',
    );

    gate.complete();
    await batch.timeout(const Duration(seconds: 5));

    expect(
      nodes.every((n) => n.latencyMs == 100),
      isTrue,
      reason: '单节点测速推进批次代际会取消全量测速，剩下的节点就测不到了',
    );
    expect(MclashSpeedTester.lastSuccessCount, 8);
    expect(store.isTesting, isFalse);
  });

  test('测速抛异常也必须清空 testing 状态', () async {
    store.debugSetNodes(makeNodes(["异常-a"]));
    MclashNodesStore.debugCacheSaveOverride = (nodes) async {};
    MclashSpeedTester.debugProbeOverride = (n) async {
      throw StateError("probe boom");
    };

    await expectLater(store.testAll(), throwsStateError);

    expect(store.isTesting, isFalse);
    expect(store.testing, 0);
    expect(store.debugLastFullTestAt, isNull);
  });
}
