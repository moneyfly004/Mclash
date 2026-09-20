library;

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
    if (diff.isNegative || diff.inMinutes < 1) {
      return "刚刚";
    }
    if (diff.inMinutes < 60) {
      return "${diff.inMinutes} 分钟前";
    }
    if (diff.inHours < 24 && ref.day == at.day) {
      return "今天 ${_two(at.hour)}:${_two(at.minute)}";
    }
    return "${_two(at.month)}-${_two(at.day)} ${_two(at.hour)}:${_two(at.minute)}";
  }

  static String _two(int v) => v < 10 ? "0$v" : "$v";
}
