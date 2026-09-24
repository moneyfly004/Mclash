// ignore_for_file: empty_catches, no_leading_underscores_for_local_identifiers

import 'dart:convert';
import 'dart:io';

import 'package:mclash/app/local_services/vpn_service.dart';
import 'package:mclash/app/modules/remote_config.dart';
import 'package:mclash/app/modules/remote_config_manager.dart';
import 'package:mclash/app/runtime/return_result.dart';
import 'package:mclash/app/utils/app_utils.dart';
import 'package:mclash/app/utils/http_utils.dart';
import 'package:mclash/app/utils/log.dart';
import 'package:mclash/mf/mclash_download_sources.dart';
import 'package:mclash/mf/mclash_update_check.dart';
import 'package:tuple/tuple.dart';

Future<List<AutoupdateItem>> _itemsFromGitHub() async {
  try {
    // 先把远程下发的镜像前缀接上，再展开候选地址；用户没下发就用内置默认。
    MclashDownloadSources.applyRemoteMirrors(RemoteConfigManager.getConfig());
    final info = await MclashUpdateCheck.latest(
      currentVersion: AppUtils.getBuildinVersion(),
      proxyPorts: await VPNService.getPortsByPrefer(true),
    );
    if (info == null || info.downloadUrl.isEmpty) {
      return const [];
    }
    final item = AutoupdateItem()
      ..platform = Platform.operatingSystem
      ..version = info.version
      // url 始终是 GitHub 直链：它是 sha256 与元数据的来源，也是最后的兜底源。
      ..url = info.downloadUrl
      ..urls = MclashDownloadSources.expandedUrls(info.downloadUrl)
      ..sha256 = info.sha256
      // 后端软件列表里的文件名，用于去 GitHub 的 SHA256SUMS 里按名字取哈希。
      ..fileName = info.assetName
      ..channels = ["*"]
      ..updateChannel = ["stable", "beta"];
    Log.i(
      "MclashUpdateCheck: GitHub 上有新版本 ${info.version}"
      "（${info.assetName}${info.sizeText.isEmpty ? "" : " ${info.sizeText}"}）",
    );
    return [item];
  } catch (e) {
    Log.w("MclashUpdateCheck: 构造更新条目失败 $e");
    return const [];
  }
}


class AutoupdateItem {
  String platform = "";

  List<String> channels = [];

  List<String> abis = [];
  String version = "";

  /// 主下载地址（GitHub 直链，或后端 `/config` 里下发的地址）。
  String url = "";

  /// 候选下载地址列表（按优先级排好）。空表示"只有 [url] 一个源"。
  List<String> urls = [];

  /// 安装包文件名。后端渠道需要它去 `SHA256SUMS-*.txt` 里按名字查哈希。
  String fileName = "";
  String sha256 = "";
  List<String> updateChannel = [];

  /// 实际按优先级排好的下载地址（[urls] 为空时回落成 `[url]`）。
  List<String> candidateUrls() {
    final out = <String>[];
    for (final item in urls) {
      if (item.trim().isEmpty || out.contains(item)) {
        continue;
      }
      out.add(item);
    }
    if (out.isEmpty && url.trim().isNotEmpty) {
      out.add(url);
    }
    return out;
  }

  void fromJson(Map<String, dynamic>? map) {
    if (map == null) {
      return;
    }
    platform = map["platform"] ?? "";

    var _channels = map["channels"] ?? [];
    for (var i in _channels) {
      channels.add(i as String);
    }

    var _abis = map["abis"] ?? [];
    for (var i in _abis) {
      abis.add(i as String);
    }
    version = map["version"] ?? "";
    url = map["url"] ?? "";
    final _urls = map["urls"];
    if (_urls is List) {
      for (var i in _urls) {
        if (i is String && i.trim().isNotEmpty) {
          urls.add(i);
        }
      }
    }
    fileName = map["file_name"] ?? "";
    sha256 = map["sha256"] ?? "";
    var _versionChannel = map["version_channel"] ?? [];
    for (var i in _versionChannel) {
      updateChannel.add(i as String);
    }
  }
}

abstract final class AutoupdateUtils {
  /// 取本轮可用的更新条目。
  ///
  /// 只用 GitHub 渠道：下载地址会经镜像前缀加速（见 MclashDownloadSources），
  /// 不再向站点后端索取软件地址 —— 更新与下载完全自足于 GitHub。
  static Future<ReturnResult<List<AutoupdateItem>>> getAutoupdate(
    bool withQueryParams,
  ) async {
    final items = await _itemsFromGitHub();
    if (items.isEmpty) {
      return ReturnResult(
        error: ReturnResultError("GitHub 上没有取到可用的更新信息"),
      );
    }
    return ReturnResult(data: items);
  }

  static Future<ReturnResult<RemoteConfig>> getRemoteConfig() async {
    RemoteConfig rc = RemoteConfig();
    String url = RemoteConfigManager.getConfig().config;
    late ReturnResult<Tuple2<int, String>> response;
    List<int?> ports = await VPNService.getPortsByPrefer(true);
    for (var port in ports) {
      response = await HttpUtils.httpGetRequest(
        url,
        port,
        null,
        const Duration(seconds: 10),
        null,
        null,
      );
      if (response.error == null) {
        break;
      }
    }

    if (response.error != null) {
      return ReturnResult(error: response.error);
    }
    try {
      if (response.data!.item2.isNotEmpty) {
        var decodedResponse = jsonDecode(response.data!.item2);
        rc.fromJson(decodedResponse);
      }
    } catch (err, _) {
      Log.i('AutoupdateUtils getRemoteConfig exception ${err.toString()}');
    }
    return ReturnResult(data: rc);
  }
}
