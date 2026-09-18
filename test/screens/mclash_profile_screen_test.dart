import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mclash/app/clash/clash_http_api.dart';
import 'package:mclash/i18n/strings.g.dart';
import 'package:mclash/mf/mclash_account_service.dart';
import 'package:mclash/screens/devices/mclash_devices_screen.dart';
import 'package:mclash/screens/file_view_screen.dart';
import 'package:mclash/screens/mclash_change_password_screen.dart';
import 'package:mclash/screens/mclash_orders_screen.dart';
import 'package:mclash/mf/mclash_update_check.dart';
import 'package:mclash/screens/mclash_profile_screen.dart';
import 'package:mclash/screens/mclash_update_prompt.dart';

/// 「我的」页的**逐按钮**验证。
///
/// 用户的要求：「我的 里面的功能按钮需要重新排版、分配，帮助可以不需要」，
/// 以及「验证每一个功能、每一个按钮、每一个点击」。所以这里：
///
///   * 断言分层结构（账户 → 订阅 → 应用设置 → 关于 → 退出）；
///   * 断言 **「帮助」已不存在**（明确的产品要求，不能只靠人眼）；
///   * **真的点每一个能点的行**，断言打开了对应页面；
///   * 断言退出登录会**先弹确认**（不能一点就掉线）。
///
/// 两个测试环境要点（第一版全红了，都是这两个原因）：
///   1. 必须套 `TranslationProvider` —— 真实 App 在 main.dart 里套了，
///      否则 `DialogUtils` 内部的 `Translations.of` 会抛异常；
///   2. 页面是 `ListView`（**懒加载**），800×600 视口里下半部分根本不会构建 ——
///      所以断言/点击下半部分的行之前，必须像真人一样先滚动。
///
/// 另外测试环境的界面语言是英文，而文案走 i18n，所以断言用**中英双语**匹配。
const Map<String, List<String>> kRowLabels = {
  "settingApp": ["应用设置", "App Settings"],
  "settingCore": ["核心设置", "Core Settings"],
  "about": ["关于", "About"],
  "quit": ["退出", "Quit"],
  "help": ["帮助", "Help"],
};

Finder textAnyOf(List<String> candidates) => find.byWidgetPredicate(
  (w) => w is Text && candidates.contains(w.data),
);

List<String> visibleTexts(WidgetTester tester) => tester
    .widgetList<Text>(find.byType(Text))
    .map((t) => t.data ?? "")
    .toList();

