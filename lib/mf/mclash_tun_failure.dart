library;

/// TUN 启动失败的判定与分类（纯 Dart，可单测）。
///
/// 参考实现（我另一台机器上的 moneyfly 桌面版，`lib/core/proxy/tun_failure.dart`）
/// 的结论照搬过来 —— 这是踩过坑之后才写对的判定：
///
/// mihomo 的 TUN 起不来时**不会退出、也不会让 Clash API 报错**，只在日志里打一行
/// error 就继续跑。于是 App 若只看「API 200」就会「显示已连接、零流量、零报错」，
/// 必须读内核日志判定。
///
/// 但判定不能粗：旧做法是「行里同时含 tun 和 error/failed」，而 mihomo 有一批
/// **正常告警**同样命中，会把一条本来好好的连接判死、还误导用户去提权：
///   * `Auto detect interface for <名> failed, return '<invalid>'`（多网卡/Hyper-V 环境
///     探不到出口接口，属正常告警）；
///   * `default interface changed/lost by monitor`（网卡切换监控，正常）；
///   * `Tun adapter listening at:` / `use tun name`（成功日志）；
///   * `error writing to TUN device`（数据面偶发转发错误，不代表 TUN 没起来）。
///
/// 所以只认**真正的启动失败串**，再按原因分类，让上层给出可执行的提示
/// （提权 / 网卡残留 / 驱动被拦），而不是一句万能的「请以管理员身份运行」。
enum TunStartFailure {
  /// 没有失败（含「只有告警」的情况）
  none,

  /// 权限不足：Windows 未以管理员运行 / macOS 未以 root 运行
  privilege,

  /// 虚拟网卡已存在或被占用（同名适配器残留、上次异常退出的遗留）
  adapterBusy,

  /// 虚拟网卡驱动 / DLL 无法加载（多被安全软件拦截）
  driver,

  /// 起来了但原因无法归类
  unknown,
}

/// 真正的「TUN 没起来」标记（sing-tun 的启动失败出口）。
/// 必须精确：多一个宽泛词就会把正常连接判死。
const List<String> kTunFatalMarkers = [
  'start tun listening error',
  'start tun interface timeout',
  // 真实内核（mihomo 1.19.x）在 macOS/Windows 上的失败出口就是这个短语，
  // 实测日志：`Start TUN listening error: configure tun interface: ...`
  'configure tun interface',
];

/// 已核实的**正常** TUN 日志（这些行含 tun + failed/error，但完全不代表 TUN 没起来）。
const List<String> kTunBenignMarkers = [
  'auto detect interface',
  'default interface changed',
  'default interface lost',
  'tun name failed',
  'unsupported tunname',
  'tun adapter listening at',
  'use tun name',
  'error writing to tun device',
  'failed to read packet from tun device',
];

/// 权限类特征（Windows ERROR_ACCESS_DENIED / POSIX EPERM）。
const List<String> kTunPrivilegeMarkers = [
  'access is denied',
  'access denied',
  'permission denied',
  'operation not permitted',
  'requires elevation',
  'administrator',
  'run as root',
];

/// 网卡冲突特征（Windows ERROR_ALREADY_EXISTS：同名适配器已存在）。
const List<String> kTunBusyMarkers = [
  'already exists',
  'already in use',
  'address already in use',
  'file exists',
  'device is in use',
  'in use',
];

/// 驱动 / 依赖加载失败特征。
const List<String> kTunDriverMarkers = [
  'wintun',
  'unable to load library',
  'load library',
  'driver',
  '.dll',
  'not found',
];

/// 单行是否命中「真致命」标记（供内核日志**边收边判**用）。
///
/// 日志缓冲区有容量上限，只在就绪时回头扫缓冲区会漏判 —— 启动瞬间打了几十条
/// debug 日志就可能把致命行挤出去。
bool isFatalTunLine(String line) {
  final s = line.toLowerCase();
  if (kTunBenignMarkers.any(s.contains)) {
    return false;
  }
  return kTunFatalMarkers.any(s.contains);
}

