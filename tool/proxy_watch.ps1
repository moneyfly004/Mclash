# 系统代理「谁改的」现场监视器
#
# 背景：Mclash 的旧版看守只比对 ProxyServer 字符串，对「地址没变、只把 ProxyEnable
# 置 0」这种改动完全无感（真机报障）。要查是谁干的，必须在改动发生的那一秒抓现场。
#
# 本脚本每 1 秒读一次 HKCU\...\Internet Settings，一旦发现状态变化就把「变化前后 +
# 当时谁在动（新起的进程、刚消耗过 CPU 的进程、最近事件日志）」写进
# tool\proxy_watch.log，供事后比对。
#
# 用法：pwsh -NoProfile -File tool\proxy_watch.ps1     （建议后台常驻）

$ErrorActionPreference = 'Continue'
$Key   = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings'
$Conns = "$Key\Connections"
$Log   = Join-Path $PSScriptRoot 'proxy_watch.log'

function Read-State {
    $o = [ordered]@{}
    try {
        $p = Get-ItemProperty -Path $Key -ErrorAction Stop
        $o.ProxyEnable = [string]$p.ProxyEnable
        $o.ProxyServer = [string]$p.ProxyServer
        $o.ProxyOverride = [string]$p.ProxyOverride
        $o.AutoConfigURL = [string]$p.AutoConfigURL
        $o.Owner = [string]$p.MclashProxyOwner
    } catch {
        $o.ProxyEnable = 'ERR'; $o.ProxyServer = 'ERR'; $o.ProxyOverride = 'ERR'
        $o.AutoConfigURL = 'ERR'; $o.Owner = 'ERR'
    }
    try {
        $b = (Get-ItemProperty -Path $Conns -ErrorAction Stop).DefaultConnectionSettings
        if ($null -ne $b -and $b.Length -ge 16) {
            $o.BlobFlags = $b[8] -bor ($b[9] -shl 8) -bor ($b[10] -shl 16) -bor ($b[11] -shl 24)
            $len = $b[12] -bor ($b[13] -shl 8) -bor ($b[14] -shl 16) -bor ($b[15] -shl 24)
            $o.BlobServer = if ($len -gt 0 -and (16 + $len) -le $b.Length) {
                [System.Text.Encoding]::UTF8.GetString($b, 16, $len)
            } else { '' }
        } else { $o.BlobFlags = -1; $o.BlobServer = '' }
    } catch { $o.BlobFlags = -1; $o.BlobServer = '' }
    return $o
}

function State-Sig($s) { "$($s.ProxyEnable)|$($s.ProxyServer)|$($s.BlobFlags)|$($s.BlobServer)" }

function Write-Log($text) {
    $line = "[{0}] {1}" -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss.fff'), $text
    Add-Content -Path $Log -Value $line -Encoding UTF8
    Write-Output $line
}

function Cpu-Snapshot {
    $h = @{}
    foreach ($p in (Get-Process -ErrorAction SilentlyContinue)) {
        try { $h[$p.Id] = [double]$p.TotalProcessorTime.TotalMilliseconds } catch {}
    }
    return $h
}

Write-Log "=== 监视启动 pid=$PID，目标 $Key ==="
$prevState = Read-State
$prevSig = State-Sig $prevState
Write-Log ("初始状态: " + ($prevState | ConvertTo-Json -Compress))

$prevCpu = Cpu-Snapshot
$lastBeat = Get-Date
$ticksSinceChange = 0

while ($true) {
    Start-Sleep -Seconds 1
    $ticksSinceChange++

    $cur = Read-State
    $sig = State-Sig $cur

    $now = Get-Date
    if (($now - $lastBeat).TotalSeconds -ge 300) {
        Write-Log ("心跳: " + ($cur | ConvertTo-Json -Compress))
        $lastBeat = $now
    }

    if ($sig -ne $prevSig) {
        $cpuNow = Cpu-Snapshot
        Write-Log "########## 检测到系统代理变化 ##########"
        Write-Log ("  旧: " + ($prevState | ConvertTo-Json -Compress))
        Write-Log ("  新: " + ($cur | ConvertTo-Json -Compress))

        # 1) 最近 5 分钟内新起的进程（最可能是刚刚动手的那个）
        $started = @()
        foreach ($p in (Get-Process -ErrorAction SilentlyContinue)) {
            try {
                $st = $p.StartTime
                if (($now - $st).TotalSeconds -le 300) {
                    $started += ("{0} pid={1} start={2}" -f $p.ProcessName, $p.Id, $st.ToString('HH:mm:ss'))
                }
            } catch {}
        }
        Write-Log ("  近 5 分钟新起进程: " + (($started | Select-Object -Unique) -join ' ; '))

        # 2) 这 1 秒里消耗过 CPU 的进程（改注册表的那一下必然要占一点 CPU）
        $busy = @()
        foreach ($k in $cpuNow.Keys) {
            if ($prevCpu.ContainsKey($k)) {
                $d = $cpuNow[$k] - $prevCpu[$k]
                if ($d -gt 0) {
                    $n = try { (Get-Process -Id $k -ErrorAction Stop).ProcessName } catch { '?' }
                    $busy += ("{0}({1}) +{2:N0}ms" -f $n, $k, $d)
                }
            } else {
                $n = try { (Get-Process -Id $k -ErrorAction Stop).ProcessName } catch { '?' }
                $busy += ("{0}({1}) NEW" -f $n, $k)
            }
        }
        Write-Log ("  该秒内消耗 CPU: " + (($busy | Sort-Object -Unique) -join ' ; '))

        # 3) 最近事件日志
        try {
            $ev = Get-WinEvent -FilterHashtable @{LogName='System'; StartTime=$now.AddMinutes(-10)} -MaxEvents 8 -ErrorAction SilentlyContinue
            if ($ev) { Write-Log ("  近 10 分钟 System 事件: " + (($ev | ForEach-Object { $_.Id.ToString() + '@' + $_.TimeCreated.ToString('HH:mm:ss') }) -join ' ')) }
        } catch {}
        try {
            $ev2 = Get-WinEvent -FilterHashtable @{LogName='Application'; StartTime=$now.AddMinutes(-10)} -MaxEvents 8 -ErrorAction SilentlyContinue
            if ($ev2) { Write-Log ("  近 10 分钟 Application 事件: " + (($ev2 | ForEach-Object { $_.ProviderName + '#' + $_.Id + '@' + $_.TimeCreated.ToString('HH:mm:ss') }) -join ' | ')) }
        } catch {}

        Write-Log "#######################################"
        $prevState = $cur
        $prevSig = $sig
    }

    $prevCpu = Cpu-Snapshot
}
