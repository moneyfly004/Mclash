// ignore_for_file: empty_catches

import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
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
      "http://www.gstatic.com/generate_204";
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

  String fixedNode = "";
  bool autoSetSystemProxy = getAutoSetSystemProxyDefault();
  List<String> systemProxyBypassDomain = proxyBypassDomainsDefault.toList();
  String _userAgent = "";
  bool boardOnline = false;
  String boardUrl = kDefaultBoardUrl;
  int boardLocalPort = kDefaultBoardPort;
  String delayTestUrl = kDefaultDelayTestUrl;
  int delayTestTimeout = 5000;
  static const String kSpeedTestModeTcp = "tcp";
  static const String kSpeedTestModeKernel = "kernel";
  String speedTestMode = kSpeedTestModeTcp;
  bool hideDockIcon = false;
  bool showTrayTraffic = false;
  bool excludeFromRecent = false;
  bool wakeLock = false;
  bool autoConnectAtBoot = false;
  bool hideVpn = false;

  bool rememberAccount = true;

  String lastAccountEmail = "";

  String dismissedUpdateVersion = "";

  static const int kSettingsVersion = 5;

  int settingsVersion = 0;

  static const String kTunModeOff = "off";
  static const String kTunModeAuto = "auto";
  static const String kTunModeForce = "force";

  String tunMode = kTunModeOff;

  bool get tunEnabled =>
      tunMode == kTunModeAuto || tunMode == kTunModeForce;

  bool get tunOnly => tunMode == kTunModeForce;

  Map<String, dynamic> toJson() => {
    'settings_version': kSettingsVersion,
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
    'speed_test_mode': speedTestMode,
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
      proxyBypassDomainsDefault.toList(),
    )!;

    _userAgent = map["user_agent"] ?? "";

    rememberAccount = map["remember_account"] ?? true;
    lastAccountEmail = map["last_account_email"]?.toString() ?? "";
    dismissedUpdateVersion =
        map["dismissed_update_version"]?.toString() ?? "";
    final rawTun = map["tun_mode"];
    if (rawTun is bool) {
      tunMode = rawTun ? kTunModeAuto : kTunModeOff;
    } else {
      final text = rawTun?.toString() ?? kTunModeOff;
      tunMode = const [kTunModeAuto, kTunModeForce, kTunModeOff].contains(text)
          ? text
          : kTunModeOff;
    }
    settingsVersion = (map["settings_version"] as num?)?.toInt() ?? 0;
    _migrate();

    boardOnline = map["board_online"] ?? false;
    boardUrl = map["board_url"] ?? kDefaultBoardUrl;
    boardLocalPort = map["board_port"] ?? kDefaultBoardPort;
    delayTestUrl = map["delay_test_url"] ?? kDefaultDelayTestUrl;
    delayTestTimeout = map["delay_test_url_timeout"] ?? 5000;
    final rawSpeedMode = map["speed_test_mode"]?.toString();
    speedTestMode = rawSpeedMode == kSpeedTestModeKernel
        ? kSpeedTestModeKernel
        : kSpeedTestModeTcp;
    hideDockIcon = map["hide_dock_icon"] ?? false;
    showTrayTraffic = map["show_tray_traffic"] ?? false;
    excludeFromRecent = map["exclude_from_recent"] ?? false;
    wakeLock = map["wake_lock"] ?? false;
    autoConnectAtBoot = map["auto_connect_at_boot"] ?? false;
    hideVpn = map["hide_vpn"] ?? false;
  }

  @visibleForTesting
  static bool Function()? debugIsDesktopOverride;

  static bool get settingsIsDesktop =>
      debugIsDesktopOverride?.call() ?? PlatformUtils.isPC();

  void _migrate() {
    if (settingsVersion >= kSettingsVersion) {
      return;
    }
    if (settingsVersion < 3) {
      const legacyHttps = "https://www.gstatic.com/generate_204";
      if (delayTestUrl.trim() == legacyHttps) {
        delayTestUrl = kDefaultDelayTestUrl;
        Log.i("SettingConfig: 迁移测速地址 $legacyHttps → $kDefaultDelayTestUrl（去掉 TLS 握手，数字不再虚高）");
      }
    }
    if (settingsVersion < 4) {
      final before = systemProxyBypassDomain.length;
      systemProxyBypassDomain.removeWhere((e) => e.trim() == "<local>");
      if (systemProxyBypassDomain.length != before) {
        Log.i(
          "SettingConfig: 迁移旁路列表，去掉 <local>（会让局域网设置对话框空白）",
        );
      }
    }
    if (settingsVersion < 5) {
      final before = systemProxyBypassDomain.length;
      systemProxyBypassDomain.removeWhere((e) => e.contains("::"));
      if (systemProxyBypassDomain.length != before) {
        Log.i(
          "SettingConfig: 迁移旁路列表，去掉 IPv6 项（Windows 代理旁路不支持 IPv6）",
        );
      }
    }
    if (settingsVersion < 2) {
      if (settingsIsDesktop && !autoSetSystemProxy) {
        autoSetSystemProxy = true;
        Log.i(
          "SettingConfig: 迁移 auto_set_system_proxy=false → true"
          "（老版本的默认值，不是用户的选择）",
        );
      }
    }
    settingsVersion = kSettingsVersion;
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
