// ignore_for_file: empty_catches

import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:mclash/app/private/app_url_utils_private.dart';
import 'package:mclash/app/utils/app_utils.dart';
import 'package:mclash/app/utils/convert_utils.dart';
import 'package:mclash/app/utils/file_utils.dart';
import 'package:mclash/app/utils/log.dart';
import 'package:mclash/app/utils/platform_utils.dart';
import 'package:mclash/app/utils/path_utils.dart';
import 'package:mclash/i18n/strings.g.dart';
import 'package:mclash/screens/theme_define.dart';
import 'package:mclash/screens/widgets/text_field.dart';

class SettingConfigItemUI {
  String theme = ThemeDefine.kThemeLight;
  bool autoOrientation = false;
  bool disableFontScaler = false;
  bool hideAfterLaunch = false;
  bool tvMode = false;
  bool perAppHideSystemApp = true;
  bool perAppHideAppIcon = false;
  bool delayTestSort = false;
  Map<String, dynamic> toJson() => {
    'theme': theme,
    'auto_orientation': autoOrientation,
    'disable_font_scaler': disableFontScaler,
    'hide_after_launch': hideAfterLaunch,
    'tv_mode': tvMode,
    'perapp_hide_system_app': perAppHideSystemApp,
    'perapp_hide_app_icon': perAppHideAppIcon,
    'delay_test_sort': delayTestSort,
  };
  void fromJson(Map<String, dynamic>? map) {
    if (map == null) {
      return;
    }
    theme = map["theme"] ?? "";
    autoOrientation = map["auto_orientation"] ?? false;
    disableFontScaler = map["disable_font_scaler"] ?? false;
    hideAfterLaunch = map["hide_after_launch"] ?? false;
    perAppHideSystemApp = map["perapp_hide_system_app"] ?? true;
    perAppHideAppIcon = map["perapp_hide_app_icon"] ?? false;
    delayTestSort = map["delay_test_sort"] ?? false;
    if (Platform.isAndroid) {
      tvMode = map["tv_mode"] ?? false;
      TextFieldEx.popupEdit = tvMode;
    }

    switch (theme) {
      case "dark":
        theme = ThemeDefine.kThemeDark;
        break;

      case "light":
        theme = ThemeDefine.kThemeLight;
        break;

      case "system":
        theme = ThemeDefine.kThemeSystem;
        break;

      default:
        theme = ThemeDefine.kThemeLight;
        break;
    }
  }

  static SettingConfigItemUI fromJsonStatic(Map<String, dynamic>? map) {
    SettingConfigItemUI config = SettingConfigItemUI();
    config.fromJson(map);
    return config;
  }

  static Future<bool> maybeTv() async {
    if (Platform.isAndroid) {
      final deviceInfo = await DeviceInfoPlugin().deviceInfo;
      if (deviceInfo is AndroidDeviceInfo) {
        final systemFeatures = deviceInfo.systemFeatures;
        if (systemFeatures.contains("android.hardware.type.television") ||
            systemFeatures.contains("android.software.leanback")) {
          return true;
        }
      }
    }
    return false;
  }
}

class SettingConfigItemWebDev {
  String url = "";
  String user = "";
  String password = "";

  Map<String, dynamic> toJson() {
    Map<String, dynamic> ret = {'url': url, 'user': user, 'password': password};
    return ret;
  }

  void fromJson(Map<String, dynamic>? map) {
    if (map == null) {
      return;
    }
    url = map["url"] ?? "";
    user = map["user"] ?? "";
    password = map["password"] ?? "";
  }

  static SettingConfigItemWebDev fromJsonStatic(Map<String, dynamic>? map) {
    SettingConfigItemWebDev config = SettingConfigItemWebDev();
    config.fromJson(map);
    return config;
  }
}

class SettingConfig {

  static const String kDefaultBoardUrl = "";
  static const int kDefaultBoardPort = 7066;
  static const String kDefaultDelayTestUrl =
      "https://www.gstatic.com/generate_204";
  String languageTag = "";

  bool setupDone = false;
  SettingConfigItemUI ui = SettingConfigItemUI();
  SettingConfigItemWebDev webdav = SettingConfigItemWebDev();
  bool devMode = false;
  bool alwayOn = false;

  String logLevel = "info";
  String autoUpdateChannel = "stable";
  bool autoDownloadUpdatePkg = true;
  bool autoConnectAfterLaunch = false;

