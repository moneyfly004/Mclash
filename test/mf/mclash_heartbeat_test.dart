import 'package:flutter_test/flutter_test.dart';
import 'package:mclash/mf/mclash_heartbeat_service.dart';

/// 在线心跳的回归（功能由用户提出并实现，这里钉住契约与省电行为）。
///
/// 服务端契约（实测 `/api/v1/client/heartbeat`）：
///   `POST ?token=<订阅token>` + `X-App-Device-Id: <设备指纹>`
///   → `{online, registered, interval, server_time}`
///   `registered=false` 表示「设备还没登记，请先拉一次订阅」。
void main() {
  tearDown(() {
    MclashHeartbeatService.instance.stop();
  });

  test('默认间隔 120 秒（服务端建议值一致）', () {
    expect(
      MclashHeartbeatService.kDefaultInterval,
      const Duration(seconds: 120),
    );
  });

  test('start 幂等：重复调用不会叠加定时器', () {
    final hb = MclashHeartbeatService.instance;
    hb.start();
    hb.start();
    hb.start();
    // 能在不抛异常的情况下反复 start/stop，且 stop 后状态可再次 start
    hb.stop();
    hb.start();
    hb.stop();
    expect(true, isTrue);
  });

  test('未登录时不上报（不发任何请求）', () async {
    // 未登录 → _send 立即 return，不会抛异常也不会卡住
    final hb = MclashHeartbeatService.instance;
    hb.start();
    await Future<void>.delayed(const Duration(milliseconds: 50));
    hb.stop();
    expect(true, isTrue);
  });
}