void main() {
  setUp(() {
    // 真实形状的账号数据（否则设备数等显示占位符）
    MclashAccountService.instance.debugSetData({
      "username": "454487210",
      "balance": 100000.87,
      "has_subscription": true,
      "device_count": 10,
      "subscription": {
        "device_limit": 500,
        "current_devices": 10,
        "is_active": true,
        "status": "active",
        "expire_time": "2028-06-25T12:44:45Z",
      },
    }, {
      "package_name": "test",
      "days_remaining": 648,
      "expire_at": "2028-06-25",
      "device_limit": 500,
      "current_devices": 10,
      "is_active": true,
      "status": "active",
      "subscription_url": "https://example.invalid/sub",
    });
    // 页面初始化会问内核要数据：给上回调，避免拼出 http://127.0.0.1:null
    ClashHttpApi.getControlPort = () => 9090;
    ClashHttpApi.getSecret = () => "test";
  });

  tearDown(() {
    MclashAccountService.instance.debugSetData(null, null);
    ClashHttpApi.getControlPort = null;
    ClashHttpApi.getSecret = null;
  });

  /// 路由观察者：数「有没有发生跳转」必须看 push 事件 ——
  /// push 之后旧路由会被从树里移除，`find.byType(Scaffold)` 的个数并不可靠。
  final pushed = <String>[];

  Future<void> pump(WidgetTester tester) async {
    pushed.clear();
    await tester.pumpWidget(
      TranslationProvider(
        child: MaterialApp(
          home: const MclashProfileScreen(),
          navigatorObservers: [
            _RecordingObserver((name) => pushed.add(name)),
          ],
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));
  }

  /// 收尾：跑完网络超时定时器 → 卸载组件树触发 dispose
  /// （`LasyRenderingState.dispose` 会经 `AppRouteObserver.popRoute` 排一个 1ms
  ///  定时器，不跑完的话框架会判「Pending timers」——那是脚手架时序，不是页面缺陷）。
  Future<void> finish(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 50));
  }

  /// 滚到目标可见（ListView 懒加载：不滚动就压根没构建）
  Future<void> scrollTo(WidgetTester tester, Finder target) async {
    await tester.scrollUntilVisible(
      target,
      120,
      scrollable: find.byType(Scrollable).first,
      maxScrolls: 30,
    );
    await tester.pump(const Duration(milliseconds: 50));
  }

  testWidgets('分层结构：账户 → 订阅 → 应用设置 → 关于 → 退出', (tester) async {
    await pump(tester);

    // 首屏：账户卡与订阅卡
    expect(find.text("账户余额"), findsOneWidget);
    expect(find.text("test"), findsWidgets, reason: '订阅卡显示套餐名');
    expect(find.text("到期时间"), findsOneWidget);
    expect(find.text("剩余天数"), findsOneWidget);
    expect(find.text("设备数"), findsOneWidget);
    expect(find.text("我的订单"), findsOneWidget);
    expect(find.text("设备管理"), findsOneWidget);

    // 下半屏：应用设置 / 关于 / 退出（需滚动，ListView 懒加载）
    await scrollTo(tester, textAnyOf(kRowLabels["settingApp"]!));
    expect(textAnyOf(kRowLabels["settingApp"]!), findsOneWidget);
    expect(textAnyOf(kRowLabels["settingCore"]!), findsOneWidget);
    await scrollTo(tester, textAnyOf(kRowLabels["about"]!));
    expect(textAnyOf(kRowLabels["about"]!), findsOneWidget);
    await scrollTo(tester, textAnyOf(kRowLabels["quit"]!));
    expect(textAnyOf(kRowLabels["quit"]!), findsOneWidget);

    await finish(tester);
  });

  testWidgets('「帮助」必须已移除（产品要求）', (tester) async {
    await pump(tester);

    final seen = <String>{};
    seen.addAll(visibleTexts(tester));
    // 从头滚到底，收集途中出现过的所有文案
    for (var i = 0; i < 8; i++) {
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -300));
      await tester.pump(const Duration(milliseconds: 50));
      seen.addAll(visibleTexts(tester));
    }

    for (final label in kRowLabels["help"]!) {
      expect(
        seen.contains(label),
        isFalse,
        reason: '用户明确要求「帮助可以不需要」，整页都不该出现 "$label"',
      );
    }
    await finish(tester);
  });

  testWidgets('点「我的订单」→ 打开订单页', (tester) async {
    await pump(tester);
    await tester.tap(find.text("我的订单"));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(MclashOrdersScreen), findsOneWidget);
    await finish(tester);
  });

  testWidgets('点「设备管理」→ 打开设备页', (tester) async {
    await pump(tester);
    await tester.tap(find.text("设备管理"));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(MclashDevicesScreen), findsOneWidget);
    await finish(tester);
  });

  testWidgets('点「检查更新」→ 手动查一次并给结论（已是最新/发现新版本）', (tester) async {
    MclashUpdateCheck.debugLatestOverride = () async => null;
    MclashUpdatePrompt.debugReset();
    addTearDown(() {
      MclashUpdateCheck.debugLatestOverride = null;
      MclashUpdatePrompt.debugReset();
    });
    await pump(tester);
    final target = find.text("检查更新");
    await scrollTo(tester, target);
    expect(target, findsOneWidget, reason: '手动检查更新的入口必须常驻在「我的」页');
    await tester.tap(target);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(seconds: 1));
    expect(find.textContaining("已是最新版本"), findsOneWidget);
    await finish(tester);
  });

  testWidgets('点「修改密码」→ 打开改密页', (tester) async {
    await pump(tester);
    final target = find.text("修改密码");
    await scrollTo(tester, target);
    await tester.tap(target);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(MclashChangePasswordScreen), findsOneWidget);
    await finish(tester);
  });

  testWidgets('点「退出」→ 先弹确认（不能一点就掉线）', (tester) async {
    await pump(tester);
    final target = textAnyOf(kRowLabels["quit"]!);
    await scrollTo(tester, target);
    await tester.tap(target);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // 确认框用的是 ClashMi 的 SimpleDialog 家族（DialogUtils.showConfirmDialog），
    // 不是 Material 的 AlertDialog。
    expect(
      find.byType(SimpleDialog),
      findsOneWidget,
      reason: '退出登录必须先弹确认框',
    );
    expect(find.textContaining("确认退出"), findsOneWidget,
        reason: '确认框要写清后果');
    await finish(tester);
  });

  testWidgets('点「运行时配置」：文件缺失时给友好提示（不是报错崩掉）', (tester) async {
    // 用户实测反馈：「我的 → 运行时配置」一点就报错。
    // 真实原因：内核还没启动过 → 运行时配置文件不存在。这里注入 reader 返回
    // null（=文件不存在），断言**弹出的是人话提示**而不是异常文本。
    final seen = <String?>[];
    mclashRuntimeProfileReader = () async {
      seen.add("called");
      return null;
    };

    await pump(tester);
    final target = textAnyOf(["运行时配置", "Runtime Profile"]);
    await scrollTo(tester, target);
    await tester.tap(target);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(seen, isNotEmpty, reason: '必须真的走到「读运行时配置」这一步');
    expect(find.byType(SimpleDialog), findsOneWidget);
    expect(
      find.textContaining("还没有生成运行时配置"),
      findsOneWidget,
      reason: '缺失要给人话解释 + 下一步怎么办，不能把异常直接丢给用户',
    );

    mclashRuntimeProfileReader = null;
    await finish(tester);
  });

  testWidgets('点「运行时配置」：文件为空时同样给友好提示', (tester) async {
    mclashRuntimeProfileReader = () async => "   \n  ";

    await pump(tester);
    final target = textAnyOf(["运行时配置", "Runtime Profile"]);
    await scrollTo(tester, target);
    await tester.tap(target);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(SimpleDialog), findsOneWidget);
    expect(find.textContaining("运行时配置当前为空"), findsOneWidget);

    mclashRuntimeProfileReader = null;
    await finish(tester);
  });

  testWidgets('点「运行时配置」：有内容时打开查看页（不是弹窗）', (tester) async {
    mclashRuntimeProfileReader = () async => "mixed-port: 7890\n";

    await pump(tester);
    final target = textAnyOf(["运行时配置", "Runtime Profile"]);
    await scrollTo(tester, target);
    await tester.tap(target);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(SimpleDialog), findsNothing);
    // 查看页是代码编辑器（re_editor）渲染的，不是普通 Text，
    // 所以断言「页面已打开 + 拿到的就是文件内容」而不是找文本。
    expect(find.byType(FileViewScreen), findsOneWidget);
    expect(
      tester.widget<FileViewScreen>(find.byType(FileViewScreen)).content,
      contains("mixed-port: 7890"),
      reason: '必须把文件真实内容交给查看页，不能打开一个空页面',
    );

    mclashRuntimeProfileReader = null;
    await finish(tester);
  });

  testWidgets('「通知」必须已移除（产品要求：该功能不可用，直接删掉）', (tester) async {
    await pump(tester);

    final seen = <String>{};
    seen.addAll(visibleTexts(tester));
    for (var i = 0; i < 8; i++) {
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -300));
      await tester.pump(const Duration(milliseconds: 50));
      seen.addAll(visibleTexts(tester));
    }
    for (final label in ["通知", "Notice"]) {
      expect(
        seen.contains(label),
        isFalse,
        reason: '通知功能已按要求整体删除，不能还留着入口（出现过：$label）',
      );
    }

    await finish(tester);
  });

  /// 「我的」里**每一个可点行都要有点反应**（打开页面 / 弹提示 / 弹面板）。
  ///
  /// 用户要求：「检查我里边所有的按钮，所有的选项，它的作用，有些有问题的，
  /// 帮我解决」。这里不是断言「有没有这一行」，而是逐个点下去看结果 ——
  /// 点不动、点了没反应、或者直接把异常文本弹出来，都算问题。
  testWidgets('逐行点一遍：每行都要有事发生（不能点了没反应）', (tester) async {
    // 测试环境的界面语言是英文，而这些文案走 i18n（部分是我们后加的硬编码中文），
    // 所以每行都用「中英任选其一」来定位。
    final rows = <String, List<String>>{
      "我的订单": ["我的订单", "My Orders"],
      "设备管理": ["设备管理", "Devices"],
      "修改密码": ["修改密码", "Change Password"],
      "连接自检": ["连接自检"],
      "检查更新": ["检查更新"],
      "控制面板": ["面板", "Board"],
      "网络检测": ["网络检测", "Network Check"],
      "核心日志": ["核心日志", "Core Log"],
      "运行时配置": ["运行时配置", "Runtime Profile"],
      "应用设置": ["应用设置", "App Settings"],
      "核心设置": ["核心设置", "Core Settings"],
      "备份与同步": ["备份与同步", "Backup and Sync"],
      "关于": ["关于", "About"],
    };
    for (final entry in rows.entries) {
      await pump(tester);
      final finder = textAnyOf(entry.value);
      await scrollTo(tester, finder);
      await tester.tap(finder);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump(const Duration(seconds: 1));

      // 「有事发生」= 发生了一次路由 push，或出现了弹窗/底部面板
      final hasRoute = pushed.isNotEmpty;
      final hasDialog =
          find.byType(SimpleDialog).evaluate().isNotEmpty ||
          find.byType(AlertDialog).evaluate().isNotEmpty ||
          find.byType(Dialog).evaluate().isNotEmpty;
      final hasSheet = find.byType(BottomSheet).evaluate().isNotEmpty;
      expect(
        hasRoute || hasDialog || hasSheet,
        isTrue,
        reason: '「${entry.key}」点下去没有任何反应（页面/弹窗都没出现）',
      );
      await finish(tester);
    }
  });

  // 用户反馈：「我的页面也会出现 UI 抖动的问题，帮我固定位置」。
  // 根因：头部那个位置在「加载中(20×20 转圈)」和「加载完(44×44 刷新图标)」之间
  // 切换，一次刷新的高度差 24px，整页内容跟着上下跳。
  group('布局稳定（不抖动）', () {
    testWidgets('加载中与加载完：头部占位一致，卡片位置不移动', (tester) async {
      await pump(tester);
      final loadedTop = tester.getRect(find.byType(Card).first).top;
      final loadedHeader = tester.getRect(find.byIcon(Icons.refresh));

      // 再点一次刷新：进入加载态。此时头部必须还是 44×44
      // （旧实现这里会缩成 20×20，整页上移 24px）。
      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pump();

      final duringTop = tester.getRect(find.byType(Card).first).top;
      expect(
        duringTop,
        closeTo(loadedTop, 0.5),
        reason: '刷新期间卡片位置不能移动（旧实现在这里跳 24px）',
      );

      await tester.pump(const Duration(seconds: 1));
      expect(
        tester.getRect(find.byType(Card).first).top,
        closeTo(loadedTop, 0.5),
        reason: '刷新完成后也不能移动',
      );
      // 头部占位在两个状态下一致：图标消失时，那个位置仍是同样的高度
      final afterHeader = tester.getRect(find.byIcon(Icons.refresh));
      expect(afterHeader.height, closeTo(loadedHeader.height, 0.5));
      expect(afterHeader.width, closeTo(loadedHeader.width, 0.5));
      await finish(tester);
    });

    testWidgets('已有数据时刷新是静默的：不弹转圈、不插错误卡', (tester) async {
      await pump(tester);
      final cardsBefore = find.byType(Card).evaluate().length;
      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pump();
      expect(
        find.byType(CircularProgressIndicator),
        findsNothing,
        reason: '已有数据时刷新不该出现转圈（页面不该跳）',
      );
      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(Card).evaluate().length, cardsBefore);
      await finish(tester);
    });
  });

  testWidgets('面板改了设备上限/到期时间 → 账号服务一更新，「我的」页面跟着变', (tester) async {
    await pump(tester);
    expect(find.text("2028-06-25"), findsWidgets, reason: '先显示旧到期时间');
    expect(find.text("10 / 500"), findsWidgets, reason: '先显示旧设备上限');

    // 模拟「账号服务取到了面板的新值」（管理员在后台改了上限与到期时间）
    MclashAccountService.instance.debugSetData({
      "username": "454487210",
      "balance": 100000.87,
      "has_subscription": true,
      "device_count": 3,
      "subscription": {
        "device_limit": 5,
        "current_devices": 3,
        "is_active": true,
        "status": "active",
        "expire_time": "2029-01-01T12:44:45Z",
      },
    }, {
      "package_name": "test",
      "days_remaining": 900,
      "expire_at": "2029-01-01",
      "device_limit": 5,
      "current_devices": 3,
      "is_active": true,
      "status": "active",
      "subscription_url": "https://example.invalid/sub",
    });
    await tester.pump();

    expect(
      find.text("2029-01-01"),
      findsWidgets,
      reason: '账号更新后必须重建页面，否则后台改了到期时间这里还是旧的',
    );
    expect(find.text("2028-06-25"), findsNothing);
    expect(find.text("3 / 5"), findsWidgets);
    await finish(tester);
  });
}

/// 只记录 push 的路由观察者（测试用）。
class _RecordingObserver extends NavigatorObserver {
  _RecordingObserver(this.onPush);

  final void Function(String name) onPush;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    onPush(route.settings.name ?? route.runtimeType.toString());
  }
}
