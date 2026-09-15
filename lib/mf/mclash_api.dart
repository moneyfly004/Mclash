/// Mclash 业务 API —— 自有后台 CBoard 的类型化门面。
///
/// 直连 `https://new.moneyfly.top/api/v1`。
///
/// ## 为什么不再走 board_service
///
/// 本文件此前复用 `board_service` 的 `BoardApiClient`，理由是「登录态只有一份，
/// 避免两套 token 不同步」。理由本身没错，但**协议搞错了**：
/// board_service 实现的是 V2Board / XBoard / SSPanel-UIM 三种「面板协议」，
/// 而实测确认 new.moneyfly.top 跑的是自研 Go 后端 CBoard —— 两者在登录路径、
/// 凭据载体、响应包络上全都不同（详见 `cboard_client.dart` 顶部对照表）。
/// 后果不是「报错难看」，而是**核心需求直接不可用**：登录拿不到 token、
/// 订阅地址取不回来，于是「自动拉取用户订阅」这条主线整体失效。
///
/// 所以这里改为：**CBoard 客户端是唯一凭据持有者**（`CBoardClient`），
/// 本文件只是它的静态门面，供 UI 层像以前一样调用。
/// 保持了原来的方法名与签名，调用方无需改动。
///
/// 原有的 `BoardSessionPersistentManager` 仍然存在，用于兼容 Clash Mi 遗留的
/// 多面板导入/切换功能（那些入口现在收在「开发者选项」里）；
/// Mclash 自己的登录/订阅不再经过它。
library;

import 'package:mclash/app/utils/log.dart';
import 'package:mclash/mf/cboard_client.dart';

export 'package:mclash/mf/cboard_client.dart'
    show CBoardClient, CBoardException, CBoardSession, CBoardResponse;

class MclashApi {
  MclashApi._();

  static CBoardClient _client = CBoardClient();
  static bool _restored = false;

  /// 底层客户端（需要用到本门面未封装的方法时用）。
  static CBoardClient get client => _client;

  /// 进程启动时恢复登录态。幂等。
  static Future<bool> restore() async {
    if (_restored) {
      return isLoggedIn;
    }
    _restored = true;
    final ok = await _client.restore();
    Log.i("MclashApi.restore -> ${ok ? "已登录" : "未登录"}");
    return ok;
  }

  /// 登录并持久化会话。
  static Future<void> login(String email, String password) async {
    _restored = true;
    await _client.login(email, password);
  }

  static bool get isLoggedIn => _client.isLoggedIn;

  /// 登录账号（邮箱）。
  static String get account {
    final s = _client.session;
    if (s == null) {
      return "";
    }
    final e = s.email;
    return e.isNotEmpty ? e : s.nickname;
  }

  /// 昵称；为空时回退到邮箱。
  static String get nickname {
    final n = _client.session?.nickname ?? "";
    return n.isNotEmpty ? n : account;
  }

  static Map<String, dynamic> get user => _client.user;

  /// 站点显示名。
  ///
  /// 改造前这里是「面板类型名」（XBoard / V2Board / SSPanel-UIM）。CBoard 是
  /// 单一自研后台，没有多面板概念，所以改为后端 `/config` 下发的 site_name。
  /// 尚未取到时返回空串，UI 会回退到自己的文案（改造前的行为即如此）。
  static String get providerName => _siteName;
  static String _siteName = "";

  // ---------------------------------------------------------------------
  // 通用请求（保留原签名：旧的 path 字符串调用方不必改）
  // ---------------------------------------------------------------------
  static Future<Map<String, dynamic>?> get(String path) async {
    if (!isLoggedIn) {
      return null;
    }
    try {
      final d = await _client.get(_norm(path));
      return d is Map ? Map<String, dynamic>.from(d) : null;
    } on CBoardException catch (e) {
      Log.w("MclashApi.get $path failed: $e");
      throw MclashApiError(e.message, e.httpStatus, e.code);
    }
  }

  static Future<Map<String, dynamic>?> post(
    String path, [
    Map<String, dynamic>? body,
  ]) async {
    if (!isLoggedIn) {
      return null;
    }
    try {
      final d = await _client.post(_norm(path), body: body);
      return d is Map ? Map<String, dynamic>.from(d) : null;
    } on CBoardException catch (e) {
      Log.w("MclashApi.post $path failed: $e");
      throw MclashApiError(e.message, e.httpStatus, e.code);
    }
  }

  /// 历史调用方把 query 直接拼在 path 上（`"/orders?page=1"`），
  /// 这里原样透传：CBoardClient 用 Uri.parse 处理，拼好的 query 会被保留。
  static String _norm(String path) {
    if (path.isEmpty) {
      return "/";
    }
    return path.startsWith("/") ? path : "/$path";
  }

  // ---------------------------------------------------------------------
  // 站点 / 订阅
  // ---------------------------------------------------------------------

