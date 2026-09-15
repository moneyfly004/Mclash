//
//  CBoard 客户端 —— Mclash 唯一认可的业务后台协议实现。
//
//  为什么是「唯一」：Mclash 最初照搬 Clash Mi 的客户端分层，实现了 V2Board /
//  XBoard / SSPanel-UIM 三套「面板协议」。但实测确认，new.moneyfly.top 跑的
//  既不是 V2Board 也不是 XBoard，而是自研的 Go 后端 CBoard：
//
//      V2Board / XBoard（旧实现，错）        CBoard（本文件，对）
//      --------------------------------      --------------------------------
//      POST /passport/auth/login             POST /auth/login
//      data.auth_data.token                  data.access_token + refresh_token
//      Cookie 会话（PHPSESSID / laravel_*）   Authorization: Bearer <token>
//      响应 {status, data, message}          响应 {code, message, data}
//      status == "success" 判成功            code == 0 判成功
//      无 CSRF                               写操作必须带 X-CSRF-Token
//      GET /user/subscribe                   GET /subscriptions/user-subscription
//      GET /user/info                        GET /users/me
//      POST /user/order/save                 POST /orders
//      POST /user/order/checkout             POST /orders/:orderNo/pay
//
//  权威依据：后端仓库 /Users/apple/v2 的 API.md 与
//  internal/api/router/router.go（本文档注释均逐条核对过路由）。
//
//  两处最容易踩、且文档一句话带过、但实现上必须当真的约定：
//
//  1) CSRF Token 是**一次性**的，且每次校验成功后后端立即轮换。
//     所以「启动时取一次存起来反复用」必然在第二次写操作就 40300。
//     本实现的处理是：每次写操作前现取（GET /csrf-token），
//     并在收到 40300 时重取一次 + 重试一次（覆盖「取到即被并发消费」的窗口）。
//
//  2) 订阅下发地址不在「订阅信息」里，而是从订阅信息里的
//     token_clash_url 直接拿。它就是 mihomo 能直接吃的 Clash 配置地址，
//     形如 https://<host>/api/v1/client/subscribe?token=<sub_token>&format=clash
//     拉取它会返回 text/yaml，并带 Subscription-Title / Profile-Title 头
//     （订阅名中文化、流量信息都靠这两个头，不要自己拼标题）。
//

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:mclash/app/utils/secure_storage.dart';

/// 统一的 CBoard 响应包装。
class CBoardResponse<T> {
  CBoardResponse({
    required this.code,
    required this.message,
    required this.data,
    required this.httpStatus,
  });

  /// 业务码。0 = 成功。
  final int code;
  final String message;
  final T? data;
  final int httpStatus;

  bool get ok => code == 0;

  /// 需要重新登录（Token 失效）。
  bool get isUnauthorized => code == 40100 || httpStatus == 401;

  /// CSRF 校验失败。
  bool get isCsrfFailure => code == 40300;

  /// 订阅过期 / 无订阅（后端在业务码里用 40400/40900 表达，语义由调用方决定）。
  bool get isNotFound => code == 40400 || httpStatus == 404;

  @override
  String toString() => 'CBoardResponse(code: $code, message: $message)';
}

/// 业务异常。带上 [code] 便于 UI 分流（例如 40100 直接踢回登录页）。
class CBoardException implements Exception {
  CBoardException(this.message, {this.code = -1, this.httpStatus = 0});

  final String message;
  final int code;
  final int httpStatus;

  bool get isUnauthorized => code == 40100 || httpStatus == 401;

  @override
  String toString() => message;
}

/// 登录态。持久化在安全存储里（access/refresh 是凭据，不进 SharedPreferences）。
class CBoardSession {
  CBoardSession({
    required this.accessToken,
    required this.refreshToken,
    this.user = const {},
  });

  final String accessToken;
  final String refreshToken;
  final Map<String, dynamic> user;

  String get email => (user['email'] ?? '').toString();
  String get nickname =>
      (user['nickname'] ?? user['name'] ?? user['email'] ?? '').toString();

  CBoardSession copyWith({
    String? accessToken,
    String? refreshToken,
    Map<String, dynamic>? user,
  }) =>
      CBoardSession(
        accessToken: accessToken ?? this.accessToken,
        refreshToken: refreshToken ?? this.refreshToken,
        user: user ?? this.user,
      );

  Map<String, dynamic> toJson() => {
        'access_token': accessToken,
        'refresh_token': refreshToken,
        'user': user,
      };

