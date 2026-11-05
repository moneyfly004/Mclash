// ignore_for_file: unused_catch_stack, empty_catches

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:mclash/app/clash/clash_config.dart' show ClashProtocolType;
import 'package:mclash/app/utils/file_utils.dart';
import 'package:mclash/app/utils/log.dart';
import 'package:mclash/app/utils/path_utils.dart';
import 'package:crypto/crypto.dart' show sha256;
import 'package:path/path.dart' as path;

class RuleProviderHttp {
  RuleProviderHttp({
    this.url = "",
    this.format = "",
    this.behavior = "",
    this.interval = const Duration(hours: 12),
  });

  String url;
  String format;
  String behavior;
  Duration? interval;

  /// 规则集缓存路径（相对 mihomo 工作目录）。
  ///
  /// 为什么不能只用 URL 的 basename：mihomo 按我们下发的 `path` 缓存下载结果，
  /// `https://a/cn/geoip.mrs` 与 `https://b/us/geoip.mrs` 的 basename 都是
  /// `geoip.mrs`，会落到同一个缓存文件上 —— 后下载的覆盖先下载的，两个规则
  /// 提供者在运行时共享同一份规则，分流结果完全错误。
  ///
  /// 因此把**完整 URL** 的 sha256 前 12 位（48 bit）拼进文件名：同一 URL 永远
  /// 得到同一路径（跨进程/跨平台稳定，不像 `String.hashCode` 只在本进程内稳定），
  /// 不同 URL 即使 basename 相同也不会互相覆盖。
  static String cachePathForUrl(String url) {
    return "./rules/${cacheFileNameForUrl(url)}";
  }

  /// 规则集缓存文件名：`<原文件名去扩展名>-<url 哈希前 12 位><扩展名>`。
  ///
  /// 没有可用文件名（空 URL、只有域名、路径只有分隔符等）时退回
  /// `rule-set-<url 哈希>`，仍然是稳定且按 URL 唯一的，不会像旧实现那样用
  /// 进程内的 `url.hashCode` 生成一个每次启动都可能变化的路径。
  static String cacheFileNameForUrl(String url) {
    final hash = sha256.convert(utf8.encode(url)).toString().substring(0, 12);
    final uri = Uri.tryParse(url);
    final rawName = (uri != null && uri.path.isNotEmpty)
        ? path.basename(uri.path)
        : "";
    final safeName = _sanitizeCacheFileName(rawName);
    if (safeName.isEmpty) {
      return "rule-set-$hash";
    }
    final ext = path.extension(safeName);
    final stem = path.basenameWithoutExtension(safeName);
    final prefix = stem.isEmpty ? "rule-set" : stem;
    return "$prefix-$hash$ext";
  }

  /// 只保留跨平台文件系统安全的字符，并拒绝 `.` / `..` / 纯分隔符这类
  /// 不能当文件名用的 basename（`path.basename("/")` 会返回 `/`）。
  static String _sanitizeCacheFileName(String rawName) {
    var name = rawName.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
    if (!RegExp(r'[A-Za-z0-9]').hasMatch(name)) {
      return "";
    }
    name = name.replaceFirst(RegExp(r'^\.+'), '');
    if (name.isEmpty || name == "." || name == "..") {
      return "";
    }
    return name;
  }

  Map<String, dynamic> toJson() {
    var ret = {
      'url': url,
      'format': format,
      'behavior': behavior,
      'path': cachePathForUrl(url),
      'interval': interval?.inSeconds,
    };

    return ret;
  }

  void fromJson(Map<String, dynamic>? map) {
    if (map == null) {
      return;
    }

    url = map['url'];
    format = map['format'] ?? '';
    behavior = map['behavior'] ?? '';

    int? intervalSeconds = map['interval'];
    if (!getFormats().contains(format)) {
      format = getFormats().first;
    }
    if (!getBehaviors().contains(behavior)) {
      behavior = getBehaviors().first;
    }

    if (intervalSeconds != null) {
      interval = Duration(seconds: intervalSeconds);
    }
    if (interval != null) {
      if (interval!.inMinutes < 10) {
        interval = Duration(hours: 12);
      }
    }
  }

  static RuleProviderHttp fromJsonStatic(Map<String, dynamic>? map) {
    RuleProviderHttp config = RuleProviderHttp();
    config.fromJson(map);
    return config;
  }

  static List<String> getFormats() {
    return ["mrs"];
  }

  static List<String> getBehaviors() {
    return ["domain", "ipcidr"];
  }
}

