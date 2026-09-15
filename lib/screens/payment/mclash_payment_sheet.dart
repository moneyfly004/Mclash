/// 支付弹层（S-12）。
///
/// 契约对齐 docs/design/06 §6.15.3：
///   * `showModalBottomSheet` + 拖拽手柄（复用 Clash Mi 的 `showSheet` 视觉）
///   * 二维码 196×196 白底
///   * **每 3 秒**轮询订单状态，最长 **15 分钟**；`paid` 自动关闭
///   * 超时后给「重新生成二维码 / 稍后在订单记录继续」
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mclash/mf/mclash_api.dart';
import 'package:mclash/screens/widgets/sheet.dart';
import 'package:mclash/app/utils/qrcode_utils.dart';

Future<void> showMclashPaymentSheet(
  BuildContext context, {
  required String orderNo,
  required double amount,
  required String qrCode,
}) {
  return showSheet<void>(
    context: context,
    body: _PaymentSheetBody(
      orderNo: orderNo,
      amount: amount,
      qrCode: qrCode,
    ),
  );
}

class _PaymentSheetBody extends StatefulWidget {
  const _PaymentSheetBody({
    required this.orderNo,
    required this.amount,
    required this.qrCode,
  });

  final String orderNo;
  final double amount;
  final String qrCode;

  @override
  State<_PaymentSheetBody> createState() => _PaymentSheetBodyState();
}

class _PaymentSheetBodyState extends State<_PaymentSheetBody> {
  static const _interval = Duration(seconds: 3);
  static const _timeout = Duration(minutes: 15);

  Timer? _timer;
  bool _paid = false;
  bool _timedOut = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(_interval, (_) => _poll());
    // 超时兜底：15 分钟后停止轮询并提示「重新生成二维码」
    Timer(_timeout, () {
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
    super.dispose();
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
        // 支付成功 → 自动关闭，由调用方刷新订阅
        Navigator.of(context).pop();
      }
    } catch (_) {
      // 轮询失败静默忽略（网络抖动不应打断用户）
    }
  }

  Future<void> _cancel() async {
    try {
      await MclashApi.cancelOrder(widget.orderNo);
    } catch (_) {}
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("扫码支付", style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          const Text(
            "请使用支付宝 / 微信扫码",
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 14),
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
          const SizedBox(height: 12),
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
          if (_timedOut)
            const Text(
              "未检测到支付。可稍后在「我的订单」中继续。",
              style: TextStyle(fontSize: 12, color: Colors.red),
              textAlign: TextAlign.center,
            )
          else
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 8),
                Text("等待支付…", style: TextStyle(fontSize: 14, color: Colors.grey)),
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
                  onPressed: () => _poll(),
                  child: const Text("我已支付"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
