// ignore_for_file: non_constant_identifier_names

import 'dart:async';
import 'dart:isolate';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'dart:io';

import 'package:mclash/app/clash/clash_config.dart';
import 'package:tuple/tuple.dart';

import 'package:mclash/app/runtime/return_result.dart';
import 'package:mclash/app/utils/log.dart';

class ClashConfigsTun {
  bool enable = false;
  String device = "";
  String stack = "";

  bool auto_route = false;
  bool auto_detect_interface = false;
  int file_descriptor = 0;
  void fromJson(Map<String, dynamic>? map) {
    if (map == null) {
      return;
    }
    enable = map["enable"] ?? false;
    device = map["device"] ?? "";
    stack = map["stack"] ?? "";
    auto_route = map["auto-route"] ?? false;
    auto_detect_interface = map["auto-detect-interface"] ?? false;
    file_descriptor = map["file-descriptor"] ?? 0;
  }
}

class ClashConfigs {
  int port = 0;
  int socks_port = 0;
  int redir_port = 0;
  int tproxy_port = 0;
  int mixed_port = 0;
  ClashConfigsTun tun = ClashConfigsTun();

  bool allow = false;
  String bind_address = "";
  bool inbound_tfo = false;
  bool inbound_mptcp = false;
  String mode = "direct";
  bool unified_delay = false;
  String log_level = "info";
  bool ipv6 = false;
  String interface_name = "";
  int routing_mark = 0;

  bool geo_auto_update = false;
  int geo_update_interval = 24;
  bool geodata_mode = false;
  String geodata_loader = "";
  String geosite_matcher = "";
  bool tcp_concurrent = false;
  String find_process_mode = "off";
  bool sniffing = false;
  String global_client_fingerprint = "";
  String global_ua = "";
  bool etag_support = false;
  int keep_alive_idle = 0;
  int keep_alive_interval = 30;
  bool disable_keep_alive = false;

  void fromJson(Map<String, dynamic>? map) {
    if (map == null) {
      return;
    }
    {
      port = map["port"] ?? 0;
      socks_port = map["socks-port"] ?? 0;
      redir_port = map["redir-port"] ?? 0;
      tproxy_port = map["tproxy-port"] ?? 0;
      mixed_port = map["mixed-port"] ?? 0;
      tun.fromJson(map["tun"]);
      allow = map["allow-lan"] ?? false;
      bind_address = map["bind-address"] ?? "";
      inbound_tfo = map["inbound-tfo"] ?? false;
      inbound_mptcp = map["inbound-mptcp"] ?? false;
      mode = map["mode"] ?? "";
      unified_delay = map["unified-delay"] ?? false;
      log_level = map["log-level"] ?? "";
      ipv6 = map["ipv6"] ?? false;
      interface_name = map["interface-name"] ?? "";
      routing_mark = map["routing-mark"] ?? 0;

      geo_auto_update = map["geo-auto-update"] ?? false;
      geo_update_interval = map["geo-update-interval"] ?? 0;
      geodata_mode = map["geodata-mode"] ?? false;
      geodata_loader = map["geodata-loader"] ?? "";
      geosite_matcher = map["geosite-matcher"] ?? "";
      tcp_concurrent = map["tcp-concurrent"] ?? false;
      find_process_mode = map["find-process-mode"] ?? "";
      sniffing = map["sniffing"] ?? false;
      global_client_fingerprint = map["global-client-fingerprint"] ?? "";
      global_ua = map["global-ua"] ?? "";
      etag_support = map["etag-support"] ?? false;
      keep_alive_idle = map["keep-alive-idle"] ?? 0;
      keep_alive_interval = map["keep-alive-interval"] ?? 0;
      disable_keep_alive = map["disable-keep-alive"] ?? false;
    }
  }
}

class ClashConnectionsTrack {
  String start = "";
  List<String> chains = [];
  List<String> providerChains = [];
  String rule = "";
  String rulePayload = "";

  void fromJson(Map<String, dynamic>? map) {
    if (map == null) {
      return;
    }

    start = map['start'] ?? "";
    chains = List.from(map['chains'] ?? []);
    providerChains = List.from(map['providerChains'] ?? []);
    rule = map['rule'] ?? "";
    rulePayload = map['rulePayload'] ?? "";
  }

  Map<String, dynamic> toJson() => {
    'start': start,
    'chains': chains,
    'providerChains': providerChains,
    'rule': rule,
    'rulePayload': rulePayload,
  };
}

