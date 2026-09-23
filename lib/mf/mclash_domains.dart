
library;

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:mclash/app/utils/log.dart';
import 'package:mclash/app/utils/secure_storage.dart';

/// 多域名轮换的「域名池」。
///
/// 为什么需要它：Xboard 后端同时挂了多个对外域名，单点故障（DNS 污染、证书被墙、
/// 机房线路抖动、Cloudflare 拦截页）都会让客户端「登录不上 / 拉不到订阅」，
/// 但换一个域名往往立刻就好。这里集中维护两份清单、候选顺序、上次可用域名
/// 与失败冷却，供 [CBoardClient] 与订阅同步共用。
///
/// 注意（安全红线）：域名不可用只允许「换下一个域名」，绝不允许为了让某个域名
/// 通过而放宽 TLS 校验。实测 `dollarsfly.top` / `sub.dollarsfly.top` 的证书校验会
/// 失败，那是服务端证书问题，不是客户端该绕过的。
abstract final class MclashDomainPool {
  /// API/站点域名：base URL 形如 `https://<host>/api/v1`。
  static const List<String> kApiHosts = <String>[
    'new.moneyfly.top',
    'dollarsfly.top',
  ];

  /// 订阅域名：订阅链接可以换用这些 host。
  static const List<String> kSubscriptionHosts = <String>[
    'new.moneyfly.top',
    'sub.dollarsfly.top',
    'dollarsfly.top',
  ];

  /// 轮换候选里默认排第一的 host（与历史默认 base 一致，避免改变首次启动行为）。
  static const String kDefaultHost = 'new.moneyfly.top';

  /// 失败冷却时长：短时间内不要每次都从头把坏域名试一遍。
  static const Duration kFailureCooldown = Duration(minutes: 5);

  /// 持久化键名。
  static const String kStorageKey = 'mclash.domain.pool.v1';

  static _DomainPoolState _state = _parse(null);

  /// 是否已经把磁盘上的状态读进内存（只读一次，之后走内存 + 异步落盘）。
  static bool _loaded = false;

  @visibleForTesting
  static Future<String?> Function(String key)? debugReadOverride;

  @visibleForTesting
  static Future<void> Function(String key, String value)? debugWriteOverride;

  /// 测试里把冷却起点往后推，用来验证「冷却到期」。
  @visibleForTesting
  static DateTime Function() debugNow = DateTime.now;

  /// 清空内存状态（测试用）。
  ///
  /// [resetLoaded] 为 true 时同时清掉「已读盘」标记，用于验证「下次读到的盘上状态」；
  /// 默认 false 则表示「已经读过了」，避免生产代码在测试里被误触发读盘。
  @visibleForTesting
  static void debugReset({bool resetLoaded = false}) {
    _state = _parse(null);
    _loaded = !resetLoaded;
  }

  /// 覆盖整个状态（测试用，可注入「上次可用域名」「冷却记录」）。
  @visibleForTesting
  static void debugSetState({
    String? lastGoodApiHost,
    String? lastGoodSubscriptionHost,
    Map<String, DateTime>? failures,
  }) {
    _state = _DomainPoolState(
      lastGoodApiHost: lastGoodApiHost,
      lastGoodSubscriptionHost: lastGoodSubscriptionHost,
      failures: Map<String, DateTime>.from(failures ?? const {}),
    );
    _loaded = true;
  }

  /// 供测试断言盘上到底写了什么。
  @visibleForTesting
  static String debugEncode() => jsonEncode(_state.toJson());

  static void _loadIfNeeded() {
    if (_loaded) {
      return;
    }

    // 先标记已加载，避免并发调用重复读盘、也避免读盘异常时反复重入。
    _loaded = true;
    unawaited(_load());
  }

  static Future<void> _load() async {
    try {
      final read = debugReadOverride ?? SecureStorage.read;
      final raw = await read(kStorageKey);
      if (raw == null || raw.isEmpty) {
        return;
      }
      _state = _parse(jsonDecode(raw));
    } catch (e) {
      // 读盘/解析失败一律回落默认顺序：不能因为一个坏键就把用户卡死在无法登录。
      Log.w('MclashDomainPool: 读取域名池状态失败，回落默认顺序（$e）');
    }
  }

