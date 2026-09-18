# Mclash Windows 系统代理诊断 + 一键验证
#
# 在 Windows 上以「运行 Mclash 的那个用户」打开 PowerShell 运行。
#
# 目的：一次把三层数据摊开，定位「注册表里明明有 127.0.0.1:端口、Windows 界面却空白」
# 到底卡在哪一层：
#   ① 全局注册表值（ProxyEnable / ProxyServer / ProxyOverride / 归属标记）
#   ② 「当前连接」那份（Connections\DefaultConnectionSettings）——
#      「设置 → 代理」和「Internet 选项 → 局域网设置」**读的就是它**
#   ③ 通过官方 API（InternetSetOption INTERNET_OPTION_PER_CONNECTION_OPTION）
#      把 ② 写成 127.0.0.1:<端口> 之后，界面是否立刻显示（-Write）
#
# 用法：
#   powershell -ExecutionPolicy Bypass -File tool\windows_proxy_verify.ps1
#   powershell -ExecutionPolicy Bypass -File tool\windows_proxy_verify.ps1 -Port 7890 -Write
#   powershell -ExecutionPolicy Bypass -File tool\windows_proxy_verify.ps1 -Restore
#
# -Write 写的就是 Mclash 连接时会写的那份数据。写完请把
# 「设置 → 网络和 Internet → 代理」与「Internet 选项 → 连接 → 局域网设置」
# 关掉再打开，看地址端口是否出现 —— 这会直接判定「是不是这层数据的问题」。

param(
  [int]$Port = 0,
  [switch]$Write,
  [switch]$Restore
)

$ErrorActionPreference = 'Continue'
$key = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings'

Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;

public static class MclashProxyProbe
{
    [StructLayout(LayoutKind.Sequential)]
    public struct OPTION { public int dwOption; public IntPtr value; }

