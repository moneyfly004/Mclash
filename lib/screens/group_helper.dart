// ignore_for_file: unused_catch_stack, empty_catches

import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:mclash/app/clash/clash_config.dart';
import 'package:mclash/app/local_services/vpn_service.dart';
import 'package:mclash/app/modules/auto_update_manager.dart';
import 'package:mclash/app/modules/clash_setting_manager.dart';
import 'package:mclash/app/modules/profile_manager.dart';
import 'package:mclash/app/modules/profile_patch_manager.dart';
import 'package:mclash/app/modules/remote_config_manager.dart';
import 'package:mclash/app/modules/setting_manager.dart';
import 'package:mclash/mf/mclash_subscription_service.dart';
import 'package:mclash/app/modules/zashboard.dart';
import 'package:mclash/app/runtime/return_result.dart';
import 'package:mclash/app/utils/app_scheme_actions.dart';
import 'package:mclash/app/utils/backup_and_sync_utils.dart';
import 'package:mclash/app/utils/device_utils.dart';
import 'package:mclash/app/utils/did.dart';
import 'package:mclash/app/utils/file_utils.dart';
import 'package:mclash/app/utils/http_utils.dart';
import 'package:mclash/app/utils/log.dart';
import 'package:mclash/app/utils/network_utils.dart';
import 'package:mclash/app/utils/path_utils.dart';
import 'package:mclash/app/utils/platform_utils.dart';
import 'package:mclash/app/utils/url_launcher_utils.dart';
import 'package:mclash/i18n/strings.g.dart';
import 'package:mclash/screens/backup_and_sync_icloud_screen.dart';
import 'package:mclash/screens/backup_and_sync_lan_sync_screen.dart';
import 'package:mclash/screens/backup_and_sync_webdav_screen.dart';
import 'package:mclash/screens/backup_helper.dart';
import 'package:mclash/screens/dialog_utils.dart';
import 'package:mclash/screens/file_view_screen.dart';
import 'package:mclash/screens/group_item_creator.dart';
import 'package:mclash/screens/group_item_options.dart';
import 'package:mclash/screens/group_screen.dart';
import 'package:mclash/screens/language_settings_screen.dart';
import 'package:mclash/screens/list_add_screen.dart';
import 'package:mclash/screens/mclash_system_proxy_sheet.dart';
import 'package:mclash/screens/map_string_and_string_add_screen.dart';
import 'package:mclash/screens/perapp_android_screen.dart';
import 'package:mclash/screens/profiles_patch_board_screen.dart';
import 'package:mclash/screens/qrcode_scan_screen.dart';
import 'package:mclash/screens/rule_providers_screen.dart';
import 'package:mclash/screens/rule_templates_screen.dart';
import 'package:mclash/screens/proxygroup_templates_screen.dart';
import 'package:mclash/screens/theme_define.dart';
import 'package:mclash/screens/mclash_update_prompt.dart';
import 'package:mclash/screens/themes.dart';
import 'package:mclash/screens/webview_helper.dart';
import 'package:mclash/screens/widgets/text_field.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:libclash_vpn_service/vpn_service.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tuple/tuple.dart';
import 'package:url_launcher/url_launcher.dart';

/// 把 TUN 模式的任意输入归一到**持久化常量**（`off` / `auto` / `force`）。
///
/// 显示文案（`t.tunScreen.mode*`）只在 UI 层使用，永远不参与
/// `SettingConfig.tunMode` 的赋值与比较，避免语言切换改坏已保存的设置。
String _normalizeTunMode(String? value) =>
    value == SettingConfig.kTunModeAuto || value == SettingConfig.kTunModeForce
        ? value!
        : SettingConfig.kTunModeOff;

/// 自动更新间隔：把已保存的时长换算成 `intervalChoices` 里的稳定 key
/// （找不到对应项时返回 null，调用方退回展示文案）。
String? _intervalKeyOf(Duration? interval) {
  for (final e in MclashSubscriptionService.intervalChoices.entries) {
    if (e.value == interval) {
      return e.key;
    }
  }
  return null;
}

/// 自动更新间隔的**显示文案**（按当前语言取词）。
///
/// 显示与存储严格分离：下拉项的 key、写入值、比较值都走
/// `intervalChoices` 的 key，这里只负责上屏，语言切换不会改坏已保存的设置。
String _intervalLabel(Translations t, Duration? interval) {
  if (interval == null) {
    return t.settingItems.intervalNever;
  }
  if (interval == const Duration(minutes: 30)) {
    return t.settingItems.interval30Minutes;
  }
  if (interval == const Duration(hours: 1)) {
    return t.settingItems.interval1Hour;
  }
  if (interval == const Duration(hours: 6)) {
    return t.settingItems.interval6Hours;
  }
  if (interval == const Duration(hours: 12)) {
    return t.settingItems.interval12Hours;
  }
  if (interval == const Duration(hours: 24)) {
    return t.settingItems.interval24Hours;
  }
  if (interval == const Duration(days: 3)) {
    return t.settingItems.interval3Days;
  }
  if (interval == const Duration(days: 7)) {
    return t.settingItems.interval7Days;
  }
  // 配置档里自定义的非标准间隔：按最接近的粒度展示
  if (interval.inHours >= 24) {
    return t.settingItems.intervalDays(days: interval.inDays);
  }
  if (interval.inHours >= 1) {
    return t.settingItems.intervalHours(hours: interval.inHours);
  }
  return t.settingItems.intervalMinutes(minutes: interval.inMinutes);
}

class GroupHelper {
  static Future<void> newVersionUpdate(BuildContext context) async {
    AutoUpdateCheckVersion versionCheck = AutoUpdateManager.getVersionCheck();
    if (!versionCheck.newVersion || versionCheck.version.isEmpty) {
      return;
    }
    await MclashUpdatePrompt.installNow(
      context,
      version: versionCheck.version,
    );
  }

