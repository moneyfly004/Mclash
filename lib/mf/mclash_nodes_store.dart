
library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:mclash/app/local_services/vpn_service.dart';
import 'package:mclash/app/modules/profile_manager.dart';
import 'package:mclash/app/utils/log.dart';
import 'package:mclash/mf/mclash_account_service.dart';
import 'package:mclash/mf/mclash_node.dart';
import 'package:mclash/mf/mclash_i18n.dart';
import 'package:mclash/mf/mclash_node_autopick.dart';
import 'package:mclash/mf/mclash_nodes_cache.dart';
import 'package:mclash/mf/mclash_speed_tester.dart';
import 'package:mclash/mf/mclash_subscription_service.dart';
import 'package:mclash/mf/mclash_subscription_nodes.dart';
import 'package:mclash/mf/mclash_subscription_notice.dart';
import 'package:libclash_vpn_service/state.dart';

class MclashNodesStore extends ChangeNotifier {
  MclashNodesStore._();

  static final MclashNodesStore instance = MclashNodesStore._();

  List<MclashNode> _nodes = [];
  bool _loading = false;

  int _testing = 0;
  int _testTotal = 0;

  int _connectEpoch = 0;

  /// 已经为哪个 epoch 启动了「连接后选路」流程（避免重复触发）。
  int _connectFlowEpoch = -1;


  bool _initialized = false;

  String? pendingCountryFilter;

  @visibleForTesting
  void debugSetNodes(List<MclashNode> nodes, {bool loading = false}) {
    _nodes = nodes;
    _loading = loading;
    _invalidateDerived();
    notifyListeners();
  }

  void requestCountryFilter(String? code) {
    pendingCountryFilter = code;
    notifyListeners();
  }

  List<MclashNode> get nodes => _nodes;
  bool get loading => _loading;
  int get testing => _testing;
  int get testTotal => _testTotal;
  bool get isTesting => _testing > 0;

  /// 该节点此刻是否正在被探测（界面只给这些行显示转圈）。
  bool isNodeInFlight(String name) =>
      MclashSpeedTester.instance.inFlight.contains(name);

  Map<String, int>? _bestLatencyCache;
  List<String>? _countriesCache;
  List<String>? _topCountriesCache;

  void _invalidateDerived() {
    _bestLatencyCache = null;
    _countriesCache = null;
    _topCountriesCache = null;
  }

  Map<String, int> get bestLatencyByCountry =>
      _bestLatencyCache ??= MclashSpeedTester.bestLatencyByCountry(_nodes);

  List<String> get countries => _countriesCache ??= _computeCountries();

  List<String> _computeCountries() {
    final set = <String>{};
    for (final n in _nodes) {
      set.add(n.countryCode ?? "XX");
    }
    final list = set.toList();
    list.sort(_byWeightThenCode);
    return list;
  }

  static int _byWeightThenCode(String a, String b) {
    final wa = a == "XX" ? 9999 : MclashNodeCountryWeight.of(a);
    final wb = b == "XX" ? 9999 : MclashNodeCountryWeight.of(b);
    if (wa != wb) {
      return wa.compareTo(wb);
    }
    return a.compareTo(b);
  }

  List<String> topCountries({int limit = 6}) {
    final cached = _topCountriesCache;
    if (cached != null && cached.length == limit) {
      return cached;
    }
    final latency = bestLatencyByCountry;
    final measured = countries.where(latency.containsKey).toList()
      ..sort((a, b) {
        final d = latency[a]!.compareTo(latency[b]!);
        return d != 0 ? d : _byWeightThenCode(a, b);
      });
    final rest = countries.where((c) => !latency.containsKey(c)).toList();
    final out = [...measured, ...rest].take(limit).toList();
    _topCountriesCache = out;
    return out;
  }

  void init() {
    if (_initialized) {
      return;
    }
    _initialized = true;
    ProfileManager.onEventUpdate.add(_onProfileUpdated);
    ProfileManager.onEventCurrentChanged.add(_onProfileChanged);
    VPNService.onEventStateChanged.add(_onVpnStateChanged);

    unawaited(load());
  }

  void _onProfileUpdated(String id, bool finish) {
    if (finish) {
      unawaited(load(autoTestIfNoCache: true));
    }
  }

  void _onProfileChanged(String id) => unawaited(load());

