
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mclash/app/utils/app_utils.dart';
import 'package:mclash/app/utils/log.dart';
import 'package:mclash/mf/mclash_account_service.dart';
import 'package:mclash/mf/mclash_entitlement.dart';
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
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Tooltip(
                    message: "在所有国家的节点里挑延迟最低的可用节点（自动模式）",
                    child: ActionChip(
                      key: const ValueKey("home-country-auto-best"),
                      avatar: const Icon(Icons.auto_awesome, size: 15),
                      label: const Text(
                        "自动最优",
                        style: TextStyle(fontSize: 12),
                      ),
                      onPressed: () => _onTapAutoBest(context),
                    ),
                  ),
                ),
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
    final label = code == "XX"
        ? "其他"
        : MclashNodeCountry.displayName(code);
    return Tooltip(
      // 悬停提示要说清"点了会发生什么"：在该国里自动挑最优，并固定下来。
      message: "自动选择「$label」延迟最低的可用节点，并固定使用它",
      child: InkWell(
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
                  "${MclashNodeCountry.flagFor(code)} $label",
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
      ),
    );
  }

  Future<void> _onTapAutoBest(BuildContext context) async {
    // 「自动最优」= 回到自动模式：清掉固定节点，然后在**所有国家**的节点里重新挑
    // 一次延迟最低的可用节点。
    //
    //  - force: 必须绕过「用户刚手动选过节点」的保护，否则刚切过节点的人点
    //    「自动最优」会被自己上一次的选择挡住（点了没反应）。
    //  - persist=false: 自动模式不该把自己锁死在某一台上，下次连接重新挑。
    await MclashNodeAutoPick.setFixedNode("");
    final picked = await MclashNodeAutoPick.selectBestOnConnect(
      // 用 App 已经测过的全量延迟（494 个节点都测过）选优 —— 不传的话只能
      // 探测十几个候选，那就不是"所有国家里最低"了。
      cachedLatency: MclashNodesStore.instance.latencyByName(),
      force: true,
      persist: false,
    );
    if (!context.mounted) {
      return;
    }
    if (picked != null && picked.isNotEmpty) {
      // 界面立刻跟着变（内核事实稍后会再对齐一次）
      MclashNodesStore.instance.setCurrentNodeName(picked);
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          picked == null
              ? "已在自动模式（没有找到更优的可用节点）"
              : "已切换到最优节点：$picked",
        ),
      ),
    );
  }

  Future<void> _onTapCountry(
    BuildContext context,
    MclashNodesStore store,
    String code,
  ) async {
    // 该国延迟最低的可用节点（测过速的才算数）；实在没有可用的才退回第一个。
    final node =
        store.bestNodeOfCountry(code) ?? store.preferredNodeOfCountry(code);
    if (node == null) {
      return;
    }
    final country = code == "XX"
        ? "其他"
        : MclashNodeCountry.displayName(code);
    // 和「切换」/节点列表等效：切内核 + 固定下来（下次连接仍是它）。
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

enum _DeviceFullChoice { upgrade, manage }

/// 设备数量超限：**优先引导升级**，其次才是删设备。
/// 两个按钮各自跳到设备页（升级那条会直接把升级面板弹出来）。
Future<_DeviceFullChoice?> _showDeviceFullDialog(
  BuildContext context,
  MclashAccountService acc,
) async {
  if (!context.mounted) {
    return null;
  }
  final used = acc.info.deviceUsed ?? 0;
  final limit = acc.info.deviceLimit ?? 0;
  final countText = (used > 0 && limit > 0) ? "当前设备 $used/$limit 台\n\n" : "";
  final text =
      "${acc.blockEmoji}\n${acc.blockTitle}\n\n"
      "$countText"
      "升级设备数量后可立即恢复连接（推荐）；"
      "也可以先删除不常用的设备腾出名额。";
  return showDialog<_DeviceFullChoice>(
    context: context,
    routeSettings: const RouteSettings(name: "showDeviceFullDialog"),
    barrierDismissible: false,
    builder: (dialogContext) => SimpleDialog(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Text(
            text,
            maxLines: 20,
            style: const TextStyle(
              fontSize: ThemeConfig.kFontSizeListSubItem,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, null),
              child: const Text("稍后"),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: () =>
                  Navigator.pop(dialogContext, _DeviceFullChoice.manage),
              child: const Text("设备管理"),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: () =>
                  Navigator.pop(dialogContext, _DeviceFullChoice.upgrade),
              child: const Text("升级设备数量"),
            ),
          ],
        ),
        const SizedBox(height: 20),
      ],
    ),
  );
}

