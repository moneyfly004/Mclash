import 'package:flutter_test/flutter_test.dart';
import 'package:libclash_vpn_service/src/desktop_impl.dart';
import 'package:mclash/app/local_services/vpn_service.dart';

/// 「内核实际监听端口 → 应用侧 → 系统代理」这条链的回归。
///
/// 用户反馈（Windows）：连上之后系统代理是空白，也改不动。
/// 根因：内核在 mixed-port 为 0 或被占用时会**自己换一个空闲端口**，
/// 而应用侧仍记着旧值（甚至 0）；照着旧值去设系统代理，要么被跳过
/// （Windows 代理设置页一片空白），要么写到一个没人监听的端口上。
void main() {
  group('系统代理端口决策（内核为准）', () {
    test('内核报了端口 → 用内核的（这是事实）', () {
      expect(
        VPNService.resolveEffectiveMixedPort(kernelPort: 17890, configuredPort: 0),
        17890,
        reason: '内核自动换了端口时，必须以内核为准，否则系统代理指向空端口',
      );
      expect(
        VPNService.resolveEffectiveMixedPort(
          kernelPort: 2253,
          configuredPort: 7890,
        ),
        2253,
        reason: '设置里是旧值时也不能用旧值',
      );
    });

    test('内核还没起来（0）→ 退回设置值', () {
      expect(
        VPNService.resolveEffectiveMixedPort(
          kernelPort: 0,
          configuredPort: 7890,
        ),
        7890,
      );
    });

    test('两头都没有 → 0（调用方必须当成「没有代理可设」而不是硬写）', () {
      expect(
        VPNService.resolveEffectiveMixedPort(kernelPort: 0, configuredPort: 0),
        0,
      );
      expect(
        VPNService.resolveEffectiveMixedPort(kernelPort: -1, configuredPort: -1),
        0,
        reason: '负数端口是坏值，必须归一成 0',
      );
    });

    test('负数/非法内核值不能当成有效端口写进系统代理', () {
      expect(
        VPNService.resolveEffectiveMixedPort(
          kernelPort: -5,
          configuredPort: 7890,
        ),
        7890,
      );
    });
  });

  test('系统代理地址固定用回环地址（不用局域网 IP）', () {
    expect(
      VPNService.systemProxyHost,
      "127.0.0.1",
      reason: '写局域网 IP 时本机应用反而可能绕不过去，且会随网卡变化失效',
    );
  });

  group('Windows 注册表 ProxyServer 值解析（读回校验的正确性基础）', () {
    test('单值写法必须精确匹配（含端口）', () {
      const raw = "    ProxyServer    REG_SZ    127.0.0.1:7890";
      expect(DesktopVpnServiceImpl.proxyServerValueMatches(raw, "127.0.0.1", 7890), isTrue);
      expect(
        DesktopVpnServiceImpl.proxyServerValueMatches(raw, "127.0.0.1", 7891),
        isFalse,
        reason: '端口不同就是没生效；只比 host 会误判成「已生效」→ 用户上不了网',
      );
    });

    test('按协议写法（http=…;https=…）也要认得出来', () {
      const raw =
          "    ProxyServer    REG_SZ    http=127.0.0.1:2253;https=127.0.0.1:2253";
      expect(DesktopVpnServiceImpl.proxyServerValueMatches(raw, "127.0.0.1", 2253), isTrue);
      expect(DesktopVpnServiceImpl.proxyServerValueMatches(raw, "127.0.0.1", 2254), isFalse);
    });

    test('端口 0 / 空值绝不算生效（这正是「系统代理空白」那种坏状态）', () {
      expect(
        DesktopVpnServiceImpl.proxyServerValueMatches(
          "ProxyServer    REG_SZ    127.0.0.1:0",
          "127.0.0.1",
          0,
        ),
        isFalse,
        reason: '端口 0 是坏值，调用方本来就该拒绝，解析层也不该把它当有效',
      );
      expect(DesktopVpnServiceImpl.proxyServerValueMatches("", "127.0.0.1", 7890), isFalse);
      expect(
        DesktopVpnServiceImpl.proxyServerValueMatches(
          "错误: 系统找不到指定的注册表项或值。",
          "127.0.0.1",
          7890,
        ),
        isFalse,
      );
    });

    test('大小写与多余空白不影响判断', () {
      expect(
        DesktopVpnServiceImpl.proxyServerValueMatches(
          "  PROXYSERVER   REG_SZ   127.0.0.1:7890  ",
          "127.0.0.1",
          7890,
        ),
        isTrue,
      );
    });
  });
}
