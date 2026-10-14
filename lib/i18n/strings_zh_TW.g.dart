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
class TranslationsZhTw with BaseTranslations<AppLocale, Translations> implements Translations {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	TranslationsZhTw({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: AppLocale.zhTw,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <zh-TW>.
	final TranslationMetadata<AppLocale, Translations> _meta;
	@override TranslationMetadata<AppLocale, Translations> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key);

	late final TranslationsZhTw _root = this; // ignore: unused_field

	@override 
	TranslationsZhTw $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => TranslationsZhTw(meta: meta ?? this.$meta);

	// Translations
	@override late final Translations$BackupAndSyncWebdavScreen$zh_TW BackupAndSyncWebdavScreen = Translations$BackupAndSyncWebdavScreen$zh_TW.internal(_root);
	@override late final Translations$LaunchFailedScreen$zh_TW LaunchFailedScreen = Translations$LaunchFailedScreen$zh_TW.internal(_root);
	@override late final Translations$PerAppAndroidScreen$zh_TW PerAppAndroidScreen = Translations$PerAppAndroidScreen$zh_TW.internal(_root);
	@override late final Translations$UserAgreementScreen$zh_TW UserAgreementScreen = Translations$UserAgreementScreen$zh_TW.internal(_root);
	@override late final Translations$NetCheckScreen$zh_TW NetCheckScreen = Translations$NetCheckScreen$zh_TW.internal(_root);
	@override late final Translations$VersionUpdateScreen$zh_TW VersionUpdateScreen = Translations$VersionUpdateScreen$zh_TW.internal(_root);
	@override late final Translations$loginScreen$zh_TW loginScreen = Translations$loginScreen$zh_TW.internal(_root);
	@override late final Translations$main$zh_TW main = Translations$main$zh_TW.internal(_root);
	@override late final Translations$meta$zh_TW meta = Translations$meta$zh_TW.internal(_root);
	@override late final Translations$permission$zh_TW permission = Translations$permission$zh_TW.internal(_root);
	@override late final Translations$tls$zh_TW tls = Translations$tls$zh_TW.internal(_root);
	@override late final Translations$tun$zh_TW tun = Translations$tun$zh_TW.internal(_root);
	@override late final Translations$dns$zh_TW dns = Translations$dns$zh_TW.internal(_root);
	@override late final Translations$sniffer$zh_TW sniffer = Translations$sniffer$zh_TW.internal(_root);
	@override late final Translations$profilePatchMode$zh_TW profilePatchMode = Translations$profilePatchMode$zh_TW.internal(_root);
	@override String sendOrReceiveNotMatch({required Object p}) => '請使用 [${p}]';
	@override String targetConnectFailed({required Object p}) => '連線 [${p}] 失敗, 請確保設備在同一個區域網路內';
	@override String get edgeRuntimeNotInstalled => '當前設備尚未安裝Edge WebView2運行時,無法展示頁面,請下載安裝Edge WebView2運行時(x64)後,重啟App再試';
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
		'TW': '台灣',
		'MO': '澳門',
		'CN': '中國',
		'JP': '日本',
		'KR': '韓國',
		'SG': '新加坡',
		'MY': '馬來西亞',
		'TH': '泰國',
		'VN': '越南',
		'PH': '菲律賓',
		'ID': '印尼',
		'KH': '柬埔寨',
		'US': '美國',
		'CA': '加拿大',
		'MX': '墨西哥',
		'GB': '英國',
		'DE': '德國',
		'FR': '法國',
		'NL': '荷蘭',
		'RU': '俄羅斯',
		'IT': '義大利',
		'ES': '西班牙',
		'CH': '瑞士',
		'SE': '瑞典',
		'NO': '挪威',
		'FI': '芬蘭',
		'DK': '丹麥',
		'PL': '波蘭',
		'AT': '奧地利',
		'IE': '愛爾蘭',
		'UA': '烏克蘭',
		'TR': '土耳其',
		'PT': '葡萄牙',
		'CZ': '捷克',
		'RO': '羅馬尼亞',
		'BE': '比利時',
		'GR': '希臘',
		'HU': '匈牙利',
		'IL': '以色列',
		'AE': '阿聯酋',
		'SA': '沙烏地',
		'EG': '埃及',
		'ZA': '南非',
		'NG': '奈及利亞',
		'AU': '澳洲',
		'NZ': '紐西蘭',
		'BR': '巴西',
		'AR': '阿根廷',
		'CL': '智利',
		'CO': '哥倫比亞',
		'IN': '印度',
		'PK': '巴基斯坦',
		'XX': '其他',
	};
	@override late final Translations$meScreen$zh_TW meScreen = Translations$meScreen$zh_TW.internal(_root);
	@override late final Translations$homeScreen$zh_TW homeScreen = Translations$homeScreen$zh_TW.internal(_root);
	@override late final Translations$nodesScreen$zh_TW nodesScreen = Translations$nodesScreen$zh_TW.internal(_root);
	@override late final Translations$nodeAuto$zh_TW nodeAuto = Translations$nodeAuto$zh_TW.internal(_root);
	@override late final Translations$accountBlock$zh_TW accountBlock = Translations$accountBlock$zh_TW.internal(_root);
	@override late final Translations$entitlementMsg$zh_TW entitlementMsg = Translations$entitlementMsg$zh_TW.internal(_root);
	@override late final Translations$devicesScreen$zh_TW devicesScreen = Translations$devicesScreen$zh_TW.internal(_root);
	@override late final Translations$sysProxySheet$zh_TW sysProxySheet = Translations$sysProxySheet$zh_TW.internal(_root);
	@override late final Translations$logScreen$zh_TW logScreen = Translations$logScreen$zh_TW.internal(_root);
	@override late final Translations$trayShell$zh_TW trayShell = Translations$trayShell$zh_TW.internal(_root);
	@override late final Translations$ordersScreen$zh_TW ordersScreen = Translations$ordersScreen$zh_TW.internal(_root);
	@override late final Translations$payment$zh_TW payment = Translations$payment$zh_TW.internal(_root);
	@override late final Translations$planScreen$zh_TW planScreen = Translations$planScreen$zh_TW.internal(_root);
	@override late final Translations$authScreen$zh_TW authScreen = Translations$authScreen$zh_TW.internal(_root);
	@override late final Translations$updatePrompt$zh_TW updatePrompt = Translations$updatePrompt$zh_TW.internal(_root);
	@override late final Translations$clearData$zh_TW clearData = Translations$clearData$zh_TW.internal(_root);
	@override late final Translations$apiError$zh_TW apiError = Translations$apiError$zh_TW.internal(_root);
	@override late final Translations$subNotice$zh_TW subNotice = Translations$subNotice$zh_TW.internal(_root);
	@override late final Translations$settingItems$zh_TW settingItems = Translations$settingItems$zh_TW.internal(_root);
	@override late final Translations$tunScreen$zh_TW tunScreen = Translations$tunScreen$zh_TW.internal(_root);
}

// Path: BackupAndSyncWebdavScreen
class Translations$BackupAndSyncWebdavScreen$zh_TW implements Translations$BackupAndSyncWebdavScreen$en {
	Translations$BackupAndSyncWebdavScreen$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get webdavServerUrl => '伺服器地址';
	@override String get webdavRequired => '不能為空';
	@override String get webdavLoginFailed => '登錄失敗:';
	@override String get webdavListFailed => '獲取文件列表失敗:';
}

// Path: LaunchFailedScreen
class Translations$LaunchFailedScreen$zh_TW implements Translations$LaunchFailedScreen$en {
	Translations$LaunchFailedScreen$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get invalidProcess => '應用啟動失敗[無效的進程名稱],請重新安裝應用到獨立目錄';
	@override String get invalidProfile => '應用啟動失敗[訪問設定檔失敗],請重新安裝應用';
	@override String get invalidVersion => '應用啟動失敗[無效版本],請重新安裝應用';
	@override String get systemVersionLow => '應用啟動失敗[系統版本過低]';
	@override String get invalidInstallPath => '無效的安裝路徑,請重新安裝到有效路徑';
}

// Path: PerAppAndroidScreen
class Translations$PerAppAndroidScreen$zh_TW implements Translations$PerAppAndroidScreen$en {
	Translations$PerAppAndroidScreen$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get title => '分應用代理';
	@override String get whiteListMode => '白名單模式';
	@override String get whiteListModeTip => '啟用後:僅代理已勾選的App;未啟用:僅代理未勾選的App';
}

// Path: UserAgreementScreen
class Translations$UserAgreementScreen$zh_TW implements Translations$UserAgreementScreen$en {
	Translations$UserAgreementScreen$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get privacyFirst => '您的隱私很重要';
	@override String get agreeAndContinue => '接受並繼續';
}

// Path: NetCheckScreen
class Translations$NetCheckScreen$zh_TW implements Translations$NetCheckScreen$en {
	Translations$NetCheckScreen$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get enterDomain => '請輸入網域名稱';
	@override String get checking => '檢測中...';
	@override String aQueryFailed({required Object p}) => 'A 查詢失敗: ${p}';
	@override String aaaaQueryFailed({required Object p}) => 'AAAA 查詢失敗: ${p}';
	@override String get success => '成功';
	@override String get failed => '失敗';
	@override String get suspectedPollution => '疑似被污染';
	@override String get domainLabel => '網域名稱';
	@override String get checkButton => '檢測';
	@override String get dnsSection => '1. DNS查詢';
	@override String get directHttpSection => '2. HTTP (經由TUN,請先啟用TUN)';
	@override String proxyHttpSection({required Object p}) => '3. HTTP (經由代理,連接埠:${p})';
	@override String get tunNotEnabled => 'TUN 未啟用';
	@override String get routeTableSection => '4. 路由表';
}

// Path: VersionUpdateScreen
class Translations$VersionUpdateScreen$zh_TW implements Translations$VersionUpdateScreen$en {
	Translations$VersionUpdateScreen$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String versionReady({required Object p}) => '新版本[${p}]已就緒';
	@override String get update => '重啟更新';
	@override String get cancel => '暫不更新';
}

