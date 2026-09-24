import 'dart:async';
import 'dart:io';

import 'package:mclash/app/local_services/vpn_service.dart';
import 'package:mclash/app/runtime/return_result.dart';
import 'package:mclash/app/utils/file_utils.dart';
import 'package:mclash/app/utils/http_utils.dart';
import 'package:mclash/app/utils/log.dart';

abstract final class DownloadUtils {
  static Future<ReturnResult<HttpHeaders>> download(
    Uri uri,
    String downloadPath,
  ) async {
    List<int?> ports = await VPNService.getPortsByPrefer(true);
    late ReturnResult<HttpHeaders> result;
    for (var port in ports) {
      result = await downloadWithPort(uri, downloadPath, null, false, port);
      if (result.error == null) {
        return result;
      }
      if (result.error!.message.contains("404")) {
        return result;
      }
    }
    return result;
  }

  static Future<ReturnResult<HttpHeaders>> downloadWithPort(
    Uri uri,
    String downloadPath,
    String? useAgent,
    bool xhwid,
    int? port, {
    Duration? timeout,
  }) async {
    String downloadPathTemp = "$downloadPath.tmp";
    if (!await FileUtils.deletePath(downloadPathTemp)) {
      return ReturnResult(
        error: ReturnResultError("delete $downloadPathTemp failed"),
      );
    }

    ReturnResult<HttpHeaders> result = await HttpUtils.httpDownload(
      uri,
      downloadPathTemp,
      port,
      useAgent,
      xhwid,
      timeout,
    );

    if (result.error != null) {
      await FileUtils.deletePath(downloadPathTemp);
      return ReturnResult(error: ReturnResultError(result.error!.message));
    }
    try {
      var file = File(downloadPathTemp);
      if (await file.exists()) {
        // 备份-替换-清理：绝不"先删目标再改名"。rename 在 Windows 上会因为目标
        // 被内核/杀软/索引器持有句柄而失败，先删的话用户就只剩半截 .tmp 了。
        await FileUtils.replaceFile(downloadPath, downloadPathTemp);
      }
    } catch (err) {
      Log.w(
        "DownloadUtils.download exception ${HttpUtils.redact(uri.toString())} "
        "${err.toString()} ",
      );
      return ReturnResult(error: ReturnResultError(err.toString()));
    }
    return result;
  }
}
