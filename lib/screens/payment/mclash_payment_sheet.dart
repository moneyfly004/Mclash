library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mclash/app/utils/log.dart';
import 'package:mclash/app/utils/qrcode_utils.dart';
import 'package:mclash/mf/mclash_api.dart';
import 'package:mclash/screens/widgets/sheet.dart';

/// 测试缝：替换真实的余额支付（widget 测试没有网络）。
/// 返回错误信息表示失败，返回 null 表示成功。
@visibleForTesting
Future<String?> Function(String orderNo)? debugBalancePayOverride;

/// 支付面板，返回 `true` 表示支付成功。
///
/// 两种模式：
///   * `payWithBalance: true` —— **真的发起余额扣款**。旧实现不管选什么支付方式
///     都只显示一张二维码，选「余额支付」也是一直转圈，等于支付功能不可用。
///   * 扫码支付 —— 显示二维码，并轮询订单状态，支付成功后自动关闭。
Future<bool?> showMclashPaymentSheet(
  BuildContext context, {
  required String orderNo,
  required double amount,
  String qrCode = "",
  bool payWithBalance = false,
}) {
  return showSheet<bool>(
    context: context,
    body: _PaymentSheetBody(
      orderNo: orderNo,
      amount: amount,
      qrCode: qrCode,
      payWithBalance: payWithBalance,
    ),
  );
}

class _PaymentSheetBody extends StatefulWidget {
  const _PaymentSheetBody({
    required this.orderNo,
    required this.amount,
    required this.qrCode,
    required this.payWithBalance,
  });

  final String orderNo;
  final double amount;
  final String qrCode;
  final bool payWithBalance;

  @override
  State<_PaymentSheetBody> createState() => _PaymentSheetBodyState();
}

class _PaymentSheetBodyState extends State<_PaymentSheetBody> {
  static const _interval = Duration(seconds: 3);
  static const _timeout = Duration(minutes: 15);

  Timer? _timer;

  /// 15 分钟超时定时器也要持有引用并随面板销毁取消 —— 否则面板关掉之后
  /// 定时器还会活 15 分钟（测试里会直接暴露成「Pending timers」）。
  Timer? _timeoutTimer;
  bool _paid = false;
  bool _timedOut = false;
  bool _paying = false;
  String? _payError;

  @override
  void initState() {
    super.initState();
    if (widget.payWithBalance) {
      _payWithBalance();
    } else {
      _timer = Timer.periodic(_interval, (_) => _poll());
    }
    _timeoutTimer = Timer(_timeout, () {
      if (!mounted || _paid) {
        return;
      }
      _timer?.cancel();
      setState(() => _timedOut = true);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timeoutTimer?.cancel();
    super.dispose();
  }

  /// 余额支付：真正调用支付接口，而不是让用户对着二维码发呆。
  Future<void> _payWithBalance() async {
    if (_paying) {
      return;
    }
    setState(() {
      _paying = true;
      _payError = null;
    });
    try {
      final override = debugBalancePayOverride;
      final err = override != null
          ? await override(widget.orderNo)
          : await _doPay();
      if (!mounted) {
        return;
      }
      if (err != null) {
        setState(() {
          _paying = false;
          _payError = err;
        });
        return;
      }
      _paid = true;
      setState(() => _paying = false);
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _paying = false;
        _payError = "$e";
      });
    }
  }

  Future<String?> _doPay() async {
    try {
      await MclashApi.payOrder(widget.orderNo);
      return null;
    } catch (e) {
      Log.w("支付面板: 余额支付失败 $e");
      return "$e";
    }
  }

  Future<void> _poll() async {
    if (_paid || !mounted) {
      return;
    }
    try {
      final s = await MclashApi.orderStatus(widget.orderNo);
      final status = s?["status"]?.toString() ?? "";
      if (status == "paid" || status == "completed") {
        _timer?.cancel();
        if (!mounted) {
          return;
        }
        setState(() => _paid = true);
        Navigator.of(context).pop(true);
      }
    } catch (_) {}
  }

  Future<void> _cancel() async {
    try {
      await MclashApi.cancelOrder(widget.orderNo);
    } catch (_) {}
    if (mounted) {
      Navigator.of(context).pop(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.payWithBalance ? "余额支付" : "扫码支付";
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Text(
            widget.payWithBalance ? "从账户余额扣款" : "请使用支付宝 / 微信扫码",
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 14),
          if (!widget.payWithBalance)
            Container(
              width: 196,
              height: 196,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
              child: widget.qrCode.isEmpty
                  ? const Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : (QrcodeUtils.toImage(widget.qrCode).data ??
                        const SizedBox.shrink()),
            ),
          Text(
            "¥ ${widget.amount.toStringAsFixed(2)}",
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Text(
            "订单号 ${widget.orderNo}",
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 14),
          if (_payError != null)
            Text(
              "支付失败：$_payError",
              style: const TextStyle(fontSize: 12, color: Colors.red),
              textAlign: TextAlign.center,
            )
          else if (_timedOut)
            const Text(
              "未检测到支付。可稍后在「我的订单」中继续。",
              style: TextStyle(fontSize: 12, color: Colors.red),
              textAlign: TextAlign.center,
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 8),
                Text(
                  widget.payWithBalance
                      ? (_paying ? "正在扣款…" : "处理中…")
                      : "等待支付…",
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _cancel,
                  child: const Text("取消订单"),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: widget.payWithBalance
                      ? (_paying ? null : _payWithBalance)
                      : () => _poll(),
                  child: Text(
                    widget.payWithBalance
                        ? (_payError == null ? "确认支付" : "重试")
                        : "我已支付",
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
