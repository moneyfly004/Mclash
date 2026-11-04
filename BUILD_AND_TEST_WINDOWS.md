# Windows 构建和测试指南

## 前提条件

确保你的 Windows 虚拟机已安装：
- Flutter SDK (与 macOS 版本一致)
- Visual Studio 2019 或更高版本（包含 C++ 开发工具）
- Git

## 第 1 步：同步代码到 Windows 虚拟机

在 macOS 上推送代码：
```bash
cd /Users/apple/Downloads/Mclash
git push origin main
```

在 Windows 虚拟机上拉取代码：
```powershell
git pull origin main
```

或者直接复制整个项目目录到虚拟机。

## 第 2 步：准备内核文件

确保 Windows 版本的 `mihomo.exe` 内核文件存在。

### 方法 1：从现有构建复制
如果你之前构建过，内核应该在：
```
build/windows/x64/runner/Release/mihomo.exe
```

### 方法 2：下载最新内核
从 mihomo 官方 releases 下载 Windows 版本：
```powershell
# 下载到项目根目录
Invoke-WebRequest -Uri "https://github.com/MetaCubeX/mihomo/releases/latest/download/mihomo-windows-amd64.exe" -OutFile "mihomo.exe"
```

### 方法 3：检查是否已有内核
```powershell
# 在项目根目录执行
Get-ChildItem -Recurse -Filter "mihomo.exe" | Select-Object FullName
```

## 第 3 步：清理旧构建

```powershell
# 删除旧的构建缓存
flutter clean

# 可选：删除 build 目录
Remove-Item -Recurse -Force build -ErrorAction SilentlyContinue
```

##第 4 步：获取依赖

```powershell
flutter pub get
```

## 第 5 步：构建 Windows 版本

### Debug 版本（快速测试）
```powershell
flutter build windows --debug
```

### Release 版本（正式测试）
```powershell
flutter build windows --release
```

构建完成后，可执行文件位于：
```
build/windows/x64/runner/Release/mclash.exe
```

## 第 6 步：确认内核文件位置

构建后，确保 `mihomo.exe` 在正确位置：

```powershell
# 检查 Release 目录
Test-Path "build\windows\x64\runner\Release\mihomo.exe"
```

如果内核不存在，手动复制：
```powershell
Copy-Item "mihomo.exe" "build\windows\x64\runner\Release\mihomo.exe"
```

## 第 7 步：运行应用并测试

### 方式 1：直接运行
```powershell
cd build\windows\x64\runner\Release
.\mclash.exe
```

### 方式 2：使用 Flutter 运行
```powershell
flutter run -d windows
```

## 第 8 步：测试 TUN 模式

### 测试步骤：

1. **启动应用**（以普通用户身份，非管理员）

2. **配置 TUN 模式**
   - 进入设置
   - 启用 TUN 模式

3. **点击连接**
   - 观察是否有黑色窗口闪现 ❌
   - 应该弹出 UAC 授权对话框 ✅
   - 点击"是"授权

4. **验证连接成功**
   - 检查应用状态显示"已连接"
   - 打开浏览器测试网络是否正常

5. **检查日志**
   ```powershell
   # 查看应用数据目录的日志
   cd $env:APPDATA\mclash\mclash
   Get-Content kernel_log.txt -Tail 50
   ```

   期望看到类似：
   ```
   [mclash] Windows TUN：内核已通过 UAC 提权启动（观察者 PID=xxxx，内核 PID=yyyy）
   ```

6. **测试断开连接**
   - 点击"断开"按钮
   - 观察是否有黑色窗口闪现 ❌
   - 应该立即断开，无任何窗口

### 测试场景矩阵

| 场景 | 预期结果 |
|------|----------|
| **首次连接 TUN（无计划任务）** | 弹出 UAC → 无黑框 → 连接成功 |
| **已安装计划任务** | 无 UAC → 无黑框 → 连接成功 |
| **断开 TUN** | 无黑框 → 立即断开 |
| **非 TUN 模式（系统代理）** | 无 UAC → 无黑框 → 连接成功 |