  void _onVpnStateChanged(
    FlutterVpnServiceState state,
    Map<String, String> params,
  ) {
    MclashSpeedTester.instance.resetKernelCache();

    // epoch 只代表「这一次连接」：**离开连接态**（断开/被系统撤销）才算一次结束。
    //
    // 以前是每个状态事件都 `_connectEpoch++` —— 而内核在连接过程中会连发好几个
    // 状态（connecting → connected → reasserting → connected…）。于是连上之后那段
    // 全量测速（500+ 节点要跑好几分钟）期间随便来一个事件，`_onConnected` 里的
    // `epoch != _connectEpoch` 就成立并直接 return：**自动选最优节点整段被作废**、
    // 节点也不会被固定下来。
    // 真机表现就是「连上了，主页当前节点迟迟不定 / 一直不是最优节点」。
    if (state == FlutterVpnServiceState.connected) {
      // 同一次连接里内核可能连发多次 connected（重载/自愈）：只处理第一次，
      // 否则会重复跑全量测速（500+ 节点）——既拖慢选路也把机器拖卡。
      if (_connectFlowEpoch == _connectEpoch) {
        Log.i("MclashNodesStore: 本次连接的选路已在进行，忽略重复的 connected 事件");
        return;
      }
      _connectFlowEpoch = _connectEpoch;
      Log.i("MclashNodesStore: 连接成功，自动开始测速");
      unawaited(_onConnected(_connectEpoch));
      return;
    }
    if (state == FlutterVpnServiceState.reasserting ||
        state == FlutterVpnServiceState.connecting) {
      return;
    }
    _connectEpoch++;
  }

  Future<void> _onConnected(int epoch) async {
    if (epoch != _connectEpoch) {
      return;
    }

    final lastTest = _lastFullTestAt;
    final fresh =
        lastTest != null &&
        DateTime.now().difference(lastTest) < _fullTestFreshWindow;

    if (fresh) {
      // 延迟数据是新的（刚才那次全量测速的结果）→ 直接用它定下当前节点。
      Log.i(
        "MclashNodesStore: 连接成功，延迟数据是新的"
        "（${DateTime.now().difference(lastTest).inSeconds}s 前测过）→ 直接选路，不重复全量测速",
      );
      await _autoPickAndBroadcast(epoch, persist: true);
      return;
    }

    await _autoPickAndBroadcast(epoch, persist: false);
    if (epoch != _connectEpoch) {
      return;
    }

    Log.i("MclashNodesStore: 连接成功，自动开始测速");
    await testAll();
    if (epoch != _connectEpoch) {
      return;
    }

    // ③ 用完整测速数据再优化一次，并把选中的节点固定下来。
    await _autoPickAndBroadcast(epoch, persist: true);
  }

  Future<void> _autoPickAndBroadcast(
    int epoch, {
    required bool persist,
  }) async {
    try {
      await MclashNodeAutoPick.selectBestOnConnect(
        cachedLatency: latencyByName(),
        persist: persist,
        onNote: (note) {
          if (epoch != _connectEpoch) {
            return;
          }
          autoPickNote = note;
          notifyListeners();
        },
      );
      if (epoch != _connectEpoch) {
        return;
      }
      onNodeSwitched?.call();
    } catch (e) {
      Log.w("MclashNodesStore: 自动选最优节点失败 $e");
    }
  }

  /// 全量测速结果被认为「还新鲜」的窗口：连接时若在此窗口内测过，就不再重复测。
  static const Duration _fullTestFreshWindow = Duration(minutes: 3);

  DateTime? _lastFullTestAt;

  @visibleForTesting
  DateTime? get debugLastFullTestAt => _lastFullTestAt;

  @visibleForTesting
  void debugResetLastFullTestAt() => _lastFullTestAt = null;

  /// 模拟「连接会话结束」：递增 epoch，让正在跑的全量测速在下一轮循环里收工。
  @visibleForTesting
  void debugBumpConnectEpoch() => _connectEpoch++;

  Map<String, int> latencyByName() {
    final out = <String, int>{};
    for (final n in _nodes) {
      if (n.latencyUsable && n.latencyMs > 0) {
        out[n.name] = n.latencyMs;
      }
    }
    return out;
  }

  String autoPickNote = "";

  String _currentNodeName = "";

  /// 内核事实里的「当前节点」名（主页那一行、切换弹层、节点列表的"当前选中"
  /// 都用它，三处语义一致）。
  String get currentNodeName => _currentNodeName;

