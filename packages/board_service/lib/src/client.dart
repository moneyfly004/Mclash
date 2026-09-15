
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

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

class BoardResponse<T> {
  BoardResponse({
    this.statusCode = 0,
    this.code = 0,
    this.message = "",
    this.data,
    this.ret,
  });

  int statusCode;

  int code;

  String message;
  T? data;

  bool? ret;

  bool get ok => statusCode == 200 && code == 0;

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

class LoginRequest {
  LoginRequest({required this.email, required this.password});

  final String email;
  final String password;

  Map<String, dynamic> toJson() => {"email": email, "password": password};
}

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

class BoardApiClient {

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

  Future<http.Client> _client() async {
    final proxy = proxyUrl;
    if (proxy == null || proxy.isEmpty) {
      return http.Client();
    }

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
