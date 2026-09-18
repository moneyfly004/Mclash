
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
