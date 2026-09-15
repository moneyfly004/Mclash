// ignore_for_file: unused_catch_stack
import 'dart:async';
import 'dart:io';

import 'package:dio/io.dart';
import 'package:mclash/app/runtime/return_result.dart';
import 'package:webdav_client_plus/webdav_client_plus.dart';
import 'package:punycode_converter/punycode_converter.dart' as punycode;

class WebdavClientUtils {
  static const String _prefix = "/mclash/";
  static bool isInnerError(String message) {
    int? statusCode = message.contains("Status:") == true
        ? int.tryParse(message.split("Status:")[1].split(" ")[1])
        : null;
    if (statusCode == 207 ||
        statusCode == 422 ||
        statusCode == 423 ||
        statusCode == 424 ||
        statusCode == 507 ||
        statusCode == 401 ||
        statusCode == 403 ||
        statusCode == 404 ||
        statusCode == 409 ||
        statusCode == 412) {
      return true;
    }
    return false;
  }

  static Future<ReturnResult<WebdavClient>> connect(
    String? proxyUrl,
    String url,
    String user,
    String password,
  ) async {
    Uri? uri = Uri.tryParse(url.trim());
    try {
      uri = uri?.punyEncoded;
    } catch (err) {}
    if (uri == null) {
      return ReturnResult(
        error: ReturnResultError("Invalid URL:${url.trim()}"),
      );
    }
    var client = WebdavClient(
      url: uri.toString(),
      auth: BasicAuth(user: user.trim(), pwd: password.trim()),
    );
    // ------------------------------------------------------------------
    // WebDAV 走**直连**，不经本地混合代理。
    //
    // 原因：pub.dev 版 webdav_client_plus 1.0.2 不暴露 setHttpClientAdapter /
    // setFollowRedirects（那是 KaringX fork 的私有改动）。
    // 而且 WebDAV 服务器通常是用户自己的 NAS 或国内云盘，直连更快；
    // 订阅隧道的主要用途是访问被墙站点。需要代理时用户可开 TUN 全局模式。
    // proxyUrl 参数保留以维持调用方签名兼容（当前未使用）。
    // ------------------------------------------------------------------

    client.setHeaders({'accept-charset': 'utf-8'});

    // Set the connection server timeout time in milliseconds.
    client.setConnectTimeout(8000);

    // Set send data timeout time in milliseconds.
    /* _client!.setSendTimeout(8000);

    // Set transfer data time in milliseconds.
    _client!.setReceiveTimeout(8000);*/

    // Test whether the service can connect
    try {
      await client.ping();
    } catch (err, stacktrace) {
      return ReturnResult(error: ReturnResultError("ping:${err.toString()}"));
    }
    try {
      await client.mkdir(_prefix);
    } catch (err, stacktrace) {
      return ReturnResult(error: ReturnResultError("mkdir:${err.toString()}"));
    }
    return ReturnResult(data: client);
  }

  static Future<ReturnResult<List<String>>> list(WebdavClient client) async {
    try {
      final list = await client.readDir(_prefix);
      final names = <String>[];
      for (final item in list) {
        if (item.isDir) {
          continue;
        }
        names.add(item.name);
      }
      return ReturnResult(data: names);
    } catch (err, stacktrace) {
      return ReturnResult(error: ReturnResultError("list:${err.toString()}"));
    }
  }

  static Future<ReturnResultError?> upload(
    WebdavClient client, {
    required String relativePath,
    required String localPath,
  }) async {
    try {
      await client.writeFile(localPath, _prefix + relativePath);
    } catch (err, stacktrace) {
      return ReturnResultError("upload:${err.toString()}");
    }
    return null;
  }

  static Future<ReturnResultError?> delete(
    WebdavClient client,
    String relativePath,
  ) async {
    try {
      await client.remove(_prefix + relativePath);
    } catch (err, stacktrace) {
      return ReturnResultError("delete:${err.toString()}");
    }
    return null;
  }

  static Future<ReturnResultError?> download(
    WebdavClient client, {
    required String relativePath,
    required String localPath,
  }) async {
    try {
      await client.readFile(_prefix + relativePath, localPath);
    } catch (err, stacktrace) {
      return ReturnResultError("download:${err.toString()}");
    }
    return null;
  }
}
