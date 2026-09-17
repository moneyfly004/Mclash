
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mclash/app/utils/app_utils.dart';
import 'package:mclash/app/utils/log.dart';
import 'package:mclash/mf/mclash_account_service.dart';
import 'package:mclash/screens/dialog_utils.dart';
import 'package:mclash/screens/devices/mclash_devices_screen.dart';
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
  // 判定可能来自启动时回填的旧缓存 —— 直接用它会出真实事故：
  // 用户在官网续费/删设备之后，客户端还按旧数据把人拦住，连都连不上。
  // 所以真拦之前先复核一次（拿到最新数据后仍受限才拦）。
  final kind = await acc.verifyBeforeConnect();
  if (kind == MclashBlockKind.none) {
    Log.i("mclashCheckAccountGate: 复核后账号已恢复正常，放行连接");
    return true;
  }
  if (!context.mounted) {
    return false;
  }
  await showMclashAccountGateDialog(context);
  return false;
}


/// 主页顶栏：**标志缩小靠左上，到期/设备信息条放在标志右侧、连接卡上方**。
///
/// 用户实测反馈：
///   * 「主页上 Mclash 的标志太大」——原来是 18px 居中大字 + 一行副标题，占掉整行；
///   * 「到期设备的信息应该放在连接按钮上方、标志右侧」——原来那张卡在连接卡**下方**；
///   * 「卡片数据没同步」——卡片取的就是账号服务的数据（后端口径），
///     这里补一条**新鲜度**提示，过期时点一下立刻刷新，避免「看着像没更新」。
///
/// 点信息条 → 设备管理（当前设备列表、删除旧记录都在那里）。
class MclashHomeHeader extends StatelessWidget {
  const MclashHomeHeader({super.key});

  /// 数据超过这个时长就提示「点击刷新」。
  static const Duration kStaleAfter = Duration(minutes: 5);

  /// 新鲜度文案（纯函数，便于测试）。[cachedAt] 为空 = 还没成功拉过。
  static String freshnessText(DateTime? cachedAt, {DateTime? now}) {
    if (cachedAt == null) {
      return "尚未同步 · 点击刷新";
    }
    final diff = (now ?? DateTime.now()).difference(cachedAt);
    if (diff.inMinutes < 1) {
      return "刚刚更新 · 点右侧管理设备";
    }
    if (diff < kStaleAfter) {
      return "${diff.inMinutes} 分钟前更新 · 点右侧管理设备";
    }
    return "${diff.inMinutes} 分钟前更新 · 点击刷新";
  }

  static bool isStale(DateTime? cachedAt, {DateTime? now}) {
    if (cachedAt == null) {
      return true;
    }
    return (now ?? DateTime.now()).difference(cachedAt) >= kStaleAfter;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: MclashAccountService.instance,
      builder: (context, _) {
        final acc = MclashAccountService.instance;
        final info = MclashAccountInfo(acc.dashboard, acc.subscription);
        final blocked = acc.isBlocked;
        final cachedAt = acc.cachedAt;
        final pill = _subscriptionPill(
          context,
          info: info,
          blocked: blocked,
          blockedTitle: blocked ? "${acc.blockEmoji} ${acc.blockTitle}" : "",
        );
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 窄屏（手机）折行：标志一行，信息条紧随其下，仍然在连接卡之前
              LayoutBuilder(
                builder: (context, c) {
                  final brand = _brand();
                  if (c.maxWidth < 340) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        brand,
                        const SizedBox(height: 8),
                        Align(alignment: Alignment.centerRight, child: pill),
                      ],
                    );
                  }
                  return Row(
                    children: [brand, const Spacer(), Flexible(child: pill)],
                  );
                },
              ),
              const SizedBox(height: 3),
              GestureDetector(
                key: const ValueKey("home-freshness"),
                onTap: () {
                  if (isStale(cachedAt)) {
                    unawaited(MclashAccountService.instance.refresh());
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.only(left: 32),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isStale(cachedAt)
                            ? Icons.refresh
                            : Icons.check_circle_outline,
                        size: 12,
                        color: ThemeDefine.kColorGrey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        freshnessText(cachedAt),
                        style: const TextStyle(
                          fontSize: 10.5,
                          color: ThemeDefine.kColorGrey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 左侧标志：真实 logo（24px）+ 应用名（15px）+ 一行 10.5px 副标题。
  Widget _brand() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          "assets/images/logo-round.png",
          width: 24,
          height: 24,
          filterQuality: FilterQuality.medium,
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppUtils.getName(),
              style: const TextStyle(
                fontSize: 15,
                fontWeight: ThemeConfig.kFontWeightTitle,
                height: 1.15,
              ),
            ),
            const Text(
              "订阅自动同步",
              style: TextStyle(
                fontSize: 10.5,
                color: ThemeDefine.kColorGrey,
                height: 1.2,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 右侧信息条：到期时间 + 设备数；点一下进设备管理。
  Widget _subscriptionPill(
    BuildContext context, {
    required MclashAccountInfo info,
    required bool blocked,
    required String blockedTitle,
  }) {
    final bits = <String>[
      if (info.expireDate.isNotEmpty) "到期 ${info.expireDate}",
      if (info.deviceText != null) "设备 ${info.deviceText}",
    ];
    final text = blocked ? blockedTitle : bits.join(" · ");
    if (text.isEmpty) {
      return const SizedBox.shrink();
    }
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      key: const ValueKey("home-sub-pill"),
      borderRadius: BorderRadius.circular(999),
      onTap: () {
        if (blocked) {
          showMclashAccountGateDialog(context);
          return;
        }
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const MclashDevicesScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 5, 8, 5),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              blocked ? Icons.error_outline : Icons.workspace_premium_outlined,
              size: 14,
              color: blocked ? Colors.red : ThemeDefine.kColorBlue,
            ),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  color: blocked ? Colors.red : null,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              size: 15,
              color: ThemeDefine.kColorGrey,
            ),
          ],
        ),
      ),
    );
  }
}
