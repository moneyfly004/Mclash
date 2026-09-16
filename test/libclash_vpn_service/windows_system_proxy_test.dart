@TestOn('windows')
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:libclash_vpn_service/src/models.dart';
import 'package:libclash_vpn_service/src/desktop_impl.dart' as desktop_impl;
import 'package:libclash_vpn_service/vpn_service.dart';

/// Windows 系统代理**真机**回归（只在 Windows 上跑，CI 的 Windows runner 会执行）。
///
/// 用户反馈：「Windows 连上之后系统代理是空白，无法改变 IP 和端口」。
/// 修的是端口链路（内核实际监听端口 → 应用侧 → 系统代理），但那条链最终落到
/// 「注册表里到底写了什么」。所以我在这里**真的读写一次注册表**：
/// 写入 → 精确读回 host:port → 清理 → 确认清理干净。
///
/// 在 macOS/Linux 上这个文件会被跳过（Android 更是没有系统代理这个概念）。
void main() {
  const key = r"HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings";
  const host = "127.0.0.1";
  const port = 17899;

  Future<String> rawValue(String name) =>
      desktop_impl.DesktopVpnServiceImpl.readSystemProxyRaw(value: name);

  Future<String> fullKey() async {
    final r = await Process.run("reg", ["query", key]);
    return "${r.stdout}${r.stderr}";
  }

  Future<String> query(String name) async {
    final r = await Process.run("reg", ["query", key, "/v", name]);
    return r.stdout.toString();
  }

  tearDown(() async {
    await FlutterVpnService.cleanSystemProxy();
  });

  test('写入系统代理后，注册表里就是 host:port（不是空白、不是 0）', () async {
    final ok = await FlutterVpnService.setSystemProxy(
      ProxyOption(host, port, const ["localhost"]),
    );
    if (!ok) {
      // 失败时把注册表真实内容打出来：CI 日志里直接可见，不用再猜
      // ignore: avoid_print
      print("DIAG ProxyEnable: ${await rawValue('ProxyEnable')}");
      // ignore: avoid_print
      print("DIAG ProxyServer: ${await rawValue('ProxyServer')}");
      // ignore: avoid_print
      print("DIAG 整键: ${await fullKey()}");
    }
    expect(ok, isTrue, reason: '写入必须成功');

    final enable = await query("ProxyEnable");
    expect(
      enable.contains(RegExp(r"0x1\b")),
      isTrue,
      reason: 'ProxyEnable 必须是 1，否则 Windows 认为代理没开（设置页显示空白）：$enable',
    );

    final server = await query("ProxyServer");
    expect(
      server.contains("$host:$port"),
      isTrue,
      reason: 'ProxyServer 必须精确是 $host:$port：$server',
    );
    expect(
      server.contains(":0"),
      isFalse,
      reason: '端口 0 会让 Windows 把流量发给不存在的代理（这正是「空白代理」的坏状态）',
    );

    expect(
      server.contains("Instance of"),
      isFalse,
      reason:
          '绝不能把 Dart 对象描述写进注册表：插值写成成员访问（变量点 port）'
          '时只会插入对象本身，注册表里会变成 127.0.0.1 加一段 Instance of 描述 —— '
          'Windows 解析不出地址端口，设置页显示空白、用户也改不动（真实事故）',
    );

    // 读回校验接口也必须认（App 用它判断「已生效」）
    final matched = await FlutterVpnService.getSystemProxyEnable(
      ProxyOption(host, port, const []),
    );
    expect(matched, isTrue, reason: '读回校验应当认为已生效');
  });

  test('端口不一致时必须判定为「未生效」，不能自欺欺人', () async {
    await FlutterVpnService.setSystemProxy(
      ProxyOption(host, port, const []),
    );
    final matched = await FlutterVpnService.getSystemProxyEnable(
      ProxyOption(host, port + 1, const []),
    );
    expect(
      matched,
      isFalse,
      reason: '只比 host 不比端口会让「端口错但 host 对」被判成已生效 —— 用户就上不了网',
    );
  });

  test('清理后不留残留（下次连接不会被旧值干扰）', () async {
    await FlutterVpnService.setSystemProxy(
      ProxyOption(host, port, const []),
    );
    final cleaned = await FlutterVpnService.cleanSystemProxy();
    expect(cleaned, isTrue);

    final enable = await query("ProxyEnable");
    expect(
      enable.contains(RegExp(r"0x1\b")),
      isFalse,
      reason: '清理后 ProxyEnable 必须是 0：$enable',
    );
  });
}
