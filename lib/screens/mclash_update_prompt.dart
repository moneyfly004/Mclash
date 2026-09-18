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

/// 发现新版本时的提示 + 更新入口。
///
/// 三条路径：
///   1. **后台无感预下载**：勾了「自动下载更新包」时，检测到新版本就在后台把
///      **与本机架构匹配**的安装包下好（不打扰用户）；
///   2. **提示**：检测到新版本时弹一次（同一个版本只弹一次，点「稍后」不再烦）；
///   3. **手动检查**：我的 → 检查更新，立刻查一次并给出结论。
abstract final class MclashUpdatePrompt {
  MclashUpdatePrompt._();

  /// 测试缝：替换「打开下载页」。
  @visibleForTesting
  static Future<void> Function(String url)? debugOpenUrlOverride;

  /// 正在弹窗/检查/安装时为 true：后台下载完成会再触发一次检查通知，
  /// 没有这个开关就会在用户操作过程中又弹一次。
  static bool _busy = false;

  /// 本次运行已提示过的版本（同一个版本一次运行只提示一次）。
  static final Set<String> _promptedThisRun = {};

  /// 测试缝：读取忙碌标记。
  @visibleForTesting
  static bool get debugBusy => _busy;

  /// 测试缝：清空「本次运行已提示」记录。
  @visibleForTesting
  static void debugReset() {
    _busy = false;
    _promptedThisRun.clear();
  }

  /// 同一个版本只提示一次（记住用户点过「稍后」的版本）。
  static String get _dismissed =>
      SettingManager.getConfig().dismissedUpdateVersion;

  /// 进入主界面后调用：已经知道有新版本（例如后台检查出来的）就提示一次。
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

  /// 手动检查更新（我的 → 检查更新）。
  /// 手动「检查更新」的超时：超过就当失败，别让用户对着转圈界面干等。
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
    // ⚠️ 这个 loading 弹窗**必须**由这里关掉，而且必须关对 navigator。
    //
    // 真实事故（用户实测：「点检查更新就一直转圈、无法返回、只能重启」）：
    // 它挂在**根** navigator 上（showDialog 默认 useRootNavigator），而旧代码用
    // `Navigator.of(context).pop()` 去关 —— 主页每个 tab 都套了自己的 Navigator
    // （MainTabShell），这里拿到的是 tab 内层那个，栈是空的，canPop() 为 false，
    // pop 被跳过：弹窗既不能点遮罩关闭、又不能返回，只能重启 App。
    //
    // 现在：句柄关闭（用弹窗自己的 context）+ `finally` 保证一定会关 +
    // 超时兜底（网络卡住也不会无限转圈）。
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
      loading.close(); // 幂等；成功/失败/超时/异常都会走到
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

  /// 新版本提示弹窗。
  ///
  /// [force] 为 true 时（手动检查/用户点更新）不记住「稍后」以外的行为差异，
  /// 只是不允许点遮罩关闭，避免用户以为自己错过了什么。
  static Future<void> showUpdateDialog(
    BuildContext context, {
    required String version,
    String notes = "",
    bool force = false,
  }) async {
    // 注意：这里**不**检查 _busy —— checkManually 会调进来（它自己已经置位了），
    // 再挡一次就会「手动检查更新查到了新版本，却什么都不弹」。
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
    // 后台可能已经下好了 → 文案要如实区分「已就绪」和「正在后台下载」
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
      // 记住「稍后」：同一个版本不再反复弹
      SettingManager.getConfig().dismissedUpdateVersion = version;
      SettingManager.save();
    }
  }

  /// 立即更新：已下好就进安装页；没下好就等后台下载完（最多 3 分钟），
  /// 仍不成功则退化成「打开与本机架构匹配的安装包下载地址」。
  static Future<void> installNow(
    BuildContext context, {
    required String version,
  }) async {
    var installer = await AutoUpdateManager.checkReplace();
    if (installer == null && AutoUpdateManager.getVersionCheck().url.isNotEmpty) {
      // 后台还没下好：催一次并等一会儿（没有下载地址时不等，直接给下载页入口）
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

  /// 测试缝：等待后台下载完成的上限（默认 3 分钟）。
  @visibleForTesting
  static Duration debugWaitInstallerLimit = const Duration(minutes: 3);

  /// 轮询等待后台下载完成（最多 3 分钟）。
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

  /// 打开下载地址（直链 = GitHub 上与本机平台/架构匹配的那个安装包）。
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
