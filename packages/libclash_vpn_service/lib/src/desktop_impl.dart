
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

/// 是否同时用 `INTERNET_PER_CONN_OPTION` 写「当前连接」的代理。
///
/// **默认 true（2026-09-18 改回）**：Windows 的「设置 → 代理 / Internet 选项 →
/// 局域网设置」读的就是这份**每连接**数据（`Connections\DefaultConnectionSettings`）。
/// 我们一度改成「只写注册表 + 广播」，理由是「参考实现只写注册表也能显示」——
/// 但用户随后的实测推翻了它：0.0.1 上界面依旧空白。
///
/// 更关键的是我们发现了**为什么**会出现「同一台机器上参考客户端能显示、我们不能」：
/// 我们以前在清理时（每次启动、每次断开）无条件把这份每连接数据写成「直连」，
/// 而设置时又从不写它 —— 于是这份「界面唯一读的数据」长期停在「直连」，
/// 界面必然空白；连**别人家**客户端（MoneyFly / Clash Party）设置的系统代理
/// 也一起被我们写坏（它们同样只写注册表，不会去修这份缓存）。
/// 现在写入与清理都走同一个官方接口，并且只在「确实是我们写的」时候才动它。
bool usePerConnectionProxyWrite = true;

/// 我们在 `Internet Settings` 键下留的「归属标记」值名。
///
/// 为什么必须有它（用户实测的跨软件事故）：Mclash 的默认混合端口是 **7890**，
/// 而 MoneyFly / Clash Party / Clash Verge 这些客户端的默认端口也都在 7890 一带。
/// 旧实现启动时只按「注册表里 ProxyServer 是不是 `127.0.0.1:<我们的端口>`」判断
/// 「这是我们上次留下的残留」，于是**把别人正在用的系统代理当成残留清掉**：
/// ProxyEnable=0、ProxyServer 删除，并把「界面读的那份」写成直连。
/// 用户看到的就是「用了 Mclash 之后，我的 MoneyFly 连上了、Windows 里却不显示
/// 127.0.0.1 和端口了」。有了标记：只有标记存在且与当前 ProxyServer 一致，
/// 才认作「是我们写的」，否则一律不碰。
const String kSystemProxyOwnerValueName = "MclashProxyOwner";

/// 系统代理所在的注册表键（FFI 与 reg.exe 两条路径共用）。
const String _kInternetSettingsKey =
    r"HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings";

/// 我们写入系统代理前的原始状态快照（注册表原始输出 + 每连接那份）。
///
/// 参考实现（moneyfly SystemProxyManager）就是这么做的：断开时**还原**用户原本的
/// 代理配置，而不是一律「关掉 + 删值」。旧实现直接 `ProxyEnable=0` 并删除
/// `ProxyServer`/`ProxyOverride` —— 用户本来配着公司代理，一用 Mclash 就被抹掉了。
class SystemProxySnapshot {
  /// 注册表原始输出（null = 该值原本不存在）。
  String? enableRaw;
  String? serverRaw;
  String? overrideRaw;

  /// 解析出来的注册表原值（null = 原本不存在）。
  ///
  /// 为什么要单独存一份解析结果：还原时要写回**用户原来的值**，而 `readSystemProxyRaw`
  /// 给的是 `reg query` 的整段文本（含键名、类型）。旧实现拿文本再解析一次，
  /// 于是「本来不存在」和「存在但读不到」在两条路径上可能得出不同结论，
  /// 最坏情况是把用户自己的代理值写成了空/删掉。
  String? enableValue;
  String? serverValue;
  String? overrideValue;

  /// 界面读的那一份（null = 没读到，可能是 API 不可用）。
  int? connFlags;
  String connServer = "";
  String connBypass = "";

  /// 写入前的 `Connections\DefaultConnectionSettings` 原始字节（null = 原本没有）。
  ///
  /// 官方 API 失败时我们改走「直接写这份 blob」兜底，断开时就必须把它还原回来。
  List<int>? connBlob;

  /// 本进程是否用 blob 兜底覆盖过这份数据（断开时据此决定要不要还原）。
  bool blobOverwritten = false;

  bool captured = false;

