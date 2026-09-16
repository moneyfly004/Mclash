import 'package:flutter_test/flutter_test.dart';
import 'package:mclash/mf/mclash_node.dart';
import 'package:mclash/mf/mclash_node_sort.dart';

/// 「选择节点」按延迟排序的回归。
///
/// 用户反馈原文：「主页当中的连接按钮下面的节点切换，没有按照延迟排序，
/// 延迟最低的要放最前面。」
void main() {
  MclashNode node(String name, int latencyMs) =>
      MclashNode(name: name, type: "vless", server: "1.1.1.1", port: 443)
        ..latencyMs = latencyMs;

  test("延迟最低的排最前（升序）", () {
    final sorted = sortNodesByLatency([
      node("🇺🇸 美国 01", 320),
      node("🇯🇵 日本 01", 88),
      node("🇭🇰 香港 01", 150),
    ]);
    expect(
      sorted.map((n) => n.name).toList(),
      ["🇯🇵 日本 01", "🇭🇰 香港 01", "🇺🇸 美国 01"],
    );
  });

  test("还没测到延迟的排到最后（不能把最快的顶下去）", () {
    final sorted = sortNodesByLatency([
      node("🇺🇸 美国 01", -1),
      node("🇯🇵 日本 01", 210),
      node("🇸🇬 新加坡 01", 0),
      node("🇭🇰 香港 01", 95),
    ]);
    expect(sorted.first.name, "🇭🇰 香港 01");
    expect(sorted[1].name, "🇯🇵 日本 01");
    expect(sorted.sublist(2).map((n) => n.name).toSet(), {
      "🇺🇸 美国 01",
      "🇸🇬 新加坡 01",
    });
  });

  test("延迟相同/都没有时顺序稳定（列表不会乱跳）", () {
    final input = [
      node("🇧🇷 巴西 01", -1),
      node("🇦🇷 阿根廷 01", -1),
      node("🇨🇱 智利 01", -1),
    ];
    final first = sortNodesByLatency(input).map((n) => n.name).toList();
    final second = sortNodesByLatency(input).map((n) => n.name).toList();
    expect(first, second, reason: "同样的输入必须给出同样的顺序");
    // 都没有延迟时按名字兜底（可预期）
    expect(first, ["🇦🇷 阿根廷 01", "🇧🇷 巴西 01", "🇨🇱 智利 01"]);
  });

  test("空列表不炸", () {
    expect(sortNodesByLatency([]), isEmpty);
  });

  test("fastestNode 取最快那个（没有可用延迟时返回 null）", () {
    expect(
      fastestNode([node("a", 300), node("b", 40), node("c", -1)])?.name,
      "b",
    );
    expect(fastestNode([node("a", -1), node("b", 0)]), isNull);
  });
}
