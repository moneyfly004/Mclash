import 'dart:io';

import 'package:protocol_handler/protocol_handler.dart';
import 'package:win32_registry/win32_registry.dart';

class SystemSchemeUtils {
  static const String _kClashScheme = "clash";
  static const String _kClashMiScheme = "mclash";
  static String getClashScheme() => _kClashScheme;
  static String getClashMiScheme() => _kClashMiScheme;
  static String getClashSchemeWith() => "$_kClashScheme://";
  static String getClashMiSchemeWith() => "$_kClashMiScheme://";
  static Future<String?> register(String scheme) async {
    try {
      await protocolHandler.register(scheme);
    } catch (err) {
      return err.toString();
    }
    return null;
  }

  static String? unregister(String scheme) {
    if (!Platform.isWindows) {
      return null;
    }
    String path = 'Software\\Classes\\$scheme\\shell\\open\\command';
    try {
      Registry.currentUser.deleteKey(path);
    } catch (err) {
      return err.toString();
    }

    return null;
  }

}