  /// 从 `reg query` 输出里取值的文本（`ProxyServer  REG_SZ  127.0.0.1:7890`）。
  ///
  /// 不能按空白 split 取末段：旁路列表本身可能含空格（`localhost; 127.0.0.1`），
  /// 那样还原出来的名单是残的。
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
      // 注意用 `[^\r\n]*` 而不是 `.*$`：`reg query` 的输出是 CRLF，行尾的 \r
      // 不在 `.` 的匹配范围内，而 `$` 又要求真正的结尾 —— 用 `.*$` 会**永远
      // 匹配不上**（写这段时踩过一次，单测钉住）。
      final m = RegExp(r"\s+REG_[A-Z_]+\s+([^\r\n]*)").firstMatch(rest);
      if (m != null) {
        return m.group(1)!.trim();
      }
    }
    return null;
  }

  /// ProxyEnable 的原始值是不是「开」（`0x1` / `1`）。
  static bool isEnabledRaw(String? value) {
    if (value == null) {
      return false;
    }
    final v = value.trim().toLowerCase();
    return v == "0x1" || v == "1";
  }
}

/// 最近一次 Windows 系统代理相关的动作结果（面板里直接显示，方便定位）。
class SystemProxyDiagnostics {
  static bool? internetSetOption;
  static bool? wmSettingChange;
  static bool? perConnectionApi;
  static String lastError = "";

