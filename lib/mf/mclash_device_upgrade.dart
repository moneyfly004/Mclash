library;

import 'dart:convert';

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

  /// 正在支付中：这期间**不许**取消草稿单。
  ///
  /// 真实事故：设备管理里选好支付方式后，代码会先关掉算价面板，而面板关闭时
  /// 挂着 `whenComplete(cancelDraft)` —— 于是刚建好的订单立刻被取消，紧接着
  /// 支付/发起支付用的是**已取消**的订单，后端回「订单不存在或状态不正确」。
  static bool _inPayment = false;

  /// 进入支付流程（由设备管理页在关面板前调用）。
  static void beginPayment() => _inPayment = true;

  /// 支付流程结束（成功或用户放弃）。
  static void endPayment({bool keepOrder = false}) {
    _inPayment = false;
    if (keepOrder) {
      markPaid();
    }
  }

  /// 当前草稿订单号（没有则为空）。
  static String get draftOrderNo => _draftOrderNo ?? "";

  /// 测试缝：替换真实算价（widget 测试没有网络）。
  static Future<Map<String, dynamic>> Function(int devices, int days)?
  debugQuoteOverride;

  /// 测试缝：替换真实取消。
  static Future<void> Function(String orderNo)? debugCancelOverride;

  /// 测试缝：替换订单状态查询（返回 `pending`/`cancelled`/…；抛异常 = 查不到）。
  static Future<String?> Function(String orderNo)? debugOrderStatusOverride;

  /// 并发保护：连点「重新算价」会并发走 cancelDraft + 建单，
  /// 结果可能留下两笔草稿订单（用户没付款却在订单列表里看到两笔）。
  static Future<Map<String, dynamic>>? _quoteInflight;
  static int _pendingDevices = 0;
  static int _pendingDays = 0;
  static bool _hasPending = false;

  /// 算价：返回 `{order_no, amount, final_amount, ...}`。
  ///
  /// 并发语义（**必须**）：合并连点，而且**所有**调用者都拿到**最后一轮**的结果。
  ///
  /// 真实事故（用户报「支付发起失败：这笔订单已被取消或已支付」）：
  /// 旧实现把「正在进行中的那个 future」直接丢给后到的调用者，于是后到的调用者
  /// 拿到的是**上一轮**（旧参数）的订单号与金额 —— 界面照着它显示价格、也照着它
  /// 去支付；而模块内部 `_draftOrderNo` 已经换成新一轮的订单，紧接着新一轮的开始
  /// 就把旧订单 cancelDraft 掉了。用户点支付时用的正是那笔**已取消**的订单，
  /// 后端自然回「订单不存在或状态不正确」（实测 UPG...0021/0022 就是这一对）。
  static Future<Map<String, dynamic>> quote({
    required int addDevices,
    required int addDays,
  }) {
    _pendingDevices = addDevices;
    _pendingDays = addDays;
    _hasPending = true;
    final inflight = _quoteInflight;
    if (inflight != null) {
      // 参数记下来，等当前这轮结束后立刻按最新参数再算一次；
      // 返回的是**整条队列**的 future —— 也就是最后一轮的结果。
      Log.i("MclashDeviceUpgrade: 算价进行中，已排队最新参数 $addDevices/$addDays");
      return inflight;
    }
    final future = _drainQuote();
    _quoteInflight = future;
    return future;
  }

  /// 依次算完所有排队参数，只把**最后一轮**的结果交给调用者。
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

  /// 取消草稿订单（幂等；没有草稿时什么都不做）。
  static Future<void> cancelDraft() async {
    if (_inPayment) {
      // 支付流程正在用这笔订单，取消它等于把用户正在付的订单作废
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

  /// 支付成功后调用：草稿已经变成正式订单，不能再当作草稿取消。
  static void markPaid() {
    _draftOrderNo = null;
  }

  /// 支付前确认这笔草稿订单**还能付**：已失效（被取消/已过期/不存在）就按同样参数
  /// 重新算一笔。
  ///
  /// 返回 `null` = 原订单还能用；否则返回**新的**算价结果（新订单号 / 金额 / 订单 id）。
  ///
  /// 为什么要有这一步：后端算价落的是 30 分钟有效期的 `pending` 订单，用户在支付面板
  /// 里挑通道挑久了它就过期了。以前没有兜底，点下去只能看到
  /// 「订单不存在或状态不正确」。已支付的订单**不**重新算价（那会再建一笔、可能
  /// 重复扣款），交给调用方如实报错。
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
      // 查不通（网络抖动）就按原订单继续：真正的错误交给支付那一步报出来
      Log.w("MclashDeviceUpgrade: 查询订单 $orderNo 状态失败 $e");
      return null;
    }
    final s = (status ?? "").trim().toLowerCase();
    if (s.isEmpty || s == "pending" || s == "paid" || s == "completed") {
      return null;
    }
    Log.w("MclashDeviceUpgrade: 草稿订单 $orderNo 状态「$s」不可支付，按同样参数重新算价");
    // 这笔单已经废了，别再拿它去 cancel（省一次请求，也避免取消到别人的单）
    _draftOrderNo = null;
    return quote(addDevices: addDevices, addDays: addDays);
  }

  /// 升级后的设备上限与到期时间。
  ///
  /// 两个端点的返回位置不一样（实测）：
  ///   * `POST /orders/upgrade`（客户端现在用的，会建单）：设备数与到期时间在
  ///     **`extra_data` 这个 JSON 字符串里**（`new_device_limit` / `new_expire_time`）；
  ///   * `POST /orders/upgrade/calc`（纯算价）：直接顶层返回。
  /// 界面以前只读顶层，于是「升级后」的效果一直显示不出来 —— 顺手把两种都认了。
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

  /// 从算价响应里取应付金额。
  static double amountOf(Map<String, dynamic> data) =>
      double.tryParse(
        (data["final_amount"] ?? data["amount"] ?? "0").toString(),
      ) ??
      0;
}
