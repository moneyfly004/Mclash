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

// ============================================================================
// 用**官方 API** 设置「连接」级代理
// ============================================================================
//
// 为什么还需要这个（真实用户问题，Windows 11）：
// 只写 `Internet Settings` 的 `ProxyEnable` / `ProxyServer` 是**全局值** ——
// WinINet 的新连接会用（所以「能上网、有流量」，reg query 也能看到 127.0.0.1:端口），
// 但「Internet 选项 → 连接 → 局域网设置」和 Windows 11 的「设置 → 网络和 Internet
// → 代理」读的是**每个连接的缓存副本**（`Connections\DefaultConnectionSettings`）。
// 那份副本没被更新时，界面就一直显示「不使用代理服务器」= 地址/端口空白 ——
// 用户反复反馈「注册表里明明有，界面却是空的」。
//
// Windows 自己改代理用的是
// `InternetSetOption(NULL, INTERNET_OPTION_PER_CONNECTION_OPTION(=75), &list, size)`；
// 这一下会**同时**更新注册表与那份缓存（界面立刻可见）。这里就调它。

/// `INTERNET_OPTION_PER_CONNECTION_OPTION`
const int _kOptionPerConnectionOption = 75;

/// `INTERNET_PER_CONN_*` 选项号
const int _kPerConnFlags = 1;
const int _kPerConnProxyServer = 2;
const int _kPerConnProxyBypass = 3;

/// `PROXY_TYPE_*`
const int _kProxyTypeDirect = 0x1;
const int _kProxyTypeProxy = 0x2;

// ── 结构体布局（按指针宽度自适应 32/64 位）──
// struct INTERNET_PER_CONN_OPTIONW { DWORD dwOption; union { DWORD dwValue; LPWSTR pszValue; } Value; }
// struct INTERNET_PER_CONN_OPTION_LISTW { DWORD dwSize; LPWSTR pszConnection; DWORD dwOptionCount;
//                                         DWORD dwOptionError; OPTION* pOptions; }
int get _ptrSize => sizeOf<Pointer<NativeType>>();
int get _optionSize => _ptrSize * 2; // x64:16  x86:8
int get _optionValueOffset => _ptrSize; // x64:8   x86:4
int get _listPszConnectionOffset => _ptrSize; // x64:8   x86:4
int get _listCountOffset => _ptrSize * 2; // x64:16  x86:8
int get _listErrorOffset => _ptrSize * 2 + 4; // x64:20  x86:12
int get _listOptionsOffset => _ptrSize == 8 ? 24 : 16;
int get _listSize => _listOptionsOffset + _ptrSize; // x64:32  x86:20

typedef _InternetQueryOptionNative = Int32 Function(
  IntPtr hInternet,
  Int32 dwOption,
  IntPtr lpBuffer,
  Pointer<Uint32> lpdwBufferLength,
);
typedef _InternetQueryOptionDart = int Function(
  int hInternet,
  int dwOption,
  int lpBuffer,
  Pointer<Uint32> lpdwBufferLength,
);

typedef _LocalAllocNative = IntPtr Function(Uint32 uFlags, IntPtr uBytes);
typedef _LocalAllocDart = int Function(int uFlags, int uBytes);
typedef _LocalFreeNative = IntPtr Function(IntPtr hMem);
typedef _LocalFreeDart = int Function(int hMem);

_InternetQueryOptionDart? _queryOption;
_LocalAllocDart? _localAlloc;
_LocalFreeDart? _localFree;

/// `LPTR` = LMEM_FIXED | LMEM_ZEROINIT
const int _kLptr = 0x0040;

bool _loadMore() {
  if (_queryOption != null) {
    return true;
  }
  try {
    final wininet = DynamicLibrary.open('wininet.dll');
    _queryOption =
        wininet.lookupFunction<_InternetQueryOptionNative, _InternetQueryOptionDart>(
          'InternetQueryOptionW',
        );
    final kernel32 = DynamicLibrary.open('kernel32.dll');
    _localAlloc = kernel32
        .lookupFunction<_LocalAllocNative, _LocalAllocDart>('LocalAlloc');
    _localFree =
        kernel32.lookupFunction<_LocalFreeNative, _LocalFreeDart>('LocalFree');
    return true;
  } catch (_) {
    return false;
  }
}

/// 写一个 DWORD（flags 之类）。
void _writeDword(int base, int value) =>
    Pointer<Uint32>.fromAddress(base).value = value;

