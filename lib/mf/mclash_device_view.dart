library;

/// 设备列表（`GET /subscriptions/devices`）的展示口径。
///
/// **真实事故**：设备管理里每台设备都显示「○ 离线」，包括本机 —— 而本机一直在
/// 打心跳，后台也明明记着 `is_online: true`（实测 device 182：
/// `last_heartbeat: 2026-09-17T00:16:30+08:00`）。
///
/// 原因：后端返回的字段是 **`is_online`**，界面却只读 `online`，于是恒为 false。
/// 这里把「在线判定 / 地区 / 最后活跃」的口径集中成纯函数，并用**线上真实字段**
/// 钉住（字段名不对就是恒离线，必须能被测试发现）。
abstract final class MclashDeviceView {
  /// 服务端的在线窗口：3 分钟内有心跳即在线（与后台判定一致）。
  static const Duration onlineWindow = Duration(minutes: 3);

  /// 设备是否在线。
  ///
  /// 优先信后端字段（`is_online` / `online` / `status`）；后端没给时才按最后活跃
  /// 时间自己判断 —— 宁可少显示一个「在线」，也不要凭空把离线设备说成在线。
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

  /// 最后活跃时间（后端只填其中一个字段，实测 `last_seen` 常为 null）。
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

  /// 地区：后端字段是 `region`（`location` 是历史口径，两个都认）。
  static String locationOf(Map<String, dynamic> device) {
    for (final key in const ["location", "region", "country"]) {
      final v = (device[key] ?? "").toString().trim();
      if (v.isNotEmpty && v != "未知") {
        return v;
      }
    }
    return "";
  }

  /// 「最后活跃」一行文案；没有可用时间就返回空串（不显示空行）。
  ///
  /// 3 分钟内 → 「刚刚」/「n 分钟前」；更早 → 「MM-dd HH:mm」。
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