  static _DomainPoolState _parse(dynamic raw) {
    String? api;
    String? sub;
    final failures = <String, DateTime>{};
    if (raw is Map) {
      final a = raw['last_good_api_host'];
      if (a is String && kApiHosts.contains(a)) {
        api = a;
      }
      final s = raw['last_good_subscription_host'];
      if (s is String && kSubscriptionHosts.contains(s)) {
        sub = s;
      }
      final f = raw['failures'];
      if (f is Map) {
        for (final e in f.entries) {
          final host = e.key.toString();
          final t = DateTime.tryParse(e.value?.toString() ?? '');
          if (t != null) {
            failures[host] = t;
          }
        }
      }
    }
    return _DomainPoolState(
      lastGoodApiHost: api,
      lastGoodSubscriptionHost: sub,
      failures: failures,
    );
  }

  static Future<void> _persist() async {
    try {
      final write = debugWriteOverride ?? SecureStorage.write;
      await write(kStorageKey, jsonEncode(_state.toJson()));
    } catch (e) {
      // 落盘失败不影响本次请求：内存里的顺序已经生效，下次启动退回默认顺序而已。
      Log.w('MclashDomainPool: 保存域名池状态失败（$e）');
    }
  }

  /// 某个 host 是否还在失败冷却期内。
  static bool inCooldown(String host) {
    _loadIfNeeded();
    final at = _state.failures[host];
    if (at == null) {
      return false;
    }
    return debugNow().difference(at) < kFailureCooldown;
  }

  /// 上次可用的 API host（没有则为 null）。
  static String? lastGoodApiHost() {
    _loadIfNeeded();
    return _state.lastGoodApiHost;
  }

  /// 上次可用的订阅 host（没有则为 null）。
  static String? lastGoodSubscriptionHost() {
    _loadIfNeeded();
    return _state.lastGoodSubscriptionHost;
  }

  /// 记录一次成功：记住它、优先用它，并清掉它的失败记录。
  ///
  /// 注意：即便 host 不在清单里（例如构建期的 MCLASH_API_BASE 覆盖）也要记住，
  /// 这样下次请求仍然优先走这个可用域名。
  static void reportSuccess(String host, {bool subscription = false}) {
    _loadIfNeeded();
    final h = host.trim().toLowerCase();
    if (h.isEmpty) {
      return;
    }
    var changed = false;
    if (_state.failures.remove(h) != null) {
      changed = true;
    }
    if (subscription) {
      if (_state.lastGoodSubscriptionHost != h) {
        _state.lastGoodSubscriptionHost = h;
        changed = true;
      }
    } else if (_state.lastGoodApiHost != h) {
      _state.lastGoodApiHost = h;
      changed = true;
    }
    if (changed) {
      unawaited(_persist());
    }
  }

  /// 记录一次失败：进入冷却期，稍后的候选排序会把它排到最后。
  static void reportFailure(String host, {bool subscription = false}) {
    _loadIfNeeded();
    final h = host.trim().toLowerCase();
    if (h.isEmpty) {
      return;
    }
    _state.failures[h] = debugNow();

    // 失败的是「上次可用」的那个域名时，把记忆清掉，避免下次仍然优先选它。
    if (subscription) {
      if (_state.lastGoodSubscriptionHost == h) {
        _state.lastGoodSubscriptionHost = null;
      }
    } else if (_state.lastGoodApiHost == h) {
      _state.lastGoodApiHost = null;
    }
    unawaited(_persist());
  }

  /// 测试用：等落盘完成（生产路径刻意不 await，避免拖慢请求）。
  @visibleForTesting
  static Future<void> debugFlushPersistence() => _persist();

  /// 某个 host 是否属于 API 清单。
  static bool isApiHost(String host) =>
      kApiHosts.contains(host.trim().toLowerCase());

  /// API base 候选顺序：上次可用的优先，其余按默认顺序补齐。
  static List<String> apiBaseUrls() {
    _loadIfNeeded();
    final preferred = _state.lastGoodApiHost;
    final ordered = _orderedHosts(kApiHosts, preferred);
    return ordered.map((h) => apiBaseUrlOf(h)).toList(growable: false);
  }

