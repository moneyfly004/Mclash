import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

import 'kernel_config.dart';
import 'models.dart';
import 'vpn_service_platform.dart';

class AndroidVpnServicePlatform extends VpnServicePlatform {
  AndroidVpnServicePlatform() {
    _channel.setMethodCallHandler(_onNativeCall);
  }

  static const MethodChannel _channel = MethodChannel('top.moneyfly/vpn_core');

  VpnServiceConfig? _config;
  FlutterVpnServiceState _state = FlutterVpnServiceState.disconnected;

  @override
  FlutterVpnServiceState get state => _state;

  Future<dynamic> _onNativeCall(MethodCall call) async {
    switch (call.method) {
      case "onStateChanged":
        final args = call.arguments is Map
            ? Map<String, dynamic>.from(call.arguments as Map)
            : <String, dynamic>{};
        _state = flutterVpnServiceStateFromString(args["state"]?.toString());
        emitStateChanged(_state, {
          for (final e in args.entries) e.key.toString(): e.value.toString(),
        });
        return null;
      default:
        return null;
    }
  }

  @override
  Future<VpnServiceResultError?> prepareConfig(Map<String, dynamic> args) async {
    final cfg = VpnServiceConfig()
      ..fromJson(Map<String, dynamic>.from(args["config"] as Map));
    cfg.config_file_path = args["configFilePath"]?.toString() ?? "";
    cfg.tunnel_service_path = args["tunnelServicePath"]?.toString() ?? "";
    final ports = args["excludePorts"];
    if (ports is List) {
      cfg.exclude_ports = [for (final e in ports) (e as num).toInt()];
    }
    _config = cfg;

    try {
      final f = File(cfg.config_file_path);
      await f.parent.create(recursive: true);
      await f.writeAsString(cfg.toPrettyJson(), flush: true);
    } catch (_) {}
    return null;
  }

  Future<String> _resolvedConfigYaml(VpnServiceConfig cfg) async {
    final result = await buildKernelConfig(cfg);
    for (final note in result.notes) {
      stderr.writeln("[mclash] 内核配置(android): $note");
    }
    emitKernelConfigWarnings(result.warnings);
    return result.yaml;
  }

  /// 内核配置落盘路径：**不能**把配置内容塞进 Intent extra。
  ///
  /// 为什么（真机报障，安卓全平台连不上）：
  ///   config_yaml 会随节点数线性增长（500+ 节点时约 700KB）。它以前是作为
  ///   `startForegroundService(intent)` 的 extra 传过去的，而 Binder 单次事务
  ///   上限约 512KB → `TransactionTooLargeException: data parcel size 698536 bytes`
  ///   → 服务根本没被创建（onStartCommand 不会执行）→ 系统 FGS 看门狗在 30 秒后
  ///   直接杀掉整个 App（ForegroundServiceDidNotStartInTimeException）。
  ///   表现就是「点连接连不上 + App 卡死/闪退」。
  ///
  /// 现在只传路径，服务在自己的后台线程里读文件（见 MclashVpnService.startBox）。
  static String configFilePathOf(VpnServiceConfig cfg) {
    final dir = cfg.work_dir.isNotEmpty
        ? cfg.work_dir
        : (cfg.config_file_path.isNotEmpty
              ? File(cfg.config_file_path).parent.path
              : "");
    final sep = Platform.pathSeparator;
    final name = "service_core_config.yaml";
    if (dir.isEmpty) {
      return name;
    }
    return dir.endsWith(sep) ? "$dir$name" : "$dir$sep$name";
  }

  @override
  Future<bool> isServiceAuthorized(String path) async {
    final r = await _channel.invokeMethod<bool>("prepare", {});
    return r == true;
  }

  @override
  Future<VpnServiceResultError?> authorizeService(
    String path,
    String password,
  ) async {
    final ok = await isServiceAuthorized(path);
    return ok
        ? null
        : VpnServiceResultError(code: -1, message: "noVpnPermission");
  }