    [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
    public struct LIST
    {
        public int dwSize;
        public string pszConnection;
        public int dwOptionCount;
        public int dwOptionError;
        public IntPtr pOptions;
    }

    [DllImport("wininet.dll", SetLastError = true, CharSet = CharSet.Unicode)]
    static extern bool InternetSetOptionW(IntPtr h, int opt, IntPtr buf, int len);

    [DllImport("wininet.dll", SetLastError = true, CharSet = CharSet.Unicode)]
    static extern bool InternetQueryOptionW(IntPtr h, int opt, IntPtr buf, ref int len);

    [DllImport("user32.dll", SetLastError = true)]
    static extern IntPtr SendMessageTimeout(IntPtr hWnd, uint msg, UIntPtr wParam,
        string lParam, uint fuFlags, uint uTimeout, out UIntPtr result);

    const int PER_CONNECTION_OPTION = 75;
    const int OPT_FLAGS = 1, OPT_SERVER = 2, OPT_BYPASS = 3;
    const int PROXY_TYPE_DIRECT = 0x1, PROXY_TYPE_PROXY = 0x2;
    const int SETTINGS_CHANGED = 39, REFRESH = 37;

    static int OptionSize { get { return Marshal.SizeOf(typeof(OPTION)); } }
    static int ListSize { get { return Marshal.SizeOf(typeof(LIST)); } }

    public static string SetProxy(string server, string bypass)
    {
        int count = 3;
        IntPtr options = Marshal.AllocHGlobal(OptionSize * count);
        IntPtr list = Marshal.AllocHGlobal(ListSize);
        IntPtr serverPtr = IntPtr.Zero, bypassPtr = IntPtr.Zero;
        try
        {
            serverPtr = Marshal.StringToHGlobalUni(server);
            bypassPtr = Marshal.StringToHGlobalUni(bypass);
            OPTION o0 = new OPTION();
            o0.dwOption = OPT_FLAGS;
            o0.value = (IntPtr)(PROXY_TYPE_DIRECT | PROXY_TYPE_PROXY);
            OPTION o1 = new OPTION();
            o1.dwOption = OPT_SERVER;
            o1.value = serverPtr;
            OPTION o2 = new OPTION();
            o2.dwOption = OPT_BYPASS;
            o2.value = bypassPtr;
            Marshal.StructureToPtr(o0, options, false);
            Marshal.StructureToPtr(o1, (IntPtr)((long)options + OptionSize), false);
            Marshal.StructureToPtr(o2, (IntPtr)((long)options + OptionSize * 2), false);

            LIST l = new LIST();
            l.dwSize = ListSize;
            l.pszConnection = null;
            l.dwOptionCount = count;
            l.dwOptionError = 0;
            l.pOptions = options;
            Marshal.StructureToPtr(l, list, false);

            bool ok = InternetSetOptionW(IntPtr.Zero, PER_CONNECTION_OPTION, list, ListSize);
            if (!ok) return "InternetSetOption 失败，Win32 错误 " + Marshal.GetLastWin32Error();
            Broadcast();
            return "";
        }
        finally
        {
            if (serverPtr != IntPtr.Zero) Marshal.FreeHGlobal(serverPtr);
            if (bypassPtr != IntPtr.Zero) Marshal.FreeHGlobal(bypassPtr);
            Marshal.FreeHGlobal(options);
            Marshal.FreeHGlobal(list);
        }
    }

    public static string ClearProxy()
    {
        int count = 1;
        IntPtr options = Marshal.AllocHGlobal(OptionSize * count);
        IntPtr list = Marshal.AllocHGlobal(ListSize);
        try
        {
            OPTION o0 = new OPTION();
            o0.dwOption = OPT_FLAGS;
            o0.value = (IntPtr)PROXY_TYPE_DIRECT;
            Marshal.StructureToPtr(o0, options, false);
            LIST l = new LIST();
            l.dwSize = ListSize;
            l.pszConnection = null;
            l.dwOptionCount = count;
            l.dwOptionError = 0;
            l.pOptions = options;
            Marshal.StructureToPtr(l, list, false);
            bool ok = InternetSetOptionW(IntPtr.Zero, PER_CONNECTION_OPTION, list, ListSize);
            if (!ok) return "InternetSetOption 失败，Win32 错误 " + Marshal.GetLastWin32Error();
            Broadcast();
            return "";
        }
        finally
        {
            Marshal.FreeHGlobal(options);
            Marshal.FreeHGlobal(list);
        }
    }

    public static string ReadConnection()
    {
        int count = 3;
        IntPtr options = Marshal.AllocHGlobal(OptionSize * count);
        IntPtr list = Marshal.AllocHGlobal(ListSize);
        try
        {
            OPTION o0 = new OPTION(); o0.dwOption = OPT_FLAGS; o0.value = IntPtr.Zero;
            OPTION o1 = new OPTION(); o1.dwOption = OPT_SERVER; o1.value = IntPtr.Zero;
            OPTION o2 = new OPTION(); o2.dwOption = OPT_BYPASS; o2.value = IntPtr.Zero;
            Marshal.StructureToPtr(o0, options, false);
            Marshal.StructureToPtr(o1, (IntPtr)((long)options + OptionSize), false);
            Marshal.StructureToPtr(o2, (IntPtr)((long)options + OptionSize * 2), false);

            LIST l = new LIST();
            l.dwSize = ListSize;
            l.pszConnection = null;
            l.dwOptionCount = count;
            l.dwOptionError = 0;
            l.pOptions = options;
            Marshal.StructureToPtr(l, list, false);

            int size = ListSize;
            bool ok = InternetQueryOptionW(IntPtr.Zero, PER_CONNECTION_OPTION, list, ref size);
            if (!ok) return "InternetQueryOption 失败，Win32 错误 " + Marshal.GetLastWin32Error();

            OPTION r0 = (OPTION)Marshal.PtrToStructure(options, typeof(OPTION));
            OPTION r1 = (OPTION)Marshal.PtrToStructure(
                (IntPtr)((long)options + OptionSize), typeof(OPTION));
            OPTION r2 = (OPTION)Marshal.PtrToStructure(
                (IntPtr)((long)options + OptionSize * 2), typeof(OPTION));
            string server = r1.value == IntPtr.Zero ? "" : Marshal.PtrToStringUni(r1.value);
            string bypass = r2.value == IntPtr.Zero ? "" : Marshal.PtrToStringUni(r2.value);
            return string.Format("flags={0}（含 0x2 才是「使用代理服务器」） server='{1}' bypass='{2}'",
                (int)r0.value, server, bypass);
        }
        finally
        {
            Marshal.FreeHGlobal(options);
            Marshal.FreeHGlobal(list);
        }
    }

    static void Broadcast()
    {
        try
        {
            InternetSetOptionW(IntPtr.Zero, SETTINGS_CHANGED, IntPtr.Zero, 0);
            InternetSetOptionW(IntPtr.Zero, REFRESH, IntPtr.Zero, 0);
            UIntPtr result;
            SendMessageTimeout((IntPtr)0xffff, 0x001A, UIntPtr.Zero, "InternetSettings", 2, 1000, out result);
        }
        catch { }
    }
}
'@

Write-Host '=== 0. 当前用户 / 进程 ==='
whoami
Write-Host ("会话: " + (Get-Process -Id $PID).SessionId)

Write-Host ''
Write-Host '=== 1. 全局注册表值（App 写的就是这里） ==='
Get-ItemProperty $key |
  Select-Object ProxyEnable, ProxyServer, ProxyOverride, MclashProxyOwner, AutoConfigURL |
  Format-List

Write-Host '=== 2. 每连接缓存块（Windows 界面读的是它） ==='
$conn = Get-ItemProperty "$key\Connections"
foreach ($n in @('DefaultConnectionSettings', 'SavedLegacySettings')) {
  $b = $conn.$n
  if ($b) {
    $txt = -join ($b | ForEach-Object { if ($_ -ge 32 -and $_ -lt 127) { [char]$_ } else { '.' } })
    $flags = if ($b.Length -ge 9) { $b[8] } else { -1 }
    Write-Host ("{0} 长度={1} flags(第9字节)=0x{2:x2}" -f $n, $b.Length, $flags)
    Write-Host ("  文本: {0}" -f $txt)
  } else {
    Write-Host "$n : (不存在)"
  }
}

Write-Host ''
Write-Host '=== 3. 官方 API 读回的「当前连接」（与界面同一份数据） ==='
Write-Host ([MclashProxyProbe]::ReadConnection())

Write-Host ''
Write-Host '=== 4. 组策略是否接管代理 ==='
Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\Internet Settings' |
  Select-Object ProxyEnable, ProxyServer, ProxySettingsPerUser, AutoConfigURL | Format-List

if ($Write) {
  if ($Port -le 0) {
    Write-Host '请用 -Port <内核混合端口> 指定端口（连接 Mclash 后在「我的 → 应用设置 → 系统代理」里能看到）'
    exit 1
  }
  Write-Host ''
  Write-Host ("=== 5. 通过官方 API 写「当前连接」代理 → 127.0.0.1:{0} ===" -f $Port)
  $err = [MclashProxyProbe]::SetProxy(("127.0.0.1:" + $Port), '<local>')
  if ($err -eq '') {
    Write-Host '写入成功（这就是 Mclash 连接时会写的那份数据）'
    Write-Host ('写回读: ' + [MclashProxyProbe]::ReadConnection())
    Write-Host '请把「设置 → 网络和 Internet → 代理」和「Internet 选项 → 连接 → 局域网设置」关掉再打开，看是否出现地址端口。'
    Write-Host '若这里出现了、而 Mclash 连接时不出现 → 请把 Mclash 的应用日志（我的 → 应用日志）发出来。'
  } else {
    Write-Host $err
  }
}

if ($Restore) {
  Write-Host ''
  Write-Host '=== 6. 把「当前连接」还原成直连 ==='
  $err = [MclashProxyProbe]::ClearProxy()
  if ($err -eq '') {
    Write-Host ('已还原: ' + [MclashProxyProbe]::ReadConnection())
  } else {
    Write-Host $err
  }
}
