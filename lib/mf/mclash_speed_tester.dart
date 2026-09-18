library;

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:mclash/app/clash/clash_http_api.dart';
import 'package:mclash/app/modules/setting_manager.dart';
import 'package:mclash/app/utils/log.dart';
import 'package:mclash/mf/mclash_node.dart';

/// 节点测速。**内核支持的每一种协议都必须成立。**
///
/// ## 两条路径
///
/// 1. **内核 API（首选，协议无关）**：`GET /proxies/{name}/delay?url=…`
///    —— 由内核按节点**自己的协议**真正发一次 HTTP 请求再返回耗时。
///    只要是内核能承载的协议都能测：`ss` / `ssr` / `vmess` / `vless` / `trojan` /
///    `hysteria` / `hysteria2` / `tuic` / `wireguard` / `snell` / `ssh` /
///    `http` / `socks5` / `anytls` / `mieru` …（含纯 UDP 的那几种）。
///    它还顺带识别「端口通、但密码/UUID 错或节点已下线」的死节点
///    —— 这是 TCP 握手永远识别不了的。
///
/// 2. **本机 TCP 粗测（仅内核不可用时兜底）**：`Socket.connect(server, port)`。
///    只能证明那个端口能握手：
///      * 对**纯 UDP 协议**（hysteria / hysteria2 / tuic / wireguard）**完全无效**，
///        所以这些协议在内核不可用时保持「延迟未知」而不是编一个数字；
///      * 对 CDN 前置的 TCP 节点，测到的是**边缘节点**的延迟，不是代理延迟。
///    因此它标出来的值一律 `measuredByKernel = false`，UI 需要如实区分。
///
/// 历史问题（本次修复）：旧实现**只用** TCP 粗测，并且把纯 UDP 协议直接排除在
/// 测速之外 —— 那类节点永远没有延迟、永远进不了「自动最优」，首页
/// 「延迟最低的 6 个国家」也看不到它们。
class MclashSpeedTester {
  MclashSpeedTester({this.connectTimeout = const Duration(seconds: 5)});

  static final MclashSpeedTester instance = MclashSpeedTester();

  final Duration connectTimeout;

  /// TCP 粗测的采样次数（取中位数，抗抖动）。
  static const int probeCount = 3;

  /// 并发上限。
  ///
  /// 以前是 12，后来 6，现在 3。
  ///
  /// 每一次探测都是「内核去连一次测速地址」：12 路并发时，连接后被立刻拉起的
  /// 自动测速会把内核的 CPU 与连接表塞满，真正需要内核响应的东西（切节点、
  /// 读配置、流量订阅、界面刷新）全排在后面 —— 用户的原话是「连接之后非常卡，
  /// 根本点不动」。3 路并发虽然测得慢一些，但**连接后的流畅度**回来了，
  /// 而且我们本来就有延迟缓存（连接后绝大多数节点不需要重测）。
  static const int maxConcurrent = 3;

  /// 连续这么多次「内核根本没在听」就整批放弃。
  ///
  /// 用户日志里最刺眼的一段就是这个：内核 16:35:22 已经停了，测速还在继续，
  /// 从 16:35:24 到 16:35:30 刷了几百行
  /// `SocketException: 远程计算机拒绝网络连接 (errno = 1225)` —— 每一条都要
  /// 新建连接、失败、写一行同步日志。而结论在**失败第一条**时就已经确定了。
  static const int fatalStreakLimit = 8;

  /// 上一轮测速中「内核里还没有」的节点数量（供上层决定要不要重载内核）。
  static int missingInKernel = 0;

  /// 本轮的「内核不在了」连续计数（跨 worker 共享，所以放在实例字段上）。
  int _deadStreak = 0;
  bool _kernelGone = false;

  /// 这条错误是不是「内核压根没在监听」。
  ///
  /// 这类错误重试没有意义（对方连不上就是连不上），而且一旦出现就说明整批测速
  /// 的前提已经崩了。区分它和「节点不通」很重要：后者要如实标记节点离线，
  /// 前者不能把 400 个节点全判成离线（那会误导用户去清空订阅）。
  static bool isKernelUnreachable(String message) {
    final m = message.toLowerCase();
    return m.contains("远程计算机拒绝网络连接") ||
        m.contains("connection refused") ||
        m.contains("errno = 1225") ||
        m.contains("errno=1225") ||
        m.contains("connection closed before full header was received") ||
        m.contains("connection reset by peer") ||
        m.contains("socketexception");
  }

  @visibleForTesting
  static Future<int> Function(MclashNode node)? debugProbeOverride;

  /// 测试缝：内核是否可用（真实实现是一次轻量的 `/configs` 探测）。
  @visibleForTesting
  static Future<bool> Function()? debugKernelAvailableOverride;

  /// 测试缝：内核的按节点延迟测试（真实实现是 `/proxies/{name}/delay`）。
  @visibleForTesting
  static Future<int> Function(MclashNode node)? debugKernelDelayOverride;

