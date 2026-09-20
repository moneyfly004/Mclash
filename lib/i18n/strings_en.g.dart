// coverage:ignore-file
// ignore_for_file: type=lint, unused_import

part of 'strings.g.dart';

typedef TranslationsEn = Translations; // ignore: unused_element
class Translations with BaseTranslations<AppLocale, Translations> {
	static Translations of(BuildContext context) => InheritedLocaleData.of<AppLocale, Translations>(context).translations;

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

	final TranslationMetadata<AppLocale, Translations> _meta;
	@override TranslationMetadata<AppLocale, Translations> get $meta => _meta;

	dynamic operator[](String key) => _meta.getTranslation(key);

	late final Translations _root = this; // ignore: unused_field

	Translations $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => Translations(meta: meta ?? this.$meta);

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

	String sendOrReceiveNotMatch({required Object p}) => 'Please use [${p}]';

	String targetConnectFailed({required Object p}) => 'Failed to connect to [${p}]. Please make sure the devices are in the same LAN';

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
}

class Translations$BackupAndSyncWebdavScreen$en {
	Translations$BackupAndSyncWebdavScreen$en._(this._root);

	final Translations _root; // ignore: unused_field


	String get webdavServerUrl => 'Server Url';

	String get webdavRequired => 'Can not be empty';

	String get webdavLoginFailed => 'Login failed:';

	String get webdavListFailed => 'Failed to get file list:';
}

class Translations$LaunchFailedScreen$en {
	Translations$LaunchFailedScreen$en._(this._root);

	final Translations _root; // ignore: unused_field


	String get invalidProcess => 'The app failed to start [Invalid process name], please reinstall the app to a separate directory';

	String get invalidProfile => 'The app failed to start [Failed to access the profile], please reinstall the app';

	String get invalidVersion => 'The app failed to start [Invalid version], please reinstall the app';

	String get systemVersionLow => 'The app failed to start [system version too low]';

	String get invalidInstallPath => 'The installation path is invalid, please reinstall it to a valid path';
}

class Translations$PerAppAndroidScreen$en {
	Translations$PerAppAndroidScreen$en._(this._root);

	final Translations _root; // ignore: unused_field


	String get title => 'Per-App Proxy';

	String get whiteListMode => 'Whitelist Mode';

	String get whiteListModeTip => 'When enabled: only the apps that have been checked are proxies; when not enabled: only the apps that are not checked are proxies';
}

class Translations$UserAgreementScreen$en {
	Translations$UserAgreementScreen$en._(this._root);

	final Translations _root; // ignore: unused_field


	String get privacyFirst => 'Your Privacy Comes First';

	String get agreeAndContinue => 'Accept & Continue';
}

class Translations$VersionUpdateScreen$en {
	Translations$VersionUpdateScreen$en._(this._root);

	final Translations _root; // ignore: unused_field


	String versionReady({required Object p}) => 'The new version[${p}] is ready';

	String get update => 'Restart To Update';

	String get cancel => 'Not Now';
}

class Translations$NetCheckScreen$en {
	Translations$NetCheckScreen$en._(this._root);

	final Translations _root; // ignore: unused_field


	String get enterDomain => 'Please enter a domain';

	String get checking => 'Checking...';

	String aQueryFailed({required Object p}) => 'A query failed: ${p}';

	String aaaaQueryFailed({required Object p}) => 'AAAA query failed: ${p}';

	String get success => 'Success';

	String get failed => 'Failed';

	String get suspectedPollution => 'Suspected DNS poisoning';

	String get domainLabel => 'Domain';

	String get checkButton => 'Check';

	String get dnsSection => '1. DNS Query';

	String get directHttpSection => '2. HTTP (via TUN, enable TUN first)';

	String proxyHttpSection({required Object p}) => '3. HTTP (via Proxy, port: ${p})';

	String get tunNotEnabled => 'TUN is not enabled';

	String get routeTableSection => '4. Route Table';
}

class Translations$loginScreen$en {
	Translations$loginScreen$en._(this._root);

	final Translations _root; // ignore: unused_field


	String get login => 'Login';

	String get register => 'Register Account';

	String get forgotPassword => 'Forgot Password';

	String get provider => 'Provider';

	String get providerName => '${_root.loginScreen.provider} Code/Alias/URL';

