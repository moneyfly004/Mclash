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

const int _kInternetOptionSettingsChanged = 39;

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

const int _kHkeyCurrentUser = 0x80000001;

const int _kKeySetAndQueryValue = 0x0002 | 0x0001;

const int _kKeyQueryValue = 0x0001;

const int _kRegSz = 1;
const int _kRegDword = 4;

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
    return rc == _kErrorSuccess || rc == 2;
  } finally {
    _freeLocal(namePtr);
    _regCloseKey?.call(key);
  }
}

bool get windowsRegistryAvailable {
  _loadMore();
  return _loadAdvapi();
}

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
    return "    $name    REG_SZ    ${String.fromCharCodes(units)}";
  }
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


const int _kOptionPerConnectionOption = 75;

const int _kPerConnFlags = 1;
const int _kPerConnProxyServer = 2;
const int _kPerConnProxyBypass = 3;

const int kProxyTypeDirect = 0x1;
const int kProxyTypeProxy = 0x2;
const int _kProxyTypeDirect = kProxyTypeDirect;
const int _kProxyTypeProxy = kProxyTypeProxy;

int get _ptrSize => sizeOf<Pointer<NativeType>>();
int get _optionSize => _ptrSize + 8; 
int get _optionValueOffset => _ptrSize; 
int get _listPszConnectionOffset => _ptrSize; 
int get _listCountOffset => _ptrSize * 2; 
int get _listErrorOffset => _ptrSize * 2 + 4; 
int get _listOptionsOffset => _ptrSize == 8 ? 24 : 16;
int get _listSize => _listOptionsOffset + _ptrSize; 

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

const int _kLptr = 0x0040;

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
    _getLastError = kernel32
        .lookupFunction<_GetLastErrorNative, _GetLastErrorDart>('GetLastError');
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

void _writeDword(int base, int value) =>
    Pointer<Uint32>.fromAddress(base).value = value;

void _writePtr(int base, int value) =>
    Pointer<UintPtr>.fromAddress(base).value = value;

int _readPtr(int base) => Pointer<UintPtr>.fromAddress(base).value;

int _readDword(int base) => Pointer<Uint32>.fromAddress(base).value;

int _allocUtf16(String s) {
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

bool applySystemProxyForConnection({
  required String server,
  required String bypass,
}) => writeSystemProxyForConnection(server: server, bypass: bypass);

bool writeSystemProxyForConnection({
  required String server,
  required String bypass,
}) {
  final fn = _resolve();
  if (fn == null || !_loadMore() || server.trim().isEmpty) {
    return false;
  }
  final s = server.trim();
  final b = bypass
      .split(';')
      .map((e) => e.trim())
      .where((e) =>
          e.isNotEmpty && e.toLowerCase() != '<local>' && !e.contains('::'))
      .join(';');

  final connections = <String>[""];
  try {
    connections.addAll(enumerateRasConnections());
  } catch (_) {}

  final attempts = <({String label, String server, String bypass})>[
    (label: "FLAGS+SERVER+BYPASS", server: s, bypass: b),
    if (b.isNotEmpty) (label: "FLAGS+SERVER", server: s, bypass: ""),
    (label: "FLAGS", server: "", bypass: ""),
  ];

  var lanOk = false;
  for (final conn in connections) {
    for (final a in attempts) {
      PerConnectionDiagnostics.lastAttempt =
          "${conn.isEmpty ? "LAN" : conn}:${a.label}";
      final ok = _trySetPerConnection(
        fn,
        server: a.server,
        bypass: a.bypass,
        connection: conn,
      );
      if (ok) {
        if (conn.isEmpty) {
          lanOk = true;
        }
        PerConnectionDiagnostics.lastError = 0;
        PerConnectionDiagnostics.optionError = -1;
        break; 
      }
    }
  }
  PerConnectionDiagnostics.lastSucceeded = lanOk;
  return lanOk;
}

bool _trySetPerConnection(
  _InternetSetOptionDart fn, {
  required String server,
  required String bypass,
  required String connection,
}) {
  final hasServer = server.isNotEmpty;
  final hasBypass = bypass.isNotEmpty;
  final count = 1 + (hasServer ? 1 : 0) + (hasBypass ? 1 : 0);
  var options = 0;
  var list = 0;
  var serverPtr = 0;
  var bypassPtr = 0;
  var connPtr = 0;
  try {
    options = _localAlloc!(_kLptr, _optionSize * count);
    list = _localAlloc!(_kLptr, _listSize);
    if (hasServer) {
      serverPtr = _allocUtf16(server);
    }
    if (hasBypass) {
      bypassPtr = _allocUtf16(bypass);
    }
    if (connection.isNotEmpty) {
      connPtr = _allocUtf16(connection);
    }
    if (options == 0 ||
        list == 0 ||
        (hasServer && serverPtr == 0) ||
        (hasBypass && bypassPtr == 0) ||
        (connection.isNotEmpty && connPtr == 0)) {
      return false;
    }
    _fillOptions(
      options,
      count: count,
      flags: _kProxyTypeDirect | _kProxyTypeProxy,
      serverPtr: serverPtr,
      bypassPtr: bypassPtr,
    );
    _fillList(list, options, count, connection: connPtr);
    final ok = fn(0, _kOptionPerConnectionOption, list, _listSize);
    if (ok == 0) {
      PerConnectionDiagnostics.lastError = _winLastError();
      PerConnectionDiagnostics.optionError = _readDword(list + _listErrorOffset);
    }
    return ok != 0;
  } catch (_) {
    PerConnectionDiagnostics.lastError = _winLastError();
    return false;
  } finally {
    if (serverPtr != 0) {
      _localFree?.call(serverPtr);
    }
    if (bypassPtr != 0) {
      _localFree?.call(bypassPtr);
    }
    if (connPtr != 0) {
      _localFree?.call(connPtr);
    }
    if (options != 0) {
      _localFree?.call(options);
    }
    if (list != 0) {
      _localFree?.call(list);
    }
  }
}

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
    _writeDword(options + _optionSize * index + _optionValueOffset, flags);
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
  assert(index <= count);
}

