
library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:mclash/app/local_services/vpn_service.dart';
import 'package:mclash/app/modules/profile_manager.dart';
import 'package:mclash/app/utils/log.dart';
import 'package:mclash/mf/mclash_account_service.dart';
import 'package:mclash/mf/mclash_node.dart';
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

  Map<String, int>? _bestLatencyCache;
  List<String>? _countriesCache;
  List<String>? _topCountriesCache;

  /// 节点列表或延迟变了才失效；主页/节点页每次重建都会读这些派生值，
  /// 不缓存的话每帧都要遍历几百个节点（这是卡顿的来源之一）。
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

  /// 主页「快速筛选国家」用：延迟最低的 [limit] 个国家。
  ///
  /// 还没测速的国家排在后面（有延迟数据的优先），不足 [limit] 时按权重补齐，
  /// 保证首屏永远有可点的国家，而不是空白。
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
    // 连接状态一变，内核可用性就变了 → 丢掉缓存，下一次测速重新判定
    // （内核在跑 = 走 /proxies/{name}/delay，协议无关；没跑 = TCP 粗测兜底）。
    MclashSpeedTester.instance.resetKernelCache();
    if (state == FlutterVpnServiceState.connected) {
      Log.i("MclashNodesStore: 连接成功，自动开始测速");
      unawaited(_onConnected());
    }
  }

  Future<void> _onConnected() async {

    await Future<void>.delayed(const Duration(seconds: 2));

    try {
      await MclashNodeAutoPick.selectBestOnConnect(
        onNote: (note) {
          autoPickNote = note;
          notifyListeners();
        },
      );
      onNodeSwitched?.call();
    } catch (e) {
      Log.w("MclashNodesStore: 自动选最优节点失败 $e");
    }

    // **不再无条件全量测速。**
    //
    // 旧行为：每次连接成功都把所有节点（订阅动辄 316 个）重新测一遍 ——
    // 12 路并发 × 每个节点探测 3 次，连接后要连发近千次连接请求。手机上是实打实的
    // 耗电与流量（用户要求「减少耗电」），而绝大多数节点的延迟刚刚测过、没有变化。
    // 现在只测「没有可用延迟 / 缓存太旧」的那些；全都新鲜就跳过（自动选最优用的是
    // 缓存值，行为不变）。
    final stale = staleNodes();
    if (stale.isEmpty) {
      Log.i(
        "MclashNodesStore: 连接成功，${_nodes.length} 个节点的延迟缓存都还新鲜（"
        "${latencyCacheFresh.inHours}h 内），跳过全量测速",
      );
      return;
    }
    Log.i("MclashNodesStore: 连接成功，只测 ${stale.length}/${_nodes.length} 个需要更新的节点");
    await testAll(subset: stale);
  }

  /// 延迟缓存的新鲜期：在这之内不重复测速（省电、省流量）。
  static const Duration latencyCacheFresh = Duration(hours: 6);

  /// 需要重新测速的节点：没有可用延迟的，或缓存时间过期的。
  ///
  /// 节点没有单独的测速时间戳（缓存文件只存延迟本身），所以用**缓存文件的
  /// 修改时间**作为整批延迟的时间基准：文件是刚刚写入的就说明这批延迟是新的。
  List<MclashNode> staleNodes() {
    final missing = _nodes
        .where((n) => !n.latencyUsable || n.latencyMs <= 0)
        .toList();
    if (missing.isNotEmpty) {
      return missing;
    }
    if (_latencyCacheAge != null &&
        _latencyCacheAge! < latencyCacheFresh) {
      return const [];
    }
    return List.of(_nodes);
  }

  /// 最近一次延迟缓存的「年龄」（载入时记录；未知时为 null）。
  Duration? _latencyCacheAge;

  @visibleForTesting
  void debugSetLatencyCacheAge(Duration? age) => _latencyCacheAge = age;

  String autoPickNote = "";

  VoidCallback? onNodeSwitched;

  /// 测试缝：**整体**替换真实加载（读配置档 + 读延迟缓存都要访问真实文件）。
  ///
  /// widget 测试的假时钟下真实 I/O 的 future 不会推进，于是「点按钮 → 出反馈」
  /// 这条链永远走不完、没法断言。给出替换口后，测试就能确定性地验证
  /// 「点击有没有接线、有没有反馈」。
  @visibleForTesting
  static Future<List<MclashNode>> Function()? debugLoadNodesOverride;

  bool _reloadRequested = false;
  Future<void>? _loadInflight;

  /// 一轮读取最多认多久。
  ///
  /// 合并并发请求的前提是「那一轮总会结束」；万一真的卡住（磁盘异常、网络盘），
  /// 后面所有重载都会陪它一起等。超过这个时间再来请求就另开一轮，
  /// 而不是无限期地等下去。
  static const Duration _loadStaleAfter = Duration(seconds: 20);

  DateTime? _loadStartedAt;

  /// 代际号：只有最新一轮的结果才允许写进 `_nodes`。
  ///
  /// 否则「先发起的慢加载」会覆盖「后发起的快加载」的结果 —— 用户点了更新订阅，
  /// 列表却退回旧数据。
  int _loadGeneration = 0;

  @visibleForTesting
  void debugResetLoadState() {
    _loadInflight = null;
    _reloadRequested = false;
    _loading = false;
    _loadStartedAt = null;
  }

  /// 载入节点列表。
  ///
  /// 竞态处理：正在载入时**不丢请求**，而是记一次「待重载」，等当前这轮结束后
  /// 再跑一遍。旧实现直接 `return`，于是「更新订阅 → 立刻载入」会被正在跑的
  /// 那轮吞掉，界面停在旧列表（用户看到的就是「点了更新没反应」）。
  Future<void> load({bool autoTestIfNoCache = false}) {
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
        _nodes = nodes;
      }
      _loading = false;
      _invalidateDerived();
      notifyListeners();
      return;
    }

    try {
      final nodes = await MclashSubscriptionNodes.loadNodes();
      // 后端在「到期 / 被禁用 / 设备超限」时只会下发提示节点 —— 这一步把
      // 「配置档本身说了什么」交给账号门禁，于是：
      //   · 节点列表归零（提示节点被过滤），自动选节点无候选；
      //   · 任何连接入口都会被门禁拦住（含托盘/URL scheme/开机自动连接）；
      //   · 已连接时由 MclashAccountService 断开。
      _applySubscriptionNotice(MclashSubscriptionNodes.lastNotice);
      final hit = await MclashNodesCache.apply(nodes);
      _latencyCacheAge = await MclashNodesCache.age();
      if (generation != _loadGeneration) {
        // 已经有更新的一轮在跑（例如用户手动更新订阅），这轮的旧结果直接丢弃。
        Log.i("MclashNodesStore: 丢弃过期结果（第 $generation 轮）");
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

  /// 把订阅下发状态交给账号门禁，并清掉「已经不可用」的旧选择。
  static void _applySubscriptionNotice(MclashSubscriptionNotice notice) {
    MclashAccountService.instance.markPayloadNotice(notice);
    if (!notice.blocked) {
      return;
    }
    // 记住的固定节点此刻已经不存在了；不清掉的话下次连上会去找一个死节点。
    if (MclashNodeAutoPick.fixedNode().isNotEmpty) {
      Log.w("MclashNodesStore: 订阅不可用（${notice.title}），清除已固定的节点");
      unawaited(MclashNodeAutoPick.setFixedNode(""));
    }
  }

  Future<void> testAll({List<MclashNode>? subset}) async {
    if (_nodes.isEmpty || _testing > 0) {
      return;
    }
    final src = subset ?? _nodes;
    // **不再**按 udpOnly 过滤：内核在跑时（走 /proxies/{name}/delay）
    // hysteria2 / tuic / wireguard 这些纯 UDP 协议同样能测出真实延迟；
    // 内核没跑时由 MclashSpeedTester 自己判断能不能 TCP 兜底。
    final targets = src
        .where((n) => n.name.isNotEmpty && n.server.isNotEmpty && n.port > 0)
        .toList();
    if (targets.isEmpty) {
      return;
    }
    _testing = targets.length;
    _testTotal = targets.length;
    notifyListeners();
    await MclashSpeedTester.instance.testAll(
      targets,
      onProgress: (done, total) {
        _testing = total - done;
        _invalidateDerived();
        notifyListeners();
      },
    );
    _testing = 0;
    _invalidateDerived();
    notifyListeners();
    await MclashNodesCache.save(_nodes);
    Log.i("MclashNodesStore: 测速完成，已写缓存");

    // 有一批节点「内核里还没有」= 内核还在用旧订阅跑（新订阅里新增的节点，
    // 比如用户新出现的 SSR / light* 节点）。这时把它们显示成「超时」是误导，
    // 正确做法是**自动重载内核**，并在界面上说清原因。
    final missing = MclashSpeedTester.missingInKernel;
    if (missing > 0) {
      autoPickNote = "订阅里有 $missing 个新节点还没进内核，正在重载…";
      notifyListeners();
      Log.w(
        "MclashNodesStore: 有 $missing 个节点不在当前内核里 → 触发内核重载（订阅内容已变化）",
      );
      await MclashSubscriptionService.applyToRunningKernel();
      autoPickNote = "内核已按新订阅重载，请再点一次测速";
      notifyListeners();
    }
  }

  Future<void> testOne(MclashNode node) async {
    if (node.server.isEmpty || node.port <= 0) {
      return;
    }
    _testing = 1;
    _testTotal = 1;
    notifyListeners();
    await MclashSpeedTester.instance.testAll([node]);
    _testing = 0;
    _invalidateDerived();
    notifyListeners();
    unawaited(MclashNodesCache.save(_nodes));
  }

  /// 点国家时用：优先延迟最低的可用节点，都没测过就取该国第一个节点。
  ///
  /// 与 [bestNodeOfCountry] 的区别：后者只认「已测速且可用」，首页点国家时
  /// 往往还没测速，用它会返回 null，于是「选了国家没反应」。
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
