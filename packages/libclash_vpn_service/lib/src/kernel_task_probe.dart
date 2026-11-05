/// 「Mclash Kernel」计划任务是否真实存在的探测工具（纯逻辑，可单测）。
///
/// 背景（0.0.5 真机确认的 TUN 起不来 bug）：App 过去只判断
/// `%APPDATA%\mclash\mclash\kernel_host.vbs` 是否存在。安装包会先写脚本、
/// 再 `schtasks /create` 建任务；两步之间任何一步失败（UAC、策略、任务被删）
/// 都会留下「脚本在、任务不在」的状态 —— 旧判断返回 true，App 于是走计划任务
/// 路径，`schtasks /run` 静默失败，TUN 永远起不来。
///
/// 正确判据 = 查询计划任务本身（`schtasks /query`）成功 **且** 任务动作引用的
/// 启动脚本还在。查询不能直接 `Process.run("schtasks", ...)`：schtasks 是控制台
/// 程序，会闪一下黑框。这里改为生成一个只含 ASCII 的 VBS，由 `wscript.exe`
/// （GUI 子系统，不创建控制台）执行；脚本内部以隐藏窗口（0）同步运行
/// `schtasks /query`，再把退出码写进标记文件，Dart 侧读标记文件判定。
library;

/// 生成「查询计划任务是否存在」的探测脚本。
///
/// - [taskName]：计划任务名（`Mclash Kernel`）。
/// - [markerFileName]：标记文件名（**只允许文件名，不要带目录**）。脚本会用
///   `WScript.ScriptFullName` 的目录拼出完整路径，因此脚本正文里不会出现任何
///   非 ASCII 路径 —— wscript 按系统 ANSI 代码页解析 .vbs，UTF-8 中文路径写进
///   脚本会乱码，标记文件就写不出来了。
///
/// 约定：退出码 `0` 表示任务存在，非 `0` 表示不存在；脚本用
/// `On Error Resume Next` 保证任何意外都不会弹 WScript 错误框（窗口）。
String buildKernelTaskProbeVbs({
  required String taskName,
  required String markerFileName,
}) {
  return 'On Error Resume Next\r\n'
      'Set sh = CreateObject("WScript.Shell")\r\n'
      'rc = sh.Run("schtasks /query /tn ""${_escapeVbs(taskName)}""", 0, True)\r\n'
      'If Err.Number <> 0 Then rc = 1\r\n'
      'Set fso = CreateObject("Scripting.FileSystemObject")\r\n'
      'marker = fso.BuildPath(fso.GetParentFolderName(WScript.ScriptFullName), '
      '"${_escapeVbs(markerFileName)}")\r\n'
      'fso.OpenTextFile(marker, 2, True).Write CStr(rc)\r\n';
}

/// 解析探测脚本写下的标记文件内容。
///
/// 返回 true = 任务存在（退出码 0）；false = 任务不存在（非 0）；
/// null = 文件缺失 / 空 / 内容非法 = **未知**。调用方必须把未知当成「不可用」
/// （fail-closed，退回 UAC 路径），绝不能当成就绪。
bool? parseKernelTaskProbeMarker(String? content) {
  final raw = content?.trim();
  if (raw == null || raw.isEmpty) {
    return null;
  }
  final rc = int.tryParse(raw);
  if (rc == null) {
    return null;
  }
  return rc == 0;
}

/// 计划任务是否可用：**任务查询成功** 且 任务动作引用的启动脚本存在。
///
/// 这是本 bug 的核心回归点：只看 `kernel_host.vbs` 存在（旧实现）会在
/// 「脚本已写、任务没建成」时误判为就绪。脚本缺失同样算不可用 —— 任务动作是
/// `wscript.exe <脚本>`，脚本没了任务必然跑不起来。
bool evaluateKernelTaskProbe({
  required bool? markerResult,
  required bool hostScriptExists,
}) {
  return markerResult == true && hostScriptExists;
}

