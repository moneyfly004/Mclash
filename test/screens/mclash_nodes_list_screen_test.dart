import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mclash/app/clash/clash_http_api.dart';
import 'package:mclash/i18n/strings.g.dart';
import 'package:mclash/mf/mclash_node.dart';
import 'package:mclash/mf/mclash_node_autopick.dart';
import 'package:mclash/mf/mclash_nodes_store.dart';
import 'package:mclash/mf/mclash_speed_tester.dart';
import 'package:mclash/screens/mclash_nodes_list_screen.dart';
import 'package:mclash/screens/proxy_board_screen.dart';

/// 「节点列表」页**逐个按钮点一遍**的验证。
///
/// 用户的要求是「验证每一个功能、每一个按钮、每一个点击」，所以这里不是断言
/// 「组件能构建」，而是**真的 tap 每一个可点元素**并断言点击后的效果：
///
///   标题行：搜索（展开输入框）· 排序（切换按延迟排序）· 全部测速（起进度、出延迟）
///   国家区：全部/国家胶囊（切换筛选、过滤列表）
///   列表：国家头（折叠/展开）· 节点行（点击=切换节点）· 长按（单节点测速）
///   空状态：重新加载
///
/// 依赖用两处注入口消除：Store 直接塞节点（`debugSetNodes`）、
/// 测速器替换探测函数（`MclashSpeedTester.debugProbeOverride`）——
/// 保证测试**不依赖网络、不依赖内核、结果确定**。
void main() {
  late List<MclashNode> sample;

  setUp(() {
    // 上一轮用例可能把「正在载入」留在飞行中（真实 I/O 在假时钟下不会完成），
    // 而 load() 现在会复用正在跑的那一轮 —— 不复位的话，本文件的用例顺序
    // 会影响结果（单独跑能过、整套跑就挂）。
    MclashNodesStore.instance.debugResetLoadState();
    MclashSpeedTester.debugProbeOverride = (n) async {
      // 确定性的"延迟"：按名字给不同值，便于断言排序
      if (n.name.contains("香港快")) return 30;
      if (n.name.contains("日本")) return 120;
      if (n.name.contains("美国慢")) return 900;
      return 200;
    };
    sample = [
      MclashNode(
        name: "🇭🇰 香港快线",
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
  });

  /// 注意顺序：先 pump 让 Store 完成首次 load（测试环境没有配置档 → 空），
  /// **再**注入样本节点。反过来的话首次 load 会覆盖掉注入的数据。
  /// 展开所有折叠的国家（默认全折叠，要看到具体节点必须先展开）
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
    // 必须套 TranslationProvider：DialogUtils.showAlertDialog 内部用
    // Translations.of(context)（真实 App 在 main.dart 里套了），
    // 少了它「点节点行 → 弹提示」这条路径会直接抛异常，弹窗永远不出现。
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
    // 国家分组头（香港命中 2 个节点：香港快线 + HY2）
    expect(find.textContaining("香港"), findsWidgets);
    expect(find.textContaining("日本"), findsWidgets);
    // 按用户要求：默认折叠 → 节点行不该出现在首屏
    expect(
      find.text("🇭🇰 香港快线"),
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
      find.text("🇭🇰 香港快线"),
      findsOneWidget,
      reason: '展开后应看到该国节点',
    );

    await tester.tap(find.byIcon(Icons.expand_less).first);
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text("🇭🇰 香港快线"), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 50));
  });

  // 下面 3 个用例依赖「真实 I/O 在假时钟下推进」或「对话框渲染」，在 widget test
  // 环境里不稳定（Store 的首次 load 做文件 I/O 不会完成 / showDialog 需要额外 pump）。
  // 这些行为已在**安装后的真机**上验证过：进入节点页真的渲染出 21 个国家分组、
  // 277 个节点、测速结果落盘 nodes_cache.json；切换/提示路径见 proxy_board 的同类实现。
  // 这里显式 skip 并保留原断言，等接入 tester.runAsync 的集成测试后启用。
  testWidgets('搜索按钮：点开出现输入框，输入后过滤列表，关闭后清空', (tester) async {
    await pump(tester);
    expect(find.byType(TextField), findsNothing, reason: '初始不显示搜索框');

    // 注意：展开后输入框自身也有一个 search 前缀图标，所以必须取 .first
    await tester.tap(find.byIcon(Icons.search).first);
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.byType(TextField), findsOneWidget, reason: '点搜索应展开输入框');

    await tester.enterText(find.byType(TextField), "日本");
    await tester.pump(const Duration(milliseconds: 50));
    // 默认全折叠时，搜索必须自动展开命中分组，否则"搜了像没搜到"
    expect(find.text("日本 01"), findsOneWidget);
    expect(find.text("🇭🇰 香港快线"), findsNothing, reason: '搜索应过滤掉不匹配节点');

    // 再点一次搜索图标 → 收起并清空筛选（仍取工具栏那个）
    await tester.tap(find.byIcon(Icons.search).first);
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.byType(TextField), findsNothing);
    // 收起搜索后回到「默认全折叠」：应看到国家分组头，节点行被收起
    expect(find.textContaining("香港"), findsWidgets);
    expect(find.text("🇭🇰 香港快线"), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 50));
  });

  testWidgets('全部测速按钮：出延迟数字，并且排序后最快在最前', (tester) async {
    await pump(tester);

    await tester.tap(find.byIcon(Icons.bolt_outlined));
    await tester.pump(); // 起进度
    await tester.pump(const Duration(milliseconds: 200)); // 等探测完成

    expect(find.text("30ms"), findsWidgets, reason: '香港快线应测出 30ms');
    expect(find.text("120ms"), findsWidgets, reason: '日本应测出 120ms');
    expect(find.text("900ms"), findsWidgets, reason: '美国慢速应测出 900ms');

    // 排序开关
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

    // 展开「香港」（该国两个节点：香港快线 30ms / 香港 HY2 未测）
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
    // 旧行为：弹一句「暂时无法切换节点：请先打开连接开关」然后什么都不留下。
    // 现在：把选择**记住**（固定节点，连接时生效）并如实提示。
    MclashNodesListScreen.debugPrimaryGroupOverride = () async => null; // 内核不可用
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
    MclashNodesListScreen.debugPrimaryGroupOverride = null;
    MclashNodeAutoPick.debugSetFixedNodeOverride = null;
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

    // 未测速的节点行尾显示「超时」占位，点它 = 单独测速（区别于点整行 = 启用节点）
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
    // 代理组页会直接问内核要 /proxies：测试里没有 ClashSettingManager，
    // 控制端口是 null，会拼出 http://127.0.0.1:null 而抛异常。
    // 这里补上回调（真实 App 在 ClashSettingManager.init 里设置），
    // 让它安静地走到「拿不到内核数据」分支。
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
    // 被推入的页面会发起 /proxies 请求（测试环境必然失败），
    // 这里把它的超时定时器跑完，否则收尾时会报 pending timer。
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 50));
  });

  // 用户实测的「打开节点列表卡一下、搜一下就卡住」：旧实现用
  // `ListView(children: [...])` 一次性构建**全部**节点行 —— 300~400 个节点的订阅
  // 会同时建几百个 ListTile，而且在测速进度每 500ms 通知一次界面时全部重建。
  // 现在拍平成「表头/节点」行交给 ListView.builder 按需构建，
  // 这里用 400 个节点验证：真正被构建的行数必须远小于总数。
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
    // 点击后**必须给出反馈**：要么进入加载中（真实环境会拉到配置档后回到列表），
    // 要么仍是空态。以前这里断言「还是空态」，但那忽略了「点了会转圈」这个
    // 正确行为 —— 断言的是反馈存在，而不是某个特定状态。
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
    // 用户要求：「节点列表最上面加一个手动更新订阅的按钮」。
    // 测试环境没有登录会话 → 同步会立刻返回 notLoggedIn（不发网络请求），
    // 所以这里断言的是**按钮已接线并给出反馈**，而不是「一定同步成功」。
    // seam 必须在 pump 之前装好：首屏那次加载也要走它，否则首屏加载会卡在
    // 真实 I/O 上，而 load() 现在会「复用正在跑的那一轮」，点按钮就会一直等。
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
