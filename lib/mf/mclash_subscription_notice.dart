library;

/// 后端在「订阅不可用」时下发的**提示节点**里携带的信息。
///
/// 背景（用户要求的行为）：当客户
///   * 套餐已到期、或被禁用（`status != active` / `is_active = false`）、
///   * 或设备数超过上限（拉订阅时当下判定），
/// 后端会让这次订阅请求**只下发提示节点**（`📢 官网:` / `❌ 原因:` /
/// `💡 解决:` / `💬 客服:`，节点本体是 `baidu.com:1234` 的死节点），
/// 并把订阅名改成「订阅已过期 / 订阅已失效 / 设备超限 / 订阅不存在」。
///
/// 客户端据此完成三件事：
///   1. **覆盖本地配置档**（下载校验通过 → 原子替换，旧的真实节点被抹掉）；
///   2. **节点列表归零**（提示节点被 [MclashPseudoNodes] 过滤掉，自动选节点无候选）；
///   3. **禁止连接**（本文件解析出的状态会进入账号门禁，任何连接入口都会被拦住）。
///
/// 生产实测（只读）：`GET /api/v1/client/subscribe?token=<不存在>&type=clash` 返回
/// ```yaml
/// name: 订阅不存在
/// proxies:
///   - {name: "📢 官网: https://new.moneyfly.top", server: baidu.com, port: 1234, type: ss, ...}
///   - {name: "❌ 原因: 订阅不存在", ...}
///   - {name: "💡 解决: 请检查订阅地址是否正确", ...}
///   - {name: "💬 客服: …", ...}
/// ```
enum MclashNoticeState {
  /// 还没看过配置档 / 配置档里没有任何 proxies。
  unknown,

  /// 有真实节点 → 订阅可用。
  ok,

  /// `订阅不存在`（token 失效或订阅被删除）
  notFound,

  /// `订阅已过期`
  expired,

  /// `订阅已失效`（被禁用 / status 非 active）
  inactive,

  /// `设备数量超限`
  deviceOverLimit,

  /// 后端有 `❌ 原因:` 但原因不是上面几种（例如新增的
  /// 「服务暂时不可用」）。**同样禁止连接** —— 配置档里确实一个真实节点都没有，
  /// 放行只会让用户以为连上了；区别只是提示文案要如实转述后端的话。
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

  /// `❌ 原因:` 后面的原文（例如「订阅已过期」）。
  final String reason;

  /// `💡 解决:` 后面的原文（例如「请前往官网续费 (过期时间: 2026-01-01)」）。
  final String solution;

  /// `📢 官网:` 后面的站点地址。
  final String site;

  /// `💬 客服:` 后面的联系方式。
  final String support;

  /// `⏰ 到期:` 里的到期日期（可用订阅也会带）。
  final String expire;

  final int deviceUsed;
  final int deviceLimit;

  static const MclashSubscriptionNotice unknown = MclashSubscriptionNotice();

  static const MclashSubscriptionNotice ok = MclashSubscriptionNotice(
    state: MclashNoticeState.ok,
  );

  /// 是否应当**禁止连接**。
  bool get blocked =>
      state == MclashNoticeState.notFound ||
      state == MclashNoticeState.expired ||
      state == MclashNoticeState.inactive ||
      state == MclashNoticeState.deviceOverLimit ||
      state == MclashNoticeState.other;

  /// 「订阅已过期」这类短语，与后端下发的订阅名保持一致。
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

  /// 从配置档 `proxies` 的名字列表里还原出后端想说的话。
  ///
  /// 名字列表里只要存在**真实节点**就是 ok —— 老版本会在正常订阅前面插
  /// 信息节点（📢/⏰/📱），不能因为看到提示节点就判定订阅不可用。
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

    // 「当前设备 3/2，请在官网删除不使用的设备」里也带设备数
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
    // 有明确的「原因」但没有真实节点 → 一律视为不可用（如实转述后端文案）。
    return MclashNoticeState.other;
  }

  /// 给用户看的完整说明（原因 + 解决 + 客服 + 官网）。
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
