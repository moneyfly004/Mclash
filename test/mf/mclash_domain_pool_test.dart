import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mclash/mf/mclash_domains.dart';

void main() {
  group('MclashDomainPool', () {
    late Map<String, String> disk;

    setUp(() {
      disk = <String, String>{};
      MclashDomainPool.debugReadOverride = (key) async => disk[key];
      MclashDomainPool.debugWriteOverride = (key, value) async {
        disk[key] = value;
      };
      MclashDomainPool.debugNow = DateTime.now;
      MclashDomainPool.debugReset();
    });

    tearDown(() {
      MclashDomainPool.debugReadOverride = null;
      MclashDomainPool.debugWriteOverride = null;
      MclashDomainPool.debugNow = DateTime.now;
      MclashDomainPool.debugReset();
    });

    test('首次运行：按默认顺序给候选，且不含拼错的 dollarfly.top', () {
      expect(MclashDomainPool.apiBaseUrls(), <String>[
        'https://new.moneyfly.top/api/v1',
        'https://dollarsfly.top/api/v1',
      ]);

      final subs = MclashDomainPool.subscriptionUrlsFor(
        'https://new.moneyfly.top/api/v1/client/subscribe?token=abc',
      );
      expect(subs, <String>[
        'https://new.moneyfly.top/api/v1/client/subscribe?token=abc',
        'https://sub.dollarsfly.top/api/v1/client/subscribe?token=abc',
        'https://dollarsfly.top/api/v1/client/subscribe?token=abc',
      ]);
      for (final u in subs) {
        expect(
          u.contains('dollarfly.top') && !u.contains('dollarsfly.top'),
          isFalse,
          reason: 'dollarfly.top 是错误拼写（DNS 不存在），绝不能写进候选',
        );
      }
    });

    test('上次可用的域名会被排到候选第一位', () {
      MclashDomainPool.reportSuccess('dollarsfly.top');

      expect(
        MclashDomainPool.apiBaseUrls().first,
        'https://dollarsfly.top/api/v1',
        reason: '换域名要「记住上次可用的」，否则每次请求都从头试一遍',
      );
      expect(MclashDomainPool.lastGoodApiHost(), 'dollarsfly.top');

      final subs = MclashDomainPool.subscriptionUrlsFor(
        'https://new.moneyfly.top/sub?token=abc',
      );
      expect(subs.first, 'https://new.moneyfly.top/sub?token=abc',
          reason: '原文 host 来自刚跑通的 API 域名，优先照原样用');
      expect(subs[1], 'https://dollarsfly.top/sub?token=abc',
          reason: '上次可用的订阅域名紧随其后');
      expect(subs.toSet().length, subs.length, reason: '候选不能重复');
    });

    test('失败域名进入冷却：排到最后，冷却过后恢复正常位置', () {
      MclashDomainPool.reportFailure('new.moneyfly.top');

      expect(MclashDomainPool.inCooldown('new.moneyfly.top'), isTrue);
      expect(
        MclashDomainPool.apiBaseUrls().first,
        'https://dollarsfly.top/api/v1',
        reason: '冷却中的域名不该被优先尝试',
      );

      // 冷却到期（把「现在」往后推到冷却窗口之外）。
      MclashDomainPool.debugNow = () => DateTime.now().add(
            MclashDomainPool.kFailureCooldown + const Duration(seconds: 1),
          );
      expect(MclashDomainPool.inCooldown('new.moneyfly.top'), isFalse);
      expect(
        MclashDomainPool.apiBaseUrls().first,
        'https://new.moneyfly.top/api/v1',
        reason: '冷却结束后要回到默认顺序，不能永久打入冷宫',
      );
    });

    test('全部域名都在冷却时仍然给出完整候选（不能返回空）', () {
      MclashDomainPool.reportFailure('new.moneyfly.top');
      MclashDomainPool.reportFailure('dollarsfly.top');

      expect(
        MclashDomainPool.apiBaseUrls().length,
        2,
        reason: '所有域名都在冷却时若返回空，就等于什么都试不了',
      );
      expect(MclashDomainPool.apiBaseUrls().toSet().length, 2);
    });

    test('轮换到好域名后会清掉它的失败记录', () {
      MclashDomainPool.reportFailure('dollarsfly.top');
      expect(MclashDomainPool.inCooldown('dollarsfly.top'), isTrue);

      MclashDomainPool.reportSuccess('dollarsfly.top');
      expect(MclashDomainPool.inCooldown('dollarsfly.top'), isFalse);
      expect(MclashDomainPool.lastGoodApiHost(), 'dollarsfly.top');
    });

    test('状态会落盘，且坏数据不会把候选弄丢', () async {
      MclashDomainPool.reportSuccess('dollarsfly.top');
      MclashDomainPool.reportFailure('new.moneyfly.top');
      await MclashDomainPool.debugFlushPersistence();

      final raw = disk[MclashDomainPool.kStorageKey];
      expect(raw, isNotNull);
      final decoded = jsonDecode(raw!) as Map<String, dynamic>;
      expect(decoded['last_good_api_host'], 'dollarsfly.top');
      expect(
        (decoded['failures'] as Map).containsKey('new.moneyfly.top'),
        isTrue,
      );

      // 坏数据：解析失败要回落默认顺序，而不是抛异常/给空候选。
      disk[MclashDomainPool.kStorageKey] = '{not json';
      MclashDomainPool.debugReset(resetLoaded: true);
      expect(MclashDomainPool.lastGoodApiHost(), isNull);
      expect(MclashDomainPool.apiBaseUrls().length, 2);

      // 干净启动：盘上留的是上一次可用的域名时，要优先用它（读盘是异步的，
      // 第一次读候选会先给默认顺序，随后异步读入磁盘状态）。
      disk[MclashDomainPool.kStorageKey] = jsonEncode(<String, dynamic>{
        'last_good_api_host': 'dollarsfly.top',
        'last_good_subscription_host': null,
        'failures': <String, String>{},
      });
      MclashDomainPool.debugReset(resetLoaded: true);
      expect(
        MclashDomainPool.apiBaseUrls().first,
        'https://new.moneyfly.top/api/v1',
        reason: '第一次调用不等读盘，先用默认顺序，避免启动时卡住',
      );
      await Future<void>.delayed(Duration.zero);
      expect(
        MclashDomainPool.apiBaseUrls().first,
        'https://dollarsfly.top/api/v1',
        reason: '读完盘后要优先用上次可用的域名',
      );
    });

    test('订阅候选改写只换 host，path/query/fragment 原样保留', () {
      final urls = MclashDomainPool.subscriptionUrlsFor(
        'https://new.moneyfly.top/api/v1/client/subscribe?token=t0ken&flag=clash#frag',
      );
      final swapped = urls[1];
      expect(swapped, contains('token=t0ken'));
      expect(swapped, contains('flag=clash'));
      expect(swapped, endsWith('#frag'));
      expect(swapped, startsWith('https://sub.dollarsfly.top/'));
      expect(swapped, contains('/api/v1/client/subscribe'));
    });

    test('无法解析的订阅地址：原样返回，不吞掉', () {
      expect(
        MclashDomainPool.subscriptionUrlsFor('not a url'),
        <String>['not a url'],
      );
    });

    test('API 清单成员判定', () {
      expect(MclashDomainPool.isApiHost('dollarsfly.top'), isTrue);
      expect(MclashDomainPool.isApiHost('DOLLARSFLY.TOP'), isTrue);
      expect(MclashDomainPool.isApiHost('sub.dollarsfly.top'), isFalse,
          reason: '订阅域名不是 API 域名');
    });
  });
}
