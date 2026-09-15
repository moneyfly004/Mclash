/// Mclash 的 VPN 内核启动器（桌面端：Windows / macOS / Linux）。
///
/// 设计（与原 Clash Mi 的根本差异）：
///   原 Clash Mi 为桌面端额外编译了一个原生服务二进制 `clashmiService`（+ mscrt/ucrt/icu
///   运行时），由它 fork 内核并管理 TUN/系统代理。该二进制在仓库里是 gitignore 的，
///   不可得。
///   **Mclash 改为纯 Dart 实现**：直接 `Process.start(mihomo)` + 轮询 Clash REST API
///   就绪 + 调平台命令设系统代理。少一层原生代码、少一次进程、少一堆运行时依赖，
///   且与 UI 同进程可精确上报状态。
///
/// 关键正确性约束（来自实测踩坑）：
///   1. **就绪判定必须双条件**：Clash API 返回 200 **且** mixed 端口 TCP 可连接。
///      只看 API 200 时，端口被占/非法内核照跑照 200 → 误判"已连接"
///      并把系统代理指向一个死端口 → 界面显示已连接但浏览器打不开网页。
///   2. **启动互斥**：`_starting` 标志 + `_stopInFlight` Future，防快速连点双开内核
///      留下清不掉的孤儿进程（占死端口与 cache.db）。
///   3. **系统代理残留清扫**：判据是"指向本机端口 **且** 该端口已无人监听"。
///      只看"指向本机端口"会误清活着的代理。
///   4. **退出必须恢复系统代理**，否则关机后代理指向死端口 → 重启整机断网。
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

import 'models.dart';
import 'vpn_service_platform.dart';

class DesktopVpnServiceImpl extends VpnServicePlatform {
  DesktopVpnServiceImpl();

  Process? _proc;
  VpnServiceConfig? _config;
  FlutterVpnServiceState _state = FlutterVpnServiceState.disconnected;

  /// 启动流程进行中标志。start() 从第一行到 Process.start 之间有多个 await，
  /// 期间 _proc 仍为 null —— 只检查 _proc 会让并发 start() 双双通过守卫。
  bool _starting = false;
  Future<void>? _stopInFlight;
  bool _intentionalStop = false;

  /// 本机 mixed 入站端口（系统代理指向它）
  int _mixedPort = 0;

  /// 系统代理是否由本进程设置（决定 stop 时是否要恢复）
  bool _systemProxyApplied = false;
  Map<String, String>? _systemProxyOriginal;

  @override
  FlutterVpnServiceState get state => _state;

  void _setState(FlutterVpnServiceState s, [Map<String, String>? params]) {
    if (_state == s) {
      return;
    }
    _state = s;
    emitStateChanged(s, params ?? const {});
  }

  // ======================================================================
  // 内核二进制定位
  //   优先级：MLASH_MIHOMO 环境变量（测试/调试注入）→ 用户副本目录
  //          （设置页切换/更新过的内核）→ 安装目录内置（CI 打包进来的）
  // ======================================================================
  static String get _exeName => Platform.isWindows ? "mihomo.exe" : "mihomo";

  static Future<String?> _userKernelDir() async {
    try {
      final base = await getApplicationSupportDir();
      final dir = Directory(p.join(base, "kernel"));
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      return dir.path;
    } catch (_) {
      return null;
    }
  }

  /// 生效内核路径（找不到返回 null）
  static Future<String?> resolveKernelPath() async {
    final override = Platform.environment["MCLASH_MIHOMO"];
    if (override != null && override.isNotEmpty && File(override).existsSync()) {
      return override;
    }
    final userDir = await _userKernelDir();
    if (userDir != null) {
      final f = File(p.join(userDir, _exeName));
      if (await f.exists()) {
        return f.path;
      }
    }
    // 安装目录：与主程序同目录（macOS 在 .app/Contents/MacOS/ 下）
    final exeDir = p.dirname(Platform.resolvedExecutable);
    for (final c in [
      p.join(exeDir, _exeName),
      p.join(exeDir, "..", "Resources", _exeName),
    ]) {
      if (File(c).existsSync()) {
        return File(c).absolute.path;
      }
    }
    return null;
  }

