import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mclash/app/utils/app_utils.dart';
import 'package:mclash/i18n/strings.g.dart';
import 'package:mclash/mf/mclash_account_service.dart';
import 'package:mclash/screens/home_mclash_widgets.dart';

/// 回归：主页顶栏（软件名 + 到期/设备信息条）在**每种语言**下都不能乱。
///
/// 真机报障：中文界面下排列正常，切成其它语言（文案更长 / 阿拉伯语是 RTL）后顶栏就乱了。
/// 根因：原来用 `Wrap(spaceBetween)` + 不设上限的 `Text`，长文案既不会换行也不会省略，
/// 直接把内容顶出屏幕；刷新提示还硬写了 `left: 32`（RTL 语言下缩进跑错边）。
void main() {
  Map<String, dynamic> dash({String expire = "2028-06-25"}) => {
        "username": "454487210",
        "balance": 100,
        "has_subscription": true,
        "subscription": {
          "package_name": "test",
          "device_limit": 20,
          "current_devices": 4,
          "is_active": true,
          "status": "active",
          "expire_time": "${expire}T12:44:45Z",
        },
      };

  Map<String, dynamic> sub({String expire = "2028-06-25"}) => {
        "package_name": "test",
        "days_remaining": 647,
        "expire_at": expire,
        "device_limit": 20,
        "current_devices": 4,
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

  /// 语言包是 deferred 的，切换必须走真实异步（fake async 里等不到 loadLibrary）。
  Future<void> useLocale(WidgetTester tester, AppLocale locale) async {
    await tester.runAsync(() => LocaleSettings.setLocale(locale));
  }

  Future<void> pumpHeader(WidgetTester tester, double width) async {
    tester.view.physicalSize = Size(width * 3, 900 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      TranslationProvider(
        // 与真实 App 一致：传 locale + 全局本地化代理，阿拉伯语/波斯语才会进 RTL 方向。
        child: MaterialApp(
          locale: LocaleSettings.currentLocale.flutterLocale,
          supportedLocales: AppLocaleUtils.supportedLocales,
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          home: const Scaffold(body: MclashHomeHeader()),
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

  /// 顶栏两块内容不能重叠：要么左右分开，要么上下分开。
  void expectNoOverlap(WidgetTester tester) {
    final brand = tester.getRect(find.text(AppUtils.getName()));
    final pill = tester.getRect(find.byKey(const ValueKey("home-sub-pill")));
    final apartHorizontally =
        brand.right <= pill.left + 0.5 || pill.right <= brand.left + 0.5;
    final apartVertically =
        brand.bottom <= pill.top + 0.5 || pill.bottom <= brand.top + 0.5;
    expect(
      apartHorizontally || apartVertically,
      isTrue,
      reason: '品牌块 $brand 与信息条 $pill 重叠了',
    );
  }

  for (final locale in AppLocale.values) {
    testWidgets('${locale.name}：顶栏不溢出、不出屏、不重叠（360px 手机宽）',
        (tester) async {
      await useLocale(tester, locale);
      await pumpHeader(tester, 360);

      expect(
        tester.takeException(),
        isNull,
        reason: '${locale.name} 下出现 RenderFlex overflow 之类的布局异常',
      );

      final pill = tester.getRect(find.byKey(const ValueKey("home-sub-pill")));
      final freshness = tester.getRect(
        find.byKey(const ValueKey("home-freshness")),
      );
      expect(pill.left, greaterThanOrEqualTo(-0.5), reason: '信息条不能出屏（左）');
      expect(pill.right, lessThanOrEqualTo(360.5), reason: '信息条不能出屏（右）');
      expect(freshness.right, lessThanOrEqualTo(360.5), reason: '刷新提示不能出屏');
      expectNoOverlap(tester);

      await finish(tester);
    });
  }

  testWidgets('RTL（阿拉伯语）：品牌在右、信息条在左，箭头也跟着镜像', (tester) async {
    await useLocale(tester, AppLocale.ar);
    await pumpHeader(tester, 900);

    final brand = tester.getCenter(find.text(AppUtils.getName()));
    final pill = tester.getCenter(find.byKey(const ValueKey("home-sub-pill")));
    expect(brand.dx, greaterThan(pill.dx), reason: 'RTL 下顺序应镜像');

    await finish(tester);
  });

  testWidgets('LTR（英文）：品牌在左、信息条在右（与中文一致）', (tester) async {
    await useLocale(tester, AppLocale.en);
    await pumpHeader(tester, 900);

    final brand = tester.getCenter(find.text(AppUtils.getName()));
    final pill = tester.getCenter(find.byKey(const ValueKey("home-sub-pill")));
    expect(brand.dx, lessThan(pill.dx), reason: '英文下与中文同样的顺序');

    await finish(tester);
  });

  for (final scale in <double>[1.3, 2.0]) {
    testWidgets('字体放大 ${scale}x（等于文案变长）：顶栏照样不溢出、不重叠', (tester) async {
      await useLocale(tester, AppLocale.ru);
      tester.view.physicalSize = const Size(360 * 3, 900 * 3);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        TranslationProvider(
          child: MaterialApp(
            locale: LocaleSettings.currentLocale.flutterLocale,
            supportedLocales: AppLocaleUtils.supportedLocales,
            localizationsDelegates: GlobalMaterialLocalizations.delegates,
            home: MediaQuery(
              data: MediaQueryData(textScaler: TextScaler.linear(scale)),
              child: const Scaffold(
                body: SingleChildScrollView(child: MclashHomeHeader()),
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 50));

      expect(
        tester.takeException(),
        isNull,
        reason: '字体放大 ${scale}x 后出现布局溢出（长文案语言就是这个效果）',
      );
      final pill = tester.getRect(find.byKey(const ValueKey("home-sub-pill")));
      expect(pill.right, lessThanOrEqualTo(360.5), reason: '信息条出屏了');
      expectNoOverlap(tester);

      await finish(tester);
    });
  }

  testWidgets('页面开着切语言：顶栏文案立刻跟着变（不是进去才刷新）', (tester) async {
    await useLocale(tester, AppLocale.zhCn);
    await pumpHeader(tester, 900);
    expect(find.textContaining("到期"), findsOneWidget);

    await useLocale(tester, AppLocale.en);
    await tester.pump();

    expect(find.textContaining("Expires"), findsOneWidget);
    expect(find.textContaining("到期"), findsNothing);
    expect(find.textContaining("Devices 4/20"), findsOneWidget);

    await finish(tester);
  });
}
