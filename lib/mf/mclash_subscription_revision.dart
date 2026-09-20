library;

import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:mclash/app/utils/log.dart';
import 'package:mclash/mf/mclash_subscription_nodes.dart';

abstract final class MclashSubscriptionRevision {
  MclashSubscriptionRevision._();

  static String? _running;

  static Future<String> current() async {
    try {
      final nodes = await MclashSubscriptionNodes.loadNodes();
      final sb = StringBuffer();
      for (final n in nodes) {
        sb
          ..write(n.name)
          ..write('|')
          ..write(n.server)
          ..write(':')
          ..write(n.port)
          ..write(';');
      }
      return sha256.convert(utf8.encode(sb.toString())).toString();
    } catch (e) {
      Log.w("MclashSubscriptionRevision: 计算指纹失败 $e");
      return "";
    }
  }

  static Future<void> markRunning() async {
    final v = await current();
    if (v.isNotEmpty) {
      _running = v;
    }
  }

  static Future<bool> kernelIsStale() async {
    final running = _running;
    if (running == null || running.isEmpty) {
      return false;
    }
    final now = await current();
    if (now.isEmpty) {
      return false;
    }
    return now != running;
  }
}