  static Future<void> showBackupAndSync(BuildContext context) async {
    Future<List<GroupItem>> getOptions(
      BuildContext context,
      SetStateCallback? setstate,
    ) async {
      final tcontext = Translations.of(context);

      List<GroupItemOptions> options = [
        if (Platform.isMacOS) ...[
          GroupItemOptions(
            pushOptions: GroupItemPushOptions(
              name: tcontext.meta.iCloud,
              onPush: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    settings: BackupAndSyncIcloudScreen.routeSettings(),
                    builder: (context) => const BackupAndSyncIcloudScreen(),
                  ),
                );
              },
            ),
          ),
        ],
        GroupItemOptions(
          pushOptions: GroupItemPushOptions(
            name: tcontext.meta.webdav,
            onPush: () async {
              Navigator.push(
                context,
                MaterialPageRoute(
                  settings: BackupAndSyncWebdavScreen.routeSettings(),
                  builder: (context) => const BackupAndSyncWebdavScreen(),
                ),
              );
            },
          ),
        ),
        GroupItemOptions(
          pushOptions: GroupItemPushOptions(
            name: tcontext.meta.lanSync,
            onPush: () async {
              onTapLanSync(context);
            },
          ),
        ),
        GroupItemOptions(
          pushOptions: GroupItemPushOptions(
            name: tcontext.meta.export,
            onPush: () async {
              onTapImportExport(context);
            },
          ),
        ),
      ];

      return [GroupItem(options: options)];
    }

    final tcontext = Translations.of(context);
    await Navigator.push(
      context,
      MaterialPageRoute(
        settings: GroupScreen.routeSettings("backupAndSync"),
        builder: (context) => GroupScreen(
          title: tcontext.meta.backupAndSync,
          titleBuilder: (t) => t.meta.backupAndSync,
          getOptions: getOptions,
        ),
      ),
    );
    SettingManager.save();
  }

  static Future<void> onTapLanSyncSendTo(BuildContext context) async {
    final tcontext = Translations.of(context);
    Future<List<GroupItem>> getOptions(
      BuildContext context,
      SetStateCallback? setstate,
    ) async {
      List<GroupItemOptions> options = [
        GroupItemOptions(
          pushOptions: GroupItemPushOptions(
            name: tcontext.meta.qrcode,
            onPush: () async {
              Navigator.push(
                context,
                MaterialPageRoute(
                  settings: BackupAndSyncLanSyncScreen.routeSettings(),
                  builder: (context) =>
                      BackupAndSyncLanSyncScreen(
                        title: tcontext.meta.send,
                        titleBuilder: (t) => t.meta.send,
                      ),
                ),
              );
            },
          ),
        ),
        if (PlatformUtils.isMobile()) ...[
          GroupItemOptions(
            pushOptions: GroupItemPushOptions(
              name: tcontext.meta.qrcodeScan,
              onPush: () async {
                onTapSyncByScanQRcode(context, true);
              },
            ),
          ),
        ],
      ];
      return [GroupItem(options: options)];
    }

    if (!context.mounted) {
      return;
    }
    await Navigator.push(
      context,
      MaterialPageRoute(
        settings: GroupScreen.routeSettings("send"),
        builder: (context) =>
            GroupScreen(title: tcontext.meta.send, titleBuilder: (t) => t.meta.send, getOptions: getOptions),
      ),
    );
  }

  static Future<void> onTapLanSync(BuildContext context) async {
    final tcontext = Translations.of(context);

    Future<List<GroupItem>> getOptions(
      BuildContext context,
      SetStateCallback? setstate,
    ) async {
      List<GroupItemOptions> options = [
        GroupItemOptions(
          pushOptions: GroupItemPushOptions(
            name: tcontext.meta.send,
            onPush: () async {
              onTapLanSyncSendTo(context);
            },
          ),
        ),
      ];
      return [GroupItem(options: options)];
    }

    if (!context.mounted) {
      return;
    }
    await Navigator.push(
      context,
      MaterialPageRoute(
        settings: GroupScreen.routeSettings("BackupAndSyncLanSyncScreen"),
        builder: (context) =>
            GroupScreen(title: tcontext.meta.lanSync, titleBuilder: (t) => t.meta.lanSync, getOptions: getOptions),
      ),
    );
  }

  static Future<void> syncByScanQRcode(
    BuildContext context,
    String qrcode,
    bool send,
  ) async {
    final tcontext = Translations.of(context);
    if (qrcode.isEmpty) {
      return;
    }
    Uri? uri = Uri.tryParse(qrcode);
    if (uri == null || uri.scheme != AppSchemeActions.scheme()) {
      return;
    }

    if (uri.host != AppSchemeActions.syncDownloadAction() &&
        uri.host != AppSchemeActions.syncUploadAction()) {
      return;
    }

    String ips = uri.queryParameters['ips'] ?? '';
    String port = uri.queryParameters['port'] ?? '';
    if (ips.isEmpty || port.isEmpty) {
      return;
    }

    List<String> hosts = ips.split(",");
    int targetPort = int.parse(port);
    String? targetHost;
    ReturnResult<Tuple2<int, String>>? result;

    for (String host in hosts) {
      if (host.isNotEmpty) {
        if (NetworkUtils.isIpv4(host)) {
          result = await HttpUtils.httpGetRequest(
            "http://$host:$targetPort/",
            null,
            null,
            const Duration(seconds: 3),
            null,
            null,
          );
          if (result.error == null || result.error!.message.contains("404")) {
            targetHost = host;
            break;
          }
        }
      }
    }
    if (!context.mounted) {
      return;
    }
    if (targetHost == null) {
      if (result != null && result.error != null) {
        DialogUtils.showAlertDialog(
          context,
          tcontext.targetConnectFailed(p: result.error!.message),
          showCopy: true,
          showFAQ: true,
          withVersion: true,
        );
      } else {
        DialogUtils.showAlertDialog(
          context,
          tcontext.targetConnectFailed(p: ips),
          showCopy: true,
          showFAQ: true,
          withVersion: true,
        );
      }
      return;
    }
    if (!context.mounted) {
      return;
    }

    if (uri.host == AppSchemeActions.syncDownloadAction()) {
      DialogUtils.showAlertDialog(
        context,
        tcontext.sendOrReceiveNotMatch(p: tcontext.meta.send),
        showCopy: false,
        showFAQ: true,
        withVersion: true,
      );
      return;
    } else if (uri.host == AppSchemeActions.syncUploadAction()) {
      if (!send) {
        DialogUtils.showAlertDialog(
          context,
          tcontext.sendOrReceiveNotMatch(p: tcontext.meta.send),
          showCopy: true,
          showFAQ: true,
          withVersion: true,
        );
        return;
      }
      bool? ok = await DialogUtils.showConfirmDialog(
        context,
        tcontext.meta.sendConfirm,
      );
      if (ok != true) {
        return;
      }
      String dir = await PathUtils.cacheDir();
      if (!context.mounted) {
        return;
      }
      String zipPath = path.join(dir, BackupAndSyncUtils.getZipFileName());
      ReturnResultError? error = await BackupHelper.backupToZip(
        context,
        zipPath,
      );
      if (error != null) {
        if (!context.mounted) {
          return;
        }
        DialogUtils.showAlertDialog(
          context,
          error.message,
          showCopy: true,
          showFAQ: true,
          withVersion: true,
        );
        return;
      }
      String url = "http://$targetHost:$targetPort/${uri.host}";
      ReturnResultError? err = await HttpUtils.httpUpload(
        Uri.parse(url),
        zipPath,
        null,
        null,
      );
      await FileUtils.deletePath(zipPath);
      if (!context.mounted) {
        return;
      }
      if (err != null) {
        DialogUtils.showAlertDialog(
          context,
          err.message,
          showCopy: true,
          showFAQ: true,
          withVersion: true,
        );
      } else {
        DialogUtils.showAlertDialog(context, tcontext.meta.done);
      }
    }
  }

  static Future<void> onTapSyncByScanQRcode(
    BuildContext context,
    bool send,
  ) async {
    var qrcode = await Navigator.push(
      context,
      MaterialPageRoute(
        settings: QrcodeScanScreen.routeSettings(),
        builder: (context) => const QrcodeScanScreen(),
      ),
    );
    if (!context.mounted) {
      return;
    }
    if (qrcode == null) {
      return;
    }
    if (qrcode is String) {
      await syncByScanQRcode(context, qrcode, send);
    }
  }

  static Future<void> onTapImportExport(BuildContext context) async {
    final tcontext = Translations.of(context);

    Future<List<GroupItem>> getOptions(
      BuildContext context,
      SetStateCallback? setstate,
    ) async {
      List<GroupItemOptions> options = [
        GroupItemOptions(
          pushOptions: GroupItemPushOptions(
            name: tcontext.meta.export,
            onPush: () async {
              onTapExport(context);
            },
          ),
        ),
      ];
      return [GroupItem(options: options)];
    }

    if (!context.mounted) {
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        settings: GroupScreen.routeSettings("importAndExport"),
        builder: (context) => GroupScreen(
          title: tcontext.meta.export,
          titleBuilder: (t) => t.meta.export,
          getOptions: getOptions,
        ),
      ),
    );
  }

  static Future<void> onTapPortableModeOn(BuildContext context) async {
    Directory? dir;
    bool exist = false;
    bool created = false;
    try {
      String portableProfileDir = PathUtils.profileDirForPortableMode();
      dir = Directory(portableProfileDir);
      exist = await dir.exists();
      if (!exist) {
        await dir.create(recursive: true);
        created = true;
        String profileDir = await PathUtils.profileDir();
        var fileList = Directory(profileDir).listSync(followLinks: false);
        for (var f in fileList) {
          if (f is File) {
            String ext = path.extension(f.path);
            String basename = path.basename(f.path);
            if (ext == ".log") {
              continue;
            }
            var newFilePath = path.join(portableProfileDir, basename);
            await f.copy(newFilePath);
          } else if (f is Directory) {
            String fbasename = path.basename(f.path);
            if (fbasename == "cache" || fbasename == "webviewCache") {
              continue;
            }
            final newDirPath = path.join(portableProfileDir, fbasename);
            var newDir = Directory(newDirPath);
            await newDir.create(recursive: false);
            var fileList = f.listSync(followLinks: false);
            for (var ff in fileList) {
              if (ff is File) {
                String ext = path.extension(ff.path);
                String basename = path.basename(ff.path);
                if (ext == ".log") {
                  continue;
                }
                var newFilePath = path.join(newDirPath, basename);
                await ff.copy(newFilePath);
              }
            }
          }
        }
      }
    } catch (err, stacktrace) {
      if (!exist && created) {
        await dir!.delete();
      }
      if (!context.mounted) {
        return;
      }
      DialogUtils.showAlertDialog(
        context,
        err.toString(),
        showCopy: true,
        showFAQ: true,
        withVersion: true,
      );
      return;
    }
    await VPNService.uninit();
    await ServicesBinding.instance.exitApplication(AppExitType.required);
  }

  static Future<void> onTapExport(BuildContext context) async {
    try {
      String? filePath;
      if (PlatformUtils.isMobile()) {
        String dir = await PathUtils.cacheDir();
        filePath = path.join(dir, BackupAndSyncUtils.getZipFileName());
      } else {
        filePath = await FilePicker.saveFile(
          fileName: BackupAndSyncUtils.getZipFileName(),
          lockParentWindow: true,
        );
      }

      if (filePath != null) {
        if (!context.mounted) {
          return;
        }
        ReturnResultError? error = await BackupHelper.backupToZip(
          context,
          filePath,
        );
        if (!context.mounted) {
          FileUtils.deletePath(filePath);
          return;
        }
        if (error != null) {
          DialogUtils.showAlertDialog(
            context,
            error.message,
            showCopy: true,
            showFAQ: true,
            withVersion: true,
          );
          return;
        }
        if (PlatformUtils.isMobile()) {
          try {
            final box = context.findRenderObject() as RenderBox?;
            final rect = box != null
                ? box.localToGlobal(Offset.zero) & box.size
                : null;
            await SharePlus.instance.share(
              ShareParams(files: [XFile(filePath)], sharePositionOrigin: rect),
            );
          } catch (err) {
            if (!context.mounted) {
              return;
            }
            DialogUtils.showAlertDialog(
              context,
              err.toString(),
              showCopy: true,
              showFAQ: true,
              withVersion: true,
            );
          }
        }
      }
    } catch (err, stacktrace) {
      if (!context.mounted) {
        return;
      }
      DialogUtils.showAlertDialog(
        context,
        err.toString(),
        showCopy: true,
        showFAQ: true,
        withVersion: true,
      );
    }
  }

  static Future<void> showHelp(BuildContext context) async {
    Future<List<GroupItem>> getOptions(
      BuildContext context,
      SetStateCallback? setstate,
    ) async {
      final tcontext = Translations.of(context);

      List<GroupItemOptions> options = [
        GroupItemOptions(
          pushOptions: GroupItemPushOptions(
            name: tcontext.meta.download,
            onPush: () async {
              var remoteConfig = RemoteConfigManager.getConfig();
              await UrlLauncherUtils.loadUrl(
                remoteConfig.download,
                mode: LaunchMode.externalApplication,
              );
            },
          ),
        ),
        GroupItemOptions(
          pushOptions: GroupItemPushOptions(
            name: tcontext.meta.tutorial,
            onPush: () async {
              var remoteConfig = RemoteConfigManager.getConfig();
              await WebviewHelper.loadUrl(
                context,
                remoteConfig.tutorial,
                tcontext.meta.tutorial,
              );
            },
          ),
        ),
        GroupItemOptions(
          pushOptions: GroupItemPushOptions(
            name: tcontext.meta.faq,
            onPush: () async {
              var remoteConfig = RemoteConfigManager.getConfig();
              await WebviewHelper.loadUrl(
                context,
                remoteConfig.faq,
                tcontext.meta.faq,
              );
            },
          ),
        ),
        GroupItemOptions(
          pushOptions: GroupItemPushOptions(
            name: "Telegram",
            onPush: () async {
              var remoteConfig = RemoteConfigManager.getConfig();
              await WebviewHelper.loadUrl(
                context,
                remoteConfig.telegram,
                "Telegram",
              );
            },
          ),
        ),
      ];

      List<GroupItemOptions> options1 = [
        GroupItemOptions(
          pushOptions: GroupItemPushOptions(
            name: tcontext.meta.doc,
            onPush: () async {
              var remoteConfig = RemoteConfigManager.getConfig();
              await UrlLauncherUtils.loadUrl(
                remoteConfig.doc,
                mode: LaunchMode.externalApplication,
              );
            },
          ),
        ),
        GroupItemOptions(
          pushOptions: GroupItemPushOptions(
            name: tcontext.meta.htmlTools,
            onPush: () async {
              var remoteConfig = RemoteConfigManager.getConfig();
              await UrlLauncherUtils.loadUrl(
                remoteConfig.htmlTools,
                mode: LaunchMode.externalApplication,
              );
            },
          ),
        ),
      ];
      return [GroupItem(options: options), GroupItem(options: options1)];
    }

    final tcontext = Translations.of(context);
    await Navigator.push(
      context,
      MaterialPageRoute(
        settings: GroupScreen.routeSettings("help"),
        builder: (context) =>
            GroupScreen(title: tcontext.meta.help, titleBuilder: (t) => t.meta.help, getOptions: getOptions),
      ),
    );
    SettingManager.save();
  }

  static Future<void> showAppSettings(BuildContext context) async {
    Future<List<GroupItem>> getOptions(
      BuildContext context,
      SetStateCallback? setstate,
    ) async {
      final tcontext = Translations.of(context);
      var setting = SettingManager.getConfig();
      final logLevels = ["trace", "debug", "info", "warning", "error"];
      bool disableOrientation = await DeviceUtils.disableOrientation();
      List<GroupItemOptions> options0 = [
        GroupItemOptions(
          pushOptions: GroupItemPushOptions(
            name: tcontext.meta.reset,
            onPush: () async {
              SettingManager.reset();

              Provider.of<Themes>(
                context,
                listen: false,
              ).setTheme(setting.ui.theme, true);
              TextFieldEx.popupEdit = setting.ui.tvMode;
            },
          ),
        ),
      ];
      List<GroupItemOptions> options = [
        GroupItemOptions(
          pushOptions: GroupItemPushOptions(
            name: tcontext.meta.language,
            icon: Icons.language_outlined,
            text: tcontext.locales[setting.languageTag] ?? setting.languageTag,
            textWidthPercent: 0.5,
            onPush: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  settings: LanguageSettingsScreen.routeSettings(),
                  builder: (context) => const LanguageSettingsScreen(
                    canPop: true,
                    canGoBack: true,
                  ),
                ),
              );
            },
          ),
        ),
        GroupItemOptions(
          stringPickerOptions: GroupItemStringPickerOptions(
            name: tcontext.meta.theme,
            selected: setting.ui.theme,
            strings: [
              ThemeDefine.kThemeLight,
              ThemeDefine.kThemeDark,
              ThemeDefine.kThemeSystem,
            ],
            textWidthPercent: 0.3,
            onPicker: (String? selected) async {
              if (selected == null) {
                return;
              }
              setting.ui.theme = selected;
              Provider.of<Themes>(
                context,
                listen: false,
              ).setTheme(selected, true);
            },
          ),
        ),
        if (Platform.isAndroid) ...[
          GroupItemOptions(
            switchOptions: GroupItemSwitchOptions(
              name: tcontext.meta.tvMode,
              switchValue: setting.ui.tvMode,
              onSwitch: (bool value) async {
                setting.ui.tvMode = value;
                TextFieldEx.popupEdit = setting.ui.tvMode;
              },
            ),
          ),
        ],
        if (!disableOrientation) ...[
          GroupItemOptions(
            switchOptions: GroupItemSwitchOptions(
              name: tcontext.meta.autoOrientation,
              switchValue: setting.ui.autoOrientation,
              onSwitch: (bool value) async {
                setting.ui.autoOrientation = value;
                if (value) {
                  SystemChrome.setPreferredOrientations([
                    DeviceOrientation.portraitUp,
                    DeviceOrientation.landscapeLeft,
                    DeviceOrientation.portraitDown,
                    DeviceOrientation.landscapeRight,
                  ]);
                } else {
                  SystemChrome.setPreferredOrientations([
                    DeviceOrientation.portraitUp,
                  ]);
                }
              },
            ),
          ),
        ],
        if (AutoUpdateManager.isSupport()) ...[
          GroupItemOptions(
            stringPickerOptions: GroupItemStringPickerOptions(
              name: tcontext.meta.updateChannel,
              selected: setting.autoUpdateChannel,
              strings: AutoUpdateManager.updateChannels(),
              textWidthPercent: 0.3,
              onPicker: (String? selected) async {
                if (selected == null || setting.autoUpdateChannel == selected) {
                  return;
                }
                setting.autoUpdateChannel = selected;
                AutoUpdateManager.updateChannelChanged();
              },
            ),
          ),
        ],
        if (AutoUpdateManager.isSupport()) ...[
          GroupItemOptions(
            switchOptions: GroupItemSwitchOptions(
              name: tcontext.meta.autoDownloadPkg,
              switchValue: SettingManager.getConfig().autoDownloadUpdatePkg,
              onSwitch: (bool value) async {
                setting.autoDownloadUpdatePkg = value;
              },
            ),
          ),
        ],
      ];
      List<GroupItemOptions> options01 = [
        GroupItemOptions(
          stringPickerOptions: GroupItemStringPickerOptions(
            name: tcontext.settingItems.subscriptionAutoUpdateInterval,
            // 展示层按当前语言取词；写入层仍用 intervalChoices 的 key（稳定值），
            // 语言切换不会影响已经保存的自动更新间隔。
            selected:
                _intervalKeyOf(MclashSubscriptionService.accountInterval()) ??
                _intervalLabel(
                  tcontext,
                  MclashSubscriptionService.accountInterval(),
                ),
            tupleStrings: [
              for (final e in MclashSubscriptionService.intervalChoices.entries)
                Tuple2(e.key, _intervalLabel(tcontext, e.value)),
            ],
            textWidthPercent: 0.35,
            onPicker: (String? selected) async {
              if (selected == null) {
                return;
              }
              final err = await MclashSubscriptionService.setAccountInterval(
                MclashSubscriptionService.intervalChoices[selected],
              );
              if (!context.mounted) {
                return;
              }
              if (err != null) {
                await DialogUtils.showAlertDialog(context, err);
              }
              setstate?.call();
            },
          ),
        ),
        GroupItemOptions(
          stringPickerOptions: GroupItemStringPickerOptions(
            name: tcontext.meta.logLevel,
            selected: logLevels.contains(setting.logLevel)
                ? setting.logLevel
                : logLevels.last,
            strings: logLevels,
            onPicker: (String? selected) async {
              setting.logLevel = selected ?? logLevels.last;
              Log.setLevel(setting.logLevel);
              Log.i('itest:${setting.logLevel}');
              Log.w('wtest:${setting.logLevel}');
            },
          ),
        ),
      ];
      List<GroupItemOptions> options1 = [
        GroupItemOptions(
          textFormFieldOptions: GroupItemTextFieldOptions(
            name: tcontext.meta.userAgent,
            text: setting.userAgent(),
            textWidthPercent: 0.6,
            onChanged: (String value) {
              setting.setUserAgent(value);
            },
          ),
        ),
      ];

      List<GroupItemOptions> options2 = [
        GroupItemOptions(
          stringPickerOptions: GroupItemStringPickerOptions(
            name: tcontext.settingItems.speedTestMode,
            // 选中值 = 持久化常量（tcp/kernel）；显示文案来自语言包，
            // 切换语言后这里随 build 重新取词，不再缓存中文字面量。
            selected: setting.speedTestMode == SettingConfig.kSpeedTestModeKernel
                ? SettingConfig.kSpeedTestModeKernel
                : SettingConfig.kSpeedTestModeTcp,
            tupleStrings: [
              Tuple2(
                SettingConfig.kSpeedTestModeTcp,
                tcontext.settingItems.speedTestModeTcp,
              ),
              Tuple2(
                SettingConfig.kSpeedTestModeKernel,
                tcontext.settingItems.speedTestModeKernel,
              ),
            ],
            textWidthPercent: 0.35,
            onPicker: (String? selected) async {
              if (selected == null) {
                return;
              }
              setting.speedTestMode =
                  selected == SettingConfig.kSpeedTestModeKernel
                  ? SettingConfig.kSpeedTestModeKernel
                  : SettingConfig.kSpeedTestModeTcp;
            },
          ),
        ),
        GroupItemOptions(
          textFormFieldOptions: GroupItemTextFieldOptions(
            name: tcontext.meta.delayTestUrl,
            tips: tcontext.settingItems.delayTestUrlTip,
            text: setting.delayTestUrl,
            textWidthPercent: 0.5,
            onChanged: (String value) {
              setting.delayTestUrl = value;
            },
          ),
        ),
        GroupItemOptions(
          textFormFieldOptions: GroupItemTextFieldOptions(
            name: tcontext.meta.delayTestTimeout,
            text: setting.delayTestTimeout.toString(),
            textWidthPercent: 0.3,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (String value) {
              setting.delayTestTimeout = int.tryParse(value) ?? 5000;
            },
          ),
        ),
      ];

      List<GroupItemOptions> options3 = [
        GroupItemOptions(
          switchOptions: GroupItemSwitchOptions(
            name: tcontext.meta.boardOnline,
            switchValue: setting.boardOnline,
            onSwitch: (bool value) async {
              setting.boardOnline = value;
              if (value) {
                Zashboard.stop();
              }
            },
          ),
        ),
        if (setting.boardOnline) ...[
          GroupItemOptions(
            textFormFieldOptions: GroupItemTextFieldOptions(
              name: tcontext.meta.boardOnlineUrl,
              text: setting.boardUrl,
              textWidthPercent: 0.5,
              onChanged: (String value) {
                setting.boardUrl = value;
              },
            ),
          ),
        ],
        if (!setting.boardOnline) ...[
          GroupItemOptions(
            textFormFieldOptions: GroupItemTextFieldOptions(
              name: tcontext.meta.boardLocalPort,
              text: setting.boardLocalPort.toString(),
              textWidthPercent: 0.3,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (String value) {
                setting.boardLocalPort =
                    int.tryParse(value) ?? SettingConfig.kDefaultBoardPort;
              },
            ),
          ),
        ],
      ];

      List<GroupItemOptions> options4 = [
        GroupItemOptions(
          switchOptions: GroupItemSwitchOptions(
            name: tcontext.meta.launchAtStartup,
            switchValue: await VPNService.getLaunchAtStartup(),
            onSwitch: (bool value) async {
              if (!VPNService.isRunAsAdmin()) {
                DialogUtils.showAlertDialog(
                  context,
                  tcontext.meta.launchAtStartupRunAsAdmin,
                  showCopy: true,
                  showFAQ: false,
                  withVersion: true,
                );
                return;
              }
              ReturnResultError? err = await VPNService.setLaunchAtStartup(
                value,
              );
              if (err != null) {
                if (!context.mounted) {
                  return;
                }
                DialogUtils.showAlertDialog(
                  context,
                  err.message,
                  showCopy: true,
                  showFAQ: false,
                  withVersion: true,
                );
              }
            },
          ),
        ),
      ];
      List<GroupItemOptions> options5 = [
        if (Platform.isWindows) ...[
          GroupItemOptions(
            switchOptions: GroupItemSwitchOptions(
              name: tcontext.meta.hideAfterLaunch,
              switchValue: setting.ui.hideAfterLaunch,
              onSwitch: (bool value) async {
                setting.ui.hideAfterLaunch = value;
              },
            ),
          ),
        ],
        GroupItemOptions(
          switchOptions: GroupItemSwitchOptions(
            name: tcontext.meta.autoConnectAfterLaunch,
            switchValue: setting.autoConnectAfterLaunch,
            onSwitch: (bool value) async {
              setting.autoConnectAfterLaunch = value;
            },
          ),
        ),
        if (VPNService.getSupportSystemProxy()) ...[
          GroupItemOptions(
            switchOptions: GroupItemSwitchOptions(
              name: tcontext.meta.autoSetSystemProxy,
              switchValue: setting.autoSetSystemProxy,
              onSwitch: (bool value) async {
                setting.autoSetSystemProxy = value;
              },
            ),
          ),
          GroupItemOptions(
            pushOptions: GroupItemPushOptions(
              name: tcontext.settingItems.systemProxy,
              tips: tcontext.settingItems.systemProxyTip,
              onPush: () => showMclashSystemProxySheet(context),
            ),
          ),
          GroupItemOptions(
            pushOptions: GroupItemPushOptions(
              name: tcontext.meta.bypassSystemProxy,
              onPush: !setting.autoSetSystemProxy
                  ? null
                  : () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          settings: ListAddScreen.routeSettings(
                            "systemProxyBypassDomain",
                          ),
                          builder: (context) => ListAddScreen(
                            title: tcontext.meta.bypassSystemProxy, titleBuilder: (t) => t.meta.bypassSystemProxy,
                            data: setting.systemProxyBypassDomain,
                          ),
                        ),
                      );
                    },
            ),
          ),
        ],
      ];
      List<GroupItemOptions> options6 = [
        GroupItemOptions(
          switchOptions: GroupItemSwitchOptions(
            name: tcontext.meta.portableMode,
            tips: tcontext.meta.portableModeDisableTips,
            switchValue: PathUtils.portableMode(),
            onSwitch: PathUtils.portableMode()
                ? null
                : (bool value) async {
                    if (value) {
                      onTapPortableModeOn(context);
                    }
                  },
          ),
        ),
      ];
      List<GroupItemOptions> options7 = [
        GroupItemOptions(
          switchOptions: GroupItemSwitchOptions(
            name: tcontext.meta.excludeFromRecent,
            switchValue: setting.excludeFromRecent,
            onSwitch: (bool value) async {
              setting.excludeFromRecent = value;
              final err = await FlutterVpnService.setExcludeFromRecents(value);
              if (err != null) {
                if (!context.mounted) {
                  return;
                }
                DialogUtils.showAlertDialog(
                  context,
                  err,
                  showCopy: true,
                  showFAQ: true,
                  withVersion: true,
                );
              }
            },
          ),
        ),
        GroupItemOptions(
          switchOptions: GroupItemSwitchOptions(
            name: tcontext.meta.wakeLock,
            switchValue: setting.wakeLock,
            onSwitch: (bool value) async {
              setting.wakeLock = value;
            },
          ),
        ),
        GroupItemOptions(
          switchOptions: GroupItemSwitchOptions(
            name: tcontext.meta.autoConnectAtBoot,
            switchValue: setting.autoConnectAtBoot,
            tips:
                "${tcontext.meta.reconnectTakesEffect};${tcontext.meta.autoConnectAtBootTips}",
            onSwitch: (bool value) async {
              setting.autoConnectAtBoot = value;
            },
          ),
        ),
      ];
      List<GroupItemOptions> options8 = [
        GroupItemOptions(
          switchOptions: GroupItemSwitchOptions(
            name: tcontext.meta.alwayOnVPN,
            switchValue: setting.alwayOn,
            onSwitch: (bool value) async {
              setting.alwayOn = value;
            },
          ),
        ),
      ];
      List<GroupItemOptions> options9 = [
        GroupItemOptions(
          switchOptions: GroupItemSwitchOptions(
            name: tcontext.meta.hideDockIcon,
            tips: tcontext.meta.restartTakesEffect,
            switchValue: setting.hideDockIcon,
            onSwitch: (bool value) async {
              setting.hideDockIcon = value;
            },
          ),
        ),
        GroupItemOptions(
          switchOptions: GroupItemSwitchOptions(
            name: tcontext.meta.showTrayTraffic,
            switchValue: setting.showTrayTraffic,
            onSwitch: (bool value) async {
              setting.showTrayTraffic = value;
            },
          ),
        ),
      ];

      List<GroupItem> gitems = [
        GroupItem(options: options0),
        GroupItem(options: options),
        GroupItem(options: options01),
        GroupItem(options: options1),
        GroupItem(options: options2),
        GroupItem(options: options3),
      ];
      if (Platform.isWindows) {
        gitems.add(GroupItem(options: options4));
      }
      if (PlatformUtils.isPC()) {
        gitems.add(GroupItem(options: options5));
      }
      if (Platform.isWindows) {
        gitems.add(GroupItem(options: options6));
      }
      if (Platform.isAndroid) {
        gitems.add(GroupItem(options: options7));
      }
      if (Platform.isMacOS) {
        gitems.add(GroupItem(options: options8));
      }
      if (Platform.isMacOS) {
        gitems.add(GroupItem(options: options9));
      }

      return gitems;
    }

    final tcontext = Translations.of(context);
    await Navigator.push(
      context,
      MaterialPageRoute(
        settings: GroupScreen.routeSettings("appSettings"),
        builder: (context) => GroupScreen(
          title: tcontext.meta.settingApp,
          titleBuilder: (t) => t.meta.settingApp,
          getOptions: getOptions,
        ),
      ),
    );
    SettingManager.save();
  }

  static Future<void> showClashSettings(BuildContext context) async {
    final tcontext = Translations.of(context);
    Future<List<GroupItem>> getOptions(
      BuildContext context,
      SetStateCallback? setstate,
    ) async {
      final currentPatch = ProfilePatchManager.getCurrent();
      final remark = currentPatch.getShowName(context);
      var setting = ClashSettingManager.getConfig();
      var extensions = setting.Extension!;
      final logLevels = ClashLogLevel.toList();
      final findProcessModes = ClashFindProcessMode.toList();

      final ipv6Tuple = BoolToTuple.toTupleList(context);
      final ipv6Selected = BoolToTuple.getSelectedString(context, setting.IPv6);

      final unifiedDelayTuple = BoolToTuple.toTupleList(context);
      final unifiedDelaySelected = BoolToTuple.getSelectedString(
        context,
        setting.UnifiedDelay,
      );

      final tcpConcurrentTuple = BoolToTuple.toTupleList(context);
      final tcpConcurrentSelected = BoolToTuple.getSelectedString(
        context,
        setting.TCPConcurrent,
      );

      final started = await VPNService.getStarted();

      List<GroupItemOptions> options = [
        GroupItemOptions(
          textOptions: GroupItemTextOptions(
            name: "",
            text: tcontext.meta.coreSettingTips,
            textColor: Colors.green,
            textWidthPercent: 1,
          ),
        ),
      ];
      List<GroupItemOptions> options0 = [
        GroupItemOptions(
          pushOptions: GroupItemPushOptions(
            name: tcontext.meta.reset,
            onPush: () async {
              ClashSettingManager.reset();
              ProfilePatchManager.reset();
            },
          ),
        ),
      ];

      List<GroupItemOptions> options1 = [
        GroupItemOptions(
          textFormFieldOptions: GroupItemTextFieldOptions(
            name: tcontext.meta.externalController,
            tips: "external-controller",
            text: setting.ExternalController,
            textWidthPercent: 0.5,
            onChanged: (String value) {
              setting.ExternalController = value;
            },
          ),
        ),
        GroupItemOptions(
          textOptions: GroupItemTextOptions(
            name: tcontext.meta.secret,
            tips: "secret",
            text: setting.Secret,
            textWidthPercent: 0.5,
            onPush: () async {
              try {
                await Clipboard.setData(
                  ClipboardData(text: setting.Secret ?? ""),
                );
              } catch (e) {}
            },
            onLongPress: () async {
              setting.Secret = Did.newUUID().substring(8, 24);
              setstate?.call();
            },
          ),
        ),
        GroupItemOptions(
          textFormFieldOptions: GroupItemTextFieldOptions(
            name: tcontext.meta.mixedPort,
            tips: "mixed-port",
            text: setting.MixedPort?.toString() ?? "",
            textWidthPercent: 0.5,
            hint: tcontext.meta.required,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (String value) {
              setting.MixedPort = int.tryParse(value);
            },
          ),
        ),
        GroupItemOptions(
          stringPickerOptions: GroupItemStringPickerOptions(
            name: tcontext.meta.logLevel,
            tips: "log-level",
            selected: logLevels.contains(setting.LogLevel)
                ? setting.LogLevel
                : logLevels.last,
            strings: logLevels,
            onPicker: (String? selected) async {
              setting.LogLevel = selected;
            },
          ),
        ),
        if (Platform.isAndroid) ...[
          GroupItemOptions(
            pushOptions: GroupItemPushOptions(
              name: tcontext.PerAppAndroidScreen.title,
              onPush: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    settings: PerAppAndroidScreen.routeSettings(),
                    builder: (context) => const PerAppAndroidScreen(),
                  ),
                );
              },
            ),
          ),
        ],
        GroupItemOptions(
          textFormFieldOptions: GroupItemTextFieldOptions(
            name: "Pprof Address",
            text: extensions.PprofAddr,
            hint: "127.0.0.1:4578",
            textWidthPercent: 0.5,
            onChanged: (String value) {
              extensions.PprofAddr = value;
            },
          ),
        ),
        GroupItemOptions(
          pushOptions: GroupItemPushOptions(
            name: "Pprof",
            onPush: () async {
              if (extensions.PprofAddr == null ||
                  extensions.PprofAddr!.isEmpty) {
                return;
              }
              await UrlLauncherUtils.loadUrl(
                "http://${extensions.PprofAddr}/debug/pprof/",
              );
            },
          ),
        ),
      ];

      List<GroupItemOptions> options2 = [
        GroupItemOptions(
          stringPickerOptions: GroupItemStringPickerOptions(
            name: "Unified Delay",
            tips: "unified-delay",
            selected: unifiedDelaySelected,
            tupleStrings: unifiedDelayTuple,
            onPicker: (String? selected) async {
              setting.UnifiedDelay = BoolToTuple.getSelectedKey(
                context,
                selected,
              );
            },
          ),
        ),
        GroupItemOptions(
          stringPickerOptions: GroupItemStringPickerOptions(
            name: tcontext.meta.findProcessMode,
            tips: "find-process-mode",
            selected: findProcessModes.contains(setting.FindProcessMode)
                ? setting.FindProcessMode
                : findProcessModes.first,
            strings: findProcessModes,
            onPicker: (String? selected) async {
              setting.FindProcessMode = selected;
            },
          ),
        ),
        GroupItemOptions(
          stringPickerOptions: GroupItemStringPickerOptions(
            name: "IPv6",
            tips: "ipv6\ndns.ipv6",
            selected: ipv6Selected,
            tupleStrings: ipv6Tuple,
            onPicker: (String? selected) async {
              setting.IPv6 = BoolToTuple.getSelectedKey(context, selected);
              setting.DNS?.IPv6 = setting.IPv6;
            },
          ),
        ),
        GroupItemOptions(
          pushOptions: GroupItemPushOptions(
            name: tcontext.meta.tun,
            tips: "tun",
            onPush: () async {
              showClashSettingsTUN(context);
            },
          ),
        ),
        GroupItemOptions(
          pushOptions: GroupItemPushOptions(
            name: "Geo RuleSet",
            tips: tcontext.meta.geoRulesetTips,
            onPush: () async {
              showClashSettingsGEORuleset(context);
            },
          ),
        ),
      ];
      List<GroupItemOptions> options3 = [
        GroupItemOptions(
          pushOptions: GroupItemPushOptions(
            name: tcontext.meta.diversionTemplates,
            onPush: () async {
              showClashSettingsDiversionTemplates(context);
            },
          ),
        ),
      ];
      List<GroupItemOptions> options4 = [
        GroupItemOptions(
          pushOptions: GroupItemPushOptions(
            name: tcontext.meta.overwrite,
            text: remark,
            tips: tcontext.meta.overwriteTips,
            textWidthPercent: 0.5,
            onPush: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  settings: ProfilesPatchBoardScreen.routeSettings(),
                  builder: (context) => ProfilesPatchBoardScreen(),
                ),
              );
            },
          ),
        ),
      ];
      List<GroupItem> groups = [];
      if (started) {
        groups.add(GroupItem(options: options));
      }

      groups.addAll([
        GroupItem(options: options0),
        GroupItem(options: options1),
        GroupItem(options: options2),
        GroupItem(options: options3),
        GroupItem(options: options4),
      ]);

      List<GroupItemOptions> options5 = [
        GroupItemOptions(
          stringPickerOptions: GroupItemStringPickerOptions(
            name: tcontext.meta.tcpConcurrent,
            tips: "tcp-concurrent",
            selected: tcpConcurrentSelected,
            tupleStrings: tcpConcurrentTuple,
            onPicker: (String? selected) async {
              setting.TCPConcurrent = BoolToTuple.getSelectedKey(
                context,
                selected,
              );
            },
          ),
        ),
        GroupItemOptions(
          timerIntervalPickerOptions: GroupItemTimerIntervalPickerOptions(
            name: tcontext.meta.tcpkeepAliveInterval,
            tips: "disable-keep-alive\nkeep-alive-idle\nkeep-alive-interval",
            duration: setting.DisableKeepAlive == true
                ? null
                : Duration(seconds: setting.KeepAliveInterval ?? 30),
            showDays: false,
            showHours: false,
            showSeconds: true,
            showMinutes: true,
            showDisable: true,
            onPicker: (bool canceled, Duration? duration) async {
              if (canceled) {
                return;
              }
              setting.DisableKeepAlive = duration == null;
              setting.KeepAliveIdle = duration?.inSeconds;
              setting.KeepAliveInterval = duration?.inSeconds;
            },
          ),
        ),
      ];
      List<GroupItemOptions> options6 = [
        GroupItemOptions(
          pushOptions: GroupItemPushOptions(
            name: tcontext.meta.allowLanAccess,
            onPush: () async {
              showClashSettingsLanAccess(context);
            },
          ),
        ),
      ];

      List<GroupItemOptions> options7 = [
        GroupItemOptions(
          pushOptions: GroupItemPushOptions(
            name: tcontext.meta.dns,
            tips: "dns",
            onPush: () async {
              showClashSettingsDNS(context);
            },
          ),
        ),

        GroupItemOptions(
          pushOptions: GroupItemPushOptions(
            name: tcontext.meta.ntp,
            tips: "ntp",
            onPush: () async {
              showClashSettingsNTP(context);
            },
          ),
        ),
        GroupItemOptions(
          pushOptions: GroupItemPushOptions(
            name: tcontext.meta.tls,
            tips: "tls",
            onPush: () async {
              showClashSettingsTLS(context);
            },
          ),
        ),
        GroupItemOptions(
          pushOptions: GroupItemPushOptions(
            name: tcontext.meta.sniffer,
            tips: "sniffer",
            onPush: () async {
              showClashSettingsSniffer(context);
            },
          ),
        ),
      ];
      if (currentPatch.id.isEmpty ||
          currentPatch.id == kProfilePatchBuildinOverwrite) {
        groups.addAll([
          GroupItem(options: options5),
          GroupItem(options: options6),
          GroupItem(options: options7),
        ]);
      }

      return groups;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        settings: GroupScreen.routeSettings("coreSettings"),
        builder: (context) => GroupScreen(
          title: tcontext.meta.settingCore,
          titleBuilder: (t) => t.meta.settingCore,
          getOptions: getOptions,
          onDone: (context) async {
            final profile = ProfileManager.getCurrent();
            final currentPatch = ProfilePatchManager.getCurrent();
            final result = await ClashSettingManager.getPatchContent(
              currentPatch.id,
              currentPatch.id.isEmpty ||
                  currentPatch.id == kProfilePatchBuildinOverwrite,
              profile != null && profile.overwriteRules
                  ? (profile.overwriteProxyGroups
                        ? profile.rulesForProxyGroups
                        : profile.rules)
                  : null,
              profile != null && profile.overwriteProxyGroups
                  ? profile.proxyGroups
                  : null,
              null,
            );
            if (!context.mounted) {
              return false;
            }
            if (result.error != null) {
              DialogUtils.showAlertDialog(context, result.error!.message);
              return false;
            }
            Navigator.push(
              context,
              MaterialPageRoute(
                settings: FileViewScreen.routeSettings(),
                builder: (context) => FileViewScreen(
                  title: PathUtils.serviceCorePatchFinalFileName(),
                  content: result.data!,
                ),
              ),
            );

            return false;
          },
          onDoneIcon: Icons.file_present,
        ),
      ),
    );
    ClashSettingManager.save();
    ProfilePatchManager.save();
    ProfileManager.save();
  }

  static Future<void> showClashSettingsLanAccess(BuildContext context) async {
    final tcontext = Translations.of(context);
    Future<List<GroupItem>> getOptions(
      BuildContext context,
      SetStateCallback? setstate,
    ) async {
      var setting = ClashSettingManager.getConfig();

      List<GroupItemOptions> options = [
        GroupItemOptions(
          switchOptions: GroupItemSwitchOptions(
            name: tcontext.meta.overwrite,
            switchValue: setting.AllowLan != null,
            onSwitch: (bool value) async {
              setting.AllowLan = value ? false : null;
              if (!value) {
                setting.Authentication = null;
              }
            },
          ),
        ),
        GroupItemOptions(
          switchOptions: GroupItemSwitchOptions(
            name: tcontext.meta.enable,
            tips: "allow-lan",
            switchValue: setting.AllowLan == true,
            onSwitch: setting.AllowLan == null
                ? null
                : (bool value) async {
                    setting.AllowLan = value;
                  },
          ),
        ),
        GroupItemOptions(
          textFormFieldOptions: GroupItemTextFieldOptions(
            name: tcontext.meta.authentication,
            tips: "authentication",
            text: setting.Authentication?.first,
            hint: "username:password",
            readOnly: setting.AllowLan != true,
            textWidthPercent: 0.5,
            onChanged: setting.AllowLan != true
                ? null
                : (String value) {
                    setting.Authentication = value.isEmpty ? null : [value];
                  },
          ),
        ),
      ];

      return [GroupItem(options: options)];
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        settings: GroupScreen.routeSettings("lanAccess"),
        builder: (context) => GroupScreen(
          title: tcontext.meta.allowLanAccess,
          titleBuilder: (t) => t.meta.allowLanAccess,
          getOptions: getOptions,
        ),
      ),
    );
  }

  static Future<void> showClashSettingsTUN(BuildContext context) async {
    final tcontext = Translations.of(context);
    Future<List<GroupItem>> getOptions(
      BuildContext context,
      SetStateCallback? setstate,
    ) async {
      // 每次 build 都按**当前语言**取词：既把本页注册成语言依赖（切换语言会
      // 触发本页重建），又不会把第一次取到的文案缓存下来 —— TUN 模式的下拉
      // 选项与提示文案在切换语言后立刻是新语言。
      final t = Translations.of(context);
      var setting = ClashSettingManager.getConfig();

      var tun = setting.Tun!;
      var extensions = setting.Extension!;
      final tunStacks = ClashTunStack.toList();
      List<GroupItemOptions> options = [
        GroupItemOptions(
          stringPickerOptions: GroupItemStringPickerOptions(
            name: t.settingItems.tunMode,
            tips: t.settingItems.tunModeTip,
            // 选中值 = 持久化常量（off/auto/force），显示文案来自语言包。
            // 旧的 `strings: const ["关闭","自动","强制"]` 既缓存了中文，又把
            // 显示文案当成了写入值 —— 这里彻底拆开：显示走 t.*，存储走常量。
            selected: _normalizeTunMode(SettingManager.getConfig().tunMode),
            tupleStrings: [
              Tuple2(SettingConfig.kTunModeOff, t.tunScreen.modeOff),
              Tuple2(SettingConfig.kTunModeAuto, t.tunScreen.modeAuto),
              Tuple2(SettingConfig.kTunModeForce, t.tunScreen.modeForce),
            ],
            onPicker: (String? selected) async {
              final mode = _normalizeTunMode(selected);
              SettingManager.getConfig().tunMode = mode;
              SettingManager.save();
              ClashSettingManager.syncTunSwitch();
              Log.i("核心设置: TUN 模式 → $mode");
              setstate?.call();
            },
          ),
        ),
        GroupItemOptions(
          switchOptions: GroupItemSwitchOptions(
            name: t.meta.overwrite,
            tips: t.settingItems.tunOverwriteTip,
            switchValue: tun.OverWrite,
            onSwitch: (bool value) async {
              tun.OverWrite = value;
            },
          ),
        ),
        GroupItemOptions(
          switchOptions: GroupItemSwitchOptions(
            name: t.settingItems.tunEnableByTunMode(
              enable: t.meta.enable,
            ),
            tips: "tun.enable",
            switchValue: SettingManager.getConfig().tunEnabled,
            onSwitch: null,
          ),
        ),
        GroupItemOptions(
          textFormFieldOptions: GroupItemTextFieldOptions(
            name: t.tun.inet4Address,
            text: tun.Inet4Address?.first ?? ClashSettingManager.iNet4Address,
            textWidthPercent: 0.6,
            onChanged: (String value) {
              final parts = value.split('/');
              if (parts.length != 2) {
                return;
              }
              if (!NetworkUtils.isIpv4(parts[0])) {
                return;
              }
              tun.Inet4Address = [value];
            },
          ),
        ),
        GroupItemOptions(
          stringPickerOptions: GroupItemStringPickerOptions(
            name: t.tun.stack,
            tips: "stack",
            selected: tunStacks.contains(tun.Stack)
                ? tun.Stack
                : tunStacks.first,
            strings: tunStacks,
            onPicker: tun.OverWrite != true || tun.Enable != true
                ? null
                : (String? selected) async {
                    tun.Stack = selected;
                  },
          ),
        ),
        GroupItemOptions(
          textFormFieldOptions: GroupItemTextFieldOptions(
            name: "MTU",
            text: tun.MTU?.toString() ?? "1280",
            textWidthPercent: 0.6,
            onChanged: (String value) {
              final mtu = int.tryParse(value);
              if (mtu == null || mtu <= 0) {
                return;
              }
              tun.MTU = mtu;
            },
          ),
        ),
        GroupItemOptions(
          switchOptions: GroupItemSwitchOptions(
            name: t.tun.dnsHijack,
            tips: "dns-hijack",
            switchValue: tun.DNSHijack?.isNotEmpty,
            onSwitch: tun.OverWrite != true || tun.Enable != true
                ? null
                : (bool value) async {
                    tun.DNSHijack = value
                        ? [ClashSettingManager.dnsHijack]
                        : [];
                  },
          ),
        ),
        GroupItemOptions(
          switchOptions: GroupItemSwitchOptions(
            name: t.tun.strictRoute,
            tips: "strict-route",
            switchValue: tun.StrictRoute,
            onSwitch: tun.OverWrite != true || tun.Enable != true
                ? null
                : (bool value) async {
                    tun.StrictRoute = value;
                  },
          ),
        ),
        if (Platform.isMacOS) ...[
          GroupItemOptions(
            switchOptions: GroupItemSwitchOptions(
              name: t.tun.tunDefaultRoute,
              switchValue:
                  extensions.Tun.autoRouteUseSubRangesByDefault != true,
              onSwitch: tun.OverWrite != true || tun.Enable != true
                  ? null
                  : (bool value) async {
                      extensions.Tun.autoRouteUseSubRangesByDefault = !value;
                    },
            ),
          ),
          GroupItemOptions(
            switchOptions: GroupItemSwitchOptions(
              name: "includeAllNetworks",
              tips: "macOS 10.15+",
              switchValue: extensions.Tun.includeAllNetworks,
              onSwitch: tun.OverWrite != true || tun.Enable != true
                  ? null
                  : (bool value) async {
                      extensions.Tun.includeAllNetworks = value;
                    },
            ),
          ),
          GroupItemOptions(
            switchOptions: GroupItemSwitchOptions(
              name: "excludeLocalNetworks",
              tips: "macOS 10.15+",
              switchValue: extensions.Tun.excludeLocalNetworks,
              onSwitch: tun.OverWrite != true || tun.Enable != true
                  ? null
                  : (bool value) async {
                      extensions.Tun.excludeLocalNetworks = value;
                    },
            ),
          ),
          GroupItemOptions(
            switchOptions: GroupItemSwitchOptions(
              name: "excludeCellularServices",
              tips: "macOS 13.3+",
              switchValue: extensions.Tun.excludeCellularServices,
              onSwitch: tun.OverWrite != true || tun.Enable != true
                  ? null
                  : (bool value) async {
                      extensions.Tun.excludeCellularServices = value;
                    },
            ),
          ),
          GroupItemOptions(
            switchOptions: GroupItemSwitchOptions(
              name: "excludeAPNs",
              tips: "macOS 13.3+",
              switchValue: extensions.Tun.excludeApns,
              onSwitch: tun.OverWrite != true || tun.Enable != true
                  ? null
                  : (bool value) async {
                      extensions.Tun.excludeApns = value;
                    },
            ),
          ),
          GroupItemOptions(
            switchOptions: GroupItemSwitchOptions(
              name: "excludeDeviceCommunication",
              tips: "macOS 14.4+",
              switchValue: extensions.Tun.excludeDeviceCommunication,
              onSwitch: tun.OverWrite != true || tun.Enable != true
                  ? null
                  : (bool value) async {
                      extensions.Tun.excludeDeviceCommunication = value;
                    },
            ),
          ),
          GroupItemOptions(
            switchOptions: GroupItemSwitchOptions(
              name: "enforceRoutes",
              tips: "macOS 11.0+",
              switchValue: extensions.Tun.enforceRoutes,
              onSwitch: tun.OverWrite != true || tun.Enable != true
                  ? null
                  : (bool value) async {
                      extensions.Tun.enforceRoutes = value;
                    },
            ),
          ),
        ],
        GroupItemOptions(
          switchOptions: GroupItemSwitchOptions(
            name: t.tun.icmpForward,
            tips: "disable-icmp-forwarding",
            switchValue: tun.DisableICMPForwarding != true,
            onSwitch: tun.OverWrite != true || tun.Enable != true
                ? null
                : (bool value) async {
                    tun.DisableICMPForwarding = !value;
                  },
          ),
        ),
      ];
      List<GroupItemOptions> options1 = [];
      if (Platform.isAndroid) {
        options1.addAll([
          GroupItemOptions(
            switchOptions: GroupItemSwitchOptions(
              name: t.tun.allowBypass,
              switchValue: extensions.Tun.httpProxy.AllowBypass,
              onSwitch: tun.OverWrite != true || tun.Enable != true
                  ? null
                  : (bool value) async {
                      extensions.Tun.httpProxy.AllowBypass = value;
                    },
            ),
          ),
        ]);
      }
      if (Platform.isAndroid) {
        options1.addAll([
          GroupItemOptions(
            switchOptions: GroupItemSwitchOptions(
              name: t.tun.appendHttpProxy,
              switchValue: extensions.Tun.httpProxy.Enable,
              onSwitch: tun.OverWrite != true || tun.Enable != true
                  ? null
                  : (bool value) async {
                      extensions.Tun.httpProxy.Enable = value;
                      extensions.Tun.httpProxy.Server = value
                          ? "127.0.0.1"
                          : null;
                      extensions.Tun.httpProxy.ServerPort = value
                          ? setting.MixedPort
                          : null;
                    },
            ),
          ),
          GroupItemOptions(
            pushOptions: GroupItemPushOptions(
              name: t.tun.bypassHttpProxyDomain,
              onPush: tun.OverWrite != true || tun.Enable != true
                  ? null
                  : () async {
                      extensions.Tun.httpProxy.BypassDomain ??= [];
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          settings: ListAddScreen.routeSettings(
                            "HttpProxyBypassDomain",
                          ),
                          builder: (context) => ListAddScreen(
                            title: t.tun.bypassHttpProxyDomain,
                            data: extensions.Tun.httpProxy.BypassDomain!,
                          ),
                        ),
                      );
                    },
            ),
          ),
        ]);
      }

      return [GroupItem(options: options), GroupItem(options: options1)];
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        settings: GroupScreen.routeSettings("tun"),
        builder: (context) =>
            GroupScreen(title: tcontext.meta.tun, titleBuilder: (t) => t.meta.tun, getOptions: getOptions),
      ),
    );
  }

  static Future<void> showClashSettingsDNS(BuildContext context) async {
    final tcontext = Translations.of(context);
    Future<List<GroupItem>> getOptions(
      BuildContext context,
      SetStateCallback? setstate,
    ) async {
      var setting = ClashSettingManager.getConfig();
      var dns = setting.DNS!;

      final enhancedModes = ClashDnsEnhancedMode.toList();
      final enhancedModesTuple = ClashDnsEnhancedMode.toTupleList();
      final fakeIPFilterModes = ClashFakeIPFilterMode.toList();
      List<GroupItemOptions> options = [
        GroupItemOptions(
          switchOptions: GroupItemSwitchOptions(
            name: tcontext.meta.overwrite,
            switchValue: dns.OverWrite,
            onSwitch: (bool value) async {
              dns.OverWrite = value;
            },
          ),
        ),
        GroupItemOptions(
          switchOptions: GroupItemSwitchOptions(
            name: tcontext.meta.enable,
            tips: "enable",
            switchValue: dns.Enable,
            onSwitch: dns.OverWrite != true
                ? null
                : (bool value) async {
                    dns.Enable = value;
                  },
          ),
        ),
        GroupItemOptions(
          textFormFieldOptions: GroupItemTextFieldOptions(
            name: tcontext.dns.listen,
            text: dns.Listen,
            textWidthPercent: 0.5,
            hint: "0.0.0.0:53",
            readOnly: dns.OverWrite != true || dns.Enable != true,
            tips: "listen",
            onChanged: (String value) {
              dns.Listen = value;
            },
          ),
        ),

        GroupItemOptions(
          switchOptions: GroupItemSwitchOptions(
            name: tcontext.dns.preferH3,
            tips: "prefer-h3",
            switchValue: dns.PreferH3,
            onSwitch: dns.OverWrite != true || dns.Enable != true
                ? null
                : (bool value) async {
                    dns.PreferH3 = value;
                  },
          ),
        ),

        GroupItemOptions(
          switchOptions: GroupItemSwitchOptions(
            name: tcontext.dns.useSystemHosts,
            tips: "use-system-hosts",
            switchValue: dns.UseSystemHosts,
            onSwitch: dns.OverWrite != true || dns.Enable != true
                ? null
                : (bool value) async {
                    dns.UseSystemHosts = value;
                  },
          ),
        ),
        GroupItemOptions(
          switchOptions: GroupItemSwitchOptions(
            name: tcontext.dns.useHosts,
            tips: "use-hosts",
            switchValue: dns.UseHosts,
            onSwitch: dns.OverWrite != true || dns.Enable != true
                ? null
                : (bool value) async {
                    dns.UseHosts = value;
                  },
          ),
        ),

      ];

      List<GroupItemOptions> options0 = [
        GroupItemOptions(
          pushOptions: GroupItemPushOptions(
            name: "hosts",
            tips: "hosts",
            onPush: dns.OverWrite != true || dns.Enable != true
                ? null
                : () async {
                    showClashSettingsHosts(context);
                  },
          ),
        ),
      ];

      List<GroupItemOptions> options1 = [
        GroupItemOptions(
          stringPickerOptions: GroupItemStringPickerOptions(
            name: tcontext.dns.enhancedMode,
            tips: "enhanced-mode",
            selected: enhancedModes.contains(dns.EnhancedMode)
                ? dns.EnhancedMode
                : enhancedModes.last,
            tupleStrings: enhancedModesTuple,
            onPicker: dns.OverWrite != true || dns.Enable != true
                ? null
                : (String? selected) async {
                    dns.EnhancedMode = selected;
                  },
          ),
        ),
        GroupItemOptions(
          stringPickerOptions: GroupItemStringPickerOptions(
            name: tcontext.dns.fakeIPFilterMode,
            tips: "fake-ip-filter-mode",
            selected: fakeIPFilterModes.contains(dns.FakeIPFilterMode)
                ? dns.FakeIPFilterMode
                : fakeIPFilterModes.last,
            strings: fakeIPFilterModes,
            onPicker: dns.OverWrite != true || dns.Enable != true
                ? null
                : (String? selected) async {
                    dns.FakeIPFilterMode = selected;
                  },
          ),
        ),
        GroupItemOptions(
          pushOptions: GroupItemPushOptions(
            name: tcontext.dns.fakeIPFilter,
            tips: "fake-ip-filter",
            onPush: dns.OverWrite != true || dns.Enable != true
                ? null
                : () async {
                    dns.FakeIPFilter ??= [];
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        settings: ListAddScreen.routeSettings("FakeIPFilter"),
                        builder: (context) => ListAddScreen(
                          title: tcontext.dns.fakeIPFilter, titleBuilder: (t) => t.dns.fakeIPFilter,
                          data: dns.FakeIPFilter!,
                        ),
                      ),
                    );
                  },
          ),
        ),
      ];
      List<GroupItemOptions> options2 = [
        GroupItemOptions(
          switchOptions: GroupItemSwitchOptions(
            name: tcontext.dns.respectRules,
            tips: "respect-rules",
            switchValue: dns.RespectRules,
            onSwitch: dns.OverWrite != true || dns.Enable != true
                ? null
                : (bool value) async {
                    dns.RespectRules = value;
                  },
          ),
        ),
        GroupItemOptions(
          pushOptions: GroupItemPushOptions(
            name: tcontext.dns.defaultNameServer,
            tips: "default-nameserver",
            onPush: dns.OverWrite != true || dns.Enable != true
                ? null
                : () async {
                    dns.DefaultNameserver ??= [];
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        settings: ListAddScreen.routeSettings(
                          "DefaultNameserver",
                        ),
                        builder: (context) => ListAddScreen(
                          title: tcontext.dns.defaultNameServer, titleBuilder: (t) => t.dns.defaultNameServer,
                          data: dns.DefaultNameserver!,
                        ),
                      ),
                    );
                  },
          ),
        ),
        GroupItemOptions(
          pushOptions: GroupItemPushOptions(
            name: tcontext.dns.nameServer,
            tips: "nameserver",
            onPush: dns.OverWrite != true || dns.Enable != true
                ? null
                : () async {
                    dns.NameServer ??= [];
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        settings: ListAddScreen.routeSettings("NameServer"),
                        builder: (context) => ListAddScreen(
                          title: tcontext.dns.nameServer, titleBuilder: (t) => t.dns.nameServer,
                          data: dns.NameServer!,
                        ),
                      ),
                    );
                  },
          ),
        ),
        GroupItemOptions(
          pushOptions: GroupItemPushOptions(
            name: tcontext.dns.proxyNameServer,
            tips: "proxy-server-nameserver",
            onPush: dns.OverWrite != true || dns.Enable != true
                ? null
                : () async {
                    dns.ProxyServerNameserver ??= [];
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        settings: ListAddScreen.routeSettings(
                          "ProxyServerNameserver",
                        ),
                        builder: (context) => ListAddScreen(
                          title: tcontext.dns.proxyNameServer, titleBuilder: (t) => t.dns.proxyNameServer,
                          data: dns.ProxyServerNameserver!,
                        ),
                      ),
                    );
                  },
          ),
        ),
        GroupItemOptions(
          pushOptions: GroupItemPushOptions(
            name: tcontext.dns.directNameServer,
            tips: "direct-nameserver",
            onPush: dns.OverWrite != true || dns.Enable != true
                ? null
                : () async {
                    dns.DirectNameServer ??= [];
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        settings: ListAddScreen.routeSettings(
                          "DirectNameServer",
                        ),
                        builder: (context) => ListAddScreen(
                          title: tcontext.dns.directNameServer, titleBuilder: (t) => t.dns.directNameServer,
                          data: dns.DirectNameServer!,
                        ),
                      ),
                    );
                  },
          ),
        ),
        GroupItemOptions(
          pushOptions: GroupItemPushOptions(
            name: tcontext.dns.fallbackNameServer,
            tips: "fallback",
            onPush: dns.OverWrite != true || dns.Enable != true
                ? null
                : () async {
                    dns.Fallback ??= [];
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        settings: ListAddScreen.routeSettings("Fallback"),
                        builder: (context) => ListAddScreen(
                          title: tcontext.dns.fallbackNameServer, titleBuilder: (t) => t.dns.fallbackNameServer,
                          data: dns.Fallback!,
                        ),
                      ),
                    );
                  },
          ),
        ),
        GroupItemOptions(
          switchOptions: GroupItemSwitchOptions(
            name: tcontext.dns.fallbackGeoIp,
            tips: "geoip",
            switchValue: dns.FallbackFilter?.GeoIP,
            onSwitch: dns.OverWrite != true || dns.Enable != true
                ? null
                : (bool value) async {
                    dns.FallbackFilter ??= RawFallbackFilter.by();
                    dns.FallbackFilter?.GeoIP = value;
                  },
          ),
        ),
        GroupItemOptions(
          textFormFieldOptions: GroupItemTextFieldOptions(
            name: tcontext.dns.fallbackGeoIpCode,
            text: dns.FallbackFilter?.GeoIPCode,
            textWidthPercent: 0.5,
            readOnly: dns.OverWrite != true || dns.Enable != true,
            tips: "geoip-code",
            onChanged: (String value) {
              dns.FallbackFilter ??= RawFallbackFilter.by();
              dns.FallbackFilter?.GeoIPCode = value;
            },
          ),
        ),
      ];

      return [
        GroupItem(options: options),
        GroupItem(options: options0),
        GroupItem(options: options1),
        GroupItem(options: options2),
      ];
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        settings: GroupScreen.routeSettings("dns"),
        builder: (context) =>
            GroupScreen(title: tcontext.meta.dns, titleBuilder: (t) => t.meta.dns, getOptions: getOptions),
      ),
    );
  }

  static Future<void> showClashSettingsHosts(BuildContext context) async {
    final tcontext = Translations.of(context);
    Future<List<GroupItem>> getOptions(
      BuildContext context,
      SetStateCallback? setstate,
    ) async {
      var setting = ClashSettingManager.getConfig();

      List<GroupItemOptions> options = [
        GroupItemOptions(
          switchOptions: GroupItemSwitchOptions(
            name: tcontext.meta.overwrite,
            switchValue: setting.OverWriteHosts,
            onSwitch: (bool value) async {
              setting.OverWriteHosts = value;
            },
          ),
        ),
        GroupItemOptions(
          pushOptions: GroupItemPushOptions(
            name: "hosts",
            tips: "hosts",
            onPush: setting.OverWriteHosts != true
                ? null
                : () async {
                    setting.Hosts ??= {};
                    List<Tuple2<String, String>> hs = [];
                    setting.Hosts!.forEach((key, value) {
                      hs.add(Tuple2(key, value));
                    });
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        settings: MapStringAndStringAddScreen.routeSettings(),
                        builder: (context) => MapStringAndStringAddScreen(
                          title: "hosts",
                          data: hs,
                        ),
                      ),
                    );
                    setting.Hosts!.clear();
                    for (var h in hs) {
                      setting.Hosts![h.item1] = h.item2;
                    }
                  },
          ),
        ),
      ];

      return [GroupItem(options: options)];
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        settings: GroupScreen.routeSettings("hosts"),
        builder: (context) =>
            GroupScreen(title: "hosts", getOptions: getOptions),
      ),
    );
  }

  static Future<void> showClashSettingsNTP(BuildContext context) async {
    final tcontext = Translations.of(context);
    Future<List<GroupItem>> getOptions(
      BuildContext context,
      SetStateCallback? setstate,
    ) async {
      var setting = ClashSettingManager.getConfig();
      var ntp = setting.NTP!;
      List<GroupItemOptions> options = [
        GroupItemOptions(
          switchOptions: GroupItemSwitchOptions(
            name: tcontext.meta.overwrite,
            switchValue: ntp.OverWrite,
            onSwitch: (bool value) async {
              ntp.OverWrite = value;
            },
          ),
        ),
        GroupItemOptions(
          switchOptions: GroupItemSwitchOptions(
            name: tcontext.meta.enable,
            switchValue: ntp.Enable,
            tips: "enable",
            onSwitch: ntp.OverWrite != true
                ? null
                : (bool value) async {
                    ntp.Enable = value;
                  },
          ),
        ),
        GroupItemOptions(
          textFormFieldOptions: GroupItemTextFieldOptions(
            name: tcontext.meta.server,
            tips: "server",
            text: ntp.Server,
            textWidthPercent: 0.5,
            hint: tcontext.meta.required,
            readOnly: ntp.OverWrite != true || ntp.Enable != true,
            onChanged: (String value) {
              ntp.Server = value;
            },
          ),
        ),
        GroupItemOptions(
          textFormFieldOptions: GroupItemTextFieldOptions(
            name: tcontext.meta.port,
            tips: "port",
            text: ntp.Port?.toString() ?? "",
            textWidthPercent: 0.5,
            hint: tcontext.meta.required,
            readOnly: ntp.OverWrite != true || ntp.Enable != true,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (String value) {
              ntp.Port = int.tryParse(value);
            },
          ),
        ),
      ];

      return [GroupItem(options: options)];
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        settings: GroupScreen.routeSettings("ntp"),
        builder: (context) =>
            GroupScreen(title: tcontext.meta.ntp, titleBuilder: (t) => t.meta.ntp, getOptions: getOptions),
      ),
    );
  }

  static Future<void> showClashSettingsTLS(BuildContext context) async {
    final tcontext = Translations.of(context);
    Future<List<GroupItem>> getOptions(
      BuildContext context,
      SetStateCallback? setstate,
    ) async {
      var setting = ClashSettingManager.getConfig();
      var tls = setting.TLS!;
      List<GroupItemOptions> options = [
        GroupItemOptions(
          switchOptions: GroupItemSwitchOptions(
            name: tcontext.meta.overwrite,
            switchValue: tls.OverWrite,
            onSwitch: (bool value) async {
              tls.OverWrite = value;
            },
          ),
        ),
        GroupItemOptions(
          textFormFieldOptions: GroupItemTextFieldOptions(
            name: tcontext.tls.certificate,
            tips: "certificate",
            text: tls.Certificate,
            textWidthPercent: 0.5,
            readOnly: tls.OverWrite != true,
            onChanged: (String value) {
              tls.Certificate = value;
            },
          ),
        ),
        GroupItemOptions(
          textFormFieldOptions: GroupItemTextFieldOptions(
            name: tcontext.tls.privateKey,
            tips: "private-key",
            text: tls.PrivateKey,
            textWidthPercent: 0.5,
            readOnly: tls.OverWrite != true,
            onChanged: (String value) {
              tls.PrivateKey = value;
            },
          ),
        ),
        GroupItemOptions(
          pushOptions: GroupItemPushOptions(
            name: tcontext.tls.customTrustCert,
            tips: "custom-certifactes",
            onPush: tls.OverWrite != true
                ? null
                : () async {
                    tls.CustomTrustCert ??= [];
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        settings: ListAddScreen.routeSettings(
                          "CustomTrustCert",
                        ),
                        builder: (context) => ListAddScreen(
                          title: tcontext.tls.customTrustCert,
                          data: tls.CustomTrustCert!,
                        ),
                      ),
                    );
                  },
          ),
        ),
      ];

      return [GroupItem(options: options)];
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        settings: GroupScreen.routeSettings("tls"),
        builder: (context) =>
            GroupScreen(title: tcontext.meta.tls, titleBuilder: (t) => t.meta.tls, getOptions: getOptions),
      ),
    );
  }

  static Future<void> showClashSettingsSniffer(BuildContext context) async {
    final tcontext = Translations.of(context);
    Future<List<GroupItem>> getOptions(
      BuildContext context,
      SetStateCallback? setstate,
    ) async {
      var setting = ClashSettingManager.getConfig();
      var sniffer = setting.Sniffer!;
      List<GroupItemOptions> options = [
        GroupItemOptions(
          switchOptions: GroupItemSwitchOptions(
            name: tcontext.meta.overwrite,
            switchValue: sniffer.OverWrite,
            onSwitch: (bool value) async {
              sniffer.OverWrite = value;
            },
          ),
        ),
        GroupItemOptions(
          switchOptions: GroupItemSwitchOptions(
            name: tcontext.meta.enable,
            tips: "enable",
            switchValue: sniffer.Enable,
            onSwitch: sniffer.OverWrite != true
                ? null
                : (bool value) async {
                    sniffer.Enable = value;
                  },
          ),
        ),
        GroupItemOptions(
          switchOptions: GroupItemSwitchOptions(
            name: tcontext.sniffer.overrideDest,
            tips: "override-destination",
            switchValue: sniffer.OverrideDest,
            onSwitch: sniffer.OverWrite != true || sniffer.Enable != true
                ? null
                : (bool value) async {
                    sniffer.OverrideDest = value;
                  },
          ),
        ),
      ];

      return [GroupItem(options: options)];
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        settings: GroupScreen.routeSettings("sniffer"),
        builder: (context) =>
            GroupScreen(title: tcontext.meta.sniffer, titleBuilder: (t) => t.meta.sniffer, getOptions: getOptions),
      ),
    );
  }

  static Future<void> showClashSettingsDiversionTemplates(
    BuildContext context,
  ) async {
    final tcontext = Translations.of(context);
    Future<List<GroupItem>> getOptions(
      BuildContext context,
      SetStateCallback? setstate,
    ) async {
      List<GroupItemOptions> options = [
        GroupItemOptions(
          pushOptions: GroupItemPushOptions(
            name: tcontext.meta.ruleProviders,
            tips: "rule-providers",
            onPush: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  settings: RuleProvidersScreen.routeSettings(),
                  builder: (context) => RuleProvidersScreen(),
                ),
              );
            },
          ),
        ),
        GroupItemOptions(
          pushOptions: GroupItemPushOptions(
            name: tcontext.meta.ruleTemplates,
            tips: "rules",
            onPush: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  settings: RuleTemplatesScreen.routeSettings(),
                  builder: (context) => RuleTemplatesScreen(),
                ),
              );
            },
          ),
        ),
        GroupItemOptions(
          pushOptions: GroupItemPushOptions(
            name: tcontext.meta.proxyGroupsTemplates,
            tips: "proxy-groups",
            onPush: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  settings: ProxyGroupsTemplatesScreen.routeSettings(),
                  builder: (context) => ProxyGroupsTemplatesScreen(),
                ),
              );
            },
          ),
        ),
      ];

      return [GroupItem(options: options)];
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        settings: GroupScreen.routeSettings("diversionTemplates"),
        builder: (context) => GroupScreen(
          title: tcontext.meta.diversionTemplates,
          titleBuilder: (t) => t.meta.diversionTemplates,
          getOptions: getOptions,
        ),
      ),
    );
  }

  static Future<void> showClashSettingsGEORuleset(BuildContext context) async {
    final tcontext = Translations.of(context);
    Future<List<GroupItem>> getOptions(
      BuildContext context,
      SetStateCallback? setstate,
    ) async {
      var setting = ClashSettingManager.getConfig();
      var ruleset = setting.Extension!.Ruleset;
      List<GroupItemOptions> options = [
        GroupItemOptions(
          timerIntervalPickerOptions: GroupItemTimerIntervalPickerOptions(
            name: tcontext.meta.updateInterval,
            duration: Duration(
              seconds: ruleset.UpdateInterval ?? 2 * 24 * 3600,
            ),
            showMinutes: false,
            showSeconds: false,
            showDisable: false,
            onPicker: (bool canceled, Duration? duration) async {
              if (canceled) {
                return;
              }
              if (duration == null) {
                return;
              }
              ruleset.UpdateInterval = duration.inSeconds;
            },
          ),
        ),
        GroupItemOptions(
          switchOptions: GroupItemSwitchOptions(
            name: tcontext.meta.geoDownloadByProxy,
            switchValue: ruleset.EnableProxy,
            onSwitch: ruleset.UpdateInterval == null
                ? null
                : (bool value) async {
                    ruleset.EnableProxy = value;
                  },
          ),
        ),
        GroupItemOptions(
          textFormFieldOptions: GroupItemTextFieldOptions(
            name: "GeoSite",
            text: ruleset.GeoSiteUrl,
            textWidthPercent: 0.6,
            onChanged: (String value) {
              ruleset.GeoSiteUrl = value;
            },
          ),
        ),
        GroupItemOptions(
          textFormFieldOptions: GroupItemTextFieldOptions(
            name: "GeoIp",
            text: ruleset.GeoIpUrl,
            textWidthPercent: 0.6,
            onChanged: (String value) {
              ruleset.GeoIpUrl = value;
            },
          ),
        ),

      ];

      return [GroupItem(options: options)];
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        settings: GroupScreen.routeSettings("geo"),
        builder: (context) =>
            GroupScreen(title: "Geo RuleSet", getOptions: getOptions),
      ),
    );
  }

}
