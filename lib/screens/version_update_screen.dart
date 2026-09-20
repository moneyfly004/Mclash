// ignore_for_file: unused_catch_stack

import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:app_installer/app_installer.dart';
import 'package:mclash/app/local_services/vpn_service.dart';
import 'package:mclash/app/modules/auto_update_manager.dart';
import 'package:mclash/app/utils/log.dart';
import 'package:mclash/i18n/strings.g.dart';
import 'package:mclash/screens/dialog_utils.dart';
import 'package:mclash/screens/theme_config.dart';
import 'package:mclash/screens/theme_define.dart';
import 'package:mclash/screens/widgets/framework.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class VersionUpdateScreen extends LasyRenderingStatefulWidget {
  static RouteSettings routeSettings() {
    return const RouteSettings(name: "VersionUpdateScreen");
  }

  const VersionUpdateScreen({super.key});

  @override
  State<VersionUpdateScreen> createState() => _VersionUpdateScreenState();
}

class _VersionUpdateScreenState
    extends LasyRenderingState<VersionUpdateScreen> {
  bool _installing = false;
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tcontext = Translations.of(context);
    var checkVersion = AutoUpdateManager.getVersionCheck();

    return Scaffold(
      appBar: PreferredSize(preferredSize: Size.zero, child: AppBar()),
      body: Stack(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 20, left: 20, right: 20),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      tcontext.VersionUpdateScreen.versionReady(
                        p: checkVersion.version,
                      ),
                      style: const TextStyle(
                        fontSize: ThemeConfig.kFontSizeListItem,
                        fontWeight: ThemeConfig.kFontWeightListItem,
                        color: ThemeDefine.kColorBlue,
                      ),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      height: 45.0,
                      child: ElevatedButton(
                        onPressed: _installing
                            ? null
                            : () async {
                                await checkReplace();
                              },
                        child: _installing
                            ? SizedBox(
                                width: 26,
                                height: 26,
                                child: RepaintBoundary(
                                  child: CircularProgressIndicator(
                                    color: ThemeDefine.kColorGreenBright,
                                  ),
                                ),
                              )
                            : Text(tcontext.VersionUpdateScreen.update),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> checkReplace() async {
    String? installer = await AutoUpdateManager.checkReplace();
    if (!mounted) {
      return;
    }
    if (installer == null) {
      Navigator.pop(context);
      return;
    }
    if (_installing) {
      return;
    }
    _installing = true;
    setState(() {});
    try {
      await VPNService.stop();
      if (Platform.isWindows || Platform.isMacOS) {
        // 先退出应用，再由一个**分离进程**在稍后启动安装包。
        //
        // 不能 `await launchUrl(installer)` 再退出：安装包（Inno Setup）一启动
        // 就要覆盖正在运行的 mclash.exe，于是等它退出；而这里又卡在等
        // launchUrl / exitApplication —— 两边互相等，界面就「未响应」。
        _launchInstallerAfterExit(installer);
        await ServicesBinding.instance.exitApplication(AppExitType.required);
      } else if (Platform.isAndroid) {
        await AppInstaller.installApk(installer);
      }
    } catch (err, stacktrace) {
      Log.w("VersionUpdateScreen.checkReplace exception ${err.toString()}");
      _installing = false;
      if (!mounted) {
        return;
      }
      DialogUtils.showAlertDialog(
        context,
        err.toString(),
        showCopy: true,
        showFAQ: true,
        withVersion: true,
      );
      setState(() {});
    }
    _installing = false;
    if (!mounted) {
      setState(() {});
    }
  }

  /// 启动一个**分离**进程：等本进程退干净之后，再运行安装包。
  ///
  /// 直接启动安装包会和「覆盖正在运行的 exe」打架；这里延迟 2 秒（足够本进程
  /// 走完 exitApplication 退出），再用 `ProcessStartMode.detached` 让安装进程
  /// 独立于本进程，父进程退出不影响它。
  void _launchInstallerAfterExit(String installer) {
    try {
      if (Platform.isWindows) {
        unawaited(
          Process.start(
            'cmd',
            ['/c', 'timeout /t 2 /nobreak >nul & start "" "$installer"'],
            mode: ProcessStartMode.detached,
          ),
        );
      } else if (Platform.isMacOS) {
        unawaited(
          Process.start(
            'sh',
            ['-c', 'sleep 2 && open "$installer"'],
            mode: ProcessStartMode.detached,
          ),
        );
      }
    } catch (e) {
      Log.w("VersionUpdateScreen: 启动延迟安装进程失败 $e");
    }
  }
}
