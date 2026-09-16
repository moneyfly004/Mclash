import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mclash/app/modules/auto_update_manager.dart';
import 'package:mclash/app/modules/setting_manager.dart';
import 'package:mclash/i18n/strings.g.dart';
import 'package:mclash/mf/mclash_update_check.dart';
import 'package:mclash/screens/mclash_update_prompt.dart';
import 'package:mclash/screens/version_update_screen.dart';

/// 「检查更新 → 提示 → 下载/安装」这条链路的**行为**验证。
///
/// 用户的要求原文：
///   * 「如果有新版本，软件要有提示」；
///   * 「确实需要手动更新，要能点击下载，指定到我的对应项目的软件新版本，
///      适合他的架构安装包」；
///   * 后台无感更新（下载好之后点「立即更新」直接装）。
///
/// 覆盖：
///   1. 有新版本 → 弹提示；同一版本用户点过「稍后」→ 不再弹；
///   2. 弹窗里点「稍后」→ **记进设置**（重启也不打扰）；
///   3. 安装包已在后台下好 → 「立即更新」直接进安装页；
///   4. 还没下好 → 给**下载页**入口，且地址就是「适合本机架构」的那个安装包；
///   5. 手动「检查更新」→ 已是最新 / 发现新版本，两种结论都要如实说。
void main() {
  late List<String> openedUrls;

  /// 把「有新版本」这个状态直接摆好（真实链路里是后台检查写进去的）。
  void setNewVersion(String version, {String url = ""}) {
    AutoUpdateManager.getVersionCheck()
      ..newVersion = true
      ..version = version
      ..url = url;
  }

  setUp(() {
    openedUrls = [];
    MclashUpdatePrompt.debugReset();
    MclashUpdatePrompt.debugOpenUrlOverride = (url) async {
      openedUrls.add(url);
    };
    MclashUpdatePrompt.debugWaitInstallerLimit = Duration.zero;
    MclashUpdateCheck.debugLatestOverride = null;
    // 默认「还没下好」：真实 checkReplace 要问 path_provider（测试环境不装插件）
    AutoUpdateManager.debugCheckReplaceOverride = () async => null;
    SettingManager.getConfig().dismissedUpdateVersion = "";
    SettingManager.getConfig().autoDownloadUpdatePkg = false;
    AutoUpdateManager.getVersionCheck()
      ..clear()
      ..latestCheck = "";
  });

  tearDown(() {
    MclashUpdatePrompt.debugOpenUrlOverride = null;
    MclashUpdatePrompt.debugWaitInstallerLimit = const Duration(minutes: 3);
    MclashUpdateCheck.debugLatestOverride = null;
    AutoUpdateManager.debugCheckReplaceOverride = null;
    MclashUpdatePrompt.debugReset();
    SettingManager.getConfig().dismissedUpdateVersion = "";
    SettingManager.getConfig().autoDownloadUpdatePkg = true;
    AutoUpdateManager.getVersionCheck().clear();
  });

  /// 一个最小宿主页面：按钮 = 触发点（等同真实 App 的启动/我的页入口）。
  Future<void> pumpHost(
    WidgetTester tester, {
    required Future<void> Function(BuildContext context) onTap,
  }) async {
    await tester.pumpWidget(
      TranslationProvider(
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () => onTap(context),
                  child: const Text("TAP"),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  /// 收尾：跑完挂起的定时器 → 卸载组件树触发 dispose
  /// （LasyRendering 的 dispose 会排一个 1ms 定时器，不跑完框架会判「Pending timers」）。
  Future<void> finish(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 50));
  }

  Future<void> tapTrigger(WidgetTester tester) async {
    await tester.tap(find.text("TAP"));
    // 300ms 覆盖 AutoUpdateManager._notify 的延迟
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  testWidgets("有新版本 → 提示；没有新版本 → 不打扰", (tester) async {
    // ① 没有新版本：不该弹
    await pumpHost(
      tester,
      onTap: MclashUpdatePrompt.maybePromptOnLaunch,
    );
    await tapTrigger(tester);
    expect(find.textContaining("发现新版本"), findsNothing);

    // ② 有新版本：必须弹
    setNewVersion("9.9.9");
    await tapTrigger(tester);
    expect(
      find.text("发现新版本 9.9.9"),
      findsOneWidget,
      reason: "检测到新版本必须有提示",
    );

    // 关掉弹窗收尾
    await tester.tap(find.text("稍后"));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await finish(tester);
  });

  testWidgets("点「稍后」→ 记住这个版本，同一版本不再弹", (tester) async {
    setNewVersion("9.9.9");
    await pumpHost(tester, onTap: MclashUpdatePrompt.maybePromptOnLaunch);
    await tapTrigger(tester);
    expect(find.text("发现新版本 9.9.9"), findsOneWidget);

    await tester.tap(find.text("稍后"));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      SettingManager.getConfig().dismissedUpdateVersion,
      "9.9.9",
      reason: "点过「稍后」的版本要落进设置，重启后也不再弹",
    );

    // 再触发一次：安静
    await tapTrigger(tester);
    expect(find.text("发现新版本 9.9.9"), findsNothing);
    await finish(tester);
  });

  testWidgets("安装包已在后台下好 → 「立即更新」直接进安装页", (tester) async {
    setNewVersion("9.9.9");
    AutoUpdateManager.debugCheckReplaceOverride =
        () async => "/tmp/Mclash-macos-arm64-9.9.9.dmg";

    await pumpHost(tester, onTap: MclashUpdatePrompt.maybePromptOnLaunch);
    await tapTrigger(tester);
    expect(find.textContaining("安装包已在后台下载完成"), findsOneWidget);

    await tester.tap(find.text("立即更新"));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(
      find.byType(VersionUpdateScreen),
      findsOneWidget,
      reason: "后台无感下载完成后，点「立即更新」应直接进安装页",
    );
    expect(openedUrls, isEmpty, reason: "已下好就不该再让用户手动下载");
    await finish(tester);
  });

  testWidgets("还没下好 → 给下载页入口，地址是适合本机架构的那个安装包", (tester) async {
    const assetUrl =
        "https://github.com/moneyfly004/Mclash/releases/download/v9.9.9/"
        "Mclash-macos-arm64-9.9.9.dmg";
    setNewVersion("9.9.9", url: assetUrl);
    AutoUpdateManager.debugCheckReplaceOverride = () async => null;

    await pumpHost(tester, onTap: MclashUpdatePrompt.maybePromptOnLaunch);
    await tapTrigger(tester);
    await tester.tap(find.text("立即更新"));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    // 等不到后台下载（测试里上限 0）→ 弹确认，点确定打开下载页
    expect(find.textContaining("安装包还没下载完成"), findsOneWidget);
    final confirmButtons = find.descendant(
      of: find.byType(SimpleDialog),
      matching: find.byType(ElevatedButton),
    );
    await tester.tap(confirmButtons.last); // 取消 | 确定
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      openedUrls,
      [assetUrl],
      reason: "手动更新必须能点到「我的项目里适合本机架构」的那个安装包",
    );
    await finish(tester);
  });

  testWidgets("手动「检查更新」：已是最新 → 如实说已是最新", (tester) async {
    MclashUpdateCheck.debugLatestOverride = () async => null;
    await pumpHost(tester, onTap: MclashUpdatePrompt.checkManually);
    await tapTrigger(tester);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(seconds: 1));

    expect(find.textContaining("已是最新版本"), findsOneWidget);
    await finish(tester);
  });

  testWidgets("手动「检查更新」：有新版本 → 弹提示并给出更新入口", (tester) async {
    MclashUpdateCheck.debugLatestOverride = () async => const MclashUpdateInfo(
      tag: "v9.9.9",
      version: "9.9.9",
      notes: "修了若干问题",
      assetName: "Mclash-macos-arm64-9.9.9.dmg",
      downloadUrl: "https://example.invalid/Mclash-9.9.9.dmg",
      assetSize: 1024,
      sha256: "",
    );
    AutoUpdateManager.debugCheckReplaceOverride = () async => null;

    await pumpHost(tester, onTap: MclashUpdatePrompt.checkManually);
    await tapTrigger(tester);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(seconds: 1));

    expect(find.text("发现新版本 9.9.9"), findsOneWidget);
    expect(find.textContaining("修了若干问题"), findsOneWidget, reason: "更新说明要能看到");

    await tester.tap(find.text("稍后"));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await finish(tester);
  });
}
