
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:mclash/app/modules/setting_manager.dart';
import 'package:mclash/app/utils/log.dart';
import 'package:mclash/app/utils/secure_storage.dart';

class CBoardResponse<T> {
  CBoardResponse({
    required this.code,
    required this.message,
    required this.data,
    required this.httpStatus,
  });

  final int code;
  final String message;
  final T? data;
  final int httpStatus;

  bool get ok => code == 0;

  bool get isUnauthorized => code == 40100 || httpStatus == 401;

  bool get isCsrfFailure => code == 40300;

  bool get isNotFound => code == 40400 || httpStatus == 404;

  @override
  String toString() => 'CBoardResponse(code: $code, message: $message)';
}

class CBoardException implements Exception {
  CBoardException(this.message, {this.code = -1, this.httpStatus = 0});

  final String message;
  final int code;
  final int httpStatus;

  bool get isUnauthorized => code == 40100 || httpStatus == 401;

  @override
  String toString() => message;
}

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

/// 会话存储。**是否落盘由登录窗口的「保存账号信息」决定。**
///
///   * 勾选（`remember == true`）→ 会话写进磁盘，下次打开自动登录；
///   * 不勾选 → 会话**只留在内存**里（本次运行照常用），磁盘上不写任何东西，
///     下次打开就停在登录窗口。同时会把上一次可能残留的会话清掉，
///     否则「取消勾选」对老会话不生效。
abstract final class CBoardSessionStore {
  static const _key = 'mclash.cboard.session.v1';

  static CBoardSession? _cached;

  static CBoardSession? get cached => _cached;

  /// 测试缝：替换「是否记住账号」的来源（真实实现读设置）。
  @visibleForTesting
  static bool Function()? rememberOverride;

  /// 测试缝：替换落盘层（真实实现写 SecureStorage），便于断言「到底写没写」。
  @visibleForTesting
  static Future<void> Function(String key, String value)? debugWriteOverride;

  @visibleForTesting
  static Future<String?> Function(String key)? debugReadOverride;

  @visibleForTesting
  static void debugResetCache() => _cached = null;

  static bool get remember => (rememberOverride ?? _rememberFromSettings)();

  static bool _rememberFromSettings() =>
      SettingManager.getConfig().rememberAccount;

  static Future<void> _write(String value) =>
      (debugWriteOverride ?? SecureStorage.write)(_key, value);

  static Future<String?> _read() =>
      (debugReadOverride ?? SecureStorage.read)(_key);

  static Future<CBoardSession?> load() async {
    if (_cached != null) return _cached;
    // 不记住账号 → 磁盘上的旧会话一律不认，并顺手删掉
    if (!remember) {
      await _write('');
      return null;
    }
    try {
      final raw = await _read();
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
        await _write('');
        return;
      }
      if (!remember) {
        // 只留在内存：本次运行照常用，但下次打开不会自动登录
        return;
      }
      await _write(jsonEncode(s.toJson()));
    } catch (e) {
      debugPrint('CBoardSessionStore.save failed: $e');
    }
  }

  static Future<void> clear() => save(null);
}

class CBoardClient {
  CBoardClient({String? baseUrl, HttpClient? httpClient})
      : baseUrl = _normalize(baseUrl ?? kCBoardDefaultBaseUrl),
        _http = httpClient ?? HttpClient();

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

  Future<bool> restore() async {
    _session = await CBoardSessionStore.load();
    return _session != null;
  }

  Map<String, String> _headers({bool auth = true, String? csrf}) {
    final h = <String, String>{
      'Accept': 'application/json',

      'User-Agent': 'Mclash/1.0 (${Platform.operatingSystem})',
    };
    if (auth) {
      final t = session?.accessToken;
      if (t != null && t.isNotEmpty) h['Authorization'] = 'Bearer $t';
    }
    if (csrf != null && csrf.isNotEmpty) h['X-CSRF-Token'] = csrf;
    return h;
  }