  /// 界面上"哪个节点算当前选中"：内核事实优先；内核还没来得及给出结果时
  /// 退回用户固定的节点（重启后还没连接，也要看得出选的是谁）。
  String get selectedNodeName =>
      _currentNodeName.isNotEmpty ? _currentNodeName : MclashNodeAutoPick.fixedNode();

  /// 记录当前节点名。
  ///
  /// **空串不覆盖**：内核在测速 / 重载 / 重启期间读不到节点状态时必须保留上一次的
  /// 值，否则主页节点名会"闪一下就变成空白"（真机报障的时序特征）。
  /// 需要"确实没有当前节点"（例如切到直连模式）时用 [clearCurrentNode]。
  void setCurrentNodeName(String name) {
    final value = name.trim();
    if (value.isEmpty || value == _currentNodeName) {
      return;
    }
    _currentNodeName = value;
    notifyListeners();
  }

  /// 明确清空当前节点（直连模式：此时没有"当前节点"）。
  void clearCurrentNode() {
    if (_currentNodeName.isEmpty) {
      return;
    }
    _currentNodeName = "";
    notifyListeners();
  }

  @visibleForTesting
  void debugResetCurrentNode() {
    _currentNodeName = "";
  }

  VoidCallback? onNodeSwitched;

  void clearAutoPickNote() {
    if (autoPickNote.isEmpty) {
      return;
    }
    autoPickNote = "";
    notifyListeners();
  }

  void notifyCurrentMaybeChanged() => onNodeSwitched?.call();

  @visibleForTesting
  static Future<List<MclashNode>> Function()? debugLoadNodesOverride;

  /// 测试替换缓存写入（避免碰真实配置目录，并可断言最终写进去的是哪一份列表）。
  @visibleForTesting
  static Future<void> Function(Iterable<MclashNode> nodes)?
      debugCacheSaveOverride;

  bool _reloadRequested = false;
  Future<void>? _loadInflight;

  static const Duration _loadStaleAfter = Duration(seconds: 20);

  DateTime? _loadStartedAt;

  int _loadGeneration = 0;

  /// 测速期间到达的 load()：先挂起，等这一轮测速收尾后再真正执行。
  ///
  /// 测速结果写在当前 [_nodes] 的对象上；此时若整体换掉列表，跑了几分钟的
  /// 测量值会全部丢掉，缓存还会被写进一份没有延迟数据的新列表。
  bool _loadDeferredWhileTesting = false;
  bool _deferredLoadAutoTest = false;
  Completer<void>? _deferredLoadCompleter;

  @visibleForTesting
  void debugResetLoadState() {
    _loadInflight = null;
    _reloadRequested = false;
    _loading = false;
    _loadStartedAt = null;
    _loadDeferredWhileTesting = false;
    _deferredLoadAutoTest = false;
    final pending = _deferredLoadCompleter;
    _deferredLoadCompleter = null;
    if (pending != null && !pending.isCompleted) {
      pending.complete();
    }
  }

  Future<void> load({bool autoTestIfNoCache = false}) {
    if (isTesting) {
      return _deferLoad(autoTestIfNoCache: autoTestIfNoCache);
    }
    final inflight = _loadInflight;
    final startedAt = _loadStartedAt;
    final stillFresh =
        startedAt != null &&
        DateTime.now().difference(startedAt) < _loadStaleAfter;
    if (inflight != null && stillFresh) {
      _reloadRequested = true;
      return inflight;
    }

    final generation = ++_loadGeneration;
    _loadStartedAt = DateTime.now();
    final future = _loadOnce(
      autoTestIfNoCache: autoTestIfNoCache,
      generation: generation,
    );
    _loadInflight = future;
    return future.whenComplete(() async {
      if (identical(_loadInflight, future)) {
        _loadInflight = null;
        _loadStartedAt = null;
      }
      if (_reloadRequested) {
        _reloadRequested = false;
        await load();
      }
    });
  }

  Future<void> _deferLoad({required bool autoTestIfNoCache}) {
    _loadDeferredWhileTesting = true;
    _deferredLoadAutoTest = _deferredLoadAutoTest || autoTestIfNoCache;
    return (_deferredLoadCompleter ??= Completer<void>()).future;
  }

