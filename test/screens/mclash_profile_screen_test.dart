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

  Future<void> pump(WidgetTester tester) async {
    await tester.pumpWidget(
      TranslationProvider(child: const MaterialApp(home: MclashProfileScreen())),
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
}
