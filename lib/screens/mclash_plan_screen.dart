
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mclash/app/utils/log.dart';
import 'package:mclash/i18n/strings.g.dart';
import 'package:mclash/mf/mclash_account_info.dart';
import 'package:mclash/mf/mclash_account_service.dart';
import 'package:mclash/mf/mclash_api.dart';
import 'package:mclash/mf/mclash_payment.dart';
import 'package:mclash/screens/dialog_utils.dart';
import 'package:mclash/screens/payment/mclash_payment_sheet.dart';
import 'package:mclash/screens/theme_config.dart';
import 'package:mclash/screens/theme_define.dart';
import 'package:mclash/screens/widgets/framework.dart';

class MclashPlanScreen extends LasyRenderingStatefulWidget {
  const MclashPlanScreen({super.key});

  @override
  State<MclashPlanScreen> createState() => _MclashPlanScreenState();
}

class _MclashPlanScreenState extends LasyRenderingState<MclashPlanScreen> {
  bool _loading = true;
  String? _error;

  Map<String, dynamic>? _sub;
  List<Map<String, dynamic>> _plans = [];
  List<Map<String, dynamic>> _methods = [];

  int? _selectedPlanId;

  Map<String, dynamic>? _selectedMethod;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _load() async {
    if (!mounted) {
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      Map<String, dynamic>? sub;
      List<Map<String, dynamic>> plans = [];
      List<Map<String, dynamic>> methods = [];

      await Future.wait([
        MclashApi.subscription().then((v) => sub = v).catchError((e) {
          Log.w("plan: subscription failed $e");
          return null;
        }),
        MclashApi.packages().then((v) => plans = v),
        MclashApi.availablePaymentMethods().then((v) => methods = v),
      ]);
      if (!mounted) {
        return;
      }
      setState(() {
        _sub = sub;
        _plans = plans;
        _methods = methods;
        _selectedPlanId ??= plans.isNotEmpty
            ? ((plans.firstWhere(
                    (p) => p["is_recommended"] == true,
                    orElse: () => plans.first,
                  )["id"]) as num?)
                ?.toInt()
            : null;
        _selectedMethod ??= methods.isNotEmpty ? methods.first : null;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }
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
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: Row(
                  children: [
                    Text(
                      t.meta.buyProfile,
                      style: const TextStyle(
                        fontWeight: ThemeConfig.kFontWeightTitle,
                        fontSize: ThemeConfig.kFontSizeTitle,
                      ),
                    ),
                    const Spacer(),
                    if (_loading)
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    else
                      InkWell(
                        onTap: _load,
                        child: const SizedBox(
                          width: 44,
                          height: 44,
                          child: Icon(Icons.refresh, size: 26),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: _error != null
                    ? _buildError(t)
                    : ListView(
                        padding: const EdgeInsets.only(bottom: 24),
                        children: [
                          if (_sub != null) _buildCurrentSub(t, _sub!),
                          ..._buildPlans(t),
                          _buildMethods(t),
                          _buildCheckout(t),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentSub(Translations t, Map<String, dynamic> sub) {
    final status = sub["status"]?.toString() ?? "";
    final active = status == "active" && sub["is_expired"] != true;
    final expire = sub["expire_time"]?.toString() ?? "";
    final remaining = (sub["remaining_days"] as num?)?.toInt() ?? 0;
    final used = (sub["upload"] as num?)?.toDouble() ?? 0;
    final used2 = (sub["download"] as num?)?.toDouble() ?? 0;
    final total = (sub["total"] as num?)?.toDouble() ?? 0;
    final usedGb = (used + used2) / (1024 * 1024 * 1024);

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: Text(
                    MclashApi.providerName.isNotEmpty
                        ? MclashApi.providerName
                        : t.meta.myProfiles,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: ThemeConfig.kFontWeightListItem,
                    ),
                  ),
                ),
                _pill(active ? t.meta.enable : t.meta.disable, active),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              expire.isEmpty
                  ? t.meta.none
                  : "$expire · ${t.meta.days} $remaining",
              style: const TextStyle(
                fontSize: 12,
                color: ThemeDefine.kColorGrey,
              ),
            ),
            if (total > 0) ...[
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: (usedGb * 1024 * 1024 * 1024 / total).clamp(0.0, 1.0),
                  minHeight: 4,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "${usedGb.toStringAsFixed(1)} / "
                "${(total / (1024 * 1024 * 1024)).toStringAsFixed(0)} GB",
                style: const TextStyle(
                  fontSize: 12,
                  color: ThemeDefine.kColorGrey,
                ),
              ),
            ],
            const SizedBox(height: 14),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildPlans(Translations t) {
    if (_plans.isEmpty) {
      return [const SizedBox(height: 8)];
    }
    return [
      for (final p in _plans)
        Card(
          shape: _selectedPlanId == _asInt(p["id"])
              ? RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: ThemeDefine.kColorBlue),
                )
              : null,
          child: InkWell(
            onTap: () => setState(() {
              _selectedPlanId = _asInt(p["id"]);
            }),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          p["name"]?.toString() ?? "",
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: ThemeConfig.kFontWeightListItem,
                          ),
                        ),
                      ),
                      if (p["is_recommended"] == true)
                        const Text(
                          "推荐",
                          style: TextStyle(
                            fontSize: 12,
                            color: ThemeDefine.kColorBlue,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: "¥ ${_price(p["price"])}",
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: ThemeConfig.kFontWeightListItem,
                          ),
                        ),
                        TextSpan(
                          text: " / ${p["duration_days"] ?? 30} ${t.meta.days}",
                          style: const TextStyle(
                            fontSize: 12,
                            color: ThemeDefine.kColorGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "${p["duration_days"] ?? 30} ${t.meta.days} · "
                    "${p["device_limit"] ?? 1} 设备 · "
                    "${p["traffic_limit"] ?? "-"}",
                    style: const TextStyle(
                      fontSize: 12,
                      color: ThemeDefine.kColorGrey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
    ];
  }

  Widget _buildMethods(Translations t) {
    if (_methods.isEmpty) {
      return const SizedBox.shrink();
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        child: ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _methods.length,
          separatorBuilder: (_, _) => const Divider(height: 1, thickness: 0.3),
          itemBuilder: (context, i) {
            final m = _methods[i];
            final payType = (m["pay_type"] ?? "").toString();
            final selected =
                payType == (_selectedMethod?["pay_type"] ?? "").toString();

            final label = (m["label"] ?? "").toString().isNotEmpty
                ? m["label"].toString()
                : MclashApi.paymentMethodLabel(payType);

            final isBalance = payType == "balance";
            final info = MclashAccountInfo(
              MclashAccountService.instance.dashboard,
              MclashAccountService.instance.subscription,
            );
            final plan = _plans.firstWhere(
              (p) => _asInt(p["id"]) == _selectedPlanId,
              orElse: () => const {},
            );
            final price =
                double.tryParse(plan["price"]?.toString() ?? "0") ?? 0;
            final notEnough = isBalance && info.balance < price;
            return ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                label,
                style: TextStyle(
                  color: selected ? ThemeDefine.kColorBlue : null,
                ),
              ),
              subtitle: isBalance
                  ? Text(
                      "余额 ¥${info.balance.toStringAsFixed(2)}"
                      "${notEnough ? "（不足，请先充值）" : ""}",
                      style: TextStyle(
                        fontSize: 12,
                        color: notEnough ? Colors.red : ThemeDefine.kColorGrey,
                      ),
                    )
                  : null,
              trailing: selected
                  ? const Icon(Icons.done, size: 20)
                  : const SizedBox(width: 20),
              onTap: () => setState(() => _selectedMethod = m),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCheckout(Translations t) {
    final plan = _plans.firstWhere(
      (p) => _asInt(p["id"]) == _selectedPlanId,
      orElse: () => const {},
    );
    final price = double.tryParse(plan["price"]?.toString() ?? "0") ?? 0;
    final payable = price;
    final canPay = _selectedPlanId != null && _selectedMethod != null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
        child: Row(
          children: [
            const Text("合计", style: TextStyle(fontSize: 12.5)),
            const SizedBox(width: 6),
            Text(
              "¥${payable.toStringAsFixed(2)}",
              style: const TextStyle(
                fontSize: 17,
                fontWeight: ThemeConfig.kFontWeightListItem,
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: canPay ? () => _pay(payable) : null,
              child: const Text("立即支付"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pay(double amount) async {
    try {
      final order = await MclashApi.createOrder(
        _selectedPlanId!,
        couponCode: "",
      );
      if (order == null) {
        return;
      }
      final orderNo = order["order_no"]?.toString() ?? "";
      final orderId = (order["id"] as num?)?.toInt();
      if (orderNo.isEmpty) {
        return;
      }

      final payType = (_selectedMethod?["pay_type"] ?? "").toString();
      final methodId = (_selectedMethod?["id"] as num?)?.toInt();

      String payUrl = "";
      if (payType == "balance") {
        // 余额支付由支付面板自己发起（面板里能看到「正在扣款 / 扣款失败原因」）。
        // 旧实现先在这里静默扣款、再弹一个「扫码支付」二维码，用户完全看不懂。
        if (!mounted) {
          return;
        }
        final ok = await showMclashPaymentSheet(
          context,
          orderNo: orderNo,
          amount: amount,
          payWithBalance: true,
        );
        if (ok != true) {
          await _cancelDraftOrder(orderNo);
          return;
        }
      } else {

        if (orderId == null || methodId == null) {
          throw MclashApiError("订单或支付通道信息不完整，无法发起支付", 0);
        }
        final r = await MclashApi.createPayment(
          orderId: orderId,
          paymentMethodId: methodId,
          isMobile: Platform.isAndroid,
        );
        payUrl = MclashPay.payloadOf(r);
        if (!mounted) {
          return;
        }
        // 按通道决定交互：支付宝二维码弹二维码（手机可唤起 App）、
        // 码支付/收银台链接开浏览器（用户要求）。后端给了 payment_mode 时以它为准。
        final channel = MclashPay.classify(
          payUrl,
          payType: payType,
          mode: (r?["payment_mode"] ?? "").toString(),
        );
        final ok = await showMclashPaymentSheet(
          context,
          orderNo: orderNo,
          amount: amount,
          qrCode: payUrl,
          methodName: (_selectedMethod?["name"] ?? "").toString(),
          channel: channel,
          openInBrowser: MclashPay.shouldOpenInBrowser(channel),
        );
        if (ok != true) {
          await _cancelDraftOrder(orderNo);
          return;
        }
      }

      await _load();
    } catch (e) {
      if (!mounted) {
        return;
      }
      await DialogUtils.showAlertDialog(context, MclashPay.friendlyError(e));
    }
  }

  /// 用户没付成就把订单取消掉：否则订单列表里会堆一堆 pending 订单
  /// （用户实测：支付失败几次之后，列表里多了 3 笔 200 元的未付款订单）。
  Future<void> _cancelDraftOrder(String orderNo) async {
    try {
      await MclashApi.cancelOrder(orderNo);
      Log.i("套餐页: 已取消未支付的订单 $orderNo");
    } catch (e) {
      Log.w("套餐页: 取消订单 $orderNo 失败 $e");
    }
  }

  Widget _buildError(Translations t) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _error ?? "",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _load, child: const Text("重试")),
          ],
        ),
      ),
    );
  }

  static int? _asInt(dynamic v) => v is num ? v.toInt() : int.tryParse("$v");

  static String _price(dynamic v) {
    final d = double.tryParse("$v") ?? 0;
    var s = d.toStringAsFixed(2);
    if (s.contains(".")) {
      s = s.replaceAll(RegExp(r"0+$"), "").replaceAll(RegExp(r"\.$"), "");
    }
    return s.isEmpty ? "0" : s;
  }

  Widget _pill(String text, bool ok) {
    final color = ok ? ThemeDefine.kColorGreenBright : Colors.red;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(text, style: TextStyle(fontSize: 11, color: color)),
    );
  }
}
