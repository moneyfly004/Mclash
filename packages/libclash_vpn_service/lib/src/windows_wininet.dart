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

import 'dart:async';
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
// 注册表：直接调 advapi32，不再起 reg.exe
// ============================================================================
//
// 为什么不再用 `Process.run("reg", …)`：一次连接/断开要读写注册表十几次
// （4 次写 + 归属判定 2~3 次 + 原始快照 3 次），Windows 上每次 `Process.run`
// 都是 20~50ms 的进程创建 —— 合起来 300~600ms，全部落在用户点击连接的那条路上。
// 用户反馈的「点连接要等好几秒」里有它一份（日志里 [perf] 各段用时对不上就是这个）。
// 这几个 API 与 reg.exe 做的事完全一样（reg.exe 自己也是调它们），只是不用起进程。

typedef _RegOpenKeyExNative = Int32 Function(
  IntPtr hKey,
  Pointer<Uint16> lpSubKey,
  Uint32 ulOptions,
  Uint32 samDesired,
  Pointer<IntPtr> phkResult,
);
typedef _RegOpenKeyExDart = int Function(
  int hKey,
  Pointer<Uint16> lpSubKey,
  int ulOptions,
  int samDesired,
  Pointer<IntPtr> phkResult,
);
typedef _RegSetValueExNative = Int32 Function(
  IntPtr hKey,
  Pointer<Uint16> lpValueName,
  Uint32 reserved,
  Uint32 dwType,
  Pointer<Uint8> lpData,
  Uint32 cbData,
);
typedef _RegSetValueExDart = int Function(
  int hKey,
  Pointer<Uint16> lpValueName,
  int reserved,
  int dwType,
  Pointer<Uint8> lpData,
  int cbData,
);
typedef _RegDeleteValueNative = Int32 Function(
  IntPtr hKey,
  Pointer<Uint16> lpValueName,
);
typedef _RegDeleteValueDart = int Function(int hKey, Pointer<Uint16> lpValueName);
typedef _RegQueryValueExNative = Int32 Function(
  IntPtr hKey,
  Pointer<Uint16> lpValueName,
  IntPtr lpReserved,
  Pointer<Uint32> lpType,
  Pointer<Uint8> lpData,
  Pointer<Uint32> lpcbData,
);
typedef _RegQueryValueExDart = int Function(
  int hKey,
  Pointer<Uint16> lpValueName,
  int lpReserved,
  Pointer<Uint32> lpType,
  Pointer<Uint8> lpData,
  Pointer<Uint32> lpcbData,
);
typedef _RegCloseKeyNative = Int32 Function(IntPtr hKey);
typedef _RegCloseKeyDart = int Function(int hKey);

/// `HKEY_CURRENT_USER`
const int _kHkeyCurrentUser = 0x80000001;

/// `KEY_SET_VALUE | KEY_QUERY_VALUE`
const int _kKeySetAndQueryValue = 0x0002 | 0x0001;

/// 只读（用于读取，能少要权限就少要）
const int _kKeyQueryValue = 0x0001;

/// `REG_SZ` / `REG_DWORD`
const int _kRegSz = 1;
const int _kRegDword = 4;

/// `ERROR_MORE_DATA` / `ERROR_SUCCESS`
const int _kErrorSuccess = 0;

_RegOpenKeyExDart? _regOpenKeyEx;
_RegSetValueExDart? _regSetValueEx;
_RegDeleteValueDart? _regDeleteValue;
_RegQueryValueExDart? _regQueryValueEx;
_RegCloseKeyDart? _regCloseKey;
bool _advapiLoadFailed = false;

bool _loadAdvapi() {
  if (_regSetValueEx != null) {
    return true;
  }
  if (_advapiLoadFailed || !Platform.isWindows || !_loadLocal()) {
    return false;
  }
  try {
    final lib = DynamicLibrary.open('advapi32.dll');
    _regOpenKeyEx = lib
        .lookupFunction<_RegOpenKeyExNative, _RegOpenKeyExDart>('RegOpenKeyExW');
    _regSetValueEx = lib
        .lookupFunction<_RegSetValueExNative, _RegSetValueExDart>('RegSetValueExW');
    _regDeleteValue = lib
        .lookupFunction<_RegDeleteValueNative, _RegDeleteValueDart>('RegDeleteValueW');
    _regQueryValueEx = lib
        .lookupFunction<_RegQueryValueExNative, _RegQueryValueExDart>('RegQueryValueExW');
    _regCloseKey =
        lib.lookupFunction<_RegCloseKeyNative, _RegCloseKeyDart>('RegCloseKey');
    return true;
  } catch (_) {
    _advapiLoadFailed = true;
    return false;
  }
}

