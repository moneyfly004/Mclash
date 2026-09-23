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
      Log.i('http HeadRequest ${uri.toString()} exception: ${err.toString()}');
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
      Log.i('http Download ${uri.toString()} exception: ${err.toString()}');
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
      Log.i('http Upload ${uri.toString()} exception: ${err.toString()}');
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
      Log.i("http: 同一条请求失败日志已抑制 $_suppressed 条（${_lastLogKey.split("|").first}）");
      _suppressed = 0;
    }
    _lastLogKey = key;
    _lastLogAt = now;
    Log.i('http GetRequest $url exception: ${err.toString()}');
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
      Log.i('http PostRequest $url exception: ${err.toString()}');
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
      Log.i('http PutRequest $url exception: ${err.toString()}');
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
      Log.i('http PatchRequest $url exception: ${err.toString()}');
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
      Log.i('http DeletetRequest $url exception: ${err.toString()}');
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
