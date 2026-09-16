/// Windows：让内核进程**随 App 一起死**。
///
/// 真实用户问题（已实测复现）：直接结束 `mclash.exe`（任务管理器结束任务、
/// 崩溃、被安装程序强杀、`taskkill /F`）时，子进程 `mihomo.exe` **不会**
/// 跟着退出 —— Windows 没有「父进程死了子进程也死」的语义，于是内核继续跑、
/// 系统代理继续指向它、网还能上，用户看到的就是
/// 「退出软件了，内核还在运行」。
///
/// 正常退出路径（托盘 → 退出 → `_stopInternal()` → `taskkill /T /F`）是能杀掉的，
/// 但任何一次非正常退出都会留下孤儿内核，而旧实现里本该在启动时清理孤儿的
/// `killStaleKernels()` 从来没有被调用过（死代码），于是孤儿会一直活下去。
///
/// 这里用 Windows 官方的 Job Object 从根上解决：
///   * `CreateJobObjectW`
///   * `SetInformationJobObject(JobObjectExtendedLimitInformation,
///     JOB_OBJECT_LIMIT_KILL_ON_JOB_CLOSE)`
///   * `AssignProcessToJobObject(job, OpenProcess(pid))`
///
/// Job 的最后一个句柄关闭 = App 进程消失（无论怎么消失），内核态立刻终止
/// Job 内所有进程。句柄故意不关闭，随进程一起释放。
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

/// `LPTR` = LMEM_FIXED | LMEM_ZEROINIT：固定内存且清零。
const int _kLptr = 0x0040;

const int _kJobObjectExtendedLimitInformation = 9;

/// `JOB_OBJECT_LIMIT_KILL_ON_JOB_CLOSE`
const int _kJobObjectLimitKillOnJobClose = 0x00002000;

/// `PROCESS_SET_QUOTA | PROCESS_TERMINATE`（把进程加入 Job 所需的最小权限）
const int _kProcessSetQuota = 0x0100;
const int _kProcessTerminate = 0x0001;

/// `JOBOBJECT_EXTENDED_LIMIT_INFORMATION` 在 x64 上是 144 字节，
/// `BasicLimitInformation.LimitFlags` 位于偏移 16 —— 只需要写这一个 DWORD，
/// 其余保持 0。
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

/// 进程级单例 Job：**故意不关闭句柄**，进程退出时由系统回收，
/// 那一刻 Job 内所有进程（内核）被强制结束。
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

/// 创建（或复用）"App 退出即终止" 的 Job 对象；失败返回 0。
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
  // 只用 kernel32 的 LocalAlloc，避免为了一个 144 字节的缓冲区引入 package:ffi。
  final info = _localAlloc!(_kLptr, _kExtendedLimitInfoSize);
  if (info == 0) {
    _closeHandle?.call(job);
    return 0;
  }
  try {
    // LimitFlags 在 JOBOBJECT_BASIC_LIMIT_INFORMATION 中，
    // 前面是两个 LARGE_INTEGER → 偏移 16。
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

/// 把 [pid] 加入「App 退出即终止」的 Job。返回是否成功（失败不影响主流程，
/// 只是退回到「退出时显式 taskkill」这条老路）。
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
