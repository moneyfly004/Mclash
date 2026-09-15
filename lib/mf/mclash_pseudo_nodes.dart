/// 识别订阅里的「伪节点」——信息节点与错误节点。
///
/// ## 问题是什么
///
/// 后端（`internal/api/handlers/subscription.go` 的 `createInfoNode` /
/// `createErrorNode`）会把账号信息塞进节点列表，做法是**伪造一批 ss 代理**：
///
///     ss://<aes-128-gcm:info>@baidu.com:1234#📢 官网: https://xxx
///
/// 也就是服务器写死 `baidu.com:1234`，凭据写死 `info`。它们是给用户「看一眼」
/// 用的（到期时间、剩余设备、客服联系方式），**永远不可能连通**。
///
/// 这在业界是常见做法，本身没问题。问题在于客户端如果把它们当成真节点：
///
///   1. 「全部测速」必然出现若干条超时失败，混在真节点里，用户以为节点坏了；
///   2. 按延迟排序（`ui.delay_test_sort`）时它们永远垫底；
///   3. 更糟的是**可以被选中** —— 一旦用户选了「📢 官网」当出口，
///      所有流量都发给 baidu.com:1234，表现为「连上了但完全没网」，
///      而且极难归因（用户不会想到自己选中的是一条广告文案）。
///
/// 所以这里给出一处统一判定，供测速与节点列表复用。
///
/// ## 为什么按名字判定
///
/// mihomo 的 `/proxies` 返回体里**只有 name/type/history/all**，
/// 没有 server/port（见 `ClashProxiesNode`），所以没法从模型里读 server 来判。
/// 好在后端这批节点的名字是固定前缀的，且都带 emoji 或固定文案，足够稳定。
/// 两边任一改动时只需同步这一个文件。
library;

class MclashPseudoNodes {
  MclashPseudoNodes._();

  /// 信息节点前缀（`createInfoNode`）。
  static const List<String> _infoPrefixes = [
    "📢 官网:", // 站点地址
    "⏰ 到期:", // 订阅到期时间
    "📱 设备:", // 已用/可用设备数
    "💬 客服:", // 客服联系方式
  ];

  /// 错误节点名字（`getErrorNodes`）——订阅不可用时后端下发这些代替真节点。
  static const List<String> _errorNames = [
    "订阅不存在",
    "订阅已过期",
    "订阅已失效",
    "设备数量超限",
    "请在系统设置中配置域名",
    "请检查订阅地址是否正确",
    "请联系管理员检查订阅状态",
  ];

  /// 错误节点的固定前缀（后面接可变内容）。
  static const List<String> _errorPrefixes = [
    "❌ 原因:",
    "💡 解决:",
    "请前往官网续费", // "请前往官网续费 (过期时间: ...)"
    "当前设备 ", // "当前设备 3/5，请在官网删除不使用的设备"
  ];

  /// 是否是伪节点（信息节点或错误节点）。精确匹配前缀/全名，避免误伤
  /// 真节点里恰好含 emoji 的名字。
  static bool isPseudo(String name) {
    if (name.isEmpty) {
      return false;
    }
    for (final p in _infoPrefixes) {
      if (name.startsWith(p)) {
        return true;
      }
    }
    for (final p in _errorPrefixes) {
      if (name.startsWith(p)) {
        return true;
      }
    }
    return _errorNames.contains(name);
  }

  /// 是否是「订阅有问题」的错误节点（用于把这一情况显式告诉用户，
  /// 而不是让用户对着一堆超时猜）。
  static bool isErrorNode(String name) =>
      isPseudo(name) && !_infoPrefixes.any(name.startsWith);

  /// 从节点名列表里剔掉伪节点。
  static List<String> filterOut(Iterable<String> names) =>
      names.where((n) => !isPseudo(n)).toList(growable: false);
}
