import 'package:flutter_test/flutter_test.dart';
import 'package:mclash/app/local_services/vpn_service.dart';

/// 回归：真机报障「系统代理被别的程序关掉，界面还显示已连接」。
///
/// 这里覆盖看守的**退让策略与告警通道**（纯逻辑，可在 Linux CI 上跑）。
/// 判定本身（ProxyEnable + ProxyServer 都要看）在
/// test/libclash_vpn_service/windows_system_proxy_test.dart 里用真机验证。
void main() {
  tearDown(() {
    VPNService.debugResetProxyWatchdogState();
  });

  group('系统代理看守的退让策略', () {
    final now = DateTime(2026, 9, 23, 14, 0, 0);

    test('没有抢改记录 → 继续自动恢复', () {
      expect(VPNService.shouldPauseProxyWatchdog(<DateTime>[], now), isFalse);
    });

    test('窗口内未达上限（4 次）→ 仍然自动恢复', () {
      final repairs = <DateTime>[
        for (var i = 1; i <= 4; i++) now.subtract(Duration(minutes: i)),
      ];
      expect(VPNService.shouldPauseProxyWatchdog(repairs, now), isFalse);
    });

    test('10 分钟内被抢改 5 次 → 暂停自动恢复（避免和别的代理软件无限互抢）', () {
      final repairs = <DateTime>[
        for (var i = 1; i <= 5; i++) now.subtract(Duration(minutes: i)),
      ];
      expect(VPNService.shouldPauseProxyWatchdog(repairs, now), isTrue);
    });

    test('窗口外的旧记录会过期，不会一直暂停', () {
      final repairs = <DateTime>[
        for (var i = 0; i < 6; i++)
          now.subtract(Duration(minutes: 30 + i)),
      ];
      expect(VPNService.shouldPauseProxyWatchdog(repairs, now), isFalse);
    });
  });

  group('告警通道（首页据此显示醒目提示）', () {
    test('默认没有告警', () {
      VPNService.debugResetProxyWatchdogState();
      expect(VPNService.systemProxyWarning.value, isEmpty);
    });

    test('写入告警后界面读得到；复位后清空', () {
      VPNService.systemProxyWarning.value = "系统代理已被其它程序关闭";
      expect(VPNService.systemProxyWarning.value, isNotEmpty);
      VPNService.debugResetProxyWatchdogState();
      expect(VPNService.systemProxyWarning.value, isEmpty);
    });
  });
}
