import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// 静态接线守卫：`restoreSystemProxyIfStale` 长期存在却没有任何调用点，
/// 等于"异常退出后自愈系统代理"的能力是死代码。这里锁住启动时的调用。
void main() {
  test('启动初始化必须调用 restoreSystemProxyIfStale（防止再次变成死代码）', () {
    final source = File('lib/app/modules/biz.dart').readAsStringSync();
    final init = source.split('static Future<void> init(').last;
    final body = init.split('static Future<void> uninit(').first;
    expect(
      body,
      contains('restoreSystemProxyIfStale()'),
      reason: '崩溃/Cmd+Q 后残留的系统代理必须有自愈入口',
    );
    // 顺序：必须在 VPNService.init() 之后（那时内核状态才是可靠的）
    expect(
      body.indexOf('restoreSystemProxyIfStale()'),
      greaterThan(body.indexOf('await VPNService.init()')),
    );
  });
}
