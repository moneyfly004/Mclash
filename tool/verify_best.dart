/// 真机验证：连接后自动选「延迟最低的最优节点」。
/// 运行：flutter test tool/verify_best.dart （需要内核在跑、App 已连接）
import 'package:flutter_test/flutter_test.dart';
import 'package:mclash/app/clash/clash_http_api.dart';
import 'package:mclash/mf/mclash_node_autopick.dart';

void main() {
  test('整组测速 → 自动切到延迟最低的节点', () async {
    ClashHttpApi.getSecret = () => 'd3ab76428e7538fd';
    ClashHttpApi.getControlPort = () => 9090;

    Future<String?> now() async {
      for (final p in (await ClashHttpApi.getProxies()).data ?? []) {
        if (p.name == '🚀 节点选择') return p.now;
      }
      return null;
    }

    // ① 人为切到一个慢/坏节点
    await ClashHttpApi.setProxiesNode('🚀 节点选择', 'RedMouse-香港-A1');
    await Future<void>.delayed(const Duration(seconds: 3));
    print('BEFORE=${await now()}');

    // ② 整组测速，看内核给出的延迟分布
    final delays = await ClashHttpApi.getGroupDelay(
      '🚀 节点选择',
      url: 'https://www.gstatic.com/generate_204',
    );
    final valid = delays.entries.where((e) => e.value > 0).toList()
      ..sort((a, b) => a.value.compareTo(b.value));
    print('GROUP_TESTED=${delays.length} VALID=${valid.length}');
    if (valid.isNotEmpty) {
      print('FASTEST_5=${valid.take(5).map((e) => "${e.key}=${e.value}ms").toList()}');
    }

    // ③ 跑真实选优逻辑
    String note = '';
    final picked = await MclashNodeAutoPick.selectBestOnConnect(onNote: (n) => note = n);
    print('PICKED=$picked');
    print('NOTE=$note');
    print('AFTER=${await now()}');
  }, timeout: const Timeout(Duration(minutes: 4)));
}
