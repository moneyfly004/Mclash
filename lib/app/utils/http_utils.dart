// ignore_for_file: empty_catches

import 'dart:convert';
import 'dart:io';

import 'package:mclash/app/runtime/return_result.dart';

import 'package:mclash/app/modules/setting_manager.dart';
import 'package:mclash/app/utils/did.dart';
import 'package:mclash/app/utils/hwid_utils.dart';
import 'package:mclash/app/utils/log.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:punycode_converter/punycode_converter.dart';
import 'package:tuple/tuple.dart';

typedef DecodeCallback = String Function(String);

abstract final class HttpUtils {
  static const String kStatusError = "http statusCode:";

  /// 需要打码的 query 参数名（小写比较）。
  static const Set<String> _sensitiveKeys = {
    "token",
    "access_token",
    "refresh_token",
    "ticket",
    "secret",
    "key",
    "apikey",
    "api_key",
    "password",
    "passwd",
    "pwd",
    "auth",
    "authorization",
    "sign",
    "signature",
    "code",
    "hwid",
  };

  /// 兜底正则：不依赖 Uri 解析，直接按"参数名=值"打码。
  ///
  /// 只认 `? & # , ;` 或字符串开头之后的参数，因此 **path 里的 `token` 不会被碰**
  /// （例如 `/api/v1/client/subscribe/token/abc` 原样保留）。
  static final RegExp _sensitiveParamRegExp = RegExp(
    r"([?&#,;]|^)([A-Za-z0-9_.\-\[\]]*(?:token|secret|password|passwd|ticket|"
    r"sign|signature|api_?key|hwid|auth|code|key)[A-Za-z0-9_.\-\[\]]*)=([^&#\s]*)",
    caseSensitive: false,
  );

  static bool _isSensitiveKey(String key) {
    final raw = key.trim().toLowerCase();
    // PHP 风格的数组参数：token[0]、token[] 也要打码。
    final k = raw.contains("[") ? raw.split("[").first : raw;
    if (k.isEmpty) {
      return false;
    }
    if (_sensitiveKeys.contains(k)) {
      return true;
    }
    // 兜底：sub_token / userToken / client_secret 这类带前后缀的键。
    return k.endsWith("token") ||
        k.endsWith("secret") ||
        k.endsWith("password") ||
        k.endsWith("passwd") ||
        k.endsWith("_key") ||
        k.endsWith("apikey");
  }

  static String _tryDecodeKey(String raw) {
    try {
      return Uri.decodeQueryComponent(raw);
    } catch (_) {
      return raw;
    }
  }

  static String _redactQueryString(String query) {
    final out = <String>[];
    for (final seg in query.split("&")) {
      if (seg.isEmpty) {
        continue;
      }
      final i = seg.indexOf("=");
      if (i < 0) {
        out.add(seg);
        continue;
      }
      final rawKey = seg.substring(0, i);
      out.add(_isSensitiveKey(_tryDecodeKey(rawKey)) ? "$rawKey=***" : seg);
    }
    return out.join("&");
  }

  /// 兜底正则 2：参数名/等号被转义过的**嵌套 URL**（深链里很常见），例如
  /// `clash://install-config?url=https%3A%2F%2Fsub...%3Ftoken%3Dabc`：
  /// 只看 `?`/`&` 是抓不到里面那个 `token` 的。
  static final RegExp _encodedSensitiveParamRegExp = RegExp(
    r"(%3F|%3f|%26|%23|\?|&|#)"
    r"([A-Za-z0-9_.\-\[\]]*(?:token|secret|password|passwd|ticket|"
    r"sign|signature|api_?key|hwid|auth|code|key)[A-Za-z0-9_.\-\[\]]*)"
    r"(%3D|%3d|=)([^&#\s%]*)",
    caseSensitive: false,
  );

  static String _redactByRegExp(String text) {
    final plain = text.replaceAllMapped(
      _sensitiveParamRegExp,
      (m) => "${m.group(1) ?? ""}${m.group(2) ?? ""}=***",
    );
    return plain.replaceAllMapped(
      _encodedSensitiveParamRegExp,
      (m) =>
          "${m.group(1) ?? ""}${m.group(2) ?? ""}${m.group(3) ?? ""}***",
    );
  }

