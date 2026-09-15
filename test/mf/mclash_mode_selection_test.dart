import 'package:flutter_test/flutter_test.dart';
import 'package:mclash/app/clash/clash_http_api.dart';
import 'package:mclash/app/modules/clash_setting_manager.dart';
import 'package:mclash/app/runtime/return_result.dart';
import 'package:mclash/mf/mclash_mode_selection.dart';

/// 「切到全局模式就上不了外网」的回归。
///
/// 真实成因：订阅配置里没有 GLOBAL 组，mihomo 自己造一个并**默认指向 DIRECT**；
/// 而全局模式下所有流量都由 GLOBAL 决定 —— 于是用户一切到全局就全部直连。
/// 这里覆盖「什么时候该把 GLOBAL 接到真实节点」这个判断。
void main() {
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

    test('内核不可用时给出人话错误，而不是静默失败', () async {
      MclashNodeSelector.debugProxiesOverride = () async => [];
      MclashNodeSelector.debugSetNodeOverride = (g, n) async =>
          ReturnResultError("should-not-be-called");
      ClashSettingManager.debugSetMode("rule");

      final err = await MclashNodeSelector.select("🇭🇰 香港 01");
      expect(err, isNotNull);
      expect(err!.message.contains("内核未运行"), isTrue);

      MclashNodeSelector.debugProxiesOverride = null;
      MclashNodeSelector.debugSetNodeOverride = null;
    });
  });
}