  static CBoardSession? fromJson(dynamic v) {
    if (v is! Map) return null;
    final a = (v['access_token'] ?? '').toString();
    final r = (v['refresh_token'] ?? '').toString();
    if (a.isEmpty) return null;
    final u = v['user'];
    return CBoardSession(
      accessToken: a,
      refreshToken: r,
      user: u is Map ? Map<String, dynamic>.from(u) : const {},
    );
  }
}

/// 会话持久化。key 加版本前缀，将来换协议不会读到旧结构。
class CBoardSessionStore {
  static const _key = 'mclash.cboard.session.v1';

  static CBoardSession? _cached;

  static CBoardSession? get cached => _cached;

  static Future<CBoardSession?> load() async {
    if (_cached != null) return _cached;
    try {
      final raw = await SecureStorage.read(_key);
      if (raw == null || raw.isEmpty) return null;
      _cached = CBoardSession.fromJson(jsonDecode(raw));
      return _cached;
    } catch (e) {
      debugPrint('CBoardSessionStore.load failed: $e');
      return null;
    }
  }

  static Future<void> save(CBoardSession? s) async {
    _cached = s;
    try {
      if (s == null) {
        await SecureStorage.write(_key, '');
      } else {
        await SecureStorage.write(_key, jsonEncode(s.toJson()));
      }
    } catch (e) {
      // 写安全存储失败**不能**让登录本身失败：本次进程内仍可用（内存缓存已置），
      // 只是重启后需要重新登录。故只记录不抛出。
      debugPrint('CBoardSessionStore.save failed: $e');
    }
  }

  static Future<void> clear() => save(null);
}

/// CBoard 客户端。
///
/// 线程模型：Dart 单线程事件循环，[_refreshing] 用 Future 做单飞（single-flight），
/// 避免多个并发 401 同时触发 N 次 refresh（refresh token 也可能是一次性的，
/// 并发刷新=互相作废，是最难查的一类「随机掉登录」）。
class CBoardClient {
  CBoardClient({String? baseUrl, HttpClient? httpClient})
      : baseUrl = _normalize(baseUrl ?? kCBoardDefaultBaseUrl),
        _http = httpClient ?? HttpClient();

  /// 线上实测确认可用（{code:0,message:"success"}）。
  static const kCBoardDefaultHost = 'new.moneyfly.top';
  static const kCBoardDefaultBaseUrl = 'https://new.moneyfly.top/api/v1';

  final String baseUrl;
  final HttpClient _http;

  CBoardSession? _session;
  Future<bool>? _refreshing;

  CBoardSession? get session => _session ?? CBoardSessionStore.cached;
  bool get isLoggedIn => session != null;
  Map<String, dynamic> get user => session?.user ?? const {};

  static String _normalize(String u) =>
      u.endsWith('/') ? u.substring(0, u.length - 1) : u;

  /// 从已保存的会话恢复。
  Future<bool> restore() async {
    _session = await CBoardSessionStore.load();
    return _session != null;
  }

  Map<String, String> _headers({bool auth = true, String? csrf}) {
    final h = <String, String>{
      'Accept': 'application/json',
      // 后端按 UA 识别客户端类型（ParseUserAgent / ClientInfo.SubscriptionType），
      // 用默认 Dart UA 会被判成 Unknown，可能拿到通用格式而非 Clash 格式。
      'User-Agent': 'Mclash/1.0 (${Platform.operatingSystem})',
    };
    if (auth) {
      final t = session?.accessToken;
      if (t != null && t.isNotEmpty) h['Authorization'] = 'Bearer $t';
    }
    if (csrf != null && csrf.isNotEmpty) h['X-CSRF-Token'] = csrf;
    return h;
  }