  /// 把 URL 里的敏感值（订阅 token、密码、签名等）替换成 `***`，用于日志与剪贴板。
  ///
  /// 订阅地址里的 `token=` 就是账号凭证：真机日志里出现过完整
  /// `https://sub.example.com/api/v1/client/subscribe?token=9c68ff44...`，
  /// 而日志页支持一键复制粘贴到群里 —— 等于把账号送人。
  ///
  /// 约定：
  ///  · **任何情况下都不抛异常**（日志路径不能因为脱敏失败而中断）；
  ///  · 解析失败 / 没解析出 query 时退回正则打码；
  ///  · path 里的 `token` 不需要处理（那是路径不是凭证值，且改动会破坏 URL 语义）。
  static String redact(String url) {
    if (url.isEmpty) {
      return url;
    }
    var text = url;
    try {
      final uri = Uri.tryParse(url);
      if (uri != null && uri.query.isNotEmpty) {
        final qStart = url.indexOf("?");
        if (qStart >= 0) {
          final qEnd = url.indexOf("#", qStart + 1);
          final head = url.substring(0, qStart + 1);
          final query = _redactQueryString(
            url.substring(qStart + 1, qEnd < 0 ? url.length : qEnd),
          );
          final tail = qEnd < 0 ? "" : url.substring(qEnd);
          text = "$head$query$tail";
        }
      }
    } catch (_) {
      text = url;
    }
    try {
      return _redactByRegExp(text);
    } catch (_) {
      return text;
    }
  }

  static Future<String> getUserAgent() async {
    return SettingManager.getConfig().userAgent();
  }

  static Future<ReturnResult<Tuple2<int, HttpHeaders>>> httpHeadRequest(
    Uri uri,
    int? proxyPort,
    String? userAgent,
    bool xhwid,
    Duration? timeout,
  ) async {
    timeout ??= const Duration(seconds: 20);
    var client = HttpClient();
    client.userAgent = userAgent == null || userAgent.isEmpty
        ? await getUserAgent()
        : userAgent;
    client.connectionTimeout = timeout;
    if ((proxyPort != null) && (proxyPort != 0)) {
      setProxy(client, proxyPort);
    }
    try {
      uri = uri.punyEncoded;
    } catch (err) {}
    try {
      HttpClientRequest request = await client.headUrl(uri).timeout(timeout);
      request.headers.set(HttpHeaders.acceptHeader, "*/*");
      await applyDeviceIdentityHeaders(request);
      if (xhwid) {
        final hwidHeaders = await HwidUtils.getHwidHeaders();
        hwidHeaders.forEach((key, value) => request.headers.set(key, value));
      }
      HttpClientResponse? response = await Future.any([
        waitResponseDone(request, null),
        waitResponseTimeout(request, timeout),
      ]);

      if (response == null) {
        return ReturnResult(
          error: ReturnResultError(
            "http response timeout after ${timeout.inSeconds} seconds",
          ),
        );
      }

      return ReturnResult(data: Tuple2(response.statusCode, response.headers));
    } catch (err, _) {
      Log.i(
        'http HeadRequest ${redact(uri.toString())} exception: ${err.toString()}',
      );
      return ReturnResult(
        error: ReturnResultError("http exception: ${err.toString()}"),
      );
    } finally {
      client.close(force: true);
    }
  }

  static Future<List<ReturnResult<HttpHeaders>>> httpDownloadList(
    List<Tuple2<Uri, String>> uris,
    int? proxyPort,
    String? userAgent,
    bool xhwid,
    Duration? timeout,
  ) async {
    if (uris.isEmpty) {
      return [ReturnResult(error: ReturnResultError("uris is empty"))];
    }
    if (uris.length == 1) {
      return [
        await httpDownload(
          uris[0].item1,
          uris[0].item2,
          proxyPort,
          userAgent,
          xhwid,
          timeout,
        ),
      ];
    }
    return Future.wait(
      uris.map(
        (item) => httpDownload(
          item.item1,
          item.item2,
          proxyPort,
          userAgent,
          xhwid,
          timeout,
        ),
      ),
    );
  }