/// 把 Dart 字符串编成 UTF-16 结尾的本地缓冲（地址形式；用完用 [_freeLocal] 释放）。
///
/// 与文件里其它 FFI 一致：只用 kernel32 的 LocalAlloc，不引入 package:ffi。
int _utf16Address(String s) {
  final units = s.codeUnits;
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

void _freeLocal(int addr) {
  if (addr != 0) {
    _localFree?.call(addr);
  }
}

/// 打开 Internet Settings 键；失败返回 0。
int _openInternetSettings({bool readOnly = false}) {
  final fn = _regOpenKeyEx;
  if (fn == null) {
    return 0;
  }
  final sub = _utf16Address(
    r"Software\Microsoft\Windows\CurrentVersion\Internet Settings",
  );
  if (sub == 0) {
    return 0;
  }
  final out = _localAlloc!(_kLptr, _ptrSize);
  if (out == 0) {
    _freeLocal(sub);
    return 0;
  }
  try {
    Pointer<UintPtr>.fromAddress(out).value = 0;
    final rc = fn(
      _kHkeyCurrentUser,
      Pointer<Uint16>.fromAddress(sub),
      0,
      readOnly ? _kKeyQueryValue : _kKeySetAndQueryValue,
      Pointer<IntPtr>.fromAddress(out),
    );
    return rc == _kErrorSuccess ? _readPtr(out) : 0;
  } finally {
    _freeLocal(sub);
    _freeLocal(out);
  }
}

/// 写一个 REG_SZ 值。成功返回 true。
bool writeRegistryString(String name, String value) {
  if (!_loadMore() || !_loadAdvapi()) {
    return false;
  }
  final key = _openInternetSettings();
  if (key == 0) {
    return false;
  }
  final namePtr = _utf16Address(name);
  final data = _utf16Address(value);
  try {
    if (namePtr == 0 || data == 0) {
      return false;
    }
    // REG_SZ 的字节数包含结尾的 NUL。
    final rc = _regSetValueEx!(
      key,
      Pointer<Uint16>.fromAddress(namePtr),
      0,
      _kRegSz,
      Pointer<Uint8>.fromAddress(data),
      (value.length + 1) * 2,
    );
    return rc == _kErrorSuccess;
  } finally {
    _freeLocal(namePtr);
    _freeLocal(data);
    _regCloseKey?.call(key);
  }
}

/// 写一个 REG_DWORD 值。成功返回 true。
bool writeRegistryDword(String name, int value) {
  if (!_loadMore() || !_loadAdvapi()) {
    return false;
  }
  final key = _openInternetSettings();
  if (key == 0) {
    return false;
  }
  final namePtr = _utf16Address(name);
  final data = _localAlloc!(_kLptr, 4);
  try {
    if (namePtr == 0 || data == 0) {
      return false;
    }
    Pointer<Uint32>.fromAddress(data).value = value;
    final rc = _regSetValueEx!(
      key,
      Pointer<Uint16>.fromAddress(namePtr),
      0,
      _kRegDword,
      Pointer<Uint8>.fromAddress(data),
      4,
    );
    return rc == _kErrorSuccess;
  } finally {
    _freeLocal(namePtr);
    _freeLocal(data);
    _regCloseKey?.call(key);
  }
}

/// 删除一个值。成功、或「本来就不存在」都返回 true（调用方要的是「确保没有」）。
bool deleteRegistryValue(String name) {
  if (!_loadMore() || !_loadAdvapi()) {
    return false;
  }
  final key = _openInternetSettings();
  if (key == 0) {
    return false;
  }
  final namePtr = _utf16Address(name);
  try {
    if (namePtr == 0) {
      return false;
    }
    final rc = _regDeleteValue!(key, Pointer<Uint16>.fromAddress(namePtr));
    // 2 = ERROR_FILE_NOT_FOUND：值本来就不在，语义上已经满足。
    return rc == _kErrorSuccess || rc == 2;
  } finally {
    _freeLocal(namePtr);
    _regCloseKey?.call(key);
  }
}

/// 这几条注册表 API 在当前平台是否可用（不可用时调用方退回 `reg.exe`）。
bool get windowsRegistryAvailable {
  _loadMore();
  return _loadAdvapi();
}

/// 注册表值的原始字节（REG_SZ 的 UTF-16 / REG_DWORD 的 4 字节）；不存在 → null。
///
/// 值不存在、或类型不是这两种（REG_BINARY 等）时返回 null —— 调用方按「没有」处理。
({int type, List<int> bytes})? queryRegistryValueRaw(String name) {
  if (!_loadMore() || !_loadAdvapi()) {
    return null;
  }
  final fn = _regQueryValueEx;
  if (fn == null) {
    return null;
  }
  final key = _openInternetSettings(readOnly: true);
  if (key == 0) {
    return null;
  }
  final namePtr = _utf16Address(name);
  final typePtr = _localAlloc!(_kLptr, 4);
  final sizePtr = _localAlloc!(_kLptr, 4);
  // 先问一次大小（REG_SZ 的值长度不定）。
  var dataPtr = 0;
  try {
    if (namePtr == 0 || typePtr == 0 || sizePtr == 0) {
      return null;
    }
    Pointer<Uint32>.fromAddress(sizePtr).value = 0;
    var rc = fn(
      key,
      Pointer<Uint16>.fromAddress(namePtr),
      0,
      Pointer<Uint32>.fromAddress(typePtr),
      Pointer<Uint8>.fromAddress(0),
      Pointer<Uint32>.fromAddress(sizePtr),
    );
    final size = Pointer<Uint32>.fromAddress(sizePtr).value;
    // ERROR_SUCCESS(0) = 拿到了；ERROR_MORE_DATA(234) = 缓冲区不够，但这个大小可用。
    if (rc != _kErrorSuccess && rc != 234) {
      return null;
    }
    if (size == 0) {
      return (type: Pointer<Uint32>.fromAddress(typePtr).value, bytes: const []);
    }
    dataPtr = _localAlloc!(_kLptr, size);
    if (dataPtr == 0) {
      return null;
    }
    Pointer<Uint32>.fromAddress(sizePtr).value = size;
    rc = fn(
      key,
      Pointer<Uint16>.fromAddress(namePtr),
      0,
      Pointer<Uint32>.fromAddress(typePtr),
      Pointer<Uint8>.fromAddress(dataPtr),
      Pointer<Uint32>.fromAddress(sizePtr),
    );
    if (rc != _kErrorSuccess) {
      return null;
    }
    final got = Pointer<Uint32>.fromAddress(sizePtr).value;
    final bytes = List<int>.generate(got, (i) => Pointer<Uint8>.fromAddress(dataPtr)[i]);
    return (type: Pointer<Uint32>.fromAddress(typePtr).value, bytes: bytes);
  } catch (_) {
    return null;
  } finally {
    _freeLocal(namePtr);
    _freeLocal(typePtr);
    _freeLocal(sizePtr);
    _freeLocal(dataPtr);
    _regCloseKey?.call(key);
  }
}

/// 读一个 REG_SZ / REG_DWORD，格式化成 `reg query` 同款的一行文本：
/// `    <name>    REG_SZ    <value>`。不存在/类型不符 → null。
///
/// 这样它的输出可以直接喂给 `SystemProxySnapshot.valueText`，两套读取路径
/// （FFI 与 reg.exe 兜底）的解析结果完全一致。
String? queryRegistryValueAsRegText(String name) {
  final raw = queryRegistryValueRaw(name);
  if (raw == null) {
    return null;
  }
  if (raw.type == _kRegDword) {
    if (raw.bytes.length < 4) {
      return null;
    }
    final v = raw.bytes[0] |
        (raw.bytes[1] << 8) |
        (raw.bytes[2] << 16) |
        (raw.bytes[3] << 24);
    return "    $name    REG_DWORD    0x${v.toRadixString(16)}";
  }
  if (raw.type == _kRegSz) {
    final units = <int>[];
    for (var i = 0; i + 1 < raw.bytes.length; i += 2) {
      final u = raw.bytes[i] | (raw.bytes[i + 1] << 8);
      if (u == 0) {
        break;
      }
      units.add(u);
    }
    // 值可能是 REG_EXPAND_SZ（2），那种我们按原文显示（不做环境变量展开）——
    // 只有 REG_SZ 与它会被读成字符串，其余类型上面已经返回 null。
    return "    $name    REG_SZ    ${String.fromCharCodes(units)}";
  }
  // REG_EXPAND_SZ = 2：也按字符串处理
  if (raw.type == 2) {
    final units = <int>[];
    for (var i = 0; i + 1 < raw.bytes.length; i += 2) {
      final u = raw.bytes[i] | (raw.bytes[i + 1] << 8);
      if (u == 0) {
        break;
      }
      units.add(u);
    }
    return "    $name    REG_EXPAND_SZ    ${String.fromCharCodes(units)}";
  }
  return null;
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

/// `PROXY_TYPE_*`（公开：desktop_impl 需要在清理时按原值还原 flags）
const int kProxyTypeDirect = 0x1;
const int kProxyTypeProxy = 0x2;
const int _kProxyTypeDirect = kProxyTypeDirect;
const int _kProxyTypeProxy = kProxyTypeProxy;

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
bool _localAllocFailed = false;

/// `LPTR` = LMEM_FIXED | LMEM_ZEROINIT
const int _kLptr = 0x0040;

/// 加载 kernel32 的 LocalAlloc / LocalFree（注册表写入与每连接选项都要用）。
bool _loadLocal() {
  if (_localAlloc != null) {
    return true;
  }
  if (_localAllocFailed || !Platform.isWindows) {
    return false;
  }
  try {
    final kernel32 = DynamicLibrary.open('kernel32.dll');
    _localAlloc = kernel32
        .lookupFunction<_LocalAllocNative, _LocalAllocDart>('LocalAlloc');
    _localFree =
        kernel32.lookupFunction<_LocalFreeNative, _LocalFreeDart>('LocalFree');
    return true;
  } catch (_) {
    _localAllocFailed = true;
    return false;
  }
}

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
    return _loadLocal();
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
}) => writeSystemProxyForConnection(server: server, bypass: bypass);

