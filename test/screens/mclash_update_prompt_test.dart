import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mclash/app/modules/auto_update_manager.dart';
import 'package:mclash/app/modules/setting_manager.dart';
import 'package:mclash/i18n/strings.g.dart';
import 'package:mclash/mf/mclash_update_check.dart';
import 'package:mclash/screens/mclash_update_prompt.dart';
import 'package:mclash/screens/version_update_screen.dart';

void main() {
  late List<String> openedUrls;

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

  Future<void> finish(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 50));
  }

  Future<void> tapTrigger(WidgetTester tester) async {
    await tester.tap(find.text("TAP"));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  testWidgets("有新版本 → 提示；没有新版本 → 不打扰", (tester) async {
    await pumpHost(
      tester,
      onTap: MclashUpdatePrompt.maybePromptOnLaunch,
    );
    await tapTrigger(tester);
    expect(find.textContaining("发现新版本"), findsNothing);

    setNewVersion("9.9.9");
    await tapTrigger(tester);
    expect(
      find.text("发现新版本 9.9.9"),
      findsOneWidget,
      reason: "检测到新版本必须有提示",
    );

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

    expect(find.textContaining("安装包还没下载完成"), findsOneWidget);
    final confirmButtons = find.descendant(
      of: find.byType(SimpleDialog),
      matching: find.byType(ElevatedButton),
    );
    await tester.tap(confirmButtons.last); 
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      openedUrls,
      [assetUrl],
      reason: "手动更新必须能点到「我的项目里适合本机架构」的那个安装包",
    );
    await finish(tester);
  });

  Future<void> pumpNestedHost(
    WidgetTester tester, {
    required Future<void> Function(BuildContext context) onTap,
  }) async {
    await tester.pumpWidget(
      TranslationProvider(
        child: MaterialApp(
          home: Navigator(
            key: GlobalKey<NavigatorState>(),
            onGenerateRoute: (_) => MaterialPageRoute(
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
      ),
    );
    await tester.pump();
  }

  testWidgets("嵌套导航（真实 App 结构）：检查更新后 loading 一定会关掉", (tester) async {
    MclashUpdateCheck.debugLatestOverride = () async => null;
    await pumpNestedHost(tester, onTap: MclashUpdatePrompt.checkManually);
    await tester.tap(find.text("TAP"));
    await tester.pump();
    expect(
      find.text("正在检查更新…"),
      findsOneWidget,
      reason: '点了就应该有 loading 反馈',
    );

    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));
    expect(
      find.text("正在检查更新…"),
      findsNothing,
      reason: '检查完成后 loading 必须关掉（旧实现在嵌套导航下会一直卡住）',
    );
    expect(find.textContaining("已是最新版本"), findsOneWidget);
    await finish(tester);
  });

  testWidgets("检查卡住（网络无响应）→ 超时后自动关掉 loading 并给失败提示", (tester) async {
    MclashUpdateCheck.debugLatestOverride =
        () => Completer<MclashUpdateInfo?>().future;
    await pumpNestedHost(tester, onTap: MclashUpdatePrompt.checkManually);
    await tester.tap(find.text("TAP"));
    await tester.pump();
    expect(find.text("正在检查更新…"), findsOneWidget);

    await tester.pump(MclashUpdatePrompt.kManualCheckTimeout);
    await tester.pump(const Duration(milliseconds: 100));
    expect(
      find.text("正在检查更新…"),
      findsNothing,
      reason: '超时后必须关掉 loading，不能让用户永远转圈',
    );
    expect(find.textContaining("检查更新失败"), findsOneWidget);
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
