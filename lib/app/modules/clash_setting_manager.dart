// ignore_for_file: unused_catch_stack, empty_catches

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:mclash/app/private/app_url_utils_private.dart';
import 'package:mclash/app/clash/clash_config.dart';
import 'package:mclash/app/clash/clash_http_api.dart';
import 'package:mclash/app/local_services/vpn_service.dart';
import 'package:mclash/app/modules/diversion_template_manager.dart';
import 'package:mclash/app/modules/profile_manager.dart';
import 'package:mclash/app/modules/setting_manager.dart';
import 'package:mclash/app/runtime/return_result.dart';
import 'package:mclash/app/utils/app_utils.dart';
import 'package:mclash/app/utils/did.dart';
import 'package:mclash/app/utils/file_utils.dart';
import 'package:mclash/app/utils/log.dart';
import 'package:mclash/app/utils/path_utils.dart';
import 'package:mclash/i18n/strings.g.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:path/path.dart' as path;

class ClashSettingManager {
  static final List<void Function()> onEventModeChanged = [];
  static const iNet4Address = "172.19.0.1/30";
  static const iNet6Address = "fdfe:dcbe:9876::1/126";
  static const dnsHijack = "0.0.0.0:53";
  static RawConfig _setting = defaultConfig();
  static final FileSaver _fileSaver = FileSaver();

  static Future<void> init() async {
    ClashHttpApi.getControlPort = () {
      return getControlPort();
    };
    ClashHttpApi.getSecret = () {
      return _setting.Secret ?? "";
    };
    _fileSaver.setSavePath(await PathUtils.serviceCoreSettingFilePath());
    await load();
    await initGeo();
  }

  static Future<void> initGeo() async {
    final homePath = await PathUtils.profileDir();
    // country.mmdb / geosite.dat 由 `assets/rules/` 直接提供（见 pubspec 里的说明），
    // 内核还需要的 ASN 库在这里落一份到 profile 目录，供内核侧按目录查找时直接命中。
    // （原实现还会落 geoip.zip / geosite.zip —— 那两个 zip 从来没有被解压过，
    //  内核按固定文件名找 country.mmdb/geosite.dat，zip 纯属冗余，已删除。）
    const fileNameList = ["ASN.mmdb"];

    try {
      for (final fileName in fileNameList) {
        final filePath = File(path.join(homePath, fileName));
        final isExists = await filePath.exists();
        if (isExists) {
          final stat = await filePath.stat();
          final dur = DateTime.now().difference(stat.modified);
          if (dur.inDays < 7) {
            continue;
          }
        }

        final data = await rootBundle.load('assets/datas/$fileName');
        List<int> bytes = data.buffer.asUint8List();
        await filePath.writeAsBytes(bytes, flush: true);
      }
    } catch (err) {
      Log.w("ClashSettingManager.initGeo exception ${err.toString()} ");
    }
  }

  static Future<String> getSecretFromDid() async {
    String secret = await Did.getDid();
    return secret.substring(8, 24);
  }

  static Future<void> reload() async {
    await load();
  }

  static RawTun defaultTun() {

    return RawTun.by(
      OverWrite: true,
      Enable: tunEnabledByUser(),
      Stack: ClashTunStack.gvisor.name,
      MTU: 1280,
      Inet4Address: [iNet4Address],
      Inet6Address: [iNet6Address],

      DNSHijack: [dnsHijack],
      DisableICMPForwarding: true,
    );
  }

  /// TUN 是否启用：**只**看用户选择（Android 上的 VpnService 本身就是 TUN，恒开）。
  ///
  /// 「关闭」= 不建虚拟网卡（只走系统代理）；「自动 / 强制」= 建虚拟网卡。
  static bool tunEnabledByUser() {
    if (Platform.isAndroid) {
      return true;
    }
    return SettingManager.getConfig().tunEnabled;
  }

  /// 每一轮生成内核配置前，把 TUN 开关同步到设置里。
  ///
  /// 不这样做的话，老安装的 `service_core_setting` 里存着 `tun.enable: true`
  /// （旧默认值），用户关掉开关也没用 —— 内核配置里还是 TUN。
  static void syncTunSwitch() {
    _setting.Tun ??= defaultTun();
    _setting.Tun?.Enable = tunEnabledByUser();
  }

