/// 生成「隐藏窗口启动内核」的 VBScript。
///
/// 为什么需要它：Windows 计划任务若直接执行 `mihomo.exe`（控制台程序），
/// 会弹出黑色控制台窗口；改用 `wscript.exe`（GUI 子系统）执行本脚本，
/// 由 `Shell.Run(..., 0, True)` 以隐藏窗口启动内核并等待其退出。
///
/// **引号规则（曾经写错、导致 TUN 计划任务整条路径失效）**：
/// VBScript 里要传一条「自身带引号的命令行」，必须把整条命令放进**一个**
/// 字符串，内部引号成对转义：
///
/// ```vbs
/// sh.Run """C:\...\mihomo.exe"" -d ""C:\..."" -f ""C:\...\config.yaml""", 0, True
/// ```
///
/// 曾经在每段路径两端都写三连引号，结果第一个字符串在 `-d` 之前就结束了，
/// `cscript //B` 直接返回 exit=1（Windows 11 虚拟机实测）。这里集中一处生成，
/// 并由单元测试锁住引号形状。
library;

/// '0' = 隐藏窗口；'True' = 等待内核退出（计划任务外壳进程与内核同生命周期）。
String buildKernelHostVbs({
  required String kernelPath,
  required String dataDir,
}) {
  // 先拼出真实命令行（不转义），再整体做一次 VBS 转义 —— 转义只做一次。
  final cmd = '"$kernelPath" -d "$dataDir" '
      '-f "$dataDir\\config.yaml"';
  // 整条命令作为一个 VBScript 字符串：外层一对引号 + 内部引号成对转义。
  final literal = '"${cmd.replaceAll('"', '""')}"';
  return 'Set sh = CreateObject("WScript.Shell")\r\n'
      'sh.Run $literal, 0, True\r\n';
}

/// 观察者脚本：触发计划任务 → 等内核出现并记下 PID → 等内核消失。
///
/// App 用它感知「内核何时退出」（`_proc.exitCode`）。同样必须是 GUI 子系统
/// 程序执行，否则会出现控制台窗口。
String buildKernelWatchVbs({
  required String taskName,
  required String pidFilePath,
}) {
  return 'Set sh = CreateObject("WScript.Shell")\r\n'
      'Set fso = CreateObject("Scripting.FileSystemObject")\r\n'
      'sh.Run "schtasks /run /tn ""${_esc(taskName)}""", 0, False\r\n'
      'Dim svc, procs, seen, pid\r\n'
      'seen = False\r\n'
      'Set svc = GetObject("winmgmts:\\\\.\\root\\cimv2")\r\n'
      'For i = 1 To 300\r\n'
      '  Set procs = svc.ExecQuery("SELECT ProcessId FROM Win32_Process '
      "WHERE Name='mihomo.exe'\")\r\n"
      '  If procs.Count > 0 Then\r\n'
      '    For Each pe In procs\r\n'
      '      pid = pe.ProcessId\r\n'
      '      Exit For\r\n'
      '    Next\r\n'
      '    seen = True\r\n'
      '    Exit For\r\n'
      '  End If\r\n'
      '  WScript.Sleep 200\r\n'
      'Next\r\n'
      'If seen Then\r\n'
      '  On Error Resume Next\r\n'
      '  fso.OpenTextFile("${_esc(pidFilePath)}", 2, True).Write CStr(pid)\r\n'
      '  Do\r\n'
      '    Set procs = svc.ExecQuery("SELECT ProcessId FROM Win32_Process '
      "WHERE Name='mihomo.exe'\")\r\n"
      '    If procs.Count = 0 Then Exit Do\r\n'
      '    WScript.Sleep 500\r\n'
      '  Loop\r\n'
      'End If\r\n';
}

/// VBScript 字符串内的双引号转义。
String _esc(String v) => v.replaceAll('"', '""');
