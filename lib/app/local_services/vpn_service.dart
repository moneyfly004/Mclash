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
import 'package:mclash/app/local_services/mac_tun_helper.dart';
import 'package:launch_at_startup/launch_at_startup.dart';
import 'package:libclash_vpn_service/libclash_vpn_service.dart'
    show lastSystemProxyCleanSkip, DesktopVpnServiceImpl, buildKernelHostVbs;
import 'package:libclash_vpn_service/proxy_manager.dart';
import 'package:libclash_vpn_service/state.dart';
import 'package:libclash_vpn_service/vpn_service_platform_interface.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as path;

/// 准备连接配置时可直接展示给用户的失败（目前用于内核补丁写入失败）。
///
/// `_prepareConfig` 的调用方（start / restart）统一 `catch (err)` 后返回
/// `ReturnResultError(err.toString())`，所以这里只需要让 toString 是干净的
/// 人话，而不是 "Bad state: ..." 之类。
class _PrepareConfigFailure implements Exception {
  _PrepareConfigFailure(this.message);

  final String message;

  @override
  String toString() => message;
}

class VPNService {
  static const localhost = "127.0.0.1";
  static bool _runAsAdmin = false;

  /// Windows：安装时创建的最高权限计划任务是否就绪。
  /// 就绪时 App 不需要管理员权限也能用 TUN（内核由任务以最高权限拉起，零 UAC）。
  static bool _kernelTaskReady = false;

  static const String kKernelTaskName = "Mclash Kernel";

