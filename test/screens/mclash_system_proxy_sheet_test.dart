import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mclash/app/modules/clash_setting_manager.dart';
import 'package:mclash/i18n/strings.g.dart';
import 'package:mclash/mf/mclash_nodes_store.dart';
import 'package:mclash/screens/mclash_system_proxy_sheet.dart';

/// 「系统代理」面板的回归。
///
/// 用户反馈（Windows）：「连上之后系统代理是空白，无法改变 IP 和端口」。
/// 端口链路已在 VPNService 里修（以内核实际监听端口为准），但用户还需要一个
/// **能看见当前地址、能重设、能换端口**的地方 —— 就是这里要钉住的东西。
void main() {
  setUp(() {
    MclashNodesStore.instance.debugResetLoadState();
  });

  tearDown(() {
    debugSystemProxyStateOverride = null;
    debugSystemProxyApplyOverride = null;
    debugSetMixedPortOverride = null;
  });

  Future<void> pumpSheet(WidgetTester tester) async {
    await tester.pumpWidget(
      TranslationProvider(
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showMclashSystemProxySheet(context),
                child: const Text("open"),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text("open"));
    await tester.pumpAndSettle();
  }

  testWidgets('显示当前生效地址（用户要能看见，而不是只有日志）', (tester) async {
    debugSystemProxyStateOverride = () async => "已生效 · 127.0.0.1:2253";

    await pumpSheet(tester);

    expect(find.text("系统代理"), findsOneWidget);
    expect(find.textContaining("已生效 · 127.0.0.1:2253"), findsOneWidget);
    expect(
      find.textContaining("127.0.0.1"),
      findsWidgets,
      reason: '要写清地址固定是回环地址，端口才是变量',
    );

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 50));
  });

  testWidgets('「重新设置」会真的去设，并刷新状态', (tester) async {
    final calls = <bool>[];
    var state = "未生效（系统里没有指向 2253 的代理）";
    debugSystemProxyStateOverride = () async => state;
    debugSystemProxyApplyOverride = (enable) async {
      calls.add(enable);
      state = enable ? "已生效 · 127.0.0.1:2253" : "已关闭";
      return true;
    };

    await pumpSheet(tester);
    expect(find.textContaining("未生效"), findsOneWidget);

    await tester.tap(find.text("重新设置"));
    await tester.pumpAndSettle();

    expect(calls, [true]);
    expect(
      find.textContaining("已生效"),
      findsOneWidget,
      reason: '设置完必须刷新状态，否则用户不知道到底成没成',
    );

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 50));
  });

  testWidgets('可以关闭系统代理（用户改得动，不再只能被 App 覆盖）', (tester) async {
    final calls = <bool>[];
    debugSystemProxyStateOverride = () async => "已生效 · 127.0.0.1:2253";
    debugSystemProxyApplyOverride = (enable) async {
      calls.add(enable);
      return true;
    };

    await pumpSheet(tester);
    await tester.tap(find.text("关闭系统代理"));
    await tester.pumpAndSettle();

    expect(calls, [false]);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 50));
  });

  testWidgets('设置失败时把原因显示出来（不静默）', (tester) async {
    debugSystemProxyStateOverride = () async => "未生效";
    debugSystemProxyApplyOverride = (enable) async => false;

    await pumpSheet(tester);
    await tester.tap(find.text("重新设置"));
    await tester.pumpAndSettle();

    expect(find.textContaining("设置失败"), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 50));
  });

  testWidgets('改端口：写进设置并提示需要重连生效', (tester) async {
    final applied = <int>[];
    debugSystemProxyStateOverride = () async => "已生效 · 127.0.0.1:7890";
    debugSetMixedPortOverride = (port) async => applied.add(port);

    await pumpSheet(tester);
    await tester.tap(find.text("17890"));
    await tester.pumpAndSettle();

    expect(applied, [17890], reason: '预设端口要落到设置里');
    expect(
      find.textContaining("请断开重连一次"),
      findsOneWidget,
      reason: '内核监听端口由配置决定，必须明确告诉用户重连才生效',
    );

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 50));
  });

  testWidgets('非法端口被拒绝（不写坏值进设置）', (tester) async {
    final applied = <int>[];
    debugSystemProxyStateOverride = () async => "未生效";
    debugSetMixedPortOverride = (port) async => applied.add(port);

    await pumpSheet(tester);
    await tester.enterText(find.byType(TextField), "70000");
    await tester.tap(find.text("应用"));
    await tester.pumpAndSettle();

    expect(applied, isEmpty);
    expect(find.textContaining("1–65535"), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 50));
  });

  test('默认端口是有效值（不会出现「端口 0 → 系统代理空白」）', () {
    expect(
      ClashSettingManager.getMixedPort(),
      greaterThan(0),
      reason: '端口为 0 时系统代理会被跳过，这正是用户看到的「空白」',
    );
  });
}