class ClashProxiesNode {
  List<String> all = [];
  String name = "";
  String now = "";
  String type = "";
  String icon = "";
  int? delay;
  String? delayErr;
  bool hidden = false;

  Map<String, dynamic> toJson() => {
    'all': all,
    'name': name,
    'now': now,
    'type': type,
    'icon': icon,
    'delay': delay,
    'hidden': hidden,
  };
  void fromJson(Map<String, dynamic>? map) {
    if (map == null) {
      return;
    }

    name = map['name'] ?? "";
    now = map['now'] ?? "";
    type = map['type'] ?? "";
    icon = map['icon'] ?? "";
    all = List.from(map['all'] ?? []);
    hidden = map['hidden'] ?? false;
    var history = map['history'];
    if (history is List) {
      if (history.isNotEmpty) {
        delay = history.last["delay"] as int;
        if (delay == 0) {
          delay = null;
        }
      }
    }
  }
}

class ClashProxies {
  List<ClashProxiesNode> proxies = [];

  void fromJsonProxies(Map<String, dynamic>? map) {
    if (map == null) {
      return;
    }

    final p = map['proxies'];
    if (p is Map) {
      final toRemove = <String>{};
      p.forEach((key, value) {
        var node = ClashProxiesNode();
        node.fromJson(value);
        if (node.type.toLowerCase() != "dns") {
          proxies.add(node);
        } else {
          toRemove.add(node.name);
        }
      });

      final byName = <String, ClashProxiesNode>{
        for (final n in proxies) n.name: n,
      };

      for (final n in proxies) {
        n.all.removeWhere((ele) => toRemove.contains(ele));
        n.delay = updateGroupDelayIndexed(n, byName, <String>{});
      }

      final globalAll = byName["GLOBAL"]?.all ?? const <String>[];
      final globalAllProxies = <ClashProxiesNode>[
        for (final tag in globalAll)
          if (byName[tag] != null) byName[tag]!,
      ];
      if (globalAllProxies.isNotEmpty) {
        final keep = globalAllProxies.toSet();
        proxies.removeWhere(keep.contains);
        proxies.insertAll(0, globalAllProxies);
      }
    }
  }

  void fromJsonProviders(Map<String, dynamic>? map) {
    if (map == null) {
      return;
    }

    final p = map['providers'];
    if (p is Map) {
      final existing = <String>{for (final n in proxies) n.name};
      p.forEach((key, value) {
        final p = value['proxies'];
        if (p != null && p is List) {
          for (var item in p) {
            var node = ClashProxiesNode();
            node.fromJson(item);
            if (node.type.toLowerCase() != "dns" &&
                !existing.contains(node.name)) {
              proxies.add(node);
              existing.add(node.name);
            }
          }
        }
      });
    }
  }

  int? updateGroupDelayIndexed(
    ClashProxiesNode node,
    Map<String, ClashProxiesNode> byName,
    Set<String> visiting,
  ) {
    if (node.now.isEmpty) {
      return node.delay;
    }
    if (!visiting.add(node.name)) {
      return node.delay;
    }
    final next = byName[node.now];
    final delay = next == null
        ? node.delay
        : updateGroupDelayIndexed(next, byName, visiting);
    visiting.remove(node.name);
    return delay ?? node.delay;
  }
}

class ClashHttpApi {
  static String host = "http://127.0.0.1";
  static String wshost = "ws://127.0.0.1";
  static const int timeoutSeconds = 1;

  /// 读 `/proxies` / `/providers/proxies` 这种**大响应**的超时。
  ///
  /// 494 个节点的 `/proxies` 有几百 KB，内核刚测速完或正在重载时 1 秒根本读不完 ——
  /// 真机日志就是 `TimeoutException after 0:00:01.000000`。读不到的直接后果是主页
  /// "当前节点"和自动选路静默失效（真机报障的空白）。
  /// 小请求（切节点/读 configs）继续用 1 秒，只有这两个大响应放宽。
  static const Duration proxiesReadTimeout = Duration(seconds: 5);

  static int Function()? getControlPort;
  static String Function()? getSecret;

  static Map<String, String> getHeaders(String secret) {
    Map<String, String> headers = {};
    if (secret.isNotEmpty) {
      headers["Authorization"] = "Bearer $secret";
    }
    headers[HttpHeaders.contentTypeHeader] = "application/json; charset=UTF-8";
    return headers;
  }

  static HttpClient? _client;

