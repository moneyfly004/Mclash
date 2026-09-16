library;

import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:mclash/app/utils/log.dart';

/// 更新来源：**本项目自己的 GitHub Releases**。
///
/// 为什么不用原来的「远端配置里的更新接口」：那个接口返回的是**别的客户端**
/// （Clash Meta for Android / Clash Party…）的版本，条目里没有 `platform`/`abis`，
/// 客户端筛完是空的 —— 用户侧表现就是「永远检测不到新版本」。
///
/// 换成 GitHub Releases 之后，安装包名字本身就带平台与架构
/// （`Mclash-android-arm64-v8a-0.0.1.apk` / `Mclash-setup-0.0.1.exe` /
/// `Mclash-macos-arm64-0.0.1.dmg`），因此可以**精确挑到适合本机架构的那个包**，
/// 不会把 Intel 的包装到 Apple 芯片上（内核架构不匹配会启动即崩）。
abstract final class MclashUpdateCheck {
  MclashUpdateCheck._();

  /// 本项目仓库（发布即更新源）。
  static const String repo = "moneyfly004/Mclash";

  static const String _apiBase = "https://api.github.com";

  /// 直连不通时可用的本机代理端口（由调用方传入 `VPNService.getPortsByPrefer`）：
  /// 有些网络环境直连 GitHub 是断的，走应用自己的代理才通。
  static List<int?> _ports = const [];

  /// 测试缝：替换整段「查最新 release」逻辑（单测不打网络）。
  @visibleForTesting
  static Future<MclashUpdateInfo?> Function()? debugLatestOverride;

  /// 拉取最新 release 里属于本机平台/架构的那个安装包。
  ///
  /// [platform] 缺省用 `Platform.operatingSystem`（android / windows / macos）。
  /// [arch] 缺省用 [currentArch]。
  /// 返回 null 表示：没有 release、没有匹配的安装包、或版本不比当前新。
  static Future<MclashUpdateInfo?> latest({
    String? platform,
    String? arch,
    String currentVersion = "",
    bool includePrerelease = false,
    List<int?> proxyPorts = const [],
  }) async {
    _ports = proxyPorts;
    final override = debugLatestOverride;
    if (override != null) {
      return override();
    }
    final p = platform ?? Platform.operatingSystem;
    final a = arch ?? currentArch();
    final version = currentVersion.isEmpty ? "" : currentVersion;

    final release = await _fetchRelease(includePrerelease: includePrerelease);
    if (release == null) {
      return null;
    }
    final tag = (release["tag_name"] ?? "").toString();
    final latestVersion = normalizeVersion(tag);
    if (latestVersion.isEmpty) {
      return null;
    }
    if (version.isNotEmpty && compareVersions(latestVersion, version) <= 0) {
      Log.i("MclashUpdateCheck: 已是最新版本（本地 $version ≥ 远端 $latestVersion）");
      return null;
    }

    final assets = <Map<String, dynamic>>[
      for (final a in (release["assets"] as List? ?? const []))
        if (a is Map) a.map((k, v) => MapEntry(k.toString(), v)),
    ];
    final names = [for (final a in assets) (a["name"] ?? "").toString()];
    final picked = pickAssetName(names, platform: p, arch: a);
    if (picked == null) {
      Log.w(
        "MclashUpdateCheck: release $tag 里没有适合 $p/$a 的安装包（可选：${names.join(", ")}）",
      );
      return null;
    }
    final asset = assets.firstWhere((x) => x["name"] == picked);

    return MclashUpdateInfo(
      tag: tag,
      version: latestVersion,
      notes: (release["body"] ?? "").toString(),
      assetName: picked,
      downloadUrl: (asset["browser_download_url"] ?? "").toString(),
      assetSize: (asset["size"] as num?)?.toInt() ?? 0,
      sha256: await _fetchSha256(assets, picked, p),
    );
  }

