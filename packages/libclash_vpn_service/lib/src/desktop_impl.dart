
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

import 'geo_data.dart';
import 'models.dart';
import 'vpn_service_platform.dart';

class DesktopVpnServiceImpl extends VpnServicePlatform {
  DesktopVpnServiceImpl();

  Process? _proc;
  VpnServiceConfig? _config;
  FlutterVpnServiceState _state = FlutterVpnServiceState.disconnected;

  bool _starting = false;
  Future<void>? _stopInFlight;
  bool _intentionalStop = false;

  int _mixedPort = 0;

  bool _systemProxyApplied = false;
  Map<String, String>? _systemProxyOriginal;

  List<String> _missingGeo = const [];

  @override
  FlutterVpnServiceState get state => _state;

  void _setState(FlutterVpnServiceState s, [Map<String, String>? params]) {
    if (_state == s) {
      return;
    }
    _state = s;
    emitStateChanged(s, params ?? const {});
  }

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

      final home = Directory(workDir);
      if (!await home.exists()) {
        await home.create(recursive: true);
      }
      await _ensureGeoData(workDir);

      final configFile = File(p.join(workDir, "config.yaml"));
      await configFile.writeAsString(yamlText, flush: true);

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

      proc.stdout.listen((d) => logSink.add(d), onDone: () {}, onError: (_) {});
      proc.stderr.listen((d) => logSink.add(d), onDone: () {}, onError: (_) {});

      unawaited(proc.exitCode.then((code) async {
        try {
          await logSink.flush();
          await logSink.close();
        } catch (_) {}
        if (_proc != proc) {
          return;
        }
        _proc = null;
        if (_intentionalStop) {
          _setState(FlutterVpnServiceState.disconnected);
          return;
        }

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

      final ok = await _waitReady(
        cfg.control_port,
        cfg.secret,
        _mixedPort,
        timeout == Duration.zero ? const Duration(seconds: 10) : timeout,
        proc,
      );
      if (!ok) {
        final errText = await _readErr(errFile);
        final kernelTail = await _tail(logFile, 40);
        await stop();

        final String message;
        if (errText.isNotEmpty) {
          message = errText;
        } else if (_missingGeo.isNotEmpty) {
          message = "缺少内置分流数据（${_missingGeo.join("、")}），"
              "内核已尝试联网补拉并卡住。请检查网络后重试；"
              "若反复出现，说明安装包不完整，请重新下载完整安装包。";
        } else if (kernelTail.contains("address already in use")) {
          message = "本地代理端口被占用（多为另一个代理程序或残留内核仍在运行）。"
              "请退出其它代理软件后重试，或在「核心设置」中更换本地端口。";
        } else if (kernelTail.contains("Can't find MMDB") ||
            kernelTail.contains("start download")) {
          message = "内核正在联网下载分流数据（GitHub 不可达时会一直卡住）。"
              "请检查网络，或使用带内置分流数据的完整安装包。";
        } else {
          message = "内核启动超时（${timeout.inSeconds}s）。"
              "可能被安全软件拦截，或端口被占用。";
        }
        return VpnServiceWaitResult(
          type: VpnServiceWaitType.error,
          err: VpnServiceResultError(code: -6, message: message),
        );
      }

      await _applyDataPathFallback(logFile);
      _setState(FlutterVpnServiceState.connected);
      return VpnServiceWaitResult(type: VpnServiceWaitType.done);
    } finally {
      _starting = false;
    }
  }

  bool _systemProxyFallbackActive = false;

  @override
  bool get systemProxyFallbackActive => _systemProxyFallbackActive;

  static bool logIndicatesTunUnavailable(String kernelLogTail) =>
      kernelLogTail.contains("configure tun interface") ||
      kernelLogTail.contains("Start TUN listening error");

  Future<void> _applyDataPathFallback(File logFile) async {
    _systemProxyFallbackActive = false;
    if (Platform.isLinux) {

      return;
    }
    final tail = await _tail(logFile, 40);
    if (!logIndicatesTunUnavailable(tail)) {
      return;
    }
    final port = _mixedPort;
    if (port <= 0) {
      return;
    }
    try {
      final ok = await setSystemProxy(
        ProxyOption(InternetAddress.loopbackIPv4.address, port, const []),
      );
      if (ok) {

        final readBack = await getSystemProxyEnable(
          ProxyOption(InternetAddress.loopbackIPv4.address, port, const []),
        );
        _systemProxyFallbackActive = true;
        stderr.writeln(
          "[mclash] TUN 不可用（需要管理员权限），已把系统代理指向 "
          "127.0.0.1:$port（读回校验: ${readBack ? "一致" : "不一致，请检查系统代理设置"}）",
        );
      }
    } catch (e) {
      stderr.writeln("[mclash] TUN 兜底设系统代理失败: $e");
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

    if (_systemProxyApplied) {
      await cleanSystemProxy();
    }
    _systemProxyFallbackActive = false;
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

        try {
          final patchYaml = loadYaml(text);
          if (patchYaml is Map) {
            _deepMerge(config, _deepCopyMap(patchYaml));
          }
        } catch (_) {}
      }
    }

    if (cfg.control_port > 0) {
      config["external-controller"] = "127.0.0.1:${cfg.control_port}";
    }
    if (cfg.secret.isNotEmpty) {
      config["secret"] = cfg.secret;
    }
    final mixed = config["mixed-port"];
    _mixedPort = mixed is num ? mixed.toInt() : 7890;

    for (final k in ["port", "socks-port", "redir-port", "tproxy-port"]) {
      config.remove(k);
    }

    if (!await _portFree(_mixedPort)) {
      final picked = await _pickFreePort();
      stderr.writeln(
        "[mclash] 混合端口 $_mixedPort 被占用，已自动改用 $picked",
      );
      _mixedPort = picked;
      config["mixed-port"] = _mixedPort;
    }

    return (_dumpYaml(config), cfg.work_dir);
  }

