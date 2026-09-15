
library;

import 'dart:convert';
import 'dart:io';

import 'package:mclash/app/utils/log.dart';
import 'package:mclash/app/utils/path_utils.dart';
import 'package:mclash/mf/mclash_node.dart';
import 'package:path/path.dart' as path;

abstract final class MclashNodesCache {
  static const String _fileName = "nodes_cache.json";

  static Future<File> _file() async {
    final dir = await PathUtils.profileDir();
    return File(path.join(dir, _fileName));
  }

  static Future<void> save(Iterable<MclashNode> nodes) async {
    try {
      final list = nodes
          .where((n) => n.latencyMs >= 0 || n.online)
          .map(
            (n) => {
              'name': n.name,
              'server': n.server,
              'port': n.port,
              'latencyMs': n.latencyMs,
              'online': n.online,
            },
          )
          .toList();
      final f = await _file();
      await f.writeAsString(jsonEncode(list), flush: true);
    } catch (e) {
      Log.w("MclashNodesCache.save 失败 $e");
    }
  }

  static Future<int> apply(Iterable<MclashNode> nodes) async {
    try {
      final f = await _file();
      if (!await f.exists()) {
        return 0;
      }
      final raw = await f.readAsString();
      if (raw.trim().isEmpty) {
        return 0;
      }
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return 0;
      }
      final byKey = <String, Map<String, dynamic>>{};
      for (final e in decoded) {
        if (e is Map) {
          final m = e.map((k, v) => MapEntry(k.toString(), v));
          byKey["${m['name']}|${m['server']}:${m['port']}"] = m;
        }
      }
      var hit = 0;
      for (final n in nodes) {
        final m = byKey["${n.name}|${n.server}:${n.port}"];
        if (m == null) {
          continue;
        }
        n.latencyMs = (m['latencyMs'] as num?)?.toInt() ?? -1;
        n.online = m['online'] == true;
        hit++;
      }
      return hit;
    } catch (e) {
      Log.w("MclashNodesCache.apply 失败 $e");
      return 0;
    }
  }
}