class RuleProvider {
  RuleProvider({this.name = "", this.type = "", this.http});
  String name = "";
  String type = "";
  RuleProviderHttp? http;

  Map<String, dynamic> toJsonNoName() => {
    'type': type,
    ...http?.toJson() ?? {},
  };
  Map<String, dynamic> toJson() => {
    'name': name,
    'type': type,
    ...http?.toJson() ?? {},
  };
  void fromJson(Map<String, dynamic>? map) {
    if (map == null) {
      return;
    }

    name = map['name'] ?? '';
    type = map['type'] ?? '';
    if (!getTypes().contains(type)) {
      type = getTypes().first;
    }
    http = RuleProviderHttp.fromJsonStatic(map);
  }

  RuleProvider clone() {
    return RuleProvider(
      name: name,
      type: type,
      http: http == null
          ? null
          : RuleProviderHttp(
              url: http!.url,
              format: http!.format,
              behavior: http!.behavior,
              interval: http!.interval,
            ),
    );
  }

  static List<String> getTypes() {
    return ["http"];
  }
}

class RuleTemplate {
  RuleTemplate({this.name = "", this.rules = const []});
  String name = "";
  List<String> rules = [];

  Map<String, dynamic> toJson() => {'name': name, 'rules': rules};
  void fromJson(Map<String, dynamic>? map) {
    if (map == null) {
      return;
    }
    name = map['name'] ?? '';
    rules = List<String>.from(map['rules'] ?? []);
  }

  Set<String> getProviders() {
    Set<String> providers = {};
    for (var rule in rules) {
      List<String> parts = parseRule(rule);
      if (parts[0] == "RULE-SET") {
        providers.add(parts[1]);
      }
    }
    return providers;
  }

  void reorder(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    if (oldIndex >= rules.length || newIndex >= rules.length) {
      return;
    }
    var item = rules.removeAt(oldIndex);
    rules.insert(newIndex, item);
  }

  RuleTemplate clone() {
    return RuleTemplate(name: name, rules: rules.toList());
  }

  static List<String> getTypes() {
    return [
      "RULE-SET",
      "GEOSITE",
      "GEOIP",
      "IP-ASN",
      "DOMAIN",
      "DOMAIN-SUFFIX",
      "DOMAIN-KEYWORD",
      "DOMAIN-REGEX",
      "IP-CIDR",
      "IP-CIDR6",
      "PROCESS-NAME",
      "PROCESS-NAME-REGEX",
      "AND",
      "OR",
      "NOT",
      "MATCH",
    ];
  }

  static bool needValue(String value) {
    final types = {
      "RULE-SET",
      "GEOSITE",
      "GEOIP",
      "IP-ASN",
      "DOMAIN",
      "DOMAIN-SUFFIX",
      "DOMAIN-KEYWORD",
      "DOMAIN-REGEX",
      "IP-CIDR",
      "IP-CIDR6",
      "PROCESS-NAME",
      "PROCESS-NAME-REGEX",
      "AND",
      "OR",
      "NOT",
    };
    return types.contains(value);
  }

  static bool supportNoResolve(String type) {
    final types = {"RULE-SET", "GEOIP", "IP-ASN", "IP-CIDR", "IP-CIDR6"};
    return types.contains(type);
  }

  static List<String> parseRule(String rule) {
    if (rule.isEmpty) {
      return [];
    }
    return rule.split(",");
  }
}

class ProxyGroupTemplate {
  ProxyGroupTemplate({
    this.name = "",
    this.icon = "",
    this.type = "",
    this.proxies = const [],
  });
  String name = "";
  String icon = "";
  String type = getTypes().first;
  List<String> proxies = [];

  Map<String, dynamic> toJson() => {
    'name': name,
    'icon': icon,
    'type': type,
    'proxies': proxies,

  };
  void fromJson(Map<String, dynamic>? map) {
    if (map == null) {
      return;
    }
    name = map['name'] ?? '';
    icon = map['icon'] ?? '';
    type = map['type'] ?? '';
    proxies = List<String>.from(map['proxies'] ?? []);

    if (!ProxyGroupTemplate.getTypes().contains(type)) {
      type = ProxyGroupTemplate.getTypes().first;
    }
  }

  ProxyGroupTemplate clone() {
    return ProxyGroupTemplate(
      name: name,
      icon: icon,
      type: type,
      proxies: proxies.toList(),

    );
  }

  static List<String> getTypes() {
    return ["select", "url-test", "load-balance", "fallback"];
  }

