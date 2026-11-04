# Windows TUN 窗口闪现修复 - 快速测试脚本
# 在 Windows PowerShell 中运行

Write-Host "================================" -ForegroundColor Cyan
Write-Host "Mclash TUN 窗口闪现修复测试脚本" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""

# 检查 Flutter
Write-Host "[1/8] 检查 Flutter 环境..." -ForegroundColor Yellow
try {
    $flutterVersion = flutter --version 2>&1 | Select-String "Flutter" | Select-Object -First 1
    Write-Host "✓ Flutter 已安装: $flutterVersion" -ForegroundColor Green
} catch {
    Write-Host "✗ Flutter 未安装或未添加到 PATH" -ForegroundColor Red
    exit 1
}

# 检查 Git 状态
Write-Host "`n[2/8] 检查 Git 状态..." -ForegroundColor Yellow
$gitBranch = git branch --show-current 2>$null
if ($gitBranch -eq "main") {
    $gitHash = git rev-parse --short HEAD
    Write-Host "✓ 当前分支: $gitBranch ($gitHash)" -ForegroundColor Green
} else {
    Write-Host "⚠ 当前分支: $gitBranch (建议切换到 main)" -ForegroundColor Yellow
}

# 检查最新提交
$latestCommit = git log -1 --oneline 2>$null
Write-Host "✓ 最新提交: $latestCommit" -ForegroundColor Green

# 检查是否有修复提交
$fixCommit = git log --all --grep="彻底消除 TUN 模式所有 PowerShell 窗口闪现" --oneline 2>$null
if ($fixCommit) {
    Write-Host "✓ 已找到修复提交" -ForegroundColor Green
} else {
    Write-Host "⚠ 未找到修复提交，可能需要拉取最新代码" -ForegroundColor Yellow
}

# 检查内核文件
Write-Host "`n[3/8] 检查 mihomo 内核..." -ForegroundColor Yellow
$kernelLocations = @(
    "mihomo.exe",
    "build\windows\x64\runner\Release\mihomo.exe",
    "build\windows\x64\runner\Debug\mihomo.exe"
)

$kernelFound = $false
foreach ($loc in $kernelLocations) {
    if (Test-Path $loc) {
        $kernelSize = (Get-Item $loc).Length / 1MB
        Write-Host "✓ 找到内核: $loc (${kernelSize:N2} MB)" -ForegroundColor Green
        $kernelFound = $true
        break
    }
}

if (-not $kernelFound) {
    Write-Host "✗ 未找到 mihomo.exe 内核文件" -ForegroundColor Red
    Write-Host "请从以下地址下载:" -ForegroundColor Yellow
    Write-Host "https://github.com/MetaCubeX/mihomo/releases/latest" -ForegroundColor Cyan

    $download = Read-Host "`n是否现在下载? (y/n)"
    if ($download -eq "y") {
        Write-Host "正在下载..." -ForegroundColor Yellow
        try {
            Invoke-WebRequest -Uri "https://github.com/MetaCubeX/mihomo/releases/latest/download/mihomo-windows-amd64.exe" -OutFile "mihomo.exe"
            Write-Host "✓ 下载完成" -ForegroundColor Green
            $kernelFound = $true
        } catch {
            Write-Host "✗ 下载失败: $_" -ForegroundColor Red
            exit 1
        }
    } else {
        exit 1
    }
}

# 清理旧构建
Write-Host "`n[4/8] 清理旧构建..." -ForegroundColor Yellow
$clean = Read-Host "是否执行 flutter clean? (y/n)"
if ($clean -eq "y") {
    flutter clean
    Write-Host "✓ 清理完成" -ForegroundColor Green
}

# 获取依赖
Write-Host "`n[5/8] 获取依赖..." -ForegroundColor Yellow
flutter pub get
if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ 依赖获取成功" -ForegroundColor Green
} else {
    Write-Host "✗ 依赖获取失败" -ForegroundColor Red
    exit 1
}

# 构建应用
Write-Host "`n[6/8] 构建应用..." -ForegroundColor Yellow
Write-Host "选择构建模式:" -ForegroundColor Cyan
Write-Host "  1) Debug (快速，适合测试)"
Write-Host "  2) Release (完整优化)"
$buildMode = Read-Host "请选择 (1/2)"

