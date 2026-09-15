import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:mclash/app/utils/platform_utils.dart';
import 'package:libclash_vpn_service/vpn_service.dart';

class DeviceUtils {
  static Future<bool> disableOrientation() async {
    if (Platform.isWindows) {
      return false;
    }
    if (!PlatformUtils.isMobile()) {
      return true;
    }

    if (Platform.isAndroid) {
      final platformDispatcher = WidgetsBinding.instance.platformDispatcher;
      if (platformDispatcher.views.isEmpty ||
          platformDispatcher.displays.isEmpty) {
        return false;
      }
      var screenWidthInPixels =
          platformDispatcher.views.first.physicalSize.width;
      var devicePixelRatio = platformDispatcher.displays.first.devicePixelRatio;
      double screenWidthInDp = screenWidthInPixels / devicePixelRatio;
      if (screenWidthInDp >= 600) {

        String version = await FlutterVpnService.getSystemVersion();
        int? v = int.tryParse(version);
        if (v != null && v >= 36) {
          return true;
        }
      }
    }
    return false;
  }
}
