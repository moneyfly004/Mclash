import 'dart:io';

import 'package:mclash/app/utils/convert_utils.dart';
import 'package:mclash/app/utils/install_referrer_utils.dart';

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
  // ==========================================================================
  //  远端配置 / 帮助链接的默认地址
  //
  //  ⚠️ 全部指向 **Mclash 自有后台**。
  //  原 Clash Mi 的默认值指向其自家服务器（`dot.clashmi.app`、`tools.karing.app`、
  //  Telegram 群、GitHub 仓库等）。本项目**不得**调用任何与业务无关的第三方域名：
  //    · 会把用户设备信息（did/语言/时区/安装来源）发往第三方；
  //    · 那些域名与本产品无关，随时可能变更或消失。
  //
  //  注意：`mconfig.json` / `mautoupdate.json` 是 Clash Mi 的私有 schema，
  //  我们后台没有对应实现。这里指向自有后台的等效端点（`/api/v1/config`、
  //  `/api/v1/software/versions`）—— schema 不同，`RemoteConfig.fromJson` 会
  //  走防御分支落到内置默认值，行为安全（不会崩，也不会拿到错误配置）。
  // ==========================================================================
  static const String kDefaultHost = "new.moneyfly.top";
  static const String kDefaultAPI = "https://$kDefaultHost/api/v1";

  static const String kDefaultConfig = "$kDefaultAPI/config";
  static const String kDefaultAutoUpdate = "$kDefaultAPI/software/versions";

  /// 套餐 / 官网（原为 Clash Mi 的服务商推广页）
  static const String kDefaultGetTranffic = "https://$kDefaultHost";

  static const String kDefaultTutorial = "https://$kDefaultHost";
  static const String kDefaultFaq = "https://$kDefaultHost";

  static const String kDefaultDownload = "https://$kDefaultHost";
  /// 在线客服（原为 Clash Mi 的 Telegram 群）
  static const String kDefaultTelegram = "https://$kDefaultHost";

  static const String kDefaultFollow = "https://github.com/moneyfly004/Mclash";
  static const String kDefaultDonate = "https://$kDefaultHost";
  /// mihomo 官方配置文档（这是上游文档，保留是正确的）
  static const String kDefaultDoc = "https://wiki.metacubex.one/config/";
  /// 原为 Clash Mi 的私有工具站 —— 置空以免外链到无关站点
  static const String kDefaultHtmlTools = "";
  static const String kDefaultConnect = "https://$kDefaultHost";

  String latestCheck = "";

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
