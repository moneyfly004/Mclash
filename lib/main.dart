// ignore_for_file: empty_catches, unused_catch_stack

import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:mclash/app/clash/clash_config.dart';
import 'package:mclash/app/local_services/vpn_service.dart';
import 'package:mclash/app/modules/auto_update_manager.dart';
import 'package:mclash/app/modules/biz.dart';
import 'package:mclash/app/modules/clash_setting_manager.dart';
import 'package:mclash/app/modules/remote_config_manager.dart';
import 'package:mclash/app/modules/setting_manager.dart';
import 'package:mclash/app/utils/app_args.dart';
import 'package:mclash/app/utils/app_lifecycle_state_notify.dart';
import 'package:mclash/app/utils/app_utils.dart';
import 'package:mclash/app/utils/device_utils.dart';
import 'package:mclash/app/utils/local_storage.dart';
import 'package:mclash/app/utils/log.dart';
import 'package:mclash/app/utils/move_to_background_utils.dart';
import 'package:mclash/app/utils/path_utils.dart';
import 'package:mclash/app/utils/platform_utils.dart';
import 'package:mclash/app/utils/system_scheme_utils.dart';
import 'package:mclash/app/utils/windows_version_helper.dart';
import 'package:mclash/i18n/strings.g.dart';
import 'package:mclash/mf/mclash_account_service.dart';
import 'package:mclash/mf/mclash_api.dart';
import 'package:mclash/screens/dialog_utils.dart';
import 'package:mclash/screens/mclash_gate.dart';
import 'package:mclash/screens/mclash_mode_action.dart';
import 'package:mclash/screens/launch_failed_screen.dart';
import 'package:mclash/screens/theme_data_dark.dart';
import 'package:mclash/screens/themes.dart';
import 'package:mclash/app/utils/vpn_action_handler.dart';
import 'package:mclash/screens/widgets/routes.dart';
import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:libclash_vpn_service/libclash_vpn_service.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter_single_instance/flutter_single_instance.dart';

List<String> processArgs = [];
StartFailedReason? startFailedReason;
String? startFailedReasonDesc;

/// 全局 Navigator key：窗口关闭时的确认弹窗需要在没有页面 context 的地方
/// 也能弹出来（托盘/窗口事件里没有可用的 BuildContext）。
final GlobalKey<NavigatorState> mclashNavigatorKey =
    GlobalKey<NavigatorState>();

/// 「关闭窗口时的选择」是否已经问过并记住（见 [_maybeAskCloseAction]）。
const String kCloseActionAskedKey = 'closeActionAsked';
const String kCloseActionQuitKey = 'closeActionQuit';

void main(List<String> args) async {
  processArgs = args;
  WidgetsFlutterBinding.ensureInitialized();
  await LocaleSettings.useDeviceLocale();
  await VPNService.initABI();
  await RemoteConfigManager.init();
  await SettingManager.init();
  Log.setLevel(SettingManager.getConfig().logLevel);
  if (Platform.isWindows || Platform.isMacOS) {
    await _ensureSingleInstanceOrExit();
  }

  await run(args);
}

