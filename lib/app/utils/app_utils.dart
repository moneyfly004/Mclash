import 'dart:io';

import 'package:package_info_plus/package_info_plus.dart';

abstract final class AppUtils {
  static Future<String> getPackgetVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return "${packageInfo.version}.${packageInfo.buildNumber}";
  }

  static String getName() {
    return "Mclash";
  }

  static String getBuildinVersion() {
    return "0.0.1.4";
  }

  static String getId() {
    return "top.moneyfly.mclash";
  }

  static String getGroupId() {
    return "group.top.moneyfly.mclash";
  }

  static String getBundleId(bool systemExtension) {
    if (Platform.isMacOS) {
      return "top.moneyfly.mclash";
    }
    return "";
  }

  static String getControlKind() {
    return "top.moneyfly.mclash.mclashWidget.ControlCenterToggle";
  }

  static String getICloudContainerId() {
    return "iCloud.top.moneyfly.mclash";
  }

  static String getCoreVersion() {
    return "1.19.31";
  }
}