  /// 用户**固定**的节点名（手动选过节点或国家后记住）。
  ///
  /// 空 = 自动模式：连接后自动选延迟最低的节点。
  /// 非空 = 固定模式：每次连接都沿用这个节点；只有它探测不可用、或用户点了
  /// 「自动最优」时才改变（参考客户端 MoneyFly 的 lastSelectedTag 行为）。
  String fixedNode = "";
  bool autoSetSystemProxy = getAutoSetSystemProxyDefault();
  List<String> systemProxyBypassDomain = ProxyBypassDoaminsDefault.toList();
  String _userAgent = "";
  bool boardOnline = false;
  String boardUrl = kDefaultBoardUrl;
  int boardLocalPort = kDefaultBoardPort;
  String delayTestUrl = kDefaultDelayTestUrl;
  int delayTestTimeout = 5000;
  bool hideDockIcon = false;
  bool showTrayTraffic = false;
  bool excludeFromRecent = false;
  bool wakeLock = false;
  bool autoConnectAtBoot = false;
  bool hideVpn = false;

  /// 登录窗口的「保存账号信息」。
  ///
  /// true  → 会话落盘，下次打开软件直接自动登录；
  /// false → 会话只留在内存里，下次打开**停在登录窗口**（不自动登录）。
  /// 默认 true：与升级前的行为一致（老用户不会被突然要求重新登录）。
  bool rememberAccount = true;

  /// 上次登录用的邮箱（**只记邮箱，绝不存密码**）：不勾选保存时也预填，
  /// 用户只需再输一次密码。
  String lastAccountEmail = "";

  /// 用户点过「稍后」的更新版本号：同一个版本不再反复弹提示。
  String dismissedUpdateVersion = "";

  /// TUN 模式（虚拟网卡）开关，**默认关**。
  ///
  /// 用户要求：「默认系统代理生效，要用 TUN 就在主页给个开关」。
  /// 之前桌面端 TUN 与系统代理是**一起生效**的（`defaultTun()` 里
  /// `Enable: !Platform.isWindows`），两套数据通路同时改系统状态，退出时也难还原。
  /// Android 侧不看这个值：那里的 VpnService 本身就是 TUN，关不掉。
  bool tunMode = false;

  Map<String, dynamic> toJson() => {
    'language_tag': languageTag,
    'setup_done': setupDone,
    'ui': ui,
    'webdav': webdav,
    'alway_on': alwayOn,
    'log_level': logLevel,
    'auto_update_channel': autoUpdateChannel,
    'auto_download_udpate_pkg': autoDownloadUpdatePkg,
    'auto_connect_after_launch': autoConnectAfterLaunch,
    'fixed_node': fixedNode,
    'auto_set_system_proxy': autoSetSystemProxy,
    'system_proxy_bypass_domain': systemProxyBypassDomain,
    'user_agent': _userAgent,
    'board_online': boardOnline,
    'board_url': boardUrl,
    'board_port': boardLocalPort,
    'delay_test_url': delayTestUrl,
    'delay_test_url_timeout': delayTestTimeout,
    'hide_dock_icon': hideDockIcon,
    'show_tray_traffic': showTrayTraffic,
    'exclude_from_recent': excludeFromRecent,
    'wake_lock': wakeLock,
    'auto_connect_at_boot': autoConnectAtBoot,
    'hide_vpn': hideVpn,
    'remember_account': rememberAccount,
    'last_account_email': lastAccountEmail,
    'dismissed_update_version': dismissedUpdateVersion,
    'tun_mode': tunMode,
  };
  void fromJson(Map<String, dynamic>? map) {
    if (map == null) {
      return;
    }

    languageTag = map["language_tag"] ?? "";
    setupDone = map["setup_done"] ?? false;
    ui = SettingConfigItemUI.fromJsonStatic(map["ui"]);
    webdav = SettingConfigItemWebDev.fromJsonStatic(map["webdav"]);
    alwayOn = map["alway_on"] ?? false;
    logLevel = map["log_level"] ?? "info";
    autoUpdateChannel = map["auto_update_channel"] ?? "stable";
    if (autoUpdateChannel.isEmpty) {
      autoUpdateChannel = "stable";
    }
    autoDownloadUpdatePkg = map["auto_download_udpate_pkg"] ?? true;
    autoConnectAfterLaunch = map["auto_connect_after_launch"] ?? false;
    fixedNode = map["fixed_node"]?.toString() ?? "";
    autoSetSystemProxy =
        map["auto_set_system_proxy"] ?? getAutoSetSystemProxyDefault();
    systemProxyBypassDomain = ConvertUtils.getListStringFromDynamic(
      map["system_proxy_bypass_domain"],
      true,
      ProxyBypassDoaminsDefault.toList(),
    )!;

    _userAgent = map["user_agent"] ?? "";

    rememberAccount = map["remember_account"] ?? true;
    lastAccountEmail = map["last_account_email"]?.toString() ?? "";
    dismissedUpdateVersion =
        map["dismissed_update_version"]?.toString() ?? "";
    tunMode = map["tun_mode"] ?? false;

    boardOnline = map["board_online"] ?? false;
    boardUrl = map["board_url"] ?? kDefaultBoardUrl;
    boardLocalPort = map["board_port"] ?? kDefaultBoardPort;
    delayTestUrl = map["delay_test_url"] ?? kDefaultDelayTestUrl;
    delayTestTimeout = map["delay_test_url_timeout"] ?? 5000;
    hideDockIcon = map["hide_dock_icon"] ?? false;
    showTrayTraffic = map["show_tray_traffic"] ?? false;
    excludeFromRecent = map["exclude_from_recent"] ?? false;
    wakeLock = map["wake_lock"] ?? false;
    autoConnectAtBoot = map["auto_connect_at_boot"] ?? false;
    hideVpn = map["hide_vpn"] ?? false;
  }