Future<void> showMclashAccountGateDialog(BuildContext context) async {
  final acc = MclashAccountService.instance;
  final kind = acc.blockKind;

  switch (kind) {
    case MclashBlockKind.deviceFull:
      final choice = await _showDeviceFullDialog(context, acc);
      if (!context.mounted) {
        return;
      }
      if (choice == _DeviceFullChoice.upgrade) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const MclashDevicesScreen(autoOpenUpgrade: true),
          ),
        );
      } else if (choice == _DeviceFullChoice.manage) {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const MclashDevicesScreen()),
        );
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

/// 连接前的账号/授权闸门。
///
/// 两道：
///  1. [MclashEntitlement.check] —— 授权租约（到期时间 / 封禁状态 / 校验新鲜度）。
///     这一道**离线也生效**：过期的用户即使还留着旧的本地配置档，同样连不上。
///  2. 账号受限复核 —— 设备超限这类可自助修复的场景给更具体的文案。
Future<bool> mclashCheckAccountGate(BuildContext context) async {
  final decision = await MclashEntitlement.check();
  if (!decision.allowed) {
    Log.w(
      "mclashCheckAccountGate: 已拦截连接（${decision.state.name}）${decision.title}",
    );
    if (!context.mounted) {
      return false;
    }
    // 服务端下发的受限（到期/封禁的伪节点）自带具体原因与解决方式：
    // 这种情况用富文本弹窗，把「❌原因 / ⏰到期 / 💡解决 / 📢官网 / 💬客服」原样给到客户，
    // 而不是只丢一句笼统提示。租约自身的原因（需联网校验/时间异常）才用简化弹窗。
    //
    // ⚠️ 弹窗**不能 await**：调用方（首页开关）在这之后要立刻把「正在连接…」的
    // 乐观状态收掉，await 弹窗会让它一直挂着转圈（widget 测试已抓到过这个回归）。
    if (MclashAccountService.instance.isBlocked) {
      unawaited(showMclashAccountGateDialog(context));
    } else {
      unawaited(_showEntitlementGateDialog(context, decision));
    }
    return false;
  }

  final acc = MclashAccountService.instance;
  if (!acc.isBlocked) {
    return true;
  }
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

Future<void> _showEntitlementGateDialog(
  BuildContext context,
  MclashEntitlementDecision decision,
) async {
  final title = decision.title.isEmpty ? "无法连接" : decision.title;
  final message = decision.message.isEmpty ? title : decision.message;
  try {
    await DialogUtils.showAlertDialog(
      context,
      "$title\n\n$message",
      showCopy: true,
      showFAQ: true,
      withVersion: true,
    );
  } catch (err) {
    Log.w("mclashCheckAccountGate: 弹出提示失败 $err");
  }
}


class MclashHomeHeader extends StatelessWidget {
  const MclashHomeHeader({super.key});

  static const Duration kStaleAfter = Duration(minutes: 5);

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
              LayoutBuilder(
                builder: (context, c) {
                  final brand = _brand();
                  if (c.maxWidth < 300) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        brand,
                        const SizedBox(height: 6),
                        pill,
                      ],
                    );
                  }
                  return Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 6,
                    children: [brand, pill],
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

  Widget _subscriptionPill(
    BuildContext context, {
    required MclashAccountInfo info,
    required bool blocked,
    required String blockedTitle,
  }) {
    final used = info.deviceUsed;
    final limit = info.deviceLimit;
    final deviceText = (used != null || limit != null)
        ? "${used ?? "-"}/${limit ?? "-"}"
        : (info.deviceText ?? "").replaceAll(" ", "");
    final bits = <String>[
      if (info.expireDate.isNotEmpty) "到期 ${info.expireDate}",
      if (deviceText.isNotEmpty) "设备 $deviceText",
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
