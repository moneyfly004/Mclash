
library;

import 'package:mclash/mf/mclash_pseudo_nodes.dart';

class NodeFilterEntry {
  const NodeFilterEntry({
    required this.name,
    this.type = "",
    this.isGroup = false,
    this.hidden = false,
  });

  final String name;
  final String type;

  final bool isGroup;

  final bool hidden;
}

class MclashNodeFilter {
  MclashNodeFilter._();

  static bool matches(NodeFilterEntry e, String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) {
      return true;
    }

    if (MclashPseudoNodes.isPseudo(e.name)) {
      return false;
    }
    return e.name.toLowerCase().contains(q) ||
        e.type.toLowerCase().contains(q);
  }

  static List<T> select<T>(
    List<T> all,
    String query, {
    required NodeFilterEntry Function(T) describe,
  }) {
    final q = query.trim();
    if (q.isEmpty) {

      return List<T>.from(all);
    }
    final out = <T>[];
    for (final item in all) {
      final e = describe(item);
      if (e.isGroup || e.hidden) {
        continue;
      }
      if (matches(e, q)) {
        out.add(item);
      }
    }
    return out;
  }
}
