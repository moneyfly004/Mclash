import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mclash/app/clash/clash_config.dart';
import 'package:mclash/screens/widgets/segmented_elevated_button.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
    home: Scaffold(
      body: Center(child: SizedBox(width: 360, child: child)),
    ),
  );

  List<SegemntedElevatedButtonItem> modeSegments() => [
    SegemntedElevatedButtonItem(
      value: ClashConfigsMode.rule.index,
      text: "规则",
    ),
    SegemntedElevatedButtonItem(
      value: ClashConfigsMode.global.index,
      text: "全局",
    ),
    SegemntedElevatedButtonItem(
      value: ClashConfigsMode.direct.index,
      text: "直连",
    ),
  ];

  testWidgets('窄窗口（最小 400px 级）下不溢出', (tester) async {
    await tester.pumpWidget(
      wrap(
        SegmentedElevatedButton(
          segments: modeSegments(),
          selected: ClashConfigsMode.rule.index,
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text("规则"), findsOneWidget);
    expect(find.text("全局"), findsOneWidget);
    expect(find.text("直连"), findsOneWidget);
  });

  testWidgets('点每个分段都会回调对应模式值（规则/全局/直连）', (tester) async {
    final tapped = <int>[];
    await tester.pumpWidget(
      wrap(
        SegmentedElevatedButton(
          segments: modeSegments(),
          selected: ClashConfigsMode.rule.index,
          onPressed: tapped.add,
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 50));

    await tester.tap(find.text("全局"));
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(find.text("直连"));
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(find.text("规则"));
    await tester.pump(const Duration(milliseconds: 200));

    expect(tapped, [
      ClashConfigsMode.global.index,
      ClashConfigsMode.direct.index,
      ClashConfigsMode.rule.index,
    ]);
  });

  test('三个模式值就是内核认的 rule / global / direct', () {
    expect(ClashConfigsMode.rule.name, "rule");
    expect(ClashConfigsMode.global.name, "global");
    expect(ClashConfigsMode.direct.name, "direct");
    expect(ClashConfigsMode.rule.index, 0);
    expect(ClashConfigsMode.global.index, 1);
    expect(ClashConfigsMode.direct.index, 2);
  });

  testWidgets('点当前已选中的分段不会重复回调', (tester) async {
    final tapped = <int>[];
    await tester.pumpWidget(
      wrap(
        SegmentedElevatedButton(
          segments: modeSegments(),
          selected: ClashConfigsMode.rule.index,
          onPressed: tapped.add,
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 50));

    await tester.tap(find.text("规则"));
    await tester.pump(const Duration(milliseconds: 200));
    expect(tapped, isEmpty);
  });
}
