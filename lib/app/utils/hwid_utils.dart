import 'dart:convert';
import 'dart:io';
import 'package:mclash/app/utils/did.dart';
import 'package:mclash/app/utils/log.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:win32_registry/win32_registry.dart';

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
      headers['x-device-model'] = info.model;
      headers['x-device-brand'] = "Apple";
    } else if (Platform.isWindows) {
      final info = await plugin.windowsInfo;
      headers['x-device-os'] = "Windows";
      headers['x-ver-os'] = "${info.majorVersion}.${info.minorVersion}";
      final hw = windowsHardware();
      headers['x-device-model'] = hw.model.isNotEmpty
          ? hw.model
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

  static WindowsHardware windowsHardware() {
    final cached = _windowsCache;
    if (cached != null) {
      return cached;
    }
    var brand = "";
    var model = "";
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

  static void debugResetWindowsHardware() => _windowsCache = null;
}

class WindowsHardware {
  const WindowsHardware({required this.brand, required this.model});

  final String brand;
  final String model;
}
