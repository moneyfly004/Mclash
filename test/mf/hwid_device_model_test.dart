import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mclash/app/utils/hwid_utils.dart';

/// 设备型号上报：**Windows 不能用系统版本名当型号**。
///
/// `WindowsInfo.productName` 读的是注册表
/// `SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProductName`，值是
/// “Windows 11 Pro”这类**操作系统版本名**；真型号在 BIOS 信息里
/// （`Get-CimInstance Win32_ComputerSystem` / `wmic csproduct get name` 读的就是它）。
/// 面板里显示“型号 = Windows 11 Pro”是错的，所以 Windows 上改读注册表。
///
/// 这个文件在 Windows 上会**真读注册表**（CI 的 Windows runner 会跑），
/// 其它平台自动跳过。
void main() {
  test('Windows：机型来自 BIOS 信息，不是系统版本名', () {
    if (!Platform.isWindows) {
      return; // 非 Windows 平台没有注册表可读
    }
    HwidUtils.debugResetWindowsHardware();
    final hw = HwidUtils.windowsHardware();
    // 不强制「一定读得到」：精简版/容器镜像里 BIOS 键可能缺失，
    // 那种情况要能安静回退（getHwidHeaders 会退回 productName）。
    expect(
      hw.model.isEmpty || !hw.model.toLowerCase().startsWith('windows'),
      isTrue,
      reason: '型号不能是「Windows 11 Pro」这种系统版本名，实际读到：${hw.model}',
    );
    // 有型号时品牌也应当有（两者同源，同一注册表项）
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
