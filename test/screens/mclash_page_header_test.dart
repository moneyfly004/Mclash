import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mclash/i18n/strings.g.dart';
import 'package:mclash/screens/widgets/mclash_page_header.dart';

void main() {
  Future<void> pumpHeader(
    WidgetTester tester, {
    required bool loading,
    VoidCallback? onRefresh,
  }) async {
    await tester.pumpWidget(
      TranslationProvider(
        child: MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                MclashPageHeader(
                  title: "我的",
                  loading: loading,
                  onRefresh: onRefresh,
                ),
                const Card(
                  key: ValueKey("below"),
                  child: SizedBox(height: 100, width: double.infinity),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  double headerHeight(WidgetTester tester) =>
      tester.getSize(find.byType(MclashPageHeader)).height;

  double belowTop(WidgetTester tester) =>
      tester.getRect(find.byKey(const ValueKey("below"))).top;

  testWidgets('加载中 / 加载完：标题栏高度一致，下面的内容不位移', (tester) async {
    await pumpHeader(tester, loading: true, onRefresh: () {});
    final loadingHeight = headerHeight(tester);
    final loadingTop = belowTop(tester);

    await pumpHeader(tester, loading: false, onRefresh: () {});
    final loadedHeight = headerHeight(tester);
    final loadedTop = belowTop(tester);

    expect(
      loadedHeight,
      closeTo(loadingHeight, 0.01),
      reason: '加载态与完成态高度必须相同（旧实现差 24px → 整页跳）',
    );
    expect(
      loadedTop,
      closeTo(loadingTop, 0.01),
      reason: '标题栏一变，下面的卡片就跟着跳 —— 这正是用户看到的抖动',
    );
    expect(
      loadedHeight,
      greaterThanOrEqualTo(MclashPageHeader.slotSize),
      reason: '功能位至少要占满 44px',
    );
  });

  testWidgets('没有刷新按钮时同样占位（三态高度都一致）', (tester) async {
    await pumpHeader(tester, loading: false, onRefresh: () {});
    final withButton = headerHeight(tester);

    await pumpHeader(tester, loading: false, onRefresh: null);
    expect(
      headerHeight(tester),
      closeTo(withButton, 0.01),
      reason: '「有没有刷新按钮」也不该改变高度',
    );
    expect(find.byIcon(Icons.refresh), findsNothing);
  });

  testWidgets('加载中显示转圈，完成后显示刷新按钮（位置相同）', (tester) async {
    await pumpHeader(tester, loading: true, onRefresh: () {});
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    final spinner = tester.getRect(find.byType(CircularProgressIndicator));

    await pumpHeader(tester, loading: false, onRefresh: () {});
    final button = tester.getRect(find.byIcon(Icons.refresh));
    expect(
      button.center.dx,
      closeTo(spinner.center.dx, 0.01),
      reason: '两者占同一个位置，不能左右跳',
    );
    expect(button.center.dy, closeTo(spinner.center.dy, 0.01));
  });

  testWidgets('点刷新图标触发回调', (tester) async {
    var taps = 0;
    await pumpHeader(tester, loading: false, onRefresh: () => taps++);
    await tester.tap(find.byIcon(Icons.refresh));
    await tester.pump();
    expect(taps, 1);
  });
}