  static String toClashProtocolTypeString(String type) {
    switch (type) {
      case "url-test":
        return ClashProtocolType.urltest.name;
      case "select":
        return ClashProtocolType.selector.name;
      case "load-balance":
        return ClashProtocolType.loadBalance.name;
      case "fallback":
        return ClashProtocolType.fallback.name;
    }
    return "";
  }
}

class DiversionTemplates {
  List<RuleProvider> ruleProviders = [];
  List<RuleTemplate> ruleTemplates = [];
  List<ProxyGroupTemplate> proxyGroupTemplates = [];

  Map<String, dynamic> toJson() => {
    'rule-providers': ruleProviders,
    'rule-templates': ruleTemplates,
    'proxygroup-templates': proxyGroupTemplates,
  };

  void fromJson(Map<String, dynamic>? map) {
    if (map == null) {
      return;
    }

    final p = map['rule-providers'];
    if (p is List) {
      for (var value in p) {
        RuleProvider ps = RuleProvider();
        ps.fromJson(value);
        ruleProviders.add(ps);
      }
    }
    final t = map['rule-templates'];
    if (t is List) {
      for (var value in t) {
        RuleTemplate rt = RuleTemplate();
        rt.fromJson(value);
        ruleTemplates.add(rt);
      }
    }
    final g = map['proxygroup-templates'];
    if (g is List) {
      for (var value in g) {
        ProxyGroupTemplate rt = ProxyGroupTemplate();
        rt.fromJson(value);
        proxyGroupTemplates.add(rt);
      }
    }
  }
}

/// 删除规则提供者的结果。
///
/// 删除被规则模板引用时会被**拒绝**而不是硬删：模板里的
/// `RULE-SET,<provider>,<target>` 会在生成配置时原样下发，而 `rule-providers`
/// 段里已经没有这个 provider —— mihomo 会拒绝加载整份配置，用户看到的就是
/// "连不上"。拒绝删除会把问题留在可见的配置层，而不是变成运行时的连接失败。
class RuleProviderRemoveResult {
  const RuleProviderRemoveResult._(
    this.providerName,
    this.removed,
    this.referencingTemplates,
  );

  const RuleProviderRemoveResult.success(String providerName)
      : this._(providerName, true, const []);

  const RuleProviderRemoveResult.refused(
    String providerName,
    List<String> referencingTemplates,
  ) : this._(providerName, false, referencingTemplates);

  final String providerName;

  /// 是否真的删除了。
  final bool removed;

  /// 删除被拒绝时，引用该 provider 的规则模板名（按模板顺序）。
  final List<String> referencingTemplates;

  /// 可直接展示给用户的错误说明；删除成功时为空字符串。
  String get errorMessage => removed
      ? ""
      : "无法删除规则提供者 \"$providerName\"：仍有 "
            "${referencingTemplates.length} 个规则模板引用它"
            "（${referencingTemplates.join("、")}）。请先删除这些模板里的 "
            "RULE-SET 规则，否则生成的配置会引用不存在的规则提供者，"
            "mihomo 将拒绝加载。";
}

class DiversionTemplateManager {
  static final DiversionTemplates _diversionTemplates = DiversionTemplates();

  static final List<void Function(String)> onEventRuleProviderAdd = [];
  static final List<void Function(String)> onEventRuleProviderRemove = [];
  static final List<void Function(String)> onEventRuleTemplateAdd = [];
  static final List<void Function(String)> onEventRuleTemplateRemove = [];
  static final List<void Function(String)> onEventProxyGroupAdd = [];
  static final List<void Function(String)> onEventProxyGroupRemove = [];
  static final FileSaver _fileSaver = FileSaver();

  static Future<void> init() async {
    _fileSaver.setSavePath(await PathUtils.diversionTemplateConfigFilePath());
    await load();
  }

  static Future<void> uninit() async {}
  static Future<void> reload() async {
    _diversionTemplates.ruleProviders.clear();
    _diversionTemplates.ruleTemplates.clear();
    _diversionTemplates.proxyGroupTemplates.clear();
    await load();
  }

  static Future<void> save() async {
    await _fileSaver.saveAsJson(_diversionTemplates);
  }

  static Future<void> load() async {
    String filePath = await PathUtils.diversionTemplateConfigFilePath();
    var file = File(filePath);
    bool exists = await file.exists();
    if (exists) {
      try {
        String content = await file.readAsString();
        if (content.isNotEmpty) {
          var config = jsonDecode(content);
          _diversionTemplates.fromJson(config);
        }
      } catch (err, stacktrace) {
        Log.w("DiversionTemplateManager.load exception ${err.toString()} ");
      }
    } else {
      await save();
    }
  }

