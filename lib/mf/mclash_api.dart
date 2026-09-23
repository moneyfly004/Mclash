
library;

import 'package:mclash/app/utils/log.dart';
import 'package:mclash/mf/cboard_client.dart';
import 'package:mclash/mf/mclash_domains.dart';

export 'package:mclash/mf/cboard_client.dart'
    show CBoardClient, CBoardException, CBoardSession, CBoardResponse;
export 'package:mclash/mf/mclash_domains.dart' show MclashDomainPool;

class MclashApi {
  MclashApi._();

  static const String _baseUrlOverride =
      String.fromEnvironment("MCLASH_API_BASE", defaultValue: "");

  static CBoardClient _client = CBoardClient(
    baseUrl: _baseUrlOverride.isEmpty ? null : _baseUrlOverride,
  );
  static bool _restored = false;

  static CBoardClient get client => _client;

  /// 当前正在使用的 API 域名（UI/日志用）。
  ///
  /// 为什么会变：某个域名连不上时 [CBoardClient] 会自动轮换到另一个域名，
  /// 这里跟着反映最新结果，方便用户看出「现在走的是哪个域名」。
  static String get currentApiHost => _client.currentHost;

  /// 当前 base URL（形如 `https://new.moneyfly.top/api/v1`）。
  static String get currentApiBaseUrl => _client.baseUrl;

  static Future<bool>? _restoreInflight;

  static Future<bool> restore() {
    if (_restored) {
      return Future.value(isLoggedIn);
    }
    return _restoreInflight ??=
        _doRestore().whenComplete(() => _restoreInflight = null);
  }

  static Future<bool> _doRestore() async {
    final ok = await _client.restore();

    _restored = true;
    Log.i("MclashApi.restore -> ${ok ? "已登录" : "未登录"}");
    return ok;
  }

  static Future<void> login(String email, String password) async {
    _restored = true;
    await _client.login(email, password);
  }

  static bool get isLoggedIn => _client.isLoggedIn;

  static String get account {
    final s = _client.session;
    if (s == null) {
      return "";
    }
    final e = s.email;
    return e.isNotEmpty ? e : s.nickname;
  }

  static String get nickname {
    final n = _client.session?.nickname ?? "";
    return n.isNotEmpty ? n : account;
  }

  static Map<String, dynamic> get user => _client.user;

  static String get providerName => _siteName;
  static String _siteName = "";

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

  static String _norm(String path) {
    if (path.isEmpty) {
      return "/";
    }
    return path.startsWith("/") ? path : "/$path";
  }

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

  static Future<Map<String, dynamic>?> subscription() async {
    if (!isLoggedIn) {
      return null;
    }
    try {
      return await _client.userSubscription();
    } on CBoardException catch (e) {

      if (e.code == 40400 || e.httpStatus == 404) {
        return null;
      }
      throw MclashApiError(e.message, e.httpStatus, e.code);
    }
  }

  static Future<String?> clashSubscribeUrl() async {
    final sub = await subscription();
    if (sub == null) {
      return null;
    }
    return CBoardClient.clashSubscribeUrl(sub);
  }

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

  static Future<List<Map<String, dynamic>>> packages() => _client.packages();

  static Future<List<Map<String, dynamic>>> paymentMethods() async {
    try {
      return await _client.paymentMethods();
    } on CBoardException catch (e) {
      Log.w("MclashApi.paymentMethods failed: $e");
      return const [];
    }
  }

  static Future<bool> paymentBalanceEnabled() async {
    try {
      final raw = await paymentMethodsRaw();
      final v = raw["balance_enabled"] ?? raw["balanceEnabled"];
      return v is bool ? v : true;
    } catch (_) {
      return true;
    }
  }

  static Future<Map<String, dynamic>> paymentMethodsRaw() async {
    try {
      final d = await _client.get("/payment/methods");
      return d is Map ? Map<String, dynamic>.from(d) : const {};
    } on CBoardException catch (e) {
      Log.w("MclashApi.paymentMethodsRaw failed: $e");
      return const {};
    }
  }

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