  static Future<ReturnResult<HttpHeaders>> httpDownload(
    Uri uri,
    String path,
    int? proxyPort,
    String? userAgent,
    bool xhwid,
    Duration? timeout,
  ) async {
    timeout ??= const Duration(seconds: 60);
    var client = HttpClient();
    client.userAgent = userAgent == null || userAgent.isEmpty
        ? await getUserAgent()
        : userAgent;
    if ((proxyPort != null) && (proxyPort != 0)) {
      setProxy(client, proxyPort);
    }
    try {
      uri = uri.punyEncoded;
    } catch (err) {}
    try {
      HttpClientRequest request = await client.getUrl(uri).timeout(timeout);
      request.headers.set(HttpHeaders.acceptHeader, "*/*");
      await applyDeviceIdentityHeaders(request);
      if (xhwid) {
        final hwidHeaders = await HwidUtils.getHwidHeaders();
        hwidHeaders.forEach((key, value) => request.headers.set(key, value));
      }

      HttpClientResponse? response = await Future.any([
        waitResponseDone(request, path),
        waitResponseTimeout(request, timeout),
      ]);

      if (response == null) {
        return ReturnResult(
          error: ReturnResultError(
            "http response timeout after ${timeout.inSeconds} seconds",
          ),
        );
      }
      if (response.statusCode != 200) {
        return ReturnResult(
          error: ReturnResultError("$kStatusError ${response.statusCode}"),
        );
      }
      return ReturnResult(data: response.headers);
    } catch (err, _) {
      Log.i(
        'http Download ${redact(uri.toString())} exception: ${err.toString()}',
      );
      return ReturnResult(
        error: ReturnResultError("http exception: ${err.toString()}"),
      );
    } finally {
      client.close(force: true);
    }
  }

  static Future<ReturnResultError?> httpUpload(
    Uri uri,
    String path,
    int? proxyPort,
    String? userAgent,
  ) async {
    try {
      uri = uri.punyEncoded;
    } catch (err) {}
    var client = HttpClient();
    client.userAgent = userAgent == null || userAgent.isEmpty
        ? await getUserAgent()
        : userAgent;
    if ((proxyPort != null) && (proxyPort != 0)) {
      setProxy(client, proxyPort);
    }

    try {
      var request = http.MultipartRequest("POST", uri);
      request.files.add(await http.MultipartFile.fromPath('files', path));

      IOClient ioclient = IOClient(client);
      var response = await ioclient.send(request);

      if (response.statusCode != 200) {
        return ReturnResultError("$kStatusError ${response.statusCode}");
      }
    } catch (err, _) {
      Log.i(
        'http Upload ${redact(uri.toString())} exception: ${err.toString()}',
      );
      return ReturnResultError("http exception: ${err.toString()}");
    } finally {
      client.close(force: true);
    }
    return null;
  }

  static Future<ReturnResult<Tuple2<int, String>>> httpGetRequest(
    String url,
    int? proxyPort,
    Map<String, String>? headers,
    Duration? timeout,
    String? userAgent,
    List<Cookie>? cookies, {
    bool? noResponseBody,
    bool checkStatuscode = true,
  }) async {
    timeout ??= const Duration(seconds: 30);
    var client = HttpClient();
    client.userAgent = userAgent == null || userAgent.isEmpty
        ? await getUserAgent()
        : userAgent;
    client.connectionTimeout = timeout;
    if ((proxyPort != null) && (proxyPort != 0)) {
      setProxy(client, proxyPort);
    }
    var uri = Uri.parse(url);
    try {
      uri = uri.punyEncoded;
    } catch (err) {}
    try {
      HttpClientRequest request = await client.getUrl(uri).timeout(timeout);
      request.headers.set(HttpHeaders.acceptHeader, "*/*");
      if (headers != null) {
        headers.forEach((key, value) {
          request.headers.set(key, value);
        });
      }
      HttpClientResponse? response = await Future.any([
        waitResponseDone(request, null),
        waitResponseTimeout(request, timeout),
      ]);

      if (response == null) {
        return ReturnResult(
          error: ReturnResultError(
            "http response timeout after ${timeout.inSeconds} seconds",
          ),
        );
      }
      if (checkStatuscode == true) {
        if (response.statusCode != 200) {
          return ReturnResult(
            error: ReturnResultError("$kStatusError ${response.statusCode}"),
          );
        }
      }
      if (noResponseBody == true) {
        return ReturnResult(data: Tuple2(response.statusCode, ""));
      }
      var stringData = await response.transform(utf8.decoder).join();
      return ReturnResult(data: Tuple2(response.statusCode, stringData));
    } catch (err, _) {
      _logRequestFailure(url, err);
      return ReturnResult(
        error: ReturnResultError("http exception: ${err.toString()}"),
      );
    } finally {
      client.close(force: true);
    }
  }