/// 写一个指针（LPWSTR / 结构体指针）。
void _writePtr(int base, int value) =>
    Pointer<UintPtr>.fromAddress(base).value = value;

/// 读一个指针。
int _readPtr(int base) => Pointer<UintPtr>.fromAddress(base).value;

int _allocUtf16(String s) {
  final units = s.codeUnits; // Windows 用的就是 UTF-16
  final addr = _localAlloc!(_kLptr, (units.length + 1) * 2);
  if (addr == 0) {
    return 0;
  }
  final p = Pointer<Uint16>.fromAddress(addr);
  for (var i = 0; i < units.length; i++) {
    p[i] = units[i];
  }
  p[units.length] = 0;
  return addr;
}

String _readUtf16(int addr) {
  if (addr == 0) {
    return "";
  }
  final p = Pointer<Uint16>.fromAddress(addr);
  final buf = StringBuffer();
  for (var i = 0; i < 4096; i++) {
    final u = p[i];
    if (u == 0) {
      break;
    }
    buf.writeCharCode(u);
  }
  return buf.toString();
}

/// 把 `host:port`（可带旁路列表）写进**当前连接**的代理设置。
///
/// 成功时 Windows 的注册表与「Internet 选项 / 设置 → 代理」缓存会一起更新。
/// 失败（老系统 / 被策略锁住）时返回 false —— 调用方仍保留「只写注册表」那条路，
/// 所以失败不会让用户断网。
bool applySystemProxyForConnection({
  required String server,
  required String bypass,
}) {
  final fn = _resolve();
  if (fn == null || !_loadMore() || server.trim().isEmpty) {
    return false;
  }
  var options = 0;
  var list = 0;
  var serverPtr = 0;
  var bypassPtr = 0;
  try {
    options = _localAlloc!(_kLptr, _optionSize * 3);
    list = _localAlloc!(_kLptr, _listSize);
    serverPtr = _allocUtf16(server.trim());
    bypassPtr = _allocUtf16(bypass.trim());
    if (options == 0 || list == 0 || serverPtr == 0 || bypassPtr == 0) {
      return false;
    }
    // option[0] = FLAGS（直连 + 走代理）
    _writeDword(options, _kPerConnFlags);
    _writePtr(options + _optionValueOffset, _kProxyTypeDirect | _kProxyTypeProxy);
    // option[1] = PROXY_SERVER
    _writeDword(options + _optionSize, _kPerConnProxyServer);
    _writePtr(options + _optionSize + _optionValueOffset, serverPtr);
    // option[2] = PROXY_BYPASS
    _writeDword(options + _optionSize * 2, _kPerConnProxyBypass);
    _writePtr(options + _optionSize * 2 + _optionValueOffset, bypassPtr);

    _writeDword(list, _listSize);
    _writePtr(list + _listPszConnectionOffset, 0);
    _writeDword(list + _listCountOffset, 3);
    _writeDword(list + _listErrorOffset, 0);
    _writePtr(list + _listOptionsOffset, options);

    final ok = fn(0, _kOptionPerConnectionOption, list, _listSize);
    return ok != 0;
  } catch (_) {
    return false;
  } finally {
    if (serverPtr != 0) {
      _localFree?.call(serverPtr);
    }
    if (bypassPtr != 0) {
      _localFree?.call(bypassPtr);
    }
    if (options != 0) {
      _localFree?.call(options);
    }
    if (list != 0) {
      _localFree?.call(list);
    }
  }
}

/// 把**当前连接**的代理清成「直连」（同样会同步界面缓存）。
bool clearSystemProxyForConnection() {
  final fn = _resolve();
  if (fn == null || !_loadMore()) {
    return false;
  }
  var options = 0;
  var list = 0;
  try {
    options = _localAlloc!(_kLptr, _optionSize);
    list = _localAlloc!(_kLptr, _listSize);
    if (options == 0 || list == 0) {
      return false;
    }
    _writeDword(options, _kPerConnFlags);
    _writePtr(options + _optionValueOffset, _kProxyTypeDirect);
    _writeDword(list, _listSize);
    _writePtr(list + _listPszConnectionOffset, 0);
    _writeDword(list + _listCountOffset, 1);
    _writeDword(list + _listErrorOffset, 0);
    _writePtr(list + _listOptionsOffset, options);
    return fn(0, _kOptionPerConnectionOption, list, _listSize) != 0;
  } catch (_) {
    return false;
  } finally {
    if (options != 0) {
      _localFree?.call(options);
    }
    if (list != 0) {
      _localFree?.call(list);
    }
  }
}

