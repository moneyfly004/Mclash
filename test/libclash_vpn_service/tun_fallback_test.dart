import 'package:flutter_test/flutter_test.dart';
import 'package:libclash_vpn_service/libclash_vpn_service.dart';

void main() {
  group('TUN 不可用判据（回归：已连接但上不了网）', () {
    test('真实内核日志里 TUN 失败的那一行必须被判为不可用', () {
      const realLog = '''
time="2026-09-16T00:45:00.047379000+08:00" level=info msg="Initial configuration complete, total time: 18ms"
time="2026-09-16T00:45:00.050656000+08:00" level=error msg="Start Mixed(http+socks) server error: listen tcp :17890: bind: address already in use"
time="2026-09-16T00:45:00.052540000+08:00" level=error msg="Start TUN listening error: configure tun interface: Connect: operation not permitted"
''';
      expect(
        DesktopVpnServiceImpl.logIndicatesTunUnavailable(realLog),
        isTrue,
        reason: '判不出来 → 不会兜底 → 界面「已连接」但没出口',
      );
    });

    test('以管理员身份运行（TUN 正常）时不得判为不可用', () {
      const healthyLog = '''
time="2026-09-16T00:45:00.047379000+08:00" level=info msg="Initial configuration complete, total time: 18ms"
time="2026-09-16T00:45:00.052540000+08:00" level=info msg="Tun started"
''';
      expect(
        DesktopVpnServiceImpl.logIndicatesTunUnavailable(healthyLog),
        isFalse,
        reason: '误判 → 明明 TUN 正常却去改用户的系统代理',
      );
    });

    test('空日志（内核还没输出）不触发兜底', () {
      expect(
        DesktopVpnServiceImpl.logIndicatesTunUnavailable(""),
        isFalse,
      );
    });
  });

  group('TUN 就绪证据（决定「要不要兜底系统代理」）', tunEstablishEvidenceTests);
}

void tunEstablishEvidenceTests() {
  test('TUN 正常（Tun started）→ 认作已接管，不去动系统代理', () {
    const log = '''
time="2026-09-16T00:45:00.047379000+08:00" level=info msg="Initial configuration complete, total time: 18ms"
time="2026-09-16T00:45:00.052540000+08:00" level=info msg="Tun started"
''';
    expect(DesktopVpnServiceImpl.tunLooksEstablished(log), isTrue);
  });

  test('TUN 失败（Start TUN listening error）→ 不得认作已接管', () {
    const log = '''
time="2026-09-16T00:45:00.052540000+08:00" level=error msg="Start TUN listening error: configure tun interface: Access is denied"
''';
    expect(
      DesktopVpnServiceImpl.tunLooksEstablished(log),
      isFalse,
      reason: '把失败当成功 → 不兜底 → 用户既没有 TUN 也没有系统代理（没网）',
    );
  });

  test('日志里只有「像失败的正常告警」→ 不算已接管（要兜底）', () {
    const log = '''
level=info msg="Auto detect interface: Ethernet"
level=warn msg="tun name failed, using default"
''';
    expect(DesktopVpnServiceImpl.tunLooksEstablished(log), isFalse);
  });

  test('空日志 → 不算已接管', () {
    expect(DesktopVpnServiceImpl.tunLooksEstablished(""), isFalse);
  });
}
