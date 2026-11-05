import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// 回归（吞错误）：`_prepareConfig` 以前 `await ClashSettingManager
/// .saveCorePatchFinal(...)` 却不看返回值。补丁写失败时它继续启动内核，
/// 内核读到的是上一次（可能属于另一个配置档）的
/// `service_core_patch_final.json` —— 规则/代理组张冠李戴。
///
/// 这里做静态接线守卫（与 test/stale_system_proxy_wiring_test.dart 同风格）：
/// 错误必须被捕获、在启动内核前中止，并交给 start/restart 统一转成
/// ReturnResultError。真实路径依赖大量平台插件，不适合单测直接跑。
void main() {
  late String source;
  late String prepareBody;

  setUpAll(() {
    source = File('lib/app/local_services/vpn_service.dart').readAsStringSync();
    final start = source.indexOf('static Future<bool> _prepareConfig(');
    expect(start, greaterThanOrEqualTo(0), reason: '找不到 _prepareConfig');
    final end = source.indexOf(
      'static Future<ReturnResultError?> install()',
      start,
    );
    expect(end, greaterThan(start));
    prepareBody = source.substring(start, end);
  });

  test('必须接住 saveCorePatchFinal 的返回值（不能再裸 await）', () {
    final calls = RegExp(
      r'await\s+ClashSettingManager\.saveCorePatchFinal\(',
    ).allMatches(prepareBody).toList();
    expect(calls, hasLength(1), reason: '补丁只能写一次，且必须被赋值检查');

    final assigned = RegExp(
      r'final\s+(\w+)\s*=\s*await\s+ClashSettingManager\.saveCorePatchFinal\(',
    ).firstMatch(prepareBody);
    expect(assigned, isNotNull, reason: '返回值必须赋给变量才能判断失败');
  });

  test('补丁失败必须在 FlutterVpnService.prepareConfig / 启动内核之前中止', () {
    final assigned = RegExp(
      r'final\s+(\w+)\s*=\s*await\s+ClashSettingManager\.saveCorePatchFinal\(',
    ).firstMatch(prepareBody)!;
    final errorVar = assigned.group(1)!;

    final checkIndex = prepareBody.indexOf('if ($errorVar != null)');
    expect(
      checkIndex,
      greaterThan(assigned.end),
      reason: '写完补丁后必须立刻检查 $errorVar',
    );

    final throwIndex = prepareBody.indexOf('throw', checkIndex);
    expect(throwIndex, greaterThan(checkIndex), reason: '失败必须抛出中止连接');

    final prepareIndex = prepareBody.indexOf(
      'FlutterVpnService.prepareConfig(',
    );
    expect(prepareIndex, greaterThan(throwIndex), reason: '中止必须发生在启动内核之前');

    final startIndex = prepareBody.indexOf('FlutterVpnService.start(');
    if (startIndex >= 0) {
      expect(throwIndex, lessThan(startIndex));
    }
  });

  test('抛出的是可读错误：start/restart 会用 err.toString() 作为用户提示', () {
    expect(prepareBody, contains('_PrepareConfigFailure('));
    expect(
      source,
      contains('throw _PrepareConfigFailure("生成内核补丁失败：'),
      reason: '错误信息要带上下文，不能是裸的路径异常',
    );
    // start / restart 两条连接路径都把 _prepareConfig 的异常转成 ReturnResultError。
    expect(
      RegExp(
        r'return ReturnResultError\(err\.toString\(\)\);',
      ).allMatches(source).length,
      greaterThanOrEqualTo(2),
    );
  });
}