  @override
  Future<VpnServiceWaitResult> start(Duration timeout) async {
    final cfg = _config;
    if (cfg == null) {
      return VpnServiceWaitResult(
        type: VpnServiceWaitType.error,
        err: VpnServiceResultError(code: -2, message: "config not prepared"),
      );
    }
    _state = FlutterVpnServiceState.connecting;
    emitStateChanged(_state, const {});
    try {
      final yaml = await _resolvedConfigYaml(cfg);
      // 落地到文件，只把**路径**交给服务：内容走 Intent extra 会撞 Binder
      // 上限（约 512KB）→ TransactionTooLargeException → 服务起不来 + 30 秒后
      // 被 FGS 看门狗杀进程。500+ 节点时配置约 700KB，必踩。
      final configPath = configFilePathOf(cfg);
      var wrotePath = "";
      try {
        final f = File(configPath);
        await f.parent.create(recursive: true);
        await f.writeAsString(yaml, flush: true);
        wrotePath = configPath;
      } catch (e) {
        stderr.writeln("[mclash] 内核配置落盘失败，回退到内存传递: $e");
      }
      final args = <String, dynamic>{
        if (wrotePath.isNotEmpty) "config_path": wrotePath,
        // 只有落盘失败时才走旧的 inline 传递（小配置仍可用；大配置由原生侧
        // 自行落盘兜底，见 VpnServicePlugin.start）。
        if (wrotePath.isEmpty) "config_yaml": yaml,
        "need_tun": true,
        "ipv6": cfg.ipv6,
        "home_dir": cfg.work_dir,
        "mixed_port": cfg.control_port,
        "secret": cfg.secret,
        "log_path": cfg.log_path,
        "core_path": cfg.core_path,
        "core_path_patch": cfg.core_path_patch,
        "core_path_patch_final": cfg.core_path_patch_final,
        "wake_lock": cfg.wake_lock,
      };
      await _channel.invokeMethod<void>("start", args);

      final deadline = DateTime.now().add(
        timeout == Duration.zero ? const Duration(seconds: 10) : timeout,
      );
      while (DateTime.now().isBefore(deadline)) {
        final s = await _channel.invokeMethod<String>("state");
        if (s == "connected") {
          _state = FlutterVpnServiceState.connected;
          emitStateChanged(_state, const {});
          return VpnServiceWaitResult(type: VpnServiceWaitType.done);
        }
        if (s == "disconnected") {
          final err = await _channel.invokeMethod<String>("lastStartError");
          _state = FlutterVpnServiceState.disconnected;
          emitStateChanged(_state, const {});
          return VpnServiceWaitResult(
            type: VpnServiceWaitType.error,
            err: VpnServiceResultError(
              code: -6,
              message: (err == null || err.isEmpty)
                  ? "内核启动失败（原生侧未返回具体原因）"
                  : err,
            ),
          );
        }
        await Future<void>.delayed(const Duration(milliseconds: 200));
      }
      await stop();
      return VpnServiceWaitResult(
        type: VpnServiceWaitType.timeout,
        err: VpnServiceResultError(code: -7, message: "service start timeout"),
      );
    } on PlatformException catch (e) {
      _state = FlutterVpnServiceState.disconnected;
      emitStateChanged(_state, const {});

      final msg = e.code == "NEED_PERMISSION"
          ? "noVpnPermission"
          : "启动失败：${e.message ?? e.code}";
      return VpnServiceWaitResult(
        type: VpnServiceWaitType.error,
        err: VpnServiceResultError(code: -8, message: msg),
      );
    } catch (e) {
      _state = FlutterVpnServiceState.disconnected;
      emitStateChanged(_state, const {});
      return VpnServiceWaitResult(
        type: VpnServiceWaitType.error,
        err: VpnServiceResultError(code: -9, message: "$e"),
      );
    }
  }

  @override
  Future<VpnServiceWaitResult> restart(Duration timeout) async {
    await stop();
    return start(timeout);
  }

  @override
  Future<void> stop() async {
    _state = FlutterVpnServiceState.disconnecting;
    emitStateChanged(_state, const {});
    try {
      await _channel.invokeMethod<void>("stop");
    } catch (_) {}
    _state = FlutterVpnServiceState.disconnected;
    emitStateChanged(_state, const {});
  }

  @override
  Future<String> getABIs() async {
    try {
      return await _channel.invokeMethod<String>("getABIs") ?? "";
    } catch (_) {
      return "";
    }
  }

  @override
  Future<String> getSystemVersion() async {
    try {
      return await _channel.invokeMethod<String>("getSystemVersion") ?? "";
    } catch (_) {
      return Platform.operatingSystemVersion;
    }
  }

  Future<String> kernelVersion() async {
    try {
      return await _channel.invokeMethod<String>("kernelVersion") ?? "";
    } catch (_) {
      return "";
    }
  }

  @override
  Future<String> fetchKernelLogs({bool incremental = true}) async {
    try {
      return await _channel.invokeMethod<String>("fetchKernelLogs", {
            "incremental": incremental,
          }) ??
          "";
    } catch (_) {
      return "";
    }
  }

  Future<List<Map<String, dynamic>>> getInstalledApps() async {
    try {
      final list = await _channel.invokeListMethod<dynamic>("getInstalledApps");
      if (list == null) {
        return const [];
      }
      return [
        for (final e in list)
          if (e is Map) Map<String, dynamic>.from(e),
      ];
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<String?> setExcludeFromRecents(bool exclude) async {
    try {
      await _channel.invokeMethod<void>("setExcludeFromRecents", {
        "exclude": exclude,
      });
      return null;
    } catch (e) {
      return "$e";
    }
  }

  Future<void> setWakeLock(bool enable) async {
    try {
      await _channel.invokeMethod<void>("wakeLock", {"enable": enable});
    } catch (_) {}
  }

  @override
  Future<VpnServiceResultError?> installService() async => null;
  @override
  Future<VpnServiceResultError?> uninstallService() async => null;
  @override
  Future<void> setAlwaysOn(bool enable) async {}
  @override
  Future<bool> setSystemProxy(ProxyOption option) async => false;
  @override
  Future<bool> cleanSystemProxy() async => false;
  @override
  Future<bool> getSystemProxyEnable(ProxyOption option) async => false;
  @override
  Future<bool> isRunAsAdmin() async => false;
  @override
  Future<bool> firewallAddApp(String path, String name) async => false;
  @override
  Future<bool> firewallAddPorts(List<int> ports, String name) async => false;
  @override
  Future<bool> autoStartCreate(
    String name,
    String path, {
    String? processArgs,
    bool runElevated = false,
  }) async =>
      false;
  @override
  Future<bool> autoStartDelete(String name) async => false;
  @override
  Future<bool> autoStartIsActive(String name) async => false;
  @override

  @override
  Future<Directory?> getAppGroupDirectory(String groupId) async =>
      Directory(await getApplicationSupportDir());
  @override
  Future<void> hideDockIcon(bool hide) async {}
  @override
  Future<String> clashiApiConnections(bool all) async => "";
  @override
  Future<String> clashiApiTraffic() async => "";

  @override
  Future<bool> requestNotificationPermission() async {
    try {
      final r = await _channel.invokeMethod<bool>(
        "requestNotificationPermission",
      );
      return r ?? true;
    } catch (_) {
      return true;
    }
  }
}
