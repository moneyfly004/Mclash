import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mclash/app/clash/clash_http_api.dart';
import 'package:mclash/i18n/strings.g.dart';
import 'package:mclash/mf/mclash_account_service.dart';
import 'package:mclash/screens/devices/mclash_devices_screen.dart';
import 'package:mclash/screens/mclash_change_password_screen.dart';
import 'package:mclash/screens/mclash_orders_screen.dart';
import 'package:mclash/mf/mclash_update_check.dart';
import 'package:mclash/screens/mclash_profile_screen.dart';
import 'package:mclash/screens/mclash_update_prompt.dart';

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
    ClashHttpApi.getControlPort = () => 9090;
    ClashHttpApi.getSecret = () => "test";
  });

  tearDown(() {
    MclashAccountService.instance.debugSetData(null, null);
    ClashHttpApi.getControlPort = null;
    ClashHttpApi.getSecret = null;
  });

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

  Future<void> finish(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 50));
  }

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

    expect(find.text("账户余额"), findsOneWidget);
    expect(find.text("test"), findsWidgets, reason: '订阅卡显示套餐名');
    expect(find.text("到期时间"), findsOneWidget);
    expect(find.text("剩余天数"), findsOneWidget);
    expect(find.text("设备数"), findsOneWidget);
    expect(find.text("我的订单"), findsOneWidget);
    expect(find.text("设备管理"), findsOneWidget);

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

    expect(
      find.byType(SimpleDialog),
      findsOneWidget,
      reason: '退出登录必须先弹确认框',
    );
    expect(find.textContaining("确认退出"), findsOneWidget,
        reason: '确认框要写清后果');
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

  testWidgets('逐行点一遍：每行都要有事发生（不能点了没反应）', (tester) async {
    final rows = <String, List<String>>{
      "我的订单": ["我的订单", "My Orders"],
      "设备管理": ["设备管理", "Devices"],
      "修改密码": ["修改密码", "Change Password"],
      "检查更新": ["检查更新"],
      "控制面板": ["面板", "Board"],
      "网络检测": ["网络检测", "Network Check"],
      "日志": ["日志", "Log"],
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

  group('布局稳定（不抖动）', () {
    testWidgets('加载中与加载完：头部占位一致，卡片位置不移动', (tester) async {
      await pump(tester);
      final loadedTop = tester.getRect(find.byType(Card).first).top;
      final loadedHeader = tester.getRect(find.byIcon(Icons.refresh));

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

class _RecordingObserver extends NavigatorObserver {
  _RecordingObserver(this.onPush);

  final void Function(String name) onPush;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    onPush(route.settings.name ?? route.runtimeType.toString());
  }
}
