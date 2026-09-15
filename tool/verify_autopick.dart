/// 真机验证：连接后「自动挑真能用的节点」。
/// 运行：flutter test tool/verify_autopick.dart   （需要 App 正在连接、内核在跑）
import 'package:flutter_test/flutter_test.dart';
import 'package:mclash/app/clash/clash_http_api.dart';
import 'package:mclash/mf/mclash_node_autopick.dart';

void main() {
  test('把组切到坏节点后，ensureUsable 能自动换到可用节点', () async {
    ClashHttpApi.getSecret = () => 'd3ab76428e7538fd';
    ClashHttpApi.getControlPort = () => 9090;

    Future<String?> now() async {
      final r = await ClashHttpApi.getProxies();
      for (final p in r.data ?? []) {
        if (p.name == '🚀 节点选择') return p.now;
      }
      return null;
    }

    // ① 人为切到已知"能连但访问不了外网"的节点
    await ClashHttpApi.setProxiesNode('🚀 节点选择', 'RedMouse-香港-A1');
    await Future<void>.delayed(const Duration(seconds: 3));
    print('BEFORE_NOW=${await now()}');

    // ② 跑真实的选择逻辑（无任何测试替身）
    String note = '';
    final picked = await MclashNodeAutoPick.ensureUsable(onNote: (n) => note = n);
    print('PICKED=$picked');
    print('NOTE=$note');
    print('AFTER_NOW=${await now()}');
  }, timeout: const Timeout(Duration(minutes: 3)));
}
