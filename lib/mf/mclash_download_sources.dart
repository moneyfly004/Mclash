/// 「更新包从哪下」这一件事的集中实现：GitHub 加速镜像前缀 + 多源候选列表。
///
/// 背景（真机实测）：
///  · 更新检查走 `api.github.com`，国内能通（约 1.2s）；
///  · 但安装包走 `github.com/.../releases/download/...`，国内**直连不通**
///    （实测 HTTP 000，5.3s 后失败）→ 后台永远下不到包，用户只能手动去下载页。
///
/// 解决办法是「多源 + 哈希保护」：给每个 GitHub 直链配上若干加速前缀，
/// 逐个尝试，谁先成功用谁；**下载完仍然必须过 sha256 校验**，校验不过就当这个
/// 源坏了，继续试下一个。镜像只负责搬运字节，没有能力让坏包通过校验。
///
/// 本文件不依赖网络、不依赖 UI，纯逻辑部分全部可以单测。
library;

import 'package:flutter/foundation.dart';
import 'package:mclash/app/modules/remote_config.dart';
import 'package:mclash/app/utils/http_utils.dart';

/// 一个下载源的「身份」，只用于日志（用户看得懂"经哪个源下的"）。
abstract final class MclashDownloadSourceKind {
  static const String backend = "后端直连";
  static const String mirror = "镜像";
  static const String direct = "GitHub 直连";
}

/// 后端 `/api/v1/software/versions` 里的一项（**没有 url、没有 sha256**）。
class MclashBackendSoftwareItem {
  MclashBackendSoftwareItem({
    required this.key,
    required this.version,
    required this.fileName,
    this.size = 0,
    this.updatedAt = "",
  });

  final String key;
  final String version;
  final String fileName;
  final int size;
  final String updatedAt;

  /// 解析 `/software/versions` 的 `data.list[]`。
  ///
  /// 容忍：不是 Map 的项、字段缺失、字段类型不对（一律跳过或取默认值），**不抛异常**。
  static List<MclashBackendSoftwareItem> parseList(dynamic data) {
    final raw = _rawList(data);
    if (raw == null) {
      return const [];
    }
    final out = <MclashBackendSoftwareItem>[];
    for (final entry in raw) {
      if (entry is! Map) {
        continue;
      }
      final key = _asString(entry["key"]).trim();
      if (key.isEmpty) {
        continue;
      }
      out.add(
        MclashBackendSoftwareItem(
          key: key,
          version: _asString(entry["version"]).trim(),
          fileName: _asString(entry["file_name"]).trim(),
          size: _asInt(entry["size"]),
          updatedAt: _asString(entry["updated_at"]),
        ),
      );
    }
    return out;
  }

  static List<dynamic>? _rawList(dynamic data) {
    dynamic node = data;
    if (node is Map) {
      // `{code, message, data: {list: [...]}}`
      final inner = node["data"];
      if (inner is Map) {
        node = inner;
      } else if (inner is List) {
        return inner;
      }
    }
    if (node is Map) {
      final list = node["list"];
      if (list is List) {
        return list;
      }
      return null;
    }
    if (node is List) {
      return node;
    }
    return null;
  }

  static String _asString(dynamic value) {
    if (value == null) {
      return "";
    }
    if (value is String) {
      return value;
    }
    return value.toString();
  }

  static int _asInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }
}

/// 后端渠道解析结果：选中的版本信息 + 该平台可取到的下载地址。
class MclashBackendSelection {
  MclashBackendSelection({required this.item, required this.url});

  final MclashBackendSoftwareItem item;

  /// 已经是可下载的 http(s) 地址（占位值会被判成"不可用"）。
  final String url;
}

abstract final class MclashDownloadSources {
  MclashDownloadSources._();

  /// 内置 GitHub 加速前缀（实测可用，按顺序决定优先级）。
  ///
  /// 实测（HEAD 一个真实 release 资产）：
  ///  · `https://ghfast.top/`      200 / 1.66s
  ///  · `https://gh-proxy.com/`    200 / 1.69s
  ///  · `https://ghproxy.net/`     200 / 1.78s
  /// 不可用、**不要**加回来：`gh.llkk.cc`、`github.moeyy.xyz`、`ghproxy.cc`。
  static const List<String> builtinMirrors = [
    "https://ghfast.top/",
    "https://gh-proxy.com/",
    "https://ghproxy.net/",
  ];

  /// 只有 GitHub 的下载地址才值得套加速前缀。
  static const String githubHost = "github.com";

  static const String _panScheme = "pan://";

  static const int _sha256Length = 64;

  static List<String>? _mirrors;