  static const Duration _logDedupeWindow = Duration(seconds: 10);
  static String _lastLogKey = "";
  static DateTime? _lastLogAt;
  static int _suppressed = 0;

  static void _logRequestFailure(String url, Object err) {
    final key = "$url|${err.runtimeType}";
    final now = DateTime.now();
    final at = _lastLogAt;
    if (key == _lastLogKey &&
        at != null &&
        now.difference(at) < _logDedupeWindow) {
      _suppressed++;
      _lastLogAt = now;
      return;
    }
    if (_suppressed > 0) {
      Log.i(
        "http: 同一条请求失败日志已抑制 $_suppressed 条"
        "（${redact(_lastLogKey.split("|").first)}）",
      );
      _suppressed = 0;
    }
    _lastLogKey = key;
    _lastLogAt = now;
    Log.i('http GetRequest ${redact(url)} exception: ${err.toString()}');
  }

  static Future<ReturnResult<Tuple2<int, String>>> httpPostRequest(
    String url,
    int? proxyPort,
    Map<String, String>? headers,
    String body,
    Duration? timeout,
    String? userAgent,
    List<Cookie>? cookies,
    List<Cookie>? responseCookies, {
    bool checkStatuscode = true,
  }) async {
    timeout ??= const Duration(seconds: 30);
    var client = HttpClient();
    client.userAgent = userAgent == null || userAgent.isEmpty
        ? await getUserAgent()
        : userAgent;
    client.connectionTimeout = timeout;
    if ((proxyPort != null) && (proxyPort != 0)) {
      setProxy(client, proxyPort);
    }
    var uri = Uri.parse(url);
    try {
      uri = uri.punyEncoded;
    } catch (err) {}
    try {
      HttpClientRequest request = await client.postUrl(uri).timeout(timeout);
      request.headers.set(HttpHeaders.acceptHeader, "*/*");
      if (headers != null) {
        headers.forEach((key, value) {
          request.headers.set(key, value);
        });
      }
      if (cookies != null) {
        request.cookies.addAll(cookies);
      }

      if (body.isNotEmpty) {
        var bytes = request.encoding.encode(body);
        request.headers.set(
          HttpHeaders.contentLengthHeader,
          bytes.length.toString(),
        );

        request.add(bytes);
      }
      HttpClientResponse? response = await Future.any([
        waitResponseDone(request, null),
        waitResponseTimeout(request, timeout),
      ]);

      if (response == null) {
        return ReturnResult(
          error: ReturnResultError(
            "http response timeout after ${timeout.inSeconds} seconds",
          ),
        );
      }
      if (checkStatuscode == true) {
        if (response.statusCode != 200) {
          String stringData = "";
          try {
            stringData = await response.transform(utf8.decoder).join();
          } catch (err) {}
          return ReturnResult(
            error: ReturnResultError("$kStatusError ${response.statusCode}"),
            data: stringData.isNotEmpty
                ? Tuple2(response.statusCode, stringData)
                : null,
          );
        }
      }
      var stringData = await response.transform(utf8.decoder).join();
      if (responseCookies != null) {
        for (var cookie in response.cookies) {
          responseCookies.add(Cookie(cookie.name, cookie.value));
        }
      }

      return ReturnResult(data: Tuple2(response.statusCode, stringData));
    } catch (err) {
      Log.i(
        'http PostRequest ${redact(url)} exception: ${err.toString()}',
      );
      return ReturnResult(
        error: ReturnResultError("http exception: ${err.toString()}"),
      );
    } finally {
      client.close(force: true);
    }
  }

