import 'package:flutter_test/flutter_test.dart';
import 'package:libclash_vpn_service/src/desktop_impl.dart' as desktop_impl;
import 'package:libclash_vpn_service/src/windows_wininet.dart' as wininet;

/// 「清理系统代理」为什么不能写坏**别的客户端**的设置（跨平台回归）。
///
/// 用户实测的事故：用了 Mclash 之后，MoneyFly 连上、Windows 里却不显示
/// 127.0.0.1 和端口（注册表里有值、也能上网，界面是空白）。根因是 Windows
/// 界面读的是「每连接」那份缓存（`Connections\DefaultConnectionSettings`），
/// 而 MoneyFly / Clash Party / Clash Verge **只写注册表**，从不碰这份缓存 ——
/// 我们清理时无条件把缓存写成「直连」，等于把别人的代理从界面上抹掉了。
///
/// 修法是：只有快照里记着「我们写入之前它是什么」时才动那份缓存。
/// 这里把那条判定钉死（纯逻辑，不需要真机）。
void main() {
  group('每连接缓存的还原判定', () {
    test('原本是直连 → 才允许写回直连', () {
      // clearSystemProxyForConnection 会写「直连」；restore 在「原本没代理」时
      // 应该选它。
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
      // 读不到 flags 的机器上，界面本来也没显示过我们的值 —— 写直连不会让
      // 界面「从有变无」，这是这个默认值安全的原因。
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
      // reg query 给的是 "0x1"；我们用 RegQueryValueEx 读回来再格式化，同样给
      // "0x1"。但历史日志里见过 "1" 的形式，两种都必须认。
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