	String get account => 'Account';

	String get email => 'Email';

	String get password => 'Password';
}

class Translations$main$en {
	Translations$main$en._(this._root);

	final Translations _root; // ignore: unused_field

	late final Translations$main$tray$en tray = Translations$main$tray$en._(_root);
}

class Translations$meta$en {
	Translations$meta$en._(this._root);

	final Translations _root; // ignore: unused_field


	String get enable => 'Enable';

	String get disable => 'Disable';

	String get open => 'Open';

	String get close => 'Close';

	String get quit => 'Quit';

	String get add => 'Add';

	String get remove => 'Remove';

	String get removeConfirm => 'Are you sure to delete?';

	String get edit => 'Edit';

	String get view => 'View';

	String get remark => 'Remark';

	String get byDefault => 'Default';

	String get more => 'More';

	String get tips => 'Info';

	String get selectAll => 'Select All';

	String get copy => 'Copy';

	String get paste => 'Paste';

	String get cut => 'Cut';

	String get save => 'Save';

	String get ok => 'Ok';

	String get cancel => 'Cancel';

	String get faq => 'FAQ';

	String get doc => 'Document';

	String get htmlTools => 'HTML Toolset';

	String get download => 'Download';

	String get loading => 'Loading...';

	String get days => 'Days';

	String get hours => 'Hours';

	String get minutes => 'Minutes';

	String get seconds => 'Seconds';

	String get milliseconds => 'Milliseconds';

	String get search => 'Search';

	String get searchNodeHint => 'Filter nodes (name or protocol)';

	String get connect => 'Connect';

	String get disconnect => 'Disconnect';

	String get connected => 'Connected';

	String get disconnected => 'Disconnected';

	String get connecting => 'Connecting';

	String get connectTimeout => 'Connect Timeout';

	String get timeout => 'Timeout';

	String get latencyTest => 'Latency Checks';

	String get networkCheck => 'Network Check';

	String get language => 'Language';

	String get next => 'Next';

	String get done => 'Done';

	String get apply => 'Apply';

	String get refresh => 'Refresh';

	String get update => 'Update';

	String get updateInterval => 'Update interval';

	String updateFailed({required Object p}) => 'Update failed:${p}';

	String get updateInterval5mTips => 'Minimum: 5m';

	String get updateIntervalPreferByProfile => 'Prefer provider settings';

	String get none => 'None';

	String get reset => 'Reset';

	String get authentication => 'Authentication';

	String get user => 'User';

	String get account => 'Account';

	String get password => 'Password';

	String get decryptPassword => 'Decrypt Password';

	String get required => 'Required';

	String get go => 'Continue';

	String get other => 'Other';

	String get dns => 'DNS';

	String get url => 'URL';

	String get urlInvalid => 'Invalid URL';

	String get copyUrl => 'Copy Link';

	String get openUrl => 'Open Link';

	String get coreSettingTips => 'Note: After modifying the configuration, you need to reconnect to take effect';

	String get overwrite => 'Overwrite';

	String get overwriteAppend => 'Append Overwrite';

	String get overwriteTips => 'Original Profile <- Custom Overwrite <- App Overwrite';

	String get noOverwrite => 'Do not overwrite';

	String get diversionTemplates => 'Diversion Template';

	String get ruleProviders => 'Rule Providers';

	String get ruleTemplates => 'Rule Templates';

	String get proxyGroupsTemplates => 'Proxy Group Template';

	String get proxyGroups => 'Proxy Group';

	String get proxyNodeList => 'Proxy Node list';

	String proxyNodeFailure({required Object p}) => 'The following proxy nodes have expired and have been automatically removed: ${p}';

	String get externalController => 'External Controller';

	String get secret => 'Secret';

	String get tcpConcurrent => 'TCP Concurrent Handshake';

	String get globalClientFingerprint => 'TLS Global Fingerprint';

	String get allowLanAccess => 'LAN device access';

	String get mixedPort => 'Mixed Proxy Port';

	String get logLevel => 'Log Level';

	String get findProcessMode => 'Find Process Mode';

	String get tcpkeepAliveInterval => 'TCP Keep-alive Interval';

	String get delayTestUrl => 'Delay Test URL';

	String get delayTestTimeout => 'Delay Test Timeout(ms)';

