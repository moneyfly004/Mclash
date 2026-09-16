
library;

import 'package:flutter/material.dart';
import 'package:mclash/mf/mclash_account_service.dart';
import 'package:mclash/screens/dialog_utils.dart';
import 'package:mclash/screens/main_tab_shell.dart';
import 'package:mclash/mf/mclash_account_info.dart';
import 'package:mclash/mf/mclash_node_country.dart';
import 'package:mclash/mf/mclash_mode_selection.dart';
import 'package:mclash/mf/mclash_node_autopick.dart';
import 'package:mclash/mf/mclash_nodes_store.dart';
import 'package:mclash/screens/theme_config.dart';
import 'package:mclash/screens/theme_define.dart';

class MclashSubscriptionCard extends StatelessWidget {
  const MclashSubscriptionCard({super.key});

  @override
  Widget build(BuildContext context) {
    final acc = MclashAccountService.instance;
    final info = MclashAccountInfo(acc.dashboard, acc.subscription);
    final blocked = acc.isBlocked;
    final parts = <String>[
      if (info.planName.isNotEmpty) info.planName,
      if (info.expireDate.isNotEmpty) "到期 ${info.expireDate}",
      if (info.deviceText != null) "设备 ${info.deviceText}",
    ];
    final text = blocked ? "${acc.blockEmoji} ${acc.blockTitle}" : parts.join(" · ");
    if (text.isEmpty) {
      return const SizedBox.shrink();
    }
    return Card(
      child: InkWell(
        onTap: () {
          if (blocked) {
            showMclashAccountGateDialog(context);
          } else {
            MainTabController.instance?.setTab(2);
          }
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
          child: Row(
            children: [
              Icon(
                blocked ? Icons.error_outline : Icons.workspace_premium_outlined,
                size: 16,
                color: blocked ? Colors.red : ThemeDefine.kColorBlue,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    color: blocked ? Colors.red : null,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 16,
                color: ThemeDefine.kColorGrey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 主页「快速筛选国家」：**延迟最低的 6 个国家，两排**。
///
/// 点一个国家不只是筛选列表，而是**真的切到该国最快的节点** —— 用户点国家
/// 的本意就是「我要走这个国家」，只筛选不切换等于没反应。
class MclashQuickCountries extends StatelessWidget {
  const MclashQuickCountries({super.key});

  static const int kCountryCount = 6;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: MclashNodesStore.instance,
      builder: (context, _) {
        final store = MclashNodesStore.instance;
        final codes = store.topCountries(limit: kCountryCount);
        if (codes.isEmpty) {
          return const SizedBox.shrink();
        }
        final latency = store.bestLatencyByCountry;
        return Card(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      "快速筛选国家",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: ThemeConfig.kFontWeightListItem,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      "${store.nodes.length} 个节点",
                      style: const TextStyle(
                        fontSize: 11,
                        color: ThemeDefine.kColorGrey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // 「自动最优」：解除国家限制，让内核/自动选路挑最快节点
                // （参考客户端 MoneyFly 的快捷栏就有这一项，用户按国家点几下
                //   之后需要一个「回到自动」的出口）。
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: ActionChip(
                    key: const ValueKey("home-country-auto-best"),
                    avatar: const Icon(Icons.auto_awesome, size: 15),
                    label: const Text("自动最优", style: TextStyle(fontSize: 12)),
                    onPressed: () => _onTapAutoBest(context),
                  ),
                ),
                // 两排：每排 3 个（共 6 个，延迟最低的优先）
                for (var row = 0; row < 2; row++)
                  Padding(
                    padding: EdgeInsets.only(top: row == 0 ? 0 : 8),
                    child: Row(
                      children: [
                        for (var col = 0; col < 3; col++)
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(left: col == 0 ? 0 : 8),
                              child: _countryChip(
                                context,
                                store,
                                codes,
                                row * 3 + col,
                                latency,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _countryChip(
    BuildContext context,
    MclashNodesStore store,
    List<String> codes,
    int index,
    Map<String, int> latency,
  ) {
    if (index >= codes.length) {
      return const SizedBox.shrink();
    }
    final code = codes[index];
    final ms = latency[code];
    return InkWell(
      key: ValueKey("home-country-$code"),
      borderRadius: BorderRadius.circular(10),
      onTap: () => _onTapCountry(context, store, code),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
        decoration: BoxDecoration(
          border: Border.all(color: ThemeDefine.kColorGrey, width: 0.6),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                "${MclashNodeCountry.flagFor(code)} "
                "${code == "XX" ? "其他" : MclashNodeCountry.displayName(code)}",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12),
              ),
            ),
            if (ms != null) ...[
              const SizedBox(width: 4),
              Text(
                "${ms}ms",
                style: TextStyle(
                  fontSize: 11,
                  color: ms < 800
                      ? ThemeDefine.kColorGreenBright
                      : ThemeDefine.kColorGrey,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 「自动最优」：让自动选路挑一个最快节点，并留在主页。
  Future<void> _onTapAutoBest(BuildContext context) async {
    // 「自动最优」= 解除固定，回到自动选路（参考客户端的「自动最优」同义）
    await MclashNodeAutoPick.setFixedNode("");
    final note = await MclashNodeAutoPick.selectBestOnConnect();
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(note == null ? "已在自动选路（最优节点）" : "已切换到最优节点：$note")),
    );
  }

  Future<void> _onTapCountry(
    BuildContext context,
    MclashNodesStore store,
    String code,
  ) async {
    // 只做「切到该国最快节点」这一件事，并且**留在主页**：
    // 用户反馈点国家会跳到节点列表整页，他想要的是主页自己的独立选项。
    // （也不再顺手改节点列表的筛选条件 —— 那属于「节点列表」页自己的状态，
    //   主页点一下却让另一个页面变样子，同样是意外行为。）
    final node = store.preferredNodeOfCountry(code);
    if (node == null) {
      return;
    }
    final country = code == "XX"
        ? "其他"
        : MclashNodeCountry.displayName(code);
    final err = await MclashNodeSelector.select(node.name);
    if (!context.mounted) {
      return;
    }
    final ms = node.latencyUsable ? "（${node.latencyMs}ms）" : "";
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          err == null
              ? "已切换到 $country 最快节点：${node.name}$ms"
              : "已筛选 $country；切换节点失败：${err.message}",
        ),
      ),
    );
  }
}

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

        MainTabController.instance?.setTab(3);
      }
      return;

    case MclashBlockKind.accountDisabled:
    case MclashBlockKind.subscriptionDisabled:
    case MclashBlockKind.serverUnavailable:
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

Future<bool> mclashCheckAccountGate(BuildContext context) async {
  final acc = MclashAccountService.instance;
  if (!acc.isBlocked) {
    return true;
  }
  await showMclashAccountGateDialog(context);
  return false;
}
