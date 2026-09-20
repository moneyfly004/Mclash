import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mclash/app/clash/clash_http_api.dart';
import 'package:mclash/app/modules/clash_setting_manager.dart';
import 'package:mclash/i18n/strings.g.dart';
import 'package:mclash/mf/mclash_mode_selection.dart';
import 'package:mclash/screens/proxy_board_screen_widgets.dart';

void main() {
  late List<String> writes;

  ClashProxiesNode node(String name, {String type = "Vless", int? delay}) =>
      ClashProxiesNode()
        ..name = name
        ..type = type
        ..delay = delay;

  ClashProxiesNode group(String name, List<String> all, {String? now}) =>
      ClashProxiesNode()
        ..name = name
        ..type = "Selector"
        ..all = all
        ..now = now ?? "";

  setUp(() {
    writes = [];
    ClashSettingManager.debugSetMode("global");
    MclashNodeSelector.debugSetNodeOverride = (g, n) async {
      writes.add("$g->$n");
      return null;
    };
    MclashNodeSelector.debugProxiesOverride = () async => [
      group("🚀 节点选择", ["🇯🇵 日本 01"], now: "🇯🇵 日本 01"),
    ];
  });

  tearDown(() {
    ClashSettingManager.debugSetMode("rule");
    MclashNodeSelector.debugSetNodeOverride = null;
    MclashNodeSelector.debugProxiesOverride = null;
  });

  Future<void> pump(WidgetTester tester, {required bool flat}) async {
    await tester.pumpWidget(
      TranslationProvider(
        child: MaterialApp(
          home: Scaffold(
            body: ProxyScreenProxiesNodeWidget(
              nodes: [
                group("🚀 节点选择", ["🇯🇵 日本 01", "🇭🇰 香港 01"]),
                group("GLOBAL", ["🇯🇵 日本 01"]),
                node("🇯🇵 日本 01", delay: 180),
                node("🇭🇰 香港 01", delay: 60),
                node("🇺🇸 美国 01"),
                node("GLOBAL", type: "Selector"),
                node("DIRECT", type: "Direct"),
              ],
              controller: ProxyScreenProxiesNodeWidgetController(onTesting: () {}),
              flatNodes: flat,
            ),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 50));
  }

  List<String> visibleNames(WidgetTester tester) => tester
      .widgetList<Text>(find.byType(Text))
      .map((t) => t.data ?? "")
      .where((t) => t.isNotEmpty)
      .toList();

  testWidgets('策略组模式（规则模式）：列策略组，不列单个节点', (tester) async {
    await pump(tester, flat: false);
    final texts = visibleNames(tester);
    expect(texts.contains("🚀 节点选择"), isTrue);
    expect(
      texts.contains("🇭🇰 香港 01"),
      isFalse,
      reason: '规则模式下点组才展开成员（原有交互不能变）',
    );
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('扁平模式（全局模式）：只列真实节点，按延迟升序，没有 GLOBAL/组名', (tester) async {
    await pump(tester, flat: true);
    final texts = visibleNames(tester);

    expect(texts.contains("GLOBAL"), isFalse, reason: '用户明确不要看到 global');
    expect(texts.contains("DIRECT"), isFalse);
    expect(texts.contains("🚀 节点选择"), isFalse, reason: '全局模式下策略组没有意义');

    final order = texts
        .where((t) => t.contains("日本 01") || t.contains("香港 01") || t.contains("美国 01"))
        .toList();
    expect(
      order,
      ["🇭🇰 香港 01", "🇯🇵 日本 01", "🇺🇸 美国 01"],
      reason: '60ms → 180ms → 未测速：延迟最低的排最前',
    );

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('扁平模式点节点：直接写内核 GLOBAL（不是写某个组）', (tester) async {
    await pump(tester, flat: true);

    await tester.tap(find.text("🇭🇰 香港 01"));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      writes,
      ["GLOBAL->🇭🇰 香港 01"],
      reason: '全局模式下真正生效的是内核 GLOBAL，写策略组等于没切',
    );

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
