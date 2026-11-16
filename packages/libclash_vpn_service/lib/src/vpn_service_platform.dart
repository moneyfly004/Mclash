import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
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

  TunStartFailureKind get tunFailureKind => TunStartFailureKind.none;

  Future<String> getABIs();

  Future<String> fetchKernelLogs({bool incremental = true}) async => "";

  Future<bool> requestNotificationPermission() async => true;

  Future<String> clashiApiConnections(bool all);

  Future<String> clashiApiTraffic();
}

String? _appSupportDirCache;

/// path_provider 失败时使用的**持久化**兜底目录。
///
/// 旧实现退回 `Directory.systemTemp/mclash`。系统清理临时目录、安装器替换文件、
/// 或下一次以不同用户/权限启动后，会话文件、账号缓存与授权租约就会集体"消失"，
/// 表现为更新后账号读取失败、无法校验套餐状态。临时目录绝不允许保存登录态。
@visibleForTesting
String persistentFallbackSupportPath({
  required Map<String, String> environment,
  required bool isWindows,
  required bool isMacOS,
}) {
  if (isWindows) {
    // 与 path_provider_windows 的 RoamingAppData\CompanyName\ProductName
    // 保持一致（Runner.rc 中两者均为 mclash），避免正常/兜底路径来回切换。
    final roaming = environment['APPDATA']?.trim() ?? '';
    if (roaming.isNotEmpty) {
      return p.join(roaming, 'mclash', 'mclash');
    }
    final userProfile = environment['USERPROFILE']?.trim() ?? '';
    if (userProfile.isNotEmpty) {
      return p.join(userProfile, 'AppData', 'Roaming', 'mclash', 'mclash');
    }
    throw StateError('APPDATA/USERPROFILE 均不可用，无法确定持久化数据目录');
  }
  final home = environment['HOME']?.trim() ?? '';
  if (home.isEmpty) {
    throw StateError('HOME 不可用，无法确定持久化数据目录');
  }
  if (isMacOS) {
    return p.join(home, 'Library', 'Application Support', 'top.moneyfly.mclash');
  }
  return p.join(home, '.mclash');
}

Future<String> getApplicationSupportDir() async {
  final cached = _appSupportDirCache;
  if (cached != null && cached.isNotEmpty) {
    return cached;
  }
  try {
    final d = await getApplicationSupportDirectory();
    if (!await d.exists()) {
      await d.create(recursive: true);
    }
    _appSupportDirCache = d.path;
    return d.path;
  } catch (_) {
    // 先尝试持久化目录（桌面端：APPDATA / Application Support / HOME）。
    try {
      final persistent = Directory(
        persistentFallbackSupportPath(
          environment: Platform.environment,
          isWindows: Platform.isWindows,
          isMacOS: Platform.isMacOS,
        ),
      );
      if (!await persistent.exists()) {
        await persistent.create(recursive: true);
      }
      _appSupportDirCache = persistent.path;
      return persistent.path;
    } catch (_) {
      // 极端环境（例如 Android 上 HOME 不可写）：持久化目录都拿不到，
      // 只能退回临时目录，但这时数据本来也无处安放，不再静默当作正常路径。
    }
    final fallback = Directory(p.join(Directory.systemTemp.path, "mclash"));
    if (!await fallback.exists()) {
      await fallback.create(recursive: true);
    }
    _appSupportDirCache = fallback.path;
    return fallback.path;
  }
}