  static Future<bool> _portFree(int port) async {
    if (port <= 0) {
      return false;
    }
    try {
      final s = await ServerSocket.bind(InternetAddress.loopbackIPv4, port);
      await s.close();
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<int> _pickFreePort() async {
    for (final p in [17890, 27890, 38890]) {
      if (await _portFree(p)) {
        return p;
      }
    }
    final s = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
    final port = s.port;
    await s.close();
    return port;
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

  /// geo 数据落盘：真正的逻辑在 [installGeoData]（可被单元测试直接覆盖）。
  ///
  /// 这里只负责拿应用支持目录 + 记录缺失清单 —— 缺 geo 时内核会去 GitHub 下载
  /// 并卡死，所以「缺了什么」必须能一路传到错误提示里。
  Future<void> _ensureGeoData(String workDir) async {
    String support;
    try {
      support = await getApplicationSupportDir();
    } catch (_) {
      support = "";
    }
    _missingGeo = await installGeoData(workDir, supportDir: support);
    if (_missingGeo.isNotEmpty) {
      stderr.writeln(
        "[mclash] geo data missing in -d dir: ${_missingGeo.join(", ")} "
        "(searched: ${geoSourceDirs(workDir, support).join(" | ")})",
      );
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
      // 只比 host 是不够的：`Enabled: Yes` + host 相同、**端口却是 0（空白）**
      // 是最常见的坏状态（本机上 21 个网络服务长期就是这个值），
      // 只比 host 会把它判成「已生效」，于是 App 以为设好了、用户却完全没流量。
      for (final svc in await _macNetworkServices()) {
        if (await _macServiceProxyMatches(svc, option)) {
          return true;
        }
      }
      return false;
    }
    return false;
  }

  /// 执行 `reg` 并检查退出码。
  ///
  /// 之前这里**完全忽略退出码**：`reg add` 写失败（权限不足 / 被策略拦 / 参数被拒）
  /// 时照样往下走，最后只在读回校验打印一句「可能被其它代理软件覆盖」——
  /// 用户和我们都拿不到真实原因。现在失败即带上真实 stderr。
  static Future<_RegResult> _reg(List<String> args) async {
    try {
      final r = await Process.run("reg", args);
      return _RegResult(
        exitCode: r.exitCode,
        stdout: r.stdout.toString(),
        stderr: r.stderr.toString(),
      );
    } catch (err) {
      return _RegResult(exitCode: -1, stdout: "", stderr: "$err");
    }
  }

  /// 读取系统代理注册表值的**原始**内容（诊断/断言用）。
  static Future<String> readSystemProxyRaw({
    String value = "ProxyServer",
  }) async {
    final r = await _reg([
      "query",
      r"HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings",
      "/v",
      value,
    ]);
    return r.exitCode == 0 ? r.stdout : r.stderr;
  }

  Future<bool> _setSystemProxyWindows(ProxyOption option) async {
    // 与 macOS 同一条硬规则：**绝不写无端口的系统代理**。
    // 端口 0 会让注册表里留下 "127.0.0.1:0"，Windows 流量会被发到一个不存在的
    // 代理上（浏览器全打不开），而且这个残留会一直留到下次清理。
    if (option.port <= 0) {
      stderr.writeln("[mclash] 拒绝设置无端口的系统代理（port=${option.port}）");
      return false;
    }
    try {
      const key =
          r"HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings";
      // 记下原值以便恢复
      _systemProxyOriginal ??= {};

      final bypass = option.bypassDomains.isEmpty
          ? "<local>"
          : "<local>;${option.bypassDomains.join(';')}";
      final enableRes = await _reg([
        "add", key, "/v", "ProxyEnable", "/t", "REG_DWORD", "/d", "1", "/f",
      ]);
      final serverRes = await _reg([
        "add", key, "/v", "ProxyServer", "/t", "REG_SZ", "/d",
        "${option.host}:$option.port", "/f",
      ]);
      await _reg([
        "add", key, "/v", "ProxyOverride", "/t", "REG_SZ", "/d", bypass, "/f",
      ]);
      if (enableRes.exitCode != 0 || serverRes.exitCode != 0) {
        stderr.writeln(
          "[mclash] 写系统代理注册表失败："
          "ProxyEnable=${enableRes.exitCode}(${enableRes.stderr.trim()}) "
          "ProxyServer=${serverRes.exitCode}(${serverRes.stderr.trim()})",
        );
        return false;
      }
      // 读回校验：调用成功 ≠ 生效（注册表被策略/其它代理软件改回去过）
      if (!await _windowsProxyMatches(option)) {
        stderr.writeln(
          "[mclash] 系统代理写入后校验不一致（期望 ${option.host}:${option.port}），"
          "可能被其它代理软件覆盖",
        );
        return false;
      }
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

  /// 某个网络服务的 HTTP 代理是否**精确**等于期望值（host + 端口）
  static Future<bool> _macServiceProxyMatches(
    String svc,
    ProxyOption option,
  ) async {
    try {
      final r = await Process.run("networksetup", ["-getwebproxy", svc]);
      final out = r.stdout.toString();
      if (!out.contains("Enabled: Yes")) {
        return false;
      }
      final pm = RegExp(r"Port:\s*(\d+)").firstMatch(out);
      final port = int.tryParse(pm?.group(1) ?? "");
      return out.contains("Server: ${option.host}") && port == option.port;
    } catch (_) {
      return false;
    }
  }

  /// Windows：读回注册表，确认 ProxyEnable=1 且 ProxyServer 精确等于期望值
  static Future<bool> _windowsProxyMatches(ProxyOption option) async {
    try {
      const key =
          r"HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings";
      String lastServer = "";
      for (var attempt = 0; attempt < 3; attempt++) {
        if (attempt > 0) {
          // 注册表写入偶发不是立刻可见（CI 的 Windows runner 上遇到过「刚写完读不到」）
          await Future<void>.delayed(const Duration(milliseconds: 120));
        }
        final en = await _reg(["query", key, "/v", "ProxyEnable"]);
        if (en.exitCode != 0 || !en.stdout.contains(RegExp(r"0x1\b"))) {
          continue;
        }
        final sv = await _reg(["query", key, "/v", "ProxyServer"]);
        lastServer = sv.exitCode == 0 ? sv.stdout : sv.stderr;
        if (sv.exitCode == 0 &&
            proxyServerValueMatches(lastServer, option.host, option.port)) {
          return true;
        }
      }
      stderr.writeln(
        "[mclash] 系统代理读回校验未通过（期望 ${option.host}:$option.port），"
        "注册表实际内容：${lastServer.replaceAll("\n", " | ").trim()}",
      );
      return false;
    } catch (_) {
      return false;
    }
  }

  /// 判断 `reg query` 输出里的代理地址是否就是 [host]:[port]。
  ///
  /// `ProxyServer` 可能是 `127.0.0.1:7890`，也可能是
  /// `http=127.0.0.1:7890;https=127.0.0.1:7890` 这类按协议写法；
  /// 只做整串 contains 会漏判（漏判 → 明明设好了却报失败）。
  /// 反向也要严格：**端口必须精确相等**，只比 host 会把「端口错了」判成已生效，
  /// 那正是「显示已生效却上不了网」的来源。
  @visibleForTesting
  static bool proxyServerValueMatches(String raw, String host, int port) {
    // 端口 0/负数永远不算「生效」：`127.0.0.1:0` 是历史坏值（流量会被发到
    // 不存在的代理），把它判成有效正是「显示已生效却上不了网」的来源。
    // 防御性放在这里，任何调用点都不可能绕过。
    if (port <= 0) {
      return false;
    }
    final wanted = "${host.toLowerCase()}:$port";
    for (final entry in raw.split(RegExp(r"[\s;\r\n]+"))) {
      if (entry.isEmpty) {
        continue;
      }
      final eq = entry.indexOf("=");
      final value = (eq >= 0 ? entry.substring(eq + 1) : entry).toLowerCase();
      if (value == wanted) {
        return true;
      }
    }
    return false;
  }

  Future<bool> _setSystemProxyMacos(ProxyOption option) async {
    // 端口为 0 时**绝不能**下笔：`networksetup -setwebproxy <svc> <host> 0` 会留下
    // 「代理已开启 + 端口 0（等效 80）」的状态 —— 浏览器把所有流量发给一个不存在的
    // 代理，表现为「连上了却上不了网」，而且这个残留会一直留到下次清理。
    if (option.port <= 0) {
      stderr.writeln("[mclash] 拒绝设置无端口的系统代理（port=${option.port}）");
      return false;
    }
    final bypass = [
      "localhost",
      "127.0.0.1",
      "10.0.0.0/8",
      "172.16.0.0/12",
      "192.168.0.0/16",
      "*.local",
      ...option.bypassDomains,
    ];
    try {
      var anyOk = false;
      final failed = <String>[];
      for (final svc in await _macNetworkServices()) {
        final ok = await _macSetOneService(svc, option, bypass);
        if (ok) {
          anyOk = true;
        } else {
          failed.add(svc);
        }
      }
      if (!anyOk && failed.isNotEmpty) {
        // 普通权限下改不动（或被 TCC 拦）时，用一次系统授权兜底：
        // 这正是用户手动去「系统设置 → 网络 → 代理」填端口的等价操作。
        stderr.writeln(
          "[mclash] 普通权限设置系统代理失败（${failed.take(3).join(", ")}…），"
          "改用系统授权重试",
        );
        anyOk = await _macSetByAdmin(failed, option);
      }
      _systemProxyApplied = anyOk;
      if (!anyOk) {
        stderr.writeln("[mclash] 系统代理设置失败：请检查是否允许修改网络设置");
      }
      return anyOk;
    } catch (e) {
      stderr.writeln("[mclash] 设置系统代理异常: $e");
      return false;
    }
  }

  /// 设置单个网络服务并**校验结果**（调用成功 ≠ 生效）
  Future<bool> _macSetOneService(
    String svc,
    ProxyOption option,
    List<String> bypass,
  ) async {
    Future<void> run(List<String> args) async {
      final r = await Process.run("networksetup", args);
      if (r.exitCode != 0) {
        // 以前这里完全不看退出码 —— 失败也被当成成功，读回又只比 host，
        // 于是「设置失败」被伪装成「已生效」。
        stderr.writeln(
          "[mclash] networksetup ${args.first} $svc 失败(${r.exitCode}): "
          "${r.stderr.toString().trim()}",
        );
      }
    }

    await run(["-setwebproxy", svc, option.host, "${option.port}"]);
    await run(["-setsecurewebproxy", svc, option.host, "${option.port}"]);
    await run(["-setproxybypassdomains", svc, ...bypass]);
    return _macServiceProxyMatches(svc, option);
  }

  /// 用系统授权（一次密码弹窗）设置代理 —— 普通权限失败时的兜底
  Future<bool> _macSetByAdmin(List<String> services, ProxyOption option) async {
    final cmds = <String>[];
    for (final svc in services) {
      final s = svc.replaceAll('"', r'\"');
      cmds.add('networksetup -setwebproxy "$s" ${option.host} ${option.port}');
      cmds.add(
        'networksetup -setsecurewebproxy "$s" ${option.host} ${option.port}',
      );
    }
    final script =
        'do shell script "${cmds.join("; ")}" with administrator privileges';
    try {
      final r = await Process.run("osascript", ["-e", script]);
      if (r.exitCode != 0) {
        stderr.writeln("[mclash] 授权设置系统代理失败: ${r.stderr.toString().trim()}");
        return false;
      }
      var ok = false;
      for (final svc in services) {
        if (await _macServiceProxyMatches(svc, option)) {
          ok = true;
          break;
        }
      }
      return ok;
    } catch (e) {
      stderr.writeln("[mclash] 授权设置系统代理异常: $e");
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

/// `reg` 命令的结果（退出码 + 原始输出），用于把「写入失败」和「写入没生效」区分开。
class _RegResult {
  _RegResult({
    required this.exitCode,
    required this.stdout,
    required this.stderr,
  });

  final int exitCode;
  final String stdout;
  final String stderr;
}
