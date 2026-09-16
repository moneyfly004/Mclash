/// Windows 系统代理：写注册表之后的**广播**步骤。
///
/// 背景（真实用户问题，已在本机 Windows 11 26200 上复现并验证）：
/// 只把 `ProxyEnable` / `ProxyServer` 写进
/// `HKCU\...\Internet Settings`，能让 **WinINET 之后新建的连接**走代理 ——
/// 所以「能上网、有流量」；但：
///   * 已经在运行的浏览器/Electron 应用不会重新读取，仍走直连；
///   * Windows 自己的 UI（设置 → 网络和 Internet → 代理、Internet 选项）
///     读的是它缓存的那份状态，页面上仍然显示「使用代理服务器 = 关」——
///     用户看到的就是「系统代理没有改变，但能上网」。
///
/// Windows 自己改代理时会调用
/// `InternetSetOption(NULL, INTERNET_OPTION_SETTINGS_CHANGED)` +
/// `InternetSetOption(NULL, INTERNET_OPTION_REFRESH)` 把这次变更广播出去 ——
/// 这会把注册表值同步进系统缓存（实测 `Connections\DefaultConnectionSettings`
/// 会被刷新成新值），并通知所有 WinINET 使用者。Clash Verge / v2rayN 等
/// 主流客户端都做这一步。
///
/// 这里用 `dart:ffi` 直接调 `wininet.dll`，不引入任何插件依赖。
library;

import 'dart:ffi';
import 'dart:io';

typedef _InternetSetOptionNative = Int32 Function(
  IntPtr hInternet,
  Int32 dwOption,
  IntPtr lpBuffer,
  Int32 dwBufferLength,
);
typedef _InternetSetOptionDart = int Function(
  int hInternet,
  int dwOption,
  int lpBuffer,
  int dwBufferLength,
);

/// `INTERNET_OPTION_SETTINGS_CHANGED`：告诉 WinINET「Internet 设置变了」。
const int _kInternetOptionSettingsChanged = 39;

/// `INTERNET_OPTION_REFRESH`：让 WinINET 重新读取上面的设置。
const int _kInternetOptionRefresh = 37;

_InternetSetOptionDart? _setOption;
bool _loadFailed = false;

_InternetSetOptionDart? _resolve() {
  if (_setOption != null) {
    return _setOption;
  }
  if (_loadFailed || !Platform.isWindows) {
    return null;
  }
  try {
    final lib = DynamicLibrary.open('wininet.dll');
    // 导出名是 InternetSetOptionA/W（InternetSetOption 是头文件里的宏）。
    // 这里 buffer 传 NULL，A/W 无差别，所以两个名字都试。
    _InternetSetOptionDart fn;
    try {
      fn = lib.lookupFunction<_InternetSetOptionNative, _InternetSetOptionDart>(
        'InternetSetOptionW',
      );
    } catch (_) {
      fn = lib.lookupFunction<_InternetSetOptionNative, _InternetSetOptionDart>(
        'InternetSetOption',
      );
    }
    _setOption = fn;
    return fn;
  } catch (_) {
    _loadFailed = true;
    return null;
  }
}

/// 广播「系统代理设置已变更」。返回是否两个调用都成功。
///
/// 只在 Windows 上有效；其它平台直接返回 false（调用方无需分支）。
bool notifySystemProxyChanged() {
  final fn = _resolve();
  if (fn == null) {
    return false;
  }
  try {
    final changed = fn(0, _kInternetOptionSettingsChanged, 0, 0);
    final refreshed = fn(0, _kInternetOptionRefresh, 0, 0);
    return changed != 0 && refreshed != 0;
  } catch (_) {
    return false;
  }
}