  static RawDNS defaultDNS() {
    const List<String> nameServer = [
      "223.5.5.5",
      "119.29.29.29",
      "8.8.8.8",
      "8.8.4.4",
      "1.0.0.1",
      "1.1.1.1",
      "tls://223.5.5.5:853",
      "tls://8.8.8.8",
      "tls://8.8.4.4",
      "tls://1.0.0.1",
      "tls://1.1.1.1",
      "https://dns.alidns.com/dns-query#h3=true",
      "https://mozilla.cloudflare-dns.com/dns-query#DNS&h3=true",
      "quic://dns.adguard.com:784",
      "system",
    ];
    const List<String> defaultNameserver = [
      "223.5.5.5",
      "119.29.29.29",
      "8.8.8.8",
      "8.8.4.4",
      "1.0.0.1",
      "1.1.1.1",
      "system",
    ];
    const List<String> proxyServerNameserver = [
      "223.5.5.5",
      "119.29.29.29",
      "8.8.8.8",
      "8.8.4.4",
      "1.0.0.1",
      "1.1.1.1",
      "tls://8.8.4.4",
      "tls://1.1.1.1",
      "tls://223.5.5.5:853",
      "https://dns.alidns.com/dns-query#h3=true",
    ];
    const List<String> directNameServer = [
      "223.5.5.5",
      "119.29.29.29",
      "8.8.8.8",
      "8.8.4.4",
      "1.0.0.1",
      "1.1.1.1",
      "system",
    ];
    const List<String> fallback = [

    ];
    const List<String> fakeIPFilter = [
      "*.lan",
      "*.local",
      "time.*.com",
      "time.*.gov",
      "time.*.edu.cn",
      "time.*.apple.com",
      "time-ios.apple.com",
      "time1.*.com",
      "time2.*.com",
      "time3.*.com",
      "time4.*.com",
      "time5.*.com",
      "time6.*.com",
      "time7.*.com",
      "ntp.*.com",
      "ntp1.*.com",
      "ntp2.*.com",
      "ntp3.*.com",
      "ntp4.*.com",
      "ntp5.*.com",
      "ntp6.*.com",
      "ntp7.*.com",
      "*.time.edu.cn",
      "*.ntp.org.cn",
      "*.pool.ntp.org",
      "+.services.googleapis.cn",
      "+.push.apple.com",
      "time1.cloud.tencent.com",
      "localhost.ptlogin2.qq.com",
      "+.stun.*.*",
      "+.stun.*.*.*",
      "+.stun.*.*.*.*",
      "+.stun.*.*.*.*.*",
      "lens.l.google.com",
      "*.n.n.srv.nintendo.net",
      "+.stun.playstation.net",
      "xbox.*.*.microsoft.com",
      "*.*.xboxlive.com",
      "*.msftncsi.com",
      "*.msftconnecttest.com",
      "*.mcdn.bilivideo.cn",
      "+.bilibili.com",
      "+.bilicdn.com",
      "+.bilivideo.com",
      "+.market.xiaomi.com",
      "WORKGROUP",
    ];

    return RawDNS.by(
      OverWrite: true,
      Enable: true,
      PreferH3: true,
      IPv6: false,
      IPv6Timeout: 300,
      UseHosts: true,
      UseSystemHosts: true,
      RespectRules: false,
      NameServer: nameServer,
      Fallback: fallback,
      FallbackFilter: RawFallbackFilter.by(GeoIP: null),
      Listen: null,
      EnhancedMode: ClashDnsEnhancedMode.fakeIp.name,
      FakeIPRange: "${iNet4Address.split('/')[0]}/16",
      FakeIPFilter: fakeIPFilter,
      FakeIPFilterMode: ClashFakeIPFilterMode.blacklist.name,
      CacheAlgorithm: ClashDnsCacheAlgorithm.arc.name,
      DefaultNameserver: defaultNameserver,
      NameServerPolicy: {},
      ProxyServerNameserver: proxyServerNameserver,
      DirectNameServer: directNameServer,
      DirectNameServerFollowPolicy: false,
    );
  }

  static RawNTP defaultNTP() {
    return RawNTP.by(OverWrite: false, Enable: false);
  }

  static RawSniffer defaultSniffer() {
    return RawSniffer.by(OverWrite: false, Enable: false);
  }

  static RawTLS defaultTLS() {
    return RawTLS.by(
      OverWrite: false,
      Certificate: null,
      PrivateKey: null,
      CustomTrustCert: null,
    );
  }

  static RawExtensionGeoRuleset defaultRawExtensionRuleset() {
    return RawExtensionGeoRuleset.by(
      GeoSiteUrl:
          "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite",
      GeoIpUrl:
          "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geoip",
      AsnUrl:
          "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/asn",
      UpdateInterval: 2 * 24 * 3600,
      EnableProxy: true,
    );
  }