  /// 测速收尾后补跑测速期间被推迟的 load()。
  Future<void> _runDeferredLoad() async {
    if (!_loadDeferredWhileTesting) {
      return;
    }
    _loadDeferredWhileTesting = false;
    final autoTest = _deferredLoadAutoTest;
    _deferredLoadAutoTest = false;
    final pending = _deferredLoadCompleter;
    _deferredLoadCompleter = null;
    try {
      await load(autoTestIfNoCache: autoTest);
    } finally {
      if (pending != null && !pending.isCompleted) {
        pending.complete();
      }
    }
  }

  Future<void> _saveCache(Iterable<MclashNode> nodes) {
    final save = debugCacheSaveOverride ?? MclashNodesCache.save;
    return save(nodes);
  }

  Future<void> _loadOnce({
    bool autoTestIfNoCache = false,
    required int generation,
  }) async {
    _loading = true;
    notifyListeners();

    final override = debugLoadNodesOverride;
    if (override != null) {
      List<MclashNode>? nodes;
      try {
        nodes = await override();
      } catch (e) {
        Log.w("MclashNodesStore.load（测试替换）失败 $e");
      }
      if (nodes != null && generation == _loadGeneration) {
        if (isTesting) {
          // 测速中换列表会把正在写入的测量结果整批丢掉：等测速收尾再载入。
          _deferLoad(autoTestIfNoCache: false);
        } else {
          _nodes = nodes;
        }
      }
      _loading = false;
      _invalidateDerived();
      notifyListeners();
      return;
    }

    try {
      final nodes = await MclashSubscriptionNodes.loadNodes();
      _applySubscriptionNotice(MclashSubscriptionNodes.lastNotice);
      final hit = await MclashNodesCache.apply(nodes);
      if (generation != _loadGeneration) {
        Log.i("MclashNodesStore: 丢弃过期结果（第 $generation 轮）");
        return;
      }
      if (isTesting) {
        Log.i("MclashNodesStore: 测速进行中，节点载入推迟到测速结束");
        _deferLoad(autoTestIfNoCache: autoTestIfNoCache);
        _loading = false;
        notifyListeners();
        return;
      }
      _nodes = nodes;
      _loading = false;
      _invalidateDerived();
      notifyListeners();
      Log.i("MclashNodesStore: 载入 ${nodes.length} 个节点，缓存命中 $hit");
      if (autoTestIfNoCache && hit == 0 && nodes.isNotEmpty) {
        unawaited(testAll());
      }
    } catch (e) {
      _loading = false;
      Log.w("MclashNodesStore.load 失败 $e");
      notifyListeners();
    }
  }

  static void _applySubscriptionNotice(MclashSubscriptionNotice notice) {
    MclashAccountService.instance.markPayloadNotice(notice);
    if (!notice.blocked) {
      return;
    }
    if (MclashNodeAutoPick.fixedNode().isNotEmpty) {
      Log.w("MclashNodesStore: 订阅不可用（${notice.title}），清除已固定的节点");
      unawaited(MclashNodeAutoPick.setFixedNode(""));
    }
  }