void _fillList(int list, int options, int count, {int connection = 0}) {
  _writeDword(list, _listSize);
  _writePtr(list + _listPszConnectionOffset, connection);
  _writeDword(list + _listCountOffset, count);
  _writeDword(list + _listErrorOffset, 0);
  _writePtr(list + _listOptionsOffset, options);
}

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

bool restoreDecisionFor({int? flags, required String server}) {
  final wanted = flags ?? _kProxyTypeDirect;
  return (wanted & _kProxyTypeProxy) != 0 && server.trim().isNotEmpty;
}

String restoreFlagsDecideForTest({int? flags, required String server}) =>
    restoreDecisionFor(flags: flags, server: server) ? "write" : "clear";

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

String querySystemProxyForConnection() =>
    queryConnectionOption(_kPerConnProxyServer, asString: true) ?? "";

String querySystemProxyBypassForConnection() =>
    queryConnectionOption(_kPerConnProxyBypass, asString: true) ?? "";

int? queryConnectionFlagsForConnection() {
  final raw = queryConnectionOption(_kPerConnFlags, asString: false);
  if (raw == null) {
    return null;
  }
  return int.tryParse(raw) ?? -1;
}

bool connectionProxyEnabled() {
  final flags = queryConnectionFlagsForConnection();
  if (flags == null) {
    return false;
  }
  return (flags & _kProxyTypeProxy) != 0;
}


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

const int _kHwndBroadcast = 0xffff;

const int _kWmSettingChange = 0x001A;

/// ⚠️ 广播超时**必须**是真能生效的：
///
/// - **禁止** `SMTO_NOTIMEOUTIFNOTHUNG (0x0008)`。按 Win32 文档，只要接收线程
///   “还在处理消息”就完全不执行超时；而“是否 hung”的判定标准只是“5 秒内有没有
///   调过 GetMessage”。现实里 Qt 内部窗口、输入法/悬浮窗等线程会定时醒来处理
///   自己的定时器（因此被判定为“没 hung”），却永远不会处理这条被 Send 过来的
///   消息 —— 调用线程就会**永久**卡死在 user32!SendMessageTimeout 里，整个 GUI
///   变成「未响应」，连关闭窗口都只能靠任务管理器强制结束。
///   实测：Mclash 连接时广播 WM_SETTINGCHANGE，被 WPS Office 的
///   `QEventDispatcherWin32_Internal_Widget`（wps.exe）卡死 20+ 分钟不返回。
/// - `SMTO_ABORTIFHUNG (0x0002)` 才是正确选择：对方不响应就立刻返回。
const int _kSmtoAbortIfHung = 0x0002;