  static RawExtension defaultExtension() {
    const bypassDomainLocal = proxyBypassDomainsDefault;
    List<String> bypassDomainCN = Platform.isAndroid
        ? [
            "*zhihu.com",
            "*zhimg.com",
            "*jd.com",
            "100ime-iat-api.xfyun.cn",
            "*360buyimg.com",
          ]
        : [];

    return RawExtension.by(
      Ruleset: defaultRawExtensionRuleset(),
      Tun: RawExtensionTun.by(
        httpProxy: RawExtensionTunHttpProxy.by(
          Enable: false,
          BypassDomain: bypassDomainLocal + bypassDomainCN,
        ),
        perApp: RawExtensionTunPerApp.by(Enable: false),
      ),
      PprofAddr: null,
    );
  }

  /// 剔除 mihomo 已删除的配置键（否则内核每次启动都会打一行 error）。
  ///
  /// 目前只有 `global-client-fingerprint`：mihomo 1.19 删掉了这个全局键，
  /// 官方建议改为在**每个节点**上写 `client-fingerprint`（订阅下发的节点已经带了）。
  /// 老安装的设置文件里还留着它，加载时清掉，save() 会把 null 键剔除。
  static void stripDeprecatedKeys(RawConfig setting) {
    if (setting.GlobalClientFingerprint != null) {
      Log.i("ClashSettingManager: 移除已废弃的 global-client-fingerprint（mihomo 已删除该键，指纹改由节点自带的 client-fingerprint 决定）");
      setting.GlobalClientFingerprint = null;
    }
  }

  static RawConfig defaultConfig() {
    return RawConfig.by(
      Mode: ClashConfigsMode.rule.name,
      MixedPort: 7890,
      LogLevel: ClashLogLevel.error.name,
      ExternalController: "127.0.0.1:9090",
      IPv6: false,
      DNS: defaultDNS(),
      NTP: defaultNTP(),
      Sniffer: defaultSniffer(),
      TLS: defaultTLS(),
      Tun: defaultTun(),
      Extension: defaultExtension(),
      // 不再写 `global-client-fingerprint`：mihomo 1.19 已经**删除**这个键，
      // 每次启动都会打一行 error（用户贴的 service_core.log 里就有）：
      //   The `global-client-fingerprint` configuration is removed,
      //   please set `client-fingerprint` directly on the proxy instead
      // 现在按官方建议：指纹由**每个节点**自己的 `client-fingerprint` 决定
      // （订阅/面板下发的节点里已经带了 `client-fingerprint: chrome`）。
      DisableKeepAlive: false,
      KeepAliveIdle: 30,
      KeepAliveInterval: 30,
      FindProcessMode: ClashFindProcessMode.always.name,
    );
  }

  static RawConfig defaultConfigNoOverwrite() {
    return RawConfig.by(
      Mode: _setting.Mode,
      MixedPort: _setting.MixedPort,
      LogLevel: _setting.LogLevel,
      ExternalController: _setting.ExternalController,
      Secret: _setting.Secret,
      IPv6: _setting.IPv6,
      DNS: null,
      NTP: null,
      Sniffer: null,
      TLS: null,
      Tun: _setting.Tun,
      Extension: _setting.Extension,
      UnifiedDelay: _setting.UnifiedDelay,
      FindProcessMode: _setting.FindProcessMode,
      Profile: _setting.Profile,
    );
  }

  static Future<void> uninit() async {}

  static Future<void> save() async {
    final map = _setting.toJson();
    MapHelper.removeNullOrEmpty(map, false, false);
    await _fileSaver.saveAsJson(map);
  }

