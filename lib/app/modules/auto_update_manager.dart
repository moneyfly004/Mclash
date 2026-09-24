// ignore_for_file: unused_catch_stack, empty_catches

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:mclash/app/local_services/vpn_service.dart';
import 'package:mclash/app/modules/setting_manager.dart';
import 'package:mclash/app/runtime/return_result.dart';
import 'package:mclash/app/utils/app_lifecycle_state_notify.dart';
import 'package:mclash/app/utils/app_utils.dart';
import 'package:mclash/app/utils/auto_update_utils.dart';
import 'package:mclash/app/utils/crypto_utils.dart';
import 'package:mclash/app/utils/download_utils.dart';
import 'package:mclash/app/utils/file_utils.dart';
import 'package:mclash/app/utils/install_referrer_utils.dart';
import 'package:mclash/app/utils/log.dart';
import 'package:mclash/app/utils/path_utils.dart';
import 'package:mclash/app/utils/platform_utils.dart';
import 'package:mclash/mf/mclash_download_sources.dart';
import 'package:mclash/mf/mclash_update_check.dart';
import 'package:libclash_vpn_service/state.dart';
import 'package:path/path.dart' as path;

class AutoUpdateCheckVersion {
  String latestCheck = "";
  bool newVersion = false;
  String version = "";

  /// 主下载地址（第一个候选源）。
  String url = "";

  /// 候选下载地址（按优先级排好：后端直连 → 镜像 → GitHub 直链）。
  ///
  /// 为空表示"只有 [url] 一个源"，因此本次改动不影响老数据与老测试。
  List<String> urls = [];

  String sha256 = "";
  Map<String, dynamic> toJson() => {
    'latest_check': latestCheck,
    'new_version': newVersion,
    "version": version,
    "url": url,
    "urls": urls,
    "sha256": sha256,
  };
  void fromJson(Map<String, dynamic>? map) {
    if (map == null) {
      return;
    }
    latestCheck = map["latest_check"] ?? "";
    newVersion = map["new_version"] ?? "";
    version = map["version"] ?? "";
    url = map["url"] ?? "";
    final savedUrls = map["urls"];
    if (savedUrls is List) {
      for (var i in savedUrls) {
        if (i is String && i.trim().isNotEmpty) {
          urls.add(i);
        }
      }
    }
    sha256 = map["sha256"] ?? "";
  }

  static AutoUpdateCheckVersion fromJsonStatic(Map<String, dynamic>? map) {
    AutoUpdateCheckVersion config = AutoUpdateCheckVersion();
    config.fromJson(map);
    return config;
  }

  /// 实际可用的下载地址列表（[urls] 为空时回落成 `[url]`）。
  List<String> updateUrls() {
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

  String getExtension() {
    String ext = path.extension(url);
    if (ext.isNotEmpty && ext.length <= ".AppImage".length) {
      return ext;
    }
    if (Platform.isAndroid) {
      ext = ".apk";
    } else if (Platform.isWindows) {
      ext = ".exe";
    } else if (Platform.isMacOS) {
      ext = ".pkg";
    }
    return ext;
  }

  Future<String> getDownloadPath() async {
    String ext = getExtension();
    if (ext.isEmpty) {
      return "";
    }
    final newPath = path.join(await PathUtils.cacheDir(), version);
    return "$newPath$ext";
  }

  void clear() {
    latestCheck = "";
    newVersion = false;
    version = "";
    url = "";
    urls = [];
    sha256 = "";
  }
}

/// 一次「多源下载」尝试的结果。
///
/// [verified] 是**下载之后**的结论（包含 sha256 校验），
/// 不能在建对象时就按"有没有 sha256"定下来。
class _DownloadAttempt {
  _DownloadAttempt();

  /// 实际尝试过的下载源数量（用于「已尝试 N 个下载源」这类用户可见文案）。
  int attempted = 0;

  /// 是否有一个源返回了成功响应（不代表哈希校验通过）。
  bool downloaded = false;

  /// 是否拿到了「下载完成且校验通过（或该渠道本来就没有哈希）」的安装包。
  bool verified = false;

  /// 因为 sha256 对不上而被判为"这个源坏了"的次数。
  int corruptedSources = 0;

  /// 是否出现过 404（说明这个版本在服务端已经不存在，继续试别的源没意义）。
  bool notFound = false;

