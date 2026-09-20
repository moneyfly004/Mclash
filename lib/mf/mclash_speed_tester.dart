library;

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:mclash/app/clash/clash_http_api.dart';
import 'package:mclash/app/modules/setting_manager.dart';
import 'package:mclash/app/utils/log.dart';
import 'package:mclash/mf/mclash_node.dart';

class MclashSpeedTester {
  MclashSpeedTester({this.connectTimeout = const Duration(seconds: 3)});

  static final MclashSpeedTester instance = MclashSpeedTester();

  final Duration connectTimeout;

  int _testGen = 0;

  static const int probeCount = 3;

  static const int maxConcurrent = 8;

  static const int udpMaxConcurrent = 2;

  static const int fatalStreakLimit = 24;

  static int missingInKernel = 0;

  static int lastSuccessCount = 0;

  int _deadStreak = 0;
  bool _kernelGone = false;

  static bool isKernelUnreachable(String message) {
    final m = message.toLowerCase();
    return m.contains("远程计算机拒绝网络连接") ||
        m.contains("connection refused") ||
        m.contains("errno = 1225") ||
        m.contains("errno=1225");
  }

  @visibleForTesting
  static Future<int> Function(MclashNode node)? debugProbeOverride;

  @visibleForTesting
  static Future<bool> Function()? debugKernelAvailableOverride;

  @visibleForTesting
  static Future<int> Function(MclashNode node)? debugKernelDelayOverride;

  bool? _kernelUp;
  DateTime? _kernelCheckedAt;
  static const Duration _kernelProbeTtl = Duration(seconds: 5);

  void resetKernelCache() {
    _kernelUp = null;
    _kernelCheckedAt = null;
  }

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

  Future<int> testOne(MclashNode node, {bool? kernelUp}) async {
    if (node.name.isEmpty || node.server.isEmpty || node.port <= 0) {
      return -1;
    }

    node.testedByKernel = false;
    node.measuredByKernel = false;

    final preferKernel = SettingManager.getConfig().speedTestMode ==
        SettingConfig.kSpeedTestModeKernel;

    if (preferKernel) {
      final up = kernelUp ?? await kernelAvailable();
      if (up) {
        final probe = debugKernelDelayOverride ?? _probeViaKernel;
        final ms = await probe(node);
        node.testedByKernel = true;
        node.measuredByKernel = ms >= 0;
        return ms;
      }
      if (node.udpOnly) {
        return -1;
      }
    } else if (node.udpOnly) {
      final up = kernelUp ?? await kernelAvailable();
      if (up) {
        final probe = debugKernelDelayOverride ?? _probeViaKernel;
        final ms = await probe(node);
        node.testedByKernel = true;
        node.measuredByKernel = ms >= 0;
        return ms;
      }
      return -1;
    }

    final override = debugProbeOverride;
    if (override != null) {
      return override(node);
    }
    return _probeViaTcp(node);
  }

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
      if (r.error != null) {
        final msg = r.error!.message;
        if (msg.contains("404") || msg.toLowerCase().contains("not found")) {
          node.missingInKernel = true;
          Log.i("MclashSpeedTester: 内核里还没有节点 [${node.name}]，本次跳过");
        } else if (isKernelUnreachable(msg)) {
          node.missingInKernel = true;
          _deadStreak++;
          if (_deadStreak >= fatalStreakLimit) {
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

  Future<void> testAll(
    List<MclashNode> nodes, {
    void Function(int done, int total)? onProgress,
    void Function(MclashNode node)? onEach,
    bool Function()? shouldStop,
  }) async {
    if (nodes.isEmpty) {
      return;
    }
    final gen = ++_testGen;
    final kernelUp = await kernelAvailable();
    final swBatch = Stopwatch()..start();
    Log.i(
      "MclashSpeedTester: 开始测速 ${nodes.length} 个节点（并发 $maxConcurrent）"
      "（TCP 握手，对齐 MoneyFly；UDP 节点${kernelUp ? "走内核 /delay 兜底" : "跳过"}）",
    );

    final tcpQueue = <int>[];
    final udpQueue = <int>[];
    for (var i = 0; i < nodes.length; i++) {
      (nodes[i].udpOnly ? udpQueue : tcpQueue).add(i);
    }
    var done = 0;
    var ok = 0;
    missingInKernel = 0;
    _deadStreak = 0;
    _kernelGone = false;

    Future<void> worker(List<int> queue) async {
      while (queue.isNotEmpty) {
        if (gen != _testGen) {
          break;
        }
        if (shouldStop != null && shouldStop()) {
          break;
        }
        if (_kernelGone) {
          break;
        }
        final n = nodes[queue.removeLast()];
        n.missingInKernel = false;
        final ms = await testOne(n, kernelUp: kernelUp);
        n.latencyMs = ms;
        if (ms > 0) {
          n.online = true;
          ok++;
        } else if (n.missingInKernel) {
          n.online = true;
          missingInKernel++;
        } else if (n.udpOnly && !kernelUp) {
          n.online = true;
        } else {
          n.online = false;
        }
        done++;
        onProgress?.call(done, nodes.length);
        onEach?.call(n);
      }
    }

    final tcpCount = tcpQueue.length < maxConcurrent ? tcpQueue.length : maxConcurrent;
    final udpCount = udpQueue.length < udpMaxConcurrent ? udpQueue.length : udpMaxConcurrent;
    await Future.wait([
      for (var i = 0; i < tcpCount; i++) worker(tcpQueue),
      for (var i = 0; i < udpCount; i++) worker(udpQueue),
    ]);
    if (onProgress != null) {
      onProgress(nodes.length, nodes.length);
    }
    swBatch.stop();
    lastSuccessCount = ok;
    Log.i(
      "MclashSpeedTester: 测速结束 ${nodes.length} 个节点，用时 ${swBatch.elapsedMilliseconds} ms"
      "（成功 $ok / 失败 ${nodes.length - ok}"
      "${_kernelGone ? "，内核中途不可用已提前中止" : ""}）",
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