/// 单个窗口的超时时间。注意 `HWND_BROADCAST` 的总耗时 = 本值 × 顶层窗口数，
/// 所以这个值不能大；真正的兜底是「不要在调用线程里同步广播」。
const int _kBroadcastTimeoutMs = 200;

typedef _PostMessageNative = Int32 Function(
  IntPtr hWnd,
  Uint32 msg,
  UintPtr wParam,
  IntPtr lParam,
);
typedef _PostMessageDart = int Function(
  int hWnd,
  int msg,
  int wParam,
  int lParam,
);

_SendMessageTimeoutDart? _sendMessageTimeout;
_PostMessageDart? _postMessage;
bool _user32LoadFailed = false;

int _internetSettingsTextPtr = 0;

int _internetSettingsText() {
  if (_internetSettingsTextPtr != 0) {
    return _internetSettingsTextPtr;
  }
  if (!_loadMore()) {
    return 0;
  }
  _internetSettingsTextPtr = _allocUtf16("InternetSettings");
  return _internetSettingsTextPtr;
}

_PostMessageDart? _resolvePostMessage() {
  if (_postMessage != null) {
    return _postMessage;
  }
  if (_user32LoadFailed || !Platform.isWindows) {
    return null;
  }
  try {
    final lib = DynamicLibrary.open('user32.dll');
    _postMessage = lib
        .lookupFunction<_PostMessageNative, _PostMessageDart>('PostMessageW');
    return _postMessage;
  } catch (_) {
    return null;
  }
}

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

/// 同步广播（会阻塞调用线程直到所有顶层窗口处理完/超时）。
///
/// ⚠️ **不要在 UI/GUI 线程上调用它**（生产路径请用
/// [broadcastInternetSettingsChangedAsync]，它绝不阻塞调用线程）。
/// 保留此函数只给测试与诊断用，且已改用 `SMTO_ABORTIFHUNG`。
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

bool postInternetSettingsChanged() {
  final fn = _resolvePostMessage();
  if (fn == null) {
    return false;
  }
  final text = _internetSettingsText();
  if (text == 0) {
    return false;
  }
  try {
    return fn(_kHwndBroadcast, _kWmSettingChange, 0, text) != 0;
  } catch (_) {
    return false;
  }
}

/// 通知系统「Internet 设置已变更」（新版：**绝不阻塞调用线程**）。
///
/// 历史坑：这里以前在 `PostMessage` 失败时会退到
/// `broadcastInternetSettingsChanged()`（同线程同步广播 + SMTO_NOTIMEOUTIFNOTHUNG），
/// 一旦系统里存在“不处理这条消息”的顶层窗口，GUI 线程就永久卡死
/// （实测被 WPS Office 的 Qt 内部窗口卡住，整个 App 变「未响应」）。
///
/// 现在只做两件不会阻塞调用线程的事：
///   1. `PostMessage` 异步投递（首选，投递成功即返回）；
///   2. 失败时把同步广播交给一次性的 PowerShell 子进程（可超时、可杀）——
///      就算对方窗口不处理消息，卡住的也只是那个子进程，不会拖住 UI。
bool broadcastInternetSettingsChangedAsync() {
  if (!Platform.isWindows) {
    return false;
  }
  if (postInternetSettingsChanged()) {
    return true;
  }
  unawaited(broadcastInternetSettingsViaPowerShell());
  return true;
}