  static Future<ReturnResult<String>> httpPutRequest(
    String url,
    int? proxyPort,
    Map<String, String>? headers,
    String body,
    Duration? timeout,
    String? userAgent,
    List<Cookie>? cookies,
    List<Cookie>? responseCookies,
  ) async {
    timeout ??= const Duration(seconds: 20);
    var client = HttpClient();
    client.userAgent = userAgent == null || userAgent.isEmpty
        ? await getUserAgent()
        : userAgent;
    client.connectionTimeout = timeout;
    if ((proxyPort != null) && (proxyPort != 0)) {
      setProxy(client, proxyPort);
    }
    var uri = Uri.parse(url);
    try {
      uri = uri.punyEncoded;
    } catch (err) {}
    try {
      HttpClientRequest request = await client.putUrl(uri).timeout(timeout);
      request.headers.set(HttpHeaders.acceptHeader, "*/*");
      if (headers != null) {
        headers.forEach((key, value) {
          request.headers.set(key, value);
        });
      }
      if (cookies != null) {
        request.cookies.addAll(cookies);
      }

      if (body.isNotEmpty) {
        var bytes = request.encoding.encode(body);
        request.headers.set(
          HttpHeaders.contentLengthHeader,
          bytes.length.toString(),
        );

        request.add(bytes);
      }
      HttpClientResponse? response = await Future.any([
        waitResponseDone(request, null),
        waitResponseTimeout(request, timeout),
      ]);

      if (response == null) {
        return ReturnResult(
          error: ReturnResultError(
            "http response timeout after ${timeout.inSeconds} seconds",
          ),
        );
      }
      if (response.statusCode != 200 && response.statusCode != 204) {
        return ReturnResult(
          error: ReturnResultError("$kStatusError ${response.statusCode}"),
        );
      }
      var stringData = await response.transform(utf8.decoder).join();
      if (responseCookies != null) {
        for (var cookie in response.cookies) {
          responseCookies.add(Cookie(cookie.name, cookie.value));
        }
      }

      return ReturnResult(data: stringData);
    } catch (err) {
      Log.i('http PutRequest ${redact(url)} exception: ${err.toString()}');
      return ReturnResult(
        error: ReturnResultError("http exception: ${err.toString()}"),
      );
    } finally {
      client.close(force: true);
    }
  }

  static Future<ReturnResult<String>> httpPatchRequest(
    String url,
    int? proxyPort,
    Map<String, String>? headers,
    String body,
    Duration? timeout,
    String? userAgent,
    List<Cookie>? cookies,
  ) async {
    timeout ??= const Duration(seconds: 20);
    var client = HttpClient();
    client.userAgent = userAgent == null || userAgent.isEmpty
        ? await getUserAgent()
        : userAgent;
    client.connectionTimeout = timeout;
    if ((proxyPort != null) && (proxyPort != 0)) {
      setProxy(client, proxyPort);
    }
    var uri = Uri.parse(url);
    try {
      uri = uri.punyEncoded;
    } catch (err) {}
    try {
      HttpClientRequest request = await client.patchUrl(uri).timeout(timeout);
      if (headers != null) {
        headers.forEach((key, value) {
          request.headers.set(key, value);
        });
      } else {
        request.headers.set(
          HttpHeaders.contentTypeHeader,
          "application/json; charset=UTF-8",
        );
        request.headers.set(HttpHeaders.acceptHeader, "*/*");
      }
      if (cookies != null) {
        request.cookies.addAll(cookies);
      }

      if (body.isNotEmpty) {
        var bytes = request.encoding.encode(body);
        request.headers.set(
          HttpHeaders.contentLengthHeader,
          bytes.length.toString(),
        );

        request.add(bytes);
      }
      HttpClientResponse? response = await Future.any([
        waitResponseDone(request, null),
        waitResponseTimeout(request, timeout),
      ]);

      if (response == null) {
        return ReturnResult(
          error: ReturnResultError(
            "http response timeout after ${timeout.inSeconds} seconds",
          ),
        );
      }
      if (response.statusCode != 200 && response.statusCode != 204) {
        return ReturnResult(
          error: ReturnResultError("$kStatusError ${response.statusCode}"),
        );
      }
      var stringData = await response.transform(utf8.decoder).join();
      return ReturnResult(data: stringData);
    } catch (err) {
      Log.i('http PatchRequest ${redact(url)} exception: ${err.toString()}');
      return ReturnResult(
        error: ReturnResultError("http exception: ${err.toString()}"),
      );
    } finally {
      client.close(force: true);
    }
  }