Future<void> run(List<String> args) async {
  try {
    do {
      String profileDir = await PathUtils.profileDir();
      if (profileDir.isEmpty) {
        startFailedReason = StartFailedReason.invalidProfile;
        break;
      }
      await Log.init();
      String buildVersion = AppUtils.getBuildinVersion();
      String exePath = Platform.resolvedExecutable;
      Log.w(
        'launch $buildVersion $exePath, $args, ${Directory.current.absolute.path}, $profileDir',
      );
      String cache = await PathUtils.cacheDir();
      if (cache.isEmpty) {
        startFailedReason = StartFailedReason.invalidProfile;
        break;
      }
      String version = await AppUtils.getPackgetVersion();
      if (buildVersion != version) {
        startFailedReason = StartFailedReason.invalidVersion;
        break;
      }
      if (PlatformUtils.isPC()) {
        if (path.basename(exePath).toLowerCase() !=
            PathUtils.getExeName().toLowerCase()) {
          startFailedReason = StartFailedReason.invalidProcess;
          break;
        }
      }
      const inProduction = bool.fromEnvironment("dart.vm.product");
      if (inProduction) {
        if (Platform.isMacOS) {
          if (!path.isWithin("/Applications", exePath)) {
            startFailedReason = StartFailedReason.invalidInstallPath;
            break;
          }
        }
      }
      if (Platform.isWindows) {
        var tmp = await getTemporaryDirectory();
        if (exePath.contains("UNC/") ||
            exePath.contains("UNC\\") ||
            path.isWithin(tmp.absolute.path, exePath)) {
          startFailedReason = StartFailedReason.invalidInstallPath;
          break;
        }

        if (VersionHelper.instance.majorVersion != 0 &&
            VersionHelper.instance.majorVersion < 10) {
          startFailedReason = StartFailedReason.systemVersionLow;
          startFailedReasonDesc =
              "Current: ${VersionHelper.instance.majorVersion}\nMinimum required: >= 10.0";
          break;
        }
      } else if (Platform.isAndroid) {
        String version = await FlutterVpnService.getSystemVersion();
        int? v = int.tryParse(version);
        if (v != null && v < 26) {
          startFailedReason = StartFailedReason.systemVersionLow;
          String osVersion = "";
          if (v == 25) {
            osVersion = "7.1";
          } else if (v == 24) {
            osVersion = "7.0";
          } else if (v == 23) {
            osVersion = "6.0";
          } else {
            osVersion = "< 6.0";
          }
          startFailedReasonDesc =
              "Current: $osVersion\nMinimum required: >= 8.0";
          break;
        }
      }
    } while (false);

    if (PlatformUtils.isPC()) {
      await windowManager.ensureInitialized();
      const inProduction = bool.fromEnvironment("dart.vm.product");
      if (inProduction) {

        await windowManager.setMinimumSize(Size(400, 700));
      }

      await windowManager.center();
    }

    await AutoUpdateManager.init();

    bool disableOrientation = await DeviceUtils.disableOrientation();
    if (!disableOrientation) {
      if (SettingManager.getConfig().ui.autoOrientation) {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.portraitDown,
          DeviceOrientation.landscapeRight,
        ]);
      } else {
        SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      }
    }
  } catch (err, stacktrace) {
    startFailedReason = StartFailedReason.exception;
    startFailedReasonDesc = err.toString();
    String cmdline = args.toString();
    Log.w("main.run exception: ${err.toString()}, $cmdline");
  }
  try {
    await FastCachedImageConfig.init(subDir: AppUtils.getName());
  } catch (err, stacktrace) {
    Log.w("FastCachedImageConfig.init() exception: ${err.toString()}");
  }
  if (Platform.isAndroid) {
    SystemUiOverlayStyle systemUiOverlayStyle = const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
    );
    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  registerMclashVpnService();
  // 桌面端（mihomo 子进程 + 系统代理）的诊断以前只写 stderr：Windows 上从开始菜单
  // 启动的 GUI 程序没有控制台，那些行全部丢失 —— 用户报「系统代理没生效/界面空白」时
  // 我们拿不到任何线索。这里接到应用日志，Windows 上也能直接查。
  registerDesktopLogSink((line) => Log.i(line));

  runApp(TranslationProvider(child: const MyApp()));
}

