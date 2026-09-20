library;

import 'dart:ffi';
import 'dart:io';

typedef _CreateJobObjectNative = IntPtr Function(IntPtr lpJobAttributes, IntPtr lpName);
typedef _CreateJobObjectDart = int Function(int lpJobAttributes, int lpName);

typedef _SetInformationJobObjectNative = Int32 Function(
  IntPtr hJob,
  Int32 jobObjectInformationClass,
  IntPtr lpJobObjectInformation,
  Int32 cbJobObjectInformationLength,
);
typedef _SetInformationJobObjectDart = int Function(
  int hJob,
  int jobObjectInformationClass,
  int lpJobObjectInformation,
  int cbJobObjectInformationLength,
);

typedef _OpenProcessNative = IntPtr Function(Int32 access, Int32 inherit, Int32 pid);
typedef _OpenProcessDart = int Function(int access, int inherit, int pid);

typedef _AssignProcessToJobObjectNative = Int32 Function(IntPtr hJob, IntPtr hProcess);
typedef _AssignProcessToJobObjectDart = int Function(int hJob, int hProcess);

typedef _CloseHandleNative = Int32 Function(IntPtr hObject);
typedef _CloseHandleDart = int Function(int hObject);

typedef _LocalAllocNative = IntPtr Function(Uint32 uFlags, IntPtr uBytes);
typedef _LocalAllocDart = int Function(int uFlags, int uBytes);

typedef _LocalFreeNative = IntPtr Function(IntPtr hMem);
typedef _LocalFreeDart = int Function(int hMem);

const int _kLptr = 0x0040;

const int _kJobObjectExtendedLimitInformation = 9;

const int _kJobObjectLimitKillOnJobClose = 0x00002000;

const int _kProcessSetQuota = 0x0100;
const int _kProcessTerminate = 0x0001;

const int _kExtendedLimitInfoSize = 144;
const int _kLimitFlagsOffset = 16;

_CreateJobObjectDart? _createJobObject;
_SetInformationJobObjectDart? _setInformationJobObject;
_OpenProcessDart? _openProcess;
_AssignProcessToJobObjectDart? _assignProcessToJobObject;
_CloseHandleDart? _closeHandle;
_LocalAllocDart? _localAlloc;
_LocalFreeDart? _localFree;
bool _loadFailed = false;

int _jobHandle = 0;

bool _load() {
  if (_createJobObject != null) {
    return true;
  }
  if (_loadFailed || !Platform.isWindows) {
    return false;
  }
  try {
    final lib = DynamicLibrary.open('kernel32.dll');
    _createJobObject = lib.lookupFunction<_CreateJobObjectNative, _CreateJobObjectDart>(
      'CreateJobObjectW',
    );
    _setInformationJobObject =
        lib.lookupFunction<_SetInformationJobObjectNative, _SetInformationJobObjectDart>(
          'SetInformationJobObject',
        );
    _openProcess = lib.lookupFunction<_OpenProcessNative, _OpenProcessDart>('OpenProcess');
    _assignProcessToJobObject =
        lib.lookupFunction<_AssignProcessToJobObjectNative, _AssignProcessToJobObjectDart>(
          'AssignProcessToJobObject',
        );
    _closeHandle = lib.lookupFunction<_CloseHandleNative, _CloseHandleDart>('CloseHandle');
    _localAlloc = lib.lookupFunction<_LocalAllocNative, _LocalAllocDart>('LocalAlloc');
    _localFree = lib.lookupFunction<_LocalFreeNative, _LocalFreeDart>('LocalFree');
    return true;
  } catch (_) {
    _loadFailed = true;
    return false;
  }
}

int _ensureJob() {
  if (_jobHandle != 0) {
    return _jobHandle;
  }
  if (!_load()) {
    return 0;
  }
  final job = _createJobObject!(0, 0);
  if (job == 0) {
    return 0;
  }
  final info = _localAlloc!(_kLptr, _kExtendedLimitInfoSize);
  if (info == 0) {
    _closeHandle?.call(job);
    return 0;
  }
  try {
    Pointer<Uint32>.fromAddress(
      info + _kLimitFlagsOffset,
    ).value = _kJobObjectLimitKillOnJobClose;
    final ok = _setInformationJobObject!(
      job,
      _kJobObjectExtendedLimitInformation,
      info,
      _kExtendedLimitInfoSize,
    );
    if (ok == 0) {
      _closeHandle?.call(job);
      return 0;
    }
  } finally {
    _localFree?.call(info);
  }
  _jobHandle = job;
  return job;
}

bool assignToKillOnCloseJob(int pid) {
  if (pid <= 0) {
    return false;
  }
  final job = _ensureJob();
  if (job == 0) {
    return false;
  }
  final h = _openProcess!(_kProcessSetQuota | _kProcessTerminate, 0, pid);
  if (h == 0) {
    return false;
  }
  try {
    return _assignProcessToJobObject!(job, h) != 0;
  } finally {
    _closeHandle?.call(h);
  }
}
