library;

import 'package:mclash/mf/mclash_node.dart';

/// 节点排序规则：**延迟最低的排最前**。
///
/// 用户反馈原文：「主页当中的连接按钮下面的节点切换，没有按照延迟排序，
/// 延迟最低的要放最前面」。所以「选择节点」这个弹层里**永远**按延迟升序排，
/// 不再依赖用户手动点「按延迟排序」。
///
/// 三条细节（都来自真实使用）：
///   1. **实测过延迟的排前面**，按毫秒升序；
///   2. 还没测到延迟（`-1`/不可用）的排在后面 —— 让它们插在中间会让
///      「最快的那个」被没数据的节点顶下去；
///   3. 延迟相同/都没数据时保持原来的顺序（稳定排序），并且最后一档用名字兜底，
///      这样列表不会在两次刷新之间无理由地跳来跳去。
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

/// 排序键：有实测延迟用毫秒值，没有就用一个很大的数（排到最后）。
int _latencyKey(MclashNode n) {
  if (n.latencyUsable && n.latencyMs > 0) {
    return n.latencyMs;
  }
  return 1 << 30;
}

/// 最快的那个节点（没有可用延迟时返回 null）。
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
