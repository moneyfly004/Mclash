
library;

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:mclash/app/utils/app_utils.dart';
import 'package:mclash/app/utils/log.dart';
import 'package:mclash/i18n/strings.g.dart';
import 'package:mclash/mf/mclash_account_service.dart';
import 'package:mclash/mf/mclash_entitlement.dart';
import 'package:mclash/screens/dialog_utils.dart';
import 'package:mclash/screens/devices/mclash_devices_screen.dart';
import 'package:mclash/screens/main_tab_shell.dart';
import 'package:mclash/mf/mclash_account_info.dart';
import 'package:mclash/mf/mclash_node_country.dart';
import 'package:mclash/screens/mclash_country_label.dart';
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
    final t = Translations.of(context);
    final info = MclashAccountInfo(acc.dashboard, acc.subscription);
    final blocked = acc.isBlocked;
    final parts = <String>[
      if (info.planName.isNotEmpty) info.planName,
      if (info.expireDate.isNotEmpty) t.homeScreen.expiresOn(date: info.expireDate),
      if (info.deviceText != null) t.homeScreen.devicesText(text: info.deviceText!),
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

/// 设备名额用满时的**非阻断**提示条。
///
/// 与 [MclashSubscriptionCard] 的红色受限提示是两件事（真机报障的核心区别）：
///  · 名额用满（`used == limit`）≠ 本机被拒绝。上限 5 台时第 5 台用的就是最后一个
///    合法名额，必须能正常更新订阅、正常连接；这里只提示"再加新设备要升级"，
///    **绝不拦连接**，也绝不置灰首页的连接开关。
///  · 真正被服务端拒绝的设备（第 6 台：订阅只下发伪节点）走红色受限提示 +
///    授权闸门（[MclashAccountService.blockKind] 的 deviceFull）。
class MclashDeviceQuotaBar extends StatelessWidget {
  const MclashDeviceQuotaBar({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    return AnimatedBuilder(
      animation: MclashAccountService.instance,
      builder: (context, _) {
        final hint = MclashAccountService.instance.deviceQuotaHint;
        if (hint.isEmpty) {
          return const SizedBox.shrink();
        }
        return Container(
          key: const ValueKey("home-device-quota-bar"),
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
          decoration: BoxDecoration(
            color: ThemeDefine.kColorBlue.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: ThemeDefine.kColorBlue.withValues(alpha: 0.4),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.devices_other,
                size: 18,
                color: ThemeDefine.kColorBlue,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  hint,
                  style: const TextStyle(fontSize: 12, height: 1.35),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const MclashDevicesScreen(autoOpenUpgrade: true),
                  ),
                ),
                child: Text(t.homeScreen.upgrade),
              ),
            ],
          ),
        );
      },
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
    final t = Translations.of(context);
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
                    Text(
                      t.homeScreen.quickCountries,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: ThemeConfig.kFontWeightListItem,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      t.homeScreen.nodeCount(count: store.nodes.length),
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
                    message: t.homeScreen.autoBestTip,
                    child: ActionChip(
                      key: const ValueKey("home-country-auto-best"),
                      avatar: const Icon(Icons.auto_awesome, size: 15),
                      label: Text(
                        t.homeScreen.autoBest,
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
    final t = Translations.of(context);
    final code = codes[index];
    final ms = latency[code];
    final label = MclashCountryLabel.of(context, code);
    return Tooltip(
      // 悬停提示要说清"点了会发生什么"：在该国里自动挑最优，并固定下来。
      message: t.homeScreen.pickCountryTip(label: label),
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
    final t = Translations.of(context);
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
      // 界面立刻跟着变（内核事实稍后会再对齐一次）。
      MclashNodesStore.instance.setCurrentNodeName(picked);
      // ⚠️ 必须显式通知一次：主页那一行绑的是 `onNodeSwitched`（→ `_updateProxyNow`），
      // 只有 `setCurrentNodeName` 的话它要等 15 秒周期轮询才刷新 ——
      // 真机走查实测「自动最优」后主页最长 ~11s 还显示旧节点（手动点选只要 23~702ms）。
      MclashNodesStore.instance.notifyCurrentMaybeChanged();
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          picked == null
              ? t.homeScreen.autoNoBetter
              : t.homeScreen.switchedBest(name: picked),
        ),
      ),
    );
  }

  Future<void> _onTapCountry(
    BuildContext context,
    MclashNodesStore store,
    String code,
  ) async {
    final t = Translations.of(context);
    // 该国延迟最低的可用节点（测过速的才算数）；实在没有可用的才退回第一个。
    final node =
        store.bestNodeOfCountry(code) ?? store.preferredNodeOfCountry(code);
    if (node == null) {
      return;
    }
    final country = MclashCountryLabel.of(context, code);
    // 和「切换」/节点列表等效：切内核 + 固定下来（下次连接仍是它）。
    final err = await MclashNodeSelector.select(node.name);
    if (!context.mounted) {
      return;
    }
    // 延迟后缀也要走 i18n：英文界面下出现全角括号「（30ms）」很奇怪
    // （真机走查：Switched to the fastest Japan node: 日本线路1（30ms））。
    final ms = node.latencyUsable
        ? t.homeScreen.latencySuffix(ms: node.latencyMs)
        : "";
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          err == null
              ? t.homeScreen.switchedCountry(country: country, node: node.name, ms: ms)
              : t.homeScreen.filterCountryFailed(country: country, err: err.message),
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
  final t = Translations.of(context);
  final used = acc.info.deviceUsed ?? 0;
  final limit = acc.info.deviceLimit ?? 0;
  final countText = (used > 0 && limit > 0)
      ? t.homeScreen.deviceFullCount(used: used, limit: limit)
      : "";
  final text =
      "${acc.blockEmoji}\n${acc.blockTitle}\n\n"
      "$countText"
      "${t.homeScreen.deviceFullUpgradeHint}";
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
              child: Text(t.homeScreen.later),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: () =>
                  Navigator.pop(dialogContext, _DeviceFullChoice.manage),
              child: Text(t.meScreen.deviceManagement),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: () =>
                  Navigator.pop(dialogContext, _DeviceFullChoice.upgrade),
              child: Text(t.homeScreen.upgradeDeviceCount),
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

/// 名额用满时的非阻断提示（同一档 used/limit 每次运行只提示一次，
/// 避免用户每次点连接都弹一条）。
String _quotaHintShownKey = "";

/// 名额用满：**只提示，不拦连接**。
///
/// 第 5 台设备（上限 5 台）就属于这种情况 —— 它在授权范围内，必须放行。
void _hintDeviceQuotaIfNeeded(BuildContext context, MclashAccountService acc) {
  final t = Translations.of(context);
  final hint = acc.deviceQuotaHint;
  if (hint.isEmpty) {
    return;
  }
  final key = "${acc.info.deviceUsed}/${acc.info.deviceLimit}";
  if (_quotaHintShownKey == key) {
    return;
  }
  _quotaHintShownKey = key;
  Log.i("mclashCheckAccountGate: 设备名额已用满（$key）→ 放行连接，仅提示升级");
  final messenger = ScaffoldMessenger.maybeOf(context);
  messenger?.showSnackBar(
    SnackBar(
      content: Text(hint),
      duration: const Duration(seconds: 6),
      action: SnackBarAction(
        label: t.homeScreen.upgrade,
        onPressed: () {
          if (!context.mounted) {
            return;
          }
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const MclashDevicesScreen(autoOpenUpgrade: true),
            ),
          );
        },
      ),
    ),
  );
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
    // 名额用满 ≠ 本机被拒绝：上限 5 台时的第 5 台仍然合法，必须能连上。
    // 这里只做一次非阻断的升级提示（提示完照样返回 true 放行）。
    if (context.mounted) {
      _hintDeviceQuotaIfNeeded(context, acc);
    }
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
  final t = Translations.of(context);
  final title = decision.title.isEmpty ? t.homeScreen.cannotConnect : decision.title;
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

  /// 静态方法拿不到 context，所以文案库由调用方传进来（测试也照此调用）。
  static String freshnessText(
    Translations t,
    DateTime? cachedAt, {
    DateTime? now,
  }) {
    if (cachedAt == null) {
      return t.homeScreen.freshnessNever;
    }
    final diff = (now ?? DateTime.now()).difference(cachedAt);
    if (diff.inMinutes < 1) {
      return t.homeScreen.freshnessJustNow;
    }
    if (diff < kStaleAfter) {
      return t.homeScreen.freshnessMinutes(minutes: diff.inMinutes);
    }
    return t.homeScreen.freshnessStale(minutes: diff.inMinutes);
  }

  static bool isStale(DateTime? cachedAt, {DateTime? now}) {
    if (cachedAt == null) {
      return true;
    }
    return (now ?? DateTime.now()).difference(cachedAt) >= kStaleAfter;
  }

  /// 顶栏右上信息条要显示的文本（真机报障：换语言后顶栏错位，故文本与排版分开算）。
  static String subscriptionText(
    Translations t,
    MclashAccountInfo info, {
    required bool blocked,
    required String blockedTitle,
  }) {
    if (blocked) {
      return blockedTitle;
    }
    final used = info.deviceUsed;
    final limit = info.deviceLimit;
    final deviceText = (used != null || limit != null)
        ? "${used ?? "-"}/${limit ?? "-"}"
        : (info.deviceText ?? "").replaceAll(" ", "");
    final bits = <String>[
      if (info.expireDate.isNotEmpty)
        t.homeScreen.expiresOn(date: info.expireDate),
      if (deviceText.isNotEmpty) t.homeScreen.devicesText(text: deviceText),
    ];
    return bits.join(" · ");
  }

  /// 用真实字体量一段文本的宽度（含系统字体缩放）。
  ///
  /// 真机报障：中文界面下顶栏排列正常，**切成其它语言（俄语/西语/阿拉伯语…）就乱了** ——
  /// 文案变长后原来那套固定排版会顶出屏幕。所以这里按语言实测宽度再决定"一行"还是"上下两行"。
  static double measureTextWidth(
    BuildContext context,
    String text,
    TextStyle style,
  ) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: Directionality.of(context),
      maxLines: 1,
      textScaler: MediaQuery.textScalerOf(context),
    )..layout();
    return painter.width;
  }

  static const TextStyle _kBrandNameStyle = TextStyle(
    fontSize: 15,
    fontWeight: ThemeConfig.kFontWeightTitle,
    height: 1.15,
  );

  static const TextStyle _kBrandSubStyle = TextStyle(
    fontSize: 10.5,
    color: ThemeDefine.kColorGrey,
    height: 1.2,
  );

  static const double _kLogoSize = 24;
  static const double _kLogoGap = 8;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: MclashAccountService.instance,
      builder: (context, _) {
        final t = Translations.of(context);
        final acc = MclashAccountService.instance;
        final info = MclashAccountInfo(acc.dashboard, acc.subscription);
        final blocked = acc.isBlocked;
        final cachedAt = acc.cachedAt;
        final pillText = subscriptionText(
          t,
          info,
          blocked: blocked,
          blockedTitle: blocked ? "${acc.blockEmoji} ${acc.blockTitle}" : "",
        );
        final pill = pillText.isEmpty
            ? const SizedBox.shrink()
            : _subscriptionPill(context, text: pillText, blocked: blocked);
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LayoutBuilder(
                builder: (context, c) {
                  final brand = _brand(t);
                  // 估算两块内容各要多少宽：品牌块 = logo + 间距 + 两行文字里较宽的一行；
                  // 信息条 = 内边距 + 图标 + 文字 + 展开箭头。
                  final brandNeed = _kLogoSize +
                      _kLogoGap +
                      math.max(
                        measureTextWidth(context, AppUtils.getName(),
                            _kBrandNameStyle),
                        measureTextWidth(
                            context, t.homeScreen.subscriptionAutoSync,
                            _kBrandSubStyle),
                      );
                  final pillNeed = pillText.isEmpty
                      ? 0.0
                      : 10 +
                          14 +
                          5 +
                          measureTextWidth(
                              context, pillText, const TextStyle(fontSize: 12)) +
                          15 +
                          8;
                  final fits =
                      brandNeed + 10 + pillNeed <= c.maxWidth && pillNeed > 0;
                  if (!fits) {
                    // 放不下就上下排（不裁字、不溢出）：长文案语言与窄屏走这里。
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        brand,
                        if (pillText.isNotEmpty) const SizedBox(height: 6),
                        if (pillText.isNotEmpty) pill,
                      ],
                    );
                  }
                  // 品牌块占剩余宽度，信息条按内容宽度靠右（spaceBetween 的等效写法，
                  // 且任何语言下都不会互相挤压）。
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(child: brand),
                      const SizedBox(width: 10),
                      pill,
                    ],
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
                  // 缩进对齐品牌文字：用方向相关的 start，阿拉伯语等 RTL 语言才不会露馅。
                  padding: const EdgeInsetsDirectional.only(start: 32),
                  child: Row(
                    children: [
                      Icon(
                        isStale(cachedAt)
                            ? Icons.refresh
                            : Icons.check_circle_outline,
                        size: 12,
                        color: ThemeDefine.kColorGrey,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          freshnessText(t, cachedAt),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 10.5,
                            color: ThemeDefine.kColorGrey,
                          ),
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

  Widget _brand(Translations t) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          "assets/images/logo-round.png",
          width: _kLogoSize,
          height: _kLogoSize,
          filterQuality: FilterQuality.medium,
        ),
        const SizedBox(width: _kLogoGap),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppUtils.getName(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _kBrandNameStyle,
              ),
              Text(
                t.homeScreen.subscriptionAutoSync,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _kBrandSubStyle,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _subscriptionPill(
    BuildContext context, {
    required String text,
    required bool blocked,
  }) {
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
            Icon(
              // RTL 语言（阿拉伯语/波斯语）箭头要朝左，否则方向感是反的。
              Directionality.of(context) == TextDirection.rtl
                  ? Icons.chevron_left
                  : Icons.chevron_right,
              size: 15,
              color: ThemeDefine.kColorGrey,
            ),
          ],
        ),
      ),
    );
  }
}