// Path: loginScreen
class Translations$loginScreen$zh_TW implements Translations$loginScreen$en {
	Translations$loginScreen$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get login => '登錄';
	@override String get register => '註冊賬號';
	@override String get forgotPassword => '忘記密碼';
	@override String get provider => '服務商';
	@override String get providerName => '${_root.loginScreen.provider}編碼/別名/URL';
	@override String get account => '賬號';
	@override String get email => '郵箱';
	@override String get password => '密碼';
}

// Path: main
class Translations$main$zh_TW implements Translations$main$en {
	Translations$main$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override late final Translations$main$tray$zh_TW tray = Translations$main$tray$zh_TW.internal(_root);
}

// Path: meta
class Translations$meta$zh_TW implements Translations$meta$en {
	Translations$meta$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get enable => '啟用';
	@override String get disable => '禁用';
	@override String get open => '打開';
	@override String get close => '關閉';
	@override String get quit => '退出';
	@override String get add => '添加';
	@override String get remove => '刪除';
	@override String get removeConfirm => '確認刪除?';
	@override String get edit => '編輯';
	@override String get view => '查看';
	@override String get remark => '備註';
	@override String get byDefault => '預設';
	@override String get more => '更多';
	@override String get tips => '提示';
	@override String get selectAll => '全選';
	@override String get copy => '複製';
	@override String get paste => '貼上';
	@override String get cut => '剪切';
	@override String get save => '儲存';
	@override String get ok => '確定';
	@override String get cancel => '取消';
	@override String get faq => '常見問題';
	@override String get doc => '文檔';
	@override String get htmlTools => 'HTML工具集';
	@override String get download => '下載';
	@override String get loading => '載入中...';
	@override String get days => '天';
	@override String get hours => '時';
	@override String get minutes => '分';
	@override String get seconds => '秒';
	@override String get milliseconds => '毫秒';
	@override String get search => '搜索';
	@override String get searchNodeHint => '篩選節點（名稱或協定）';
	@override String get connect => '連接';
	@override String get disconnect => '斷開';
	@override String get connected => '已連接';
	@override String get disconnected => '未連接';
	@override String get connecting => '連接中';
	@override String get connectTimeout => '連接超時';
	@override String get timeout => '超時';
	@override String get latencyTest => '延遲檢測';
	@override String get networkCheck => '網路檢測';
	@override String get language => '語言';
	@override String get next => '下一步';
	@override String get done => '完成';
	@override String get apply => '應用';
	@override String get refresh => '刷新';
	@override String get update => '更新';
	@override String get updateInterval => '更新時間間隔';
	@override String get updateInterval5mTips => '最小:5m';
	@override String get updateIntervalPreferByProfile => '優先使用服務商(機場)設定';
	@override String updateFailed({required Object p}) => '更新失敗:${p}';
	@override String get none => '無';
	@override String get reset => '重置';
	@override String get authentication => '授權';
	@override String get user => '用戶';
	@override String get account => '賬號';
	@override String get password => '密碼';
	@override String get decryptPassword => '解密密碼';
	@override String get required => '必填';
	@override String get go => '繼續';
	@override String get other => '其他';
	@override String get dns => 'DNS';
	@override String get url => 'URL';
	@override String get urlInvalid => 'URL無效';
	@override String get copyUrl => '複製連結';
	@override String get openUrl => '打開連結';
	@override String get coreSettingTips => '注意:修改配置後,需要重新連接才會生效';
	@override String get overwrite => '覆寫';
	@override String get overwriteAppend => '追加覆寫';
	@override String get overwriteTips => '原始配置<-自定義覆寫<-App覆寫';
	@override String get noOverwrite => '不覆寫';
	@override String get diversionTemplates => '分流模板';
	@override String get ruleProviders => '規則提供者';
	@override String get ruleTemplates => '規則模板';
	@override String get proxyGroupsTemplates => '代理組模板';
	@override String get proxyGroups => '代理組';
	@override String get proxyNodeList => '代理節點列表';
	@override String proxyNodeFailure({required Object p}) => '下列代理節點已失效,已自動移除:${p}';
	@override String get externalController => '外部控制';
	@override String get secret => '金鑰';
	@override String get tcpConcurrent => 'TCP併發握手';
	@override String get globalClientFingerprint => 'TLS全局指紋';
	@override String get allowLanAccess => '局域網設備接入';
	@override String get mixedPort => '混合代理端口';
	@override String get logLevel => '日誌等級';
	@override String get findProcessMode => '進程匹配模式';
	@override String get tcpkeepAliveInterval => 'TCP保活時間間隔';
	@override String get delayTestUrl => '延遲測試URL';
	@override String get delayTestTimeout => '延遲測試超時(ms)';
	@override String get tun => 'TUN';
	@override String get ntp => 'NTP';
	@override String get tls => 'TLS';
	@override String get geoDownloadByProxy => '使用代理下載Geo RuleSet';
	@override String get geoRulesetTips => 'Geosite/Geoip 會被轉換成 對應的RuleSet';
	@override String get sniffer => '嗅探';
	@override String get userAgent => 'UserAgent';
	@override String get launchAtStartup => '開機啟動';
	@override String get launchAtStartupRunAsAdmin => '請以管理員身份重新啟動Mclash';
	@override String get tunModeRunAsAdmin => 'TUN模式需要系統管理員權限,請以管理員身份重新啟動應用';
	@override String get portableMode => '便攜模式';
	@override String get portableModeDisableTips => '如需退出便攜模式,請退出[mclash]後,手動刪除[mclash.exe]同目錄下的[portable]文件夾即可';
	@override String get autoConnectAfterLaunch => '啟動後自動連接';
	@override String get autoConnectAtBoot => '系統啟動後自動連接';
	@override String get autoConnectAtBootTips => '需要系統支持,部分系統可能還需要開啟[自啟動]';
	@override String get hideAfterLaunch => '啟動後隱藏窗口';
	@override String get autoSetSystemProxy => '連接後自動設置系統代理';
	@override String get bypassSystemProxy => '允許繞過系統代理的域名';
	@override String get excludeFromRecent => '從[最近任務]中隱藏';
	@override String get wakeLock => '喚醒鎖';
	@override String get hideDockIcon => '隱藏Dock圖標';
	@override String get showTrayTraffic => '托盤上顯示流量資訊';
	@override String get website => '官網';
	@override String get rule => '規則';
	@override String get global => '全局';
	@override String get direct => '直連';
	@override String get qrcode => '二維碼';
	@override String get qrcodeTooLong => '文本過長,無法展示';
	@override String get qrcodeShare => '分享二維碼';
	@override String get qrcodeScan => '掃描二維碼';
	@override String get qrcodeScanResult => '掃描結果';
	@override String get backupAndSync => '備份與同步';
	@override String get export => '匯出';
	@override String get send => '發送';
	@override String get sendConfirm => '確認發送?';
	@override String get log => '日誌';
	@override String get coreLog => '核心日誌';
	@override String get appLog => '應用日誌';
	@override String get core => '核心';
	@override String get help => '幫助';
	@override String get tutorial => '使用教程';
	@override String get board => '面板';
	@override String get boardOnline => '使用在線面板';
	@override String get boardOnlineUrl => '在線面板URL';
	@override String get boardLocalPort => '本地面板端口';
	@override String get alwayOnVPN => '始終開啟連線';
	@override String get disableFontScaler => '禁用字體縮放';
	@override String get autoOrientation => '跟隨螢幕旋轉';
	@override String get restartTakesEffect => '重啟生效';
	@override String get reconnectTakesEffect => '重新連接後生效';
	@override String get runtimeProfile => '運行時配置';
	@override String get willCompleteAfterRebootInstall => '請重啟設備,以便完成系統擴展安裝';
	@override String get requestNeedsUserApproval => '1. 請在[系統設置]-[隱私與安全性]裏[允許] Mclash安裝系統擴展\n2. :[系統設置]-[通用]-[登錄項與擴展-網絡擴展]啟用[mclashServiceSE]\n完成後重新連接';
	@override String get FullDiskAccessPermissionRequired => '請在[系統設置]-[隱私與安全性]-[完全磁盤訪問權限]裏開啟mclashServiceSE權限後,重新連接';
	@override String get proxy => '代理';
	@override String get theme => '主題';
	@override String get tvMode => 'TV模式';
	@override String get autoUpdate => '自動更新';
	@override String get updateChannel => '自動更新通道';
	@override String hasNewVersion({required Object p}) => '更新版本 ${p}';
	@override String get autoDownloadPkg => '自動下載更新包';
	@override String get devOptions => '開發者選項';
	@override String get about => '關於';
	@override String get name => '名稱';
	@override String get version => '版本';
	@override String get sort => '排序';
	@override String get share => '分享';
	@override String get importFromClipboard => '從剪貼簿導入';
	@override String get exportToClipboard => '匯出到剪貼簿';
	@override String get server => '伺服器';
	@override String get port => '端口';
	@override String get donate => '捐助';
	@override String get setting => '設定';
	@override String get settingCore => '核心設定';
	@override String get settingApp => '應用設定';
	@override String get coreOverwrite => '核心覆寫';
	@override String get iCloud => 'iCloud';
	@override String get webdav => 'Webdav';
	@override String get lanSync => '局域網同步';
	@override String get lanSyncNotQuitTips => '同步完成前請勿退出此界面';
	@override String get deviceNoSpace => '磁盤空間不足';
	@override String get hideSystemApp => '隱藏系統應用';
	@override String get hideAppIcon => '隱藏應用圖標';
	@override String get openDir => '打開文件目錄';
	@override String get type => '類型';
	@override String fileNotExist({required Object p}) => '文件不存在:${p}';
	@override String get buyProfile => '購買設定';
	@override String get myProfiles => '我的設定';
	@override String get profileEdit => '編輯設定';
	@override String get profileNeedActive => '請先將本設定設為目前設定，並開啟連線/重新連線';
	@override String profileUrlOrContent({required Object p}) => '${p}設定連結';
	@override String get tabHome => '首頁';
	@override String get tabNodes => '節點列表';
	@override String get tabPlans => '套餐購買';
	@override String get tabMe => '我的';
}

