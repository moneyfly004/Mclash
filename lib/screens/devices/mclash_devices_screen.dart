
library;

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mclash/mf/mclash_account_info.dart';
import 'package:mclash/app/utils/log.dart';
import 'package:mclash/mf/mclash_device_upgrade.dart';
import 'package:mclash/mf/mclash_device_view.dart';
import 'package:mclash/mf/mclash_payment.dart';
import 'package:mclash/mf/mclash_account_service.dart';
import 'package:mclash/mf/mclash_api.dart';
import 'package:mclash/screens/payment/mclash_payment_sheet.dart';
import 'package:mclash/screens/dialog_utils.dart';
import 'package:mclash/screens/main_tab_shell.dart';
import 'package:mclash/screens/theme_config.dart';
import 'package:mclash/screens/theme_define.dart';
import 'package:mclash/screens/widgets/framework.dart';

class MclashDevicesScreen extends LasyRenderingStatefulWidget {
  const MclashDevicesScreen({super.key});

  @override
  State<MclashDevicesScreen> createState() => _MclashDevicesScreenState();
}

class _MclashDevicesScreenState extends LasyRenderingState<MclashDevicesScreen> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _items = [];

  @override
  void initState() {
    super.initState();
    // 面板改了「设备上限 / 到期时间」后要立刻能看到：
    //   * 打开本页补一次账号刷新（不必等 5 分钟定时器）；
    //   * 并监听账号服务 —— 以前这里只读一次快照，账号更新了界面也不重建，
    //     用户看到的就是「后台改了，软件没更新」。
    MclashAccountService.instance.addListener(_onAccountChanged);
    unawaited(MclashAccountService.instance.refreshIfStale());
    _load();
  }

  @override
  void dispose() {
    MclashAccountService.instance.removeListener(_onAccountChanged);
    super.dispose();
  }

  void _onAccountChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  /// 右上角刷新：设备列表与账号信息（设备上限/到期时间）一起刷新。
  Future<void> _refreshAll() async {
    await Future.wait([
      _load(),
      MclashAccountService.instance.refresh(),
    ]);
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final items = await MclashApi.subscriptionDevices();
      if (!mounted) return;
      setState(() {
        _items = items;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = "$e";
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: PreferredSize(preferredSize: Size.zero, child: AppBar()),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: const SizedBox(
                      width: 50,
                      height: 44,
                      child: Icon(Icons.arrow_back_ios_outlined, size: 26),
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      "设备管理",
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: ThemeConfig.kFontWeightTitle,
                        fontSize: ThemeConfig.kFontSizeTitle,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 50,
                    height: 44,
                    child: _loading
                        ? const Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : InkWell(
                            onTap: _refreshAll,
                            child: const Icon(Icons.refresh, size: 26),
                          ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Expanded(
                child: _error != null
                    ? Center(
                        child: Text(
                          _error!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      )
                    : ListView(
                        padding: const EdgeInsets.only(bottom: 24),
                        children: [
                          _buildUpgradeCard(),
                          for (final d in _items) _buildDevice(d),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUpgradeCard() {
    final info = MclashAccountInfo(
      MclashAccountService.instance.dashboard,
      MclashAccountService.instance.subscription,
    );
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        child: Column(
          children: [
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: Text(
                    info.planName.isNotEmpty ? info.planName : "当前套餐",
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: ThemeConfig.kFontWeightListItem,
                    ),
                  ),
                ),
                Text(
                  "设备 ${info.deviceText ?? "-"}",
                  style: const TextStyle(
                    fontSize: 13,
                    color: ThemeDefine.kColorGrey,
                  ),
                ),
              ],
            ),
            const Divider(height: 24, thickness: 0.3),
            // 一个入口搞定：以前分成「加设备数」「加时长」两个入口，用户想同时
            // 加台数和天数就做不到（必须分两次下单、付两次钱）。
            _upgradeRow(
              Icons.add_circle_outline,
              "升级设备数 / 延长时长",
              "可同时增加台数与天数，一起算价一次支付",
              _showUpgradeSheet,
            ),
            const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }

  Widget _upgradeRow(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: Icon(icon, size: 20),
    title: Text(title, style: const TextStyle(fontSize: 15)),
    subtitle: Text(
      subtitle,
      style: const TextStyle(fontSize: 11, color: ThemeDefine.kColorGrey),
    ),
    trailing: const Icon(Icons.chevron_right, size: 20),
    onTap: onTap,
  );

  /// 升级面板：**设备台数与天数是同一张面板里的两组选择**。
  ///
  /// 旧实现分两张面板，用户没法「既加台数又加时长」；而且面板打开时**不发起
  /// 算价**，价格停在 ¥0.00、按钮禁用 —— 用户看到的就是「获取价格失败 / 付不了款」。
  Future<void> _showUpgradeSheet() async {
    var addDevices = 0;
    var addDays = 0;
    Map<String, dynamic> quote = const {};
    var quoting = false;
    String? quoteError;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            Future<void> refreshQuote() async {
              // 两项都选 0 时没有意义，不算价（也不建草稿订单）
              if (addDevices <= 0 && addDays <= 0) {
                setSheetState(() {
                  quote = const {};
                  quoteError = null;
                });
                return;
              }
              setSheetState(() {
                quoting = true;
                quoteError = null;
              });
              try {
                final d = await MclashDeviceUpgrade.quote(
                  addDevices: addDevices,
                  addDays: addDays,
                );
                _lastQuoteOrderId = (d["id"] as num?)?.toInt() ?? 0;
                if (!sheetContext.mounted) {
                  return;
                }
                setSheetState(() => quote = d);
              } catch (e) {
                if (!sheetContext.mounted) {
                  return;
                }
                setSheetState(() {
                  quoteError = _friendlyQuoteError(
                    e,
                    addDevices: addDevices,
                    addDays: addDays,
                  );
                });
              } finally {
                if (sheetContext.mounted) {
                  setSheetState(() => quoting = false);
                }
              }
            }

            if (quote.isEmpty && quoteError == null && !quoting) {
              // 首帧就开算（默认 +1 台），避免用户看到 ¥0.00 的空面板
              addDevices = addDevices == 0 && addDays == 0 ? 1 : addDevices;
              WidgetsBinding.instance.addPostFrameCallback(
                (_) => refreshQuote(),
              );
            }

            final amount = MclashDeviceUpgrade.amountOf(quote);
            final orderNo = (quote["order_no"] ?? "").toString();
            final canPay = !quoting && quoteError == null && amount > 0;
            // 「升级后」的结果必须显示出来：以前只显示金额，用户看不到设备数/到期
            // 时间有没有变 —— 「增加天数」被后端忽略的问题就是因为看不见才没被发现。
            final newLimit = MclashDeviceUpgrade.newDeviceLimitOf(quote);
            final newExpire = MclashDeviceUpgrade.newExpireTimeOf(quote);

            return Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                16,
                20,
                20 + MediaQuery.of(sheetContext).padding.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "升级设备数 / 延长时长",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: ThemeConfig.kFontWeightTitle,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    "增加台数",
                    style: TextStyle(
                      fontSize: 12,
                      color: ThemeDefine.kColorGrey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      for (final n in [0, 1, 2, 5, 10])
                        ChoiceChip(
                          key: ValueKey("upgrade-devices-$n"),
                          label: Text(n == 0 ? "不增加" : "+$n 台"),
                          selected: addDevices == n,
                          onSelected: (_) {
                            setSheetState(() => addDevices = n);
                            refreshQuote();
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    "增加天数",
                    style: TextStyle(
                      fontSize: 12,
                      color: ThemeDefine.kColorGrey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      // 面板按下单口径是「月」，这里按天展示但换算成月发送
                      // （30→1、90→3、180→6、365→12），文案里把月数写出来。
                      for (final n in [0, 30, 90, 180, 365])
                        ChoiceChip(
                          key: ValueKey("upgrade-days-$n"),
                          label: Text(
                            n == 0
                                ? "不延长"
                                : "+$n 天（${(n + 29) ~/ 30} 个月）",
                          ),
                          selected: addDays == n,
                          onSelected: (_) {
                            setSheetState(() => addDays = n);
                            refreshQuote();
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      if (quoting)
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      else
                        Text(
                          quoteError != null
                              ? "价格获取失败"
                              : "应付 ¥${amount.toStringAsFixed(2)}",
                          style: TextStyle(
                            fontSize: 15,
                            color: quoteError != null ? Colors.red : null,
                            fontWeight: ThemeConfig.kFontWeightListItem,
                          ),
                        ),
                      const Spacer(),
                      TextButton(
                        onPressed: quoting ? null : refreshQuote,
                        child: const Text("重新算价"),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: canPay
                            ? () => _submitUpgrade(
                                sheetContext,
                                orderNo: orderNo,
                                amount: amount,
                                addDevices: addDevices,
                                addDays: addDays,
                              )
                            : null,
                        child: const Text("去支付"),
                      ),
                    ],
                  ),
                  if (newLimit != null || newExpire.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          size: 13,
                          color: ThemeDefine.kColorGrey,
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            "升级后："
                            "${newLimit == null ? "" : "设备上限 $newLimit 台"}"
                            "${newLimit != null && newExpire.isNotEmpty ? " · " : ""}"
                            "${newExpire.isEmpty ? "" : "到期 $newExpire"}",
                            key: const ValueKey("upgrade-effect"),
                            style: const TextStyle(
                              fontSize: 11,
                              color: ThemeDefine.kColorGrey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (quoteError != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      "$quoteError",
                      style: const TextStyle(fontSize: 11, color: Colors.red),
                    ),
                  ],
                  if (addDevices <= 0 && addDays <= 0) ...[
                    const SizedBox(height: 8),
                    const Text(
                      "请至少选择要增加的台数或天数",
                      style: TextStyle(fontSize: 11, color: ThemeDefine.kColorGrey),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    ).whenComplete(MclashDeviceUpgrade.cancelDraft);
  }

  /// 算价失败的原因翻译成人话（`参数错误` 这种原文对用户毫无帮助）。
  static String _friendlyQuoteError(
    Object e, {
    required int addDevices,
    required int addDays,
  }) {
    final text = e.toString();
    if (text.contains("参数错误") || text.contains("40000")) {
      if (addDevices <= 0 && addDays > 0) {
        // 面板旧版本要求 add_devices ≥ 1，因此「只延长时间」会被拒
        return "面板暂不支持「只延长时间」：请把「增加台数」选成 1 台及以上再试"
            "（或联系客服开通）。";
      }
      return "参数不被接受：请重新选择台数与天数。";
    }
    if (text.contains("订阅已到期")) {
      return "订阅已到期，无法升级：请先续费或重新购买套餐。";
    }
    return text;
  }

  /// 用算价时那笔草稿订单去支付。
  ///
  /// 不再「重新下单」：后端算价就已经建单，重新下单会在订单列表里多出一笔。
  /// 最近一次算价得到的订单 id（非余额支付时用它对后端发起支付）。
  int _lastQuoteOrderId = 0;

  Future<void> _submitUpgrade(
    BuildContext sheetContext, {
    required String orderNo,
    required double amount,
    required int addDevices,
    required int addDays,
  }) async {
    if (orderNo.isEmpty) {
      if (!mounted) {
        return;
      }
      await DialogUtils.showAlertDialog(context, "订单信息不完整，请点「重新算价」再试");
      return;
    }
    // 用户要求：**让客户自己选支付方式**（以前这里直接走余额）。
    final method = await _pickPayMethod(amount);
    if (method == null || !mounted) {
      return;
    }

    if (!mounted) {
      return;
    }
    // 支付前确认这笔草稿订单还能付（后端 30 分钟就过期；被取消/过期都会让它失效）。
    // 以前没有这一步，用户挑通道挑久了点支付只会看到「订单不存在或状态不正确」。
    var payOrderNo = orderNo;
    var payAmount = amount;
    final fresh = await MclashDeviceUpgrade.refreshIfUnpayable(
      orderNo: orderNo,
      addDevices: addDevices,
      addDays: addDays,
    );
    if (fresh != null) {
      final no = (fresh["order_no"] ?? fresh["trade_no"] ?? "").toString();
      _lastQuoteOrderId = (fresh["id"] as num?)?.toInt() ?? 0;
      if (no.isNotEmpty) {
        payOrderNo = no;
        payAmount = MclashDeviceUpgrade.amountOf(fresh);
      }
      Log.i("设备管理: 原草稿订单已失效，已按同样配置重新算价 -> $payOrderNo");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("原订单已失效，已按同样配置重新生成订单")),
        );
      }
    }

    if (!mounted) {
      return;
    }
    // 关键：进入支付流程 → 草稿订单**上锁**。
    // 紧接着下面就会关掉算价面板，而面板关闭时挂着 cancelDraft()
    // （以前没上锁 → 刚建的订单被立刻取消 → 支付报「订单不存在或状态不正确」）。
    MclashDeviceUpgrade.beginPayment();
    // 关掉支付方式面板：这里用的是面板自己的 context，
    // 所以要按**它**的 mounted 判断（外层 State 的 mounted 管不到它）。
    if (sheetContext.mounted) {
      Navigator.of(sheetContext).pop();
    }

    bool ok = false;
    try {
    final payType = MclashPay.payTypeOf(method);
    if (MclashPay.isBalance(payType)) {
      ok =
          await showMclashPaymentSheet(
            context,
            orderNo: payOrderNo,
            amount: payAmount,
            payWithBalance: true,
            methodName: MclashPay.nameOf(method),
          ) ==
          true;
    } else {
      // 非余额：向后端发起支付拿二维码/收银台链接，再按通道决定交互
      final methodId = (method["id"] as num?)?.toInt() ?? 0;
      var orderId = _lastQuoteOrderId;
      if (methodId <= 0 || orderId <= 0) {
        if (mounted) {
          await DialogUtils.showAlertDialog(context, "订单或支付通道信息不完整，请重新算价后再试");
        }
        return;
      }
      Map<String, dynamic>? r;
      try {
        r = await MclashApi.createPayment(
          orderId: orderId,
          paymentMethodId: methodId,
          isMobile: Platform.isAndroid,
        );
      } catch (e) {
        // 兜底：订单在「确认」到「发起支付」之间失效（例如刚好过期），
        // 自动按同样配置重新算一笔再发起一次，不让用户自己去猜要点「重新算价」。
        if (!_looksLikeDeadOrder(e)) {
          rethrow;
        }
        Log.w("设备管理: 发起支付遇已失效订单，重新算价后重试一次 $e");
        final again = await MclashDeviceUpgrade.quote(
          addDevices: addDevices,
          addDays: addDays,
        );
        final no = (again["order_no"] ?? again["trade_no"] ?? "").toString();
        orderId = (again["id"] as num?)?.toInt() ?? 0;
        if (no.isEmpty || orderId <= 0) {
          rethrow;
        }
        payOrderNo = no;
        payAmount = MclashDeviceUpgrade.amountOf(again);
        r = await MclashApi.createPayment(
          orderId: orderId,
          paymentMethodId: methodId,
          isMobile: Platform.isAndroid,
        );
      }
      final payload = MclashPay.payloadOf(r);
      if (payload.isEmpty) {
        if (mounted) {
          await DialogUtils.showAlertDialog(context, "后端没有返回支付二维码/链接，请换一个支付方式或稍后再试");
        }
        return;
      }
      if (!mounted) {
        return;
      }
      final channel = MclashPay.classify(
        payload,
        payType: payType,
        mode: (r?["payment_mode"] ?? "").toString(),
      );
      ok =
          await showMclashPaymentSheet(
            context,
            orderNo: payOrderNo,
            amount: payAmount,
            qrCode: payload,
            methodName: MclashPay.nameOf(method),
            channel: channel,
            openInBrowser: MclashPay.shouldOpenInBrowser(channel),
          ) ==
          true;
    }

    } catch (e) {
      // **不再静默失败**：以前发起支付/取消抛异常时这里没有 try/catch，
      // 异常被 Flutter 吞掉，用户看到的就是「点了支付没反应」。
      Log.w("设备管理: 支付流程失败 $e");
      if (mounted) {
        await DialogUtils.showAlertDialog(
          context,
          "支付发起失败：${_friendlyPayError(e)}",
        );
      }
      return;
    } finally {
      // 无论成功失败都要解锁，否则后续的草稿单清理会被永久跳过
      MclashDeviceUpgrade.endPayment(keepOrder: ok);
    }

    if (ok) {
      await MclashAccountService.instance.refresh();
      await _load();
    } else {
      // 用户放弃支付 → 把这笔草稿订单取消掉，别在他订单列表里留 pending
      unawaited(MclashDeviceUpgrade.cancelDraft());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("已取消本次支付；草稿订单已清理")),
        );
      }
    }
  }

  /// 订单是否已经失效（后端 40400「订单不存在或状态不正确」）。
  static bool _looksLikeDeadOrder(Object e) {
    final text = e.toString();
    return text.contains("订单不存在") ||
        text.contains("状态不正确") ||
        text.contains("40400");
  }

  /// 把技术错误翻译成用户能懂的一句话（CSRF/网络/过期各不同）。
  static String _friendlyPayError(Object e) => MclashPay.friendlyError(e);

  /// 让用户选择支付方式（余额 + 后端下发的通道）。
  Future<Map<String, dynamic>?> _pickPayMethod(double amount) async {
    final info = MclashAccountInfo(
      MclashAccountService.instance.dashboard,
      MclashAccountService.instance.subscription,
    );
    final balance = info.balance;
    List<Map<String, dynamic>> methods = const [];
    try {
      methods = await MclashApi.paymentMethods();
    } catch (e) {
      Log.w("读取支付方式失败 $e");
    }
    if (!mounted) {
      return null;
    }

    final balanceEnabled = await MclashApi.paymentBalanceEnabled();
    if (!mounted) {
      return null;
    }
    final usable = <Map<String, dynamic>>[
      // 余额排在第一位（后端允许时才给），并标出余额是否够付
      if (balanceEnabled) {"id": -1, "key": "balance", "name": "余额支付"},
      ...methods.where((m) => !MclashPay.isBalance(MclashPay.payTypeOf(m))),
    ];
    if (usable.isEmpty) {
      if (mounted) {
        await DialogUtils.showAlertDialog(context, "当前没有可用的支付方式，请稍后再试或联系客服");
      }
      return null;
    }
    if (usable.length == 1 &&
        MclashPay.isBalance(MclashPay.payTypeOf(usable.first)) &&
        balance < amount) {
      // 没有其它通道又余额不足：引导充值
      final go = await DialogUtils.showConfirmDialog(
        context,
        "余额不足（¥${balance.toStringAsFixed(2)}，需付 ¥${amount.toStringAsFixed(2)}）。\n是否先去充值？",
      );
      if (go == true) {
        MainTabController.instance?.setTab(2);
      }
      return null;
    }

    return showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "选择支付方式",
              style: TextStyle(
                fontSize: 17,
                fontWeight: ThemeConfig.kFontWeightTitle,
              ),
            ),
            const SizedBox(height: 12),
            // 点一项即选定并关闭（支付方式的"选择"不需要二次确认）
            for (final m in usable)
              ListTile(
                key: ValueKey("pay-method-${MclashPay.payTypeOf(m)}"),
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  MclashPay.isBalance(MclashPay.payTypeOf(m))
                      ? Icons.account_balance_wallet_outlined
                      : Icons.qr_code_2,
                  size: 20,
                ),
                title: Text(MclashPay.nameOf(m)),
                subtitle: MclashPay.isBalance(MclashPay.payTypeOf(m))
                    ? Text(
                        balance >= amount
                            ? "余额 ¥${balance.toStringAsFixed(2)}"
                            : "余额 ¥${balance.toStringAsFixed(2)}（不足，请先充值）",
                        style: TextStyle(
                          fontSize: 12,
                          color: balance >= amount
                              ? ThemeDefine.kColorGrey
                              : Colors.red,
                        ),
                      )
                    : null,
                trailing: const Icon(Icons.chevron_right, size: 20),
                onTap: () => Navigator.of(ctx).pop(m),
              ),
            const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }

  Widget _buildDevice(Map<String, dynamic> d) {
    final name = d["device_name"]?.toString().isNotEmpty == true
        ? d["device_name"].toString()
        : (d["os_name"]?.toString() ?? "未知设备");
    final model = "${d["os_name"] ?? ""} · ${d["device_model"] ?? ""}";
    // 后端字段是 `is_online`（不是 `online`）—— 只读 `online` 会让**每台设备
    // 都显示离线**，包括正在打心跳的本机（用户实测反馈）。判定口径见
    // MclashDeviceView（纯函数，有测试钉住）。
    final online = MclashDeviceView.isOnline(d);
    final ip = d["ip_address"]?.toString() ?? "";
    final loc = MclashDeviceView.locationOf(d);
    final lastSeen = MclashDeviceView.lastActiveText(d);
    final id = (d["id"] as num?)?.toInt() ?? 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: ThemeConfig.kFontWeightListItem,
                    ),
                  ),
                ),
                Text(
                  online ? "● 在线" : "○ 离线",
                  style: TextStyle(
                    fontSize: 11,
                    color: online
                        ? ThemeDefine.kColorGreenBright
                        : ThemeDefine.kColorGrey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              model,
              style: const TextStyle(fontSize: 12, color: ThemeDefine.kColorGrey),
            ),
            if (ip.isNotEmpty)
              Text(
                "$ip${loc.isEmpty ? '' : ' · $loc'}",
                style: const TextStyle(fontSize: 12, color: ThemeDefine.kColorGrey),
              ),
            if (lastSeen.isNotEmpty)
              Text(
                "最近活跃 $lastSeen",
                style: const TextStyle(fontSize: 12, color: ThemeDefine.kColorGrey),
              ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _remove(id, name),
                    child: const Text("删除", style: TextStyle(color: Colors.red)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _remove(int id, String name) async {
    final ok = await DialogUtils.showConfirmDialog(
      context,
      "确认删除设备「$name」？该设备会被立即踢下线。",
    );
    if (ok != true) return;
    try {
      await MclashApi.deleteDevice(id);
      await _load();
    } catch (e) {
      if (!mounted) return;
      await DialogUtils.showAlertDialog(context, "$e");
    }
  }
}
