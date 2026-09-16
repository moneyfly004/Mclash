import 'dart:io';

/// 安装来源 / 渠道名。
///
/// 原实现只读 Apple 的安装来源（App Store / TestFlight / Debug）——
/// Mclash 已不再支持 iOS，这条链路整体删除：现在直接返回构建渠道名
/// （CI 通过 `--dart-define=PACKAGE_TARGET=...` 注入），没有渠道时回退成系统名。
/// 这与旧实现在 Android / Windows / macOS 上的行为完全一致。
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
