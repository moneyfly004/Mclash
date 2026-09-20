
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

void registerDesktopLogSink(void Function(String line)? sink) {
  desktopLogSink = sink;
}

Future<String> systemProxyDiagnostics() => SystemProxyDiagnostics.report();

String get lastSystemProxyCleanSkip => SystemProxyDiagnostics.lastCleanSkip;
