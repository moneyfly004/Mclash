import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

import 'models.dart';
import 'vpn_service_platform.dart';

/// Android 平台实现：MethodChannel → Kotlin `MclashVpnService`
///
/// 架构（与桌面端完全同一套上层代码）：
///   Flutter 侧生成 mihomo Clash YAML → 经 MethodChannel 传给 Kotlin 服务
///   → `VpnService.establish()` 拿到 TUN fd → `Mihomelib.start(homeDir, yaml, tunFd)`
///   → 内核直接用该 fd 收发包（非 root 全局代理的关键）
///   → 内核自带 Clash API（external-controller）→ Flutter 侧热切换/DNS/流量统计
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

    // 落盘 service.json（与原实现一致：原生侧与 Dart 侧都能读）
    try {
      final f = File(cfg.config_file_path);
      await f.parent.create(recursive: true);
      await f.writeAsString(cfg.toPrettyJson(), flush: true);
    } catch (_) {}
    return null;
  }

  /// 读取内核最终配置（core + patch 合并由 Kotlin 侧调用内核前完成）
  Future<String> _resolvedConfigYaml(VpnServiceConfig cfg) async {
    if (cfg.core_path_patch.isNotEmpty || cfg.core_path_patch_final.isNotEmpty) {
      // 内核在 hub.Parse 前会做 YAML+patch 合并；这里把三方路径一并交过去，
      // 由 Kotlin 侧先合并后调用 Mihomelib.start。
      return "";
    }
    return File(cfg.core_path).readAsString();
  }

  /// VpnService.prepare()：返回 true 表示**已经**授权，无需再弹框
  @override
  Future<bool> isServiceAuthorized(String path) async {
    final r = await _channel.invokeMethod<bool>("prepare", {});
    return r == true;
  }

  /// Android 下"授权"= 拉起系统 VPN 授权弹框；返回 null 表示成功
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
      final args = <String, dynamic>{
        "config_yaml": yaml,
        "need_tun": true,
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
      // 原生侧启动成功后即把状态推成 connected；这里等一小段确认
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
      // 未授权 VPN 是一种**可引导**的错误，不是崩溃
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

  /// 内置内核版本（设置页「内核管理」显示）
  Future<String> kernelVersion() async {
    try {
      return await _channel.invokeMethod<String>("kernelVersion") ?? "";
    } catch (_) {
      return "";
    }
  }

  /// 内核日志增量（日志中心页轮询）
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

  /// 已安装应用列表（分应用代理页）
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

  /// 唤醒锁：连接期间保持 CPU 唤醒（防厂商 ROM 杀后台）
  Future<void> setWakeLock(bool enable) async {
    try {
      await _channel.invokeMethod<void>("wakeLock", {"enable": enable});
    } catch (_) {}
  }

  // ---- Android 不适用 ----
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
  Future<Directory?> getAppGroupDirectory(String groupId) async => null;
  @override
  Future<void> hideDockIcon(bool hide) async {}
  @override
  Future<String> clashiApiConnections(bool all) async => "";
  @override
  Future<String> clashiApiTraffic() async => "";
}