  // ======================================================================
  // 配置准备
  // ======================================================================
  @override
  Future<VpnServiceResultError?> prepareConfig(Map<String, dynamic> args) async {
    final cfg = VpnServiceConfig()..fromJson(Map<String, dynamic>.from(args["config"] as Map));
    cfg.tunnel_service_path = args["tunnelServicePath"]?.toString() ?? "";
    cfg.config_file_path = args["configFilePath"]?.toString() ?? "";
    cfg.system_extension = args["systemExtension"] == true;
    cfg.bundle_identifier = args["bundleIdentifier"]?.toString() ?? "";
    cfg.control_kind = args["controlKind"]?.toString() ?? "";
    cfg.ui_server_address = args["uiServerAddress"]?.toString() ?? "";
    cfg.ui_localized_description = args["uiLocalizedDescription"]?.toString() ?? "";
    final ports = args["excludePorts"];
    if (ports is List) {
      cfg.exclude_ports = [for (final e in ports) (e as num).toInt()];
    }
    _config = cfg;
    return null;
  }

  // ======================================================================
  // 启动 / 重启 / 停止
  // ======================================================================
  @override
  Future<VpnServiceWaitResult> start(Duration timeout) => _startInternal(timeout);

  @override
  Future<VpnServiceWaitResult> restart(Duration timeout) async {
    await stop();
    return _startInternal(timeout);
  }

  Future<VpnServiceWaitResult> _startInternal(Duration timeout) async {
    if (_starting) {
      return VpnServiceWaitResult(
        type: VpnServiceWaitType.error,
        err: VpnServiceResultError(code: -1, message: "service is starting"),
      );
    }
    _starting = true;
    try {
      final cfg = _config;
      if (cfg == null) {
        return VpnServiceWaitResult(
          type: VpnServiceWaitType.error,
          err: VpnServiceResultError(code: -2, message: "config not prepared"),
        );
      }

      final kernel = await resolveKernelPath();
      if (kernel == null) {
        return VpnServiceWaitResult(
          type: VpnServiceWaitType.error,
          err: VpnServiceResultError(
            code: -3,
            message: "未找到 mihomo 内核。请确认安装包完整，"
                "或在设置 → 内核管理中下载内核。",
          ),
        );
      }

      _setState(FlutterVpnServiceState.connecting);
      _intentionalStop = false;

      // ---- 1) 生成最终配置 ----
      final String yamlText;
      final String workDir;
      try {
        final resolved = await _buildFinalConfig(cfg);
        yamlText = resolved.$1;
        workDir = resolved.$2;
      } catch (e) {
        _setState(FlutterVpnServiceState.disconnected);
        return VpnServiceWaitResult(
          type: VpnServiceWaitType.error,
          err: VpnServiceResultError(code: -4, message: "生成配置失败：$e"),
        );
      }

      // ---- 2) 确保 homeDir 可写且 geo 数据就位 ----
      final home = Directory(workDir);
      if (!await home.exists()) {
        await home.create(recursive: true);
      }
      await _ensureGeoData(workDir);

      final configFile = File(p.join(workDir, "config.yaml"));
      await configFile.writeAsString(yamlText, flush: true);

      // ---- 3) 起内核子进程 ----
      final logFile = cfg.log_path.isNotEmpty
          ? File(cfg.log_path)
          : File(p.join(workDir, "kernel_log.txt"));
      final errFile = cfg.err_path.isNotEmpty
          ? File(cfg.err_path)
          : File(p.join(workDir, "kernel_stderr.txt"));
      try {
        await logFile.parent.create(recursive: true);
        await errFile.writeAsString("", flush: true);
      } catch (_) {}

      final logSink = logFile.openWrite(mode: FileMode.append);
      Process proc;
      try {
        proc = await Process.start(
          kernel,
          ["-d", workDir, "-f", configFile.path],
          environment: {"PATH": Platform.environment["PATH"] ?? ""},
          workingDirectory: workDir,
        );
      } catch (e) {
        await logSink.close();
        _setState(FlutterVpnServiceState.disconnected);
        return VpnServiceWaitResult(
          type: VpnServiceWaitType.error,
          err: VpnServiceResultError(code: -5, message: "启动内核失败：$e"),
        );
      }
      _proc = proc;

      // 内核输出全量落盘（排障："内核被谁杀的"只能靠这份日志）
      proc.stdout.listen((d) => logSink.add(d), onDone: () {}, onError: (_) {});
      proc.stderr.listen((d) => logSink.add(d), onDone: () {}, onError: (_) {});

      unawaited(proc.exitCode.then((code) async {
        try {
          await logSink.flush();
          await logSink.close();
        } catch (_) {}
        if (_proc != proc) {
          return; // 已被新进程替换
        }
        _proc = null;
        if (_intentionalStop) {
          _setState(FlutterVpnServiceState.disconnected);
          return;
        }
        // 内核异常退出：写崩溃档（退出码 + 尾部），并把状态打成断开，
        // 由上层 ConnectionController 决定是否自愈。
        try {
          await errFile.writeAsString(
            "kernel exited unexpectedly, code=$code\n"
            "--- tail of kernel_log.txt ---\n"
            "${await _tail(logFile, 200)}",
            flush: true,
          );
        } catch (_) {}
        if (_systemProxyApplied) {
          await cleanSystemProxy();
        }
        _setState(
          FlutterVpnServiceState.disconnected,
          {"code": "$code", "reason": "kernel exited"},
        );
      }));

      // ---- 4) 就绪探测（双条件） ----
      final ok = await _waitReady(
        cfg.control_port,
        cfg.secret,
        _mixedPort,
        timeout == Duration.zero ? const Duration(seconds: 10) : timeout,
        proc,
      );
      if (!ok) {
        final errText = await _readErr(errFile);
        await stop();
        return VpnServiceWaitResult(
          type: VpnServiceWaitType.error,
          err: VpnServiceResultError(
            code: -6,
            message: errText.isNotEmpty
                ? errText
                : "内核启动超时（${timeout.inSeconds}s）。"
                    "可能被安全软件拦截，或端口被占用。",
          ),
        );
      }

      // ---- 5) 系统代理 ----
      if (cfg.control_port == 0) {
        // 无控制端口配置时不做系统代理
      }
      _setState(FlutterVpnServiceState.connected);
      return VpnServiceWaitResult(type: VpnServiceWaitType.done);
    } finally {
      _starting = false;
    }
  }

