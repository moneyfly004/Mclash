import 'dart:io';

import 'package:mclash/app/utils/convert_utils.dart';
import 'package:mclash/app/utils/install_referrer_utils.dart';
import 'package:mclash/mf/mclash_download_sources.dart';

class RemoteConfigChannel {
  String platform = "";
  String channel = "";
  String url = "";

  Map<String, dynamic> toJson() => {
    'platform': platform,
    'channel': channel,
    "url": url,
  };
  void fromJson(Map<String, dynamic>? map) {
    if (map == null) {
      return;
    }
    platform = map["platform"] ?? "";
    channel = map["channel"] ?? "";
    url = map["url"] ?? "";
  }

  static RemoteConfigChannel fromJsonStatic(Map<String, dynamic>? map) {
    RemoteConfigChannel config = RemoteConfigChannel();
    config.fromJson(map);
    return config;
  }
}

class RemoteConfigGetProfile {
  String platform = "";
  List<String> region = [];
  String url = "";

  Map<String, dynamic> toJson() => {
    'platform': platform,
    'region': region,
    'url': url,
  };
  void fromJson(Map<String, dynamic>? map) {
    if (map == null) {
      return;
    }
    platform = map["platform"] ?? "";
    region = ConvertUtils.getListStringFromDynamic(map["region"], true, [])!;
    url = map["url"] ?? "";
  }

  static RemoteConfigGetProfile fromJsonStatic(Map<String, dynamic>? map) {
    RemoteConfigGetProfile config = RemoteConfigGetProfile();
    config.fromJson(map);
    return config;
  }
}

class RemoteConfigDonate {
  String name = "";
  String url = "";
  Map<String, dynamic> toJson() => {'name': name, 'url': url};
  void fromJson(Map<String, dynamic>? map) {
    if (map == null) {
      return;
    }
    name = map["name"] ?? "";
    url = map["url"] ?? "";
  }

  static RemoteConfigDonate fromJsonStatic(Map<String, dynamic>? map) {
    RemoteConfigDonate config = RemoteConfigDonate();
    config.fromJson(map);
    return config;
  }
}

class RemoteConfig {

  static const String kDefaultHost = "new.moneyfly.top";
  static const String kDefaultAPI = "https://$kDefaultHost/api/v1";

  static const String kDefaultConfig = "$kDefaultAPI/config";
  static const String kDefaultAutoUpdate = "$kDefaultAPI/software/versions";

  static const String kDefaultGetTranffic = "https://$kDefaultHost";

  static const String kDefaultTutorial = "https://$kDefaultHost";
  static const String kDefaultFaq = "https://$kDefaultHost";

  static const String kDefaultDownload = "https://$kDefaultHost";

  static const String kDefaultTelegram = "https://$kDefaultHost";

  static const String kDefaultFollow = "https://github.com/moneyfly004/Mclash";
  static const String kDefaultDonate = "https://$kDefaultHost";

  static const String kDefaultDoc = "https://wiki.metacubex.one/config/";

  static const String kDefaultHtmlTools = "";
  static const String kDefaultConnect = "https://$kDefaultHost";

  String latestCheck = "";

  /// 更新包下载的 GitHub 加速前缀（可选）。
  ///
  /// 远程下发比发版更灵活：某个镜像挂了，后端改一行配置就能把用户切到别的镜像，
  /// 不用等新版本。**空 = 用内置默认**，绝不表示"不要镜像"。
  List<String> downloadMirrors = [];

  /// 后端 `/config` 里下发的 `client_mclash_*_url`（可选，已过滤掉 `pan://` 占位）。
  ///
  /// 取出来单独存一份，是因为 `/config` 与 `/software/versions` 是两次独立请求：
  /// 只把原始 JSON 攥在解析函数里，下一次检查更新就拿不到了。
  Map<String, String> clientMclashUrls = {};

  List<RemoteConfigGetProfile> getProfile = [];
  List<RemoteConfigChannel> channels = [];
  String host = kDefaultHost;
  String config = kDefaultConfig;
  String autoUpdate = kDefaultAutoUpdate;

  String getTranffic = kDefaultGetTranffic;
  String tutorial = kDefaultTutorial;
  String faq = kDefaultFaq;
  String download = kDefaultDownload;
  String telegram = kDefaultTelegram;
  String follow = kDefaultFollow;
  String donate = kDefaultDonate;
  String doc = kDefaultDoc;
  String htmlTools = kDefaultHtmlTools;
  String connect = kDefaultConnect;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> ret = {
      'latest_check': latestCheck,
      "get_profile": getProfile,
      "channel": channels,
    };
    if (downloadMirrors.isNotEmpty) {
      ret["download_mirrors"] = downloadMirrors;
    }
    if (getTranffic != kDefaultGetTranffic) {
      ret["get_tranffic"] = getTranffic;
    }
    if (tutorial != kDefaultTutorial) {
      ret["tutorial"] = tutorial;
    }
    if (faq != kDefaultFaq) {
      ret["faq"] = faq;
    }
    if (download != kDefaultDownload) {
      ret["download"] = download;
    }
    if (telegram != kDefaultTelegram) {
      ret["telegram"] = telegram;
    }
    if (follow != kDefaultFollow) {
      ret["follow"] = follow;
    }
    if (donate != kDefaultDonate) {
      ret["donate_url"] = donate;
    }
    if (doc != kDefaultDoc) {
      ret["doc"] = doc;
    }
    if (htmlTools != kDefaultHtmlTools) {
      ret["htmltools"] = htmlTools;
    }
    if (connect != kDefaultConnect) {
      ret["connect"] = connect;
    }

