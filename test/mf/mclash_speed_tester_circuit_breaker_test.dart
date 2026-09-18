import 'package:flutter_test/flutter_test.dart';
import 'package:mclash/app/clash/clash_http_api.dart';
import 'package:mclash/app/runtime/return_result.dart';
import 'package:mclash/mf/mclash_node.dart';
import 'package:mclash/mf/mclash_speed_tester.dart';

/// 「断开后测速还在打一个已经死掉的内核」的回归。
///
/// 用户日志里的真实片段（内核 16:35:22 已经停了）：
///
///   16:35:24 ~ 16:35:30  几百行
///   `http GetRequest http://127.0.0.1:9090/proxies/.../delay?...
///    exception: SocketException: 远程计算机拒绝网络连接 (errno = 1225)`
///
/// 每一条都是一次新建连接 + 一次同步写盘。而结论在**第一条失败**时就已经
/// 确定了：控制端口连不上 = 内核不在了，剩下 400 个节点一个也测不了。
void main() {
  MclashNode node(String name) =>
      MclashNode(name: name, type: "ss", server: "1.1.1.1", port: 443);

  test('控制端口连不上时的错误要能被识别为「内核不在了」', () {
    // 这些字符串都来自用户日志（Windows 中文/英文两种系统语言）
    expect(
      MclashSpeedTester.isKernelUnreachable(
        "SocketException: 远程计算机拒绝网络连接。 (OS Error: 远程计算机拒绝网络连接。, errno = 1225)",
      ),
      isTrue,
    );
    expect(
      MclashSpeedTester.isKernelUnreachable(
        "HttpException: Connection closed before full header was received",
      ),
      isTrue,
    );
    expect(
      MclashSpeedTester.isKernelUnreachable("SocketException: Connection refused"),
      isTrue,
    );
    // 「节点不通」不能被当成「内核不在」——那会把整批节点误判成离线
    expect(
      MclashSpeedTester.isKernelUnreachable("http statusCode: 400"),
      isFalse,
    );
    expect(
      MclashSpeedTester.isKernelUnreachable("HTTP 404"),
      isFalse,
    );
  });

  test('连续失败达到阈值 → 整批中止，不再逐个试剩下的节点', () async {
    final nodes = List.generate(80, (i) => node("节点$i"));
    var probed = 0;
    MclashSpeedTester.debugKernelAvailableOverride = () async => true;
    ClashHttpApi.debugDelayOverride = (n, url, timeout) async {
      probed++;
      return ReturnResult(
        error: ReturnResultError(
          "SocketException: 远程计算机拒绝网络连接。 (OS Error: 拒绝, errno = 1225)",
        ),
      );
    };
    await MclashSpeedTester.instance.testAll(nodes);
    ClashHttpApi.debugDelayOverride = null;
    MclashSpeedTester.debugKernelAvailableOverride = null;

    expect(
      probed,
      lessThanOrEqualTo(MclashSpeedTester.fatalStreakLimit + MclashSpeedTester.maxConcurrent),
      reason: '内核已经死了，不该把 80 个节点全试一遍'
          '（日志里就是几百行「拒绝连接」的来源）',
    );
    expect(
      probed,
      lessThan(nodes.length),
      reason: '必须真的提前停下来',
    );
  });

  test('内核不在时**不能**把所有节点标成离线（那会误导用户清空订阅）', () async {
    final nodes = List.generate(30, (i) => node("节点$i"));
    MclashSpeedTester.debugKernelAvailableOverride = () async => true;
    ClashHttpApi.debugDelayOverride = (n, url, timeout) async => ReturnResult(
      error: ReturnResultError("SocketException: Connection refused"),
    );
    await MclashSpeedTester.instance.testAll(nodes);
    ClashHttpApi.debugDelayOverride = null;
    MclashSpeedTester.debugKernelAvailableOverride = null;

    expect(
      nodes.where((n) => n.online).length,
      nodes.where((n) => n.missingInKernel).length,
      reason: '「内核不在了」的节点一律走 missingInKernel 分支（保持在线、待重载）',
    );
  });

  test('中间恢复（内核回来了）→ 阈值不会被旧的失败累积触发', () async {
    final nodes = List.generate(20, (i) => node("节点$i"));
    var probed = 0;
    MclashSpeedTester.debugKernelAvailableOverride = () async => true;
    ClashHttpApi.debugDelayOverride = (n, url, timeout) async {
      probed++;
      // 前几个失败、之后恢复：连续计数必须被清零
      if (probed <= 3) {
        return ReturnResult(
          error: ReturnResultError("SocketException: Connection refused"),
        );
      }
      return ReturnResult(data: 300);
    };
    await MclashSpeedTester.instance.testAll(nodes);
    ClashHttpApi.debugDelayOverride = null;
    MclashSpeedTester.debugKernelAvailableOverride = null;

    expect(probed, nodes.length, reason: '内核还活着就必须把整批测完');
  });
}