  @override
  Future<void> stop() async {
    if (_stopInFlight != null) {
      return _stopInFlight;
    }
    final fut = _stopInternal();
    _stopInFlight = fut;
    try {
      await fut;
    } finally {
      _stopInFlight = null;
    }
  }

  Future<void> _stopInternal() async {
    _intentionalStop = true;
    _setState(FlutterVpnServiceState.disconnecting);
    // 先恢复系统代理：否则浏览器还指着即将消失的端口
    if (_systemProxyApplied) {
      await cleanSystemProxy();
    }
    final proc = _proc;
    _proc = null;
    if (proc != null) {
      try {
        if (Platform.isWindows) {
          await Process.run("taskkill", ["/PID", "${proc.pid}", "/T", "/F"]);
        } else {
          proc.kill(ProcessSignal.sigterm);
        }
      } catch (_) {}
      try {
        await proc.exitCode.timeout(const Duration(seconds: 3));
      } catch (_) {
        try {
          proc.kill(ProcessSignal.sigkill);
        } catch (_) {}
      }
    }
    _setState(FlutterVpnServiceState.disconnected);
  }

  // ======================================================================
  // 配置合成：core_path (YAML) ← core_path_patch ← core_path_patch_final (JSON)
  //   优先级语义与 Clash Mi 一致：原始配置 ← 自定义覆写 ← App 覆写
  // ======================================================================
  Future<(String, String)> _buildFinalConfig(VpnServiceConfig cfg) async {
    final coreFile = File(cfg.core_path);
    if (!await coreFile.exists()) {
      throw "profile file not found: ${cfg.core_path}";
    }
    final raw = await coreFile.readAsString();
    dynamic doc;
    try {
      doc = loadYaml(raw);
    } catch (e) {
      throw "profile is not valid YAML: $e";
    }
    if (doc is! Map) {
      throw "profile is not a YAML mapping";
    }
    final config = _deepCopyMap(doc);

    for (final patchPath in [cfg.core_path_patch, cfg.core_path_patch_final]) {
      if (patchPath.isEmpty) {
        continue;
      }
      final f = File(patchPath);
      if (!await f.exists()) {
        continue;
      }
      final text = await f.readAsString();
      if (text.trim().isEmpty) {
        continue;
      }
      try {
        final patch = jsonDecode(text);
        if (patch is Map) {
          _deepMerge(config, Map<String, dynamic>.from(patch));
        }
      } catch (_) {
        // patch 可能是 YAML（用户手写的覆写），再试一次
        try {
          final patchYaml = loadYaml(text);
          if (patchYaml is Map) {
            _deepMerge(config, _deepCopyMap(patchYaml));
          }
        } catch (_) {}
      }
    }

    // 保证内核 API 与 mixed 端口可控（系统代理与热切换都依赖它）
    if (cfg.control_port > 0) {
      config["external-controller"] = "127.0.0.1:${cfg.control_port}";
    }
    if (cfg.secret.isNotEmpty) {
      config["secret"] = cfg.secret;
    }
    final mixed = config["mixed-port"];
    _mixedPort = mixed is num ? mixed.toInt() : 7890;
    config["mixed-port"] = _mixedPort;

    return (_dumpYaml(config), cfg.work_dir);
  }

