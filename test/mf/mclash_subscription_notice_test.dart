import 'package:flutter_test/flutter_test.dart';
import 'package:mclash/mf/mclash_account_service.dart';
import 'package:mclash/mf/mclash_subscription_nodes.dart';
import 'package:mclash/mf/mclash_subscription_notice.dart';

/// 「客户到期 / 被禁用 / 设备超过限制 → 禁止连接 + 覆盖配置档 + 只加载失效节点」
/// 这条产品行为的客户端侧回归测试。
///
/// 用**后端真实下发**的字符串钉死（生产环境只读实测过，见
/// `MclashSubscriptionNotice` 的文档注释）：
/// ```yaml
/// name: 订阅不存在
/// proxies:
///   - {name: "📢 官网: https://new.moneyfly.top", ...}
///   - {name: "❌ 原因: 订阅不存在", ...}
///   - {name: "💡 解决: 请检查订阅地址是否正确", ...}
///   - {name: "💬 客服: 2562866992@qq.com | QQ:2562866992", ...}
/// ```
void main() {
  const site = "📢 官网: https://new.moneyfly.top";
  const support = "💬 客服: 2562866992@qq.com | QQ:2562866992";

  group('后端提示节点 → 订阅状态', () {
    test('订阅不存在', () {
      final n = MclashSubscriptionNotice.parse([
        site,
        "❌ 原因: 订阅不存在",
        "💡 解决: 请检查订阅地址是否正确",
        support,
      ]);
      expect(n.state, MclashNoticeState.notFound);
      expect(n.blocked, isTrue);
      expect(n.title, "订阅不存在");
      expect(n.site, "https://new.moneyfly.top");
      expect(n.support, "2562866992@qq.com | QQ:2562866992");
      expect(n.fullText, contains("请检查订阅地址是否正确"));
    });

    test('订阅已过期（带过期时间）', () {
      final n = MclashSubscriptionNotice.parse([
        site,
        "❌ 原因: 订阅已过期",
        "💡 解决: 请前往官网续费 (过期时间: 2026-01-01)",
        support,
      ]);
      expect(n.state, MclashNoticeState.expired);
      expect(n.blocked, isTrue);
      expect(n.title, "订阅已过期");
      expect(n.fullText, contains("2026-01-01"));
    });

    test('订阅已失效（被禁用）', () {
      final n = MclashSubscriptionNotice.parse([
        site,
        "❌ 原因: 订阅已失效",
        "💡 解决: 请联系管理员检查订阅状态",
      ]);
      expect(n.state, MclashNoticeState.inactive);
      expect(n.blocked, isTrue);
    });

    test('设备数量超限：设备数从「解决」文案里解析出来', () {
      final n = MclashSubscriptionNotice.parse([
        site,
        "❌ 原因: 设备数量超限",
        "💡 解决: 当前设备 3/2，请在官网删除不使用的设备",
        support,
      ]);
      expect(n.state, MclashNoticeState.deviceOverLimit);
      expect(n.blocked, isTrue);
      expect(n.title, "设备数量超限");
      expect(n.deviceUsed, 3);
      expect(n.deviceLimit, 2);
      expect(n.fullText, contains("3/2"));
    });

    test('正常订阅：信息节点不算异常（否则用户明明能用却连不上）', () {
      final n = MclashSubscriptionNotice.parse([
        site,
        "⏰ 到期: 2028-06-25",
        "📱 设备: 10/500",
        support,
        "香港线路3",
        "日本东京",
      ]);
      expect(n.state, MclashNoticeState.ok);
      expect(n.blocked, isFalse);
      expect(n.expire, "2028-06-25");
      expect(n.deviceUsed, 10);
      expect(n.deviceLimit, 500);
    });

    test('空 proxies → unknown（一点信息都没有时不能乱拦）', () {
      expect(MclashSubscriptionNotice.parse([]).state, MclashNoticeState.unknown);
      expect(MclashSubscriptionNotice.parse([]).blocked, isFalse);
    });

    test('后端给了原因但不在已知几种（例如「服务暂时不可用」）→ 照样禁止连接，如实转述', () {
      // 配置档里确实一个真实节点都没有，放行只会让用户以为连上了。
      final n = MclashSubscriptionNotice.parse([
        "❌ 原因: 服务暂时不可用",
        "💡 解决: 请稍后重试；若持续出现请截图联系客服",
      ]);
      expect(n.state, MclashNoticeState.other);
      expect(n.blocked, isTrue);
      expect(n.title, "服务暂时不可用");
      expect(n.fullText, contains("请稍后重试"));
    });
  });

  group('从真实订阅 YAML 解析（含 proxy-groups）', () {
    test('到期订阅：解析出状态，且节点列表为空（只加载了失效节点）', () {
      const yaml = '''
name: 订阅已过期
port: 7890
proxies:
  - {name: "📢 官网: https://new.moneyfly.top", server: baidu.com, port: 1234, type: ss, cipher: aes-128-gcm, password: info}
  - {name: "❌ 原因: 订阅已过期", server: baidu.com, port: 1234, type: ss, cipher: aes-128-gcm, password: info}
  - {name: "💡 解决: 请前往官网续费 (过期时间: 2026-01-01)", server: baidu.com, port: 1234, type: ss, cipher: aes-128-gcm, password: info}
proxy-groups:
  - name: "🚀 节点选择"
    type: select
    proxies:
      - DIRECT
      - "❌ 原因: 订阅已过期"
''';
      final notice = MclashSubscriptionNodes.parseNotice(yaml);
      expect(notice.state, MclashNoticeState.expired);
      expect(notice.blocked, isTrue);
      // 提示节点全部被过滤 → 自动选节点没有候选 → 连不上
      expect(MclashSubscriptionNodes.parseNodes(yaml), isEmpty);
    });

    test('正常订阅：依然解析出全部真实节点', () {
      const yaml = '''
proxies:
  - {name: "📢 官网: https://new.moneyfly.top", server: baidu.com, port: 1234, type: ss, cipher: aes-128-gcm, password: info}
  - {name: 香港线路3, server: 5.6.7.8, port: 8443, type: ss, cipher: aes-128-gcm, password: z}
  - {name: 日本东京, server: 1.2.3.4, port: 443, type: vmess, uuid: y}
''';
      expect(MclashSubscriptionNodes.parseNotice(yaml).blocked, isFalse);
      expect(MclashSubscriptionNodes.parseNodes(yaml).length, 2);
    });
  });

  group('账号门禁采纳「订阅下发状态」', () {
    final acc = MclashAccountService.instance;
    tearDown(() {
      acc.debugSetData(null, null);
      acc.debugClearPayloadNotice();
    });

    test('账号接口没有数据时，也能靠订阅下发状态拦住（含设备超限）', () {
      // 真实场景：设备超限是「拉订阅那一刻」由后端判定的；而账号接口
      // （/dashboard、/user/subscribe）可能还没返回、或干脆请求失败。
      // 这时唯一可信的信号就是刚下载下来的这份订阅本身。
      acc.debugSetData(null, null);
      acc.debugClearPayloadNotice();
      expect(
        acc.isBlocked,
        isFalse,
        reason: '一点信息都没有时不能乱拦（否则正常用户连不上）',
      );

      acc.markPayloadNotice(
        MclashSubscriptionNotice.parse([
          "📢 官网: https://new.moneyfly.top",
          "❌ 原因: 设备数量超限",
          "💡 解决: 当前设备 3/2，请在官网删除不使用的设备",
          "💬 客服: 2562866992@qq.com",
        ]),
      );
      expect(acc.blockKind, MclashBlockKind.deviceFull);
      expect(acc.isBlocked, isTrue);
      // 原因/解决/客服/官网 都用后端下发的原文
      expect(acc.blockText, contains("3/2"));
      expect(acc.blockText, contains("2562866992@qq.com"));
      expect(acc.blockText, contains("new.moneyfly.top"));
    });

    test('到期 / 失效 / 不存在 都能映射到对应的拦截原因', () {
      void check(String reason, MclashBlockKind want) {
        acc.debugClearPayloadNotice();
        acc.markPayloadNotice(
          MclashSubscriptionNotice.parse(["❌ 原因: $reason"]),
        );
        expect(acc.blockKind, want, reason: reason);
      }

      check("订阅已过期", MclashBlockKind.expired);
      check("订阅已失效", MclashBlockKind.subscriptionDisabled);
      check("订阅不存在", MclashBlockKind.noSubscription);
      // 服务端暂时不可用：不能谎报成「套餐已被禁用」（付费客户会以为套餐出问题）
      check("服务暂时不可用", MclashBlockKind.serverUnavailable);
    });

    test('正常下发（有真实节点）不拦截', () {
      acc.debugClearPayloadNotice();
      acc.markPayloadNotice(
        MclashSubscriptionNotice.parse(["📢 官网: https://x", "香港线路3"]),
      );
      expect(acc.isBlocked, isFalse);
    });
  });
}
