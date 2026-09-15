// ignore_for_file: empty_catches

import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:mclash/app/private/app_url_utils_private.dart';
import 'package:mclash/app/utils/app_utils.dart';
import 'package:mclash/app/utils/convert_utils.dart';
import 'package:mclash/app/utils/file_utils.dart';
import 'package:mclash/app/utils/log.dart';
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
  // 默认"在线面板"地址。
  // 原 Clash Mi 指向其自家的第三方面板服务（board.zash.run.place）。
  // Mclash 已按设计移除 zashboard 内嵌面板（ADR/D-01），且不外链第三方域名，
  // 因此置空 —— 「使用在线面板」开关默认关闭，用户若自建面板可自行填写。
  static const String kDefaultBoardUrl = "";
  static const int kDefaultBoardPort = 7066;
  static const String kDefaultDelayTestUrl =
      "https://www.gstatic.com/generate_204";
  String languageTag = "";

  /// 首次运行的「语言选择」步骤是否已完成。
  ///
  /// 为什么不复用 [languageTag] 判断：`parseConfig()` 在首次运行时也会
  /// **从系统语言推导并写回** languageTag（见该函数），所以它启动后永不为空，
  /// 无法用来区分「用户选过语言」和「跟随系统」。必须有独立的标记。
  ///
  /// 默认 false：全新安装先走语言选择，再进登录页。
  bool setupDone = false;
  SettingConfigItemUI ui = SettingConfigItemUI();
  SettingConfigItemWebDev webdav = SettingConfigItemWebDev();
  bool devMode = false;
  bool alwayOn = false;
  String logLevel = bool.fromEnvironment("dart.vm.product")
      ? "warning"
      : "info"; //trace, debug, info, warning, error
  String autoUpdateChannel = "stable"; //stable, beta
  bool autoDownloadUpdatePkg = true;
  bool autoConnectAfterLaunch = false;
  bool autoSetSystemProxy = getAutoSetSystemProxyDefault();
  List<String> systemProxyBypassDomain = ProxyBypassDoaminsDefault.toList();
  String _userAgent = "";
  bool boardOnline = false;
  String boardUrl = kDefaultBoardUrl;
  int boardLocalPort = kDefaultBoardPort;
  String delayTestUrl = kDefaultDelayTestUrl;
  int delayTestTimeout = 5000;
  bool hideDockIcon = false; //macos
  bool showTrayTraffic = false; //macos
  bool excludeFromRecent = false; //android
  bool wakeLock = false; //android
  bool autoConnectAtBoot = false; //android
  bool hideVpn = false; //ios

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
    logLevel =
        map["log_level"] ??
        (bool.fromEnvironment("dart.vm.product") ? "warning" : "info");
    autoUpdateChannel = map["auto_update_channel"] ?? "stable";
    if (autoUpdateChannel.isEmpty) {
      autoUpdateChannel = Random().nextInt(10) < 5 ? "beta" : "stable";
    }
    autoDownloadUpdatePkg = map["auto_download_udpate_pkg"] ?? true;
    autoConnectAfterLaunch = map["auto_connect_after_launch"] ?? false;
    autoSetSystemProxy =
        map["auto_set_system_proxy"] ?? getAutoSetSystemProxyDefault();
    systemProxyBypassDomain = ConvertUtils.getListStringFromDynamic(
      map["system_proxy_bypass_domain"],
      true,
      ProxyBypassDoaminsDefault.toList(),
    )!;

    _userAgent = map["user_agent"] ?? "";

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

  String userAgent() {
    if (_userAgent.isEmpty) {
      final coreVersion = AppUtils.getCoreVersion();
      return "ClashMeta/$coreVersion; mihomo/$coreVersion";
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
    if (Platform.isWindows) {
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
