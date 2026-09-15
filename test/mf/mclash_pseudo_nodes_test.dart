import 'package:mclash/mf/mclash_pseudo_nodes.dart';
import 'package:flutter_test/flutter_test.dart';

/// 用例取自后端 `createInfoNode` / `getErrorNodes` **实际下发的字符串**，
/// 不是凭空编的 —— 这些名字一旦变动，本测试会立刻失败。
void main() {
  group('信息节点（createInfoNode）', () {
    for (final n in [
      "📢 官网: http://localhost:9000",
      "📢 官网: https://new.moneyfly.top",
      "⏰ 到期: 2027-09-15",
      "⏰ 到期: 无限期",
      "📱 设备: 3/5",
      "💬 客服: 2562866992",
    ]) {
      test('$n 是伪节点', () => expect(MclashPseudoNodes.isPseudo(n), isTrue));
    }
  });

  group('错误节点（getErrorNodes）', () {
    for (final n in [
      "订阅不存在",
      "订阅已过期",
      "订阅已失效",
      "设备数量超限",
      "请在系统设置中配置域名",
      "请检查订阅地址是否正确",
      "请联系管理员检查订阅状态",
      "❌ 原因: 设备数量超限",
      "💡 解决: 请在官网删除不使用的设备",
      "请前往官网续费 (过期时间: 2026-01-01)",
      "当前设备 5/5，请在官网删除不使用的设备",
    ]) {
      test('$n 是伪节点', () => expect(MclashPseudoNodes.isPseudo(n), isTrue));
    }
  });

  group('真节点不应被误伤', () {
    for (final n in [
      "JP-日本-直连",
      "JP-日本-直连2",
      "TW-台湾-直连",
      "🇭🇰 香港 01",
      "美国-洛杉矶-优化",
      "🇸🇬 SG-01",
      "剩余流量：100GB", // 看起来像信息，但不是后端下发的那几种
    ]) {
      test('$n 不是伪节点', () => expect(MclashPseudoNodes.isPseudo(n), isFalse));
    }
  });

  test('filterOut 只剔掉伪节点', () {
    final all = [
      "📢 官网: https://x",
      "JP-日本-直连",
      "⏰ 到期: 2027-09-15",
      "TW-台湾-直连",
      "📱 设备: 3/5",
    ];
    expect(MclashPseudoNodes.filterOut(all), ["JP-日本-直连", "TW-台湾-直连"]);
  });

  test('空名不判定为伪节点（避免误吞无名字条目）', () {
    expect(MclashPseudoNodes.isPseudo(""), isFalse);
  });

  test('isErrorNode 把错误节点与信息节点区分开', () {
    expect(MclashPseudoNodes.isErrorNode("订阅已过期"), isTrue);
    expect(MclashPseudoNodes.isErrorNode("📢 官网: https://x"), isFalse);
  });
}
