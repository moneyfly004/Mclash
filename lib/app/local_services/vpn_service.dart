// ignore_for_file: unused_catch_stack, empty_catches

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:mclash/app/clash/clash_http_api.dart';
import 'package:mclash/app/modules/clash_setting_manager.dart';
import 'package:mclash/app/modules/profile_manager.dart';
import 'package:mclash/app/modules/profile_patch_manager.dart';
import 'package:mclash/app/modules/setting_manager.dart';
import 'package:mclash/app/runtime/return_result.dart';
import 'package:mclash/app/utils/app_args.dart';
import 'package:mclash/app/utils/app_utils.dart';
import 'package:mclash/app/utils/did.dart';
import 'package:mclash/app/utils/error_reporter_utils.dart';
import 'package:mclash/app/utils/file_utils.dart';
import 'package:mclash/app/utils/install_referrer_utils.dart';
import 'package:mclash/app/utils/log.dart';
import 'package:mclash/app/utils/network_utils.dart';
import 'package:mclash/app/utils/path_utils.dart';
import 'package:mclash/mf/mclash_subscription_revision.dart';
import 'package:mclash/app/utils/platform_utils.dart';
import 'package:launch_at_startup/launch_at_startup.dart';
import 'package:libclash_vpn_service/libclash_vpn_service.dart'
    show lastSystemProxyCleanSkip;
import 'package:libclash_vpn_service/proxy_manager.dart';
import 'package:libclash_vpn_service/state.dart';
import 'package:libclash_vpn_service/vpn_service_platform_interface.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as path;

class VPNService {
  static const localhost = "127.0.0.1";
  static bool _runAsAdmin = false;
  static final bool _systemExtension = true;
  static List<String> _abis = [];
  static final List<
    void Function(FlutterVpnServiceState state, Map<String, String> params)
  >
  onEventStateChanged = [];

  static Future<void> initABI() async {
    if (Platform.isAndroid) {
      String abisAll = await FlutterVpnService.getABIs();
      _abis = abisAll.replaceAll("[", "").replaceAll("]", "").split(",");
    }
  }

  static Future<void> init() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    if (PlatformUtils.isPC()) {
      unawaited(_scanStaleKernelsInBackground());
    }
    if (Platform.isWindows) {
      unawaited(_readAdminStateInBackground());
      unawaited(_prewarmFirewallRules());
    }

    launchAtStartup.setup(
      appName: packageInfo.appName,
      appPath: Platform.resolvedExecutable,
      args: [AppArgs.launchStartup],
    );

    FlutterVpnService.onStateChanged((
      FlutterVpnServiceState state,
      Map<String, String> params,
    ) async {
      if (getSupportSystemProxy() &&
          state == FlutterVpnServiceState.disconnected) {
        try {
          await FlutterVpnService.cleanSystemProxy();
        } catch (err) {
          Log.w("VPNService: 断开后清理系统代理失败（忽略）${err.toString()}");
        }
      }

      for (var callback in onEventStateChanged) {
        callback(state, params);
      }
    });

    final profile = ProfileManager.getCurrent();
    if (profile != null) {
      final prepareResult = await ProfileManager.prepare(profile);
      if (prepareResult == null) {
        await _prepareConfig(profile);
      }
    }

