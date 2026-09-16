import 'package:flutter_test/flutter_test.dart';
import 'package:mclash/app/clash/clash_http_api.dart';
import 'package:mclash/mf/mclash_flat_nodes.dart';

/// 「全局模式只显示国家节点」的回归。
///
/// 用户反馈原文：「选择全局模式，我不要他显示 global 的东西，我要他只能看到
/// 国家节点可以选择，不需要看 global。」
void main() {
  ClashProxiesNode node(String name, {int? delay}) => ClashProxiesNode()
    ..name = name
    ..type = "Vless"
    ..delay = delay;

  ClashProxiesNode group(String name, List<String> all) => ClashProxiesNode()
    ..name = name
    ..type = "Selector"
    ..all = all;

  test("策略组与内核内置伪目标都不出现", () {
    final out = flatSelectableNodes([
      group("🚀 节点选择", ["🇯🇵 日本 01"]),
      group("GLOBAL", ["🇯🇵 日本 01"]),
      node("GLOBAL"),
      node("DIRECT"),
      node("REJECT"),
      node("🇯🇵 日本 01", delay: 90),
    ]);
    expect(out.map((n) => n.name).toList(), ["🇯🇵 日本 01"]);
  });

  test("订阅提示节点（📢 官网 之类）也不出现", () {
    final out = flatSelectableNodes([
      node("📢 官网: https://example.com"),
      node("⏰ 到期: 2028-06-25"),
      node("🇭🇰 香港 01", delay: 60),
    ]);
    expect(out.map((n) => n.name).toList(), ["🇭🇰 香港 01"]);
  });

  test("按延迟升序，没测到的排后面", () {
    final out = flatSelectableNodes([
      node("🇺🇸 美国 01", delay: 300),
      node("🇯🇵 日本 01", delay: 80),
      node("🇸🇬 新加坡 01"),
      node("🇭🇰 香港 01", delay: 120),
    ]);
    expect(out.map((n) => n.name).toList(), [
      "🇯🇵 日本 01",
      "🇭🇰 香港 01",
      "🇺🇸 美国 01",
      "🇸🇬 新加坡 01",
    ]);
  });

  test("隐藏节点不列出", () {
    final hidden = node("🇰🇵 隐藏 01", delay: 10)..hidden = true;
    final out = flatSelectableNodes([hidden, node("🇯🇵 日本 01", delay: 50)]);
    expect(out.map((n) => n.name).toList(), ["🇯🇵 日本 01"]);
  });
}
