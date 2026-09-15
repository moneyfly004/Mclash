/// Mclash 后台客户端核心 —— XBoard 兼容 API 的通用实现。
///
/// 后台：`https://new.moneyfly.top/api/v1`（CBoard / XBoard 兼容）
/// 统一响应：`{ "code": 0, "message": "success", "data": { ... } }`
///
/// 设计说明：
///   原 Clash Mi 的 `board_service` 支持 v2board / xboard / sspanel 三种第三方机场面板，
///   Mclash 只对接自家后台，因此这里实现**同一套客户端接口**（V2BoardClient /
///   XboardClient / SSPanelUimClient），但底层都指向自有后端。
///   好处：Clash Mi 的会话持久化、配置管理、覆写管线（约 3000 行）零改动可用。
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

/// 会话持久化接口（由 App 侧的 BoardSessionPersistentManager 实现）
abstract class BoardSessionPersistent {
  void updateLoginAuthData(String id, String account, String authData);

  void logout(String id, String account);

  void update(String id, String account, String api, dynamic data);

  void updateSubscribeUrl(String id, String account, String subscribeUrl);

  dynamic get(String id, String account, String api);

  void updateHeadersAndCookies(
    String cookie,
    Map<String, String> headers,
    List<String> cookies,
  );
}

/// 后台统一响应包（对齐 `/api/v1` 的 `{code, message, data}`）
class BoardResponse<T> {
  BoardResponse({
    this.statusCode = 0,
    this.code = 0,
    this.message = "",
    this.data,
    this.ret,
  });

  /// HTTP 状态码（200 视为成功，与 Clash Mi 的判定保持一致）
  int statusCode;

  /// 业务码（0 = 成功）
  int code;

  String message;
  T? data;

  /// SSPanel-UIM 风格的布尔结果（`{"ret": 1}`）。null 表示该后端不返回此字段。
  bool? ret;

  bool get ok => statusCode == 200 && code == 0;

  /// 供 UI 直接展示的完整错误信息
  String getFullMessage() {
    if (message.isNotEmpty) {
      return message;
    }
    if (statusCode == 0) {
      return "网络连接失败，请检查网络后重试";
    }
    return "请求失败（$statusCode）";
  }

  @override
  String toString() => "BoardResponse($statusCode, $code, $message)";
}

/// 登录请求
class LoginRequest {
  LoginRequest({required this.email, required this.password});

  final String email;
  final String password;

  Map<String, dynamic> toJson() => {"email": email, "password": password};
}

/// 登录响应数据
class LoginResponseData {
  LoginResponseData({
    this.accessToken = "",
    this.refreshToken = "",
    this.userId = 0,
    this.isAdmin = false,
  });

  String accessToken;
  String refreshToken;
  int userId;
  bool isAdmin;

  void fromJson(Map<String, dynamic> j) {
    accessToken = j["access_token"]?.toString() ?? "";
    refreshToken = j["refresh_token"]?.toString() ?? "";
    final user = j["user"];
    if (user is Map) {
      userId = (user["id"] as num?)?.toInt() ?? 0;
      isAdmin = user["is_admin"] == true;
    }
  }
}

/// 订阅响应数据
class SubscribeResponseData {
  SubscribeResponseData({
    this.subscribeUrl = "",
    this.universalUrl = "",
    this.expireTime = "",
    this.deviceLimit = 0,
    this.currentDevices = 0,
    this.remainingDays = 0,
    this.isExpired = false,
    this.status = "",
    this.isActive = true,
  });

  String subscribeUrl;
  String universalUrl;
  String expireTime;
  int deviceLimit;
  int currentDevices;
  int remainingDays;
  bool isExpired;
  String status;
  bool isActive;

  bool get hasSubscription => status == "active" && !isExpired && isActive;