## 第 9 步：查看生成的 VBS 文件

连接 TUN 后，检查生成的 VBS 脚本：

```powershell
cd $env:APPDATA\mclash\mclash
Get-Content kernel_uac.vbs
```

应该看到类似：
```vbscript
Set sh = CreateObject("Shell.Application")
Set fso = CreateObject("Scripting.FileSystemObject")
Set svc = GetObject("winmgmts:\\.\root\cimv2")
sh.ShellExecute "C:\...\mihomo.exe", "-d ... -f ...", "", "runas", 0
...
```

## 第 10 步：对比测试（可选）

如果你想对比修复前后的差异：

### 测试修复前的版本
```powershell
# 切换到修复前的提交
git checkout HEAD~1

# 重新构建
flutter clean
flutter build windows --release

# 运行并观察窗口闪现
```

### 测试修复后的版本
```powershell
# 切换回最新提交
git checkout main

# 重新构建
flutter clean
flutter build windows --release

# 运行并验证无窗口闪现
```

## 常见问题排查

### 问题 1：找不到 mihomo.exe

**解决方案**：
```powershell
# 下载最新内核
Invoke-WebRequest -Uri "https://github.com/MetaCubeX/mihomo/releases/latest/download/mihomo-windows-amd64.exe" -OutFile "build\windows\x64\runner\Release\mihomo.exe"
```

### 问题 2：UAC 无法弹出

**原因**：可能以管理员身份运行了应用

**解决方案**：以普通用户身份运行应用

### 问题 3：连接后立即断开

**原因**：内核启动失败

**排查步骤**：
```powershell
# 查看错误日志
Get-Content $env:APPDATA\mclash\mclash\kernel_stderr.txt
Get-Content $env:APPDATA\mclash\mclash\kernel_log.txt -Tail 100
```

### 问题 4：仍然看到黑色窗口

**排查步骤**：
1. 确认使用的是最新构建
2. 检查是否是其他进程（如安全软件）
3. 查看日志确认使用了正确的启动路径

## 性能对比

### 修复前（使用 PowerShell）
- 启动时间：~500ms
- 用户体验：看到黑框闪现 ❌
- 进程链：mclash.exe → powershell.exe → mihomo.exe

### 修复后（使用 wscript + VBS）
- 启动时间：~400ms
- 用户体验：完全无窗口 ✅
- 进程链：mclash.exe → wscript.exe → mihomo.exe

## 日志关键字

成功启动的日志标志：
```
[mclash] Windows TUN：内核已通过 UAC 提权启动（观察者 PID=xxxx，内核 PID=yyyy）
```

或（计划任务路径）：
```
[mclash] Windows TUN：内核由计划任务「Mclash Kernel」以最高权限启动（无需 UAC；观察者 PID=xxxx）
```

## 安装包构建（可选）

如果需要构建 Inno Setup 安装包：

```powershell
# 确保已安装 Inno Setup
# 运行安装脚本
iscc windows\packaging\mclash.iss
```

安装包会在 `windows\packaging\Output\` 目录生成。

## 视频录制建议

为了验证修复效果，建议录制屏幕视频：

1. **修复前**：显示连接 TUN 时的黑框闪现
2. **修复后**：显示连接 TUN 时完全无窗口
3. **对比**：并排显示修复前后的差异

录制工具推荐：
- Windows 自带：`Win + G` 游戏栏
- OBS Studio
- ScreenToGif（录制 GIF）

## 报告测试结果

测试完成后，请报告：

1. ✅ 连接 TUN 时是否还有黑框闪现？
2. ✅ UAC 对话框是否正常弹出？
3. ✅ TUN 连接是否成功？
4. ✅ 断开连接是否正常？
5. ✅ 日志中的启动路径是否正确？
6. 📸 截图或视频（可选）

## 下一步

测试通过后：
1. 创建新的 Release Tag
2. 更新 CHANGELOG
3. 构建并上传安装包到 GitHub Releases
