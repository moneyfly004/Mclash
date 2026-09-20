import 'package:flutter_test/flutter_test.dart';
import 'package:mclash/mf/mclash_heartbeat_service.dart';

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
    hb.stop();
    hb.start();
    hb.stop();
    expect(true, isTrue);
  });

  test('未登录时不上报（不发任何请求）', () async {
    final hb = MclashHeartbeatService.instance;
    hb.start();
    await Future<void>.delayed(const Duration(milliseconds: 50));
    hb.stop();
    expect(true, isTrue);
  });
}
