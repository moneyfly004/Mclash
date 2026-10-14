library;

import 'package:flutter/material.dart';
import 'package:mclash/app/local_services/vpn_service.dart';
import 'package:mclash/app/modules/setting_manager.dart';
import 'package:mclash/app/utils/log.dart';
import 'package:mclash/app/utils/platform_utils.dart';
import 'package:mclash/i18n/strings.g.dart';
import 'package:mclash/screens/dialog_utils.dart';
import 'package:mclash/screens/group_helper.dart';
import 'package:mclash/screens/theme_config.dart';
import 'package:mclash/screens/theme_define.dart';

abstract final class MclashTunSetting {
  static bool _applying = false;

  /// 取词入口：`context != null` 时走 slang（`Translations.of(context)`），
  /// 语言切换后立即是新语言；为 `null` 时走下面的 `_legacy*` 分支。
  ///
  /// 为什么保留 `_legacy*` 中文分支：它的唯一调用方
  /// `lib/screens/mclash_profile_screen.dart` 拿不到 `context`，而
  /// `test/screens/mclash_home_tun_switch_test.dart` 又逐条断言这三段中文文案。
  /// 这两个文件不在本次改造范围（只能改本文件与 group_helper.dart），所以
  /// 无 context 的行为与改造前逐字一致，零回归。
  /// 若后续把这两个文件一起改造，删掉 `_legacy*` 即可。
  ///
  /// 本 App 内所有界面（TUN 设置页 + 核心设置页）一律传 `context`。

  static String label(String mode, [BuildContext? context]) => context == null
      ? _legacyLabel(mode)
      : _label(Translations.of(context), mode);

  static String _label(Translations t, String mode) => switch (mode) {
    SettingConfig.kTunModeAuto => t.tunScreen.modeAuto,
    SettingConfig.kTunModeForce => t.tunScreen.modeForce,
    _ => t.tunScreen.modeOff,
  };

  static String _legacyLabel(String mode) => switch (mode) {
    SettingConfig.kTunModeAuto => "自动",
    SettingConfig.kTunModeForce => "强制",
    _ => "关闭",
  };

  static String description(String mode, [BuildContext? context]) =>
      context == null
      ? _legacyDescription(mode)
      : _description(Translations.of(context), mode);

  static String _description(Translations t, String mode) => switch (mode) {
    SettingConfig.kTunModeAuto => t.tunScreen.modeAutoDesc,
    SettingConfig.kTunModeForce => t.tunScreen.modeForceDesc,
    _ => t.tunScreen.modeOffDesc,
  };

  static String _legacyDescription(String mode) => switch (mode) {
    SettingConfig.kTunModeAuto => "TUN + 系统代理（双保险）：全部流量走虚拟网卡，含 UDP",
    SettingConfig.kTunModeForce => "仅 TUN：全部流量走虚拟网卡，不再改系统代理",
    _ => "仅系统代理：浏览器等遵守系统代理的程序生效，UDP/游戏不走代理",
  };

  static String optionDesc(String mode, [BuildContext? context]) =>
      context == null
      ? _legacyOptionDesc(mode)
      : _optionDesc(Translations.of(context), mode);

  static String _optionDesc(Translations t, String mode) => switch (mode) {
    SettingConfig.kTunModeAuto => t.tunScreen.modeAutoOptionDesc,
    SettingConfig.kTunModeForce => t.tunScreen.modeForceOptionDesc,
    _ => t.tunScreen.modeOffOptionDesc,
  };

  static String _legacyOptionDesc(String mode) => switch (mode) {
    SettingConfig.kTunModeAuto =>
      "建虚拟网卡接管全部流量（含 UDP、游戏）；同时保留系统代理作为兜底。"
          "推荐：既能全局生效，又不会因为权限问题彻底没网。",
    SettingConfig.kTunModeForce =>
      "只用虚拟网卡，不再改系统代理。全部流量（含 UDP）都进隧道，"
          "系统里「代理」一项保持原样。",
    _ => "不改系统路由表，只在系统里设置 127.0.0.1 的代理。"
        "只有遵守系统代理的程序走代理；UDP 流量与自带代理设置的程序不走。",
  };

  static bool prerequisitesMet() => VPNService.tunPrerequisitesMet();

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

  static Future<void> _apply(BuildContext context, String mode) async {
    if (!context.mounted || _applying) {
      return;
    }
    _applying = true;
    try {
      await _applyInner(context, mode);
    } finally {
      _applying = false;
    }
  }

  static Future<void> _applyInner(BuildContext context, String mode) async {
    if (!context.mounted) {
      return;
    }
    final t = Translations.of(context);
    final needsAdmin =
        mode != SettingConfig.kTunModeOff &&
        PlatformUtils.isPC() &&
        !prerequisitesMet();
    if (needsAdmin) {
      final go = await DialogUtils.showConfirmDialog(
        context,
        t.tunScreen.adminRequiredDialog,
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
          await DialogUtils.showAlertDialog(
            context,
            t.tunScreen.relaunchFailed(message: err.message),
          );
          return;
        }
        return;
      }
    }

    final setting = SettingManager.getConfig();
    setting.tunMode = mode;
    SettingManager.save();
    Log.i("MclashTunSetting: TUN 模式 → $mode（${description(mode)}）");

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
            t.tunScreen.switchFailed(message: err.message),
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
              ? t.tunScreen.setOffSnack
              : t.tunScreen.setModeSnack(
                  mode: _label(t, mode),
                  effect: connected
                      ? t.tunScreen.effectReconnected
                      : t.tunScreen.effectAfterConnect,
                ),
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
    final t = Translations.of(context);
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
                Expanded(
                  child: Text(
                    t.tunScreen.sheetTitle,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: ThemeConfig.kFontWeightTitle,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: t.meta.close,
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
                MclashTunSetting.label(mode, context),
                style: TextStyle(
                  fontWeight: current == mode
                      ? ThemeConfig.kFontWeightListItem
                      : FontWeight.normal,
                  color: current == mode ? ThemeDefine.kColorBlue : null,
                ),
              ),
              subtitle: Text(
                MclashTunSetting.optionDesc(mode, context),
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
        ListTile(
          key: const ValueKey("tun-advanced"),
          dense: true,
          leading: const Icon(
            Icons.tune,
            size: 18,
            color: ThemeDefine.kColorBlue,
          ),
          title: Text(
            t.tunScreen.advancedTitle,
            style: const TextStyle(fontSize: 13, color: ThemeDefine.kColorBlue),
          ),
          subtitle: Text(
            t.tunScreen.advancedSubtitle,
            style: const TextStyle(fontSize: 11, color: ThemeDefine.kColorGrey),
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
                    admin ? t.tunScreen.adminOk : t.tunScreen.adminMissing,
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
