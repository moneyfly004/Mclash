import 'dart:convert';
import 'dart:io';
import 'package:mclash/app/utils/did.dart';
import 'package:mclash/app/utils/log.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:win32_registry/win32_registry.dart';

/// 设备详情（型号 / 系统 / 品牌）上报。
///
/// 这些头会在**订阅拉取**与**心跳**两条请求上发给面板，面板据此在设备列表里显示
/// 型号与系统。以前两条链路各缺一半，于是面板里**永远是空的**（用户实测反馈）：
///   * 订阅拉取（决定「设备登记」的那次请求）没带这些头 → 新设备行的型号存成空串；
///   * 心跳虽然带了，但服务端只写心跳时间，型号被丢掉。
class HwidUtils {
  static Future<String> getHwid() async {
    final did = await Did.getDid();
    return base64Encode(utf8.encode(did.hashCode.toString()));
  }

  static Future<Map<String, String>> getHwidHeaders() async {
    Map<String, String> headers = {};
    final plugin = DeviceInfoPlugin();
    final hwid = await getHwid();
    headers["x-hwid"] = hwid.toLowerCase();
    if (Platform.isMacOS) {
      final info = await plugin.macOsInfo;
      headers['x-device-os'] = "macOS";
      headers['x-ver-os'] = "${info.majorVersion}.${info.minorVersion}";
      // `model` 是机型标识（如 Mac16,10），比 UA 里的信息准确得多
      headers['x-device-model'] = info.model;
      headers['x-device-brand'] = "Apple";
    } else if (Platform.isWindows) {
      final info = await plugin.windowsInfo;
      headers['x-device-os'] = "Windows";
      headers['x-ver-os'] = "${info.majorVersion}.${info.minorVersion}";
      final hw = windowsHardware();
      headers['x-device-model'] = hw.model.isNotEmpty
          ? hw.model
          // 兜底：注册表读不到时才退回系统版本名（会显示成「Windows 11 Pro」这种）
          : info.productName;
      headers['x-device-brand'] = hw.brand;
    } else if (Platform.isAndroid) {
      final info = await plugin.androidInfo;
      headers['x-device-os'] = "Android";
      headers['x-ver-os'] = info.version.release;
      headers['x-device-model'] = '${info.manufacturer} ${info.model}';
      headers['x-device-brand'] = info.manufacturer;
    }

    return headers;
  }

  /// Windows 的**真实**机型（厂商 + 型号），从注册表里的 BIOS 信息读取。
  ///
  /// **不能用 `WindowsInfo.productName` 当型号**：它读的是
  /// `SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProductName`，值是操作系统
  /// 版本名（"Windows 11 Pro"），不是硬件型号。真型号出自 BIOS 信息
  /// （`wmic csproduct get name` / `Get-CimInstance Win32_ComputerSystem`
  /// 读的就是同一份数据）；这里直接读注册表，**不会起进程、不会闪窗**。
  static WindowsHardware windowsHardware() {
    final cached = _windowsCache;
    if (cached != null) {
      return cached;
    }
    var brand = "";
    var model = "";
    // Win10 1803+ 把整机信息放在第一处；更老的系统只有 BIOS 那一份
    for (final entry in const [
      (
        r"SYSTEM\CurrentControlSet\Control\SystemInformation",
        "SystemManufacturer",
        "SystemProductName",
      ),
      (
        r"HARDWARE\DESCRIPTION\System\BIOS",
        "SystemManufacturer",
        "SystemProductName",
      ),
    ]) {
      try {
        final key = Registry.openPath(
          RegistryHive.localMachine,
          path: entry.$1,
        );
        try {
          final m = (key.getValueAsString(entry.$3) ?? "").trim();
          final b = (key.getValueAsString(entry.$2) ?? "").trim();
          if (m.isNotEmpty) {
            model = m;
            brand = b;
            break;
          }
        } finally {
          key.close();
        }
      } catch (e) {
        Log.w("读取 Windows 机型注册表失败（${entry.$1}）: $e");
      }
    }
    return _windowsCache = WindowsHardware(brand: brand, model: model);
  }

  static WindowsHardware? _windowsCache;

  /// 测试缝：重置机型缓存。
  static void debugResetWindowsHardware() => _windowsCache = null;
}

class WindowsHardware {
  const WindowsHardware({required this.brand, required this.model});

  final String brand;
  final String model;
}
