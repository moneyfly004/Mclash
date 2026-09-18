# 验证「局域网设置」对话框读的那份数据到底对不对（在连接 Mclash 之后运行）
# 用法：右键「用 PowerShell 运行」，或：
#   powershell -ExecutionPolicy Bypass -File windows_proxy_check.ps1
#
# 它不修改任何东西，只读并打印三层数据：
#   ① 全局注册表（ProxyEnable / ProxyServer）
#   ② DefaultConnectionSettings 的完整十六进制（界面真正读的二进制）
#   ③ 用 .NET 调 InternetQueryOption 读回「当前连接」的 flags + 服务器

$ErrorActionPreference = 'SilentlyContinue'
$key = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings'

Write-Host '=== ① 全局注册表 ==='
Get-ItemProperty $key | Select-Object ProxyEnable, ProxyServer, ProxyOverride | Format-List

Write-Host '=== ② DefaultConnectionSettings 完整 hex ==='
$conn = Get-ItemProperty "$key\Connections"
foreach ($n in @('DefaultConnectionSettings', 'SavedLegacySettings')) {
  $b = $conn.$n
  if ($b) {
    Write-Host ("{0} ({1} 字节):" -f $n, $b.Length)
    Write-Host (($b | ForEach-Object { $_.ToString('x2') }) -join '')
  } else {
    Write-Host "$n : (不存在)"
  }
}

Write-Host ''
Write-Host '=== ③ InternetQueryOption 读回（inetcpl.cpl 就是用它）==='
Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class MclashProxyCheck {
  [StructLayout(LayoutKind.Sequential, CharSet=CharSet.Unicode)]
  public struct OPTION { public int dwOption; public IntPtr value; }
  [StructLayout(LayoutKind.Sequential, CharSet=CharSet.Unicode)]
  public struct LIST {
    public int dwSize; public string pszConnection; public int dwOptionCount;
    public int dwOptionError; public IntPtr pOptions;
  }
  [DllImport("wininet.dll", CharSet=CharSet.Unicode, SetLastError=true)]
  public static extern bool InternetQueryOptionW(IntPtr h, int opt, ref LIST list, ref int size);
}
"@
$optSize = [System.Runtime.InteropServices.Marshal]::SizeOf([Type]'MclashProxyCheck+OPTION')
$list = New-Object MclashProxyCheck+LIST
$list.dwSize = [System.Runtime.InteropServices.Marshal]::SizeOf($list)
$list.dwOptionCount = 2
$opts = [System.Runtime.InteropServices.Marshal]::AllocHGlobal($optSize * 2)
$o1 = New-Object MclashProxyCheck+OPTION; $o1.dwOption = 1; $o1.value = [IntPtr]::Zero
$o2 = New-Object MclashProxyCheck+OPTION; $o2.dwOption = 2; $o2.value = [IntPtr]::Zero
[System.Runtime.InteropServices.Marshal]::StructureToPtr($o1, $opts, $false)
[System.Runtime.InteropServices.Marshal]::StructureToPtr($o2, [IntPtr]::Add($opts, $optSize), $false)
$list.pOptions = $opts
$size = [System.Runtime.InteropServices.Marshal]::SizeOf($list)
$ok = [MclashProxyCheck]::InternetQueryOptionW([IntPtr]::Zero, 75, [ref]$list, [ref]$size)
$r1 = [System.Runtime.InteropServices.Marshal]::PtrToStructure($opts, [Type]'MclashProxyCheck+OPTION')
$r2 = [System.Runtime.InteropServices.Marshal]::PtrToStructure([IntPtr]::Add($opts, $optSize), [Type]'MclashProxyCheck+OPTION')
Write-Host ("InternetQueryOption 返回 = {0}" -f $ok)
Write-Host ("  读回 flags  = {0}  （含 2 才是「使用代理服务器」）" -f $r1.value)
Write-Host ("  读回 server = '{0}'" -f [System.Runtime.InteropServices.Marshal]::PtrToStringUni($r2.value))
[System.Runtime.InteropServices.Marshal]::FreeHGlobal($opts)

Write-Host ''
Write-Host '结论：如果 ③ 读回 flags 含 2、server=127.0.0.1:<端口>，说明数据层完全正确，'
Write-Host '      「局域网设置」对话框空白只是因为**它没刷新**——请把该对话框/Internet 选项'
Write-Host '      窗口完全关闭，再重新打开一次。'
Write-Host '      如果 ③ 读回不对，请把上面全部输出发回来。'
