
library;

class MclashAccountInfo {
  MclashAccountInfo(this.dashboard, this.subscription);

  final Map<String, dynamic>? dashboard;

  final Map<String, dynamic>? subscription;

  Map<String, dynamic>? get _inner {
    final s = dashboard?["subscription"];
    return s is Map ? s.map((k, v) => MapEntry(k.toString(), v)) : null;
  }

  Map<String, dynamic>? _first(String key) {
    for (final m in [subscription, _inner, dashboard]) {
      if (m != null && m[key] != null) {
        return m;
      }
    }
    return null;
  }

  String _str(String key) => _first(key)?[key]?.toString().trim() ?? "";

  int? _int(String key) {
    final v = _first(key)?[key];
    if (v is num) {
      return v.toInt();
    }
    return int.tryParse(v?.toString() ?? "");
  }

  String get username {
    final u = dashboard?["username"]?.toString().trim() ?? "";
    return u;
  }

  double get balance {
    final v = dashboard?["balance"];
    if (v is num) {
      return v.toDouble();
    }
    return double.tryParse(v?.toString() ?? "") ?? 0;
  }

  String get planName {
    final p = _str("package_name");
    if (p.isNotEmpty) {
      return p;
    }
    return _str("level_name");
  }

  String get expireDate {
    final at = _str("expire_at");
    if (at.isNotEmpty) {
      return at;
    }
    final t = _str("expire_time");
    if (t.isEmpty) {
      return "";
    }
    return t.length >= 10 ? t.substring(0, 10) : t;
  }

  int? get remainingDays => _int("days_remaining") ?? _int("remaining_days");

  int? get deviceUsed => _int("current_devices") ?? _int("device_count");

  int? get deviceLimit => _int("device_limit") ?? _int("total_devices");

  String get status => _str("status");

  bool get isActive {
    final v = _first("is_active")?["is_active"];
    if (v is bool) {
      return v;
    }
    if (v != null) {
      return v.toString().toLowerCase() == "true";
    }

    return status.isEmpty || status == "active";
  }

  bool get hasSubscription {
    final v = dashboard?["has_subscription"];
    if (v is bool) {
      return v;
    }
    return isActive;
  }

  int? get nodeOnline => _int("node_online");
  int? get nodeTotal => _int("node_total");

  int? get orderCount => _int("order_count");

  bool get hasData =>
      dashboard != null || subscription != null;

  String? get deviceText {
    final used = deviceUsed;
    final limit = deviceLimit;
    if (used == null && limit == null) {
      return null;
    }
    return "${used ?? "-"} / ${limit ?? "-"}";
  }
}
