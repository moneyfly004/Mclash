library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mclash/app/utils/log.dart';
import 'package:mclash/app/utils/qrcode_utils.dart';
import 'package:mclash/app/utils/url_launcher_utils.dart';
import 'package:mclash/mf/mclash_api.dart';
import 'package:mclash/mf/mclash_payment.dart';
import 'package:mclash/screens/widgets/sheet.dart';
import 'package:url_launcher/url_launcher.dart';

/// 测试缝：替换真实的余额支付（widget 测试没有网络）。返回错误信息 = 失败。
@visibleForTesting
Future<String?> Function(String orderNo)? debugBalancePayOverride;

/// 测试缝：替换「唤起支付 App / 打开浏览器」，返回是否成功。
@visibleForTesting
Future<bool> Function(String target, bool external)? debugLaunchOverride;

/// 支付面板，返回 `true` 表示支付成功。
///
/// 覆盖三种真实交互（用户要求）：
///   * **余额支付** —— 面板里直接扣款（旧实现只显示二维码，选余额也在转圈）；
///   * **扫码支付** —— 展示二维码（支付宝当面付 / 微信 NATIVE / USDT 地址码）；
///     手机端额外给「打开支付宝」按钮，`qr.alipay.com` 会包成 `alipays://` 深链
///     直接唤起支付宝 App（参考客户端同款做法）；
///   * **码支付收银台** —— 后端返回的是 http(s) 收银台链接时**打开浏览器**支付。
Future<bool?> showMclashPaymentSheet(
  BuildContext context, {
  required String orderNo,
  required double amount,
  String qrCode = "",
  bool payWithBalance = false,
  String methodName = "",
  MclashPayChannel? channel,
  String launchTarget = "",
  bool openInBrowser = false,
}) {
  return showSheet<bool>(
    context: context,
    body: _PaymentSheetBody(
      orderNo: orderNo,
      amount: amount,
      qrCode: qrCode,
      payWithBalance: payWithBalance,
      methodName: methodName,
      channel: channel ?? MclashPay.classify(qrCode),
      launchTarget: launchTarget,
      openInBrowser: openInBrowser,
    ),
  );
}

class _PaymentSheetBody extends StatefulWidget {
  const _PaymentSheetBody({
    required this.orderNo,
    required this.amount,
    required this.qrCode,
    required this.payWithBalance,
    required this.methodName,
    required this.channel,
    required this.launchTarget,
    required this.openInBrowser,
  });

  final String orderNo;
  final double amount;
  final String qrCode;
  final bool payWithBalance;
  final String methodName;
  final MclashPayChannel channel;
  final String launchTarget;
  final bool openInBrowser;

  @override
  State<_PaymentSheetBody> createState() => _PaymentSheetBodyState();
}

class _PaymentSheetBodyState extends State<_PaymentSheetBody>
    with WidgetsBindingObserver {
  static const _interval = Duration(seconds: 3);
  static const _timeout = Duration(minutes: 15);

  Timer? _timer;
  Timer? _timeoutTimer;
  bool _paid = false;
  bool _timedOut = false;
  bool _paying = false;
  bool _launching = false;
  bool _autoOpened = false;
  String? _payError;

  bool get _isMobile => defaultTargetPlatform == TargetPlatform.android;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.payWithBalance) {
      _payWithBalance();
    } else {
      _timer = Timer.periodic(_interval, (_) => _poll());
      _poll();
      if (widget.openInBrowser) {
        // 码支付收银台：进面板就把浏览器打开（用户要求：码支付弹到浏览器支付）
        WidgetsBinding.instance.addPostFrameCallback((_) => _openExternal());
      }
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
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _timeoutTimer?.cancel();
    super.dispose();
  }

  /// 从支付宝/浏览器切回 App 时立刻查一次（不必等下个轮询周期）。
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && !widget.payWithBalance) {
      _poll();
    }
  }

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

  /// 唤起支付 App / 打开浏览器。
  Future<void> _openExternal() async {
    if (_launching) {
      return;
    }
    final target = widget.launchTarget.isNotEmpty
        ? widget.launchTarget
        : MclashPay.appLaunchTarget(widget.qrCode, widget.channel);
    if (target.isEmpty) {
      return;
    }
    setState(() => _launching = true);
    try {
      final override = debugLaunchOverride;
      final ok = override != null
          ? await override(target, true)
          : await _launch(target);
      _autoOpened = true;
      if (!ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("没能打开支付页面，请改用扫码支付")),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _launching = false);
      }
    }
  }

  Future<bool> _launch(String target) async {
    final err = await UrlLauncherUtils.loadUrl(
      target,
      mode: LaunchMode.externalApplication,
    );
    return err == null;
  }

  Future<void> _cancel() async {
    try {
      await MclashApi.cancelOrder(widget.orderNo);
    } catch (_) {}
    if (mounted) {
      Navigator.of(context).pop(false);
    }
  }

  bool get _showLaunchButton =>
      !widget.payWithBalance &&
      MclashPay.canLaunchApp(widget.channel, isMobile: _isMobile);

  String get _launchLabel {
    if (widget.channel == MclashPayChannel.cashierUrl) {
      return _autoOpened ? "重新打开支付页面" : "在浏览器中支付";
    }
    return "打开支付宝支付";
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.payWithBalance
        ? "余额支付"
        : (widget.methodName.isNotEmpty ? widget.methodName : "扫码支付");
    final showQr = !widget.payWithBalance &&
        widget.channel != MclashPayChannel.cashierUrl;
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
            widget.payWithBalance
                ? "从账户余额扣款"
                : (widget.channel == MclashPayChannel.cashierUrl
                      ? "已在浏览器中打开支付页面"
                      : "请使用支付宝 / 微信扫码"),
            style: const TextStyle(fontSize: 12, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),
          if (showQr)
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
          if (_showLaunchButton) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _launching ? null : _openExternal,
                icon: _launching
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.open_in_new, size: 16),
                label: Text(_launchLabel),
              ),
            ),
          ],
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