  static Future<ReturnResult<String>> getPatchContent(
    String profileId,
    bool overwrite,
    Map<String, String>? overwriteRule,
    Map<String, ProfileSettingProxyGroup>? overwriteProxyGroups,
    List<String>? appendRules,
  ) async {
    syncTunSwitch();
    if (Platform.isMacOS) {
      _setting.Tun?.Stack = ClashTunStack.gvisor.name;
    }
    _setting.DNS?.IPv6 = _setting.IPv6;
    if (_setting.IPv6 == true) {
      _setting.Tun?.Inet6Address = [iNet6Address];
    } else {
      _setting.Tun?.Inet6Address = null;
    }
    if (_setting.Tun?.Inet4Address == null ||
        _setting.Tun!.Inet4Address!.isEmpty ||
        !_setting.Tun!.Inet4Address!.first.contains("/")) {
      _setting.Tun?.Inet4Address = [iNet4Address];
    }
    final parts = _setting.Tun?.Inet4Address!.first.split('/');
    if (parts != null && parts.length == 2) {
      _setting.DNS?.FakeIPRange = "${parts[0]}/16";
    }

    _setting.OverWriteRuleProviders = false;
    _setting.OverWriteRules = false;
    _setting.OverWriteSubRules = false;
    _setting.Rules = null;
    _setting.RuleProviders = null;
    _setting.ProxyGroups = null;
    _setting.Extension?.ProfileStoreSelectedPrefix = profileId;
    if (overwriteRule != null && overwriteRule.isNotEmpty) {
      _setting.OverWriteRuleProviders = true;
      _setting.OverWriteRules = true;
      _setting.OverWriteSubRules = true;

      List<RuleProvider> newAllProviders = [];
      final allProviders = DiversionTemplateManager.getRuleProviders();
      final templates = DiversionTemplateManager.getRuleTemplates();
      Set<String> targets = {};
      for (var template in templates) {
        final target = overwriteRule[template.name];
        if (target != null && target.isNotEmpty) {
          targets.add(target);
          _setting.Rules ??= [];
          final providers = allProviders.where((ele) {
            return template.getProviders().contains(ele.name);
          });
          newAllProviders.addAll(providers);
          for (var rule in template.rules) {
            String ruleWithTarget = "";
            if (rule.endsWith(",NO-RESOLVE")) {
              ruleWithTarget =
                  "${rule.substring(0, rule.length - ",NO-RESOLVE".length)},$target,NO-RESOLVE";
            } else {
              ruleWithTarget = "$rule,$target";
            }

            if (!_setting.Rules!.contains(ruleWithTarget)) {
              _setting.Rules!.add(ruleWithTarget);
            }
          }
        }
      }
      if (newAllProviders.isNotEmpty) {
        _setting.RuleProviders ??= {};
        for (var provider in newAllProviders) {
          _setting.RuleProviders![provider.name] = provider.toJsonNoName();
        }
      }
      if (overwriteProxyGroups != null && overwriteProxyGroups.isNotEmpty) {
        _setting.OverWriteProxyGroups = true;
        final pgTemplates = DiversionTemplateManager.getProxyGroupTemplates();
        _setting.ProxyGroups ??= [];
        for (var template in pgTemplates) {
          final pg = overwriteProxyGroups[template.name];
          if (pg == null) {
            return ReturnResult(
              error: ReturnResultError(
                "${t.meta.proxyGroups} [${template.name}]: not exist",
              ),
            );
          }
          if (pg.proxies.isEmpty) {
            return ReturnResult(
              error: ReturnResultError(
                "${t.meta.proxyGroups} [${template.name}]->[${t.meta.proxyNodeList}] is empty",
              ),
            );
          }
          var newTemplate = template.clone();
          newTemplate.proxies = pg.proxies;
          _setting.ProxyGroups!.add(newTemplate.toJson());
        }
      }
    }
    _setting.Extension?.AppendRules = appendRules;
    if (overwrite) {
      final map = _setting.toJson();
      MapHelper.removeNullOrEmpty(map, true, true);

      const JsonEncoder encoder = JsonEncoder.withIndent('  ');
      String content = encoder.convert(map);
      return ReturnResult(data: content);
    }
    return ReturnResult(data: getPatchFinalContent());
  }

  static String getPatchFinalContent() {
    final setting = defaultConfigNoOverwrite();
    final map = setting.toJson();
    MapHelper.removeNullOrEmpty(map, true, true);
    const JsonEncoder encoder = JsonEncoder.withIndent('  ');
    String content = encoder.convert(map);
    return content;
  }

  static Future<ReturnResultError?> saveCorePatchFinal(
    String profileId,
    bool overwrite,
    Map<String, String>? overwriteRule,
    Map<String, ProfileSettingProxyGroup>? overwriteProxyGroups,
    List<String>? appendRules,
  ) async {
    final result = await getPatchContent(
      profileId,
      overwrite,
      overwriteRule,
      overwriteProxyGroups,
      appendRules,
    );
    if (result.error != null) {
      return result.error;
    }
    String filePath = await PathUtils.serviceCorePatchFinalPath();
    try {
      await File(filePath).writeAsString(result.data!, flush: true);
    } catch (err, stacktrace) {
      return ReturnResultError(err.toString());
    }
    return null;
  }

  static Future<void> load() async {
    String filePath = await PathUtils.serviceCoreSettingFilePath();
    var file = File(filePath);
    bool exists = await file.exists();
    if (exists) {
      try {
        String content = await file.readAsString();
        if (content.isNotEmpty) {
          await _load(content);
        }
      } catch (err, stacktrace) {
        Log.w("ClashSettingManager.load exception ${err.toString()} ");
      }
    } else {
      await save();
    }
    await _initFixed();
  }