  static HttpClient _sharedClient() {
    final cached = _client;
    if (cached != null) {
      return cached;
    }
    final created = HttpClient()
      ..connectionTimeout = const Duration(seconds: 3)
      ..idleTimeout = const Duration(seconds: 20)
      ..maxConnectionsPerHost = 8;
    _client = created;
    return created;
  }

  static void resetControlConnection() {
    final c = _client;
    _client = null;
    try {
      c?.close(force: true);
    } catch (_) {}
  }

  /// 只有"连接本身坏了（IO / 传输层）"才值得重建连接池。
  ///
  /// [resetControlConnection] 会 `force: close()` **共享**的 HttpClient，连带打断
  /// 首页轮询 / 测速 / 流量等并发请求（真机：读当前节点时把别人的请求一起掐了）。
  /// `SocketException`（连接被拒/被重置）与 `HttpException`（对端提前关闭）都属于
  /// [IOException]；超时（`TimeoutException`）不算 —— 它只是这一次慢，强关反而会
  /// 把并发的其它请求一起打断。用异常**类型**判断，不做本地化文案匹配。
  static bool _isConnectionStateError(Object err) => err is IOException;

  /// 共享连接连续超时计数（达到 2 次就重建连接，见 controlRequest）
  static int _consecutiveTimeouts = 0;

  static Future<ReturnResult<Tuple2<int, String>>> controlRequest(
    String method,
    String path, {
    Duration? timeout,
    String? body,
    bool retry = true,
  }) async {
    final t = timeout ?? const Duration(seconds: timeoutSeconds);
    final port = getControlPort?.call() ?? 0;
    if (port <= 0) {
      return ReturnResult(error: ReturnResultError("控制端口未就绪"));
    }
    final uri = Uri.parse("$host:$port$path");
    final headers = getHeaders(getSecret?.call() ?? "");
    Object? lastError;
    final attempts = retry ? 2 : 1;
    for (var attempt = 0; attempt < attempts; attempt++) {
      try {
        final client = _sharedClient();
        final req = await client.openUrl(method, uri).timeout(t);
        headers.forEach((k, v) => req.headers.set(k, v));
        if (body != null) {
          req.write(body);
        }
        final resp = await req.close().timeout(t);
        final text = await resp.transform(utf8.decoder).join().timeout(t);
        _consecutiveTimeouts = 0;
        return ReturnResult(data: Tuple2(resp.statusCode, text));
      } catch (err) {
        lastError = err;
        if (err is TimeoutException) {
          // 连续超时 = 共享连接已经坏了（内核重启/半关闭时常见）。
          // 只关一次会打断并发请求，所以给一次容忍：同一连接**连续两次**超时
          // 才重置，下一次请求重建连接。
          // 真机证据：一条坏连接会让 /proxies 每 5 秒超时持续几十分钟，
          // 而流量 WebSocket（独立连接）一直正常 —— 典型 keep-alive 中毒。
          _consecutiveTimeouts++;
          if (_consecutiveTimeouts >= 2) {
            Log.w("ClashHttpApi: 连续 $_consecutiveTimeouts 次超时 → 重建控制连接");
            resetControlConnection();
            _consecutiveTimeouts = 0;
          }
          break;
        }
        _consecutiveTimeouts = 0;
        if (_isConnectionStateError(err)) {
          resetControlConnection();
        }
      }
    }
    return ReturnResult(error: ReturnResultError("$lastError"));
  }

  /// 只读**一个代理组**（`GET /proxies/{name}`）。
  ///
  /// 为什么需要：`GET /proxies` 会把 500+ 节点连同 history 全部序列化（几百 KB），
  /// 首页/选路每 15~30 秒读一次，JSON 解析 + 对象分配都在主 isolate 上 —— Windows
  /// 上表现为持续掉帧/卡顿。读单个组只返回 {now, all, type}，几十字节~几 KB。
  static Future<ReturnResult<ClashProxiesNode>> getProxyGroup(String name) async {
    final r = await controlRequest(
      "GET",
      "/proxies/${Uri.encodeComponent(name)}",
      timeout: proxiesReadTimeout,
    );
    if (r.error != null) {
      return ReturnResult(error: r.error);
    }
    try {
      final decoded = jsonDecode(r.data!.item2);
      if (decoded is! Map) {
        return ReturnResult(error: ReturnResultError("代理组响应格式异常"));
      }
      final node = ClashProxiesNode();
      node.fromJson(Map<String, dynamic>.from(decoded));
      return ReturnResult(data: node);
    } catch (e) {
      return ReturnResult(error: ReturnResultError("$e"));
    }
  }