/// 写「当前连接」的代理设置（**界面读的就是这一份**）。
///
/// 这是 Windows 自己勾选「使用代理服务器」时走的同一条官方 API：
/// `InternetSetOption(NULL, INTERNET_OPTION_PER_CONNECTION_OPTION(75), &list, size)`。
/// 它一次把 flags / 服务器 / 旁路写进 `Connections\DefaultConnectionSettings`
/// 并同步注册表 —— 「Internet 选项 → 局域网设置」和「设置 → 网络和 Internet →
/// 代理」读的都是这份数据。
///
/// 只写注册表（ProxyEnable/ProxyServer）时，窗口里的字段在某些机器上**一直空白**：
/// 用户实测同一台机器上参考客户端能显示、我们不能（见 desktop_impl 里的对比注释）。
bool writeSystemProxyForConnection({
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
    _fillOptions(
      options,
      count: 3,
      flags: _kProxyTypeDirect | _kProxyTypeProxy,
      serverPtr: serverPtr,
      bypassPtr: bypassPtr,
    );
    _fillList(list, options, 3);
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

/// 把 INTERNET_PER_CONN_OPTION 数组按需填好（只填给了的项）。
void _fillOptions(
  int options, {
  required int count,
  int? flags,
  int serverPtr = 0,
  int bypassPtr = 0,
}) {
  var index = 0;
  if (flags != null) {
    _writeDword(options + _optionSize * index, _kPerConnFlags);
    _writePtr(options + _optionSize * index + _optionValueOffset, flags);
    index++;
  }
  if (serverPtr != 0) {
    _writeDword(options + _optionSize * index, _kPerConnProxyServer);
    _writePtr(options + _optionSize * index + _optionValueOffset, serverPtr);
    index++;
  }
  if (bypassPtr != 0) {
    _writeDword(options + _optionSize * index, _kPerConnProxyBypass);
    _writePtr(options + _optionSize * index + _optionValueOffset, bypassPtr);
    index++;
  }
  // count 只是缓冲区上限；实际项数由调用方传进来的个数决定
  assert(index <= count);
}

/// 填 INTERNET_PER_CONN_OPTION_LIST（dwSize / pszConnection=NULL / count / options）。
void _fillList(int list, int options, int count) {
  _writeDword(list, _listSize);
  _writePtr(list + _listPszConnectionOffset, 0);
  _writeDword(list + _listCountOffset, count);
  _writeDword(list + _listErrorOffset, 0);
  _writePtr(list + _listOptionsOffset, options);
}

/// 把**当前连接**的代理清成「直连」（同样会同步界面缓存）。
///
/// ⚠️ 清理系统代理**不要**用这个当作默认动作。
///
/// Windows 界面读的就是这份每连接数据，而 MoneyFly / Clash Party / Clash Verge
/// 这些客户端**只写注册表**、从不去碰它。我们在这里写一次「直连」，等于把别人
/// 设置的系统代理从界面上抹掉 —— 用户实测的现象就是
/// 「用了 Mclash 之后，MoneyFly 连上了、Windows 里却不显示 127.0.0.1 和端口了」，
/// 而注册表里其实是有值的（所以还能上网）。
/// 现在它只有两个正当用途：测试隔离，以及还原「我们写入前就是直连」的那份快照
/// （见 desktop_impl 的 _cleanSystemProxyWindows）。其余情况请用
/// [restoreSystemProxyForConnection]。
bool clearSystemProxyForConnection() {
  final fn = _resolve();
  if (fn == null || !_loadMore()) {
    return false;
  }
  var options = 0;
  var list = 0;
  var emptyServer = 0;
  var emptyBypass = 0;
  try {
    // ⚠️ 必须**同时**清掉服务器与旁路字符串。
    //
    // 只把 flags 改成直连（Windows 自己在界面上的行为）时，PROXY_SERVER 字符串
    // 会留在里面。对我们来说那是残留的坏状态：下次别家客户端只写注册表时，
    // 这份「flags=直连 + 上一次的 127.0.0.1:端口」会造成界面显示与实际不符。
    options = _localAlloc!(_kLptr, _optionSize * 3);
    list = _localAlloc!(_kLptr, _listSize);
    emptyServer = _allocUtf16("");
    emptyBypass = _allocUtf16("");
    if (options == 0 || list == 0 || emptyServer == 0 || emptyBypass == 0) {
      return false;
    }
    _fillOptions(
      options,
      count: 3,
      flags: _kProxyTypeDirect,
      serverPtr: emptyServer,
      bypassPtr: emptyBypass,
    );
    _fillList(list, options, 3);
    return fn(0, _kOptionPerConnectionOption, list, _listSize) != 0;
  } catch (_) {
    return false;
  } finally {
    _freeLocal(emptyServer);
    _freeLocal(emptyBypass);
    _freeLocal(options);
    _freeLocal(list);
  }
}

/// 把「当前连接」的代理**还原**成我们写入之前的那个状态。
///
/// 与 [clearSystemProxyForConnection] 的区别是「用户原本就配着代理」的那种情况：
/// 那时应该把原值写回去，而不是一律清成直连。
///
/// [flags] 为空（读不到）时按「原本没启用代理」处理 —— 这时写「直连」是安全的，
/// 因为读不到 flags 的机器上界面本来也没显示过我们的值。
bool restoreSystemProxyForConnection({
  int? flags,
  required String server,
  required String bypass,
}) {
  if (restoreDecisionFor(flags: flags, server: server)) {
    return writeSystemProxyForConnection(server: server, bypass: bypass);
  }
  return clearSystemProxyForConnection();
}

/// 还原时该「写原值」还是「写直连」——**纯函数**，单测直接钉住。
///
/// 只有「flags 里确实开着代理」且「有非空的服务器地址」时才写原值。
/// 其余情况（读不到 flags / 原本就没配）都按直连处理：那种机器上界面本来也没
/// 显示过我们的值，写直连不会让界面「从有变无」，因此是安全的默认。
bool restoreDecisionFor({int? flags, required String server}) {
  final wanted = flags ?? _kProxyTypeDirect;
  return (wanted & _kProxyTypeProxy) != 0 && server.trim().isNotEmpty;
}

/// 测试缝：[restoreDecisionFor] 的字符串形式（"write" / "clear"）。
String restoreFlagsDecideForTest({int? flags, required String server}) =>
    restoreDecisionFor(flags: flags, server: server) ? "write" : "clear";

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

/// 读回「当前连接」里配置的旁路列表；没配则空串。
String querySystemProxyBypassForConnection() =>
    queryConnectionOption(_kPerConnProxyBypass, asString: true) ?? "";

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
  // flags 走的是 union 里的 dwValue，`queryConnectionOption` 会把它读成十进制
  // 数字字符串（指针宽度那 8 字节的高位是 LPTR 清零的）。解析不出来就按「未启用」。
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

/// `SMTO_NOTIMEOUTIFNOTHUNG`：对方没卡就一定会回，卡住才受超时限制。
///
/// 比 [ABORTIFHUNG] 更适合我们这种「发完就不管」的场合：它不会因为对方处理得慢
/// 就把消息丢掉（那会导致界面不刷新），只在真的挂起时才提前放弃。
const int _kSmtoNotTimeoutIfNotHung = 0x0008;

/// 广播的超时（毫秒）。
///
/// 这条广播是**同步**的，而 `HWND_BROADCAST` 意味着机器上每个顶层窗口都在关键
/// 路径上。以前用 1000ms：只要有一个窗口不响应，一次连接就要多等整整一秒
/// （用户日志里那段 8.8 秒的「写入 → 广播返回」间隔就是这么来的，断开时一样）。
/// 200ms 足够让正常窗口收到消息，卡住的窗口也不会再把我们拖住。
const int _kBroadcastTimeoutMs = 200;

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
///
/// ⚠️ 这是**同步**调用（见 [_kBroadcastTimeoutMs]）。连接/断开的关键路径上请用
/// [broadcastInternetSettingsChangedAsync]，别让用户的点击等在这里。
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
      _kSmtoNotTimeoutIfNotHung,
      _kBroadcastTimeoutMs,
      Pointer<UintPtr>.fromAddress(resultPtr),
    );
    return r != 0;
  } catch (_) {
    return false;
  } finally {
    _freeLocal(textPtr);
    _freeLocal(resultPtr);
  }
}