  String path = "";
  String error = "";
}

class AutoUpdateManager {
  static final List<void Function()> onEventCheck = [];

  static void addCheckListener(void Function() cb) {
    if (!onEventCheck.contains(cb)) {
      onEventCheck.add(cb);
    }
  }

  static void removeCheckListener(void Function() cb) {
    onEventCheck.remove(cb);
  }
  static Timer? _timerChecker;
  static bool _checking = false;
  static final FileSaver _fileSaver = FileSaver();
  static bool _downloading = false;
  static Duration _duration = const Duration(hours: 3);
  static DateTime? _lastCheck;
  static final AutoUpdateCheckVersion _versionCheck = AutoUpdateCheckVersion();

  static bool isSupport() {
    return Platform.isWindows || Platform.isAndroid || Platform.isMacOS;
  }

  static List<String> updateChannels() {
    return ["beta", "stable"];
  }

  static Future<void> init() async {
    _fileSaver.setSavePath(await PathUtils.autoUpdateFilePath());
    await load();
    String version = AppUtils.getBuildinVersion();

    if (MclashUpdateCheck.compareVersions(version, _versionCheck.version) >=
        0) {
      if (_versionCheck.version.isNotEmpty) {
        if (isSupport()) {
          String downloadPath = await _versionCheck.getDownloadPath();
          if (downloadPath.isNotEmpty) {
            Future.delayed(const Duration(seconds: 10), () async {
              await FileUtils.deletePath(downloadPath);
            });
          }
        }
      }

      _versionCheck.clear();

      save();
    }
    VPNService.onEventStateChanged.add((
      FlutterVpnServiceState state,
      Map<String, String> params,
    ) async {
      if (state == FlutterVpnServiceState.connected) {
        Future.delayed(const Duration(seconds: 3), () async {
          _check();
        });
      }
    });
    AppLifecycleStateNofity.onStateResumed(null, () {
      Future.delayed(const Duration(seconds: 3), () async {
        _check();
      });
    });
    Future.delayed(const Duration(seconds: 3), () async {
      _check();
    });

    if (PlatformUtils.isPC()) {
      _timerChecker = Timer.periodic(const Duration(minutes: 30), (timer) {
        _check();
      });
    }
  }

  static Future<void> uninit() async {
    _timerChecker?.cancel();
    _timerChecker = null;
  }

  static void updateChannelChanged() {
    _versionCheck.clear();
    _check();
  }

  static AutoUpdateCheckVersion getVersionCheck() {
    return _versionCheck;
  }

  @visibleForTesting
  static Future<String?> Function()? debugCheckReplaceOverride;

  static Future<void> load() async {
    String filePath = await PathUtils.autoUpdateFilePath();
    var file = File(filePath);
    bool exists = await file.exists();
    if (!exists) {
      return;
    }
    try {
      String content = await file.readAsString();
      if (content.isNotEmpty) {
        var config = jsonDecode(content);
        _versionCheck.fromJson(config);
      }
    } catch (err, stacktrace) {}
  }

  static Future<void> save() async {
    await _fileSaver.saveAsJson(_versionCheck);
  }

  static Future<MclashUpdateInfo?> checkNow() async {
    final info = await MclashUpdateCheck.latest(
      currentVersion: AppUtils.getBuildinVersion(),
      proxyPorts: await VPNService.getPortsByPrefer(true),
    );
    _versionCheck.latestCheck = DateTime.now().toString();
    if (info == null) {
      _versionCheck.newVersion = false;
      _versionCheck.version = "";
      _versionCheck.url = "";
      _versionCheck.urls = [];
      _versionCheck.sha256 = "";
      await save();
      _notify();
      return null;
    }
    _versionCheck.newVersion = true;
    _versionCheck.version = info.version;
    _versionCheck.url = info.downloadUrl;
    // 后台下载会按这个列表逐个试（镜像在前、GitHub 直链兜底）。
    _versionCheck.urls = MclashDownloadSources.expandedUrls(info.downloadUrl);
    _versionCheck.sha256 = info.sha256;
    _lastCheck = DateTime.now();
    await save();
    _notify();
    unawaited(
      download().catchError((Object e) {
        Log.w("AutoUpdateManager.checkNow: 后台预下载失败 $e");
      }),
    );
    return info;
  }

