# 抓「谁改了系统代理」的决定性方法：注册表审核 → 安全日志 4657 会直接写出进程名。
#
# **必须以管理员身份运行**（当前 DSH 会话不是提升权限，读不了 Security 日志、也设不了 SACL）。
#
# 用法（在某台机器上，管理员 PowerShell 里）：
#     pwsh -NoProfile -File tool\proxy_audit_who.ps1
#
# 它会：
#   1) 打开「审核对象访问 → 注册表」的成功审核；
#   2) 给 HKCU\...\Internet Settings 加一条 SACL：任何人 SetValue 都记一条 4657；
#   3) 挂起等待，一旦有人改 ProxyEnable/ProxyServer/ProxyOverride，立刻打印
#      「时间 + 进程名 + 进程路径 + 新值」。
#
# 注意：审核只对**开启之后**发生的改动有效，所以要让它常驻，等下次掉代理。

$ErrorActionPreference = 'Stop'

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
    ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Error "需要管理员权限：请用「以管理员身份运行」的 PowerShell 再执行一次。"
    exit 1
}

$keyPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings'

Write-Output "[1/3] 打开注册表审核（Registry 子类别，成功）…"
# {0CCE921E-69AE-11D9-BED3-505054503030} = Audit Registry
auditpol /set /subcategory:"{0CCE921E-69AE-11D9-BED3-505054503030}" /success:enable | Out-Null
auditpol /get /subcategory:"{0CCE921E-69AE-11D9-BED3-505054503030}"

Write-Output "[2/3] 给 $keyPath 加 SACL（Everyone / SetValue / Success）…"
$acl = Get-Acl -Path $keyPath -Audit
$rule = New-Object System.Security.AccessControl.RegistryAuditRule(
    'Everyone',
    [System.Security.AccessControl.RegistryRights]::SetValue,
    [System.Security.AccessControl.AuditFlags]::Success,
    [System.Security.AccessControl.InheritanceFlags]::None,
    [System.Security.AccessControl.PropagationFlags]::None)
$acl.AddAuditRule($rule)
Set-Acl -Path $keyPath -Audit $acl
Write-Output "     已设置。"

Write-Output "[3/3] 开始守候（Ctrl+C 结束）。任何对代理设置的写入都会被记下来："
Write-Output ""

$lastSeen = (Get-Date).AddSeconds(-5)
while ($true) {
    try {
        $events = Get-WinEvent -FilterHashtable @{
            LogName   = 'Security'
            Id        = 4657
            StartTime = $lastSeen
        } -ErrorAction SilentlyContinue
    } catch { $events = $null }

    foreach ($e in $events) {
        $msg = $e.Message
        if ($msg -notmatch 'Internet Settings') { continue }
        if ($msg -notmatch 'ProxyEnable|ProxyServer|ProxyOverride|AutoConfigURL') { continue }

        $proc = if ($msg -match '(?m)^\s*进程名称:\s*(.+)$') { $Matches[1].Trim() }
                elseif ($msg -match '(?m)^\s*Process Name:\s*(.+)$') { $Matches[1].Trim() }
                else { '?' }
        $obj = if ($msg -match '(?m)^\s*对象名称:\s*(.+)$') { $Matches[1].Trim() }
               elseif ($msg -match '(?m)^\s*Object Name:\s*(.+)$') { $Matches[1].Trim() }
               else { '?' }
        $val = if ($msg -match '(?m)^\s*值名称:\s*(.+)$') { $Matches[1].Trim() }
               elseif ($msg -match '(?m)^\s*Value Name:\s*(.+)$') { $Matches[1].Trim() }
               else { '?' }

        Write-Output ("[{0}] ★ 改代理的进程 = {1}`n        对象 = {2}`n        值   = {3}" -f `
            $e.TimeCreated.ToString('yyyy-MM-dd HH:mm:ss.fff'), $proc, $obj, $val)
        $lastSeen = $e.TimeCreated
    }
    Start-Sleep -Seconds 2
}