  /// 站点公开配置：站点名、图标、客服、注册策略、自定义套餐价格。
  /// 不要求登录 —— 登录页也要用它来显示站点名。
  static Future<Map<String, dynamic>> siteConfig() async {
    try {
      final c = await _client.siteConfig();
      final n = (c["site_name"] ?? "").toString();
      if (n.isNotEmpty) {
        _siteName = n;
      }
      return c;
    } on CBoardException catch (e) {
      Log.w("MclashApi.siteConfig failed: $e");
      return const {};
    }
  }

  /// 我的订阅元信息：到期时间 / 剩余天数 / 设备数 / 是否有效 / 套餐名。
  static Future<Map<String, dynamic>?> subscription() async {
    if (!isLoggedIn) {
      return null;
    }
    try {
      return await _client.userSubscription();
    } on CBoardException catch (e) {
      // 无订阅时后端返回 40400「暂无订阅」——这是正常业务态，不是错误，
      // 交给上层渲染「未订阅」引导，不要抛。
      if (e.code == 40400 || e.httpStatus == 404) {
        return null;
      }
      throw MclashApiError(e.message, e.httpStatus, e.code);
    }
  }

  /// mihomo 可直接拉取的 Clash 订阅地址。未订阅返回 null。
  static Future<String?> clashSubscribeUrl() async {
    final sub = await subscription();
    if (sub == null) {
      return null;
    }
    return CBoardClient.clashSubscribeUrl(sub);
  }

  /// 可空：未登录或后端异常时返回 null，**不抛**。
  /// 契约与改造前一致 —— 首页/我的页多处 `.catchError((e) => null)` 依赖这一点。
  static Future<Map<String, dynamic>?> dashboard() async {
    if (!isLoggedIn) {
      return null;
    }
    try {
      return await _client.dashboard();
    } on CBoardException catch (e) {
      Log.w("MclashApi.dashboard failed: $e");
      return null;
    }
  }

  static Future<Map<String, dynamic>?> me() async {
    if (!isLoggedIn) {
      return null;
    }
    try {
      return await _client.me();
    } on CBoardException catch (e) {
      Log.w("MclashApi.me failed: $e");
      return null;
    }
  }

  // ---------------------------------------------------------------------
  // 套餐 / 订单 / 支付
  // ---------------------------------------------------------------------

  /// 套餐列表。公开接口，登录前也能取（用于展示价格）。
  static Future<List<Map<String, dynamic>>> packages() => _client.packages();

  /// 支付方式列表。契约与改造前一致：直接返回 List。
  static Future<List<Map<String, dynamic>>> paymentMethods() async {
    try {
      return await _client.paymentMethods();
    } on CBoardException catch (e) {
      Log.w("MclashApi.paymentMethods failed: $e");
      return const [];
    }
  }

  /// 原始包络 `{balance_enabled, methods:[...]}` —— 余额支付开关在这里。
  static Future<Map<String, dynamic>> paymentMethodsRaw() async {
    try {
      final d = await _client.get("/payment/methods");
      return d is Map ? Map<String, dynamic>.from(d) : const {};
    } on CBoardException catch (e) {
      Log.w("MclashApi.paymentMethodsRaw failed: $e");
      return const {};
    }
  }

  /// 余额支付是否可用。
  static Future<bool> balanceEnabled() async =>
      (await paymentMethodsRaw())["balance_enabled"] == true;

  static Future<Map<String, dynamic>?> createOrder(
    int packageId, {
    String couponCode = "",
  }) async {
    if (!isLoggedIn) {
      return null;
    }
    return _client.createOrder(packageId: packageId, couponCode: couponCode);
  }

  /// 自定义套餐下单（后端 config 里 custom_package_enabled = true 时可用）。
  static Future<Map<String, dynamic>?> createCustomOrder({
    required int devices,
    required int months,
    String couponCode = "",
  }) async {
    if (!isLoggedIn) {
      return null;
    }
    return _client.createCustomOrder(
      devices: devices,
      months: months,
      couponCode: couponCode,
    );
  }

  /// 发起支付。[paymentMethod] 是通道字符串（`pay_type`），或 `"balance"`。
  static Future<Map<String, dynamic>?> payOrder(
    String orderNo,
    String paymentMethod,
  ) async {
    if (!isLoggedIn) {
      return null;
    }
    return _client.payOrder(orderNo, paymentMethod: paymentMethod);
  }

  /// `pay_type` → 中文名。
  ///
  /// 后端 `/payment/methods` 只回 `{id, pay_type, sort_order}`，**没有 name**。
  /// 早期实现直接取 `m["name"]`，结果渲染出一列空白行 —— 界面看着「有东西但没字」，
  /// 所以显示名必须在客户端兜。未知通道回退到原始 pay_type，宁可显示英文也不空白。
  static String paymentMethodLabel(String payType) {
    switch (payType) {
      case "balance":
        return "余额支付";
      case "alipay":
        return "支付宝";
      case "wxpay":
      case "wechat":
        return "微信支付";
      case "codepay_alipay":
        return "码支付 · 支付宝";
      case "codepay_wxpay":
        return "码支付 · 微信";
      case "epay_alipay":
        return "易支付 · 支付宝";
      case "epay_wxpay":
        return "易支付 · 微信";
      case "stripe":
        return "Stripe";
      case "paypal":
        return "PayPal";
      case "usdt":
      case "crypto":
        return "USDT";
      default:
        return payType.isEmpty ? "在线支付" : payType;
    }
  }

