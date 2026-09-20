import 'dart:io';

abstract final class InstallReferrerUtils {
  static String getBuildChannelName() {
    String channel = const String.fromEnvironment('PACKAGE_TARGET');
    return channel;
  }

  static Future<String> getString() async {
    final channel = getBuildChannelName();
    if (channel.isNotEmpty) {
      return channel;
    }
    return Platform.operatingSystem;
  }
}
