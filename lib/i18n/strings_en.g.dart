///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import
// dart format off

part of 'strings.g.dart';

// Path: <root>
typedef TranslationsEn = Translations; // ignore: unused_element
class Translations with BaseTranslations<AppLocale, Translations> {
	/// Returns the current translations of the given [context].
	///
	/// Usage:
	/// final t = Translations.of(context);
	static Translations of(BuildContext context) => InheritedLocaleData.of<AppLocale, Translations>(context).translations;

	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	Translations({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: AppLocale.en,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <en>.
	final TranslationMetadata<AppLocale, Translations> _meta;
	@override TranslationMetadata<AppLocale, Translations> get $meta => _meta;

	/// Access flat map
	dynamic operator[](String key) => _meta.getTranslation(key);

	late final Translations _root = this; // ignore: unused_field

	Translations $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => Translations(meta: meta ?? this.$meta);

	// Translations
	late final Translations$BackupAndSyncWebdavScreen$en BackupAndSyncWebdavScreen = Translations$BackupAndSyncWebdavScreen$en._(_root);
	late final Translations$LaunchFailedScreen$en LaunchFailedScreen = Translations$LaunchFailedScreen$en._(_root);
	late final Translations$PerAppAndroidScreen$en PerAppAndroidScreen = Translations$PerAppAndroidScreen$en._(_root);
	late final Translations$UserAgreementScreen$en UserAgreementScreen = Translations$UserAgreementScreen$en._(_root);
	late final Translations$VersionUpdateScreen$en VersionUpdateScreen = Translations$VersionUpdateScreen$en._(_root);
	late final Translations$NetCheckScreen$en NetCheckScreen = Translations$NetCheckScreen$en._(_root);
	late final Translations$loginScreen$en loginScreen = Translations$loginScreen$en._(_root);
	late final Translations$main$en main = Translations$main$en._(_root);
	late final Translations$meta$en meta = Translations$meta$en._(_root);
	late final Translations$permission$en permission = Translations$permission$en._(_root);
	late final Translations$tls$en tls = Translations$tls$en._(_root);
	late final Translations$tun$en tun = Translations$tun$en._(_root);
	late final Translations$dns$en dns = Translations$dns$en._(_root);
	late final Translations$sniffer$en sniffer = Translations$sniffer$en._(_root);
	late final Translations$profilePatchMode$en profilePatchMode = Translations$profilePatchMode$en._(_root);

	/// en: 'Please use [$p]'
	String sendOrReceiveNotMatch({required Object p}) => 'Please use [${p}]';

	/// en: 'Failed to connect to [$p]. Please make sure the devices are in the same LAN'
	String targetConnectFailed({required Object p}) => 'Failed to connect to [${p}]. Please make sure the devices are in the same LAN';

	/// en: 'The current device has not installed the Edge WebView2 runtime, so the page cannot be displayed. Please download and install the Edge WebView2 runtime (x64), restart the App and try again.'
	String get edgeRuntimeNotInstalled => 'The current device has not installed the Edge WebView2 runtime, so the page cannot be displayed. Please download and install the Edge WebView2 runtime (x64), restart the App and try again.';

	Map<String, String> get locales => {
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
	Map<String, String> get countries => {
		'HK': 'Hong Kong',
		'TW': 'Taiwan',
		'MO': 'Macau',
		'CN': 'China',
		'JP': 'Japan',
		'KR': 'South Korea',
		'SG': 'Singapore',
		'MY': 'Malaysia',
		'TH': 'Thailand',
		'VN': 'Vietnam',
		'PH': 'Philippines',
		'ID': 'Indonesia',
		'KH': 'Cambodia',
		'US': 'United States',
		'CA': 'Canada',
		'MX': 'Mexico',
		'GB': 'United Kingdom',
		'DE': 'Germany',
		'FR': 'France',
		'NL': 'Netherlands',
		'RU': 'Russia',
		'IT': 'Italy',
		'ES': 'Spain',
		'CH': 'Switzerland',
		'SE': 'Sweden',
		'NO': 'Norway',
		'FI': 'Finland',
		'DK': 'Denmark',
		'PL': 'Poland',
		'AT': 'Austria',
		'IE': 'Ireland',
		'UA': 'Ukraine',
		'TR': 'Turkey',
		'PT': 'Portugal',
		'CZ': 'Czechia',
		'RO': 'Romania',
		'BE': 'Belgium',
		'GR': 'Greece',
		'HU': 'Hungary',
		'IL': 'Israel',
		'AE': 'United Arab Emirates',
		'SA': 'Saudi Arabia',
		'EG': 'Egypt',
		'ZA': 'South Africa',
		'NG': 'Nigeria',
		'AU': 'Australia',
		'NZ': 'New Zealand',
		'BR': 'Brazil',
		'AR': 'Argentina',
		'CL': 'Chile',
		'CO': 'Colombia',
		'IN': 'India',
		'PK': 'Pakistan',
		'XX': 'Other',
	};
	late final Translations$meScreen$en meScreen = Translations$meScreen$en._(_root);
	late final Translations$homeScreen$en homeScreen = Translations$homeScreen$en._(_root);
	late final Translations$nodesScreen$en nodesScreen = Translations$nodesScreen$en._(_root);
	late final Translations$nodeAuto$en nodeAuto = Translations$nodeAuto$en._(_root);
	late final Translations$accountBlock$en accountBlock = Translations$accountBlock$en._(_root);
	late final Translations$entitlementMsg$en entitlementMsg = Translations$entitlementMsg$en._(_root);
	late final Translations$devicesScreen$en devicesScreen = Translations$devicesScreen$en._(_root);
	late final Translations$sysProxySheet$en sysProxySheet = Translations$sysProxySheet$en._(_root);
	late final Translations$logScreen$en logScreen = Translations$logScreen$en._(_root);
	late final Translations$trayShell$en trayShell = Translations$trayShell$en._(_root);
	late final Translations$ordersScreen$en ordersScreen = Translations$ordersScreen$en._(_root);
	late final Translations$payment$en payment = Translations$payment$en._(_root);
	late final Translations$planScreen$en planScreen = Translations$planScreen$en._(_root);
	late final Translations$authScreen$en authScreen = Translations$authScreen$en._(_root);
	late final Translations$updatePrompt$en updatePrompt = Translations$updatePrompt$en._(_root);
	late final Translations$clearData$en clearData = Translations$clearData$en._(_root);
	late final Translations$apiError$en apiError = Translations$apiError$en._(_root);
	late final Translations$subNotice$en subNotice = Translations$subNotice$en._(_root);
	late final Translations$settingItems$en settingItems = Translations$settingItems$en._(_root);
	late final Translations$tunScreen$en tunScreen = Translations$tunScreen$en._(_root);
}

// Path: BackupAndSyncWebdavScreen
class Translations$BackupAndSyncWebdavScreen$en {
	Translations$BackupAndSyncWebdavScreen$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Server Url'
	String get webdavServerUrl => 'Server Url';

	/// en: 'Can not be empty'
	String get webdavRequired => 'Can not be empty';

	/// en: 'Login failed:'
	String get webdavLoginFailed => 'Login failed:';

	/// en: 'Failed to get file list:'
	String get webdavListFailed => 'Failed to get file list:';
}

// Path: LaunchFailedScreen
class Translations$LaunchFailedScreen$en {
	Translations$LaunchFailedScreen$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'The app failed to start [Invalid process name], please reinstall the app to a separate directory'
	String get invalidProcess => 'The app failed to start [Invalid process name], please reinstall the app to a separate directory';

	/// en: 'The app failed to start [Failed to access the profile], please reinstall the app'
	String get invalidProfile => 'The app failed to start [Failed to access the profile], please reinstall the app';

	/// en: 'The app failed to start [Invalid version], please reinstall the app'
	String get invalidVersion => 'The app failed to start [Invalid version], please reinstall the app';

	/// en: 'The app failed to start [system version too low]'
	String get systemVersionLow => 'The app failed to start [system version too low]';

	/// en: 'The installation path is invalid, please reinstall it to a valid path'
	String get invalidInstallPath => 'The installation path is invalid, please reinstall it to a valid path';
}

// Path: PerAppAndroidScreen
class Translations$PerAppAndroidScreen$en {
	Translations$PerAppAndroidScreen$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Per-App Proxy'
	String get title => 'Per-App Proxy';

	/// en: 'Whitelist Mode'
	String get whiteListMode => 'Whitelist Mode';

	/// en: 'When enabled: only the apps that have been checked are proxies; when not enabled: only the apps that are not checked are proxies'
	String get whiteListModeTip => 'When enabled: only the apps that have been checked are proxies; when not enabled: only the apps that are not checked are proxies';
}

// Path: UserAgreementScreen
class Translations$UserAgreementScreen$en {
	Translations$UserAgreementScreen$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Your Privacy Comes First'
	String get privacyFirst => 'Your Privacy Comes First';

	/// en: 'Accept & Continue'
	String get agreeAndContinue => 'Accept & Continue';
}

// Path: VersionUpdateScreen
class Translations$VersionUpdateScreen$en {
	Translations$VersionUpdateScreen$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'The new version[$p] is ready'
	String versionReady({required Object p}) => 'The new version[${p}] is ready';

	/// en: 'Restart To Update'
	String get update => 'Restart To Update';

	/// en: 'Not Now'
	String get cancel => 'Not Now';
}

// Path: NetCheckScreen
class Translations$NetCheckScreen$en {
	Translations$NetCheckScreen$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Please enter a domain'
	String get enterDomain => 'Please enter a domain';

	/// en: 'Checking...'
	String get checking => 'Checking...';

	/// en: 'A query failed: $p'
	String aQueryFailed({required Object p}) => 'A query failed: ${p}';

	/// en: 'AAAA query failed: $p'
	String aaaaQueryFailed({required Object p}) => 'AAAA query failed: ${p}';

	/// en: 'Success'
	String get success => 'Success';

	/// en: 'Failed'
	String get failed => 'Failed';

	/// en: 'Suspected DNS poisoning'
	String get suspectedPollution => 'Suspected DNS poisoning';

	/// en: 'Domain'
	String get domainLabel => 'Domain';

	/// en: 'Check'
	String get checkButton => 'Check';

	/// en: '1. DNS Query'
	String get dnsSection => '1. DNS Query';

	/// en: '2. HTTP (via TUN, enable TUN first)'
	String get directHttpSection => '2. HTTP (via TUN, enable TUN first)';

	/// en: '3. HTTP (via Proxy, port: $p)'
	String proxyHttpSection({required Object p}) => '3. HTTP (via Proxy, port: ${p})';

	/// en: 'TUN is not enabled'
	String get tunNotEnabled => 'TUN is not enabled';

	/// en: '4. Route Table'
	String get routeTableSection => '4. Route Table';
}

// Path: loginScreen
class Translations$loginScreen$en {
	Translations$loginScreen$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Login'
	String get login => 'Login';

	/// en: 'Register Account'
	String get register => 'Register Account';

	/// en: 'Forgot Password'
	String get forgotPassword => 'Forgot Password';

	/// en: 'Provider'
	String get provider => 'Provider';

	/// en: 'Provider Code/Alias/URL'
	String get providerName => '${_root.loginScreen.provider} Code/Alias/URL';

	/// en: 'Account'
	String get account => 'Account';

	/// en: 'Email'
	String get email => 'Email';

	/// en: 'Password'
	String get password => 'Password';
}

// Path: main
class Translations$main$en {
	Translations$main$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$main$tray$en tray = Translations$main$tray$en._(_root);
}

// Path: meta
class Translations$meta$en {
	Translations$meta$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Enable'
	String get enable => 'Enable';

	/// en: 'Disable'
	String get disable => 'Disable';

	/// en: 'Open'
	String get open => 'Open';

	/// en: 'Close'
	String get close => 'Close';

	/// en: 'Quit'
	String get quit => 'Quit';

	/// en: 'Add'
	String get add => 'Add';

	/// en: 'Remove'
	String get remove => 'Remove';

	/// en: 'Are you sure to delete?'
	String get removeConfirm => 'Are you sure to delete?';

	/// en: 'Edit'
	String get edit => 'Edit';

	/// en: 'View'
	String get view => 'View';

	/// en: 'Remark'
	String get remark => 'Remark';

	/// en: 'Default'
	String get byDefault => 'Default';

	/// en: 'More'
	String get more => 'More';

	/// en: 'Info'
	String get tips => 'Info';

	/// en: 'Select All'
	String get selectAll => 'Select All';

	/// en: 'Copy'
	String get copy => 'Copy';

	/// en: 'Paste'
	String get paste => 'Paste';

	/// en: 'Cut'
	String get cut => 'Cut';

	/// en: 'Save'
	String get save => 'Save';

	/// en: 'Ok'
	String get ok => 'Ok';

	/// en: 'Cancel'
	String get cancel => 'Cancel';

	/// en: 'FAQ'
	String get faq => 'FAQ';

	/// en: 'Document'
	String get doc => 'Document';

	/// en: 'HTML Toolset'
	String get htmlTools => 'HTML Toolset';

	/// en: 'Download'
	String get download => 'Download';

	/// en: 'Loading...'
	String get loading => 'Loading...';

	/// en: 'Days'
	String get days => 'Days';

	/// en: 'Hours'
	String get hours => 'Hours';

	/// en: 'Minutes'
	String get minutes => 'Minutes';

	/// en: 'Seconds'
	String get seconds => 'Seconds';

	/// en: 'Milliseconds'
	String get milliseconds => 'Milliseconds';

	/// en: 'Search'
	String get search => 'Search';

	/// en: 'Filter nodes (name or protocol)'
	String get searchNodeHint => 'Filter nodes (name or protocol)';

	/// en: 'Connect'
	String get connect => 'Connect';

	/// en: 'Disconnect'
	String get disconnect => 'Disconnect';

	/// en: 'Connected'
	String get connected => 'Connected';

	/// en: 'Disconnected'
	String get disconnected => 'Disconnected';

	/// en: 'Connecting'
	String get connecting => 'Connecting';

	/// en: 'Connect Timeout'
	String get connectTimeout => 'Connect Timeout';

	/// en: 'Timeout'
	String get timeout => 'Timeout';

	/// en: 'Latency Checks'
	String get latencyTest => 'Latency Checks';

	/// en: 'Network Check'
	String get networkCheck => 'Network Check';

	/// en: 'Language'
	String get language => 'Language';

	/// en: 'Next'
	String get next => 'Next';

	/// en: 'Done'
	String get done => 'Done';

	/// en: 'Apply'
	String get apply => 'Apply';

	/// en: 'Refresh'
	String get refresh => 'Refresh';

	/// en: 'Update'
	String get update => 'Update';

	/// en: 'Update interval'
	String get updateInterval => 'Update interval';

	/// en: 'Update failed:$p'
	String updateFailed({required Object p}) => 'Update failed:${p}';

	/// en: 'Minimum: 5m'
	String get updateInterval5mTips => 'Minimum: 5m';

	/// en: 'Prefer provider settings'
	String get updateIntervalPreferByProfile => 'Prefer provider settings';

	/// en: 'None'
	String get none => 'None';

	/// en: 'Reset'
	String get reset => 'Reset';

	/// en: 'Authentication'
	String get authentication => 'Authentication';

	/// en: 'User'
	String get user => 'User';

	/// en: 'Account'
	String get account => 'Account';

	/// en: 'Password'
	String get password => 'Password';

	/// en: 'Decrypt Password'
	String get decryptPassword => 'Decrypt Password';

	/// en: 'Required'
	String get required => 'Required';

	/// en: 'Continue'
	String get go => 'Continue';

	/// en: 'Other'
	String get other => 'Other';

	/// en: 'DNS'
	String get dns => 'DNS';

	/// en: 'URL'
	String get url => 'URL';

	/// en: 'Invalid URL'
	String get urlInvalid => 'Invalid URL';

	/// en: 'Copy Link'
	String get copyUrl => 'Copy Link';

	/// en: 'Open Link'
	String get openUrl => 'Open Link';

	/// en: 'Note: After modifying the configuration, you need to reconnect to take effect'
	String get coreSettingTips => 'Note: After modifying the configuration, you need to reconnect to take effect';

	/// en: 'Overwrite'
	String get overwrite => 'Overwrite';

	/// en: 'Append Overwrite'
	String get overwriteAppend => 'Append Overwrite';

	/// en: 'Original Profile <- Custom Overwrite <- App Overwrite'
	String get overwriteTips => 'Original Profile <- Custom Overwrite <- App Overwrite';

	/// en: 'Do not overwrite'
	String get noOverwrite => 'Do not overwrite';

	/// en: 'Diversion Template'
	String get diversionTemplates => 'Diversion Template';

	/// en: 'Rule Providers'
	String get ruleProviders => 'Rule Providers';

	/// en: 'Rule Templates'
	String get ruleTemplates => 'Rule Templates';

	/// en: 'Proxy Group Template'
	String get proxyGroupsTemplates => 'Proxy Group Template';

	/// en: 'Proxy Group'
	String get proxyGroups => 'Proxy Group';

	/// en: 'Proxy Node list'
	String get proxyNodeList => 'Proxy Node list';

	/// en: 'The following proxy nodes have expired and have been automatically removed: $p'
	String proxyNodeFailure({required Object p}) => 'The following proxy nodes have expired and have been automatically removed: ${p}';

	/// en: 'External Controller'
	String get externalController => 'External Controller';

	/// en: 'Secret'
	String get secret => 'Secret';

	/// en: 'TCP Concurrent Handshake'
	String get tcpConcurrent => 'TCP Concurrent Handshake';

	/// en: 'TLS Global Fingerprint'
	String get globalClientFingerprint => 'TLS Global Fingerprint';

	/// en: 'LAN device access'
	String get allowLanAccess => 'LAN device access';

	/// en: 'Mixed Proxy Port'
	String get mixedPort => 'Mixed Proxy Port';

	/// en: 'Log Level'
	String get logLevel => 'Log Level';

	/// en: 'Find Process Mode'
	String get findProcessMode => 'Find Process Mode';

	/// en: 'TCP Keep-alive Interval'
	String get tcpkeepAliveInterval => 'TCP Keep-alive Interval';

	/// en: 'Delay Test URL'
	String get delayTestUrl => 'Delay Test URL';

	/// en: 'Delay Test Timeout(ms)'
	String get delayTestTimeout => 'Delay Test Timeout(ms)';

	/// en: 'TUN'
	String get tun => 'TUN';

	/// en: 'NTP'
	String get ntp => 'NTP';

	/// en: 'TLS'
	String get tls => 'TLS';

	/// en: 'Downloading Geo RuleSet by proxy'
	String get geoDownloadByProxy => 'Downloading Geo RuleSet by proxy';

	/// en: 'Geosite/Geoip will be converted into the corresponding RuleSet'
	String get geoRulesetTips => 'Geosite/Geoip will be converted into the corresponding RuleSet';

	/// en: 'Sniffer'
	String get sniffer => 'Sniffer';

	/// en: 'UserAgent'
	String get userAgent => 'UserAgent';

	/// en: 'Launch at Startup'
	String get launchAtStartup => 'Launch at Startup';

	/// en: 'Please restart Mclash as administrator'
	String get launchAtStartupRunAsAdmin => 'Please restart Mclash as administrator';

	/// en: 'The TUN mode requires system administrator permissions, please restart the app as an administrator'
	String get tunModeRunAsAdmin => 'The TUN mode requires system administrator permissions, please restart the app as an administrator';

	/// en: 'Portable Mode'
	String get portableMode => 'Portable Mode';

	/// en: 'If you need to exit portable mode, please exit [mclash] and manually delete the [portable] folder in the same directory as [mclash.exe]'
	String get portableModeDisableTips => 'If you need to exit portable mode, please exit [mclash] and manually delete the [portable] folder in the same directory as [mclash.exe]';

	/// en: 'Auto Connection after Launch'
	String get autoConnectAfterLaunch => 'Auto Connection after Launch';

	/// en: 'Auto Connection after System Startup'
	String get autoConnectAtBoot => 'Auto Connection after System Startup';

	/// en: 'System support is required; some systems may also require [auto-start] to be enabled.'
	String get autoConnectAtBootTips => 'System support is required; some systems may also require [auto-start] to be enabled.';

	/// en: 'Hide window after startup'
	String get hideAfterLaunch => 'Hide window after startup';

	/// en: 'Auto Set System Proxy when Connected'
	String get autoSetSystemProxy => 'Auto Set System Proxy when Connected';

	/// en: 'Domain names that are allowed to bypass the system proxy'
	String get bypassSystemProxy => 'Domain names that are allowed to bypass the system proxy';

	/// en: 'Hide from [Recent Tasks]'
	String get excludeFromRecent => 'Hide from [Recent Tasks]';

	/// en: 'Wake Lock'
	String get wakeLock => 'Wake Lock';

	/// en: 'Hide Dock Icon'
	String get hideDockIcon => 'Hide Dock Icon';

	/// en: 'Show traffic info in tray'
	String get showTrayTraffic => 'Show traffic info in tray';

	/// en: 'Website'
	String get website => 'Website';

	/// en: 'Rule'
	String get rule => 'Rule';

	/// en: 'Global'
	String get global => 'Global';

	/// en: 'Direct'
	String get direct => 'Direct';

	/// en: 'QR Code'
	String get qrcode => 'QR Code';

	/// en: 'The text is too long to display'
	String get qrcodeTooLong => 'The text is too long to display';

	/// en: 'Share QR Code'
	String get qrcodeShare => 'Share QR Code';

	/// en: 'Scan QR Code'
	String get qrcodeScan => 'Scan QR Code';

	/// en: 'Scan Result'
	String get qrcodeScanResult => 'Scan Result';

	/// en: 'Backup and Sync'
	String get backupAndSync => 'Backup and Sync';

	/// en: 'Export'
	String get export => 'Export';

	/// en: 'Send'
	String get send => 'Send';

	/// en: 'Confirm to send?'
	String get sendConfirm => 'Confirm to send?';

	/// en: 'Log'
	String get log => 'Log';

	/// en: 'Core Log'
	String get coreLog => 'Core Log';

	/// en: 'App log'
	String get appLog => 'App log';

	/// en: 'Core'
	String get core => 'Core';

	/// en: 'Help'
	String get help => 'Help';

	/// en: 'Tutorial'
	String get tutorial => 'Tutorial';

	/// en: 'Board'
	String get board => 'Board';

	/// en: 'Use Online Board'
	String get boardOnline => 'Use Online Board';

	/// en: 'Online Board URL'
	String get boardOnlineUrl => 'Online Board URL';

	/// en: 'Local Board Port'
	String get boardLocalPort => 'Local Board Port';

	/// en: 'Always-on Connection'
	String get alwayOnVPN => 'Always-on Connection';

	/// en: 'Disable Font scaling(Restart takes effect)'
	String get disableFontScaler => 'Disable Font scaling(Restart takes effect)';

	/// en: 'Rotate with the screen'
	String get autoOrientation => 'Rotate with the screen';

	/// en: 'Restart takes effect'
	String get restartTakesEffect => 'Restart takes effect';

	/// en: 'Reconnect takes effect'
	String get reconnectTakesEffect => 'Reconnect takes effect';

	/// en: 'Runtime Profile'
	String get runtimeProfile => 'Runtime Profile';

	/// en: 'Please restart your device to complete the system extension installation'
	String get willCompleteAfterRebootInstall => 'Please restart your device to complete the system extension installation';

	/// en: '1. Please [Allow] Mclash to install system extensions in [System Settings]-[Privacy and Security] 2. [System Settings]-[General]-[Login Items Extensions]-[Network Extension] enable [mclashServiceSE] reconnect after completion'
	String get requestNeedsUserApproval => '1. Please [Allow] Mclash to install system extensions in [System Settings]-[Privacy and Security]\n2. [System Settings]-[General]-[Login Items Extensions]-[Network Extension] enable [mclashServiceSE]\nreconnect after completion';

	/// en: 'Please enable mclashServiceSE permission in [System Settings]-[Privacy and Security]-[Full Disk Access] and reconnect.'
	String get FullDiskAccessPermissionRequired => 'Please enable mclashServiceSE permission in [System Settings]-[Privacy and Security]-[Full Disk Access] and reconnect.';

	/// en: 'Proxy'
	String get proxy => 'Proxy';

	/// en: 'Theme'
	String get theme => 'Theme';

	/// en: 'TV Mode'
	String get tvMode => 'TV Mode';

	/// en: 'Auto Update'
	String get autoUpdate => 'Auto Update';

	/// en: 'Auto Update Channel'
	String get updateChannel => 'Auto Update Channel';

	/// en: 'Update Version $p'
	String hasNewVersion({required Object p}) => 'Update Version ${p}';

	/// en: 'Auto Download Update Packages'
	String get autoDownloadPkg => 'Auto Download Update Packages';

	/// en: 'Developer Options'
	String get devOptions => 'Developer Options';

	/// en: 'About'
	String get about => 'About';

	/// en: 'Name'
	String get name => 'Name';

	/// en: 'Version'
	String get version => 'Version';

	/// en: 'Reorder'
	String get sort => 'Reorder';

	/// en: 'Share'
	String get share => 'Share';

	/// en: 'Import From Clipboard'
	String get importFromClipboard => 'Import From Clipboard';

	/// en: 'Export to Clipboard'
	String get exportToClipboard => 'Export to Clipboard';

	/// en: 'Server'
	String get server => 'Server';

	/// en: 'Port'
	String get port => 'Port';

	/// en: 'Donate'
	String get donate => 'Donate';

	/// en: 'Settings'
	String get setting => 'Settings';

	/// en: 'Core Settings'
	String get settingCore => 'Core Settings';

	/// en: 'App Settings'
	String get settingApp => 'App Settings';

	/// en: 'Core Overwrite'
	String get coreOverwrite => 'Core Overwrite';

	/// en: 'iCloud'
	String get iCloud => 'iCloud';

	/// en: 'Webdav'
	String get webdav => 'Webdav';

	/// en: 'LAN Sync'
	String get lanSync => 'LAN Sync';

	/// en: 'Do not exit this interface before synchronization is completed'
	String get lanSyncNotQuitTips => 'Do not exit this interface before synchronization is completed';

	/// en: 'Not enough disk space'
	String get deviceNoSpace => 'Not enough disk space';

	/// en: 'Hide System Apps'
	String get hideSystemApp => 'Hide System Apps';

	/// en: 'Hide App Icons'
	String get hideAppIcon => 'Hide App Icons';

	/// en: 'Open File Directory'
	String get openDir => 'Open File Directory';

	/// en: 'Type'
	String get type => 'Type';

	/// en: 'File does not exist:$p'
	String fileNotExist({required Object p}) => 'File does not exist:${p}';

	/// en: 'Buy Profile'
	String get buyProfile => 'Buy Profile';

	/// en: 'My Profiles'
	String get myProfiles => 'My Profiles';

	/// en: 'Profile Edit'
	String get profileEdit => 'Profile Edit';

	/// en: 'Please set this profile as the current profile first, then start/reconnect'
	String get profileNeedActive => 'Please set this profile as the current profile first, then start/reconnect';

	/// en: '$p Profile Link'
	String profileUrlOrContent({required Object p}) => '${p} Profile Link';

	/// en: 'Home'
	String get tabHome => 'Home';

	/// en: 'Nodes'
	String get tabNodes => 'Nodes';

	/// en: 'Plans'
	String get tabPlans => 'Plans';

	/// en: 'Me'
	String get tabMe => 'Me';
}

// Path: permission
class Translations$permission$en {
	Translations$permission$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Camera'
	String get camera => 'Camera';

	/// en: 'Screen Recording'
	String get screen => 'Screen Recording';

	/// en: 'Get Application List'
	String get appQuery => 'Get Application List';

	/// en: 'Turn on [$p] permission'
	String request({required Object p}) => 'Turn on [${p}] permission';

	/// en: 'Please Turn on [$p] permission'
	String requestNeed({required Object p}) => 'Please Turn on [${p}] permission';
}

// Path: tls
class Translations$tls$en {
	Translations$tls$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Certificate'
	String get certificate => 'Certificate';

	/// en: 'Private Key'
	String get privateKey => 'Private Key';

	/// en: 'Custom Certifactes'
	String get customTrustCert => 'Custom Certifactes';
}

// Path: tun
class Translations$tun$en {
	Translations$tun$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Network stack'
	String get stack => 'Network stack';

	/// en: 'IPv4 Gateway Address'
	String get inet4Address => 'IPv4 Gateway Address';

	/// en: 'DNS Hijack'
	String get dnsHijack => 'DNS Hijack';

	/// en: 'Strict Route'
	String get strictRoute => 'Strict Route';

	/// en: 'Default Route'
	String get tunDefaultRoute => 'Default Route';

	/// en: 'ICMP Forwarding'
	String get icmpForward => 'ICMP Forwarding';

	/// en: 'Allow Apps to Bypass VPN'
	String get allowBypass => 'Allow Apps to Bypass VPN';

	/// en: 'Append HTTP Proxy to VPN'
	String get appendHttpProxy => 'Append HTTP Proxy to VPN';

	/// en: 'Domains allowed to bypass HTTP proxy'
	String get bypassHttpProxyDomain => 'Domains allowed to bypass HTTP proxy';
}

// Path: dns
class Translations$dns$en {
	Translations$dns$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Listen'
	String get listen => 'Listen';

	/// en: 'fake-ip'
	String get fakeIp => 'fake-ip';

	/// en: 'Fallback'
	String get fallback => 'Fallback';

	/// en: 'Prefer DoH H3'
	String get preferH3 => 'Prefer DoH H3';

	/// en: 'Use Hosts'
	String get useHosts => 'Use Hosts';

	/// en: 'Use System Hosts'
	String get useSystemHosts => 'Use System Hosts';

	/// en: 'Enhanced Mode'
	String get enhancedMode => 'Enhanced Mode';

	/// en: 'fake-ip Filter Mode'
	String get fakeIPFilterMode => '${_root.dns.fakeIp} Filter Mode';

	/// en: 'fake-ip Filter'
	String get fakeIPFilter => 'fake-ip Filter';

	/// en: 'Respect Rules'
	String get respectRules => 'Respect Rules';

	/// en: 'NameServer'
	String get nameServer => 'NameServer';

	/// en: 'Default NameServer'
	String get defaultNameServer => '${_root.meta.byDefault} ${_root.dns.nameServer}';

	/// en: 'Proxy NameServer'
	String get proxyNameServer => '${_root.meta.proxy} ${_root.dns.nameServer}';

	/// en: 'Direct NameServer'
	String get directNameServer => '${_root.meta.direct} ${_root.dns.nameServer}';

	/// en: 'Fallback NameServer'
	String get fallbackNameServer => '${_root.dns.fallback} ${_root.dns.nameServer}';

	/// en: 'Fallback GeoIp'
	String get fallbackGeoIp => '${_root.dns.fallback} GeoIp';

	/// en: 'Fallback GeoIpCode'
	String get fallbackGeoIpCode => '${_root.dns.fallback} GeoIpCode';
}

// Path: sniffer
class Translations$sniffer$en {
	Translations$sniffer$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Override'
	String get overrideDest => 'Override';
}

// Path: profilePatchMode
class Translations$profilePatchMode$en {
	Translations$profilePatchMode$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Current Selected'
	String get currentSelected => 'Current Selected';

	/// en: 'Built-in Overwrite'
	String get overwrite => 'Built-in Overwrite';

	/// en: 'Built-in - no Overwrite'
	String get noOverwrite => 'Built-in - no Overwrite';
}

// Path: meScreen
class Translations$meScreen$en {
	Translations$meScreen$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Balance'
	String get accountBalance => 'Balance';

	/// en: 'Expires'
	String get expireAt => 'Expires';

	/// en: 'Days Left'
	String get remainingDays => 'Days Left';

	/// en: 'Devices'
	String get deviceCount => 'Devices';

	/// en: 'My Orders'
	String get myOrders => 'My Orders';

	/// en: 'Device Management'
	String get deviceManagement => 'Device Management';

	/// en: 'Change Password'
	String get changePassword => 'Change Password';

	/// en: 'Clear local data (before uninstall)'
	String get clearLocalData => 'Clear local data (before uninstall)';

	/// en: 'Profile management (developer)'
	String get profileManagementDev => 'Profile management (developer)';

	/// en: 'TUN virtual adapter'
	String get tunAdapter => 'TUN virtual adapter';

	/// en: 'Check for updates'
	String get checkUpdate => 'Check for updates';

	/// en: 'Retry'
	String get retry => 'Retry';

	/// en: 'Failed to load account info: the sign-in may have expired or the network is unreachable. Tap Refresh at the top right to retry; if it keeps failing, sign in again.'
	String get loadFailed => 'Failed to load account info: the sign-in may have expired or the network is unreachable.\nTap Refresh at the top right to retry; if it keeps failing, sign in again.';

	/// en: 'Sign out?'
	String get logoutConfirm => 'Sign out?';

	/// en: 'The dashboard shows the kernel's live data (connection, traffic, rule hits). The kernel is not running, so the dashboard would be an empty shell. Tap OK to open it anyway, or Cancel to connect on the Home tab first.'
	String get boardNoKernel => 'The dashboard shows the kernel\'s live data (connection, traffic, rule hits).\n\nThe kernel is not running, so the dashboard would be an empty shell.\nTap OK to open it anyway, or Cancel to connect on the Home tab first.';

	/// en: 'Opened the dashboard in your browser; switch nodes or rules there and the app follows within ~5 seconds.'
	String get boardOpened => 'Opened the dashboard in your browser; switch nodes or rules there and the app follows within ~5 seconds.';
}

// Path: homeScreen
class Translations$homeScreen$en {
	Translations$homeScreen$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Expires ${date}'
	String expiresOn({required Object date}) => 'Expires ${date}';

	/// en: 'Devices ${text}'
	String devicesText({required Object text}) => 'Devices ${text}';

	/// en: 'Upgrade'
	String get upgrade => 'Upgrade';

	/// en: 'Quick country filter'
	String get quickCountries => 'Quick country filter';

	/// en: '${count} nodes'
	String nodeCount({required Object count}) => '${count} nodes';

	/// en: 'Pick the lowest-latency available node across all countries (auto mode)'
	String get autoBestTip => 'Pick the lowest-latency available node across all countries (auto mode)';

	/// en: 'Auto best'
	String get autoBest => 'Auto best';

	/// en: 'Auto-select the lowest-latency available node in "${label}" and pin it'
	String pickCountryTip({required Object label}) => 'Auto-select the lowest-latency available node in "${label}" and pin it';

	/// en: 'Already in auto mode (no better node found)'
	String get autoNoBetter => 'Already in auto mode (no better node found)';

	/// en: 'Switched to the best node: ${name}'
	String switchedBest({required Object name}) => 'Switched to the best node: ${name}';

	/// en: 'Switched to the fastest ${country} node: ${node}${ms}'
	String switchedCountry({required Object country, required Object node, required Object ms}) => 'Switched to the fastest ${country} node: ${node}${ms}';

	/// en: 'Filtered by ${country}; switching failed: ${err}'
	String filterCountryFailed({required Object country, required Object err}) => 'Filtered by ${country}; switching failed: ${err}';

	/// en: 'Current devices ${used}/${limit} '
	String deviceFullCount({required Object used, required Object limit}) => 'Current devices ${used}/${limit}\n\n';

	/// en: 'Upgrading the device limit restores the connection immediately (recommended); you can also delete unused devices to free a slot.'
	String get deviceFullUpgradeHint => 'Upgrading the device limit restores the connection immediately (recommended); you can also delete unused devices to free a slot.';

	/// en: 'Later'
	String get later => 'Later';

	/// en: 'Upgrade device limit'
	String get upgradeDeviceCount => 'Upgrade device limit';

	/// en: 'Cannot connect'
	String get cannotConnect => 'Cannot connect';

	/// en: 'Not synced yet · tap to refresh'
	String get freshnessNever => 'Not synced yet · tap to refresh';

	/// en: 'Updated just now · tap Manage devices'
	String get freshnessJustNow => 'Updated just now · tap Manage devices';

	/// en: '${minutes} min ago · tap Manage devices'
	String freshnessMinutes({required Object minutes}) => '${minutes} min ago · tap Manage devices';

	/// en: '${minutes} min ago · tap to refresh'
	String freshnessStale({required Object minutes}) => '${minutes} min ago · tap to refresh';

	/// en: 'Auto subscription sync'
	String get subscriptionAutoSync => 'Auto subscription sync';

	/// en: 'Connecting…'
	String get connecting => 'Connecting…';

	/// en: 'Disconnecting…'
	String get disconnecting => 'Disconnecting…';

	/// en: 'Tap the switch to disconnect'
	String get tapToDisconnect => 'Tap the switch to disconnect';

	/// en: 'Tap the switch to connect'
	String get tapToConnect => 'Tap the switch to connect';

	/// en: 'Current node'
	String get currentNode => 'Current node';

	/// en: 'No node selected'
	String get noNodeSelected => 'No node selected';

	/// en: 'Switch'
	String get switchAction => 'Switch';

	/// en: 'Real-time speed'
	String get realtimeSpeed => 'Real-time speed';

	/// en: 'Total traffic'
	String get totalTraffic => 'Total traffic';

	/// en: 'Subscription downloaded, but the profile is not ready yet. Please try again shortly.'
	String get subSyncedNotReady => 'Subscription downloaded, but the profile is not ready yet. Please try again shortly.';

	/// en: 'This account has no available plan yet. Please purchase one first.'
	String get noPlan => 'This account has no available plan yet. Please purchase one first.';

	/// en: 'Your sign-in has expired. Please sign in again.'
	String get loginExpired => 'Your sign-in has expired. Please sign in again.';

	/// en: 'Syncing subscription, please wait.'
	String get syncingWait => 'Syncing subscription, please wait.';

	/// en: 'Subscription sync failed: ${message} Check your network and try again.'
	String syncFailedNetwork({required Object message}) => 'Subscription sync failed: ${message}\nCheck your network and try again.';

	/// en: 'Subscription sync failed, please try again later.'
	String get syncFailed => 'Subscription sync failed, please try again later.';

	/// en: 'Reset'
	String get resetProxy => 'Reset';

	/// en: ' (${ms}ms)'
	String latencySuffix({required Object ms}) => ' (${ms}ms)';
}

// Path: nodesScreen
class Translations$nodesScreen$en {
	Translations$nodesScreen$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Subscription updated: ${count} nodes'
	String updatedCount({required Object count}) => 'Subscription updated: ${count} nodes';

	/// en: 'Update failed: ${message}'
	String updateFailed({required Object message}) => 'Update failed: ${message}';

	/// en: 'Update failed, please check your network'
	String get updateFailedNetwork => 'Update failed, please check your network';

	/// en: 'Speed test done: ${ok} reachable, ${fail} unreachable (may be offline)'
	String testDone({required Object ok, required Object fail}) => 'Speed test done: ${ok} reachable, ${fail} unreachable (may be offline)';

	/// en: 'Switched to ${name}'
	String switchedTo({required Object name}) => 'Switched to ${name}';

	/// en: 'Switch failed: ${message} (Node switching needs a running kernel; turn on the switch on the Home tab first.)'
	String switchFailed({required Object message}) => 'Switch failed: ${message}\n(Node switching needs a running kernel; turn on the switch on the Home tab first.)';

	/// en: 'Selected ${name} (takes effect after connecting)'
	String selectedAfterConnect({required Object name}) => 'Selected ${name} (takes effect after connecting)';

	/// en: 'Nodes'
	String get title => 'Nodes';

	/// en: 'Search nodes'
	String get searchNode => 'Search nodes';

	/// en: 'Sort by latency'
	String get sortByLatency => 'Sort by latency';

	/// en: 'Update subscription'
	String get updateSubscription => 'Update subscription';

	/// en: 'View by proxy group'
	String get viewByGroup => 'View by proxy group';

	/// en: 'Test all'
	String get testAll => 'Test all';

	/// en: 'Search node / country / protocol'
	String get searchHint => 'Search node / country / protocol';

	/// en: 'No nodes available yet. Subscriptions sync automatically; if you just signed in, wait a moment or tap reload below.'
	String get emptyNoNodes => 'No nodes available yet.\nSubscriptions sync automatically; if you just signed in, wait a moment or tap reload below.';

	/// en: 'No matching nodes.'
	String get emptyNoMatch => 'No matching nodes.';

	/// en: 'Reload'
	String get reload => 'Reload';

	/// en: 'Current (in use)'
	String get currentInUse => 'Current (in use)';

	/// en: 'Current'
	String get current => 'Current';

	/// en: 'Not measured (kernel reload pending)'
	String get notTested => 'Not measured (kernel reload pending)';

	/// en: 'Timeout'
	String get timeout => 'Timeout';

	/// en: 'Clear'
	String get clear => 'Clear';

	/// en: 'Select node'
	String get selectNode => 'Select node';

	/// en: 'No nodes available yet. Please turn on the connection switch on the Home tab first.'
	String get emptyNoKernel => 'No nodes available yet.\nPlease turn on the connection switch on the Home tab first.';

	/// en: 'Open the full node list (search / speed test / groups)'
	String get openFullList => 'Open the full node list (search / speed test / groups)';
}

// Path: nodeAuto
class Translations$nodeAuto$en {
	Translations$nodeAuto$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Node status is temporarily unavailable from the kernel; will retry automatically.'
	String get kernelStateUnavailable => 'Node status is temporarily unavailable from the kernel; will retry automatically.';

	/// en: 'Back to the pinned node: $fixed'
	String backToFixedNode({required Object fixed}) => 'Back to the pinned node: ${fixed}';

	/// en: 'No usable node found. Please pick one manually in the node list.'
	String get noUsableNodePickOne => 'No usable node found. Please pick one manually in the node list.';

	/// en: 'No usable node found. Please try picking one in the node list.'
	String get noUsableNodeTryOne => 'No usable node found. Please try picking one in the node list.';

	/// en: 'Auto-connected to the best node: $bestNode ($bestMs ms)'
	String autoConnectedBest({required Object bestNode, required Object bestMs}) => 'Auto-connected to the best node: ${bestNode} (${bestMs} ms)';

	/// en: 'The current node cannot reach the internet; switching automatically…'
	String get currentNodeUnreachable => 'The current node cannot reach the internet; switching automatically…';

	/// en: 'Automatically switched to a usable node: $target'
	String autoSwitchedToUsable({required Object target}) => 'Automatically switched to a usable node: ${target}';

	/// en: '$missing new node(s) in the subscription are not in the kernel yet; reloading…'
	String newNodesReloading({required Object missing}) => '${missing} new node(s) in the subscription are not in the kernel yet; reloading…';

	/// en: 'The kernel reloaded with the new subscription; run the speed test again.'
	String get kernelReloadedRetest => 'The kernel reloaded with the new subscription; run the speed test again.';
}

// Path: accountBlock
class Translations$accountBlock$en {
	Translations$accountBlock$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Device slots are full ($used/$limit): this device is still within the licensed range and can connect normally. To add another device, upgrade the device limit or remove unused ones.'
	String quotaFull({required Object used, required Object limit}) => 'Device slots are full (${used}/${limit}): this device is still within the licensed range and can connect normally. To add another device, upgrade the device limit or remove unused ones.';

	/// en: 'Your account has been disabled and can no longer be used.'
	String get banFallback => 'Your account has been disabled and can no longer be used.';

	/// en: 'Plan expired'
	String get titleExpired => 'Plan expired';

	/// en: 'Device limit reached'
	String get titleDeviceFull => 'Device limit reached';

	/// en: 'Account disabled'
	String get titleAccountDisabled => 'Account disabled';

	/// en: 'Plan disabled'
	String get titlePlanDisabled => 'Plan disabled';

	/// en: 'No plan yet'
	String get titleNoPlan => 'No plan yet';

	/// en: 'This device was removed'
	String get titleDeviceRemoved => 'This device was removed';

	/// en: 'Service temporarily unavailable'
	String get titleServiceUnavailable => 'Service temporarily unavailable';

	/// en: 'Your plan has expired. Purchase a plan to keep using global nodes.'
	String get textExpired => 'Your plan has expired. Purchase a plan to keep using global nodes.';

	/// en: 'The server has determined this device exceeds the plan device limit ($used/$limit), so it cannot connect for now. Remove unused devices in Me - Device Management, or upgrade to a plan with more devices.'
	String textDeviceFull({required Object used, required Object limit}) => 'The server has determined this device exceeds the plan device limit (${used}/${limit}), so it cannot connect for now. Remove unused devices in Me - Device Management, or upgrade to a plan with more devices.';

	/// en: 'Your account has been disabled. Please contact support if you have questions.'
	String get textAccountDisabled => 'Your account has been disabled. Please contact support if you have questions.';

	/// en: 'Your plan has been disabled or is in an abnormal state, so you cannot connect. Please contact support if you have questions.'
	String get textPlanDisabled => 'Your plan has been disabled or is in an abnormal state, so you cannot connect. Please contact support if you have questions.';

	/// en: 'You have not purchased a plan yet. Purchase one to use global nodes.'
	String get textNoPlan => 'You have not purchased a plan yet. Purchase one to use global nodes.';

	/// en: 'This device was removed and signed out. Please sign in again.'
	String get textDeviceRemoved => 'This device was removed and signed out. Please sign in again.';

	/// en: 'The service is temporarily unavailable. Please try again later; if it persists, take a screenshot and contact support.'
	String get textServiceUnavailable => 'The service is temporarily unavailable. Please try again later; if it persists, take a screenshot and contact support.';

	/// en: '$days days left'
	String remainingDays({required Object days}) => '${days} days left';

	/// en: 'Devices $used/$limit'
	String deviceUsage({required Object used, required Object limit}) => 'Devices ${used}/${limit}';
}

// Path: entitlementMsg
class Translations$entitlementMsg$en {
	Translations$entitlementMsg$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Authorization state abnormal'
	String get tamperedTitle => 'Authorization state abnormal';

	/// en: 'A system clock rollback (or local authorization data tampering) was detected. Please go online to complete a verification before connecting.'
	String get tamperedClock => 'A system clock rollback (or local authorization data tampering) was detected. Please go online to complete a verification before connecting.';

	/// en: 'Local authorization data is corrupted or was modified. Please go online to complete a verification before connecting.'
	String get tamperedLocal => 'Local authorization data is corrupted or was modified. Please go online to complete a verification before connecting.';

	/// en: 'Online verification required'
	String get needVerifyTitle => 'Online verification required';

	/// en: 'Cannot confirm your plan status: please connect to the network and sign in, then complete one verification before connecting.'
	String get needVerifyFirst => 'Cannot confirm your plan status: please connect to the network and sign in, then complete one verification before connecting.';

	/// en: 'Cannot confirm your plan status. Please go online and try again.'
	String get needVerifyRetry => 'Cannot confirm your plan status. Please go online and try again.';

	/// en: 'Cannot verify plan status'
	String get verifyFailedTitle => 'Cannot verify plan status';

	/// en: 'The verification grace period has passed and the server is unreachable. Check your network and try again (if you just renewed, sign in again).'
	String get verifyFailedText => 'The verification grace period has passed and the server is unreachable. Check your network and try again (if you just renewed, sign in again).';

	/// en: 'Account restricted'
	String get restrictedTitle => 'Account restricted';

	/// en: 'Your account or plan has been disabled, so you cannot connect.'
	String get restrictedFallback => 'Your account or plan has been disabled, so you cannot connect.';

	/// en: 'Plan expired'
	String get expiredTitle => 'Plan expired';

	/// en: 'Your plan expired on $date. The local subscription profile has been cleared. Renew and sign in again to restore it.'
	String expiredText({required Object date}) => 'Your plan expired on ${date}. The local subscription profile has been cleared. Renew and sign in again to restore it.';
}

// Path: devicesScreen
class Translations$devicesScreen$en {
	Translations$devicesScreen$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Device Management'
	String get title => 'Device Management';

	/// en: 'Current plan'
	String get currentPlan => 'Current plan';

	/// en: 'Devices $text'
	String devicesText({required Object text}) => 'Devices ${text}';

	/// en: 'Upgrade devices / extend time'
	String get upgradeTitle => 'Upgrade devices / extend time';

	/// en: 'Add devices and days together; one price, one payment'
	String get upgradeSubtitle => 'Add devices and days together; one price, one payment';

	/// en: 'Add devices'
	String get addDevices => 'Add devices';

	/// en: 'No change'
	String get noAddDevices => 'No change';

	/// en: '+$n devices'
	String addDevicesCount({required Object n}) => '+${n} devices';

	/// en: 'Add days'
	String get addDays => 'Add days';

	/// en: 'No extension'
	String get noExtend => 'No extension';

	/// en: '+$n days ($months months)'
	String addDaysCount({required Object n, required Object months}) => '+${n} days (${months} months)';

	/// en: 'Failed to get the price'
	String get priceFailed => 'Failed to get the price';

	/// en: 'Total ¥$amount'
	String amountDue({required Object amount}) => 'Total ¥${amount}';

	/// en: 'Recalculate'
	String get requote => 'Recalculate';

	/// en: 'Pay now'
	String get goPay => 'Pay now';

	/// en: 'After upgrade: '
	String get afterUpgrade => 'After upgrade: ';

	/// en: 'device limit $limit'
	String afterLimit({required Object limit}) => 'device limit ${limit}';

	/// en: 'expires $date'
	String afterExpire({required Object date}) => 'expires ${date}';

	/// en: 'Please add at least some devices or days'
	String get pickSomething => 'Please add at least some devices or days';

	/// en: 'The panel does not support "extend time only" yet: please set "Add devices" to 1 or more and try again (or contact support to enable it).'
	String get daysOnlyUnsupported => 'The panel does not support "extend time only" yet: please set "Add devices" to 1 or more and try again (or contact support to enable it).';

	/// en: 'Parameters rejected: please pick the device count and days again.'
	String get paramsRejected => 'Parameters rejected: please pick the device count and days again.';

	/// en: 'The subscription has expired, so it cannot be upgraded. Please renew or purchase a plan first.'
	String get subscriptionExpired => 'The subscription has expired, so it cannot be upgraded. Please renew or purchase a plan first.';

	/// en: 'Order information is incomplete. Tap "Recalculate" and try again.'
	String get orderIncomplete => 'Order information is incomplete. Tap "Recalculate" and try again.';

	/// en: 'The previous order expired; a new one was created with the same settings.'
	String get orderRegenerated => 'The previous order expired; a new one was created with the same settings.';

	/// en: 'Order or payment channel information is incomplete. Please recalculate and try again.'
	String get payChannelIncomplete => 'Order or payment channel information is incomplete. Please recalculate and try again.';

	/// en: 'The server did not return a payment QR code / link. Please pick another payment method or try later.'
	String get noQrCode => 'The server did not return a payment QR code / link. Please pick another payment method or try later.';

	/// en: 'Failed to start payment: $err'
	String payStartFailed({required Object err}) => 'Failed to start payment: ${err}';

	/// en: 'Payment cancelled; the draft order has been cleaned up.'
	String get payCancelled => 'Payment cancelled; the draft order has been cleaned up.';

	/// en: 'Balance'
	String get balancePay => 'Balance';

	/// en: 'No payment method is available right now. Please try later or contact support.'
	String get noPayMethod => 'No payment method is available right now. Please try later or contact support.';

	/// en: 'Insufficient balance (¥$balance, need ¥$amount). Top up first?'
	String balanceInsufficient({required Object balance, required Object amount}) => 'Insufficient balance (¥${balance}, need ¥${amount}).\nTop up first?';

	/// en: 'Choose a payment method'
	String get choosePayMethod => 'Choose a payment method';

	/// en: 'Balance ¥$balance'
	String balanceText({required Object balance}) => 'Balance ¥${balance}';

	/// en: 'Balance ¥$balance (insufficient, please top up)'
	String balanceShort({required Object balance}) => 'Balance ¥${balance} (insufficient, please top up)';

	/// en: 'Unknown device'
	String get unknownDevice => 'Unknown device';

	/// en: '● Online'
	String get online => '● Online';

	/// en: '○ Offline'
	String get offline => '○ Offline';

	/// en: 'Last active $text'
	String lastActive({required Object text}) => 'Last active ${text}';

	/// en: 'Delete'
	String get delete => 'Delete';

	/// en: 'Delete device "$name"? It will be kicked offline immediately.'
	String deleteConfirm({required Object name}) => 'Delete device "${name}"? It will be kicked offline immediately.';
}

// Path: sysProxySheet
class Translations$sysProxySheet$en {
	Translations$sysProxySheet$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Reading…'
	String get reading => 'Reading…';

	/// en: 'Unknown'
	String get unknown => 'Unknown';

	/// en: 'Kernel is not running (turn on the switch on the Home tab first)'
	String get kernelNotRunning => 'Kernel is not running (turn on the switch on the Home tab first)';

	/// en: 'Applied · $host:$port'
	String applied({required Object host, required Object port}) => 'Applied · ${host}:${port}';

	/// en: 'System proxy not set — $reason'
	String notSet({required Object reason}) => 'System proxy not set — ${reason}';

	/// en: 'Not effective (no system proxy pointing to $port)'
	String notEffective({required Object port}) => 'Not effective (no system proxy pointing to ${port})';

	/// en: 'Read failed: $err'
	String readFailed({required Object err}) => 'Read failed: ${err}';

	/// en: 'Failed to set: the system may have rejected the write (or another proxy app overwrote it)'
	String get setRejected => 'Failed to set: the system may have rejected the write (or another proxy app overwrote it)';

	/// en: 'Failed to turn off'
	String get disableFailed => 'Failed to turn off';

	/// en: 'Port must be between 1 and 65535'
	String get portRange => 'Port must be between 1 and 65535';

	/// en: 'Port changed to $value: disconnect and reconnect once so the kernel listens on the new port'
	String portChanged({required Object value}) => 'Port changed to ${value}: disconnect and reconnect once so the kernel listens on the new port';

	/// en: 'System proxy'
	String get title => 'System proxy';

	/// en: 'The system proxy address is fixed to $host (local loopback) and the port is the kernel mixed port.'
	String desc({required Object host}) => 'The system proxy address is fixed to ${host} (local loopback) and the port is the kernel mixed port.';

	/// en: 'This is exactly what you see in Windows Settings → Network & Internet → Proxy.'
	String get descWindows => 'This is exactly what you see in Windows Settings → Network & Internet → Proxy.';

	/// en: 'Set again'
	String get reset => 'Set again';

	/// en: 'Turn off system proxy'
	String get disable => 'Turn off system proxy';

	/// en: 'Diagnostics (is the UI reading the same values as the registry?)'
	String get diagnostics => 'Diagnostics (is the UI reading the same values as the registry?)';

	/// en: 'Mixed port'
	String get mixedPort => 'Mixed port';

	/// en: 'Apply'
	String get apply => 'Apply';
}

// Path: logScreen
class Translations$logScreen$en {
	Translations$logScreen$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Failed to read the app log: $e'
	String readAppFailed({required Object e}) => 'Failed to read the app log: ${e}';

	/// en: 'Failed to read the kernel log: $e'
	String readCoreFailed({required Object e}) => 'Failed to read the kernel log: ${e}';

	/// en: 'Copied (subscription URLs and other secrets are masked; the log file itself may still contain the raw address)'
	String get copied => 'Copied (subscription URLs and other secrets are masked; the log file itself may still contain the raw address)';

	/// en: 'Copy'
	String get copy => 'Copy';

	/// en: 'Refresh'
	String get refresh => 'Refresh';

	/// en: 'No content'
	String get empty => 'No content';
}

// Path: trayShell
class Translations$trayShell$en {
	Translations$trayShell$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Close window'
	String get closeTitle => 'Close window';

	/// en: 'Closing the window just puts Mclash in the tray — the kernel and system proxy keep working, and your network stays connected. · OK: minimize to the tray (to quit completely, right-click the tray icon → Quit) · Cancel: quit Mclash completely, stop the kernel and restore the system proxy (Your choice is remembered; next time you can use the tray icon directly)'
	String get closeBody => 'Closing the window just puts Mclash in the tray — the kernel and system proxy keep working, and your network stays connected.\n\n· OK: minimize to the tray (to quit completely, right-click the tray icon → Quit)\n· Cancel: quit Mclash completely, stop the kernel and restore the system proxy\n\n(Your choice is remembered; next time you can use the tray icon directly)';
}

// Path: ordersScreen
class Translations$ordersScreen$en {
	Translations$ordersScreen$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'My Orders'
	String get title => 'My Orders';

	/// en: 'Order information is incomplete. Pull down to refresh and try again.'
	String get orderInfoIncomplete => 'Order information is incomplete. Pull down to refresh and try again.';

	/// en: 'Payment channel information is incomplete. Please try again later.'
	String get payChannelIncomplete => 'Payment channel information is incomplete. Please try again later.';

	/// en: 'The server did not return a payment QR code or link. Please choose another payment method or try again later.'
	String get noQrPayload => 'The server did not return a payment QR code or link. Please choose another payment method or try again later.';

	/// en: 'Failed to start payment: ${err}'
	String payStartFailed({required Object err}) => 'Failed to start payment: ${err}';

	/// en: 'No payment method is available right now. Please try again later or contact support.'
	String get noPayMethod => 'No payment method is available right now. Please try again later or contact support.';

	/// en: 'Choose a payment method'
	String get choosePayMethod => 'Choose a payment method';

	/// en: 'Amount due ¥${amount}'
	String amountDue({required Object amount}) => 'Amount due ¥${amount}';

	/// en: '● Paid'
	String get paidLabel => '● Paid';

	/// en: '○ Unpaid'
	String get pendingLabel => '○ Unpaid';

	/// en: '✕ ${status}'
	String unknownStatus({required Object status}) => '✕ ${status}';

	/// en: 'Order No. ${orderNo}'
	String orderNoText({required Object orderNo}) => 'Order No. ${orderNo}';

	/// en: 'Created at ${createdAt}'
	String createdAtText({required Object createdAt}) => 'Created at ${createdAt}';

	/// en: 'Order canceled'
	String get orderCanceled => 'Order canceled';

	/// en: 'Cancel failed: ${err} (If the order has already been paid or canceled, pull down to refresh to see the latest status.)'
	String cancelFailed({required Object err}) => 'Cancel failed: ${err}\n(If the order has already been paid or canceled, pull down to refresh to see the latest status.)';

	/// en: 'Cancel order'
	String get cancelOrder => 'Cancel order';

	/// en: 'Continue payment'
	String get continuePay => 'Continue payment';
}

// Path: payment
class Translations$payment$en {
	Translations$payment$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Balance payment'
	String get balancePay => 'Balance payment';

	/// en: 'Scan to pay'
	String get qrPay => 'Scan to pay';

	/// en: 'Deducted from your account balance'
	String get deductFromBalance => 'Deducted from your account balance';

	/// en: 'The payment page has been opened in your browser'
	String get openedInBrowser => 'The payment page has been opened in your browser';

	/// en: 'Scan with Alipay or WeChat'
	String get scanWithAlipayWechat => 'Scan with Alipay or WeChat';

	/// en: 'Order No. ${orderNo}'
	String orderNoText({required Object orderNo}) => 'Order No. ${orderNo}';

	/// en: 'Payment failed: ${err}'
	String payFailed({required Object err}) => 'Payment failed: ${err}';

	/// en: 'No payment detected. You can continue later in "My Orders".'
	String get notDetected => 'No payment detected. You can continue later in "My Orders".';

	/// en: 'Charging…'
	String get charging => 'Charging…';

	/// en: 'Processing…'
	String get processing => 'Processing…';

	/// en: 'Waiting for payment…'
	String get waitingPay => 'Waiting for payment…';

	/// en: 'Could not open the payment page. Tap the button below to retry, or scan the QR code instead.'
	String get openPageFailed => 'Could not open the payment page. Tap the button below to retry, or scan the QR code instead.';

	/// en: 'Reopen payment page'
	String get reopenPayPage => 'Reopen payment page';

	/// en: 'Pay in browser'
	String get payInBrowser => 'Pay in browser';

	/// en: 'Open Alipay'
	String get openAlipay => 'Open Alipay';

	/// en: 'Cancel order'
	String get cancelOrder => 'Cancel order';

	/// en: 'Confirm payment'
	String get confirmPay => 'Confirm payment';

	/// en: 'Retry'
	String get retry => 'Retry';

	/// en: 'I have paid'
	String get paidAlready => 'I have paid';

	/// en: 'Alipay'
	String get channelAlipay => 'Alipay';

	/// en: 'Code Pay · Alipay'
	String get channelCodepayAlipay => 'Code Pay · Alipay';

	/// en: 'Code Pay · WeChat'
	String get channelCodepayWechat => 'Code Pay · WeChat';

	/// en: 'Code Pay'
	String get channelCodepay => 'Code Pay';

	/// en: 'WeChat Pay'
	String get channelWechat => 'WeChat Pay';

	/// en: 'USDT'
	String get channelUsdt => 'USDT';

	/// en: 'USDT · TRC20'
	String get channelUsdtTrc20 => 'USDT · TRC20';

	/// en: 'Payment'
	String get payFallback => 'Payment';

	/// en: 'Your login credential has expired (CSRF check failed). Pull down to refresh on the "Me" tab or sign in again, then retry.'
	String get errCsrf => 'Your login credential has expired (CSRF check failed).\nPull down to refresh on the "Me" tab or sign in again, then retry.';

	/// en: 'Alipay face-to-face payment has a per-transaction limit (¥1000 for this merchant), and this order exceeds it. Please use "Balance payment" or "Code Pay" instead, or contact support to raise the Alipay limit.'
	String get errAlipayLimit => 'Alipay face-to-face payment has a per-transaction limit (¥1000 for this merchant), and this order exceeds it.\nPlease use "Balance payment" or "Code Pay" instead, or contact support to raise the Alipay limit.';

	/// en: 'The Alipay app has not signed up for the matching payment product, so this channel is temporarily unavailable. Please use "Balance payment" or "Code Pay" instead, or contact support to enable it.'
	String get errNotSigned => 'The Alipay app has not signed up for the matching payment product, so this channel is temporarily unavailable.\nPlease use "Balance payment" or "Code Pay" instead, or contact support to enable it.';

	/// en: 'This order has been canceled or has expired (draft orders are valid for 30 minutes). Tap "Re-quote" to create a new order, then pay.'
	String get errOrderGone => 'This order has been canceled or has expired (draft orders are valid for 30 minutes).\nTap "Re-quote" to create a new order, then pay.';

	/// en: 'Network unreachable: ${err}'
	String errNetwork({required Object err}) => 'Network unreachable: ${err}';
}

// Path: planScreen
class Translations$planScreen$en {
	Translations$planScreen$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Recommended'
	String get recommended => 'Recommended';

	/// en: 'Devices'
	String get devices => 'Devices';

	/// en: 'Balance ¥${amount}'
	String balanceLabel({required Object amount}) => 'Balance ¥${amount}';

	/// en: ' (Insufficient, please top up first)'
	String get balanceInsufficient => ' (Insufficient, please top up first)';

	/// en: 'Total'
	String get total => 'Total';

	/// en: 'Pay Now'
	String get payNow => 'Pay Now';

	/// en: 'Retry'
	String get retry => 'Retry';

	/// en: 'Order or payment channel information is incomplete; payment cannot be started.'
	String get errIncompleteOrder => 'Order or payment channel information is incomplete; payment cannot be started.';

	/// en: 'Balance Pay'
	String get payBalance => 'Balance Pay';

	/// en: 'Alipay'
	String get payAlipay => 'Alipay';

	/// en: 'WeChat Pay'
	String get payWechat => 'WeChat Pay';

	/// en: 'Codepay'
	String get payCodepay => 'Codepay';

	/// en: 'Codepay · Alipay'
	String get payCodepayAlipay => 'Codepay · Alipay';

	/// en: 'Codepay · WeChat'
	String get payCodepayWechat => 'Codepay · WeChat';

	/// en: 'Epay · Alipay'
	String get payEpayAlipay => 'Epay · Alipay';

	/// en: 'Epay · WeChat'
	String get payEpayWechat => 'Epay · WeChat';

	/// en: 'USDT'
	String get payUsdt => 'USDT';

	/// en: 'USDT · TRC20'
	String get payUsdtTrc20 => 'USDT · TRC20';

	/// en: 'Stripe'
	String get payStripe => 'Stripe';

	/// en: 'PayPal'
	String get payPaypal => 'PayPal';

	/// en: 'Online Payment'
	String get payOnline => 'Online Payment';
}

// Path: authScreen
class Translations$authScreen$en {
	Translations$authScreen$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Save account info'
	String get saveAccountInfo => 'Save account info';

	/// en: 'Sign in automatically next time'
	String get autoLoginNextTime => 'Sign in automatically next time';

	/// en: 'You'll need to sign in again next time'
	String get needLoginNextTime => 'You\'ll need to sign in again next time';

	/// en: 'Please enter a valid email address'
	String get invalidEmail => 'Please enter a valid email address';

	/// en: 'Please enter a valid email address first'
	String get enterEmailFirst => 'Please enter a valid email address first';

	/// en: 'Please enter your password'
	String get passwordRequired => 'Please enter your password';

	/// en: 'Incorrect email or password'
	String get wrongCredentials => 'Incorrect email or password';

	/// en: 'Request rejected. Please try again later.'
	String get requestRejected => 'Request rejected. Please try again later.';

	/// en: 'Too many attempts. Please try again later.'
	String get tooFrequent => 'Too many attempts. Please try again later.';

	/// en: 'Login failed'
	String get loginFailed => 'Login failed';

	/// en: 'Username'
	String get username => 'Username';

	/// en: 'Confirm password'
	String get confirmPassword => 'Confirm password';

	/// en: 'Invite code'
	String get inviteCode => 'Invite code';

	/// en: 'Email verification code'
	String get emailCode => 'Email verification code';

	/// en: 'Get code'
	String get getCode => 'Get code';

	/// en: 'Register and log in'
	String get registerAndLogin => 'Register and log in';

	/// en: 'Username must be at least ${min} characters'
	String usernameMinLength({required Object min}) => 'Username must be at least ${min} characters';

	/// en: 'The passwords do not match'
	String get passwordMismatch => 'The passwords do not match';

	/// en: 'Please enter the email verification code'
	String get emailCodeRequired => 'Please enter the email verification code';

	/// en: 'Registration on this site requires an invite code'
	String get inviteCodeRequired => 'Registration on this site requires an invite code';

	/// en: 'Verification code sent. Please check your email.'
	String get codeSentCheckEmail => 'Verification code sent. Please check your email.';

	/// en: 'Registration successful. You are now logged in.'
	String get registerSuccess => 'Registration successful. You are now logged in.';

	/// en: 'At least ${min} characters, including both letters and digits'
	String passwordHint({required Object min}) => 'At least ${min} characters, including both letters and digits';

	/// en: 'Password must be at least ${min} characters'
	String passwordTooShort({required Object min}) => 'Password must be at least ${min} characters';

	/// en: 'Password must contain both letters and digits'
	String get passwordNeedsLetterAndDigit => 'Password must contain both letters and digits';

	/// en: 'Registered email'
	String get registeredEmail => 'Registered email';

	/// en: 'New password'
	String get newPassword => 'New password';

	/// en: 'Confirm new password'
	String get confirmNewPassword => 'Confirm new password';

	/// en: 'Reset password'
	String get resetPassword => 'Reset password';

	/// en: 'If this email is registered, a reset code has been sent (valid for 15 minutes).'
	String get resetCodeSent => 'If this email is registered, a reset code has been sent (valid for 15 minutes).';

	/// en: 'Password reset. Please log in with your new password.'
	String get resetSuccess => 'Password reset. Please log in with your new password.';

	/// en: 'Change password'
	String get changePasswordTitle => 'Change password';

	/// en: 'Current password'
	String get currentPassword => 'Current password';

	/// en: 'Save new password'
	String get saveNewPassword => 'Save new password';

	/// en: 'The new passwords do not match'
	String get newPasswordMismatch => 'The new passwords do not match';

	/// en: 'Password changed. Please log in again.'
	String get changePasswordSuccess => 'Password changed. Please log in again.';
}

// Path: updatePrompt
class Translations$updatePrompt$en {
	Translations$updatePrompt$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Checking for updates…'
	String get checking => 'Checking for updates…';

	/// en: 'Update check failed. Please check your network and try again.'
	String get checkFailed => 'Update check failed. Please check your network and try again.';

	/// en: 'You're on the latest version (${version}).'
	String alreadyLatest({required Object version}) => 'You\'re on the latest version (${version}).';

	/// en: 'New version ${version} is available'
	String newVersionFound({required Object version}) => 'New version ${version} is available';

	/// en: 'The installer has finished downloading in the background. Tap Update Now to complete the upgrade.'
	String get installerDownloaded => 'The installer has finished downloading in the background. Tap Update Now to complete the upgrade.';

	/// en: 'Tap Update Now to download and install it (you can keep using the app; the installer downloads in the background).'
	String get downloadInBackground => 'Tap Update Now to download and install it (you can keep using the app; the installer downloads in the background).';

	/// en: 'Later'
	String get later => 'Later';

	/// en: 'Update Now'
	String get updateNow => 'Update Now';

	/// en: 'The installer has not finished downloading yet. Tap OK to open the download page and manually download the installer that matches your device (version ${version}).'
	String installerNotReady({required Object version}) => 'The installer has not finished downloading yet.\n\nTap OK to open the download page and manually download the installer that matches your device (version ${version}).';
}

// Path: clearData
class Translations$clearData$en {
	Translations$clearData$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Login session'
	String get itemLoginSession => 'Login session';

	/// en: 'Subscription profiles (profiles/)'
	String get itemProfiles => 'Subscription profiles (profiles/)';

	/// en: 'App and core settings'
	String get itemSettings => 'App and core settings';

	/// en: 'Node latency cache'
	String get itemLatencyCache => 'Node latency cache';

	/// en: 'Runtime logs'
	String get itemLogs => 'Runtime logs';

	/// en: 'Routing data and temporary files'
	String get itemRoutingData => 'Routing data and temporary files';

	/// en: 'The following data saved on this device will be deleted (this cannot be undone): ${items} The account itself and any plan you purchased live on the server and are not affected; sign in again to restore your subscription. Data directory: ${dir} (Do this before uninstalling the app: only then will reinstalling start clean and ask you to sign in again)'
	String confirmBody({required Object items, required Object dir}) => 'The following data saved on this device will be deleted (this cannot be undone):\n\n${items}\n\nThe account itself and any plan you purchased live on the server and are not affected; sign in again to restore your subscription.\n\nData directory: ${dir}\n(Do this before uninstalling the app: only then will reinstalling start clean and ask you to sign in again)';

	/// en: 'Clear now? You will need to sign in again afterwards.'
	String get confirmAgain => 'Clear now? You will need to sign in again afterwards.';

	/// en: 'Cleared ${count} local data items (including the login session, so you will need to sign in again next time you open the app). You can now delete the app to finish uninstalling: · macOS: drag Mclash.app to the Trash (the data directory has been emptied: ${dir}) · Windows: uninstall Mclash from Control Panel and choose No when the wizard asks whether to keep your user data'
	String clearedNotice({required Object count, required Object dir}) => 'Cleared ${count} local data items (including the login session, so you will need to sign in again next time you open the app).\n\nYou can now delete the app to finish uninstalling:\n· macOS: drag Mclash.app to the Trash (the data directory has been emptied: ${dir})\n· Windows: uninstall Mclash from Control Panel and choose No when the wizard asks whether to keep your user data';

	/// en: 'Clear failed: ${error}'
	String clearFailed({required Object error}) => 'Clear failed: ${error}';
}

// Path: apiError
class Translations$apiError$en {
	Translations$apiError$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Request failed (HTTP ${status}); already tried ${domain}'
	String requestFailedHttp({required Object status, required Object domain}) => 'Request failed (HTTP ${status}); already tried ${domain}';

	/// en: 'Request failed: ${method} ${path} (tried ${count} domains)'
	String allDomainsFailed({required Object method, required Object path, required Object count}) => 'Request failed: ${method} ${path} (tried ${count} domains)';

	/// en: 'Request timed out (${seconds}s): ${method} ${path}'
	String requestTimeout({required Object seconds, required Object method, required Object path}) => 'Request timed out (${seconds}s): ${method} ${path}';

	/// en: 'Network unreachable: ${detail}'
	String networkUnreachable({required Object detail}) => 'Network unreachable: ${detail}';

	/// en: 'TLS handshake failed. Check your network connection or system time.'
	String get tlsHandshakeFailed => 'TLS handshake failed. Check your network connection or system time.';

	/// en: 'Connection failed: ${detail}'
	String connectionFailed({required Object detail}) => 'Connection failed: ${detail}';

	/// en: 'Request failed: ${error}'
	String requestError({required Object error}) => 'Request failed: ${error}';

	/// en: 'Reading the response timed out (${seconds}s): ${method} ${path}'
	String responseReadTimeout({required Object seconds, required Object method, required Object path}) => 'Reading the response timed out (${seconds}s): ${method} ${path}';

	/// en: 'Response is not JSON (HTTP ${status}): ${snippet}'
	String notJson({required Object status, required Object snippet}) => 'Response is not JSON (HTTP ${status}): ${snippet}';

	/// en: 'Unexpected response structure (HTTP ${status})'
	String badStructure({required Object status}) => 'Unexpected response structure (HTTP ${status})';

	/// en: 'Login failed (code ${code})'
	String loginFailed({required Object code}) => 'Login failed (code ${code})';

	/// en: 'Login response is missing data'
	String get loginMissingData => 'Login response is missing data';

	/// en: 'Login response is missing access_token'
	String get loginMissingToken => 'Login response is missing access_token';

	/// en: 'Registration failed (code ${code})'
	String registerFailed({required Object code}) => 'Registration failed (code ${code})';

	/// en: 'Registration response has no access_token - risk control may have been triggered, or the site is configured differently'
	String get registerMissingToken => 'Registration response has no access_token - risk control may have been triggered, or the site is configured differently';

	/// en: 'Request failed (code ${code})'
	String requestFailedCode({required Object code}) => 'Request failed (code ${code})';
}

// Path: subNotice
class Translations$subNotice$en {
	Translations$subNotice$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Subscription not found'
	String get titleNotFound => 'Subscription not found';

	/// en: 'Subscription expired'
	String get titleExpired => 'Subscription expired';

	/// en: 'Subscription inactive'
	String get titleInactive => 'Subscription inactive';

	/// en: 'Device limit exceeded'
	String get titleDeviceOverLimit => 'Device limit exceeded';

	/// en: 'Subscription unavailable'
	String get titleUnavailable => 'Subscription unavailable';

	/// en: '${emoji} ${title} (${reason})'
	String titleWithReason({required Object emoji, required Object title, required Object reason}) => '${emoji} ${title} (${reason})';

	/// en: 'Current devices ${used}/${limit}'
	String deviceUsedOfLimit({required Object used, required Object limit}) => 'Current devices ${used}/${limit}';

	/// en: 'Current devices ${used}'
	String deviceUsedOnly({required Object used}) => 'Current devices ${used}';

	/// en: 'Expires at ${expire}'
	String expireAt({required Object expire}) => 'Expires at ${expire}';

	/// en: '💬 Support: ${account}'
	String supportLine({required Object account}) => '💬 Support: ${account}';

	/// en: '📢 Website: ${url}'
	String siteLine({required Object url}) => '📢 Website: ${url}';
}

// Path: settingItems
class Translations$settingItems$en {
	Translations$settingItems$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Subscription auto-update interval'
	String get subscriptionAutoUpdateInterval => 'Subscription auto-update interval';

	/// en: 'Speed test method'
	String get speedTestMode => 'Speed test method';

	/// en: 'TCP speed test'
	String get speedTestModeTcp => 'TCP speed test';

	/// en: 'Kernel speed test'
	String get speedTestModeKernel => 'Kernel speed test';

	/// en: 'Time for one full HTTP request through this node (it is not a ping) Defaults to a plain http 204 empty response; using https adds a TLS handshake and a larger number'
	String get delayTestUrlTip => 'Time for one full HTTP request through this node (it is not a ping)\nDefaults to a plain http 204 empty response; using https adds a TLS handshake and a larger number';

	/// en: 'System proxy'
	String get systemProxy => 'System proxy';

	/// en: 'View / reset address and port'
	String get systemProxyTip => 'View / reset address and port';

	/// en: 'TUN mode'
	String get tunMode => 'TUN mode';

	/// en: 'off=system proxy only / auto=TUN+system proxy / force=TUN only On desktop, TUN requires administrator privileges (wintun on Windows / utun on macOS)'
	String get tunModeTip => 'off=system proxy only / auto=TUN+system proxy / force=TUN only\nOn desktop, TUN requires administrator privileges (wintun on Windows / utun on macOS)';

	/// en: 'overwrite On = the TUN settings on this page override the tun section of the profile Off = the profile's own tun configuration is used (the app does not interfere)'
	String get tunOverwriteTip => 'overwrite\nOn = the TUN settings on this page override the tun section of the profile\nOff = the profile\'s own tun configuration is used (the app does not interfere)';

	/// en: '${enable} (decided by TUN mode)'
	String tunEnableByTunMode({required Object enable}) => '${enable} (decided by TUN mode)';

	/// en: '30 minutes'
	String get interval30Minutes => '30 minutes';

	/// en: '1 hour'
	String get interval1Hour => '1 hour';

	/// en: '6 hours'
	String get interval6Hours => '6 hours';

	/// en: '12 hours'
	String get interval12Hours => '12 hours';

	/// en: '24 hours'
	String get interval24Hours => '24 hours';

	/// en: '3 days'
	String get interval3Days => '3 days';

	/// en: '7 days'
	String get interval7Days => '7 days';

	/// en: 'Never'
	String get intervalNever => 'Never';

	/// en: '${minutes} minutes'
	String intervalMinutes({required Object minutes}) => '${minutes} minutes';

	/// en: '${hours} hours'
	String intervalHours({required Object hours}) => '${hours} hours';

	/// en: '${days} days'
	String intervalDays({required Object days}) => '${days} days';
}

// Path: tunScreen
class Translations$tunScreen$en {
	Translations$tunScreen$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Off'
	String get modeOff => 'Off';

	/// en: 'Auto'
	String get modeAuto => 'Auto';

	/// en: 'Force'
	String get modeForce => 'Force';

	/// en: 'System proxy only: works for programs that honor the system proxy (browsers and so on); UDP/games are not proxied'
	String get modeOffDesc => 'System proxy only: works for programs that honor the system proxy (browsers and so on); UDP/games are not proxied';

	/// en: 'TUN + system proxy (belt and braces): all traffic goes through the virtual adapter, including UDP'
	String get modeAutoDesc => 'TUN + system proxy (belt and braces): all traffic goes through the virtual adapter, including UDP';

	/// en: 'TUN only: all traffic goes through the virtual adapter, the system proxy is left untouched'
	String get modeForceDesc => 'TUN only: all traffic goes through the virtual adapter, the system proxy is left untouched';

	/// en: 'Does not touch the system routing table; only sets a 127.0.0.1 proxy in the system. Only programs that honor the system proxy use it; UDP traffic and programs with their own proxy settings do not.'
	String get modeOffOptionDesc => 'Does not touch the system routing table; only sets a 127.0.0.1 proxy in the system. Only programs that honor the system proxy use it; UDP traffic and programs with their own proxy settings do not.';

	/// en: 'Creates a virtual adapter and takes over all traffic (including UDP and games); the system proxy is kept as a fallback. Recommended: it works globally and you are not left without network access if permissions are missing.'
	String get modeAutoOptionDesc => 'Creates a virtual adapter and takes over all traffic (including UDP and games); the system proxy is kept as a fallback. Recommended: it works globally and you are not left without network access if permissions are missing.';

	/// en: 'Uses only the virtual adapter and no longer changes the system proxy. All traffic (including UDP) goes through the tunnel; the "proxy" entry in the system stays as it is.'
	String get modeForceOptionDesc => 'Uses only the virtual adapter and no longer changes the system proxy. All traffic (including UDP) goes through the tunnel; the "proxy" entry in the system stays as it is.';

	/// en: 'The TUN virtual adapter requires administrator privileges (wintun on Windows / utun on macOS). Mclash is not running as administrator right now, so TUN will not take effect after enabling it (in "Auto" mode the system proxy still works as a fallback, so the network stays usable). OK = restart Mclash as administrator now (a UAC prompt will appear) Cancel = still save this choice (the system proxy is used automatically when TUN is unavailable)'
	String get adminRequiredDialog => 'The TUN virtual adapter requires administrator privileges (wintun on Windows / utun on macOS).\n\nMclash is not running as administrator right now, so TUN will not take effect after enabling it (in "Auto" mode the system proxy still works as a fallback, so the network stays usable).\n\nOK = restart Mclash as administrator now (a UAC prompt will appear)\nCancel = still save this choice (the system proxy is used automatically when TUN is unavailable)';

	/// en: 'Restart failed: ${message}'
	String relaunchFailed({required Object message}) => 'Restart failed: ${message}';

	/// en: 'Failed to switch TUN mode: ${message} The previous settings have been restored.'
	String switchFailed({required Object message}) => 'Failed to switch TUN mode: ${message}\nThe previous settings have been restored.';

	/// en: 'Set to "Off": system proxy only'
	String get setOffSnack => 'Set to "Off": system proxy only';

	/// en: 'Set to "${mode}", ${effect}'
	String setModeSnack({required Object mode, required Object effect}) => 'Set to "${mode}", ${effect}';

	/// en: 'reconnected and now active'
	String get effectReconnected => 'reconnected and now active';

	/// en: 'active after connecting'
	String get effectAfterConnect => 'active after connecting';

	/// en: 'TUN Virtual Adapter'
	String get sheetTitle => 'TUN Virtual Adapter';

	/// en: 'Advanced parameters (Core Settings → TUN)'
	String get advancedTitle => 'Advanced parameters (Core Settings → TUN)';

	/// en: 'Adapter address / stack / MTU / auto route / DNS hijack / overwrite'
	String get advancedSubtitle => 'Adapter address / stack / MTU / auto route / DNS hijack / overwrite';

	/// en: 'TUN requires administrator privileges; the current privileges are sufficient (run as administrator on Windows / as root on macOS)'
	String get adminOk => 'TUN requires administrator privileges; the current privileges are sufficient (run as administrator on Windows / as root on macOS)';

	/// en: 'TUN requires administrator privileges: Mclash is not running as administrator, so TUN will not take effect after selecting "Auto/Force" ("Auto" falls back to the system proxy, so the network stays usable)'
	String get adminMissing => 'TUN requires administrator privileges: Mclash is not running as administrator, so TUN will not take effect after selecting "Auto/Force" ("Auto" falls back to the system proxy, so the network stays usable)';
}

// Path: main.tray
class Translations$main$tray$en {
	Translations$main$tray$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Open'
	String get menuOpen => 'Open';

	/// en: 'Exit'
	String get menuExit => 'Exit';
}

/// The flat map containing all translations for locale <en>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on Translations {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'BackupAndSyncWebdavScreen.webdavServerUrl' => 'Server Url',
			'BackupAndSyncWebdavScreen.webdavRequired' => 'Can not be empty',
			'BackupAndSyncWebdavScreen.webdavLoginFailed' => 'Login failed:',
			'BackupAndSyncWebdavScreen.webdavListFailed' => 'Failed to get file list:',
			'LaunchFailedScreen.invalidProcess' => 'The app failed to start [Invalid process name], please reinstall the app to a separate directory',
			'LaunchFailedScreen.invalidProfile' => 'The app failed to start [Failed to access the profile], please reinstall the app',
			'LaunchFailedScreen.invalidVersion' => 'The app failed to start [Invalid version], please reinstall the app',
			'LaunchFailedScreen.systemVersionLow' => 'The app failed to start [system version too low]',
			'LaunchFailedScreen.invalidInstallPath' => 'The installation path is invalid, please reinstall it to a valid path',
			'PerAppAndroidScreen.title' => 'Per-App Proxy',
			'PerAppAndroidScreen.whiteListMode' => 'Whitelist Mode',
			'PerAppAndroidScreen.whiteListModeTip' => 'When enabled: only the apps that have been checked are proxies; when not enabled: only the apps that are not checked are proxies',
			'UserAgreementScreen.privacyFirst' => 'Your Privacy Comes First',
			'UserAgreementScreen.agreeAndContinue' => 'Accept & Continue',
			'VersionUpdateScreen.versionReady' => ({required Object p}) => 'The new version[${p}] is ready',
			'VersionUpdateScreen.update' => 'Restart To Update',
			'VersionUpdateScreen.cancel' => 'Not Now',
			'NetCheckScreen.enterDomain' => 'Please enter a domain',
			'NetCheckScreen.checking' => 'Checking...',
			'NetCheckScreen.aQueryFailed' => ({required Object p}) => 'A query failed: ${p}',
			'NetCheckScreen.aaaaQueryFailed' => ({required Object p}) => 'AAAA query failed: ${p}',
			'NetCheckScreen.success' => 'Success',
			'NetCheckScreen.failed' => 'Failed',
			'NetCheckScreen.suspectedPollution' => 'Suspected DNS poisoning',
			'NetCheckScreen.domainLabel' => 'Domain',
			'NetCheckScreen.checkButton' => 'Check',
			'NetCheckScreen.dnsSection' => '1. DNS Query',
			'NetCheckScreen.directHttpSection' => '2. HTTP (via TUN, enable TUN first)',
			'NetCheckScreen.proxyHttpSection' => ({required Object p}) => '3. HTTP (via Proxy, port: ${p})',
			'NetCheckScreen.tunNotEnabled' => 'TUN is not enabled',
			'NetCheckScreen.routeTableSection' => '4. Route Table',
			'loginScreen.login' => 'Login',
			'loginScreen.register' => 'Register Account',
			'loginScreen.forgotPassword' => 'Forgot Password',
			'loginScreen.provider' => 'Provider',
			'loginScreen.providerName' => '${_root.loginScreen.provider} Code/Alias/URL',
			'loginScreen.account' => 'Account',
			'loginScreen.email' => 'Email',
			'loginScreen.password' => 'Password',
			'main.tray.menuOpen' => 'Open',
			'main.tray.menuExit' => 'Exit',
			'meta.enable' => 'Enable',
			'meta.disable' => 'Disable',
			'meta.open' => 'Open',
			'meta.close' => 'Close',
			'meta.quit' => 'Quit',
			'meta.add' => 'Add',
			'meta.remove' => 'Remove',
			'meta.removeConfirm' => 'Are you sure to delete?',
			'meta.edit' => 'Edit',
			'meta.view' => 'View',
			'meta.remark' => 'Remark',
			'meta.byDefault' => 'Default',
			'meta.more' => 'More',
			'meta.tips' => 'Info',
			'meta.selectAll' => 'Select All',
			'meta.copy' => 'Copy',
			'meta.paste' => 'Paste',
			'meta.cut' => 'Cut',
			'meta.save' => 'Save',
			'meta.ok' => 'Ok',
			'meta.cancel' => 'Cancel',
			'meta.faq' => 'FAQ',
			'meta.doc' => 'Document',
			'meta.htmlTools' => 'HTML Toolset',
			'meta.download' => 'Download',
			'meta.loading' => 'Loading...',
			'meta.days' => 'Days',
			'meta.hours' => 'Hours',
			'meta.minutes' => 'Minutes',
			'meta.seconds' => 'Seconds',
			'meta.milliseconds' => 'Milliseconds',
			'meta.search' => 'Search',
			'meta.searchNodeHint' => 'Filter nodes (name or protocol)',
			'meta.connect' => 'Connect',
			'meta.disconnect' => 'Disconnect',
			'meta.connected' => 'Connected',
			'meta.disconnected' => 'Disconnected',
			'meta.connecting' => 'Connecting',
			'meta.connectTimeout' => 'Connect Timeout',
			'meta.timeout' => 'Timeout',
			'meta.latencyTest' => 'Latency Checks',
			'meta.networkCheck' => 'Network Check',
			'meta.language' => 'Language',
			'meta.next' => 'Next',
			'meta.done' => 'Done',
			'meta.apply' => 'Apply',
			'meta.refresh' => 'Refresh',
			'meta.update' => 'Update',
			'meta.updateInterval' => 'Update interval',
			'meta.updateFailed' => ({required Object p}) => 'Update failed:${p}',
			'meta.updateInterval5mTips' => 'Minimum: 5m',
			'meta.updateIntervalPreferByProfile' => 'Prefer provider settings',
			'meta.none' => 'None',
			'meta.reset' => 'Reset',
			'meta.authentication' => 'Authentication',
			'meta.user' => 'User',
			'meta.account' => 'Account',
			'meta.password' => 'Password',
			'meta.decryptPassword' => 'Decrypt Password',
			'meta.required' => 'Required',
			'meta.go' => 'Continue',
			'meta.other' => 'Other',
			'meta.dns' => 'DNS',
			'meta.url' => 'URL',
			'meta.urlInvalid' => 'Invalid URL',
			'meta.copyUrl' => 'Copy Link',
			'meta.openUrl' => 'Open Link',
			'meta.coreSettingTips' => 'Note: After modifying the configuration, you need to reconnect to take effect',
			'meta.overwrite' => 'Overwrite',
			'meta.overwriteAppend' => 'Append Overwrite',
			'meta.overwriteTips' => 'Original Profile <- Custom Overwrite <- App Overwrite',
			'meta.noOverwrite' => 'Do not overwrite',
			'meta.diversionTemplates' => 'Diversion Template',
			'meta.ruleProviders' => 'Rule Providers',
			'meta.ruleTemplates' => 'Rule Templates',
			'meta.proxyGroupsTemplates' => 'Proxy Group Template',
			'meta.proxyGroups' => 'Proxy Group',
			'meta.proxyNodeList' => 'Proxy Node list',
			'meta.proxyNodeFailure' => ({required Object p}) => 'The following proxy nodes have expired and have been automatically removed: ${p}',
			'meta.externalController' => 'External Controller',
			'meta.secret' => 'Secret',
			'meta.tcpConcurrent' => 'TCP Concurrent Handshake',
			'meta.globalClientFingerprint' => 'TLS Global Fingerprint',
			'meta.allowLanAccess' => 'LAN device access',
			'meta.mixedPort' => 'Mixed Proxy Port',
			'meta.logLevel' => 'Log Level',
			'meta.findProcessMode' => 'Find Process Mode',
			'meta.tcpkeepAliveInterval' => 'TCP Keep-alive Interval',
			'meta.delayTestUrl' => 'Delay Test URL',
			'meta.delayTestTimeout' => 'Delay Test Timeout(ms)',
			'meta.tun' => 'TUN',
			'meta.ntp' => 'NTP',
			'meta.tls' => 'TLS',
			'meta.geoDownloadByProxy' => 'Downloading Geo RuleSet by proxy',
			'meta.geoRulesetTips' => 'Geosite/Geoip will be converted into the corresponding RuleSet',
			'meta.sniffer' => 'Sniffer',
			'meta.userAgent' => 'UserAgent',
			'meta.launchAtStartup' => 'Launch at Startup',
			'meta.launchAtStartupRunAsAdmin' => 'Please restart Mclash as administrator',
			'meta.tunModeRunAsAdmin' => 'The TUN mode requires system administrator permissions, please restart the app as an administrator',
			'meta.portableMode' => 'Portable Mode',
			'meta.portableModeDisableTips' => 'If you need to exit portable mode, please exit [mclash] and manually delete the [portable] folder in the same directory as [mclash.exe]',
			'meta.autoConnectAfterLaunch' => 'Auto Connection after Launch',
			'meta.autoConnectAtBoot' => 'Auto Connection after System Startup',
			'meta.autoConnectAtBootTips' => 'System support is required; some systems may also require [auto-start] to be enabled.',
			'meta.hideAfterLaunch' => 'Hide window after startup',
			'meta.autoSetSystemProxy' => 'Auto Set System Proxy when Connected',
			'meta.bypassSystemProxy' => 'Domain names that are allowed to bypass the system proxy',
			'meta.excludeFromRecent' => 'Hide from [Recent Tasks]',
			'meta.wakeLock' => 'Wake Lock',
			'meta.hideDockIcon' => 'Hide Dock Icon',
			'meta.showTrayTraffic' => 'Show traffic info in tray',
			'meta.website' => 'Website',
			'meta.rule' => 'Rule',
			'meta.global' => 'Global',
			'meta.direct' => 'Direct',
			'meta.qrcode' => 'QR Code',
			'meta.qrcodeTooLong' => 'The text is too long to display',
			'meta.qrcodeShare' => 'Share QR Code',
			'meta.qrcodeScan' => 'Scan QR Code',
			'meta.qrcodeScanResult' => 'Scan Result',
			'meta.backupAndSync' => 'Backup and Sync',
			'meta.export' => 'Export',
			'meta.send' => 'Send',
			'meta.sendConfirm' => 'Confirm to send?',
			'meta.log' => 'Log',
			'meta.coreLog' => 'Core Log',
			'meta.appLog' => 'App log',
			'meta.core' => 'Core',
			'meta.help' => 'Help',
			'meta.tutorial' => 'Tutorial',
			'meta.board' => 'Board',
			'meta.boardOnline' => 'Use Online Board',
			'meta.boardOnlineUrl' => 'Online Board URL',
			'meta.boardLocalPort' => 'Local Board Port',
			'meta.alwayOnVPN' => 'Always-on Connection',
			'meta.disableFontScaler' => 'Disable Font scaling(Restart takes effect)',
			'meta.autoOrientation' => 'Rotate with the screen',
			'meta.restartTakesEffect' => 'Restart takes effect',
			'meta.reconnectTakesEffect' => 'Reconnect takes effect',
			'meta.runtimeProfile' => 'Runtime Profile',
			'meta.willCompleteAfterRebootInstall' => 'Please restart your device to complete the system extension installation',
			'meta.requestNeedsUserApproval' => '1. Please [Allow] Mclash to install system extensions in [System Settings]-[Privacy and Security]\n2. [System Settings]-[General]-[Login Items Extensions]-[Network Extension] enable [mclashServiceSE]\nreconnect after completion',
			'meta.FullDiskAccessPermissionRequired' => 'Please enable mclashServiceSE permission in [System Settings]-[Privacy and Security]-[Full Disk Access] and reconnect.',
			'meta.proxy' => 'Proxy',
			'meta.theme' => 'Theme',
			'meta.tvMode' => 'TV Mode',
			'meta.autoUpdate' => 'Auto Update',
			'meta.updateChannel' => 'Auto Update Channel',
			'meta.hasNewVersion' => ({required Object p}) => 'Update Version ${p}',
			'meta.autoDownloadPkg' => 'Auto Download Update Packages',
			'meta.devOptions' => 'Developer Options',
			'meta.about' => 'About',
			'meta.name' => 'Name',
			'meta.version' => 'Version',
			'meta.sort' => 'Reorder',
			'meta.share' => 'Share',
			'meta.importFromClipboard' => 'Import From Clipboard',
			'meta.exportToClipboard' => 'Export to Clipboard',
			'meta.server' => 'Server',
			'meta.port' => 'Port',
			'meta.donate' => 'Donate',
			'meta.setting' => 'Settings',
			'meta.settingCore' => 'Core Settings',
			'meta.settingApp' => 'App Settings',
			'meta.coreOverwrite' => 'Core Overwrite',
			'meta.iCloud' => 'iCloud',
			'meta.webdav' => 'Webdav',
			'meta.lanSync' => 'LAN Sync',
			'meta.lanSyncNotQuitTips' => 'Do not exit this interface before synchronization is completed',
			'meta.deviceNoSpace' => 'Not enough disk space',
			'meta.hideSystemApp' => 'Hide System Apps',
			'meta.hideAppIcon' => 'Hide App Icons',
			'meta.openDir' => 'Open File Directory',
			'meta.type' => 'Type',
			'meta.fileNotExist' => ({required Object p}) => 'File does not exist:${p}',
			'meta.buyProfile' => 'Buy Profile',
			'meta.myProfiles' => 'My Profiles',
			'meta.profileEdit' => 'Profile Edit',
			'meta.profileNeedActive' => 'Please set this profile as the current profile first, then start/reconnect',
			'meta.profileUrlOrContent' => ({required Object p}) => '${p} Profile Link',
			'meta.tabHome' => 'Home',
			'meta.tabNodes' => 'Nodes',
			'meta.tabPlans' => 'Plans',
			'meta.tabMe' => 'Me',
			'permission.camera' => 'Camera',
			'permission.screen' => 'Screen Recording',
			'permission.appQuery' => 'Get Application List',
			'permission.request' => ({required Object p}) => 'Turn on [${p}] permission',
			'permission.requestNeed' => ({required Object p}) => 'Please Turn on [${p}] permission',
			'tls.certificate' => 'Certificate',
			'tls.privateKey' => 'Private Key',
			'tls.customTrustCert' => 'Custom Certifactes',
			'tun.stack' => 'Network stack',
			'tun.inet4Address' => 'IPv4 Gateway Address',
			'tun.dnsHijack' => 'DNS Hijack',
			'tun.strictRoute' => 'Strict Route',
			'tun.tunDefaultRoute' => 'Default Route',
			'tun.icmpForward' => 'ICMP Forwarding',
			'tun.allowBypass' => 'Allow Apps to Bypass VPN',
			'tun.appendHttpProxy' => 'Append HTTP Proxy to VPN',
			'tun.bypassHttpProxyDomain' => 'Domains allowed to bypass HTTP proxy',
			'dns.listen' => 'Listen',
			'dns.fakeIp' => 'fake-ip',
			'dns.fallback' => 'Fallback',
			'dns.preferH3' => 'Prefer DoH H3',
			'dns.useHosts' => 'Use Hosts',
			'dns.useSystemHosts' => 'Use System Hosts',
			'dns.enhancedMode' => 'Enhanced Mode',
			'dns.fakeIPFilterMode' => '${_root.dns.fakeIp} Filter Mode',
			'dns.fakeIPFilter' => 'fake-ip Filter',
			'dns.respectRules' => 'Respect Rules',
			'dns.nameServer' => 'NameServer',
			'dns.defaultNameServer' => '${_root.meta.byDefault} ${_root.dns.nameServer}',
			'dns.proxyNameServer' => '${_root.meta.proxy} ${_root.dns.nameServer}',
			'dns.directNameServer' => '${_root.meta.direct} ${_root.dns.nameServer}',
			'dns.fallbackNameServer' => '${_root.dns.fallback} ${_root.dns.nameServer}',
			'dns.fallbackGeoIp' => '${_root.dns.fallback} GeoIp',
			'dns.fallbackGeoIpCode' => '${_root.dns.fallback} GeoIpCode',
			'sniffer.overrideDest' => 'Override',
			'profilePatchMode.currentSelected' => 'Current Selected',
			'profilePatchMode.overwrite' => 'Built-in Overwrite',
			'profilePatchMode.noOverwrite' => 'Built-in - no Overwrite',
			'sendOrReceiveNotMatch' => ({required Object p}) => 'Please use [${p}]',
			'targetConnectFailed' => ({required Object p}) => 'Failed to connect to [${p}]. Please make sure the devices are in the same LAN',
			'edgeRuntimeNotInstalled' => 'The current device has not installed the Edge WebView2 runtime, so the page cannot be displayed. Please download and install the Edge WebView2 runtime (x64), restart the App and try again.',
			'locales.en' => 'English',
			'locales.zh-CN' => '简体中文',
			'locales.zh-TW' => '繁體中文',
			'locales.ja' => '日本語',
			'locales.ko' => '한국어',
			'locales.ar' => 'عربي',
			'locales.ru' => 'Русский',
			'locales.fa' => 'فارسی',
			'locales.es' => 'Español',
			'countries.HK' => 'Hong Kong',
			'countries.TW' => 'Taiwan',
			'countries.MO' => 'Macau',
			'countries.CN' => 'China',
			'countries.JP' => 'Japan',
			'countries.KR' => 'South Korea',
			'countries.SG' => 'Singapore',
			'countries.MY' => 'Malaysia',
			'countries.TH' => 'Thailand',
			'countries.VN' => 'Vietnam',
			'countries.PH' => 'Philippines',
			'countries.ID' => 'Indonesia',
			'countries.KH' => 'Cambodia',
			'countries.US' => 'United States',
			'countries.CA' => 'Canada',
			'countries.MX' => 'Mexico',
			'countries.GB' => 'United Kingdom',
			'countries.DE' => 'Germany',
			'countries.FR' => 'France',
			'countries.NL' => 'Netherlands',
			'countries.RU' => 'Russia',
			'countries.IT' => 'Italy',
			'countries.ES' => 'Spain',
			'countries.CH' => 'Switzerland',
			'countries.SE' => 'Sweden',
			'countries.NO' => 'Norway',
			'countries.FI' => 'Finland',
			'countries.DK' => 'Denmark',
			'countries.PL' => 'Poland',
			'countries.AT' => 'Austria',
			'countries.IE' => 'Ireland',
			'countries.UA' => 'Ukraine',
			'countries.TR' => 'Turkey',
			'countries.PT' => 'Portugal',
			'countries.CZ' => 'Czechia',
			'countries.RO' => 'Romania',
			'countries.BE' => 'Belgium',
			'countries.GR' => 'Greece',
			'countries.HU' => 'Hungary',
			'countries.IL' => 'Israel',
			'countries.AE' => 'United Arab Emirates',
			'countries.SA' => 'Saudi Arabia',
			'countries.EG' => 'Egypt',
			'countries.ZA' => 'South Africa',
			'countries.NG' => 'Nigeria',
			'countries.AU' => 'Australia',
			'countries.NZ' => 'New Zealand',
			'countries.BR' => 'Brazil',
			'countries.AR' => 'Argentina',
			'countries.CL' => 'Chile',
			'countries.CO' => 'Colombia',
			'countries.IN' => 'India',
			'countries.PK' => 'Pakistan',
			'countries.XX' => 'Other',
			'meScreen.accountBalance' => 'Balance',
			'meScreen.expireAt' => 'Expires',
			'meScreen.remainingDays' => 'Days Left',
			'meScreen.deviceCount' => 'Devices',
			'meScreen.myOrders' => 'My Orders',
			'meScreen.deviceManagement' => 'Device Management',
			'meScreen.changePassword' => 'Change Password',
			'meScreen.clearLocalData' => 'Clear local data (before uninstall)',
			'meScreen.profileManagementDev' => 'Profile management (developer)',
			'meScreen.tunAdapter' => 'TUN virtual adapter',
			'meScreen.checkUpdate' => 'Check for updates',
			'meScreen.retry' => 'Retry',
			'meScreen.loadFailed' => 'Failed to load account info: the sign-in may have expired or the network is unreachable.\nTap Refresh at the top right to retry; if it keeps failing, sign in again.',
			'meScreen.logoutConfirm' => 'Sign out?',
			'meScreen.boardNoKernel' => 'The dashboard shows the kernel\'s live data (connection, traffic, rule hits).\n\nThe kernel is not running, so the dashboard would be an empty shell.\nTap OK to open it anyway, or Cancel to connect on the Home tab first.',
			'meScreen.boardOpened' => 'Opened the dashboard in your browser; switch nodes or rules there and the app follows within ~5 seconds.',
			'homeScreen.expiresOn' => ({required Object date}) => 'Expires ${date}',
			'homeScreen.devicesText' => ({required Object text}) => 'Devices ${text}',
			'homeScreen.upgrade' => 'Upgrade',
			'homeScreen.quickCountries' => 'Quick country filter',
			'homeScreen.nodeCount' => ({required Object count}) => '${count} nodes',
			'homeScreen.autoBestTip' => 'Pick the lowest-latency available node across all countries (auto mode)',
			'homeScreen.autoBest' => 'Auto best',
			'homeScreen.pickCountryTip' => ({required Object label}) => 'Auto-select the lowest-latency available node in "${label}" and pin it',
			'homeScreen.autoNoBetter' => 'Already in auto mode (no better node found)',
			'homeScreen.switchedBest' => ({required Object name}) => 'Switched to the best node: ${name}',
			'homeScreen.switchedCountry' => ({required Object country, required Object node, required Object ms}) => 'Switched to the fastest ${country} node: ${node}${ms}',
			'homeScreen.filterCountryFailed' => ({required Object country, required Object err}) => 'Filtered by ${country}; switching failed: ${err}',
			'homeScreen.deviceFullCount' => ({required Object used, required Object limit}) => 'Current devices ${used}/${limit}\n\n',
			'homeScreen.deviceFullUpgradeHint' => 'Upgrading the device limit restores the connection immediately (recommended); you can also delete unused devices to free a slot.',
			'homeScreen.later' => 'Later',
			'homeScreen.upgradeDeviceCount' => 'Upgrade device limit',
			'homeScreen.cannotConnect' => 'Cannot connect',
			'homeScreen.freshnessNever' => 'Not synced yet · tap to refresh',
			'homeScreen.freshnessJustNow' => 'Updated just now · tap Manage devices',
			'homeScreen.freshnessMinutes' => ({required Object minutes}) => '${minutes} min ago · tap Manage devices',
			'homeScreen.freshnessStale' => ({required Object minutes}) => '${minutes} min ago · tap to refresh',
			'homeScreen.subscriptionAutoSync' => 'Auto subscription sync',
			'homeScreen.connecting' => 'Connecting…',
			'homeScreen.disconnecting' => 'Disconnecting…',
			'homeScreen.tapToDisconnect' => 'Tap the switch to disconnect',
			'homeScreen.tapToConnect' => 'Tap the switch to connect',
			'homeScreen.currentNode' => 'Current node',
			'homeScreen.noNodeSelected' => 'No node selected',
			'homeScreen.switchAction' => 'Switch',
			'homeScreen.realtimeSpeed' => 'Real-time speed',
			'homeScreen.totalTraffic' => 'Total traffic',
			'homeScreen.subSyncedNotReady' => 'Subscription downloaded, but the profile is not ready yet. Please try again shortly.',
			'homeScreen.noPlan' => 'This account has no available plan yet. Please purchase one first.',
			'homeScreen.loginExpired' => 'Your sign-in has expired. Please sign in again.',
			'homeScreen.syncingWait' => 'Syncing subscription, please wait.',
			'homeScreen.syncFailedNetwork' => ({required Object message}) => 'Subscription sync failed: ${message}\nCheck your network and try again.',
			'homeScreen.syncFailed' => 'Subscription sync failed, please try again later.',
			'homeScreen.resetProxy' => 'Reset',
			'homeScreen.latencySuffix' => ({required Object ms}) => ' (${ms}ms)',
			'nodesScreen.updatedCount' => ({required Object count}) => 'Subscription updated: ${count} nodes',
			'nodesScreen.updateFailed' => ({required Object message}) => 'Update failed: ${message}',
			'nodesScreen.updateFailedNetwork' => 'Update failed, please check your network',
			'nodesScreen.testDone' => ({required Object ok, required Object fail}) => 'Speed test done: ${ok} reachable, ${fail} unreachable (may be offline)',
			'nodesScreen.switchedTo' => ({required Object name}) => 'Switched to ${name}',
			'nodesScreen.switchFailed' => ({required Object message}) => 'Switch failed: ${message}\n(Node switching needs a running kernel; turn on the switch on the Home tab first.)',
			'nodesScreen.selectedAfterConnect' => ({required Object name}) => 'Selected ${name} (takes effect after connecting)',
			'nodesScreen.title' => 'Nodes',
			'nodesScreen.searchNode' => 'Search nodes',
			'nodesScreen.sortByLatency' => 'Sort by latency',
			'nodesScreen.updateSubscription' => 'Update subscription',
			'nodesScreen.viewByGroup' => 'View by proxy group',
			'nodesScreen.testAll' => 'Test all',
			'nodesScreen.searchHint' => 'Search node / country / protocol',
			'nodesScreen.emptyNoNodes' => 'No nodes available yet.\nSubscriptions sync automatically; if you just signed in, wait a moment or tap reload below.',
			'nodesScreen.emptyNoMatch' => 'No matching nodes.',
			'nodesScreen.reload' => 'Reload',
			'nodesScreen.currentInUse' => 'Current (in use)',
			'nodesScreen.current' => 'Current',
			'nodesScreen.notTested' => 'Not measured (kernel reload pending)',
			'nodesScreen.timeout' => 'Timeout',
			'nodesScreen.clear' => 'Clear',
			'nodesScreen.selectNode' => 'Select node',
			'nodesScreen.emptyNoKernel' => 'No nodes available yet.\nPlease turn on the connection switch on the Home tab first.',
			'nodesScreen.openFullList' => 'Open the full node list (search / speed test / groups)',
			'nodeAuto.kernelStateUnavailable' => 'Node status is temporarily unavailable from the kernel; will retry automatically.',
			'nodeAuto.backToFixedNode' => ({required Object fixed}) => 'Back to the pinned node: ${fixed}',
			'nodeAuto.noUsableNodePickOne' => 'No usable node found. Please pick one manually in the node list.',
			'nodeAuto.noUsableNodeTryOne' => 'No usable node found. Please try picking one in the node list.',
			'nodeAuto.autoConnectedBest' => ({required Object bestNode, required Object bestMs}) => 'Auto-connected to the best node: ${bestNode} (${bestMs} ms)',
			'nodeAuto.currentNodeUnreachable' => 'The current node cannot reach the internet; switching automatically…',
			'nodeAuto.autoSwitchedToUsable' => ({required Object target}) => 'Automatically switched to a usable node: ${target}',
			'nodeAuto.newNodesReloading' => ({required Object missing}) => '${missing} new node(s) in the subscription are not in the kernel yet; reloading…',
			'nodeAuto.kernelReloadedRetest' => 'The kernel reloaded with the new subscription; run the speed test again.',
			'accountBlock.quotaFull' => ({required Object used, required Object limit}) => 'Device slots are full (${used}/${limit}): this device is still within the licensed range and can connect normally. To add another device, upgrade the device limit or remove unused ones.',
			'accountBlock.banFallback' => 'Your account has been disabled and can no longer be used.',
			'accountBlock.titleExpired' => 'Plan expired',
			'accountBlock.titleDeviceFull' => 'Device limit reached',
			'accountBlock.titleAccountDisabled' => 'Account disabled',
			'accountBlock.titlePlanDisabled' => 'Plan disabled',
			'accountBlock.titleNoPlan' => 'No plan yet',
			'accountBlock.titleDeviceRemoved' => 'This device was removed',
			'accountBlock.titleServiceUnavailable' => 'Service temporarily unavailable',
			'accountBlock.textExpired' => 'Your plan has expired. Purchase a plan to keep using global nodes.',
			'accountBlock.textDeviceFull' => ({required Object used, required Object limit}) => 'The server has determined this device exceeds the plan device limit (${used}/${limit}), so it cannot connect for now. Remove unused devices in Me - Device Management, or upgrade to a plan with more devices.',
			'accountBlock.textAccountDisabled' => 'Your account has been disabled. Please contact support if you have questions.',
			'accountBlock.textPlanDisabled' => 'Your plan has been disabled or is in an abnormal state, so you cannot connect. Please contact support if you have questions.',
			'accountBlock.textNoPlan' => 'You have not purchased a plan yet. Purchase one to use global nodes.',
			'accountBlock.textDeviceRemoved' => 'This device was removed and signed out. Please sign in again.',
			'accountBlock.textServiceUnavailable' => 'The service is temporarily unavailable. Please try again later; if it persists, take a screenshot and contact support.',
			'accountBlock.remainingDays' => ({required Object days}) => '${days} days left',
			'accountBlock.deviceUsage' => ({required Object used, required Object limit}) => 'Devices ${used}/${limit}',
			'entitlementMsg.tamperedTitle' => 'Authorization state abnormal',
			'entitlementMsg.tamperedClock' => 'A system clock rollback (or local authorization data tampering) was detected. Please go online to complete a verification before connecting.',
			'entitlementMsg.tamperedLocal' => 'Local authorization data is corrupted or was modified. Please go online to complete a verification before connecting.',
			'entitlementMsg.needVerifyTitle' => 'Online verification required',
			'entitlementMsg.needVerifyFirst' => 'Cannot confirm your plan status: please connect to the network and sign in, then complete one verification before connecting.',
			'entitlementMsg.needVerifyRetry' => 'Cannot confirm your plan status. Please go online and try again.',
			'entitlementMsg.verifyFailedTitle' => 'Cannot verify plan status',
			'entitlementMsg.verifyFailedText' => 'The verification grace period has passed and the server is unreachable. Check your network and try again (if you just renewed, sign in again).',
			'entitlementMsg.restrictedTitle' => 'Account restricted',
			'entitlementMsg.restrictedFallback' => 'Your account or plan has been disabled, so you cannot connect.',
			'entitlementMsg.expiredTitle' => 'Plan expired',
			'entitlementMsg.expiredText' => ({required Object date}) => 'Your plan expired on ${date}. The local subscription profile has been cleared. Renew and sign in again to restore it.',
			'devicesScreen.title' => 'Device Management',
			'devicesScreen.currentPlan' => 'Current plan',
			'devicesScreen.devicesText' => ({required Object text}) => 'Devices ${text}',
			'devicesScreen.upgradeTitle' => 'Upgrade devices / extend time',
			'devicesScreen.upgradeSubtitle' => 'Add devices and days together; one price, one payment',
			'devicesScreen.addDevices' => 'Add devices',
			'devicesScreen.noAddDevices' => 'No change',
			'devicesScreen.addDevicesCount' => ({required Object n}) => '+${n} devices',
			'devicesScreen.addDays' => 'Add days',
			'devicesScreen.noExtend' => 'No extension',
			'devicesScreen.addDaysCount' => ({required Object n, required Object months}) => '+${n} days (${months} months)',
			'devicesScreen.priceFailed' => 'Failed to get the price',
			'devicesScreen.amountDue' => ({required Object amount}) => 'Total ¥${amount}',
			'devicesScreen.requote' => 'Recalculate',
			'devicesScreen.goPay' => 'Pay now',
			'devicesScreen.afterUpgrade' => 'After upgrade: ',
			'devicesScreen.afterLimit' => ({required Object limit}) => 'device limit ${limit}',
			'devicesScreen.afterExpire' => ({required Object date}) => 'expires ${date}',
			'devicesScreen.pickSomething' => 'Please add at least some devices or days',
			'devicesScreen.daysOnlyUnsupported' => 'The panel does not support "extend time only" yet: please set "Add devices" to 1 or more and try again (or contact support to enable it).',
			'devicesScreen.paramsRejected' => 'Parameters rejected: please pick the device count and days again.',
			'devicesScreen.subscriptionExpired' => 'The subscription has expired, so it cannot be upgraded. Please renew or purchase a plan first.',
			'devicesScreen.orderIncomplete' => 'Order information is incomplete. Tap "Recalculate" and try again.',
			'devicesScreen.orderRegenerated' => 'The previous order expired; a new one was created with the same settings.',
			'devicesScreen.payChannelIncomplete' => 'Order or payment channel information is incomplete. Please recalculate and try again.',
			'devicesScreen.noQrCode' => 'The server did not return a payment QR code / link. Please pick another payment method or try later.',
			'devicesScreen.payStartFailed' => ({required Object err}) => 'Failed to start payment: ${err}',
			'devicesScreen.payCancelled' => 'Payment cancelled; the draft order has been cleaned up.',
			'devicesScreen.balancePay' => 'Balance',
			'devicesScreen.noPayMethod' => 'No payment method is available right now. Please try later or contact support.',
			'devicesScreen.balanceInsufficient' => ({required Object balance, required Object amount}) => 'Insufficient balance (¥${balance}, need ¥${amount}).\nTop up first?',
			'devicesScreen.choosePayMethod' => 'Choose a payment method',
			'devicesScreen.balanceText' => ({required Object balance}) => 'Balance ¥${balance}',
			'devicesScreen.balanceShort' => ({required Object balance}) => 'Balance ¥${balance} (insufficient, please top up)',
			'devicesScreen.unknownDevice' => 'Unknown device',
			'devicesScreen.online' => '● Online',
			'devicesScreen.offline' => '○ Offline',
			'devicesScreen.lastActive' => ({required Object text}) => 'Last active ${text}',
			'devicesScreen.delete' => 'Delete',
			'devicesScreen.deleteConfirm' => ({required Object name}) => 'Delete device "${name}"? It will be kicked offline immediately.',
			'sysProxySheet.reading' => 'Reading…',
			'sysProxySheet.unknown' => 'Unknown',
			'sysProxySheet.kernelNotRunning' => 'Kernel is not running (turn on the switch on the Home tab first)',
			'sysProxySheet.applied' => ({required Object host, required Object port}) => 'Applied · ${host}:${port}',
			'sysProxySheet.notSet' => ({required Object reason}) => 'System proxy not set — ${reason}',
			'sysProxySheet.notEffective' => ({required Object port}) => 'Not effective (no system proxy pointing to ${port})',
			'sysProxySheet.readFailed' => ({required Object err}) => 'Read failed: ${err}',
			'sysProxySheet.setRejected' => 'Failed to set: the system may have rejected the write (or another proxy app overwrote it)',
			'sysProxySheet.disableFailed' => 'Failed to turn off',
			'sysProxySheet.portRange' => 'Port must be between 1 and 65535',
			'sysProxySheet.portChanged' => ({required Object value}) => 'Port changed to ${value}: disconnect and reconnect once so the kernel listens on the new port',
			'sysProxySheet.title' => 'System proxy',
			'sysProxySheet.desc' => ({required Object host}) => 'The system proxy address is fixed to ${host} (local loopback) and the port is the kernel mixed port.',
			'sysProxySheet.descWindows' => 'This is exactly what you see in Windows Settings → Network & Internet → Proxy.',
			'sysProxySheet.reset' => 'Set again',
			'sysProxySheet.disable' => 'Turn off system proxy',
			'sysProxySheet.diagnostics' => 'Diagnostics (is the UI reading the same values as the registry?)',
			'sysProxySheet.mixedPort' => 'Mixed port',
			'sysProxySheet.apply' => 'Apply',
			'logScreen.readAppFailed' => ({required Object e}) => 'Failed to read the app log: ${e}',
			'logScreen.readCoreFailed' => ({required Object e}) => 'Failed to read the kernel log: ${e}',
			'logScreen.copied' => 'Copied (subscription URLs and other secrets are masked; the log file itself may still contain the raw address)',
			'logScreen.copy' => 'Copy',
			_ => null,
		} ?? switch (path) {
			'logScreen.refresh' => 'Refresh',
			'logScreen.empty' => 'No content',
			'trayShell.closeTitle' => 'Close window',
			'trayShell.closeBody' => 'Closing the window just puts Mclash in the tray — the kernel and system proxy keep working, and your network stays connected.\n\n· OK: minimize to the tray (to quit completely, right-click the tray icon → Quit)\n· Cancel: quit Mclash completely, stop the kernel and restore the system proxy\n\n(Your choice is remembered; next time you can use the tray icon directly)',
			'ordersScreen.title' => 'My Orders',
			'ordersScreen.orderInfoIncomplete' => 'Order information is incomplete. Pull down to refresh and try again.',
			'ordersScreen.payChannelIncomplete' => 'Payment channel information is incomplete. Please try again later.',
			'ordersScreen.noQrPayload' => 'The server did not return a payment QR code or link. Please choose another payment method or try again later.',
			'ordersScreen.payStartFailed' => ({required Object err}) => 'Failed to start payment: ${err}',
			'ordersScreen.noPayMethod' => 'No payment method is available right now. Please try again later or contact support.',
			'ordersScreen.choosePayMethod' => 'Choose a payment method',
			'ordersScreen.amountDue' => ({required Object amount}) => 'Amount due ¥${amount}',
			'ordersScreen.paidLabel' => '● Paid',
			'ordersScreen.pendingLabel' => '○ Unpaid',
			'ordersScreen.unknownStatus' => ({required Object status}) => '✕ ${status}',
			'ordersScreen.orderNoText' => ({required Object orderNo}) => 'Order No. ${orderNo}',
			'ordersScreen.createdAtText' => ({required Object createdAt}) => 'Created at ${createdAt}',
			'ordersScreen.orderCanceled' => 'Order canceled',
			'ordersScreen.cancelFailed' => ({required Object err}) => 'Cancel failed: ${err}\n(If the order has already been paid or canceled, pull down to refresh to see the latest status.)',
			'ordersScreen.cancelOrder' => 'Cancel order',
			'ordersScreen.continuePay' => 'Continue payment',
			'payment.balancePay' => 'Balance payment',
			'payment.qrPay' => 'Scan to pay',
			'payment.deductFromBalance' => 'Deducted from your account balance',
			'payment.openedInBrowser' => 'The payment page has been opened in your browser',
			'payment.scanWithAlipayWechat' => 'Scan with Alipay or WeChat',
			'payment.orderNoText' => ({required Object orderNo}) => 'Order No. ${orderNo}',
			'payment.payFailed' => ({required Object err}) => 'Payment failed: ${err}',
			'payment.notDetected' => 'No payment detected. You can continue later in "My Orders".',
			'payment.charging' => 'Charging…',
			'payment.processing' => 'Processing…',
			'payment.waitingPay' => 'Waiting for payment…',
			'payment.openPageFailed' => 'Could not open the payment page. Tap the button below to retry, or scan the QR code instead.',
			'payment.reopenPayPage' => 'Reopen payment page',
			'payment.payInBrowser' => 'Pay in browser',
			'payment.openAlipay' => 'Open Alipay',
			'payment.cancelOrder' => 'Cancel order',
			'payment.confirmPay' => 'Confirm payment',
			'payment.retry' => 'Retry',
			'payment.paidAlready' => 'I have paid',
			'payment.channelAlipay' => 'Alipay',
			'payment.channelCodepayAlipay' => 'Code Pay · Alipay',
			'payment.channelCodepayWechat' => 'Code Pay · WeChat',
			'payment.channelCodepay' => 'Code Pay',
			'payment.channelWechat' => 'WeChat Pay',
			'payment.channelUsdt' => 'USDT',
			'payment.channelUsdtTrc20' => 'USDT · TRC20',
			'payment.payFallback' => 'Payment',
			'payment.errCsrf' => 'Your login credential has expired (CSRF check failed).\nPull down to refresh on the "Me" tab or sign in again, then retry.',
			'payment.errAlipayLimit' => 'Alipay face-to-face payment has a per-transaction limit (¥1000 for this merchant), and this order exceeds it.\nPlease use "Balance payment" or "Code Pay" instead, or contact support to raise the Alipay limit.',
			'payment.errNotSigned' => 'The Alipay app has not signed up for the matching payment product, so this channel is temporarily unavailable.\nPlease use "Balance payment" or "Code Pay" instead, or contact support to enable it.',
			'payment.errOrderGone' => 'This order has been canceled or has expired (draft orders are valid for 30 minutes).\nTap "Re-quote" to create a new order, then pay.',
			'payment.errNetwork' => ({required Object err}) => 'Network unreachable: ${err}',
			'planScreen.recommended' => 'Recommended',
			'planScreen.devices' => 'Devices',
			'planScreen.balanceLabel' => ({required Object amount}) => 'Balance ¥${amount}',
			'planScreen.balanceInsufficient' => ' (Insufficient, please top up first)',
			'planScreen.total' => 'Total',
			'planScreen.payNow' => 'Pay Now',
			'planScreen.retry' => 'Retry',
			'planScreen.errIncompleteOrder' => 'Order or payment channel information is incomplete; payment cannot be started.',
			'planScreen.payBalance' => 'Balance Pay',
			'planScreen.payAlipay' => 'Alipay',
			'planScreen.payWechat' => 'WeChat Pay',
			'planScreen.payCodepay' => 'Codepay',
			'planScreen.payCodepayAlipay' => 'Codepay · Alipay',
			'planScreen.payCodepayWechat' => 'Codepay · WeChat',
			'planScreen.payEpayAlipay' => 'Epay · Alipay',
			'planScreen.payEpayWechat' => 'Epay · WeChat',
			'planScreen.payUsdt' => 'USDT',
			'planScreen.payUsdtTrc20' => 'USDT · TRC20',
			'planScreen.payStripe' => 'Stripe',
			'planScreen.payPaypal' => 'PayPal',
			'planScreen.payOnline' => 'Online Payment',
			'authScreen.saveAccountInfo' => 'Save account info',
			'authScreen.autoLoginNextTime' => 'Sign in automatically next time',
			'authScreen.needLoginNextTime' => 'You\'ll need to sign in again next time',
			'authScreen.invalidEmail' => 'Please enter a valid email address',
			'authScreen.enterEmailFirst' => 'Please enter a valid email address first',
			'authScreen.passwordRequired' => 'Please enter your password',
			'authScreen.wrongCredentials' => 'Incorrect email or password',
			'authScreen.requestRejected' => 'Request rejected. Please try again later.',
			'authScreen.tooFrequent' => 'Too many attempts. Please try again later.',
			'authScreen.loginFailed' => 'Login failed',
			'authScreen.username' => 'Username',
			'authScreen.confirmPassword' => 'Confirm password',
			'authScreen.inviteCode' => 'Invite code',
			'authScreen.emailCode' => 'Email verification code',
			'authScreen.getCode' => 'Get code',
			'authScreen.registerAndLogin' => 'Register and log in',
			'authScreen.usernameMinLength' => ({required Object min}) => 'Username must be at least ${min} characters',
			'authScreen.passwordMismatch' => 'The passwords do not match',
			'authScreen.emailCodeRequired' => 'Please enter the email verification code',
			'authScreen.inviteCodeRequired' => 'Registration on this site requires an invite code',
			'authScreen.codeSentCheckEmail' => 'Verification code sent. Please check your email.',
			'authScreen.registerSuccess' => 'Registration successful. You are now logged in.',
			'authScreen.passwordHint' => ({required Object min}) => 'At least ${min} characters, including both letters and digits',
			'authScreen.passwordTooShort' => ({required Object min}) => 'Password must be at least ${min} characters',
			'authScreen.passwordNeedsLetterAndDigit' => 'Password must contain both letters and digits',
			'authScreen.registeredEmail' => 'Registered email',
			'authScreen.newPassword' => 'New password',
			'authScreen.confirmNewPassword' => 'Confirm new password',
			'authScreen.resetPassword' => 'Reset password',
			'authScreen.resetCodeSent' => 'If this email is registered, a reset code has been sent (valid for 15 minutes).',
			'authScreen.resetSuccess' => 'Password reset. Please log in with your new password.',
			'authScreen.changePasswordTitle' => 'Change password',
			'authScreen.currentPassword' => 'Current password',
			'authScreen.saveNewPassword' => 'Save new password',
			'authScreen.newPasswordMismatch' => 'The new passwords do not match',
			'authScreen.changePasswordSuccess' => 'Password changed. Please log in again.',
			'updatePrompt.checking' => 'Checking for updates…',
			'updatePrompt.checkFailed' => 'Update check failed. Please check your network and try again.',
			'updatePrompt.alreadyLatest' => ({required Object version}) => 'You\'re on the latest version (${version}).',
			'updatePrompt.newVersionFound' => ({required Object version}) => 'New version ${version} is available',
			'updatePrompt.installerDownloaded' => 'The installer has finished downloading in the background. Tap Update Now to complete the upgrade.',
			'updatePrompt.downloadInBackground' => 'Tap Update Now to download and install it (you can keep using the app; the installer downloads in the background).',
			'updatePrompt.later' => 'Later',
			'updatePrompt.updateNow' => 'Update Now',
			'updatePrompt.installerNotReady' => ({required Object version}) => 'The installer has not finished downloading yet.\n\nTap OK to open the download page and manually download the installer that matches your device (version ${version}).',
			'clearData.itemLoginSession' => 'Login session',
			'clearData.itemProfiles' => 'Subscription profiles (profiles/)',
			'clearData.itemSettings' => 'App and core settings',
			'clearData.itemLatencyCache' => 'Node latency cache',
			'clearData.itemLogs' => 'Runtime logs',
			'clearData.itemRoutingData' => 'Routing data and temporary files',
			'clearData.confirmBody' => ({required Object items, required Object dir}) => 'The following data saved on this device will be deleted (this cannot be undone):\n\n${items}\n\nThe account itself and any plan you purchased live on the server and are not affected; sign in again to restore your subscription.\n\nData directory: ${dir}\n(Do this before uninstalling the app: only then will reinstalling start clean and ask you to sign in again)',
			'clearData.confirmAgain' => 'Clear now? You will need to sign in again afterwards.',
			'clearData.clearedNotice' => ({required Object count, required Object dir}) => 'Cleared ${count} local data items (including the login session, so you will need to sign in again next time you open the app).\n\nYou can now delete the app to finish uninstalling:\n· macOS: drag Mclash.app to the Trash (the data directory has been emptied: ${dir})\n· Windows: uninstall Mclash from Control Panel and choose No when the wizard asks whether to keep your user data',
			'clearData.clearFailed' => ({required Object error}) => 'Clear failed: ${error}',
			'apiError.requestFailedHttp' => ({required Object status, required Object domain}) => 'Request failed (HTTP ${status}); already tried ${domain}',
			'apiError.allDomainsFailed' => ({required Object method, required Object path, required Object count}) => 'Request failed: ${method} ${path} (tried ${count} domains)',
			'apiError.requestTimeout' => ({required Object seconds, required Object method, required Object path}) => 'Request timed out (${seconds}s): ${method} ${path}',
			'apiError.networkUnreachable' => ({required Object detail}) => 'Network unreachable: ${detail}',
			'apiError.tlsHandshakeFailed' => 'TLS handshake failed. Check your network connection or system time.',
			'apiError.connectionFailed' => ({required Object detail}) => 'Connection failed: ${detail}',
			'apiError.requestError' => ({required Object error}) => 'Request failed: ${error}',
			'apiError.responseReadTimeout' => ({required Object seconds, required Object method, required Object path}) => 'Reading the response timed out (${seconds}s): ${method} ${path}',
			'apiError.notJson' => ({required Object status, required Object snippet}) => 'Response is not JSON (HTTP ${status}): ${snippet}',
			'apiError.badStructure' => ({required Object status}) => 'Unexpected response structure (HTTP ${status})',
			'apiError.loginFailed' => ({required Object code}) => 'Login failed (code ${code})',
			'apiError.loginMissingData' => 'Login response is missing data',
			'apiError.loginMissingToken' => 'Login response is missing access_token',
			'apiError.registerFailed' => ({required Object code}) => 'Registration failed (code ${code})',
			'apiError.registerMissingToken' => 'Registration response has no access_token - risk control may have been triggered, or the site is configured differently',
			'apiError.requestFailedCode' => ({required Object code}) => 'Request failed (code ${code})',
			'subNotice.titleNotFound' => 'Subscription not found',
			'subNotice.titleExpired' => 'Subscription expired',
			'subNotice.titleInactive' => 'Subscription inactive',
			'subNotice.titleDeviceOverLimit' => 'Device limit exceeded',
			'subNotice.titleUnavailable' => 'Subscription unavailable',
			'subNotice.titleWithReason' => ({required Object emoji, required Object title, required Object reason}) => '${emoji} ${title} (${reason})',
			'subNotice.deviceUsedOfLimit' => ({required Object used, required Object limit}) => 'Current devices ${used}/${limit}',
			'subNotice.deviceUsedOnly' => ({required Object used}) => 'Current devices ${used}',
			'subNotice.expireAt' => ({required Object expire}) => 'Expires at ${expire}',
			'subNotice.supportLine' => ({required Object account}) => '💬 Support: ${account}',
			'subNotice.siteLine' => ({required Object url}) => '📢 Website: ${url}',
			'settingItems.subscriptionAutoUpdateInterval' => 'Subscription auto-update interval',
			'settingItems.speedTestMode' => 'Speed test method',
			'settingItems.speedTestModeTcp' => 'TCP speed test',
			'settingItems.speedTestModeKernel' => 'Kernel speed test',
			'settingItems.delayTestUrlTip' => 'Time for one full HTTP request through this node (it is not a ping)\nDefaults to a plain http 204 empty response; using https adds a TLS handshake and a larger number',
			'settingItems.systemProxy' => 'System proxy',
			'settingItems.systemProxyTip' => 'View / reset address and port',
			'settingItems.tunMode' => 'TUN mode',
			'settingItems.tunModeTip' => 'off=system proxy only / auto=TUN+system proxy / force=TUN only\nOn desktop, TUN requires administrator privileges (wintun on Windows / utun on macOS)',
			'settingItems.tunOverwriteTip' => 'overwrite\nOn = the TUN settings on this page override the tun section of the profile\nOff = the profile\'s own tun configuration is used (the app does not interfere)',
			'settingItems.tunEnableByTunMode' => ({required Object enable}) => '${enable} (decided by TUN mode)',
			'settingItems.interval30Minutes' => '30 minutes',
			'settingItems.interval1Hour' => '1 hour',
			'settingItems.interval6Hours' => '6 hours',
			'settingItems.interval12Hours' => '12 hours',
			'settingItems.interval24Hours' => '24 hours',
			'settingItems.interval3Days' => '3 days',
			'settingItems.interval7Days' => '7 days',
			'settingItems.intervalNever' => 'Never',
			'settingItems.intervalMinutes' => ({required Object minutes}) => '${minutes} minutes',
			'settingItems.intervalHours' => ({required Object hours}) => '${hours} hours',
			'settingItems.intervalDays' => ({required Object days}) => '${days} days',
			'tunScreen.modeOff' => 'Off',
			'tunScreen.modeAuto' => 'Auto',
			'tunScreen.modeForce' => 'Force',
			'tunScreen.modeOffDesc' => 'System proxy only: works for programs that honor the system proxy (browsers and so on); UDP/games are not proxied',
			'tunScreen.modeAutoDesc' => 'TUN + system proxy (belt and braces): all traffic goes through the virtual adapter, including UDP',
			'tunScreen.modeForceDesc' => 'TUN only: all traffic goes through the virtual adapter, the system proxy is left untouched',
			'tunScreen.modeOffOptionDesc' => 'Does not touch the system routing table; only sets a 127.0.0.1 proxy in the system. Only programs that honor the system proxy use it; UDP traffic and programs with their own proxy settings do not.',
			'tunScreen.modeAutoOptionDesc' => 'Creates a virtual adapter and takes over all traffic (including UDP and games); the system proxy is kept as a fallback. Recommended: it works globally and you are not left without network access if permissions are missing.',
			'tunScreen.modeForceOptionDesc' => 'Uses only the virtual adapter and no longer changes the system proxy. All traffic (including UDP) goes through the tunnel; the "proxy" entry in the system stays as it is.',
			'tunScreen.adminRequiredDialog' => 'The TUN virtual adapter requires administrator privileges (wintun on Windows / utun on macOS).\n\nMclash is not running as administrator right now, so TUN will not take effect after enabling it (in "Auto" mode the system proxy still works as a fallback, so the network stays usable).\n\nOK = restart Mclash as administrator now (a UAC prompt will appear)\nCancel = still save this choice (the system proxy is used automatically when TUN is unavailable)',
			'tunScreen.relaunchFailed' => ({required Object message}) => 'Restart failed: ${message}',
			'tunScreen.switchFailed' => ({required Object message}) => 'Failed to switch TUN mode: ${message}\nThe previous settings have been restored.',
			'tunScreen.setOffSnack' => 'Set to "Off": system proxy only',
			'tunScreen.setModeSnack' => ({required Object mode, required Object effect}) => 'Set to "${mode}", ${effect}',
			'tunScreen.effectReconnected' => 'reconnected and now active',
			'tunScreen.effectAfterConnect' => 'active after connecting',
			'tunScreen.sheetTitle' => 'TUN Virtual Adapter',
			'tunScreen.advancedTitle' => 'Advanced parameters (Core Settings → TUN)',
			'tunScreen.advancedSubtitle' => 'Adapter address / stack / MTU / auto route / DNS hijack / overwrite',
			'tunScreen.adminOk' => 'TUN requires administrator privileges; the current privileges are sufficient (run as administrator on Windows / as root on macOS)',
			'tunScreen.adminMissing' => 'TUN requires administrator privileges: Mclash is not running as administrator, so TUN will not take effect after selecting "Auto/Force" ("Auto" falls back to the system proxy, so the network stays usable)',
			_ => null,
		};
	}
}