	String get tun => 'TUN';

	String get ntp => 'NTP';

	String get tls => 'TLS';

	String get geoDownloadByProxy => 'Downloading Geo RuleSet by proxy';

	String get geoRulesetTips => 'Geosite/Geoip will be converted into the corresponding RuleSet';

	String get sniffer => 'Sniffer';

	String get userAgent => 'UserAgent';

	String get launchAtStartup => 'Launch at Startup';

	String get launchAtStartupRunAsAdmin => 'Please restart Mclash as administrator';

	String get tunModeRunAsAdmin => 'The TUN mode requires system administrator permissions, please restart the app as an administrator';

	String get portableMode => 'Portable Mode';

	String get portableModeDisableTips => 'If you need to exit portable mode, please exit [mclash] and manually delete the [portable] folder in the same directory as [mclash.exe]';

	String get autoConnectAfterLaunch => 'Auto Connection after Launch';

	String get autoConnectAtBoot => 'Auto Connection after System Startup';

	String get autoConnectAtBootTips => 'System support is required; some systems may also require [auto-start] to be enabled.';

	String get hideAfterLaunch => 'Hide window after startup';

	String get autoSetSystemProxy => 'Auto Set System Proxy when Connected';

	String get bypassSystemProxy => 'Domain names that are allowed to bypass the system proxy';

	String get excludeFromRecent => 'Hide from [Recent Tasks]';

	String get wakeLock => 'Wake Lock';

	String get hideDockIcon => 'Hide Dock Icon';

	String get showTrayTraffic => 'Show traffic info in tray';

	String get website => 'Website';

	String get rule => 'Rule';

	String get global => 'Global';

	String get direct => 'Direct';

	String get qrcode => 'QR Code';

	String get qrcodeTooLong => 'The text is too long to display';

	String get qrcodeShare => 'Share QR Code';

	String get qrcodeScan => 'Scan QR Code';

	String get qrcodeScanResult => 'Scan Result';

	String get backupAndSync => 'Backup and Sync';

	String get export => 'Export';

	String get send => 'Send';

	String get sendConfirm => 'Confirm to send?';

	String get log => 'Log';

	String get coreLog => 'Core Log';

	String get appLog => 'App log';

	String get core => 'Core';

	String get help => 'Help';

	String get tutorial => 'Tutorial';

	String get board => 'Board';

	String get boardOnline => 'Use Online Board';

	String get boardOnlineUrl => 'Online Board URL';

	String get boardLocalPort => 'Local Board Port';

	String get alwayOnVPN => 'Always-on Connection';

	String get disableFontScaler => 'Disable Font scaling(Restart takes effect)';

	String get autoOrientation => 'Rotate with the screen';

	String get restartTakesEffect => 'Restart takes effect';

	String get reconnectTakesEffect => 'Reconnect takes effect';

	String get runtimeProfile => 'Runtime Profile';

	String get willCompleteAfterRebootInstall => 'Please restart your device to complete the system extension installation';

	String get requestNeedsUserApproval => '1. Please [Allow] Mclash to install system extensions in [System Settings]-[Privacy and Security]\n2. [System Settings]-[General]-[Login Items Extensions]-[Network Extension] enable [mclashServiceSE]\nreconnect after completion';

	String get FullDiskAccessPermissionRequired => 'Please enable mclashServiceSE permission in [System Settings]-[Privacy and Security]-[Full Disk Access] and reconnect.';

	String get proxy => 'Proxy';

	String get theme => 'Theme';

	String get tvMode => 'TV Mode';

	String get autoUpdate => 'Auto Update';

	String get updateChannel => 'Auto Update Channel';

	String hasNewVersion({required Object p}) => 'Update Version ${p}';

	String get autoDownloadPkg => 'Auto Download Update Packages';

	String get devOptions => 'Developer Options';

	String get about => 'About';

	String get name => 'Name';

	String get version => 'Version';

	String get sort => 'Reorder';

	String get share => 'Share';

	String get importFromClipboard => 'Import From Clipboard';

	String get exportToClipboard => 'Export to Clipboard';

	String get server => 'Server';

	String get port => 'Port';

	String get donate => 'Donate';

	String get setting => 'Settings';

	String get settingCore => 'Core Settings';

	String get settingApp => 'App Settings';

