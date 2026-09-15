library;

import 'package:mclash/app/clash/clash_config.dart';
import 'package:mclash/app/modules/clash_setting_manager.dart';
import 'package:mclash/app/runtime/return_result.dart';
import 'package:mclash/mf/mclash_mode_selection.dart';

/// 切换分流模式的统一入口（分段控件、托盘菜单、快捷键都走这里）。
///
/// 除了切内核模式，还要处理一个真实的坑：**全局模式下一切流量由 GLOBAL
/// 选择器决定**，而订阅配置里没有 GLOBAL 组时 mihomo 默认把它设成 DIRECT，
/// 于是「切到全局 = 全部直连 = 上不了外网」。切完模式顺手把它接到用户原本
/// 正在用的节点上（已经有真实选择时不动）。
Future<ReturnResultError?> mclashSetMode(ClashConfigsMode mode) async {
  final error = await ClashSettingManager.setConfigsMode(mode);
  if (error == null && mode == ClashConfigsMode.global) {
    await MclashModeSelection.ensureGlobalUsable();
  }
  return error;
}
