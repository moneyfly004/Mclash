import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mclash/i18n/strings.g.dart';
import 'package:mclash/mf/mclash_account_service.dart';
import 'package:mclash/screens/home_mclash_widgets.dart';
import 'package:mclash/screens/mclash_login_screen.dart';
import 'package:mclash/screens/mclash_profile_screen.dart';

/// 多语言布局冒烟：常用页面在**每种语言**下都不能溢出、也不能漏出中文。
///
/// 真机报障：中文界面正常，切换成其它语言（文案更长 / 阿拉伯语与波斯语还是 RTL）后布局就乱了。
/// 这里把每门语言都用真机窄屏宽度（360dp）渲染一遍，任何一个 RenderFlex overflow 都会让用例失败；
/// 另外对非中文语言扫一遍可见文案，防止硬编码中文又溜回来。
void main() {
  Map<String, dynamic> dash() => {
        "username": "454487210",
        "balance": 99858.81,
        "has_subscription": true,
        "subscription": {
          "package_name": "test",
          "device_limit": 20,
          "current_devices": 6,
          "is_active": true,
          "status": "active",
          "expire_time": "2028-06-25T12:44:45Z",
        },
      };

  Map<String, dynamic> sub() => {
        "package_name": "test",
        "days_remaining": 620,
        "expire_at": "2028-06-25",
        "device_limit": 20,
        "current_devices": 6,
        "is_active": true,
        "status": "active",
        "subscription_url": "https://example.invalid/sub",
      };

  setUp(() {
    MclashAccountService.instance.debugSetData(dash(), sub());
  });

  tearDown(() {
    MclashAccountService.instance.debugSetData(null, null);
  });

  /// 非中文语言里绝不该出现的简体中文词（日/韩里这些写法也不成立）。
  const chineseLeftovers = <String>[
    "设置",
    "登录",
    "订阅",
    "设备",
    "节点",
    "订单",
    "套餐",
    "密码",
    "清除",
    "语言",
    "到期",
    "首页",
    "连接",
    "当前",
    "刷新",
  ];

  Future<void> useLocale(WidgetTester tester, AppLocale locale) async {
    // 语言包是 deferred 的，必须走真实异步（fake async 里等不到 loadLibrary）。
    await tester.runAsync(() => LocaleSettings.setLocale(locale));
  }

  Future<void> pump(
    WidgetTester tester,
    Widget child, {
    double width = 360,
  }) async {
    tester.view.physicalSize = Size(width * 3, 900 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      TranslationProvider(
        child: MaterialApp(
          locale: LocaleSettings.currentLocale.flutterLocale,
          supportedLocales: AppLocaleUtils.supportedLocales,
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          home: Scaffold(body: child),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 50));
  }

  Future<void> finish(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 50));
  }

  List<String> visibleTexts(WidgetTester tester) => tester
      .widgetList<Text>(find.byType(Text))
      .map((w) => w.data ?? w.textSpan?.toPlainText() ?? "")
      .where((s) => s.isNotEmpty)
      .toList();

  for (final locale in AppLocale.values) {
    final isChinese =
        locale == AppLocale.zhCn || locale == AppLocale.zhTw;

    testWidgets('${locale.name}：主页顶栏 / 我的 / 登录页都不溢出', (tester) async {
      await useLocale(tester, locale);

      for (final entry in <String, Widget>{
        "顶栏": const MclashHomeHeader(),
        "我的": const MclashProfileScreen(),
        "登录": const MclashLoginScreen(),
      }.entries) {
        await pump(tester, entry.value);
        expect(
          tester.takeException(),
          isNull,
          reason: '${locale.name} 的「${entry.key}」出现布局溢出',
        );
        if (!isChinese) {
          for (final s in visibleTexts(tester)) {
            for (final bad in chineseLeftovers) {
              expect(
                s.contains(bad),
                isFalse,
                reason: '${locale.name} 的「${entry.key}」仍显示中文「$s」',
              );
            }
          }
        }
        await finish(tester);
      }
    });
  }
}
