import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mclash/mf/cboard_client.dart';
import 'package:mclash/screens/mclash_gate.dart';
import 'package:mclash/screens/mclash_login_screen.dart';

/// 启动首屏的**决定性**验证。
///
/// 需求原文：「打开软件是进行语言设置，然后是登录账号……软件打开之后第一个页面
/// 应该是登录」。
///
/// 这件事不能靠看截图判断（窗口坐标、Retina 缩放、别的窗口遮挡都会误导 ——
/// 我排查时就被「截到了别的窗口」误导过一次），所以分两层钉死：
///
///   1. [stageFor] 纯函数：断言「未登录 → login」「已登录 → main」
///      「未判定 → loading」，不依赖任何原生插件；
///   2. 登录页真实渲染：断言页面上确实有登录按钮 / 忘记密码 / 输入框。
///
/// 不做「已登录时整棵树」的 widget 断言：`MainTabShell` 会构建 4 个 Tab 页面，
/// 依赖窗口管理、VPN 服务、托盘等原生插件，测试环境必然抛 MissingPluginException。
/// 硬测只会得到假红，或只能弱断言（「没看到登录页」也可能是因为整棵树构建失败），
/// 两种都不比第 1 层更可信。
/// 主动卸载组件树并把 dispose 期间排下的定时器跑掉。
///
/// `LasyRenderingState.dispose` 会经 `AppRouteObserver.popRoute` 排一个 1ms 定时器；
/// 如果留到测试 teardown 才卸载，框架会以「Pending timers」判失败 ——
/// 那是脚手架时序问题，不是页面缺陷。所以这里先换成空树触发 dispose，
/// 再 pump 足够时长让定时器落地。
Future<void> _disposeAndSettleTimers(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(milliseconds: 50));
}

void main() {
  group('stageFor：首屏阶段判定', () {
    test('未判定（restore 未完成）→ 加载态，不能直接给登录页', () {
      // 若这里返回 login，已登录用户每次冷启动都会先闪一下登录页
      expect(stageFor(null), MclashGateStage.loading);
    });

    test('未登录 → 登录页（这是需求的核心）', () {
      expect(stageFor(false), MclashGateStage.login);
    });

    test('已登录 → 主界面', () {
      expect(stageFor(true), MclashGateStage.main);
    });
  });

  group('登录页真实渲染', () {
    // 注：LasyRenderingState 在 dispose 时会排一个 1ms 定时器，
    // 用 pumpAndSettle 会因「仍有 pending timer」报错（测试脚手架问题，
    // 不是页面问题），所以统一用显式 pump。
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
      // 门禁监听它；登录 / 注册（后端注册即下发 token）/ 登出 / 刷新失败
      // 都会经 CBoardClient._setSession 这唯一出口发布。
      expect(CBoardClient.sessionChanges, isA<ValueNotifier<bool>>());
      expect(CBoardClient.sessionChanges.value, isFalse);
    });
  });
}