    return ret;
  }

  void fromJson(Map<String, dynamic>? map) {
    if (map == null) {
      return;
    }
    latestCheck = map["latest_check"] ?? "";

    if (map["get_profile"] != null) {
      for (var i in map["get_profile"]) {
        RemoteConfigGetProfile ch = RemoteConfigGetProfile();
        ch.fromJson(i);
        getProfile.add(ch);
      }
    }

    if (map["channel"] != null) {
      for (var i in map["channel"]) {
        RemoteConfigChannel ch = RemoteConfigChannel();
        ch.fromJson(i);
        channels.add(ch);
      }
    }

    getTranffic = map["get_tranffic"] ?? kDefaultGetTranffic;
    tutorial = map["tutorial"] ?? kDefaultTutorial;
    faq = map["faq"] ?? kDefaultFaq;
    download = map["download"] ?? kDefaultDownload;
    telegram = map["telegram"] ?? kDefaultTelegram;
    follow = map["follow"] ?? kDefaultFollow;
    donate = map["donate_url"] ?? kDefaultDonate;
    if (!isSelfHost(donate, host)) {
      donate = "";
    }
    doc = map["doc"] ?? kDefaultDoc;
    htmlTools = map["htmltools"] ?? kDefaultHtmlTools;
    connect = map["connect"] ?? kDefaultConnect;
    _parseDownloadMirrors(map["download_mirrors"]);
    _parseClientMclashUrls(map);
  }

  /// 解析可选的镜像前缀配置。容忍缺失、类型不对、内容非法 —— 一律不抛。
  ///
  /// 支持的写法：
  ///  · 数组：`"download_mirrors": ["https://ghfast.top/"]` → 替换内置列表；
  ///  · 对象：`{"mode": "append", "list": [...]}` → 追加在内置列表之后；
  ///  · 对象：`{"mode": "replace", "list": [...]}` 或未写 mode → 替换内置列表。
  ///
  /// 空列表 / 全部非法 → 保持为空（= 调用方回落内置默认），**不会**把镜像清空。
  void _parseDownloadMirrors(dynamic value) {
    dynamic node = value;
    var append = false;
    if (node is Map) {
      final mode = (node["mode"] ?? "").toString().trim().toLowerCase();
      append = mode == "append";
      node = node["list"] ?? node["mirrors"] ?? node["items"];
    }
    if (node is! List) {
      return;
    }
    final cleaned = MclashDownloadSources.sanitizeMirrors(
      node.whereType<String>().toList(),
    );
    if (cleaned.isEmpty) {
      return;
    }
    if (append) {
      for (final mirror in cleaned) {
        if (!downloadMirrors.contains(mirror)) {
          downloadMirrors.add(mirror);
        }
      }
      return;
    }
    downloadMirrors = cleaned;
  }

  /// `/config` 的 `client_mclash_*_url` 可能在 data 里，也可能在顶层，两处都收。
  void _parseClientMclashUrls(Map<String, dynamic> map) {
    final urls = <String, String>{};
    urls.addAll(MclashDownloadSources.collectConfigUrls(map));
    urls.addAll(MclashDownloadSources.collectConfigUrls(map["data"]));
    clientMclashUrls = urls;
  }

  /// 取后端 `/config` 下发的该平台下载地址。
  ///
  /// 字段名与架构的对应关系写在 [MclashDownloadSources.configUrlKeyFor] 一处，
  /// 避免「解析时用一套规则、读取时用另一套」这种对不上的老毛病。
  /// 返回空串 = 该渠道不可用（字段缺失、值是 `pan://` 占位、或者后端根本给的是空）。
  String clientMclashUrlFor({
    required String platform,
    required String arch,
  }) {
    final key = MclashDownloadSources.configUrlKeyFor(
      platform: platform,
      arch: arch,
    );
    if (key == null) {
      return "";
    }
    final value = clientMclashUrls[key] ?? "";
    return MclashDownloadSources.isUsableUrl(value) ? value.trim() : "";
  }

  static bool isSelfHost(String url, String host) {
    Uri? uri = Uri.tryParse(url);
    if (uri == null) {
      return false;
    }
    if (uri.host == host || uri.host.contains(".$host")) {
      return true;
    }
    return false;
  }

  static RemoteConfig fromJsonStatic(Map<String, dynamic>? map) {
    RemoteConfig config = RemoteConfig();
    config.fromJson(map);
    return config;
  }

  Future<RemoteConfigChannel?> getCurrentChannel() async {
    if (channels.isNotEmpty) {
      return channels[0];
    }
    String channelName = await InstallReferrerUtils.getString();
    for (var cha in channels) {
      if (cha.platform == Platform.operatingSystem &&
          cha.channel == channelName) {
        return cha;
      }
    }
    return null;
  }

  RemoteConfigGetProfile? getProfileByRegionCode(String regionCode) {
    regionCode = regionCode.toLowerCase();
    for (var item in getProfile) {
      if (item.platform == Platform.operatingSystem) {
        if (item.region.contains("*") || item.region.contains(regionCode)) {
          if (item.url.isNotEmpty) {
            return item;
          }
        }
      }
    }
    return null;
  }
}
