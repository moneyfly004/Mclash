library;

import 'package:mclash/mf/mclash_i18n.dart';

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

  /// 展示用标题（会拼进 [fullText] 上屏）。业务层没有 BuildContext，所以走
  /// [MclashI18n.t]，按当前全局语言取词。
  ///
  /// 注意 `other` 状态返回的是**服务端下发的原因原文**——那是数据，不做翻译。
  String get title {
    switch (state) {
      case MclashNoticeState.notFound:
        return MclashI18n.t.subNotice.titleNotFound;
      case MclashNoticeState.expired:
        return MclashI18n.t.subNotice.titleExpired;
      case MclashNoticeState.inactive:
        return MclashI18n.t.subNotice.titleInactive;
      case MclashNoticeState.deviceOverLimit:
        return MclashI18n.t.subNotice.titleDeviceOverLimit;
      case MclashNoticeState.other:
        return reason.isEmpty
            ? MclashI18n.t.subNotice.titleUnavailable
            : reason;
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

  /// 上屏用的整段提示（主页提示条 / 拦截弹窗都取这里）。
  ///
  /// 只翻译**本地拼出来的框架文案**（标题前缀 / 设备数 / 到期 / 客服 / 官网）；
  /// `reason`、`solution`、`expire` 等是服务端下发的数据，一律原样透传。
  String get fullText {
    final parts = <String>[];
    if (reason.isNotEmpty) {
      final e = emoji.isEmpty ? "❌" : emoji;
      // reason == title（other 状态）时 title 就是服务端原文，不必再加括号。
      parts.add(
        reason == title
            ? "$e $title"
            : MclashI18n.t.subNotice
                .titleWithReason(emoji: e, title: title, reason: reason),
      );
    } else if (title.isNotEmpty) {
      parts.add("$emoji $title");
    }
    if (deviceLimit > 0) {
      parts.add(MclashI18n.t.subNotice
          .deviceUsedOfLimit(used: deviceUsed, limit: deviceLimit));
    } else if (deviceUsed > 0) {
      parts.add(MclashI18n.t.subNotice.deviceUsedOnly(used: deviceUsed));
    }
    if (expire.isNotEmpty) {
      parts.add(MclashI18n.t.subNotice.expireAt(expire: expire));
    }
    if (solution.isNotEmpty) {
      // solution 是服务端原文，这里只补一个提示图标。
      parts.add("💡 $solution");
    }
    if (support.isNotEmpty) {
      parts.add(MclashI18n.t.subNotice.supportLine(account: support));
    }
    if (site.isNotEmpty) {
      parts.add(MclashI18n.t.subNotice.siteLine(url: site));
    }
    return parts.join("\n");
  }
}