  /// 当前生效的镜像前缀（一定非空：远程列表为空/解析失败时回落内置默认）。
  static List<String> get mirrors =>
      List<String>.unmodifiable(_mirrors ?? builtinMirrors);

  static bool get isUsingRemoteMirrors => _mirrors != null;

  /// 单测注入点：直接指定生效的镜像前缀列表。
  ///
  /// 传空列表 / null 等同于"回落内置默认"（这是刻意的：
  /// 任何"看起来像是要清空镜像"的输入都不允许把更新链路打瘸）。
  @visibleForTesting
  static void debugSetMirrors(List<String>? mirrors) {
    setRemoteMirrors(mirrors);
  }

  /// 单测注入点：恢复内置默认。
  @visibleForTesting
  static void debugReset() {
    _mirrors = null;
  }

  /// 用远程配置里的镜像列表覆盖内置列表。
  ///
  /// 约定：**远程列表为空 / 全部无效 → 回落内置默认**（`_mirrors = null`）。
  static void setRemoteMirrors(List<String>? mirrors) {
    final sanitized = sanitizeMirrors(mirrors);
    _mirrors = sanitized.isEmpty ? null : sanitized;
  }

  /// 应用 [RemoteConfig] 里下发的镜像配置。
  static void applyRemoteMirrors(RemoteConfig? config) {
    if (config == null) {
      return;
    }
    setRemoteMirrors(config.downloadMirrors);
  }

  /// 清洗镜像前缀：去空白、补 `/`、只要 http(s)、去掉重复，保持下发顺序。
  ///
  /// 任何输入都不抛异常；解析不出来的项直接丢掉。
  static List<String> sanitizeMirrors(List<String>? raw) {
    if (raw == null || raw.isEmpty) {
      return const [];
    }
    final out = <String>[];
    for (final item in raw) {
      final prefix = normalizeMirrorPrefix(item);
      if (prefix.isEmpty || out.contains(prefix)) {
        continue;
      }
      out.add(prefix);
    }
    return out;
  }

  static String normalizeMirrorPrefix(String? raw) {
    final value = (raw ?? "").trim();
    if (value.isEmpty) {
      return "";
    }
    final uri = Uri.tryParse(value);
    if (uri == null) {
      return "";
    }
    final scheme = uri.scheme.toLowerCase();
    if (scheme != "http" && scheme != "https") {
      return "";
    }
    if (uri.host.isEmpty) {
      return "";
    }
    return value.endsWith("/") ? value : "$value/";
  }

  /// 把「一个原始下载地址」展开成「按优先级排好的候选地址列表」。
  ///
  ///  · GitHub 的 `https://github.com/...` → 各镜像前缀 + 原链接；
  ///  · 其它地址（后端 `client_mclash_*_url`、用户存储、http 明文等）→ 原样单元素；
  ///  · **任何情况下都不抛异常**，解析不出来就返回原 URL。
  static List<String> expandedUrls(String originalUrl) {
    final url = (originalUrl).trim();
    if (url.isEmpty) {
      return const [];
    }
    try {
      if (!isGitHubUrl(url)) {
        return [url];
      }
      final out = <String>[];
      for (final prefix in mirrors) {
        final candidate = combine(prefix, url);
        if (candidate.isEmpty || out.contains(candidate)) {
          continue;
        }
        out.add(candidate);
      }
      if (!out.contains(url)) {
        out.add(url);
      }
      return out;
    } catch (_) {
      return [url];
    }
  }

  /// 是否值得套加速前缀的 GitHub 下载链接。
  ///
  /// 只认 `http(s)://github.com/...`（可带 `www.`），不做字符串 contains 匹配 ——
  /// 否则 `https://evil.example/github.com/x.exe` 也会被"加速"。
  static bool isGitHubUrl(String? raw) {
    final value = (raw ?? "").trim();
    if (value.isEmpty) {
      return false;
    }
    final uri = Uri.tryParse(value);
    if (uri == null) {
      return false;
    }
    final scheme = uri.scheme.toLowerCase();
    if (scheme != "http" && scheme != "https") {
      return false;
    }
    var host = uri.host.toLowerCase();
    if (host.startsWith("www.")) {
      host = host.substring(4);
    }
    return host == githubHost;
  }

  /// `前缀 + 原链接`（形如 `https://ghfast.top/https://github.com/...`）。
  static String combine(String prefix, String originalUrl) {
    final base = normalizeMirrorPrefix(prefix);
    final url = originalUrl.trim();
    if (base.isEmpty || url.isEmpty) {
      return url;
    }
    return "$base$url";
  }

