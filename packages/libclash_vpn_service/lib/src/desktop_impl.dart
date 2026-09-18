
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

/// 最近一次 Windows 系统代理相关的动作结果（面板里直接显示，方便定位）。
class SystemProxyDiagnostics {
  static bool? internetSetOption;
  static bool? wmSettingChange;
  static bool? perConnectionApi;
  static String lastError = "";

  static void reset() {
    internetSetOption = null;
    wmSettingChange = null;
    perConnectionApi = null;
    lastError = "";
  }

  /// 给用户/客服看的一份纯文本报告。
  ///
  /// 为什么要有它（用户实测）：Windows 上「注册表里明明有 127.0.0.1:端口、
  /// 浏览器也能上网，但 Internet 选项里一片空白」，而用户手里只有核心日志
  /// （内核输出），看不到 App 侧到底做了哪几步、每步成没成功 —— 两边都在猜。
  /// 这个报告把「注册表值 / 每连接设置（界面读的那份）/ 两次广播结果」摊开，
  /// 在「系统代理」面板里直接可读。
  static Future<String> report() async {
    final buf = StringBuffer();
    buf.writeln("平台: ${Platform.operatingSystem}");
    if (!Platform.isWindows) {
      buf.writeln("（本报告主要针对 Windows；macOS 用的是 networksetup，界面即时可见）");
      return buf.toString();
    }
    buf.writeln("注册表 ProxyEnable: ${await _regQueryValue('ProxyEnable')}");
    buf.writeln("注册表 ProxyServer: ${await _regQueryValue('ProxyServer')}");
    buf.writeln("界面读的每连接 ProxyServer: ${querySystemProxyForConnection()}");
    buf.writeln("界面读的每连接 代理已启用: ${connectionProxyEnabled()}");
    buf.writeln("最后一次 InternetSetOption 广播: $internetSetOption");
    buf.writeln("最后一次 WM_SETTINGCHANGE 广播: $wmSettingChange");
    buf.writeln("最后一次每连接官方 API 写入: $perConnectionApi");
    if (lastError.isNotEmpty) {
      buf.writeln("最后错误: $lastError");
    }
    return buf.toString();
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

/// 桌面端诊断日志的出口。
///
/// 这些行以前只写 `stderr.writeln` —— Windows 上从开始菜单启动的 GUI 程序没有
/// 控制台，stderr 直接被丢掉：用户报「系统代理没生效 / 界面空白」时，
/// 最关键的几行诊断（注册表写了什么、读回校验结果、官方 API 是否成功）
/// 我们一条都拿不到。App 侧（main.dart）把 [desktopLogSink] 指到 `Log.i`，
/// 这些行就会进 app.log，Windows 上也能远程排查。
typedef DesktopLogSink = void Function(String line);

/// 由 App 注入的日志出口（为空时只写 stderr）。
DesktopLogSink? desktopLogSink;

/// 写一行桌面端诊断日志：先给 App，再兜底写 stderr。
void desktopLog(String line) {
  try {
    desktopLogSink?.call(line);
  } catch (_) {}
  try {
    desktopLog(line);
  } catch (_) {}
}

class DesktopVpnServiceImpl extends VpnServicePlatform {
  DesktopVpnServiceImpl();

  Process? _proc;
  VpnServiceConfig? _config;
  FlutterVpnServiceState _state = FlutterVpnServiceState.disconnected;

  bool _starting = false;
  Future<void>? _stopInFlight;
  bool _intentionalStop = false;

  /// 用户**期望**处于连接状态（start 成功后为 true，用户主动 stop 才置 false）。
  ///
  /// 用来区分「内核崩了但用户还想连着」和「用户自己断开的」——
  /// 只有前者才需要自愈，否则会把用户主动断开当成故障反复重连。
  bool _wantConnected = false;

  /// 自愈次数（连续失败达到上限就不再重试，避免崩溃循环刷屏/刷 CPU）。
  int _autoRecoveries = 0;
  static const int kMaxAutoRecover = 3;

  /// 内核存活看门狗：进程没退但控制 API 卡死（假活）也要能发现并恢复。
  Timer? _kernelWatchdog;
  int _watchdogMisses = 0;
  static const Duration kWatchdogInterval = Duration(seconds: 20);
  static const int kWatchdogMaxMisses = 3;

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

  /// App 资源根目录（安装目录下的 `data`）：由应用层注入，用于 geo 数据查找。
  ///
  /// 平台包不能依赖上层的 PathUtils，所以走这个注入点。
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

      // 工作目录准备 + 写 config.yaml：**必须捕获异常**。
      //
      // 真实事故（Windows）：App 装在 Program Files 时工作目录不可写，
      // 这里抛出的 PathAccessException 之前会一路冒到 UI 层变成
      // "[ERROR] Unhandled Exception" —— 用户看到的是「点了连接没反应」，
      // 既没有弹窗也没有日志结论。现在明确返回错误信息。
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
        // 关键：把内核挂到「App 一死就被系统杀掉」的 Job 上。
        // 否则任务管理器结束任务 / 崩溃 / 被强杀都会留下孤儿内核继续跑。
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
        // 「控制 API 通了但没有入站监听」要和「内核根本没起来」分开报 ——
        // 这两种情况的排查方向完全不同（前者是配置里缺 mixed-port，
        // 后者才是被拦截 / 端口被占）。旧实现一律报"启动超时/可能被安全软件
        // 拦截"，把用户和我们一起带偏。
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
          // 控制端口（Clash API）被占用 —— 与「混合端口被占用」是两回事：
          // 前者是别的代理软件的内核占着 9090，后者是我们的入站端口冲突。
          // 上层每次连接前都会自动挑空闲控制端口，所以走到这里说明是运行中被抢占。
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

  /// 退出前「请求内核关闭 TUN」成功的次数（诊断用；也是验证脚本的观测点）。
  int tunTeardownRequests = 0;

  @override
  bool get systemProxyFallbackActive => _systemProxyFallbackActive;

  /// 真正的「TUN 没起来」标记（sing-tun 的启动失败出口）。
  ///
  /// 只认精确串：mihomo 有一批**正常告警**同样含 tun + error/failed
  /// （`Auto detect interface ... failed`、`default interface changed`、
  /// `error writing to TUN device`…），宽泛匹配会把正常连接判死。
  static const List<String> kTunFatalMarkers = [
    "start tun listening error",
    "start tun interface timeout",
    "configure tun interface",
  ];

  /// 已核实的正常 TUN 日志（出现这些行就说明 TUN 其实是好的）。
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

  /// 权限类特征（Windows ERROR_ACCESS_DENIED / POSIX EPERM）。
  static const List<String> kTunPrivilegeMarkers = [
    "access is denied",
    "access denied",
    "permission denied",
    "operation not permitted",
    "requires elevation",
    "administrator",
    "run as root",
  ];

  /// 网卡冲突特征（同名适配器已存在）。
  static const List<String> kTunBusyMarkers = [
    "already exists",
    "already in use",
    "address already in use",
    "file exists",
    "device is in use",
    "in use",
  ];

  /// 驱动 / 依赖加载失败特征。
  static const List<String> kTunDriverMarkers = [
    "wintun",
    "unable to load library",
    "load library",
    "driver",
    ".dll",
    "not found",
  ];

  /// TUN 启动失败的原因（供客户端给出**可执行**的提示，而不是万能句）。
  @override
  TunStartFailureKind tunFailureKind = TunStartFailureKind.none;

  static bool _hasAny(String line, List<String> markers) =>
      markers.any(line.contains);

  /// 单行是否命中「真致命」标记；已知正常日志直接排除。
  static bool isFatalTunLine(String line) {
    final s = line.toLowerCase();
    if (_hasAny(s, kTunBenignMarkers)) {
      return false;
    }
    return _hasAny(s, kTunFatalMarkers);
  }

  /// 判定 + 分类（纯函数，日志尾部 → 失败原因）。
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

  /// 兼容旧调用：是否「TUN 不可用」。
  static bool logIndicatesTunUnavailable(String kernelLogTail) =>
      classifyTunFailure(kernelLogTail) != TunStartFailureKind.none;

  /// 给用户看的可执行提示（不是一句万能的「请以管理员身份运行」）。
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
    final tail = await _tail(logFile, 40);
    final kind = classifyTunFailure(tail);
    tunFailureKind = kind;
    if (kind == TunStartFailureKind.none) {
      return;
    }
    desktopLog(
      "[mclash] TUN 启动失败（${kind.name}）→ ${tunFailureHint(kind)}",
    );
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
        desktopLog(
          "[mclash] TUN 不可用（需要管理员权限），已把系统代理指向 "
          "127.0.0.1:$port（读回校验: ${readBack ? "一致" : "不一致，请检查系统代理设置"}）",
        );
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

  /// 内核「意外退出」时的自愈：用户还期望连着 → 用原配置重启一次。
  ///
  /// 为什么要做：内核因为一次瞬时故障（配置热重载、端口被短暂占用、内存压力）
  /// 退出时，旧实现只是**默默断开并把系统代理撤掉** —— 用户侧看到的是
  /// 「突然断网/自动断开」，只能手动再连一次。现在先自愈，连续失败才如实报错。
  ///
  /// 返回 true 表示已经重新拉起来了（调用方不要再往 disconnected 上写状态）。
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

  /// 内核「进程还在但已经不理人」的检测（假活）。
  ///
  /// 只看进程是否退出是不够的：内核可能因为死锁/内存压力卡住 ——
  /// 这时进程在、系统代理指向它，但**所有流量都出不去**，
  /// 用户看到的同样是「连不上 / 用着用着就断了」。
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
      // 卡死同样算「核心异常」→ 杀掉再自愈，避免留一个假活的进程占着端口
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
    _stopKernelWatchdog();
    _setState(FlutterVpnServiceState.disconnecting);

    if (_systemProxyApplied) {
      await cleanSystemProxy();
    }
    _systemProxyFallbackActive = false;
    // 关掉内核之前先把 TUN 拆干净。
    //
    // 为什么必须做：Windows 上 Stopping 内核是 `taskkill /F`（强杀），进程没有
    // 机会执行自己的清理 —— mihomo 用 `auto-route` 加的系统路由与 wintun 虚拟网卡
    // 会留在系统里，用户看到的就是「退出软件之后电脑上不了网，得重启」。
    // 先通过控制接口把 `tun.enable` 置 false，内核会正常关闭 TUN（撤路由、卸网卡），
    // 这时候再强杀就没有副作用了。
    await _disableTunBeforeStop();
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

  /// 退出前拆掉 TUN（幂等；失败只记日志，不影响退出流程）。
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
          .timeout(const Duration(seconds: 3));
      if (cfg.secret.isNotEmpty) {
        req.headers.set(HttpHeaders.authorizationHeader, "Bearer ${cfg.secret}");
      }
      req.headers.contentType = ContentType.json;
      req.write('{"tun":{"enable":false}}');
      final resp = await req.close().timeout(const Duration(seconds: 3));
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
    // 共用实现（与 Android 同一套）：基础 YAML + 深合并 patch + 注入控制端口/密钥
    // + 去掉重复入站端口 + 保证混合端口可用。
    final result = await buildKernelConfig(cfg);
    for (final note in result.notes) {
      // 配置生成过程的每一步都留痕（排查「内核起不来」时最关键的一段）
      desktopLog("[mclash] 内核配置: $note");
    }
    _mixedPort = result.mixedPort;
    return result;
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
    // ⚠️ 还要把**安装目录**（App 资源根）纳入来源。
    //
    // Windows 上工作目录已从安装目录（Program Files，只读）换到
    // `%APPDATA%\mclash\mclash`，而 country.mmdb / geosite.dat / ASN.mmdb 仍然
    // 只存在于安装目录的 `data\flutter_assets\assets\{rules,datas}` 下 ——
    // 不纳入这一条，换完工作目录 geo 又会"找不到"，内核转而跑去 GitHub 下载
    // （国内不可达 → 内核永不就绪）。
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
      return r.stdout.toString().contains("${option.host}:${option.port}");
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
      desktopLog("[mclash] 拒绝设置无端口的系统代理（port=${option.port}）");
      return false;
    }
    try {
      const key =
          r"HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings";
      // 记下原值以便恢复
      _systemProxyOriginal ??= {};

      // 去重：默认旁路列表本身就含 `<local>`，再拼一次就会写出
      // `<local>;<local>;localhost;…`（用户实测在注册表里看到重复项）。
      final bypassItems = <String>["<local>"];
      for (final d in option.bypassDomains) {
        final item = d.trim();
        if (item.isNotEmpty && !bypassItems.contains(item)) {
          bypassItems.add(item);
        }
      }
      final bypass = bypassItems.join(';');
      final enableRes = await _reg([
        "add", key, "/v", "ProxyEnable", "/t", "REG_DWORD", "/d", "1", "/f",
      ]);
      final serverRes = await _reg([
        "add", key, "/v", "ProxyServer", "/t", "REG_SZ", "/d",
        "${option.host}:${option.port}", "/f",
      ]);
      await _reg([
        "add", key, "/v", "ProxyOverride", "/t", "REG_SZ", "/d", bypass, "/f",
      ]);
      if (enableRes.exitCode != 0 || serverRes.exitCode != 0) {
        desktopLog(
          "[mclash] 写系统代理注册表失败："
          "ProxyEnable=${enableRes.exitCode}(${enableRes.stderr.trim()}) "
          "ProxyServer=${serverRes.exitCode}(${serverRes.stderr.trim()})",
        );
        return false;
      }
      // 写注册表只对**之后新建的连接**生效；已经跑着的程序与 Windows 自己的
      // 「设置 → 代理 / Internet 选项」页面读的是缓存副本。必须再广播一次
      // SETTINGS_CHANGED + REFRESH，Windows 才会刷新缓存并通知所有 WinINET 使用者
      // —— 否则用户看到的就是「代理框还是空的，但能上网」。
      // 只写注册表是**全局**值：新连接会走代理，但「Internet 选项 → 局域网设置」
      // 与 Windows 11「设置 → 代理」读的是**每个连接的缓存副本**
      // （Connections\DefaultConnectionSettings）—— 那份没更新时界面一直显示空白，
      // 用户看到的就是「注册表里有 127.0.0.1:端口，界面却是空的」。
      // 用官方 API 再设一次「当前连接」的代理，注册表与缓存会一起更新。
      SystemProxyDiagnostics.perConnectionApi = false;
      final perConn = applySystemProxyForConnection(
        server: "${option.host}:${option.port}",
        bypass: bypass,
      );
      SystemProxyDiagnostics.perConnectionApi = perConn;
      desktopLog(
        "[mclash] 已按官方 API 设置当前连接的代理（界面/缓存同步）: $perConn",
      );
      final notified = notifySystemProxyChanged();
      SystemProxyDiagnostics.internetSetOption = notified;
      desktopLog(
        "[mclash] 已广播 Internet 设置变更（SETTINGS_CHANGED+REFRESH）: $notified",
      );
      // 参考实现（moneyfly）的第三步：向所有顶层窗口广播 WM_SETTINGCHANGE
      // + lParam="InternetSettings"。Windows 自己的「Internet 选项 / 设置 → 代理」
      // 界面靠这条消息重新读取代理配置 —— 我们以前只做前两步，于是出现
      // 「注册表里明明有 127.0.0.1:端口、也能上网，界面却一直空白」。
      var wm = broadcastInternetSettingsChanged();
      if (!wm) {
        // FFI 不可用（极少数受限环境）→ 用 PowerShell 做同一件事
        wm = await broadcastInternetSettingsViaPowerShell();
        desktopLog("[mclash] WM_SETTINGCHANGE：FFI 失败，已改用 PowerShell 广播");
      }
      SystemProxyDiagnostics.wmSettingChange = wm;
      desktopLog("[mclash] 已广播 WM_SETTINGCHANGE(InternetSettings): $wm");
      // 读回校验：调用成功 ≠ 生效（注册表被策略/其它代理软件改回去过）
      if (!await _windowsProxyMatches(option)) {
        desktopLog(
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
      // 「当前连接」那份缓存也要清，否则界面上还留着上一次的地址；
      // 再广播一次，确保「设置 → 代理」页面立刻刷新。
      clearSystemProxyForConnection();
      notifySystemProxyChanged();
      if (!broadcastInternetSettingsChanged()) {
        await broadcastInternetSettingsViaPowerShell();
      }
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
      desktopLog(
        "[mclash] 系统代理读回校验未通过（期望 ${option.host}:${option.port}），"
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
        // 普通权限下改不动（或被 TCC 拦）时，用一次系统授权兜底：
        // 这正是用户手动去「系统设置 → 网络 → 代理」填端口的等价操作。
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
  ///   macOS   `~/Library/Application Support/<bundleId>`
  ///   Windows `%APPDATA%\<appId>`
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

  /// 清理**孤儿内核**：父进程已经不在了、但还在跑的 mihomo。
  ///
  /// 为什么会存在孤儿（已实测复现）：Windows 没有「父死子死」，直接结束
  /// `mclash.exe`（任务管理器结束任务 / 崩溃 / 被安装程序强杀）时子进程
  /// mihomo 会留下来继续跑、继续占着混合端口与控制端口、系统代理也还指着它，
  /// 用户看到的就是「软件退了，内核还在，网还能上」。
  ///
  /// 现在有了 [assignToKillOnCloseJob]（Job Object）从根上防止新的孤儿产生，
  /// 这里负责把**旧版本留下的**孤儿收掉；否则它们会和新实例抢端口，
  /// 表现为「连不上 / 一直转圈」。
  ///
  /// 只处理**我们自己的那个内核可执行文件**（按路径精确匹配），不会误伤
  /// 其它同样使用 mihomo.exe 的代理软件。
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

  /// 取某个 PID 的可执行文件路径（用于确认「这是我们自己的内核」）。
  static Future<String> _exePathOfPid(int pid) async {
    try {
      if (Platform.isWindows) {
        return "";
      }
      final r = await Process.run("ps", ["-p", "$pid", "-o", "comm="]);
      return r.stdout.toString().trim();
    } catch (_) {
      return "";
    }
  }

  static Future<List<int>> killStaleKernels({bool includeOwn = false}) async {
    final killed = <int>[];
    // 同一路径上、但不是正在被跟踪的那个进程 → 残留内核（父进程还活着，
    // 因此不是孤儿，但继续占着端口）。起内核前必须收掉。
    if (includeOwn) {
      // 正在被跟踪的内核（本次连接用的那个）不能杀。
      final platform = VpnServicePlatform.instance;
      final keepPid = platform is DesktopVpnServiceImpl
          ? (platform._proc?.pid ?? 0)
          : 0;
      try {
        final kernel = await resolveKernelPath();
        final want = kernel == null ? "" : File(kernel).absolute.path;
        if (want.isNotEmpty) {
          final r = await Process.run("pgrep", ["-x", "mihomo"]);
          if (r.exitCode == 0) {
            for (final line in r.stdout.toString().split("\n")) {
              final pid = int.tryParse(line.trim());
              if (pid == null || pid == keepPid) {
                continue;
              }
              final exe = await _exePathOfPid(pid);
              if (exe != want) {
                continue;
              }
              try {
                Process.killPid(pid, ProcessSignal.sigterm);
                await Future<void>.delayed(const Duration(milliseconds: 150));
                Process.killPid(pid, ProcessSignal.sigkill);
                killed.add(pid);
              } catch (_) {}
            }
          }
        }
      } catch (_) {}
    }
    try {
      final kernel = await resolveKernelPath();
      if (Platform.isWindows) {
        final script = r"""
$mine = '__KERNEL__'
Get-CimInstance Win32_Process -Filter "Name='mihomo.exe'" | ForEach-Object {
  $exe = $_.ExecutablePath
  if ($mine -ne '' -and $exe -and ($exe.ToLower() -ne $mine.ToLower())) { return }
  $parent = Get-CimInstance Win32_Process -Filter "ProcessId=$($_.ParentProcessId)" -ErrorAction SilentlyContinue
  if (-not $parent) {
    try { Stop-Process -Id $_.ProcessId -Force; Write-Output $_.ProcessId } catch {}
  }
}
"""
            .replaceFirst('__KERNEL__', (kernel ?? '').replaceAll("'", "''"));
        final r = await Process.run("powershell", [
          "-NoProfile",
          "-ExecutionPolicy",
          "Bypass",
          "-Command",
          script,
        ]);
        for (final line in r.stdout.toString().split("\n")) {
          final pid = int.tryParse(line.trim());
          if (pid != null) {
            killed.add(pid);
          }
        }
        return killed;
      }

      // macOS：pgrep 找 mihomo，ppid==1（被 init 收养）即孤儿。
      // 必须能拿到我们自己的内核路径才动手 —— 用户机器上可能装着别的客户端，
      // 路径对不上就一律不碰。
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

/// 测试缝：把 [notifySystemProxyChanged] 暴露给 Windows 回归测试
/// （它本身就在这个包里，测试要能在不启动内核的情况下单独验证广播这一步）。
@visibleForTesting
bool notifySystemProxyChangedForTest() => notifySystemProxyChanged();

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