  static Future<ReturnResult<List<ClashProxiesNode>>>? _proxiesInflight;
  static ReturnResult<List<ClashProxiesNode>>? _proxiesCache;
  static DateTime? _proxiesAt;
  static const Duration _proxiesTtl = Duration(milliseconds: 1500);

  static void invalidateProxiesCache() {
    _proxiesCache = null;
    _proxiesAt = null;
  }

  static Future<ReturnResult<ClashConfigs>>? _configsInflight;
  static ReturnResult<ClashConfigs>? _configsCache;
  static DateTime? _configsAt;
  static const Duration _configsTtl = Duration(seconds: 1);

  static void invalidateConfigsCache() {
    _configsCache = null;
    _configsAt = null;
  }

  @visibleForTesting
  static void debugResetControlState() {
    resetControlConnection();
    invalidateProxiesCache();
    _proxiesInflight = null;
  }

  static Future<ReturnResult<ClashConfigs>> getConfigs() {
    final cached = _configsCache;
    final at = _configsAt;
    if (cached != null &&
        at != null &&
        DateTime.now().difference(at) < _configsTtl) {
      return Future.value(cached);
    }
    final inflight = _configsInflight;
    if (inflight != null) {
      return inflight;
    }
    final future = _fetchConfigs();
    _configsInflight = future;
    return future.whenComplete(() {
      if (identical(_configsInflight, future)) {
        _configsInflight = null;
      }
    });
  }

  static Future<ReturnResult<ClashConfigs>> _fetchConfigs() async {
    final result = await controlRequest("GET", "/configs");
    if (result.error != null) {
      return ReturnResult(error: result.error);
    }
    try {
      var decodedResponse = jsonDecode(result.data!.item2);
      ClashConfigs configs = ClashConfigs();
      configs.fromJson(decodedResponse);
      final out = ReturnResult(data: configs);
      _configsCache = out;
      _configsAt = DateTime.now();
      return out;
    } catch (err) {
      return ReturnResult(error: ReturnResultError(err.toString()));
    }
  }

  @visibleForTesting
  static Future<ReturnResult<int>> Function(String node, String url, Duration timeout)?
      debugDelayOverride;

  static Future<ReturnResult<int>> getDelay(
    String node, {
    String url = "https://www.gstatic.com",
    Duration timeout = const Duration(seconds: 5),
  }) async {
    final delayOverride = debugDelayOverride;
    if (delayOverride != null) {
      return delayOverride(node, url, timeout);
    }
    final encodeNode = Uri.encodeComponent(node);
    final encodeUrl = Uri.encodeComponent(url);
    final result = await controlRequest(
      "GET",
      "/proxies/$encodeNode/delay?url=$encodeUrl&timeout=${timeout.inMilliseconds}",
      timeout: timeout,
    );
    if (result.error != null) {
      return ReturnResult(error: result.error);
    }
    try {
      var decodedResponse = jsonDecode(result.data!.item2);
      int? delay = decodedResponse["delay"];
      String? err = decodedResponse["err"];
      if (err != null) {
        return ReturnResult(error: ReturnResultError(err));
      }
      return ReturnResult(data: delay);
    } catch (err) {
      return ReturnResult(error: ReturnResultError(err.toString()));
    }
  }

  static Future<Map<String, int>> getGroupDelay(
    String group, {
    String url = "https://www.gstatic.com/generate_204",
    Duration timeout = const Duration(seconds: 5),
  }) async {
    final encodeGroup = Uri.encodeComponent(group);
    final encodeUrl = Uri.encodeComponent(url);
    final result = await controlRequest(
      "GET",
      "/group/$encodeGroup/delay?url=$encodeUrl&timeout=${timeout.inMilliseconds}",
      timeout: timeout + const Duration(seconds: 10),
    );
    if (result.error != null) {
      return {};
    }
    try {
      final decoded = jsonDecode(result.data!.item2);
      if (decoded is! Map) {
        return {};
      }
      final out = <String, int>{};
      decoded.forEach((k, v) {
        if (v is num) {
          out[k.toString()] = v.toInt();
        }
      });
      return out;
    } catch (err) {
      return {};
    }
  }

  static Future<ReturnResult<List<ClashProxiesNode>>> getProxies({
    bool force = false,
  }) {
    if (!force) {
      final cached = _proxiesCache;
      final at = _proxiesAt;
      if (cached != null &&
          at != null &&
          DateTime.now().difference(at) < _proxiesTtl) {
        return Future.value(cached);
      }
      final inflight = _proxiesInflight;
      if (inflight != null) {
        return inflight;
      }
    }
    final future = _fetchProxies();
    _proxiesInflight = future;
    return future.whenComplete(() {
      if (identical(_proxiesInflight, future)) {
        _proxiesInflight = null;
      }
    });
  }