/// TUN 是否真的启动失败、以及失败原因（纯函数）。
TunStartFailure detectTunStartFailure(Iterable<String> lines) {
  final all = [for (final l in lines) l.toLowerCase()];
  var lastFatal = -1;
  for (var i = 0; i < all.length; i++) {
    if (isFatalTunLine(all[i])) {
      lastFatal = i;
    }
  }
  if (lastFatal < 0) {
    return TunStartFailure.none;
  }

  // 致命行及其之后的若干行一起看：内核有时把 OS 错误另起一行。
  final window = all.sublist(lastFatal, (lastFatal + 4).clamp(0, all.length));
  bool has(List<String> markers) => window.any((l) => markers.any(l.contains));

  // 顺序即优先级：权限 → 驱动 → 冲突。
  // 「Access is denied」在驱动加载被打断时也会出现，但提权是用户真能立刻做的
  // 动作，所以优先给权限提示；纯驱动失败（无权限特征）才报被拦截。
  if (has(kTunPrivilegeMarkers)) {
    return TunStartFailure.privilege;
  }
  if (has(kTunDriverMarkers)) {
    return TunStartFailure.driver;
  }
  if (has(kTunBusyMarkers)) {
    return TunStartFailure.adapterBusy;
  }
  return TunStartFailure.unknown;
}

/// **弱判据**：日志里有「像 TUN 出错」的行，但不是已知致命串、也不是已知正常日志。
///
/// 内核的失败文案无法穷举，硬判据可能漏判；这时不强判失败（避免重演「正常连接
/// 被判死」），只让上层记一条可查的提示 —— 把「静默假连接」降级成「日志里留痕」。
/// 所以这个函数**允许假阳性**：命中也只写日志，不中断连接。
bool looksLikeTunTrouble(Iterable<String> lines) {
  for (final l in lines) {
    final s = l.toLowerCase();
    if (!s.contains('tun')) {
      continue;
    }
    if (!(s.contains('error') || s.contains('failed') || s.contains('unable'))) {
      continue;
    }
    if (kTunBenignMarkers.any(s.contains)) {
      continue;
    }
    return true;
  }
  return false;
}

/// 该失败是否值得自动重试。
///
/// 权限类**不重试**：进程不可能在运行中获得管理员权限，重试只是把可执行的提示
/// 延后。其余（网卡残留、驱动被拦）可能是暂态，值得重试。
bool isRetryableTunFailure(TunStartFailure failure) =>
    failure != TunStartFailure.none && failure != TunStartFailure.privilege;

/// 给用户看的一句话（可执行，而不是「请以管理员身份运行」万能句）。
String tunFailureHint(TunStartFailure failure, {required bool isWindows}) {
  switch (failure) {
    case TunStartFailure.none:
      return "";
    case TunStartFailure.privilege:
      return isWindows
          ? "TUN 需要管理员权限：右键 Mclash → 「以管理员身份运行」；"
                "或在「我的 → TUN 虚拟网卡」里选择「关闭」（仅系统代理）。"
          : "TUN 需要管理员权限：请以 root 启动 Mclash；"
                "或在「我的 → TUN 虚拟网卡」里选择「关闭」（仅系统代理）。";
    case TunStartFailure.adapterBusy:
      return "虚拟网卡已被占用（同名网卡残留）：请重启电脑后再试，"
          "或在「网络连接」里删除名为 Mclash 的虚拟网卡。";
    case TunStartFailure.driver:
      return "虚拟网卡驱动加载失败（多被安全软件拦截）："
          "请把 Mclash 与 mihomo 加入杀毒/安全软件白名单后重试。";
    case TunStartFailure.unknown:
      return "TUN 启动失败（原因未能归类）：请在「我的 → 连接自检」里复制日志给客服。";
  }
}
