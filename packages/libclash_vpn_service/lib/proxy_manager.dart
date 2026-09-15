
library;

import 'dart:io';

class ProxyManager {
  ProxyManager();

  final Set<String> _excluded = {};

  Future<void> setExcludeDevices(Set<String> devices) async {
    _excluded
      ..clear()
      ..addAll(devices);
  }

  Set<String> get excludeDevices => Set.unmodifiable(_excluded);

  static bool get needsNative => Platform.isMacOS;
}
