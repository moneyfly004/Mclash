import 'package:flutter_test/flutter_test.dart';
import 'package:mclash/mf/mclash_device_upgrade.dart';

void main() {
  var seq = 0;

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
    MclashDeviceUpgrade.markPaid(); 
  });

  tearDown(() {
    MclashDeviceUpgrade.debugQuoteOverride = null;
    MclashDeviceUpgrade.debugCancelOverride = null;
    MclashDeviceUpgrade.debugOrderStatusOverride = null;
    MclashDeviceUpgrade.endPayment(keepOrder: true);
  });

  test('第二次算价（改参数）等排队时，两次调用都拿到最后一轮的订单', () async {
    stubQuote();

    final first = MclashDeviceUpgrade.quote(addDevices: 1, addDays: 0);
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
    expect(r1["id"], 130);
  });

  test('排队期间的中间参数不会被当成结果返回', () async {
    stubQuote(delay: const Duration(milliseconds: 30));

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