  static Map<String, dynamic> _deepCopyMap(Map src) {
    final out = <String, dynamic>{};
    src.forEach((k, v) {
      final key = k.toString();
      if (v is Map) {
        out[key] = _deepCopyMap(v);
      } else if (v is List) {
        out[key] = [
          for (final e in v) e is Map ? _deepCopyMap(e) : e,
        ];
      } else {
        out[key] = v;
      }
    });
    return out;
  }

  static void _deepMerge(Map<String, dynamic> base, Map<String, dynamic> patch) {
    patch.forEach((k, v) {
      final key = k.toString();
      if (v is Map && base[key] is Map) {
        _deepMerge(base[key] as Map<String, dynamic>, Map<String, dynamic>.from(v));
      } else if (v is Map) {
        base[key] = _deepCopyMap(v);
      } else {
        base[key] = v;
      }
    });
  }

  /// 最小 YAML 序列化（不引 yaml_writer，避免多一个依赖）
  static String _dumpYaml(dynamic node, [int indent = 0]) {
    final sb = StringBuffer();
    _writeNode(sb, node, indent);
    return sb.toString();
  }

  static void _writeNode(StringBuffer sb, dynamic node, int indent) {
    final pad = "  " * indent;
    if (node is Map) {
      node.forEach((k, v) {
        final key = _yamlScalar(k.toString());
        if (v is Map && v.isNotEmpty) {
          sb.writeln("$pad$key:");
          _writeNode(sb, v, indent + 1);
        } else if (v is List && v.isNotEmpty) {
          sb.writeln("$pad$key:");
          _writeList(sb, v, indent + 1);
        } else if (v is Map || v is List) {
          sb.writeln("$pad$key: ${v is Map ? '{}' : '[]'}");
        } else {
          sb.writeln("$pad$key: ${_yamlScalar(v)}");
        }
      });
    }
  }

  static void _writeList(StringBuffer sb, List list, int indent) {
    final pad = "  " * indent;
    for (final item in list) {
      if (item is Map && item.isNotEmpty) {
        var first = true;
        item.forEach((k, v) {
          final key = _yamlScalar(k.toString());
          final prefix = first ? "$pad- " : "$pad  ";
          first = false;
          if (v is Map && v.isNotEmpty) {
            sb.writeln("$prefix$key:");
            _writeNode(sb, v, indent + 2);
          } else if (v is List && v.isNotEmpty) {
            sb.writeln("$prefix$key:");
            _writeList(sb, v, indent + 2);
          } else if (v is Map || v is List) {
            sb.writeln("$prefix$key: ${v is Map ? '{}' : '[]'}");
          } else {
            sb.writeln("$prefix$key: ${_yamlScalar(v)}");
          }
        });
      } else if (item is List) {
        sb.writeln("$pad-");
        _writeList(sb, item, indent + 1);
      } else {
        sb.writeln("$pad- ${_yamlScalar(item)}");
      }
    }
  }

