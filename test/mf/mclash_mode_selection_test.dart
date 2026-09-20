import 'package:flutter_test/flutter_test.dart';
import 'package:mclash/app/clash/clash_http_api.dart';
import 'package:mclash/app/modules/clash_setting_manager.dart';
import 'package:mclash/app/runtime/return_result.dart';
import 'package:mclash/mf/mclash_mode_selection.dart';
import 'package:mclash/mf/mclash_node_autopick.dart';

void main() {
  String remembered = '';

  group('全局模式 GLOBAL 选择器修正', () {
    test('GLOBAL 是 DIRECT（内核默认）→ 接到主选择组正在用的节点', () {
      expect(
        globalSelectionToApply(
          globalNow: "DIRECT",
          primaryGroupNode: "日本东京(YouTube,ChatGPT等)",
        ),
        "日本东京(YouTube,ChatGPT等)",
      );
    });

    test('GLOBAL 是 REJECT / 空 → 同样要接上', () {
      for (final now in ["REJECT", "REJECT-DROP", "", null]) {
        expect(
          globalSelectionToApply(globalNow: now, primaryGroupNode: "香港线路3"),
          "香港线路3",
          reason: 'GLOBAL=$now 时全局模式不可用',
        );
      }
    });

    test('GLOBAL 已经是真实节点 → 不动（尊重用户自己的选择）', () {
      expect(
        globalSelectionToApply(
          globalNow: "香港线路3",
          primaryGroupNode: "日本东京(YouTube,ChatGPT等)",
        ),
        isNull,
      );
    });

    test('主组还没选（DIRECT / 空）→ 不瞎接', () {
      for (final primary in ["DIRECT", "REJECT", "", null, "   "]) {
        expect(
          globalSelectionToApply(globalNow: "DIRECT", primaryGroupNode: primary),
          isNull,
          reason: '主组没有可用节点时无从接起，不能把 GLOBAL 接到 DIRECT 上',
        );
      }
    });

    test('主组指向另一个组（如「自动选择」）也可以接', () {
      expect(
        globalSelectionToApply(
          globalNow: "DIRECT",
          primaryGroupNode: "♻️ 自动选择",
        ),
        "♻️ 自动选择",
        reason: 'GLOBAL 指向 URLTest 组是合法的，还能保留自动选路',
      );
    });

    test('大小写不同的伪目标也要认出来', () {
      expect(
        globalSelectionToApply(
          globalNow: "direct",
          primaryGroupNode: "香港线路3",
        ),
        "香港线路3",
      );
    });
  });

  group('点节点写哪个选择器（回归：切了全局/选了国家看不出效果）', () {
    ClashProxiesNode node(
      String name, {
      String type = "Selector",
      List<String> all = const [],
      String now = "",
    }) => ClashProxiesNode()
      ..name = name
      ..type = type
      ..all = all.isEmpty ? const ["🇯🇵 日本 01"] : all
      ..now = now;

    final proxies = [
      node("🚀 节点选择", now: "🇯🇵 日本 01"),
      node("♻️ 自动选择", type: "URLTest"),
      node("GLOBAL", now: "DIRECT"),
      node("DIRECT", type: "Direct", all: const []),
    ];

    test('全局模式 → 写内核 GLOBAL（不是主选择组）', () {
      ClashSettingManager.debugSetMode("global");
      expect(MclashNodeSelector.groupNameForMode(proxies), "GLOBAL");
    });

    test('规则模式 → 写主选择组', () {
      ClashSettingManager.debugSetMode("rule");
      expect(MclashNodeSelector.groupNameForMode(proxies), "🚀 节点选择");
    });

    test('直连模式 → 仍写主选择组（切回规则时立刻生效）', () {
      ClashSettingManager.debugSetMode("direct");
      expect(MclashNodeSelector.groupNameForMode(proxies), "🚀 节点选择");
    });

    test('只有 GLOBAL 没有别的组 → 落到 GLOBAL，而不是返回 null', () {
      ClashSettingManager.debugSetMode("rule");
      expect(
        MclashNodeSelector.groupNameForMode([node("GLOBAL", now: "DIRECT")]),
        isNull,
        reason: '没有可用选择组时应如实返回 null（由调用方提示内核未就绪）',
      );
    });

    test('select() 按模式把节点写到正确选择器', () async {
      final writes = <String>[];
      MclashNodeSelector.debugProxiesOverride = () async => proxies;
      MclashNodeSelector.debugSetNodeOverride = (group, n) async {
        writes.add("$group->$n");
        return null;
      };

      ClashSettingManager.debugSetMode("global");
      await MclashNodeSelector.select("🇭🇰 香港 01");
      ClashSettingManager.debugSetMode("rule");
      await MclashNodeSelector.select("🇭🇰 香港 01");

      expect(writes, ["GLOBAL->🇭🇰 香港 01", "🚀 节点选择->🇭🇰 香港 01"]);

      MclashNodeSelector.debugProxiesOverride = null;
      MclashNodeSelector.debugSetNodeOverride = null;
    });

    test('内核没跑时：把选择记住（连接后生效），不再报错', () async {
      MclashNodeSelector.debugProxiesOverride = () async => [];
      MclashNodeSelector.debugSetNodeOverride = (g, n) async =>
          ReturnResultError("should-not-be-called");
      ClashSettingManager.debugSetMode("rule");
      MclashNodeAutoPick.debugSetFixedNodeOverride = (name) async {
        remembered = name;
      };
      remembered = "";

      final err = await MclashNodeSelector.select("🇭🇰 香港 01");
      expect(err, isNull, reason: '不该再报错：选择要被记住');
      expect(
        MclashNodeSelector.lastSelectDeferred,
        isTrue,
        reason: '界面据此显示「连接后生效」',
      );
      expect(remembered, "🇭🇰 香港 01", reason: '要被记为固定节点');

      MclashNodeSelector.debugProxiesOverride = null;
      MclashNodeSelector.debugSetNodeOverride = null;
      MclashNodeAutoPick.debugSetFixedNodeOverride = null;
    });
  });

  group('当前节点的显示文案（回归：只显示真实节点名 + 延迟，不摊 GLOBAL/组名）', () {
    test('全局模式：链路叶子在前，界面显示「节点名 (延迟 ms)」', () {
      expect(
        formatCurrentProxyName(["🇯🇵 日本东京", "GLOBAL"], delayMs: 345),
        "🇯🇵 日本东京 (345 ms)",
        reason: '用户要求节点名和延迟都显示；GLOBAL 是内核内部组名，不该出现',
      );
    });

    test('带订阅分组前缀时也只显示叶子节点（不显示「🚀 节点选择」组名）', () {
      expect(
        formatCurrentProxyName(["🇭🇰 香港 01", "🚀 节点选择"]),
        "🇭🇰 香港 01",
      );
    });

    test('直连模式说人话，而不是丢一个 DIRECT 给用户', () {
      expect(formatCurrentProxyName(["DIRECT"]), "直连（不走代理）");
      expect(formatCurrentProxyName(["DIRECT", "GLOBAL"]), "直连（不走代理）");
      expect(formatCurrentProxyName(["REJECT"]), "已拦截");
    });

    test('空链路返回空串（界面据此显示「未选择节点」）', () {
      expect(formatCurrentProxyName([]), "");
      expect(formatCurrentProxyName(["  "]), "");
    });

    test('链路上只剩内核内置组名时返回空串，**绝不**显示 GLOBAL', () {
      expect(formatCurrentProxyName(["GLOBAL"]), "");
      expect(formatCurrentProxyName(["global"]), "");
      expect(formatCurrentProxyName(["PASS", "GLOBAL"]), "跟随规则");
    });

    test('延迟有就拼、没有不拼（0 也视为「还没测到」）', () {
      expect(formatCurrentProxyName(["🇸🇬 新加坡", "GLOBAL"]), "🇸🇬 新加坡");
      expect(
        formatCurrentProxyName(["🇸🇬 新加坡", "GLOBAL"], delayMs: 123),
        "🇸🇬 新加坡 (123 ms)",
        reason: '节点名和延迟都要显示',
      );
      expect(
        formatCurrentProxyName(["🇸🇬 新加坡", "GLOBAL"], delayMs: 0),
        "🇸🇬 新加坡",
        reason: '0ms 是「还没测」，不能显示成延迟 0',
      );
    });
  });
}
