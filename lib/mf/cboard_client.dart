
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:mclash/app/modules/setting_manager.dart';
import 'package:mclash/app/utils/log.dart';
import 'package:mclash/app/utils/secure_storage.dart';
import 'package:mclash/mf/mclash_domains.dart';

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

abstract final class CBoardSessionStore {
  static const _key = 'mclash.cboard.session.v1';

  static CBoardSession? _cached;

  static CBoardSession? get cached => _cached;

  @visibleForTesting
  static bool Function()? rememberOverride;

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
  CBoardClient({
    String? baseUrl,
    List<String>? baseUrlCandidates,
    HttpClient? httpClient,
  })  : _http = httpClient ?? HttpClient(),
        _baseUrl = _normalize(baseUrl ?? MclashDomainPool.currentApiBaseUrl()) {
    final list = <String>[];
    if (baseUrl != null && baseUrl.trim().isNotEmpty) {
      // 显式传了 base（构建期 MCLASH_API_BASE、测试）就以它为首选，再补域名池候选。
      list.add(_normalize(baseUrl));
    }
    for (final c in baseUrlCandidates ?? const <String>[]) {
      final n = _normalize(c);
      if (n.isNotEmpty && !list.contains(n)) {
        list.add(n);
      }
    }
    for (final c in MclashDomainPool.apiBaseUrls()) {
      if (!list.contains(c)) {
        list.add(c);
      }
    }
    _candidates = List<String>.unmodifiable(list);
  }

  static const kCBoardDefaultHost = 'new.moneyfly.top';
  static const kCBoardDefaultBaseUrl = 'https://new.moneyfly.top/api/v1';

  final HttpClient _http;

  /// 当前使用的 base URL：轮换成功后会被改成可用域名，后续请求直接用它。
  String _baseUrl;

  /// 本次客户端可用的全部 base 候选（按域名池顺序，已去重）。
  late final List<String> _candidates;

  /// 正在处理的那次请求实际用的 base：CSRF / refresh 必须打同一个域名，
  /// 否则可能落在两个不同站点上，白白放大调用次数。
  String? _activeBase;

  CBoardSession? _session;
  Future<bool>? _refreshing;

  CBoardSession? get session => _session ?? CBoardSessionStore.cached;
  bool get isLoggedIn => session != null;
  Map<String, dynamic> get user => session?.user ?? const {};

  /// 当前 base URL（只读，UI/日志用来显示「当前在用哪个域名」）。
  String get baseUrl => _baseUrl;

  /// 当前 API host。
  String get currentHost => MclashDomainPool.hostOf(_baseUrl);

