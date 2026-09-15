import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'models.dart';

/// 平台实现契约。
///
/// 两个实现：
///   - [AndroidVpnServicePlatform]（android_impl.dart）：MethodChannel →
///     Kotlin `MclashVpnService` + `libmihomo.aar`（VpnService TUN fd 注入）
///   - `DesktopVpnServiceImpl`（desktop_impl.dart）：纯 Dart，
///     mihomo 子进程 + Clash REST API 就绪探测 + 平台系统代理命令
abstract class VpnServicePlatform {
  static VpnServicePlatform? _instance;

  static VpnServicePlatform get instance =>
      _instance ??= _createDefault();

  static set instance(VpnServicePlatform v) => _instance = v;

  static VpnServicePlatform _createDefault() {
    if (Platform.isAndroid) {
      // 延迟 import 避免桌面构建拉入 MethodChannel 依赖树
      return AndroidVpnServicePlatformFactory.create();
    }
    return DesktopVpnServicePlatformFactory.create();
  }

  /// 状态变化回调（上层 ConnectionController 订阅）
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

  /// 返回 null 表示成功；非 null 为错误（对齐原插件契约）
  Future<VpnServiceResultError?> authorizeService(String path, String password);

  Future<Directory?> getAppGroupDirectory(String groupId);

  Future<String> getSystemVersion();

  /// 返回 null 表示成功；非 null 为错误信息（对齐原插件契约）
  Future<String?> setExcludeFromRecents(bool exclude);

  Future<void> hideDockIcon(bool hide);

  Future<String> getABIs();

  Future<String> clashiApiConnections(bool all);

  Future<String> clashiApiTraffic();
}

/// 工厂：避免在桌面构建时把 MethodChannel 实现拖进依赖图
class AndroidVpnServicePlatformFactory {
  static VpnServicePlatform Function() create = () =>
      throw UnsupportedError("Android platform impl not registered");
}

class DesktopVpnServicePlatformFactory {
  static VpnServicePlatform Function() create = () =>
      throw UnsupportedError("Desktop platform impl not registered");
}

/// 应用支持目录（内核副本、geo 数据、日志都落这里）
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
