import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mclash/app/modules/clash_setting_manager.dart';
import 'package:mclash/i18n/strings.g.dart';
import 'package:mclash/mf/mclash_account_service.dart';
import 'package:mclash/mf/mclash_node.dart';
import 'package:mclash/mf/mclash_nodes_store.dart';
import 'package:mclash/screens/home_mclash_widgets.dart';
import 'package:mclash/screens/mclash_nodes_list_screen.dart';

/// 回归（真机报障）：**界面切成英文后，主页与节点列表里还是大量中文**。
///
/// 这两页的文案以前是硬编码的（"当前节点 / 快速筛选国家 / 节点列表 / 全部测速…"），
/// 现在全部走 `t.homeScreen.*` / `t.nodesScreen.*`。这个测试把"英文环境必须英文"
/// 钉死，并用反向断言保证中文不再出现。
void main() {
  setUpAll(() async {
    // base 语言（en）可同步加载，用它做确定性断言。
    await LocaleSettings.setLocale(AppLocale.en);
  });

  final sample = <MclashNode>[
    MclashNode(name: "香港快线", type: "ss", server: "1.1.1.1", port: 443),
    MclashNode(name: "日本 01", type: "vless", server: "2.2.2.2", port: 443),
  ];

  setUp(() {
    MclashNodesStore.instance.debugResetLoadState();
    MclashNodesStore.instance.debugResetCurrentNode();
    ClashSettingManager.debugSetMode("rule");
    MclashNodesStore.instance.debugSetNodes(sample, loading: false);
    MclashAccountService.instance.debugSetData({
      "username": "u",
      "balance": 1.0,
      "has_subscription": true,
      "subscription": {
        "package_name": "test",
        "device_limit": 20,
        "current_devices": 2,
        "is_active": true,
        "status": "active",
        "expire_time": "2028-06-25T12:44:45Z",
      },
    }, {
      "package_name": "test",
      "days_remaining": 648,
      "expire_at": "2028-06-25",
      "device_limit": 20,
      "current_devices": 2,
      "is_active": true,
      "status": "active",
      "subscription_url": "https://example.invalid/sub",
    });
  });

  tearDown(() {
    MclashNodesStore.instance.debugSetNodes([], loading: false);
    MclashNodesStore.instance.debugResetLoadState();
    MclashNodesStore.instance.debugResetCurrentNode();
    MclashAccountService.instance.debugSetData(null, null);
  });

  Future<void> pump(WidgetTester tester, Widget child) async {
    await tester.pumpWidget(
      TranslationProvider(child: MaterialApp(home: child)),
    );
    await tester.pump(const Duration(milliseconds: 100));
  }

  Future<void> finish(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 50));
  }

  testWidgets('英文界面：节点列表的标题/工具提示必须是英文', (tester) async {
    await pump(tester, const MclashNodesListScreen());

    for (final en in [
      "Nodes", // 标题
      "Update subscription",
      "Test all",
      "Sort by latency",
    ]) {
      expect(
        find.byWidgetPredicate(
          (w) =>
              (w is Text && w.data == en) ||
              (w is Tooltip && w.message == en),
        ),
        findsWidgets,
        reason: '英文界面下应出现「$en」',
      );
    }

    for (final zh in ["节点列表", "更新订阅", "全部测速", "按延迟排序"]) {
      expect(
        find.byWidgetPredicate(
          (w) =>
              (w is Text && w.data == zh) ||
              (w is Tooltip && w.message == zh),
        ),
        findsNothing,
        reason: '英文界面下不该出现中文「$zh」（说明这处还没走 i18n）',
      );
    }

    await finish(tester);
  });

  testWidgets('英文界面：主页订阅卡的到期/设备文案是英文', (tester) async {
    await pump(tester, const Scaffold(body: MclashSubscriptionCard()));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.textContaining("Expires"), findsWidgets);
    expect(find.textContaining("Devices"), findsWidgets);
    expect(find.textContaining("到期"), findsNothing);
    expect(find.textContaining("设备"), findsNothing);

    await finish(tester);
  });
}
