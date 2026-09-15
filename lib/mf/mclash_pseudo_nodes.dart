
library;

class MclashPseudoNodes {
  MclashPseudoNodes._();

  static const List<String> _infoPrefixes = [
    "📢 官网:",
    "⏰ 到期:",
    "📱 设备:",
    "💬 客服:",
  ];

  static const List<String> _errorNames = [
    "订阅不存在",
    "订阅已过期",
    "订阅已失效",
    "设备数量超限",
    "请在系统设置中配置域名",
    "请检查订阅地址是否正确",
    "请联系管理员检查订阅状态",
  ];

  static const List<String> _errorPrefixes = [
    "❌ 原因:",
    "💡 解决:",
    "请前往官网续费",
    "当前设备 ",
  ];

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

  static bool isErrorNode(String name) =>
      isPseudo(name) && !_infoPrefixes.any(name.startsWith);

  static List<String> filterOut(Iterable<String> names) =>
      names.where((n) => !isPseudo(n)).toList(growable: false);
}
