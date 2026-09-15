/// Mclash VPN 服务插件 —— 公开 barrel
library;

import 'dart:io';

import 'src/android_impl.dart';
import 'src/desktop_impl.dart';
import 'src/vpn_service_platform.dart';

export 'proxy_manager.dart';
export 'src/android_impl.dart' show AndroidVpnServicePlatform;
export 'src/desktop_impl.dart' show DesktopVpnServiceImpl;
export 'src/models.dart';
export 'src/vpn_service_platform.dart';
export 'state.dart';
export 'vpn_service.dart';
export 'vpn_service_platform_interface.dart';

/// 注册平台实现。必须在 `runApp` 之前调用一次（`main()` 里）。
///
/// 为什么显式注册而不是靠 pubspec 的 `dartPluginClass` 自动注册：
/// 本项目用的是 **path 依赖**（`packages/libclash_vpn_service`），
/// 不是从 pub 拉取的正式插件，Flutter 的 Dart 插件注册器不会为它生成
/// 自动注册代码。显式注册同时也避免了桌面构建把 MethodChannel 实现
/// 拖进依赖图（Android 专属代码在桌面构建里会被 tree-shake 掉）。
void registerMclashVpnService() {
  VpnServicePlatform.instance =
      Platform.isAndroid ? AndroidVpnServicePlatform() : DesktopVpnServiceImpl();
}