  static Future<ReturnResult<String>> httpDeleteRequest(
    String url,
    int? proxyPort,
    Map<String, String>? headers,
    String body,
    Duration? timeout,
    String? userAgent,
    List<Cookie>? cookies,
  ) async {
    timeout ??= const Duration(seconds: 20);
    var client = HttpClient();
    client.userAgent = userAgent == null || userAgent.isEmpty
        ? await getUserAgent()
        : userAgent;
    client.connectionTimeout = timeout;
    if ((proxyPort != null) && (proxyPort != 0)) {
      setProxy(client, proxyPort);
    }
    var uri = Uri.parse(url);
    try {
      uri = uri.punyEncoded;
    } catch (err) {}
    try {
      HttpClientRequest request = await client.deleteUrl(uri).timeout(timeout);
      if (headers != null) {
        headers.forEach((key, value) {
          request.headers.set(key, value);
        });
      } else {
        request.headers.set(
          HttpHeaders.contentTypeHeader,
          "application/json; charset=UTF-8",
        );
        request.headers.set(HttpHeaders.acceptHeader, "*/*");
      }
      if (cookies != null) {
        request.cookies.addAll(cookies);
      }
      if (body.isNotEmpty) {
        var bytes = request.encoding.encode(body);
        request.headers.set(
          HttpHeaders.contentLengthHeader,
          bytes.length.toString(),
        );

        request.add(bytes);
      }
      HttpClientResponse? response = await Future.any([
        waitResponseDone(request, null),
        waitResponseTimeout(request, timeout),
      ]);

      if (response == null) {
        return ReturnResult(
          error: ReturnResultError(
            "http response timeout after ${timeout.inSeconds} seconds",
          ),
        );
      }
      if (response.statusCode != 200 && response.statusCode != 204) {
        return ReturnResult(
          error: ReturnResultError("$kStatusError ${response.statusCode}"),
        );
      }
      var stringData = await response.transform(utf8.decoder).join();
      return ReturnResult(data: stringData);
    } catch (err) {
      Log.i('http DeletetRequest ${redact(url)} exception: ${err.toString()}');
      return ReturnResult(
        error: ReturnResultError("http exception: ${err.toString()}"),
      );
    } finally {
      client.close(force: true);
    }
  }

  static Future<ReturnResult<String>> httpGetTitle(
    String url,
    String? userAgent,
  ) async {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      return ReturnResult(data: "");
    }
    Uri site = Uri(
      scheme: uri.scheme,
      userInfo: uri.userInfo,
      host: uri.host,
      port: uri.port,
    );
    final result = await HttpUtils.httpGetRequest(
      site.toString(),
      null,
      null,
      const Duration(seconds: 5),
      userAgent,
      null,
    );

    if (result.error != null) {
      return ReturnResult(error: result.error);
    }
    String body = result.data!.item2;
    int start = body.indexOf("<title>");
    int end = body.indexOf("</title>");
    String siteName = "";
    if (start < end) {
      siteName = body.substring(start + "<title>".length, end).trim();
    }
    return ReturnResult(data: siteName);
  }

  static Future<HttpClientResponse?> waitResponseDone(
    HttpClientRequest request,
    String? path,
  ) async {
    HttpClientResponse response = await request.close();
    if (response.statusCode == 200) {
      if (path != null && path.isNotEmpty) {
        await response.pipe(File(path).openWrite());
      }
    }
    return response;
  }

  static Future<HttpClientResponse?> waitResponseTimeout(
    HttpClientRequest request,
    Duration duration,
  ) async {
    await Future.delayed(duration);

    return null;
  }

  // 这里刻意不再设置 badCertificateCallback —— HttpClient 的默认行为就是严格
  // 校验证书链，这正是我们要的。
  //
  // 历史原因：本类继承自上游 Clash Mi，8 个请求方法都挂了
  //     client.badCertificateCallback = _certificateCheck;   // 实现为 => true
  // 等于对所有 HTTPS 请求关闭证书校验。后果不是"少报个错"，而是：
  //   · 订阅内容可被中间人整体替换（注入恶意节点）；
  //   · 更新包可被替换（更新链路本身还缺哈希校验）；
  //   · 某个域名证书不可用时也"看起来正常"，使多域名轮换永远不会触发。
  // 证书真的有问题的域名应当去修服务端证书，或由多域名轮换切到下一个域名 ——
  // 而不是放宽校验。切勿再把这段回调加回来。

  static void setProxy(HttpClient client, int proxyPort) {
    client.findProxy = (Uri uri) => "PROXY 127.0.0.1:$proxyPort";
  }
}


Future<void> applyDeviceIdentityHeaders(HttpClientRequest request) async {
  try {
    final did = await Did.getDid();
    if (did.isNotEmpty) {
      request.headers.set("X-App-Device-Id", did);
    }
  } catch (err) {
    Log.w("注入设备标识失败: $err");
  }
}
