# Windows TUN 模式窗口闪现问题修复

## 问题分析

### 根本原因
Windows TUN 模式启动时出现 PowerShell 窗口一闪而逝的问题，根源在于：

**PowerShell 是控制台子系统程序**，即使使用 `-WindowStyle Hidden` 参数，也会：
1. 先创建一个控制台窗口
2. 再隐藏这个窗口

这个"创建→隐藏"的过程会被用户看到，表现为黑色窗口一闪而逝。

### 代码位置
问题出现在两个地方：

1. **启动内核（UAC 提权路径）** - `packages/libclash_vpn_service/lib/src/desktop_impl.dart:561-577`
   - 使用 PowerShell 调用 `Start-Process -Verb RunAs` 提权启动内核

2. **停止内核（UAC 提权进程）** - `packages/libclash_vpn_service/lib/src/desktop_impl.dart:1095-1105`
   - 使用 PowerShell 调用 `Start-Process -Verb RunAs` 提权杀掉内核进程

## 解决方案

### 核心思路
将所有 PowerShell 调用改为 **wscript.exe + VBScript**：

- **wscript.exe 是 GUI 子系统程序**，完全不创建控制台窗口
- VBScript 中使用 `Shell.Application` 的 `ShellExecute` 方法触发 UAC 提权
- 效果等同于 PowerShell 的 `Start-Process -Verb RunAs`，但无任何窗口

### 修改详情

#### 1. 启动内核（UAC 提权路径）

**修改前**（使用 PowerShell）：
```dart
String q(String v) => "'${v.replaceAll("'", "''")}'";
final argList = execArgs.map(q).join(",");
final ps = "\$p = Start-Process -FilePath ${q(kernel)} "
    "-ArgumentList @($argList) -Verb RunAs -PassThru -WindowStyle Hidden; "
    "\$p.Id | Out-File -FilePath ${q(pidFile)} -Encoding ascii; "
    "\$p.WaitForExit()";
proc = await Process.start(
  "powershell",
  ["-NoProfile", "-NonInteractive", "-WindowStyle", "Hidden", "-Command", ps],
  ...
);
```

**修改后**（使用 wscript + VBS）：
```dart
final vbsPath = p.join(workDir, "kernel_uac.vbs");
String vbsEscape(String s) => s.replaceAll('"', '""');
final args = execArgs.join('" "');
final vbs = 'Set sh = CreateObject("Shell.Application")\r\n'
    'Set fso = CreateObject("Scripting.FileSystemObject")\r\n'
    'Set svc = GetObject("winmgmts:\\\\.\\root\\cimv2")\r\n'
    'sh.ShellExecute "${vbsEscape(kernel)}", "${vbsEscape(args)}", "", "runas", 0\r\n'
    '... (等待进程并记录PID)\r\n';
await File(vbsPath).writeAsString(vbs, flush: true);
proc = await Process.start("wscript.exe", [vbsPath], ...);
```

#### 2. 停止内核（UAC 提权进程）

**修改前**（使用 PowerShell）：
```dart
await Process.run("powershell", [
  "-NoProfile",
  "-NonInteractive",
  "-WindowStyle",
  "Hidden",
  "-Command",
  "Start-Process -FilePath 'taskkill' -ArgumentList "
      "'/PID $_uacKernelPid /T /F' -Verb RunAs -Wait -WindowStyle Hidden",
]);
```

**修改后**（使用 wscript + VBS）：
```dart
final cfg = _config;
if (cfg != null && cfg.work_dir.isNotEmpty) {
  final vbsPath = p.join(cfg.work_dir, "kill_kernel.vbs");
  final vbs = 'Set sh = CreateObject("Shell.Application")\r\n'
      'sh.ShellExecute "taskkill", "/PID $_uacKernelPid /T /F", "", "runas", 0\r\n';
  await File(vbsPath).writeAsString(vbs, flush: true);
  await Process.run("wscript.exe", [vbsPath]);
}
```

#### 3. 优化 kernelTaskExists() 检查

**修改前**（调用 schtasks.exe，会闪黑框）：
```dart
final r = await Process.run("schtasks", [
  "/query",
  "/tn",
  kKernelTaskName,
]).timeout(const Duration(seconds: 5));
return r.exitCode == 0;
```

**修改后**（纯文件检查，零进程）：
```dart
final appData = Platform.environment["APPDATA"] ?? "";
if (appData.isEmpty) {
  return false;
}
return File("$appData\\mclash\\mclash\\kernel_host.vbs").existsSync();
```

## VBScript 详解