  /// 底层请求。`retryAuth` / `retryCsrf` 是内部重试闸，外层不要传。
  Future<CBoardResponse<dynamic>> request(
    String method,
    String path, {
    Object? body,
    Map<String, String>? query,
    bool auth = true,
    bool retryAuth = true,
    bool retryCsrf = true,
  }) async {
    final mutating = method != 'GET' && method != 'HEAD';
    // /auth/* 是公开的，后端明确不校验 CSRF；对它取 CSRF 反而会 401。
    final isAuthPath = path.startsWith('/auth/');

    var uri = Uri.parse('$baseUrl$path');
    if (query != null && query.isNotEmpty) {
      uri = uri.replace(queryParameters: {...uri.queryParameters, ...query});
    }

    String? csrf;
    if (mutating && auth && !isAuthPath) {
      csrf = await _fetchCsrfToken();
    }

    HttpClientResponse resp;
    try {
      final req = await _http.openUrl(method, uri);
      _headers(auth: auth, csrf: csrf).forEach(req.headers.set);
      if (body != null) {
        final bytes = utf8.encode(jsonEncode(body));
        req.headers.contentType = ContentType.json;
        req.headers.contentLength = bytes.length;
        req.add(bytes);
      }
      resp = await req.close();
    } on SocketException catch (e) {
      throw CBoardException('网络不可达：${e.message}');
    } on HandshakeException {
      throw CBoardException('TLS 握手失败，请检查网络或系统时间');
    } catch (e) {
      throw CBoardException('请求失败：$e');
    }

    final text = await resp.transform(utf8.decoder).join();
    final status = resp.statusCode;

    dynamic decoded;
    try {
      decoded = text.isEmpty ? <String, dynamic>{} : jsonDecode(text);
    } catch (_) {
      // 非 JSON：订阅下发接口是 text/yaml，这里的通用请求不该遇到；
      // 碰到就当作协议不符大声报错，而不是静默吞掉。
      throw CBoardException('响应不是 JSON（HTTP $status）：${_snip(text)}',
          httpStatus: status);
    }

    if (decoded is! Map) {
      throw CBoardException('响应结构异常（HTTP $status）', httpStatus: status);
    }

    final map = Map<String, dynamic>.from(decoded);
    final code = (map['code'] is num) ? (map['code'] as num).toInt() : status;
    final message = (map['message'] ?? map['msg'] ?? '').toString();
    final r = CBoardResponse<dynamic>(
      code: code,
      message: message,
      data: map['data'],
      httpStatus: status,
    );

    // ── 40100：Token 失效 → 刷新一次 → 重放一次 ──────────────────────────
    if (r.isUnauthorized && auth && retryAuth && !isAuthPath) {
      final refreshed = await _refreshOnce();
      if (refreshed) {
        return request(method, path,
            body: body,
            query: query,
            auth: auth,
            retryAuth: false,
            retryCsrf: retryCsrf);
      }
    }

    // ── 40300：CSRF 无效/被并发消费 → 重取 → 重放一次 ────────────────────
    if (r.isCsrfFailure && mutating && retryCsrf) {
      return request(method, path,
          body: body, query: query, auth: auth, retryAuth: false, retryCsrf: false);
    }

    return r;
  }

  static String _snip(String s) =>
      s.length <= 120 ? s : '${s.substring(0, 120)}…';

  /// 取一次性 CSRF Token。失败返回 null（后端若是全新站点未启用 CSRF 也能跑）。
  Future<String?> _fetchCsrfToken() async {
    try {
      final r = await request('GET', '/csrf-token',
          auth: true, retryAuth: true, retryCsrf: false);
      final d = r.data;
      if (d is Map) {
        return (d['csrf_token'] ?? d['token'] ?? d['csrfToken'])?.toString();
      }
      if (d is String && d.isNotEmpty) return d;
    } catch (_) {
      // 忽略：写操作若真需要 CSRF，后端会以 40300 告诉我们，届时走重试闸。
    }
    return null;
  }

  /// 刷新 Access Token。单飞（single-flight）：并发调用共享同一个 Future。
  Future<bool> _refreshOnce() =>
      _refreshing ??= _doRefresh().whenComplete(() => _refreshing = null);