  /// 内核连通性缓存：一次批量测速只探一次，避免每个节点都打一次 `/configs`。
  bool? _kernelUp;
  DateTime? _kernelCheckedAt;
  static const Duration _kernelProbeTtl = Duration(seconds: 5);

  /// 丢掉「内核是否可用」的缓存，下一次测速重新探一次。
  ///
  /// 连接/断开之后内核状态会变，缓存留着会让结果慢半拍。
  void resetKernelCache() {
    _kernelUp = null;
    _kernelCheckedAt = null;
  }

  /// 内核（控制 API）现在能不能用。
  Future<bool> kernelAvailable() async {
    final override = debugKernelAvailableOverride;
    if (override != null) {
      return override();
    }
    final up = _kernelUp;
    final at = _kernelCheckedAt;
    if (up != null &&
        at != null &&
        DateTime.now().difference(at) < _kernelProbeTtl) {
      return up;
    }
    var ok = false;
    // 控制端口没注册就是「内核没在跑」，别去发无意义的请求。
    if (ClashHttpApi.getControlPort?.call() != null) {
      try {
        final r = await ClashHttpApi.getConfigs();
        ok = r.error == null && r.data != null;
      } catch (_) {
        ok = false;
      }
    }
    _kernelUp = ok;
    _kernelCheckedAt = DateTime.now();
    return ok;
  }

  /// 测一个节点，返回毫秒（-1 = 测不出来 / 不可用）。
  ///
  /// 内核在跑 → 走内核（所有协议都支持）；内核没跑 → TCP 粗测兜底。
  Future<int> testOne(MclashNode node, {bool? kernelUp}) async {
    if (node.name.isEmpty || node.server.isEmpty || node.port <= 0) {
      return -1;
    }

    final up = kernelUp ?? await kernelAvailable();
    if (up) {
      // 内核可用时**必须**以内核结果为准：TCP 兜底在这时会给出
      // 「端口通就当作在线」的假结论，比没有结论更糟。
      final probe = debugKernelDelayOverride ?? _probeViaKernel;
      final ms = await probe(node);
      node.testedByKernel = true;
      node.measuredByKernel = ms >= 0;
      return ms;
    }

    node.testedByKernel = false;
    node.measuredByKernel = false;
    // 内核不可用：纯 UDP 协议连端口都握不上手，如实保持未知，不编数字。
    if (node.udpOnly) {
      return -1;
    }
    final override = debugProbeOverride;
    if (override != null) {
      return override(node);
    }
    return _probeViaTcp(node);
  }

  /// 内核的 `/proxies/{name}/delay`。返回 -1 表示这个节点确实不通/不在内核里。
  ///
  /// 用**用户设置里那个测速地址与超时**（与节点列表里手动测速同一口径），
  /// 否则两处结果会对不上。
  Future<int> _probeViaKernel(MclashNode node) async {
    var url = "https://www.gstatic.com/generate_204";
    var timeout = connectTimeout;
    try {
      final cfg = SettingManager.getConfig();
      if (cfg.delayTestUrl.isNotEmpty) {
        url = cfg.delayTestUrl;
      }
      if (cfg.delayTestTimeout > 0) {
        timeout = Duration(milliseconds: cfg.delayTestTimeout);
      }
    } catch (_) {}
    try {
      var r = await ClashHttpApi.getDelay(node.name, url: url, timeout: timeout);
      // 慢节点再测一次取较小值：这类订阅节点抖动极大（本机实测同一节点在不同
      // 时刻 333ms ~ 4158ms），单次采样会把瞬时拥塞当成节点质量。只对「>=1.5s 的
      // 慢结果」补一次，代价可忽略（快节点不会多测）。
      final firstMs = r.data ?? -1;
      // 只对「明显慢」的结果补测一次（阈值从 1.5s 提到 2.5s）：慢节点本来就多，
      // 每个都补测等于把请求数翻倍 —— 连接后那几百个请求就是这么来的。
      if (r.error == null && firstMs >= 2500) {
        final again = await ClashHttpApi.getDelay(
          node.name,
          url: url,
          timeout: timeout,
        );
        if (again.error == null &&
            (again.data ?? -1) > 0 &&
            (again.data ?? -1) < firstMs) {
          r = again;
        }
      }
      if (r.error != null) {
        final msg = r.error!.message;
        // 节点不在**当前运行的内核**里（配置档刚换过、内核还没重启）：
        // 这不能判成「节点挂了」，只能算「这次没测到」。
        if (msg.contains("404") || msg.toLowerCase().contains("not found")) {
          node.missingInKernel = true;
          Log.i("MclashSpeedTester: 内核里还没有节点 [${node.name}]，本次跳过");
        } else if (isKernelUnreachable(msg)) {
          // 控制端口连不上 = 内核已经不在（用户断开、内核崩了）。这时**不要**
          // 给节点标离线：结论是「这批没测成」，不是「这批节点都挂了」。
          node.missingInKernel = true;
          _deadStreak++;
          if (_deadStreak == fatalStreakLimit) {
            _kernelGone = true;
            Log.w(
              "MclashSpeedTester: 控制端口连续 $fatalStreakLimit 次连不上"
              "（内核已停止或正在重启）→ 中止本轮测速，不再逐个尝试",
            );
          }
        }
        return -1;
      }
      _deadStreak = 0;
      final ms = r.data ?? -1;
      if (ms > 0) {
        node.missingInKernel = false;
      }
      return ms > 0 ? ms : -1;
    } catch (_) {
      return -1;
    }
  }