  /// macOS：是否已获「免密 sudo 运行内核」授权（/etc/sudoers.d/mclash-tun）。
  /// 由 refreshTunPrerequisites() 异步刷新，tunPrerequisitesMet() 读取。
  static bool _macTunGranted = false;
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
        try {
          await _prepareConfig(profile);
        } catch (err) {
          // 初始化不是连接路径：不拦用户，只记日志（连接时还会重新准备）。
          Log.w("VPNService.init: 准备配置失败（忽略）${err.toString()}");
        }
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
    // 任务就绪状态单独刷新：管理员查询失败时也必须刷新计划任务状态
    // （以前两步在同一个 try 里，isRunAsAdmin 抛异常 → 任务状态永远不更新）。
    try {
      _kernelTaskReady = await kernelTaskExists();
      Log.i(
        "VPNService: 免密提权组件（计划任务「$kKernelTaskName」）="
        "${_kernelTaskReady ? "已就绪（TUN 无需管理员）" : "不可用（将回退 UAC 提权）"}",
      );
    } catch (err) {
      _kernelTaskReady = false;
      Log.w("VPNService: 读取计划任务状态失败 ${err.toString()}");
    }
  }

  static Future<void> _prewarmFirewallRules() async {
    try {
      // 放到 30 秒后：netsh 每次调用都要 1~2 秒并触发磁盘/Defender 活动，
      // 启动瞬间做会让"刚打开就卡"。连接时仍会补加（同一份缓存去重）。
      await Future<void>.delayed(const Duration(seconds: 30));
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
    final patchError = await ClashSettingManager.saveCorePatchFinal(
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
    if (patchError != null) {
      // 以前这里忽略返回值：补丁没写成功时内核仍会拿上一次（可能属于另一个
      // 配置档）的 service_core_patch_final.json 启动 —— 规则/代理组张冠李戴。
      // 必须中止连接并把错误交给上层（start/restart 会转成 ReturnResultError）。
      Log.w("VPNService: 生成内核补丁失败，已中止连接 ${patchError.message}");
      throw _PrepareConfigFailure("生成内核补丁失败：${patchError.message}");
    }
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
      final swWait = Stopwatch()..start();
      final waited = _opHolder.isNotEmpty;
      if (waited) {
        Log.i("VPNService: $name 等待前一个操作($_opHolder)完成");
      }
      _opHolder = name;
      try {
        return await action();
      } finally {
        // 队列等待耗时单独打点：连接慢到底慢在"等前一个操作"还是"自己干活"，
        // 之前混在一个数字里（5.6s 的真相是排队 5.3s + 启动 0.25s）。
        if (waited) {
          Log.i(
            "[perf] $name 排队等待 ${swWait.elapsedMilliseconds} ms",
          );
        }
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

  /// 用户是否处于「主动断开」意图。
  ///
  /// stop / restart 都排在同一个串行队列里。用户点断开时，队列里可能已经排着一个
  /// 由订阅同步或自动选路触发的 restart —— 串行执行的结果就是「先连上、再断开」，
  /// 用户看到的现象正是「我断开之后它自己又连了一次」。
  /// 这个标记让排队中的 restart 直接放弃，而不是先连上再被 stop 杀掉。
  static bool _userWantsDisconnected = false;

  static bool get userWantsDisconnected => _userWantsDisconnected;

  static Future<ReturnResultError?> restart(Duration timeout) {
    if (_userWantsDisconnected) {
      Log.i("VPNService: 用户已主动断开，restart 直接跳过（不再连一次）");
      return Future.value(null);
    }
    return _serialOp("restart", () async {
      if (_userWantsDisconnected) {
        Log.i("VPNService: 用户已主动断开，跳过排队中的 restart");
        return null;
      }
      return _restartInner(timeout);
    });
  }

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

  static Future<ReturnResultError?> start(Duration timeout) {
    // 显式连接：清除「用户要求断开」的意图
    _userWantsDisconnected = false;
    return _serialOp("start", () => _startInner(timeout));
  }

  static Future<ReturnResultError?> _startInner(Duration timeout) async {
    // 幂等：内核已经在跑（或正在起）时，再调一次 start() 绝不能起第二个内核。
    // 以前只靠 UI 层拦 connecting/disconnecting/reasserting，connected 不拦 ——
    // 重复 start 会让底层用新进程覆盖 `_proc`，旧内核失去引用、永远不会被回收
    // （端口占用 + 内存泄漏，断开时也只能杀掉其中一个）。
    final state = await getState();
    if (state == FlutterVpnServiceState.connected ||
        state == FlutterVpnServiceState.connecting ||
        state == FlutterVpnServiceState.reasserting) {
      Log.i("VPNService: 内核已处于 ${state.name}，忽略重复的 start 请求");
      return null;
    }
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
        // 无论校验是否通过都要启动看守：
        //   · 通过 → 之后被别的程序改动/关闭时由它恢复并提示；
        //   · 不通过 → 正是最需要它持续尝试 + 在界面报警的情况（以前这里不启动看守，
        //     于是"写入失败"就永久失败了，界面上却看不出异常）。
        _startProxyWatchdog(port);
        if (!ok) {
          Log.w(
            "VPNService: 系统代理写入后校验未通过（127.0.0.1:$port）——"
            "可能被其它代理软件/组策略覆盖；看守会继续尝试，失败会在首页提示",
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

  /// 系统代理健康告警（空字符串 = 正常）。首页用它显示醒目提示。
  ///
  /// 以前系统代理被别的程序关掉/改掉时，看守要么判定错误（只看地址不看开关），
  /// 要么只在日志里写一行 —— 用户界面一直显示"已连接"，而流量其实已经不走代理。
  static final ValueNotifier<String> systemProxyWarning = ValueNotifier<String>("");

  /// 连续「写入后读回仍不是我们」的次数。
  /// 只用于决定**要不要在首页告警**，绝不用来停止重试 —— MoneyFly 的做法是
  /// 「只要还连着，就一直把系统代理指回本机」，与别的代理软件抢不过也不会放弃，
  /// 否则就会出现「界面显示已连接、实际没有代理」这种最糟的状态。
  static int _proxyFailStreak = 0;

  /// 累计成功恢复次数（只用于日志与提示文案，不参与熔断）
  static int _proxyRepairCount = 0;

  /// 看守轮次是否在执行（避免同一时刻两轮叠加写注册表/networksetup）
  static bool _proxyCheckInFlight = false;

  /// 连续失败多少次才在界面上告警（偶发一次只写日志，不打扰用户）
  static const int kProxyWarnAfterFailures = 3;

  @visibleForTesting
  static bool shouldWarnProxyConflict(int failStreak) =>
      failStreak >= kProxyWarnAfterFailures;

  @visibleForTesting
  static int get debugProxyRepairCount => _proxyRepairCount;

  @visibleForTesting
  static int get debugProxyFailStreak => _proxyFailStreak;

  @visibleForTesting
  static void debugResetProxyWatchdogState() {
    _proxyRepairCount = 0;
    _proxyFailStreak = 0;
    _proxyCheckInFlight = false;
    systemProxyWarning.value = "";
  }

  static void _startProxyWatchdog(int port) {
    _proxyWatchdog?.cancel();
    _proxyRepairCount = 0;
    _proxyFailStreak = 0;
    systemProxyWarning.value = "";
    _proxyWatchdog = Timer.periodic(const Duration(seconds: 15), (_) async {
      if (_proxyCheckInFlight) return;
      _proxyCheckInFlight = true;
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
        // 判定同时看 ProxyEnable 与 ProxyServer（只比地址会漏掉「别的程序只关开关、
        // 值还留着」的情况 —— 真机报障就是 v2rayN 退出时把 ProxyEnable 置 0）。
        if (await getSystemProxyEnable()) {
          _proxyFailStreak = 0;
          if (systemProxyWarning.value.isNotEmpty) {
            systemProxyWarning.value = "";
          }
          return;
        }

        // 被别的程序改走/关掉了 → 立即抢回来。**不做次数熔断、不暂停**：
        // 与 MoneyFly 一致，只要 VPN 还连着就一直保证系统代理指向本机；
        // 对方程序退出后我们自然接管成功。
        _proxyRepairCount++;
        await setSystemProxy(true);
        final fixed = await getSystemProxyEnable();
        if (fixed) {
          _proxyFailStreak = 0;
          Log.w(
            "VPNService: 系统代理被改动或被关闭，已按 127.0.0.1:$expect 恢复"
            "（第 $_proxyRepairCount 次；不熔断，会一直保持）",
          );
          if (systemProxyWarning.value.isNotEmpty) {
            systemProxyWarning.value = "";
          }
        } else {
          _proxyFailStreak++;
          Log.w(
            "VPNService: 系统代理写入后仍未生效"
            "（连续第 $_proxyFailStreak 次，可能被别的代理软件覆盖；15 秒后继续重试）",
          );
          if (shouldWarnProxyConflict(_proxyFailStreak)) {
            systemProxyWarning.value =
                "系统代理正被其它代理软件占用或反复改写（如 v2rayN / Clash Verge / "
                "Nyanpasu）。Mclash 每 15 秒会自动重试并保持接管，但建议只保留一个"
                "代理软件；也可以改用 TUN 模式（设置 → TUN），TUN 不依赖系统代理。";
          }
        }
      } catch (err) {
        Log.w("VPNService: 系统代理看守异常 ${err.toString()}");
      } finally {
        _proxyCheckInFlight = false;
      }
    });
  }

  static void _stopProxyWatchdog() {
    _proxyWatchdog?.cancel();
    _proxyWatchdog = null;
    _proxyCheckInFlight = false;
    systemProxyWarning.value = "";
  }

  static Future<void> stop() {
    // 必须在入队**之前**同步置位：这样已经排在队列里的 restart 执行时会看到
    // 「用户要断开」而直接放弃，不会先连上再被这次 stop 杀掉。
    _userWantsDisconnected = true;
    return _serialOp("stop", _stopInner);
  }

  static Future<void> _stopInner() async {
    final sw = Stopwatch()..start();
    _stopProxyWatchdog();
    // 只等「内核停」。内核层已把杀进程提到最前面（毫秒级），系统代理与 TUN
    // 的收尾由它在后台完成 —— 这里再 await 一次 setSystemProxy(false) 是重复
    // 劳动：两边会并发跑同一批 networksetup，互相抢系统配置锁，把断开拖到 4 秒。
    await _quiet("停止内核", FlutterVpnService.stop());
    Log.i("[perf] 断开：内核已停 ${sw.elapsedMilliseconds} ms");

    if (Platform.isMacOS) {
      // always-on 关闭可能走特权 helper，别挡住断开的体感
      unawaited(_quiet("关闭 always-on", FlutterVpnService.setAlwaysOn(false)));
    }
    if (Platform.isWindows) {
      unawaited(uninstall());
    }
    ClashHttpApi.resetControlConnection();
    ClashHttpApi.invalidateProxiesCache();
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

  /// Windows：查询「Mclash Kernel」计划任务是否**真的就绪**。
  ///
  /// 旧实现只看 `kernel_host.vbs` 是否存在 —— 安装包先写脚本、再建任务，建任务
  /// 失败（UAC 被拒 / 任务被删）时文件检查仍为 true，App 于是走计划任务路径，
  /// `schtasks /run` 静默失败，TUN 永远起不来（0.0.5 真机确认）。
  ///
  /// 现在由 libclash_vpn_service 判断：用 `wscript.exe`（GUI 子系统）+ 隐藏窗口
  /// 查询任务本身，并校验启动脚本仍在，全程没有控制台窗口；结果带 30 秒缓存，
  /// 启动时（[_readAdminStateInBackground]）与安装任务后都会刷新。
  static Future<bool> kernelTaskExists() async {
    if (!Platform.isWindows) {
      return false;
    }
    return DesktopVpnServiceImpl.kernelTaskExists();
  }

  /// Windows：**一次性**创建最高权限计划任务（弹一次 UAC，之后 TUN 零提权）。
  ///
  /// 正规安装包会在安装结束时自动创建它；这里覆盖「老版本升级上来 / 建任务失败」
  /// 的情况，避免又退回「必须右键以管理员身份运行」。
  static Future<ReturnResultError?> installKernelTask() async {
    if (!Platform.isWindows) {
      return null;
    }
    try {
      final exeDir = File(Platform.resolvedExecutable).parent.path;
      final kernel = "$exeDir\\mihomo.exe";
      final dataDir =
          "${Platform.environment["APPDATA"]}\\mclash\\mclash";
      if (!File(kernel).existsSync()) {
        return ReturnResultError("找不到内核文件：$kernel");
      }
      String q(String v) => "'${v.replaceAll("'", "''")}'";
      // 计划任务的动作必须是一个 **GUI 子系统**的程序，否则会闪一下控制台：
      //   - powershell.exe 是控制台程序，-WindowStyle Hidden 也要先建控制台再隐藏
      //     → 用户能看到「一闪而逝」的黑框；
      //   - wscript.exe 是 GUI 程序，根本不创建控制台 → 完全没有窗口。
      // VBS 里用 Shell.Run(..., 0, True)：0 = 隐藏窗口，True = 等待内核退出。
      //
      // 安全：脚本放进**安装目录**（Program Files，只有管理员可写），不再放
      // %APPDATA%。最高权限任务执行的是普通用户随时可替换的脚本，属于本地提权
      // 边界问题。App 自己写不了 Program Files，所以下面用一次性的提权进程去写。
      final vbsPath = "$exeDir\\kernel_host.vbs";
      // VBS 里整条命令行必须是 **一个字符串**，内部引号成对转义：
      //   sh.Run (3 quotes)C:\p\mihomo.exe(2 quotes) -d (2 quotes)C:\d(2 quotes) ... , 0, True
      // 少转义会让字符串提前结束 -> cscript 语法错误（Windows VM 实测 exit=1）。
      final vbs = buildKernelHostVbs(kernelPath: kernel, dataDir: dataDir);
      // 落到用户可写目录的**临时**文件，真正的副本由下面的提权进程写进安装目录。
      final tmpVbs = "$dataDir\\kernel_host.tmp.vbs";
      try {
        await File(tmpVbs).writeAsString(vbs, flush: true);
      } catch (err) {
        return ReturnResultError("写入内核启动脚本失败：$err");
      }
      final user = Platform.environment["USERNAME"] ?? "";
      // 一次性提权进程做两件事：把脚本复制进安装目录 + 注册**无触发器**任务。
      // 用 Register-ScheduledTask：schtasks 的 /create 必须带 /SC，会凭空塞一个
      // 真实时间触发器（此前 23:59），与「只有用户点 TUN 才启动」不符。
      final installScript = [
        '\$ErrorActionPreference = "Stop"',
        'Copy-Item -LiteralPath ${q(tmpVbs)} -Destination ${q(vbsPath)} -Force',
        '\$a = New-ScheduledTaskAction -Execute "wscript.exe" -Argument '
            '(${q('"')} + ${q(vbsPath)} + ${q('"')})',
        '\$p = New-ScheduledTaskPrincipal -UserId ${q(user)} '
            '-LogonType Interactive -RunLevel Highest',
        'Register-ScheduledTask -TaskName ${q(kKernelTaskName)} '
            '-Action \$a -Principal \$p -Force | Out-Null',
      ].join("; ");
      final ps =
          "Start-Process -FilePath 'powershell' -ArgumentList "
          "@('-NoProfile','-ExecutionPolicy','Bypass','-Command',${q(installScript)}) "
          "-Verb RunAs -Wait -WindowStyle Hidden";
      final r = await Process.run("powershell", [
        "-NoProfile",
        "-NonInteractive",
        "-WindowStyle",
        "Hidden",
        "-Command",
        ps,
      ]).timeout(const Duration(seconds: 120));
      if (r.exitCode != 0) {
        return ReturnResultError(
          "安装免密提权组件失败：${r.stderr.toString().trim()}",
        );
      }
      // PowerShell 的退出码只代表「Start-Process 调用完成」：内层 schtasks 失败
      // （UAC 被拒绝、任务名冲突、被策略拦截）不会传回来，所以历史上这里会把
      // 失败当成功。**创建后必须查一次任务本身**才算数（无窗口 wscript 探测）。
      DesktopVpnServiceImpl.invalidateKernelTaskCache();
      final verified = await DesktopVpnServiceImpl.verifyKernelTaskReady();
      _kernelTaskReady = verified;
      Log.i("VPNService: 免密提权组件安装结果=$verified");
      if (!verified) {
        return ReturnResultError(
          "计划任务「$kKernelTaskName」创建后校验失败（可能是 UAC 被拒绝或任务注册失败）。"
          "TUN 将回退为每次连接弹 UAC 提权启动，可稍后重试安装。",
        );
      }
      return null;
    } catch (err) {
      return ReturnResultError(err.toString());
    }
  }

  static bool isRunAsAdmin() {
    return _runAsAdmin;
  }

  static bool tunPrerequisitesMet() {
    if (!PlatformUtils.isPC()) {
      return false;
    }
    if (Platform.isWindows && !_runAsAdmin && !_kernelTaskReady) {
      return false;
    }
    // macOS：TUN 需要 root 创建 utun / 改路由表，权限来自
    // /etc/sudoers.d/mclash-tun（由 MacTunHelper 一次性授权写入）。
    // 这里用缓存值，异步探测见 refreshTunPrerequisites()。
    if (Platform.isMacOS) {
      return _macTunGranted;
    }
    return true;
  }

  /// macOS：探测「免密 sudo 运行内核」的授权是否仍然有效。
  /// 内核路径变化（升级后落到 Application Support/kernel）会让旧规则失效，
  /// 所以每次进主页/设置页都应重新探测一次。
  static Future<bool> refreshTunPrerequisites() async {
    if (!Platform.isMacOS) {
      return true;
    }
    try {
      final corePath = await DesktopVpnServiceImpl.resolveKernelPath();
      _macTunGranted = await MacTunHelper.isGranted(corePath ?? "");
    } catch (e) {
      Log.w("VPNService: 探测 macOS TUN 授权失败: $e");
      _macTunGranted = false;
    }
    return _macTunGranted;
  }

  /// 请求提权：Windows 以管理员重启；macOS 弹一次系统密码框并写入免密规则。
  static Future<ReturnResultError?> relaunchAsAdmin() async {
    if (Platform.isMacOS) {
      try {
        final corePath = await DesktopVpnServiceImpl.resolveKernelPath();
        if (corePath == null || corePath.isEmpty) {
          return ReturnResultError("找不到内核文件，无法授权");
        }
        final ok = await MacTunHelper.grant(corePath);
        if (!ok) {
          return ReturnResultError("未获得管理员授权（已取消或密码错误）");
        }
        _macTunGranted = true;
        return null;
      } catch (err) {
        return ReturnResultError(err.toString());
      }
    }
    if (!Platform.isWindows) {
      return ReturnResultError("当前平台无需提权");
    }
    try {
      final exe = Platform.resolvedExecutable;
      final result = await Process.run("powershell", [
        "-NoProfile",
        "-WindowStyle",
        "Hidden",
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
