library;

import 'dart:convert';

import 'package:mclash/app/utils/log.dart';
import 'package:mclash/mf/mclash_api.dart';

abstract final class MclashDeviceUpgrade {
  static String? _draftOrderNo;

  static bool _inPayment = false;

  static void beginPayment() => _inPayment = true;

  static void endPayment({bool keepOrder = false}) {
    _inPayment = false;
    if (keepOrder) {
      markPaid();
    }
  }

  static String get draftOrderNo => _draftOrderNo ?? "";

  static Future<Map<String, dynamic>> Function(int devices, int days)?
  debugQuoteOverride;

  static Future<void> Function(String orderNo)? debugCancelOverride;

  static Future<String?> Function(String orderNo)? debugOrderStatusOverride;

  static Future<Map<String, dynamic>>? _quoteInflight;
  static int _pendingDevices = 0;
  static int _pendingDays = 0;
  static bool _hasPending = false;

  static Future<Map<String, dynamic>> quote({
    required int addDevices,
    required int addDays,
  }) {
    _pendingDevices = addDevices;
    _pendingDays = addDays;
    _hasPending = true;
    final inflight = _quoteInflight;
    if (inflight != null) {
      Log.i("MclashDeviceUpgrade: 算价进行中，已排队最新参数 $addDevices/$addDays");
      return inflight;
    }
    final future = _drainQuote();
    _quoteInflight = future;
    return future;
  }

  static Future<Map<String, dynamic>> _drainQuote() async {
    var last = <String, dynamic>{};
    try {
      while (_hasPending) {
        _hasPending = false;
        last = await _quoteInner(
          addDevices: _pendingDevices,
          addDays: _pendingDays,
        );
      }
      return last;
    } finally {
      _quoteInflight = null;
    }
  }

  static Future<Map<String, dynamic>> _quoteInner({
    required int addDevices,
    required int addDays,
  }) async {
    await cancelDraft();
    final override = debugQuoteOverride;
    final data = override != null
        ? await override(addDevices, addDays)
        : await MclashApi.previewDeviceUpgrade(
            addDevices: addDevices,
            addDays: addDays,
          );
    final orderNo = (data["order_no"] ?? data["trade_no"] ?? "").toString();
    if (orderNo.isNotEmpty) {
      _draftOrderNo = orderNo;
    }
    return data;
  }

  static Future<void> cancelDraft() async {
    if (_inPayment) {
      Log.i("MclashDeviceUpgrade: 支付进行中，跳过取消草稿订单");
      return;
    }
    final orderNo = _draftOrderNo;
    if (orderNo == null || orderNo.isEmpty) {
      return;
    }
    _draftOrderNo = null;
    try {
      final override = debugCancelOverride;
      if (override != null) {
        await override(orderNo);
      } else {
        await MclashApi.cancelOrder(orderNo);
      }
      Log.i("MclashDeviceUpgrade: 已取消草稿订单 $orderNo");
    } catch (e) {
      Log.w("MclashDeviceUpgrade: 取消草稿订单 $orderNo 失败 $e");
    }
  }

  static void markPaid() {
    _draftOrderNo = null;
  }

  static Future<Map<String, dynamic>?> refreshIfUnpayable({
    required String orderNo,
    required int addDevices,
    required int addDays,
  }) async {
    if (orderNo.isEmpty) {
      return null;
    }
    String? status;
    try {
      final override = debugOrderStatusOverride;
      status = override != null
          ? await override(orderNo)
          : (await MclashApi.orderStatus(orderNo))?["status"]?.toString();
    } catch (e) {
      Log.w("MclashDeviceUpgrade: 查询订单 $orderNo 状态失败 $e");
      return null;
    }
    final s = (status ?? "").trim().toLowerCase();
    if (s.isEmpty || s == "pending" || s == "paid" || s == "completed") {
      return null;
    }
    Log.w("MclashDeviceUpgrade: 草稿订单 $orderNo 状态「$s」不可支付，按同样参数重新算价");
    _draftOrderNo = null;
    return quote(addDevices: addDevices, addDays: addDays);
  }

  static int? newDeviceLimitOf(Map<String, dynamic> data) {
    final top = (data["new_device_limit"] as num?)?.toInt();
    if (top != null) {
      return top;
    }
    final extra = _extraOf(data);
    return (extra["new_device_limit"] as num?)?.toInt();
  }

  static String newExpireTimeOf(Map<String, dynamic> data) {
    final top = (data["new_expire_time"] ?? "").toString();
    if (top.isNotEmpty) {
      return top;
    }
    return (_extraOf(data)["new_expire_time"] ?? "").toString();
  }

  static Map<String, dynamic> _extraOf(Map<String, dynamic> data) {
    final raw = data["extra_data"];
    if (raw is Map) {
      return Map<String, dynamic>.from(raw);
    }
    if (raw is String && raw.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map) {
          return Map<String, dynamic>.from(decoded);
        }
      } catch (_) {}
    }
    return const {};
  }

  static double amountOf(Map<String, dynamic> data) =>
      double.tryParse(
        (data["final_amount"] ?? data["amount"] ?? "0").toString(),
      ) ??
      0;
}
