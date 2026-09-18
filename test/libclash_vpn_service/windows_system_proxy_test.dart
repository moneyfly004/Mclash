@TestOn('windows')
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:libclash_vpn_service/src/models.dart';
import 'package:libclash_vpn_service/src/desktop_impl.dart' as desktop_impl;
import 'package:libclash_vpn_service/src/windows_wininet.dart' as windows_wininet;
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

  test('写完必须广播 InternetSetOption —— 系统缓存里的「默认连接」也要同步', () async {
    // 这是用户报的「系统代理没变，但能上网」的直接修复点：
    // 只写注册表只对**之后新建的连接**生效，Windows 自己的设置页 / Internet 选项
    // 读的是缓存的 DefaultConnectionSettings。必须在写完后调用
    // InternetSetOption(SETTINGS_CHANGED) + (REFRESH)，Windows 才会把注册表值
    // 同步进缓存并通知所有 WinINET 使用者。
    // 本机实测（Windows 11 26200）：不广播时缓存里还是上一次的值。
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

  // 用户第二轮反馈：「注册表里 ProxyEnable=1、ProxyServer=127.0.0.1:17890 都在，
  // 但 Internet 选项里仍然是空白」。原因是那块界面读的是**每个连接的缓存副本**
  // （Connections\DefaultConnectionSettings），只写全局值 + 广播在部分环境下
  // 不会把那份副本刷新。修法是调用 Windows 自己用的官方接口
  // InternetSetOption(INTERNET_OPTION_PER_CONNECTION_OPTION)，
  // 注册表与缓存一起更新。这里在真机 Windows 上验证「写进去 → 读回来 → 清干净」。
  test('官方 API：当前连接的代理能写进去、读回来、清干净', () {
    final original = windows_wininet.querySystemProxyForConnection();
    try {
      final ok = windows_wininet.applySystemProxyForConnection(
        server: "$host:${port + 1}",
        bypass: "<local>",
      );
      expect(ok, isTrue, reason: 'Windows 上这个官方接口必须可用');

      final readBack = windows_wininet.querySystemProxyForConnection();
      expect(
        readBack.contains("$host:${port + 1}"),
        isTrue,
        reason: '写完之后读回来必须一致（界面读的就是这份数据）：$readBack',
      );
    } finally {
      // 还原：原来有值就写回去，原来没有就清掉 —— 不能污染后续 CI 步骤的网络
      if (original.trim().isEmpty) {
        windows_wininet.clearSystemProxyForConnection();
      } else {
        windows_wininet.applySystemProxyForConnection(
          server: original.trim(),
          bypass: "<local>",
        );
      }
    }
    expect(
      windows_wininet.connectionProxyEnabled(),
      isFalse,
      reason: '测试结束必须把当前连接的代理关掉（flags 里不能还留着「走代理」位）',
    );
  });

  // 参考实现（mysoftware/moneyfly 的 SystemProxyManager）比我们多这一步：
  // 广播 WM_SETTINGCHANGE + lParam="InternetSettings"。Windows 的「Internet 选项 /
  // 设置 → 代理」界面靠这条消息重新读取代理设置 —— 我们以前只有
  // InternetSetOption(SETTINGS_CHANGED/REFRESH)，于是出现「注册表里确实有地址端口、
  // 也能上网，但界面一片空白」。这里在真机 Windows 上确认这条广播可用。
  test('广播 WM_SETTINGCHANGE（界面刷新的关键一步）', () async {
    // 同步版仍可调用（测试/诊断用），超时已收紧到 200ms。
    expect(
      windows_wininet.broadcastInternetSettingsChanged(),
      isTrue,
      reason: 'user32!SendMessageTimeout 必须可调用，否则界面不会刷新',
    );
    // 连接/断开路径用的是**不阻塞**的这一条：广播不属于「连接成功了没有」，
    // 不该让用户的点击陪着等机器上每一个顶层窗口。
    expect(
      windows_wininet.broadcastInternetSettingsChangedAsync(),
      isTrue,
      reason: 'FFI 可用时必须能发起后台广播',
    );
    // 让后台那一次跑完，避免测试结束后还在动系统设置
    await Future<void>.delayed(const Duration(milliseconds: 300));
  });

  // 用户实测的跨软件事故（第二轮）：用了 Mclash 之后，MoneyFly 连上、Windows 里
  // 却不显示 127.0.0.1 和端口。根因是清理时把「每连接」那份（界面读的数据）
  // 无条件写成「直连」，而 MoneyFly / Clash Party 只写注册表、从不碰这份缓存。
  // 这里在真机上确认：**清理不会把「当前连接」那份写成直连**。
  test('清理后不把「当前连接」那份写成直连（否则别的客户端界面会空白）', () async {
    // 先摆出一个「别的客户端设置好的」状态：每连接那份有值。
    final before = windows_wininet.querySystemProxyForConnection();
    final hadProxy = windows_wininet.connectionProxyEnabled();
    if (!hadProxy) {
      // CI 机器上通常没有代理，跳过这一条（断言需要「原本有值」这个前提）。
      return;
    }
    await FlutterVpnService.cleanSystemProxy();
    // 不是我们写的 → 清理应当直接跳过，那台机器上的值必须原样保留。
    expect(
      windows_wininet.querySystemProxyForConnection(),
      before,
      reason: '不是我们设置的代理，清理时一行都不该动（界面读的就是这份数据）',
    );
  });

  test('旁路列表不重复（用户实测注册表里出现 <local>;<local>）', () async {
    await FlutterVpnService.setSystemProxy(
      ProxyOption(host, port, const ["<local>", "localhost"]),
    );
    // reg 输出形如：    ProxyOverride    REG_SZ    <local>;localhost
    // 取 REG_SZ 之后的那段才是值（以前把 "ProxyOverride REG_SZ" 也当成字段，
    // 于是第一个分片永远不等于 <local>，断言恒为 0）。
    final raw = await query("ProxyOverride");
    final value = raw.contains("REG_SZ")
        ? raw.split("REG_SZ").last.trim()
        : raw.trim();
    expect(
      value.split(";").where((e) => e.trim() == "<local>").length,
      1,
      reason: '默认列表已含 <local>，不能再拼一次：$value',
    );
    expect(value.contains("<local>;<local>"), isFalse, reason: '不能出现重复项：$value');
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

  // 官方 API 在用户机器上会返回 0（实测诊断），界面因此空白。兜底是**直接写**
  // Connections\DefaultConnectionSettings 这份 REG_BINARY —— 它是「设置 → 代理 /
  // Internet 选项」真正读的数据。这个用例在真实 Windows 上验证：我们构造的 blob
  // 写进注册表后，WinINET 能否正确读回（格式错了这里立刻红）。
  test('DefaultConnectionSettings blob：与 Windows 官方 API 生成的格式对齐', () async {
    String hex(List<int>? b) =>
        (b ?? []).map((e) => e.toRadixString(16).padLeft(2, '0')).join();

    final original = windows_wininet.readDefaultConnectionSettings();
    try {
      // 1) 让 Windows 官方 API 生成一份「权威」blob（runner 上这个 API 是成功的），
      //    读出来作为格式基准。
      windows_wininet.applySystemProxyForConnection(
        server: "$host:$port",
        bypass: "<local>",
      );
      final winBlob = windows_wininet.readDefaultConnectionSettings();
      // ignore: avoid_print
      print('WIN-BLOB ${hex(winBlob)}');

      // 2) 我构造的 blob，对比基准。
      final myBlob = windows_wininet.buildDefaultConnectionSettingsBlob(
        flags: 0x3,
        server: "$host:$port",
        bypass: "<local>",
      );
      // ignore: avoid_print
      print('MY-BLOB  ${hex(myBlob)}');

      // 3) 解析函数必须能读 Windows 生成的 blob（否则我的格式理解就是错的）。
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

      // 4) 直接写我构造的 blob → 读回注册表 → 内容一致（确定性的写入正确性）。
      final wrote = windows_wininet.writeDefaultConnectionSettings(myBlob);
      expect(wrote, isTrue, reason: '写 REG_BINARY 必须成功');
      final reread = windows_wininet.readDefaultConnectionSettings();
      expect(
        windows_wininet.defaultConnectionSettingsContains(reread, "$host:$port"),
        isTrue,
        reason: '写完后注册表里的 blob 必须含 $host:$port（界面读的就是它）',
      );

      // 5) 我构造的 blob 必须是 Windows 生成的 blob 的「数据前缀」。
      //    Windows 会在末尾补 0 到它的缓冲大小，而我们按长度字段紧凑写 —— 所以
      //    只比较到 autoConfigLen 结束为止，并跳过 counter（[4..8]，Windows 自增）。
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
  });}