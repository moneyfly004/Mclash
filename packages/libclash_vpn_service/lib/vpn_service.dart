
library;

import 'dart:async';
import 'dart:io';

import 'src/desktop_impl.dart';
import 'src/models.dart';
import 'src/vpn_service_platform.dart';

typedef VpnStateChangedCallback = void Function(
  FlutterVpnServiceState state,
  Map<String, String> params,
);

class FlutterVpnService {
  FlutterVpnService._();

  static VpnServicePlatform get _p => VpnServicePlatform.instance;

  /// 注入 App 资源根目录（安装目录下的 `data`）：内核找 geo 数据时用。
  ///
  /// 平台包不能依赖上层的 PathUtils，所以由应用层在启动时注入 —— 以前 app 层直接
  /// import `src/desktop_impl.dart` 去设 `cfg0AssetsDir`（跨包 import src 是不被
  /// 推荐的写法），这里给一个公开入口。
  static void setAssetsDir(String dir) => DesktopVpnServiceImpl.cfg0AssetsDir = dir;

  static Future<FlutterVpnServiceState> get currentState async {

    return _p.state;
  }

  static void onStateChanged(VpnStateChangedCallback cb) {
    _p.addStateListener(cb);
  }

  static Future<void> prepareConfig({
    required VpnServiceConfig config,
    required String tunnelServicePath,
    required String configFilePath,
    required bool systemExtension,
    required String bundleIdentifier,
    required String controlKind,
    required String uiServerAddress,
    required String uiLocalizedDescription,
    required List<int> excludePorts,
  }) async {
    await _p.prepareConfig({
      "config": config.toJson(),
      "tunnelServicePath": tunnelServicePath,
      "configFilePath": configFilePath,
      "systemExtension": systemExtension,
      "bundleIdentifier": bundleIdentifier,
      "controlKind": controlKind,
      "uiServerAddress": uiServerAddress,
      "uiLocalizedDescription": uiLocalizedDescription,
      "excludePorts": excludePorts,
    });
  }

  static Future<VpnServiceWaitResult> start(Duration timeout) =>
      _p.start(timeout);

  static Future<VpnServiceWaitResult> restart(Duration timeout) =>
      _p.restart(timeout);

  static Future<void> stop() => _p.stop();

  static Future<VpnServiceResultError?> installService() =>
      _p.installService();

  static Future<VpnServiceResultError?> uninstallService() =>
      _p.uninstallService();

  static Future<void> setAlwaysOn(bool enable) => _p.setAlwaysOn(enable);

  /// 设置系统代理；返回是否**真的写成功**。
  ///
  /// 之前这里返回 void，把平台层的成败丢掉了：调用方只能再读回一次，
  /// 而「写失败」和「写完没生效」是两回事（Windows 上被组策略/其它代理软件
  /// 覆盖时就是后者）。把结果透出去，调用方才能给出准确提示。
  static Future<bool> setSystemProxy(ProxyOption option) =>
      _p.setSystemProxy(option);

  static Future<bool> cleanSystemProxy() => _p.cleanSystemProxy();

  static Future<bool> getSystemProxyEnable(ProxyOption option) =>
      _p.getSystemProxyEnable(option);

  static Future<String> getABIs() => _p.getABIs();

  /// 请求通知权限（Android 13+ 前台服务通知）。
  static Future<bool> requestNotificationPermission() =>
      _p.requestNotificationPermission();

  static Future<bool> isRunAsAdmin() => _p.isRunAsAdmin();

  static bool get systemProxyFallbackActive => _p.systemProxyFallbackActive;

  /// TUN 启动失败的原因（none = 没失败）。
  static TunStartFailureKind get tunFailureKind => _p.tunFailureKind;

  static Future<void> firewallAddApp(String path, String name) async {
    await _p.firewallAddApp(path, name);
  }

  static Future<void> firewallAddPorts(List<int> ports, String name) async {
    await _p.firewallAddPorts(ports, name);
  }

  static Future<bool> autoStartCreate(
    String name,
    String path, {
    String? processArgs,
    bool runElevated = false,
  }) =>
      _p.autoStartCreate(
        name,
        path,
        processArgs: processArgs,
        runElevated: runElevated,
      );

  static Future<bool> autoStartDelete(String name) => _p.autoStartDelete(name);

  static Future<bool> autoStartIsActive(String name) =>
      _p.autoStartIsActive(name);

  static Future<bool> isServiceAuthorized(String path) =>
      _p.isServiceAuthorized(path);

  static Future<VpnServiceResultError?> authorizeService(
    String path,
    String password,
  ) =>
      _p.authorizeService(path, password);

  static Future<Directory?> getAppGroupDirectory(String groupId) =>
      _p.getAppGroupDirectory(groupId);

  static Future<String> getSystemVersion() => _p.getSystemVersion();

  static Future<String?> setExcludeFromRecents(bool exclude) =>
      _p.setExcludeFromRecents(exclude);

  static Future<void> hideDockIcon(bool hide) => _p.hideDockIcon(hide);

  static Future<String> clashiApiConnections(bool all) =>
      _p.clashiApiConnections(all);

  static Future<String> clashiApiTraffic() => _p.clashiApiTraffic();

  static bool get supportSystemProxy =>
      Platform.isWindows || Platform.isMacOS;

  /// 清理孤儿内核（父进程已消失但还在运行的 mihomo），返回被杀掉的 PID。
  ///
  /// 桌面端专用：Windows 没有「父死子死」，非正常退出会留下内核继续吃端口。
  /// Android 的内核是同一个进程里的 libmihomo，不存在这种情况。
  /// [includeOwn] = true 时，除了孤儿内核，还把**不在当前跟踪中**的、
  /// 与我们同一份内核路径的 mihomo 一起收掉。
  ///
  /// 为什么需要：用户实测「点了连接连不上、重试也连不上」—— 占用控制端口的
  /// 就是上一次启动留下、父进程（App）还活着因而**不是孤儿**的内核。
  static Future<List<int>> killStaleKernels({bool includeOwn = false}) async {
    if (Platform.isAndroid) {
      return const [];
    }
    return DesktopVpnServiceImpl.killStaleKernels(includeOwn: includeOwn);
  }
}
