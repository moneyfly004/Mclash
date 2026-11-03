import 'dart:io';

import 'package:package_info_plus/package_info_plus.dart';

abstract final class AppUtils {
  static Future<String> getPackgetVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return "${packageInfo.version}.${packageInfo.buildNumber}";
  }

  static Future<String> getPackgetVersionName() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }

  static String getName() {
    return "Mclash";
  }

  /// 构建版本（**运行期用 PackageInfo 回填**，不再硬编码）。
  ///
  /// 背景：这里原来写死 "0.0.2.5"，而 pubspec 已经是 0.0.3 →
  /// [getBuildinVersionName] 返回 "0.0.2"，与 PackageInfo 的 "0.0.3" 不相等，
  /// main() 的启动自检直接判 [StartFailedReason.invalidVersion]，
  /// 用户看到「应用启动失败[无效版本],请重新安装应用」。
  /// 现在版本只有 pubspec 一个来源：main() 启动最早处调用 [initBuildinVersion]。
  static String? _buildinVersion;

  /// 启动时调用一次（须早于任何 getBuildinVersion 的使用）
  static Future<void> initBuildinVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      _buildinVersion = '${info.version}.${info.buildNumber}';
    } catch (_) {
      // 拿不到 PackageInfo 时保持 null：启动自检会跳过版本比对，
      // 宁可放过也不要因为读不到版本就把用户挡在门外。
    }
  }

  /// 是否已经拿到真实版本（测试/兜底用）
  static bool get hasBuildinVersion => _buildinVersion != null;

  static String getBuildinVersion() {
    return _buildinVersion ?? "0.0.0.0";
  }

  static String getBuildinVersionName() {
    final v = getBuildinVersion();
    final i = v.lastIndexOf('.');
    return i < 0 ? v : v.substring(0, i);
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
