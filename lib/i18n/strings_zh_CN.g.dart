///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import
// dart format off

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:slang/generated.dart';
import 'strings.g.dart';

// Path: <root>
class TranslationsZhCn with BaseTranslations<AppLocale, Translations> implements Translations {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	TranslationsZhCn({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: AppLocale.zhCn,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <zh-CN>.
	final TranslationMetadata<AppLocale, Translations> _meta;
	@override TranslationMetadata<AppLocale, Translations> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key);

	late final TranslationsZhCn _root = this; // ignore: unused_field

	@override 
	TranslationsZhCn $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => TranslationsZhCn(meta: meta ?? this.$meta);

	// Translations
	@override late final Translations$BackupAndSyncWebdavScreen$zh_CN BackupAndSyncWebdavScreen = Translations$BackupAndSyncWebdavScreen$zh_CN.internal(_root);
	@override late final Translations$LaunchFailedScreen$zh_CN LaunchFailedScreen = Translations$LaunchFailedScreen$zh_CN.internal(_root);
	@override late final Translations$PerAppAndroidScreen$zh_CN PerAppAndroidScreen = Translations$PerAppAndroidScreen$zh_CN.internal(_root);
	@override late final Translations$UserAgreementScreen$zh_CN UserAgreementScreen = Translations$UserAgreementScreen$zh_CN.internal(_root);
	@override late final Translations$NetCheckScreen$zh_CN NetCheckScreen = Translations$NetCheckScreen$zh_CN.internal(_root);
	@override late final Translations$VersionUpdateScreen$zh_CN VersionUpdateScreen = Translations$VersionUpdateScreen$zh_CN.internal(_root);
	@override late final Translations$loginScreen$zh_CN loginScreen = Translations$loginScreen$zh_CN.internal(_root);
	@override late final Translations$main$zh_CN main = Translations$main$zh_CN.internal(_root);
	@override late final Translations$meta$zh_CN meta = Translations$meta$zh_CN.internal(_root);
	@override late final Translations$permission$zh_CN permission = Translations$permission$zh_CN.internal(_root);
	@override late final Translations$tls$zh_CN tls = Translations$tls$zh_CN.internal(_root);
	@override late final Translations$tun$zh_CN tun = Translations$tun$zh_CN.internal(_root);
	@override late final Translations$dns$zh_CN dns = Translations$dns$zh_CN.internal(_root);
	@override late final Translations$sniffer$zh_CN sniffer = Translations$sniffer$zh_CN.internal(_root);
	@override late final Translations$profilePatchMode$zh_CN profilePatchMode = Translations$profilePatchMode$zh_CN.internal(_root);
	@override String sendOrReceiveNotMatch({required Object p}) => '请使用[${p}]';
	@override String targetConnectFailed({required Object p}) => '连接[${p}]失败,请确保设备在同一个局域网内';
	@override String get edgeRuntimeNotInstalled => '当前设备尚未安装Edge WebView2运行时,无法展示页面,请下载安装Edge WebView2运行时(x64)后,重启App再试';
	@override Map<String, String> get locales => {
		'en': 'English',
		'zh-CN': '简体中文',
		'zh-TW': '繁體中文',
		'ja': '日本語',
		'ko': '한국어',
		'ar': 'عربي',
		'ru': 'Русский',
		'fa': 'فارسی',
		'es': 'Español',
	};
	@override Map<String, String> get countries => {
		'HK': '香港',
		'TW': '台湾',
		'MO': '澳门',
		'CN': '中国',
		'JP': '日本',
		'KR': '韩国',
		'SG': '新加坡',
		'MY': '马来西亚',
		'TH': '泰国',
		'VN': '越南',
		'PH': '菲律宾',
		'ID': '印尼',
		'KH': '柬埔寨',
		'US': '美国',
		'CA': '加拿大',
		'MX': '墨西哥',
		'GB': '英国',
		'DE': '德国',
		'FR': '法国',
		'NL': '荷兰',
		'RU': '俄罗斯',
		'IT': '意大利',
		'ES': '西班牙',
		'CH': '瑞士',
		'SE': '瑞典',
		'NO': '挪威',
		'FI': '芬兰',
		'DK': '丹麦',
		'PL': '波兰',
		'AT': '奥地利',
		'IE': '爱尔兰',
		'UA': '乌克兰',
		'TR': '土耳其',
		'PT': '葡萄牙',
		'CZ': '捷克',
		'RO': '罗马尼亚',
		'BE': '比利时',
		'GR': '希腊',
		'HU': '匈牙利',
		'IL': '以色列',
		'AE': '阿联酋',
		'SA': '沙特',
		'EG': '埃及',
		'ZA': '南非',
		'NG': '尼日利亚',
		'AU': '澳大利亚',
		'NZ': '新西兰',
		'BR': '巴西',
		'AR': '阿根廷',
		'CL': '智利',
		'CO': '哥伦比亚',
		'IN': '印度',
		'PK': '巴基斯坦',
		'XX': '其他',
	};
	@override late final Translations$meScreen$zh_CN meScreen = Translations$meScreen$zh_CN.internal(_root);
	@override late final Translations$homeScreen$zh_CN homeScreen = Translations$homeScreen$zh_CN.internal(_root);
	@override late final Translations$nodesScreen$zh_CN nodesScreen = Translations$nodesScreen$zh_CN.internal(_root);
	@override late final Translations$nodeAuto$zh_CN nodeAuto = Translations$nodeAuto$zh_CN.internal(_root);
	@override late final Translations$accountBlock$zh_CN accountBlock = Translations$accountBlock$zh_CN.internal(_root);
	@override late final Translations$entitlementMsg$zh_CN entitlementMsg = Translations$entitlementMsg$zh_CN.internal(_root);
	@override late final Translations$devicesScreen$zh_CN devicesScreen = Translations$devicesScreen$zh_CN.internal(_root);
	@override late final Translations$sysProxySheet$zh_CN sysProxySheet = Translations$sysProxySheet$zh_CN.internal(_root);
	@override late final Translations$logScreen$zh_CN logScreen = Translations$logScreen$zh_CN.internal(_root);
	@override late final Translations$trayShell$zh_CN trayShell = Translations$trayShell$zh_CN.internal(_root);
	@override late final Translations$ordersScreen$zh_CN ordersScreen = Translations$ordersScreen$zh_CN.internal(_root);
	@override late final Translations$payment$zh_CN payment = Translations$payment$zh_CN.internal(_root);
	@override late final Translations$planScreen$zh_CN planScreen = Translations$planScreen$zh_CN.internal(_root);
	@override late final Translations$authScreen$zh_CN authScreen = Translations$authScreen$zh_CN.internal(_root);
	@override late final Translations$updatePrompt$zh_CN updatePrompt = Translations$updatePrompt$zh_CN.internal(_root);
	@override late final Translations$clearData$zh_CN clearData = Translations$clearData$zh_CN.internal(_root);
	@override late final Translations$apiError$zh_CN apiError = Translations$apiError$zh_CN.internal(_root);
	@override late final Translations$subNotice$zh_CN subNotice = Translations$subNotice$zh_CN.internal(_root);
	@override late final Translations$settingItems$zh_CN settingItems = Translations$settingItems$zh_CN.internal(_root);
	@override late final Translations$tunScreen$zh_CN tunScreen = Translations$tunScreen$zh_CN.internal(_root);
}

// Path: BackupAndSyncWebdavScreen
class Translations$BackupAndSyncWebdavScreen$zh_CN implements Translations$BackupAndSyncWebdavScreen$en {
	Translations$BackupAndSyncWebdavScreen$zh_CN.internal(this._root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override String get webdavServerUrl => '服务器地址';
	@override String get webdavRequired => '不能为空';
	@override String get webdavLoginFailed => '登录失败:';
	@override String get webdavListFailed => '获取文件列表失败:';
}

// Path: LaunchFailedScreen
class Translations$LaunchFailedScreen$zh_CN implements Translations$LaunchFailedScreen$en {
	Translations$LaunchFailedScreen$zh_CN.internal(this._root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override String get invalidProcess => '应用启动失败[无效的进程名称],请重新安装应用到独立目录';
	@override String get invalidProfile => '应用启动失败[访问配置文件失败],请重新安装应用';
	@override String get invalidVersion => '应用启动失败[无效版本],请重新安装应用';
	@override String get systemVersionLow => '应用启动失败[系统版本过低]';
	@override String get invalidInstallPath => '无效的安装路径,请重新安装到有效路径';
}

// Path: PerAppAndroidScreen
class Translations$PerAppAndroidScreen$zh_CN implements Translations$PerAppAndroidScreen$en {
	Translations$PerAppAndroidScreen$zh_CN.internal(this._root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override String get title => '分应用代理';
	@override String get whiteListMode => '白名单模式';
	@override String get whiteListModeTip => '启用后:仅代理已勾选的App;未启用:仅代理未勾选的App';
}

// Path: UserAgreementScreen
class Translations$UserAgreementScreen$zh_CN implements Translations$UserAgreementScreen$en {
	Translations$UserAgreementScreen$zh_CN.internal(this._root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override String get privacyFirst => '您的隐私很重要';
	@override String get agreeAndContinue => '接受并继续';
}

// Path: NetCheckScreen
class Translations$NetCheckScreen$zh_CN implements Translations$NetCheckScreen$en {
	Translations$NetCheckScreen$zh_CN.internal(this._root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override String get enterDomain => '请输入域名';
	@override String get checking => '检测中...';
	@override String aQueryFailed({required Object p}) => 'A 查询失败: ${p}';
	@override String aaaaQueryFailed({required Object p}) => 'AAAA 查询失败: ${p}';
	@override String get success => '成功';
	@override String get failed => '失败';
	@override String get suspectedPollution => '疑似被污染';
	@override String get domainLabel => '域名';
	@override String get checkButton => '检测';
	@override String get dnsSection => '1. DNS查询';
	@override String get directHttpSection => '2. HTTP (经由TUN,请先开启TUN)';
	@override String proxyHttpSection({required Object p}) => '3. HTTP (经由代理,端口:${p})';
	@override String get tunNotEnabled => 'TUN 未开启';
	@override String get routeTableSection => '4. 路由表';
}

// Path: VersionUpdateScreen
class Translations$VersionUpdateScreen$zh_CN implements Translations$VersionUpdateScreen$en {
	Translations$VersionUpdateScreen$zh_CN.internal(this._root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override String versionReady({required Object p}) => '新版本[${p}]已就绪';
	@override String get update => '重启更新';
	@override String get cancel => '暂不更新';
}

// Path: loginScreen
class Translations$loginScreen$zh_CN implements Translations$loginScreen$en {
	Translations$loginScreen$zh_CN.internal(this._root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override String get login => '登录';
	@override String get register => '注册账号';
	@override String get forgotPassword => '忘记密码';
	@override String get provider => '服务商(机场)';
	@override String get providerName => '${_root.loginScreen.provider}编码/别名/URL';
	@override String get account => '账号';
	@override String get email => '邮箱';
	@override String get password => '密码';
}

// Path: main
class Translations$main$zh_CN implements Translations$main$en {
	Translations$main$zh_CN.internal(this._root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override late final Translations$main$tray$zh_CN tray = Translations$main$tray$zh_CN.internal(_root);
}

// Path: meta
class Translations$meta$zh_CN implements Translations$meta$en {
	Translations$meta$zh_CN.internal(this._root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override String get enable => '启用';
	@override String get disable => '禁用';
	@override String get open => '打开';
	@override String get close => '关闭';
	@override String get quit => '退出';
	@override String get add => '添加';
	@override String get remove => '删除';
	@override String get removeConfirm => '确认删除?';
	@override String get edit => '编辑';
	@override String get view => '查看';
	@override String get remark => '备注';
	@override String get byDefault => '默认';
	@override String get more => '更多';
	@override String get tips => '提示';
	@override String get selectAll => '全选';
	@override String get copy => '拷贝';
	@override String get paste => '粘贴';
	@override String get cut => '剪切';
	@override String get save => '保存';
	@override String get ok => '确定';
	@override String get cancel => '取消';
	@override String get faq => '常见问题';
	@override String get doc => '文档';
	@override String get htmlTools => 'HTML工具集';
	@override String get download => '下载';
	@override String get loading => '加载中...';
	@override String get days => '天';
	@override String get hours => '时';
	@override String get minutes => '分';
	@override String get seconds => '秒';
	@override String get milliseconds => '毫秒';
	@override String get search => '搜索';
	@override String get searchNodeHint => '筛选节点（名称或协议）';
	@override String get connect => '连接';
	@override String get disconnect => '断开';
	@override String get connected => '已连接';
	@override String get disconnected => '未连接';
	@override String get connecting => '连接中';
	@override String get connectTimeout => '连接超时';
	@override String get timeout => '超时';
	@override String get latencyTest => '延迟检测';
	@override String get networkCheck => '网络检测';
	@override String get language => '语言';
	@override String get next => '下一步';
	@override String get done => '完成';
	@override String get apply => '应用';
	@override String get refresh => '刷新';
	@override String get update => '更新';
	@override String get updateInterval => '更新时间间隔';
	@override String get updateInterval5mTips => '最小:5m';
	@override String get updateIntervalPreferByProfile => '优先使用服务商(机场)设置';
	@override String updateFailed({required Object p}) => '更新失败:${p}';
	@override String get none => '无';
	@override String get reset => '重置';
	@override String get authentication => '授权';
	@override String get user => '用户';
	@override String get account => '账号';
	@override String get password => '密码';
	@override String get decryptPassword => '解密密码';
	@override String get required => '必填';
	@override String get go => '继续';
	@override String get other => '其他';
	@override String get dns => 'DNS';
	@override String get url => 'URL';
	@override String get urlInvalid => 'URL无效';
	@override String get copyUrl => '拷贝链接';
	@override String get openUrl => '打开链接';
	@override String get coreSettingTips => '注意:修改配置后,需要重新连接才会生效';
	@override String get overwrite => '覆写';
	@override String get overwriteAppend => '追加覆写';
	@override String get overwriteTips => '原始配置<-自定义覆写<-App覆写';
	@override String get noOverwrite => '不覆写';
	@override String get diversionTemplates => '分流模板';
	@override String get ruleProviders => '规则提供者';
	@override String get ruleTemplates => '规则模板';
	@override String get proxyGroupsTemplates => '代理组模板';
	@override String get proxyGroups => '代理组';
	@override String get proxyNodeList => '代理节点列表';
	@override String proxyNodeFailure({required Object p}) => '下列代理节点已失效,已自动移除:${p}';
	@override String get externalController => '外部控制';
	@override String get secret => 'Secret';
	@override String get tcpConcurrent => 'TCP并发握手';
	@override String get globalClientFingerprint => 'TLS全局指纹';
	@override String get allowLanAccess => '局域网设备接入';
	@override String get mixedPort => '混合代理端口';
	@override String get logLevel => '日志等级';
	@override String get findProcessMode => '进程匹配模式';
	@override String get tcpkeepAliveInterval => 'TCP保活时间间隔';
	@override String get delayTestUrl => '延迟测试URL';
	@override String get delayTestTimeout => '延迟测试超时(ms)';
	@override String get tun => 'TUN';
	@override String get ntp => 'NTP';
	@override String get tls => 'TLS';
	@override String get geoDownloadByProxy => '使用代理下载Geo RuleSet';
	@override String get geoRulesetTips => 'Geosite/Geoip 会被转换成 对应的RuleSet';
	@override String get sniffer => '嗅探';
	@override String get userAgent => 'UserAgent';
	@override String get launchAtStartup => '开机启动';
	@override String get launchAtStartupRunAsAdmin => '请以管理员身份重新启动Mclash';
	@override String get tunModeRunAsAdmin => 'TUN模式需要系统管理员权限,请以管理员身份重新启动应用';
	@override String get portableMode => '便携模式';
	@override String get portableModeDisableTips => '如需退出便携模式,请退出[mclash]后,手动删除[mclash.exe]同目录下的[portable]文件夹即可';
	@override String get autoConnectAfterLaunch => '启动后自动连接';
	@override String get autoConnectAtBoot => '系统启动后自动连接';
	@override String get autoConnectAtBootTips => '需要系统支持,部分系统可能还需要开启[自启动]';
	@override String get hideAfterLaunch => '启动后隐藏窗口';
	@override String get autoSetSystemProxy => '连接后自动设置系统代理';
	@override String get bypassSystemProxy => '允许绕过系统代理的域名';
	@override String get excludeFromRecent => '从[最近任务]中隐藏';
	@override String get wakeLock => '唤醒锁';
	@override String get hideDockIcon => '隐藏Dock图标';
	@override String get showTrayTraffic => '托盘上显示流量信息';
	@override String get website => '官网';
	@override String get rule => '规则';
	@override String get global => '全局';
	@override String get direct => '直连';
	@override String get qrcode => '二维码';
	@override String get qrcodeTooLong => '文本过长,无法展示';
	@override String get qrcodeShare => '分享二维码';
	@override String get qrcodeScan => '扫描二维码';
	@override String get qrcodeScanResult => '扫描结果';
	@override String get backupAndSync => '备份与同步';
	@override String get export => '导出';
	@override String get send => '发送';
	@override String get sendConfirm => '确认发送?';
	@override String get log => '日志';
	@override String get coreLog => '核心日志';
	@override String get appLog => '应用日志';
	@override String get core => '核心';
	@override String get help => '帮助';
	@override String get tutorial => '使用教程';
	@override String get board => '面板';
	@override String get boardOnline => '使用在线面板';
	@override String get boardOnlineUrl => '在线面板URL';
	@override String get boardLocalPort => '本地面板端口';
	@override String get alwayOnVPN => '始终开启连接';
	@override String get disableFontScaler => '禁用字体缩放';
	@override String get autoOrientation => '跟随屏幕旋转';
	@override String get restartTakesEffect => '重启生效';
	@override String get reconnectTakesEffect => '重新连接后生效';
	@override String get runtimeProfile => '运行时配置';
	@override String get willCompleteAfterRebootInstall => '请重启设备,以便完成系统扩展安装';
	@override String get requestNeedsUserApproval => '1. 请在[系统设置]-[隐私与安全性]里[允许] Mclash安装系统扩展\n2. :[系统设置]-[通用]-[登录项与扩展-网络扩展]启用[mclashServiceSE]\n完成后重新连接';
	@override String get FullDiskAccessPermissionRequired => '请在[系统设置]-[隐私与安全性]-[完全磁盘访问权限]里开启mclashServiceSE权限后,重新连接';
	@override String get proxy => '代理';
	@override String get theme => '主题';
	@override String get tvMode => 'TV模式';
	@override String get autoUpdate => '自动更新';
	@override String get updateChannel => '自动更新通道';
	@override String hasNewVersion({required Object p}) => '更新版本 ${p}';
	@override String get autoDownloadPkg => '自动下载更新包';
	@override String get devOptions => '开发者选项';
	@override String get about => '关于';
	@override String get name => '名称';
	@override String get version => '版本';
	@override String get sort => '排序';
	@override String get share => '分享';
	@override String get importFromClipboard => '从剪贴板导入';
	@override String get exportToClipboard => '导出到剪贴板';
	@override String get server => '服务器';
	@override String get port => '端口';
	@override String get donate => '捐助';
	@override String get setting => '设置';
	@override String get settingCore => '核心设置';
	@override String get settingApp => '应用设置';
	@override String get coreOverwrite => '核心覆写';
	@override String get iCloud => 'iCloud';
	@override String get webdav => 'Webdav';
	@override String get lanSync => '局域网同步';
	@override String get lanSyncNotQuitTips => '同步完成前请勿退出此界面';
	@override String get deviceNoSpace => '磁盘空间不足';
	@override String get hideSystemApp => '隐藏系统应用';
	@override String get hideAppIcon => '隐藏应用图标';
	@override String get openDir => '打开文件目录';
	@override String get type => '类型';
	@override String fileNotExist({required Object p}) => '文件不存在:${p}';
	@override String get buyProfile => '购买配置';
	@override String get myProfiles => '我的配置';
	@override String get profileEdit => '编辑配置';
	@override String get profileNeedActive => '请先将本配置设置为当前配置,并开启连接/重新连接';
	@override String profileUrlOrContent({required Object p}) => '${p}配置链接';
	@override String get tabHome => '主页';
	@override String get tabNodes => '节点列表';
	@override String get tabPlans => '套餐购买';
	@override String get tabMe => '我的';
}

// Path: permission
class Translations$permission$zh_CN implements Translations$permission$en {
	Translations$permission$zh_CN.internal(this._root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override String get camera => '摄像头';
	@override String get screen => '屏幕录制';
	@override String get appQuery => '获取应用列表';
	@override String request({required Object p}) => '开启[${p}]权限';
	@override String requestNeed({required Object p}) => '请开启[${p}]权限';
}

// Path: tls
class Translations$tls$zh_CN implements Translations$tls$en {
	Translations$tls$zh_CN.internal(this._root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override String get certificate => '证书';
	@override String get privateKey => '私钥';
	@override String get customTrustCert => '自定义证书';
}

// Path: tun
class Translations$tun$zh_CN implements Translations$tun$en {
	Translations$tun$zh_CN.internal(this._root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override String get stack => '网络栈';
	@override String get inet4Address => 'IPv4地址段';
	@override String get dnsHijack => 'DNS劫持';
	@override String get strictRoute => '严格路由';
	@override String get tunDefaultRoute => '默认路由';
	@override String get icmpForward => 'ICMP 转发';
	@override String get allowBypass => '允许应用绕过VPN';
	@override String get appendHttpProxy => '附加HTTP代理到VPN';
	@override String get bypassHttpProxyDomain => '允许绕过HTTP代理的域名';
}

// Path: dns
class Translations$dns$zh_CN implements Translations$dns$en {
	Translations$dns$zh_CN.internal(this._root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override String get listen => '监听地址';
	@override String get fakeIp => 'fake-ip';
	@override String get fallback => 'Fallback';
	@override String get preferH3 => 'DoH H3优先';
	@override String get useHosts => '使用Hosts';
	@override String get useSystemHosts => '使用系统Hosts';
	@override String get enhancedMode => '增强模式';
	@override String get fakeIPFilterMode => '${_root.dns.fakeIp} 过滤模式';
	@override String get fakeIPFilter => '${_root.dns.fakeIp} 过滤';
	@override String get respectRules => '遵守[rules]规则';
	@override String get nameServer => '域名解析服务器';
	@override String get defaultNameServer => '${_root.meta.byDefault} ${_root.dns.nameServer}';
	@override String get proxyNameServer => '${_root.meta.proxy} ${_root.dns.nameServer}';
	@override String get directNameServer => '${_root.meta.direct} ${_root.dns.nameServer}';
	@override String get fallbackNameServer => '${_root.dns.fallback} ${_root.dns.nameServer}';
	@override String get fallbackGeoIp => '${_root.dns.fallback} GeoIp';
	@override String get fallbackGeoIpCode => '${_root.dns.fallback} GeoIp 代码';
}

// Path: sniffer
class Translations$sniffer$zh_CN implements Translations$sniffer$en {
	Translations$sniffer$zh_CN.internal(this._root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override String get overrideDest => '覆盖';
}

// Path: profilePatchMode
class Translations$profilePatchMode$zh_CN implements Translations$profilePatchMode$en {
	Translations$profilePatchMode$zh_CN.internal(this._root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override String get currentSelected => '当前选择';
	@override String get overwrite => '内置-覆写';
	@override String get noOverwrite => '内置-不覆写';
}

// Path: meScreen
class Translations$meScreen$zh_CN implements Translations$meScreen$en {
	Translations$meScreen$zh_CN.internal(this._root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override String get accountBalance => '账户余额';
	@override String get expireAt => '到期时间';
	@override String get remainingDays => '剩余天数';
	@override String get deviceCount => '设备数';
	@override String get myOrders => '我的订单';
	@override String get deviceManagement => '设备管理';
	@override String get changePassword => '修改密码';
	@override String get clearLocalData => '清除本地数据（卸载前使用）';
	@override String get profileManagementDev => '配置档管理（开发者）';
	@override String get tunAdapter => 'TUN 虚拟网卡';
	@override String get checkUpdate => '检查更新';
	@override String get retry => '重试';
	@override String get loadFailed => '账号信息读取失败：登录可能已过期或网络不通。\n请点右上角刷新重试；仍失败请重新登录。';
	@override String get logoutConfirm => '确认退出登录？';
	@override String get boardNoKernel => '面板显示的是内核的实时数据（连接、流量、规则命中）。\n\n当前内核没有运行，面板会是一个空壳。\n点「确定」仍然打开，点「取消」先去主页连接。';
	@override String get boardOpened => '已在浏览器中打开面板；在里面换节点 / 切规则-全局，App 会自动跟随（约 5 秒内）';
}

// Path: homeScreen
class Translations$homeScreen$zh_CN implements Translations$homeScreen$en {
	Translations$homeScreen$zh_CN.internal(this._root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override String expiresOn({required Object date}) => '到期 ${date}';
	@override String devicesText({required Object text}) => '设备 ${text}';
	@override String get upgrade => '升级';
	@override String get quickCountries => '快速筛选国家';
	@override String nodeCount({required Object count}) => '${count} 个节点';
	@override String get autoBestTip => '在所有国家的节点里挑延迟最低的可用节点（自动模式）';
	@override String get autoBest => '自动最优';
	@override String pickCountryTip({required Object label}) => '自动选择「${label}」延迟最低的可用节点，并固定使用它';
	@override String get autoNoBetter => '已在自动模式（没有找到更优的可用节点）';
	@override String switchedBest({required Object name}) => '已切换到最优节点：${name}';
	@override String switchedCountry({required Object country, required Object node, required Object ms}) => '已切换到 ${country} 最快节点：${node}${ms}';
	@override String filterCountryFailed({required Object country, required Object err}) => '已筛选 ${country}；切换节点失败：${err}';
	@override String deviceFullCount({required Object used, required Object limit}) => '当前设备 ${used}/${limit} 台\n\n';
	@override String get deviceFullUpgradeHint => '升级设备数量后可立即恢复连接（推荐）；也可以先删除不常用的设备腾出名额。';
	@override String get later => '稍后';
	@override String get upgradeDeviceCount => '升级设备数量';
	@override String get cannotConnect => '无法连接';
	@override String get freshnessNever => '尚未同步 · 点击刷新';
	@override String get freshnessJustNow => '刚刚更新 · 点右侧管理设备';
	@override String freshnessMinutes({required Object minutes}) => '${minutes} 分钟前更新 · 点右侧管理设备';
	@override String freshnessStale({required Object minutes}) => '${minutes} 分钟前更新 · 点击刷新';
	@override String get subscriptionAutoSync => '订阅自动同步';
	@override String get connecting => '正在连接…';
	@override String get disconnecting => '正在断开…';
	@override String get tapToDisconnect => '点击开关断开';
	@override String get tapToConnect => '点击开关连接';
	@override String get currentNode => '当前节点';
	@override String get noNodeSelected => '未选择节点';
	@override String get switchAction => '切换';
	@override String get realtimeSpeed => '实时速度';
	@override String get totalTraffic => '累计流量';
	@override String get subSyncedNotReady => '订阅已下载，但配置档还没就绪，请稍后再试。';
	@override String get noPlan => '该账号暂无可用套餐，请先购买套餐。';
	@override String get loginExpired => '登录已失效，请重新登录。';
	@override String get syncingWait => '正在同步订阅，请稍候再试。';
	@override String syncFailedNetwork({required Object message}) => '订阅同步失败：${message}\n请检查网络后重试。';
	@override String get syncFailed => '订阅同步失败，请稍后重试。';
	@override String get resetProxy => '重设';
	@override String latencySuffix({required Object ms}) => '（${ms}ms）';
}

// Path: nodesScreen
class Translations$nodesScreen$zh_CN implements Translations$nodesScreen$en {
	Translations$nodesScreen$zh_CN.internal(this._root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override String updatedCount({required Object count}) => '订阅已更新：${count} 个节点';
	@override String updateFailed({required Object message}) => '更新失败：${message}';
	@override String get updateFailedNetwork => '更新失败，请检查网络';
	@override String testDone({required Object ok, required Object fail}) => '测速完成：${ok} 个可用，${fail} 个连不上（可能已下线）';
	@override String switchedTo({required Object name}) => '已切换到 ${name}';
	@override String switchFailed({required Object message}) => '切换失败：${message}\n（节点切换需要内核运行，请先打开连接开关）';
	@override String selectedAfterConnect({required Object name}) => '已选择 ${name}（连接后生效）';
	@override String get title => '节点列表';
	@override String get searchNode => '搜索节点';
	@override String get sortByLatency => '按延迟排序';
	@override String get updateSubscription => '更新订阅';
	@override String get viewByGroup => '按代理组查看';
	@override String get testAll => '全部测速';
	@override String get searchHint => '搜索节点 / 国家 / 协议';
	@override String get emptyNoNodes => '还没有可用节点。\n订阅会自动同步；若刚登录，请稍候或点下方重试。';
	@override String get emptyNoMatch => '没有匹配的节点。';
	@override String get reload => '重新加载';
	@override String get currentInUse => '当前选中（正在使用的节点）';
	@override String get current => '当前';
	@override String get notTested => '未测到（待重载内核）';
	@override String get timeout => '超时';
	@override String get clear => '清空';
	@override String get selectNode => '选择节点';
	@override String get emptyNoKernel => '还没有可用节点。\n请先在主页打开连接开关。';
	@override String get openFullList => '打开完整节点列表（搜索 / 测速 / 分组）';
}

// Path: nodeAuto
class Translations$nodeAuto$zh_CN implements Translations$nodeAuto$en {
	Translations$nodeAuto$zh_CN.internal(this._root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override String get kernelStateUnavailable => '暂时读不到内核的节点状态，稍后会自动重试';
	@override String backToFixedNode({required Object fixed}) => '已回到固定节点：${fixed}';
	@override String get noUsableNodePickOne => '没有找到可用节点，请在「节点列表」里手动换一个';
	@override String get noUsableNodeTryOne => '没有找到可用的节点，请在「节点列表」里手动换一个试试';
	@override String autoConnectedBest({required Object bestNode, required Object bestMs}) => '已自动连接最优节点：${bestNode}（${bestMs} ms）';
	@override String get currentNodeUnreachable => '当前节点无法访问外网，正在自动换一个…';
	@override String autoSwitchedToUsable({required Object target}) => '已自动切换到可用节点：${target}';
	@override String newNodesReloading({required Object missing}) => '订阅里有 ${missing} 个新节点还没进内核，正在重载…';
	@override String get kernelReloadedRetest => '内核已按新订阅重载，请再点一次测速';
}

// Path: accountBlock
class Translations$accountBlock$zh_CN implements Translations$accountBlock$en {
	Translations$accountBlock$zh_CN.internal(this._root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override String quotaFull({required Object used, required Object limit}) => '设备名额已用满（${used}/${limit}）：本机仍在授权范围内，可正常连接。如需再添加新设备，请升级设备数量或先删除不用的设备。';
	@override String get banFallback => '您的账号已被禁用，无法继续使用服务。';
	@override String get titleExpired => '套餐已到期';
	@override String get titleDeviceFull => '设备数量已达上限';
	@override String get titleAccountDisabled => '账号已被禁用';
	@override String get titlePlanDisabled => '套餐已被禁用';
	@override String get titleNoPlan => '尚未开通套餐';
	@override String get titleDeviceRemoved => '本设备已被移除';
	@override String get titleServiceUnavailable => '服务暂时不可用';
	@override String get textExpired => '您的套餐已到期，购买套餐后即可继续畅连全球节点。';
	@override String textDeviceFull({required Object used, required Object limit}) => '服务端判定本机已超出套餐设备数上限（${used}/${limit}），暂时无法连接。可在「我的 - 设备管理」中删除不常用设备，或升级更高设备数的套餐。';
	@override String get textAccountDisabled => '您的账号已被禁用，无法使用服务。如有疑问，请联系客服。';
	@override String get textPlanDisabled => '您的套餐已被禁用或状态异常，无法连接。如有疑问，请联系客服。';
	@override String get textNoPlan => '您还没有开通套餐，开通后即可畅连全球节点。';
	@override String get textDeviceRemoved => '本设备已被移除并踢下线，请重新登录。';
	@override String get textServiceUnavailable => '服务暂时不可用，请稍后重试；若持续出现请截图联系客服。';
	@override String remainingDays({required Object days}) => '剩余 ${days} 天';
	@override String deviceUsage({required Object used, required Object limit}) => '设备 ${used}/${limit}';
}

// Path: entitlementMsg
class Translations$entitlementMsg$zh_CN implements Translations$entitlementMsg$en {
	Translations$entitlementMsg$zh_CN.internal(this._root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override String get tamperedTitle => '授权状态异常';
	@override String get tamperedClock => '检测到系统时间被回拨（或本地授权数据被改动），请联网完成一次校验后再连接。';
	@override String get tamperedLocal => '本地授权数据已损坏或被改动，请联网完成一次校验后再连接。';
	@override String get needVerifyTitle => '需要联网校验';
	@override String get needVerifyFirst => '无法确认套餐状态：请先连接网络并登录账号，完成一次校验后再连接。';
	@override String get needVerifyRetry => '无法确认套餐状态，请联网后重试。';
	@override String get verifyFailedTitle => '无法校验套餐状态';
	@override String get verifyFailedText => '已超过校验宽限期且无法连接服务器，请检查网络后重试（如刚续费，请重新登录）。';
	@override String get restrictedTitle => '账号受限';
	@override String get restrictedFallback => '账号或套餐已被禁用，无法连接。';
	@override String get expiredTitle => '套餐已到期';
	@override String expiredText({required Object date}) => '您的套餐已于 ${date} 到期，本地订阅配置已清除。续费后重新登录即可恢复。';
}

// Path: devicesScreen
class Translations$devicesScreen$zh_CN implements Translations$devicesScreen$en {
	Translations$devicesScreen$zh_CN.internal(this._root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override String get title => '设备管理';
	@override String get currentPlan => '当前套餐';
	@override String devicesText({required Object text}) => '设备 ${text}';
	@override String get upgradeTitle => '升级设备数 / 延长时长';
	@override String get upgradeSubtitle => '可同时增加台数与天数，一起算价一次支付';
	@override String get addDevices => '增加台数';
	@override String get noAddDevices => '不增加';
	@override String addDevicesCount({required Object n}) => '+${n} 台';
	@override String get addDays => '增加天数';
	@override String get noExtend => '不延长';
	@override String addDaysCount({required Object n, required Object months}) => '+${n} 天（${months} 个月）';
	@override String get priceFailed => '价格获取失败';
	@override String amountDue({required Object amount}) => '应付 ¥${amount}';
	@override String get requote => '重新算价';
	@override String get goPay => '去支付';
	@override String get afterUpgrade => '升级后：';
	@override String afterLimit({required Object limit}) => '设备上限 ${limit} 台';
	@override String afterExpire({required Object date}) => '到期 ${date}';
	@override String get pickSomething => '请至少选择要增加的台数或天数';
	@override String get daysOnlyUnsupported => '面板暂不支持「只延长时间」：请把「增加台数」选成 1 台及以上再试（或联系客服开通）。';
	@override String get paramsRejected => '参数不被接受：请重新选择台数与天数。';
	@override String get subscriptionExpired => '订阅已到期，无法升级：请先续费或重新购买套餐。';
	@override String get orderIncomplete => '订单信息不完整，请点「重新算价」再试';
	@override String get orderRegenerated => '原订单已失效，已按同样配置重新生成订单';
	@override String get payChannelIncomplete => '订单或支付通道信息不完整，请重新算价后再试';
	@override String get noQrCode => '后端没有返回支付二维码/链接，请换一个支付方式或稍后再试';
	@override String payStartFailed({required Object err}) => '支付发起失败：${err}';
	@override String get payCancelled => '已取消本次支付；草稿订单已清理';
	@override String get balancePay => '余额支付';
	@override String get noPayMethod => '当前没有可用的支付方式，请稍后再试或联系客服';
	@override String balanceInsufficient({required Object balance, required Object amount}) => '余额不足（¥${balance}，需付 ¥${amount}）。\n是否先去充值？';
	@override String get choosePayMethod => '选择支付方式';
	@override String balanceText({required Object balance}) => '余额 ¥${balance}';
	@override String balanceShort({required Object balance}) => '余额 ¥${balance}（不足，请先充值）';
	@override String get unknownDevice => '未知设备';
	@override String get online => '● 在线';
	@override String get offline => '○ 离线';
	@override String lastActive({required Object text}) => '最近活跃 ${text}';
	@override String get delete => '删除';
	@override String deleteConfirm({required Object name}) => '确认删除设备「${name}」？该设备会被立即踢下线。';
	@override String get lastActiveJustNow => '刚刚';
	@override String lastActiveMinutes({required Object minutes}) => '${minutes} 分钟前';
	@override String lastActiveToday({required Object time}) => '今天 ${time}';
}

// Path: sysProxySheet
class Translations$sysProxySheet$zh_CN implements Translations$sysProxySheet$en {
	Translations$sysProxySheet$zh_CN.internal(this._root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override String get reading => '读取中…';
	@override String get unknown => '未知';
	@override String get kernelNotRunning => '内核未运行（先在主页打开连接开关）';
	@override String applied({required Object host, required Object port}) => '已生效 · ${host}:${port}';
	@override String notSet({required Object reason}) => '未设置系统代理 —— ${reason}';
	@override String notEffective({required Object port}) => '未生效（系统里没有指向 ${port} 的代理）';
	@override String readFailed({required Object err}) => '读取失败：${err}';
	@override String get setRejected => '设置失败：系统可能拒绝了写入（或被其它代理软件覆盖）';
	@override String get disableFailed => '关闭失败';
	@override String get portRange => '端口需在 1–65535 之间';
	@override String portChanged({required Object value}) => '端口已改为 ${value}：请断开重连一次，内核才会监听新端口';
	@override String get title => '系统代理';
	@override String desc({required Object host}) => '系统代理地址固定为 ${host}（本机回环），端口就是内核的混合端口。';
	@override String get descWindows => 'Windows 的「设置 → 网络和 Internet → 代理」里看到的就是这个地址。';
	@override String get reset => '重新设置';
	@override String get disable => '关闭系统代理';
	@override String get diagnostics => '诊断详情（界面读的到底是不是注册表那份）';
	@override String get mixedPort => '混合端口';
	@override String get apply => '应用';
}

// Path: logScreen
class Translations$logScreen$zh_CN implements Translations$logScreen$en {
	Translations$logScreen$zh_CN.internal(this._root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override String readAppFailed({required Object e}) => '读取应用日志失败：${e}';
	@override String readCoreFailed({required Object e}) => '读取核心日志失败：${e}';
	@override String get copied => '已复制（订阅地址等敏感信息已自动打码，日志文件本身仍可能包含原始地址）';
	@override String get copy => '复制';
	@override String get refresh => '刷新';
	@override String get empty => '暂无内容';
}

// Path: trayShell
class Translations$trayShell$zh_CN implements Translations$trayShell$en {
	Translations$trayShell$zh_CN.internal(this._root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override String get closeTitle => '关闭窗口';
	@override String get closeBody => '关闭窗口只是把 Mclash 收进托盘 —— 内核与系统代理会继续工作，网照旧能上。\n\n· 点「确定」：最小化到托盘（想彻底退出时，右键托盘图标 → 退出）\n· 点「取消」：完全退出 Mclash，同时停止内核并还原系统代理\n\n（本次选择会被记住；下次可直接右键托盘图标操作）';
}

// Path: ordersScreen
class Translations$ordersScreen$zh_CN implements Translations$ordersScreen$en {
	Translations$ordersScreen$zh_CN.internal(this._root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override String get title => '我的订单';
	@override String get orderInfoIncomplete => '订单信息不完整，请下拉刷新后重试';
	@override String get payChannelIncomplete => '支付通道信息不完整，请稍后重试';
	@override String get noQrPayload => '后端没有返回支付二维码/链接，请换一个支付方式或稍后再试';
	@override String payStartFailed({required Object err}) => '发起支付失败：${err}';
	@override String get noPayMethod => '当前没有可用的支付方式，请稍后再试或联系客服';
	@override String get choosePayMethod => '选择支付方式';
	@override String amountDue({required Object amount}) => '应付 ¥${amount}';
	@override String get paidLabel => '● 已支付';
	@override String get pendingLabel => '○ 待支付';
	@override String unknownStatus({required Object status}) => '✕ ${status}';
	@override String orderNoText({required Object orderNo}) => '订单号 ${orderNo}';
	@override String createdAtText({required Object createdAt}) => '下单时间 ${createdAt}';
	@override String get orderCanceled => '订单已取消';
	@override String cancelFailed({required Object err}) => '取消失败：${err}\n（若订单已被支付/已取消，下拉刷新即可看到最新状态）';
	@override String get cancelOrder => '取消订单';
	@override String get continuePay => '继续支付';
}

// Path: payment
class Translations$payment$zh_CN implements Translations$payment$en {
	Translations$payment$zh_CN.internal(this._root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override String get balancePay => '余额支付';
	@override String get qrPay => '扫码支付';
	@override String get deductFromBalance => '从账户余额扣款';
	@override String get openedInBrowser => '已在浏览器中打开支付页面';
	@override String get scanWithAlipayWechat => '请使用支付宝 / 微信扫码';
	@override String orderNoText({required Object orderNo}) => '订单号 ${orderNo}';
	@override String payFailed({required Object err}) => '支付失败：${err}';
	@override String get notDetected => '未检测到支付。可稍后在「我的订单」中继续。';
	@override String get charging => '正在扣款…';
	@override String get processing => '处理中…';
	@override String get waitingPay => '等待支付…';
	@override String get openPageFailed => '没能打开支付页面，请点下方按钮重试，或改用扫码支付';
	@override String get reopenPayPage => '重新打开支付页面';
	@override String get payInBrowser => '在浏览器中支付';
	@override String get openAlipay => '打开支付宝支付';
	@override String get cancelOrder => '取消订单';
	@override String get confirmPay => '确认支付';
	@override String get retry => '重试';
	@override String get paidAlready => '我已支付';
	@override String get channelAlipay => '支付宝';
	@override String get channelCodepayAlipay => '码支付 · 支付宝';
	@override String get channelCodepayWechat => '码支付 · 微信';
	@override String get channelCodepay => '码支付';
	@override String get channelWechat => '微信支付';
	@override String get channelUsdt => 'USDT';
	@override String get channelUsdtTrc20 => 'USDT · TRC20';
	@override String get payFallback => '支付';
	@override String get errCsrf => '登录凭证已过期（CSRF 校验失败）。\n请到「我的」下拉刷新或重新登录后重试。';
	@override String get errAlipayLimit => '支付宝当面付单笔限额（本商户 ¥1000），本单金额超出。\n请改用「余额支付」或「码支付」，或联系客服提高支付宝限额。';
	@override String get errNotSigned => '支付宝应用未签约对应的支付产品，暂时无法用这个通道。\n请改用「余额支付」或「码支付」，或联系客服开通。';
	@override String get errOrderGone => '这笔订单已被取消或已过期（草稿订单 30 分钟有效期）。\n请点「重新算价」生成新订单再支付。';
	@override String errNetwork({required Object err}) => '网络不通：${err}';
}

// Path: planScreen
class Translations$planScreen$zh_CN implements Translations$planScreen$en {
	Translations$planScreen$zh_CN.internal(this._root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override String get recommended => '推荐';
	@override String get devices => '设备';
	@override String balanceLabel({required Object amount}) => '余额 ¥${amount}';
	@override String get balanceInsufficient => '（不足，请先充值）';
	@override String get total => '合计';
	@override String get payNow => '立即支付';
	@override String get retry => '重试';
	@override String get errIncompleteOrder => '订单或支付通道信息不完整，无法发起支付';
	@override String get payBalance => '余额支付';
	@override String get payAlipay => '支付宝';
	@override String get payWechat => '微信支付';
	@override String get payCodepay => '码支付';
	@override String get payCodepayAlipay => '码支付 · 支付宝';
	@override String get payCodepayWechat => '码支付 · 微信';
	@override String get payEpayAlipay => '易支付 · 支付宝';
	@override String get payEpayWechat => '易支付 · 微信';
	@override String get payUsdt => 'USDT';
	@override String get payUsdtTrc20 => 'USDT · TRC20';
	@override String get payStripe => 'Stripe';
	@override String get payPaypal => 'PayPal';
	@override String get payOnline => '在线支付';
}

// Path: authScreen
class Translations$authScreen$zh_CN implements Translations$authScreen$en {
	Translations$authScreen$zh_CN.internal(this._root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override String get saveAccountInfo => '保存账号信息';
	@override String get autoLoginNextTime => '下次打开自动登录';
	@override String get needLoginNextTime => '下次打开需要重新登录';
	@override String get invalidEmail => '请填写有效邮箱';
	@override String get enterEmailFirst => '请先填写有效邮箱';
	@override String get passwordRequired => '请填写密码';
	@override String get wrongCredentials => '邮箱或密码错误';
	@override String get requestRejected => '请求被拒绝，请稍后重试';
	@override String get tooFrequent => '操作过于频繁，请稍后再试';
	@override String get loginFailed => '登录失败';
	@override String get username => '用户名';
	@override String get confirmPassword => '确认密码';
	@override String get inviteCode => '邀请码';
	@override String get emailCode => '邮箱验证码';
	@override String get getCode => '获取验证码';
	@override String get registerAndLogin => '注册并登录';
	@override String usernameMinLength({required Object min}) => '用户名至少 ${min} 位';
	@override String get passwordMismatch => '两次输入的密码不一致';
	@override String get emailCodeRequired => '请填写邮箱验证码';
	@override String get inviteCodeRequired => '本站注册需要邀请码';
	@override String get codeSentCheckEmail => '验证码已发送，请查收邮件';
	@override String get registerSuccess => '注册成功，已自动登录';
	@override String passwordHint({required Object min}) => '至少 ${min} 位，且同时包含字母和数字';
	@override String passwordTooShort({required Object min}) => '密码长度不能少于 ${min} 位';
	@override String get passwordNeedsLetterAndDigit => '密码必须包含字母和数字';
	@override String get registeredEmail => '注册邮箱';
	@override String get newPassword => '新密码';
	@override String get confirmNewPassword => '确认新密码';
	@override String get resetPassword => '重置密码';
	@override String get resetCodeSent => '如果该邮箱已注册，重置验证码已发送（15 分钟内有效）。';
	@override String get resetSuccess => '密码已重置，请用新密码登录';
	@override String get changePasswordTitle => '修改密码';
	@override String get currentPassword => '当前密码';
	@override String get saveNewPassword => '保存新密码';
	@override String get newPasswordMismatch => '两次输入的新密码不一致';
	@override String get changePasswordSuccess => '密码已修改，请重新登录';
}

// Path: updatePrompt
class Translations$updatePrompt$zh_CN implements Translations$updatePrompt$en {
	Translations$updatePrompt$zh_CN.internal(this._root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override String get checking => '正在检查更新…';
	@override String get checkFailed => '检查更新失败，请检查网络后重试。';
	@override String alreadyLatest({required Object version}) => '已是最新版本（${version}）。';
	@override String newVersionFound({required Object version}) => '发现新版本 ${version}';
	@override String get installerDownloaded => '安装包已在后台下载完成，点「立即更新」完成升级。';
	@override String get downloadInBackground => '点「立即更新」开始下载并安装（也可继续使用，安装包会在后台下载）。';
	@override String get later => '稍后';
	@override String get updateNow => '立即更新';
	@override String installerNotReady({required Object version}) => '安装包还没下载完成。\n\n点「确定」打开下载页，手动下载适合你设备的安装包（版本 ${version}）。';
}

// Path: clearData
class Translations$clearData$zh_CN implements Translations$clearData$en {
	Translations$clearData$zh_CN.internal(this._root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override String get itemLoginSession => '登录会话';
	@override String get itemProfiles => '订阅配置档（profiles/）';
	@override String get itemSettings => '应用与内核设置';
	@override String get itemLatencyCache => '节点延迟缓存';
	@override String get itemLogs => '运行日志';
	@override String get itemRoutingData => '分流数据与临时文件';
	@override String confirmBody({required Object items, required Object dir}) => '将删除本机保存的以下数据（不可恢复）：\n\n${items}\n\n账号本身、已购买的套餐都在服务器上，不受影响；重新登录即可恢复订阅。\n\n数据目录：${dir}\n（卸载 App 之前先点这里，重装后才会是干净的、需要重新登录的状态）';
	@override String get confirmAgain => '确认清除？清除后需要重新登录。';
	@override String clearedNotice({required Object count, required Object dir}) => '已清除 ${count} 项本地数据（含登录会话，下次打开需要重新登录）。\n\n现在可以删除 App 完成卸载：\n· macOS：把 Mclash.app 拖进废纸篓（数据目录已清空：${dir}）\n· Windows：控制面板卸载 Mclash，卸载向导里的「是否保留用户数据」选「否」';
	@override String clearFailed({required Object error}) => '清除失败：${error}';
}

// Path: apiError
class Translations$apiError$zh_CN implements Translations$apiError$en {
	Translations$apiError$zh_CN.internal(this._root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override String requestFailedHttp({required Object status, required Object domain}) => '请求失败（HTTP ${status}），已尝试域名 ${domain}';
	@override String allDomainsFailed({required Object method, required Object path, required Object count}) => '请求失败：${method} ${path}（已尝试 ${count} 个域名）';
	@override String requestTimeout({required Object seconds, required Object method, required Object path}) => '请求超时（${seconds}s）：${method} ${path}';
	@override String networkUnreachable({required Object detail}) => '网络不可达：${detail}';
	@override String get tlsHandshakeFailed => 'TLS 握手失败，请检查网络或系统时间';
	@override String connectionFailed({required Object detail}) => '连接失败：${detail}';
	@override String requestError({required Object error}) => '请求失败：${error}';
	@override String responseReadTimeout({required Object seconds, required Object method, required Object path}) => '读取响应超时（${seconds}s）：${method} ${path}';
	@override String notJson({required Object status, required Object snippet}) => '响应不是 JSON（HTTP ${status}）：${snippet}';
	@override String badStructure({required Object status}) => '响应结构异常（HTTP ${status}）';
	@override String loginFailed({required Object code}) => '登录失败（code ${code}）';
	@override String get loginMissingData => '登录响应缺少 data';
	@override String get loginMissingToken => '登录响应缺少 access_token';
	@override String registerFailed({required Object code}) => '注册失败（code ${code}）';
	@override String get registerMissingToken => '注册响应未包含 access_token，可能触发了风控或站点配置不同';
	@override String requestFailedCode({required Object code}) => '请求失败（code ${code}）';
}

// Path: subNotice
class Translations$subNotice$zh_CN implements Translations$subNotice$en {
	Translations$subNotice$zh_CN.internal(this._root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override String get titleNotFound => '订阅不存在';
	@override String get titleExpired => '订阅已过期';
	@override String get titleInactive => '订阅已失效';
	@override String get titleDeviceOverLimit => '设备数量超限';
	@override String get titleUnavailable => '订阅不可用';
	@override String titleWithReason({required Object emoji, required Object title, required Object reason}) => '${emoji} ${title}（${reason}）';
	@override String deviceUsedOfLimit({required Object used, required Object limit}) => '当前设备 ${used}/${limit}';
	@override String deviceUsedOnly({required Object used}) => '当前设备 ${used}';
	@override String expireAt({required Object expire}) => '到期时间 ${expire}';
	@override String supportLine({required Object account}) => '💬 客服: ${account}';
	@override String siteLine({required Object url}) => '📢 官网: ${url}';
}

// Path: settingItems
class Translations$settingItems$zh_CN implements Translations$settingItems$en {
	Translations$settingItems$zh_CN.internal(this._root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override String get subscriptionAutoUpdateInterval => '订阅自动更新间隔';
	@override String get speedTestMode => '测速方式';
	@override String get speedTestModeTcp => 'TCP 测速';
	@override String get speedTestModeKernel => '内核测速';
	@override String get delayTestUrlTip => '经该节点完整走一次 HTTP 请求的耗时（非 ping）\n默认用明文 http 的 204 空响应；换成 https 会多一次 TLS 握手，数字更大';
	@override String get systemProxy => '系统代理';
	@override String get systemProxyTip => '查看/重设地址与端口';
	@override String get tunMode => 'TUN 模式';
	@override String get tunModeTip => 'off=仅系统代理 / auto=TUN+系统代理 / force=仅 TUN\n桌面端 TUN 需要管理员权限（Windows 建 wintun / macOS 建 utun）';
	@override String get tunOverwriteTip => 'overwrite\n开 = 用这里的 TUN 设置覆盖订阅里的 tun 段\n关 = 让订阅自己的 tun 配置生效（App 不插手）';
	@override String tunEnableByTunMode({required Object enable}) => '${enable}（由 TUN 模式决定）';
	@override String get interval30Minutes => '30 分钟';
	@override String get interval1Hour => '1 小时';
	@override String get interval6Hours => '6 小时';
	@override String get interval12Hours => '12 小时';
	@override String get interval24Hours => '24 小时';
	@override String get interval3Days => '3 天';
	@override String get interval7Days => '7 天';
	@override String get intervalNever => '从不';
	@override String intervalMinutes({required Object minutes}) => '${minutes} 分钟';
	@override String intervalHours({required Object hours}) => '${hours} 小时';
	@override String intervalDays({required Object days}) => '${days} 天';
}

// Path: tunScreen
class Translations$tunScreen$zh_CN implements Translations$tunScreen$en {
	Translations$tunScreen$zh_CN.internal(this._root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override String get modeOff => '关闭';
	@override String get modeAuto => '自动';
	@override String get modeForce => '强制';
	@override String get modeOffDesc => '仅系统代理：浏览器等遵守系统代理的程序生效，UDP/游戏不走代理';
	@override String get modeAutoDesc => 'TUN + 系统代理（双保险）：全部流量走虚拟网卡，含 UDP';
	@override String get modeForceDesc => '仅 TUN：全部流量走虚拟网卡，不再改系统代理';
	@override String get modeOffOptionDesc => '不改系统路由表，只在系统里设置 127.0.0.1 的代理。只有遵守系统代理的程序走代理；UDP 流量与自带代理设置的程序不走。';
	@override String get modeAutoOptionDesc => '建虚拟网卡接管全部流量（含 UDP、游戏）；同时保留系统代理作为兜底。推荐：既能全局生效，又不会因为权限问题彻底没网。';
	@override String get modeForceOptionDesc => '只用虚拟网卡，不再改系统代理。全部流量（含 UDP）都进隧道，系统里「代理」一项保持原样。';
	@override String get adminRequiredDialog => 'TUN 虚拟网卡需要管理员权限（Windows 建 wintun / macOS 建 utun）。\n\n当前 Mclash 不是以管理员身份运行的，开启后 TUN 不会生效（「自动」模式下系统代理仍会兜底，网络可用）。\n\n点「确定」= 现在以管理员身份重启 Mclash（会弹 UAC）\n点「取消」= 仍要保存这个选择（TUN 不生效时会自动用系统代理）';
	@override String relaunchFailed({required Object message}) => '重启失败：${message}';
	@override String switchFailed({required Object message}) => '切换 TUN 模式失败：${message}\n已恢复原来的设置。';
	@override String get setOffSnack => '已设为「关闭」：只使用系统代理';
	@override String setModeSnack({required Object mode, required Object effect}) => '已设为「${mode}」，${effect}';
	@override String get effectReconnected => '已重连生效';
	@override String get effectAfterConnect => '连接后生效';
	@override String get sheetTitle => 'TUN 虚拟网卡';
	@override String get advancedTitle => '高级参数（核心设置 → TUN）';
	@override String get advancedSubtitle => '虚拟网卡地址 / 栈 / MTU / 自动路由 / DNS 劫持 / 覆写';
	@override String get adminOk => 'TUN 需要管理员权限；当前权限满足（Windows 以管理员运行 / macOS 以 root 运行）';
	@override String get adminMissing => 'TUN 需要管理员权限：当前未以管理员身份运行，选中「自动/强制」后 TUN 不会生效（「自动」会用系统代理兜底，网络仍可用）';
}

// Path: main.tray
class Translations$main$tray$zh_CN implements Translations$main$tray$en {
	Translations$main$tray$zh_CN.internal(this._root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override String get menuOpen => '打开';
	@override String get menuExit => '退出';
}

/// The flat map containing all translations for locale <zh-CN>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on TranslationsZhCn {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'BackupAndSyncWebdavScreen.webdavServerUrl' => '服务器地址',
			'BackupAndSyncWebdavScreen.webdavRequired' => '不能为空',
			'BackupAndSyncWebdavScreen.webdavLoginFailed' => '登录失败:',
			'BackupAndSyncWebdavScreen.webdavListFailed' => '获取文件列表失败:',
			'LaunchFailedScreen.invalidProcess' => '应用启动失败[无效的进程名称],请重新安装应用到独立目录',
			'LaunchFailedScreen.invalidProfile' => '应用启动失败[访问配置文件失败],请重新安装应用',
			'LaunchFailedScreen.invalidVersion' => '应用启动失败[无效版本],请重新安装应用',
			'LaunchFailedScreen.systemVersionLow' => '应用启动失败[系统版本过低]',
			'LaunchFailedScreen.invalidInstallPath' => '无效的安装路径,请重新安装到有效路径',
			'PerAppAndroidScreen.title' => '分应用代理',
			'PerAppAndroidScreen.whiteListMode' => '白名单模式',
			'PerAppAndroidScreen.whiteListModeTip' => '启用后:仅代理已勾选的App;未启用:仅代理未勾选的App',
			'UserAgreementScreen.privacyFirst' => '您的隐私很重要',
			'UserAgreementScreen.agreeAndContinue' => '接受并继续',
			'NetCheckScreen.enterDomain' => '请输入域名',
			'NetCheckScreen.checking' => '检测中...',
			'NetCheckScreen.aQueryFailed' => ({required Object p}) => 'A 查询失败: ${p}',
			'NetCheckScreen.aaaaQueryFailed' => ({required Object p}) => 'AAAA 查询失败: ${p}',
			'NetCheckScreen.success' => '成功',
			'NetCheckScreen.failed' => '失败',
			'NetCheckScreen.suspectedPollution' => '疑似被污染',
			'NetCheckScreen.domainLabel' => '域名',
			'NetCheckScreen.checkButton' => '检测',
			'NetCheckScreen.dnsSection' => '1. DNS查询',
			'NetCheckScreen.directHttpSection' => '2. HTTP (经由TUN,请先开启TUN)',
			'NetCheckScreen.proxyHttpSection' => ({required Object p}) => '3. HTTP (经由代理,端口:${p})',
			'NetCheckScreen.tunNotEnabled' => 'TUN 未开启',
			'NetCheckScreen.routeTableSection' => '4. 路由表',
			'VersionUpdateScreen.versionReady' => ({required Object p}) => '新版本[${p}]已就绪',
			'VersionUpdateScreen.update' => '重启更新',
			'VersionUpdateScreen.cancel' => '暂不更新',
			'loginScreen.login' => '登录',
			'loginScreen.register' => '注册账号',
			'loginScreen.forgotPassword' => '忘记密码',
			'loginScreen.provider' => '服务商(机场)',
			'loginScreen.providerName' => '${_root.loginScreen.provider}编码/别名/URL',
			'loginScreen.account' => '账号',
			'loginScreen.email' => '邮箱',
			'loginScreen.password' => '密码',
			'main.tray.menuOpen' => '打开',
			'main.tray.menuExit' => '退出',
			'meta.enable' => '启用',
			'meta.disable' => '禁用',
			'meta.open' => '打开',
			'meta.close' => '关闭',
			'meta.quit' => '退出',
			'meta.add' => '添加',
			'meta.remove' => '删除',
			'meta.removeConfirm' => '确认删除?',
			'meta.edit' => '编辑',
			'meta.view' => '查看',
			'meta.remark' => '备注',
			'meta.byDefault' => '默认',
			'meta.more' => '更多',
			'meta.tips' => '提示',
			'meta.selectAll' => '全选',
			'meta.copy' => '拷贝',
			'meta.paste' => '粘贴',
			'meta.cut' => '剪切',
			'meta.save' => '保存',
			'meta.ok' => '确定',
			'meta.cancel' => '取消',
			'meta.faq' => '常见问题',
			'meta.doc' => '文档',
			'meta.htmlTools' => 'HTML工具集',
			'meta.download' => '下载',
			'meta.loading' => '加载中...',
			'meta.days' => '天',
			'meta.hours' => '时',
			'meta.minutes' => '分',
			'meta.seconds' => '秒',
			'meta.milliseconds' => '毫秒',
			'meta.search' => '搜索',
			'meta.searchNodeHint' => '筛选节点（名称或协议）',
			'meta.connect' => '连接',
			'meta.disconnect' => '断开',
			'meta.connected' => '已连接',
			'meta.disconnected' => '未连接',
			'meta.connecting' => '连接中',
			'meta.connectTimeout' => '连接超时',
			'meta.timeout' => '超时',
			'meta.latencyTest' => '延迟检测',
			'meta.networkCheck' => '网络检测',
			'meta.language' => '语言',
			'meta.next' => '下一步',
			'meta.done' => '完成',
			'meta.apply' => '应用',
			'meta.refresh' => '刷新',
			'meta.update' => '更新',
			'meta.updateInterval' => '更新时间间隔',
			'meta.updateInterval5mTips' => '最小:5m',
			'meta.updateIntervalPreferByProfile' => '优先使用服务商(机场)设置',
			'meta.updateFailed' => ({required Object p}) => '更新失败:${p}',
			'meta.none' => '无',
			'meta.reset' => '重置',
			'meta.authentication' => '授权',
			'meta.user' => '用户',
			'meta.account' => '账号',
			'meta.password' => '密码',
			'meta.decryptPassword' => '解密密码',
			'meta.required' => '必填',
			'meta.go' => '继续',
			'meta.other' => '其他',
			'meta.dns' => 'DNS',
			'meta.url' => 'URL',
			'meta.urlInvalid' => 'URL无效',
			'meta.copyUrl' => '拷贝链接',
			'meta.openUrl' => '打开链接',
			'meta.coreSettingTips' => '注意:修改配置后,需要重新连接才会生效',
			'meta.overwrite' => '覆写',
			'meta.overwriteAppend' => '追加覆写',
			'meta.overwriteTips' => '原始配置<-自定义覆写<-App覆写',
			'meta.noOverwrite' => '不覆写',
			'meta.diversionTemplates' => '分流模板',
			'meta.ruleProviders' => '规则提供者',
			'meta.ruleTemplates' => '规则模板',
			'meta.proxyGroupsTemplates' => '代理组模板',
			'meta.proxyGroups' => '代理组',
			'meta.proxyNodeList' => '代理节点列表',
			'meta.proxyNodeFailure' => ({required Object p}) => '下列代理节点已失效,已自动移除:${p}',
			'meta.externalController' => '外部控制',
			'meta.secret' => 'Secret',
			'meta.tcpConcurrent' => 'TCP并发握手',
			'meta.globalClientFingerprint' => 'TLS全局指纹',
			'meta.allowLanAccess' => '局域网设备接入',
			'meta.mixedPort' => '混合代理端口',
			'meta.logLevel' => '日志等级',
			'meta.findProcessMode' => '进程匹配模式',
			'meta.tcpkeepAliveInterval' => 'TCP保活时间间隔',
			'meta.delayTestUrl' => '延迟测试URL',
			'meta.delayTestTimeout' => '延迟测试超时(ms)',
			'meta.tun' => 'TUN',
			'meta.ntp' => 'NTP',
			'meta.tls' => 'TLS',
			'meta.geoDownloadByProxy' => '使用代理下载Geo RuleSet',
			'meta.geoRulesetTips' => 'Geosite/Geoip 会被转换成 对应的RuleSet',
			'meta.sniffer' => '嗅探',
			'meta.userAgent' => 'UserAgent',
			'meta.launchAtStartup' => '开机启动',
			'meta.launchAtStartupRunAsAdmin' => '请以管理员身份重新启动Mclash',
			'meta.tunModeRunAsAdmin' => 'TUN模式需要系统管理员权限,请以管理员身份重新启动应用',
			'meta.portableMode' => '便携模式',
			'meta.portableModeDisableTips' => '如需退出便携模式,请退出[mclash]后,手动删除[mclash.exe]同目录下的[portable]文件夹即可',
			'meta.autoConnectAfterLaunch' => '启动后自动连接',
			'meta.autoConnectAtBoot' => '系统启动后自动连接',
			'meta.autoConnectAtBootTips' => '需要系统支持,部分系统可能还需要开启[自启动]',
			'meta.hideAfterLaunch' => '启动后隐藏窗口',
			'meta.autoSetSystemProxy' => '连接后自动设置系统代理',
			'meta.bypassSystemProxy' => '允许绕过系统代理的域名',
			'meta.excludeFromRecent' => '从[最近任务]中隐藏',
			'meta.wakeLock' => '唤醒锁',
			'meta.hideDockIcon' => '隐藏Dock图标',
			'meta.showTrayTraffic' => '托盘上显示流量信息',
			'meta.website' => '官网',
			'meta.rule' => '规则',
			'meta.global' => '全局',
			'meta.direct' => '直连',
			'meta.qrcode' => '二维码',
			'meta.qrcodeTooLong' => '文本过长,无法展示',
			'meta.qrcodeShare' => '分享二维码',
			'meta.qrcodeScan' => '扫描二维码',
			'meta.qrcodeScanResult' => '扫描结果',
			'meta.backupAndSync' => '备份与同步',
			'meta.export' => '导出',
			'meta.send' => '发送',
			'meta.sendConfirm' => '确认发送?',
			'meta.log' => '日志',
			'meta.coreLog' => '核心日志',
			'meta.appLog' => '应用日志',
			'meta.core' => '核心',
			'meta.help' => '帮助',
			'meta.tutorial' => '使用教程',
			'meta.board' => '面板',
			'meta.boardOnline' => '使用在线面板',
			'meta.boardOnlineUrl' => '在线面板URL',
			'meta.boardLocalPort' => '本地面板端口',
			'meta.alwayOnVPN' => '始终开启连接',
			'meta.disableFontScaler' => '禁用字体缩放',
			'meta.autoOrientation' => '跟随屏幕旋转',
			'meta.restartTakesEffect' => '重启生效',
			'meta.reconnectTakesEffect' => '重新连接后生效',
			'meta.runtimeProfile' => '运行时配置',
			'meta.willCompleteAfterRebootInstall' => '请重启设备,以便完成系统扩展安装',
			'meta.requestNeedsUserApproval' => '1. 请在[系统设置]-[隐私与安全性]里[允许] Mclash安装系统扩展\n2. :[系统设置]-[通用]-[登录项与扩展-网络扩展]启用[mclashServiceSE]\n完成后重新连接',
			'meta.FullDiskAccessPermissionRequired' => '请在[系统设置]-[隐私与安全性]-[完全磁盘访问权限]里开启mclashServiceSE权限后,重新连接',
			'meta.proxy' => '代理',
			'meta.theme' => '主题',
			'meta.tvMode' => 'TV模式',
			'meta.autoUpdate' => '自动更新',
			'meta.updateChannel' => '自动更新通道',
			'meta.hasNewVersion' => ({required Object p}) => '更新版本 ${p}',
			'meta.autoDownloadPkg' => '自动下载更新包',
			'meta.devOptions' => '开发者选项',
			'meta.about' => '关于',
			'meta.name' => '名称',
			'meta.version' => '版本',
			'meta.sort' => '排序',
			'meta.share' => '分享',
			'meta.importFromClipboard' => '从剪贴板导入',
			'meta.exportToClipboard' => '导出到剪贴板',
			'meta.server' => '服务器',
			'meta.port' => '端口',
			'meta.donate' => '捐助',
			'meta.setting' => '设置',
			'meta.settingCore' => '核心设置',
			'meta.settingApp' => '应用设置',
			'meta.coreOverwrite' => '核心覆写',
			'meta.iCloud' => 'iCloud',
			'meta.webdav' => 'Webdav',
			'meta.lanSync' => '局域网同步',
			'meta.lanSyncNotQuitTips' => '同步完成前请勿退出此界面',
			'meta.deviceNoSpace' => '磁盘空间不足',
			'meta.hideSystemApp' => '隐藏系统应用',
			'meta.hideAppIcon' => '隐藏应用图标',
			'meta.openDir' => '打开文件目录',
			'meta.type' => '类型',
			'meta.fileNotExist' => ({required Object p}) => '文件不存在:${p}',
			'meta.buyProfile' => '购买配置',
			'meta.myProfiles' => '我的配置',
			'meta.profileEdit' => '编辑配置',
			'meta.profileNeedActive' => '请先将本配置设置为当前配置,并开启连接/重新连接',
			'meta.profileUrlOrContent' => ({required Object p}) => '${p}配置链接',
			'meta.tabHome' => '主页',
			'meta.tabNodes' => '节点列表',
			'meta.tabPlans' => '套餐购买',
			'meta.tabMe' => '我的',
			'permission.camera' => '摄像头',
			'permission.screen' => '屏幕录制',
			'permission.appQuery' => '获取应用列表',
			'permission.request' => ({required Object p}) => '开启[${p}]权限',
			'permission.requestNeed' => ({required Object p}) => '请开启[${p}]权限',
			'tls.certificate' => '证书',
			'tls.privateKey' => '私钥',
			'tls.customTrustCert' => '自定义证书',
			'tun.stack' => '网络栈',
			'tun.inet4Address' => 'IPv4地址段',
			'tun.dnsHijack' => 'DNS劫持',
			'tun.strictRoute' => '严格路由',
			'tun.tunDefaultRoute' => '默认路由',
			'tun.icmpForward' => 'ICMP 转发',
			'tun.allowBypass' => '允许应用绕过VPN',
			'tun.appendHttpProxy' => '附加HTTP代理到VPN',
			'tun.bypassHttpProxyDomain' => '允许绕过HTTP代理的域名',
			'dns.listen' => '监听地址',
			'dns.fakeIp' => 'fake-ip',
			'dns.fallback' => 'Fallback',
			'dns.preferH3' => 'DoH H3优先',
			'dns.useHosts' => '使用Hosts',
			'dns.useSystemHosts' => '使用系统Hosts',
			'dns.enhancedMode' => '增强模式',
			'dns.fakeIPFilterMode' => '${_root.dns.fakeIp} 过滤模式',
			'dns.fakeIPFilter' => '${_root.dns.fakeIp} 过滤',
			'dns.respectRules' => '遵守[rules]规则',
			'dns.nameServer' => '域名解析服务器',
			'dns.defaultNameServer' => '${_root.meta.byDefault} ${_root.dns.nameServer}',
			'dns.proxyNameServer' => '${_root.meta.proxy} ${_root.dns.nameServer}',
			'dns.directNameServer' => '${_root.meta.direct} ${_root.dns.nameServer}',
			'dns.fallbackNameServer' => '${_root.dns.fallback} ${_root.dns.nameServer}',
			'dns.fallbackGeoIp' => '${_root.dns.fallback} GeoIp',
			'dns.fallbackGeoIpCode' => '${_root.dns.fallback} GeoIp 代码',
			'sniffer.overrideDest' => '覆盖',
			'profilePatchMode.currentSelected' => '当前选择',
			'profilePatchMode.overwrite' => '内置-覆写',
			'profilePatchMode.noOverwrite' => '内置-不覆写',
			'sendOrReceiveNotMatch' => ({required Object p}) => '请使用[${p}]',
			'targetConnectFailed' => ({required Object p}) => '连接[${p}]失败,请确保设备在同一个局域网内',
			'edgeRuntimeNotInstalled' => '当前设备尚未安装Edge WebView2运行时,无法展示页面,请下载安装Edge WebView2运行时(x64)后,重启App再试',
			'locales.en' => 'English',
			'locales.zh-CN' => '简体中文',
			'locales.zh-TW' => '繁體中文',
			'locales.ja' => '日本語',
			'locales.ko' => '한국어',
			'locales.ar' => 'عربي',
			'locales.ru' => 'Русский',
			'locales.fa' => 'فارسی',
			'locales.es' => 'Español',
			'countries.HK' => '香港',
			'countries.TW' => '台湾',
			'countries.MO' => '澳门',
			'countries.CN' => '中国',
			'countries.JP' => '日本',
			'countries.KR' => '韩国',
			'countries.SG' => '新加坡',
			'countries.MY' => '马来西亚',
			'countries.TH' => '泰国',
			'countries.VN' => '越南',
			'countries.PH' => '菲律宾',
			'countries.ID' => '印尼',
			'countries.KH' => '柬埔寨',
			'countries.US' => '美国',
			'countries.CA' => '加拿大',
			'countries.MX' => '墨西哥',
			'countries.GB' => '英国',
			'countries.DE' => '德国',
			'countries.FR' => '法国',
			'countries.NL' => '荷兰',
			'countries.RU' => '俄罗斯',
			'countries.IT' => '意大利',
			'countries.ES' => '西班牙',
			'countries.CH' => '瑞士',
			'countries.SE' => '瑞典',
			'countries.NO' => '挪威',
			'countries.FI' => '芬兰',
			'countries.DK' => '丹麦',
			'countries.PL' => '波兰',
			'countries.AT' => '奥地利',
			'countries.IE' => '爱尔兰',
			'countries.UA' => '乌克兰',
			'countries.TR' => '土耳其',
			'countries.PT' => '葡萄牙',
			'countries.CZ' => '捷克',
			'countries.RO' => '罗马尼亚',
			'countries.BE' => '比利时',
			'countries.GR' => '希腊',
			'countries.HU' => '匈牙利',
			'countries.IL' => '以色列',
			'countries.AE' => '阿联酋',
			'countries.SA' => '沙特',
			'countries.EG' => '埃及',
			'countries.ZA' => '南非',
			'countries.NG' => '尼日利亚',
			'countries.AU' => '澳大利亚',
			'countries.NZ' => '新西兰',
			'countries.BR' => '巴西',
			'countries.AR' => '阿根廷',
			'countries.CL' => '智利',
			'countries.CO' => '哥伦比亚',
			'countries.IN' => '印度',
			'countries.PK' => '巴基斯坦',
			'countries.XX' => '其他',
			'meScreen.accountBalance' => '账户余额',
			'meScreen.expireAt' => '到期时间',
			'meScreen.remainingDays' => '剩余天数',
			'meScreen.deviceCount' => '设备数',
			'meScreen.myOrders' => '我的订单',
			'meScreen.deviceManagement' => '设备管理',
			'meScreen.changePassword' => '修改密码',
			'meScreen.clearLocalData' => '清除本地数据（卸载前使用）',
			'meScreen.profileManagementDev' => '配置档管理（开发者）',
			'meScreen.tunAdapter' => 'TUN 虚拟网卡',
			'meScreen.checkUpdate' => '检查更新',
			'meScreen.retry' => '重试',
			'meScreen.loadFailed' => '账号信息读取失败：登录可能已过期或网络不通。\n请点右上角刷新重试；仍失败请重新登录。',
			'meScreen.logoutConfirm' => '确认退出登录？',
			'meScreen.boardNoKernel' => '面板显示的是内核的实时数据（连接、流量、规则命中）。\n\n当前内核没有运行，面板会是一个空壳。\n点「确定」仍然打开，点「取消」先去主页连接。',
			'meScreen.boardOpened' => '已在浏览器中打开面板；在里面换节点 / 切规则-全局，App 会自动跟随（约 5 秒内）',
			'homeScreen.expiresOn' => ({required Object date}) => '到期 ${date}',
			'homeScreen.devicesText' => ({required Object text}) => '设备 ${text}',
			'homeScreen.upgrade' => '升级',
			'homeScreen.quickCountries' => '快速筛选国家',
			'homeScreen.nodeCount' => ({required Object count}) => '${count} 个节点',
			'homeScreen.autoBestTip' => '在所有国家的节点里挑延迟最低的可用节点（自动模式）',
			'homeScreen.autoBest' => '自动最优',
			'homeScreen.pickCountryTip' => ({required Object label}) => '自动选择「${label}」延迟最低的可用节点，并固定使用它',
			'homeScreen.autoNoBetter' => '已在自动模式（没有找到更优的可用节点）',
			'homeScreen.switchedBest' => ({required Object name}) => '已切换到最优节点：${name}',
			'homeScreen.switchedCountry' => ({required Object country, required Object node, required Object ms}) => '已切换到 ${country} 最快节点：${node}${ms}',
			'homeScreen.filterCountryFailed' => ({required Object country, required Object err}) => '已筛选 ${country}；切换节点失败：${err}',
			'homeScreen.deviceFullCount' => ({required Object used, required Object limit}) => '当前设备 ${used}/${limit} 台\n\n',
			'homeScreen.deviceFullUpgradeHint' => '升级设备数量后可立即恢复连接（推荐）；也可以先删除不常用的设备腾出名额。',
			'homeScreen.later' => '稍后',
			'homeScreen.upgradeDeviceCount' => '升级设备数量',
			'homeScreen.cannotConnect' => '无法连接',
			'homeScreen.freshnessNever' => '尚未同步 · 点击刷新',
			'homeScreen.freshnessJustNow' => '刚刚更新 · 点右侧管理设备',
			'homeScreen.freshnessMinutes' => ({required Object minutes}) => '${minutes} 分钟前更新 · 点右侧管理设备',
			'homeScreen.freshnessStale' => ({required Object minutes}) => '${minutes} 分钟前更新 · 点击刷新',
			'homeScreen.subscriptionAutoSync' => '订阅自动同步',
			'homeScreen.connecting' => '正在连接…',
			'homeScreen.disconnecting' => '正在断开…',
			'homeScreen.tapToDisconnect' => '点击开关断开',
			'homeScreen.tapToConnect' => '点击开关连接',
			'homeScreen.currentNode' => '当前节点',
			'homeScreen.noNodeSelected' => '未选择节点',
			'homeScreen.switchAction' => '切换',
			'homeScreen.realtimeSpeed' => '实时速度',
			'homeScreen.totalTraffic' => '累计流量',
			'homeScreen.subSyncedNotReady' => '订阅已下载，但配置档还没就绪，请稍后再试。',
			'homeScreen.noPlan' => '该账号暂无可用套餐，请先购买套餐。',
			'homeScreen.loginExpired' => '登录已失效，请重新登录。',
			'homeScreen.syncingWait' => '正在同步订阅，请稍候再试。',
			'homeScreen.syncFailedNetwork' => ({required Object message}) => '订阅同步失败：${message}\n请检查网络后重试。',
			'homeScreen.syncFailed' => '订阅同步失败，请稍后重试。',
			'homeScreen.resetProxy' => '重设',
			'homeScreen.latencySuffix' => ({required Object ms}) => '（${ms}ms）',
			'nodesScreen.updatedCount' => ({required Object count}) => '订阅已更新：${count} 个节点',
			'nodesScreen.updateFailed' => ({required Object message}) => '更新失败：${message}',
			'nodesScreen.updateFailedNetwork' => '更新失败，请检查网络',
			'nodesScreen.testDone' => ({required Object ok, required Object fail}) => '测速完成：${ok} 个可用，${fail} 个连不上（可能已下线）',
			'nodesScreen.switchedTo' => ({required Object name}) => '已切换到 ${name}',
			'nodesScreen.switchFailed' => ({required Object message}) => '切换失败：${message}\n（节点切换需要内核运行，请先打开连接开关）',
			'nodesScreen.selectedAfterConnect' => ({required Object name}) => '已选择 ${name}（连接后生效）',
			'nodesScreen.title' => '节点列表',
			'nodesScreen.searchNode' => '搜索节点',
			'nodesScreen.sortByLatency' => '按延迟排序',
			'nodesScreen.updateSubscription' => '更新订阅',
			'nodesScreen.viewByGroup' => '按代理组查看',
			'nodesScreen.testAll' => '全部测速',
			'nodesScreen.searchHint' => '搜索节点 / 国家 / 协议',
			'nodesScreen.emptyNoNodes' => '还没有可用节点。\n订阅会自动同步；若刚登录，请稍候或点下方重试。',
			'nodesScreen.emptyNoMatch' => '没有匹配的节点。',
			'nodesScreen.reload' => '重新加载',
			'nodesScreen.currentInUse' => '当前选中（正在使用的节点）',
			'nodesScreen.current' => '当前',
			'nodesScreen.notTested' => '未测到（待重载内核）',
			'nodesScreen.timeout' => '超时',
			'nodesScreen.clear' => '清空',
			'nodesScreen.selectNode' => '选择节点',
			'nodesScreen.emptyNoKernel' => '还没有可用节点。\n请先在主页打开连接开关。',
			'nodesScreen.openFullList' => '打开完整节点列表（搜索 / 测速 / 分组）',
			'nodeAuto.kernelStateUnavailable' => '暂时读不到内核的节点状态，稍后会自动重试',
			'nodeAuto.backToFixedNode' => ({required Object fixed}) => '已回到固定节点：${fixed}',
			'nodeAuto.noUsableNodePickOne' => '没有找到可用节点，请在「节点列表」里手动换一个',
			'nodeAuto.noUsableNodeTryOne' => '没有找到可用的节点，请在「节点列表」里手动换一个试试',
			'nodeAuto.autoConnectedBest' => ({required Object bestNode, required Object bestMs}) => '已自动连接最优节点：${bestNode}（${bestMs} ms）',
			'nodeAuto.currentNodeUnreachable' => '当前节点无法访问外网，正在自动换一个…',
			'nodeAuto.autoSwitchedToUsable' => ({required Object target}) => '已自动切换到可用节点：${target}',
			'nodeAuto.newNodesReloading' => ({required Object missing}) => '订阅里有 ${missing} 个新节点还没进内核，正在重载…',
			'nodeAuto.kernelReloadedRetest' => '内核已按新订阅重载，请再点一次测速',
			'accountBlock.quotaFull' => ({required Object used, required Object limit}) => '设备名额已用满（${used}/${limit}）：本机仍在授权范围内，可正常连接。如需再添加新设备，请升级设备数量或先删除不用的设备。',
			'accountBlock.banFallback' => '您的账号已被禁用，无法继续使用服务。',
			'accountBlock.titleExpired' => '套餐已到期',
			'accountBlock.titleDeviceFull' => '设备数量已达上限',
			'accountBlock.titleAccountDisabled' => '账号已被禁用',
			'accountBlock.titlePlanDisabled' => '套餐已被禁用',
			'accountBlock.titleNoPlan' => '尚未开通套餐',
			'accountBlock.titleDeviceRemoved' => '本设备已被移除',
			'accountBlock.titleServiceUnavailable' => '服务暂时不可用',
			'accountBlock.textExpired' => '您的套餐已到期，购买套餐后即可继续畅连全球节点。',
			'accountBlock.textDeviceFull' => ({required Object used, required Object limit}) => '服务端判定本机已超出套餐设备数上限（${used}/${limit}），暂时无法连接。可在「我的 - 设备管理」中删除不常用设备，或升级更高设备数的套餐。',
			'accountBlock.textAccountDisabled' => '您的账号已被禁用，无法使用服务。如有疑问，请联系客服。',
			'accountBlock.textPlanDisabled' => '您的套餐已被禁用或状态异常，无法连接。如有疑问，请联系客服。',
			'accountBlock.textNoPlan' => '您还没有开通套餐，开通后即可畅连全球节点。',
			'accountBlock.textDeviceRemoved' => '本设备已被移除并踢下线，请重新登录。',
			'accountBlock.textServiceUnavailable' => '服务暂时不可用，请稍后重试；若持续出现请截图联系客服。',
			'accountBlock.remainingDays' => ({required Object days}) => '剩余 ${days} 天',
			'accountBlock.deviceUsage' => ({required Object used, required Object limit}) => '设备 ${used}/${limit}',
			'entitlementMsg.tamperedTitle' => '授权状态异常',
			'entitlementMsg.tamperedClock' => '检测到系统时间被回拨（或本地授权数据被改动），请联网完成一次校验后再连接。',
			'entitlementMsg.tamperedLocal' => '本地授权数据已损坏或被改动，请联网完成一次校验后再连接。',
			'entitlementMsg.needVerifyTitle' => '需要联网校验',
			'entitlementMsg.needVerifyFirst' => '无法确认套餐状态：请先连接网络并登录账号，完成一次校验后再连接。',
			'entitlementMsg.needVerifyRetry' => '无法确认套餐状态，请联网后重试。',
			'entitlementMsg.verifyFailedTitle' => '无法校验套餐状态',
			'entitlementMsg.verifyFailedText' => '已超过校验宽限期且无法连接服务器，请检查网络后重试（如刚续费，请重新登录）。',
			'entitlementMsg.restrictedTitle' => '账号受限',
			'entitlementMsg.restrictedFallback' => '账号或套餐已被禁用，无法连接。',
			'entitlementMsg.expiredTitle' => '套餐已到期',
			'entitlementMsg.expiredText' => ({required Object date}) => '您的套餐已于 ${date} 到期，本地订阅配置已清除。续费后重新登录即可恢复。',
			'devicesScreen.title' => '设备管理',
			'devicesScreen.currentPlan' => '当前套餐',
			'devicesScreen.devicesText' => ({required Object text}) => '设备 ${text}',
			'devicesScreen.upgradeTitle' => '升级设备数 / 延长时长',
			'devicesScreen.upgradeSubtitle' => '可同时增加台数与天数，一起算价一次支付',
			'devicesScreen.addDevices' => '增加台数',
			'devicesScreen.noAddDevices' => '不增加',
			'devicesScreen.addDevicesCount' => ({required Object n}) => '+${n} 台',
			'devicesScreen.addDays' => '增加天数',
			'devicesScreen.noExtend' => '不延长',
			'devicesScreen.addDaysCount' => ({required Object n, required Object months}) => '+${n} 天（${months} 个月）',
			'devicesScreen.priceFailed' => '价格获取失败',
			'devicesScreen.amountDue' => ({required Object amount}) => '应付 ¥${amount}',
			'devicesScreen.requote' => '重新算价',
			'devicesScreen.goPay' => '去支付',
			'devicesScreen.afterUpgrade' => '升级后：',
			'devicesScreen.afterLimit' => ({required Object limit}) => '设备上限 ${limit} 台',
			'devicesScreen.afterExpire' => ({required Object date}) => '到期 ${date}',
			'devicesScreen.pickSomething' => '请至少选择要增加的台数或天数',
			'devicesScreen.daysOnlyUnsupported' => '面板暂不支持「只延长时间」：请把「增加台数」选成 1 台及以上再试（或联系客服开通）。',
			'devicesScreen.paramsRejected' => '参数不被接受：请重新选择台数与天数。',
			'devicesScreen.subscriptionExpired' => '订阅已到期，无法升级：请先续费或重新购买套餐。',
			'devicesScreen.orderIncomplete' => '订单信息不完整，请点「重新算价」再试',
			'devicesScreen.orderRegenerated' => '原订单已失效，已按同样配置重新生成订单',
			'devicesScreen.payChannelIncomplete' => '订单或支付通道信息不完整，请重新算价后再试',
			'devicesScreen.noQrCode' => '后端没有返回支付二维码/链接，请换一个支付方式或稍后再试',
			'devicesScreen.payStartFailed' => ({required Object err}) => '支付发起失败：${err}',
			'devicesScreen.payCancelled' => '已取消本次支付；草稿订单已清理',
			'devicesScreen.balancePay' => '余额支付',
			'devicesScreen.noPayMethod' => '当前没有可用的支付方式，请稍后再试或联系客服',
			'devicesScreen.balanceInsufficient' => ({required Object balance, required Object amount}) => '余额不足（¥${balance}，需付 ¥${amount}）。\n是否先去充值？',
			'devicesScreen.choosePayMethod' => '选择支付方式',
			'devicesScreen.balanceText' => ({required Object balance}) => '余额 ¥${balance}',
			'devicesScreen.balanceShort' => ({required Object balance}) => '余额 ¥${balance}（不足，请先充值）',
			'devicesScreen.unknownDevice' => '未知设备',
			'devicesScreen.online' => '● 在线',
			'devicesScreen.offline' => '○ 离线',
			'devicesScreen.lastActive' => ({required Object text}) => '最近活跃 ${text}',
			'devicesScreen.delete' => '删除',
			'devicesScreen.deleteConfirm' => ({required Object name}) => '确认删除设备「${name}」？该设备会被立即踢下线。',
			'devicesScreen.lastActiveJustNow' => '刚刚',
			'devicesScreen.lastActiveMinutes' => ({required Object minutes}) => '${minutes} 分钟前',
			'devicesScreen.lastActiveToday' => ({required Object time}) => '今天 ${time}',
			'sysProxySheet.reading' => '读取中…',
			'sysProxySheet.unknown' => '未知',
			'sysProxySheet.kernelNotRunning' => '内核未运行（先在主页打开连接开关）',
			'sysProxySheet.applied' => ({required Object host, required Object port}) => '已生效 · ${host}:${port}',
			'sysProxySheet.notSet' => ({required Object reason}) => '未设置系统代理 —— ${reason}',
			'sysProxySheet.notEffective' => ({required Object port}) => '未生效（系统里没有指向 ${port} 的代理）',
			'sysProxySheet.readFailed' => ({required Object err}) => '读取失败：${err}',
			'sysProxySheet.setRejected' => '设置失败：系统可能拒绝了写入（或被其它代理软件覆盖）',
			'sysProxySheet.disableFailed' => '关闭失败',
			'sysProxySheet.portRange' => '端口需在 1–65535 之间',
			'sysProxySheet.portChanged' => ({required Object value}) => '端口已改为 ${value}：请断开重连一次，内核才会监听新端口',
			'sysProxySheet.title' => '系统代理',
			'sysProxySheet.desc' => ({required Object host}) => '系统代理地址固定为 ${host}（本机回环），端口就是内核的混合端口。',
			'sysProxySheet.descWindows' => 'Windows 的「设置 → 网络和 Internet → 代理」里看到的就是这个地址。',
			'sysProxySheet.reset' => '重新设置',
			'sysProxySheet.disable' => '关闭系统代理',
			'sysProxySheet.diagnostics' => '诊断详情（界面读的到底是不是注册表那份）',
			'sysProxySheet.mixedPort' => '混合端口',
			'sysProxySheet.apply' => '应用',
			'logScreen.readAppFailed' => ({required Object e}) => '读取应用日志失败：${e}',
			_ => null,
		} ?? switch (path) {
			'logScreen.readCoreFailed' => ({required Object e}) => '读取核心日志失败：${e}',
			'logScreen.copied' => '已复制（订阅地址等敏感信息已自动打码，日志文件本身仍可能包含原始地址）',
			'logScreen.copy' => '复制',
			'logScreen.refresh' => '刷新',
			'logScreen.empty' => '暂无内容',
			'trayShell.closeTitle' => '关闭窗口',
			'trayShell.closeBody' => '关闭窗口只是把 Mclash 收进托盘 —— 内核与系统代理会继续工作，网照旧能上。\n\n· 点「确定」：最小化到托盘（想彻底退出时，右键托盘图标 → 退出）\n· 点「取消」：完全退出 Mclash，同时停止内核并还原系统代理\n\n（本次选择会被记住；下次可直接右键托盘图标操作）',
			'ordersScreen.title' => '我的订单',
			'ordersScreen.orderInfoIncomplete' => '订单信息不完整，请下拉刷新后重试',
			'ordersScreen.payChannelIncomplete' => '支付通道信息不完整，请稍后重试',
			'ordersScreen.noQrPayload' => '后端没有返回支付二维码/链接，请换一个支付方式或稍后再试',
			'ordersScreen.payStartFailed' => ({required Object err}) => '发起支付失败：${err}',
			'ordersScreen.noPayMethod' => '当前没有可用的支付方式，请稍后再试或联系客服',
			'ordersScreen.choosePayMethod' => '选择支付方式',
			'ordersScreen.amountDue' => ({required Object amount}) => '应付 ¥${amount}',
			'ordersScreen.paidLabel' => '● 已支付',
			'ordersScreen.pendingLabel' => '○ 待支付',
			'ordersScreen.unknownStatus' => ({required Object status}) => '✕ ${status}',
			'ordersScreen.orderNoText' => ({required Object orderNo}) => '订单号 ${orderNo}',
			'ordersScreen.createdAtText' => ({required Object createdAt}) => '下单时间 ${createdAt}',
			'ordersScreen.orderCanceled' => '订单已取消',
			'ordersScreen.cancelFailed' => ({required Object err}) => '取消失败：${err}\n（若订单已被支付/已取消，下拉刷新即可看到最新状态）',
			'ordersScreen.cancelOrder' => '取消订单',
			'ordersScreen.continuePay' => '继续支付',
			'payment.balancePay' => '余额支付',
			'payment.qrPay' => '扫码支付',
			'payment.deductFromBalance' => '从账户余额扣款',
			'payment.openedInBrowser' => '已在浏览器中打开支付页面',
			'payment.scanWithAlipayWechat' => '请使用支付宝 / 微信扫码',
			'payment.orderNoText' => ({required Object orderNo}) => '订单号 ${orderNo}',
			'payment.payFailed' => ({required Object err}) => '支付失败：${err}',
			'payment.notDetected' => '未检测到支付。可稍后在「我的订单」中继续。',
			'payment.charging' => '正在扣款…',
			'payment.processing' => '处理中…',
			'payment.waitingPay' => '等待支付…',
			'payment.openPageFailed' => '没能打开支付页面，请点下方按钮重试，或改用扫码支付',
			'payment.reopenPayPage' => '重新打开支付页面',
			'payment.payInBrowser' => '在浏览器中支付',
			'payment.openAlipay' => '打开支付宝支付',
			'payment.cancelOrder' => '取消订单',
			'payment.confirmPay' => '确认支付',
			'payment.retry' => '重试',
			'payment.paidAlready' => '我已支付',
			'payment.channelAlipay' => '支付宝',
			'payment.channelCodepayAlipay' => '码支付 · 支付宝',
			'payment.channelCodepayWechat' => '码支付 · 微信',
			'payment.channelCodepay' => '码支付',
			'payment.channelWechat' => '微信支付',
			'payment.channelUsdt' => 'USDT',
			'payment.channelUsdtTrc20' => 'USDT · TRC20',
			'payment.payFallback' => '支付',
			'payment.errCsrf' => '登录凭证已过期（CSRF 校验失败）。\n请到「我的」下拉刷新或重新登录后重试。',
			'payment.errAlipayLimit' => '支付宝当面付单笔限额（本商户 ¥1000），本单金额超出。\n请改用「余额支付」或「码支付」，或联系客服提高支付宝限额。',
			'payment.errNotSigned' => '支付宝应用未签约对应的支付产品，暂时无法用这个通道。\n请改用「余额支付」或「码支付」，或联系客服开通。',
			'payment.errOrderGone' => '这笔订单已被取消或已过期（草稿订单 30 分钟有效期）。\n请点「重新算价」生成新订单再支付。',
			'payment.errNetwork' => ({required Object err}) => '网络不通：${err}',
			'planScreen.recommended' => '推荐',
			'planScreen.devices' => '设备',
			'planScreen.balanceLabel' => ({required Object amount}) => '余额 ¥${amount}',
			'planScreen.balanceInsufficient' => '（不足，请先充值）',
			'planScreen.total' => '合计',
			'planScreen.payNow' => '立即支付',
			'planScreen.retry' => '重试',
			'planScreen.errIncompleteOrder' => '订单或支付通道信息不完整，无法发起支付',
			'planScreen.payBalance' => '余额支付',
			'planScreen.payAlipay' => '支付宝',
			'planScreen.payWechat' => '微信支付',
			'planScreen.payCodepay' => '码支付',
			'planScreen.payCodepayAlipay' => '码支付 · 支付宝',
			'planScreen.payCodepayWechat' => '码支付 · 微信',
			'planScreen.payEpayAlipay' => '易支付 · 支付宝',
			'planScreen.payEpayWechat' => '易支付 · 微信',
			'planScreen.payUsdt' => 'USDT',
			'planScreen.payUsdtTrc20' => 'USDT · TRC20',
			'planScreen.payStripe' => 'Stripe',
			'planScreen.payPaypal' => 'PayPal',
			'planScreen.payOnline' => '在线支付',
			'authScreen.saveAccountInfo' => '保存账号信息',
			'authScreen.autoLoginNextTime' => '下次打开自动登录',
			'authScreen.needLoginNextTime' => '下次打开需要重新登录',
			'authScreen.invalidEmail' => '请填写有效邮箱',
			'authScreen.enterEmailFirst' => '请先填写有效邮箱',
			'authScreen.passwordRequired' => '请填写密码',
			'authScreen.wrongCredentials' => '邮箱或密码错误',
			'authScreen.requestRejected' => '请求被拒绝，请稍后重试',
			'authScreen.tooFrequent' => '操作过于频繁，请稍后再试',
			'authScreen.loginFailed' => '登录失败',
			'authScreen.username' => '用户名',
			'authScreen.confirmPassword' => '确认密码',
			'authScreen.inviteCode' => '邀请码',
			'authScreen.emailCode' => '邮箱验证码',
			'authScreen.getCode' => '获取验证码',
			'authScreen.registerAndLogin' => '注册并登录',
			'authScreen.usernameMinLength' => ({required Object min}) => '用户名至少 ${min} 位',
			'authScreen.passwordMismatch' => '两次输入的密码不一致',
			'authScreen.emailCodeRequired' => '请填写邮箱验证码',
			'authScreen.inviteCodeRequired' => '本站注册需要邀请码',
			'authScreen.codeSentCheckEmail' => '验证码已发送，请查收邮件',
			'authScreen.registerSuccess' => '注册成功，已自动登录',
			'authScreen.passwordHint' => ({required Object min}) => '至少 ${min} 位，且同时包含字母和数字',
			'authScreen.passwordTooShort' => ({required Object min}) => '密码长度不能少于 ${min} 位',
			'authScreen.passwordNeedsLetterAndDigit' => '密码必须包含字母和数字',
			'authScreen.registeredEmail' => '注册邮箱',
			'authScreen.newPassword' => '新密码',
			'authScreen.confirmNewPassword' => '确认新密码',
			'authScreen.resetPassword' => '重置密码',
			'authScreen.resetCodeSent' => '如果该邮箱已注册，重置验证码已发送（15 分钟内有效）。',
			'authScreen.resetSuccess' => '密码已重置，请用新密码登录',
			'authScreen.changePasswordTitle' => '修改密码',
			'authScreen.currentPassword' => '当前密码',
			'authScreen.saveNewPassword' => '保存新密码',
			'authScreen.newPasswordMismatch' => '两次输入的新密码不一致',
			'authScreen.changePasswordSuccess' => '密码已修改，请重新登录',
			'updatePrompt.checking' => '正在检查更新…',
			'updatePrompt.checkFailed' => '检查更新失败，请检查网络后重试。',
			'updatePrompt.alreadyLatest' => ({required Object version}) => '已是最新版本（${version}）。',
			'updatePrompt.newVersionFound' => ({required Object version}) => '发现新版本 ${version}',
			'updatePrompt.installerDownloaded' => '安装包已在后台下载完成，点「立即更新」完成升级。',
			'updatePrompt.downloadInBackground' => '点「立即更新」开始下载并安装（也可继续使用，安装包会在后台下载）。',
			'updatePrompt.later' => '稍后',
			'updatePrompt.updateNow' => '立即更新',
			'updatePrompt.installerNotReady' => ({required Object version}) => '安装包还没下载完成。\n\n点「确定」打开下载页，手动下载适合你设备的安装包（版本 ${version}）。',
			'clearData.itemLoginSession' => '登录会话',
			'clearData.itemProfiles' => '订阅配置档（profiles/）',
			'clearData.itemSettings' => '应用与内核设置',
			'clearData.itemLatencyCache' => '节点延迟缓存',
			'clearData.itemLogs' => '运行日志',
			'clearData.itemRoutingData' => '分流数据与临时文件',
			'clearData.confirmBody' => ({required Object items, required Object dir}) => '将删除本机保存的以下数据（不可恢复）：\n\n${items}\n\n账号本身、已购买的套餐都在服务器上，不受影响；重新登录即可恢复订阅。\n\n数据目录：${dir}\n（卸载 App 之前先点这里，重装后才会是干净的、需要重新登录的状态）',
			'clearData.confirmAgain' => '确认清除？清除后需要重新登录。',
			'clearData.clearedNotice' => ({required Object count, required Object dir}) => '已清除 ${count} 项本地数据（含登录会话，下次打开需要重新登录）。\n\n现在可以删除 App 完成卸载：\n· macOS：把 Mclash.app 拖进废纸篓（数据目录已清空：${dir}）\n· Windows：控制面板卸载 Mclash，卸载向导里的「是否保留用户数据」选「否」',
			'clearData.clearFailed' => ({required Object error}) => '清除失败：${error}',
			'apiError.requestFailedHttp' => ({required Object status, required Object domain}) => '请求失败（HTTP ${status}），已尝试域名 ${domain}',
			'apiError.allDomainsFailed' => ({required Object method, required Object path, required Object count}) => '请求失败：${method} ${path}（已尝试 ${count} 个域名）',
			'apiError.requestTimeout' => ({required Object seconds, required Object method, required Object path}) => '请求超时（${seconds}s）：${method} ${path}',
			'apiError.networkUnreachable' => ({required Object detail}) => '网络不可达：${detail}',
			'apiError.tlsHandshakeFailed' => 'TLS 握手失败，请检查网络或系统时间',
			'apiError.connectionFailed' => ({required Object detail}) => '连接失败：${detail}',
			'apiError.requestError' => ({required Object error}) => '请求失败：${error}',
			'apiError.responseReadTimeout' => ({required Object seconds, required Object method, required Object path}) => '读取响应超时（${seconds}s）：${method} ${path}',
			'apiError.notJson' => ({required Object status, required Object snippet}) => '响应不是 JSON（HTTP ${status}）：${snippet}',
			'apiError.badStructure' => ({required Object status}) => '响应结构异常（HTTP ${status}）',
			'apiError.loginFailed' => ({required Object code}) => '登录失败（code ${code}）',
			'apiError.loginMissingData' => '登录响应缺少 data',
			'apiError.loginMissingToken' => '登录响应缺少 access_token',
			'apiError.registerFailed' => ({required Object code}) => '注册失败（code ${code}）',
			'apiError.registerMissingToken' => '注册响应未包含 access_token，可能触发了风控或站点配置不同',
			'apiError.requestFailedCode' => ({required Object code}) => '请求失败（code ${code}）',
			'subNotice.titleNotFound' => '订阅不存在',
			'subNotice.titleExpired' => '订阅已过期',
			'subNotice.titleInactive' => '订阅已失效',
			'subNotice.titleDeviceOverLimit' => '设备数量超限',
			'subNotice.titleUnavailable' => '订阅不可用',
			'subNotice.titleWithReason' => ({required Object emoji, required Object title, required Object reason}) => '${emoji} ${title}（${reason}）',
			'subNotice.deviceUsedOfLimit' => ({required Object used, required Object limit}) => '当前设备 ${used}/${limit}',
			'subNotice.deviceUsedOnly' => ({required Object used}) => '当前设备 ${used}',
			'subNotice.expireAt' => ({required Object expire}) => '到期时间 ${expire}',
			'subNotice.supportLine' => ({required Object account}) => '💬 客服: ${account}',
			'subNotice.siteLine' => ({required Object url}) => '📢 官网: ${url}',
			'settingItems.subscriptionAutoUpdateInterval' => '订阅自动更新间隔',
			'settingItems.speedTestMode' => '测速方式',
			'settingItems.speedTestModeTcp' => 'TCP 测速',
			'settingItems.speedTestModeKernel' => '内核测速',
			'settingItems.delayTestUrlTip' => '经该节点完整走一次 HTTP 请求的耗时（非 ping）\n默认用明文 http 的 204 空响应；换成 https 会多一次 TLS 握手，数字更大',
			'settingItems.systemProxy' => '系统代理',
			'settingItems.systemProxyTip' => '查看/重设地址与端口',
			'settingItems.tunMode' => 'TUN 模式',
			'settingItems.tunModeTip' => 'off=仅系统代理 / auto=TUN+系统代理 / force=仅 TUN\n桌面端 TUN 需要管理员权限（Windows 建 wintun / macOS 建 utun）',
			'settingItems.tunOverwriteTip' => 'overwrite\n开 = 用这里的 TUN 设置覆盖订阅里的 tun 段\n关 = 让订阅自己的 tun 配置生效（App 不插手）',
			'settingItems.tunEnableByTunMode' => ({required Object enable}) => '${enable}（由 TUN 模式决定）',
			'settingItems.interval30Minutes' => '30 分钟',
			'settingItems.interval1Hour' => '1 小时',
			'settingItems.interval6Hours' => '6 小时',
			'settingItems.interval12Hours' => '12 小时',
			'settingItems.interval24Hours' => '24 小时',
			'settingItems.interval3Days' => '3 天',
			'settingItems.interval7Days' => '7 天',
			'settingItems.intervalNever' => '从不',
			'settingItems.intervalMinutes' => ({required Object minutes}) => '${minutes} 分钟',
			'settingItems.intervalHours' => ({required Object hours}) => '${hours} 小时',
			'settingItems.intervalDays' => ({required Object days}) => '${days} 天',
			'tunScreen.modeOff' => '关闭',
			'tunScreen.modeAuto' => '自动',
			'tunScreen.modeForce' => '强制',
			'tunScreen.modeOffDesc' => '仅系统代理：浏览器等遵守系统代理的程序生效，UDP/游戏不走代理',
			'tunScreen.modeAutoDesc' => 'TUN + 系统代理（双保险）：全部流量走虚拟网卡，含 UDP',
			'tunScreen.modeForceDesc' => '仅 TUN：全部流量走虚拟网卡，不再改系统代理',
			'tunScreen.modeOffOptionDesc' => '不改系统路由表，只在系统里设置 127.0.0.1 的代理。只有遵守系统代理的程序走代理；UDP 流量与自带代理设置的程序不走。',
			'tunScreen.modeAutoOptionDesc' => '建虚拟网卡接管全部流量（含 UDP、游戏）；同时保留系统代理作为兜底。推荐：既能全局生效，又不会因为权限问题彻底没网。',
			'tunScreen.modeForceOptionDesc' => '只用虚拟网卡，不再改系统代理。全部流量（含 UDP）都进隧道，系统里「代理」一项保持原样。',
			'tunScreen.adminRequiredDialog' => 'TUN 虚拟网卡需要管理员权限（Windows 建 wintun / macOS 建 utun）。\n\n当前 Mclash 不是以管理员身份运行的，开启后 TUN 不会生效（「自动」模式下系统代理仍会兜底，网络可用）。\n\n点「确定」= 现在以管理员身份重启 Mclash（会弹 UAC）\n点「取消」= 仍要保存这个选择（TUN 不生效时会自动用系统代理）',
			'tunScreen.relaunchFailed' => ({required Object message}) => '重启失败：${message}',
			'tunScreen.switchFailed' => ({required Object message}) => '切换 TUN 模式失败：${message}\n已恢复原来的设置。',
			'tunScreen.setOffSnack' => '已设为「关闭」：只使用系统代理',
			'tunScreen.setModeSnack' => ({required Object mode, required Object effect}) => '已设为「${mode}」，${effect}',
			'tunScreen.effectReconnected' => '已重连生效',
			'tunScreen.effectAfterConnect' => '连接后生效',
			'tunScreen.sheetTitle' => 'TUN 虚拟网卡',
			'tunScreen.advancedTitle' => '高级参数（核心设置 → TUN）',
			'tunScreen.advancedSubtitle' => '虚拟网卡地址 / 栈 / MTU / 自动路由 / DNS 劫持 / 覆写',
			'tunScreen.adminOk' => 'TUN 需要管理员权限；当前权限满足（Windows 以管理员运行 / macOS 以 root 运行）',
			'tunScreen.adminMissing' => 'TUN 需要管理员权限：当前未以管理员身份运行，选中「自动/强制」后 TUN 不会生效（「自动」会用系统代理兜底，网络仍可用）',
			_ => null,
		};
	}
}
