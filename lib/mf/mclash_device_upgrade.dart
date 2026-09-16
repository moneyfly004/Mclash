library;

import 'package:mclash/app/utils/log.dart';
import 'package:mclash/mf/mclash_api.dart';

/// 设备/时长增量升级的**算价 + 草稿订单**管理。
///
/// 服务端实测行为（很重要，代码必须顺着它来）：
///   * `POST /orders/upgrade {add_devices, add_days}` 会**直接建单**；
///   * `preview_only` 后端不认 —— 算价请求同样会落一笔 `pending` 订单。
///
/// 所以正确姿势不是「先算价再下单」（那样一次操作会留下两笔订单），而是：
/// 把算价返回的订单当**草稿订单**，用户点支付就用它付；改数量/退出时取消掉，
/// 别在他的订单列表里堆垃圾。
abstract final class MclashDeviceUpgrade {
  static String? _draftOrderNo;

  /// 当前草稿订单号（没有则为空）。
  static String get draftOrderNo => _draftOrderNo ?? "";

  /// 测试缝：替换真实算价（widget 测试没有网络）。
  static Future<Map<String, dynamic>> Function(int devices, int days)?
  debugQuoteOverride;

  /// 测试缝：替换真实取消。
  static Future<void> Function(String orderNo)? debugCancelOverride;

  /// 并发保护：连点「重新算价」会并发走 cancelDraft + 建单，
  /// 结果可能留下两笔草稿订单（用户没付款却在订单列表里看到两笔）。
  static Future<Map<String, dynamic>>? _quoteInflight;
  static int _quotePendingDevices = 0;
  static int _quotePendingDays = 0;

  /// 算价：返回 `{order_no, amount, final_amount, ...}`。
  static Future<Map<String, dynamic>> quote({
    required int addDevices,
    required int addDays,
  }) {
    if (_quoteInflight != null) {
      // 记住最后一次请求的参数：等当前这次结束后立刻按最新参数再算一次
      _quotePendingDevices = addDevices;
      _quotePendingDays = addDays;
      Log.i("MclashDeviceUpgrade: 算价进行中，已排队最新参数 $addDevices/$addDays");
      return _quoteInflight!;
    }
    final future = _quoteInner(addDevices: addDevices, addDays: addDays);
    _quoteInflight = future;
    return future.whenComplete(() async {
      _quoteInflight = null;
      if (_quotePendingDevices > 0 || _quotePendingDays > 0) {
        final d = _quotePendingDevices;
        final day = _quotePendingDays;
        _quotePendingDevices = 0;
        _quotePendingDays = 0;
        await quote(addDevices: d, addDays: day);
      }
    });
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

  /// 取消草稿订单（幂等；没有草稿时什么都不做）。
  static Future<void> cancelDraft() async {
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

  /// 支付成功后调用：草稿已经变成正式订单，不能再当作草稿取消。
  static void markPaid() {
    _draftOrderNo = null;
  }

  /// 从算价响应里取应付金额。
  static double amountOf(Map<String, dynamic> data) =>
      double.tryParse(
        (data["final_amount"] ?? data["amount"] ?? "0").toString(),
      ) ??
      0;
}
