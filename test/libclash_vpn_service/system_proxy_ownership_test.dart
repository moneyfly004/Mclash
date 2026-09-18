import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:libclash_vpn_service/src/desktop_impl.dart' as desktop_impl;
import 'package:libclash_vpn_service/src/windows_wininet.dart' as wininet;

/// 系统代理的「归属判定」与「桌面日志」回归（**跨平台**，CI 的 Linux runner 也跑）。
///
/// 这两块各对应一次真实用户事故：
///   * 归属判定错了 → Mclash 启动时把**别的客户端**（MoneyFly / Clash Party）
///     正在用的系统代理当成自己的残留清掉（用户实测：「用了 Mclash 之后，
///     MoneyFly 连上了、Windows 里却不显示 127.0.0.1 和端口了」）。
///   * desktopLog 写成自己调自己 → 一行日志被写几百上千次（用户实测日志刷屏），
///     而 Log 是**同步写磁盘**，于是连接/断开直接卡顿。
void main() {
  group('desktopLog 绝不递归', () {
    test('一次调用只写一行（曾经递归到栈溢出，一行变几百行）', () {
      var calls = 0;
      final lines = <String>[];
      desktop_impl.desktopLogSink = (line) {
        calls++;
        lines.add(line);
      };
      addTearDown(() => desktop_impl.desktopLogSink = null);

      final sw = Stopwatch()..start();
      desktop_impl.desktopLog("[perf] 断开：撤系统代理 + 拆 TUN 用时 0 ms");
      sw.stop();

      expect(
        calls,
        1,
        reason: 'desktopLog 曾经写成 `desktopLog(line)`（自己调自己），'
            '实测一次调用会写 11585 行并撞一次栈溢出 —— 日志刷屏 + 同步写盘卡顿',
      );
      expect(lines.single, contains("撤系统代理"));
      // 递归时单次调用要 400µs 以上（还要吃掉一次 StackOverflowError）
      expect(
        sw.elapsedMilliseconds,
        lessThan(50),
        reason: '写一行日志不该有任何可观测的停顿',
      );
    });

    test('sink 抛异常时不吞掉调用方，也不递归', () {
      var calls = 0;
      desktop_impl.desktopLogSink = (_) {
        calls++;
        throw StateError("sink 坏了");
      };
      addTearDown(() => desktop_impl.desktopLogSink = null);

      expect(() => desktop_impl.desktopLog("x"), returnsNormally);
      expect(calls, 1, reason: 'sink 失败应该只试一次，然后落到 stderr 兜底');
    });

    test('sink 内部又回头调 desktopLog 时不会无限递归', () {
      var calls = 0;
      desktop_impl.desktopLogSink = (line) {
        calls++;
        if (calls < 10) {
          desktop_impl.desktopLog(line);
        }
      };
      addTearDown(() => desktop_impl.desktopLogSink = null);

      expect(() => desktop_impl.desktopLog("y"), returnsNormally);
      expect(calls, 1, reason: '重入必须被拦住（只写 stderr），否则就是递归');
    });
  });

  group('注册表原始输出的取值', () {
    test('REG_SZ 带空格的值要完整取出（旁路列表可能含空格）', () {
      const raw = "\r\n"
          "HKEY_CURRENT_USER\\Software\\Microsoft\\Windows\\CurrentVersion\\Internet Settings\r\n"
          "    ProxyOverride    REG_SZ    <local>;localhost; 127.0.0.1\r\n\r\n";
      expect(
        desktop_impl.SystemProxySnapshot.valueText(raw, "ProxyOverride"),
        "<local>;localhost; 127.0.0.1",
        reason: '按空白 split 取末段会把用户手填的旁路列表截断（真实事故）',
      );
    });

    test('值不存在时返回 null（reg query 的报错输出不能当值）', () {
      const err = "\r\nERROR: The system was unable to find the specified "
          "registry key or value.\r\n\r\n";
      expect(
        desktop_impl.SystemProxySnapshot.valueText(err, "ProxyServer"),
        isNull,
      );
      expect(desktop_impl.SystemProxySnapshot.valueText(null, "ProxyServer"), isNull);
    });

    test('ProxyEnable 的 0x1 / 0x0 能取出来（决定还原成开还是关）', () {
      const raw = "    ProxyEnable    REG_DWORD    0x1\r\n";
      expect(
        desktop_impl.SystemProxySnapshot.valueText(raw, "ProxyEnable"),
        "0x1",
      );
    });
  });

  group('回环代理端口解析（决定「能不能清理」）', () {
    test('认这几种本机写法', () {
      expect(wininet.loopbackProxyPort("127.0.0.1:7890"), 7890);
      expect(wininet.loopbackProxyPort("localhost:2080"), 2080);
      expect(wininet.loopbackProxyPort(" 127.0.0.1:17890 "), 17890);
      expect(wininet.loopbackProxyPort("127.0.0.1:7890;https=127.0.0.1:7891"), 7890);
    });

    test('不是「单机地址+端口」一律 null → 判成别人的代理，绝不清理', () {
      expect(wininet.loopbackProxyPort(null), isNull);
      expect(wininet.loopbackProxyPort(""), isNull);
      expect(wininet.loopbackProxyPort("10.0.0.2:7890"), isNull);
      expect(wininet.loopbackProxyPort("http=127.0.0.1:80"), isNull);
      expect(wininet.loopbackProxyPort("127.0.0.1:0"), isNull);
      expect(wininet.loopbackProxyPort("127.0.0.1:99999"), isNull);
    });
  });

  group('端口存活探测（活代理不能碰、死残留才清）', () {
    test('有人监听 → true；没人监听 → false', () async {
      final server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
      addTearDown(() => server.close());
      expect(await wininet.isLocalPortAlive(server.port), isTrue);

      final free = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
      final freePort = free.port;
      await free.close();
      expect(await wininet.isLocalPortAlive(freePort), isFalse);
    });
  });

  test('默认会写「界面读的那份」（每连接），否则 Windows 界面永远空白', () {
    expect(
      desktop_impl.usePerConnectionProxyWrite,
      isTrue,
      reason: '「设置 → 代理 / Internet 选项」读的是每连接那份；'
          '只写注册表时用户在界面上看到的就是空白（0.0.1 的实测结论）',
    );
  });
}
