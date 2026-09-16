library;

import 'package:flutter/material.dart';
import 'package:mclash/app/local_services/vpn_service.dart';
import 'package:mclash/app/modules/setting_manager.dart';
import 'package:mclash/app/utils/log.dart';
import 'package:mclash/app/utils/platform_utils.dart';
import 'package:mclash/screens/dialog_utils.dart';
import 'package:mclash/screens/group_helper.dart';
import 'package:mclash/screens/theme_config.dart';
import 'package:mclash/screens/theme_define.dart';

/// 「我的 → TUN 虚拟网卡」：三态选择（关闭 / 自动 / 强制）。
///
/// 语义与我的参考实现（moneyfly 桌面版）完全对齐 —— 这套分档是用户真正需要的：
///   * **关闭（默认）**：仅系统代理。轻量、不改路由表；只有遵守系统代理的程序
///     走代理，UDP / 游戏 / 自带代理设置的程序不生效；
///   * **自动**：TUN + 系统代理（双保险）。TUN 起来就靠它接管全部流量，
///     万一没起来（没权限等）系统代理还在，不会「连上了却上不了网」；
///   * **强制**：仅 TUN。所有流量（含 UDP）都进虚拟网卡，不再改系统代理。
///
/// 桌面端 TUN 需要管理员权限（Windows 建 wintun、macOS 建 utun）—— 这一点
/// 在选中的那一刻就告诉用户，并直接给「以管理员身份重启」的入口，
/// 而不是等他发现「开了没反应」。
abstract final class MclashTunSetting {
  /// 界面上的名字。
  static String label(String mode) => switch (mode) {
    SettingConfig.kTunModeAuto => "自动",
    SettingConfig.kTunModeForce => "强制",
    _ => "关闭",
  };

  /// 一行说明（放在「我的」那一行的副标题）。
  static String description(String mode) => switch (mode) {
    SettingConfig.kTunModeAuto => "TUN + 系统代理（双保险）：全部流量走虚拟网卡，含 UDP",
    SettingConfig.kTunModeForce => "仅 TUN：全部流量走虚拟网卡，不再改系统代理",
    _ => "仅系统代理：浏览器等遵守系统代理的程序生效，UDP/游戏不走代理",
  };

  /// 选项列表里的详细说明。
  static String optionDesc(String mode) => switch (mode) {
    SettingConfig.kTunModeAuto =>
      "建虚拟网卡接管全部流量（含 UDP、游戏）；同时保留系统代理作为兜底。"
          "推荐：既能全局生效，又不会因为权限问题彻底没网。",
    SettingConfig.kTunModeForce =>
      "只用虚拟网卡，不再改系统代理。全部流量（含 UDP）都进隧道，"
          "系统里「代理」一项保持原样。",
    _ => "不改系统路由表，只在系统里设置 127.0.0.1 的代理。"
        "只有遵守系统代理的程序走代理；UDP 流量与自带代理设置的程序不走。",
  };

  /// 当前是否满足 TUN 的前置条件（桌面端需要管理员权限）。
  static bool prerequisitesMet() => VPNService.tunPrerequisitesMet();

  /// 打开选择面板。
  static Future<void> show(BuildContext context) async {
    final current = SettingManager.getConfig().tunMode;
    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => _TunModeSheet(current: current),
    );
    if (selected == null || selected == current || !context.mounted) {
      return;
    }
    await _apply(context, selected);
  }

  /// 应用选择：落盘 → 需要时重连 → 提示。
  static Future<void> _apply(BuildContext context, String mode) async {
    if (!context.mounted) {
      return;
    }
    // 桌面端选 auto/force 但没管理员权限：先把原因和出路说清楚
    final needsAdmin =
        mode != SettingConfig.kTunModeOff &&
        PlatformUtils.isPC() &&
        !prerequisitesMet();
    if (needsAdmin) {
      final go = await DialogUtils.showConfirmDialog(
        context,
        "TUN 虚拟网卡需要管理员权限（Windows 建 wintun / macOS 建 utun）。\n\n"
        "当前 Mclash 不是以管理员身份运行的，开启后 TUN 不会生效"
        "（「自动」模式下系统代理仍会兜底，网络可用）。\n\n"
        "点「确定」= 现在以管理员身份重启 Mclash（会弹 UAC）\n"
        "点「取消」= 仍要保存这个选择（TUN 不生效时会自动用系统代理）",
      );
      if (!context.mounted) {
        return;
      }
      if (go == true) {
        final err = await VPNService.relaunchAsAdmin();
        if (!context.mounted) {
          return;
        }
        if (err != null) {
          await DialogUtils.showAlertDialog(context, "重启失败：${err.message}");
          return;
        }
        return;
      }
    }

    final setting = SettingManager.getConfig();
    setting.tunMode = mode;
    SettingManager.save();
    Log.i("MclashTunSetting: TUN 模式 → $mode（${description(mode)}）");

    // TUN 是内核启动参数：已连接时重连一次让它按新配置起来
    final connected = await VPNService.getStarted();
    if (connected) {
      final err = await VPNService.restart(const Duration(seconds: 60));
      if (err != null) {
        setting.tunMode = mode == SettingConfig.kTunModeOff
            ? SettingConfig.kTunModeAuto
            : SettingConfig.kTunModeOff;
        SettingManager.save();
        if (context.mounted) {
          await DialogUtils.showAlertDialog(
            context,
            "切换 TUN 模式失败：${err.message}\n已恢复原来的设置。",
          );
        }
        return;
      }
    }
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          mode == SettingConfig.kTunModeOff
              ? "已设为「关闭」：只使用系统代理"
              : "已设为「${label(mode)}」，${connected ? "已重连生效" : "连接后生效"}",
        ),
      ),
    );
  }
}

