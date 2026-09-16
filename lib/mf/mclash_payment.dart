library;

/// 支付载荷分类：决定「弹二维码」还是「打开浏览器」还是「唤起支付 App」。
///
/// 背景（用户反馈）：设备管理里点了支付**直接扣余额**，用户没法选支付方式；
/// 而且不同通道的正确交互是不一样的 —— 支付宝二维码要弹码、码支付要跳浏览器、
/// 安卓上支付宝要能唤起 App。
///
/// 这里把「后端返回的支付载荷」分类成明确的通道，界面据此决定动作。
/// 参考实现：`/Users/apple/Downloads/mysoftware/moneyfly` 的支付弹窗
/// （`qr.alipay.com` 会包成 `alipays://platformapi/startapp?saId=10000007&qrcode=`，
///  微信 NATIVE / USDT 只扫码不跳转，http(s) 走外部浏览器）。
enum MclashPayChannel {
  /// 余额支付（面板里直接扣款）
  balance,

  /// 支付宝二维码：弹二维码；手机端可再唤起支付宝 App
  alipayQr,

  /// 已是可以直接唤起的支付宝深链
  alipayApp,

  /// 微信 NATIVE：只能扫码（微信不允许外部 App 直接唤起收款）
  wechatQr,

  /// 加密货币地址码：只能扫码/复制
  crypto,

  /// 收银台网页（码支付/易支付）：**打开浏览器**支付
  cashierUrl,

  /// 其它：当二维码内容展示
  qr,
}

abstract final class MclashPay {
  static const String _alipaySaIdQr = "10000007";

  /// 分类支付载荷。
  ///
  /// * [payType] 是支付通道的 key（如 `balance`/`alipay`/`codepay_alipay`）；
  /// * [mode] 是后端 `payment_mode`（实测码支付会返回）：`qrcode` = 给了二维码内容、
  ///   `page`/`redirect` = 给的是收银台网页。**有 mode 时以 mode 为准** —— 光看链接
  ///   形态猜不准：`https://pay.xxx/submit.php?...`（收银台）和
  ///   `https://qr.alipay.com/xxx`（二维码）都是 http 链接，动作却完全相反。
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
      // 后端明确说这是收银台网页（码支付/易支付）→ 打开浏览器
      return MclashPayChannel.cashierUrl;
    }
    final qrOnly = m == "qrcode";
    // 后端实测通道：alipay（支付宝当面付二维码）/ codepay_alipay（码支付）。
    // 码支付是收银台网页，**一律打开浏览器**（用户明确要求），
    // 即使它偶尔返回了 qr.alipay.com 链接也按码支付处理；除非后端明确给了
    // `payment_mode=qrcode`（那时它真的给了二维码内容，要在软件内出码）。
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
      // 后端说这是二维码内容（码支付的 mapi 常见形态就是一条支付链接）→ 出码；
      // 否则是收银台/码支付网页 → 打开浏览器。
      return qrOnly ? MclashPayChannel.qr : MclashPayChannel.cashierUrl;
    }
    return MclashPayChannel.qr;
  }

  /// 是否需要**自动打开浏览器**（码支付收银台）。
  static bool shouldOpenInBrowser(MclashPayChannel c) =>
      c == MclashPayChannel.cashierUrl;

  /// 手机端是否提供「唤起支付 App」按钮（微信/USDT 无法唤起，不给按钮免得误导）。
  static bool canLaunchApp(MclashPayChannel c, {required bool isMobile}) =>
      isMobile &&
      (c == MclashPayChannel.alipayQr ||
          c == MclashPayChannel.alipayApp ||
          c == MclashPayChannel.cashierUrl);

  /// 手机端把支付宝二维码内容转成可直接唤起支付宝的深链。
  ///
  /// 支付宝当面付二维码是一个 `https://qr.alipay.com/xxx` 链接，
  /// 直接 `launchUrl` 只会开浏览器；包成 `alipays://...startapp?saId=10000007&qrcode=`
  /// 才会拉起支付宝 App 的付款页（与支付宝官方/网页端做法一致）。
  static String appLaunchTarget(String payload, MclashPayChannel c) {
    final s = payload.trim();
    if (c == MclashPayChannel.alipayQr ||
        s.toLowerCase().contains("qr.alipay.com")) {
      return "alipays://platformapi/startapp?saId=$_alipaySaIdQr"
          "&qrcode=${Uri.encodeComponent(s)}";
    }
    return s;
  }

  /// 支付方式列表里，哪些是「余额」。
  static bool isBalance(String payType) =>
      payType.trim().toLowerCase() == "balance";

  /// 把后端/网络抛出的技术错误翻译成用户能懂的一句话。
  ///
  /// 三个页面（套餐购买、订单续付、设备升级）共用，避免各写一份、口径还不同。
  static String friendlyError(Object e) {
    final text = e.toString();
    if (text.contains("CSRF") || text.contains("40300")) {
      return "登录凭证已过期（CSRF 校验失败）。\n请到「我的」下拉刷新或重新登录后重试。";
    }
    // 支付宝当面付有**单笔收款限额**（本商户实测 ¥1000）：超了支付宝直接拒绝，
    // 不是网络问题，也不该把用户丢到一个必然报错的网页上。
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

  /// 从后端支付方式条目里取通道 key（实测字段是 `key`，兼容历史的 `pay_type`）。
  static String payTypeOf(Map<String, dynamic> method) =>
      (method["key"] ?? method["pay_type"] ?? "").toString();

  /// 通道 key → 界面展示名。
  ///
  /// 后端 `/payment/methods` 实测只返回 `pay_type`（如 `alipay` / `codepay_alipay`），
  /// **没有 name 字段** —— 直接把 key 摊给用户（"codepay_alipay"）很难看懂，
  /// 所以这里给已知通道配中文名，未知通道回退到 key。
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

  /// 从后端支付方式条目里取展示名。
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

  /// 从「发起支付」的响应里取出真正的支付载荷（不同通道字段名不一致）。
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
