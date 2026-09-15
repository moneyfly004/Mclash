import 'package:flutter/services.dart';
import 'package:mclash/app/utils/platform_utils.dart';
import 'package:window_manager/window_manager.dart';

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