/// 用一次性的 PowerShell 子进程做 `WM_SETTINGCHANGE` 广播。
///
/// 子进程里用的是 `SMTO_ABORTIFHUNG(2)` + 1000ms；再加一层 8 秒硬超时并强杀，
/// 保证**任何情况下都不会**在客户端留下卡死的线程/进程。
Future<bool> broadcastInternetSettingsViaPowerShell() async {
  if (!Platform.isWindows) {
    return false;
  }
  const script = r'''
Add-Type -MemberDefinition '[DllImport("user32.dll", SetLastError = true)] public static extern bool SendMessageTimeout(IntPtr hWnd, uint Msg, UIntPtr wParam, string lParam, uint fuFlags, uint uTimeout, out UIntPtr lpdwResult);' -Name P -Namespace W32
$r = [UIntPtr]::Zero
[void][W32.P]::SendMessageTimeout([IntPtr]0xffff, 0x001A, [UIntPtr]::Zero, "InternetSettings", 2, 1000, [ref]$r)
''';
  File? ps1;
  Process? proc;
  try {
    ps1 = File(
      '${Directory.systemTemp.path}/mclash_proxy_notify_'
      '${pid}_${DateTime.now().microsecondsSinceEpoch}.ps1',
    );
    await ps1.writeAsString(script, flush: true);
    final started = await Process.start('powershell', [
      '-NoProfile',
      '-NonInteractive',
      '-ExecutionPolicy',
      'Bypass',
      '-File',
      ps1.path,
    ]);
    proc = started;
    final code = await started.exitCode.timeout(
      const Duration(seconds: 8),
      onTimeout: () {
        try {
          proc?.kill(ProcessSignal.sigkill);
        } catch (_) {}
        return -1;
      },
    );
    return code == 0;
  } catch (_) {
    return false;
  } finally {
    try {
      await ps1?.delete();
    } catch (_) {}
  }
}

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


const int _kRegBinary = 3;

class PerConnectionDiagnostics {
  static bool lastSucceeded = false;
  static int lastError = 0; 
  static int optionError = -1; 
  static String fallbackUsed = ""; 
  static String lastAttempt = ""; 

  static void reset() {
    lastSucceeded = false;
    lastError = 0;
    optionError = -1;
    fallbackUsed = "";
    lastAttempt = "";
  }
}

typedef _GetLastErrorNative = Uint32 Function();
typedef _GetLastErrorDart = int Function();
_GetLastErrorDart? _getLastError;

int _winLastError() {
  try {
    _getLastError ??= DynamicLibrary.open(
      'kernel32.dll',
    ).lookupFunction<_GetLastErrorNative, _GetLastErrorDart>('GetLastError');
    return _getLastError!();
  } catch (_) {
    return -1;
  }
}

