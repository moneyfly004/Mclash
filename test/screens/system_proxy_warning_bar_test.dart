import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mclash/app/local_services/vpn_service.dart';
import 'package:mclash/screens/home_screen_widgets.dart';
import 'package:mclash/i18n/strings.g.dart';

/// 回归：真机报障「系统代理没了，但软件还显示已连接」——
/// 界面上必须有醒目告警，不能再"默默不一致"。
void main() {

  // 固定语言：这些页面的文案现在走 i18n，而测试环境的语言取决于**宿主系统** ——
  // 不固定就会出现"英文机器挂、中文机器过"。这里固定简中，与断言里的中文一致。
  // ⚠️ zh-CN 是 deferred 加载的，只能在 setUpAll 里异步设置：放进 testWidgets 的
  //    fake async 里会永远等不到 loadLibrary（会把整套测试挂住）。
  setUpAll(() async {
    await LocaleSettings.setLocale(AppLocale.zhCn);
  });

  tearDown(() {
    VPNService.debugResetProxyWatchdogState();
  });

  Future<void> pumpBar(WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: SystemProxyWarningBar()),
      ),
    );
    await tester.pump();
  }

  testWidgets('没有告警时不占位置（不打扰正常用户）', (tester) async {
    VPNService.debugResetProxyWatchdogState();
    await pumpBar(tester);
    expect(find.text("重设"), findsNothing);
    expect(find.byIcon(Icons.warning_amber_rounded), findsNothing);
  });

  testWidgets('系统代理被别的程序关掉时，明确提示"流量没有经过代理"并给重设入口', (tester) async {
    VPNService.systemProxyWarning.value =
        "系统代理已被其它程序占用或关闭，Mclash 无法恢复 —— 当前流量没有经过代理。";
    await pumpBar(tester);

    expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
    expect(find.textContaining("没有经过代理"), findsOneWidget);
    expect(find.text("重设"), findsOneWidget, reason: '要能一键重设，而不是让用户去别处找');
  });

  testWidgets('自动恢复成功后告警自动消失', (tester) async {
    VPNService.systemProxyWarning.value = "系统代理被其它程序改动，已自动恢复（第 1 次）。";
    await pumpBar(tester);
    expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);

    VPNService.systemProxyWarning.value = "";
    await tester.pump();
    expect(find.byIcon(Icons.warning_amber_rounded), findsNothing);
  });
}
