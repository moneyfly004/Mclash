library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mclash/app/modules/auto_update_manager.dart';
import 'package:mclash/app/modules/setting_manager.dart';
import 'package:mclash/app/utils/app_utils.dart';
import 'package:mclash/app/utils/log.dart';
import 'package:mclash/app/utils/url_launcher_utils.dart';
import 'package:mclash/mf/mclash_update_check.dart';
import 'package:mclash/screens/dialog_utils.dart';
import 'package:mclash/screens/theme_define.dart';
import 'package:mclash/screens/version_update_screen.dart';
import 'package:url_launcher/url_launcher.dart';

abstract final class MclashUpdatePrompt {
  MclashUpdatePrompt._();

  @visibleForTesting
  static Future<void> Function(String url)? debugOpenUrlOverride;

  static bool _busy = false;

  static final Set<String> _promptedThisRun = {};

  @visibleForTesting
  static bool get debugBusy => _busy;

  @visibleForTesting
  static void debugReset() {
    _busy = false;
    _promptedThisRun.clear();
  }

  static String get _dismissed =>
      SettingManager.getConfig().dismissedUpdateVersion;

  static Future<void> maybePromptOnLaunch(BuildContext context) async {
    final check = AutoUpdateManager.getVersionCheck();
    if (!check.newVersion || check.version.isEmpty) {
      return;
    }
    if (check.version == _dismissed) {
      return;
    }
    if (_busy || _promptedThisRun.contains(check.version)) {
      return;
    }
    _promptedThisRun.add(check.version);
    await showUpdateDialog(context, version: check.version);
  }

  static const Duration kManualCheckTimeout = Duration(seconds: 20);

  static Future<void> checkManually(BuildContext context) async {
    if (!context.mounted || _busy) {
      return;
    }
    _busy = true;
    try {
      await _checkManuallyInner(context);
    } finally {
      _busy = false;
    }
  }

  static Future<void> _checkManuallyInner(BuildContext context) async {
    if (!context.mounted) {
      return;
    }
    final loading = DialogUtils.showLoadingDialogHandle(
      context,
      text: "正在检查更新…",
    );
    MclashUpdateInfo? info;
    var failed = false;
    try {
      info = await AutoUpdateManager.checkNow().timeout(kManualCheckTimeout);
    } on TimeoutException {
      failed = true;
      Log.w(
        "MclashUpdatePrompt: 检查更新超时（${kManualCheckTimeout.inSeconds}s），"
        "按失败处理并关闭弹窗",
      );
    } catch (e) {
      failed = true;
      Log.w("MclashUpdatePrompt: 检查更新失败 $e");
    } finally {
      loading.close(); 
    }
    if (!context.mounted) {
      return;
    }
    if (info == null) {
      await DialogUtils.showAlertDialog(
        context,
        failed
            ? "检查更新失败，请检查网络后重试。"
            : "已是最新版本（${AppUtils.getBuildinVersion()}）。",
      );
      return;
    }
    await showUpdateDialog(
      context,
      version: info.version,
      notes: info.notes,
      force: true,
    );
  }

  static Future<void> showUpdateDialog(
    BuildContext context, {
    required String version,
    String notes = "",
    bool force = false,
  }) async {
    if (!context.mounted) {
      return;
    }
    _busy = true;
    try {
      await _showDialogInner(
        context,
        version: version,
        notes: notes,
        force: force,
      );
    } finally {
      _busy = false;
    }
  }

  static Future<void> _showDialogInner(
    BuildContext context, {
    required String version,
    required String notes,
    required bool force,
  }) async {
    if (!context.mounted) {
      return;
    }
    final ready = await AutoUpdateManager.checkReplace();
    if (!context.mounted) {
      return;
    }
    final downloaded = ready != null;

    final ok = await showDialog<bool>(
      context: context,
      barrierDismissible: !force,
      builder: (ctx) => AlertDialog(
        title: Text("发现新版本 $version"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              downloaded
                  ? "安装包已在后台下载完成，点「立即更新」完成升级。"
                  : "点「立即更新」开始下载并安装（也可继续使用，安装包会在后台下载）。",
              style: const TextStyle(fontSize: 13),
            ),
            if (notes.trim().isNotEmpty) ...[
              const SizedBox(height: 12),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 180),
                child: SingleChildScrollView(
                  child: Text(
                    notes.length > 600 ? "${notes.substring(0, 600)}…" : notes,
                    style: const TextStyle(
                      fontSize: 12,
                      color: ThemeDefine.kColorGrey,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("稍后"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("立即更新"),
          ),
        ],
      ),
    );

    if (!context.mounted) {
      return;
    }
    if (ok == true) {
      await installNow(context, version: version);
    } else if (ok == false) {
      SettingManager.getConfig().dismissedUpdateVersion = version;
      SettingManager.save();
    }
  }

  static Future<void> installNow(
    BuildContext context, {
    required String version,
  }) async {
    var installer = await AutoUpdateManager.checkReplace();
    if (installer == null && AutoUpdateManager.getVersionCheck().url.isNotEmpty) {
      unawaited(
        AutoUpdateManager.download().catchError((Object e) {
          Log.w("MclashUpdatePrompt: 下载安装包失败 $e");
        }),
      );
      installer = await _waitForInstaller();
    }
    if (!context.mounted) {
      return;
    }
    if (installer != null) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          settings: VersionUpdateScreen.routeSettings(),
          builder: (_) => const VersionUpdateScreen(),
        ),
      );
      return;
    }
    final url = AutoUpdateManager.getVersionCheck().url;
    if (!context.mounted) {
      return;
    }
    final ok = await DialogUtils.showConfirmDialog(
      context,
      "安装包还没下载完成。\n\n"
      "点「确定」打开下载页，手动下载适合你设备的安装包（版本 $version）。",
    );
    if (ok == true && url.isNotEmpty) {
      await openDownloadUrl(url);
    }
  }

  @visibleForTesting
  static Duration debugWaitInstallerLimit = const Duration(minutes: 3);

  static Future<String?> _waitForInstaller() async {
    final deadline = DateTime.now().add(debugWaitInstallerLimit);
    while (DateTime.now().isBefore(deadline)) {
      await Future<void>.delayed(const Duration(seconds: 2));
      final path = await AutoUpdateManager.checkReplace();
      if (path != null) {
        return path;
      }
    }
    return null;
  }

  static Future<void> openDownloadUrl(String url) async {
    final override = debugOpenUrlOverride;
    if (override != null) {
      return override(url);
    }
    try {
      await UrlLauncherUtils.loadUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      Log.w("MclashUpdatePrompt: 打开下载地址失败 $e");
    }
  }
}