    if (PlatformUtils.isPC()) {
      await stop();
    }
  }

  static Future<void> uninit() async {
    if (PlatformUtils.isPC()) {
      await stop();
    }
  }

  static Future<void> _scanStaleKernelsInBackground() async {
    try {
      final stale = await FlutterVpnService.killStaleKernels();
      if (stale.isNotEmpty) {
        Log.w("VPNService: 已清理上一次遗留的内核进程 ${stale.join("、")}");
      }
    } catch (err) {
      Log.w("VPNService: 清理遗留内核失败 ${err.toString()}");
    }
  }

  static Future<void> _readAdminStateInBackground() async {
    try {
      final admin = await FlutterVpnService.isRunAsAdmin();
      _runAsAdmin = admin;
      Log.i("VPNService: 管理员权限=${admin ? "是" : "否"}");
    } catch (err) {
      Log.w("VPNService: 读取管理员状态失败 ${err.toString()}");
    }
  }

  static Future<void> _prewarmFirewallRules() async {
    try {
      await Future<void>.delayed(const Duration(seconds: 3));
      final ports = <int>[
        ClashSettingManager.getControlPort(),
        ClashSettingManager.getMixedPort(),
      ].where((p) => p > 0).toSet().toList();
      await FlutterVpnService.firewallAddApp(
        Platform.resolvedExecutable,
        PathUtils.getExeName(),
      );
      await FlutterVpnService.firewallAddApp(
        PathUtils.serviceExePath(),
        PathUtils.serviceExeName(),
      );
      if (ports.isNotEmpty) {
        await FlutterVpnService.firewallAddPorts(
          ports,
          PathUtils.serviceExeName(),
        );
      }
      Log.i("VPNService: 防火墙规则已预热（点击连接时不再等 netsh）");
    } catch (err) {
      Log.w("VPNService: 预热防火墙规则失败（忽略）${err.toString()}");
    }
  }

  static List<String> getABIs() {
    return _abis;
  }

  static ReturnResultError? convertErr(VpnServiceResultError? err) {
    if (err == null) {
      return null;
    }
    return ReturnResultError(err.message);
  }

  static Future<bool> _prepareConfig(ProfileSetting profile) async {
    final corePath = path.join(await PathUtils.profilesDir(), profile.id);
    final patch = ProfilePatchManager.getProfilePatch(profile.patch);
    final setting = ClashSettingManager.getConfig();
    final appSetting = SettingManager.getConfig();

    try {
      final controlPort = ClashSettingManager.getControlPort();
      final mixedPort = ClashSettingManager.getMixedPort();
      final busy =
          (controlPort > 0 && !await _portFree(controlPort)) ||
          (mixedPort > 0 && !await _portFree(mixedPort));
      if (busy) {
        Log.w("VPNService: 端口被占用（控制 $controlPort / 混合 $mixedPort）→ 强制清理残留内核");
      }
      final stale = await FlutterVpnService.killStaleKernels(
        includeOwn: true,
        force: busy,
      );
      if (stale.isNotEmpty) {
        Log.w("VPNService: 起内核前清理残留内核进程 ${stale.join("、")}");
      }
    } catch (err) {
      Log.w("VPNService: 清理残留内核失败（忽略）${err.toString()}");
    }
    await _ensureMixedPortAvailable();
    await _ensureControlPortAvailable();
    final controlPort = ClashSettingManager.getControlPort();

    bool overwriteFinal =
        patch.id.isEmpty ||
        patch.id == kProfilePatchBuildinOverwrite ||
        patch.appendPatchBuildin == kProfilePatchBuildinOverwrite;
    final swPatch = Stopwatch()..start();
    await ClashSettingManager.saveCorePatchFinal(
      profile.id,
      overwriteFinal,
      profile.overwriteRules
          ? (profile.overwriteProxyGroups
                ? profile.rulesForProxyGroups
                : profile.rules)
          : null,
      profile.overwriteProxyGroups ? profile.proxyGroups : null,
      null,
    );
    Log.i("[perf] 连接：生成内核补丁用时 ${swPatch.elapsedMilliseconds} ms");

    var excludePorts = [controlPort];
    excludePorts.add(ClashSettingManager.getMixedPort());

    String name = AppUtils.getName();
    String vpnName = name;
    String configFilePath = await PathUtils.serviceConfigFilePath();
    String installReferrer = await InstallReferrerUtils.getString();

    VpnServiceConfig config = VpnServiceConfig();
    config.tun_enabled = ClashSettingManager.tunEnabledByUser();
    config.control_port = controlPort;
    config.base_dir = await PathUtils.profileDir();
    config.work_dir = await PathUtils.serviceWorkDir();
    final missingGeo = await _ensureGeoDataOnDisk(config.work_dir);
    _lastWorkDir = config.work_dir;
    _lastMissingGeo = missingGeo;
    FlutterVpnService.setAssetsDir(PathUtils.appAssetsDir());
    config.cache_dir = await PathUtils.cacheDir();
    if (patch.type == ProfilePatchFileType.yaml) {
      config.core_path = corePath;
      config.core_path_patch = await ProfilePatchManager.getProfilePatchPath(
        profile.patch,
      );
    } else {
      config.core_path = await ProfilePatchManager.getProfilePatchScriptPath(
        corePath,
        profile.patch,
      );
    }

    config.core_path_patch_final = await PathUtils.serviceCorePatchFinalPath();
    config.log_path = await PathUtils.serviceLogFilePath();
    config.err_path = await PathUtils.serviceStdErrorFilePath();
    config.id = await Did.getDid();
    config.version = AppUtils.getBuildinVersion();
    config.name = name;
    config.secret = ClashSettingManager.getConfig().Secret!;
    config.install_refer = installReferrer;
    config.prepare =
        (overwriteFinal &&
            setting.Tun?.OverWrite == true &&
            setting.Tun?.Enable == true) ||
        !overwriteFinal;
    config.wake_lock = appSetting.wakeLock;
    config.ipv6 = setting.IPv6 == true;
    config.auto_connect_at_boot = appSetting.autoConnectAtBoot;
    config.include_all_networks =
        setting.Extension?.Tun.includeAllNetworks ?? false;
    config.exclude_local_networks =
        setting.Extension?.Tun.excludeLocalNetworks ?? false;
    config.exclude_cellular_services =
        setting.Extension?.Tun.excludeCellularServices ?? false;
    config.exclude_apns = setting.Extension?.Tun.excludeApns ?? false;
    config.exclude_device_communication =
        setting.Extension?.Tun.excludeDeviceCommunication ?? false;
    config.enforce_routes = setting.Extension?.Tun.enforceRoutes ?? false;
    config.auto_route_use_sub_ranges_by_default =
        setting.Extension?.Tun.autoRouteUseSubRangesByDefault ?? false;
    var bundleIdentifier = AppUtils.getBundleId(_systemExtension);
    var uiServerAddress = name;
    var uiLocalizedDescription = vpnName;
    if (Platform.isMacOS) {
      if (_systemExtension) {
        uiServerAddress = "$uiServerAddress (system)";
        uiLocalizedDescription = "$uiLocalizedDescription (system)";
      }
    }
    await FlutterVpnService.prepareConfig(
      config: config,
      tunnelServicePath: PathUtils.serviceExePath(),
      configFilePath: configFilePath,
      systemExtension: _systemExtension,
      bundleIdentifier: bundleIdentifier,
      controlKind: AppUtils.getControlKind(),
      uiServerAddress: uiServerAddress,
      uiLocalizedDescription: uiLocalizedDescription,
      excludePorts: excludePorts,
    );
    File confFile = File(configFilePath);
    bool reinstall = false;
    if (Platform.isMacOS) {
      bool exists = await confFile.exists();
      if (exists) {
        try {
          String content = await confFile.readAsString();
          if (content.isNotEmpty) {
            var configJson = jsonDecode(content);
            VpnServiceConfig configOld = VpnServiceConfig();
            configOld.fromJson(configJson);
            if (config.install_refer != configOld.install_refer) {
              reinstall = true;
            }
          }
        } catch (err, stacktrace) {
          Log.w("VPNService.prepareConfig exception ${err.toString()}");
        }
      }
    }

    const JsonEncoder encoder = JsonEncoder.withIndent('  ');
    String content = encoder.convert(config);
    try {
      await confFile.writeAsString(content, flush: true);
    } catch (err) {
      ErrorReporterUtils.tryReportNoSpace(err.toString());
    }

    if (Platform.isMacOS) {
      ProxyManager().setExcludeDevices({vpnName});
    }

    return reinstall;
  }

  static Future<ReturnResultError?> install() async {
    VpnServiceResultError? err = await FlutterVpnService.installService();
    if (err != null) {
      Log.w("VPNService.install err ${err.message.toString()}");
    }
    return convertErr(err);
  }

  static Future<ReturnResultError?> uninstall() async {
    VpnServiceResultError? err = await FlutterVpnService.uninstallService();
    if (err != null) {
      Log.w("VPNService.uninstall err ${err.message.toString()}");
    }
    return convertErr(err);
  }

  static String _lastWorkDir = "";
  static List<String> _lastMissingGeo = const [];

  static Future<void> _opLock = Future<void>.value();
  static String _opHolder = "";

  /// 连接许可闸门（由账号/授权层注入）：返回非 null 表示**拒绝**本次连接。
  ///
  /// 到期 / 被禁用的账号必须在**所有**路径上都连不上：首页按钮、托盘菜单、
  /// `clash://` 深链、开机自启、订阅更新后的重连、内核自愈 —— 它们最终都走
  /// `start()` / `restart()`，所以闸门放在这里最可靠（UI 层的提示是第二道）。
  static Future<ReturnResultError?> Function()? connectGate;

  /// 执行闸门。**失败即拒绝**（fail-closed）：宁可让连接被拦下并报错，
  /// 也不能因为校验本身出错而放行一个到期/被封禁的账号。
  static Future<ReturnResultError?> _runConnectGate() async {
    final gate = connectGate;
    if (gate == null) {
      return null;
    }
    try {
      return await gate();
    } catch (err) {
      Log.w("VPNService: 连接许可校验异常 → 拒绝连接 $err");
      return ReturnResultError("连接许可校验失败，请联网后重试：$err");
    }
  }

  static Future<T> _serialOp<T>(String name, Future<T> Function() action) {
    final prev = _opLock;
    final gate = Completer<void>();
    _opLock = gate.future;

    Future<T> run() async {
      final waited = _opHolder.isNotEmpty;
      if (waited) {
        Log.i("VPNService: $name 等待前一个操作($_opHolder)完成");
      }
      _opHolder = name;
      try {
        return await action();
      } finally {
        _opHolder = "";
        if (!gate.isCompleted) {
          gate.complete();
        }
      }
    }

    // ⚠️ 前一个操作**异常结束**时也必须放行后面的操作：
    // 以前写成 `prev.then(...)`，prev 带错误完成时回调根本不会执行 → gate 永不
    // 完成 → 之后所有 start / stop / restart 永久排队（表现为「点了没反应」，
    // 且再怎么点都连不上/断不开）。
    return prev
        .then((_) => run(), onError: (Object _) => run())
        .whenComplete(() {
          if (!gate.isCompleted) {
            gate.complete();
          }
        });
  }

  static Future<ReturnResultError?> restart(Duration timeout) =>
      _serialOp("restart", () => _restartInner(timeout));

  static Future<ReturnResultError?> _restartInner(Duration timeout) async {
    final gateError = await _runConnectGate();
    if (gateError != null) {
      return gateError;
    }
    final profile = ProfileManager.getCurrent();
    if (profile == null) {
      return ReturnResultError("current profile is empty");
    }
    final prepareResult = await ProfileManager.prepare(profile);
    if (prepareResult != null) {
      return prepareResult;
    }
    var started = await getStarted();
    if (!started) {
      return null;
    }
    try {
      bool reinstall = await _prepareConfig(profile);
      if (reinstall) {
        await uninstall();
      }
    } catch (err, stacktrace) {
      return ReturnResultError(err.toString());
    }

    await _ensureMixedPortAvailable();
    await syncMixedPortFromKernel();

    var setting = SettingManager.getConfig();
    if (Platform.isWindows) {
      final controlPort = ClashSettingManager.getControlPort();
      final mixedPort = ClashSettingManager.getMixedPort();
      var ports = [controlPort, mixedPort];

      FlutterVpnService.firewallAddPorts(ports, PathUtils.serviceExeName());
    }
    if (Platform.isMacOS) {
      await FlutterVpnService.setAlwaysOn(false);
    }
    final bool wantProxy = shouldApplySystemProxy();
    VpnServiceWaitResult result = await FlutterVpnService.restart(timeout);
    if (result.type == VpnServiceWaitType.timeout) {
      _logConnectDiagnostics("内核 ${timeout.inSeconds}s 内未就绪");
      await _stopInner();
      return ReturnResultError("service restart timeout");
    }
    if (result.type != VpnServiceWaitType.done) {
      Log.w(
        "VPNService.restart err ${result.type}:${result.err!.message.toString()}",
      );

      await _stopInner();
      return convertErr(result.err);
    }
    String errorPath = await PathUtils.serviceStdErrorFilePath();
    String? content = await FileUtils.readAndDelete(errorPath);
    if (content != null && content.isNotEmpty) {
      await _stopInner();
      return ReturnResultError(content);
    }
    if (Platform.isMacOS) {
      if (setting.alwayOn) {
        await FlutterVpnService.setAlwaysOn(setting.alwayOn);
      }
    }

    if (wantProxy) {
      var port = await syncMixedPortFromKernel();
      if (port <= 0) {
        await _ensureMixedPortAvailable();
        port = await syncMixedPortFromKernel();
      }
      if (port > 0) {
        await setSystemProxy(true);
        final ok = await getSystemProxyEnable();
        Log.i(
          "VPNService: 重启后已重设系统代理 -> 127.0.0.1:$port"
          "（读回校验: ${ok ? "已生效" : "未生效"}）",
        );
      } else {
        Log.w("VPNService: 重启后拿不到有效混合端口，未设置系统代理");
      }
    }
    return null;
  }

  static Future<ReturnResultError?> start(Duration timeout) =>
      _serialOp("start", () => _startInner(timeout));

  static Future<ReturnResultError?> _startInner(Duration timeout) async {
    final gateError = await _runConnectGate();
    if (gateError != null) {
      return gateError;
    }
    final profile = ProfileManager.getCurrent();
    if (profile == null) {
      return ReturnResultError("current profile is empty");
    }
    if (Platform.isAndroid) {
      var authorized = false;
      try {
        authorized = await FlutterVpnService.isServiceAuthorized("");
      } catch (err) {
        Log.w("VPNService.start: 请求 VPN 授权失败 ${err.toString()}");
      }
      Log.i("VPNService.start: VPN 授权=${authorized ? "已允许" : "未允许"}");
      if (!authorized) {
        return ReturnResultError("需要你的授权才能建立 VPN 连接：\n请在系统弹窗中点击「允许」，然后重新连接。");
      }
      try {
        final already =
            await FlutterVpnService.requestNotificationPermission();
        Log.i("VPNService.start: 通知权限=${already ? "已有" : "已向用户请求"}");
      } catch (err) {
        Log.w("VPNService.start: 请求通知权限失败 ${err.toString()}");
      }
    }
    final prepareResult = await ProfileManager.prepare(profile);
    if (prepareResult != null) {
      return prepareResult;
    }
    ClashHttpApi.resetControlConnection();
    ClashHttpApi.invalidateProxiesCache();

    final swPrepare = Stopwatch()..start();
    try {
      bool reinstall = await _prepareConfig(profile);
      if (reinstall) {
        await uninstall();
      }
    } catch (err, stacktrace) {
      Log.w("[perf] 连接：准备配置失败，用时 ${swPrepare.elapsedMilliseconds} ms");
      return ReturnResultError(err.toString());
    }
    Log.i("[perf] 连接：准备配置用时 ${swPrepare.elapsedMilliseconds} ms");
    var setting = SettingManager.getConfig();
    if (Platform.isWindows) {
      final controlPort = ClashSettingManager.getControlPort();
      final mixedPort = ClashSettingManager.getMixedPort();
      var ports = [controlPort, mixedPort];

      FlutterVpnService.firewallAddPorts(ports, PathUtils.serviceExeName());
    }
    VpnServiceWaitResult result;
    try {
      result = await FlutterVpnService.start(timeout);
    } catch (err) {
      _logConnectDiagnostics("start 抛出异常: $err");
      return ReturnResultError("启动失败：$err");
    }
    if (result.type == VpnServiceWaitType.timeout) {
      _logConnectDiagnostics("内核 ${timeout.inSeconds}s 内未就绪");
      await _stopInner();
      return ReturnResultError("service start timeout");
    }

    if (result.err != null) {
      Log.w("VPNService.start err ${result.err!.message.toString()}");
      _logConnectDiagnostics(result.err!.message.toString());
      await _stopInner();
      return convertErr(result.err);
    }
    String errorPath = await PathUtils.serviceStdErrorFilePath();
    String? content = await FileUtils.readAndDelete(errorPath);
    if (content != null && content.isNotEmpty) {
      await _stopInner();
      return ReturnResultError(content);
    }
    if (Platform.isMacOS) {
      if (setting.alwayOn) {
        await FlutterVpnService.setAlwaysOn(setting.alwayOn);
      }
    }

    if (PlatformUtils.isPC() && !shouldApplySystemProxy()) {
      Log.w("VPNService: 未设置系统代理 —— ${systemProxySkipReason()}");
      if (PlatformUtils.isPC() && SettingManager.getConfig().tunEnabled) {
        if (VPNService.systemProxyFallbackActive) {
          Log.w("VPNService: TUN 未生效，已由兜底逻辑改用系统代理");
        }
      }
    } else if (PlatformUtils.isPC()) {
      var port = await syncMixedPortFromKernel();
      if (port <= 0) {
        await _ensureMixedPortAvailable();
        port = await syncMixedPortFromKernel();
      }
      if (port > 0 && shouldApplySystemProxy()) {
        await setSystemProxy(true);
        final ok = await getSystemProxyEnable();
        Log.i("VPNService: 系统代理 -> 127.0.0.1:$port（读回校验: ${ok ? "已生效" : "未生效"}）");
        if (ok) {
          _startProxyWatchdog(port);
        } else {
          Log.w(
            "VPNService: 系统代理写入后校验未通过（127.0.0.1:$port）——"
            "可能被其它代理软件/组策略覆盖，可在「我的→应用设置→系统代理」里重设",
          );
        }
      } else {
        Log.w("VPNService: 混合端口仍无效，未设置系统代理（可在「应用设置→系统代理」手动重设）");
      }
    }

    unawaited(MclashSubscriptionRevision.markRunning());
    return null;
  }

  static int resolveEffectiveMixedPort({
    required int kernelPort,
    required int configuredPort,
  }) {
    if (kernelPort > 0 && kernelPort <= 65535) {
      return kernelPort;
    }
    if (configuredPort > 0 && configuredPort <= 65535) {
      return configuredPort;
    }
    return 0;
  }

  static Future<int> syncMixedPortFromKernel() async {
    final configured = ClashSettingManager.getMixedPort();
    var kernelPort = 0;
    try {
      final result = await ClashHttpApi.getConfigs();
      kernelPort = result.data?.mixed_port ?? 0;
    } catch (err) {
      Log.w("VPNService: 读取内核 mixed-port 失败 ${err.toString()}");
    }

    final port = resolveEffectiveMixedPort(
      kernelPort: kernelPort,
      configuredPort: configured,
    );
    if (port > 0 && port != configured) {
      Log.w("VPNService: 内核实际监听 $port，设置里是 $configured，已同步为 $port");
      await ClashSettingManager.setMixedPort(port);
    }
    if (port <= 0) {
      Log.w("VPNService: 拿不到有效的混合端口（内核 $kernelPort / 设置 $configured），跳过系统代理设置");
    }
    return port;
  }

  static Future<void> _ensureControlPortAvailable() async {
    final cur = ClashSettingManager.getControlPort();
    if (cur > 0 && await _portFree(cur)) {
      return;
    }
    final mixed = ClashSettingManager.getMixedPort();
    var picked = 0;
    for (final p in [9091, 9092, 9093, 19090, 29090, 39090]) {
      if (p == mixed) {
        continue;
      }
      if (await _portFree(p)) {
        picked = p;
        break;
      }
    }
    if (picked <= 0) {
      picked = await _pickFreePort();
    }
    Log.w(
      "VPNService: 控制端口 $cur 被占用（多为另一个代理软件的内核）→ 改用 $picked 并写入设置",
    );
    await ClashSettingManager.setControlPort(picked);
  }

  static Future<void> _ensureMixedPortAvailable() async {
    final cur = ClashSettingManager.getMixedPort();
    if (cur > 0 && await _portFree(cur)) {
      return;
    }
    final picked = await _pickFreePort();
    Log.w("VPNService: 混合端口 $cur 被占用，改用 $picked 并写入设置");
    await ClashSettingManager.setMixedPort(picked);
  }

  static Future<bool> _portFree(int port) async {
    if (port <= 0) {
      return false;
    }
    for (final addr in [
      InternetAddress.anyIPv4,
      InternetAddress.anyIPv6,
      InternetAddress.loopbackIPv4,
    ]) {
      ServerSocket? s;
      try {
        s = await ServerSocket.bind(addr, port);
      } catch (_) {
        return false;
      } finally {
        await s?.close();
      }
    }
    return true;
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

  static Timer? _proxyWatchdog;

  static void _startProxyWatchdog(int port) {
    _proxyWatchdog?.cancel();
    _proxyWatchdog = Timer.periodic(const Duration(seconds: 15), (_) async {
      try {
        if (!shouldApplySystemProxy() && !systemProxyFallbackActive) {
          return;
        }
        if (await getState() == FlutterVpnServiceState.disconnected) {
          _stopProxyWatchdog();
          return;
        }
        final expect = ClashSettingManager.getMixedPort();
        if (expect <= 0) {
          return;
        }
        if (await getSystemProxyEnable()) {
          return;
        }
        await setSystemProxy(true);
        final fixed = await getSystemProxyEnable();
        Log.w(
          "VPNService: 系统代理被改动，已按 127.0.0.1:$expect 重新设置"
          "（读回: ${fixed ? "已生效" : "仍未生效"}）",
        );
      } catch (err) {
        Log.w("VPNService: 系统代理看守异常 ${err.toString()}");
      }
    });
  }

  static void _stopProxyWatchdog() {
    _proxyWatchdog?.cancel();
    _proxyWatchdog = null;
  }

  static Future<void> stop() => _serialOp("stop", _stopInner);

  static Future<void> _stopInner() async {
    final sw = Stopwatch()..start();
    _stopProxyWatchdog();
    final tasks = <Future<void>>[
      _quiet("撤系统代理", setSystemProxy(false)),
      _quiet("停止内核", FlutterVpnService.stop()),
    ];
    if (Platform.isMacOS) {
      tasks.add(_quiet("关闭 always-on", FlutterVpnService.setAlwaysOn(false)));
    }
    await Future.wait(tasks);
    if (Platform.isWindows) {
      await uninstall();
    }
    ClashHttpApi.resetControlConnection();
    ClashHttpApi.invalidateProxiesCache();
    Log.i("[perf] 断开：撤系统代理 + 停内核用时 ${sw.elapsedMilliseconds} ms");
  }

  static Future<void> _quiet(String what, Future<void> f) async {
    try {
      await f;
    } catch (err) {
      Log.w("VPNService: 断开步骤「$what」失败（忽略）${err.toString()}");
    }
  }

  @visibleForTesting
  static bool? debugSupportSystemProxyOverride;

  static bool getSupportSystemProxy() {
    final override = debugSupportSystemProxyOverride;
    if (override != null) {
      return override;
    }
    return PlatformUtils.isPC();
  }

  static bool shouldApplySystemProxy() {
    if (!getSupportSystemProxy()) {
      return false;
    }
    if (Platform.isAndroid) {
      return false;
    }
    final setting = SettingManager.getConfig();
    if (setting.tunOnly) {
      return false;
    }
    return setting.autoSetSystemProxy;
  }

  static String systemProxySkipReason() {
    if (!getSupportSystemProxy()) {
      return "当前平台不支持系统代理（仅 Windows / macOS）";
    }
    final setting = SettingManager.getConfig();
    if (setting.tunOnly) {
      return "TUN 模式为「强制」：由虚拟网卡接管全部流量，不再改系统代理";
    }
    if (!setting.autoSetSystemProxy) {
      return "已关闭「连接后自动设置系统代理」（应用设置 → 系统代理）";
    }
    return "";
  }

  static Future<void> restoreSystemProxy() async {
    if (!getSupportSystemProxy()) {
      return;
    }
    try {
      await FlutterVpnService.cleanSystemProxy();
      final skip = lastSystemProxyCleanSkip;
      if (skip.isEmpty) {
        Log.i("VPNService: 已还原系统代理（退出清理）");
      } else {
        Log.i("VPNService: 系统代理未改动 —— $skip");
      }
    } catch (err) {
      Log.w("VPNService restoreSystemProxy exception:${err.toString()}");
    }
  }

  static bool get systemProxyFallbackActive =>
      FlutterVpnService.systemProxyFallbackActive;

  static TunStartFailureKind get tunFailureKind =>
      FlutterVpnService.tunFailureKind;

  static String get systemProxyHost => localhost;

  static Future<void> setSystemProxy(bool enable) async {
    if (!getSupportSystemProxy()) {
      return;
    }
    try {
      if (!enable) {
        await restoreSystemProxy();
        return;
      }
      final options = await getSystemProxyOptions();
      if (options.port == 0) {
        return;
      }
      await FlutterVpnService.setSystemProxy(options);
    } catch (err) {
      Log.w("VPNService setSystemProxy exception:${err.toString()}");
    }
  }

  static Future<bool> getSystemProxyEnable() async {
    if (!getSupportSystemProxy()) {
      return false;
    }
    final hostOptionsLocal = getSystemProxyOptionsLocalhost();
    bool enable = await FlutterVpnService.getSystemProxyEnable(
      hostOptionsLocal,
    );
    if (!enable) {
      final hostOptionsLan = await getSystemProxyOptionsLan();
      if (hostOptionsLan != null) {
        enable |= await FlutterVpnService.getSystemProxyEnable(hostOptionsLan);
      }
    }

    return enable;
  }

  static bool isRunAsAdmin() {
    return _runAsAdmin;
  }

  static bool tunPrerequisitesMet() {
    if (!PlatformUtils.isPC()) {
      return false;
    }
    if (Platform.isWindows && !_runAsAdmin) {
      return false;
    }
    return true;
  }

  static Future<ReturnResultError?> relaunchAsAdmin() async {
    if (!Platform.isWindows) {
      return ReturnResultError("只有 Windows 需要以管理员身份重启");
    }
    try {
      final exe = Platform.resolvedExecutable;
      final result = await Process.run("powershell", [
        "-NoProfile",
        "-Command",
        "Start-Process -FilePath '${exe.replaceAll("'", "''")}' -Verb RunAs",
      ]);
      if (result.exitCode != 0) {
        return ReturnResultError(
          "以管理员身份启动失败（UAC 被拒绝？）：${result.stderr.toString().trim()}",
        );
      }
      return null;
    } catch (err) {
      return ReturnResultError(err.toString());
    }
  }

  static Future<FlutterVpnServiceState> getState() async {
    return await FlutterVpnService.currentState;
  }

  static Future<bool> getStarted() async {
    FlutterVpnServiceState newState = await FlutterVpnService.currentState;
    if (newState == FlutterVpnServiceState.connected) {
      return true;
    }

    return false;
  }

  static Future<List<int?>> getPortsByPrefer(bool preferForward) async {
    var started = await getStarted();
    if (started) {
      final mixedPort = ClashSettingManager.getMixedPort();
      if (preferForward) {
        return [mixedPort, null];
      }
      return [null, mixedPort];
    }
    return [null];
  }

  static Future<ReturnResultError?> reload(Duration timeout) async {
    return restart(timeout);
  }

  static String getLaunchAtStartupTaskName() {
    return "${AppUtils.getName()} Autorun";
  }

  static Future<ReturnResultError?> setLaunchAtStartup(bool enable) async {
    if (PlatformUtils.isPC()) {
      try {
        if (enable) {
          if (Platform.isWindows) {
            bool admin = isRunAsAdmin();
            await FlutterVpnService.autoStartCreate(
              getLaunchAtStartupTaskName(),
              Platform.resolvedExecutable,
              processArgs: AppArgs.launchStartup,
              runElevated: admin,
            );
            return null;
          }
        } else {
          await FlutterVpnService.autoStartDelete(getLaunchAtStartupTaskName());
          await launchAtStartup.disable();
        }
      } catch (err, stacktrace) {
        return ReturnResultError(err.toString());
      }
    }
    return null;
  }

  static Future<bool> getLaunchAtStartup() async {
    if (PlatformUtils.isPC()) {
      try {
        if (Platform.isWindows) {
          if (await FlutterVpnService.autoStartIsActive(
            getLaunchAtStartupTaskName(),
          )) {
            return true;
          }
        }
        return await launchAtStartup.isEnabled();
      } catch (err, stacktrace) {
        return false;
      }
    }
    return false;
  }

  static ProxyOption getSystemProxyOptionsLocalhost() {
    return ProxyOption(
      localhost,
      ClashSettingManager.getMixedPort(),
      SettingManager.getConfig().systemProxyBypassDomain,
    );
  }

  static ProxyOption? _lanOptionsCache;
  static DateTime? _lanOptionsCacheAt;
  static const Duration _lanOptionsTtl = Duration(seconds: 60);

  static Future<ProxyOption?> getSystemProxyOptionsLan() async {
    if (!PlatformUtils.isPC()) {
      return null;
    }
    final cached = _lanOptionsCache;
    final at = _lanOptionsCacheAt;
    if (cached != null &&
        at != null &&
        DateTime.now().difference(at) < _lanOptionsTtl) {
      return cached;
    }

    var host = localhost;
    List<NetInterfacesInfo> interfaces = await NetworkUtils.getInterfaces();
    if (interfaces.length == 1) {
      host = interfaces[0].address;
    } else {
      for (var face in interfaces) {
        if (Platform.isMacOS && face.name.startsWith("en")) {
          host = face.address;
          break;
        }
      }
    }

    final option = ProxyOption(
      host,
      ClashSettingManager.getMixedPort(),
      SettingManager.getConfig().systemProxyBypassDomain,
    );
    _lanOptionsCache = option;
    _lanOptionsCacheAt = DateTime.now();
    return option;
  }

  static Future<ProxyOption> getSystemProxyOptions() async {
    final bypassDomain = SettingManager.getConfig().systemProxyBypassDomain;
    final mixedPort = ClashSettingManager.getMixedPort();

    return ProxyOption(localhost, mixedPort, bypassDomain);
  }

  static Future<List<String>> _ensureGeoDataOnDisk(String workDir) async {
    if (workDir.isEmpty) {
      return const [];
    }
    const files = <String, List<String>>{
      "country.mmdb": ["assets/rules/country.mmdb"],
      "geosite.dat": ["assets/rules/geosite.dat"],
      "GeoLite2-ASN.mmdb": ["assets/rules/GeoLite2-ASN.mmdb", "assets/datas/ASN.mmdb"],
    };
    final missing = <String>[];
    final copied = <String>[];
    for (final entry in files.entries) {
      final dst = File(path.join(workDir, entry.key));
      try {
        if (await dst.exists() && await dst.length() > 0) {
          continue;
        }
      } catch (_) {}
      var ok = false;
      for (final asset in entry.value) {
        try {
          final data = await rootBundle.load(asset);
          if (data.lengthInBytes <= 0) {
            continue;
          }
          await dst.writeAsBytes(data.buffer.asUint8List(), flush: true);
          copied.add("${entry.key}(${data.lengthInBytes}B)");
          ok = true;
          break;
        } catch (_) {
        }
      }
      if (!ok) {
        missing.add(entry.key);
      }
    }
    if (copied.isNotEmpty) {
      Log.i("VPNService: geo 数据已就绪 ${copied.join(", ")} -> $workDir");
    }
    if (missing.isNotEmpty) {
      Log.w("VPNService: geo 数据缺失 ${missing.join(", ")}（内核可能尝试联网下载而卡住）");
    } else {
      Log.i("VPNService: geo 数据齐全（country.mmdb / geosite.dat / GeoLite2-ASN.mmdb）");
    }
    return missing;
  }

  static void _logConnectDiagnostics(String detail) {
    Log.w("VPNService: 连接失败诊断 —— $detail");
    Log.w("VPNService:   · 工作目录 = ${_lastWorkDir.isEmpty ? "(未知)" : _lastWorkDir}");
    Log.w(
      "VPNService:   · geo 数据 = "
      "${_lastMissingGeo.isEmpty ? "齐全" : "缺失 ${_lastMissingGeo.join(", ")}"}",
    );
    final port = ClashSettingManager.getMixedPort();
    Log.w("VPNService:   · 混合端口 = $port");
    Log.w(
      "VPNService:   · 提示：安卓请确认已在系统弹窗允许 VPN；"
      "TUN 需要权限，起不来时会退化为系统代理",
    );
  }
}