// Path: permission
class Translations$permission$zh_TW implements Translations$permission$en {
	Translations$permission$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get camera => '攝像頭';
	@override String get screen => '屏幕錄製';
	@override String get appQuery => '獲取應用列表';
	@override String request({required Object p}) => '開啟[${p}]權限';
	@override String requestNeed({required Object p}) => '請開啟[${p}]權限';
}

// Path: tls
class Translations$tls$zh_TW implements Translations$tls$en {
	Translations$tls$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get certificate => '證書';
	@override String get privateKey => '私鑰';
	@override String get customTrustCert => '自定義證書';
}

// Path: tun
class Translations$tun$zh_TW implements Translations$tun$en {
	Translations$tun$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get stack => '網絡棧';
	@override String get inet4Address => 'IPv4位址段';
	@override String get dnsHijack => 'DNS劫持';
	@override String get strictRoute => '嚴格路由';
	@override String get tunDefaultRoute => '預設路由';
	@override String get icmpForward => 'ICMP 轉發';
	@override String get allowBypass => '允許應用繞過VPN';
	@override String get appendHttpProxy => '附加HTTP代理到VPN';
	@override String get bypassHttpProxyDomain => '允許繞過HTTP代理的域名';
}

// Path: dns
class Translations$dns$zh_TW implements Translations$dns$en {
	Translations$dns$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get listen => '監聽地址';
	@override String get fakeIp => 'fake-ip';
	@override String get fallback => 'Fallback';
	@override String get preferH3 => 'DoH H3優先';
	@override String get useHosts => '使用Hosts';
	@override String get useSystemHosts => '使用系統Hosts';
	@override String get enhancedMode => '增強模式';
	@override String get fakeIPFilterMode => '${_root.dns.fakeIp} 過濾模式';
	@override String get fakeIPFilter => '${_root.dns.fakeIp} 過濾';
	@override String get respectRules => '遵守[rules]規則';
	@override String get nameServer => '域名解析伺服器';
	@override String get defaultNameServer => '${_root.meta.byDefault} ${_root.dns.nameServer}';
	@override String get proxyNameServer => '${_root.meta.proxy} ${_root.dns.nameServer}';
	@override String get directNameServer => '${_root.meta.direct} ${_root.dns.nameServer}';
	@override String get fallbackNameServer => '${_root.dns.fallback} ${_root.dns.nameServer}';
	@override String get fallbackGeoIp => '${_root.dns.fallback} GeoIp';
	@override String get fallbackGeoIpCode => '${_root.dns.fallback} GeoIp 代碼';
}

// Path: sniffer
class Translations$sniffer$zh_TW implements Translations$sniffer$en {
	Translations$sniffer$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get overrideDest => '覆蓋';
}

// Path: profilePatchMode
class Translations$profilePatchMode$zh_TW implements Translations$profilePatchMode$en {
	Translations$profilePatchMode$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get currentSelected => '當前選擇';
	@override String get overwrite => '內置-覆寫';
	@override String get noOverwrite => '內置-不覆寫';
}