/// 读回「当前连接」里的某个选项（[option] = INTERNET_PER_CONN_*）。
///
/// 返回：字符串选项 → 字符串；FLAGS → 十进制数字的字符串；失败 → null。
String? queryConnectionOption(int option, {required bool asString}) {
  if (!_loadMore()) {
    return null;
  }
  var options = 0;
  var list = 0;
  var size = 0;
  var apiAllocated = 0;
  try {
    options = _localAlloc!(_kLptr, _optionSize);
    list = _localAlloc!(_kLptr, _listSize);
    size = _localAlloc!(_kLptr, 4);
    if (options == 0 || list == 0 || size == 0) {
      return null;
    }
    _writeDword(options, option);
    _writePtr(options + _optionValueOffset, 0);
    _writeDword(list, _listSize);
    _writePtr(list + _listPszConnectionOffset, 0);
    _writeDword(list + _listCountOffset, 1);
    _writeDword(list + _listErrorOffset, 0);
    _writePtr(list + _listOptionsOffset, options);
    _writeDword(size, _listSize);
    final ok = _queryOption!(
      0,
      _kOptionPerConnectionOption,
      list,
      Pointer<Uint32>.fromAddress(size),
    );
    if (ok == 0) {
      return null;
    }
    if (asString) {
      apiAllocated = _readPtr(options + _optionValueOffset);
      final text = _readUtf16(apiAllocated);
      return text;
    }
    return _readPtr(options + _optionValueOffset).toString();
  } catch (_) {
    return null;
  } finally {
    // 查询出来的字符串是 API 分配的，必须由调用方释放
    if (apiAllocated != 0) {
      _localFree?.call(apiAllocated);
    }
    if (size != 0) {
      _localFree?.call(size);
    }
    if (options != 0) {
      _localFree?.call(options);
    }
    if (list != 0) {
      _localFree?.call(list);
    }
  }
}

/// 读回「当前连接」里配置的代理服务器（`host:port`）；没配则空串。
///
/// 这是**和 Windows 界面同一份数据**，所以它为空就说明界面一定显示空白 ——
/// 用它就能区分「注册表写了但缓存没同步」和「真的没写」。
String querySystemProxyForConnection() =>
    queryConnectionOption(_kPerConnProxyServer, asString: true) ?? "";

/// 读回「当前连接」的 FLAGS（是否启用代理看这里；失败返回 null）。
///
/// 注意：清代理时 Windows 的做法是**把 flags 改回直连**，PROXY_SERVER 字符串
/// 会留在里面（界面里也是这个行为）—— 所以判断「清干净没」要看 flags，
/// 不能看服务器字符串是否为空。
int? queryConnectionFlagsForConnection() {
  final raw = queryConnectionOption(_kPerConnFlags, asString: false);
  if (raw == null) {
    return null;
  }
  return int.tryParse(raw) ?? _readPtrFromString(raw);
}

int _readPtrFromString(String raw) {
  // 兜底：API 返回的是指针地址的十进制字符串（见 queryConnectionOption）
  return int.tryParse(raw) ?? -1;
}

/// 当前连接是否**启用了代理**（flags 里含 PROXY_TYPE_PROXY）。
bool connectionProxyEnabled() {
  final flags = queryConnectionFlagsForConnection();
  if (flags == null) {
    return false;
  }
  return (flags & _kProxyTypeProxy) != 0;
}

// ============================================================================
// WM_SETTINGCHANGE 广播（参考实现 moneyfly 的关键一步，我们以前缺这个）
// ============================================================================
//
// 对比结论：参考实现（/Users/apple/Downloads/mysoftware/moneyfly 的
// SystemProxyManager）在 Windows 上做的是
//   ① reg add ProxyEnable/ProxyServer/ProxyOverride（和我们一样）
//   ② InternetSetOption(SETTINGS_CHANGED=39) + (REFRESH=37)（和我们一样）
//   ③ **失败时回退**：user32!SendMessageTimeout 向所有顶层窗口广播
//      WM_SETTINGCHANGE(0x001A)，lParam = "InternetSettings"
// 第 ③ 步我们完全没有 —— 而 Windows 自己的「Internet 选项 / 设置 → 代理」界面
// 正是靠这条消息重新读取设置的。只发 ②（且 ② 在某些机器上返回非零却不起作用）时，
// 注册表里明明有 127.0.0.1:端口、浏览器也能上网，界面却一直显示空白。
//
// 这里把 ③ 做成**与 ② 并列的一步**（不是「只在失败时才做」）：代价只有一次
// 消息广播，换来界面确定刷新。

