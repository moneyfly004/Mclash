import 'package:flutter_test/flutter_test.dart';
import 'package:mclash/app/clash/clash_http_api.dart';
import 'package:mclash/app/local_services/vpn_service.dart';

/// 回归：真机报障「v2rayN 同时开着 → 两边互相抢系统代理 → Mclash 抢不过就
/// 暂停自动恢复，界面却还显示已连接、实际没有代理」。
///
/// 现在的策略与 MoneyFly 一致：**永不暂停**。只要 VPN 还连着，每 15 秒把系统
/// 代理抢回 `127.0.0.1:<mixed>`；连续 3 次写入后读回仍不是我们，才在首页提示
/// 用户「有别的代理软件在抢，建议只留一个或改用 TUN」。
void main() {
  tearDown(() => VPNService.debugResetProxyWatchdogState());

  group('看守告警阈值（不再有"暂停恢复"）', () {
    test('偶发 1~2 次写入失败：只写日志，不打扰用户', () {
      expect(VPNService.shouldWarnProxyConflict(0), isFalse);
      expect(VPNService.shouldWarnProxyConflict(1), isFalse);
      expect(VPNService.shouldWarnProxyConflict(2), isFalse);
    });

    test('连续 3 次以上仍抢不回来 → 首页告警', () {
      expect(VPNService.shouldWarnProxyConflict(3), isTrue);
      expect(VPNService.shouldWarnProxyConflict(10), isTrue,
          reason: '继续失败仍要告警（但不会停止重试）');
    });

    test('成功后计数清零，告警随之消失', () {
      VPNService.systemProxyWarning.value = "占用中";
      VPNService.debugResetProxyWatchdogState();
      expect(VPNService.systemProxyWarning.value, isEmpty);
      expect(VPNService.debugProxyFailStreak, 0);
      expect(VPNService.debugProxyRepairCount, 0);
    });
  });

  group('内核状态读取：只对瞬时错误重试', () {
    test('超时/拒绝连接/5xx/控制口未就绪 → 属于瞬时错误（会重试）', () {
      for (final m in [
        'TimeoutException after 0:00:05.000000: Future not completed',
        'Connection refused',
        'SocketException: Connection reset by peer',
        'HTTP 503',
        '控制端口未就绪',
      ]) {
        expect(ClashHttpApi.isTransientControlError(m), isTrue, reason: m);
      }
    });

    test('401/403（密钥或端口错）不重试 —— 重试也修不好', () {
      for (final m in ['401 Unauthorized', '403 Forbidden', 'not found']) {
        expect(ClashHttpApi.isTransientControlError(m), isFalse, reason: m);
      }
    });
  });
}
