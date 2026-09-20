
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:path/path.dart' as p;

import 'geo_data.dart';
import 'kernel_config.dart';
import 'models.dart';
import 'vpn_service_platform.dart';
import 'windows_job.dart';
import 'windows_wininet.dart';

bool usePerConnectionProxyWrite = true;

const String kSystemProxyOwnerValueName = "MclashProxyOwner";

const String _kInternetSettingsKey =
    r"HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings";

class SystemProxySnapshot {
  String? enableRaw;
  String? serverRaw;
  String? overrideRaw;

  String? enableValue;
  String? serverValue;
  String? overrideValue;

  int? connFlags;
  String connServer = "";
  String connBypass = "";

  List<int>? connBlob;

  bool blobOverwritten = false;

  bool captured = false;

  static String? valueText(String? raw, String name) {
    if (raw == null || !raw.contains(name)) {
      return null;
    }
    for (final line in raw.split("\n")) {
      final i = line.indexOf(name);
      if (i < 0) {
        continue;
      }
      final rest = line.substring(i + name.length);
      final m = RegExp(r"\s+REG_[A-Z_]+\s+([^\r\n]*)").firstMatch(rest);
      if (m != null) {
        return m.group(1)!.trim();
      }
    }
    return null;
  }

  static bool isEnabledRaw(String? value) {
    if (value == null) {
      return false;
    }
    final v = value.trim().toLowerCase();
    return v == "0x1" || v == "1";
  }
}

class SystemProxyDiagnostics {
  static bool? internetSetOption;
  static bool? wmSettingChange;
  static bool? perConnectionApi;
  static String lastError = "";

  static String lastCleanSkip = "";

  static String _lastProxyServer = "";

  static void noteProxyServer(String host, int port) {
    _lastProxyServer = "$host:$port";
  }

  static Future<String> report() async {
    final buf = StringBuffer();
    buf.writeln("平台: ${Platform.operatingSystem}");
    if (!Platform.isWindows) {
      buf.writeln("（本报告主要针对 Windows；macOS 用的是 networksetup，界面即时可见）");
      return buf.toString();
    }
    buf.writeln("注册表 ProxyEnable: ${await _regQueryValue('ProxyEnable')}");
    buf.writeln("注册表 ProxyServer: ${await _regQueryValue('ProxyServer')}");
    buf.writeln("注册表 ProxyOverride: ${await _regQueryValue('ProxyOverride')}");
    buf.writeln("界面读的每连接 ProxyServer: ${querySystemProxyForConnection()}");
    buf.writeln("界面读的每连接 代理已启用: ${connectionProxyEnabled()}");
    buf.writeln(
      "界面读的每连接 旁路: ${querySystemProxyBypassForConnection()}",
    );
    buf.writeln(
      "归属标记($kSystemProxyOwnerValueName): "
      "${await _regQueryValue(kSystemProxyOwnerValueName)}",
    );
    buf.writeln("最后一次 InternetSetOption 广播: $internetSetOption");
    buf.writeln("最后一次 WM_SETTINGCHANGE 广播: $wmSettingChange");
    buf.writeln("最后一次每连接官方 API 写入: $perConnectionApi");
    if (perConnectionApi == false) {
      buf.writeln(
        "每连接官方 API 失败: GetLastError=${PerConnectionDiagnostics.lastError} "
        "dwOptionError=${PerConnectionDiagnostics.optionError} "
        "兜底=${PerConnectionDiagnostics.fallbackUsed.isEmpty ? "未记录" : PerConnectionDiagnostics.fallbackUsed}",
      );
    }
    final blob = readDefaultConnectionSettings();
    final blobServer = await _regQueryValueBlobServer(blob);
    buf.writeln(
      "界面真正读的 DefaultConnectionSettings: "
      "flags=${parseDefaultConnectionSettingsFlags(blob) ?? "?"} "
      "含地址=${blobServer.isEmpty ? "(无)" : blobServer}",
    );
    final connNames = enumerateConnectionValueNames();
    if (connNames.isEmpty) {
      buf.writeln("Connections 键下无其它值（只有默认连接）");
    } else {
      buf.writeln("Connections 键下所有值（共 ${connNames.length} 个）:");
      for (final name in connNames) {
        final b = readDefaultConnectionSettings(connection: name);
        final flags = parseDefaultConnectionSettingsFlags(b);
        final hasAddr = b == null
            ? false
            : defaultConnectionSettingsContains(b, _lastProxyServer);
        buf.writeln(
          "  · $name: flags=${flags ?? "?"} 含地址=${hasAddr ? "是" : "否"}",
        );
      }
    }
    if (lastCleanSkip.isNotEmpty) {
      buf.writeln("最近一次清理跳过原因: $lastCleanSkip");
    }
    if (lastError.isNotEmpty) {
      buf.writeln("最后错误: $lastError");
    }
    return buf.toString();
  }

  static Future<String> _regQueryValueBlobServer(List<int>? blob) async {
    if (blob == null || blob.length < 16) {
      return "";
    }
    final len = blob[12] | (blob[13] << 8) | (blob[14] << 16) | (blob[15] << 24);
    if (len <= 0 || 16 + len > blob.length) {
      return "";
    }
    return String.fromCharCodes(blob.sublist(16, 16 + len));
  }

  static Future<String> _regQueryValue(String name) async {
    try {
      const key =
          r"HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings";
      final r = await Process.run("reg", ["query", key, "/v", name]);
      if (r.exitCode != 0) {
        return "(不存在)";
      }
      final text = r.stdout.toString().trim();
      final lines = text.split("\n");
      return lines.isEmpty ? text : lines.last.trim();
    } catch (e) {
      return "(查询失败: $e)";
    }
  }
}

typedef DesktopLogSink = void Function(String line);