  /// 删除规则提供者。
  ///
  /// **被规则模板引用时拒绝删除**并返回 [RuleProviderRemoveResult.refused]：
  /// 删除没有"新名字"可以改写，硬删只会留下悬空的 `RULE-SET,<name>`，让
  /// mihomo 拒绝整份配置。拒绝是这里更安全的选择 —— 用户先改模板里的
  /// RULE-SET，再回来删。调用方应当把 [RuleProviderRemoveResult.errorMessage]
  /// 展示给用户，否则用户会以为点击删除没有反应。
  static Future<RuleProviderRemoveResult> removeRuleProviderByName(
    String name,
  ) async {
    final referencingTemplates = getRuleTemplateNamesUsingProvider(name);
    if (referencingTemplates.isNotEmpty) {
      final result = RuleProviderRemoveResult.refused(
        name,
        referencingTemplates,
      );
      Log.w("DiversionTemplateManager: ${result.errorMessage}");
      return result;
    }

    for (int i = 0; i < _diversionTemplates.ruleProviders.length; ++i) {
      if (name == _diversionTemplates.ruleProviders[i].name) {
        _diversionTemplates.ruleProviders.removeAt(i);
        break;
      }
    }

    for (var event in onEventRuleProviderRemove) {
      event(name);
    }

    await save();
    return RuleProviderRemoveResult.success(name);
  }

  static void removeRuleTemplateByName(String name) async {
    for (int i = 0; i < _diversionTemplates.ruleTemplates.length; ++i) {
      if (name == _diversionTemplates.ruleTemplates[i].name) {
        _diversionTemplates.ruleTemplates.removeAt(i);
        break;
      }
    }

    for (var event in onEventRuleTemplateRemove) {
      event(name);
    }

    await save();
  }

  static void removeProxyGroupTemplateByName(String name) async {
    for (int i = 0; i < _diversionTemplates.proxyGroupTemplates.length; ++i) {
      if (name == _diversionTemplates.proxyGroupTemplates[i].name) {
        _diversionTemplates.proxyGroupTemplates.removeAt(i);
        break;
      }
    }

    for (var event in onEventProxyGroupRemove) {
      event(name);
    }

    await save();
  }

  static RuleProvider? getRuleProviderByName(String name) {
    for (var provider in _diversionTemplates.ruleProviders) {
      if (provider.name == name) {
        return provider;
      }
    }
    return null;
  }

  static RuleTemplate? getRuleTemplateByName(String name) {
    for (var template in _diversionTemplates.ruleTemplates) {
      if (template.name == name) {
        return template;
      }
    }
    return null;
  }

  static ProxyGroupTemplate? getProxyGroupTemplateByName(String name) {
    for (var template in _diversionTemplates.proxyGroupTemplates) {
      if (template.name == name) {
        return template;
      }
    }
    return null;
  }

  static List<RuleProvider> getRuleProviders() {
    return _diversionTemplates.ruleProviders;
  }

  static List<RuleTemplate> getRuleTemplates() {
    return _diversionTemplates.ruleTemplates;
  }

  static List<ProxyGroupTemplate> getProxyGroupTemplates() {
    return _diversionTemplates.proxyGroupTemplates;
  }

  static Set<String> getRuleProvidersNames() {
    return _diversionTemplates.ruleProviders
        .map((element) => element.name)
        .toSet();
  }

  static Set<String> getRuleTemplatesNames() {
    return _diversionTemplates.ruleTemplates
        .map((element) => element.name)
        .toSet();
  }

  static Set<String> getProxyGroupTemplatesNames() {
    return _diversionTemplates.proxyGroupTemplates
        .map((element) => element.name)
        .toSet();
  }

  /// 返回引用了 [providerName] 的规则模板名（按模板顺序）。
  ///
  /// 规则模板只保存 `RULE-SET,<provider>`（可带 `,NO-RESOLVE`），目标代理组是
  /// 生成配置时才拼上的，所以这里只匹配前两段。
  static List<String> getRuleTemplateNamesUsingProvider(String providerName) {
    final names = <String>[];
    for (final template in _diversionTemplates.ruleTemplates) {
      if (template.rules.any(
        (rule) => _ruleReferencesProvider(rule, providerName),
      )) {
        names.add(template.name);
      }
    }
    return names;
  }

