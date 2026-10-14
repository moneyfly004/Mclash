import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mclash/i18n/strings.g.dart';
import 'package:mclash/screens/group_item_creator.dart';
import 'package:mclash/screens/group_screen.dart';

/// 回归：**已经压在导航栈里的页面**，在用户切换语言后标题必须跟着变。
///
/// 真机报障：语言从英文切到波斯语后，之前打开的「应用设置」页标题仍是
/// 「App Settings」—— 标题是 push 那一刻按当时语言取词、当构造参数存下来的。
/// 现在 GroupScreen 支持 `titleBuilder`，每次 build 按当前语言取词。
void main() {
  Future<void> useLocale(WidgetTester tester, AppLocale locale) async {
    await tester.runAsync(() => LocaleSettings.setLocale(locale));
  }

  testWidgets('切语言后，已打开的设置页标题跟着变（不再停在旧语言）', (tester) async {
    await useLocale(tester, AppLocale.en);

    late BuildContext hostContext;
    await tester.pumpWidget(
      TranslationProvider(
        child: MaterialApp(
          locale: LocaleSettings.currentLocale.flutterLocale,
          supportedLocales: AppLocaleUtils.supportedLocales,
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          home: Scaffold(
            body: Builder(
              builder: (context) {
                hostContext = context;
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      ),
    );

    await tester.pump();
    // 以「推入新页面」的方式打开设置页（模拟用户点进「应用设置」）
    final t = Translations.of(hostContext);
    // ignore: unawaited_futures
    Navigator.of(hostContext).push(
      MaterialPageRoute<void>(
        settings: GroupScreen.routeSettings("appSettings"),
        builder: (_) => GroupScreen(
          title: t.meta.settingApp,
          titleBuilder: (tt) => tt.meta.settingApp,
          getOptions: (context, setstate) async => <GroupItem>[],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(t.meta.settingApp), findsOneWidget, reason: '英文下标题是英文');
    final before = t.meta.settingApp;

    // 用户在这个页面上直接切换语言（页面不关闭）
    await useLocale(tester, AppLocale.ru);
    await tester.pumpAndSettle();

    final ru = LocaleSettings.instance.getTranslations(AppLocale.ru);
    expect(find.text(ru.meta.settingApp), findsOneWidget, reason: '切语言后标题要变俄语');
    expect(find.text(before), findsNothing, reason: '不能还停留在旧语言的标题');

    // 收尾：把挂起的定时器/路由清掉，避免测试互相影响
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 50));
  });
}