DesktopLogSink? desktopLogSink;

bool _logging = false;

void desktopLog(String line) {
  if (_logging) {
    try {
      stderr.writeln(line);
    } catch (_) {}
    return;
  }
  _logging = true;
  try {
    final sink = desktopLogSink;
    if (sink != null) {
      try {
        sink(line);
        return;
      } catch (_) {
      }
    }
    stderr.writeln(line);
  } catch (_) {
  } finally {
    _logging = false;
  }
}

class DesktopVpnServiceImpl extends VpnServicePlatform {
  DesktopVpnServiceImpl();

  Process? _proc;
  VpnServiceConfig? _config;
  FlutterVpnServiceState _state = FlutterVpnServiceState.disconnected;

  bool _starting = false;
  Future<void>? _stopInFlight;
  bool _intentionalStop = false;

  bool _wantConnected = false;

  int _autoRecoveries = 0;
  static const int kMaxAutoRecover = 3;

  Timer? _kernelWatchdog;
  int _watchdogMisses = 0;
  static const Duration kWatchdogInterval = Duration(seconds: 20);
  static const int kWatchdogMaxMisses = 4;

  int _mixedPort = 0;

  bool _systemProxyApplied = false;

  bool _teardownInProgress = false;

  final SystemProxySnapshot _systemProxySnapshot = SystemProxySnapshot();

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

  static String cfg0AssetsDir = "";

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
      final swStart = Stopwatch()..start();

      final String yamlText;
      final String workDir;
      try {
        final resolved = await _buildFinalConfig(cfg);
        yamlText = resolved.yaml;
        workDir = resolved.workDir;
      } catch (e) {
        _setState(FlutterVpnServiceState.disconnected);
        return VpnServiceWaitResult(
          type: VpnServiceWaitType.error,
          err: VpnServiceResultError(code: -4, message: "生成配置失败：$e"),
        );
      }

      final home = Directory(workDir);
      final configFile = File(p.join(workDir, "config.yaml"));
      try {
        if (!await home.exists()) {
          await home.create(recursive: true);
        }
        await _ensureGeoData(workDir);
        await configFile.writeAsString(yamlText, flush: true);
      } catch (e) {
        _setState(FlutterVpnServiceState.disconnected);
        return VpnServiceWaitResult(
          type: VpnServiceWaitType.error,
          err: VpnServiceResultError(
            code: -6,
            message: "无法写入内核工作目录（$workDir）：$e\n"
                "请确认该目录可写，或把应用安装到用户可写的位置。",
          ),
        );
      }

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

