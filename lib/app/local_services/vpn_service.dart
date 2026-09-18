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
      // 收掉上一次**非正常退出**（任务管理器结束任务 / 崩溃 / 被强杀）留下的
      // 孤儿内核：它会继续占着混合端口与控制端口，还会让系统代理继续指向它，
      // 用户看到的就是「软件退了，内核还在跑，网还能上」，而且新实例连不上。
      // 新版内核还会被挂到 Job 上（退出即终止），这里负责清理旧版本遗留的。
      //
      // ⚠️ 这一步在 Windows 上要起一次 PowerShell（冷启动实测 1~3 秒），以前是
      // `await` 的 —— 启动流程（含首屏）就白白等它。现在放后台：
      //   * 安全性由扫描自身的规则保证：只杀「与本次使用同一内核路径、且不在本次
      //     跟踪中」的进程（keepPid），不会误伤马上要启动的内核；
      //   * 端口真被占用时，连接前还会**强制**再扫一次（见 _prepareConfig）。
      unawaited(_scanStaleKernelsInBackground());
    }
    if (Platform.isWindows) {
      // 是否管理员同样放在后台：`net session` 是几百毫秒的进程调用，而它只用于
      // 「TUN 需要管理员权限」这类提示的判定，不需要挡住启动。
      unawaited(_readAdminStateInBackground());
      // 防火墙规则**改到后台预热**，不再占着启动路径，也不占点击路径。
      //
      // 以前这里是 `await firewallAddApp` ×2（每次 netsh 都要起一个进程，实测
      // 几百毫秒），而放行端口那两条（`firewallAddPorts`）更是落在**用户点击连接**
      // 的路上 —— 「点了连接半天没反应」的空窗里就有它们。现在统一在启动后空闲时
      // 预热一次，插件按规则参数缓存，点击时直接命中缓存（近似 0 成本）。
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
        // 断开后把系统代理还原（插件侧按「归属」决定动不动，见 restoreSystemProxy）。
        //
        // 以前这里先判断 `getSystemProxyEnable()`——那是「注册表里的 ProxyServer
        // 是不是 127.0.0.1:<我们设置里的端口>」。默认端口 7890 与别的客户端撞车，
        // 于是 Mclash 一断开就可能把**别人正在用的**系统代理清掉（用户实测的
        // 跨软件事故）。判据下沉到插件后，先问「这份代理是不是我们写的」，
        // 不是就一行都不碰。
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

    // 启动收尾：把「上次没还原干净的系统代理」恢复原状，并确认内核已停。
    //
    // 为什么必须在这里做（而不是留给调用方）：上次崩溃/被强杀时，系统代理可能
    // 还指着本机内核端口 —— 那台电脑此时**完全上不了网**（代理指向没人监听的端口）。
    // 启动时兜一次，只有「确实是我们写的」才还原（判据在插件侧，见
    // _systemProxyOwnership）。
    //
    // ⚠️ 这里以前只对 Windows 做（`if (Platform.isWindows) await stop();`），
    // 而 Biz 里又有一个「启动清理系统代理」（restoreSystemProxy），两者是同一次
    // 清理的两次调用 —— 日志里能直接看到连着两行「清理系统代理已跳过」。
    // 现在合并成一次：stop() 内部本来就会走系统代理清理。
    if (PlatformUtils.isPC()) {
      await stop();
    }
  }

  static Future<void> uninit() async {
    if (PlatformUtils.isPC()) {
      await stop();
    }
  }

  /// 后台扫描「上一次异常退出留下的内核」，并把结果写进日志。
  ///
  /// 见 init() 里的说明：这一步在 Windows 上是 1~3 秒的 PowerShell 冷启动，
  /// 不该挡住启动与首屏。
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

  /// 后台读一次「当前是否以管理员运行」（`net session` 是几百毫秒的进程调用）。
  static Future<void> _readAdminStateInBackground() async {
    try {
      final admin = await FlutterVpnService.isRunAsAdmin();
      _runAsAdmin = admin;
      Log.i("VPNService: 管理员权限=${admin ? "是" : "否"}");
    } catch (err) {
      Log.w("VPNService: 读取管理员状态失败 ${err.toString()}");
    }
  }

  /// 预热 Windows 防火墙规则（应用本体 + 内核 + 两个端口）。
  ///
  /// 为什么放到后台：`netsh advfirewall firewall add rule` 每次都要起一个进程
  /// （实测几百毫秒，首次更慢）。以前「放行端口」这一条就在用户点击连接的路上
  /// （`_startInner` → `firewallAddPorts`），点击到界面出现「正在连接…」之间的
  /// 空窗里有它一份。启动后空闲时先放行，点击时命中插件里的缓存直接返回。
  ///
  /// 失败不影响任何功能（只是没有防火墙例外），所以只记日志。
  static Future<void> _prewarmFirewallRules() async {
    try {
      // 先让窗口与首页把首帧画出来，别和启动抢时间
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

    // 起内核之前先清场：**同一份内核路径**上还在跑的旧进程会占着控制端口与混合
    // 端口，让新内核 bind 失败（用户实测：控制端口 9090 被占 → 连接直接失败，
    // 而且重试一次也失败，因为占用者就是上一次留下的内核）。
    //
    // ⚠️ 这里以前**每次连接**都无条件扫一遍：Windows 上那是起一次 PowerShell
    // （冷启动实测 1~3 秒），是「连接时卡顿」的大头。现在只在**端口真的被占用**
    // 时才强制扫描（占用者十有八九就是残留内核）；平时用启动时那一次扫描的结果
    // （新内核被挂在「退出即终止」的 Job 上，不会再产生新孤儿）。
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
    // 两个端口都要可用：混合端口（入站）与控制端口（Clash API）
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
      // `appendRules`：此前只有 iOS 的 Apple 推送分流会往这里塞规则，
      // 随 iOS 支持一起删除；参数保留是因为内核侧 `extension.append-rules`
      // 是一项通用能力（见 ClashSettingManager.getPatchContent）。
      null,
    );
    // 这段是纯 CPU（规则展开 + JSON 编码几百 KB）且跑在主 isolate 上，单独打点：
    // 若日志里它很大，就该像内核配置生成那样挪到后台 isolate。
    Log.i("[perf] 连接：生成内核补丁用时 ${swPatch.elapsedMilliseconds} ms");

    var excludePorts = [controlPort];
    excludePorts.add(ClashSettingManager.getMixedPort());

    String name = AppUtils.getName();
    String vpnName = name;
    String configFilePath = await PathUtils.serviceConfigFilePath();
    String installReferrer = await InstallReferrerUtils.getString();

    VpnServiceConfig config = VpnServiceConfig();
    // 告诉内核侧本次是否用 TUN：退出前要先把 TUN 拆掉（撤销路由、卸载虚拟网卡），
    // 否则 Windows 上强杀内核会在系统里留下 TUN 的路由，退出后直接断网。
    config.tun_enabled = ClashSettingManager.tunEnabledByUser();
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
        Log.i("VPNService: $name 等待前一个操作($_opHolder)完成");
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
    // ⚠️ 这里**不能**用「重启前读到的系统代理状态」来决定重启后要不要设置。
    //
    // `FlutterVpnService.restart` 内部是先 stop 再 start，而 stop 会把系统代理
    // 撤掉（并把归属标记一起删掉）。旧代码是
    //     final enable = await getSystemProxyEnable();   // 重启前
    //     ...restart...
    //     if (enable && shouldApplySystemProxy()) setSystemProxy(true);
    // 于是只要重启前的那次读值不是「指向我们当前端口」（用户手动关过、端口被换过、
    // 或者本来就没设过），重启之后就**再也不会设置系统代理** —— 用户看到的就是
    // 「切了模式 / 切了节点 / 自动同步订阅之后，系统代理变空白了」。
    // 正确的判据只有一个：当前设置是否要求系统代理（shouldApplySystemProxy），
    // 端口则问内核（它才知道自己监听哪个）。
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

    // 重启后**按当前设置重新写一次**系统代理（理由见上面 wantProxy 的注释）。
    // 端口以内核实际监听为准 —— 重启有可能换端口，写错端口等于把流量发给空气。
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
    // 内核要重启了：控制接口的连接池与 /proxies 缓存都指向即将消失的进程，
    // 先丢掉，避免之后拿到「已关闭的连接」或过期节点表（虽然传输层有重试兜底，
    // 但那要多付一次失败往返）。
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
    // 打点：这一段是「点击连接之后、内核还没开始启动」的部分（端口探测、
    // 规则/补丁落盘、geo 数据检查、防火墙放行）——「点了半天没反应」时先看它。
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

    if (PlatformUtils.isPC() && !shouldApplySystemProxy()) {
      // 跳过是**有理由的**，必须写清楚：用户看到的「连上了系统代理是空的」
      // 十有八九就是这里的某一条（以前只记一条笼统日志，排查全靠猜）。
      Log.w("VPNService: 未设置系统代理 —— ${systemProxySkipReason()}");
      if (PlatformUtils.isPC() && SettingManager.getConfig().tunEnabled) {
        // TUN 起不来时不能让用户「既没 TUN 又没代理」：内核侧兜底会写系统代理，
        // 这里再补一道，并把结果如实记下来。
        if (VPNService.systemProxyFallbackActive) {
          Log.w("VPNService: TUN 未生效，已由兜底逻辑改用系统代理");
        }
      }
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

  /// 控制端口（Clash API）也必须可用。
  ///
  /// 真实案例（用户机器实测）：另一款代理客户端的内核占着 127.0.0.1:9090，
  /// 我们的内核日志只有一行
  /// `External controller listen error: listen tcp 127.0.0.1:9090: bind: address already in use`，
  /// 随后就绪检测一直等控制 API → 超时 → 界面报「本地代理端口被占用」。
  /// 混合端口早就会自动换端口，控制端口却一直是写死的 9090 —— 这里补齐。
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

  /// 端口是否可用。
  ///
  /// **必须连通配地址一起测**：内核的入站监听绑的是 `*:port`，只测回环会出现
  /// 「回环绑得上、实际端口已被别人占用」的误判（真实事故，见 kernel_config.dart）。
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

  /// 系统代理看守。
  ///
  /// 存在的意义：连上之后代理可能被别的程序（或用户手贱）改掉，用户就断网了 ——
  /// 这里定期确认「该开的时候它开着」，被改掉就按内核实际端口补一次。
  ///
  /// ⚠️ 必须让开「正在断开 / 正在连接」的窗口，否则它会和清理/写入互相覆盖：
  /// 用户点断开 → 清理撤掉代理 → 看守醒来发现「该开却没开」→ 又写回去，
  /// 结果「关了但代理还在」。判据不能只看设置（设置在整个断开过程中都没变）。
  static void _startProxyWatchdog(int port) {
    _proxyWatchdog?.cancel();
    _proxyWatchdog = Timer.periodic(const Duration(seconds: 15), (_) async {
      try {
        // TUN 打开但**没起来**（内核侧已回退到系统代理）时，代理必须继续维持住，
        // 否则 TUN 死掉 + 代理被清理 = 用户彻底没网。
        if (!shouldApplySystemProxy() && !systemProxyFallbackActive) {
          return;
        }
        // 已经断开/正在断开：看守的任务结束了。
        //
        // 为什么这条不能省：守看是在**用户点击断开之前**就排好的定时器，
        // `_stopProxyWatchdog()` 与清理存在竞争窗口；而断开过程中
        // `shouldApplySystemProxy()` 始终为 true，只看它会得出「该开却没开
        // → 补一次」的结论，把刚撤掉的代理又写回去。
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

  /// 停掉看守（断开时调用，见 [_startProxyWatchdog] 的说明）。
  static void _stopProxyWatchdog() {
    _proxyWatchdog?.cancel();
    _proxyWatchdog = null;
  }

  static Future<void> stop() => _serialOp("stop", _stopInner);

  /// 断开：把互不依赖的两件事**并行**做。
  ///
  /// 为什么（用户实测：「关闭的时候点击半天才有反应」）：旧实现是串行的
  ///   1) 撤系统代理（Windows：注册表 4 次 + 官方 API + 两次广播；macOS：逐网络
  ///      服务跑 networksetup）
  ///   2) 让内核停下来（先 PATCH 让内核自己拆 TUN，再 taskkill 并等进程退出）
  /// 两段本来没有先后依赖，却要一段一段等 —— 总时长是**相加**。
  /// 现在并行发起，总时长取两者最大值。
  static Future<void> _stopInner() async {
    final sw = Stopwatch()..start();
    _stopProxyWatchdog();
    final tasks = <Future<void>>[
      _quiet("撤系统代理", setSystemProxy(false)),
      _quiet("停止内核", FlutterVpnService.stop()),
    ];
    if (Platform.isMacOS) {
      // 与上面两步独立：只是让系统助手不再 always-on
      tasks.add(_quiet("关闭 always-on", FlutterVpnService.setAlwaysOn(false)));
    }
    await Future.wait(tasks);
    if (Platform.isWindows) {
      await uninstall();
    }
    // 内核已停：连接池里的连接全部失效，节点表也不再可信。
    ClashHttpApi.resetControlConnection();
    ClashHttpApi.invalidateProxiesCache();
    Log.i("[perf] 断开：撤系统代理 + 停内核用时 ${sw.elapsedMilliseconds} ms");
  }

  /// 跑一步「失败也不该拖垮断开」的子任务：异常只记日志。
  static Future<void> _quiet(String what, Future<void> f) async {
    try {
      await f;
    } catch (err) {
      Log.w("VPNService: 断开步骤「$what」失败（忽略）${err.toString()}");
    }
  }

  /// 测试缝：强制「支持系统代理」的判定。
  ///
  /// 为什么需要：CI 跑在 Linux 上，而 Linux 不是产品平台（isPC 只认
  /// Windows/macOS）。如果断言跟着宿主平台走，测试就会「本地绿、CI 红」——
  /// 这个坑已经让安卓构建失败过两次。给出替换口之后，两条路径都能确定性覆盖。
  @visibleForTesting
  static bool? debugSupportSystemProxyOverride;

  static bool getSupportSystemProxy() {
    final override = debugSupportSystemProxyOverride;
    if (override != null) {
      return override;
    }
    return PlatformUtils.isPC();
  }

  /// 是否应该由我们**主动**去写系统代理（**唯一判定点**）。
  ///
  /// 三件事必须一起看，缺一个就会出现用户报过的现象：
  ///   * 平台：只有桌面端有「系统代理」这件事；
  ///   * TUN 开关：打开时数据通路是虚拟网卡，再改系统代理等于两套机制同时生效
  ///     （用户反馈的「系统代理和 tun 同时生效」）；
  ///   * 应用设置里的「连接后自动设置系统代理」：用户显式关掉时要尊重
  ///     —— **但**旧版本在桌面端默认 false、用户从没关过，于是升级后
  ///     「连上了系统代理一直是空的」（用户反馈：「无论规则还是全局，
  ///     电脑的系统代理都没有配置」）。老默认值现在由
  ///     [SettingConfig._migrate] 一次性纠正，这里只管用户真正的选择。
  static bool shouldApplySystemProxy() {
    if (!getSupportSystemProxy()) {
      return false;
    }
    if (Platform.isAndroid) {
      return false;
    }
    final setting = SettingManager.getConfig();
    // 「强制」= 只走 TUN，不再动系统代理；「关闭 / 自动」都保留系统代理
    // （自动 = 双保险：TUN 万一没起来，系统代理还在，用户不会断网）。
    if (setting.tunOnly) {
      return false;
    }
    return setting.autoSetSystemProxy;
  }

  /// 为什么没有写系统代理（给界面/日志用，避免用户只看到「没生效」）。
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

  /// 退出/清理时把系统代理恢复原状。
  ///
  /// 与 [setSystemProxy] 的区别：这里**不看**当前混合端口是否取得到 ——
  /// 端口读不到（内核已停、设置被重置）恰恰是"退出后代理还留着"的常见场景。
  ///
  /// ⚠️ 也**不再**用「注册表里是不是 `127.0.0.1:<我们的端口>`」当归属判据：
  /// Mclash 的默认端口是 7890，而 MoneyFly / Clash Party / Clash Verge 的默认端口
  /// 也都在 7890 一带 —— 用端口判断「这是我们上次留下的残留」，就会**把别的客户端
  /// 正在用的系统代理清掉**（用户实测：用了 Mclash 之后，MoneyFly 连上了、
  /// Windows 里却不显示 127.0.0.1 和端口了）。
  /// 归属判定现在只在插件侧做一次（注册表里的归属标记 + 端口是否还有人监听），
  /// 不是我们写的就一行都不碰，并把原因写进日志与诊断报告。
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

  /// TUN 是否**没能**起来（此时数据通路是系统代理）。
  ///
  /// 首页用它判断并展示「当前到底怎么被代理的」：TUN 正常时不需要系统代理，
  /// 系统里的代理设置保持原样是正常的。
  static bool get systemProxyFallbackActive =>
      FlutterVpnService.systemProxyFallbackActive;

  /// TUN 启动失败的原因（none = 没失败）。
  ///
  /// 首页状态行/连接自检用它给出**具体**原因（权限 / 网卡残留 / 驱动被拦），
  /// 而不是一句万能的「请以管理员身份运行」。
  static TunStartFailureKind get tunFailureKind =>
      FlutterVpnService.tunFailureKind;

  /// 系统代理固定写入的本机回环地址（Windows/macOS 都不用局域网 IP：
  /// 用局域 IP 时本机应用反而绕不过去，而且会随网卡变化而失效）。
  static String get systemProxyHost => localhost;

  static Future<void> setSystemProxy(bool enable) async {
    if (!getSupportSystemProxy()) {
      return;
    }
    try {
      if (!enable) {
        // 关闭时**不**依赖混合端口：端口读不到（内核已停/设置被重置）时
        // 旧实现直接 return，于是系统代理留在系统里 —— 用户退出软件后
        // 浏览器全部打不开，就是这个。只要系统代理是我们的，就还原掉。
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

  /// TUN 是否具备必要条件（Windows 需要管理员权限才能建 wintun 网卡）。
  ///
  /// 没有权限时不是「静默失败」：内核侧会把系统代理指过来兜底；
  /// 这里给界面一个明确的判断，好把「以管理员身份重启」这条路摆出来。
  static bool tunPrerequisitesMet() {
    if (!PlatformUtils.isPC()) {
      return false;
    }
    if (Platform.isWindows && !_runAsAdmin) {
      return false;
    }
    return true;
  }

  /// 以管理员身份重新启动本应用（Windows 专用；会弹 UAC）。
  ///
  /// 为什么需要：mihomo 建 wintun 虚拟网卡必须有管理员权限 —— 没权限时
  /// 用户「开了 TUN」只会看到什么都没发生（没有虚拟网卡），这正是用户反馈的
  /// 「开启 tun 模式也没有建立虚拟网卡」。与其让他自己去找「以管理员身份运行」，
  /// 不如在开关上直接给一条路。
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

  /// LAN 兜底读回的缓存（TTL 内复用）。
  ///
  /// 为什么需要：`getSystemProxyEnable()` 在「本地回环那份不匹配」时才会走这里
  /// （TUN 接管、没设系统代理时**每次**都会走），而它要枚举一次网卡
  /// （`NetworkInterface.list()`，Windows 上是一次真实的适配器查询，几十到几百 ms）。
  /// 首页的代理状态轮询 + 15 秒一次的系统代理看守都会调它 —— 不缓存的话，
  /// 一台开着 TUN 的机器每 15 秒就要白枚举两次网卡，正是「用着用着卡一下」的来源。
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
