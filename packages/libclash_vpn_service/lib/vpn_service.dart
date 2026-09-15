/// `FlutterVpnService` —— Mclash 的 VPN 服务门面（drop-in 替代原 Clash Mi 的同名插件）。
///
/// 调用方（`lib/app/local_services/vpn_service.dart` 等 20 处）**无需改动**：
/// 方法签名、参数名、返回类型与错误语义全部保持一致。
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

  // ======================================================================
  // 状态
  // ======================================================================
  static Future<FlutterVpnServiceState> get currentState async {
    // 桌面端每次读实时状态；Android 端状态由原生侧主动推送，
    // 这里回读一次以防进程重启后缓存过期。
    return _p.state;
  }

  static void onStateChanged(VpnStateChangedCallback cb) {
    _p.addStateListener(cb);
  }

  // ======================================================================
  // 配置
  // ======================================================================
  /// 准备配置。参数名与原插件一致（调用方用命名参数）。
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

  // ======================================================================
  // 启停
  // ======================================================================
  static Future<VpnServiceWaitResult> start(Duration timeout) =>
      _p.start(timeout);

  static Future<VpnServiceWaitResult> restart(Duration timeout) =>
      _p.restart(timeout);

  static Future<void> stop() => _p.stop();

  // ======================================================================
  // 服务安装（桌面端为空操作；Android 端走 VpnService 授权）
  // ======================================================================
  static Future<VpnServiceResultError?> installService() =>
      _p.installService();

  static Future<VpnServiceResultError?> uninstallService() =>
      _p.uninstallService();

  static Future<void> setAlwaysOn(bool enable) => _p.setAlwaysOn(enable);

  // ======================================================================
  // 系统代理
  // ======================================================================
  static Future<void> setSystemProxy(ProxyOption option) async {
    await _p.setSystemProxy(option);
  }

  static Future<void> cleanSystemProxy() async {
    await _p.cleanSystemProxy();
  }

  static Future<bool> getSystemProxyEnable(ProxyOption option) =>
      _p.getSystemProxyEnable(option);

  // ======================================================================
  // 平台能力
  // ======================================================================
  static Future<String> getABIs() => _p.getABIs();

  static Future<bool> isRunAsAdmin() => _p.isRunAsAdmin();

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

  // ======================================================================
  // Clash API 直读（供面板/首页取连接与流量）
  // ======================================================================
  static Future<String> clashiApiConnections(bool all) =>
      _p.clashiApiConnections(all);

  static Future<String> clashiApiTraffic() => _p.clashiApiTraffic();

  // ======================================================================
  // 便捷工具
  // ======================================================================

  /// 当前平台是否支持系统代理（仅 PC）
  static bool get supportSystemProxy =>
      Platform.isWindows || Platform.isMacOS || Platform.isLinux;
}
