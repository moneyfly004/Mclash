library;

import 'package:mclash/mf/mclash_node.dart';

List<MclashNode> sortNodesByLatency(List<MclashNode> nodes) {
  final indexed = <MapEntry<int, MclashNode>>[
    for (var i = 0; i < nodes.length; i++) MapEntry(i, nodes[i]),
  ];
  indexed.sort((a, b) {
    final la = _latencyKey(a.value);
    final lb = _latencyKey(b.value);
    if (la != lb) {
      return la.compareTo(lb);
    }
    final byName = a.value.name.compareTo(b.value.name);
    if (byName != 0) {
      return byName;
    }
    return a.key.compareTo(b.key);
  });
  return [for (final e in indexed) e.value];
}

int _latencyKey(MclashNode n) {
  if (n.latencyUsable && n.latencyMs > 0) {
    return n.latencyMs;
  }
  return 1 << 30;
}

MclashNode? fastestNode(List<MclashNode> nodes) {
  MclashNode? best;
  for (final n in nodes) {
    if (!n.latencyUsable || n.latencyMs <= 0) {
      continue;
    }
    if (best == null || n.latencyMs < best.latencyMs) {
      best = n;
    }
  }
  return best;
}
