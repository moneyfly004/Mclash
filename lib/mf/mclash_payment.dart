library;

import 'package:mclash/mf/mclash_i18n.dart';

enum MclashPayChannel {
  balance,

  alipayQr,

  alipayApp,

  wechatQr,

  crypto,

  cashierUrl,

  qr,
}

abstract final class MclashPay {
  static const String _alipaySaIdQr = "10000007";

  static MclashPayChannel classify(
    String payload, {
    String payType = "",
    String mode = "",
  }) {
    final type = payType.trim().toLowerCase();
    if (type == "balance") {
      return MclashPayChannel.balance;
    }
    final m = mode.trim().toLowerCase();
    if (m == "page" || m == "redirect") {
      return MclashPayChannel.cashierUrl;
    }
    final qrOnly = m == "qrcode";
    if (!qrOnly && type.startsWith("codepay")) {
      return MclashPayChannel.cashierUrl;
    }
    final low = payload.trim().toLowerCase();
    if (low.isEmpty) {
      return MclashPayChannel.qr;
    }
    if (low.startsWith("weixin://") || low.startsWith("wxp://")) {
      return MclashPayChannel.wechatQr;
    }
    if (low.startsWith("usdt:") ||
        low.startsWith("tron:") ||
        low.startsWith("ethereum:")) {
      return MclashPayChannel.crypto;
    }
    if (low.startsWith("alipay://") || low.startsWith("alipays://")) {
      return MclashPayChannel.alipayApp;
    }
    if (low.contains("qr.alipay.com")) {
      return MclashPayChannel.alipayQr;
    }
    if (low.startsWith("http://") || low.startsWith("https://")) {
      return qrOnly ? MclashPayChannel.qr : MclashPayChannel.cashierUrl;
    }
    return MclashPayChannel.qr;
  }

  static bool shouldOpenInBrowser(MclashPayChannel c) =>
      c == MclashPayChannel.cashierUrl;

  static bool canLaunchApp(MclashPayChannel c, {required bool isMobile}) =>
      isMobile &&
      (c == MclashPayChannel.alipayQr ||
          c == MclashPayChannel.alipayApp ||
          c == MclashPayChannel.cashierUrl);

  static String appLaunchTarget(String payload, MclashPayChannel c) {
    final s = payload.trim();
    if (c == MclashPayChannel.alipayQr ||
        s.toLowerCase().contains("qr.alipay.com")) {
      return "alipays://platformapi/startapp?saId=$_alipaySaIdQr"
          "&qrcode=${Uri.encodeComponent(s)}";
    }
    return s;
  }

  static bool isBalance(String payType) =>
      payType.trim().toLowerCase() == "balance";

  static String friendlyError(Object e) {
    final t = MclashI18n.t.payment;
    final text = e.toString();
    // 下面这些中文是**服务端返回里用来判定错误类型的匹配串**，不是上屏文案，不要翻译。
    if (text.contains("CSRF") || text.contains("40300")) {
      return t.errCsrf;
    }
    if (text.contains("BEYOND_PER_RECEIPT") ||
        text.contains("单笔收款") ||
        text.contains("限额")) {
      return t.errAlipayLimit;
    }
    if (text.contains("insufficient-isv-permissions") || text.contains("未签约")) {
      return t.errNotSigned;
    }
    if (text.contains("订单不存在") || text.contains("状态不正确")) {
      return t.errOrderGone;
    }
    if (text.contains("网络") || text.contains("Socket") || text.contains("超时")) {
      return t.errNetwork(err: text);
    }
    return text;
  }

  static String payTypeOf(Map<String, dynamic> method) =>
      (method["key"] ?? method["pay_type"] ?? "").toString();

  /// 通道 key → 展示名；未知通道返回 null（由调用方回退到 key 本身）。
  static String? _friendlyName(String key) {
    final t = MclashI18n.t.payment;
    switch (key.toLowerCase()) {
      case "balance":
        return t.balancePay;
      case "alipay":
        return t.channelAlipay;
      case "codepay_alipay":
        return t.channelCodepayAlipay;
      case "codepay_wechat":
        return t.channelCodepayWechat;
      case "codepay":
        return t.channelCodepay;
      case "wechat":
      case "wxpay":
        return t.channelWechat;
      case "usdt":
        return t.channelUsdt;
      case "usdt_trc20":
        return t.channelUsdtTrc20;
      default:
        return null;
    }
  }

  static String nameOf(Map<String, dynamic> method) {
    final name = (method["name"] ?? "").toString().trim();
    if (name.isNotEmpty) {
      return name;
    }
    final key = payTypeOf(method);
    if (key.isEmpty) {
      return MclashI18n.t.payment.payFallback;
    }
    return _friendlyName(key) ?? key;
  }

  static String payloadOf(Map<String, dynamic>? r) {
    if (r == null) {
      return "";
    }
    for (final k in [
      "payment_qr_code",
      "qr_code",
      "payment_url",
      "pay_url",
      "url",
      "code_url",
    ]) {
      final v = r[k]?.toString() ?? "";
      if (v.trim().isNotEmpty) {
        return v.trim();
      }
    }
    return "";
  }
}