  /// 判断一个下载地址是不是「可用」的，占位值一律不可用。
  ///
  /// 后端 `/config` 里的 `client_mclash_*_url` 可能是 `pan://...` 这种无意义占位
  /// （网盘协议，不是可下载的 http 地址）。把它当下载地址的后果是：每个用户都
  /// 会看到一个"下载失败"，而且失败原因完全看不懂。所以这里必须硬性拦掉。
  static bool isUsableUrl(String? raw) {
    final value = (raw ?? "").trim();
    if (value.isEmpty) {
      return false;
    }
    final lower = value.toLowerCase();
    if (lower.startsWith(_panScheme)) {
      return false;
    }
    if (value.contains("://")) {
      final uri = Uri.tryParse(value);
      if (uri == null || uri.host.isEmpty) {
        return false;
      }
      final scheme = uri.scheme.toLowerCase();
      return scheme == "http" || scheme == "https";
    }
    return false;
  }

  /// 该平台的 `client_mclash_*_url` 字段名。
  ///
  /// Windows：`client_mclash_windows_url`；
  /// macOS：arm64 用 `client_mclash_macos_arm_url`，其它架构退 `client_mclash_macos_url`；
  /// Android：`client_mclash_android_url`。
  static String? configUrlKeyFor({
    required String platform,
    required String arch,
  }) {
    switch (platform) {
      case "windows":
        return "client_mclash_windows_url";
      case "android":
        return "client_mclash_android_url";
      case "macos":
        return arch.trim().toLowerCase() == "arm64"
            ? "client_mclash_macos_arm_url"
            : "client_mclash_macos_url";
      default:
        return null;
    }
  }

  /// 该平台/架构对应的 `/software/versions` 里的 `key`。
  ///
  /// 与 `configUrlKeyFor` 一一对应：hash 用 `file_name` 去 GitHub 的
  /// `SHA256SUMS-*.txt` 里查，**不会**回落到"任意名字"。
  static String? softwareKeyFor({
    required String platform,
    required String arch,
  }) {
    switch (platform) {
      case "windows":
        return "client_mclash_windows";
      case "android":
        return "client_mclash_android";
      case "macos":
        return arch.trim().toLowerCase() == "arm64"
            ? "client_mclash_macos_arm"
            : "client_mclash_macos";
      default:
        return null;
    }
  }

  /// 从 `/config` 的响应体里取出 `client_mclash_*_url`。
  ///
  /// 结构是 `{code, message, data: {..., client_mclash_windows_url: "..."}}`。
  /// 值可能是 `pan://` 占位 —— 那种情况返回空串（= 该渠道不可用），
  /// **绝不能把 pan:// 当下载地址**。
  static String configUrlFor(
    dynamic responseBody, {
    required String platform,
    required String arch,
  }) {
    final key = configUrlKeyFor(platform: platform, arch: arch);
    if (key == null) {
      return "";
    }
    final data = _configDataMap(responseBody);
    if (data == null) {
      return "";
    }
    final value = _readString(data, key);
    return isUsableUrl(value) ? value.trim() : "";
  }

  /// 把 `/config` 响应体里所有 `client_mclash_*_url` 收集成一张表（供持久化）。
  ///
  /// 只收**可用**的 http(s) 地址，`pan://` 与空值直接不进表 —— 下游拿不到，
  /// 也就不可能被当成下载地址。
  static Map<String, String> collectConfigUrls(dynamic responseBody) {
    final data = _configDataMap(responseBody);
    if (data == null) {
      return const {};
    }
    final out = <String, String>{};
    for (final entry in data.entries) {
      final key = entry.key.toString();
      if (!key.startsWith("client_mclash_")) {
        continue;
      }
      final value = entry.value;
      if (value is! String || !isUsableUrl(value)) {
        continue;
      }
      out[key] = value.trim();
    }
    return out;
  }

  static Map<String, dynamic>? _configDataMap(dynamic responseBody) {
    dynamic node = responseBody;
    if (node is Map) {
      final data = node["data"];
      if (data is Map) {
        node = data;
      } else if (data is List && data.isNotEmpty && data.first is Map) {
        node = data.first;
      }
    }
    if (node is! Map) {
      return null;
    }
    try {
      return node.map((k, v) => MapEntry(k.toString(), v));
    } catch (_) {
      return null;
    }
  }

  static dynamic _readString(Map<String, dynamic> map, String key) {
    final direct = map[key];
    if (direct != null) {
      return direct;
    }
    // 兼容历史上出现过的 `client_` 前缀写法，少一次"后端改字段就全灭"。
    final alt = "client_$key";
    return map[alt];
  }

