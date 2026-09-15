/// 账户状态与准入闸门。
///
/// 对应设计稿：`docs/design/06` §6.2.5（账户状态条）与 §4.7.2（准入闸门 5 态）。
///
/// 为什么单独做一个 ChangeNotifier：
///   * 首页的连接开关需要**在构建时**就知道账号是否受限（受限要禁用开关），
///     而不是点下去再弹窗 —— 后者会让用户以为"点了没反应"；
///   * 「我的」Tab、「套餐」Tab 也要读同一份状态，集中一处避免三处各自请求。
library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:mclash/app/utils/log.dart';
import 'package:mclash/mf/mclash_api.dart';

/// 受限原因（与后台状态一一对应）
enum MclashBlockKind {
  none,

  /// 未开通套餐
  noSubscription,

  /// 已到期
  expired,

  /// 订阅被停用
  subscriptionDisabled,

  /// 账号被禁用
  accountDisabled,

  /// 设备数已达上限
  deviceFull,

  /// 本设备已被踢下线
  deviceKicked,
}

class MclashAccountService extends ChangeNotifier {
  MclashAccountService._();

  static final MclashAccountService instance = MclashAccountService._();

  Map<String, dynamic>? _dash;
  Map<String, dynamic>? _sub;

  bool _loading = false;

  /// 设备被踢下线：由订阅拉取的 403 文案触发（`SubscriptionService.isKickedMessage`）
  bool _kicked = false;

  Map<String, dynamic>? get dashboard => _dash;
  Map<String, dynamic>? get subscription => _sub;
  bool get loading => _loading;

  Timer? _timer;

  /// 登录后启动：立即拉一次，之后每 5 分钟刷新
  void start() {
    refresh();
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(minutes: 5), (_) => refresh());
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    _dash = null;
    _sub = null;
    _kicked = false;
    notifyListeners();
  }

  /// 被踢下线（订阅 403）→ 立即转为受限态并断开
  void markKicked() {
    _kicked = true;
    notifyListeners();
  }

  Future<void> refresh() async {
    if (!MclashApi.isLoggedIn) {
      return;
    }
    if (_loading) {
      return;
    }
    _loading = true;
    try {
      Map<String, dynamic>? dash;
      Map<String, dynamic>? sub;
      await Future.wait([
        MclashApi.dashboard().then((v) => dash = v).catchError((e) {
          Log.w("account: dashboard failed $e");
          return null;
        }),
        MclashApi.subscription().then((v) => sub = v).catchError((e) {
          Log.w("account: subscription failed $e");
          return null;
        }),
      ]);
      if (dash != null) {
        _dash = dash;
      }
      if (sub != null) {
        _sub = sub;
      }
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // ---------------------------------------------------------------------
  // 准入判定
  // ---------------------------------------------------------------------

  bool get isBlocked => blockKind != MclashBlockKind.none;

  MclashBlockKind get blockKind {
    if (_kicked) {
      return MclashBlockKind.deviceKicked;
    }
    // 账号级禁用优先于订阅级（禁用账号连套餐页也不该让他买）
    if (_dash?["is_active"] == false) {
      return MclashBlockKind.accountDisabled;
    }
    final status = _dash?["subscription_status"]?.toString() ??
        _sub?["status"]?.toString() ??
        "";
    final subActive = _sub?["is_active"] != false;
    final expired = _sub?["is_expired"] == true || status == "expired";

    if (!subActive || status == "disabled") {
      return MclashBlockKind.subscriptionDisabled;
    }
    if (expired) {
      return MclashBlockKind.expired;
    }

    final limit = (_sub?["device_limit"] as num?)?.toInt() ??
        (_dash?["total_devices"] as num?)?.toInt() ??
        0;
    final used = (_sub?["current_devices"] as num?)?.toInt() ??
        (_dash?["online_devices"] as num?)?.toInt() ??
        0;
    if (limit > 0 && used >= limit) {
      return MclashBlockKind.deviceFull;
    }

    final url = _sub?["subscribe_url"]?.toString() ?? "";
    if (url.isEmpty && status != "active") {
      return MclashBlockKind.noSubscription;
    }
    return MclashBlockKind.none;
  }

  /// 首页状态条 / 弹窗标题
  String get blockTitle {
    switch (blockKind) {
      case MclashBlockKind.expired:
        return "套餐已到期";
      case MclashBlockKind.deviceFull:
        return "设备数量已达上限";
      case MclashBlockKind.accountDisabled:
        return "账号已被禁用";
      case MclashBlockKind.subscriptionDisabled:
        return "套餐已被禁用";
      case MclashBlockKind.noSubscription:
        return "尚未开通套餐";
      case MclashBlockKind.deviceKicked:
        return "本设备已被移除";
      case MclashBlockKind.none:
        return "";
    }
  }

  /// 弹窗正文（受限时文案必须指向可操作方向，不允许含糊）
  String get blockText {
    switch (blockKind) {
      case MclashBlockKind.expired:
        return "您的套餐已到期，购买套餐后即可继续畅连全球节点。";
      case MclashBlockKind.deviceFull:
        final limit = (_sub?["device_limit"] as num?)?.toInt() ?? 0;
        final used = (_sub?["current_devices"] as num?)?.toInt() ?? 0;
        return "设备数量已达上限（$used/$limit），无法连接新设备。"
            "可在「我的 - 设备管理」中删除不常用设备，或升级更高设备数的套餐。";
      case MclashBlockKind.accountDisabled:
        return "您的账号已被禁用，无法使用服务。如有疑问，请联系客服。";
      case MclashBlockKind.subscriptionDisabled:
        return "您的套餐已被禁用或状态异常，无法连接。如有疑问，请联系客服。";
      case MclashBlockKind.noSubscription:
        return "您还没有开通套餐，开通后即可畅连全球节点。";
      case MclashBlockKind.deviceKicked:
        return "本设备已被移除并踢下线，请重新登录。";
      case MclashBlockKind.none:
        return "";
    }
  }

  /// 状态条上的 emoji（Clash Mi 的 dialog 用 emoji 做视觉锚点）
  String get blockEmoji {
    switch (blockKind) {
      case MclashBlockKind.expired:
        return "⏰";
      case MclashBlockKind.deviceFull:
        return "📱";
      case MclashBlockKind.accountDisabled:
      case MclashBlockKind.subscriptionDisabled:
        return "🚫";
      case MclashBlockKind.noSubscription:
        return "🛒";
      case MclashBlockKind.deviceKicked:
        return "⚠️";
      case MclashBlockKind.none:
        return "";
    }
  }

  /// 首页账户状态条文案（正常态与受限态共用一行）
  String get statusBarText {
    if (isBlocked) {
      return "$blockEmoji $blockTitle";
    }
    final membership = _dash?["membership"]?.toString() ?? "";
    final remaining = (_dash?["remaining_days"] as num?)?.toInt() ?? 0;
    final online = (_dash?["online_devices"] as num?)?.toInt() ?? 0;
    final total = (_dash?["total_devices"] as num?)?.toInt() ?? 0;
    final parts = <String>[
      if (membership.isNotEmpty) membership,
      if (remaining > 0) "剩余 $remaining 天",
      if (total > 0) "设备 $online/$total",
    ];
    return parts.isEmpty ? "" : parts.join(" · ");
  }

  /// 即将到期（≤7 天）—— 用红色但不算"受限"
  bool get expiringSoon {
    if (isBlocked) {
      return false;
    }
    final remaining = (_dash?["remaining_days"] as num?)?.toInt() ?? 0;
    return remaining > 0 && remaining <= 7;
  }
}
