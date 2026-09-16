library;

import 'dart:io';

import 'package:mclash/app/clash/clash_config.dart';
import 'package:mclash/app/local_services/vpn_service.dart';
import 'package:mclash/app/modules/clash_setting_manager.dart';
import 'package:mclash/app/runtime/return_result.dart';
import 'package:mclash/app/utils/log.dart';
import 'package:mclash/mf/mclash_mode_selection.dart';

/// 切换分流模式的统一入口（分段控件、托盘菜单、快捷键都走这里）。
///
/// 三件事必须一起做，否则用户会觉得「切了没用」：
///
/// 1. **落盘**：模式写进设置，重连/重启后仍然是这个模式。
/// 2. **热切内核**：`PATCH /configs {mode}`，不断网即时生效。
/// 3. **全局模式的 GLOBAL 修正**：全局模式下一切流量由内核内置的 GLOBAL 选择器
///    决定，而订阅配置里没有该组时 mihomo 默认把它设成 DIRECT —— 于是
///    「切到全局 = 全部直连 = 上不了外网」。切完模式顺手把它接到用户在用的节点。
///
/// 另外：**手机上的内核（cmfa 构建）不允许热切**（PATCH /configs 返回 405），
/// 参考客户端（MoneyFly）的做法是「断开 → 用新模式重连」。这里照做，
/// 否则手机上切全局/规则完全不生效（用户反馈的「全局模式真的生效了吗」）。
Future<ReturnResultError?> mclashSetMode(ClashConfigsMode mode) async {
  final error = await ClashSettingManager.setConfigsMode(mode);

  final started = await VPNService.getStarted();
  if (started && (Platform.isAndroid || error != null)) {
    // 热切不可用（或失败）→ 断开重连让内核用新配置起来
    Log.i("mclashSetMode: 热切不可用，改用重连方式应用模式 ${mode.name}");
    await VPNService.restart(const Duration(seconds: 60));
  }

  if (mode == ClashConfigsMode.global) {
    await MclashModeSelection.ensureGlobalUsable();
  }
  return error;
}