	String get coreOverwrite => 'Core Overwrite';

	String get iCloud => 'iCloud';

	String get webdav => 'Webdav';

	String get lanSync => 'LAN Sync';

	String get lanSyncNotQuitTips => 'Do not exit this interface before synchronization is completed';

	String get deviceNoSpace => 'Not enough disk space';

	String get hideSystemApp => 'Hide System Apps';

	String get hideAppIcon => 'Hide App Icons';

	String get openDir => 'Open File Directory';

	String get type => 'Type';

	String fileNotExist({required Object p}) => 'File does not exist:${p}';

	String get buyProfile => 'Buy Profile';

	String get myProfiles => 'My Profiles';

	String get profileEdit => 'Profile Edit';

	String get profileNeedActive => 'Please set this profile as the current profile first, then start/reconnect';

	String profileUrlOrContent({required Object p}) => '${p} Profile Link';

	String get tabHome => 'Home';

	String get tabNodes => 'Nodes';

	String get tabPlans => 'Plans';

	String get tabMe => 'Me';
}

class Translations$permission$en {
	Translations$permission$en._(this._root);

	final Translations _root; // ignore: unused_field


	String get camera => 'Camera';

	String get screen => 'Screen Recording';

	String get appQuery => 'Get Application List';

	String request({required Object p}) => 'Turn on [${p}] permission';

	String requestNeed({required Object p}) => 'Please Turn on [${p}] permission';
}

class Translations$tls$en {
	Translations$tls$en._(this._root);

	final Translations _root; // ignore: unused_field


	String get certificate => 'Certificate';

	String get privateKey => 'Private Key';

	String get customTrustCert => 'Custom Certifactes';
}

class Translations$tun$en {
	Translations$tun$en._(this._root);

	final Translations _root; // ignore: unused_field


	String get stack => 'Network stack';

	String get inet4Address => 'IPv4 Gateway Address';

	String get dnsHijack => 'DNS Hijack';

	String get strictRoute => 'Strict Route';

	String get tunDefaultRoute => 'Default Route';

	String get icmpForward => 'ICMP Forwarding';

	String get allowBypass => 'Allow Apps to Bypass VPN';

	String get appendHttpProxy => 'Append HTTP Proxy to VPN';

	String get bypassHttpProxyDomain => 'Domains allowed to bypass HTTP proxy';
}

class Translations$dns$en {
	Translations$dns$en._(this._root);

	final Translations _root; // ignore: unused_field


	String get listen => 'Listen';

	String get fakeIp => 'fake-ip';

	String get fallback => 'Fallback';

	String get preferH3 => 'Prefer DoH H3';

	String get useHosts => 'Use Hosts';

	String get useSystemHosts => 'Use System Hosts';

	String get enhancedMode => 'Enhanced Mode';

	String get fakeIPFilterMode => '${_root.dns.fakeIp} Filter Mode';

	String get fakeIPFilter => 'fake-ip Filter';

	String get respectRules => 'Respect Rules';

	String get nameServer => 'NameServer';

	String get defaultNameServer => '${_root.meta.byDefault} ${_root.dns.nameServer}';

	String get proxyNameServer => '${_root.meta.proxy} ${_root.dns.nameServer}';

	String get directNameServer => '${_root.meta.direct} ${_root.dns.nameServer}';

	String get fallbackNameServer => '${_root.dns.fallback} ${_root.dns.nameServer}';

	String get fallbackGeoIp => '${_root.dns.fallback} GeoIp';

	String get fallbackGeoIpCode => '${_root.dns.fallback} GeoIpCode';
}

class Translations$sniffer$en {
	Translations$sniffer$en._(this._root);

	final Translations _root; // ignore: unused_field


	String get overrideDest => 'Override';
}

class Translations$profilePatchMode$en {
	Translations$profilePatchMode$en._(this._root);

	final Translations _root; // ignore: unused_field


	String get currentSelected => 'Current Selected';

	String get overwrite => 'Built-in Overwrite';

	String get noOverwrite => 'Built-in - no Overwrite';
}

class Translations$main$tray$en {
	Translations$main$tray$en._(this._root);

	final Translations _root; // ignore: unused_field


	String get menuOpen => 'Open';

	String get menuExit => 'Exit';
}

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
			_ => null,
		};
	}
}