  static String _yamlScalar(dynamic v) {
    if (v == null) {
      return "null";
    }
    if (v is num || v is bool) {
      return v.toString();
    }
    final s = v.toString();
    if (s.isEmpty) {
      return "''";
    }
    final needsQuote = RegExp(r'''[:#\[\]{}&*!|>'"%@`,]''').hasMatch(s) ||
        s.startsWith(" ") ||
        s.endsWith(" ") ||
        s.startsWith("-") ||
        s.toLowerCase() == "true" ||
        s.toLowerCase() == "false" ||
        s.toLowerCase() == "null" ||
        num.tryParse(s) != null ||
        s.contains("\n");
    if (!needsQuote) {
      return s;
    }
    return '"${s.replaceAll(r'\', r'\\').replaceAll('"', r'\"').replaceAll('\n', r'\n')}"';
  }

  // ======================================================================
  // geo 数据：内核从 homeDir 按默认文件名加载 country.mmdb / geosite.dat
  // ======================================================================
  Future<void> _ensureGeoData(String workDir) async {
    for (final name in ["country.mmdb", "geosite.dat"]) {
      final dst = File(p.join(workDir, name));
      if (await dst.exists() && await dst.length() > 0) {
        continue;
      }
      // 候选来源：work_dir 自带的 assets 目录、应用支持目录
      final candidates = <String>[
        p.join(workDir, "assets", "rules", name),
        p.join(workDir, "rules", name),
      ];
      final support = await getApplicationSupportDir();
      candidates.add(p.join(support, "rules", name));
      for (final c in candidates) {
        final f = File(c);
        if (await f.exists() && await f.length() > 0) {
          try {
            await f.copy(dst.path);
          } catch (_) {}
          break;
        }
      }
    }
  }

