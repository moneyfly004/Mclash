
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

  int _connectEpoch = 0;

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
    _connectEpoch++;
    if (state == FlutterVpnServiceState.connected) {
      Log.i("MclashNodesStore: 连接成功，自动开始测速");
      unawaited(_onConnected(_connectEpoch));
    }
  }

  Future<void> _onConnected(int epoch) async {
    if (epoch != _connectEpoch) {
      return;
    }

    await testAll();

    if (epoch != _connectEpoch) {
      return;
    }

    try {
      await MclashNodeAutoPick.selectBestOnConnect(
        cachedLatency: latencyByName(),
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

  bool _reloadRequested = false;
  Future<void>? _loadInflight;

  static const Duration _loadStaleAfter = Duration(seconds: 20);

  DateTime? _loadStartedAt;

  int _loadGeneration = 0;

  @visibleForTesting
  void debugResetLoadState() {
    _loadInflight = null;
    _reloadRequested = false;
    _loading = false;
    _loadStartedAt = null;
  }

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
      _applySubscriptionNotice(MclashSubscriptionNodes.lastNotice);
      final hit = await MclashNodesCache.apply(nodes);
      if (generation != _loadGeneration) {
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
    final src = subset ?? _nodes;
    final targets = src
        .where((n) => n.name.isNotEmpty && n.server.isNotEmpty && n.port > 0)
        .toList();
    if (targets.isEmpty) {
      return;
    }
    _testing = targets.length;
    _testTotal = targets.length;
    notifyListeners();
    var lastNotify = DateTime.fromMillisecondsSinceEpoch(0);
    await MclashSpeedTester.instance.testAll(
      targets,
      onProgress: (done, total) {
        _testing = total - done;
        final now = DateTime.now();
        if (now.difference(lastNotify) < const Duration(milliseconds: 500)) {
          return;
        }
        lastNotify = now;
        _invalidateDerived();
        notifyListeners();
      },
    );
    _testing = 0;
    _invalidateDerived();
    notifyListeners();
    await MclashNodesCache.save(_nodes);
    Log.i("MclashNodesStore: 测速完成，已写缓存");

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
