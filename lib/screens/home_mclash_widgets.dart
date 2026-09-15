/// 首页的 MoneyFly 组件：
///   * `MclashAccountBar` —— 连接卡下方的**一行账户状态条**（见 docs/design/06 §6.2.5）
///   * `MclashAccountGateDialog` —— 准入闸门弹窗（D-09）
///
/// 视觉完全沿用 Clash Mi：`Card`（r12 / elevation 1 / margin 4）
/// + `Padding(fromLTRB(20,0,20,0))` + `ListTile`，文字受限时用 `Colors.red`。
library;

import 'package:flutter/material.dart';
import 'package:mclash/mf/mclash_account_service.dart';
import 'package:mclash/screens/dialog_utils.dart';
import 'package:mclash/screens/main_tab_shell.dart';
import 'package:mclash/screens/theme_define.dart';

/// 首页账户状态条：一行摘要，点击跳「套餐购买」Tab。
///
/// 为什么压成一行而不是一整张卡：完整的账户中心已经在「我的」Tab，
/// 主页只保留速览 + 跳转，避免同一批入口在 主页/套餐/我的 三处重复。
class MclashAccountBar extends StatelessWidget {
  const MclashAccountBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: MclashAccountService.instance,
      builder: (context, _) {
        final acc = MclashAccountService.instance;
        final text = acc.statusBarText;
        if (text.isEmpty) {
          return const SizedBox.shrink();
        }
        final warn = acc.isBlocked || acc.expiringSoon;
        return Card(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              title: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  color: warn ? Colors.red : null,
                ),
              ),
              trailing: const Icon(Icons.chevron_right, size: 20),
              onTap: () {
                if (acc.isBlocked) {
                  showMclashAccountGateDialog(context);
                } else {
                  // 正常态 → 去「套餐购买」Tab
                  MainTabController.instance?.setTab(2);
                }
              },
            ),
          ),
        );
      },
    );
  }
}

/// 准入闸门弹窗（D-09）。
///
/// 用 Clash Mi 的 `SimpleDialog` 家族（`DialogUtils.showAlertDialog`）保证视觉一致，
/// 但按钮语义按设计稿定制：取消 + 行动（去续费 / 管理设备 / 重新登录 / 好的）。
Future<void> showMclashAccountGateDialog(BuildContext context) async {
  final acc = MclashAccountService.instance;
  final kind = acc.blockKind;

  switch (kind) {
    case MclashBlockKind.deviceFull:
      final ok = await DialogUtils.showConfirmDialog(
        context,
        "${acc.blockEmoji}\n${acc.blockTitle}\n\n${acc.blockText}",
      );
      if (ok == true) {
        MainTabController.instance?.setTab(3);
      }
      return;

    case MclashBlockKind.expired:
    case MclashBlockKind.noSubscription:
      final ok = await DialogUtils.showConfirmDialog(
        context,
        "${acc.blockEmoji}\n${acc.blockTitle}\n\n${acc.blockText}",
      );
      if (ok == true) {
        MainTabController.instance?.setTab(2);
      }
      return;

    case MclashBlockKind.deviceKicked:
      final ok = await DialogUtils.showConfirmDialog(
        context,
        "${acc.blockEmoji}\n${acc.blockTitle}\n\n${acc.blockText}",
      );
      if (ok == true) {
        // 清会话后回登录页（「我的」Tab 有登出按钮，这里直接提示即可）
        MainTabController.instance?.setTab(3);
      }
      return;

    case MclashBlockKind.accountDisabled:
    case MclashBlockKind.subscriptionDisabled:
      await DialogUtils.showAlertDialog(
        context,
        "${acc.blockEmoji}\n${acc.blockTitle}\n\n${acc.blockText}",
        showFAQ: true,
      );
      return;

    case MclashBlockKind.none:
      return;
  }
}

/// 首页连接开关的点击前置判定。
///
/// 返回 true 表示**放行连接**；false 表示已受限并已弹出闸门弹窗。
Future<bool> mclashCheckAccountGate(BuildContext context) async {
  final acc = MclashAccountService.instance;
  if (!acc.isBlocked) {
    return true;
  }
  await showMclashAccountGateDialog(context);
  return false;
}

/// 受限态的开关外观：禁用（灰）且不可拨动。
///
/// 设计意图：受限时**在构建期就禁用开关**，而不是点下去再弹窗 ——
/// 后者会让用户以为"点了没反应"（Clash Mi 的 VPN 授权流程踩过同一个坑）。
class MclashGateHint extends StatelessWidget {
  const MclashGateHint({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: MclashAccountService.instance,
      builder: (context, _) {
        if (!MclashAccountService.instance.isBlocked) {
          return const SizedBox.shrink();
        }
        return Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            "订阅不可用，连接已暂停",
            style: TextStyle(
              fontSize: 12,
              color: ThemeDefine.kColorGrey,
            ),
          ),
        );
      },
    );
  }
}
