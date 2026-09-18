# Mclash Windows 系统代理诊断（在 Windows 上以「运行 Mclash 的那个用户」打开 PowerShell 运行）
#
# 目的：一次把「App 写进去的值」和「Windows 界面读的那份数据」都摊开，
# 定位「注册表里明明有 127.0.0.1:端口、界面却空白」到底卡在哪一层。
#
# 用法：连接 Mclash 之后运行本脚本（只读 + 最后一步会重新广播一次设置变更）。

$ErrorActionPreference = 'SilentlyContinue'
$key  = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings'
$conn = "$key\Connections"

Write-Host '=== 0. 当前用户（必须和你看 Internet 选项的用户一致） ==='
whoami
Write-Host ("会话: " + (Get-Process -Id $PID).SessionId)

Write-Host ''
Write-Host '=== 1. 全局注册表值（App 写的就是这里） ==='
Get-ItemProperty $key | Select-Object ProxyEnable, ProxyServer, ProxyOverride, AutoConfigURL | Format-List

Write-Host '=== 2. 每连接缓存块（Internet 选项 / 设置→代理 读的是它） ==='
$p = Get-ItemProperty $conn
foreach ($n in @('DefaultConnectionSettings', 'SavedLegacySettings')) {
  $b = $p.$n
  if ($b) {
    $txt = -join ($b | ForEach-Object { if ($_ -ge 32 -and $_ -lt 127) { [char]$_ } else { '.' } })
    Write-Host ("{0} 长度={1}" -f $n, $b.Length)
    Write-Host ("  文本: {0}" -f $txt)
    Write-Host ("  十六进制: {0}" -f (($b | ForEach-Object { $_.ToString('x2') }) -join ''))
  }
  else {
    Write-Host "$n : (不存在)"
  }
}

Write-Host ''
Write-Host '=== 3. WinHTTP 代理（另一套存储，netsh 读的，与本问题无关但一并确认） ==='
netsh winhttp show proxy

Write-Host '=== 4. 组策略是否接管代理 ==='
Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\Internet Settings' |
  Select-Object ProxyEnable, ProxyServer, AutoConfigURL, ProxySettingsPerUser, CallLegacyWCMPolicies | Format-List
Write-Host '(ProxySettingsPerUser=0 表示「代理设置按机器存 HKLM」，那样写 HKCU 界面就不会显示)'

Write-Host ''
Write-Host '=== 5. 重新广播一次设置变更（等价于 Mclash 内部做的三步里的后两步） ==='
Add-Type -Namespace W -Name N -MemberDefinition @'
[DllImport("wininet.dll", SetLastError=true)] public static extern bool InternetSetOption(IntPtr h, int o, IntPtr b, int l);
[DllImport("user32.dll", SetLastError=true)] public static extern IntPtr SendMessageTimeout(IntPtr hWnd, uint Msg, UIntPtr wParam, string lParam, uint fuFlags, uint uTimeout, out UIntPtr lpdwResult);
'@
$r = [UIntPtr]::Zero
Write-Host ("InternetSetOption(SETTINGS_CHANGED=39) = " + [W.N]::InternetSetOption([IntPtr]::Zero, 39, [IntPtr]::Zero, 0))
Write-Host ("InternetSetOption(REFRESH=37)          = " + [W.N]::InternetSetOption([IntPtr]::Zero, 37, [IntPtr]::Zero, 0))
Write-Host ("SendMessageTimeout(WM_SETTINGCHANGE)   = " + [W.N]::SendMessageTimeout([IntPtr]0xffff, 0x001A, [UIntPtr]::Zero, 'InternetSettings', 2, 1000, [ref]$r))

Write-Host ''
Write-Host '现在把 Internet 选项（inetcpl.cpl → 连接 → 局域网设置）**关掉再重新打开**，看是否出现 127.0.0.1 + 端口。'
Write-Host '同时也把 设置 → 网络和 Internet → 代理 页面关掉重开看一眼。'