  void fromJson(Map<String, dynamic> j) {
    subscribeUrl = j["subscribe_url"]?.toString() ??
        j["subscribeUrl"]?.toString() ??
        "";
    universalUrl = j["universal_url"]?.toString() ?? "";
    expireTime = j["expire_time"]?.toString() ?? "";
    deviceLimit = (j["device_limit"] as num?)?.toInt() ?? 0;
    currentDevices = (j["current_devices"] as num?)?.toInt() ?? 0;
    remainingDays = (j["remaining_days"] as num?)?.toInt() ?? 0;
    isExpired = j["is_expired"] == true;
    status = j["status"]?.toString() ?? "";
    isActive = j["is_active"] != false;
  }
}

/// 用户信息响应数据
class UserInfoResponseData {
  UserInfoResponseData({
    this.id = 0,
    this.email = "",
    this.balance = 0,
    this.planId = 0,
    this.expiredAt = 0,
    this.isActive = true,
  });

  int id;
  String email;
  double balance;
  int planId;
  int expiredAt;
  bool isActive;

  void fromJson(Map<String, dynamic> j) {
    id = (j["id"] as num?)?.toInt() ?? 0;
    email = j["email"]?.toString() ?? "";
    balance = double.tryParse(j["balance"]?.toString() ?? "") ?? 0;
    planId = (j["plan_id"] as num?)?.toInt() ?? 0;
    expiredAt = (j["expired_at"] as num?)?.toInt() ?? 0;
    isActive = j["is_active"] != false;
  }
}

/// 客户端公共参数
class BoardClientOptions {
  BoardClientOptions({
    required this.baseUrl,
    this.baseDomains = const [],
    required this.id,
    required this.persistent,
  });

  String baseUrl;
  List<String> baseDomains;
  String id;
  BoardSessionPersistent persistent;
}

/// XBoard 兼容客户端核心。三个"面板类型"共用这一份实现。
class BoardApiClient {
  // 这里原先还有一个 `_base` 字段（构造时净化 options.baseUrl），但它从未被读取 ——
  // 真正生效的是下面的 `baseUrl` getter（_baseUrlOverride ?? options.baseUrl）。
  // 分析器报 unused_field，已删除字段与对应初始化式。
  BoardApiClient(this.options);

  final BoardClientOptions options;

  String? proxyUrl;
  String userAgent = "";
  Duration timeout = const Duration(seconds: 10);

  String _auth = "";
  String _account = "";
  final Map<String, String> _headers = {};
  final List<String> _cookies = [];

  String get account => _account;

  /// 客户端版本（部分面板按版本返回不同订阅格式）
  String version = "";

  void setVersion(String v) => version = v;

  Map<String, String> getAuthHeaders() {
    final h = <String, String>{..._headers};
    if (_auth.isNotEmpty) {
      h["Authorization"] = "Bearer $_auth";
      h["X-Auth-Token"] = _auth;
    }
    if (userAgent.isNotEmpty) {
      h["User-Agent"] = userAgent;
    }
    return h;
  }

  void _restoreAuth() {
    final v = options.persistent.get(options.id, _account, "auth");
    if (v is String && v.isNotEmpty) {
      _auth = v;
    }
  }

  // ---------------------------------------------------------------------
  // HTTP
  // ---------------------------------------------------------------------
  Future<http.Client> _client() async {
    final proxy = proxyUrl;
    if (proxy == null || proxy.isEmpty) {
      return http.Client();
    }
    // 已连接时经本地混合代理发起请求（与原 Clash Mi 行为一致：
    // 后台域名在部分网络环境下直连不可达）。
    // http 包默认不读系统代理，因此这里显式指定。
    final inner = HttpClient();
    inner.connectionTimeout = timeout;
    inner.findProxy = (_) => "PROXY $proxy";
    return IOClient(inner);
  }

  Uri _uri(String path) {
    if (path.startsWith("http")) {
      return Uri.parse(path);
    }
    final base = baseUrl.replaceAll(RegExp(r'/+$'), "");
    return Uri.parse("$base${path.startsWith("/") ? path : "/$path"}");
  }

