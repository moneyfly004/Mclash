
library;

import 'dart:async';
import 'dart:io';

import 'src/models.dart';
import 'src/vpn_service_platform.dart';

typedef VpnStateChangedCallback = void Function(
  FlutterVpnServiceState state,
  Map<String, String> params,
);

class FlutterVpnService {
  FlutterVpnService._();

  static VpnServicePlatform get _p => VpnServicePlatform.instance;

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
      Platform.isWindows || Platform.isMacOS || Platform.isLinux;
}
