import 'package:flutter_test/flutter_test.dart';
import 'package:mclash/mf/mclash_device_upgrade.dart';

/// 算价合并（连点/改参数）必须把**最后一轮**的结果交给**所有**调用者。
///
/// 真实事故（用户报「支付发起失败：这笔订单已被取消或已支付」）：
/// 打开升级面板会先按 +1 台算价（建 UPG...0021），用户再点「+30 天」时第二次
/// 算价请求落在「正在进行中」的分支里 —— 旧实现把**正在进行中的那个 future**
/// 直接返回给第二次调用者，于是：
///   * 界面显示的订单号/金额是**上一次**的（UPG...0021 / ¥71，而不是 ¥1744）；
///   * 模块内部 `_draftOrderNo` 已经是新一轮的 UPG...0022；
///   * 新一轮开始时把 UPG...0021 取消了（日志：已取消草稿订单 UPG202609160021）；
///   * 用户点支付用的正是那笔**已取消**的订单 → 后端回「订单不存在或状态不正确」。
///
/// 这个文件用**假算价**重放那条时间线，钉住修复：谁问都只能拿到最后一轮。
void main() {
  var seq = 0;

  /// 假算价：订单号带参数与序号，序号能区分「这是新算的一笔」。
  void stubQuote({Duration delay = const Duration(milliseconds: 20)}) {
    MclashDeviceUpgrade.debugQuoteOverride = (devices, days) async {
      await Future<void>.delayed(delay);
      seq += 1;
      return {
        "id": devices * 100 + days,
        "order_no": "UPG-$devices-$days#$seq",
        "final_amount": days > 0 ? 1744.33 : 71.0,
      };
    };
  }

  setUp(() {
    seq = 0;
    MclashDeviceUpgrade.debugQuoteOverride = null;
    MclashDeviceUpgrade.debugCancelOverride = null;
    MclashDeviceUpgrade.debugOrderStatusOverride = null;
    MclashDeviceUpgrade.markPaid(); // 清掉上一用例残留的草稿
  });

  tearDown(() {
    MclashDeviceUpgrade.debugQuoteOverride = null;
    MclashDeviceUpgrade.debugCancelOverride = null;
    MclashDeviceUpgrade.debugOrderStatusOverride = null;
    MclashDeviceUpgrade.endPayment(keepOrder: true);
  });

  test('第二次算价（改参数）等排队时，两次调用都拿到最后一轮的订单', () async {
    stubQuote();

    // 面板打开：先按 +1 台算价（这一轮还没结束）
    final first = MclashDeviceUpgrade.quote(addDevices: 1, addDays: 0);
    // 用户立刻点了「+30 天」：第二轮的参数被排队
    final second = MclashDeviceUpgrade.quote(addDevices: 1, addDays: 30);

    final r1 = await first;
    final r2 = await second;

    expect(
      r1["order_no"],
      "UPG-1-30#2",
      reason: '第一轮的调用者也必须看到最后一轮的结果（否则界面显示的是废单价格）',
    );
    expect(r2["order_no"], "UPG-1-30#2");
    expect(
      MclashDeviceUpgrade.draftOrderNo,
      r1["order_no"],
      reason: '模块内部记住的草稿订单必须与界面显示的订单一致，否则支付打的是另一笔单',
    );
    expect(MclashDeviceUpgrade.draftOrderNo, r2["order_no"]);
    // 界面用 `id` 向后端发起支付，它也必须来自同一轮
    expect(r1["id"], 130);
  });

  test('排队期间的中间参数不会被当成结果返回', () async {
    stubQuote(delay: const Duration(milliseconds: 30));

    // 面板打开先算 +1 台；用户紧接着连点 +2 台、再点 +30 天。
    // 正在飞的那一轮（1/0）无法收回，但**交付**出去的必须是最后参数那一轮（2/30）。
    final a = MclashDeviceUpgrade.quote(addDevices: 1, addDays: 0);
    final b = MclashDeviceUpgrade.quote(addDevices: 2, addDays: 0);
    final c = MclashDeviceUpgrade.quote(addDevices: 2, addDays: 30);

    final results = await Future.wait([a, b, c]);
    for (final r in results) {
      expect(r["order_no"], "UPG-2-30#2", reason: '只交付最后一轮');
    }
    expect(MclashDeviceUpgrade.draftOrderNo, "UPG-2-30#2");
  });

  test('没有并发时逐次算价互不影响', () async {
    stubQuote(delay: Duration.zero);
    final r1 = await MclashDeviceUpgrade.quote(addDevices: 1, addDays: 0);
    final r2 = await MclashDeviceUpgrade.quote(addDevices: 3, addDays: 30);
    expect(r1["order_no"], "UPG-1-0#1");
    expect(r2["order_no"], "UPG-3-30#2");
    expect(MclashDeviceUpgrade.draftOrderNo, "UPG-3-30#2");
  });

  test('支付前发现草稿单已失效 → 按同样参数重新算一笔（不再报「订单不存在」）', () async {
    stubQuote(delay: Duration.zero);
    final dead = await MclashDeviceUpgrade.quote(addDevices: 1, addDays: 30);
    expect(dead["order_no"], "UPG-1-30#1");

    MclashDeviceUpgrade.debugOrderStatusOverride = (orderNo) async => "cancelled";
    final fresh = await MclashDeviceUpgrade.refreshIfUnpayable(
      orderNo: "UPG-1-30#1",
      addDevices: 1,
      addDays: 30,
    );
    expect(fresh, isNotNull, reason: '失效订单要重新算价，不能拿去支付');
    expect(fresh!["order_no"], isNot(dead["order_no"]), reason: '必须是新的一笔');
    expect(fresh["order_no"], "UPG-1-30#2");
    expect(MclashDeviceUpgrade.draftOrderNo, fresh["order_no"]);
  });

  test('「已过期」同样重新算价', () async {
    stubQuote(delay: Duration.zero);
    await MclashDeviceUpgrade.quote(addDevices: 1, addDays: 0);
    MclashDeviceUpgrade.debugOrderStatusOverride = (orderNo) async => "expired";
    final fresh = await MclashDeviceUpgrade.refreshIfUnpayable(
      orderNo: "UPG-1-0#1",
      addDevices: 1,
      addDays: 0,
    );
    expect(fresh, isNotNull);
  });

  test('支付前确认草稿单仍然可付 → 不动它（不重复建单）', () async {
    stubQuote(delay: Duration.zero);
    await MclashDeviceUpgrade.quote(addDevices: 1, addDays: 0);

    MclashDeviceUpgrade.debugOrderStatusOverride = (orderNo) async => "pending";
    final fresh = await MclashDeviceUpgrade.refreshIfUnpayable(
      orderNo: "UPG-1-0#1",
      addDevices: 1,
      addDays: 0,
    );
    expect(fresh, isNull);
    expect(MclashDeviceUpgrade.draftOrderNo, "UPG-1-0#1");
  });

  test('已支付的订单不重新算价（避免再建一笔、重复扣款）', () async {
    stubQuote(delay: Duration.zero);
    await MclashDeviceUpgrade.quote(addDevices: 1, addDays: 0);

    MclashDeviceUpgrade.debugOrderStatusOverride = (orderNo) async => "paid";
    final fresh = await MclashDeviceUpgrade.refreshIfUnpayable(
      orderNo: "UPG-1-0#1",
      addDevices: 1,
      addDays: 0,
    );
    expect(fresh, isNull, reason: '已支付就如实报错，不能再下一单');
  });

  test('查询订单状态失败（网络抖动）时不重新算价，按原订单继续', () async {
    stubQuote(delay: Duration.zero);
    await MclashDeviceUpgrade.quote(addDevices: 1, addDays: 0);

    MclashDeviceUpgrade.debugOrderStatusOverride = (orderNo) async =>
        throw Exception("socket timeout");
    final fresh = await MclashDeviceUpgrade.refreshIfUnpayable(
      orderNo: "UPG-1-0#1",
      addDevices: 1,
      addDays: 0,
    );
    expect(fresh, isNull);
    expect(MclashDeviceUpgrade.draftOrderNo, "UPG-1-0#1");
  });
}