  /// 本机架构标识（与发布产物名字里的架构段一致）。
  static String currentArch() {
    try {
      final abi = Abi.current();
      switch (abi) {
        case Abi.androidArm64:
          return "arm64-v8a";
        case Abi.androidArm:
          return "armeabi-v7a";
        case Abi.androidX64:
          return "x86_64";
        case Abi.macosArm64:
          return "arm64";
        case Abi.macosX64:
          return "x64";
        case Abi.windowsX64:
          return "x64";
        default:
          return "";
      }
    } catch (_) {
      return "";
    }
  }

  /// **纯函数**：从 release 的资产名里挑出适合 [platform] / [arch] 的安装包。
  ///
  /// 命名约定（见 release.yml）：
  ///   * android：`Mclash-android-<abi>-<ver>.apk`
  ///   * windows：`Mclash-setup-<ver>.exe`（x64）
  ///   * macos  ：`Mclash-macos-<arch>-<ver>.dmg`（arch = arm64 / x64 / universal）
  ///
  /// 挑不到就返回 null —— **绝不退而求其次挑一个架构不符的包**：
  /// 架构不符的安装包（尤其 macOS 的 Intel 版内核）装上会直接起不来。
  static String? pickAssetName(
    List<String> names, {
    required String platform,
    required String arch,
  }) {
    bool has(String n, String suffix) => n.startsWith("Mclash-") && n.endsWith(suffix);

    if (platform == "android") {
      if (arch.isEmpty) {
        return null;
      }
      for (final n in names) {
        if (has(n, ".apk") && n.contains("-android-$arch-")) {
          return n;
        }
      }
      return null;
    }
    if (platform == "windows") {
      for (final n in names) {
        if (has(n, ".exe") && n.startsWith("Mclash-setup-")) {
          return n;
        }
      }
      return null;
    }
    if (platform == "macos") {
      if (arch.isEmpty) {
        return null;
      }
      // 先精确匹配本机架构，再退到 universal（两者都能跑当前机器）
      for (final n in names) {
        if (has(n, ".dmg") && n.contains("-macos-$arch-")) {
          return n;
        }
      }
      for (final n in names) {
        if (has(n, ".dmg") && n.contains("-macos-universal-")) {
          return n;
        }
      }
      return null;
    }
    return null;
  }

  /// 版本比较：**按数值逐段比，短的一方补 0**。
  ///
  /// 不能用字符串比较：`0.0.10` 在字符串序里小于 `0.0.9`，
  /// 会导致「明明有新版本却提示已是最新」。（原来的 `VersionCompareUtils`
  /// 只在段数相同时按数值比，段数不同时退化成字符串比较。）
  static int compareVersions(String a, String b) {
    final pa = normalizeVersion(a).split(".").map(int.tryParse).toList();
    final pb = normalizeVersion(b).split(".").map(int.tryParse).toList();
    final n = pa.length > pb.length ? pa.length : pb.length;
    for (var i = 0; i < n; i++) {
      final x = i < pa.length ? (pa[i] ?? 0) : 0;
      final y = i < pb.length ? (pb[i] ?? 0) : 0;
      if (x != y) {
        return x < y ? -1 : 1;
      }
    }
    return 0;
  }

  /// `v0.0.1` / `0.0.1+1` / 空白 → `0.0.1`。
  static String normalizeVersion(String raw) {
    var v = raw.trim();
    if (v.startsWith("v") || v.startsWith("V")) {
      v = v.substring(1);
    }
    final plus = v.indexOf("+");
    if (plus >= 0) {
      v = v.substring(0, plus);
    }
    final dash = v.indexOf("-");
    if (dash >= 0) {
      v = v.substring(0, dash);
    }
    return v.trim();
  }

