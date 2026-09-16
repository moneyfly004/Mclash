import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mclash/app/clash/clash_http_api.dart';
import 'package:mclash/app/modules/clash_setting_manager.dart';
import 'package:mclash/i18n/strings.g.dart';
import 'package:mclash/mf/mclash_mode_selection.dart';
import 'package:mclash/mf/mclash_node.dart';
import 'package:mclash/mf/mclash_nodes_store.dart';
import 'package:mclash/screens/main_tab_shell.dart';
import 'package:mclash/screens/home_screen_widgets.dart';
import 'package:mclash/screens/mclash_node_picker_sheet.dart';

/// 主页「独立节点选择器」的回归。
///
/// 用户反馈：主页点当前节点那一行会跳到「节点列表」整页，他想要的是主页自己的
/// 选项。所以这里钉住三件事：
///   1. 点节点行 → 打开就地弹层，**不切标签页**；
///   2. 弹层里点节点 → 真的切换（全局模式下写内核 GLOBAL）并关闭；
///   3. 搜索 / 国家筛选在弹层内生效（不必跳页也能找到节点）。
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
    MclashNode(
      name: "🇺🇸 美国 HY2",
      type: "hysteria2",
      server: "3.3.3.3",
      port: 443,
    )..online = true,
  ];

  late List<int> tabSwitches;

  setUp(() {
    MclashNodesStore.instance.debugResetLoadState();
    MclashNodesStore.instance.debugSetNodes(sample, loading: false);
    tabSwitches = [];
    MainTabController(tabSwitches.add);
    ClashHttpApi.getControlPort = () => 9090;
    ClashHttpApi.getSecret = () => "test";
  });

  tearDown(() {
    MclashNodesStore.instance.debugSetNodes([], loading: false);
    MclashNodesStore.instance.debugResetLoadState();
    MclashNodeSelector.debugProxiesOverride = null;
    MclashNodeSelector.debugSetNodeOverride = null;
    ClashSettingManager.debugSetMode("rule");
    ClashHttpApi.getControlPort = null;
    ClashHttpApi.getSecret = null;
  });

  Future<void> pumpSheet(WidgetTester tester, {String current = ""}) async {
    await tester.pumpWidget(
      TranslationProvider(
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => Center(
                child: ElevatedButton(
                  onPressed: () =>
                      showMclashNodePickerSheet(context, current: current),
                  child: const Text("open"),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text("open"));
    await tester.pumpAndSettle();
  }

  testWidgets('弹层列出节点，点一下即切换（全局模式写 GLOBAL）并关闭', (tester) async {
    final writes = <String>[];
    final proxies = [
      ClashProxiesNode()
        ..name = "🚀 节点选择"
        ..type = "Selector"
        ..all = ["🇭🇰 香港 02"]
        ..now = "🇭🇰 香港 01",
    ];
    MclashNodeSelector.debugProxiesOverride = () async => proxies;
    MclashNodeSelector.debugSetNodeOverride = (group, node) async {
      writes.add("$group->$node");
      return null;
    };
    ClashSettingManager.debugSetMode("global");

    await pumpSheet(tester, current: "🇭🇰 香港 01");
    expect(find.text("选择节点"), findsOneWidget);
    // 用户明确要求「不要看到 global」：界面里不该出现任何 global/GLOBAL 字样
    expect(find.text("全局模式"), findsNothing);
    expect(find.textContaining("GLOBAL"), findsNothing);
    expect(find.text("按延迟排序"), findsOneWidget, reason: '让排序规则可见、可预期');

    await tester.tap(find.byKey(const ValueKey("picker-node-🇯🇵 日本 01")));
    await tester.pumpAndSettle();

    expect(writes, ["GLOBAL->🇯🇵 日本 01"]);
    expect(find.text("选择节点"), findsNothing, reason: '切完就关掉，不占着屏幕');
    expect(find.textContaining("已切换到"), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 50));
  });

  testWidgets('列表按延迟升序：最快的排最前，没测到的排最后', (tester) async {
    await pumpSheet(tester);

    final tys = tester
        .widgetList<Text>(find.byType(Text))
        .map((t) => t.data ?? "")
        .where((t) => t.contains("香港 0") || t.contains("日本 01") || t.contains("美国 HY2"))
        .toList();
    expect(
      tys,
      ["🇭🇰 香港 02", "🇭🇰 香港 01", "🇯🇵 日本 01", "🇺🇸 美国 HY2"],
      reason: '60ms → 120ms → 200ms → 未测速（香港 02 必须排在香港 01 前面）',
    );

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 50));
  });

  testWidgets('内核内置伪目标（GLOBAL/DIRECT）不出现在可选项里', (tester) async {
    MclashNodesStore.instance.debugSetNodes([
      ...sample,
      MclashNode(name: "GLOBAL", type: "Selector", server: "", port: 0),
      MclashNode(name: "DIRECT", type: "Direct", server: "", port: 0),
    ], loading: false);
    await pumpSheet(tester);

    expect(find.byKey(const ValueKey("picker-node-GLOBAL")), findsNothing);
    expect(find.byKey(const ValueKey("picker-node-DIRECT")), findsNothing);
    expect(find.textContaining("GLOBAL"), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 50));
  });

  testWidgets('只有「打开完整节点列表」才会切标签页（显式操作）', (tester) async {
    await pumpSheet(tester);

    expect(
      tabSwitches,
      isEmpty,
      reason: '打开弹层本身不该切页；否则等于又跳回「节点列表」',
    );

    await tester.tap(find.textContaining("打开完整节点列表"));
    await tester.pumpAndSettle();
    expect(tabSwitches, [1]);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 50));
  });

  testWidgets('弹层内按名字搜索（不必跳页找节点）', (tester) async {
    await pumpSheet(tester);

    expect(find.byKey(const ValueKey("picker-node-🇯🇵 日本 01")), findsOneWidget);
    expect(find.byKey(const ValueKey("picker-node-🇺🇸 美国 HY2")), findsOneWidget);

    await tester.enterText(find.byType(TextField), "日本");
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey("picker-node-🇯🇵 日本 01")), findsOneWidget);
    expect(find.byKey(const ValueKey("picker-node-🇺🇸 美国 HY2")), findsNothing);

    await tester.enterText(find.byType(TextField), "没有这个节点");
    await tester.pumpAndSettle();
    expect(find.textContaining("没有匹配的节点"), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 50));
  });

  testWidgets('不再有国家图标那一排（用户要求：不需要、还会溢出弹窗）', (tester) async {
    await pumpSheet(tester);

    expect(
      find.byKey(const ValueKey("picker-country-all")),
      findsNothing,
      reason: '国家图标一排已按用户要求移除：主页本来就有「快速筛选国家」',
    );
    expect(find.byKey(const ValueKey("picker-country-US")), findsNothing);
    expect(find.byKey(const ValueKey("picker-country-HK")), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 50));
  });

  testWidgets('UDP 节点如实标注（不编延迟，用紧凑标签不占一行）', (tester) async {
    await pumpSheet(tester);

    // 纯 UDP 协议（hysteria2/tuic/wireguard）在内核起来之前测不了。
    // 现在的呈现是**右侧一个小标签**（原来的两行副标题太占地方、弹层更挤）。
    expect(find.text("UDP"), findsWidgets);
    expect(find.text("—"), findsWidgets, reason: '没测过就该显示占位符，而不是 0ms');

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 50));
  });

  testWidgets('主页当前节点行 → 打开就地弹层，而不是跳到节点列表页', (tester) async {
    await tester.pumpWidget(
      TranslationProvider(
        child: const MaterialApp(
          home: Scaffold(body: SingleChildScrollView(child: HomeScreenWidgetPart1())),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 200));

    final row = find.byIcon(Icons.dns_outlined);
    expect(row, findsOneWidget, reason: '主页要有「当前节点」那一行');

    await tester.tap(row);
    await tester.pumpAndSettle();

    expect(
      find.text("选择节点"),
      findsOneWidget,
      reason: '点这一行应当在主页就地弹层选节点',
    );
    expect(
      tabSwitches,
      isEmpty,
      reason: '不能再把用户甩到「节点列表」整页（用户反馈的原始问题）',
    );

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 50));
  });
}
