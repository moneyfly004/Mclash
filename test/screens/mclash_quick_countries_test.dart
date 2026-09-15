import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mclash/app/clash/clash_http_api.dart';
import 'package:mclash/app/modules/clash_setting_manager.dart';
import 'package:mclash/i18n/strings.g.dart';
import 'package:mclash/mf/mclash_mode_selection.dart';
import 'package:mclash/mf/mclash_node.dart';
import 'package:mclash/mf/mclash_nodes_store.dart';
import 'package:mclash/screens/home_mclash_widgets.dart';

/// 主页「快速筛选国家」的两条产品要求 + 一条交互要求：
///
///   1. 只显示**延迟最低的 6 个国家**（以前铺开所有国家，占掉大半屏）；
///   2. **两排**（每排 3 个）；
///   3. 点国家要**真的切到该国最快的节点** —— 用户点国家的本意是「我要走这个
///      国家」，只筛选不切换等于没反应（全局模式下还要写内核 GLOBAL）。
void main() {
  final sample = <MclashNode>[
    MclashNode(name: "🇭🇰 香港 01", type: "ss", server: "1.1.1.1", port: 443)
      ..latencyMs = 120
      ..online = true,
    MclashNode(name: "🇭🇰 香港 02", type: "ss", server: "1.1.1.2", port: 443)
      ..latencyMs = 60
      ..online = true,
    MclashNode(name: "🇯🇵 日本 01", type: "vmess", server: "2.2.2.2", port: 443)
      ..latencyMs = 200
      ..online = true,
    MclashNode(name: "🇸🇬 新加坡 01", type: "trojan", server: "3.3.3.3", port: 443)
      ..latencyMs = 300
      ..online = true,
    MclashNode(name: "🇺🇸 美国 01", type: "vmess", server: "4.4.4.4", port: 443)
      ..latencyMs = 400
      ..online = true,
    MclashNode(name: "🇰🇷 韩国 01", type: "ss", server: "5.5.5.5", port: 443)
      ..latencyMs = 500
      ..online = true,
    MclashNode(name: "🇩🇪 德国 01", type: "ss", server: "6.6.6.6", port: 443)
      ..latencyMs = 900
      ..online = true,
    MclashNode(name: "🇬🇧 英国 01", type: "ss", server: "7.7.7.7", port: 443)
      ..latencyMs = 1200
      ..online = true,
  ];

  setUp(() {
    MclashNodesStore.instance.debugResetLoadState();
    MclashNodesStore.instance.debugSetNodes(sample, loading: false);
  });

  tearDown(() {
    MclashNodesStore.instance.debugSetNodes([], loading: false);
    MclashNodesStore.instance.debugResetLoadState();
    MclashNodeSelector.debugProxiesOverride = null;
    MclashNodeSelector.debugSetNodeOverride = null;
    ClashSettingManager.debugSetMode("rule");
  });

  Future<void> pump(WidgetTester tester) async {
    await tester.pumpWidget(
      TranslationProvider(
        child: const MaterialApp(
          home: Scaffold(body: SingleChildScrollView(child: MclashQuickCountries())),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 50));
  }

  Finder chip(String code) => find.byKey(ValueKey("home-country-$code"));

  testWidgets('只显示延迟最低的 6 个国家（慢的不出现）', (tester) async {
    await pump(tester);

    for (final code in ["HK", "JP", "SG", "US", "KR", "TW"]) {
      // TW 没有节点，下面单独断言；这里先确认前五个 + 第 6 个槽位有内容
      if (code == "TW") {
        continue;
      }
      expect(chip(code), findsOneWidget, reason: "$code 是延迟最低的六个之一");
    }
    // 6 个国家（只有 7 个国家有节点 → 第 6 个是德国，英国被挤掉）
    var count = 0;
    for (final code in ["HK", "JP", "SG", "US", "KR", "DE", "GB"]) {
      if (chip(code).evaluate().isNotEmpty) {
        count++;
      }
    }
    expect(count, MclashQuickCountries.kCountryCount, reason: '只能显示 6 个国家');
    expect(
      chip("GB"),
      findsNothing,
      reason: '延迟最慢的英国应被挤出去（用户要求：只要延迟最低的六个）',
    );

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 50));
  });

  testWidgets('两排、每排 3 个（用户要求：两排 6 个国家）', (tester) async {
    await pump(tester);

    final codes = MclashNodesStore.instance.topCountries(
      limit: MclashQuickCountries.kCountryCount,
    );
    expect(codes.length, 6);

    final centers = [
      for (final c in codes) tester.getCenter(chip(c)),
    ];
    final firstRowY = centers[0].dy;
    final secondRowY = centers[3].dy;
    expect(centers[1].dy, closeTo(firstRowY, 1), reason: '前 3 个在同一排');
    expect(centers[2].dy, closeTo(firstRowY, 1));
    expect(centers[4].dy, closeTo(secondRowY, 1), reason: '后 3 个在第二排');
    expect(centers[5].dy, closeTo(secondRowY, 1));
    expect(secondRowY, greaterThan(firstRowY), reason: '确实是两排（第二排在下面）');
    // 同一排内横向递增
    expect(centers[1].dx, greaterThan(centers[0].dx));
    expect(centers[2].dx, greaterThan(centers[1].dx));

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 50));
  });

  testWidgets('点国家 → 切到该国最快节点；全局模式下写内核 GLOBAL', (tester) async {
    final writes = <String>[];
    final proxies = [
      ClashProxiesNode()
        ..name = "🚀 节点选择"
        ..type = "Selector"
        ..all = ["🇭🇰 香港 01", "🇭🇰 香港 02"]
        ..now = "🇭🇰 香港 01",
      ClashProxiesNode()
        ..name = "GLOBAL"
        ..type = "Selector"
        ..all = ["🇭🇰 香港 01"]
        ..now = "DIRECT",
    ];
    MclashNodeSelector.debugProxiesOverride = () async => proxies;
    MclashNodeSelector.debugSetNodeOverride = (group, node) async {
      writes.add("$group->$node");
      return null;
    };

    ClashSettingManager.debugSetMode("global");
    await pump(tester);

    await tester.tap(chip("HK"));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      writes,
      ["GLOBAL->🇭🇰 香港 02"],
      reason: '全局模式下必须写 GLOBAL，且取该国延迟最低的节点（60ms 那个）',
    );
    expect(
      find.textContaining("已切换到 香港 最快节点"),
      findsOneWidget,
      reason: '切了必须有反馈，用户才知道生效了',
    );

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 50));
  });
}