  Future<BoardResponse<T>> _request<T>(
    String method,
    String path, {
    Map<String, dynamic>? body,
    T Function(Map<String, dynamic>)? parse,
    bool auth = true,
  }) async {
    final headers = <String, String>{
      "Content-Type": "application/json; charset=UTF-8",
      "Accept": "application/json",
    };
    if (userAgent.isNotEmpty) {
      headers["User-Agent"] = userAgent;
    }
    if (auth && _auth.isNotEmpty) {
      headers["Authorization"] = "Bearer $_auth";
    }
    headers.addAll(_headers);

    try {
      final uri = _uri(path);
      late http.Response resp;
      final client = await _client();
      try {
        switch (method) {
          case "POST":
            resp = await client
                .post(uri, headers: headers, body: jsonEncode(body ?? {}))
                .timeout(timeout);
          case "PUT":
            resp = await client
                .put(uri, headers: headers, body: jsonEncode(body ?? {}))
                .timeout(timeout);
          case "DELETE":
            resp = await client.delete(uri, headers: headers).timeout(timeout);
          default:
            resp = await client.get(uri, headers: headers).timeout(timeout);
        }
      } finally {
        client.close();
      }

      // 记住 Set-Cookie（部分面板靠 cookie 维持会话）
      final setCookie = resp.headers["set-cookie"];
      if (setCookie != null && setCookie.isNotEmpty) {
        _cookies
          ..clear()
          ..addAll(setCookie.split(",").map((e) => e.split(";").first.trim()));
      }

      Map<String, dynamic>? json;
      if (resp.body.isNotEmpty) {
        try {
          final decoded = jsonDecode(resp.body);
          if (decoded is Map) {
            json = Map<String, dynamic>.from(decoded);
          }
        } catch (_) {}
      }

      if (json == null) {
        return BoardResponse<T>(
          statusCode: resp.statusCode,
          message: resp.statusCode == 200
              ? "服务器返回了无法解析的内容"
              : "请求失败（${resp.statusCode}）",
        );
      }

      final code = (json["code"] as num?)?.toInt() ?? 0;
      final message = json["message"]?.toString() ??
          json["msg"]?.toString() ??
          json["detail"]?.toString() ??
          "";
      final dataRaw = json["data"];

      T? data;
      if (parse != null && dataRaw is Map) {
        data = parse(Map<String, dynamic>.from(dataRaw));
      }

      bool? ret;
      if (json["ret"] != null) {
        final r = json["ret"];
        ret = r == true || r == 1 || r == "1";
      }

      return BoardResponse<T>(
        statusCode: resp.statusCode,
        code: code,
        message: (resp.statusCode == 200 && code == 0) ? "" : message,
        data: data,
        ret: ret,
      );
    } on TimeoutException {
      return BoardResponse<T>(statusCode: 0, message: "服务器响应超时，请稍后重试");
    } on SocketException {
      return BoardResponse<T>(statusCode: 0, message: "网络连接失败，请检查网络后重试");
    } catch (e) {
      return BoardResponse<T>(statusCode: 0, message: "$e");
    }
  }

  // ---------------------------------------------------------------------
  // 认证
  // ---------------------------------------------------------------------
  Future<BoardResponse<LoginResponseData>> login(
    LoginRequest request, {
    String basePath = "/auth/login",
  }) async {
    _account = request.email;
    _restoreAuth();
    final resp = await _request<LoginResponseData>(
      "POST",
      basePath,
      body: request.toJson(),
      auth: false,
      parse: (j) => LoginResponseData()..fromJson(j),
    );
    if (resp.statusCode == 200 && resp.code == 0 && resp.data != null) {
      _auth = resp.data!.accessToken;
      options.persistent.updateLoginAuthData(options.id, _account, _auth);
      options.persistent.update(
        options.id,
        _account,
        "login",
        {"email": _account, "user": resp.data!.userId},
      );
      options.persistent.updateHeadersAndCookies(
        "${options.id}:$_account",
        _headers,
        _cookies,
      );
    }
    return resp;
  }

