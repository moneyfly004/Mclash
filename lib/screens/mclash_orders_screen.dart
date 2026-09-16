
library;

import 'dart:io';

import 'package:flutter/material.dart';
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
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: PreferredSize(preferredSize: Size.zero, child: AppBar()),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
          child: Column(
            children: [
              _TopBar(title: "我的订单", onRefresh: _load, loading: _loading),
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
                        itemBuilder: (_, i) => _buildOrder(_items[i]),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 「继续支付」：**重新发起一次支付**，而不是拿空二维码糊弄用户。
  ///
  /// 旧实现的两个真问题（用户实测「点了没反应 / 没有二维码」）：
  ///   1. `/orders/{no}/status` 只返回金额/套餐/状态，**没有** payment_method 与
  ///      qr_code —— 于是这里 `payWithBalance` 永远 false、二维码永远是空字符串，
  ///      面板打开就是一个空框；
  ///   2. 整个流程没有 try/catch，CSRF 过期等异常被吞掉 → 点击毫无反应。
  /// 现在：让用户选支付方式（余额 + 后端下发的通道），余额走余额支付，
  /// 其它通道用 `POST /payment` 重新拿一次支付链接/二维码。
  Future<void> _resumePayment(Map<String, dynamic> o, double amount) async {
    final orderNo = o["order_no"]?.toString() ?? "";
    final orderId = (o["id"] as num?)?.toInt() ?? 0;
    if (orderNo.isEmpty || orderId <= 0) {
      await DialogUtils.showAlertDialog(context, "订单信息不完整，请下拉刷新后重试");
      return;
    }
    try {
      final method = await _pickPayMethod(amount);
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
        await DialogUtils.showAlertDialog(context, "支付通道信息不完整，请稍后重试");
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
        await DialogUtils.showAlertDialog(
          context,
          "后端没有返回支付二维码/链接，请换一个支付方式或稍后再试",
        );
        return;
      }
      final channel = MclashPay.classify(payload, payType: payType);
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
      await DialogUtils.showAlertDialog(context, "发起支付失败：$e");
    }
  }

  /// 支付方式选择（与设备管理同一套：余额 + 后端下发通道）。
  Future<Map<String, dynamic>?> _pickPayMethod(double amount) async {
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
      if (balanceEnabled) {"id": -1, "key": "balance", "name": "余额支付"},
      ...methods.where((m) => !MclashPay.isBalance(MclashPay.payTypeOf(m))),
    ];
    if (usable.isEmpty) {
      await DialogUtils.showAlertDialog(context, "当前没有可用的支付方式，请稍后再试或联系客服");
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
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  Text(
                    "选择支付方式",
                    style: TextStyle(
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
                        "应付 ¥${amount.toStringAsFixed(2)}",
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

  Widget _buildOrder(Map<String, dynamic> o) {
    final status = o["status"]?.toString() ?? "";
    final paid = status == "paid" || status == "completed";
    final pending = status == "pending" || status == "waiting";
    final amount = (o["final_amount"] as num?)?.toDouble() ??
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
                  paid ? "● 已支付" : (pending ? "○ 待支付" : "✕ $status"),
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
              "订单号 $orderNo",
              style: const TextStyle(fontSize: 12, color: ThemeDefine.kColorGrey),
            ),
            if (createdAt.isNotEmpty)
              Text(
                "下单时间 $createdAt",
                style: const TextStyle(fontSize: 12, color: ThemeDefine.kColorGrey),
              ),
            if (pending) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        // 以前这里异常被吞掉 → 用户点「取消订单」毫无反应
                        try {
                          await MclashApi.cancelOrder(orderNo);
                          await _load();
                          if (!mounted) {
                            return;
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("订单已取消")),
                          );
                        } catch (e) {
                          if (!mounted) {
                            return;
                          }
                          await DialogUtils.showAlertDialog(
                            context,
                            "取消失败：$e\n（若订单已被支付/已取消，下拉刷新即可看到最新状态）",
                          );
                        }
                      },
                      child: const Text("取消订单", style: TextStyle(color: Colors.red)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _resumePayment(o, amount),
                      child: const Text("继续支付"),
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
  const _TopBar({
    required this.title,
    this.onRefresh,
    this.loading = false,
  });

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