  static Future<void> _load(String content) async {
    late RawConfig setting;
    try {
      var config = jsonDecode(content);
      setting = RawConfig.fromJson(config);
    } catch (err, stacktrace) {
      Log.w("ClashSettingManager.load exception ${err.toString()} ");
      _setting = defaultConfig();
      await save();
      return;
    }
    _setting = setting;
    // 清理已废弃的配置键：mihomo 1.19 删除了 `global-client-fingerprint`，
    // 老安装的设置文件里还留着它，内核每次启动都会报
    //   The `global-client-fingerprint` configuration is removed, …
    // 这里置空（save() 会把 null 键剔掉），下次写配置就不再出现；
    // 指纹改为由每个节点自己的 `client-fingerprint` 决定（订阅里已经带了）。
    stripDeprecatedKeys(_setting);
    _setting.MixedPort ??= 7890;
    _setting.DNS ??= defaultDNS();
    _setting.NTP ??= defaultNTP();
    _setting.Tun ??= defaultTun();

    _setting.Sniffer ??= defaultSniffer();
    _setting.TLS ??= defaultTLS();
    _setting.Extension ??= defaultExtension();
    if (_setting.Extension?.Tun.perApp.PackageIds != null) {
      _setting.Extension?.Tun.perApp.PackageIds!.removeWhere(
        (element) => element == AppUtils.getId(),
      );
    }

    if (_setting.Extension?.Ruleset.AsnUrl ==
        "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/asn") {
      _setting.Extension?.Ruleset.AsnUrl =
          "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/asn";
      await save();
    }
  }

  static Future<void> _initFixed() async {
    if (_setting.Secret == null || _setting.Secret!.isEmpty) {
      _setting.Secret = await getSecretFromDid();
    }
    _setting.ExternalUI = "";
    _setting.ExternalUIName = "";
    _setting.ExternalUIURL = "";
    _setting.ExternalControllerCors = null;
    _setting.Tun?.Device = AppUtils.getName();
    _setting.Tun?.AutoRedirect = false;
    _setting.Tun?.AutoRoute = !Platform.isAndroid;
    _setting.Tun?.AutoDetectInterface = Platform.isWindows;
    _setting.Profile = RawProfile.by(StoreSelected: true, StoreFakeIP: true);
    _setting.Extension?.RuntimeProfileSavePath =
        await PathUtils.serviceCoreRuntimeProfileFilePath();
  }

  /// 测试缝：直接设定当前模式（真实设置要落盘，测试不该碰文件）。
  @visibleForTesting
  static void debugSetMode(String mode) {
    _setting.Mode = mode;
  }

  static Future<ReturnResultError?> setConfigsMode(
    ClashConfigsMode mode,
  ) async {
    _setting.Mode = mode.name;
    await save();
    for (var callback in onEventModeChanged) {
      callback();
    }

    bool run = await VPNService.getStarted();
    if (!run) {
      return null;
    }
    return await ClashHttpApi.setConfigsMode(mode.name);
  }

  static ClashConfigsMode getConfigsMode() {
    for (var i = 0; i <= ClashConfigsMode.direct.index; ++i) {
      ClashConfigsMode type = ClashConfigsMode.values[i];
      if (type.name == _setting.Mode) {
        return type;
      }
    }

    return ClashConfigsMode.rule;
  }

  static RawConfig getConfig() {
    return _setting;
  }

  static Future<void> reset() async {
    _setting = defaultConfig();
    await _initFixed();
  }

  static int getControlPort() {
    final parts = _setting.ExternalController?.split(':');
    if (parts?.length == 2) {
      return int.tryParse(parts![1]) ?? 0;
    }
    return 0;
  }

  static int getMixedPort() {
    return _setting.MixedPort ?? 7890;
  }

  /// 改控制端口（Clash API）。被别的代理软件占用时由 VPNService 调用。
  static Future<void> setControlPort(int port) async {
    if (port <= 0 || getControlPort() == port) {
      return;
    }
    _setting.ExternalController = "127.0.0.1:$port";
    await save();
    Log.w("ClashSettingManager: 控制端口已改为 $port");
  }

  static Future<void> setMixedPort(int port) async {
    if (port <= 0 || _setting.MixedPort == port) {
      return;
    }
    _setting.MixedPort = port;
    await save();
    Log.w("ClashSettingManager: 混合端口已改为 $port");
  }
}