  static Future<Map<String, dynamic>?> payOrder(String orderNo) async {
    if (!isLoggedIn) {
      return null;
    }
    return _client.payWithBalance(orderNo);
  }

  static Future<Map<String, dynamic>?> createPayment({
    required int orderId,
    required int paymentMethodId,
    bool isMobile = false,
  }) async {
    if (!isLoggedIn) {
      return null;
    }
    return _client.createPayment(
      orderId: orderId,
      paymentMethodId: paymentMethodId,
      isMobile: isMobile,
    );
  }

  static Future<Map<String, dynamic>?> paymentStatus(int paymentId) async {
    if (!isLoggedIn) {
      return null;
    }
    return _client.paymentStatus(paymentId);
  }

  static bool isPaymentDone(Map<String, dynamic>? s) {
    if (s == null) {
      return false;
    }
    final v = (s['status'] ?? s['pay_status'] ?? '').toString().toLowerCase();
    return v == 'paid' || v == 'success' || v == 'completed' || v == '已完成';
  }

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

  static Future<Map<String, dynamic>> previewDeviceUpgrade({
    required int addDevices,
    int addDays = 0,
  }) => isLoggedIn
      ? _client.previewDeviceUpgrade(addDevices: addDevices, addDays: addDays)
      : Future<Map<String, dynamic>>.value(const {});

  static Future<Map<String, dynamic>> createDeviceUpgradeOrder({
    required int addDevices,
    int addDays = 0,
    String? paymentMethod,
  }) => isLoggedIn
      ? _client.createDeviceUpgradeOrder(
          addDevices: addDevices,
          addDays: addDays,
          paymentMethod: paymentMethod,
        )
      : Future<Map<String, dynamic>>.value(const {});

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

  static Future<List<Map<String, dynamic>>> announcements() =>
      _client.announcements();

  static Future<void> changePassword(String oldPassword, String newPassword) =>
      _client.changePassword(oldPassword, newPassword);

  static Future<Map<String, dynamic>> softwareVersions() =>
      _client.softwareVersions();

  static Future<void> logout() async {
    await _client.logout();
  }

  static bool registerEnabledFrom(Map<String, dynamic> cfg) =>
      cfg["register_enabled"] == true || cfg["register_enabled"] == "true";

  static bool registerEmailVerifyFrom(Map<String, dynamic> cfg) =>
      cfg["register_email_verify"] == true ||
      cfg["register_email_verify"] == "true";

  static bool registerInviteRequiredFrom(Map<String, dynamic> cfg) =>
      cfg["register_invite_required"] == true ||
      cfg["register_invite_required"] == "true";

  static Future<void> sendVerificationCode(
    String email, {
    String purpose = "register",
  }) =>
      _client.sendVerificationCode(email, purpose: purpose);

  static Future<void> verifyCode(String email, String code) =>
      _client.verifyCode(email, code);

  static Future<void> register({
    required String username,
    required String email,
    required String password,
    String verificationCode = "",
    String inviteCode = "",
  }) async {
    _restored = true;
    await _client.register(
      username: username,
      email: email,
      password: password,
      verificationCode: verificationCode,
      inviteCode: inviteCode,
    );
  }

  static Future<void> forgotPassword(String email) =>
      _client.forgotPassword(email);

  static Future<void> resetPassword({
    required String email,
    required String code,
    required String password,
  }) =>
      _client.resetPassword(email: email, code: code, password: password);

  static const int passwordMinLen = 6;

  static void debugUse(CBoardClient c) {
    _client = c;
    _restored = true;
  }
}

class MclashApiError implements Exception {
  MclashApiError(this.message, this.statusCode, [this.code = -1]);

  final String message;
  final int statusCode;

  final int code;

  bool get isUnauthorized => code == 40100 || statusCode == 401;

  @override
  String toString() => message;
}
