library;

import 'dart:io';

import 'package:mclash/app/clash/clash_config.dart';
import 'package:mclash/app/local_services/vpn_service.dart';
import 'package:mclash/app/modules/clash_setting_manager.dart';
import 'package:mclash/app/runtime/return_result.dart';
import 'package:mclash/app/utils/log.dart';
import 'package:mclash/mf/mclash_mode_selection.dart';

Future<ReturnResultError?> mclashSetMode(ClashConfigsMode mode) async {
  final error = await ClashSettingManager.setConfigsMode(mode);

  final started = await VPNService.getStarted();
  if (started && (Platform.isAndroid || error != null)) {
    Log.i("mclashSetMode: 热切不可用，改用重连方式应用模式 ${mode.name}");
    await VPNService.restart(const Duration(seconds: 60));
  }

  if (mode == ClashConfigsMode.global) {
    await MclashModeSelection.ensureGlobalUsable();
  }
  return error;
}
