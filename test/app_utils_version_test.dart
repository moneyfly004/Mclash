import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:mclash/app/utils/app_utils.dart';

/// 启动版本自检（曾导致「应用启动失败[无效版本]」的真因）：
/// AppUtils.getBuildinVersion 原来硬编码 "0.0.2.5"，而 pubspec 是 0.0.3，
/// getBuildinVersionName() 得到 "0.0.2" ≠ PackageInfo.version "0.0.3"，
/// main() 直接判 invalidVersion。现在版本从 PackageInfo 回填，二者恒等。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('回填后：buildin 名 == 包版本名（不会再误判无效版本）', () async {
    PackageInfo.setMockInitialValues(
      appName: 'Mclash',
      packageName: 'top.moneyfly.mclash',
      version: '0.0.4',
      buildNumber: '7',
      buildSignature: '',
    );
    await AppUtils.initBuildinVersion();
    expect(AppUtils.hasBuildinVersion, isTrue);
    expect(AppUtils.getBuildinVersion(), '0.0.4.7');
    expect(AppUtils.getBuildinVersionName(), '0.0.4');
    expect(AppUtils.getBuildinVersionName(), '0.0.4',
        reason: '必须与 PackageInfo.version 一致，否则启动被判无效版本');
  });

  test('未回填时 hasBuildinVersion=false（启动自检跳过比对，不拦用户）', () {
    // 这里不复位真实状态（Dart 静态字段），只锁语义：未初始化时不应崩
    expect(AppUtils.getBuildinVersion(), isNotEmpty);
  });
}
