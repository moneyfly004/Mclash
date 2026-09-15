import 'package:flutter/services.dart';
import 'package:mclash/app/utils/platform_utils.dart';
import 'package:window_manager/window_manager.dart';

/// 「移到后台」的原生通道。
///
/// 由 `android/app/src/main/kotlin/top/moneyfly/mclash/MainActivity.kt` 实现，
/// 直接调用 `Activity.moveTaskToBack(true)`。
///
/// 原先这里用的是 pub.dev 的 `move_to_background` 包，但它最新版（1.0.2）
/// 仍用 Flutter 已移除的 v1 嵌入 API（`PluginRegistry.Registrar`），
/// 导致整个 Android 构建失败且**无法升级解决**（pub.dev 上没有新版本）。
/// 参考 MainActivity.kt 里更详细的说明。
const MethodChannel _moveToBackgroundChannel =
    MethodChannel("mclash/move_to_background");

abstract final class MoveToBackgroundUtils {
  static Future<void> moveToBackground({Duration? duration}) async {
    if (duration != null) {
      Future.delayed(const Duration(milliseconds: 300), () async {
        if (PlatformUtils.isMobile()) {
          await _moveToBackgroundChannel.invokeMethod("moveTaskToBack");
        } else if (PlatformUtils.isPC()) {
          await windowManager.hide();
        }
      });
    } else {
      if (PlatformUtils.isMobile()) {
        await _moveToBackgroundChannel.invokeMethod("moveTaskToBack");
      } else if (PlatformUtils.isPC()) {
        await windowManager.hide();
      }
    }
  }
}