  Future<void> testAll({List<MclashNode>? subset}) async {
    if (_nodes.isEmpty) {
      return;
    }
    if (isTesting) {
      // 已有一次全量测速在跑（订阅更新/连接两处都可能触发）：不要叠第二轮 ——
      // 两组 worker 一起抢 CPU/网络/控制口，进度条乱跳、耗时翻倍，界面更卡。
      Log.i("MclashNodesStore: 已有测速在进行，跳过这一轮");
      return;
    }
    final src = subset ?? _nodes;
    final targets = src
        .where((n) => n.name.isNotEmpty && n.server.isNotEmpty && n.port > 0)
        .toList();
    if (targets.isEmpty) {
      return;
    }
    // 这一轮测速归属的节点列表：结果写在这些对象上，期间不能被 load() 换掉。
    final batchNodes = _nodes;
    _testing = targets.length;
    _testTotal = targets.length;
    notifyListeners();
    var lastNotify = DateTime.fromMillisecondsSinceEpoch(0);
    var completed = false;
    // 这次测速开始时所属的"连接会话"：会话一结束（断开/内核被撤）就收工，
    // 不该在用户已经断开后继续抢资源。
    //
    // 注意**不能**写成"当前没连接就停"：手动点「全部测速」时用户往往还没连，
    // 那样会被立刻中止（测试也已抓到这个回归）。
    final sessionAtStart = _connectEpoch;
    try {
      completed = await MclashSpeedTester.instance.testAll(
        targets,
        shouldStop: () => _connectEpoch != sessionAtStart,
        onProgress: (done, total) {
          _testing = total - done;
          final now = DateTime.now();
          // 1s 一次就够：界面只需要看到进度在走，500ms 一次会把列表/首页卡片
          // 每秒重建两遍（测速要跑好几分钟）。
          if (now.difference(lastNotify) < const Duration(milliseconds: 1000)) {
            return;
          }
          lastNotify = now;
          _invalidateDerived();
          notifyListeners();
        },
      );

      if (completed && identical(_nodes, batchNodes)) {
        // 只有真的跑完的一轮才算「新鲜」；被连接会话中止的半轮不能冒充，
        // 否则下次连接会直接拿一份不完整的数据选路。
        _lastFullTestAt = DateTime.now();
      } else if (!completed) {
        Log.i("MclashNodesStore: 本轮全量测速被提前中止，不记为新鲜结果");
      }

      final missing = MclashSpeedTester.missingInKernel;
      if (missing > 0) {
        autoPickNote = MclashI18n.t.nodeAuto.newNodesReloading(missing: missing);
        notifyListeners();
        Log.w(
          "MclashNodesStore: 有 $missing 个节点不在当前内核里 → 触发内核重载（订阅内容已变化）",
        );
        await MclashSubscriptionService.applyToRunningKernel();
        autoPickNote = MclashI18n.t.nodeAuto.kernelReloadedRetest;
        notifyListeners();
      }
    } finally {
      // 正常结束、被中止、异常都必须把进度状态归零，否则界面会一直转圈。
      _testing = 0;
      _invalidateDerived();
      notifyListeners();

      // 先写这一轮的结果，再执行被推迟的 load()：新列表会按 key 从缓存里
      // 套上刚测出的延迟。列表若已经被换掉（极端的并发载入），就不要再写，
      // 以免缓存落进一份没有测量值的新列表。
      if (identical(_nodes, batchNodes)) {
        try {
          await _saveCache(batchNodes);
          if (completed) {
            Log.i("MclashNodesStore: 测速完成，已写缓存");
          }
        } catch (e) {
          Log.w("MclashNodesStore: 写节点缓存失败 $e");
        }
      }
      await _runDeferredLoad();
    }
  }

  Future<void> testOne(MclashNode node) async {
    if (node.server.isEmpty || node.port <= 0) {
      return;
    }
    // 单节点探测不能打断全量测速，也不能把全量的进度计数改成 1/1。
    final batchRunning = isTesting;
    if (!batchRunning) {
      _testing = 1;
      _testTotal = 1;
      notifyListeners();
    }
    try {
      await MclashSpeedTester.instance.testSingle(node);
    } finally {
      _invalidateDerived();
      if (batchRunning) {
        // 全量测速的计数和收尾归它自己；这里只刷新派生数据。
        notifyListeners();
      } else {
        _testing = 0;
        notifyListeners();
        final save = _saveCache(_nodes);
        if (_loadDeferredWhileTesting) {
          // 单节点测速期间到达的 load() 同样要等这里收尾（它也会看 isTesting）。
          // 先把这次测量落盘，载入新列表时才能从缓存套上结果。
          try {
            await save;
          } catch (e) {
            Log.w("MclashNodesStore: 写节点缓存失败 $e");
          }
          await _runDeferredLoad();
        } else {
          unawaited(save);
        }
      }
    }
  }

  MclashNode? preferredNodeOfCountry(String code) {
    MclashNode? first;
    MclashNode? best;
    for (final n in _nodes) {
      if ((n.countryCode ?? "XX") != code) {
        continue;
      }
      first ??= n;
      if (n.online && n.latencyUsable) {
        if (best == null || n.latencyMs < best.latencyMs) {
          best = n;
        }
      }
    }
    return best ?? first;
  }

  MclashNode? bestNodeOfCountry(String code) {
    MclashNode? best;
    for (final n in _nodes) {
      if ((n.countryCode ?? "XX") != code || !n.online || !n.latencyUsable) {
        continue;
      }
      if (best == null || n.latencyMs < best.latencyMs) {
        best = n;
      }
    }
    return best;
  }
}

abstract final class MclashNodeCountryWeight {
  static int of(String code) => _weights[code] ?? 500;

  static const Map<String, int> _weights = {
    'HK': 0, 'TW': 1, 'JP': 2, 'SG': 3, 'US': 4, 'KR': 5, 'MO': 6, 'CN': 7,
  };
}