  static void _notify() {
    Future.delayed(const Duration(milliseconds: 200), () {
      for (var callback in onEventCheck) {
        callback();
      }
    });
  }

  static Future<String?> checkReplace() async {
    final override = debugCheckReplaceOverride;
    if (override != null) {
      return override();
    }
    if (!isSupport()) {
      return null;
    }
    if (_versionCheck.version.isEmpty) {
      return null;
    }
    String version = AppUtils.getBuildinVersion();
    String downloadPath = await _versionCheck.getDownloadPath();
    if (downloadPath.isEmpty) {
      return null;
    }
    if (MclashUpdateCheck.compareVersions(version, _versionCheck.version) <
        0) {
      var file = File(downloadPath);
      bool exist = await file.exists();
      if (exist) {
        await _sanitizeMacOSInstaller(downloadPath);
        return downloadPath;
      }
    }

    return null;
  }

  static Future<void> download() async {
    if (!SettingManager.getConfig().autoDownloadUpdatePkg) {
      return;
    }
    if (!isSupport()) {
      return;
    }
    if (PathUtils.portableMode()) {
      return;
    }
    if (_versionCheck.version.isEmpty || _versionCheck.url.isEmpty) {
      return;
    }
    if (_downloading) {
      return;
    }
    List<int?> ports = await VPNService.getPortsByPrefer(true);
    String version = AppUtils.getBuildinVersion();
    if (MclashUpdateCheck.compareVersions(version, _versionCheck.version) <
        0) {
      String downloadPath = await _versionCheck.getDownloadPath();
      if (downloadPath.isEmpty) {
        return;
      }
      if (await File(downloadPath).exists()) {
        return;
      }
      String dir = await PathUtils.cacheDir();
      final ext = _versionCheck.getExtension();
      if (ext.isEmpty) {
        return;
      }
      var files = FileUtils.recursionFile(dir, extensionFilter: {ext});
      for (var file in files) {
        await FileUtils.deletePath(file);
      }
      List<String> candidates = _versionCheck.updateUrls();
      final uris = <Uri>[];
      for (final candidate in candidates) {
        final parsed = Uri.tryParse(candidate);
        if (parsed != null && parsed.hasScheme) {
          uris.add(parsed);
        }
      }
      if (uris.isEmpty) {
        Log.w(
          "AutoUpdateManager.download: 没有可用的下载地址"
          "（${MclashDownloadSources.redacted(_versionCheck.url)}）",
        );
        return;
      }
      _downloading = true;
      if (_versionCheck.sha256.isEmpty) {
        Log.w(
          "AutoUpdateManager.download: 本次更新没有 sha256 可比对"
          "（该渠道无哈希可比对：${MclashDownloadSources.redacted(_versionCheck.url)}），"
          "下载后不做哈希校验",
        );
      } else {
        Log.i(
          "AutoUpdateManager.download: 将校验 sha256=${_versionCheck.sha256}"
          " path=$downloadPath",
        );
      }
      late _DownloadAttempt attempt;
      try {
        attempt = await _downloadFromCandidates(
          candidates,
          uris,
          downloadPath,
          ports,
        );
      } catch (err) {
        Log.w("AutoUpdateManager.download exception ${err.toString()}");
        attempt = _DownloadAttempt()
          ..attempted = uris.length
          ..error = "downloading failed: ${err.toString()}";
      }
      if (!attempt.verified) {
        if (attempt.corruptedSources > 0) {
          Log.w(
            "AutoUpdateManager.download: 已尝试 ${attempt.attempted} 个下载源，"
            "其中 ${attempt.corruptedSources} 个下载到的文件 sha256 校验失败"
            "（镜像被替换或缓存了坏文件），删除安装包",
          );
        } else {
          Log.w(
            "AutoUpdateManager.download: 所有下载源都失败了"
            "（已尝试 ${attempt.attempted} 个下载源）"
            "${attempt.error.isEmpty ? "" : "：${attempt.error}"}",
          );
        }
        await FileUtils.deletePath(downloadPath);
      }

      if (attempt.notFound) {
        _versionCheck.newVersion = false;
        _versionCheck.version = "";
        _versionCheck.url = "";
        _versionCheck.urls = [];
        _versionCheck.sha256 = "";

        await save();
      }
      if (attempt.verified) {
        await _sanitizeMacOSInstaller(downloadPath);
      } else {
        Log.i(
          "AutoUpdateManager.download: 本次没有取到可用的安装包"
          "（已尝试 ${attempt.attempted} 个下载源），保留原有状态",
        );
      }
      _downloading = false;
      Future.delayed(const Duration(milliseconds: 300), () async {
        for (var callback in onEventCheck) {
          callback();
        }
      });
    }
  }

