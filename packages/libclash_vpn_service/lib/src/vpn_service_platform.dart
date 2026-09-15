import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

// 直接 import 两个平台实现。
//
// ⚠️ 这里**必须**直接构造，不能走"外部注册的工厂函数"那种间接层 ——
// 曾经的写法（_createDefault 调用 AndroidVpnServicePlatformFactory.create）
// 会让 VpnServicePlatform.instance 在**注册之前**被首次访问时抛
// UnsupportedError。真实后果：main() 里 PathUtils.profileDir() →
// FlutterVpnService.getAppGroupDirectory() 一访问 instance 就崩，
// 崩点在 runApp 之前 → 窗口起来了但内容是**纯黑**（既没有界面也没有报错）。
//
// Dart 允许 import 循环（本文件 ↔ 两个实现文件），且双方都只在方法体内使用
// 对方的类型，没有初始化顺序问题。
import 'android_impl.dart';
import 'desktop_impl.dart';
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
    // Android：MethodChannel → Kotlin VpnService + libmihomo.aar
    // 其余平台：纯 Dart（mihomo 子进程 + 系统代理）
    return Platform.isAndroid
        ? AndroidVpnServicePlatform()
        : DesktopVpnServiceImpl();
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
