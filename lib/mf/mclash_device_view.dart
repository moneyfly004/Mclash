library;

import 'package:mclash/mf/mclash_i18n.dart';

abstract final class MclashDeviceView {
  static const Duration onlineWindow = Duration(minutes: 3);

  static bool isOnline(Map<String, dynamic> device, {DateTime? now}) {
    for (final key in const ["is_online", "online"]) {
      final v = device[key];
      if (v is bool) {
        return v;
      }
      if (v is num) {
        return v != 0;
      }
      if (v != null) {
        final s = v.toString().trim().toLowerCase();
        if (s == "true" || s == "1" || s == "online") {
          return true;
        }
        if (s == "false" || s == "0" || s == "offline") {
          return false;
        }
      }
    }
    final status = (device["status"] ?? "").toString().trim().toLowerCase();
    if (status == "online") {
      return true;
    }
    if (status == "offline") {
      return false;
    }
    final at = lastActiveAt(device);
    if (at == null) {
      return false;
    }
    return (now ?? DateTime.now()).difference(at) <= onlineWindow;
  }

  static DateTime? lastActiveAt(Map<String, dynamic> device) {
    for (final key in const ["last_heartbeat", "last_access", "last_seen"]) {
      final raw = (device[key] ?? "").toString().trim();
      if (raw.isEmpty) {
        continue;
      }
      final t = DateTime.tryParse(raw);
      if (t != null) {
        return t.toLocal();
      }
    }
    return null;
  }

  static String locationOf(Map<String, dynamic> device) {
    for (final key in const ["location", "region", "country"]) {
      final v = (device[key] ?? "").toString().trim();
      if (v.isNotEmpty && v != "未知") {
        return v;
      }
    }
    return "";
  }

  static String lastActiveText(Map<String, dynamic> device, {DateTime? now}) {
    final at = lastActiveAt(device);
    if (at == null) {
      return "";
    }
    final ref = now ?? DateTime.now();
    final diff = ref.difference(at);
    // 真机报障：这里原来写死中文，导致**所有非中文界面的设备卡片都显示中文时间**
    // （「刚刚」「N 分钟前」「今天 HH:MM」）。改为按当前语言取词。
    final t = MclashI18n.t;
    if (diff.isNegative || diff.inMinutes < 1) {
      return t.devicesScreen.lastActiveJustNow;
    }
    if (diff.inMinutes < 60) {
      return t.devicesScreen.lastActiveMinutes(minutes: diff.inMinutes);
    }
    if (diff.inHours < 24 && ref.day == at.day) {
      return t.devicesScreen.lastActiveToday(
        time: "${_two(at.hour)}:${_two(at.minute)}",
      );
    }
    return "${_two(at.month)}-${_two(at.day)} ${_two(at.hour)}:${_two(at.minute)}";
  }

  static String _two(int v) => v < 10 ? "0$v" : "$v";
}
