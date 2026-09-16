import 'dart:io';

import 'package:package_info_plus/package_info_plus.dart';
import 'package:mclash/generated/build_time.dart' as build_time;

abstract final class AppUtils {
  static Future<String> getPackgetVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return "${packageInfo.version}.${packageInfo.buildNumber}";
  }

  static String getName() {
    return "Mclash";
  }

  static String getReleaseVersion() {
    List<String> v = getBuildinVersion().split(".");
    return "${v[0]}.${v[1]}.${v[2]}+${v[3]}";
  }

  static String getNextBuildinVersion() {
    List<String> v = getBuildinVersion().split(".");
    return "${v[0]}.${v[1]}.${v[2]}.${int.parse(v[3]) + 1}";
  }

  static String getBuildinVersion() {
    return "0.0.3.1";
  }

  static DateTime getBuildinVersionDate() {
    return build_time.buildDateTime;
  }

  static String getId() {
    return "top.moneyfly.mclash";
  }

  static String getGroupId() {
    return "group.top.moneyfly.mclash";
  }

  static String getBundleId(bool systemExtension) {
    if (Platform.isIOS || Platform.isMacOS) {
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
