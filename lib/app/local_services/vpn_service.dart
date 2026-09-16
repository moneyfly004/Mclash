// ignore_for_file: unused_catch_stack, empty_catches

import 'dart:async';
import 'dart:convert';
import 'dart:io';

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
import 'package:libclash_vpn_service/proxy_manager.dart';
import 'package:libclash_vpn_service/src/desktop_impl.dart';
import 'package:libclash_vpn_service/state.dart';
import 'package:libclash_vpn_service/vpn_service.dart';
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
      // 收掉上一次**非正常退出**（任务管理器结束任务 / 崩溃 / 被强杀）留下的
      // 孤儿内核：它会继续占着混合端口与控制端口，还会让系统代理继续指向它，
      // 用户看到的就是「软件退了，内核还在跑，网还能上」，而且新实例连不上。
      // 新版内核还会被挂到 Job 上（退出即终止），这里负责清理旧版本遗留的。
      try {
        final stale = await FlutterVpnService.killStaleKernels();
        if (stale.isNotEmpty) {
          Log.w("VPNService: 已清理上一次遗留的内核进程 ${stale.join("、")}");
        }
      } catch (err) {
        Log.w("VPNService: 清理遗留内核失败 ${err.toString()}");
      }
    }
    if (Platform.isWindows) {
      _runAsAdmin = await FlutterVpnService.isRunAsAdmin();
      FlutterVpnService.firewallAddApp(
        Platform.resolvedExecutable,
        PathUtils.getExeName(),
      );
      FlutterVpnService.firewallAddApp(
        PathUtils.serviceExePath(),
        PathUtils.serviceExeName(),
      );
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
      if (getSupportSystemProxy()) {
        if (state == FlutterVpnServiceState.disconnected) {
          bool enable = await getSystemProxyEnable();
          if (enable) {
            await FlutterVpnService.cleanSystemProxy();
          }
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

    if (Platform.isWindows) {
      await stop();
    }
  }

  static Future<void> uninit() async {
    if (PlatformUtils.isPC()) {
      await stop();
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
    final controlPort = ClashSettingManager.getControlPort();

    bool overwriteFinal =
        patch.id.isEmpty ||
        patch.id == kProfilePatchBuildinOverwrite ||
        patch.appendPatchBuildin == kProfilePatchBuildinOverwrite;
    await ClashSettingManager.saveCorePatchFinal(
      profile.id,
      overwriteFinal,
      profile.overwriteRules
          ? (profile.overwriteProxyGroups
                ? profile.rulesForProxyGroups
                : profile.rules)
          : null,
      profile.overwriteProxyGroups ? profile.proxyGroups : null,
      // `appendRules`：此前只有 iOS 的 Apple 推送分流会往这里塞规则，
      // 随 iOS 支持一起删除；参数保留是因为内核侧 `extension.append-rules`
      // 是一项通用能力（见 ClashSettingManager.getPatchContent）。
      null,
    );

    var excludePorts = [controlPort];
    excludePorts.add(ClashSettingManager.getMixedPort());

    String name = AppUtils.getName();
    String vpnName = name;
    String configFilePath = await PathUtils.serviceConfigFilePath();
    String installReferrer = await InstallReferrerUtils.getString();

    VpnServiceConfig config = VpnServiceConfig();
    config.control_port = controlPort;
    config.base_dir = await PathUtils.profileDir();
    // 内核工作目录必须可写（Windows 装到 Program Files 时不可写 → 连接直接失败）
    config.work_dir = await PathUtils.serviceWorkDir();
    // geo 数据必须落在内核工作目录里：缺了 mihomo 会去 GitHub 下载（国内不可达 →
    // 内核永不就绪）。桌面端资源在安装目录，安卓端资源在 APK 里 —— 后者必须先解出来。
    final missingGeo = await _ensureGeoDataOnDisk(config.work_dir);
    _lastWorkDir = config.work_dir;
    _lastMissingGeo = missingGeo;
    // geo 数据（country.mmdb / geosite.dat / ASN）仍在**安装目录**里，把它注册为
    // 查找来源；否则换了工作目录后 geo 会"找不到"，内核转去 GitHub 下载（不可达 → 卡死）。
    DesktopVpnServiceImpl.cfg0AssetsDir = PathUtils.appAssetsDir();
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
    // Android：是否把 IPv6 流量也纳入隧道（用户在「核心设置」里开的 ipv6）。
    // 不开就完全维持历史行为（只路由 IPv4）；开了才给 TUN 加 IPv6 地址/DNS/路由。
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
    FlutterVpnService.prepareConfig(
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

  /// 最近一次准备阶段的关键诊断信息（连接失败时一并打印）。
  static String _lastWorkDir = "";
  static List<String> _lastMissingGeo = const [];

  /// 连接操作的串行闸门。
  ///
  /// 为什么需要：`start` / `stop` / `restart` 之间存在真实竞态 ——
  ///   * 用户连点开关（或托盘菜单 + 界面同时触发）→ 两个 start 并发，
  ///     桌面端会争抢同一个工作目录/端口，安卓端会把刚起的内核又停掉重启；
  ///   * 切模式触发的 restart 与正在进行的连接交叉（切模式写 PATCH 的同时
  ///     内核正在启动）；
  ///   * 断开与连接交叉 → 出现「显示已连接但内核不在跑」的幽灵状态。
  /// 这里让三者互斥执行，并在被串行化时留日志（便于排查"点了两下"这类现象）。
  static Future<void> _opLock = Future<void>.value();
  static String _opHolder = "";

  static Future<T> _serialOp<T>(String name, Future<T> Function() action) {
    final prev = _opLock;
    final gate = Completer<void>();
    _opLock = gate.future;
    return prev.then((_) async {
      final waited = _opHolder.isNotEmpty;
      if (waited) {
        Log.i("VPNService: $name 等待前一个操作(${_opHolder})完成");
      }
      _opHolder = name;
      try {
        return await action();
      } finally {
        _opHolder = "";
        gate.complete();
      }
    });
  }

  static Future<ReturnResultError?> restart(Duration timeout) =>
      _serialOp("restart", () => _restartInner(timeout));

  static Future<ReturnResultError?> _restartInner(Duration timeout) async {
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
    final enable = await getSystemProxyEnable();
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

    if (enable) {
      await setSystemProxy(true);
    }
    return null;
  }

  static Future<ReturnResultError?> start(Duration timeout) =>
      _serialOp("start", () => _startInner(timeout));

  static Future<ReturnResultError?> _startInner(Duration timeout) async {
    final profile = ProfileManager.getCurrent();
    if (profile == null) {
      return ReturnResultError("current profile is empty");
    }
    // 安卓：**必须先拿到系统 VPN 授权**（`VpnService.prepare` 弹窗）。
    // 旧代码从不请求授权 → Builder.establish()
    // 拿不到 fd → 内核起不来，而错误只说"未获得文件描述符"，用户完全不知道要授权。
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
      // 通知权限（Android 13+）：前台服务通知需要它，否则连上看不到状态通知
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
    try {
      bool reinstall = await _prepareConfig(profile);
      if (reinstall) {
        await uninstall();
      }
    } catch (err, stacktrace) {
      return ReturnResultError(err.toString());
    }
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
      // 兜底：内核启动过程中的任何异常都要变成用户看得见的错误，
      // 不能以「Unhandled Exception + 界面毫无反应」收场（Windows 上真实发生过）。
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

    if (PlatformUtils.isPC() && !setting.autoSetSystemProxy) {
      // 用户明确关掉了「连接后自动设置系统代理」→ 尊重它，不再每次连接都覆盖
      // 系统代理（以前是无条件覆盖，用户会感觉「这设置改不动 / 我的代理总被改掉」）。
      // 但 TUN 需要管理员权限；真降级时仍由内核侧的兜底逻辑补上系统代理，
      // 保证「关掉开关」不会变成「连上了却完全没网」。
      Log.i("VPNService: 已关闭「连接后自动设置系统代理」，跳过自动设置（可在应用设置→系统代理手动设置）");
    } else if (PlatformUtils.isPC()) {
      // 顺序很关键：**先问内核它到底监听哪个端口**，再据此设系统代理。
      // 旧实现在 start() 里既不修端口也不问内核，直接拿设置里的值去设：
      // 配置里 mixed-port 为 0（或被别的软件占用、内核自动换端口）时，
      // 系统代理要么被跳过（Windows 代理设置页一片空白）、要么指向没人监听的
      // 端口 —— 用户侧的现象就是「连上了，系统代理是空白，也改不动」。
      var port = await syncMixedPortFromKernel();
      if (port <= 0) {
        await _ensureMixedPortAvailable();
        port = await syncMixedPortFromKernel();
      }
      if (port > 0) {
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

    // 记下「内核现在跑的是这份订阅内容」——订阅更新后据此判断要不要重连，
    // 否则内核会一直用旧节点列表/旧凭据跑（切节点报"节点不存在"、连上没流量）。
    unawaited(MclashSubscriptionRevision.markRunning());
    return null;
  }

  /// 决定系统代理该用哪个端口（纯函数，便于回归测试）。
  ///
  /// 内核在配置里的 mixed-port 为 0 或被占用时**会自己改用一个空闲端口**，
  /// 而应用侧仍记着旧值。若照着旧值去设系统代理，表现就是：
  ///   「连上了，但系统代理是空白 / 指向一个没人监听的端口」。
  /// 规则：内核报了什么就用什么（它是事实），拿不到才退回设置值。
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

  /// 把内核**真实监听**的混合端口同步回设置，并返回该端口（0 = 仍然未知）。
  ///
  /// 必须在设置系统代理**之前**调用：这是 Windows/macOS 上「系统代理空白」
  /// 的直接修复点。
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
      // 内核没起来或没监听任何入站：这时设置系统代理是没有意义的，
      // 必须明确说出来，而不是静默跳过（用户看到的就是「代理是空白」）。
      Log.w("VPNService: 拿不到有效的混合端口（内核 $kernelPort / 设置 $configured），跳过系统代理设置");
    }
    return port;
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

  static Timer? _proxyWatchdog;

  static void _startProxyWatchdog(int port) {
    _proxyWatchdog?.cancel();
    _proxyWatchdog = Timer.periodic(const Duration(seconds: 15), (_) async {
      try {
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
    _stopProxyWatchdog();
    if (Platform.isMacOS) {
      await FlutterVpnService.setAlwaysOn(false);
    }
    await setSystemProxy(false);
    await FlutterVpnService.stop();

    if (Platform.isWindows) {
      await uninstall();
    }
  }

  static bool getSupportSystemProxy() {
    return PlatformUtils.isPC();
  }

  /// TUN 是否**没能**起来（此时数据通路是系统代理）。
  ///
  /// 首页用它判断并展示「当前到底怎么被代理的」：TUN 正常时不需要系统代理，
  /// 系统里的代理设置保持原样是正常的。
  static bool get systemProxyFallbackActive =>
      FlutterVpnService.systemProxyFallbackActive;

  /// 系统代理固定写入的本机回环地址（Windows/macOS 都不用局域网 IP：
  /// 用局域 IP 时本机应用反而绕不过去，而且会随网卡变化而失效）。
  static String get systemProxyHost => localhost;

  static Future<void> setSystemProxy(bool enable) async {
    if (getSupportSystemProxy()) {
      try {
        final options = await getSystemProxyOptions();
        if (options.port == 0) {
          return;
        }
        if (enable) {
          await FlutterVpnService.setSystemProxy(await getSystemProxyOptions());
        } else {
          if (await getSystemProxyEnable()) {
            await FlutterVpnService.cleanSystemProxy();
          }
        }
      } catch (err) {
        Log.w("VPNService setSystemProxy exception:${err.toString()}");
      }
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

  static Future<ProxyOption?> getSystemProxyOptionsLan() async {
    if (!PlatformUtils.isPC()) {
      return null;
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

    return ProxyOption(
      host,
      ClashSettingManager.getMixedPort(),
      SettingManager.getConfig().systemProxyBypassDomain,
    );
  }

  static Future<ProxyOption> getSystemProxyOptions() async {
    final bypassDomain = SettingManager.getConfig().systemProxyBypassDomain;
    final mixedPort = ClashSettingManager.getMixedPort();

    return ProxyOption(localhost, mixedPort, bypassDomain);
  }

  /// 确保内核工作目录里存在 geo 数据（country.mmdb / geosite.dat / GeoLite2-ASN.mmdb）。
  ///
  /// 桌面端这些文件随安装包落在磁盘上（`assets/rules/`），Android 端它们**在 APK 里**，
  /// 磁盘上只有 app 启动时写出的 zip（`ClashSettingManager.initGeo` 写的是 zip，
  /// 而内核要的是解开的 `.dat/.mmdb`）。缺文件时 mihomo 会尝试从 GitHub 下载，
  /// 国内不可达 → 卡住几十秒后失败，用户看到的就是「核心起不来 / 连不上」。
  ///
  /// 这里直接从 asset bundle 把内核需要的三个文件写到工作目录（幂等：已存在且非空就跳过），
  /// 并把「拷了什么 / 缺了什么」写进日志，保证出问题时日志能明确列出来。
  static Future<List<String>> _ensureGeoDataOnDisk(String workDir) async {
    if (workDir.isEmpty) {
      return const [];
    }
    // 顺序与 geo_data.dart 的候选名一致（ASN 允许两个文件名）
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
          // 换下一个候选资源名
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
      // 明确列出来：这是「内核卡在下载 geo」的直接原因
      Log.w("VPNService: geo 数据缺失 ${missing.join(", ")}（内核可能尝试联网下载而卡住）");
    } else {
      Log.i("VPNService: geo 数据齐全（country.mmdb / geosite.dat / GeoLite2-ASN.mmdb）");
    }
    return missing;
  }

  /// 连接失败时一次性列出关键诊断（用户要求：有问题日志能明确列出来）。
  ///
  /// 覆盖安卓/桌面最常见的几类失败：VPN 未授权、配置为空、geo 缺失、
  /// 端口被占用、内核未就绪。逐条打印，避免"只知道失败、不知道为什么"。
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
