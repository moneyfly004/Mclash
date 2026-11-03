import 'package:flutter/services.dart';
import 'package:mclash/app/utils/app_lifecycle_state_notify.dart';
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
          // 隐藏后必须标暂停：否则首页仍每 2s 查内核状态、每 30s 读代理组
          //（用户报障「最小化到托盘后电脑还是卡」）。
          AppLifecycleStateNofity.statePaused("hide");
        }
      });
    } else {
      if (PlatformUtils.isMobile()) {
        await _moveToBackgroundChannel.invokeMethod("moveTaskToBack");
      } else if (PlatformUtils.isPC()) {
        await windowManager.hide();
        AppLifecycleStateNofity.statePaused("hide");
      }
    }
  }
}