class _TunModeSheet extends StatelessWidget {
  const _TunModeSheet({required this.current});

  final String current;

  @override
  Widget build(BuildContext context) {
    final admin = MclashTunSetting.prerequisitesMet();
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: ThemeDefine.kColorGrey,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 12, 4),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    "TUN 虚拟网卡",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: ThemeConfig.kFontWeightTitle,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: "关闭",
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          for (final mode in const [
            SettingConfig.kTunModeOff,
            SettingConfig.kTunModeAuto,
            SettingConfig.kTunModeForce,
          ])
            ListTile(
              key: ValueKey("tun-mode-$mode"),
              leading: Icon(
                mode == SettingConfig.kTunModeOff
                    ? Icons.language_outlined
                    : Icons.lan_outlined,
                color: current == mode
                    ? ThemeDefine.kColorBlue
                    : ThemeDefine.kColorGrey,
              ),
              title: Text(
                MclashTunSetting.label(mode),
                style: TextStyle(
                  fontWeight: current == mode
                      ? ThemeConfig.kFontWeightListItem
                      : FontWeight.normal,
                  color: current == mode ? ThemeDefine.kColorBlue : null,
                ),
              ),
              subtitle: Text(
                MclashTunSetting.optionDesc(mode),
                style: const TextStyle(
                  fontSize: 11.5,
                  height: 1.4,
                  color: ThemeDefine.kColorGrey,
                ),
              ),
              trailing: current == mode
                  ? const Icon(
                      Icons.check,
                      size: 18,
                      color: ThemeDefine.kColorBlue,
                    )
                  : null,
              onTap: () => Navigator.of(context).pop(mode),
            ),
          // 高级参数（地址 / 栈 / MTU / 自动路由 / DNS 劫持 …）仍在
        // 「我的 → 核心设置 → TUN」里，这里给一个直达入口。
        ListTile(
          key: const ValueKey("tun-advanced"),
          dense: true,
          leading: const Icon(
            Icons.tune,
            size: 18,
            color: ThemeDefine.kColorBlue,
          ),
          title: const Text(
            "高级参数（核心设置 → TUN）",
            style: TextStyle(fontSize: 13, color: ThemeDefine.kColorBlue),
          ),
          subtitle: const Text(
            "虚拟网卡地址 / 栈 / MTU / 自动路由 / DNS 劫持 / 覆写",
            style: TextStyle(fontSize: 11, color: ThemeDefine.kColorGrey),
          ),
          onTap: () {
            Navigator.of(context).pop();
            GroupHelper.showClashSettingsTUN(context);
          },
        ),
        Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  admin ? Icons.info_outline : Icons.warning_amber_outlined,
                  size: 14,
                  color: admin ? ThemeDefine.kColorGrey : Colors.orange,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    admin
                        ? "TUN 需要管理员权限；当前权限满足（Windows 以管理员运行 / macOS 以 root 运行）"
                        : "TUN 需要管理员权限：当前未以管理员身份运行，选中「自动/强制」后 TUN 不会生效"
                              "（「自动」会用系统代理兜底，网络仍可用）",
                    style: TextStyle(
                      fontSize: 11,
                      height: 1.4,
                      color: admin ? ThemeDefine.kColorGrey : Colors.orange,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
