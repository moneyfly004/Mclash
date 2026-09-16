import 'package:flutter_test/flutter_test.dart';
import 'package:mclash/mf/mclash_device_upgrade.dart';

/// 草稿订单在支付期间**不许被取消**的回归。
///
/// 真实事故（用户报「支付时提示订单不存在或状态不正确」）：
/// 设备管理里选好支付方式后，代码先关掉算价面板，而面板关闭时挂着
/// `whenComplete(cancelDraft)` —— 刚建好的订单立刻被取消，紧接着用这笔
/// **已取消**的订单去支付/发起支付，后端自然回「订单不存在或状态不正确」。
void main() {
  final cancelled = <String>[];

  setUp(() {
    cancelled.clear();
    MclashDeviceUpgrade.debugQuoteOverride = null;
    MclashDeviceUpgrade.debugCancelOverride = (orderNo) async {
      cancelled.add(orderNo);
    };
  });

  tearDown(() async {
    MclashDeviceUpgrade.debugCancelOverride = null;
    // 解锁，避免影响其它用例
    MclashDeviceUpgrade.endPayment(keepOrder: true);
  });

  test('进入支付流程后，关面板触发的 cancelDraft 不会取消订单', () async {
    MclashDeviceUpgrade.debugQuoteOverride = (devices, days) async =>
        {"order_no": "UPG-1", "final_amount": 10};
    await MclashDeviceUpgrade.quote(addDevices: 1, addDays: 0);

    MclashDeviceUpgrade.beginPayment();
    await MclashDeviceUpgrade.cancelDraft();

    expect(
      cancelled,
      isEmpty,
      reason: '支付进行中不许取消这笔订单（否则支付必然报「订单不存在」）',
    );
    expect(MclashDeviceUpgrade.draftOrderNo, "UPG-1");
  });

  test('支付流程结束后可以正常取消（用户放弃支付要清理草稿）', () async {
    MclashDeviceUpgrade.debugQuoteOverride = (devices, days) async =>
        {"order_no": "UPG-2", "final_amount": 10};
    await MclashDeviceUpgrade.quote(addDevices: 1, addDays: 0);

    MclashDeviceUpgrade.beginPayment();
    MclashDeviceUpgrade.endPayment();
    await MclashDeviceUpgrade.cancelDraft();

    expect(cancelled, ["UPG-2"], reason: '放弃支付后要把草稿订单清掉，别留 pending');
    expect(MclashDeviceUpgrade.draftOrderNo, isEmpty);
  });

  test('支付成功（keepOrder）后不再当作草稿取消', () async {
    MclashDeviceUpgrade.debugQuoteOverride = (devices, days) async =>
        {"order_no": "UPG-3", "final_amount": 10};
    await MclashDeviceUpgrade.quote(addDevices: 1, addDays: 0);

    MclashDeviceUpgrade.beginPayment();
    MclashDeviceUpgrade.endPayment(keepOrder: true);
    await MclashDeviceUpgrade.cancelDraft();

    expect(cancelled, isEmpty, reason: '已支付的订单不能再取消');
  });
}