  /// 从后端 `/software/versions` 里挑出当前平台/架构的那一项。
  ///
  /// 拿不到对应 `key` 的条目（例如后端根本没有 android）→ 返回 null，
  /// 调用方应当直接跳过这个渠道，而不是硬凑一个别人的包下来。
  static MclashBackendSelection? selectBackendItem(
    List<MclashBackendSoftwareItem> items, {
    required String platform,
    required String arch,
  }) {
    final key = softwareKeyFor(platform: platform, arch: arch);
    if (key == null) {
      return null;
    }
    for (final item in items) {
      if (item.key == key) {
        if (item.version.isEmpty) {
          return null;
        }
        return MclashBackendSelection(item: item, url: "");
      }
    }
    return null;
  }

  /// 该平台/架构对应的 GitHub 校验文件名。
  ///
  /// 与 `MclashUpdateCheck._fetchSha256` 的选择规则保持一致（macOS 按资产名区分）。
  static String sumsAssetNameFor({
    required String platform,
    required String assetName,
  }) {
    switch (platform) {
      case "android":
        return "SHA256SUMS-android.txt";
      case "windows":
        return "SHA256SUMS-windows.txt";
      case "macos":
        if (assetName.contains("-macos-arm64-")) {
          return "SHA256SUMS-macos-arm64.txt";
        }
        if (assetName.contains("-macos-universal-")) {
          return "SHA256SUMS-macos-universal.txt";
        }
        if (assetName.contains("-macos-x64-")) {
          return "SHA256SUMS-macos-x64.txt";
        }
        return "";
      default:
        return "";
    }
  }

  /// 在 `SHA256SUMS-*.txt` 的文本里按**文件名**取 sha256。
  ///
  /// 格式形如 `<64位十六进制><空白><文件名>`。取不到 / 格式不对 → 返回空串
  /// （调用方据此"不做哈希校验"，而不是拿一个错哈希去把好包判成坏包）。
  static String sha256ForFileName(String sumsText, String fileName) {
    if (sumsText.isEmpty || fileName.isEmpty) {
      return "";
    }
    for (final line in sumsText.split("\n")) {
      if (!line.contains(fileName)) {
        continue;
      }
      final parts = line.trim().split(RegExp(r"\s+"));
      if (parts.isEmpty) {
        continue;
      }
      final hash = parts.first.toLowerCase();
      if (hash.length != _sha256Length) {
        continue;
      }
      var hex = true;
      for (final ch in hash.codeUnits) {
        final isDigit = ch >= 0x30 && ch <= 0x39; // 0-9
        final isLower = ch >= 0x61 && ch <= 0x66; // a-f
        if (!isDigit && !isLower) {
          hex = false;
          break;
        }
      }
      if (!hex) {
        continue;
      }
      return hash;
    }
    return "";
  }

  /// 下载成功后，文件哈希该和什么比。
  ///
  ///  · 有期望值（后端渠道从 `SHA256SUMS` 查到的 / GitHub 自带的）→ 必须相等；
  ///  · 没有期望值 → 放行，但如实告诉调用方"没有哈希可比对"。
  static bool hashMatches({
    required String expected,
    required String? actual,
  }) {
    if (expected.trim().isEmpty) {
      return true;
    }
    final got = (actual ?? "").trim().toLowerCase();
    if (got.isEmpty) {
      return false;
    }
    return got == expected.trim().toLowerCase();
  }

  /// 这个地址在日志里该怎么称呼（用户可见文案）。
  ///
  /// 例：`经镜像 ghfast.top 下载`、`经后端直连下载`、`GitHub 直连`。
  static String sourceLabel(String url) {
    final value = (url ?? "").trim();
    if (value.isEmpty) {
      return "未知来源";
    }
    final host = mirrorHostOf(value);
    if (host.isNotEmpty) {
      return "经镜像 $host 下载";
    }
    if (isGitHubUrl(value)) {
      return MclashDownloadSourceKind.direct;
    }
    return MclashDownloadSourceKind.backend;
  }

  /// 如果这个地址是某个镜像前缀拼出来的，返回该镜像的 host，否则空串。
  static String mirrorHostOf(String url) {
    final value = (url ?? "").trim();
    if (value.isEmpty) {
      return "";
    }
    for (final prefix in mirrors) {
      if (!value.startsWith(prefix)) {
        continue;
      }
      final uri = Uri.tryParse(prefix);
      final host = uri?.host ?? "";
      return host.isNotEmpty ? host : prefix;
    }
    return "";
  }

  /// 日志安全用的短地址（去掉 query，打码敏感参数）。
  static String redacted(String url) => HttpUtils.redact(url);
}