  /// 读 /proxies 的短退避重试（只对**瞬时**错误重试）。
  ///
  /// 真机现象：刚连上内核、或正在批量测速时，控制口会短暂超时/拒绝连接，
  /// 之前一次失败就让上层显示「暂时读不到内核的节点状态」，几秒后自己又好了。
  /// 这里把这类抖动挡在 API 层：超时/连接被拒/5xx 各重试 2 次（约 1 秒），
  /// 401/403（密钥或端口不对）**不重试**，那种错误重试多少次也没用。
  static bool isTransientControlError(String message) {
    final m = message.toLowerCase();
    const transient = [
      'timeoutexception',
      'timed out',
      'timeout',
      'connection refused',
      'connection reset',
      'socketexception',
      'broken pipe',
      'connection closed',
      '502',
      '503',
      '504',
      '控制端口未就绪',
    ];
    return transient.any(m.contains);
  }

  static Future<ReturnResult<Tuple2<int, String>>> _proxiesReadWithRetry() async {
    var r = await controlRequest("GET", "/proxies", timeout: proxiesReadTimeout);
    for (var attempt = 1;
        attempt <= 2 && r.error != null && isTransientControlError(r.error!.message);
        attempt++) {
      Log.w("ClashHttpApi: /proxies 读取失败（${r.error!.message}），"
          "第 $attempt 次重试");
      await Future.delayed(Duration(milliseconds: 300 * attempt));
      r = await controlRequest("GET", "/proxies", timeout: proxiesReadTimeout);
    }
    return r;
  }

  static Future<ReturnResult<List<ClashProxiesNode>>> _fetchProxies() async {
    final resultProxies = await _proxiesReadWithRetry();
    if (resultProxies.error != null) {
      return ReturnResult(error: resultProxies.error);
    }
    ClashProxies proxies = ClashProxies();
    try {
      final payload = resultProxies.data!.item2;
      // 500+ 节点的 /proxies 响应有几百 KB：jsonDecode 在主 isolate 上要几毫秒到
      // 几十毫秒，叠加每 15~30 秒的轮询就是持续性掉帧（Windows 上尤其明显）。
      // 大 payload 丢到后台 isolate 解析，主 isolate 只做对象构造。
      final Object? decodedResponse = payload.length > 64 * 1024
          ? await Isolate.run(() => jsonDecode(payload))
          : jsonDecode(payload);
      proxies.fromJsonProxies(decodedResponse as Map<String, dynamic>?);
    } catch (err) {
      return ReturnResult(error: ReturnResultError(err.toString()));
    }
    final resultProviders = await controlRequest(
      "GET",
      "/providers/proxies",
      timeout: proxiesReadTimeout,
    );
    if (resultProviders.error == null) {
      try {
        final payload = resultProviders.data!.item2;
        final Object? decodedResponse = payload.length > 64 * 1024
            ? await Isolate.run(() => jsonDecode(payload))
            : jsonDecode(payload);
        proxies.fromJsonProviders(decodedResponse as Map<String, dynamic>?);
      } catch (err) {
        // 只有 provider 这部分解析失败：已经成功拿到的 /proxies 不能一起丢掉 ——
        // 丢了上层就会把"当前节点读不到"当成"没有节点"，界面直接空白。
        Log.w("ClashHttpApi: 解析 /providers/proxies 失败，忽略这部分 $err");
      }
    }
    final out = ReturnResult(data: proxies.proxies);
    _proxiesCache = out;
    _proxiesAt = DateTime.now();
    return out;
  }

  static List<ClashProxiesNode> getNowChain(
    List<ClashProxiesNode> proxies,
    ClashProxiesNode node,
    String mode,
  ) {
    if (node.all.isEmpty) {
      return [node];
    }
    for (var proxy in proxies) {
      if (proxy.name == node.now) {
        List<ClashProxiesNode> nodes = getNowChain(proxies, proxy, mode);
        node.delay ??= proxy.delay;
        nodes.add(node);
        return nodes;
      }
    }

    return [node];
  }

