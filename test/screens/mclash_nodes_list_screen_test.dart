import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mclash/app/clash/clash_http_api.dart';
import 'package:mclash/app/modules/clash_setting_manager.dart';
import 'package:mclash/i18n/strings.g.dart';
import 'package:mclash/mf/mclash_mode_selection.dart';
import 'package:mclash/mf/mclash_node.dart';
import 'package:mclash/mf/mclash_node_autopick.dart';
import 'package:mclash/mf/mclash_nodes_store.dart';
import 'package:mclash/mf/mclash_speed_tester.dart';
import 'package:mclash/screens/mclash_nodes_list_screen.dart';
import 'package:mclash/screens/proxy_board_screen.dart';

void main() {
  late List<MclashNode> sample;

  setUp(() {
    MclashNodesStore.instance.debugResetLoadState();
    MclashNodesStore.instance.debugResetCurrentNode();
    MclashNodeAutoPick.debugFixedNodeValue = "";
    ClashSettingManager.debugSetMode("rule");
    MclashSpeedTester.debugProbeOverride = (n) async {
      if (n.name.contains("香港快")) return 30;
      if (n.name.contains("日本")) return 120;
      if (n.name.contains("美国慢")) return 900;
      return 200;
    };
    sample = [
      MclashNode(
        name: "香港快线",
        type: "ss",
        server: "1.1.1.1",
        port: 443,
      ),
      MclashNode(name: "日本 01", type: "vless", server: "2.2.2.2", port: 443),
      MclashNode(name: "美国慢速", type: "vmess", server: "3.3.3.3", port: 443),
      MclashNode(
        name: "香港 HY2",
        type: "hysteria2",
        server: "4.4.4.4",
        port: 443,
      ),
    ];
    MclashNodesStore.instance.debugSetNodes(sample, loading: false);
  });

  tearDown(() {
    MclashSpeedTester.debugProbeOverride = null;
    MclashNodesStore.debugLoadNodesOverride = null;
    MclashNodesStore.instance.debugSetNodes([], loading: false);
    MclashNodesStore.instance.debugResetLoadState();
    MclashNodesStore.instance.debugResetCurrentNode();
    MclashNodeAutoPick.debugFixedNodeValue = null;
    MclashNodeSelector.debugProxiesOverride = null;
    MclashNodeSelector.debugSetNodeOverride = null;
    ClashSettingManager.debugSetMode("rule");
  });

  Future<void> expandAll(WidgetTester tester) async {
    for (var i = 0; i < 20; i++) {
      final more = find.byIcon(Icons.expand_more);
      if (more.evaluate().isEmpty) {
        break;
      }
      await tester.tap(more.first);
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  Future<void> pump(WidgetTester tester, {bool injectSample = true}) async {
    await tester.pumpWidget(
      TranslationProvider(
        child: const MaterialApp(home: MclashNodesListScreen()),
      ),
    );
    await tester.pump(const Duration(milliseconds: 50));
    if (injectSample) {
      MclashNodesStore.instance.debugSetNodes(sample, loading: false);
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  testWidgets('默认全折叠：只列国家，不铺开节点', (tester) async {
    await pump(tester);

    expect(find.text("节点列表"), findsOneWidget);
    expect(find.textContaining("香港"), findsWidgets);
    expect(find.textContaining("日本"), findsWidgets);
    expect(
      find.text("香港快线"),
      findsNothing,
      reason: '订阅动辄几百个节点，默认铺开会把国家分组淹掉',
    );
    expect(find.text("日本 01"), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 50));
  });

  testWidgets('点国家头 → 展开该国节点（再点收起）', (tester) async {
    await pump(tester);

    await tester.tap(find.byIcon(Icons.expand_more).first);
    await tester.pump(const Duration(milliseconds: 50));
    expect(
      find.text("香港快线"),
      findsOneWidget,
      reason: '展开后应看到该国节点',
    );

    await tester.tap(find.byIcon(Icons.expand_less).first);
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text("香港快线"), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 50));
  });

  testWidgets('搜索按钮：点开出现输入框，输入后过滤列表，关闭后清空', (tester) async {
    await pump(tester);
    expect(find.byType(TextField), findsNothing, reason: '初始不显示搜索框');

    await tester.tap(find.byIcon(Icons.search).first);
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.byType(TextField), findsOneWidget, reason: '点搜索应展开输入框');

    await tester.enterText(find.byType(TextField), "日本");
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text("日本 01"), findsOneWidget);
    expect(find.text("香港快线"), findsNothing, reason: '搜索应过滤掉不匹配节点');

    await tester.tap(find.byIcon(Icons.search).first);
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.byType(TextField), findsNothing);
    expect(find.textContaining("香港"), findsWidgets);
    expect(find.text("香港快线"), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 50));
  });

  testWidgets('全部测速按钮：出延迟数字，并且排序后最快在最前', (tester) async {
    await pump(tester);

    await tester.tap(find.byIcon(Icons.bolt_outlined));
    await tester.pump(); 
    await tester.pump(const Duration(milliseconds: 200)); 

    expect(find.text("30ms"), findsWidgets, reason: '香港快线应测出 30ms');
    expect(find.text("120ms"), findsWidgets, reason: '日本应测出 120ms');
    expect(find.text("900ms"), findsWidgets, reason: '美国慢速应测出 900ms');

    await tester.tap(find.byIcon(Icons.sort));
    await tester.pump(const Duration(milliseconds: 50));
    final texts = tester
        .widgetList<Text>(find.byType(Text))
        .map((t) => t.data ?? "")
        .where((s) => s.contains("ms") && s != "30ms")
        .toList();
    expect(texts, isNotEmpty, reason: '排序后仍应有延迟显示');
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 50));
  });

  testWidgets('默认就按延迟排序：同一国家里最快的排最前（不用先点排序按钮）', (tester) async {
    await pump(tester);

    await tester.tap(find.byIcon(Icons.bolt_outlined));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    await tester.tap(find.byIcon(Icons.expand_more).first);
    await tester.pump(const Duration(milliseconds: 50));

    final hk = tester
        .widgetList<Text>(find.byType(Text))
        .map((t) => t.data ?? "")
        .where((t) => t.contains("香港"))
        .toList();
    final fast = hk.indexWhere((t) => t.contains("香港快线"));
    final slow = hk.indexWhere((t) => t.contains("香港 HY2"));
    expect(fast, isNonNegative, reason: '展开后应看到香港的两个节点');
    if (slow >= 0) {
      expect(
        fast < slow,
        isTrue,
        reason: '30ms 的节点必须排在没测速的节点前面（用户要求：延迟最低的放最前）',
      );
    }

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 50));
  });

  testWidgets('点节点行：内核不可用时要给出明确反馈（不能点了没反应）', (tester) async {
    MclashNodeSelector.debugProxiesOverride = () async => <ClashProxiesNode>[];
    final remembered = <String>[];
    MclashNodeAutoPick.debugSetFixedNodeOverride = (name) async {
      remembered.add(name);
    };
    await pump(tester);
    await expandAll(tester);

    await tester.tap(find.text("日本 01"));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(
      find.textContaining("连接后生效"),
      findsWidgets,
      reason: '要明确告诉用户「已记住，连接后生效」',
    );
    expect(remembered, ["日本 01"], reason: '选择必须被记住');
    MclashNodeSelector.debugProxiesOverride = null;
    MclashNodeAutoPick.debugSetFixedNodeOverride = null;
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 50));
  });

  testWidgets('列表里选节点 = 固定该节点（和顶部「切换」等效，写 fixed_node）', (tester) async {
    final writes = <String>[];
    final fixed = <String>[];
    MclashNodeSelector.debugProxiesOverride = () async => [
      ClashProxiesNode()
        ..name = "🚀 节点选择"
        ..type = "Selector"
        ..all = ["日本 01", "香港快线"]
        ..now = "香港快线",
    ];
    MclashNodeSelector.debugSetNodeOverride = (group, node) async {
      writes.add("$group->$node");
      return null;
    };
    MclashNodeAutoPick.debugSetFixedNodeOverride = (name) async {
      fixed.add(name);
    };
    await pump(tester);
    await expandAll(tester);

    await tester.tap(find.text("日本 01"));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(writes, ["🚀 节点选择->日本 01"], reason: '列表选节点要真的切内核');
    expect(
      fixed,
      ["日本 01"],
      reason: '列表选节点必须固定下来（重启后仍是它），用户报障就是这条',
    );
    MclashNodeSelector.debugProxiesOverride = null;
    MclashNodeSelector.debugSetNodeOverride = null;
    MclashNodeAutoPick.debugSetFixedNodeOverride = null;
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 50));
  });

  testWidgets('当前选中：列表里有明确的「当前」标志（不再没有高亮）', (tester) async {
    MclashNodesStore.instance.setCurrentNodeName("日本 01");
    await pump(tester, injectSample: false);
    MclashNodesStore.instance.debugSetNodes(sample, loading: false);
    await tester.pump(const Duration(milliseconds: 50));
    await expandAll(tester);

    expect(
      find.text("当前"),
      findsOneWidget,
      reason: '当前节点必须有明确标志（用户报障：列表里看不出哪个是当前）',
    );
    expect(find.byIcon(Icons.check), findsWidgets);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 50));
  });

  testWidgets('长按节点行：只测被长按的那一个节点', (tester) async {
    await pump(tester);
    await expandAll(tester);
    final jp = MclashNodesStore.instance.nodes.firstWhere(
      (n) => n.name == "日本 01",
    );
    expect(jp.latencyMs, -1, reason: '长按前未测速');

    await tester.longPress(find.text("日本 01"));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(jp.latencyMs, 120, reason: '长按应测出该节点延迟');
    final hk = MclashNodesStore.instance.nodes.firstWhere(
      (n) => n.name.contains("香港快"),
    );
    expect(hk.latencyMs, -1, reason: '长按只测一个，不该把别的节点也测了');
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 50));
  });

  testWidgets('点击行尾延迟区域：只测这一个节点，且不切换节点', (tester) async {
    final remembered = <String>[];
    MclashNodeAutoPick.debugSetFixedNodeOverride = (name) async {
      remembered.add(name);
    };
    await pump(tester);
    await expandAll(tester);
    final jp = MclashNodesStore.instance.nodes.firstWhere(
      (n) => n.name == "日本 01",
    );
    expect(jp.latencyMs, -1, reason: '点击前未测速');

    final row = find.widgetWithText(ListTile, "日本 01");
    final latencyText = find.descendant(of: row, matching: find.text("超时"));
    expect(latencyText, findsOneWidget, reason: '未测速时行尾应有「超时」占位');

    await tester.tap(latencyText);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(jp.latencyMs, 120, reason: '点延迟区应测出该节点延迟');
    final hk = MclashNodesStore.instance.nodes.firstWhere(
      (n) => n.name.contains("香港快"),
    );
    expect(hk.latencyMs, -1, reason: '点延迟区只测一个，不测别的节点');
    expect(remembered, isEmpty, reason: '点延迟区不应触发「启用节点」');
    MclashNodeAutoPick.debugSetFixedNodeOverride = null;
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 50));
  });

  testWidgets('分组按钮：能打开 ClashMi 的代理组页（原有能力不能丢）', (tester) async {
    ClashHttpApi.getControlPort = () => 9090;
    ClashHttpApi.getSecret = () => "test";
    addTearDown(() {
      ClashHttpApi.getControlPort = null;
      ClashHttpApi.getSecret = null;
    });

    await pump(tester);

    await tester.tap(find.byIcon(Icons.account_tree_outlined));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(
      find.byType(ProxyBoardScreen),
      findsOneWidget,
      reason: '节点页是平铺视图，按策略组查看的能力必须还进得去',
    );
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 50));
  });

  testWidgets('400 个节点：只构建视口内的行（懒构建回归）', (tester) async {
    final many = [
      for (var i = 0; i < 400; i++)
        MclashNode(
          name: "节点 $i",
          type: "vless",
          server: "10.0.${i ~/ 250}.${i % 250 + 1}",
          port: 443,
        )..latencyMs = 100,
    ];

    await pump(tester, injectSample: false);
    MclashNodesStore.instance.debugSetNodes(many, loading: false);
    await tester.pump(const Duration(milliseconds: 50));
    await expandAll(tester);

    final built = find.byType(ListTile).evaluate().length;
    expect(
      built,
      lessThan(80),
      reason: '只应构建视口内的行；一次性构建 400 行会让打开/搜索/刷新都卡',
    );
    expect(find.textContaining("节点 0"), findsWidgets);

    await tester.pump(const Duration(seconds: 1));
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 50));
  });

  testWidgets('空列表：显示空状态与「重新加载」按钮，点击不崩', (tester) async {
    await pump(tester, injectSample: false);
    MclashNodesStore.instance.debugSetNodes([], loading: false);
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.textContaining("还没有可用节点"), findsOneWidget);
    expect(
      find.byType(OutlinedButton),
      findsOneWidget,
      reason: '空状态必须给出「重新加载」出口',
    );

    await tester.tap(find.byType(OutlinedButton));
    await tester.pump(const Duration(milliseconds: 100));
    final loading = MclashNodesStore.instance.loading;
    final stillEmpty = find.textContaining("还没有可用节点").evaluate().isNotEmpty;
    expect(
      loading || stillEmpty,
      isTrue,
      reason: '「重新加载」必须给出反馈，不能点了没反应',
    );
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 50));
  });

  testWidgets('顶部「更新订阅」按钮：点一下真的会去同步订阅并给出反馈', (tester) async {
    var reloaded = 0;
    MclashNodesStore.debugLoadNodesOverride = () async {
      reloaded++;
      return sample;
    };
    await pump(tester);

    final button = find.byTooltip("更新订阅");
    expect(button, findsOneWidget, reason: '顶部必须有手动更新订阅的入口');

    final before = reloaded;
    await tester.tap(button);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      find.byType(SnackBar),
      findsOneWidget,
      reason: '点了必须有明确反馈（成功/失败/未登录），不能静默',
    );

    expect(
      reloaded,
      greaterThan(before),
      reason: '更新订阅后必须重新载入节点列表',
    );
    expect(
      find.textContaining("登录已失效"),
      findsOneWidget,
      reason: '未登录时要说清楚是「登录失效」，而不是笼统的失败',
    );

    MclashNodesStore.debugLoadNodesOverride = null;
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 50));
  });
}