  /// 本机 TCP 握手粗测（中位数）。
  Future<int> _probeViaTcp(MclashNode node) async {
    final samples = <int>[];
    for (var i = 0; i < probeCount; i++) {
      final sw = Stopwatch()..start();
      Socket? socket;
      try {
        socket = await Socket.connect(
          node.server,
          node.port,
          timeout: connectTimeout,
        );
        sw.stop();
        samples.add(sw.elapsedMilliseconds);
      } catch (_) {
        return -1;
      } finally {
        socket?.destroy();
      }
    }
    samples.sort();
    return samples[samples.length ~/ 2];
  }

  /// 批量测速（带并发上限与进度回调）。
  ///
  /// **不再按 `udpOnly` 过滤节点**：内核在跑时所有协议都能测。
  Future<void> testAll(
    List<MclashNode> nodes, {
    void Function(int done, int total)? onProgress,
    void Function(MclashNode node)? onEach,
    bool Function()? shouldStop,
  }) async {
    if (nodes.isEmpty) {
      return;
    }
    final kernelUp = await kernelAvailable();
    final swBatch = Stopwatch()..start();
    Log.i(
      "MclashSpeedTester: 开始测速 ${nodes.length} 个节点（并发 $maxConcurrent）"
      "（${kernelUp ? "走内核 /delay，协议无关" : "内核未运行 → 本机 TCP 粗测"}）",
    );

    final queue = List<int>.generate(nodes.length, (i) => i);
    var done = 0;
    /// 本次测速里「内核还没有」的节点数量（>0 说明内核配置落后于订阅）。
    missingInKernel = 0;
    _deadStreak = 0;
    _kernelGone = false;

    Future<void> worker() async {
      while (queue.isNotEmpty) {
        if (shouldStop != null && shouldStop()) {
          break;
        }
        // 内核已经不在了（连续多次连接被拒）：剩下的节点一个都测不了，
        // 继续跑只会制造几百行「拒绝连接」的日志。整批停。
        if (_kernelGone) {
          break;
        }
        final n = nodes[queue.removeLast()];
        n.missingInKernel = false;
        final ms = await testOne(n, kernelUp: kernelUp);
        n.latencyMs = ms;
        if (ms > 0) {
          n.online = true;
        } else if (n.missingInKernel) {
          // 内核里根本没这个节点（订阅刚换、内核还在跑旧配置）→
          // **不是节点挂了**，别标成离线/超时，交给上层去重载内核。
          n.online = true;
          missingInKernel++;
        } else if (n.udpOnly && !kernelUp) {
          // 内核没跑 + 纯 UDP 协议：**测不了 ≠ 离线**，
          // 否则一堆其实能用的节点会被标成挂了。
          n.online = true;
        } else {
          n.online = false;
        }
        done++;
        onProgress?.call(done, nodes.length);
        onEach?.call(n);
      }
    }

    final count = nodes.length < maxConcurrent ? nodes.length : maxConcurrent;
    await Future.wait(List.generate(count, (_) => worker()));
    if (onProgress != null) {
      onProgress(nodes.length, nodes.length);
    }
    swBatch.stop();
    // 一轮测速的规模与耗时如实记下来：用户报「连接后卡顿」时，这两行能直接
    // 说明测速是不是元凶（例如「开始 411 个节点」就是坏味道）。
    Log.i(
      "MclashSpeedTester: 测速结束 ${nodes.length} 个节点，用时 ${swBatch.elapsedMilliseconds} ms"
      "${_kernelGone ? "（内核中途不可用，已提前中止）" : ""}",
    );
  }

  static Map<String, int> bestLatencyByCountry(Iterable<MclashNode> nodes) {
    final map = <String, int>{};
    for (final n in nodes) {
      if (!n.online || !n.latencyUsable) {
        continue;
      }
      final code = n.countryCode ?? "XX";
      final cur = map[code];
      if (cur == null || n.latencyMs < cur) {
        map[code] = n.latencyMs;
      }
    }
    return map;
  }

  static MclashNode? selectBest(Iterable<MclashNode> nodes) {
    final online = nodes.where((n) => n.online && n.latencyUsable).toList();
    if (online.isEmpty) {
      return null;
    }
    online.sort((a, b) => a.latencyMs.compareTo(b.latencyMs));
    return online.first;
  }
}