  static bool _ruleReferencesProvider(String rule, String providerName) {
    final parts = RuleTemplate.parseRule(rule);
    return parts.length >= 2 &&
        parts[0] == "RULE-SET" &&
        parts[1] == providerName;
  }

  /// 把所有模板里的 `RULE-SET,<oldName>` 改写成 `RULE-SET,<newName>`，
  /// 返回被改写的规则条数。
  static int _rewriteRuleProviderReferences(
    String oldName,
    String newName,
  ) {
    var rewritten = 0;
    for (final template in _diversionTemplates.ruleTemplates) {
      for (var i = 0; i < template.rules.length; ++i) {
        final parts = RuleTemplate.parseRule(template.rules[i]);
        if (parts.length >= 2 &&
            parts[0] == "RULE-SET" &&
            parts[1] == oldName) {
          parts[1] = newName;
          template.rules[i] = parts.join(",");
          ++rewritten;
        }
      }
    }
    return rewritten;
  }

  static void addRuleProvider(RuleProvider provider) {
    _diversionTemplates.ruleProviders.add(provider);
  }

  static void addRuleTemplate(RuleTemplate template) {
    _diversionTemplates.ruleTemplates.add(template);
  }

  static void addProxyGroupTemplate(ProxyGroupTemplate template) {
    _diversionTemplates.proxyGroupTemplates.add(template);
  }

  /// 更新规则提供者（`name` 是旧名字，`provider.name` 是新名字）。
  ///
  /// 名字变化时**同步改写**所有规则模板里的 `RULE-SET,<oldName>` 为
  /// `RULE-SET,<newName>`。重命名保留引用是安全的：用户的意图仍是"这个规则
  /// 集"，只是换了名字；不改写的话模板会继续引用旧名字，而 `rule-providers`
  /// 段里只剩新名字，生成的配置就会带一条悬空的 RULE-SET（mihomo 直接拒绝
  /// 加载）。删除没有"新名字"可写，所以选择拒绝，见
  /// [removeRuleProviderByName]。
  static void updateRuleProvider(String name, RuleProvider provider) {
    var found = false;
    for (int i = 0; i < _diversionTemplates.ruleProviders.length; ++i) {
      if (name == _diversionTemplates.ruleProviders[i].name) {
        _diversionTemplates.ruleProviders[i] = provider;
        found = true;
        break;
      }
    }
    if (found && name != provider.name) {
      final rewritten = _rewriteRuleProviderReferences(name, provider.name);
      Log.i(
        "DiversionTemplateManager: 规则提供者 \"$name\" 重命名为 "
        "\"${provider.name}\"，已同步改写 $rewritten 条 RULE-SET 规则",
      );
    }
  }

  static void updateRuleTemplate(String name, RuleTemplate template) {
    for (int i = 0; i < _diversionTemplates.ruleTemplates.length; ++i) {
      if (name == _diversionTemplates.ruleTemplates[i].name) {
        _diversionTemplates.ruleTemplates[i] = template;
        break;
      }
    }
  }

  static void updateProxyGroupTemplate(
    String name,
    ProxyGroupTemplate template,
  ) {
    for (int i = 0; i < _diversionTemplates.proxyGroupTemplates.length; ++i) {
      if (name == _diversionTemplates.proxyGroupTemplates[i].name) {
        _diversionTemplates.proxyGroupTemplates[i] = template;
        break;
      }
    }
  }

  static void reorderRuleProvider(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    if (oldIndex >= _diversionTemplates.ruleProviders.length ||
        newIndex >= _diversionTemplates.ruleProviders.length) {
      return;
    }
    var item = _diversionTemplates.ruleProviders.removeAt(oldIndex);
    _diversionTemplates.ruleProviders.insert(newIndex, item);
  }

  static void reorderRuleTemplates(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    if (oldIndex >= _diversionTemplates.ruleTemplates.length ||
        newIndex >= _diversionTemplates.ruleTemplates.length) {
      return;
    }
    var item = _diversionTemplates.ruleTemplates.removeAt(oldIndex);
    _diversionTemplates.ruleTemplates.insert(newIndex, item);
  }

  static void reorderProxyGroupTemplates(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    if (oldIndex >= _diversionTemplates.proxyGroupTemplates.length ||
        newIndex >= _diversionTemplates.proxyGroupTemplates.length) {
      return;
    }
    var item = _diversionTemplates.proxyGroupTemplates.removeAt(oldIndex);
    _diversionTemplates.proxyGroupTemplates.insert(newIndex, item);
  }
}
