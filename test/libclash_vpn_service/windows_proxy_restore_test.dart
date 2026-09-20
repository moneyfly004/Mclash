import 'package:flutter_test/flutter_test.dart';
import 'package:libclash_vpn_service/src/desktop_impl.dart' as desktop_impl;
import 'package:libclash_vpn_service/src/windows_wininet.dart' as wininet;

void main() {
  group('每连接缓存的还原判定', () {
    test('原本是直连 → 才允许写回直连', () {
      expect(
        wininet.restoreFlagsDecideForTest(flags: wininet.kProxyTypeDirect, server: ""),
        "clear",
      );
    });

    test('原本配着代理 → 必须把原值写回去，不能清成直连', () {
      expect(
        wininet.restoreFlagsDecideForTest(
          flags: wininet.kProxyTypeProxy,
          server: "10.0.0.8:8080",
        ),
        "write",
      );
    });

    test('flags 说启用了代理，但服务器是空的 → 当直连处理（写回去也没意义）', () {
      expect(
        wininet.restoreFlagsDecideForTest(flags: wininet.kProxyTypeProxy, server: "  "),
        "clear",
      );
    });

    test('flags 读不到（null）→ 按直连处理，且不会写坏别的客户端', () {
      expect(
        wininet.restoreFlagsDecideForTest(flags: null, server: ""),
        "clear",
      );
    });

    test('PROXY_TYPE_DIRECT|PROXY_TYPE_PROXY 组合位也算「原本配着代理」', () {
      expect(
        wininet.restoreFlagsDecideForTest(
          flags: wininet.kProxyTypeDirect | wininet.kProxyTypeProxy,
          server: "127.0.0.1:8080",
        ),
        "write",
      );
    });
  });

  group('ProxyEnable 原始值的判定', () {
    test('0x1 / 1 都算开（reg.exe 与 FFI 两条路径的输出格式不同）', () {
      expect(desktop_impl.SystemProxySnapshot.isEnabledRaw("0x1"), isTrue);
      expect(desktop_impl.SystemProxySnapshot.isEnabledRaw("1"), isTrue);
      expect(desktop_impl.SystemProxySnapshot.isEnabledRaw("0x0"), isFalse);
      expect(desktop_impl.SystemProxySnapshot.isEnabledRaw("0"), isFalse);
      expect(desktop_impl.SystemProxySnapshot.isEnabledRaw(null), isFalse);
      expect(desktop_impl.SystemProxySnapshot.isEnabledRaw(""), isFalse);
    });
  });

  group('清理时的还原判据（快照解析）', () {
    test('解析出的值才是还原依据：文本里没有该值 → null（→ 删除我们写的）', () {
      const raw = "\r\nERROR: The system was unable to find the specified "
          "registry key or value.\r\n\r\n";
      expect(desktop_impl.SystemProxySnapshot.valueText(raw, "ProxyServer"), isNull);
    });

    test('用户原本的公司代理要能被解析出来（含空格的旁路列表不能截断）', () {
      const raw = "    ProxyServer    REG_SZ    10.0.0.8:8080\r\n"
          "    ProxyOverride    REG_SZ    <local>; 10.*\r\n";
      expect(
        desktop_impl.SystemProxySnapshot.valueText(raw, "ProxyServer"),
        "10.0.0.8:8080",
      );
      expect(
        desktop_impl.SystemProxySnapshot.valueText(raw, "ProxyOverride"),
        "<local>; 10.*",
      );
    });
  });
}