  Future<void> logout() async {
    try {
      await _request("POST", "/auth/logout");
    } catch (_) {}
    _auth = "";
    _cookies.clear();
    options.persistent.logout(options.id, _account);
  }

  /// 订阅元信息（XBoard 兼容：`/user/subscribe`）
  Future<BoardResponse<SubscribeResponseData>> getSubscribe() async {
    final resp = await _request<SubscribeResponseData>(
      "GET",
      "/user/subscribe",
      parse: (j) {
        // 后台可能把数据包在 user 里
        final d = j["user"] is Map
            ? Map<String, dynamic>.from(j["user"] as Map)
            : j;
        return SubscribeResponseData()..fromJson(d);
      },
    );
    if (resp.data != null && resp.data!.subscribeUrl.isNotEmpty) {
      options.persistent.updateSubscribeUrl(
        options.id,
        _account,
        resp.data!.subscribeUrl,
      );
    }
    return resp;
  }

  Future<BoardResponse<UserInfoResponseData>> getUserInfo() async {
    return _request<UserInfoResponseData>(
      "GET",
      "/users/me",
      parse: (j) => UserInfoResponseData()..fromJson(j),
    );
  }

  /// 通用 GET（供业务层复用同一套鉴权）
  Future<BoardResponse<Map<String, dynamic>>> getJson(String path) =>
      _request<Map<String, dynamic>>(
        "GET",
        path,
        parse: (j) => j,
      );

  Future<BoardResponse<Map<String, dynamic>>> postJson(
    String path, [
    Map<String, dynamic>? body,
  ]) =>
      _request<Map<String, dynamic>>(
        "POST",
        path,
        body: body,
        parse: (j) => j,
      );

  // ---------------------------------------------------------------------
  // 与 Clash Mi 的会话管理代码保持兼容的辅助方法
  // ---------------------------------------------------------------------

  /// 认证 cookie（用于把会话塞进 WebView 的 CookieManager）。
  /// 契约：`Map<String,String>?`（name → value）
  Map<String, String>? getAuthCookies() {
    if (_cookies.isEmpty) {
      return null;
    }
    final out = <String, String>{};
    for (final c in _cookies) {
      final i = c.indexOf('=');
      if (i > 0) {
        out[c.substring(0, i).trim()] = c.substring(i + 1).trim();
      }
    }
    return out.isEmpty ? null : out;
  }

  /// 认证 localStorage（原面板把 token 存在 localStorage，供 WebView 复用）
  Map<String, String>? getAuthLocalStorage() =>
      _auth.isEmpty ? null : {"auth": _auth};

  /// 换绑域名后重建 baseUrl（面板有多域名时用）
  set baseUrl(String v) => _baseUrlOverride = v;

  String get baseUrl =>
      _baseUrlOverride ?? options.baseUrl;

  String? _baseUrlOverride;

  void setAccount(String account) {
    _account = account;
    _restoreAuth();
  }

  void setAuthToken(String token) {
    _auth = token;
  }

  /// 把 headers/cookies 直接注入（从持久化会话恢复时用）
  void setHeadersAndCookiesForBot(
    Map<String, String> headers,
    List<String> cookies,
  ) {
    _headers
      ..clear()
      ..addAll(headers);
    _cookies
      ..clear()
      ..addAll(cookies);
  }

  /// 邮箱格式校验（**静态**：登录页以 `Client.validateEmail(...)` 调用）。
  /// 与后台注册校验同一条正则。
  static bool validateEmail(String? email) {
    if (email == null || email.trim().isEmpty) {
      return false;
    }
    return RegExp(r"^[\w.+-]+@[\w-]+(\.[\w-]+)+$").hasMatch(email.trim());
  }

  /// 密码最小长度（**静态**）。与后台 `auth.ValidatePasswordStrength` 对齐：8。
  static int getPasswordMinLen() => 8;


}
