@TestOn('windows')
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:libclash_vpn_service/src/models.dart';
import 'package:libclash_vpn_service/src/desktop_impl.dart' as desktop_impl;
import 'package:libclash_vpn_service/src/windows_wininet.dart' as windows_wininet;
import 'package:libclash_vpn_service/vpn_service.dart';

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

  test('写完必须广播 InternetSetOption —— 系统缓存里的「默认连接」也要同步', () async {
    final notified = desktop_impl.notifySystemProxyChangedForTest();
    expect(notified, isTrue, reason: 'Windows 上必须能调用到 wininet.dll 完成广播');

    final ok = await FlutterVpnService.setSystemProxy(
      ProxyOption(host, port, const []),
    );
    expect(ok, isTrue);

    final r = await Process.run("reg", [
      "query",
      r"HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Connections",
      "/v",
      "DefaultConnectionSettings",
    ]);
    final dump = r.stdout.toString().replaceAll(" ", "").toUpperCase();
    final hex = "127.0.0.1:$port"
        .codeUnits
        .map((c) => c.toRadixString(16).padLeft(2, "0").toUpperCase())
        .join();
    expect(
      dump.contains(hex),
      isTrue,
      reason:
          '广播之后系统缓存里的代理必须是 $host:$port（十六进制 $hex）；'
          '缓存不同步时，Windows「设置 → 代理」页面会显示旧的/空白状态：$dump',
    );
  });

  test('官方 API：当前连接的代理能写进去、读回来、清干净', () {
    final original = windows_wininet.querySystemProxyForConnection();
    try {
      final ok = windows_wininet.applySystemProxyForConnection(
        server: "$host:${port + 1}",
        bypass: "localhost",
      );
      expect(ok, isTrue, reason: 'Windows 上这个官方接口必须可用');

      final readBack = windows_wininet.querySystemProxyForConnection();
      expect(
        readBack.contains("$host:${port + 1}"),
        isTrue,
        reason: '写完之后读回来必须一致（界面读的就是这份数据）：$readBack',
      );
    } finally {
      if (original.trim().isEmpty) {
        windows_wininet.clearSystemProxyForConnection();
      } else {
        windows_wininet.applySystemProxyForConnection(
          server: original.trim(),
          bypass: "localhost",
        );
      }
    }
    expect(
      windows_wininet.connectionProxyEnabled(),
      isFalse,
      reason: '测试结束必须把当前连接的代理关掉（flags 里不能还留着「走代理」位）',
    );
  });

  test('广播 WM_SETTINGCHANGE（界面刷新的关键一步）', () async {
    // ⚠️ 回归点：这里以前用 SMTO_NOTIMEOUTIFNOTHUNG(0x8)，只要系统里有一个顶层
    // 窗口不处理这条消息（实测 WPS Office 的 Qt 内部窗口），调用线程就会**永久**
    // 卡死在 user32 里，整个 App 变「未响应」，只能强制结束进程。
    // 现在同步版本改为 SMTO_ABORTIFHUNG + 真实超时（所以返回值允许是 false：
    // 有窗口不响应时会立刻放弃），生产路径更是完全不再同步广播。
    // 关键断言是「必须能返回」，而不是返回值本身。
    final sync = windows_wininet.broadcastInternetSettingsChanged();
    expect(
      sync,
      anyOf(isTrue, isFalse),
      reason: '同步广播必须有真实超时：任何情况下都必须能返回，不能永久阻塞',
    );
    expect(
      windows_wininet.broadcastInternetSettingsChangedAsync(),
      isTrue,
      reason: 'FFI 可用时必须能发起后台广播（不得阻塞调用线程）',
    );
    await Future<void>.delayed(const Duration(milliseconds: 300));
  });

  test('清理后不把「当前连接」那份写成直连（否则别的客户端界面会空白）', () async {
    final before = windows_wininet.querySystemProxyForConnection();
    final hadProxy = windows_wininet.connectionProxyEnabled();
    if (!hadProxy) {
      return;
    }
    await FlutterVpnService.cleanSystemProxy();
    expect(
      windows_wininet.querySystemProxyForConnection(),
      before,
      reason: '不是我们设置的代理，清理时一行都不该动（界面读的就是这份数据）',
    );
  });

  test('旁路列表过滤 <local>（字面 <local> 会让「局域网设置」对话框空白）', () async {
    await FlutterVpnService.setSystemProxy(
      ProxyOption(host, port, const ["<local>", "localhost"]),
    );
    final raw = await query("ProxyOverride");
    final value = raw.contains("REG_SZ")
        ? raw.split("REG_SZ").last.trim()
        : raw.trim();
    expect(
      value.contains("<local>"),
      isFalse,
      reason: '字面 <local> 必须被过滤，否则 inetcpl.cpl 对话框空白：$value',
    );
    expect(
      value.contains("localhost"),
      isTrue,
      reason: '合法旁路项要保留：$value',
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

  test('DefaultConnectionSettings blob：与 Windows 官方 API 生成的格式对齐', () async {
    String hex(List<int>? b) =>
        (b ?? []).map((e) => e.toRadixString(16).padLeft(2, '0')).join();

    final original = windows_wininet.readDefaultConnectionSettings();
    try {
      windows_wininet.applySystemProxyForConnection(
        server: "$host:$port",
        bypass: "localhost",
      );
      final winBlob = windows_wininet.readDefaultConnectionSettings();
      // ignore: avoid_print
      print('WIN-BLOB ${hex(winBlob)}');

      final myBlob = windows_wininet.buildDefaultConnectionSettingsBlob(
        flags: 0x3,
        server: "$host:$port",
        bypass: "localhost",
      );
      // ignore: avoid_print
      print('MY-BLOB  ${hex(myBlob)}');

      expect(
        windows_wininet.defaultConnectionSettingsContains(winBlob, "$host:$port"),
        isTrue,
        reason: '解析函数要能识别 Windows 生成的 blob 里的地址',
      );
      expect(
        (windows_wininet.parseDefaultConnectionSettingsFlags(winBlob) ?? 0) & 0x2,
        isNot(0),
        reason: 'Windows blob 的 flags 必须含 PROXY 位',
      );

      final wrote = windows_wininet.writeDefaultConnectionSettings(myBlob);
      expect(wrote, isTrue, reason: '写 REG_BINARY 必须成功');
      final reread = windows_wininet.readDefaultConnectionSettings();
      expect(
        windows_wininet.defaultConnectionSettingsContains(reread, "$host:$port"),
        isTrue,
        reason: '写完后注册表里的 blob 必须含 $host:$port（界面读的就是它）',
      );

      expect(winBlob, isNotNull);
      final winNoCounter = <int>[
        ...winBlob!.sublist(0, 4),
        ...winBlob.sublist(8),
      ];
      final myNoCounter = <int>[
        ...myBlob.sublist(0, 4),
        ...myBlob.sublist(8),
      ];
      expect(
        winNoCounter.sublist(0, myNoCounter.length),
        myNoCounter,
        reason: '构造的 blob 应与 Windows 生成的数据部分一致（counter 除外），详见 WIN-BLOB / MY-BLOB',
      );
    } finally {
      if (original != null) {
        windows_wininet.writeDefaultConnectionSettings(original);
      } else {
        windows_wininet.writeDefaultConnectionSettings(
          windows_wininet.buildDefaultConnectionSettingsBlob(
            flags: 0x1,
            server: "",
            bypass: "",
          ),
        );
      }
    }
  });

  test('回归：ProxyServer 值还在、但 ProxyEnable 被关掉 → 必须判定「未生效」', () async {
    // 真机报障场景：别的代理客户端退出时只把开关置 0、地址值留在注册表。
    // 以前 getSystemProxyEnable() 只比对 ProxyServer 字符串，于是判定"已生效"，
    // 看守永远不恢复、界面一直显示已连接，而流量其实已经不走代理。
    await Process.run("reg", [
      "add", key, "/v", "ProxyServer", "/t", "REG_SZ", "/d", "$host:$port", "/f",
    ]);
    await Process.run("reg", [
      "add", key, "/v", "ProxyEnable", "/t", "REG_DWORD", "/d", "0", "/f",
    ]);

    final option = ProxyOption(host, port, const []);
    expect(
      await FlutterVpnService.getSystemProxyEnable(option),
      isFalse,
      reason: '开关是关的就必须判未生效，否则看守永远发现不了「代理没了」',
    );

    // 重设之后必须判定为已生效（否则会出现"永远修不好"的死循环）
    await FlutterVpnService.setSystemProxy(option);
    expect(await FlutterVpnService.getSystemProxyEnable(option), isTrue);
  });
}