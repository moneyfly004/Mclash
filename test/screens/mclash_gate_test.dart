import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mclash/app/modules/setting_manager.dart';
import 'package:mclash/mf/cboard_client.dart';
import 'package:mclash/screens/mclash_gate.dart';
import 'package:mclash/screens/mclash_login_screen.dart';

Future<void> _disposeAndSettleTimers(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(milliseconds: 50));
}

void main() {
  group('stageFor：首屏阶段判定', () {
    test('未判定（restore 未完成）→ 加载态，不能直接给登录页', () {
      expect(stageFor(null), MclashGateStage.loading);
    });

    test('未登录 → 登录页（这是需求的核心）', () {
      expect(stageFor(false), MclashGateStage.login);
    });

    test('已登录 → 主界面', () {
      expect(stageFor(true), MclashGateStage.main);
    });

    test('已登录但还在拉配置 → 准备页（不能先放进去再让用户干等）', () {
      expect(
        stageFor(true, preparing: true),
        MclashGateStage.preparing,
        reason: '登录成功 ≠ 能用：没有配置档时主页没有节点、点连接必然失败',
      );
    });

    test('拉配置失败 → 失败页（有重试），不能静默进主界面', () {
      expect(
        stageFor(true, prepareFailed: true),
        MclashGateStage.prepareFailed,
      );
    });

    test('未登录时准备态不生效（登录页优先）', () {
      expect(
        stageFor(false, preparing: true, prepareFailed: true),
        MclashGateStage.login,
      );
    });
  });

  group('登录页「保存账号信息」', () {
    testWidgets('默认勾选，取消后写进设置（下次打开停在登录窗口）', (tester) async {
      SettingManager.getConfig().rememberAccount = true;
      CBoardSessionStore.rememberOverride = () => false;

      await tester.pumpWidget(const MaterialApp(home: MclashLoginScreen()));
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('保存账号信息'), findsOneWidget, reason: '登录页必须有这个开关');
      expect(find.text('下次打开自动登录'), findsOneWidget);

      final box = tester.widget<CheckboxListTile>(find.byType(CheckboxListTile));
      expect(box.value, isTrue, reason: '默认应为勾选（保持既有行为）');

      await tester.tap(find.byType(CheckboxListTile));
      await tester.pump(const Duration(milliseconds: 50));

      expect(
        SettingManager.getConfig().rememberAccount,
        isFalse,
        reason: '取消勾选必须落到设置里，下次启动才知道不该自动登录',
      );
      expect(find.text('下次打开需要重新登录'), findsOneWidget);

      await _disposeAndSettleTimers(tester);
      SettingManager.getConfig().rememberAccount = true;
      CBoardSessionStore.rememberOverride = null;
    });
  });

  group('登录页真实渲染', () {
    testWidgets('含应用名、登录按钮、忘记密码入口与输入框', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: MclashLoginScreen()));
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('Mclash'), findsOneWidget, reason: '应有应用名标题');
      expect(find.text('登录'), findsOneWidget, reason: '应有登录按钮');
      expect(find.text('忘记密码'), findsOneWidget, reason: '应有忘记密码入口');
      expect(find.byType(TextField), findsWidgets, reason: '应有邮箱/密码输入框');

      await _disposeAndSettleTimers(tester);
    });

    testWidgets('邮箱为空时点登录会就地报错（不发起请求）', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: MclashLoginScreen()));
      await tester.pump(const Duration(milliseconds: 50));

      await tester.tap(find.text('登录'));
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('请填写有效邮箱'), findsOneWidget);
      await _disposeAndSettleTimers(tester);
    });
  });

  group('会话通知（门禁的驱动源）', () {
    test('sessionChanges 是可监听的会话变更通知，初始为未登录', () {
      expect(CBoardClient.sessionChanges, isA<ValueNotifier<bool>>());
      expect(CBoardClient.sessionChanges.value, isFalse);
    });
  });
}
