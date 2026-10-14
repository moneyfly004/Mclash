library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mclash/i18n/strings.g.dart';
import 'package:mclash/mf/mclash_api.dart';
import 'package:mclash/screens/dialog_utils.dart';
import 'package:mclash/mf/mclash_payment.dart';
import 'package:mclash/app/utils/log.dart';
import 'package:mclash/screens/payment/mclash_payment_sheet.dart';
import 'package:mclash/screens/theme_config.dart';
import 'package:mclash/screens/theme_define.dart';
import 'package:mclash/screens/widgets/framework.dart';

class MclashOrdersScreen extends LasyRenderingStatefulWidget {
  const MclashOrdersScreen({super.key});

  @override
  State<MclashOrdersScreen> createState() => _MclashOrdersScreenState();
}

class _MclashOrdersScreenState extends LasyRenderingState<MclashOrdersScreen> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final items = await MclashApi.orders();
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
    final t = Translations.of(context);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: PreferredSize(preferredSize: Size.zero, child: AppBar()),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
          child: Column(
            children: [
              _TopBar(
                title: t.ordersScreen.title,
                onRefresh: _load,
                loading: _loading,
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
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 24),
                        itemCount: _items.length,
                        itemBuilder: (_, i) => _buildOrder(t, _items[i]),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _resumePayment(
    Translations t,
    Map<String, dynamic> o,
    double amount,
  ) async {
    final orderNo = o["order_no"]?.toString() ?? "";
    final orderId = (o["id"] as num?)?.toInt() ?? 0;
    if (orderNo.isEmpty || orderId <= 0) {
      await DialogUtils.showAlertDialog(
        context,
        t.ordersScreen.orderInfoIncomplete,
      );
      return;
    }
    try {
      final method = await _pickPayMethod(t, amount);
      if (method == null || !mounted) {
        return;
      }
      final payType = MclashPay.payTypeOf(method);
      if (MclashPay.isBalance(payType)) {
        final ok = await showMclashPaymentSheet(
          context,
          orderNo: orderNo,
          amount: amount,
          payWithBalance: true,
          methodName: MclashPay.nameOf(method),
        );
        if (ok == true && mounted) {
          await _load();
        }
        return;
      }
      final methodId = (method["id"] as num?)?.toInt() ?? 0;
      if (methodId <= 0) {
        await DialogUtils.showAlertDialog(
          context,
          t.ordersScreen.payChannelIncomplete,
        );
        return;
      }
      final r = await MclashApi.createPayment(
        orderId: orderId,
        paymentMethodId: methodId,
        isMobile: Platform.isAndroid,
      );
      final payload = MclashPay.payloadOf(r);
      if (!mounted) {
        return;
      }
      if (payload.isEmpty) {
        await DialogUtils.showAlertDialog(context, t.ordersScreen.noQrPayload);
        return;
      }
      final channel = MclashPay.classify(
        payload,
        payType: payType,
        mode: (r?["payment_mode"] ?? "").toString(),
      );
      final ok = await showMclashPaymentSheet(
        context,
        orderNo: orderNo,
        amount: amount,
        qrCode: payload,
        methodName: MclashPay.nameOf(method),
        channel: channel,
        openInBrowser: MclashPay.shouldOpenInBrowser(channel),
      );
      if (ok == true && mounted) {
        await _load();
      }
    } catch (e) {
      if (!mounted) {
        return;
      }
      await DialogUtils.showAlertDialog(
        context,
        t.ordersScreen.payStartFailed(err: MclashPay.friendlyError(e)),
      );
    }
  }

  Future<Map<String, dynamic>?> _pickPayMethod(
    Translations t,
    double amount,
  ) async {
    List<Map<String, dynamic>> methods = const [];
    try {
      methods = await MclashApi.paymentMethods();
    } catch (e) {
      Log.w("订单页: 读取支付方式失败 $e");
    }
    if (!mounted) {
      return null;
    }
    final balanceEnabled = await MclashApi.paymentBalanceEnabled();
    if (!mounted) {
      return null;
    }
    final usable = <Map<String, dynamic>>[
      if (balanceEnabled)
        {"id": -1, "key": "balance", "name": t.payment.balancePay},
      ...methods.where((m) => !MclashPay.isBalance(MclashPay.payTypeOf(m))),
    ];
    if (usable.isEmpty) {
      await DialogUtils.showAlertDialog(context, t.ordersScreen.noPayMethod);
      return null;
    }
    return showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  Text(
                    t.ordersScreen.choosePayMethod,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: ThemeConfig.kFontWeightTitle,
                    ),
                  ),
                ],
              ),
            ),
            for (final m in usable)
              ListTile(
                key: ValueKey("order-pay-method-${MclashPay.payTypeOf(m)}"),
                title: Text(MclashPay.nameOf(m)),
                subtitle: MclashPay.isBalance(MclashPay.payTypeOf(m))
                    ? Text(
                        t.ordersScreen.amountDue(
                          amount: amount.toStringAsFixed(2),
                        ),
                        style: const TextStyle(fontSize: 11),
                      )
                    : null,
                onTap: () => Navigator.of(ctx).pop(m),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildOrder(Translations t, Map<String, dynamic> o) {
    final status = o["status"]?.toString() ?? "";
    final paid = status == "paid" || status == "completed";
    final pending = status == "pending" || status == "waiting";
    final amount =
        (o["final_amount"] as num?)?.toDouble() ??
        (o["amount"] as num?)?.toDouble() ??
        0;
    final orderNo = o["order_no"]?.toString() ?? "";
    final createdAt = o["created_at"]?.toString() ?? "";
    final pkgName = (o["package"] is Map)
        ? (o["package"] as Map)["name"]?.toString() ?? ""
        : o["package_name"]?.toString() ?? "";

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
                    pkgName.isEmpty ? "-" : pkgName,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: ThemeConfig.kFontWeightListItem,
                    ),
                  ),
                ),
                Text(
                  paid
                      ? t.ordersScreen.paidLabel
                      : (pending
                            ? t.ordersScreen.pendingLabel
                            : t.ordersScreen.unknownStatus(status: status)),
                  style: TextStyle(
                    fontSize: 11,
                    color: paid
                        ? ThemeDefine.kColorGreenBright
                        : (pending ? Colors.red : ThemeDefine.kColorGrey),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              "¥${amount.toStringAsFixed(2)}",
              style: const TextStyle(
                fontSize: 17,
                fontWeight: ThemeConfig.kFontWeightListItem,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              t.ordersScreen.orderNoText(orderNo: orderNo),
              style: const TextStyle(
                fontSize: 12,
                color: ThemeDefine.kColorGrey,
              ),
            ),
            if (createdAt.isNotEmpty)
              Text(
                t.ordersScreen.createdAtText(createdAt: createdAt),
                style: const TextStyle(
                  fontSize: 12,
                  color: ThemeDefine.kColorGrey,
                ),
              ),
            if (pending) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        try {
                          await MclashApi.cancelOrder(orderNo);
                          await _load();
                          if (!mounted) {
                            return;
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(t.ordersScreen.orderCanceled),
                            ),
                          );
                        } catch (e) {
                          if (!mounted) {
                            return;
                          }
                          await DialogUtils.showAlertDialog(
                            context,
                            t.ordersScreen.cancelFailed(err: "$e"),
                          );
                        }
                      },
                      child: Text(
                        t.ordersScreen.cancelOrder,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _resumePayment(t, o, amount),
                      child: Text(t.ordersScreen.continuePay),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.title, this.onRefresh, this.loading = false});

  final String title;
  final Future<void> Function()? onRefresh;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Row(
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
        Expanded(
          child: Text(
            title,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: ThemeConfig.kFontWeightTitle,
              fontSize: ThemeConfig.kFontSizeTitle,
            ),
          ),
        ),
        SizedBox(
          width: 50,
          height: 44,
          child: loading
              ? const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : (onRefresh == null
                    ? const SizedBox()
                    : InkWell(
                        onTap: onRefresh,
                        child: const Icon(Icons.refresh, size: 26),
                      )),
        ),
      ],
    );
  }
}
