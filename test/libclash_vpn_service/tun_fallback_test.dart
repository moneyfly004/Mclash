import 'package:flutter_test/flutter_test.dart';
import 'package:libclash_vpn_service/libclash_vpn_service.dart';

/// 「已连接但上不了网」的回归测试：TUN 不可用时必须能**判出来**。
///
/// ## 背景（实测证据）
///
/// Mclash 的内核配置默认开 TUN（`tun.enable=true`、`auto-route=true`），但桌面端
/// 是以普通权限直接跑 mihomo 子进程的。macOS 上创建 utun 必须 root，内核只会记
/// 一行错然后照常提供 mixed 端口 —— 真内核日志（/tmp 实测）：
///
///     level=info  msg="Initial configuration complete, total time: 18ms"
///     level=error msg="Start Mixed(http+socks) server error: listen tcp :17890:
///                      bind: address already in use"
///     level=error msg="Start TUN listening error: configure tun interface:
///                      Connect: operation not permitted"
///
/// 此时系统代理默认是关的（`auto_set_system_proxy=false`），于是界面显示「已连接」
/// 而流量没有出口。兜底逻辑（`DesktopVpnServiceImpl._applyDataPathFallback`）就是
/// 靠这里的判据决定「要不要自动接管系统代理」，判错任一侧后果都很直接：
///
///   * 漏判 → 用户看到「已连接」却上不了网（本 bug）
///   * 误判 → 明明 TUN 正常，却去改用户的系统代理设置
///
/// 所以用真实日志原文把判据钉住。
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
}