  static Future<ReturnResult<List<ClashProxiesNode>>> getNowProxy(
    String mode,
  ) async {
    if (mode.isEmpty) {
      return ReturnResult(data: null);
    }
    ReturnResult<List<ClashProxiesNode>> result = await getProxies();
    if (result.error != null) {
      return ReturnResult(error: result.error);
    }
    if (result.data!.isEmpty) {
      return ReturnResult(data: null);
    }
    List<ClashProxiesNode> filtered = [];
    for (var node in result.data!) {
      if (ClashProtocolType.GroupToList().contains(node.type)) {
        filtered.add(node);
      }
    }

    if (filtered.isEmpty) {
      return ReturnResult(data: null);
    }

    final proxies = result.data!;
    if (mode == ClashConfigsMode.direct.name) {
      for (var proxy in proxies) {
        if (proxy.type == ClashProtocolType.direct.name) {
          return ReturnResult(data: [proxy]);
        }
      }
    } else if (mode == ClashConfigsMode.global.name) {
      for (var proxy in proxies) {
        if (proxy.name == "GLOBAL") {
          return ReturnResult(data: getNowChain(proxies, proxy, mode));
        }
      }
    }
    return ReturnResult(data: getNowChain(proxies, filtered.first, mode));
  }

  static Future<ReturnResultError?> setProxiesNode(
    String group,
    String node,
  ) async {
    final encodeGroup = Uri.encodeComponent(group);
    final body = JsonEncoder().convert({"name": node});
    final result = await controlRequest(
      "PUT",
      "/proxies/$encodeGroup",
      body: body,
    );
    if (result.error == null) {
      // 只**本地给这一组打补丁**，不清整表缓存。
      //
      // 旧实现 `invalidateProxiesCache()` 会让紧接着的界面刷新再全量拉一次
      // `/proxies`（几百 KB、超时 5s）；内核正忙着测速时这一下就是秒级等待 ——
      // 用户点一个节点，主页要等这趟往返才更新。
      // 补丁与内核事实等价（PUT 刚成功），15s 的定时同步仍以内核为准兜底。
      patchGroupNowInCache(group, node);
    }
    return result.error;
  }

  /// 切换节点成功后，本地把该选择组的 `now` 改掉（不清整表缓存）。
  @visibleForTesting
  static void patchGroupNowInCache(String group, String node) {
    final cached = _proxiesCache?.data;
    if (cached == null || group.isEmpty || node.isEmpty) {
      return;
    }
    for (final p in cached) {
      if (p.name == group) {
        p.now = node;
      }
    }
  }

  static Future<ReturnResult<List<String>>> dnsQuery(
    String domain, {
    String queryType = "A",
  }) async {
    final result = await controlRequest(
      "GET",
      "/dns/query?name=$domain&type=$queryType",
      timeout: const Duration(seconds: 10),
    );
    if (result.error != null) {
      return ReturnResult(error: result.error);
    }
    try {
      var decodedResponse = jsonDecode(result.data!.item2);
      final answer = decodedResponse["Answer"];
      List<String> ips = [];
      if (answer is List) {
        for (var item in answer) {
          String data = item["data"] ?? "";
          if (data.isNotEmpty) {
            ips.add(data);
          }
        }
        return ReturnResult(data: ips);
      }

      return ReturnResult(data: ips);
    } catch (err) {
      return ReturnResult(error: ReturnResultError(err.toString()));
    }
  }

  static Future<ReturnResultError?> setConfigsMode(String mode) async {
    final body = JsonEncoder().convert({"mode": mode});
    final result = await controlRequest(
      "PATCH",
      "/configs",
      body: body,
      timeout: const Duration(seconds: 2),
    );
    if (result.error == null) {
      invalidateProxiesCache();
      invalidateConfigsCache();
    }
    return result.error;
  }

  static String convertTrafficToStringDouble(num? value, {num kb = 1024}) {
    if (value == null || value < 0) {
      return "";
    }
    num kKB = kb;
    num kMB = kb * kKB;
    num kGB = kb * kMB;
    num kTB = kb * kGB;
    num kPB = kb * kTB;
    if (value >= kPB) {
      return "${(value / kPB).toStringAsFixed(1)} PB";
    }
    if (value >= kTB) {
      return "${(value / kTB).toStringAsFixed(1)} TB";
    }
    if (value >= kGB) {
      return "${(value / kGB).toStringAsFixed(1)} GB";
    }
    if (value >= kMB) {
      return "${(value / kMB).toStringAsFixed(1)} MB";
    }
    if (value >= kKB) {
      return "${(value / kKB).toStringAsFixed(1)} KB";
    }
    return "$value B";
  }
}