  /// 按候选列表逐个下载源尝试，任一"下载成功且哈希校验通过"即停。
  ///
  /// 关键点（国内直连 GitHub 是不通的，所以这条路必须能走通）：
  ///  · 后端直连 → 镜像 → GitHub 直链，按列表顺序试，谁先成用谁；
  ///  · 每个源内部仍然按 [ports] 的顺序试端口（已连接时可走内核代理）；
  ///  · 下载成功但 sha256 对不上 = 这个源坏了（镜像被替换 / 缓存了坏文件），
  ///    **删掉文件继续试下一个源**，绝不把校验失败的包留在磁盘上；
  ///  · 全部失败才返回失败，错误信息里带"已尝试 N 个源"。
  static Future<_DownloadAttempt> _downloadFromCandidates(
    List<String> candidates,
    List<Uri> uris,
    String downloadPath,
    List<int?> ports,
  ) async {
    final expected = _versionCheck.sha256.trim();
    final attempt = _DownloadAttempt()..path = downloadPath;
    final safePorts = ports.isEmpty ? <int?>[null] : ports;
    final total = candidates.length < uris.length
        ? candidates.length
        : uris.length;
    for (var i = 0; i < uris.length; i++) {
      final uri = uris[i];
      attempt.attempted = i + 1;
      final label = MclashDownloadSources.sourceLabel(uri.toString());
      final safeUrl = MclashDownloadSources.redacted(uri.toString());
      Log.i(
        "AutoUpdateManager.download: 尝试第 ${i + 1}/$total 个下载源"
        "（${label.isEmpty ? safeUrl : label}）",
      );
      ReturnResult<HttpHeaders>? result;
      for (final port in safePorts) {
        result = await DownloadUtils.downloadWithPort(
          uri,
          downloadPath,
          null,
          false,
          port,
          timeout: const Duration(minutes: 10),
        );
        if (result.error == null) {
          break;
        }
      }
      if (result == null || result.error != null) {
        attempt.error = result?.error?.message ?? "downloading failed";
        Log.w(
          "AutoUpdateManager.download: 下载源失败（$label $safeUrl）：${attempt.error}",
        );
        if (attempt.error.contains("404")) {
          // 404 说明这个版本/地址在服务端已经不存在，继续试别的源也是白费。
          attempt.notFound = true;
          break;
        }
        continue;
      }
      if (!await File(downloadPath).exists()) {
        attempt.error = "downloading failed: 下载完成但文件不存在";
        Log.w("AutoUpdateManager.download: 下载源没有产出文件（$label $safeUrl）");
        continue;
      }
      attempt.downloaded = true;
      attempt.error = "";
      if (expected.isEmpty) {
        attempt.verified = true;
        Log.w(
          "AutoUpdateManager.download: $label 下载完成，但该渠道无哈希可比对，跳过 sha256 校验",
        );
        return attempt;
      }
      final actual = (await CryptoUtils.getFileSha256(downloadPath)) ?? "";
      if (MclashDownloadSources.hashMatches(
        expected: expected,
        actual: actual,
      )) {
        attempt.verified = true;
        Log.i("AutoUpdateManager.download: $label 下载完成且 sha256 校验通过");
        return attempt;
      }
      // 校验失败：当作这个源坏了，删掉接着试下一个。
      attempt.downloaded = false;
      attempt.corruptedSources++;
      attempt.error =
          "hash verification failed: sha256 mismatch "
          "expect=$expected actual=${actual.isEmpty ? "unknown" : actual}";
      Log.w(
        "AutoUpdateManager.download: $label 下载的文件 sha256 不匹配，"
        "当作该源损坏并继续下一个源（expect=$expected actual=${actual.isEmpty ? "unknown" : actual}）",
      );
      await FileUtils.deletePath(downloadPath);
    }
    return attempt;
  }