      if (Platform.isWindows) {
        final joined = assignToKillOnCloseJob(proc.pid);
        desktopLog(
          "[mclash] 内核 PID=${proc.pid} 加入「退出即终止」作业对象: "
          "${joined ? "成功" : "失败（退回退出时显式 taskkill）"}",
        );
      }

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
        if (await _tryAutoRecover("内核进程意外退出 (code=$code)")) {
          return;
        }
        if (_systemProxyApplied) {
          await cleanSystemProxy();
        }
        _wantConnected = false;
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
        final apiUp = await _controlApiAlive(cfg);
        if (errText.isNotEmpty) {
          message = errText;
        } else if (apiUp && _mixedPort > 0) {
          message =
              "内核已就绪，但没有监听混合端口 $_mixedPort（配置里缺少入站监听）。\n"
              "这通常是订阅/覆写补丁里没有 mixed-port 导致的，请重新连接一次；"
              "若持续出现请反馈（已自动补写 mixed-port）。";
        } else if (_missingGeo.isNotEmpty) {
          message = "缺少内置分流数据（${_missingGeo.join("、")}），"
              "内核已尝试联网补拉并卡住。请检查网络后重试；"
              "若反复出现，说明安装包不完整，请重新下载完整安装包。";
        } else if (kernelTail.contains("External controller listen error") ||
            kernelTail.contains("controller listen error")) {
          message =
              "控制端口 ${cfg.control_port} 被占用（另一个代理软件的内核可能在用 9090）。"
              "已自动改用其它端口，请再点一次连接。";
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
      desktopLog(
        "[perf] 连接：内核就绪用时 ${swStart.elapsedMilliseconds} ms"
        "（含配置生成 / geo 数据 / 启动等待）",
      );
      _wantConnected = true;
      _autoRecoveries = 0;
      _setState(FlutterVpnServiceState.connected);
      _startKernelWatchdog();
      return VpnServiceWaitResult(type: VpnServiceWaitType.done);
    } finally {
      _starting = false;
    }
  }

  bool _systemProxyFallbackActive = false;

  int tunTeardownRequests = 0;

  @override
  bool get systemProxyFallbackActive => _systemProxyFallbackActive;

  static const List<String> kTunFatalMarkers = [
    "start tun listening error",
    "start tun interface timeout",
    "configure tun interface",
  ];

  static const List<String> kTunBenignMarkers = [
    "auto detect interface",
    "default interface changed",
    "default interface lost",
    "tun name failed",
    "unsupported tunname",
    "tun adapter listening at",
    "use tun name",
    "error writing to tun device",
    "failed to read packet from tun device",
  ];

  static const List<String> kTunPrivilegeMarkers = [
    "access is denied",
    "access denied",
    "permission denied",
    "operation not permitted",
    "requires elevation",
    "administrator",
    "run as root",
  ];

  static const List<String> kTunBusyMarkers = [
    "already exists",
    "already in use",
    "address already in use",
    "file exists",
    "device is in use",
    "in use",
  ];

  static const List<String> kTunDriverMarkers = [
    "wintun",
    "unable to load library",
    "load library",
    "driver",
    ".dll",
    "not found",
  ];

  @override
  TunStartFailureKind tunFailureKind = TunStartFailureKind.none;

  static bool _hasAny(String line, List<String> markers) =>
      markers.any(line.contains);

  static bool isFatalTunLine(String line) {
    final s = line.toLowerCase();
    if (_hasAny(s, kTunBenignMarkers)) {
      return false;
    }
    return _hasAny(s, kTunFatalMarkers);
  }

  static TunStartFailureKind classifyTunFailure(String logTail) {
    final lines = [for (final l in logTail.split("\n")) l.toLowerCase()];
    var lastFatal = -1;
    for (var i = 0; i < lines.length; i++) {
      if (isFatalTunLine(lines[i])) {
        lastFatal = i;
      }
    }
    if (lastFatal < 0) {
      return TunStartFailureKind.none;
    }
    final window = lines.sublist(
      lastFatal,
      (lastFatal + 4).clamp(0, lines.length),
    );
    if (window.any((l) => _hasAny(l, kTunPrivilegeMarkers))) {
      return TunStartFailureKind.privilege;
    }
    if (window.any((l) => _hasAny(l, kTunDriverMarkers))) {
      return TunStartFailureKind.driver;
    }
    if (window.any((l) => _hasAny(l, kTunBusyMarkers))) {
      return TunStartFailureKind.adapterBusy;
    }
    return TunStartFailureKind.unknown;
  }

  static bool logIndicatesTunUnavailable(String kernelLogTail) =>
      classifyTunFailure(kernelLogTail) != TunStartFailureKind.none;

  static String tunFailureHint(TunStartFailureKind kind) {
    switch (kind) {
      case TunStartFailureKind.none:
        return "";
      case TunStartFailureKind.privilege:
        return Platform.isWindows
            ? "TUN 需要管理员权限：右键 Mclash →「以管理员身份运行」；"
                  "或在「我的 → TUN 虚拟网卡」里选「关闭」（仅系统代理）。"
            : "TUN 需要管理员权限：请以 root 启动 Mclash；"
                  "或在「我的 → TUN 虚拟网卡」里选「关闭」（仅系统代理）。";
      case TunStartFailureKind.adapterBusy:
        return "虚拟网卡已被占用（同名网卡残留）：重启电脑后再试，"
            "或在「网络连接」里删除名为 Mclash 的虚拟网卡。";
      case TunStartFailureKind.driver:
        return "虚拟网卡驱动加载失败（多被安全软件拦截）："
            "把 Mclash 与 mihomo 加入杀毒/安全软件白名单后重试。";
      case TunStartFailureKind.unknown:
        return "TUN 启动失败（原因未能归类）：请在「我的 → 连接自检」里复制日志给客服。";
    }
  }

  Future<void> _applyDataPathFallback(File logFile) async {
    _systemProxyFallbackActive = false;
    var tail = await _tail(logFile, 200);
    var kind = classifyTunFailure(tail);
    var established = tunLooksEstablished(tail);
    final tunWanted = _config?.tun_enabled == true;

    if (tunWanted && kind == TunStartFailureKind.none && !established) {
      await Future<void>.delayed(const Duration(milliseconds: 700));
      tail = await _tail(logFile, 200);
      kind = classifyTunFailure(tail);
      established = tunLooksEstablished(tail);
    }

    tunFailureKind = kind;
    final needsFallback =
        kind != TunStartFailureKind.none || (tunWanted && !established);
    if (!needsFallback) {
      return;
    }
    if (kind == TunStartFailureKind.none) {
      tunFailureKind = TunStartFailureKind.unknown;
    }
    desktopLog(
      "[mclash] TUN 未能接管数据通路（${tunFailureKind.name}）"
      "${established ? "" : "（日志里没有 TUN 就绪标记）"} → 改为兜底系统代理",
    );
    final port = _mixedPort;
    if (port <= 0) {
      desktopLog("[mclash] 兜底失败：拿不到混合端口");
      return;
    }
    try {
      final option = ProxyOption(
        InternetAddress.loopbackIPv4.address,
        port,
        const [],
      );
      final ok = await setSystemProxy(option);
      final readBack = ok ? await getSystemProxyEnable(option) : false;
      if (ok) {
        _systemProxyFallbackActive = true;
        desktopLog(
          "[mclash] TUN 不可用，已把系统代理指向 127.0.0.1:$port"
          "（读回校验: ${readBack ? "一致" : "不一致，请检查系统代理设置"}）",
        );
      } else {
        desktopLog("[mclash] TUN 不可用，且系统代理写入失败（用户将没有数据通路）");
      }
    } catch (e) {
      desktopLog("[mclash] TUN 兜底设系统代理失败: $e");
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

  Future<bool> _tryAutoRecover(String why) async {
    if (!_wantConnected || _intentionalStop) {
      return false;
    }
    final cfg = _config;
    if (cfg == null) {
      return false;
    }
    if (_autoRecoveries >= kMaxAutoRecover) {
      desktopLog(
        "[mclash] $why —— 已连续自愈 $_autoRecoveries 次仍失败，停止重试并如实断开。",
      );
      return false;
    }
    _autoRecoveries++;
    final backoff = Duration(seconds: 2 * _autoRecoveries);
    desktopLog(
      "[mclash] $why —— 第 $_autoRecoveries 次自愈：${backoff.inSeconds}s 后重启内核…",
    );
    _setState(FlutterVpnServiceState.reasserting);
    await Future<void>.delayed(backoff);
    if (!_wantConnected || _intentionalStop) {
      return false;
    }
    try {
      final result = await start(const Duration(seconds: 30));
      if (result.type == VpnServiceWaitType.done) {
        desktopLog("[mclash] 自愈成功：内核已恢复（第 $_autoRecoveries 次）");
        return true;
      }
      desktopLog(
        "[mclash] 自愈失败：${result.err?.message ?? "未知原因"}",
      );
    } catch (e) {
      desktopLog("[mclash] 自愈异常: $e");
    }
    return false;
  }

  void _startKernelWatchdog() {
    _stopKernelWatchdog();
    _watchdogMisses = 0;
    _kernelWatchdog = Timer.periodic(kWatchdogInterval, (_) async {
      if (!_wantConnected || _intentionalStop || _proc == null) {
        return;
      }
      final cfg = _config;
      if (cfg == null || cfg.control_port <= 0) {
        return;
      }
      final ok = await _controlApiAlive(cfg);
      if (ok) {
        _watchdogMisses = 0;
        return;
      }
      _watchdogMisses++;
      desktopLog(
        "[mclash] 存活探测失败 $_watchdogMisses/$kWatchdogMaxMisses"
        "（控制端口 ${cfg.control_port}）",
      );
      if (_watchdogMisses < kWatchdogMaxMisses) {
        return;
      }
      _watchdogMisses = 0;
      final proc = _proc;
      _proc = null;
      if (proc != null) {
        try {
          await Process.run("taskkill", [
            "/PID",
            "${proc.pid}",
            "/T",
            "/F",
          ]);
        } catch (_) {
          try {
            proc.kill(ProcessSignal.sigkill);
          } catch (_) {}
        }
      }
      await _tryAutoRecover("内核控制接口连续 $kWatchdogMaxMisses 次无响应（假活）");
    });
  }

  void _stopKernelWatchdog() {
    _kernelWatchdog?.cancel();
    _kernelWatchdog = null;
    _watchdogMisses = 0;
  }

  Future<bool> _controlApiAlive(VpnServiceConfig cfg) async {
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 2);
    try {
      final req = await client
          .getUrl(
            Uri.parse("http://127.0.0.1:${cfg.control_port}/version"),
          )
          .timeout(const Duration(seconds: 3));
      if (cfg.secret.isNotEmpty) {
        req.headers.set(HttpHeaders.authorizationHeader, "Bearer ${cfg.secret}");
      }
      final resp = await req.close().timeout(const Duration(seconds: 3));
      await resp.drain<void>();
      return resp.statusCode == 200;
    } catch (_) {
      return false;
    } finally {
      client.close(force: true);
    }
  }

  Future<void> _stopInternal() async {
    _intentionalStop = true;
    _wantConnected = false;
    _autoRecoveries = 0;
    _teardownInProgress = true;
    _stopKernelWatchdog();
    _setState(FlutterVpnServiceState.disconnecting);
    try {
      final swProxy = Stopwatch()..start();
      final cleanFuture =
          _systemProxyApplied ? cleanSystemProxy() : Future.value();
      await Future.wait([cleanFuture, _disableTunBeforeStop()]);
      swProxy.stop();
      desktopLog("[perf] 断开：撤系统代理 + 拆 TUN 用时 ${swProxy.elapsedMilliseconds} ms");
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
          await proc.exitCode.timeout(const Duration(milliseconds: 1500));
        } catch (_) {
          try {
            proc.kill(ProcessSignal.sigkill);
          } catch (_) {}
        }
      }
      desktopLog("[perf] 断开总用时 ${swProxy.elapsedMilliseconds} ms");
    } finally {
      _teardownInProgress = false;
      _setState(FlutterVpnServiceState.disconnected);
    }
  }

  Future<void> _disableTunBeforeStop() async {
    final cfg = _config;
    if (cfg == null || cfg.control_port <= 0) {
      return;
    }
    if (cfg.tun_enabled != true) {
      return;
    }
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 2);
    try {
      final req = await client
          .patchUrl(
            Uri.parse(
              "http://127.0.0.1:${cfg.control_port}/configs",
            ),
          )
          .timeout(const Duration(milliseconds: 1200));
      if (cfg.secret.isNotEmpty) {
        req.headers.set(HttpHeaders.authorizationHeader, "Bearer ${cfg.secret}");
      }
      req.headers.contentType = ContentType.json;
      req.write('{"tun":{"enable":false}}');
      final resp = await req.close().timeout(
        const Duration(milliseconds: 1200),
      );
      await resp.drain<void>();
      if (resp.statusCode == 200 || resp.statusCode == 204) {
        tunTeardownRequests++;
      }
      desktopLog(
        "[mclash] 退出前已请求内核关闭 TUN（HTTP ${resp.statusCode}）",
      );
    } catch (e) {
      desktopLog("[mclash] 退出前关闭 TUN 失败（继续退出）: $e");
    } finally {
      client.close(force: true);
    }
  }

  Future<KernelConfigResult> _buildFinalConfig(VpnServiceConfig cfg) async {
    final sw = Stopwatch()..start();
    final result = await buildKernelConfigOffThread(cfg);
    sw.stop();
    desktopLog("[perf] 生成内核配置（后台 isolate）: ${sw.elapsedMilliseconds} ms");
    for (final note in result.notes) {
      desktopLog("[mclash] 内核配置: $note");
    }
    _mixedPort = result.mixedPort;
    return result;
  }

  Future<void> _ensureGeoData(String workDir) async {
    String support;
    try {
      support = await getApplicationSupportDir();
    } catch (_) {
      support = "";
    }
    final extra = <String>[
      if (cfg0AssetsDir.isNotEmpty) cfg0AssetsDir,
    ];
    _missingGeo = await installGeoData(
      workDir,
      supportDir: support,
      extraSourceDirs: extra,
    );
    if (_missingGeo.isNotEmpty) {
      desktopLog(
        "[mclash] geo data missing in -d dir: ${_missingGeo.join(", ")} "
        "(searched: ${geoSourceDirs(workDir, support, extraSourceDirs: extra).join(" | ")})",
      );
    }
  }

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
          return false; 
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

  @visibleForTesting
  static bool tunLooksEstablished(String logText) {
    if (logText.isEmpty) {
      return false;
    }
    final lower = logText.toLowerCase();
    for (final marker in const [
      "tun started",
      "tun adapter listening at",
      "use tun name",
    ]) {
      if (lower.contains(marker)) {
        return true;
      }
    }
    return false;
  }

  static Future<String> _tail(File f, int lines) async {
    RandomAccessFile? raf;
    try {
      if (!await f.exists()) {
        return "";
      }
      const maxBytes = 256 * 1024;
      final length = await f.length();
      if (length <= 0) {
        return "";
      }
      final readFrom = length > maxBytes ? length - maxBytes : 0;
      raf = await f.open();
      await raf.setPosition(readFrom);
      final bytes = await raf.read(length - readFrom);
      var text = utf8.decode(bytes, allowMalformed: true);
      if (readFrom > 0) {
        final firstBreak = text.indexOf("\n");
        if (firstBreak >= 0) {
          text = text.substring(firstBreak + 1);
        }
      }
      final all = text.split("\n");
      final start = all.length > lines ? all.length - lines : 0;
      return all.sublist(start).join("\n");
    } catch (_) {
      return "";
    } finally {
      try {
        await raf?.close();
      } catch (_) {}
    }
  }

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
      final raw = await readSystemProxyRaw(value: "ProxyServer");
      return proxyServerValueMatches(
        SystemProxySnapshot.valueText(raw, "ProxyServer") ?? "",
        option.host,
        option.port,
      );
    }
    if (Platform.isMacOS) {
      for (final svc in await _macNetworkServices()) {
        if (await _macServiceProxyMatches(svc, option)) {
          return true;
        }
      }
      return false;
    }
    return false;
  }

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

  static Future<String> readSystemProxyRaw({
    String value = "ProxyServer",
  }) async {
    if (windowsRegistryAvailable) {
      final text = queryRegistryValueAsRegText(value);
      return text ??
          "\r\nERROR: The system was unable to find the specified "
              "registry key or value.\r\n\r\n";
    }
    final r = await _reg([
      "query",
      _kInternetSettingsKey,
      "/v",
      value,
    ]);
    return r.exitCode == 0 ? r.stdout : r.stderr;
  }

  Future<bool> _setSystemProxyWindows(ProxyOption option) async {
    if (option.port <= 0) {
      desktopLog("[mclash] 拒绝设置无端口的系统代理（port=${option.port}）");
      return false;
    }
    if (_teardownInProgress) {
      desktopLog("[mclash] 忽略一次系统代理写入：正在断开");
      return false;
    }
    try {
      final server = "${option.host}:${option.port}";
      SystemProxyDiagnostics.noteProxyServer(option.host, option.port);

      await _captureSystemProxyOriginal();

      final bypassItems = <String>[];
      for (final d in option.bypassDomains) {
        final item = d.trim();
        if (item.isNotEmpty &&
            item != "<local>" &&
            !item.contains("::") &&
            !bypassItems.contains(item)) {
          bypassItems.add(item);
        }
      }
      final bypass = bypassItems.join(';');

      var perConnOk = false;
      if (usePerConnectionProxyWrite) {
        perConnOk = applySystemProxyForConnection(
          server: server,
          bypass: bypass,
        );
        SystemProxyDiagnostics.perConnectionApi = perConnOk;
        if (perConnOk) {
          PerConnectionDiagnostics.fallbackUsed = "official";
          desktopLog("[mclash] 官方 API 写「当前连接」成功（FlClash 同款流程）");
        }
      } else {
        SystemProxyDiagnostics.perConnectionApi = null;
      }

      _writeProxyRegistryString(kSystemProxyOwnerValueName, server);

      if (!perConnOk) {
        final wroteEnable = _writeProxyRegistryDword("ProxyEnable", 1);
        final wroteServer = _writeProxyRegistryString("ProxyServer", server);
        _writeProxyRegistryString("ProxyOverride", bypass);
        if (!wroteEnable || !wroteServer) {
          desktopLog("[mclash] 官方 API 失败且手动写注册表也失败");
          return false;
        }
        final targets = <String>[""];
        try {
          targets.addAll(enumerateRasConnections());
        } catch (_) {}
        var blobOk = true;
        for (final conn in targets) {
          final prev = readDefaultConnectionSettings(connection: conn);
          final prevCounter = (prev != null && prev.length >= 8)
              ? (prev[4] | (prev[5] << 8) | (prev[6] << 16) | (prev[7] << 24))
              : 0;
          final blob = buildDefaultConnectionSettingsBlob(
            flags: kProxyTypeDirect | kProxyTypeProxy,
            server: server,
            bypass: bypass,
            counter: prevCounter + 1,
          );
          final ok = writeDefaultConnectionSettings(blob, connection: conn);
          blobOk = blobOk && ok;
          if (conn.isEmpty) {
            _systemProxySnapshot.blobOverwritten = ok;
          }
        }
        PerConnectionDiagnostics.fallbackUsed = blobOk ? "blob" : "none";
        desktopLog(
          "[mclash] 官方 API 失败（GetLastError="
          "${PerConnectionDiagnostics.lastError} dwOptionError="
          "${PerConnectionDiagnostics.optionError}）→ 手动写注册表 + "
          "DefaultConnectionSettings（及 ${targets.length - 1} 个 RAS 连接）兜底: "
          "${blobOk ? "成功" : "失败"}",
        );
      }

      final notified = notifySystemProxyChanged();
      SystemProxyDiagnostics.internetSetOption = notified;
      desktopLog(
        "[mclash] 已广播 Internet 设置变更（SETTINGS_CHANGED+REFRESH）: $notified",
      );
      final wm = broadcastInternetSettingsChangedAsync();
      if (!wm) {
        unawaited(broadcastInternetSettingsViaPowerShell());
        desktopLog("[mclash] WM_SETTINGCHANGE：FFI 失败，已改用 PowerShell 广播");
      }
      SystemProxyDiagnostics.wmSettingChange = wm;
      desktopLog("[mclash] 已发起 WM_SETTINGCHANGE(InternetSettings) 广播: $wm");

      final connServer = querySystemProxyForConnection();
      final connOn = connectionProxyEnabled();
      final registryOk = await _windowsProxyMatches(option);
      final blobNow = readDefaultConnectionSettings();
      final blobHasServer = defaultConnectionSettingsContains(blobNow, server);
      desktopLog(
        "[mclash] 读回：注册表=${registryOk ? "一致" : "不一致"} / "
        "DefaultConnectionSettings 含地址=${blobHasServer ? "是" : "否"
            }（官方 API 读回的 ProxyServer=${connServer.isEmpty ? "(空)" : connServer}、"
        "代理已启用=$connOn）",
      );
      if (!registryOk) {
        desktopLog(
          "[mclash] 系统代理写入后校验不一致（期望 $server），"
          "可能被其它代理软件覆盖",
        );
        return false;
      }
      if (usePerConnectionProxyWrite && !connOn) {
        desktopLog(
          "[mclash] ⚠️ 「当前连接」的代理未启用（界面会显示空白）："
          "官方 API 返回 ${SystemProxyDiagnostics.perConnectionApi}，读到 '$connServer'",
        );
      }
      _systemProxyApplied = true;
      return true;
    } catch (err) {
      SystemProxyDiagnostics.lastError = "$err";
      return false;
    }
  }

  Future<void> _captureSystemProxyOriginal() async {
    if (_systemProxySnapshot.captured) {
      return;
    }
    final snap = _systemProxySnapshot;
    snap.enableRaw = await readSystemProxyRaw(value: "ProxyEnable");
    snap.serverRaw = await readSystemProxyRaw(value: "ProxyServer");
    snap.overrideRaw = await readSystemProxyRaw(value: "ProxyOverride");
    snap.enableValue = SystemProxySnapshot.valueText(snap.enableRaw, "ProxyEnable");
    snap.serverValue = SystemProxySnapshot.valueText(snap.serverRaw, "ProxyServer");
    snap.overrideValue =
        SystemProxySnapshot.valueText(snap.overrideRaw, "ProxyOverride");
    snap.connFlags = queryConnectionFlagsForConnection();
    snap.connServer = querySystemProxyForConnection();
    snap.connBypass = querySystemProxyBypassForConnection();
    snap.connBlob = readDefaultConnectionSettings();
    snap.captured = true;
    desktopLog(
      "[mclash] 已记录用户原有代理配置：注册表 "
      "ProxyEnable=${snap.enableValue ?? "(无)"} "
      "ProxyServer=${snap.serverValue ?? "(无)"} "
      "ProxyOverride=${snap.overrideValue ?? "(无)"} "
      "/ 界面那份 flags=${snap.connFlags} server='${snap.connServer}'",
    );
  }

  Future<({bool owned, String reason})> _systemProxyOwnership() async {
    if (_systemProxyApplied) {
      return (owned: true, reason: "本进程刚写入");
    }
    final markerRaw = await readSystemProxyRaw(
      value: kSystemProxyOwnerValueName,
    );
    final marker = SystemProxySnapshot.valueText(
      markerRaw,
      kSystemProxyOwnerValueName,
    );
    final enable = SystemProxySnapshot.valueText(
      await readSystemProxyRaw(value: "ProxyEnable"),
      "ProxyEnable",
    );
    if (enable == null || !enable.contains("0x1")) {
      return (
        owned: false,
        reason: "注册表 ProxyEnable 不是 1（系统里没有启用的代理）",
      );
    }
    final serverRaw = await readSystemProxyRaw(value: "ProxyServer");
    final server = SystemProxySnapshot.valueText(serverRaw, "ProxyServer");
    if (marker != null && marker.isNotEmpty) {
      if (server == marker) {
        return (owned: true, reason: "归属标记=$marker 一致");
      }
      return (
        owned: false,
        reason: "归属标记=$marker，但当前 ProxyServer=${server ?? "(空)"} —— 已被别的程序改写",
      );
    }
    final port = loopbackProxyPort(server);
    if (port == null) {
      return (
        owned: false,
        reason: "没有归属标记，且 ProxyServer=${server ?? "(空)"} 不是本机回环地址",
      );
    }
    if (await isLocalPortAlive(port)) {
      return (
        owned: false,
        reason: "没有归属标记，但 127.0.0.1:$port 仍有程序在监听"
            "（很可能是其它代理软件正在使用）→ 不碰",
      );
    }
    return (owned: true, reason: "无标记，但 127.0.0.1:$port 已无人监听（异常退出的残留）");
  }

  Future<bool> _cleanSystemProxyWindows() async {
    try {
      final own = await _systemProxyOwnership();
      if (!own.owned) {
        SystemProxyDiagnostics.lastCleanSkip = own.reason;
        desktopLog("[mclash] 清理系统代理已跳过（不是我们设置的）：${own.reason}");
        _systemProxyApplied = false;
        return true;
      }
      SystemProxyDiagnostics.lastCleanSkip = "";
      desktopLog("[mclash] 清理系统代理：${own.reason}");

      final snap = _systemProxySnapshot;
      if (snap.captured) {
        final rawEnable =
            snap.enableValue ?? SystemProxySnapshot.valueText(snap.enableRaw, "ProxyEnable");
        _writeProxyRegistryDword(
          "ProxyEnable",
          SystemProxySnapshot.isEnabledRaw(rawEnable) ? 1 : 0,
        );
        _restoreWindowsValueOrDelete(
          "ProxyServer",
          snap.serverValue ?? SystemProxySnapshot.valueText(snap.serverRaw, "ProxyServer"),
        );
        _restoreWindowsValueOrDelete(
          "ProxyOverride",
          snap.overrideValue ??
              SystemProxySnapshot.valueText(snap.overrideRaw, "ProxyOverride"),
        );
      } else {
        desktopLog(
          "[mclash] 清理：没拿到原始快照，不动注册表里的 ProxyEnable/ProxyServer",
        );
      }
      _deleteProxyRegistryValue(kSystemProxyOwnerValueName);

      if (snap.captured) {
        final hadOriginalBlob = snap.connBlob != null;
        if (snap.blobOverwritten || hadOriginalBlob) {
          final target = snap.connBlob ??
              buildDefaultConnectionSettingsBlob(
                flags: kProxyTypeDirect,
                server: "",
                bypass: "",
              );
          final ok = writeDefaultConnectionSettings(target);
          desktopLog(
            "[mclash] 清理：还原 DefaultConnectionSettings blob"
            "（写入前${hadOriginalBlob ? "有原值" : "不存在"}）: $ok",
          );
        } else {
          final flags = snap.connFlags ?? kProxyTypeDirect;
          final hadProxy =
              (flags & kProxyTypeProxy) != 0 && snap.connServer.trim().isNotEmpty;
          final restored = hadProxy
              ? restoreSystemProxyForConnection(
                  flags: flags,
                  server: snap.connServer,
                  bypass: snap.connBypass,
                )
              : clearSystemProxyForConnection();
          desktopLog(
            "[mclash] 清理：「当前连接」那份已还原"
            "（原本${hadProxy ? "配着 ${snap.connServer}" : "是直连"}）: $restored",
          );
        }
      } else {
        desktopLog(
          "[mclash] 清理：没拿到原始快照，不动「当前连接」那一份"
          "（它可能正被别的代理软件使用）",
        );
      }

      notifySystemProxyChanged();
      if (!broadcastInternetSettingsChangedAsync()) {
        unawaited(broadcastInternetSettingsViaPowerShell());
      }
      _systemProxyApplied = false;
      desktopLog("[mclash] 已清理系统代理（注册表 + 界面读的那份 + 广播）");
      return true;
    } catch (err) {
      SystemProxyDiagnostics.lastError = "$err";
      return false;
    }
  }

  static bool _writeProxyRegistryString(String name, String value) {
    try {
      if (writeRegistryString(name, value)) {
        return true;
      }
    } catch (err) {
      desktopLog("[mclash] FFI 写注册表 $name 异常，改用 reg.exe：$err");
    }
    return _regFallbackSync([
      "add",
      _kInternetSettingsKey,
      "/v",
      name,
      "/t",
      "REG_SZ",
      "/d",
      value,
      "/f",
    ]);
  }

  static bool _writeProxyRegistryDword(String name, int value) {
    try {
      if (writeRegistryDword(name, value)) {
        return true;
      }
    } catch (err) {
      desktopLog("[mclash] FFI 写注册表 $name 异常，改用 reg.exe：$err");
    }
    return _regFallbackSync([
      "add",
      _kInternetSettingsKey,
      "/v",
      name,
      "/t",
      "REG_DWORD",
      "/d",
      "$value",
      "/f",
    ]);
  }

  static bool _deleteProxyRegistryValue(String name) {
    try {
      if (deleteRegistryValue(name)) {
        return true;
      }
    } catch (err) {
      desktopLog("[mclash] FFI 删注册表值 $name 异常，改用 reg.exe：$err");
    }
    return _regFallbackSync([
      "delete",
      _kInternetSettingsKey,
      "/v",
      name,
      "/f",
    ]);
  }

  static bool _regFallbackSync(List<String> args) {
    try {
      return Process.runSync("reg", args).exitCode == 0;
    } catch (_) {
      return false;
    }
  }

  void _restoreWindowsValueOrDelete(String name, String? value) {
    if (value != null) {
      _writeProxyRegistryString(name, value);
      return;
    }
    _deleteProxyRegistryValue(name);
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

  static Future<bool> _windowsProxyMatches(ProxyOption option) async {
    try {
      String lastServer = "";
      for (var attempt = 0; attempt < 3; attempt++) {
        if (attempt > 0) {
          await Future<void>.delayed(const Duration(milliseconds: 120));
        }
        final en = queryRegistryValueAsRegText("ProxyEnable");
        if (en == null || !en.contains(RegExp(r"0x1\b"))) {
          continue;
        }
        final sv = queryRegistryValueAsRegText("ProxyServer");
        lastServer = sv ?? "(不存在)";
        if (sv != null &&
            proxyServerValueMatches(sv, option.host, option.port)) {
          return true;
        }
      }
      desktopLog(
        "[mclash] 系统代理读回校验未通过（期望 ${option.host}:${option.port}），"
        "注册表实际内容：${lastServer.replaceAll("\n", " | ").trim()}",
      );
      return false;
    } catch (_) {
      return false;
    }
  }

  @visibleForTesting
  static bool proxyServerValueMatches(String raw, String host, int port) {
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
    if (option.port <= 0) {
      desktopLog("[mclash] 拒绝设置无端口的系统代理（port=${option.port}）");
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
        desktopLog(
          "[mclash] 普通权限设置系统代理失败（${failed.take(3).join(", ")}…），"
          "改用系统授权重试",
        );
        anyOk = await _macSetByAdmin(failed, option);
      }
      _systemProxyApplied = anyOk;
      if (!anyOk) {
        desktopLog("[mclash] 系统代理设置失败：请检查是否允许修改网络设置");
      }
      return anyOk;
    } catch (e) {
      desktopLog("[mclash] 设置系统代理异常: $e");
      return false;
    }
  }

  Future<bool> _macSetOneService(
    String svc,
    ProxyOption option,
    List<String> bypass,
  ) async {
    Future<void> run(List<String> args) async {
      final r = await Process.run("networksetup", args);
      if (r.exitCode != 0) {
        desktopLog(
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
        desktopLog("[mclash] 授权设置系统代理失败: ${r.stderr.toString().trim()}");
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
      desktopLog("[mclash] 授权设置系统代理异常: $e");
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

  static final Set<String> _firewallRulesAdded = {};

  @override
  Future<bool> firewallAddApp(String path, String name) async {
    if (!Platform.isWindows || path.isEmpty) {
      return false;
    }
    final cacheKey = "app|$name|$path";
    if (_firewallRulesAdded.contains(cacheKey)) {
      return true;
    }
    try {
      final r = await Process.run("netsh", [
        "advfirewall", "firewall", "add", "rule",
        "name=Mclash - $name", "dir=in", "action=allow",
        "program=$path", "enable=yes",
      ]);
      final ok = r.exitCode == 0;
      if (ok) {
        _firewallRulesAdded.add(cacheKey);
      }
      return ok;
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
      final cacheKey = "port|$name|$port";
      if (_firewallRulesAdded.contains(cacheKey)) {
        continue;
      }
      try {
        final r = await Process.run("netsh", [
          "advfirewall", "firewall", "add", "rule",
          "name=Mclash - $name - $port", "dir=in", "action=allow",
          "protocol=TCP", "localport=$port", "enable=yes",
        ]);
        ok = ok && r.exitCode == 0;
        if (r.exitCode == 0) {
          _firewallRulesAdded.add(cacheKey);
        }
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

  @override
  Future<VpnServiceResultError?> authorizeService(
    String path,
    String password,
  ) async =>
      null;

  @override
  @override
  Future<Directory?> getAppGroupDirectory(String groupId) async =>
      Directory(await getApplicationSupportDir());

  @override
  Future<String> getSystemVersion() async => Platform.operatingSystemVersion;

  @override
  Future<String?> setExcludeFromRecents(bool exclude) async => null;

  @override
  Future<void> hideDockIcon(bool hide) async {}

  @override
  Future<String> getABIs() async => "";

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
        req.headers.set(
          HttpHeaders.authorizationHeader,
          "Bearer ${cfg.secret}",
        );
      }
      final resp = await req.close();
      final body = await resp.transform(utf8.decoder).join();
      return body;
    } finally {
      client.close(force: true);
    }
  }

  static bool _staleKernelScanDone = false;

  static Future<List<int>> killStaleKernels({
    bool includeOwn = false,
    bool force = false,
  }) async {
    if (Platform.isWindows && _staleKernelScanDone && !force) {
      return const [];
    }
    final killed = <int>[];
    try {
      final kernel = await resolveKernelPath();
      if (Platform.isWindows) {
        final platform = VpnServicePlatform.instance;
        final keepPid = platform is DesktopVpnServiceImpl
            ? (platform._proc?.pid ?? 0)
            : 0;
        final script = r"""
$mine = '__KERNEL__'
$keep = __KEEP_PID__
$onlyOrphan = __ONLY_ORPHAN__
$targets = @(Get-Process -Name mihomo -ErrorAction SilentlyContinue)
foreach ($p in $targets) {
  if ($keep -ne 0 -and $p.Id -eq $keep) { continue }
  $exe = $p.Path
  if ($mine -ne '' -and $exe -and ($exe.ToLower() -ne $mine.ToLower())) { continue }
  if ($onlyOrphan) {
    $ppid = (Get-CimInstance Win32_Process -Filter "ProcessId=$($p.Id)" -ErrorAction SilentlyContinue).ParentProcessId
    if ($ppid -and (Get-Process -Id $ppid -ErrorAction SilentlyContinue)) { continue }
  }
  try { Stop-Process -Id $p.Id -Force; Write-Output $p.Id } catch {}
}
"""
            .replaceFirst('__KERNEL__', (kernel ?? '').replaceAll("'", "''"))
            .replaceFirst('__KEEP_PID__', '$keepPid')
            .replaceFirst('__ONLY_ORPHAN__', includeOwn ? r'$false' : r'$true');
        final r = await Process.run("powershell", [
          "-NoProfile",
          "-ExecutionPolicy",
          "Bypass",
          "-Command",
          script,
        ]);
        _staleKernelScanDone = true;
        for (final line in r.stdout.toString().split("\n")) {
          final pid = int.tryParse(line.trim());
          if (pid != null) {
            killed.add(pid);
          }
        }
        return killed;
      }

      final want = kernel == null ? "" : File(kernel).absolute.path;
      if (want.isEmpty) {
        return killed;
      }
      final r = await Process.run("pgrep", ["-x", "mihomo"]);
      if (r.exitCode != 0) {
        return killed;
      }
      for (final line in r.stdout.toString().split("\n")) {
        final pid = int.tryParse(line.trim());
        if (pid == null) {
          continue;
        }
        try {
          final ps = await Process.run("ps", [
            "-o",
            "ppid=,command=",
            "-p",
            "$pid",
          ]);
          final out = ps.stdout.toString().trim();
          final parts = out.split(RegExp(r"\s+"));
          if (parts.length < 2 || int.tryParse(parts.first) != 1) {
            continue;
          }
          if (File(parts[1]).absolute.path != want) {
            continue;
          }
          Process.killPid(pid, ProcessSignal.sigkill);
          killed.add(pid);
        } catch (_) {}
      }
    } catch (_) {}
    return killed;
  }
}

@visibleForTesting
bool notifySystemProxyChangedForTest() => notifySystemProxyChanged();

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
