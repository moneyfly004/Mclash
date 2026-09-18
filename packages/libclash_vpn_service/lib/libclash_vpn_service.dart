
library;

import 'dart:io';

import 'src/android_impl.dart';
import 'src/desktop_impl.dart';
import 'src/vpn_service_platform.dart';

export 'proxy_manager.dart';
export 'src/android_impl.dart' show AndroidVpnServicePlatform;
export 'src/desktop_impl.dart' show DesktopVpnServiceImpl;
export 'src/geo_data.dart';
export 'src/models.dart';
export 'src/vpn_service_platform.dart';
export 'state.dart';
export 'vpn_service.dart';
export 'vpn_service_platform_interface.dart';

void registerMclashVpnService() {
  VpnServicePlatform.instance =
      Platform.isAndroid ? AndroidVpnServicePlatform() : DesktopVpnServiceImpl();
}

/// 让 App 把桌面端诊断日志接到自己的日志文件（见 desktop_impl.dart 的说明）。
void registerDesktopLogSink(void Function(String line)? sink) {
  desktopLogSink = sink;
}

/// Windows 系统代理的诊断报告（面板里直接显示；见 desktop_impl.dart 的说明）。
Future<String> systemProxyDiagnostics() => SystemProxyDiagnostics.report();

/// 最近一次「清理系统代理」为什么没做（空串 = 做了）。
///
/// 用户实测的跨软件事故就靠它可视：Mclash 曾经在启动时无条件清理系统代理，
/// 把别的客户端（MoneyFly / Clash Party）正在用的代理一起抹掉 ——
/// 现在只有「确实是我们写的」才会清理，跳过时会写明原因。
String get lastSystemProxyCleanSkip => SystemProxyDiagnostics.lastCleanSkip;
