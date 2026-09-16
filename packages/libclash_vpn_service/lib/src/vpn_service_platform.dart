import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'android_impl.dart';
import 'desktop_impl.dart';
import 'models.dart';

abstract class VpnServicePlatform {
  static VpnServicePlatform? _instance;

  static VpnServicePlatform get instance =>
      _instance ??= _createDefault();

  static set instance(VpnServicePlatform v) => _instance = v;

  static VpnServicePlatform _createDefault() {

    return Platform.isAndroid
        ? AndroidVpnServicePlatform()
        : DesktopVpnServiceImpl();
  }

  final List<void Function(FlutterVpnServiceState, Map<String, String>)>
      _stateListeners = [];

  void emitStateChanged(FlutterVpnServiceState s, Map<String, String> params) {
    for (final cb in List.of(_stateListeners)) {
      try {
        cb(s, params);
      } catch (_) {}
    }
  }

  void addStateListener(
    void Function(FlutterVpnServiceState, Map<String, String>) cb,
  ) {
    if (!_stateListeners.contains(cb)) {
      _stateListeners.add(cb);
    }
  }

  FlutterVpnServiceState get state;

  Future<VpnServiceResultError?> prepareConfig(Map<String, dynamic> args);

  Future<VpnServiceWaitResult> start(Duration timeout);

  Future<VpnServiceWaitResult> restart(Duration timeout);

  Future<void> stop();

  Future<VpnServiceResultError?> installService();

  Future<VpnServiceResultError?> uninstallService();

  Future<void> setAlwaysOn(bool enable);

  Future<bool> setSystemProxy(ProxyOption option);

  Future<bool> cleanSystemProxy();

  Future<bool> getSystemProxyEnable(ProxyOption option);

  Future<bool> isRunAsAdmin();

  Future<bool> firewallAddApp(String path, String name);

  Future<bool> firewallAddPorts(List<int> ports, String name);

  Future<bool> autoStartCreate(
    String name,
    String path, {
    String? processArgs,
    bool runElevated = false,
  });

  Future<bool> autoStartDelete(String name);

  Future<bool> autoStartIsActive(String name);

  Future<bool> isServiceAuthorized(String path);

  Future<VpnServiceResultError?> authorizeService(String path, String password);

  Future<Directory?> getAppGroupDirectory(String groupId);

  Future<String> getSystemVersion();

  Future<String?> setExcludeFromRecents(bool exclude);

  Future<void> hideDockIcon(bool hide);

  bool get systemProxyFallbackActive => false;

  /// TUN 启动失败的原因（none = 没失败）。
  TunStartFailureKind get tunFailureKind => TunStartFailureKind.none;

  Future<String> getABIs();

  /// 请求通知权限（Android 13+ 前台服务通知需要）。返回 true=已有权限或无需请求。
  Future<bool> requestNotificationPermission() async => true;

  Future<String> clashiApiConnections(bool all);

  Future<String> clashiApiTraffic();
}

Future<String> getApplicationSupportDir() async {
  try {
    final d = await getApplicationSupportDirectory();
    if (!await d.exists()) {
      await d.create(recursive: true);
    }
    return d.path;
  } catch (_) {
    final fallback = Directory(p.join(Directory.systemTemp.path, "mclash"));
    if (!await fallback.exists()) {
      await fallback.create(recursive: true);
    }
    return fallback.path;
  }
}
