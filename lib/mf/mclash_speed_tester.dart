
library;

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:mclash/mf/mclash_node.dart';

class MclashSpeedTester {
  MclashSpeedTester({this.connectTimeout = const Duration(seconds: 5)});

  static final MclashSpeedTester instance = MclashSpeedTester();

  final Duration connectTimeout;

  static const int probeCount = 3;

  static const int maxConcurrent = 12;

  @visibleForTesting
  static Future<int> Function(MclashNode node)? debugProbeOverride;

  Future<int> testOne(MclashNode node) async {
    final override = debugProbeOverride;
    if (override != null) {
      return override(node);
    }
    if (node.udpOnly) {
      return -1;
    }
    if (node.server.isEmpty || node.port <= 0) {
      return -1;
    }
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
    final queue = List<int>.generate(nodes.length, (i) => i);
    var done = 0;

    Future<void> worker() async {
      while (queue.isNotEmpty) {
        if (shouldStop != null && shouldStop()) {
          break;
        }
        final n = nodes[queue.removeLast()];
        if (n.udpOnly) {

          n.latencyMs = -1;
          n.online = true;
        } else {
          final ms = await testOne(n);
          n.latencyMs = ms;
          n.online = MclashSpeedTesterLatency.usable(ms);
        }
        done++;
        onProgress?.call(done, nodes.length);
        onEach?.call(n);
      }
    }

    final count = nodes.length < maxConcurrent ? nodes.length : maxConcurrent;
    await Future.wait(List.generate(count, (_) => worker()));
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
