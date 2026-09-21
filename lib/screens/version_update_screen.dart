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

/// 组装「延迟约 2 秒后在独立窗口里启动安装包」的 cmd 参数（Windows）。
///
/// ⚠️ 血泪教训（0.0.3 → 0.0.4 的真机报障：点更新后弹
/// 「Windows 找不到 'V' 文件」，安装包根本没启动）：
/// **绝不能把整条命令拼成一个字符串交给 `cmd /c`**。
/// Dart 在 Windows 上按 MSVC 规则给含空格的参数加引号，字符串里原本的 `"` 会被
/// 转义成 `\"`，而 **cmd.exe 不认识 `\"` 这种转义** —— 实测 cmd 收到的是
/// `\"\" "C:\...\0.0.4.exe\"`，路径前面多了反斜杠，于是 `start` 找不到文件。
/// 正确做法是把命令与参数拆成 argv 交给 `cmd`，让 Dart 只做它该做的加引号。
///
/// 另外两点同样重要：
///  · 延迟**不能用 `timeout`**：分离进程没有控制台，`timeout` 会立刻报
///    「ERROR: Input redirection is not supported」而根本不等待（实测），
///    于是安装包会在主程序还没退出时就启动。改用 `ping -n 3`（不需要控制台）。
///  · 安装包需要 UAC 提权，所以必须走 `start`（ShellExecute），
///    不能直接把 exe 当命令执行（CreateProcess 会因需要提权而失败）。
///  · `start` 只把**带引号**的第一个参数当作窗口标题，所以标题要留空格让 Dart 加引号；
///    标题本身不能含引号，否则又会被转义。
@visibleForTesting
List<String> buildWindowsInstallerLaunchArgs(String installer) => [
  '/c',
  'ping', '-n', '3', '127.0.0.1', '>nul',
  '&',
  'start',
  'Mclash Update',
  installer,
];

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

  void _launchInstallerAfterExit(String installer) {
    if (installer.isEmpty) {
      return;
    }
    try {
      if (Platform.isWindows) {
        Log.i("VersionUpdateScreen: 约 2 秒后启动安装包 $installer");
        unawaited(
          Process.start(
            'cmd',
            buildWindowsInstallerLaunchArgs(installer),
            mode: ProcessStartMode.detached,
          ),
        );
        return;
      }
      if (Platform.isMacOS) {
        unawaited(
          Process.start(
            'sh',
            ['-c', 'sleep 2 && open "$installer"'],
            mode: ProcessStartMode.detached,
          ),
        );
        return;
      }
    } catch (e) {
      Log.w("VersionUpdateScreen: 启动延迟安装进程失败 $e");
      _revealInstallerInExplorer(installer);
      return;
    }
    // 非 Windows / macOS（理论上不会走到）：至少把包的位置告诉用户
    _revealInstallerInExplorer(installer);
  }

  /// 兜底：自动启动失败时，把安装包在资源管理器里选中，
  /// 让用户能直接双击安装 —— 不要再出现「点了更新但什么都没发生」。
  void _revealInstallerInExplorer(String installer) {
    try {
      Log.w("VersionUpdateScreen: 改为打开安装包所在目录，请手动安装 $installer");
      unawaited(
        Process.start(
          'explorer',
          ['/select,$installer'],
          mode: ProcessStartMode.detached,
        ),
      );
    } catch (e) {
      Log.w("VersionUpdateScreen: 打开安装包所在目录失败 $e");
    }
  }
}