  /// 从 `SHA256SUMS-<platform>.txt` 里取安装包的校验值（缺失则空字符串）。
  ///
  /// 有它就顺带把「下载完整性」也校验了（`AutoUpdateManager.download()` 会用）。
  static Future<String> _fetchSha256(
    List<Map<String, dynamic>> assets,
    String assetName,
    String platform,
  ) async {
    final sumsName = switch (platform) {
      "android" => "SHA256SUMS-android.txt",
      "windows" => "SHA256SUMS-windows.txt",
      "macos" => assetName.contains("-macos-arm64-")
          ? "SHA256SUMS-macos-arm64.txt"
          : assetName.contains("-macos-universal-")
          ? "SHA256SUMS-macos-universal.txt"
          : "SHA256SUMS-macos-x64.txt",
      _ => "",
    };
    if (sumsName.isEmpty) {
      return "";
    }
    final sums = assets.firstWhere(
      (a) => a["name"] == sumsName,
      orElse: () => const {},
    );
    final url = (sums["browser_download_url"] ?? "").toString();
    if (url.isEmpty) {
      return "";
    }
    try {
      final text = await _get(url);
      for (final line in text.split("\n")) {
        if (!line.contains(assetName)) {
          continue;
        }
        final hash = line.trim().split(RegExp(r"\s+")).first;
        if (hash.length == 64) {
          return hash.toLowerCase();
        }
      }
    } catch (e) {
      Log.w("MclashUpdateCheck: 读取校验文件失败 $e");
    }
    return "";
  }

  static Future<Map<String, dynamic>?> _fetchRelease({
    required bool includePrerelease,
  }) async {
    try {
      if (!includePrerelease) {
        final body = await _get("$_apiBase/repos/$repo/releases/latest");
        final decoded = jsonDecode(body);
        if (decoded is Map) {
          return decoded.map((k, v) => MapEntry(k.toString(), v));
        }
        return null;
      }
      final body = await _get("$_apiBase/repos/$repo/releases?per_page=1");
      final decoded = jsonDecode(body);
      if (decoded is List && decoded.isNotEmpty && decoded.first is Map) {
        return (decoded.first as Map).map((k, v) => MapEntry(k.toString(), v));
      }
      return null;
    } catch (e) {
      Log.w("MclashUpdateCheck: 获取 release 失败 $e");
      return null;
    }
  }

  /// 取一个 URL：**先直连，直连失败再依次走本机代理端口**。
  static Future<String> _get(String url) async {
    Object? lastError;
    for (final port in <int?>[null, ..._ports]) {
      try {
        return await _getOnce(url, port);
      } catch (e) {
        lastError = e;
      }
    }
    throw lastError ?? "请求失败";
  }

  static Future<String> _getOnce(String url, int? proxyPort) async {
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 10);
    if (proxyPort != null && proxyPort > 0) {
      client.findProxy = (uri) => "PROXY 127.0.0.1:$proxyPort";
    }
    try {
      final req = await client
          .getUrl(Uri.parse(url))
          .timeout(const Duration(seconds: 15));
      req.headers.set(HttpHeaders.acceptHeader, "application/vnd.github+json");
      req.headers.set(HttpHeaders.userAgentHeader, "Mclash-UpdateCheck");
      final resp = await req.close().timeout(const Duration(seconds: 20));
      final body = await resp
          .transform(const SystemEncoding().decoder)
          .join()
          .timeout(const Duration(seconds: 30));
      if (resp.statusCode != 200) {
        throw "HTTP ${resp.statusCode}";
      }
      return body;
    } finally {
      client.close(force: true);
    }
  }
}

class MclashUpdateInfo {
  const MclashUpdateInfo({
    required this.tag,
    required this.version,
    required this.notes,
    required this.assetName,
    required this.downloadUrl,
    required this.assetSize,
    required this.sha256,
  });

  final String tag;

  /// 归一化后的版本（去掉 `v` 前缀），例如 `0.0.1`。
  final String version;
  final String notes;
  final String assetName;
  final String downloadUrl;
  final int assetSize;
  final String sha256;

  String get sizeText {
    if (assetSize <= 0) {
      return "";
    }
    final mb = assetSize / (1024 * 1024);
    return "${mb.toStringAsFixed(1)} MB";
  }
}