  /// 由 host 拼出 API base URL。
  static String apiBaseUrlOf(String host) => 'https://$host/api/v1';

  /// 当前应当优先使用的 API base URL。
  static String currentApiBaseUrl() {
    final list = apiBaseUrls();
    return list.isEmpty ? apiBaseUrlOf(_orderedHosts(kApiHosts, null).first) : list.first;
  }

  /// 从任意 base URL 取 host（解析失败返回空串），用来把「当前 base」换算成 host。
  static String hostOf(String url) => Uri.tryParse(url)?.host ?? '';

  /// 订阅域名候选顺序（不含 host 改写）。
  ///
  /// 顺序＝原文 host（来自刚跑通的 API 域名，本来就能用）→ 上次可用的订阅域名 →
  /// 其余按默认顺序，冷却中的排最后。
  static List<String> subscriptionHostOrder(String originalHost) {
    _loadIfNeeded();
    final current = originalHost.trim().toLowerCase();
    final hosts = <String>[];
    if (current.isNotEmpty) {
      hosts.add(current);
    }
    final preferred = _state.lastGoodSubscriptionHost;
    if (preferred != null && preferred.isNotEmpty && !hosts.contains(preferred)) {
      hosts.add(preferred);
    }
    for (final h in _orderedHosts(kSubscriptionHosts, preferred)) {
      if (!hosts.contains(h)) {
        hosts.add(h);
      }
    }
    return hosts;
  }

  /// 订阅 URL 候选：把给定 URL 的 host 换成各订阅域名，path/query/fragment 原样保留。
  ///
  /// 为什么保留 path/query：订阅链接里的 token 就在 query（也有站点放在 path），
  /// 换域名只是换入口，链接本身必须原封不动。
  static List<String> subscriptionUrlsFor(String url) {
    _loadIfNeeded();
    final text = url.trim();
    final uri = Uri.tryParse(text);
    if (uri == null || uri.host.isEmpty) {
      // 解析不出来就原样返回，让调用方照旧走一次（不要凭空吞掉订阅地址）。
      return text.isEmpty ? const <String>[] : <String>[text];
    }

    final out = <String>[];
    for (final h in subscriptionHostOrder(uri.host)) {
      final next = uri.replace(host: h);
      if (!out.contains(next.toString())) {
        out.add(next.toString());
      }
    }
    return out;
  }

  /// 排序规则：上次可用的排第一；冷却中的排到最后（而不是直接剔除）。
  ///
  /// 为什么要保留冷却中的域名：如果所有域名都在冷却（比如刚断网失败了一圈），
  /// 直接剔除会让候选为空、什么都试不了；排在最后等于「先试好的，实在不行还得试它」。
  static List<String> _orderedHosts(List<String> defaults, String? preferred) {
    final cooled = <String>[];
    final warm = <String>[];
    for (final h in defaults) {
      if (inCooldown(h)) {
        cooled.add(h);
      } else {
        warm.add(h);
      }
    }
    final ordered = <String>[];
    if (preferred != null &&
        preferred.isNotEmpty &&
        defaults.contains(preferred) &&
        !cooled.contains(preferred)) {
      ordered.add(preferred);
    }
    for (final h in warm) {
      if (!ordered.contains(h)) {
        ordered.add(h);
      }
    }
    for (final h in cooled) {
      if (!ordered.contains(h)) {
        ordered.add(h);
      }
    }
    return ordered;
  }
}

class _DomainPoolState {
  _DomainPoolState({
    this.lastGoodApiHost,
    this.lastGoodSubscriptionHost,
    Map<String, DateTime>? failures,
  }) : failures = failures ?? <String, DateTime>{};

  String? lastGoodApiHost;
  String? lastGoodSubscriptionHost;
  final Map<String, DateTime> failures;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'last_good_api_host': lastGoodApiHost,
        'last_good_subscription_host': lastGoodSubscriptionHost,
        'failures': failures.map(
          (k, v) => MapEntry<String, String>(k, v.toIso8601String()),
        ),
      };
}
