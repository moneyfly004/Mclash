import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mclash/app/modules/setting_manager.dart';
import 'package:mclash/i18n/strings.g.dart';
import 'package:mclash/screens/dialog_utils.dart';
import 'package:mclash/screens/mclash_tun_setting.dart';

/// 回归：**通用确认框**与 **TUN 模式弹层**在长文案语言 / RTL 语言下的排版。
///
/// 真机报障（多语言走查发现）：
///   1. 确认框「取消 / 确定」两个按钮用固定 `SizedBox(width: 60)` 居中 ——
///      西语在 360dp 手机上横向溢出 45px（俄语 2.9px），影响所有 `showConfirmDialog` 调用点；
///   2. TUN 模式弹层内容偏高，360×900 小屏上**英文就已经纵向溢出 32px**（西语 48px），
///      底部权限提示被挤掉。
/// 两处都改成自适应（OverflowBar / 限高可滚动），这里逐语言钉死。
void main() {
  setUp(() {
    SettingManager.getConfig().tunMode = SettingConfig.kTunModeOff;
  });

  Future<void> useLocale(WidgetTester tester, AppLocale locale) async {
    // 语言包是 deferred 的，必须走真实异步加载。
    await tester.runAsync(() => LocaleSettings.setLocale(locale));
  }

  /// 把宿主页面 pump 出来，返回一个可用 context 的引用点。
  Future<void> pumpHost(WidgetTester tester, {double height = 900}) async {
    tester.view.physicalSize = Size(360 * 3, height * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      TranslationProvider(
        child: MaterialApp(
          locale: LocaleSettings.currentLocale.flutterLocale,
          supportedLocales: AppLocaleUtils.supportedLocales,
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          home: Scaffold(
            body: Builder(
              builder: (context) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                      key: const ValueKey("open-confirm"),
                      onPressed: () => DialogUtils.showConfirmDialog(
                        context,
                        "Delete device \"Mclash - Google sdk_gphone64_arm64\"? "
                        "It will be kicked offline immediately.",
                      ),
                      child: const Text("confirm"),
                    ),
                    ElevatedButton(
                      key: const ValueKey("open-tun"),
                      onPressed: () => MclashTunSetting.show(context),
                      child: const Text("tun"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 50));
  }

  Future<void> settle(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 50));
  }

  for (final locale in AppLocale.values) {
    testWidgets('${locale.name}：确认框按钮行不溢出（360dp）', (tester) async {
      await useLocale(tester, locale);
      await pumpHost(tester);

      await tester.tap(find.byKey(const ValueKey("open-confirm")));
      await tester.pumpAndSettle();

      expect(
        tester.takeException(),
        isNull,
        reason: '${locale.name} 的确认框按钮行溢出（取消/确定 文案太长）',
      );
      // 两个按钮都必须真的渲染出来（换行也算过）
      expect(
        find.descendant(
          of: find.byType(SimpleDialog),
          matching: find.byType(ElevatedButton),
        ),
        findsNWidgets(2),
      );
      await settle(tester);
    });

    testWidgets('${locale.name}：TUN 模式弹层不溢出（360×900 小屏）', (tester) async {
      await useLocale(tester, locale);
      await pumpHost(tester, height: 900);

      await tester.tap(find.byKey(const ValueKey("open-tun")));
      await tester.pumpAndSettle();

      expect(
        tester.takeException(),
        isNull,
        reason: '${locale.name} 的 TUN 弹层纵向溢出（内容高于屏幕且不可滚动）',
      );
      for (final mode in const [
        SettingConfig.kTunModeOff,
        SettingConfig.kTunModeAuto,
        SettingConfig.kTunModeForce,
      ]) {
        expect(
          find.byKey(ValueKey("tun-mode-$mode")),
          findsOneWidget,
          reason: '${locale.name}：三态选项必须都在',
        );
      }
      await settle(tester);
    });
  }

  testWidgets('西语小屏：TUN 弹层可以滚动到底部权限提示', (tester) async {
    await useLocale(tester, AppLocale.es);
    await pumpHost(tester, height: 640);

    await tester.tap(find.byKey(const ValueKey("open-tun")));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: '640 高的小屏也不能溢出');

    await tester.drag(
      find.byType(SingleChildScrollView).last,
      const Offset(0, -200),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: '滚动到底不能出现异常');
    await settle(tester);
  });
}
