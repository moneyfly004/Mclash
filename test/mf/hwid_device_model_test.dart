import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mclash/app/utils/hwid_utils.dart';

void main() {
  test('Windows：机型来自 BIOS 信息，不是系统版本名', () {
    if (!Platform.isWindows) {
      return; 
    }
    HwidUtils.debugResetWindowsHardware();
    final hw = HwidUtils.windowsHardware();
    expect(
      hw.model.isEmpty || !hw.model.toLowerCase().startsWith('windows'),
      isTrue,
      reason: '型号不能是「Windows 11 Pro」这种系统版本名，实际读到：${hw.model}',
    );
    if (hw.model.isNotEmpty) {
      expect(hw.brand, isNotEmpty, reason: 'BIOS 信息里厂商与型号是成对的');
    }
  });

  test('重复调用走缓存（心跳每 2 分钟调一次，不能重复读注册表）', () {
    if (!Platform.isWindows) {
      return;
    }
    final a = HwidUtils.windowsHardware();
    final b = HwidUtils.windowsHardware();
    expect(identical(a, b), isTrue, reason: '应返回同一个缓存对象');
  });
}
