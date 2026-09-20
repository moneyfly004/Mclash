library;

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
    final text = e.toString();
    if (text.contains("CSRF") || text.contains("40300")) {
      return "登录凭证已过期（CSRF 校验失败）。\n请到「我的」下拉刷新或重新登录后重试。";
    }
    if (text.contains("BEYOND_PER_RECEIPT") ||
        text.contains("单笔收款") ||
        text.contains("限额")) {
      return "支付宝当面付单笔限额（本商户 ¥1000），本单金额超出。\n"
          "请改用「余额支付」或「码支付」，或联系客服提高支付宝限额。";
    }
    if (text.contains("insufficient-isv-permissions") || text.contains("未签约")) {
      return "支付宝应用未签约对应的支付产品，暂时无法用这个通道。\n"
          "请改用「余额支付」或「码支付」，或联系客服开通。";
    }
    if (text.contains("订单不存在") || text.contains("状态不正确")) {
      return "这笔订单已被取消或已过期（草稿订单 30 分钟有效期）。\n"
          "请点「重新算价」生成新订单再支付。";
    }
    if (text.contains("网络") || text.contains("Socket") || text.contains("超时")) {
      return "网络不通：$text";
    }
    return text;
  }

  static String payTypeOf(Map<String, dynamic> method) =>
      (method["key"] ?? method["pay_type"] ?? "").toString();

  static const Map<String, String> _friendlyNames = {
    "balance": "余额支付",
    "alipay": "支付宝",
    "codepay_alipay": "码支付 · 支付宝",
    "codepay_wechat": "码支付 · 微信",
    "codepay": "码支付",
    "wechat": "微信支付",
    "wxpay": "微信支付",
    "usdt": "USDT",
    "usdt_trc20": "USDT · TRC20",
  };

  static String nameOf(Map<String, dynamic> method) {
    final name = (method["name"] ?? "").toString().trim();
    if (name.isNotEmpty) {
      return name;
    }
    final key = payTypeOf(method);
    if (key.isEmpty) {
      return "支付";
    }
    return _friendlyNames[key.toLowerCase()] ?? key;
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