if ($buildMode -eq "1") {
    Write-Host "正在构建 Debug 版本..." -ForegroundColor Yellow
    flutter build windows --debug
} else {
    Write-Host "正在构建 Release 版本..." -ForegroundColor Yellow
    flutter build windows --release
}

if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ 构建成功" -ForegroundColor Green
} else {
    Write-Host "✗ 构建失败" -ForegroundColor Red
    exit 1
}

# 复制内核到构建目录
Write-Host "`n[7/8] 复制内核文件..." -ForegroundColor Yellow
$buildDir = if ($buildMode -eq "1") { "Debug" } else { "Release" }
$targetPath = "build\windows\x64\runner\$buildDir\mihomo.exe"

if (Test-Path "mihomo.exe") {
    Copy-Item "mihomo.exe" $targetPath -Force
    Write-Host "✓ 内核已复制到构建目录" -ForegroundColor Green
} elseif (-not (Test-Path $targetPath)) {
    Write-Host "⚠ 构建目录中没有内核文件" -ForegroundColor Yellow
    Write-Host "请手动复制 mihomo.exe 到: $targetPath" -ForegroundColor Yellow
}

# 检查构建输出
Write-Host "`n[8/8] 验证构建输出..." -ForegroundColor Yellow
$exePath = "build\windows\x64\runner\$buildDir\mclash.exe"
if (Test-Path $exePath) {
    $exeSize = (Get-Item $exePath).Length / 1MB
    Write-Host "✓ 应用程序: $exePath (${exeSize:N2} MB)" -ForegroundColor Green
} else {
    Write-Host "✗ 未找到可执行文件: $exePath" -ForegroundColor Red
    exit 1
}

if (Test-Path $targetPath) {
    $kernelSize = (Get-Item $targetPath).Length / 1MB
    Write-Host "✓ 内核文件: $targetPath (${kernelSize:N2} MB)" -ForegroundColor Green
} else {
    Write-Host "✗ 未找到内核文件: $targetPath" -ForegroundColor Red
}

# 测试说明
Write-Host "`n================================" -ForegroundColor Cyan
Write-Host "✓ 构建完成！开始测试" -ForegroundColor Green
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "测试步骤:" -ForegroundColor Yellow
Write-Host "  1. 以普通用户身份运行应用（不要以管理员运行）"
Write-Host "  2. 进入设置，启用 TUN 模式"
Write-Host "  3. 点击「连接」按钮"
Write-Host "  4. 观察是否有黑色窗口闪现 ❌"
Write-Host "  5. UAC 对话框应该正常弹出 ✅"
Write-Host "  6. 授权后，检查连接是否成功 ✅"
Write-Host "  7. 点击「断开」按钮"
Write-Host "  8. 观察是否有黑色窗口闪现 ❌"
Write-Host ""
Write-Host "期望结果:" -ForegroundColor Yellow
Write-Host "  ✓ 无黑色窗口闪现"
Write-Host "  ✓ UAC 正常弹出"
Write-Host "  ✓ TUN 连接成功"
Write-Host "  ✓ 断开正常"
Write-Host ""

# 询问是否立即运行
$run = Read-Host "是否立即运行应用? (y/n)"
if ($run -eq "y") {
    Write-Host "`n正在启动应用..." -ForegroundColor Yellow
    Set-Location "build\windows\x64\runner\$buildDir"
    Start-Process "mclash.exe"
    Write-Host "✓ 应用已启动" -ForegroundColor Green
    Write-Host ""
    Write-Host "提示: 应用数据目录位于:" -ForegroundColor Cyan
    Write-Host "  $env:APPDATA\mclash\mclash" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "日志文件:" -ForegroundColor Cyan
    Write-Host "  kernel_log.txt - 内核运行日志" -ForegroundColor Cyan
    Write-Host "  kernel_stderr.txt - 内核错误日志" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "VBS 脚本（连接后生成）:" -ForegroundColor Cyan
    Write-Host "  kernel_uac.vbs - UAC 提权启动脚本" -ForegroundColor Cyan
    Write-Host "  kill_kernel.vbs - UAC 提权停止脚本" -ForegroundColor Cyan
} else {
    Write-Host "`n手动运行命令:" -ForegroundColor Cyan
    Write-Host "  cd build\windows\x64\runner\$buildDir" -ForegroundColor Yellow
    Write-Host "  .\mclash.exe" -ForegroundColor Yellow
}

Write-Host "`n================================" -ForegroundColor Cyan
Write-Host "测试完成后请报告结果" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