  /// 写请求的串行闸门。
  ///
  /// 为什么必须串行：服务端的 CSRF 中间件**每次校验成功都会轮换 token**
  /// （实测：先用 tokenA 成功 POST 一次，紧接着带 tokenA 再 POST → 40300
  /// 「CSRF token 无效或已过期」）。App 里存在并发写请求（改数量时的
  /// 「取消草稿单 + 重新算价」、支付与取消交叉），并发时总有一个拿着刚被
  /// 作废的 token 失败 —— 用户侧就是支付点了没反应 / 取消订单没反应。
  static Future<void> _writeLock = Future<void>.value();

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
    if (!mutating) {
      return _requestInner(
        method,
        path,
        body: body,
        query: query,
        auth: auth,
        retryAuth: retryAuth,
        retryCsrf: retryCsrf,
      );
    }
    // 排队执行：保证「取 token → 发请求」之间不会插入另一个写请求
    final prev = _writeLock;
    final gate = Completer<void>();
    _writeLock = gate.future;
    await prev;
    try {
      return await _requestInner(
        method,
        path,
        body: body,
        query: query,
        auth: auth,
        retryAuth: retryAuth,
        retryCsrf: retryCsrf,
      );
    } finally {
      gate.complete();
    }
  }

  Future<CBoardResponse<dynamic>> _requestInner(
    String method,
    String path, {
    Object? body,
    Map<String, String>? query,
    bool auth = true,
    bool retryAuth = true,
    bool retryCsrf = true,
  }) async {
    final mutating = method != 'GET' && method != 'HEAD';

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

    if (r.isUnauthorized && auth && retryAuth && !isAuthPath) {
      final refreshed = await _refreshOnce();
      if (refreshed) {
        return _requestInner(method, path,
            body: body,
            query: query,
            auth: auth,
            retryAuth: false,
            retryCsrf: retryCsrf);
      }
    }

    if (r.isCsrfFailure && mutating && retryCsrf) {
      // token 作废了 → 立刻重新取一个再试一次（此时没有并发写请求在跑）
      Log.w("CBoardClient: CSRF token 已过期，重新获取后重试一次 $method $path");
      return _requestInner(method, path,
          body: body,
          query: query,
          auth: auth,
          retryAuth: false,
          retryCsrf: false);
    }

    return r;
  }

  static String _snip(String s) =>
      s.length <= 120 ? s : '${s.substring(0, 120)}…';

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

    }
    return null;
  }

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

  static final ValueNotifier<bool> sessionChanges = ValueNotifier<bool>(false);

  Future<void> _setSession(CBoardSession? s) async {
    _session = s;
    await CBoardSessionStore.save(s);

    sessionChanges.value = s != null;
  }

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

      await request('POST', '/auth/logout',
          body: {'refresh_token': session?.refreshToken ?? ''}, retryAuth: false);
    } catch (_) {

    }
    await _setSession(null);
  }

  Future<void> sendVerificationCode(String email, {String purpose = 'register'}) =>
      post('/auth/verification/send',
          body: {'email': email.trim().toLowerCase(), 'purpose': purpose}).then((_) {});

  Future<void> verifyCode(String email, String code) => post('/auth/verification/verify',
          body: {'email': email.trim().toLowerCase(), 'code': code})
      .then((_) {});

  Future<CBoardSession> register({
    required String username,
    required String email,
    required String password,
    String verificationCode = '',
    String inviteCode = '',
  }) async {
    final r = await request('POST', '/auth/register', auth: false, retryAuth: false, body: {
      'username': username.trim(),
      'email': email.trim().toLowerCase(),
      'password': password,
      if (verificationCode.isNotEmpty) 'verification_code': verificationCode,
      if (inviteCode.isNotEmpty) 'invite_code': inviteCode,
      'website': '',
    });
    if (!r.ok) {
      throw CBoardException(
        r.message.isNotEmpty ? r.message : '注册失败（code ${r.code}）',
        code: r.code,
        httpStatus: r.httpStatus,
      );
    }
    final d = r.data;
    if (d is Map && (d['access_token'] ?? '').toString().isNotEmpty) {
      final s = CBoardSession(
        accessToken: d['access_token'].toString(),
        refreshToken: (d['refresh_token'] ?? '').toString(),
        user: d['user'] is Map ? Map<String, dynamic>.from(d['user']) : const {},
      );
      await _setSession(s);
      return s;
    }

    throw CBoardException('注册响应未包含 access_token，可能触发了风控或站点配置不同',
        code: r.code);
  }

  Future<void> forgotPassword(String email) => post('/auth/forgot-password',
          body: {'email': email.trim().toLowerCase()})
      .then((_) {});

  Future<void> resetPassword({
    required String email,
    required String code,
    required String password,
  }) =>
      post('/auth/reset-password', body: {
        'email': email.trim().toLowerCase(),
        'code': code,
        'password': password,
      }).then((_) {});

  Future<Map<String, dynamic>> createPayment({
    required int orderId,
    required int paymentMethodId,
    bool isMobile = false,
    bool useBalance = false,
    double balanceAmount = 0,
  }) async {
    final d = await post('/payment', body: {
      'order_id': orderId,
      'payment_method_id': paymentMethodId,
      'is_mobile': isMobile,
      'use_balance': useBalance,
      if (useBalance) 'balance_amount': balanceAmount,
    });
    return d is Map ? Map<String, dynamic>.from(d) : const {};
  }

  Future<Map<String, dynamic>> paymentStatus(int paymentId) async {
    final d = await get('/payment/status/$paymentId');
    return d is Map ? Map<String, dynamic>.from(d) : const {};
  }

  /// 设备/时长增量升级：算价与下单（**实测的服务端契约**）。
  ///
  /// 路由与参数名是逐条探出来的，写错就是「价格获取失败 / 支付不了」：
  ///   * 路由是 `/orders/upgrade`（`/orders/upgrade-devices` 在服务端 404）；
  ///   * 参数是 `add_devices` / `add_days`（`additional_*` 一律 400 参数错误）。
  ///
  /// 另外：后端**不认** `preview_only`，算价请求也会落一笔待支付订单。所以
  /// 调用方不要「先算价再下单」，而应把这笔算价返回的订单当草稿订单直接用；
  /// 见 `MclashDeviceUpgrade`（改数量前先取消上一笔，退出时也取消）。
  static const String kUpgradeOrderPath = '/orders/upgrade';

  /// 算价（后端会建一笔 pending 草稿订单，所以调用方要负责取消旧的）。
  ///
  /// 字段口径（实测后端）：续期用 **`extend_months`**；`add_days` 后端**不认**
  /// —— 以前客户端只发 add_days，于是「增加天数」金额不变、到期时间也不变，
  /// 用户花了钱没续上。现在按天换算成月（30 天 = 1 个月，向上取整）再发。
  Future<Map<String, dynamic>> previewDeviceUpgrade({
    required int addDevices,
    int addDays = 0,
  }) async {
    final d = await post(
      kUpgradeOrderPath,
      body: {
        'add_devices': addDevices,
        if (addDays > 0) 'extend_months': (addDays + 29) ~/ 30,
        'add_days': addDays,
      },
    );
    return d is Map ? Map<String, dynamic>.from(d) : <String, dynamic>{};
  }

  Future<Map<String, dynamic>> createDeviceUpgradeOrder({
    required int addDevices,
    int addDays = 0,
    String? paymentMethod,
  }) async {
    final method = paymentMethod?.trim() ?? "";
    final d = await post(
      kUpgradeOrderPath,
      body: {
        'add_devices': addDevices,
        // 与算价一致：后端续期字段是 extend_months（add_days 会被忽略）
        if (addDays > 0) 'extend_months': (addDays + 29) ~/ 30,
        'add_days': addDays,
        'payment_method': method.isEmpty ? null : method,
      },
    );
    return d is Map ? Map<String, dynamic>.from(d) : <String, dynamic>{};
  }

  Future<Map<String, dynamic>> payWithBalance(String orderNo) async {
    final d = await post('/orders/$orderNo/pay', body: {'payment_method': 'balance'});
    return d is Map ? Map<String, dynamic>.from(d) : const {};
  }

  Future<Map<String, dynamic>> me() async {
    final d = await get('/users/me');
    if (d is Map) {
      final s = session;
      if (s != null) await _setSession(s.copyWith(user: Map<String, dynamic>.from(d)));
      return Map<String, dynamic>.from(d);
    }
    return const {};
  }

  Future<dynamic> get(String path, {Map<String, String>? query}) =>
      _data(request('GET', path, query: query));

  Future<dynamic> post(String path, {Object? body}) =>
      _data(request('POST', path, body: body));

  Future<dynamic> put(String path, {Object? body}) =>
      _data(request('PUT', path, body: body));

  Future<dynamic> delete(String path, {Object? body}) =>
      _data(request('DELETE', path, body: body));

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

  Future<Map<String, dynamic>> siteConfig() async {
    final d = await get('/config');
    return d is Map ? Map<String, dynamic>.from(d) : const {};
  }

  Future<List<Map<String, dynamic>>> packages() async {
    final d = await get('/packages');
    return _asList(d);
  }

  Future<Map<String, dynamic>> dashboard() async {
    final d = await get('/users/dashboard-info');
    return d is Map ? Map<String, dynamic>.from(d) : const {};
  }

  Future<Map<String, dynamic>> userSubscription() async {
    final d = await get('/subscriptions/user-subscription');
    return d is Map ? Map<String, dynamic>.from(d) : const {};
  }

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
