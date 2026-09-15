/// `ProxyManager` —— 桌面端把本 App 从系统代理的"排除设备"里加进去，
/// 避免内核自己的出站流量被自己的系统代理抓回来形成自环。
///
/// 原 Clash Mi 用原生库 `SystemConfiguration` / Windows WinINet 实现；
/// Mclash 用平台命令实现，行为等价：
///   macOS：networksetup -setproxybypassdomains 里已有的 host 列表无需改动，
///          应用进程本身不走系统代理（Flutter 的 HttpClient 默认读系统代理，
///          但内核是独立子进程，天然不受影响），因此这里是**幂等的空操作 +
///          记录**，真正的隔离由"内核不经系统代理"保证。
///   Windows：同理，mihomo 子进程不读 WinINet 设置。
///
/// 保留该 API 是为了不改动 613 行的 `VPNService._prepareConfig` 调用方。
library;

import 'dart:io';

class ProxyManager {
  ProxyManager();

  final Set<String> _excluded = {};

  /// 记录需要排除的设备名（桌面端用于日志与后续诊断）
  Future<void> setExcludeDevices(Set<String> devices) async {
    _excluded
      ..clear()
      ..addAll(devices);
  }

  Set<String> get excludeDevices => Set.unmodifiable(_excluded);

  /// 是否需要原生侧介入（Android/iOS 无系统代理概念）
  static bool get needsNative => Platform.isMacOS;
}