  /// 候选 base（测试断言用）。
  @visibleForTesting
  List<String> get baseUrlCandidates => _candidates;

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
      return _requestWithRotation(
        method,
        path,
        body: body,
        query: query,
        auth: auth,
        retryAuth: retryAuth,
        retryCsrf: retryCsrf,
      );
    }
    final prev = _writeLock;
    final gate = Completer<void>();
    _writeLock = gate.future;
    await prev;
    try {
      return await _requestWithRotation(
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

  /// 把 [method] 在候选域名上依次尝试，直到成功或走完一遍候选。
  ///
  /// 轮换条件（只有「请求根本没到达业务层」才换域名）：
  /// - 连接层失败：SocketException / HandshakeException / 超时 / 连接被重置
  /// - HTTP 5xx（仅 GET/HEAD）：站点整体挂了
  /// - 响应不是 JSON：被 Cloudflare 或错误页拦截
  ///
  /// 不轮换（换域名也一样，还会把「登录失败」变成误报）：
  /// - 401 / 403 / 404 等 4xx
  /// - 业务 code 非 0
  ///
  /// 另外，非幂等的写请求（POST/PUT/DELETE）只在**连接层**失败时轮换：
  /// 如果请求其实已经到达服务端，换域名重放会造成重复下单。
  ///
  /// CSRF 与 refresh 都在 [CBoardClient._requestAttempt] 内部按「本次 attempt 的
  /// 域名」重新获取/发起，绝不允许「在域名 A 取 CSRF 却打到域名 B」。
  Future<CBoardResponse<dynamic>> _requestWithRotation(
    String method,
    String path, {
    Object? body,
    Map<String, String>? query,
    bool auth = true,
    bool retryAuth = true,
    bool retryCsrf = true,
  }) async {
    final base = _baseUrl;
    final order = candidateBaseUrlsFor(base);
    _activeBase = base;
    try {
      CBoardException? lastFailure;
      for (var i = 0; i < order.length; i++) {
        final candidate = order[i];
        final last = i == order.length - 1;
        // 这里刻意**不提前**切换 _baseUrl：只有真的在这个域名上成功，才把它记为
        // 「当前可用域名」。否则失败后 _baseUrl 会停在坏域名上，下一次请求又会先
        // 试坏域名，等于绕过域名池的「上次可用优先 + 失败冷却」。
        _activeBase = candidate;
        try {
          final resp = await _requestAttempt(
            method,
            path,
            base: candidate,
            body: body,
            query: query,
            auth: auth,
            retryAuth: retryAuth,
            retryCsrf: retryCsrf,
          );
          if (!_shouldRotateOnResponse(resp, method)) {
            // 只有在这个域名上真的成功了，才把它固定为「当前域名」，
            // 这样「上次可用域名优先」才成立（失败路径保留原域名）。
            if (candidate != _baseUrl) {
              _switchBase(candidate);
            }
            MclashDomainPool.reportSuccess(MclashDomainPool.hostOf(candidate));
            return resp;
          }
          MclashDomainPool.reportFailure(MclashDomainPool.hostOf(candidate));
          lastFailure = CBoardException(
            '请求失败（HTTP ${resp.httpStatus}），已尝试域名 $candidate',
            code: resp.code,
            httpStatus: resp.httpStatus,
          );
        } on CBoardException catch (e) {
          if (!_shouldRotateOnException(e)) {
            // 业务层拒绝：换域名也没用，直接把结果交给调用方。
            rethrow;
          }
          MclashDomainPool.reportFailure(MclashDomainPool.hostOf(candidate));
          lastFailure = e;
        }
        if (last) {
          // 走到这里 lastFailure 必然已被赋值（上面两条路径都会写它），所以直接
          // 抛出即可；写成 `lastFailure ?? 新异常` 会被 analyze 判成
          // dead_null_aware_expression（warning 会让 CI 变红）。
          throw lastFailure;
        }
        Log.w(
          "CBoardClient: $method $path 在 ${MclashDomainPool.hostOf(candidate)} 失败"
          "（${lastFailure.message}），换下一个 API 域名重试",
        );
      }
      throw lastFailure ??
          CBoardException('请求失败：$method $path（已尝试 ${order.length} 个域名）');
    } finally {
      _activeBase = null;
    }
  }

  /// 当前 base 优先，其后是域名池候选（去重、保持域名池的优先级顺序）。
  ///
  /// 公开出来是为了让测试能断言候选顺序。
  @visibleForTesting
  List<String> candidateBaseUrlsFor(String current) {
    final list = <String>[];
    if (current.isNotEmpty) {
      list.add(current);
    }
    for (final c in _candidates) {
      if (!list.contains(c)) {
        list.add(c);
      }
    }
    if (list.isEmpty) {
      list.add(kCBoardDefaultBaseUrl);
    }
    return list;
  }

  /// 切换当前 base，并记一行中文日志，方便用户/排障时看出在用哪个域名。
  void _switchBase(String candidate) {
    final from = MclashDomainPool.hostOf(_baseUrl);
    _baseUrl = candidate;
    Log.i(
      "CBoardClient: API 域名已轮换 $from -> ${MclashDomainPool.hostOf(candidate)}",
    );
  }

  /// 只有「请求根本没到达业务层」的失败才轮换域名。
  bool _shouldRotateOnException(CBoardException e) {
    final status = e.httpStatus;
    if (status >= 300) {
      // 5xx＝站点整体挂了；3xx 但响应不是 JSON＝典型的边缘节点拦截页。
      // 两者都值得换域名；401/403/404 之类是账号/权限问题，换域名不会变好。
      return true;
    }
    if (status > 0) {
      return false;
    }
    // status == 0：连接层失败（网络不可达 / TLS 握手 / 超时 / 连接被重置）。
    // 写请求也允许在这里换域名，因为连接都没建起来，服务端肯定没处理过。
    return true;
  }

  /// 响应级的轮换判定：只有幂等请求（GET/HEAD）遇到 5xx 才换域名。
  ///
  /// 写请求遇到 5xx 不轮换：请求已经到达业务层，换域名重放可能造成重复下单。
  bool _shouldRotateOnResponse(CBoardResponse<dynamic> resp, String method) {
    if (resp.httpStatus < 500) {
      return false;
    }
    return methodAllowsFullRotation(method);
  }

  /// 幂等（GET/HEAD）＝可以放心在任意失败上换域名；写请求＝只允许连接层失败换。
  @visibleForTesting
  bool methodAllowsFullRotation(String method) {
    final m = method.toUpperCase();
    return m == 'GET' || m == 'HEAD';
  }

  /// 单次尝试：一次请求打一个 base，只做 CSRF/401 的既有重试，不再换域名。
  Future<CBoardResponse<dynamic>> _requestAttempt(
    String method,
    String path, {
    required String base,
    Object? body,
    Map<String, String>? query,
    bool auth = true,
    bool retryAuth = true,
    bool retryCsrf = true,
  }) async {
    final mutating = method != 'GET' && method != 'HEAD';

    final isAuthPath = path.startsWith('/auth/');

    var uri = Uri.parse('$base$path');
    if (query != null && query.isNotEmpty) {
      uri = uri.replace(queryParameters: {...uri.queryParameters, ...query});
    }

    String? csrf;
    if (mutating && auth && !isAuthPath) {
      csrf = await _fetchCsrfToken(base);
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
    } on HttpException catch (e) {
      // 连接被重置/中断：请求没到业务层，可以换域名。
      throw CBoardException('连接失败：${e.message}');
    } on TimeoutException {
      throw CBoardException('请求超时（连接或读取超时）');
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
        return _requestAttempt(method, path,
            base: base,
            body: body,
            query: query,
            auth: auth,
            retryAuth: false,
            retryCsrf: retryCsrf);
      }
    }

    if (r.isCsrfFailure && mutating && retryCsrf) {
      Log.w("CBoardClient: CSRF token 已过期，重新获取后重试一次 $method $path");
      return _requestAttempt(method, path,
          base: base,
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

  Future<String?> _fetchCsrfToken(String base) async {
    try {
      final r = await _requestAttempt('GET', '/csrf-token',
          base: base, auth: true, retryAuth: true, retryCsrf: false);
      final d = r.data;
      if (d is Map) {
        return (d['csrf_token'] ?? d['token'] ?? d['csrfToken'])?.toString();
      }
      if (d is String && d.isNotEmpty) return d;
    } catch (_) {

    }
    return null;
  }

  /// refresh 自身的有界超时：刷新只是重试的前置条件，不能让它把用户的请求拖死。
  static const Duration kRefreshTimeout = Duration(seconds: 15);

  Future<bool> _refreshOnce() => _refreshing ??=
      _doRefresh().timeout(kRefreshTimeout, onTimeout: () {
        // 注意：这里不能写成 `(): bool { ... }` —— Dart 不允许在闭包上标注
        // 返回类型（会报 expected_token），返回类型由 onTimeout 的签名推断。
        Log.w(
          "CBoardClient: token 刷新超时（${kRefreshTimeout.inSeconds}s），放弃本次刷新",
        );
        return false;
      }).whenComplete(() => _refreshing = null);

  Future<bool> _doRefresh() async {
    final rt = session?.refreshToken;
    if (rt == null || rt.isEmpty) return false;
    // refresh 必须打「当前这次 attempt 的域名」：token 是同一个账号的，
    // 但把请求打到另一个域名上等于凭空多碰一个站点，也容易触发风控。
    // 这里刻意不走轮换：401 本身不是轮换条件，只有连接层失败才由外层换域名。
    final base = _activeBase ?? _baseUrl;
    try {
      // 关键：直接走 _requestAttempt，**绝不能**再调 request()。
      // request() 对非 GET/HEAD 会抢同一把写锁，而写请求的 401 刷新恰恰发生在
      // 持有写锁的那次 request() 内部 —— 再抢一次就是自我死锁，下单/改密码等
      // 写操作会永久卡住（UI 表现为「点了没反应、一直转圈」）。
      final r = await _requestAttempt('POST', '/auth/refresh',
          base: base,
          body: {'refresh_token': rt},
          auth: false,
          retryAuth: false,
          retryCsrf: false);
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
      // 刷新成功说明这个域名是通的：记成可用域名（但如果 mid-request 已经
      // 轮换到别的域名，就不要把当前 base 退回去）。
      final host = MclashDomainPool.hostOf(base);
      MclashDomainPool.reportSuccess(host);
      if (_baseUrl == base) {
        Log.i("CBoardClient: API 域名 $host 正常（token 已刷新）");
      }
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

  static const String kUpgradeOrderPath = '/orders/upgrade';

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