  Future<bool> _doRefresh() async {
    final rt = session?.refreshToken;
    if (rt == null || rt.isEmpty) return false;
    try {
      final r = await request('POST', '/auth/refresh',
          body: {'refresh_token': rt}, auth: false, retryAuth: false);
      if (!r.ok) return false;
      final d = r.data;
      if (d is! Map) return false;
      final at = (d['access_token'] ?? '').toString();
      if (at.isEmpty) return false;
      final cur = session;
      final next = (cur ?? CBoardSession(accessToken: at, refreshToken: rt))
          .copyWith(
        accessToken: at,
        refreshToken: (d['refresh_token'] ?? rt).toString(),
      );
      await _setSession(next);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _setSession(CBoardSession? s) async {
    _session = s;
    await CBoardSessionStore.save(s);
  }

  // ───────────────────────────── 认证 ─────────────────────────────

  /// 登录。[email] 必填，密码由调用方校验（后端要求 ≥8 位）。
  Future<CBoardSession> login(String email, String password) async {
    final r = await request('POST', '/auth/login',
        body: {'email': email.trim(), 'password': password},
        auth: false,
        retryAuth: false);
    if (!r.ok) {
      throw CBoardException(
        r.message.isNotEmpty ? r.message : '登录失败（code ${r.code}）',
        code: r.code,
        httpStatus: r.httpStatus,
      );
    }
    final d = r.data;
    if (d is! Map) throw CBoardException('登录响应缺少 data');
    final at = (d['access_token'] ?? '').toString();
    final rt = (d['refresh_token'] ?? '').toString();
    if (at.isEmpty) throw CBoardException('登录响应缺少 access_token');
    final u = d['user'];
    final s = CBoardSession(
      accessToken: at,
      refreshToken: rt,
      user: u is Map ? Map<String, dynamic>.from(u) : const {},
    );
    await _setSession(s);
    return s;
  }

  Future<void> logout() async {
    try {
      await request('POST', '/auth/logout', retryAuth: false);
    } catch (_) {
      // 后端登出失败不影响本地清除：本地清掉就是对用户而言「已登出」。
    }
    await _setSession(null);
  }

  /// 拉最新用户信息并回写会话（用于昵称/套餐变化后刷新 UI）。
  Future<Map<String, dynamic>> me() async {
    final d = await get('/users/me');
    if (d is Map) {
      final s = session;
      if (s != null) await _setSession(s.copyWith(user: Map<String, dynamic>.from(d)));
      return Map<String, dynamic>.from(d);
    }
    return const {};
  }

  // ───────────────────────── 便捷封装 ─────────────────────────

  Future<dynamic> get(String path, {Map<String, String>? query}) =>
      _data(request('GET', path, query: query));

  Future<dynamic> post(String path, {Object? body}) =>
      _data(request('POST', path, body: body));

  Future<dynamic> put(String path, {Object? body}) =>
      _data(request('PUT', path, body: body));

  Future<dynamic> delete(String path, {Object? body}) =>
      _data(request('DELETE', path, body: body));

  /// 与 get/post 不同：返回整个响应（订阅接口需要读 code 之外的东西时用）。
  Future<CBoardResponse<dynamic>> raw(String method, String path,
          {Object? body, bool auth = true}) =>
      request(method, path, body: body, auth: auth);

  Future<dynamic> _data(Future<CBoardResponse<dynamic>> f) async {
    final r = await f;
    if (!r.ok) {
      throw CBoardException(
        r.message.isNotEmpty ? r.message : '请求失败（code ${r.code}）',
        code: r.code,
        httpStatus: r.httpStatus,
      );
    }
    return r.data;
  }

  // ───────────────────────── 业务接口 ─────────────────────────

  /// 站点公开配置（无需登录）。App 的站点名/图标/客服/注册策略/自定义套餐
  /// 价格全部来自这里 —— 不要再在客户端硬编码。
  Future<Map<String, dynamic>> siteConfig() async {
    final d = await get('/config');
    return d is Map ? Map<String, dynamic>.from(d) : const {};
  }

  /// 套餐列表（公开，返回**裸数组**，不是 {items:[]}）。
  Future<List<Map<String, dynamic>>> packages() async {
    final d = await get('/packages');
    return _asList(d);
  }

  Future<Map<String, dynamic>> dashboard() async {
    final d = await get('/users/dashboard-info');
    return d is Map ? Map<String, dynamic>.from(d) : const {};
  }

  /// 我的订阅。关键字段：
  ///  · token_clash_url —— mihomo 可直接拉取的 Clash 订阅地址
  ///  · expire_time / days_remaining / device_limit / current_devices / is_active
  Future<Map<String, dynamic>> userSubscription() async {
    final d = await get('/subscriptions/user-subscription');
    return d is Map ? Map<String, dynamic>.from(d) : const {};
  }

  /// 由订阅信息拼出 mihomo 订阅地址。
  /// 优先用后端给的 token_clash_url（已带 format=clash），
  /// 缺失时才回退到自拼（用 universal 的 subscription_url）。
  static String? clashSubscribeUrl(Map<String, dynamic> sub) {
    for (final k in ['token_clash_url', 'token_url', 'subscription_url']) {
      final v = (sub[k] ?? '').toString().trim();
      if (v.isEmpty) continue;
      if (!v.contains('format=') && !v.contains('type=')) {
        return '$v${v.contains('?') ? '&' : '?'}format=clash';
      }
      return v;
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> devices() async =>
      _asList(await get('/subscriptions/devices'));

  Future<void> deleteDevice(int id) =>
      delete('/subscriptions/devices/$id').then((_) {});

  Future<List<Map<String, dynamic>>> paymentMethods() async {
    final d = await get('/payment/methods');
    if (d is Map) return _asList(d['methods']);
    return _asList(d);
  }

  Future<Map<String, dynamic>> createOrder({
    required int packageId,
    String? couponCode,
  }) async {
    final d = await post('/orders', body: {
      'package_id': packageId,
      if (couponCode != null && couponCode.isNotEmpty) 'coupon_code': couponCode,
    });
    return d is Map ? Map<String, dynamic>.from(d) : const {};
  }

  /// 自定义套餐下单（后端 config: custom_package_enabled）。
  /// 自定义套餐下单。字段名是 `devices`（不是 `device_count`）——
  /// 后端 binding 里 `devices` 是 required，写错名字会直接 40000 参数错误。
  Future<Map<String, dynamic>> createCustomOrder({
    required int devices,
    required int months,
    String? couponCode,
  }) async {
    final d = await post('/orders/custom', body: {
      'devices': devices,
      'months': months,
      if (couponCode != null && couponCode.isNotEmpty) 'coupon_code': couponCode,
    });
    return d is Map ? Map<String, dynamic>.from(d) : const {};
  }

  /// 发起支付。
  ///
  /// [paymentMethod] 是**字符串**，取自 `/payment/methods` 里各项的 `pay_type`
  /// （实测站点为 `alipay` / `codepay_alipay`）；传 `"balance"` 表示余额支付。
  ///
  /// 注意：后端 `PayOrder` 只解析 `payment_method` 这一个字段，且**没有**
  /// `method_id` 这种按数字 ID 选通道的写法。按 ID 传会被静默忽略，
  /// 后端拿空字符串走默认分支 —— 表现为「点了支付却报通道不可用」，
  /// 排查时很难联想到是参数名不对。
  Future<Map<String, dynamic>> payOrder(
    String orderNo, {
    required String paymentMethod,
  }) async {
    final d = await post('/orders/$orderNo/pay',
        body: {'payment_method': paymentMethod});
    return d is Map ? Map<String, dynamic>.from(d) : const {};
  }

  Future<Map<String, dynamic>> orderStatus(String orderNo) async {
    final d = await get('/orders/$orderNo/status');
    return d is Map ? Map<String, dynamic>.from(d) : const {};
  }

  Future<void> cancelOrder(String orderNo) =>
      post('/orders/$orderNo/cancel').then((_) {});

  Future<List<Map<String, dynamic>>> orders({int page = 1, int pageSize = 20}) async {
    final d = await get('/orders', query: {
      'page': '$page',
      'page_size': '$pageSize',
    });
    if (d is Map) return _asList(d['items']);
    return _asList(d);
  }

  Future<Map<String, dynamic>> verifyCoupon(String code, {int? packageId}) async {
    final d = await post('/coupons/verify', body: {
      'code': code,
      if (packageId != null) 'package_id': packageId,
    });
    return d is Map ? Map<String, dynamic>.from(d) : const {};
  }

  Future<int> unreadNoticeCount() async {
    final d = await get('/notifications/unread-count');
    if (d is Map) {
      final v = d['count'] ?? d['unread_count'] ?? d['unread'];
      if (v is num) return v.toInt();
    }
    if (d is num) return d.toInt();
    return 0;
  }

  Future<List<Map<String, dynamic>>> notifications({int page = 1}) async {
    final d = await get('/notifications',
        query: {'page': '$page', 'page_size': '20'});
    if (d is Map) return _asList(d['items']);
    return _asList(d);
  }

  Future<void> markNoticeRead(int id) =>
      put('/notifications/$id/read').then((_) {});

  Future<List<Map<String, dynamic>>> announcements() async =>
      _asList(await get('/announcements'));

  Future<Map<String, dynamic>> softwareVersions() async {
    final d = await get('/software/versions');
    return d is Map ? Map<String, dynamic>.from(d) : const {};
  }

  Future<void> changePassword(String oldPassword, String newPassword) => post(
        '/users/change-password',
        body: {'old_password': oldPassword, 'new_password': newPassword},
      ).then((_) {});

  /// 后端一致性：`data` 可能是裸数组，也可能是 {items:[...]}。两种都吃。
  static List<Map<String, dynamic>> _asList(dynamic d) {
    dynamic arr = d;
    if (d is Map) {
      arr = d['items'] ?? d['list'] ?? d['data'] ?? const [];
    }
    if (arr is! List) return const [];
    return arr
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList(growable: false);
  }

  void close() => _http.close(force: true);
}