int _openConnectionsKey({bool readOnly = false}) {
  final fn = _regOpenKeyEx;
  if (fn == null) {
    return 0;
  }
  final sub = _utf16Address(
    r"Software\Microsoft\Windows\CurrentVersion\Internet Settings\Connections",
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

List<int>? readDefaultConnectionSettings({String connection = ""}) {
  if (!_loadMore() || !_loadAdvapi()) {
    return null;
  }
  final key = _openConnectionsKey(readOnly: true);
  if (key == 0) {
    return null;
  }
  final namePtr = _utf16Address(
    connection.isEmpty ? "DefaultConnectionSettings" : connection,
  );
  final typePtr = _localAlloc!(_kLptr, 4);
  final sizePtr = _localAlloc!(_kLptr, 4);
  var dataPtr = 0;
  try {
    if (namePtr == 0 || typePtr == 0 || sizePtr == 0) {
      return null;
    }
    Pointer<Uint32>.fromAddress(sizePtr).value = 0;
    var rc = _regQueryValueEx!(
      key,
      Pointer<Uint16>.fromAddress(namePtr),
      0,
      Pointer<Uint32>.fromAddress(typePtr),
      Pointer<Uint8>.fromAddress(0),
      Pointer<Uint32>.fromAddress(sizePtr),
    );
    final size = Pointer<Uint32>.fromAddress(sizePtr).value;
    if (rc != _kErrorSuccess && rc != 234) {
      return null;
    }
    if (size == 0) {
      return const [];
    }
    dataPtr = _localAlloc!(_kLptr, size);
    if (dataPtr == 0) {
      return null;
    }
    Pointer<Uint32>.fromAddress(sizePtr).value = size;
    rc = _regQueryValueEx!(
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
    return List<int>.generate(got, (i) => Pointer<Uint8>.fromAddress(dataPtr)[i]);
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

bool writeDefaultConnectionSettings(
  List<int> bytes, {
  String connection = "",
}) {
  if (!_loadMore() || !_loadAdvapi() || bytes.isEmpty) {
    return false;
  }
  final key = _openConnectionsKey();
  if (key == 0) {
    return false;
  }
  final namePtr = _utf16Address(
    connection.isEmpty ? "DefaultConnectionSettings" : connection,
  );
  final data = _localAlloc!(_kLptr, bytes.length);
  try {
    if (namePtr == 0 || data == 0) {
      return false;
    }
    for (var i = 0; i < bytes.length; i++) {
      Pointer<Uint8>.fromAddress(data)[i] = bytes[i];
    }
    final rc = _regSetValueEx!(
      key,
      Pointer<Uint16>.fromAddress(namePtr),
      0,
      _kRegBinary,
      Pointer<Uint8>.fromAddress(data),
      bytes.length,
    );
    return rc == _kErrorSuccess;
  } finally {
    _freeLocal(namePtr);
    _freeLocal(data);
    _regCloseKey?.call(key);
  }
}

List<int> buildDefaultConnectionSettingsBlob({
  required int flags,
  required String server,
  required String bypass,
  int counter = 0,
}) {
  final cleanBypass = bypass
      .split(';')
      .map((e) => e.trim())
      .where((e) =>
          e.isNotEmpty && e.toLowerCase() != '<local>' && !e.contains('::'))
      .join(';');
  final out = <int>[];
  void dw(int v) {
    out.add(v & 0xff);
    out.add((v >> 8) & 0xff);
    out.add((v >> 16) & 0xff);
    out.add((v >> 24) & 0xff);
  }

  void str(String s) {
    final bytes = <int>[];
    for (final u in s.codeUnits) {
      bytes.add(u & 0xff); 
    }
    dw(bytes.length);
    out.addAll(bytes);
  }

  dw(0x46); 
  dw(counter);
  dw(flags);
  str(server);
  str(cleanBypass);
  dw(0); 
  return out;
}

int? parseDefaultConnectionSettingsFlags(List<int>? blob) {
  if (blob == null || blob.length < 12) {
    return null;
  }
  return blob[8] | (blob[9] << 8) | (blob[10] << 16) | (blob[11] << 24);
}

bool defaultConnectionSettingsContains(List<int>? blob, String server) {
  if (blob == null || blob.isEmpty || server.isEmpty) {
    return false;
  }
  final bytes = <int>[];
  for (final u in server.codeUnits) {
    bytes.add(u & 0xff);
  }
  for (var i = 0; i + bytes.length <= blob.length; i++) {
    var match = true;
    for (var k = 0; k < bytes.length; k++) {
      if (blob[i + k] != bytes[k]) {
        match = false;
        break;
      }
    }
    if (match) {
      return true;
    }
  }
  return false;
}


typedef _RasEnumEntriesNative = Int32 Function(
  IntPtr reserved,
  IntPtr lpszPhonebook,
  Pointer<Uint8> lprasentryname,
  Pointer<Uint32> lpcb,
  Pointer<Uint32> lpcEntries,
);
typedef _RasEnumEntriesDart = int Function(
  int reserved,
  int lpszPhonebook,
  Pointer<Uint8> lprasentryname,
  Pointer<Uint32> lpcb,
  Pointer<Uint32> lpcEntries,
);

_RasEnumEntriesDart? _rasEnumEntries;
bool _rasLoadFailed = false;

const int _rasMaxEntryName = 256;
const int _rasEntryNameSize = 4 + (_rasMaxEntryName + 1) * 2; 

_RasEnumEntriesDart? _resolveRasEnumEntries() {
  if (_rasEnumEntries != null) {
    return _rasEnumEntries;
  }
  if (_rasLoadFailed || !Platform.isWindows) {
    return null;
  }
  try {
    final lib = DynamicLibrary.open('Rasapi32.dll');
    _rasEnumEntries = lib.lookupFunction<_RasEnumEntriesNative, _RasEnumEntriesDart>(
      'RasEnumEntriesW',
    );
    return _rasEnumEntries;
  } catch (_) {
    _rasLoadFailed = true;
    return null;
  }
}

List<String> enumerateRasConnections() {
  final fn = _resolveRasEnumEntries();
  if (fn == null) {
    return const [];
  }
  final sizePtr = _localAlloc!(_kLptr, 4);
  final countPtr = _localAlloc!(_kLptr, 4);
  if (sizePtr == 0 || countPtr == 0) {
    _freeLocal(sizePtr);
    _freeLocal(countPtr);
    return const [];
  }
  try {
    Pointer<Uint32>.fromAddress(sizePtr).value = 0;
    Pointer<Uint32>.fromAddress(countPtr).value = 0;
    final rc = fn(
      0,
      0,
      Pointer<Uint8>.fromAddress(0),
      Pointer<Uint32>.fromAddress(sizePtr),
      Pointer<Uint32>.fromAddress(countPtr),
    );
    final count = Pointer<Uint32>.fromAddress(countPtr).value;
    if (rc != 603 || count == 0) {
      return const [];
    }
    final buf = _localAlloc!(_kLptr, _rasEntryNameSize * count);
    if (buf == 0) {
      return const [];
    }
    final names = <String>[];
    try {
      for (var i = 0; i < count; i++) {
        Pointer<Uint32>.fromAddress(buf + i * _rasEntryNameSize).value =
            _rasEntryNameSize;
      }
      final rc2 = fn(
        0,
        0,
        Pointer<Uint8>.fromAddress(buf),
        Pointer<Uint32>.fromAddress(sizePtr),
        Pointer<Uint32>.fromAddress(countPtr),
      );
      if (rc2 != 0) {
        return const [];
      }
      final got = Pointer<Uint32>.fromAddress(countPtr).value;
      for (var i = 0; i < got; i++) {
        final base = buf + i * _rasEntryNameSize + 4; 
        final units = <int>[];
        for (var k = 0; k < _rasMaxEntryName; k++) {
          final u =
              Pointer<Uint16>.fromAddress(base + k * 2).value;
          if (u == 0) {
            break;
          }
          units.add(u);
        }
        if (units.isNotEmpty) {
          names.add(String.fromCharCodes(units));
        }
      }
    } finally {
      _freeLocal(buf);
    }
    return names;
  } finally {
    _freeLocal(sizePtr);
    _freeLocal(countPtr);
  }
}

typedef _RegEnumValueNative = Int32 Function(
  IntPtr hKey,
  Uint32 dwIndex,
  Pointer<Uint16> lpValueName,
  Pointer<Uint32> lpcchValueName,
  IntPtr lpReserved,
  Pointer<Uint32> lpType,
  Pointer<Uint8> lpData,
  Pointer<Uint32> lpcbData,
);
typedef _RegEnumValueDart = int Function(
  int hKey,
  int dwIndex,
  Pointer<Uint16> lpValueName,
  Pointer<Uint32> lpcchValueName,
  int lpReserved,
  Pointer<Uint32> lpType,
  Pointer<Uint8> lpData,
  Pointer<Uint32> lpcbData,
);

_RegEnumValueDart? _regEnumValue;

List<String> enumerateConnectionValueNames() {
  if (!_loadMore() || !_loadAdvapi()) {
    return const [];
  }
  final fn = _regEnumValue ??= (() {
    try {
      return DynamicLibrary.open('advapi32.dll').lookupFunction<
          _RegEnumValueNative, _RegEnumValueDart>('RegEnumValueW');
    } catch (_) {
      return null;
    }
  })();
  if (fn == null) {
    return const [];
  }
  final key = _openConnectionsKey(readOnly: true);
  if (key == 0) {
    return const [];
  }
  final names = <String>[];
  try {
    for (var i = 0; i < 64; i++) {
      final nameBuf = _localAlloc!(_kLptr, 1024 * 2);
      final sizePtr = _localAlloc!(_kLptr, 4);
      if (nameBuf == 0 || sizePtr == 0) {
        _freeLocal(nameBuf);
        _freeLocal(sizePtr);
        break;
      }
      try {
        Pointer<Uint32>.fromAddress(sizePtr).value = 1024;
        final rc = fn(
          key,
          i,
          Pointer<Uint16>.fromAddress(nameBuf),
          Pointer<Uint32>.fromAddress(sizePtr),
          0,
          Pointer<Uint32>.fromAddress(0),
          Pointer<Uint8>.fromAddress(0),
          Pointer<Uint32>.fromAddress(0),
        );
        if (rc != 0) {
          break; 
        }
        final len = Pointer<Uint32>.fromAddress(sizePtr).value;
        final units = <int>[];
        for (var k = 0; k < len; k++) {
          final u = Pointer<Uint16>.fromAddress(nameBuf + k * 2).value;
          if (u == 0) {
            break;
          }
          units.add(u);
        }
        if (units.isNotEmpty) {
          names.add(String.fromCharCodes(units));
        }
      } finally {
        _freeLocal(nameBuf);
        _freeLocal(sizePtr);
      }
    }
  } finally {
    _regCloseKey?.call(key);
  }
  return names;
}