  /// 最近一次「清理」为什么没做（空 = 做了）。
  static String lastCleanSkip = "";

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
    buf.writeln("注册表 ProxyOverride: ${await _regQueryValue('ProxyOverride')}");
    // 下面两行就是「Windows 界面显示什么」的答案：界面读的是每连接那份，
    // 不是上面的全局值。两者不一致时，界面显示的一定是每连接那份。
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
    // 官方 API 失败的真实原因（用户机器实测 API 返回 0，界面就空白）：
    //   GetLastError 错误码 + 是哪个 option 出错（dwOptionError）。
    if (perConnectionApi == false) {
      buf.writeln(
        "每连接官方 API 失败: GetLastError=${PerConnectionDiagnostics.lastError} "
        "dwOptionError=${PerConnectionDiagnostics.optionError} "
        "兜底=${PerConnectionDiagnostics.fallbackUsed.isEmpty ? "未记录" : PerConnectionDiagnostics.fallbackUsed}",
      );
    }
    // 「界面到底会不会显示 127.0.0.1:端口」的唯一可靠判据：直接看
    // Connections\DefaultConnectionSettings 这份二进制里有没有这个地址。
    // 不要信上面 InternetQueryOption 的读回 —— 它在数据缺失时会继承全局值，会骗人。
    final blob = readDefaultConnectionSettings();
    final blobServer = await _regQueryValueBlobServer(blob);
    buf.writeln(
      "界面真正读的 DefaultConnectionSettings: "
      "flags=${parseDefaultConnectionSettingsFlags(blob) ?? "?"} "
      "含地址=${blobServer.isEmpty ? "(无)" : blobServer}",
    );
    if (lastCleanSkip.isNotEmpty) {
      buf.writeln("最近一次清理跳过原因: $lastCleanSkip");
    }
    if (lastError.isNotEmpty) {
      buf.writeln("最后错误: $lastError");
    }
    return buf.toString();
  }

  /// 从 DefaultConnectionSettings blob 里解出 ProxyServer 字符串（用于「界面会显示什么」）。
  static Future<String> _regQueryValueBlobServer(List<int>? blob) async {
    if (blob == null || blob.length < 16) {
      return "";
    }
    final len = blob[12] | (blob[13] << 8) | (blob[14] << 16) | (blob[15] << 24);
    if (len <= 2 || 16 + len > blob.length) {
      return "";
    }
    final units = <int>[];
    for (var i = 16; i + 1 < 16 + len; i += 2) {
      final u = blob[i] | (blob[i + 1] << 8);
      if (u == 0) {
        break;
      }
      units.add(u);
    }
    return String.fromCharCodes(units);
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

/// 是否正在写日志（防止「日志出口又调回 desktopLog」造成递归）。
bool _logging = false;

/// 写一行桌面端诊断日志：先给 App，再兜底写 stderr。
///
/// ⚠️ 这里曾经写成 `desktopLog(line)`（自己调自己）而不是 `stderr.writeln(line)`：
/// 递归会一路撞到栈溢出才被 catch 吃掉，而**每一层都会先调一次 sink** ——
/// 于是一行日志被写进 app.log 几百上千次。实测（一行一次调用）：
///   sink 被调用 11585 次 / 单次 desktopLog 用时 441µs（本机 JIT）。
/// 用户侧的三个现象全部由此而来：
///   1. 日志里同一条 `[perf] 断开…` 刷屏几百行（用户实测截图）；
///   2. 日志文件被放大几百倍，应用日志页卡、复制都费劲；
///   3. 连接/断开时每个诊断行都要写几百次磁盘（Log 是**同步写**），
///      叠加起来就是「连接/断开仍然卡顿」——这条比任何 IO 都值钱。
void desktopLog(String line) {
  if (_logging) {
    // 重入（sink 内部又回头调用本函数）：只写 stderr，绝不递归。
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
        // sink 抛异常 → 落到下面的 stderr 兜底
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
  /// 连续这么多次探测无响应才认定「内核假活」（杀掉并自愈）。
  ///
  /// 从 3 提到 4：探测是 20 秒一次、每次最多等 3 秒 —— 而内核在有大批延迟测试
  /// （内核自己测 300~400 个节点）或大流量时，控制接口短暂变慢是正常的，
  /// 3 次（60 秒）就杀内核会把「只是忙」误判成「死了」，用户体感就是
  /// 「用着用着莫名其妙断一下、又自己连回来」。
  static const int kWatchdogMaxMisses = 4;

  int _mixedPort = 0;

  bool _systemProxyApplied = false;

  /// 正在断开 / 退出清理：**任何**「顺手写一下系统代理」的逻辑都必须让路。
  ///
  /// 为什么需要它（真实的竞态）：系统代理看守每 15 秒醒一次，判据是
  /// `shouldApplySystemProxy() && !getSystemProxyEnable()`。用户点断开时
  /// `shouldApplySystemProxy()` 还是 true（设置没变），而清理刚好把代理撤掉 ——
  /// 看守醒来就**又把系统代理写回去**，结果「点了关闭，代理却还在」，
  /// 或者和清理互相覆盖（谁后写谁赢，用户看到的状态随机）。
  bool _teardownInProgress = false;

  /// 写入系统代理前，用户原本的配置（断开时**还原**，而不是一律抹掉）。
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
      // 各阶段耗时打点：用户反馈「连接时卡顿 / 短暂卡死」，有这行才能从日志看出
      // 卡在哪一段（配置生成 / geo 数据 / 内核就绪等待），而不是靠猜。
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

  /// 连上之后的「数据通路兜底」：**必须保证至少有一条通路**。
  ///
  /// 用户实测的核心问题（Windows）：「连上了，但 Windows 的系统代理是空白」，
  /// 而且我们界面还显示 TUN 正常 —— 真正的状态是**两条通路都没有**：
  /// TUN 配置开着（auto/force），但虚拟网卡因为没管理员权限/网卡残留/驱动被拦
  /// 根本没建起来；而旧实现只在「日志里能匹配到已知失败关键字」时才退到系统代理。
  /// 关键字对不上（内核换了措辞、或失败信息被挤出日志窗口）→ 什么都不做 →
  /// 用户既没有 TUN 也没有系统代理：界面空白、网也不通。
  ///
  /// 现在的判据是**「有没有证据说明 TUN 真的起来了」**，而不是「有没有证据说明它失败」：
  ///   * 明确识别到失败 → 兜底；
  ///   * 配置要 TUN，但日志里连一条「TUN 就绪」都没有 → 视为没起来，兜底；
  ///   * 有就绪标记 → TUN 在接管，不动系统代理（避免两套机制同时生效）。
  Future<void> _applyDataPathFallback(File logFile) async {
    _systemProxyFallbackActive = false;
    // 判定窗口放大到 200 行：内核启动时打几百行（节点/geo/规则），40 行很容易
    // 把 TUN 的关键行挤出去。
    var tail = await _tail(logFile, 200);
    var kind = classifyTunFailure(tail);
    var established = tunLooksEstablished(tail);
    final tunWanted = _config?.tun_enabled == true;

    // TUN 的建立是异步的：日志可能还没写出来。没有就绪证据时再等一小会儿
    // （只在这种情况下等，正常连接不受影响），避免把「还没来得及打日志」
    // 误判成「TUN 没起来」而多写一次系统代理。
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
      // 没匹配到已知失败，但也没有任何就绪证据 → 按「原因未归类」提示用户，
      // 而不是假装一切正常（这正是「系统代理空白 + 界面显示 TUN 正常」的来源）。
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
    _teardownInProgress = true;
    _stopKernelWatchdog();
    _setState(FlutterVpnServiceState.disconnecting);
    try {
      // 这一步要动系统设置（macOS 逐个网络服务跑 networksetup、Windows 写注册表+广播），
      // 串行做下来要 1~2 秒 —— 用户感受就是「关闭时卡一下」。
      // 「撤系统代理」和「让内核拆掉 TUN」互不依赖，并行做 ⇒ 用时取两者的最大值。
      final swProxy = Stopwatch()..start();
      final cleanFuture =
          _systemProxyApplied ? cleanSystemProxy() : Future.value();
      await Future.wait([cleanFuture, _disableTunBeforeStop()]);
      swProxy.stop();
      desktopLog("[perf] 断开：撤系统代理 + 拆 TUN 用时 ${swProxy.elapsedMilliseconds} ms");
      _systemProxyFallbackActive = false;
      // 关掉内核之前先把 TUN 拆干净。
      //
      // 为什么必须做：Windows 上 Stopping 内核是 `taskkill /F`（强杀），进程没有
      // 机会执行自己的清理 —— mihomo 用 `auto-route` 加的系统路由与 wintun 虚拟网卡
      // 会留在系统里，用户看到的就是「退出软件之后电脑上不了网，得重启」。
      // （拆 TUN 的调用已并入上面的并行等待：先置 tun.enable=false，内核会正常
      // 撤路由、卸网卡，这时候再强杀就没有副作用了。）
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
          // 1.5s 够了：taskkill /F /T 之后内核基本立刻消失；真等不到就直接进
          // 下面那一层 kill(sigkill) 并返回，不把用户按在「断开中…」上。
          await proc.exitCode.timeout(const Duration(milliseconds: 1500));
        } catch (_) {
          try {
            proc.kill(ProcessSignal.sigkill);
          } catch (_) {}
        }
      }
      desktopLog("[perf] 断开总用时 ${swProxy.elapsedMilliseconds} ms");
    } finally {
      // 必须用 finally：中途抛异常时如果 `_teardownInProgress` 卡在 true，
      // 之后**所有**系统代理写入都会被静默忽略（用户会看到「连上了但没有代理」）。
      _teardownInProgress = false;
      _setState(FlutterVpnServiceState.disconnected);
    }
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
    // 超时**故意收紧**（原来 3s）：这一步只是为了「先让内核自己把 TUN 的路由与
    // 网卡撤干净，再强杀」，而且它和「撤系统代理」并行执行 —— 断开的总时长就是
    // 被这条最慢的分支拖着的。内核已经死了的情况是连接被拒（立刻返回），
    // 真正会等满超时的只有「假活」，那种情况本来就该马上强杀（后面还有 taskkill
    // 与「退出即终止」的 Job 对象兜底，不会留残留路由）。
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
    // 共用实现（与 Android 同一套）：基础 YAML + 深合并 patch + 注入控制端口/密钥
    // + 去掉重复入站端口 + 保证混合端口可用。
    final sw = Stopwatch()..start();
    final result = await buildKernelConfigOffThread(cfg);
    sw.stop();
    desktopLog("[perf] 生成内核配置（后台 isolate）: ${sw.elapsedMilliseconds} ms");
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

  /// 日志里有没有「TUN 确实起来了」的**正面**证据。
  ///
  /// 只认明确的成功输出（真机日志原文）：
  ///   * `msg="Tun started"`                    —— TUN 起好了（macOS/Windows 都有）
  ///   * `Tun adapter listening at ...`         —— 网卡已监听
  ///   * `use tun name ...`                     —— 网卡名已确定
  ///
  /// ⚠️ 刻意**不认** `Start TUN listening ...`：失败时内核打的是
  /// `Start TUN listening error: ...`，认了就会把失败当成功（而失败判定的另一边
  /// 是「用户没网」）。同理 `tun name failed` / `error writing to tun device`
  /// 这类「看起来像失败其实正常」的告警也不算正面证据。
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

  /// 读日志尾部 [lines] 行（**从文件末尾反向读，不把整个文件读进内存**）。
  ///
  /// 旧实现是 `readAsLines()` + sublist：内核日志会一直追加（一次运行可能几十 MB），
  /// 而 `_applyDataPathFallback` **每次连接**都要读一次 —— 等于每次连接都把整个日志
  /// 文件读进内存再切开，纯浪费（「连接时有感卡顿」的候选项之一）。
  /// 现在最多只读尾部 256KB。
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
      // 用 UTF-8 解码（allowMalformed）：日志里可能有中文/非 ASCII，
      // 按 charCode 硬转会变乱码（旧实现走 readAsLines 是正确的 UTF-8 解码）。
      var text = utf8.decode(bytes, allowMalformed: true);
      if (readFrom > 0) {
        // 从中间切进来的第一行很可能是不完整的 → 丢掉
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
      // 走 advapi32（微秒级）。以前这里是 `Process.run("reg", …)` —— 每 15 秒
      // 一次的系统代理看守、每次连接/断开都要打一次，每次都是一个新进程。
      final raw = await readSystemProxyRaw(value: "ProxyServer");
      return proxyServerValueMatches(
        SystemProxySnapshot.valueText(raw, "ProxyServer") ?? "",
        option.host,
        option.port,
      );
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
  ///
  /// 优先走 advapi32（一次函数调用，微秒级）；只在 FFI 不可用时退回 `reg.exe`
  /// （一次进程创建，几十毫秒）。返回格式两者一致，`SystemProxySnapshot.valueText`
  /// 与诊断面板都不用区分来源。
  static Future<String> readSystemProxyRaw({
    String value = "ProxyServer",
  }) async {
    if (windowsRegistryAvailable) {
      final text = queryRegistryValueAsRegText(value);
      // null = 值不存在。为了让上层「值不存在 → 还原时删掉我们写的」这条判断
      // 与 reg.exe 路径行为一致，这里返回 reg 的招牌报错文本。
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
    // 与 macOS 同一条硬规则：**绝不写无端口的系统代理**。
    // 端口 0 会让注册表里留下 "127.0.0.1:0"，Windows 流量会被发到一个不存在的
    // 代理上（浏览器全打不开），而且这个残留会一直留到下次清理。
    if (option.port <= 0) {
      desktopLog("[mclash] 拒绝设置无端口的系统代理（port=${option.port}）");
      return false;
    }
    // 正在断开：**任何**写入都是错的（会把刚撤掉的代理又装回去）。
    // 这是「点了关闭，代理却还在」这类竞态的最后一道闸。
    if (_teardownInProgress) {
      desktopLog("[mclash] 忽略一次系统代理写入：正在断开");
      return false;
    }
    try {
      final server = "${option.host}:${option.port}";

      // 0) 先记下用户原本的代理配置（一次），断开时**还原**而不是一律抹掉。
      await _captureSystemProxyOriginal();

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

      // 1) 注册表（全局值）：浏览器/WinINET 的事实来源，也是 App 读回校验的依据。
      //
      // 走 advapi32（FFI）。以前这里是 4 次 `reg add` —— 每次都是一个新进程，
      // Windows 上冷启动 20~50ms，四次就是上百毫秒，全在用户点击连接的路上。
      final wroteEnable = _writeProxyRegistryDword("ProxyEnable", 1);
      final wroteServer = _writeProxyRegistryString("ProxyServer", server);
      _writeProxyRegistryString("ProxyOverride", bypass);
      // 2) 归属标记：让「这是我们写的」这件事可判定，避免把别家客户端的代理
      //    当成我们的残留清掉（用户实测的跨软件事故，见 kSystemProxyOwnerValueName）。
      _writeProxyRegistryString(kSystemProxyOwnerValueName, server);
      if (!wroteEnable || !wroteServer) {
        desktopLog(
          "[mclash] 写系统代理注册表失败："
          "ProxyEnable=${wroteEnable ? "ok" : "失败"} "
          "ProxyServer=${wroteServer ? "ok" : "失败"}",
        );
        return false;
      }

      // 3) 「当前连接」那份（**Windows 界面读的就是它**）。
      //
      // 这一步以前默认关闭过（0.0.5 版本），理由是「参考实现只写注册表也能显示」；
      // 用户实测推翻了它。真正的原因是我们**清理时**总是把这份写成「直连」，
      // 而设置时从不写 —— 界面长期读到「直连」，自然永远是空白。
      // 现在：Windows 自己勾选代理走的就是这个官方接口，我们也用它。
      if (usePerConnectionProxyWrite) {
        final perConn = applySystemProxyForConnection(
          server: server,
          bypass: bypass,
        );
        SystemProxyDiagnostics.perConnectionApi = perConn;
        if (perConn) {
          PerConnectionDiagnostics.fallbackUsed = "official";
          desktopLog("[mclash] 已按官方 API 写「当前连接」（界面读的那份）: 成功");
        } else {
          // 官方 API 返回 0（用户机器实测）。它的失败原因只有 GetLastError 知道，
          // 但无论如何，界面读的那份 `Connections\DefaultConnectionSettings` 没被写。
          // 兜底：直接写这份 REG_BINARY —— 与 WinINet 无关，是界面真正读的数据，
          // 也是 Clash Verge 系等工具用过的可靠手段（灵感：Clash Party 只靠官方
          // API 一步写完，我们在这台机器上退到更底层的一步）。
          final prev = readDefaultConnectionSettings();
          final prevCounter = (prev != null && prev.length >= 8)
              ? (prev[4] | (prev[5] << 8) | (prev[6] << 16) | (prev[7] << 24))
              : 0;
          final blob = buildDefaultConnectionSettingsBlob(
            flags: kProxyTypeDirect | kProxyTypeProxy,
            server: server,
            bypass: bypass,
            counter: prevCounter + 1,
          );
          final blobOk = writeDefaultConnectionSettings(blob);
          PerConnectionDiagnostics.fallbackUsed = blobOk ? "blob" : "none";
          _systemProxySnapshot.blobOverwritten = blobOk;
          desktopLog(
            "[mclash] 官方 API 写「当前连接」失败（GetLastError="
            "${PerConnectionDiagnostics.lastError} dwOptionError="
            "${PerConnectionDiagnostics.optionError}）→ 直接写 DefaultConnectionSettings 兜底: "
            "${blobOk ? "成功" : "失败"}",
          );
        }
      } else {
        SystemProxyDiagnostics.perConnectionApi = null;
        desktopLog("[mclash] 跳过每连接 API 写入（usePerConnectionProxyWrite=false）");
      }

      // 4) 广播：让已经跑着的程序与 Windows 自己的设置页面立刻重读。
      //
      // ⚠️ 这里**不 await** WM_SETTINGCHANGE。它是同步的、发给机器上所有顶层窗口，
      // 任何一个窗口卡住都要吃掉整个超时 —— 用户日志里「写入到广播返回」之间
      // 有 8.8 秒，就是它。广播不属于「连接成功了没有」这个结论，交给后台做。
      final notified = notifySystemProxyChanged();
      SystemProxyDiagnostics.internetSetOption = notified;
      desktopLog(
        "[mclash] 已广播 Internet 设置变更（SETTINGS_CHANGED+REFRESH）: $notified",
      );
      final wm = broadcastInternetSettingsChangedAsync();
      if (!wm) {
        // FFI 不可用（极少数受限环境）→ 用 PowerShell 做同一件事（后台跑）
        unawaited(broadcastInternetSettingsViaPowerShell());
        desktopLog("[mclash] WM_SETTINGCHANGE：FFI 失败，已改用 PowerShell 广播");
      }
      SystemProxyDiagnostics.wmSettingChange = wm;
      desktopLog("[mclash] 已发起 WM_SETTINGCHANGE(InternetSettings) 广播: $wm");

      // 5) 读回校验：**两层都报**。「界面读的那份」就是界面显示什么；
      //    它和注册表不一致时，用户看到的是它 —— 而这正是我们排查了两轮的坑。
      final connServer = querySystemProxyForConnection();
      final connOn = connectionProxyEnabled();
      final registryOk = await _windowsProxyMatches(option);
      // 真正的判据：blob 里有没有这个地址（InternetQueryOption 读回会继承全局值，
      // 那份「ProxyServer/已启用」在这台机器上一直是假象 —— 见诊断报告说明）。
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
        // 注册表对了、界面那份没开 → 界面必然空白。明确记下来（便于定位
        // 「界面空白但能上网」这一类的机器差异），不要静默。
        desktopLog(
          "[mclash] ⚠️ 「当前连接」的代理未启用（界面会显示空白）："
          "官方 API 返回 ${SystemProxyDiagnostics.perConnectionApi}，读到 '$connServer'",
        );
      }
      _systemProxyApplied = true;
      // 注意：这里**不再**额外起一个 PowerShell 再调一次 InternetSetOption。
      // 上面 FFI 已经调过了，重复一遍只是白等 —— 而且 PowerShell 的 Add-Type
      // 每次都要现场编译 C#，实测要 1~3 秒，正好是用户反馈的「连接时卡顿」。
      // 只有 FFI 不可用时才回退（见上面的 WM_SETTINGCHANGE 分支）。
      return true;
    } catch (err) {
      SystemProxyDiagnostics.lastError = "$err";
      return false;
    }
  }

  /// 记下用户原本的代理配置（只在本进程第一次设置之前记一次）。
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

  /// 现在系统里的代理**是不是我们写的**。
  ///
  /// 判据（顺序即优先级）：
  ///   1. 本进程这次连接确实写成功了（`_systemProxyApplied`）→ 是我们的；
  ///   2. 注册表里的归属标记存在，且与当前 ProxyServer 完全一致 → 是我们的；
  ///   3. 没有标记，但 ProxyServer 指向本机回环、**那个端口已经没人监听**
  ///      → 视为「上一次异常退出留下的死代理」（参考实现用的是同一判据），可以清；
  ///      端口还活着就一律不碰。
  ///
  /// 第 3 条是「别人的活代理不能碰」与「我们自己的死残留要清」之间的界：
  /// 端口上有程序监听，就说明有内核在用它 —— 那可能是 MoneyFly / Clash Party
  /// 正在用的系统代理。旧实现按「端口是不是我们设置里的值」判断，而大家的默认
  /// 端口都在 7890 一带，于是**把别人正在用的系统代理清掉了**（用户实测的
  /// 跨软件事故：「用了 Mclash 之后，我的 MoneyFly 连上了、Windows 里却不显示
  /// 127.0.0.1 和端口了」）。
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
    // 快路径：系统里当前的代理根本没启用 → 没什么可清。
    //
    // ⚠️ 这里**不删**归属标记：以前顺手把它删掉了，于是「别家程序临时把
    // ProxyEnable 关掉」时我们的标记也没了，下次启动只能靠「端口死没死」去猜，
    // 猜错就会去动别人的代理。标记由真正写入它的那条路（清理完成的第 2 步）负责删。
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
    // 无标记：只在「本机回环 + 端口已死」时才认作我们的残留
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
      // 0) 先判定归属：不是我们写的就**什么都不要动**。
      //    这是「用了 Mclash 之后别的客户端系统代理也不显示了」的修复点：
      //    旧实现每次启动都会无条件把「界面读的那份」写成直连，等于把别人家的
      //    代理设置从界面上抹掉（注册表也一起清了）。
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
        // 1) 还原用户原有的注册表值（原本没有的值 → 删除我们写的）。
        //
        // 用快照里**解析好的原值**，而不是再解析一遍原始文本：写回用户自己的
        // 配置这一步不允许有任何歧义。
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
        // 快照没拿到（极少数：注册表读写都不可用）。
        //
        // ⚠️ 这里以前是「ProxyEnable=0 + 删掉 ProxyServer」——正是用户实测的
        // 「我本来配着公司代理，用完 Mclash 就被抹掉了」的那一下。没有快照就说明
        // 我们无法知道用户原本是什么，那就**什么都不要写**：唯一能确定属于我们的
        // 东西是下面那个归属标记，其余一律不碰。
        desktopLog(
          "[mclash] 清理：没拿到原始快照，不动注册表里的 ProxyEnable/ProxyServer",
        );
      }
      // 2) 归属标记用完即删（下次启动不会误判成我们的）。
      _deleteProxyRegistryValue(kSystemProxyOwnerValueName);

      // 3) 「当前连接」那份（**界面读的就是它**）。
      //
      // ⚠️ 这里以前**无条件**走 clearSystemProxyForConnection()，是「用了 Mclash
      // 之后 MoneyFly / Clash Party 的系统代理在 Windows 里不显示了」的**真正根因**：
      //
      //   * 那份数据我们写、别人不写（MoneyFly / Clash Party / Clash Verge 只写
      //     注册表 + 广播）；
      //   * 于是我们一清理，就把界面读的那份写成「直连」，而别人的注册表值还在 ——
      //     用户看到的就是「注册表里明明有 127.0.0.1:端口、也能上网，界面却空白」，
      //     只有让别的客户端再写一次（先勾上系统代理、再关掉）才会被刷新回来。
      //
      // 现在的规则：**只有快照里记着「我们写入之前它是什么」时，才允许动它**。
      // 原本就是直连 → 写回直连；原本配着代理 → 把原值写回去。没有快照 → 一行都不碰。
      if (snap.captured) {
        // 优先直接还原 blob（Connections\DefaultConnectionSettings）：
        // 它才是界面读的真身，而且**不依赖会在这台机器上失败的官方 API**。
        //   * 写入前就有 blob → 写回原值；
        //   * 写入前没有、但本进程用 blob 兜底覆盖过 → 写回「直连」；
        //   * 两者都没有（官方 API 成功的那条路）→ 仍走官方 API 还原。
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
      // 广播不阻塞断开：它的作用只是让界面刷新，不该让用户等（见
      // broadcastInternetSettingsChangedAsync 的说明）。
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

  /// 写一个系统代理注册表值：先走 FFI，失败再退回 `reg.exe`。
  ///
  /// 为什么要有回退：FFI 是**平台相关**的代码（结构体布局、DLL 导出名），
  /// 而且在没法本机验证的架构/精简系统上可能整个不可用。系统代理是「用户能不能
  /// 上网」的事，这条路不允许因为一次 FFI 问题而彻底失灵 —— 慢一点也要写进去。
  /// 正常情况下走的是上面几条（微秒级），回退分支只在异常时才被走到。
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

  /// 同步执行一次 `reg`（仅用于 FFI 失效时的回退，故不返回输出）。
  ///
  /// 用 `Process.runSync`：调用点（还原/清理）是同步上下文，而这条路本来就不在
  /// 正常路径上（只在 FFI 抛异常时触发），几毫秒的同步等待可以接受。
  static bool _regFallbackSync(List<String> args) {
    try {
      return Process.runSync("reg", args).exitCode == 0;
    } catch (_) {
      return false;
    }
  }

  /// 把某个注册表字符串值还原成快照里的原值；原本不存在 → 删除我们写的值。
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
      String lastServer = "";
      for (var attempt = 0; attempt < 3; attempt++) {
        if (attempt > 0) {
          // 注册表写入偶发不是立刻可见（CI 的 Windows runner 上遇到过「刚写完读不到」）
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

  /// 本次运行里已经放行过的防火墙规则（key = 规则参数）。
  ///
  /// 为什么要缓存：每次 netsh 都要起一个进程（实测几百毫秒），而
  /// 「连接」路径上本来每次都调一次 `firewallAddPorts`（两个端口 = 两次 netsh）。
  /// 规则本身是幂等的（同名规则第二次会报「已存在」→ 退出码非 0，反而被当成失败），
  /// 缓存之后既省掉这部分等待，也不再产生假失败。
  static final Set<String> _firewallRulesAdded = {};

  /// 放行应用/端口穿过 Windows 防火墙。
  /// 不放行的话防火墙会拦环回，表现为"连上了但网页打不开"。
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

  /// 本次运行是否已经扫过残留内核（Windows）。
  ///
  /// 为什么要记住：Windows 上这个扫描要起一次 PowerShell（冷启动实测 1~3 秒），
  /// 而它以前在**每次连接前**都跑一遍（`VPNService._prepareConfig` 里的
  /// `killStaleKernels(includeOwn: true)`）—— 启动时已经扫过一次，新内核又被挂在
  /// 「退出即终止」的 Job 上（不会产生新的孤儿），所以每次都扫纯属白等，
  /// 正是用户反馈的「连接时卡顿」的大头之一。端口真被占用时上层会换端口并再次
  /// 显式扫描（force: true）。
  static bool _staleKernelScanDone = false;

  static Future<List<int>> killStaleKernels({
    bool includeOwn = false,
    bool force = false,
  }) async {
    if (Platform.isWindows && _staleKernelScanDone && !force) {
      return const [];
    }
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
        // 用 Get-Process 列进程（毫秒级）而不是 Get-CimInstance Win32_Process
        // 全表扫描（WMI 冷启动实测 1~3 秒）—— 这个扫描在**每次连接**前都会跑，
        // 正是用户反馈「连接时卡顿」的来源之一。只有真的存在 mihomo 进程时，
        // 才对它逐个查一次父进程 id。
        final script = r"""
$mine = '__KERNEL__'
$targets = @(Get-Process -Name mihomo -ErrorAction SilentlyContinue)
foreach ($p in $targets) {
  $exe = $p.Path
  if ($mine -ne '' -and $exe -and ($exe.ToLower() -ne $mine.ToLower())) { continue }
  $ppid = (Get-CimInstance Win32_Process -Filter "ProcessId=$($p.Id)" -ErrorAction SilentlyContinue).ParentProcessId
  if (-not $ppid) { continue }
  if (-not (Get-Process -Id $ppid -ErrorAction SilentlyContinue)) {
    try { Stop-Process -Id $p.Id -Force; Write-Output $p.Id } catch {}
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
        _staleKernelScanDone = true;
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
