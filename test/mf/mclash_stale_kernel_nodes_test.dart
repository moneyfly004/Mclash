import 'package:flutter_test/flutter_test.dart';
import 'package:mclash/app/clash/clash_http_api.dart';
import 'package:mclash/app/runtime/return_result.dart';
import 'package:mclash/mf/mclash_node.dart';
import 'package:mclash/mf/mclash_speed_tester.dart';

void main() {
  MclashNode node(String name) =>
      MclashNode(name: name, type: "hysteria2", server: "1.1.1.1", port: 443);

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