typedef _SendMessageTimeoutNative = IntPtr Function(
  IntPtr hWnd,
  Uint32 msg,
  UintPtr wParam,
  IntPtr lParam,
  Uint32 fuFlags,
  Uint32 uTimeout,
  Pointer<UintPtr> lpdwResult,
);
typedef _SendMessageTimeoutDart = int Function(
  int hWnd,
  int msg,
  int wParam,
  int lParam,
  int fuFlags,
  int uTimeout,
  Pointer<UintPtr> lpdwResult,
);

/// `HWND_BROADCAST`：发给所有顶层窗口
const int _kHwndBroadcast = 0xffff;

/// `WM_SETTINGCHANGE`
const int _kWmSettingChange = 0x001A;

/// `SMTO_ABORTIFHUNG`：别因为某个窗口卡住而把自己也卡住
const int _kSmtoAbortIfHung = 0x0002;

_SendMessageTimeoutDart? _sendMessageTimeout;
bool _user32LoadFailed = false;

_SendMessageTimeoutDart? _resolveSendMessageTimeout() {
  if (_sendMessageTimeout != null) {
    return _sendMessageTimeout;
  }
  if (_user32LoadFailed || !Platform.isWindows) {
    return null;
  }
  try {
    final lib = DynamicLibrary.open('user32.dll');
    _sendMessageTimeout =
        lib.lookupFunction<_SendMessageTimeoutNative, _SendMessageTimeoutDart>(
          'SendMessageTimeoutW',
        );
    return _sendMessageTimeout;
  } catch (_) {
    _user32LoadFailed = true;
    return null;
  }
}

/// 向所有顶层窗口广播 `WM_SETTINGCHANGE` / `lParam = "InternetSettings"`。
///
/// Windows 的「Internet 选项 → 局域网设置」与「设置 → 网络和 Internet → 代理」
/// 页面收到这条消息才会重新读取代理配置。参考实现（moneyfly）就是靠它让界面刷新的。
bool broadcastInternetSettingsChanged() {
  final fn = _resolveSendMessageTimeout();
  if (fn == null || !_loadMore()) {
    return false;
  }
  var textPtr = 0;
  var resultPtr = 0;
  try {
    textPtr = _allocUtf16("InternetSettings");
    resultPtr = _localAlloc!(_kLptr, _ptrSize);
    if (textPtr == 0 || resultPtr == 0) {
      return false;
    }
    final r = fn(
      _kHwndBroadcast,
      _kWmSettingChange,
      0,
      textPtr,
      _kSmtoAbortIfHung,
      1000,
      Pointer<UintPtr>.fromAddress(resultPtr),
    );
    return r != 0;
  } catch (_) {
    return false;
  } finally {
    if (textPtr != 0) {
      _localFree?.call(textPtr);
    }
    if (resultPtr != 0) {
      _localFree?.call(resultPtr);
    }
  }
}

/// 广播失败时的高可靠回退：交给 PowerShell 做同一件事（参考实现的写法）。
Future<bool> broadcastInternetSettingsViaPowerShell() async {
  if (!Platform.isWindows) {
    return false;
  }
  const script = r'''
Add-Type -MemberDefinition '[DllImport("user32.dll", SetLastError = true)] public static extern bool SendMessageTimeout(IntPtr hWnd, uint Msg, UIntPtr wParam, string lParam, uint fuFlags, uint uTimeout, out UIntPtr lpdwResult);' -Name P -Namespace W32
$r = [UIntPtr]::Zero
[void][W32.P]::SendMessageTimeout([IntPtr]0xffff, 0x001A, [UIntPtr]::Zero, "InternetSettings", 2, 1000, [ref]$r)
''';
  try {
    final ps1 = File(
      '${Directory.systemTemp.path}/mclash_proxy_notify.ps1',
    );
    await ps1.writeAsString(script, flush: true);
    final r = await Process.run('powershell', [
      '-NoProfile',
      '-NonInteractive',
      '-ExecutionPolicy',
      'Bypass',
      '-File',
      ps1.path,
    ]);
    return r.exitCode == 0;
  } catch (_) {
    return false;
  }
}
