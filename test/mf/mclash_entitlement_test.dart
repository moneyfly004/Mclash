import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mclash/mf/mclash_entitlement.dart';
import 'package:mclash/mf/mclash_subscription_nodes.dart';
import 'package:mclash/mf/mclash_subscription_notice.dart';
import 'package:path/path.dart' as path;

void main() {
  late Directory dir;
  var purgeCount = 0;
  var verifyCount = 0;
  var verifyResult = true;

  final fixedNow = DateTime(2026, 1, 1, 12, 0, 0);

  setUp(() async {
    dir = await Directory.systemTemp.createTemp("mclash_entitlement_test");
    purgeCount = 0;
    verifyCount = 0;
    verifyResult = true;

    MclashEntitlement.debugReset();
    MclashEntitlement.debugDirOverride = () async => dir.path;
    MclashEntitlement.debugKeyOverride = () async => "test-key";
    MclashEntitlement.now = () => fixedNow;
    MclashEntitlement.onlineVerifyOverride = () async {
      verifyCount++;
      if (!verifyResult) {
        return false;
      }
      // 模拟真实的成功校验：账号层会把新租约写下来
      await MclashEntitlement.debugSetLease(
        verifiedAt: fixedNow,
        expireAt: DateTime(2026, 6, 1),
        lastSeenAt: fixedNow,
      );
      return true;
    };
    MclashEntitlement.purgeOverride = () async {
      purgeCount++;
    };
  });

  tearDown(() async {
    MclashEntitlement.debugReset();
    try {
      await dir.delete(recursive: true);
    } catch (_) {}
  });

  group('到期 / 封禁（产品的硬要求：不能连、旧配置也不能用）', () {
    test('套餐已到期：离线也拒绝，并且清掉本地配置档', () async {
      await MclashEntitlement.debugSetLease(
        verifiedAt: DateTime(2025, 12, 31, 12),
        expireAt: DateTime(2026, 1, 1, 0, 0, 1),
        lastSeenAt: fixedNow,
      );

      final d = await MclashEntitlement.check(allowNetwork: false);

      expect(d.allowed, isFalse);
      expect(d.state, MclashEntitlementState.expired);
      expect(purgeCount, 1, reason: '到期必须清掉本地订阅配置档');
      expect(verifyCount, 0, reason: '到期是离线就能判定的，不需要联网');
    });

    test('服务端已封禁：直接拒绝并清档', () async {
      await MclashEntitlement.debugSetLease(
        verifiedAt: fixedNow,
        expireAt: DateTime(2026, 6, 1),
        lastSeenAt: fixedNow,
        blocked: true,
        reason: "❌ 原因: 账号已被禁用",
      );

      final d = await MclashEntitlement.check(allowNetwork: false);

      expect(d.allowed, isFalse);
      expect(d.state, MclashEntitlementState.blocked);
      expect(d.message, contains("禁用"));
      expect(purgeCount, 1);
    });

    test('清理是幂等的（每 5 分钟刷新不会反复删档）', () async {
      await MclashEntitlement.debugSetLease(
        expireAt: DateTime(2025, 1, 1),
        verifiedAt: DateTime(2024, 12, 31),
        lastSeenAt: fixedNow,
      );

      await MclashEntitlement.check(allowNetwork: false);
      await MclashEntitlement.check(allowNetwork: false);
      await MclashEntitlement.check(allowNetwork: false);

      expect(purgeCount, 1);
    });

    test('设备数超限（非致命受限）：拦连接，但不清掉配置档（用户可自助恢复）',
        () async {
      await MclashEntitlement.debugSetLease(
        verifiedAt: fixedNow,
        expireAt: DateTime(2026, 6, 1),
        lastSeenAt: fixedNow,
        blocked: true,
        blockFatal: false,
        reason: "设备数量已达上限（10/10）",
      );

      final d = await MclashEntitlement.check(allowNetwork: false);

      expect(d.allowed, isFalse);
      expect(d.state, MclashEntitlementState.blocked);
      expect(purgeCount, 0, reason: '设备超限不该清档，否则用户删完设备还得重新下载订阅');
    });

    test('guard() 给服务层的返回值非空（否则连接会被放行）', () async {
      await MclashEntitlement.debugSetLease(
        expireAt: DateTime(2025, 1, 1),
        verifiedAt: DateTime(2024, 12, 31),
        lastSeenAt: fixedNow,
      );
      final err = await MclashEntitlement.guard();
      expect(err, isNotNull);
      expect(err!.message, isNotEmpty);
    });
  });

  group('校验新鲜度（防止拿旧配置长期离线使用）', () {
    test('新鲜租约：直接放行，且不触发联网校验', () async {
      await MclashEntitlement.debugSetLease(
        verifiedAt: fixedNow.subtract(const Duration(hours: 1)),
        expireAt: DateTime(2026, 6, 1),
        lastSeenAt: fixedNow,
      );

      final d = await MclashEntitlement.check();

      expect(d.allowed, isTrue);
      expect(verifyCount, 0);
    });

    test('超过 TTL：联网校验成功后放行', () async {
      await MclashEntitlement.debugSetLease(
        verifiedAt: fixedNow.subtract(const Duration(hours: 30)),
        expireAt: DateTime(2026, 6, 1),
        lastSeenAt: fixedNow,
      );

      final d = await MclashEntitlement.check();

      expect(d.allowed, isTrue);
      expect(verifyCount, 1);
    });

    test('超过 TTL 且联网失败，但在宽限期内：放行（不误伤付费用户）', () async {
      verifyResult = false;
      await MclashEntitlement.debugSetLease(
        verifiedAt: fixedNow.subtract(const Duration(hours: 30)),
        expireAt: DateTime(2026, 6, 1),
        lastSeenAt: fixedNow,
      );

      final d = await MclashEntitlement.check();

      expect(d.allowed, isTrue);
      expect(verifyCount, 1);
    });

    test('超过宽限期且联网失败：拒绝', () async {
      verifyResult = false;
      await MclashEntitlement.debugSetLease(
        verifiedAt: fixedNow.subtract(const Duration(hours: 100)),
        expireAt: DateTime(2026, 6, 1),
        lastSeenAt: fixedNow,
      );

      final d = await MclashEntitlement.check();

      expect(d.allowed, isFalse);
      expect(d.state, MclashEntitlementState.verifyFailed);
    });

    test('本机没有任何校验记录：联网失败时拒绝（不能靠旧配置离线连）', () async {
      verifyResult = false;

      final d = await MclashEntitlement.check();

      expect(d.allowed, isFalse);
      expect(d.state, MclashEntitlementState.needVerify);
    });

    test('本机没有任何校验记录：联网成功后放行', () async {
      final d = await MclashEntitlement.check();

      expect(d.allowed, isTrue);
      expect(verifyCount, 1);
    });
  });

  group('防绕过', () {
    test('系统时间回拨 + 联网失败：拒绝', () async {
      verifyResult = false;
      await MclashEntitlement.debugSetLease(
        verifiedAt: fixedNow,
        expireAt: DateTime(2026, 6, 1),
        // 曾经观察到「未来」的时间 → 说明时钟被调回去了
        lastSeenAt: fixedNow.add(const Duration(days: 2)),
      );

      final d = await MclashEntitlement.check();

      expect(d.allowed, isFalse);
      expect(d.state, MclashEntitlementState.tampered);
    });

    test('系统时间回拨但联网校验成功：放行（并刷新租约）', () async {
      await MclashEntitlement.debugSetLease(
        verifiedAt: fixedNow,
        expireAt: DateTime(2026, 6, 1),
        lastSeenAt: fixedNow.add(const Duration(days: 2)),
      );

      final d = await MclashEntitlement.check();

      expect(d.allowed, isTrue);
      expect(verifyCount, 1);
    });

    test('手工改本地租约（签名不符）→ 视为未校验', () async {
      final f = File(path.join(dir.path, MclashEntitlement.fileName));
      await f.writeAsString(
        jsonEncode(<String, dynamic>{
          "v": 1,
          "verifiedAt": "2025-12-31T00:00:00.000",
          "expireAt": "2030-01-01T00:00:00.000",
          "lastSeenAt": "2025-12-31T00:00:00.000",
          "blocked": false,
          "reason": "",
          "sig": "deadbeef",
        }),
      );

      final d = await MclashEntitlement.check(allowNetwork: false);

      expect(d.allowed, isFalse);
      expect(
        d.state,
        MclashEntitlementState.tampered,
        reason: '签名不符 = 本地授权数据被改动，要明确报异常而不是含糊的"需校验"',
      );
    });

    test('已封禁的租约被改成未封禁（签名不符）也不能放行', () async {
      await MclashEntitlement.debugSetLease(
        verifiedAt: fixedNow,
        expireAt: DateTime(2026, 6, 1),
        lastSeenAt: fixedNow,
        blocked: true,
        reason: "账号已被禁用",
      );
      final f = File(path.join(dir.path, MclashEntitlement.fileName));
      final raw = jsonDecode(await f.readAsString()) as Map<String, dynamic>;
      raw["blocked"] = false;
      await f.writeAsString(jsonEncode(raw));
      // 强制重读，模拟「改完文件后重启 App」
      await MclashEntitlement.load(force: true);

      final d = await MclashEntitlement.check(allowNetwork: false);

      expect(d.allowed, isFalse);
      expect(d.state, MclashEntitlementState.tampered);
    });
  });

  group('到期时间解析', () {
    test('只给日期 → 当天 23:59:59', () {
      final at = MclashEntitlement.parseExpireAt("2028-06-25", null, fixedNow);
      expect(at, DateTime(2028, 6, 25, 23, 59, 59));
    });

    test('带时间 → 原样解析', () {
      final at = MclashEntitlement.parseExpireAt(
        "2028-06-25T12:44:45Z",
        null,
        fixedNow,
      );
      expect(at, isNotNull);
      expect(at!.toUtc().hour, 12);
    });

    test('只有剩余天数 → 用当前时间推算', () {
      final at = MclashEntitlement.parseExpireAt("", 10, fixedNow);
      expect(at, fixedNow.add(const Duration(days: 10)));
    });

    test('都没有 → null（不拦）', () {
      expect(MclashEntitlement.parseExpireAt("", null, fixedNow), isNull);
    });
  });

  group('订阅受限信号（回归：Isolate 静态字段丢失）', () {
    test('只有伪节点时，受限结论随返回值带回主 isolate', () {
      const yaml = '''
proxies:
  - {name: "📢 官网: example.com", type: ss, server: a.example.com, port: 443}
  - {name: "❌ 原因: 套餐已过期", type: ss, server: b.example.com, port: 443}
  - {name: "💡 解决: 请前往官网续费", type: ss, server: c.example.com, port: 443}
''';
      final parsed = MclashSubscriptionNodes.parseNodesWithNotice(yaml);
      expect(parsed.nodes, isEmpty, reason: '伪节点不算真节点');
      expect(
        parsed.notice.blocked,
        isTrue,
        reason: '以前这里恒为 unknown，导致「已过期/被封禁」永远检测不到',
      );
      expect(parsed.notice.state, MclashNoticeState.expired);
    });

    test('有真节点时不受限', () {
      const yaml = '''
proxies:
  - {name: "🇭🇰 香港 01", type: ss, server: hk.example.com, port: 443}
  - {name: "❌ 原因: 套餐已过期", type: ss, server: b.example.com, port: 443}
''';
      final parsed = MclashSubscriptionNodes.parseNodesWithNotice(yaml);
      expect(parsed.nodes.length, 1);
      expect(parsed.notice.blocked, isFalse);
      expect(parsed.notice.state, MclashNoticeState.ok);
    });
  });
}
