library;

import 'dart:io';

import 'package:mclash/app/clash/clash_config.dart';
import 'package:mclash/app/clash/clash_http_api.dart';
import 'package:mclash/app/local_services/vpn_service.dart';
import 'package:mclash/app/modules/clash_setting_manager.dart';
import 'package:mclash/app/runtime/return_result.dart';
import 'package:mclash/app/utils/log.dart';
import 'package:mclash/mf/mclash_mode_selection.dart';

Future<ReturnResultError?> mclashSetMode(ClashConfigsMode mode) async {
  var error = await ClashSettingManager.setConfigsMode(mode);

  // 控制面偶尔一次超时（内核正忙/连接半坏）不代表不能热切：先重试一次。
  if (error != null && ClashHttpApi.isTransientControlError(error.message)) {
    Log.w("mclashSetMode: 热切失败（${error.message}），重试一次");
    await Future<void>.delayed(const Duration(milliseconds: 400));
    error = await ClashSettingManager.setConfigsMode(mode);
  }

  final started = await VPNService.getStarted();
  // Android 的 cmfa 内核禁用 PATCH /configs（405），只能断开重连应用模式；
  // PC/macOS 上**绝不能**因为一次超时就重启内核 —— 那正是「热切换就断线」
  // 的来源：PATCH 超时 → restart → 用户看到断线重连，而流量本来好好的。
  if (started && Platform.isAndroid) {
    Log.i("mclashSetMode: Android 内核不支持 PATCH，改用重连应用模式 ${mode.name}");
    error = await VPNService.restart(const Duration(seconds: 60));
  } else if (started && error != null) {
    Log.w("mclashSetMode: 热切最终失败（${error.message}），保持当前连接不重启内核");
  }

  if (mode == ClashConfigsMode.global) {
    await MclashModeSelection.ensureGlobalUsable();
  }
  return error;
}