  static Future<void> _sanitizeMacOSInstaller(String downloadPath) async {
    if (!Platform.isMacOS || downloadPath.isEmpty) {
      return;
    }
    final file = File(downloadPath);
    if (!await file.exists()) {
      return;
    }
    try {
      final clearResult = await Process.run("xattr", ["-c", downloadPath]);
      if (clearResult.exitCode == 0) {
        return;
      }
      Log.w(
        "AutoUpdateManager._sanitizeMacOSInstaller xattr -c failed, path=$downloadPath, exitCode=${clearResult.exitCode}, stderr=${clearResult.stderr.toString().trim()}",
      );

      final delQuarantine = await Process.run("xattr", [
        "-d",
        "com.apple.quarantine",
        downloadPath,
      ]);
      final delProvenance = await Process.run("xattr", [
        "-d",
        "com.apple.provenance",
        downloadPath,
      ]);
      if (delQuarantine.exitCode != 0 && delProvenance.exitCode != 0) {
        Log.w(
          "AutoUpdateManager._sanitizeMacOSInstaller fallback failed, path=$downloadPath, quarantineExit=${delQuarantine.exitCode}, provenanceExit=${delProvenance.exitCode}",
        );
      }
    } catch (err, _) {
      Log.w(
        "AutoUpdateManager._sanitizeMacOSInstaller exception ${err.toString()}",
      );
    }
  }

  static Future<void> _check() async {
    if (_checking) {
      return;
    }

    var last = DateTime.tryParse(_versionCheck.latestCheck);
    DateTime now = DateTime.now();
    if (last != null) {
      Duration dur = now.difference(last);
      if (dur.inSeconds < _duration.inSeconds) {
        await download();
        return;
      }
    }
    var autoUpdateChannel = SettingManager.getConfig().autoUpdateChannel;
    if (!updateChannels().contains(autoUpdateChannel)) {
      autoUpdateChannel = "stable";
    }
    _versionCheck.latestCheck = now.toString();
    _checking = true;
    try {
      bool body =
          _lastCheck == null ||
          DateTime.now().difference(_lastCheck!).inHours > 12;
      ReturnResult<List<AutoupdateItem>> items =
          await AutoupdateUtils.getAutoupdate(body);
      _lastCheck = DateTime.now();
      if (items.error != null) {
        _checking = false;
        _duration = const Duration(minutes: 10);
        save();
        return;
      }
      _duration = const Duration(hours: 3);
      if (items.data!.isNotEmpty) {
        final abis = VPNService.getABIs();

        String channel = await InstallReferrerUtils.getString();
        String version = AppUtils.getBuildinVersion();

        _versionCheck.newVersion = false;
        _versionCheck.version = "";
        _versionCheck.url = "";
        _versionCheck.urls = [];
        _versionCheck.sha256 = "";

        for (var item in items.data!) {
          if (item.platform != Platform.operatingSystem) {
            continue;
          }
          if (!item.updateChannel.contains(autoUpdateChannel)) {
            continue;
          }
          if (item.version.isEmpty || item.url.isEmpty) {
            continue;
          }
          if (abis.isNotEmpty && item.abis.isNotEmpty) {
            bool hasAbi = false;
            for (var abi in abis) {
              abi = abi.trim();
              if (abi.isEmpty ||
                  item.abis.contains("*") ||
                  item.abis.contains(abi)) {
                hasAbi = true;
                break;
              }
            }
            if (!hasAbi) {
              continue;
            }
          }

          if (item.channels.contains("*") || item.channels.contains(channel)) {
            if (MclashUpdateCheck.compareVersions(version, item.version) < 0) {
              _versionCheck.newVersion = true;
              _versionCheck.version = item.version;
              _versionCheck.url = item.url;
              // 候选源：后端直连 / 镜像 / GitHub 直链，按后端给的顺序原样保留。
              _versionCheck.urls = item.candidateUrls();
              _versionCheck.sha256 = item.sha256;
            }

            break;
          }
        }

        Future.delayed(const Duration(milliseconds: 300), () async {
          for (var callback in onEventCheck) {
            callback();
          }
        });
        save();
        await download();
      }
    } catch (err, _) {
      Log.w("AutoUpdateManager._check exception ${err.toString()}");
    }

    _checking = false;
    Future.delayed(_duration, () async {
      _check();
    });
  }
}
