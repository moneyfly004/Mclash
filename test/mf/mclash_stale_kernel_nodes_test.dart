import 'package:flutter_test/flutter_test.dart';
import 'package:mclash/app/clash/clash_http_api.dart';
import 'package:mclash/app/runtime/return_result.dart';
import 'package:mclash/mf/mclash_node.dart';
import 'package:mclash/mf/mclash_speed_tester.dart';

/// 「测速全部超时」这条反馈的回归。
///
/// 真实原因：订阅更新后（套餐新增了 SSR / light* 节点），**内核还在用旧配置跑**。
/// 这时内核对 `/proxies/{name}/delay` 返回 404，而旧实现一律把它当成「节点超时」，
/// 于是界面上新节点全是「超时」——用户以为节点全挂了。
///
/// 现在：这类节点被标成「未测到（待重载内核）」，并且不判离线；测速结束若发现
/// 有一批这类节点，会自动重载内核，然后让用户再测一次。
void main() {
  MclashNode node(String name) =>
      MclashNode(name: name, type: "ssr", server: "1.1.1.1", port: 443);

  test('内核返回 404（节点还没进内核）→ 标 missingInKernel，不判离线', () async {
    final n = node("⭐ 香港24");
    ClashHttpApi.debugDelayOverride = (node, url, timeout) async =>
        ReturnResult(error: ReturnResultError("HTTP 404"));
    final ms = await MclashSpeedTester.instance.testOne(n, kernelUp: true);
    ClashHttpApi.debugDelayOverride = null;

    expect(ms, -1, reason: '这一次确实没测到延迟');
    expect(n.missingInKernel, isTrue, reason: '要能区分「没进内核」与「真超时」');
  });

  test('测速成功会清掉 missingInKernel 标记', () async {
    final n = node("⭐ 香港25")..missingInKernel = true;
    ClashHttpApi.debugDelayOverride = (node, url, timeout) async =>
        ReturnResult(data: 480);
    final ms = await MclashSpeedTester.instance.testOne(n, kernelUp: true);
    ClashHttpApi.debugDelayOverride = null;

    expect(ms, 480);
    expect(n.missingInKernel, isFalse);
  });

  test('批量测速统计 missingInKernel，并保留 online（不显示成超时）', () async {
    final nodes = [node("⭐ 香港24"), node("⭐ 香港25")];
    ClashHttpApi.debugDelayOverride = (node, url, timeout) async {
      if (node.contains("香港24")) {
        return ReturnResult(error: ReturnResultError("HTTP 404"));
      }
      return ReturnResult(data: 500);
    };
    // testAll 内部自己判断内核可用性；这里用 kernelAvailable 的缝固定为「内核在跑」
    MclashSpeedTester.debugKernelAvailableOverride = () async => true;
    await MclashSpeedTester.instance.testAll(nodes);
    ClashHttpApi.debugDelayOverride = null;
    MclashSpeedTester.debugKernelAvailableOverride = null;

    expect(MclashSpeedTester.missingInKernel, 1);
    expect(
      nodes.first.online,
      isTrue,
      reason: '「内核里还没有」不等于节点挂了，不能标成离线（界面会显示「超时」）',
    );
    expect(nodes.first.latencyUsable, isFalse);
  });
}