/// 调用 [broadcastInternetSettingsChanged]，但**不阻塞调用方**。
///
/// 广播的用途只有一个：让 Windows 界面与已经在跑的浏览器重读设置 —— 它**不属于**
/// 「这次连接成功了没有」这个结论的一部分。以前它同步跑在连接/断开路径上，于是
/// 用户每点一次都要陪着等它（实测 8 秒+）。现在写完之后立刻返回，广播在后台完成，
/// 结果只写进日志与诊断面板。
///
/// 返回值是「广播是否已经发起」（FFI 可用），不是「窗口是否都收到了」。
bool broadcastInternetSettingsChangedAsync() {
  if (!Platform.isWindows) {
    return false;
  }
  final fn = _resolveSendMessageTimeout();
  if (fn == null) {
    return false;
  }
  // 不 await：调用方继续走自己的路。
  unawaited(Future<void>(() {
    try {
      broadcastInternetSettingsChanged();
    } catch (_) {}
  }));
  return true;
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

/// `127.0.0.1:7890` / `localhost:7890` → 7890；其它形式 → null。
///
/// 只认「单机地址 + 端口」这一种形式：`ProxyServer` 也可能是
/// `http=1.2.3.4:80;https=...` 这类分协议写法，那种一律返回 null
/// （调用方会因此判定「不是我们写的」→ 不碰，宁可不清理也不能误清）。
int? loopbackProxyPort(String? server) {
  if (server == null || server.isEmpty) {
    return null;
  }
  final first = server.split(RegExp(r"[;,]")).first.trim();
  final m = RegExp(
    r"^(127\.0\.0\.1|localhost|\[::1\]):(\d{1,5})$",
  ).firstMatch(first);
  if (m == null) {
    return null;
  }
  final port = int.tryParse(m.group(2)!) ?? 0;
  return (port > 0 && port <= 65535) ? port : null;
}

/// 本机端口上是否还有程序在监听（一次 TCP 连接尝试，默认超时 300ms）。
///
/// 用来区分「残留的死代理」和「别的代理软件正在用的活代理」：
/// 端口还活着 → 不能碰（否则会把别人正在用的系统代理清掉）。
Future<bool> isLocalPortAlive(
  int port, {
  Duration timeout = const Duration(milliseconds: 300),
}) async {
  Socket? s;
  try {
    s = await Socket.connect(
      InternetAddress.loopbackIPv4,
      port,
      timeout: timeout,
    );
    return true;
  } catch (_) {
    return false;
  } finally {
    try {
      s?.destroy();
    } catch (_) {}
  }
}