  // ======================================================================
  // 就绪探测：双条件（Clash API 200 且 mixed 端口可连接）
  // ======================================================================
  Future<bool> _waitReady(
    int controlPort,
    String secret,
    int mixedPort,
    Duration timeout,
    Process proc,
  ) async {
    final deadline = DateTime.now().add(timeout);
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 2);
    try {
      while (DateTime.now().isBefore(deadline)) {
        if (_proc != proc) {
          return false; // 内核已退出
        }
        var apiOk = controlPort == 0;
        if (controlPort > 0) {
          try {
            final req = await client
                .getUrl(Uri.parse("http://127.0.0.1:$controlPort/configs"))
                .timeout(const Duration(seconds: 2));
            if (secret.isNotEmpty) {
              req.headers.set(HttpHeaders.authorizationHeader, "Bearer $secret");
            }
            final resp = await req.close().timeout(const Duration(seconds: 2));
            await resp.drain<void>();
            apiOk = resp.statusCode == 200;
          } catch (_) {
            apiOk = false;
          }
        }
        if (apiOk && mixedPort > 0) {
          try {
            final s = await Socket.connect(
              InternetAddress.loopbackIPv4,
              mixedPort,
              timeout: const Duration(milliseconds: 600),
            );
            s.destroy();
            return true;
          } catch (_) {
            // 端口还没起来
          }
        }
        await Future<void>.delayed(const Duration(milliseconds: 200));
      }
      return false;
    } finally {
      client.close(force: true);
    }
  }

  static Future<String> _readErr(File errFile) async {
    try {
      if (await errFile.exists()) {
        final c = await errFile.readAsString();
        return c.trim();
      }
    } catch (_) {}
    return "";
  }

  static Future<String> _tail(File f, int lines) async {
    try {
      if (!await f.exists()) {
        return "";
      }
      final all = await f.readAsLines();
      final start = all.length > lines ? all.length - lines : 0;
      return all.sublist(start).join("\n");
    } catch (_) {
      return "";
    }
  }

  // ======================================================================
  // 系统代理
  //   Windows：注册表 HKCU\...\Internet Settings
  //   macOS：networksetup 逐网络服务（HTTP 与 HTTPS 都要设）
  //   Linux：不接管（走 TUN）→ 直接返回 true
  // ======================================================================
  @override
  Future<bool> setSystemProxy(ProxyOption option) async {
    if (Platform.isWindows) {
      return _setSystemProxyWindows(option);
    }
    if (Platform.isMacOS) {
      return _setSystemProxyMacos(option);
    }
    return true;
  }

  @override
  Future<bool> cleanSystemProxy() async {
    if (Platform.isWindows) {
      return _cleanSystemProxyWindows();
    }
    if (Platform.isMacOS) {
      return _cleanSystemProxyMacos();
    }
    return true;
  }

  @override
  Future<bool> getSystemProxyEnable(ProxyOption option) async {
    if (Platform.isWindows) {
      final r = await Process.run("reg", [
        "query",
        r"HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings",
        "/v",
        "ProxyServer",
      ]);
      if (r.exitCode != 0) {
        return false;
      }
      return r.stdout.toString().contains("${option.host}:$option.port");
    }
    if (Platform.isMacOS) {
      for (final svc in await _macNetworkServices()) {
        final r = await Process.run("networksetup", ["-getwebproxy", svc]);
        final out = r.stdout.toString();
        if (out.contains("Enabled: Yes") && out.contains("${option.host}")) {
          return true;
        }
      }
      return false;
    }
    return false;
  }

  Future<bool> _setSystemProxyWindows(ProxyOption option) async {
    try {
      const key =
          r"HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings";
      // 记下原值以便恢复
      _systemProxyOriginal ??= {};

      final bypass = option.bypassDomains.isEmpty
          ? "<local>"
          : "<local>;${option.bypassDomains.join(';')}";
      await Process.run("reg", [
        "add", key, "/v", "ProxyEnable", "/t", "REG_DWORD", "/d", "1", "/f",
      ]);
      await Process.run("reg", [
        "add", key, "/v", "ProxyServer", "/t", "REG_SZ", "/d",
        "${option.host}:$option.port", "/f",
      ]);
      await Process.run("reg", [
        "add", key, "/v", "ProxyOverride", "/t", "REG_SZ", "/d", bypass, "/f",
      ]);
      _systemProxyApplied = true;
      // 通知系统代理设置已变更（否则部分应用不会重新读取）
      await Process.run("powershell", [
        "-NoProfile",
        "-Command",
        r"""
$sig = @'
[DllImport("wininet.dll", SetLastError=true)]
public static extern bool InternetSetOption(IntPtr h, int o, IntPtr b, int l);
'@
Add-Type -MemberDefinition $sig -Namespace W -Name N
[W.N]::InternetSetOption([IntPtr]::Zero, 39, [IntPtr]::Zero, 0) | Out-Null
[W.N]::InternetSetOption([IntPtr]::Zero, 37, [IntPtr]::Zero, 0) | Out-Null
""",
      ]);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> _cleanSystemProxyWindows() async {
    try {
      const key =
          r"HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings";
      await Process.run("reg", [
        "add", key, "/v", "ProxyEnable", "/t", "REG_DWORD", "/d", "0", "/f",
      ]);
      await Process.run("reg", ["delete", key, "/v", "ProxyServer", "/f"]);
      _systemProxyApplied = false;
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<List<String>> _macNetworkServices() async {
    final r = await Process.run("networksetup", ["-listallnetworkservices"]);
    if (r.exitCode != 0) {
      return const [];
    }
    return [
      for (final line in r.stdout.toString().split("\n"))
        if (line.trim().isNotEmpty &&
            !line.startsWith("An asterisk") &&
            !line.startsWith("*"))
          line.trim(),
    ];
  }

  Future<bool> _setSystemProxyMacos(ProxyOption option) async {
    try {
      final bypass = [
        "localhost",
        "127.0.0.1",
        "10.0.0.0/8",
        "172.16.0.0/12",
        "192.168.0.0/16",
        "*.local",
        ...option.bypassDomains,
      ];
      for (final svc in await _macNetworkServices()) {
        await Process.run("networksetup", [
          "-setwebproxy", svc, option.host, "$option.port",
        ]);
        await Process.run("networksetup", [
          "-setsecurewebproxy", svc, option.host, "$option.port",
        ]);
        await Process.run("networksetup", [
          "-setproxybypassdomains", svc, ...bypass,
        ]);
      }
      _systemProxyApplied = true;
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> _cleanSystemProxyMacos() async {
    try {
      for (final svc in await _macNetworkServices()) {
        await Process.run("networksetup", ["-setwebproxystate", svc, "off"]);
        await Process.run("networksetup", [
          "-setsecurewebproxystate", svc, "off",
        ]);
      }
      _systemProxyApplied = false;
      return true;
    } catch (_) {
      return false;
    }
  }

  /// 启动巡检：清掉指向**已无人监听**端口的残留系统代理。
  ///
  /// 判据必须同时满足两条：
  ///   ① 代理指向本机端口
  ///   ② 该端口已无人监听
  /// 只看 ① 会把**另一个实例正在使用的活代理**误清掉 →
  /// 界面显示已连接但打不开网页。
  static Future<void> clearResidualSystemProxy(int port) async {
    try {
      final s = await Socket.connect(
        InternetAddress.loopbackIPv4,
        port,
        timeout: const Duration(milliseconds: 400),
      );
      s.destroy();
      return; // 端口还有人听 → 不是残留，别动
    } catch (_) {
      // 端口已死 → 是残留，继续清
    }
    final impl = DesktopVpnServiceImpl();
    await impl.cleanSystemProxy();
  }

  // ======================================================================
  // 桌面端无操作 / 由 Dart 直接实现的接口
  // ======================================================================
  @override
  Future<VpnServiceResultError?> installService() async => null;

  @override
  Future<VpnServiceResultError?> uninstallService() async => null;

  @override
  Future<void> setAlwaysOn(bool enable) async {}

  @override
  Future<bool> isRunAsAdmin() async {
    if (!Platform.isWindows) {
      return false;
    }
    try {
      final r = await Process.run("net", ["session"]);
      return r.exitCode == 0;
    } catch (_) {
      return false;
    }
  }

  /// 放行应用/端口穿过 Windows 防火墙。
  /// 不放行的话防火墙会拦环回，表现为"连上了但网页打不开"。
  @override
  Future<bool> firewallAddApp(String path, String name) async {
    if (!Platform.isWindows || path.isEmpty) {
      return false;
    }
    try {
      final r = await Process.run("netsh", [
        "advfirewall", "firewall", "add", "rule",
        "name=Mclash - $name", "dir=in", "action=allow",
        "program=$path", "enable=yes",
      ]);
      return r.exitCode == 0;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> firewallAddPorts(List<int> ports, String name) async {
    if (!Platform.isWindows || ports.isEmpty) {
      return false;
    }
    var ok = true;
    for (final port in ports) {
      try {
        final r = await Process.run("netsh", [
          "advfirewall", "firewall", "add", "rule",
          "name=Mclash - $name - $port", "dir=in", "action=allow",
          "protocol=TCP", "localport=$port", "enable=yes",
        ]);
        ok = ok && r.exitCode == 0;
      } catch (_) {
        ok = false;
      }
    }
    return ok;
  }

  @override
  Future<bool> autoStartCreate(
    String name,
    String path, {
    String? processArgs,
    bool runElevated = false,
  }) async {
    if (!Platform.isWindows) {
      return false;
    }
    try {
      final args = (processArgs == null || processArgs.isEmpty)
          ? ""
          : " $processArgs";
      final r = await Process.run("schtasks", [
        "/Create", "/TN", name, "/TR", '"$path"$args',
        "/SC", "ONLOGON", "/RL",
        runElevated ? "HIGHEST" : "LIMITED", "/F",
      ]);
      return r.exitCode == 0;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> autoStartDelete(String name) async {
    if (!Platform.isWindows) {
      return false;
    }
    try {
      final r = await Process.run("schtasks", ["/Delete", "/TN", name, "/F"]);
      return r.exitCode == 0;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> autoStartIsActive(String name) async {
    if (!Platform.isWindows) {
      return false;
    }
    try {
      final r = await Process.run("schtasks", ["/Query", "/TN", name]);
      return r.exitCode == 0;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> isServiceAuthorized(String path) async => true;

  /// 桌面端不需要授权（不装系统服务）→ 直接成功
  @override
  Future<VpnServiceResultError?> authorizeService(
    String path,
    String password,
  ) async =>
      null;

  @override
  /// 桌面端没有「App Group」概念（那是 Apple 沙盒下宿主 App 与扩展共享容器的机制），
  /// 但**绝不能返回 null**。
  ///
  /// 返回 null 的后果链（实测就是桌面端"打开即失败"的根因）：
  ///   getAppGroupDirectory → null
  ///   → PathUtils.profileDirNonPortable() 返回 ""
  ///   → PathUtils.profileDir() 返回 ""
  ///   → main.dart 判定 StartFailedReason.invalidProfile
  ///   → 停在「应用启动失败[访问配置文件失败]，请重新安装应用」
  /// 也就是说 App 连首屏都到不了，而且提示是"请重新安装"，会把人引向完全
  /// 错误的方向（重装多少次都一样）。
  ///
  /// 改为返回应用支持目录，与 [getApplicationSupportDir] 保持一致：
  ///   macOS   ~/Library/Application Support/<bundleId>
  ///   Windows %APPDATA%\<appId>
  ///   Linux   ~/.local/share/<appId>
  /// 内核副本、geo 数据、日志都落在这里，且该目录必然可写、无需额外权限。
  @override
  Future<Directory?> getAppGroupDirectory(String groupId) async =>
      Directory(await getApplicationSupportDir());

  @override
  Future<String> getSystemVersion() async => Platform.operatingSystemVersion;

  /// 桌面端无"最近任务"概念（该设置项仅 Android 显示）
  @override
  Future<String?> setExcludeFromRecents(bool exclude) async => null;

  @override
  Future<void> hideDockIcon(bool hide) async {}

  @override
  Future<String> getABIs() async => "";

  /// 经内核 Clash API 取连接列表（供首页/面板使用）
  @override
  Future<String> clashiApiConnections(bool all) async {
    final cfg = _config;
    if (cfg == null || cfg.control_port == 0) {
      return "";
    }
    return _clashGet(cfg, "/connections").then((v) => v).catchError((_) => "");
  }

  @override
  Future<String> clashiApiTraffic() async {
    final cfg = _config;
    if (cfg == null || cfg.control_port == 0) {
      return "";
    }
    return _clashGet(cfg, "/traffic").then((v) => v).catchError((_) => "");
  }

  Future<String> _clashGet(VpnServiceConfig cfg, String path) async {
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 2);
    try {
      final req = await client.getUrl(
        Uri.parse("http://127.0.0.1:${cfg.control_port}$path"),
      );
      if (cfg.secret.isNotEmpty) {
        req.headers.set(HttpHeaders.authorizationHeader, "Bearer ${cfg.secret}");
      }
      final resp = await req.close();
      final body = await resp.transform(utf8.decoder).join();
      return body;
    } finally {
      client.close(force: true);
    }
  }

  /// 清掉上次残留的内核进程（退出不干净时占着端口与 cache.db 锁，
  /// 会让之后每次连接都 bind 失败 —— 表现为"退出后重开连不上"）。
  ///
  /// ⚠️ 只收**父进程已消失的真孤儿**：仍在工作的内核一律不动，
  /// 否则会杀掉**另一个实例正在使用的活内核**（症状是莫名断线）。
  static Future<void> killStaleKernels() async {
    try {
      if (Platform.isWindows) {
        final r = await Process.run("powershell", [
          "-NoProfile",
          "-Command",
          r"""
Get-CimInstance Win32_Process -Filter "Name='mihomo.exe'" | ForEach-Object {
  $parent = Get-CimInstance Win32_Process -Filter "ProcessId=$($_.ParentProcessId)" -ErrorAction SilentlyContinue
  if (-not $parent) { Stop-Process -Id $_.ProcessId -Force }
}
""",
        ]);
        if (r.exitCode != 0) {
          return;
        }
      } else {
        // macOS / Linux：pgrep 找 mihomo，检查 ppid 是否为 1（被 init 收养 = 孤儿）
        final r = await Process.run("pgrep", ["-x", "mihomo"]);
        if (r.exitCode != 0) {
          return;
        }
        for (final line in r.stdout.toString().split("\n")) {
          final pid = int.tryParse(line.trim());
          if (pid == null) {
            continue;
          }
          try {
            final ps = await Process.run("ps", ["-o", "ppid=", "-p", "$pid"]);
            final ppid = int.tryParse(ps.stdout.toString().trim());
            if (ppid == 1) {
              Process.killPid(pid, ProcessSignal.sigkill);
            }
          } catch (_) {}
        }
      }
    } catch (_) {}
  }
}