  /// 可用的支付通道：`[{id, pay_type, label}]`。
  /// `balance_enabled` 为真时在最前面插入余额支付（后端用 payment_method
  /// = "balance" 特殊处理，不是 /payment/methods 里的一项）。
  static Future<List<Map<String, dynamic>>> availablePaymentMethods() async {
    final raw = await paymentMethodsRaw();
    final out = <Map<String, dynamic>>[];
    if (raw["balance_enabled"] == true) {
      out.add({"id": -1, "pay_type": "balance", "label": "余额支付"});
    }
    final list = raw["methods"];
    if (list is List) {
      for (final e in list) {
        if (e is! Map) {
          continue;
        }
        final m = Map<String, dynamic>.from(e);
        final pt = (m["pay_type"] ?? "").toString();
        if (pt.isEmpty) {
          continue;
        }
        m["label"] = paymentMethodLabel(pt);
        out.add(m);
      }
    }
    return out;
  }

  static Future<Map<String, dynamic>?> orderStatus(String orderNo) async {
    if (!isLoggedIn) {
      return null;
    }
    return _client.orderStatus(orderNo);
  }

  static Future<Map<String, dynamic>?> cancelOrder(String orderNo) async {
    if (!isLoggedIn) {
      return null;
    }
    await _client.cancelOrder(orderNo);
    return const {};
  }

  static Future<List<Map<String, dynamic>>> orders({
    int page = 1,
    int pageSize = 20,
  }) =>
      isLoggedIn
          ? _client.orders(page: page, pageSize: pageSize)
          : Future<List<Map<String, dynamic>>>.value(const []);

  static Future<Map<String, dynamic>> verifyCoupon(
    String code, {
    int? packageId,
  }) =>
      isLoggedIn
          ? _client.verifyCoupon(code, packageId: packageId)
          : Future<Map<String, dynamic>>.value(const {});

  // ---------------------------------------------------------------------
  // 设备 / 通知
  // ---------------------------------------------------------------------

  static Future<List<Map<String, dynamic>>> subscriptionDevices() =>
      isLoggedIn
          ? _client.devices()
          : Future<List<Map<String, dynamic>>>.value(const []);

  static Future<void> deleteDevice(int id) async {
    if (!isLoggedIn) {
      return;
    }
    await _client.deleteDevice(id);
  }

  static Future<int> unreadNoticeCount() =>
      isLoggedIn ? _client.unreadNoticeCount() : Future<int>.value(0);

  static Future<List<Map<String, dynamic>>> notifications() =>
      isLoggedIn
          ? _client.notifications()
          : Future<List<Map<String, dynamic>>>.value(const []);

  static Future<void> markNoticeRead(int id) async {
    if (!isLoggedIn) {
      return;
    }
    await _client.markNoticeRead(id);
  }

  static Future<List<Map<String, dynamic>>> announcements() =>
      _client.announcements();

  /// 公告 + 站内通知合并成 Notifications 页要的一份列表。
  static Future<List<Map<String, dynamic>>> allNotices() async {
    final out = <Map<String, dynamic>>[];
    try {
      for (final a in await announcements()) {
        out.add({...a, "_kind": "announcement"});
      }
    } catch (e) {
      Log.w("MclashApi.allNotices announcements failed: $e");
    }
    try {
      for (final n in await notifications()) {
        out.add({...n, "_kind": "notification"});
      }
    } catch (e) {
      Log.w("MclashApi.allNotices notifications failed: $e");
    }
    return out;
  }

  // ---------------------------------------------------------------------
  // 账户
  // ---------------------------------------------------------------------

  static Future<void> changePassword(String oldPassword, String newPassword) =>
      _client.changePassword(oldPassword, newPassword);

  static Future<Map<String, dynamic>> softwareVersions() =>
      _client.softwareVersions();

  static Future<void> logout() async {
    await _client.logout();
  }

  /// 测试用：替换底层客户端。
  static void debugUse(CBoardClient c) {
    _client = c;
    _restored = true;
  }
}

class MclashApiError implements Exception {
  MclashApiError(this.message, this.statusCode, [this.code = -1]);

  final String message;
  final int statusCode;

  /// CBoard 业务码（40000 参数错 / 40100 未登录 / 40300 CSRF / 40400 不存在 /
  /// 40900 冲突）。UI 用它分流，例如 40100 直接踢回登录页。
  final int code;

  bool get isUnauthorized => code == 40100 || statusCode == 401;

  @override
  String toString() => message;
}