Future<void> _ensureSingleInstanceOrExit() async {
  FlutterSingleInstance.debugMode = false;

  FlutterSingleInstance.processName = AppUtils.getId();
  FlutterSingleInstance.onFocus = (metadata) async {
    await windowManager.show();
    var args = metadata["args"] as List<dynamic>?;
    if (args != null && args.isNotEmpty) {
      String schemeArg = args.firstWhere((element) {
        final arg = element.toString().trim();
        return arg.startsWith(SystemSchemeUtils.getClashSchemeWith()) ||
            arg.startsWith(SystemSchemeUtils.getClashMiSchemeWith());
      }, orElse: () => '');
      if (schemeArg.isNotEmpty) {
        Biz.onEventSingletonInstance?.call(schemeArg);
      }
    }
  };

  final singleInstance = FlutterSingleInstance();
  final isFirst = await singleInstance.isFirstInstance(
    maxRetries: 1,
    retryInterval: const Duration(milliseconds: 250),
  );

  if (!isFirst) {
    try {
      await singleInstance.focus({"args": processArgs});
    } catch (err) {
      Log.w("single instance focus exception: ${err.toString()}");
    }

    exit(0);
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => MyAppState();
}

class MyAppState extends State<MyApp>
    with WidgetsBindingObserver, WindowListener, TrayListener {
  static const kMenuConnect = "connect";
  static const kMenuDisconnect = "disconnect";
  static const kMenuModeRule = "mode_rule";
  static const kMenuModeGlobal = "mode_global";
  static const kMenuModeDirect = "mode_direct";
  static const kMenuOpen = "show_window";
  static const kMenuExit = "exit_app";
  bool _launchAtStartup = false;
  bool _windowVisibleForMac = false;
  bool _trayGrey = true;
  Menu? _menu;
  String _trafficOld = "";
  String _speedOld = "";
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (PlatformUtils.isPC()) {
      windowManager.addListener(this);
      windowManager.setPreventClose(true);
      trayManager.addListener(this);
      _setTray(true, false, true);
    }
    if (Platform.isMacOS) {
      Biz.onEventTrafficChanged.add((String traffic, String speed) {
        if (!SettingManager.getConfig().showTrayTraffic) {
          traffic = "";
          speed = "";
        }
        if (_trafficOld != traffic || _speedOld != speed) {
          _trafficOld = traffic;
          _speedOld = speed;
          if (traffic.isEmpty && speed.isEmpty) {
            trayManager.setTitle("");
          }
          if (traffic.isNotEmpty && speed.isNotEmpty) {
            trayManager.setTitle("$traffic $speed");
          } else if (traffic.isNotEmpty) {
            trayManager.setTitle(traffic);
          } else if (speed.isNotEmpty) {
            trayManager.setTitle(speed);
          }
        }
      });
    }

    MclashApi.restore().then((loggedIn) {
      if (loggedIn) {
        MclashAccountService.instance.start();
      }
    });
    AppLifecycleStateNofity.init();
    LocaleSettings.getLocaleStream().listen((event) {});
    String launchStartupArg = processArgs.firstWhere(
      (element) => element == AppArgs.launchStartup,
      orElse: () => '',
    );
    _launchAtStartup = launchStartupArg.isNotEmpty;

    AppLifecycleStateNofity.stateLaunch(_launchAtStartup);
    _init();
  }

  @override
  void dispose() {
    AppLifecycleStateNofity.uninit();
    WidgetsBinding.instance.removeObserver(this);
    if (PlatformUtils.isPC()) {
      windowManager.removeListener(this);
      trayManager.removeListener(this);
      trayManager.destroy();
    }

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        AppLifecycleStateNofity.stateResumed("resumed");
        break;
      case AppLifecycleState.inactive:
        AppLifecycleStateNofity.stateInactive("inactive");
        break;
      case AppLifecycleState.detached:
        break;
      case AppLifecycleState.paused:
        AppLifecycleStateNofity.statePaused("paused");
        break;
      case AppLifecycleState.hidden:
        AppLifecycleStateNofity.stateInactive("hidden");
        break;
    }
  }

  @override
  Future<AppExitResponse> didRequestAppExit() async {
    await _quit();
    return AppExitResponse.cancel;
  }

  @override
  void didHaveMemoryPressure() {
    Log.w("memoryPressure");
  }

  @override
  Widget build(BuildContext context) {
    String schemeArg = processArgs.firstWhere((element) {
      final arg = element.trim();
      return arg.startsWith(SystemSchemeUtils.getClashSchemeWith()) ||
          arg.startsWith(SystemSchemeUtils.getClashMiSchemeWith());
    }, orElse: () => '');

    List<NavigatorObserver> observers = [];

    observers.add(AppRouteObserver.instance);

    return MultiProvider(
      providers: [ChangeNotifierProvider.value(value: Themes())],
      child: Consumer<Themes>(
        builder: (context, appTheme, _) {
          Provider.of<Themes>(
            context,
          ).setTheme(SettingManager.getConfig().ui.theme, false);
          Widget app = Shortcuts(
            shortcuts: const {
              SingleActivator(LogicalKeyboardKey.select): ActivateIntent(),
            },
            child: MaterialApp(
              navigatorKey: mclashNavigatorKey,

              debugShowCheckedModeBanner: false,
              locale: TranslationProvider.of(context).flutterLocale,
              supportedLocales: AppLocaleUtils.supportedLocales,
              localizationsDelegates: GlobalMaterialLocalizations.delegates,
              navigatorObservers: observers,
              home: PopScope(
                canPop: false,
                onPopInvokedWithResult: (didPop, result) {
                  if (Platform.isAndroid) {
                    MoveToBackgroundUtils.moveToBackground();
                  }
                },

                child: startFailedReason != null
                    ? LaunchFailedScreen(
                        startFailedReason: startFailedReason!,
                        startFailedReasonDesc: startFailedReasonDesc,
                      )
                    : MclashGate(launchUrl: schemeArg.trim()),
              ),
              builder: SettingManager.getConfig().ui.disableFontScaler
                  ? (context, widget) {
                      return MediaQuery(
                        data: MediaQuery.of(
                          context,
                        ).copyWith(textScaler: TextScaler.noScaling),
                        child: widget!,
                      );
                    }
                  : null,
              themeMode: appTheme.themeMode(),
              theme: appTheme.themeData(context),
              darkTheme: ThemeDataDark.theme(context),
            ),
          );

          return app;
        },
      ),
    );
  }

  @override
  void onWindowClose() async {
    Log.d("onWindowClose");
    // 关闭窗口**不等于**退出应用：旧实现无条件 hide()，用户以为「关掉软件了」，
    // 但 mclash.exe 与内核都还在跑、系统代理也还在生效 —— 这正是
    // 「退出软件了内核还在运行 / 还能上网」的来源。首次关闭时问清楚并记住。
    if (await _shouldQuitOnWindowClose()) {
      await _quit();
      return;
    }
    await windowManager.hide();
    _windowVisibleForMac = false;
    AppLifecycleStateNofity.statePaused("close");
  }

  /// 返回 true 表示「关窗口 = 完全退出」。首次询问，之后按记住的选择执行。
  Future<bool> _shouldQuitOnWindowClose() async {
    try {
      final asked = await LocalStorage.read(kCloseActionAskedKey);
      if (asked == "true") {
        return await LocalStorage.read(kCloseActionQuitKey) == "true";
      }
      final ctx = mclashNavigatorKey.currentContext;
      if (ctx == null || !ctx.mounted) {
        return false;
      }
      // 确定 = 最小化到托盘（保持连接）；取消 = 完全退出（并停止内核）。
      final minimize = await DialogUtils.showConfirmDialog(
        ctx,
        "关闭窗口只是把 Mclash 收进托盘 —— 内核与系统代理会继续工作，网照旧能上。\n\n"
        "· 点「确定」：最小化到托盘（想彻底退出时，右键托盘图标 → 退出）\n"
        "· 点「取消」：完全退出 Mclash，同时停止内核并还原系统代理\n\n"
        "（本次选择会被记住；下次可直接右键托盘图标操作）",
      );
      if (minimize == null) {
        return false;
      }
      await LocalStorage.write(kCloseActionAskedKey, "true");
      await LocalStorage.write(kCloseActionQuitKey, minimize ? "false" : "true");
      Log.i("onWindowClose: 用户选择 ${minimize ? "最小化到托盘" : "完全退出"}（已记住）");
      return !minimize;
    } catch (err) {
      Log.w("onWindowClose: 询问关闭行为失败 ${err.toString()}");
      return false;
    }
  }

  @override
  void onWindowMinimize() {
    _windowVisibleForMac = false;
    Log.d("onWindowMinimize");
    AppLifecycleStateNofity.statePaused("minimize");
  }

  @override
  void onWindowRestore() {
    _windowVisibleForMac = true;
    Log.d("onWindowRestore");
    AppLifecycleStateNofity.stateResumed("restore");
  }

  @override
  void onWindowFocus() {
    if (Platform.isMacOS) {
      if (!_windowVisibleForMac) {
        Log.d("onWindowFocus");
        _windowVisibleForMac = true;
        AppLifecycleStateNofity.stateResumed("restore");
      }
    }
  }

  void firstShowWindow(bool forceShow) {
    if (!PlatformUtils.isPC()) {
      return;
    }
    windowManager.waitUntilReadyToShow(null, () async {
      final settings = SettingManager.getConfig();
      if (Platform.isMacOS && settings.hideDockIcon) {
        FlutterVpnService.hideDockIcon(true);
      }
      if (forceShow || (Platform.isWindows && !settings.ui.hideAfterLaunch)) {
        await windowManager.show();
        onWindowRestore();
      }
    });
  }

  Future<void> _init() async {
    Biz.onEventExit = (() {
      _quit();
    });

    Biz.onEventVPNStateChanged = ((bool connected) {
      if (PlatformUtils.isPC()) {
        if (_trayGrey == !connected) {
          return;
        }
        _setTray(!connected, false, false);
        if (Platform.isMacOS && !connected) {
          _trafficOld = "";
          _speedOld = "";
          trayManager.setTitle("");
        }
      }
    });
    if (startFailedReason == null) {
      Biz.onEventInitHomeFinish.add(() {
        firstShowWindow(false);
      });

      await Biz.init(_launchAtStartup);
    } else {
      firstShowWindow(true);
    }
  }

  Future<void> _uninit() async {
    if (PlatformUtils.isPC()) {
      await windowManager.hide();
    }
    if (startFailedReason == null) {
      await Biz.uninit();
    }
    if (PlatformUtils.isPC()) {
      await trayManager.destroy();
    }
  }

  Future<void> _quit() async {
    try {
      await _uninit();
    } catch (err) {
      Log.w("quit: _uninit exception ${err.toString()}");
    }
    // 兜底：`_uninit()` 里的任何一步抛异常（窗口/托盘/其它模块），都不能让
    // 内核留下来继续跑 —— 那会变成「软件退了，内核还在，网还能上」。
    // stop() 本身是幂等的（内核已停时直接返回），重复调用安全。
    try {
      await VPNService.uninit();
    } catch (err) {
      Log.w("quit: 停止内核 exception ${err.toString()}");
    }
    Future.delayed(const Duration(seconds: 0), () async {
      await Log.uninit();
      await ServicesBinding.instance.exitApplication(AppExitType.required);
    });
  }

  void _setTray(bool grey, bool destroy, bool quitIfFailed) {
    Future.delayed(const Duration(milliseconds: 300), () async {
      if (destroy) {
        await trayManager.destroy();
      }

      try {
        if (Platform.isWindows) {
          await trayManager.setIcon(
            grey ? 'assets/images/grey_tray.ico' : 'assets/images/tray.ico',
            isTemplate: false,
          );
        } else {
          await trayManager.setIcon(
            grey ? 'assets/images/grey_tray.png' : 'assets/images/tray.png',
            isTemplate: false,
          );
        }
        _trayGrey = grey;
      } catch (err, stacktrace) {
        Log.w("setIcon exception: ${err.toString()}");
        if (quitIfFailed) {
          Future.delayed(const Duration(milliseconds: 1000), () async {
            _quit();
          });
        }
      }
      await trayManager.setToolTip(AppUtils.getName());
    });
  }

  Future<void> _setTrayMenu(bool grey) async {
    if (!PlatformUtils.isPC()) {
      return;
    }
    final mode = ClashSettingManager.getConfigsMode();
    List<MenuItem> items = [
      if (grey) ...[
        MenuItem(key: kMenuConnect, label: "   ${t.meta.connect}   "),
      ],
      if (!grey) ...[
        MenuItem(key: kMenuDisconnect, label: "   ${t.meta.disconnect}   "),
      ],
      MenuItem.separator(),
      MenuItem.checkbox(
        key: kMenuModeRule,
        checked: mode == ClashConfigsMode.rule,
        label: "   ${t.meta.rule}   ",
      ),
      MenuItem.checkbox(
        key: kMenuModeGlobal,
        checked: mode == ClashConfigsMode.global,
        label: "   ${t.meta.global}   ",
      ),
      MenuItem.checkbox(
        key: kMenuModeDirect,
        checked: mode == ClashConfigsMode.direct,
        label: "   ${t.meta.direct}   ",
      ),
      MenuItem.separator(),
      MenuItem(key: kMenuOpen, label: "   ${t.main.tray.menuOpen}   "),
      MenuItem(key: kMenuExit, label: "   ${t.main.tray.menuExit}   "),
    ];
    _menu = Menu(items: items);
    await trayManager.setContextMenu(_menu!);
    // bringAppToFront 在 Windows 上是「弹托盘菜单时把窗口提到最前」，
    // 正是我们要的行为；官方弃用是因为它只在 Windows 生效，尚无替代项。
    // ignore: deprecated_member_use
    await trayManager.popUpContextMenu(bringAppToFront: true);
  }

  @override
  void onTrayIconMouseDown() async {
    if (await windowManager.isMinimized()) {
      await windowManager.restore();
    } else {
      await windowManager.show();
      onWindowRestore();
    }
  }

  @override
  void onTrayIconRightMouseDown() async {
    await _setTrayMenu(_trayGrey);
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) async {
    if (menuItem.key == kMenuConnect) {
      VpnActionHandler.vpnConnect?.call("menu", false);
    } else if (menuItem.key == kMenuDisconnect) {
      VpnActionHandler.vpnDisconnect?.call("menu", false);
    } else if (menuItem.key == kMenuModeRule) {
      await mclashSetMode(ClashConfigsMode.rule);
      menuItem.checked = true;
      _menu?.getMenuItem(kMenuModeGlobal)?.checked = false;
      _menu?.getMenuItem(kMenuModeDirect)?.checked = false;
      trayManager.setContextMenu(_menu!);
    } else if (menuItem.key == kMenuModeGlobal) {
      await mclashSetMode(ClashConfigsMode.global);
      menuItem.checked = true;
      _menu?.getMenuItem(kMenuModeRule)?.checked = false;
      _menu?.getMenuItem(kMenuModeDirect)?.checked = false;
      trayManager.setContextMenu(_menu!);
    } else if (menuItem.key == kMenuModeDirect) {
      await mclashSetMode(ClashConfigsMode.direct);
      menuItem.checked = true;
      _menu?.getMenuItem(kMenuModeRule)?.checked = false;
      _menu?.getMenuItem(kMenuModeGlobal)?.checked = false;
      trayManager.setContextMenu(_menu!);
    } else if (menuItem.key == kMenuExit) {
      await _quit();
    } else if (menuItem.key == kMenuOpen) {
      if (await windowManager.isMinimized()) {
        await windowManager.restore();
      } else {
        await windowManager.show();
        onWindowRestore();
      }
    }
  }
}