  static String defaultUserAgent() {
    final version = AppUtils.getBuildinVersion();
    final coreVersion = AppUtils.getCoreVersion();
    return "${AppUtils.getName()}/$version platform/${Platform.operatingSystem} mihomo/$coreVersion";
  }

  String userAgent() {
    if (_userAgent.isEmpty) {
      return defaultUserAgent();
    }
    return _userAgent;
  }

  void setUserAgent(String ua) {
    _userAgent = ua;
  }

  static SettingConfig fromJsonStatic(Map<String, dynamic>? map) {
    SettingConfig config = SettingConfig();
    config.fromJson(map);
    return config;
  }

  /// 桌面端默认 **开启**「连接后自动设置系统代理」。
  ///
  /// 用户反馈「Windows 连上之后系统代理没变，也不知道 App 到底怎么走的代理」。
  /// 桌面 VPN 客户端的预期行为就是连接后把系统代理指到内核的混合端口
  /// （TUN 需要管理员权限，很多机器上根本起不来，这时系统代理是唯一的通路）。
  /// 默认关掉会让人以为「代理没生效」；要关的人可以在应用设置里关。
  static bool getAutoSetSystemProxyDefault() {
    if (PlatformUtils.isPC()) {
      return true;
    }
    return false;
  }
}

class SettingManager {
  static final FileSaver _fileSaver = FileSaver();
  static SettingConfig _config = SettingConfig();
  static Future<void> init({bool fromBackupRestore = false}) async {
    _fileSaver.setSavePath(await PathUtils.settingFilePath());
    await load();
    bool needSave = await parseConfig();
    if (needSave) {
      save();
    }
  }

  static Future<void> uninit() async {}
  static Future<void> reload() async {
    await load();
  }

  static Future<bool> parseConfig() async {
    bool save = false;

    String languageTag = "en";
    if (_config.languageTag.isNotEmpty) {
      for (var locale in AppLocale.values) {
        if (locale.languageTag == _config.languageTag) {
          languageTag = locale.languageTag;
          break;
        }
      }
    } else {
      String planguageTag = [
        PlatformDispatcher.instance.locale.languageCode,
        PlatformDispatcher.instance.locale.countryCode ?? "",
      ].join("-");
      for (var locale in AppLocale.values) {
        if (locale.languageTag == planguageTag) {
          languageTag = locale.languageTag;
          break;
        }
      }
    }

    if (languageTag.isEmpty) {
      languageTag = "en";
    }

    for (var locale in AppLocale.values) {
      if (languageTag == locale.languageTag) {
        save = true;
        _config.languageTag = languageTag;
        var current = LocaleSettings.currentLocale;
        if (current != locale) {
          await LocaleSettings.setLocale(locale);
        }

        break;
      }
    }

    return save;
  }

  static Future<void> load() async {
    String filePath = await PathUtils.settingFilePath();
    var file = File(filePath);
    bool exists = await file.exists();
    if (!exists) {
      _config.ui.autoOrientation = await SettingConfigItemUI.maybeTv();
      _config.ui.tvMode = _config.ui.autoOrientation;
      return;
    }
    String content = "";
    try {
      content = await file.readAsString();
      if (content.isNotEmpty) {
        var config = jsonDecode(content);
        _config.fromJson(config);
      }
    } catch (err, stacktrace) {
      Log.w("SettingManager.load exception $filePath ${err.toString()}");
    }
  }

  static void save() async {
    await _fileSaver.saveAsJson(_config);
  }

  static void reset() {
    final languageTag = _config.languageTag;
    _config = SettingConfig();
    _config.languageTag = languageTag;
  }

  static SettingConfig getConfig() {
    return _config;
  }
}
