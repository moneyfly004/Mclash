// ignore_for_file: empty_catches, no_leading_underscores_for_local_identifiers

import 'dart:convert';
import 'dart:io';

import 'package:mclash/app/local_services/vpn_service.dart';
import 'package:mclash/app/modules/remote_config.dart';
import 'package:mclash/app/modules/remote_config_manager.dart';
import 'package:mclash/app/runtime/return_result.dart';
import 'package:mclash/app/utils/app_url_utils.dart';
import 'package:mclash/app/utils/app_utils.dart';
import 'package:mclash/app/utils/http_utils.dart';
import 'package:mclash/app/utils/log.dart';
import 'package:mclash/app/utils/url_launcher_utils.dart';
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

/// 后端渠道（Xboard）能取到的最新版本号；取不到返回空串。
///
/// 两处来源：
///  · `GET /api/v1/config` → `data.client_mclash_<platform>[_arm]_url`（下载地址）；
///  · `GET /api/v1/software/versions` → `data.list[]`，每项
///    `{key, version, file_name, size, updated_at}`（**没有 url、没有 sha256**）。
///
/// 所以版本号/文件名来自 `software/versions`，下载地址来自 `/config`，两者都必须齐。
Future<String> _backendVersionOf(
  RemoteConfig rc, {
  required String platform,
  required String arch,
}) async {
  final versionsUrl = rc.autoUpdate.trim();
  if (versionsUrl.isEmpty) {
    return "";
  }
  late ReturnResult<Tuple2<int, String>> response;
  List<int?> ports = await VPNService.getPortsByPrefer(false);
  for (var port in ports) {
    response = await HttpUtils.httpGetRequest(
      versionsUrl,
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
    return "";
  }
  dynamic decoded;
  try {
    decoded = jsonDecode(response.data!.item2);
  } catch (err) {
    Log.i('AutoupdateUtils _backendVersionOf: 解析 software/versions 失败 $err');
    return "";
  }
  final parsed = MclashBackendSoftwareItem.parseList(decoded);
  final selected = MclashDownloadSources.selectBackendItem(
    parsed,
    platform: platform,
    arch: arch,
  );
  // 后端列表里没有这个平台（例如没配 android）→ 直接跳过，不硬凑别人的包。
  if (selected == null) {
    return "";
  }
  // 版本号和下载地址是两条独立通道，缺一条这个渠道就是不可用。
  final usableUrl = rc.clientMclashUrlFor(platform: platform, arch: arch);
  if (selected.item.version.isEmpty || usableUrl.isEmpty) {
    return "";
  }
  return selected.item.version;
}

/// 后端 `/config` 与 GitHub 的 `SHA256SUMS-<platform>.txt` 合起来构造的后端渠道。
///
/// sha256 一定来自 GitHub 的校验文件（按 file_name 匹配），**不信任**任何只从
/// 后端拿到的内容。取不到就留空 —— 留空时下载后不做哈希校验，但会在日志里说明。
Future<AutoupdateItem?> _backendItemIfNewer({
  required String platform,
  required String arch,
  required String fileName,
  required String sumsText,
  required String githubVersion,
  required String githubUrl,
}) async {
  final rc = RemoteConfigManager.getConfig();
  final url = rc.clientMclashUrlFor(platform: platform, arch: arch);
  if (!MclashDownloadSources.isUsableUrl(url)) {
    // 空值 / `pan://` 占位 / 非 http(s)：都算这个渠道不可用。
    Log.i(
      "AutoupdateUtils: 后端渠道不可用（${platform}/${arch} 的"
      "client_mclash_*_url 为空或不是可下载地址）",
    );
    return null;
  }
  String version;
  try {
    version = await _backendVersionOf(rc, platform: platform, arch: arch);
  } catch (e) {
    Log.i("AutoupdateUtils: 读取后端版本失败 $e");
    return null;
  }
  if (version.isEmpty) {
    return null;
  }
  // 上游 GitHub 已经更新（或一样新）就用 GitHub：它的元数据最全。
  if (githubVersion.isNotEmpty &&
      MclashUpdateCheck.compareVersions(version, githubVersion) <= 0) {
    return null;
  }
  final sha256 = MclashDownloadSources.sha256ForFileName(sumsText, fileName);
  if (sha256.isEmpty) {
    Log.w(
      "AutoupdateUtils: 后端渠道 $version 无哈希可比对"
      "（SHA256SUMS 里没有 $fileName 这一行），下载后不做 sha256 校验",
    );
  }
  Log.i(
    "AutoupdateUtils: 后端渠道有更新的版本 $version"
    "（${fileName.isEmpty ? "文件名为空" : fileName}）",
  );
  // 后端直连放最前（国内最快），失败再退到镜像，最后 GitHub 直链兜底。
  final urls = <String>[];
  for (final candidate in [
    url,
    ...MclashDownloadSources.expandedUrls(githubUrl),
  ]) {
    if (candidate.isEmpty || urls.contains(candidate)) {
      continue;
    }
    urls.add(candidate);
  }
  return AutoupdateItem()
    ..platform = platform
    ..version = version
    ..url = url
    ..urls = urls
    ..fileName = fileName
    ..sha256 = sha256
    ..channels = ["*"]
    ..updateChannel = ["stable", "beta"];
}

/// 某个平台的 GitHub 校验文件名（`SHA256SUMS-<platform>.txt`）。
///
/// macOS 按资产名区分 arm64 / universal / x64，与 `MclashUpdateCheck` 保持一致。
String _sumsAssetName(String platform, String fileName) {
  return MclashDownloadSources.sumsAssetNameFor(
    platform: platform,
    assetName: fileName,
  );
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
  /// 收集本轮可用的更新条目。
  ///
  /// 来源优先级：
  ///  1. 后端渠道**更新**时，后端条目排最前（国内直连最快）；
  ///  2. GitHub 渠道的条目（url 指向 GitHub，`urls` 里镜像在前、直链最后）；
  ///  3. GitHub 不可用时，后端渠道顶上（只要它可用）。
  static Future<List<AutoupdateItem>> collectItems() async {
    final fromGitHub = await _itemsFromGitHub();
    final platform = Platform.operatingSystem;
    final arch = MclashUpdateCheck.currentArch();
    final githubVersion = fromGitHub.isEmpty ? "" : fromGitHub.first.version;
    final fileName = fromGitHub.isEmpty ? "" : fromGitHub.first.fileName;
    final githubUrl = fromGitHub.isEmpty ? "" : fromGitHub.first.url;
    var backendUrl = "";
    try {
      backendUrl = RemoteConfigManager.getConfig().clientMclashUrlFor(
        platform: platform,
        arch: arch,
      );
    } catch (e) {
      Log.i("AutoupdateUtils: 读取后端下载地址失败 $e");
    }
    // 后端渠道根本没有可用地址时，不必白跑一趟 GitHub 去取校验文件。
    final sumsText = backendUrl.isEmpty
        ? ""
        : await _fetchSumsText(platform, fileName);
    AutoupdateItem? backend;
    try {
      backend = await _backendItemIfNewer(
        platform: platform,
        arch: arch,
        fileName: fileName,
        sumsText: sumsText,
        githubVersion: githubVersion,
        githubUrl: githubUrl,
      );
    } catch (e) {
      Log.w("AutoupdateUtils: 后端渠道构造失败 $e");
      backend = null;
    }
    final out = <AutoupdateItem>[];
    if (backend != null) {
      out.add(backend);
    }
    out.addAll(fromGitHub);
    return out;
  }

  /// 读取 GitHub 的 `SHA256SUMS-<platform>.txt`（用于给后端渠道配哈希）。
  ///
  /// 校验文件本身也从 GitHub 下载，所以同样要走镜像 —— 否则在国内取不到哈希，
  /// 后端渠道就只能"不做校验"地下载，等于白丢一层保护。
  ///
  /// 失败不抛、返回空串：没有哈希只代表"这支渠道不做校验"，
  /// 不代表"整条更新链路失败"。
  static Future<String> _fetchSumsText(String platform, String fileName) async {
    if (platform != "windows" &&
        platform != "macos" &&
        platform != "android") {
      return "";
    }
    final sumsName = _sumsAssetName(platform, fileName);
    if (sumsName.isEmpty) {
      return "";
    }
    final url = "https://github.com/${MclashUpdateCheck.repo}/releases/latest/"
        "download/$sumsName";
    List<int?> ports = const [];
    try {
      ports = await VPNService.getPortsByPrefer(true);
    } catch (e) {
      Log.i("AutoupdateUtils: 读取校验文件时取端口失败 $e");
    }
    final candidates = MclashDownloadSources.expandedUrls(url);
    for (final candidate in candidates) {
      for (final port in <int?>[null, ...ports]) {
        final result = await HttpUtils.httpGetRequest(
          candidate,
          port,
          null,
          const Duration(seconds: 10),
          null,
          null,
        );
        if (result.error != null) {
          continue;
        }
        final body = result.data?.item2 ?? "";
        if (body.isNotEmpty) {
          Log.i(
            "AutoupdateUtils: 已取到 $sumsName"
            "（${MclashDownloadSources.sourceLabel(candidate)}）",
          );
          return body;
        }
      }
    }
    Log.i("AutoupdateUtils: 读取 $sumsName 失败，后端渠道将没有哈希可比对");
    return "";
  }

  static Future<ReturnResult<List<AutoupdateItem>>> getAutoupdate(
    bool withQueryParams,
  ) async {
    final collected = await collectItems();
    if (collected.isNotEmpty) {
      return ReturnResult(data: collected);
    }

    String url = RemoteConfigManager.getConfig().autoUpdate;
    if (withQueryParams) {
      String queryParams = await AppUrlUtils.getQueryParamsForUrl(bodyLen: "1");
      url = UrlLauncherUtils.reorganizationUrl(url, queryParams) ?? url;
    }

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
    List<AutoupdateItem> items = [];
    if (response.error != null) {
      return ReturnResult(error: response.error);
    }
    try {
      if (response.data!.item2.isNotEmpty) {
        var decodedResponse = jsonDecode(response.data!.item2);
        if (decodedResponse is List) {
          for (var i in decodedResponse) {
            AutoupdateItem item = AutoupdateItem();
            item.fromJson(i);
            if (item.platform == Platform.operatingSystem) {
              items.add(item);
            }
          }
        }
      }
    } catch (err, _) {
      Log.i('AutoupdateUtils getAutoupdate exception ${err.toString()}');
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
