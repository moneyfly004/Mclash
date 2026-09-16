import 'package:flutter_test/flutter_test.dart';
import 'package:mclash/mf/mclash_node.dart';
import 'package:mclash/mf/mclash_nodes_store.dart';

/// 「连接后不要每次都全量测速」的回归（省电 / 省流量 / 少唤醒）。
///
/// 旧行为：每次连接成功都把整个订阅（动辄 316 个节点）重新测一遍 ——
/// 12 路并发 × 每节点 3 次探测，连接后瞬间近千次连接请求，手机上是实打实的耗电。
/// 现在的规则：
///   * 有「没测过」的节点 → 只测那些；
///   * 全部测过且缓存新鲜（6 小时内）→ 一个都不测；
///   * 缓存太旧 → 全量重测。
void main() {
  MclashNode node(String name, int latencyMs) =>
      MclashNode(name: name, type: "vless", server: "1.1.1.1", port: 443)
        ..latencyMs = latencyMs;

  setUp(() {
    MclashNodesStore.instance.debugResetLoadState();
    MclashNodesStore.instance.debugSetLatencyCacheAge(null);
    MclashNodesStore.instance.debugSetNodes([], loading: false);
  });

  tearDown(() {
    MclashNodesStore.instance.debugSetLatencyCacheAge(null);
    MclashNodesStore.instance.debugSetNodes([], loading: false);
    MclashNodesStore.instance.debugResetLoadState();
  });

  test('有没测过的节点 → 只测那些（不是全量）', () {
    MclashNodesStore.instance.debugSetNodes([
      node("🇭🇰 香港 01", 80),
      node("🇯🇵 日本 01", -1),
      node("🇺🇸 美国 01", 0),
    ]);
    final stale = MclashNodesStore.instance.staleNodes();
    expect(stale.map((n) => n.name).toList(), ["🇯🇵 日本 01", "🇺🇸 美国 01"]);
  });

  test('全都测过 + 缓存新鲜 → 一个都不测（省电）', () {
    MclashNodesStore.instance.debugSetNodes([
      node("🇭🇰 香港 01", 80),
      node("🇯🇵 日本 01", 120),
    ]);
    MclashNodesStore.instance.debugSetLatencyCacheAge(const Duration(hours: 1));
    expect(MclashNodesStore.instance.staleNodes(), isEmpty);
  });

  test('缓存太旧 → 全量重测', () {
    MclashNodesStore.instance.debugSetNodes([
      node("🇭🇰 香港 01", 80),
      node("🇯🇵 日本 01", 120),
    ]);
    MclashNodesStore.instance.debugSetLatencyCacheAge(const Duration(hours: 30));
    expect(MclashNodesStore.instance.staleNodes().length, 2);
  });

  test('没有缓存时间（首次启动）→ 全量测一次', () {
    MclashNodesStore.instance.debugSetNodes([node("🇭🇰 香港 01", 80)]);
    expect(MclashNodesStore.instance.staleNodes().length, 1);
  });
}