// Path: meScreen
class Translations$meScreen$zh_TW implements Translations$meScreen$en {
	Translations$meScreen$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

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
class Translations$homeScreen$zh_TW implements Translations$homeScreen$en {
	Translations$homeScreen$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

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
class Translations$nodesScreen$zh_TW implements Translations$nodesScreen$en {
	Translations$nodesScreen$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

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
class Translations$nodeAuto$zh_TW implements Translations$nodeAuto$en {
	Translations$nodeAuto$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

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
class Translations$accountBlock$zh_TW implements Translations$accountBlock$en {
	Translations$accountBlock$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

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
class Translations$entitlementMsg$zh_TW implements Translations$entitlementMsg$en {
	Translations$entitlementMsg$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

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
class Translations$devicesScreen$zh_TW implements Translations$devicesScreen$en {
	Translations$devicesScreen$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

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
}

// Path: sysProxySheet
class Translations$sysProxySheet$zh_TW implements Translations$sysProxySheet$en {
	Translations$sysProxySheet$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

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
class Translations$logScreen$zh_TW implements Translations$logScreen$en {
	Translations$logScreen$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String readAppFailed({required Object e}) => '读取应用日志失败：${e}';
	@override String readCoreFailed({required Object e}) => '读取核心日志失败：${e}';
	@override String get copied => '已复制（订阅地址等敏感信息已自动打码，日志文件本身仍可能包含原始地址）';
	@override String get copy => '复制';
	@override String get refresh => '刷新';
	@override String get empty => '暂无内容';
}

// Path: trayShell
class Translations$trayShell$zh_TW implements Translations$trayShell$en {
	Translations$trayShell$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get closeTitle => '关闭窗口';
	@override String get closeBody => '关闭窗口只是把 Mclash 收进托盘 —— 内核与系统代理会继续工作，网照旧能上。\n\n· 点「确定」：最小化到托盘（想彻底退出时，右键托盘图标 → 退出）\n· 点「取消」：完全退出 Mclash，同时停止内核并还原系统代理\n\n（本次选择会被记住；下次可直接右键托盘图标操作）';
}

// Path: ordersScreen
class Translations$ordersScreen$zh_TW implements Translations$ordersScreen$en {
	Translations$ordersScreen$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get title => '我的訂單';
	@override String get orderInfoIncomplete => '訂單資訊不完整，請下拉重新整理後再試';
	@override String get payChannelIncomplete => '付款通道資訊不完整，請稍後再試';
	@override String get noQrPayload => '伺服器沒有回傳付款 QR Code／連結，請改用其他付款方式或稍後再試';
	@override String payStartFailed({required Object err}) => '發起付款失敗：${err}';
	@override String get noPayMethod => '目前沒有可用的付款方式，請稍後再試或聯絡客服';
	@override String get choosePayMethod => '選擇付款方式';
	@override String amountDue({required Object amount}) => '應付 ¥${amount}';
	@override String get paidLabel => '● 已付款';
	@override String get pendingLabel => '○ 待付款';
	@override String unknownStatus({required Object status}) => '✕ ${status}';
	@override String orderNoText({required Object orderNo}) => '訂單號 ${orderNo}';
	@override String createdAtText({required Object createdAt}) => '下單時間 ${createdAt}';
	@override String get orderCanceled => '訂單已取消';
	@override String cancelFailed({required Object err}) => '取消失敗：${err}\n（若訂單已付款／已取消，下拉重新整理即可看到最新狀態）';
	@override String get cancelOrder => '取消訂單';
	@override String get continuePay => '繼續付款';
}

// Path: payment
class Translations$payment$zh_TW implements Translations$payment$en {
	Translations$payment$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get balancePay => '餘額付款';
	@override String get qrPay => '掃碼付款';
	@override String get deductFromBalance => '從帳戶餘額扣款';
	@override String get openedInBrowser => '已在瀏覽器開啟付款頁面';
	@override String get scanWithAlipayWechat => '請使用支付寶／微信掃碼';
	@override String orderNoText({required Object orderNo}) => '訂單號 ${orderNo}';
	@override String payFailed({required Object err}) => '付款失敗：${err}';
	@override String get notDetected => '未偵測到付款。可稍後在「我的訂單」中繼續。';
	@override String get charging => '正在扣款…';
	@override String get processing => '處理中…';
	@override String get waitingPay => '等待付款…';
	@override String get openPageFailed => '沒能開啟付款頁面，請點下方按鈕重試，或改用掃碼付款';
	@override String get reopenPayPage => '重新開啟付款頁面';
	@override String get payInBrowser => '在瀏覽器付款';
	@override String get openAlipay => '開啟支付寶付款';
	@override String get cancelOrder => '取消訂單';
	@override String get confirmPay => '確認付款';
	@override String get retry => '重試';
	@override String get paidAlready => '我已付款';
	@override String get channelAlipay => '支付寶';
	@override String get channelCodepayAlipay => '碼支付 · 支付寶';
	@override String get channelCodepayWechat => '碼支付 · 微信';
	@override String get channelCodepay => '碼支付';
	@override String get channelWechat => '微信支付';
	@override String get channelUsdt => 'USDT';
	@override String get channelUsdtTrc20 => 'USDT · TRC20';
	@override String get payFallback => '付款';
	@override String get errCsrf => '登入憑證已過期（CSRF 驗證失敗）。\n請到「我的」下拉重新整理或重新登入後再試。';
	@override String get errAlipayLimit => '支付寶當面付單筆限額（本商戶 ¥1000），本單金額超出。\n請改用「餘額付款」或「碼支付」，或聯絡客服提高支付寶限額。';
	@override String get errNotSigned => '支付寶應用未簽約對應的付款產品，暫時無法使用這個通道。\n請改用「餘額付款」或「碼支付」，或聯絡客服開通。';
	@override String get errOrderGone => '這筆訂單已被取消或已過期（草稿訂單 30 分鐘有效期）。\n請點「重新算價」產生新訂單再付款。';
	@override String errNetwork({required Object err}) => '網路不通：${err}';
}

// Path: planScreen
class Translations$planScreen$zh_TW implements Translations$planScreen$en {
	Translations$planScreen$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get recommended => '推薦';
	@override String get devices => '裝置';
	@override String balanceLabel({required Object amount}) => '餘額 ¥${amount}';
	@override String get balanceInsufficient => '（不足，請先儲值）';
	@override String get total => '合計';
	@override String get payNow => '立即付款';
	@override String get retry => '重試';
	@override String get errIncompleteOrder => '訂單或支付通道資訊不完整，無法發起付款';
	@override String get payBalance => '餘額付款';
	@override String get payAlipay => '支付寶';
	@override String get payWechat => '微信支付';
	@override String get payCodepay => '碼支付';
	@override String get payCodepayAlipay => '碼支付 · 支付寶';
	@override String get payCodepayWechat => '碼支付 · 微信';
	@override String get payEpayAlipay => '易支付 · 支付寶';
	@override String get payEpayWechat => '易支付 · 微信';
	@override String get payUsdt => 'USDT';
	@override String get payUsdtTrc20 => 'USDT · TRC20';
	@override String get payStripe => 'Stripe';
	@override String get payPaypal => 'PayPal';
	@override String get payOnline => '線上付款';
}

// Path: authScreen
class Translations$authScreen$zh_TW implements Translations$authScreen$en {
	Translations$authScreen$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get saveAccountInfo => '保存賬號資訊';
	@override String get autoLoginNextTime => '下次開啟自動登錄';
	@override String get needLoginNextTime => '下次開啟需要重新登錄';
	@override String get invalidEmail => '請填寫有效郵箱';
	@override String get enterEmailFirst => '請先填寫有效郵箱';
	@override String get passwordRequired => '請填寫密碼';
	@override String get wrongCredentials => '郵箱或密碼錯誤';
	@override String get requestRejected => '請求被拒絕，請稍後重試';
	@override String get tooFrequent => '操作過於頻繁，請稍後再試';
	@override String get loginFailed => '登錄失敗';
	@override String get username => '用戶名';
	@override String get confirmPassword => '確認密碼';
	@override String get inviteCode => '邀請碼';
	@override String get emailCode => '郵箱驗證碼';
	@override String get getCode => '獲取驗證碼';
	@override String get registerAndLogin => '註冊並登錄';
	@override String usernameMinLength({required Object min}) => '用戶名至少 ${min} 位';
	@override String get passwordMismatch => '兩次輸入的密碼不一致';
	@override String get emailCodeRequired => '請填寫郵箱驗證碼';
	@override String get inviteCodeRequired => '本站註冊需要邀請碼';
	@override String get codeSentCheckEmail => '驗證碼已發送，請查收郵件';
	@override String get registerSuccess => '註冊成功，已自動登錄';
	@override String passwordHint({required Object min}) => '至少 ${min} 位，且同時包含字母和數字';
	@override String passwordTooShort({required Object min}) => '密碼長度不能少於 ${min} 位';
	@override String get passwordNeedsLetterAndDigit => '密碼必須包含字母和數字';
	@override String get registeredEmail => '註冊郵箱';
	@override String get newPassword => '新密碼';
	@override String get confirmNewPassword => '確認新密碼';
	@override String get resetPassword => '重置密碼';
	@override String get resetCodeSent => '如果該郵箱已註冊，重置驗證碼已發送（15 分鐘內有效）。';
	@override String get resetSuccess => '密碼已重置，請用新密碼登錄';
	@override String get changePasswordTitle => '修改密碼';
	@override String get currentPassword => '當前密碼';
	@override String get saveNewPassword => '保存新密碼';
	@override String get newPasswordMismatch => '兩次輸入的新密碼不一致';
	@override String get changePasswordSuccess => '密碼已修改，請重新登錄';
}

// Path: updatePrompt
class Translations$updatePrompt$zh_TW implements Translations$updatePrompt$en {
	Translations$updatePrompt$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get checking => '正在檢查更新…';
	@override String get checkFailed => '檢查更新失敗，請檢查網路後重試。';
	@override String alreadyLatest({required Object version}) => '已是最新版本（${version}）。';
	@override String newVersionFound({required Object version}) => '發現新版本 ${version}';
	@override String get installerDownloaded => '安裝包已在背景下載完成，點「立即更新」完成升級。';
	@override String get downloadInBackground => '點「立即更新」開始下載並安裝（也可繼續使用，安裝包會在背景下載）。';
	@override String get later => '稍後';
	@override String get updateNow => '立即更新';
	@override String installerNotReady({required Object version}) => '安裝包還沒下載完成。\n\n點「確定」開啟下載頁，手動下載適合你裝置的安裝包（版本 ${version}）。';
}

// Path: clearData
class Translations$clearData$zh_TW implements Translations$clearData$en {
	Translations$clearData$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get itemLoginSession => '登入工作階段';
	@override String get itemProfiles => '訂閱設定檔（profiles/）';
	@override String get itemSettings => '應用程式與核心設定';
	@override String get itemLatencyCache => '節點延遲快取';
	@override String get itemLogs => '執行日誌';
	@override String get itemRoutingData => '分流資料與暫存檔';
	@override String confirmBody({required Object items, required Object dir}) => '將刪除本機儲存的以下資料（不可復原）：\n\n${items}\n\n帳號本身、已購買的方案都在伺服器上，不受影響；重新登入即可恢復訂閱。\n\n資料目錄：${dir}\n（卸載 App 之前先點這裡，重裝後才會是乾淨的、需要重新登入的狀態）';
	@override String get confirmAgain => '確認清除？清除後需要重新登入。';
	@override String clearedNotice({required Object count, required Object dir}) => '已清除 ${count} 項本機資料（含登入工作階段，下次開啟需要重新登入）。\n\n現在可以刪除 App 完成卸載：\n· macOS：把 Mclash.app 拖進垃圾桶（資料目錄已清空：${dir}）\n· Windows：從控制台卸載 Mclash，卸載精靈詢問是否保留使用者資料時選「否」';
	@override String clearFailed({required Object error}) => '清除失敗：${error}';
}

// Path: apiError
class Translations$apiError$zh_TW implements Translations$apiError$en {
	Translations$apiError$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String requestFailedHttp({required Object status, required Object domain}) => '請求失敗（HTTP ${status}），已嘗試網域 ${domain}';
	@override String allDomainsFailed({required Object method, required Object path, required Object count}) => '請求失敗：${method} ${path}（已嘗試 ${count} 個網域）';
	@override String requestTimeout({required Object seconds, required Object method, required Object path}) => '請求逾時（${seconds}s）：${method} ${path}';
	@override String networkUnreachable({required Object detail}) => '網路不可達：${detail}';
	@override String get tlsHandshakeFailed => 'TLS 握手失敗，請檢查網路或系統時間';
	@override String connectionFailed({required Object detail}) => '連線失敗：${detail}';
	@override String requestError({required Object error}) => '請求失敗：${error}';
	@override String responseReadTimeout({required Object seconds, required Object method, required Object path}) => '讀取回應逾時（${seconds}s）：${method} ${path}';
	@override String notJson({required Object status, required Object snippet}) => '回應不是 JSON（HTTP ${status}）：${snippet}';
	@override String badStructure({required Object status}) => '回應結構異常（HTTP ${status}）';
	@override String loginFailed({required Object code}) => '登入失敗（code ${code}）';
	@override String get loginMissingData => '登入回應缺少 data';
	@override String get loginMissingToken => '登入回應缺少 access_token';
	@override String registerFailed({required Object code}) => '註冊失敗（code ${code}）';
	@override String get registerMissingToken => '註冊回應未包含 access_token，可能觸發了風控或站點設定不同';
	@override String requestFailedCode({required Object code}) => '請求失敗（code ${code}）';
}

// Path: subNotice
class Translations$subNotice$zh_TW implements Translations$subNotice$en {
	Translations$subNotice$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get titleNotFound => '訂閱不存在';
	@override String get titleExpired => '訂閱已過期';
	@override String get titleInactive => '訂閱已失效';
	@override String get titleDeviceOverLimit => '裝置數量超限';
	@override String get titleUnavailable => '訂閱不可用';
	@override String titleWithReason({required Object emoji, required Object title, required Object reason}) => '${emoji} ${title}（${reason}）';
	@override String deviceUsedOfLimit({required Object used, required Object limit}) => '目前裝置 ${used}/${limit}';
	@override String deviceUsedOnly({required Object used}) => '目前裝置 ${used}';
	@override String expireAt({required Object expire}) => '到期時間 ${expire}';
	@override String supportLine({required Object account}) => '💬 客服: ${account}';
	@override String siteLine({required Object url}) => '📢 官網: ${url}';
}

// Path: settingItems
class Translations$settingItems$zh_TW implements Translations$settingItems$en {
	Translations$settingItems$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get subscriptionAutoUpdateInterval => '訂閱自動更新間隔';
	@override String get speedTestMode => '測速方式';
	@override String get speedTestModeTcp => 'TCP 測速';
	@override String get speedTestModeKernel => '內核測速';
	@override String get delayTestUrlTip => '經該節點完整走一次 HTTP 請求的耗時（非 ping）\n預設用明文 http 的 204 空回應；換成 https 會多一次 TLS 握手，數字更大';
	@override String get systemProxy => '系統代理';
	@override String get systemProxyTip => '檢視/重設位址與連接埠';
	@override String get tunMode => 'TUN 模式';
	@override String get tunModeTip => 'off=僅系統代理 / auto=TUN+系統代理 / force=僅 TUN\n桌面端 TUN 需要管理員權限（Windows 建 wintun / macOS 建 utun）';
	@override String get tunOverwriteTip => 'overwrite\n開 = 用這裡的 TUN 設定覆蓋訂閱裡的 tun 段\n關 = 讓訂閱自己的 tun 設定生效（App 不插手）';
	@override String tunEnableByTunMode({required Object enable}) => '${enable}（由 TUN 模式決定）';
	@override String get interval30Minutes => '30 分鐘';
	@override String get interval1Hour => '1 小時';
	@override String get interval6Hours => '6 小時';
	@override String get interval12Hours => '12 小時';
	@override String get interval24Hours => '24 小時';
	@override String get interval3Days => '3 天';
	@override String get interval7Days => '7 天';
	@override String get intervalNever => '從不';
	@override String intervalMinutes({required Object minutes}) => '${minutes} 分鐘';
	@override String intervalHours({required Object hours}) => '${hours} 小時';
	@override String intervalDays({required Object days}) => '${days} 天';
}

// Path: tunScreen
class Translations$tunScreen$zh_TW implements Translations$tunScreen$en {
	Translations$tunScreen$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get modeOff => '關閉';
	@override String get modeAuto => '自動';
	@override String get modeForce => '強制';
	@override String get modeOffDesc => '僅系統代理：瀏覽器等遵守系統代理的程式生效，UDP/遊戲不走代理';
	@override String get modeAutoDesc => 'TUN + 系統代理（雙保險）：全部流量走虛擬網卡，含 UDP';
	@override String get modeForceDesc => '僅 TUN：全部流量走虛擬網卡，不再改系統代理';
	@override String get modeOffOptionDesc => '不改系統路由表，只在系統裡設定 127.0.0.1 的代理。只有遵守系統代理的程式走代理；UDP 流量與自帶代理設定的程式不走。';
	@override String get modeAutoOptionDesc => '建立虛擬網卡接管全部流量（含 UDP、遊戲）；同時保留系統代理作為兜底。推薦：既能全域生效，又不會因為權限問題徹底沒網。';
	@override String get modeForceOptionDesc => '只用虛擬網卡，不再改系統代理。全部流量（含 UDP）都進隧道，系統裡「代理」一項保持原樣。';
	@override String get adminRequiredDialog => 'TUN 虛擬網卡需要管理員權限（Windows 建 wintun / macOS 建 utun）。\n\n目前 Mclash 不是以管理員身分執行的，開啟後 TUN 不會生效（「自動」模式下系統代理仍會兜底，網路可用）。\n\n點「確定」= 現在以管理員身分重新啟動 Mclash（會彈 UAC）\n點「取消」= 仍要儲存這個選擇（TUN 不生效時會自動用系統代理）';
	@override String relaunchFailed({required Object message}) => '重新啟動失敗：${message}';
	@override String switchFailed({required Object message}) => '切換 TUN 模式失敗：${message}\n已還原原來的設定。';
	@override String get setOffSnack => '已設為「關閉」：只使用系統代理';
	@override String setModeSnack({required Object mode, required Object effect}) => '已設為「${mode}」，${effect}';
	@override String get effectReconnected => '已重連生效';
	@override String get effectAfterConnect => '連線後生效';
	@override String get sheetTitle => 'TUN 虛擬網卡';
	@override String get advancedTitle => '進階參數（核心設定 → TUN）';
	@override String get advancedSubtitle => '虛擬網卡位址 / 堆疊 / MTU / 自動路由 / DNS 劫持 / 覆寫';
	@override String get adminOk => 'TUN 需要管理員權限；目前權限滿足（Windows 以管理員執行 / macOS 以 root 執行）';
	@override String get adminMissing => 'TUN 需要管理員權限：目前未以管理員身分執行，選中「自動/強制」後 TUN 不會生效（「自動」會用系統代理兜底，網路仍可用）';
}

// Path: main.tray
class Translations$main$tray$zh_TW implements Translations$main$tray$en {
	Translations$main$tray$zh_TW.internal(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get menuOpen => '打開';
	@override String get menuExit => '退出';
}

/// The flat map containing all translations for locale <zh-TW>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on TranslationsZhTw {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'BackupAndSyncWebdavScreen.webdavServerUrl' => '伺服器地址',
			'BackupAndSyncWebdavScreen.webdavRequired' => '不能為空',
			'BackupAndSyncWebdavScreen.webdavLoginFailed' => '登錄失敗:',
			'BackupAndSyncWebdavScreen.webdavListFailed' => '獲取文件列表失敗:',
			'LaunchFailedScreen.invalidProcess' => '應用啟動失敗[無效的進程名稱],請重新安裝應用到獨立目錄',
			'LaunchFailedScreen.invalidProfile' => '應用啟動失敗[訪問設定檔失敗],請重新安裝應用',
			'LaunchFailedScreen.invalidVersion' => '應用啟動失敗[無效版本],請重新安裝應用',
			'LaunchFailedScreen.systemVersionLow' => '應用啟動失敗[系統版本過低]',
			'LaunchFailedScreen.invalidInstallPath' => '無效的安裝路徑,請重新安裝到有效路徑',
			'PerAppAndroidScreen.title' => '分應用代理',
			'PerAppAndroidScreen.whiteListMode' => '白名單模式',
			'PerAppAndroidScreen.whiteListModeTip' => '啟用後:僅代理已勾選的App;未啟用:僅代理未勾選的App',
			'UserAgreementScreen.privacyFirst' => '您的隱私很重要',
			'UserAgreementScreen.agreeAndContinue' => '接受並繼續',
			'NetCheckScreen.enterDomain' => '請輸入網域名稱',
			'NetCheckScreen.checking' => '檢測中...',
			'NetCheckScreen.aQueryFailed' => ({required Object p}) => 'A 查詢失敗: ${p}',
			'NetCheckScreen.aaaaQueryFailed' => ({required Object p}) => 'AAAA 查詢失敗: ${p}',
			'NetCheckScreen.success' => '成功',
			'NetCheckScreen.failed' => '失敗',
			'NetCheckScreen.suspectedPollution' => '疑似被污染',
			'NetCheckScreen.domainLabel' => '網域名稱',
			'NetCheckScreen.checkButton' => '檢測',
			'NetCheckScreen.dnsSection' => '1. DNS查詢',
			'NetCheckScreen.directHttpSection' => '2. HTTP (經由TUN,請先啟用TUN)',
			'NetCheckScreen.proxyHttpSection' => ({required Object p}) => '3. HTTP (經由代理,連接埠:${p})',
			'NetCheckScreen.tunNotEnabled' => 'TUN 未啟用',
			'NetCheckScreen.routeTableSection' => '4. 路由表',
			'VersionUpdateScreen.versionReady' => ({required Object p}) => '新版本[${p}]已就緒',
			'VersionUpdateScreen.update' => '重啟更新',
			'VersionUpdateScreen.cancel' => '暫不更新',
			'loginScreen.login' => '登錄',
			'loginScreen.register' => '註冊賬號',
			'loginScreen.forgotPassword' => '忘記密碼',
			'loginScreen.provider' => '服務商',
			'loginScreen.providerName' => '${_root.loginScreen.provider}編碼/別名/URL',
			'loginScreen.account' => '賬號',
			'loginScreen.email' => '郵箱',
			'loginScreen.password' => '密碼',
			'main.tray.menuOpen' => '打開',
			'main.tray.menuExit' => '退出',
			'meta.enable' => '啟用',
			'meta.disable' => '禁用',
			'meta.open' => '打開',
			'meta.close' => '關閉',
			'meta.quit' => '退出',
			'meta.add' => '添加',
			'meta.remove' => '刪除',
			'meta.removeConfirm' => '確認刪除?',
			'meta.edit' => '編輯',
			'meta.view' => '查看',
			'meta.remark' => '備註',
			'meta.byDefault' => '預設',
			'meta.more' => '更多',
			'meta.tips' => '提示',
			'meta.selectAll' => '全選',
			'meta.copy' => '複製',
			'meta.paste' => '貼上',
			'meta.cut' => '剪切',
			'meta.save' => '儲存',
			'meta.ok' => '確定',
			'meta.cancel' => '取消',
			'meta.faq' => '常見問題',
			'meta.doc' => '文檔',
			'meta.htmlTools' => 'HTML工具集',
			'meta.download' => '下載',
			'meta.loading' => '載入中...',
			'meta.days' => '天',
			'meta.hours' => '時',
			'meta.minutes' => '分',
			'meta.seconds' => '秒',
			'meta.milliseconds' => '毫秒',
			'meta.search' => '搜索',
			'meta.searchNodeHint' => '篩選節點（名稱或協定）',
			'meta.connect' => '連接',
			'meta.disconnect' => '斷開',
			'meta.connected' => '已連接',
			'meta.disconnected' => '未連接',
			'meta.connecting' => '連接中',
			'meta.connectTimeout' => '連接超時',
			'meta.timeout' => '超時',
			'meta.latencyTest' => '延遲檢測',
			'meta.networkCheck' => '網路檢測',
			'meta.language' => '語言',
			'meta.next' => '下一步',
			'meta.done' => '完成',
			'meta.apply' => '應用',
			'meta.refresh' => '刷新',
			'meta.update' => '更新',
			'meta.updateInterval' => '更新時間間隔',
			'meta.updateInterval5mTips' => '最小:5m',
			'meta.updateIntervalPreferByProfile' => '優先使用服務商(機場)設定',
			'meta.updateFailed' => ({required Object p}) => '更新失敗:${p}',
			'meta.none' => '無',
			'meta.reset' => '重置',
			'meta.authentication' => '授權',
			'meta.user' => '用戶',
			'meta.account' => '賬號',
			'meta.password' => '密碼',
			'meta.decryptPassword' => '解密密碼',
			'meta.required' => '必填',
			'meta.go' => '繼續',
			'meta.other' => '其他',
			'meta.dns' => 'DNS',
			'meta.url' => 'URL',
			'meta.urlInvalid' => 'URL無效',
			'meta.copyUrl' => '複製連結',
			'meta.openUrl' => '打開連結',
			'meta.coreSettingTips' => '注意:修改配置後,需要重新連接才會生效',
			'meta.overwrite' => '覆寫',
			'meta.overwriteAppend' => '追加覆寫',
			'meta.overwriteTips' => '原始配置<-自定義覆寫<-App覆寫',
			'meta.noOverwrite' => '不覆寫',
			'meta.diversionTemplates' => '分流模板',
			'meta.ruleProviders' => '規則提供者',
			'meta.ruleTemplates' => '規則模板',
			'meta.proxyGroupsTemplates' => '代理組模板',
			'meta.proxyGroups' => '代理組',
			'meta.proxyNodeList' => '代理節點列表',
			'meta.proxyNodeFailure' => ({required Object p}) => '下列代理節點已失效,已自動移除:${p}',
			'meta.externalController' => '外部控制',
			'meta.secret' => '金鑰',
			'meta.tcpConcurrent' => 'TCP併發握手',
			'meta.globalClientFingerprint' => 'TLS全局指紋',
			'meta.allowLanAccess' => '局域網設備接入',
			'meta.mixedPort' => '混合代理端口',
			'meta.logLevel' => '日誌等級',
			'meta.findProcessMode' => '進程匹配模式',
			'meta.tcpkeepAliveInterval' => 'TCP保活時間間隔',
			'meta.delayTestUrl' => '延遲測試URL',
			'meta.delayTestTimeout' => '延遲測試超時(ms)',
			'meta.tun' => 'TUN',
			'meta.ntp' => 'NTP',
			'meta.tls' => 'TLS',
			'meta.geoDownloadByProxy' => '使用代理下載Geo RuleSet',
			'meta.geoRulesetTips' => 'Geosite/Geoip 會被轉換成 對應的RuleSet',
			'meta.sniffer' => '嗅探',
			'meta.userAgent' => 'UserAgent',
			'meta.launchAtStartup' => '開機啟動',
			'meta.launchAtStartupRunAsAdmin' => '請以管理員身份重新啟動Mclash',
			'meta.tunModeRunAsAdmin' => 'TUN模式需要系統管理員權限,請以管理員身份重新啟動應用',
			'meta.portableMode' => '便攜模式',
			'meta.portableModeDisableTips' => '如需退出便攜模式,請退出[mclash]後,手動刪除[mclash.exe]同目錄下的[portable]文件夾即可',
			'meta.autoConnectAfterLaunch' => '啟動後自動連接',
			'meta.autoConnectAtBoot' => '系統啟動後自動連接',
			'meta.autoConnectAtBootTips' => '需要系統支持,部分系統可能還需要開啟[自啟動]',
			'meta.hideAfterLaunch' => '啟動後隱藏窗口',
			'meta.autoSetSystemProxy' => '連接後自動設置系統代理',
			'meta.bypassSystemProxy' => '允許繞過系統代理的域名',
			'meta.excludeFromRecent' => '從[最近任務]中隱藏',
			'meta.wakeLock' => '喚醒鎖',
			'meta.hideDockIcon' => '隱藏Dock圖標',
			'meta.showTrayTraffic' => '托盤上顯示流量資訊',
			'meta.website' => '官網',
			'meta.rule' => '規則',
			'meta.global' => '全局',
			'meta.direct' => '直連',
			'meta.qrcode' => '二維碼',
			'meta.qrcodeTooLong' => '文本過長,無法展示',
			'meta.qrcodeShare' => '分享二維碼',
			'meta.qrcodeScan' => '掃描二維碼',
			'meta.qrcodeScanResult' => '掃描結果',
			'meta.backupAndSync' => '備份與同步',
			'meta.export' => '匯出',
			'meta.send' => '發送',
			'meta.sendConfirm' => '確認發送?',
			'meta.log' => '日誌',
			'meta.coreLog' => '核心日誌',
			'meta.appLog' => '應用日誌',
			'meta.core' => '核心',
			'meta.help' => '幫助',
			'meta.tutorial' => '使用教程',
			'meta.board' => '面板',
			'meta.boardOnline' => '使用在線面板',
			'meta.boardOnlineUrl' => '在線面板URL',
			'meta.boardLocalPort' => '本地面板端口',
			'meta.alwayOnVPN' => '始終開啟連線',
			'meta.disableFontScaler' => '禁用字體縮放',
			'meta.autoOrientation' => '跟隨螢幕旋轉',
			'meta.restartTakesEffect' => '重啟生效',
			'meta.reconnectTakesEffect' => '重新連接後生效',
			'meta.runtimeProfile' => '運行時配置',
			'meta.willCompleteAfterRebootInstall' => '請重啟設備,以便完成系統擴展安裝',
			'meta.requestNeedsUserApproval' => '1. 請在[系統設置]-[隱私與安全性]裏[允許] Mclash安裝系統擴展\n2. :[系統設置]-[通用]-[登錄項與擴展-網絡擴展]啟用[mclashServiceSE]\n完成後重新連接',
			'meta.FullDiskAccessPermissionRequired' => '請在[系統設置]-[隱私與安全性]-[完全磁盤訪問權限]裏開啟mclashServiceSE權限後,重新連接',
			'meta.proxy' => '代理',
			'meta.theme' => '主題',
			'meta.tvMode' => 'TV模式',
			'meta.autoUpdate' => '自動更新',
			'meta.updateChannel' => '自動更新通道',
			'meta.hasNewVersion' => ({required Object p}) => '更新版本 ${p}',
			'meta.autoDownloadPkg' => '自動下載更新包',
			'meta.devOptions' => '開發者選項',
			'meta.about' => '關於',
			'meta.name' => '名稱',
			'meta.version' => '版本',
			'meta.sort' => '排序',
			'meta.share' => '分享',
			'meta.importFromClipboard' => '從剪貼簿導入',
			'meta.exportToClipboard' => '匯出到剪貼簿',
			'meta.server' => '伺服器',
			'meta.port' => '端口',
			'meta.donate' => '捐助',
			'meta.setting' => '設定',
			'meta.settingCore' => '核心設定',
			'meta.settingApp' => '應用設定',
			'meta.coreOverwrite' => '核心覆寫',
			'meta.iCloud' => 'iCloud',
			'meta.webdav' => 'Webdav',
			'meta.lanSync' => '局域網同步',
			'meta.lanSyncNotQuitTips' => '同步完成前請勿退出此界面',
			'meta.deviceNoSpace' => '磁盤空間不足',
			'meta.hideSystemApp' => '隱藏系統應用',
			'meta.hideAppIcon' => '隱藏應用圖標',
			'meta.openDir' => '打開文件目錄',
			'meta.type' => '類型',
			'meta.fileNotExist' => ({required Object p}) => '文件不存在:${p}',
			'meta.buyProfile' => '購買設定',
			'meta.myProfiles' => '我的設定',
			'meta.profileEdit' => '編輯設定',
			'meta.profileNeedActive' => '請先將本設定設為目前設定，並開啟連線/重新連線',
			'meta.profileUrlOrContent' => ({required Object p}) => '${p}設定連結',
			'meta.tabHome' => '首頁',
			'meta.tabNodes' => '節點列表',
			'meta.tabPlans' => '套餐購買',
			'meta.tabMe' => '我的',
			'permission.camera' => '攝像頭',
			'permission.screen' => '屏幕錄製',
			'permission.appQuery' => '獲取應用列表',
			'permission.request' => ({required Object p}) => '開啟[${p}]權限',
			'permission.requestNeed' => ({required Object p}) => '請開啟[${p}]權限',
			'tls.certificate' => '證書',
			'tls.privateKey' => '私鑰',
			'tls.customTrustCert' => '自定義證書',
			'tun.stack' => '網絡棧',
			'tun.inet4Address' => 'IPv4位址段',
			'tun.dnsHijack' => 'DNS劫持',
			'tun.strictRoute' => '嚴格路由',
			'tun.tunDefaultRoute' => '預設路由',
			'tun.icmpForward' => 'ICMP 轉發',
			'tun.allowBypass' => '允許應用繞過VPN',
			'tun.appendHttpProxy' => '附加HTTP代理到VPN',
			'tun.bypassHttpProxyDomain' => '允許繞過HTTP代理的域名',
			'dns.listen' => '監聽地址',
			'dns.fakeIp' => 'fake-ip',
			'dns.fallback' => 'Fallback',
			'dns.preferH3' => 'DoH H3優先',
			'dns.useHosts' => '使用Hosts',
			'dns.useSystemHosts' => '使用系統Hosts',
			'dns.enhancedMode' => '增強模式',
			'dns.fakeIPFilterMode' => '${_root.dns.fakeIp} 過濾模式',
			'dns.fakeIPFilter' => '${_root.dns.fakeIp} 過濾',
			'dns.respectRules' => '遵守[rules]規則',
			'dns.nameServer' => '域名解析伺服器',
			'dns.defaultNameServer' => '${_root.meta.byDefault} ${_root.dns.nameServer}',
			'dns.proxyNameServer' => '${_root.meta.proxy} ${_root.dns.nameServer}',
			'dns.directNameServer' => '${_root.meta.direct} ${_root.dns.nameServer}',
			'dns.fallbackNameServer' => '${_root.dns.fallback} ${_root.dns.nameServer}',
			'dns.fallbackGeoIp' => '${_root.dns.fallback} GeoIp',
			'dns.fallbackGeoIpCode' => '${_root.dns.fallback} GeoIp 代碼',
			'sniffer.overrideDest' => '覆蓋',
			'profilePatchMode.currentSelected' => '當前選擇',
			'profilePatchMode.overwrite' => '內置-覆寫',
			'profilePatchMode.noOverwrite' => '內置-不覆寫',
			'sendOrReceiveNotMatch' => ({required Object p}) => '請使用 [${p}]',
			'targetConnectFailed' => ({required Object p}) => '連線 [${p}] 失敗, 請確保設備在同一個區域網路內',
			'edgeRuntimeNotInstalled' => '當前設備尚未安裝Edge WebView2運行時,無法展示頁面,請下載安裝Edge WebView2運行時(x64)後,重啟App再試',
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
			'countries.TW' => '台灣',
			'countries.MO' => '澳門',
			'countries.CN' => '中國',
			'countries.JP' => '日本',
			'countries.KR' => '韓國',
			'countries.SG' => '新加坡',
			'countries.MY' => '馬來西亞',
			'countries.TH' => '泰國',
			'countries.VN' => '越南',
			'countries.PH' => '菲律賓',
			'countries.ID' => '印尼',
			'countries.KH' => '柬埔寨',
			'countries.US' => '美國',
			'countries.CA' => '加拿大',
			'countries.MX' => '墨西哥',
			'countries.GB' => '英國',
			'countries.DE' => '德國',
			'countries.FR' => '法國',
			'countries.NL' => '荷蘭',
			'countries.RU' => '俄羅斯',
			'countries.IT' => '義大利',
			'countries.ES' => '西班牙',
			'countries.CH' => '瑞士',
			'countries.SE' => '瑞典',
			'countries.NO' => '挪威',
			'countries.FI' => '芬蘭',
			'countries.DK' => '丹麥',
			'countries.PL' => '波蘭',
			'countries.AT' => '奧地利',
			'countries.IE' => '愛爾蘭',
			'countries.UA' => '烏克蘭',
			'countries.TR' => '土耳其',
			'countries.PT' => '葡萄牙',
			'countries.CZ' => '捷克',
			'countries.RO' => '羅馬尼亞',
			'countries.BE' => '比利時',
			'countries.GR' => '希臘',
			'countries.HU' => '匈牙利',
			'countries.IL' => '以色列',
			'countries.AE' => '阿聯酋',
			'countries.SA' => '沙烏地',
			'countries.EG' => '埃及',
			'countries.ZA' => '南非',
			'countries.NG' => '奈及利亞',
			'countries.AU' => '澳洲',
			'countries.NZ' => '紐西蘭',
			'countries.BR' => '巴西',
			'countries.AR' => '阿根廷',
			'countries.CL' => '智利',
			'countries.CO' => '哥倫比亞',
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
			'logScreen.readCoreFailed' => ({required Object e}) => '读取核心日志失败：${e}',
			'logScreen.copied' => '已复制（订阅地址等敏感信息已自动打码，日志文件本身仍可能包含原始地址）',
			'logScreen.copy' => '复制',
			_ => null,
		} ?? switch (path) {
			'logScreen.refresh' => '刷新',
			'logScreen.empty' => '暂无内容',
			'trayShell.closeTitle' => '关闭窗口',
			'trayShell.closeBody' => '关闭窗口只是把 Mclash 收进托盘 —— 内核与系统代理会继续工作，网照旧能上。\n\n· 点「确定」：最小化到托盘（想彻底退出时，右键托盘图标 → 退出）\n· 点「取消」：完全退出 Mclash，同时停止内核并还原系统代理\n\n（本次选择会被记住；下次可直接右键托盘图标操作）',
			'ordersScreen.title' => '我的訂單',
			'ordersScreen.orderInfoIncomplete' => '訂單資訊不完整，請下拉重新整理後再試',
			'ordersScreen.payChannelIncomplete' => '付款通道資訊不完整，請稍後再試',
			'ordersScreen.noQrPayload' => '伺服器沒有回傳付款 QR Code／連結，請改用其他付款方式或稍後再試',
			'ordersScreen.payStartFailed' => ({required Object err}) => '發起付款失敗：${err}',
			'ordersScreen.noPayMethod' => '目前沒有可用的付款方式，請稍後再試或聯絡客服',
			'ordersScreen.choosePayMethod' => '選擇付款方式',
			'ordersScreen.amountDue' => ({required Object amount}) => '應付 ¥${amount}',
			'ordersScreen.paidLabel' => '● 已付款',
			'ordersScreen.pendingLabel' => '○ 待付款',
			'ordersScreen.unknownStatus' => ({required Object status}) => '✕ ${status}',
			'ordersScreen.orderNoText' => ({required Object orderNo}) => '訂單號 ${orderNo}',
			'ordersScreen.createdAtText' => ({required Object createdAt}) => '下單時間 ${createdAt}',
			'ordersScreen.orderCanceled' => '訂單已取消',
			'ordersScreen.cancelFailed' => ({required Object err}) => '取消失敗：${err}\n（若訂單已付款／已取消，下拉重新整理即可看到最新狀態）',
			'ordersScreen.cancelOrder' => '取消訂單',
			'ordersScreen.continuePay' => '繼續付款',
			'payment.balancePay' => '餘額付款',
			'payment.qrPay' => '掃碼付款',
			'payment.deductFromBalance' => '從帳戶餘額扣款',
			'payment.openedInBrowser' => '已在瀏覽器開啟付款頁面',
			'payment.scanWithAlipayWechat' => '請使用支付寶／微信掃碼',
			'payment.orderNoText' => ({required Object orderNo}) => '訂單號 ${orderNo}',
			'payment.payFailed' => ({required Object err}) => '付款失敗：${err}',
			'payment.notDetected' => '未偵測到付款。可稍後在「我的訂單」中繼續。',
			'payment.charging' => '正在扣款…',
			'payment.processing' => '處理中…',
			'payment.waitingPay' => '等待付款…',
			'payment.openPageFailed' => '沒能開啟付款頁面，請點下方按鈕重試，或改用掃碼付款',
			'payment.reopenPayPage' => '重新開啟付款頁面',
			'payment.payInBrowser' => '在瀏覽器付款',
			'payment.openAlipay' => '開啟支付寶付款',
			'payment.cancelOrder' => '取消訂單',
			'payment.confirmPay' => '確認付款',
			'payment.retry' => '重試',
			'payment.paidAlready' => '我已付款',
			'payment.channelAlipay' => '支付寶',
			'payment.channelCodepayAlipay' => '碼支付 · 支付寶',
			'payment.channelCodepayWechat' => '碼支付 · 微信',
			'payment.channelCodepay' => '碼支付',
			'payment.channelWechat' => '微信支付',
			'payment.channelUsdt' => 'USDT',
			'payment.channelUsdtTrc20' => 'USDT · TRC20',
			'payment.payFallback' => '付款',
			'payment.errCsrf' => '登入憑證已過期（CSRF 驗證失敗）。\n請到「我的」下拉重新整理或重新登入後再試。',
			'payment.errAlipayLimit' => '支付寶當面付單筆限額（本商戶 ¥1000），本單金額超出。\n請改用「餘額付款」或「碼支付」，或聯絡客服提高支付寶限額。',
			'payment.errNotSigned' => '支付寶應用未簽約對應的付款產品，暫時無法使用這個通道。\n請改用「餘額付款」或「碼支付」，或聯絡客服開通。',
			'payment.errOrderGone' => '這筆訂單已被取消或已過期（草稿訂單 30 分鐘有效期）。\n請點「重新算價」產生新訂單再付款。',
			'payment.errNetwork' => ({required Object err}) => '網路不通：${err}',
			'planScreen.recommended' => '推薦',
			'planScreen.devices' => '裝置',
			'planScreen.balanceLabel' => ({required Object amount}) => '餘額 ¥${amount}',
			'planScreen.balanceInsufficient' => '（不足，請先儲值）',
			'planScreen.total' => '合計',
			'planScreen.payNow' => '立即付款',
			'planScreen.retry' => '重試',
			'planScreen.errIncompleteOrder' => '訂單或支付通道資訊不完整，無法發起付款',
			'planScreen.payBalance' => '餘額付款',
			'planScreen.payAlipay' => '支付寶',
			'planScreen.payWechat' => '微信支付',
			'planScreen.payCodepay' => '碼支付',
			'planScreen.payCodepayAlipay' => '碼支付 · 支付寶',
			'planScreen.payCodepayWechat' => '碼支付 · 微信',
			'planScreen.payEpayAlipay' => '易支付 · 支付寶',
			'planScreen.payEpayWechat' => '易支付 · 微信',
			'planScreen.payUsdt' => 'USDT',
			'planScreen.payUsdtTrc20' => 'USDT · TRC20',
			'planScreen.payStripe' => 'Stripe',
			'planScreen.payPaypal' => 'PayPal',
			'planScreen.payOnline' => '線上付款',
			'authScreen.saveAccountInfo' => '保存賬號資訊',
			'authScreen.autoLoginNextTime' => '下次開啟自動登錄',
			'authScreen.needLoginNextTime' => '下次開啟需要重新登錄',
			'authScreen.invalidEmail' => '請填寫有效郵箱',
			'authScreen.enterEmailFirst' => '請先填寫有效郵箱',
			'authScreen.passwordRequired' => '請填寫密碼',
			'authScreen.wrongCredentials' => '郵箱或密碼錯誤',
			'authScreen.requestRejected' => '請求被拒絕，請稍後重試',
			'authScreen.tooFrequent' => '操作過於頻繁，請稍後再試',
			'authScreen.loginFailed' => '登錄失敗',
			'authScreen.username' => '用戶名',
			'authScreen.confirmPassword' => '確認密碼',
			'authScreen.inviteCode' => '邀請碼',
			'authScreen.emailCode' => '郵箱驗證碼',
			'authScreen.getCode' => '獲取驗證碼',
			'authScreen.registerAndLogin' => '註冊並登錄',
			'authScreen.usernameMinLength' => ({required Object min}) => '用戶名至少 ${min} 位',
			'authScreen.passwordMismatch' => '兩次輸入的密碼不一致',
			'authScreen.emailCodeRequired' => '請填寫郵箱驗證碼',
			'authScreen.inviteCodeRequired' => '本站註冊需要邀請碼',
			'authScreen.codeSentCheckEmail' => '驗證碼已發送，請查收郵件',
			'authScreen.registerSuccess' => '註冊成功，已自動登錄',
			'authScreen.passwordHint' => ({required Object min}) => '至少 ${min} 位，且同時包含字母和數字',
			'authScreen.passwordTooShort' => ({required Object min}) => '密碼長度不能少於 ${min} 位',
			'authScreen.passwordNeedsLetterAndDigit' => '密碼必須包含字母和數字',
			'authScreen.registeredEmail' => '註冊郵箱',
			'authScreen.newPassword' => '新密碼',
			'authScreen.confirmNewPassword' => '確認新密碼',
			'authScreen.resetPassword' => '重置密碼',
			'authScreen.resetCodeSent' => '如果該郵箱已註冊，重置驗證碼已發送（15 分鐘內有效）。',
			'authScreen.resetSuccess' => '密碼已重置，請用新密碼登錄',
			'authScreen.changePasswordTitle' => '修改密碼',
			'authScreen.currentPassword' => '當前密碼',
			'authScreen.saveNewPassword' => '保存新密碼',
			'authScreen.newPasswordMismatch' => '兩次輸入的新密碼不一致',
			'authScreen.changePasswordSuccess' => '密碼已修改，請重新登錄',
			'updatePrompt.checking' => '正在檢查更新…',
			'updatePrompt.checkFailed' => '檢查更新失敗，請檢查網路後重試。',
			'updatePrompt.alreadyLatest' => ({required Object version}) => '已是最新版本（${version}）。',
			'updatePrompt.newVersionFound' => ({required Object version}) => '發現新版本 ${version}',
			'updatePrompt.installerDownloaded' => '安裝包已在背景下載完成，點「立即更新」完成升級。',
			'updatePrompt.downloadInBackground' => '點「立即更新」開始下載並安裝（也可繼續使用，安裝包會在背景下載）。',
			'updatePrompt.later' => '稍後',
			'updatePrompt.updateNow' => '立即更新',
			'updatePrompt.installerNotReady' => ({required Object version}) => '安裝包還沒下載完成。\n\n點「確定」開啟下載頁，手動下載適合你裝置的安裝包（版本 ${version}）。',
			'clearData.itemLoginSession' => '登入工作階段',
			'clearData.itemProfiles' => '訂閱設定檔（profiles/）',
			'clearData.itemSettings' => '應用程式與核心設定',
			'clearData.itemLatencyCache' => '節點延遲快取',
			'clearData.itemLogs' => '執行日誌',
			'clearData.itemRoutingData' => '分流資料與暫存檔',
			'clearData.confirmBody' => ({required Object items, required Object dir}) => '將刪除本機儲存的以下資料（不可復原）：\n\n${items}\n\n帳號本身、已購買的方案都在伺服器上，不受影響；重新登入即可恢復訂閱。\n\n資料目錄：${dir}\n（卸載 App 之前先點這裡，重裝後才會是乾淨的、需要重新登入的狀態）',
			'clearData.confirmAgain' => '確認清除？清除後需要重新登入。',
			'clearData.clearedNotice' => ({required Object count, required Object dir}) => '已清除 ${count} 項本機資料（含登入工作階段，下次開啟需要重新登入）。\n\n現在可以刪除 App 完成卸載：\n· macOS：把 Mclash.app 拖進垃圾桶（資料目錄已清空：${dir}）\n· Windows：從控制台卸載 Mclash，卸載精靈詢問是否保留使用者資料時選「否」',
			'clearData.clearFailed' => ({required Object error}) => '清除失敗：${error}',
			'apiError.requestFailedHttp' => ({required Object status, required Object domain}) => '請求失敗（HTTP ${status}），已嘗試網域 ${domain}',
			'apiError.allDomainsFailed' => ({required Object method, required Object path, required Object count}) => '請求失敗：${method} ${path}（已嘗試 ${count} 個網域）',
			'apiError.requestTimeout' => ({required Object seconds, required Object method, required Object path}) => '請求逾時（${seconds}s）：${method} ${path}',
			'apiError.networkUnreachable' => ({required Object detail}) => '網路不可達：${detail}',
			'apiError.tlsHandshakeFailed' => 'TLS 握手失敗，請檢查網路或系統時間',
			'apiError.connectionFailed' => ({required Object detail}) => '連線失敗：${detail}',
			'apiError.requestError' => ({required Object error}) => '請求失敗：${error}',
			'apiError.responseReadTimeout' => ({required Object seconds, required Object method, required Object path}) => '讀取回應逾時（${seconds}s）：${method} ${path}',
			'apiError.notJson' => ({required Object status, required Object snippet}) => '回應不是 JSON（HTTP ${status}）：${snippet}',
			'apiError.badStructure' => ({required Object status}) => '回應結構異常（HTTP ${status}）',
			'apiError.loginFailed' => ({required Object code}) => '登入失敗（code ${code}）',
			'apiError.loginMissingData' => '登入回應缺少 data',
			'apiError.loginMissingToken' => '登入回應缺少 access_token',
			'apiError.registerFailed' => ({required Object code}) => '註冊失敗（code ${code}）',
			'apiError.registerMissingToken' => '註冊回應未包含 access_token，可能觸發了風控或站點設定不同',
			'apiError.requestFailedCode' => ({required Object code}) => '請求失敗（code ${code}）',
			'subNotice.titleNotFound' => '訂閱不存在',
			'subNotice.titleExpired' => '訂閱已過期',
			'subNotice.titleInactive' => '訂閱已失效',
			'subNotice.titleDeviceOverLimit' => '裝置數量超限',
			'subNotice.titleUnavailable' => '訂閱不可用',
			'subNotice.titleWithReason' => ({required Object emoji, required Object title, required Object reason}) => '${emoji} ${title}（${reason}）',
			'subNotice.deviceUsedOfLimit' => ({required Object used, required Object limit}) => '目前裝置 ${used}/${limit}',
			'subNotice.deviceUsedOnly' => ({required Object used}) => '目前裝置 ${used}',
			'subNotice.expireAt' => ({required Object expire}) => '到期時間 ${expire}',
			'subNotice.supportLine' => ({required Object account}) => '💬 客服: ${account}',
			'subNotice.siteLine' => ({required Object url}) => '📢 官網: ${url}',
			'settingItems.subscriptionAutoUpdateInterval' => '訂閱自動更新間隔',
			'settingItems.speedTestMode' => '測速方式',
			'settingItems.speedTestModeTcp' => 'TCP 測速',
			'settingItems.speedTestModeKernel' => '內核測速',
			'settingItems.delayTestUrlTip' => '經該節點完整走一次 HTTP 請求的耗時（非 ping）\n預設用明文 http 的 204 空回應；換成 https 會多一次 TLS 握手，數字更大',
			'settingItems.systemProxy' => '系統代理',
			'settingItems.systemProxyTip' => '檢視/重設位址與連接埠',
			'settingItems.tunMode' => 'TUN 模式',
			'settingItems.tunModeTip' => 'off=僅系統代理 / auto=TUN+系統代理 / force=僅 TUN\n桌面端 TUN 需要管理員權限（Windows 建 wintun / macOS 建 utun）',
			'settingItems.tunOverwriteTip' => 'overwrite\n開 = 用這裡的 TUN 設定覆蓋訂閱裡的 tun 段\n關 = 讓訂閱自己的 tun 設定生效（App 不插手）',
			'settingItems.tunEnableByTunMode' => ({required Object enable}) => '${enable}（由 TUN 模式決定）',
			'settingItems.interval30Minutes' => '30 分鐘',
			'settingItems.interval1Hour' => '1 小時',
			'settingItems.interval6Hours' => '6 小時',
			'settingItems.interval12Hours' => '12 小時',
			'settingItems.interval24Hours' => '24 小時',
			'settingItems.interval3Days' => '3 天',
			'settingItems.interval7Days' => '7 天',
			'settingItems.intervalNever' => '從不',
			'settingItems.intervalMinutes' => ({required Object minutes}) => '${minutes} 分鐘',
			'settingItems.intervalHours' => ({required Object hours}) => '${hours} 小時',
			'settingItems.intervalDays' => ({required Object days}) => '${days} 天',
			'tunScreen.modeOff' => '關閉',
			'tunScreen.modeAuto' => '自動',
			'tunScreen.modeForce' => '強制',
			'tunScreen.modeOffDesc' => '僅系統代理：瀏覽器等遵守系統代理的程式生效，UDP/遊戲不走代理',
			'tunScreen.modeAutoDesc' => 'TUN + 系統代理（雙保險）：全部流量走虛擬網卡，含 UDP',
			'tunScreen.modeForceDesc' => '僅 TUN：全部流量走虛擬網卡，不再改系統代理',
			'tunScreen.modeOffOptionDesc' => '不改系統路由表，只在系統裡設定 127.0.0.1 的代理。只有遵守系統代理的程式走代理；UDP 流量與自帶代理設定的程式不走。',
			'tunScreen.modeAutoOptionDesc' => '建立虛擬網卡接管全部流量（含 UDP、遊戲）；同時保留系統代理作為兜底。推薦：既能全域生效，又不會因為權限問題徹底沒網。',
			'tunScreen.modeForceOptionDesc' => '只用虛擬網卡，不再改系統代理。全部流量（含 UDP）都進隧道，系統裡「代理」一項保持原樣。',
			'tunScreen.adminRequiredDialog' => 'TUN 虛擬網卡需要管理員權限（Windows 建 wintun / macOS 建 utun）。\n\n目前 Mclash 不是以管理員身分執行的，開啟後 TUN 不會生效（「自動」模式下系統代理仍會兜底，網路可用）。\n\n點「確定」= 現在以管理員身分重新啟動 Mclash（會彈 UAC）\n點「取消」= 仍要儲存這個選擇（TUN 不生效時會自動用系統代理）',
			'tunScreen.relaunchFailed' => ({required Object message}) => '重新啟動失敗：${message}',
			'tunScreen.switchFailed' => ({required Object message}) => '切換 TUN 模式失敗：${message}\n已還原原來的設定。',
			'tunScreen.setOffSnack' => '已設為「關閉」：只使用系統代理',
			'tunScreen.setModeSnack' => ({required Object mode, required Object effect}) => '已設為「${mode}」，${effect}',
			'tunScreen.effectReconnected' => '已重連生效',
			'tunScreen.effectAfterConnect' => '連線後生效',
			'tunScreen.sheetTitle' => 'TUN 虛擬網卡',
			'tunScreen.advancedTitle' => '進階參數（核心設定 → TUN）',
			'tunScreen.advancedSubtitle' => '虛擬網卡位址 / 堆疊 / MTU / 自動路由 / DNS 劫持 / 覆寫',
			'tunScreen.adminOk' => 'TUN 需要管理員權限；目前權限滿足（Windows 以管理員執行 / macOS 以 root 執行）',
			'tunScreen.adminMissing' => 'TUN 需要管理員權限：目前未以管理員身分執行，選中「自動/強制」後 TUN 不會生效（「自動」會用系統代理兜底，網路仍可用）',
			_ => null,
		};
	}
}
