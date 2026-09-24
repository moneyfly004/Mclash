import 'package:flutter_test/flutter_test.dart';
import 'package:mclash/app/clash/clash_http_api.dart';
import 'package:mclash/app/modules/clash_setting_manager.dart';
import 'package:mclash/mf/mclash_current_node.dart';

void main() {
  ClashProxiesNode group(
    String name,
    List<String> all, {
    String now = "",
    String type = "Selector",
  }) => ClashProxiesNode()
    ..name = name
    ..type = type
    ..all = all
    ..now = now;

  ClashProxiesNode node(String name, {String type = "Vless", int? delay}) =>
      ClashProxiesNode()
        ..name = name
        ..type = type
        ..delay = delay;

  final proxies = [
    group("🎯 全球直连", ["DIRECT", "🚀 节点选择"], now: "DIRECT"),
    group("🚀 节点选择", ["♻️ 自动选择", "美国线路7", "DIRECT"], now: "美国线路7"),
    group(
      "♻️ 自动选择",
      ["美国线路7", "香港线路7"],
      now: "香港线路7",
      type: "URLTest",
    ),
    group("🔮 负载均衡", ["香港线路7"], now: "", type: "LoadBalance"),
    group("GLOBAL", ["DIRECT", "🚀 节点选择"], now: "DIRECT"),
    node("美国线路7", delay: 88),
    node("香港线路7", delay: 42),
    node("DIRECT", type: "Direct"),
  ];

  setUp(() {
    ClashSettingManager.debugSetMode("rule");
  });

  tearDown(() {
    ClashSettingManager.debugSetMode("rule");
  });

  group('当前节点解析（固定优先，否则取生效组 now）', () {
    test('固定节点存在 → 显示固定节点（内核停在别处也认用户的选择）', () {
      expect(
        MclashCurrentNode.resolveName(proxies, fixed: "美国线路7"),
        "美国线路7",
      );
      expect(
        MclashCurrentNode.resolveName(proxies, fixed: "  美国线路7  "),
        "美国线路7",
        reason: '固定节点名前后的空格不该影响显示',
      );
    });

    test('固定为空（自动模式）→ 显示生效组的 now', () {
      expect(MclashCurrentNode.resolveName(proxies), "美国线路7");
    });

    test('生效组是主选择组，而不是列表里排在前面的旁路组', () {
      // 🎯 全球直连 排在 🚀 节点选择 前面（内核给组的顺序不保证稳定）：
      // 不能因此把"当前节点"读成 DIRECT。
      final name = MclashCurrentNode.groupCurrentName(proxies);
      expect(name, "美国线路7", reason: '必须以主选择组（🚀 节点选择）为准');
      expect(name, isNot("DIRECT"));
    });

    test('生效组指向另一个组 → 一路走到链路末端的真实节点', () {
      final nested = [
        group("🚀 节点选择", ["♻️ 自动选择", "美国线路7"], now: "♻️ 自动选择"),
        group("♻️ 自动选择", ["香港线路7", "美国线路7"], now: "香港线路7"),
        node("香港线路7"),
        node("美国线路7"),
      ];
      expect(
        MclashCurrentNode.groupCurrentName(nested),
        "香港线路7",
        reason: '自动模式下要显示内核此刻真正在跑的那个节点，不是中间组名',
      );
      expect(
        MclashCurrentNode.resolveName(nested, fixed: ""),
        "香港线路7",
        reason: '自动组自己会换节点，界面跟着内核变',
      );
    });

    test('显式给组名（全局模式 GLOBAL）→ 读 GLOBAL 的链路', () {
      final global = [
        group("GLOBAL", ["🚀 节点选择"], now: "🚀 节点选择"),
        group("🚀 节点选择", ["香港线路7"], now: "香港线路7"),
        node("香港线路7"),
      ];
      expect(
        MclashCurrentNode.resolveName(global, groupName: "GLOBAL"),
        "香港线路7",
      );
    });

    test('生效组还没选成员（负载均衡没有 now）→ 空串（由调用方保留上一次的值）', () {
      final lb = [
        group("🚀 节点选择", ["🔮 负载均衡"], now: "🔮 负载均衡"),
        group("🔮 负载均衡", ["香港线路7"], now: "", type: "LoadBalance"),
        node("香港线路7"),
      ];
      expect(
        MclashCurrentNode.groupCurrentName(lb),
        "",
        reason: '读不出来就如实返回空串，界面必须沿用上一次的值，不能显示成空',
      );
    });

    test('组互相指（环）→ 空串，不猜也不死循环', () {
      final loop = [
        group("🚀 节点选择", ["♻️ 自动选择"], now: "♻️ 自动选择"),
        group("♻️ 自动选择", ["🚀 节点选择"], now: "🚀 节点选择"),
      ];
      expect(MclashCurrentNode.groupCurrentName(loop), "");
    });

    test('内核没给出任何组 / 列表为空 → 空串', () {
      expect(MclashCurrentNode.groupCurrentName([]), "");
      expect(MclashCurrentNode.resolveName([node("香港线路7")]), "");
      expect(MclashCurrentNode.resolveName([]), "");
    });

    test('链路末端是内置名（DIRECT）→ 如实返回，由界面翻译成"直连"', () {
      final direct = [
        group("🚀 节点选择", ["DIRECT"], now: "DIRECT"),
        node("DIRECT", type: "Direct"),
      ];
      expect(MclashCurrentNode.resolveName(direct), "DIRECT");
    });

    test('节点名前后空格不影响链路解析', () {
      final spaced = [
        group("🚀 节点选择", [" 香港线路7 "], now: " 香港线路7 "),
        node(" 香港线路7 "),
      ];
      expect(MclashCurrentNode.groupCurrentName(spaced), "香港线路7");
    });
  });

  group('选中判定（"哪个节点算当前选中"）', () {
    test('名字相同才算选中；空格忽略', () {
      expect(MclashCurrentNode.isSelected("香港线路7", "香港线路7"), isTrue);
      expect(MclashCurrentNode.isSelected(" 香港线路7 ", "香港线路7"), isTrue);
      expect(MclashCurrentNode.isSelected("香港线路7", "美国线路7"), isFalse);
    });

    test('当前节点为空 → 谁都不算选中（不能满屏都是勾）', () {
      expect(MclashCurrentNode.isSelected("香港线路7", ""), isFalse);
      expect(MclashCurrentNode.isSelected("", "香港线路7"), isFalse);
      expect(MclashCurrentNode.isSelected("   ", "  "), isFalse);
    });

    test('带延迟后缀的显示串不参与判定（回归：高亮一直不出现）', () {
      // 主页曾经把 "香港线路7 (42 ms)" 当"当前节点"传给弹层 → 永远匹配不上节点名
      expect(
        MclashCurrentNode.isSelected("香港线路7", "香港线路7 (42 ms)"),
        isFalse,
        reason: '所以传的必须是原始节点名，不能是带延迟的显示串',
      );
    });
  });

  group('当前节点延迟', () {
    test('取内核记录里的延迟，没有就 null', () {
      expect(MclashCurrentNode.delayOf(proxies, "香港线路7"), 42);
      expect(MclashCurrentNode.delayOf(proxies, " 美国线路7 "), 88);
      expect(MclashCurrentNode.delayOf(proxies, "不存在的节点"), isNull);
      expect(MclashCurrentNode.delayOf(proxies, ""), isNull);
    });
  });
}
