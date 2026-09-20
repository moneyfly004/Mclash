library;

enum MclashNoticeState {
  unknown,

  ok,

  notFound,

  expired,

  inactive,

  deviceOverLimit,

  other,
}

class MclashSubscriptionNotice {
  const MclashSubscriptionNotice({
    this.state = MclashNoticeState.unknown,
    this.reason = "",
    this.solution = "",
    this.site = "",
    this.support = "",
    this.expire = "",
    this.deviceUsed = 0,
    this.deviceLimit = 0,
  });

  final MclashNoticeState state;

  final String reason;

  final String solution;

  final String site;

  final String support;

  final String expire;

  final int deviceUsed;
  final int deviceLimit;

  static const MclashSubscriptionNotice unknown = MclashSubscriptionNotice();

  static const MclashSubscriptionNotice ok = MclashSubscriptionNotice(
    state: MclashNoticeState.ok,
  );

  bool get blocked =>
      state == MclashNoticeState.notFound ||
      state == MclashNoticeState.expired ||
      state == MclashNoticeState.inactive ||
      state == MclashNoticeState.deviceOverLimit ||
      state == MclashNoticeState.other;

  String get title {
    switch (state) {
      case MclashNoticeState.notFound:
        return "订阅不存在";
      case MclashNoticeState.expired:
        return "订阅已过期";
      case MclashNoticeState.inactive:
        return "订阅已失效";
      case MclashNoticeState.deviceOverLimit:
        return "设备数量超限";
      case MclashNoticeState.other:
        return reason.isEmpty ? "订阅不可用" : reason;
      case MclashNoticeState.ok:
      case MclashNoticeState.unknown:
        return "";
    }
  }

  String get emoji {
    switch (state) {
      case MclashNoticeState.expired:
        return "⏰";
      case MclashNoticeState.deviceOverLimit:
        return "📱";
      case MclashNoticeState.notFound:
      case MclashNoticeState.inactive:
      case MclashNoticeState.other:
        return "🚫";
      case MclashNoticeState.ok:
      case MclashNoticeState.unknown:
        return "";
    }
  }

  static const String _kSitePrefix = "📢 官网:";
  static const String _kReasonPrefix = "❌ 原因:";
  static const String _kSolutionPrefix = "💡 解决:";
  static const String _kSupportPrefix = "💬 客服:";
  static const String _kExpirePrefix = "⏰ 到期:";
  static const String _kDevicePrefix = "📱 设备:";

  static MclashSubscriptionNotice parse(Iterable<String> proxyNames) {
    final names = proxyNames.where((n) => n.isNotEmpty).toList();
    if (names.isEmpty) {
      return unknown;
    }

    String reason = "";
    String solution = "";
    String site = "";
    String support = "";
    String expire = "";
    int used = 0;
    int limit = 0;
    var hasRealNode = false;

    for (final raw in names) {
      final name = raw.trim();
      if (name.startsWith(_kSitePrefix)) {
        site = name.substring(_kSitePrefix.length).trim();
        continue;
      }
      if (name.startsWith(_kReasonPrefix)) {
        reason = name.substring(_kReasonPrefix.length).trim();
        continue;
      }
      if (name.startsWith(_kSolutionPrefix)) {
        solution = name.substring(_kSolutionPrefix.length).trim();
        continue;
      }
      if (name.startsWith(_kSupportPrefix)) {
        support = name.substring(_kSupportPrefix.length).trim();
        continue;
      }
      if (name.startsWith(_kExpirePrefix)) {
        expire = name.substring(_kExpirePrefix.length).trim();
        continue;
      }
      if (name.startsWith(_kDevicePrefix)) {
        final m = RegExp(
          r"(\d+)\s*/\s*(\d+)",
        ).firstMatch(name.substring(_kDevicePrefix.length));
        if (m != null) {
          used = int.tryParse(m.group(1)!) ?? 0;
          limit = int.tryParse(m.group(2)!) ?? 0;
        }
        continue;
      }
      hasRealNode = true;
    }

    final dm = RegExp(r"当前设备\s*(\d+)\s*/\s*(\d+)").firstMatch(solution);
    if (dm != null) {
      used = int.tryParse(dm.group(1)!) ?? used;
      limit = int.tryParse(dm.group(2)!) ?? limit;
    }

    if (hasRealNode) {
      return MclashSubscriptionNotice(
        state: MclashNoticeState.ok,
        site: site,
        support: support,
        expire: expire,
        deviceUsed: used,
        deviceLimit: limit,
      );
    }

    if (reason.isEmpty) {
      return MclashSubscriptionNotice(
        state: MclashNoticeState.unknown,
        site: site,
        support: support,
      );
    }

    return MclashSubscriptionNotice(
      state: _stateOf(reason),
      reason: reason,
      solution: solution,
      site: site,
      support: support,
      expire: expire,
      deviceUsed: used,
      deviceLimit: limit,
    );
  }

  static MclashNoticeState _stateOf(String reason) {
    if (reason.contains("过期")) {
      return MclashNoticeState.expired;
    }
    if (reason.contains("失效") || reason.contains("禁用")) {
      return MclashNoticeState.inactive;
    }
    if (reason.contains("设备") && reason.contains("超")) {
      return MclashNoticeState.deviceOverLimit;
    }
    if (reason.contains("不存在")) {
      return MclashNoticeState.notFound;
    }
    return MclashNoticeState.other;
  }

  String get fullText {
    final parts = <String>[];
    if (reason.isNotEmpty) {
      parts.add("${emoji.isEmpty ? "❌" : emoji} $title${reason == title ? "" : "（$reason）"}");
    } else if (title.isNotEmpty) {
      parts.add("$emoji $title");
    }
    if (deviceLimit > 0) {
      parts.add("当前设备 $deviceUsed/$deviceLimit");
    } else if (deviceUsed > 0) {
      parts.add("当前设备 $deviceUsed");
    }
    if (expire.isNotEmpty) {
      parts.add("到期时间 $expire");
    }
    if (solution.isNotEmpty) {
      parts.add("💡 $solution");
    }
    if (support.isNotEmpty) {
      parts.add("💬 客服: $support");
    }
    if (site.isNotEmpty) {
      parts.add("📢 官网: $site");
    }
    return parts.join("\n");
  }
}