### 启动内核的 VBS 逻辑

```vbscript
Set sh = CreateObject("Shell.Application")
Set fso = CreateObject("Scripting.FileSystemObject")
Set svc = GetObject("winmgmts:\\.\\root\\cimv2")

' 使用 runas verb 触发 UAC 提权，0 = 隐藏窗口
sh.ShellExecute "mihomo.exe", "-d workDir -f config.yaml", "", "runas", 0

' 等待内核进程出现
WScript.Sleep 500
For i = 1 To 100
  Set procs = svc.ExecQuery("SELECT ProcessId,CommandLine FROM Win32_Process WHERE Name='mihomo.exe'")
  For Each pe In procs
    If InStr(pe.CommandLine, "workDir") > 0 Then
      pid = pe.ProcessId
      seen = True
      Exit For
    End If
  Next
  If seen Then Exit For
  WScript.Sleep 100
Next

' 记录 PID 到文件
If seen Then
  fso.OpenTextFile("kernel.pid", 2, True).Write CStr(pid)
  ' 观察内核进程，直到退出
  Do
    Set procs = svc.ExecQuery("SELECT ProcessId FROM Win32_Process WHERE ProcessId=" & pid)
    If procs.Count = 0 Then Exit Do
    WScript.Sleep 500
  Loop
End If
```

### 停止内核的 VBS 逻辑

```vbscript
Set sh = CreateObject("Shell.Application")
' 使用 runas verb 提权执行 taskkill
sh.ShellExecute "taskkill", "/PID 12345 /T /F", "", "runas", 0
```

## 验证方法

### 在 Windows 上测试

1. **构建发布版本**：
   ```bash
   flutter build windows --release
   ```

2. **检查内核文件**：
   确保 `mihomo.exe` 存在于构建输出目录：
   ```
   build/windows/x64/runner/Release/mihomo.exe
   ```

3. **测试 TUN 模式**：
   - 启动应用（非管理员权限）
   - 点击连接，选择 TUN 模式
   - 观察是否有黑色窗口闪现
   - 检查是否弹出 UAC 提权对话框（正常行为）
   - UAC 授权后，应该没有任何窗口闪现

4. **测试断开连接**：
   - 点击断开
   - 观察是否有黑色窗口闪现

### 日志验证

查看日志确认使用了正确的启动路径：

**期望看到**：
```
[mclash] Windows TUN：内核已通过 UAC 提权启动（观察者 PID=xxxx，内核 PID=yyyy）
```

而不是：
```
[mclash] Windows TUN：内核已通过 UAC 提权启动（外壳 PID=xxxx，内核 PID=yyyy）
```

## 技术细节

### 为什么计划任务路径不会闪窗口？

计划任务路径（`useTask = true`）早已使用 wscript + VBS：
```dart
proc = await Process.start("wscript.exe", [vbsPath], ...);
```

所以当 `kernel_host.vbs` 存在时（安装时创建），不会有窗口闪现。

### 为什么 UAC 路径会闪窗口？

UAC 提权路径（`useUac = true`）之前使用 PowerShell：
```dart
proc = await Process.start("powershell", [...], ...);
```

这就是窗口闪现的根源。

### 为什么不所有场景都用计划任务？

- **计划任务需要安装时创建**（需要一次性 UAC 授权）
- **老版本升级上来的用户可能没有计划任务**
- **UAC 路径是兜底方案**，确保即使没有计划任务也能用 TUN

## 其他 PowerShell 使用场景

项目中还有两处 PowerShell 调用，但它们不会影响 TUN 连接体验：

1. **安装计划任务** (`vpn_service.dart:1090`) - 只在首次安装时执行一次
2. **以管理员身份重启** (`vpn_service.dart:1174`) - 用户主动点击"提权"按钮时才执行

这两处可以保留，因为不会在每次 TUN 连接时触发。

## 总结

**修改的核心原则**：
- ❌ 不要使用 PowerShell（控制台程序，会闪黑框）
- ✅ 使用 wscript.exe + VBScript（GUI 程序，完全无窗口）
- ✅ VBS 中用 `Shell.Application.ShellExecute(..., "runas", 0)` 触发 UAC

**影响范围**：
- ✅ Windows TUN 模式启动（UAC 提权）
- ✅ Windows TUN 模式停止（UAC 提权）
- ✅ 计划任务检查（改为纯文件判断）

**预期效果**：
- ✅ TUN 连接时不再有黑色窗口一闪而逝
- ✅ UAC 对话框仍然正常弹出（这是预期行为）
- ✅ 内核启动和停止功能完全正常