/// 探测结果短缓存。
///
/// 每次探测都要起一个 wscript（几十~几百毫秒），不能每次点连接都跑；但缓存太久
/// 又会让「任务刚被删 / 刚建好」的状态滞后。默认 30 秒 TTL + [invalidate] 显式
/// 失效（安装任务后校验、任务被删除时用）。
class KernelTaskReadinessCache {
  KernelTaskReadinessCache({
    this.ttl = const Duration(seconds: 30),
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final Duration ttl;
  final DateTime Function() _clock;

  bool? _value;
  DateTime? _at;
  Future<bool>? _inFlight;

  /// 缓存代次：invalidate 时自增，用来丢弃「失效前发起、失效后才返回」的旧探测。
  int _generation = 0;

  bool get hasFreshValue {
    final at = _at;
    return _value != null && at != null && _clock().difference(at) < ttl;
  }

  /// 返回缓存值；缓存过期 / 未命中 / [forceRefresh] 时执行 [probe]。
  ///
  /// 并发调用（同一时刻多个连接流程）只会真正探测一次。探测抛异常时不写缓存，
  /// 异常原样抛给调用方。
  Future<bool> resolve(
    Future<bool> Function() probe, {
    bool forceRefresh = false,
  }) {
    if (!forceRefresh && hasFreshValue) {
      return Future<bool>.value(_value!);
    }
    final running = _inFlight;
    if (running != null) {
      return running;
    }
    final generation = _generation;
    final future = _runProbe(probe, generation);
    _inFlight = future;
    return future;
  }

  Future<bool> _runProbe(
    Future<bool> Function() probe,
    int generation,
  ) async {
    try {
      final value = await probe();
      if (generation == _generation) {
        _value = value;
        _at = _clock();
      }
      return value;
    } finally {
      if (generation == _generation) {
        _inFlight = null;
      }
    }
  }

  /// 清掉缓存与在途探测记录，下一次 [resolve] 一定重新探测。
  void invalidate() {
    _generation++;
    _value = null;
    _at = null;
    _inFlight = null;
  }
}

/// VBScript 字符串内的双引号转义。
String _escapeVbs(String v) => v.replaceAll('"', '""');

/// 生成「TUN 网卡是否真的建起来了」的探测脚本。
///
/// 为什么需要它：内核以**提权**方式启动时（计划任务 / UAC），它的 stdout/stderr
/// 属于外壳进程，App 抓不到 —— 内核日志是空的。可是兜底逻辑
/// `_applyDataPathFallback` 正是靠"日志里有没有 TUN 就绪标记"来判断 TUN 是否接管，
/// 于是一个**工作正常**的提权 TUN 会被误判失败，进而把系统代理也设上（双重代理）。
/// 这里改用 WMI 直接查网卡，作为日志不可用时的第二条独立证据。
///
/// 匹配规则：网卡 Name 或 Description 包含 [deviceHint]（配置里的 `tun.device`，
/// 例如 `Mclash`；Windows 上实际名字是 `Mclash Meta Tunnel`）。命中写 `1`，
/// 否则写 `0`，任何异常都写 `0`（fail-closed：宁可走兜底，也不要谎报成功）。
String buildTunAdapterProbeVbs({
  required String deviceHint,
  required String markerFileName,
}) {
  return 'On Error Resume Next\r\n'
      'rc = 0\r\n'
      'hint = LCase("${_escapeVbs(deviceHint)}")\r\n'
      'Set svc = GetObject("winmgmts:\\\\.\\root\\cimv2")\r\n'
      'Set list = svc.ExecQuery("SELECT Name, Description FROM Win32_NetworkAdapter '
      'WHERE NetEnabled = True")\r\n'
      'For Each a In list\r\n'
      '  nm = LCase("" & a.Name)\r\n'
      '  ds = LCase("" & a.Description)\r\n'
      '  If hint = "" Then\r\n'
      '    If InStr(ds, "wintun") > 0 Or InStr(nm, "tunnel") > 0 Then rc = 1\r\n'
      '  Else\r\n'
      '    If InStr(nm, hint) > 0 Or InStr(ds, hint) > 0 Then rc = 1\r\n'
      '  End If\r\n'
      'Next\r\n'
      'If Err.Number <> 0 Then rc = 0\r\n'
      'Set fso = CreateObject("Scripting.FileSystemObject")\r\n'
      'marker = fso.BuildPath(fso.GetParentFolderName(WScript.ScriptFullName), '
      '"${_escapeVbs(markerFileName)}")\r\n'
      'fso.OpenTextFile(marker, 2, True).Write CStr(rc)\r\n';
}

/// 解析 TUN 网卡探测标记：`1` = 网卡在；`0`/非法/缺失 = 不在（宁可走兜底）。
bool parseTunAdapterProbeMarker(String? content) =>
    content?.trim() == "1";
