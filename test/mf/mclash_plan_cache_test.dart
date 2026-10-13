import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mclash/mf/mclash_plan_cache.dart';
import 'package:path/path.dart' as p;

/// 回归（用户点名）："每次打开套餐购买都要重新拉后台配置，感觉很慢 —— 应该有缓存"。
///
/// 这里锁住缓存的语义：内存命中 / TTL 过期 / 落盘往返 / 下单支付后失效。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tmp;

  setUp(() async {
    tmp = await Directory.systemTemp.createTemp("mclash_plan_cache_test");
    // 顺序很重要：debugReset() 会清掉 override，所以先 reset 再设。
    MclashPlanCache.debugReset();
    MclashPlanCache.debugDirOverride = () async => tmp.path;
  });

  tearDown(() async {
    MclashPlanCache.debugReset();

    try {
      await tmp.delete(recursive: true);
    } catch (_) {}
  });


  /// 模拟"重启 App"：清内存 + 重新注入目录 + 从盘上读回。
  /// （debugReset() 会清掉 debugDirOverride，所以顺序必须是 reset → 注入 → 读盘）
  Future<void> simulateRestart() async {
    MclashPlanCache.debugReset();
    MclashPlanCache.debugDirOverride = () async => tmp.path;
    await MclashPlanCache.loadFromDisk();
  }

  final plans = <Map<String, dynamic>>[
    {"id": 1, "name": "月付", "price": "10.00", "is_recommended": true},
  ];
  final methods = <Map<String, dynamic>>[
    {"id": -1, "pay_type": "balance", "name": "余额支付"},
  ];

  test('保存后立刻命中（内存）', () async {
    await MclashPlanCache.save(packages: plans, methods: methods);
    expect(MclashPlanCache.packages?.length, 1);
    expect(MclashPlanCache.methods?.length, 1);
  });

  test('落盘往返：新进程（内存清空）也能读到', () async {
    await MclashPlanCache.save(packages: plans, methods: methods);
    await simulateRestart();
    expect(
      MclashPlanCache.packagesStale?.first["name"],
      "月付",
      reason: '磁盘缓存要能复用，否则每次冷启动都得等网络',
    );
    expect(MclashPlanCache.methodsStale?.length, 1);
  });

  test('过期数据仍可"先渲染"（不转圈），但不当作"新鲜"直信', () async {
    await MclashPlanCache.save(packages: plans, methods: methods);

    // 手动把内存里的时间戳老化（等价于"缓存放了一整天"）
    final f = File(p.join(tmp.path, "plan_cache.json"));
    final raw = await f.readAsString();
    await f.writeAsString(
      raw
          .replaceAll(RegExp(r'"packagesAt":"[^"]*"'),
              '"packagesAt":"2020-01-01T00:00:00.000"')
          .replaceAll(RegExp(r'"methodsAt":"[^"]*"'),
              '"methodsAt":"2020-01-01T00:00:00.000"'),
      flush: true,
    );
    await simulateRestart();

    expect(
      MclashPlanCache.packagesStale,
      isNotNull,
      reason: '过期的也要能先渲染出来（否则进页面还是转圈）',
    );
    expect(
      MclashPlanCache.packages,
      isNull,
      reason: '过期就不该被当成"新鲜"直接信任（要后台刷新）',
    );
    expect(MclashPlanCache.hasStale, isTrue);
  });

  test('下单/支付成功 → 失效（下次进入强制在线）', () async {
    await MclashPlanCache.save(packages: plans, methods: methods);
    expect(MclashPlanCache.hasStale, isTrue);

    await MclashPlanCache.invalidate();

    expect(MclashPlanCache.packages, isNull);
    expect(MclashPlanCache.packagesStale, isNull);
    expect(
      File(p.join(tmp.path, "plan_cache.json")).existsSync(),
      isFalse,
      reason: '失效要连磁盘一起清，否则下次冷启动又用旧价格',
    );
  });
}
