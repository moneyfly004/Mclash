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
class TranslationsFa with BaseTranslations<AppLocale, Translations> implements Translations {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	TranslationsFa({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: AppLocale.fa,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <fa>.
	final TranslationMetadata<AppLocale, Translations> _meta;
	@override TranslationMetadata<AppLocale, Translations> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key);

	late final TranslationsFa _root = this; // ignore: unused_field

	@override 
	TranslationsFa $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => TranslationsFa(meta: meta ?? this.$meta);

	// Translations
	@override late final _Translations$BackupAndSyncWebdavScreen$fa BackupAndSyncWebdavScreen = _Translations$BackupAndSyncWebdavScreen$fa._(_root);
	@override late final _Translations$LaunchFailedScreen$fa LaunchFailedScreen = _Translations$LaunchFailedScreen$fa._(_root);
	@override late final _Translations$PerAppAndroidScreen$fa PerAppAndroidScreen = _Translations$PerAppAndroidScreen$fa._(_root);
	@override late final _Translations$UserAgreementScreen$fa UserAgreementScreen = _Translations$UserAgreementScreen$fa._(_root);
	@override late final _Translations$NetCheckScreen$fa NetCheckScreen = _Translations$NetCheckScreen$fa._(_root);
	@override late final _Translations$VersionUpdateScreen$fa VersionUpdateScreen = _Translations$VersionUpdateScreen$fa._(_root);
	@override late final _Translations$loginScreen$fa loginScreen = _Translations$loginScreen$fa._(_root);
	@override late final _Translations$main$fa main = _Translations$main$fa._(_root);
	@override late final _Translations$meta$fa meta = _Translations$meta$fa._(_root);
	@override late final _Translations$permission$fa permission = _Translations$permission$fa._(_root);
	@override late final _Translations$tls$fa tls = _Translations$tls$fa._(_root);
	@override late final _Translations$tun$fa tun = _Translations$tun$fa._(_root);
	@override late final _Translations$dns$fa dns = _Translations$dns$fa._(_root);
	@override late final _Translations$sniffer$fa sniffer = _Translations$sniffer$fa._(_root);
	@override late final _Translations$profilePatchMode$fa profilePatchMode = _Translations$profilePatchMode$fa._(_root);
	@override String sendOrReceiveNotMatch({required Object p}) => 'لطفا از [${p}] استفاده کنید';
	@override String targetConnectFailed({required Object p}) => 'اتصال به [${p}] ناموفق بود، لطفاً مطمئن شوید که دستگاه در همان LAN است';
	@override String get edgeRuntimeNotInstalled => 'زمان اجرا Edge WebView2 روی دستگاه فعلی نصب نشده است و صفحه قابل نمایش نیست لطفاً زمان اجرا Edge WebView2 (x64) را بارگیری و نصب کنید، برنامه را مجدداً راه اندازی کنید و دوباره امتحان کنید.';
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
	@override late final _Translations$meScreen$fa meScreen = _Translations$meScreen$fa._(_root);
	@override late final _Translations$homeScreen$fa homeScreen = _Translations$homeScreen$fa._(_root);
	@override late final _Translations$nodesScreen$fa nodesScreen = _Translations$nodesScreen$fa._(_root);
	@override late final _Translations$nodeAuto$fa nodeAuto = _Translations$nodeAuto$fa._(_root);
	@override late final _Translations$accountBlock$fa accountBlock = _Translations$accountBlock$fa._(_root);
	@override late final _Translations$entitlementMsg$fa entitlementMsg = _Translations$entitlementMsg$fa._(_root);
	@override late final _Translations$devicesScreen$fa devicesScreen = _Translations$devicesScreen$fa._(_root);
	@override late final _Translations$sysProxySheet$fa sysProxySheet = _Translations$sysProxySheet$fa._(_root);
	@override late final _Translations$logScreen$fa logScreen = _Translations$logScreen$fa._(_root);
	@override late final _Translations$trayShell$fa trayShell = _Translations$trayShell$fa._(_root);
}

// Path: BackupAndSyncWebdavScreen
class _Translations$BackupAndSyncWebdavScreen$fa implements Translations$BackupAndSyncWebdavScreen$en {
	_Translations$BackupAndSyncWebdavScreen$fa._(this._root);

	final TranslationsFa _root; // ignore: unused_field

	// Translations
	@override String get webdavServerUrl => 'آدرس URL سرور';
	@override String get webdavRequired => 'نمی‌تواند خالی باشد';
	@override String get webdavLoginFailed => 'ورود ناموفق بود:';
	@override String get webdavListFailed => 'دریافت لیست فایل ناموفق بود:';
}

// Path: LaunchFailedScreen
class _Translations$LaunchFailedScreen$fa implements Translations$LaunchFailedScreen$en {
	_Translations$LaunchFailedScreen$fa._(this._root);

	final TranslationsFa _root; // ignore: unused_field

	// Translations
	@override String get invalidProcess => 'اجرای نرم‌افزار ناموفق بود [نام‌ اجرایی پروسه نامعتبر]، لطفا مجدد نرم‌افزار را در دایرکتوری دیگری نصب کنید';
	@override String get invalidProfile => 'اجرای نرم‌افزار ناموفق بود [دسترسی به پروفایل ناموفق بود]، لطفا مجدد نرم افزار را نصب کنید';
	@override String get invalidVersion => 'اجرای نرم‌افزار ناموفق بود [ورژن نامعتبر]، لطفا مجدد نرم‌افزار را نصب کنید';
	@override String get systemVersionLow => 'راه اندازی برنامه ناموفق بود [نسخه سیستم خیلی کم است]';
	@override String get invalidInstallPath => 'مسیر نصب نامعتبر است، لطفا مجدد در مسیر معتبر نصب کنید';
}

// Path: PerAppAndroidScreen
class _Translations$PerAppAndroidScreen$fa implements Translations$PerAppAndroidScreen$en {
	_Translations$PerAppAndroidScreen$fa._(this._root);

	final TranslationsFa _root; // ignore: unused_field

	// Translations
	@override String get title => 'پروکسی به‌تفکیک برنامه';
	@override String get whiteListMode => 'حالت لیست سفید';
	@override String get whiteListModeTip => 'وقتی فعال باشد: فقط برنامه‌هایی که انتخاب شده‌اند پروکسی می‌شوند؛ وقتی فعال نباشد: فقط برنامه‌هایی که انتخاب نشده‌اند پروکسی می‌شوند';
}

// Path: UserAgreementScreen
class _Translations$UserAgreementScreen$fa implements Translations$UserAgreementScreen$en {
	_Translations$UserAgreementScreen$fa._(this._root);

	final TranslationsFa _root; // ignore: unused_field

	// Translations
	@override String get privacyFirst => 'حریم‌خصوصی شما اولویت دارد';
	@override String get agreeAndContinue => 'پذیرفتن و ادامه';
}

// Path: NetCheckScreen
class _Translations$NetCheckScreen$fa implements Translations$NetCheckScreen$en {
	_Translations$NetCheckScreen$fa._(this._root);

	final TranslationsFa _root; // ignore: unused_field

	// Translations
	@override String get enterDomain => 'لطفاً نام دامنه را وارد کنید';
	@override String get checking => 'در حال بررسی...';
	@override String aQueryFailed({required Object p}) => 'خطا در پرس‌وجوی A: ${p}';
	@override String aaaaQueryFailed({required Object p}) => 'خطا در پرس‌وجوی AAAA: ${p}';
	@override String get success => 'موفق';
	@override String get failed => 'ناموفق';
	@override String get suspectedPollution => 'مشکوک به مسمومیت DNS';
	@override String get domainLabel => 'دامنه';
	@override String get checkButton => 'بررسی';
	@override String get dnsSection => '1. پرس‌وجوی DNS';
	@override String get directHttpSection => '2. HTTP (از طریق TUN، ابتدا TUN را فعال کنید)';
	@override String proxyHttpSection({required Object p}) => '3. HTTP (از طریق پروکسی، پورت: ${p})';
	@override String get tunNotEnabled => 'TUN فعال نیست';
	@override String get routeTableSection => '4. جدول مسیریابی';
}

// Path: VersionUpdateScreen
class _Translations$VersionUpdateScreen$fa implements Translations$VersionUpdateScreen$en {
	_Translations$VersionUpdateScreen$fa._(this._root);

	final TranslationsFa _root; // ignore: unused_field

	// Translations
	@override String versionReady({required Object p}) => 'نسخه جدید [${p}] آماده است';
	@override String get update => 'راه‌اندازی مجدد برای به‌روزرسانی';
	@override String get cancel => 'الان‌ نه';
}

// Path: loginScreen
class _Translations$loginScreen$fa implements Translations$loginScreen$en {
	_Translations$loginScreen$fa._(this._root);

	final TranslationsFa _root; // ignore: unused_field

	// Translations
	@override String get login => 'ورود';
	@override String get register => 'ایجاد حساب';
	@override String get forgotPassword => 'فراموشی رمز عبور';
	@override String get provider => 'ارائه دهنده خدمات';
	@override String get providerName => 'کد/نام مستعار/URL ${_root.loginScreen.provider}';
	@override String get account => 'حساب';
	@override String get email => 'ایمیل';
	@override String get password => 'رمز عبور';
}

// Path: main
class _Translations$main$fa implements Translations$main$en {
	_Translations$main$fa._(this._root);

	final TranslationsFa _root; // ignore: unused_field

	// Translations
	@override late final _Translations$main$tray$fa tray = _Translations$main$tray$fa._(_root);
}

// Path: meta
class _Translations$meta$fa implements Translations$meta$en {
	_Translations$meta$fa._(this._root);

	final TranslationsFa _root; // ignore: unused_field

	// Translations
	@override String get enable => 'فعال‌سازی';
	@override String get disable => 'غیرفعال';
	@override String get open => 'باز کن';
	@override String get close => 'بسته';
	@override String get quit => 'خروج';
	@override String get add => 'افزودن';
	@override String get remove => 'حذف';
	@override String get removeConfirm => 'آیا از حذف اطمینان دارین؟';
	@override String get edit => 'ویرایش کنید';
	@override String get view => 'بررسی';
	@override String get remark => 'ملاحضات';
	@override String get byDefault => 'پیش‌فرض';
	@override String get more => 'بیشتر';
	@override String get tips => 'اطلاعات';
	@override String get selectAll => 'انتخاب همه';
	@override String get copy => 'کپی';
	@override String get paste => 'چسباندن';
	@override String get cut => 'برش';
	@override String get save => 'ذخیره کنید';
	@override String get ok => 'خُب';
	@override String get cancel => 'لغو';
	@override String get faq => 'سوالات متداول';
	@override String get doc => 'سند';
	@override String get htmlTools => 'مجموعه ابزارهای HTML';
	@override String get download => 'دانلود';
	@override String get loading => 'درحال بارگذاری…';
	@override String get days => 'روز';
	@override String get hours => 'ساعت';
	@override String get minutes => 'دقیقه';
	@override String get seconds => 'دومین';
	@override String get milliseconds => 'میلی‌ثانیه';
	@override String get search => 'جستجو';
	@override String get searchNodeHint => 'فیلتر گره‌ها (نام یا پروتکل)';
	@override String get connect => 'اتصال';
	@override String get disconnect => 'قطع‌ اتصال';
	@override String get connected => 'وصل شد';
	@override String get disconnected => 'قطع شد';
	@override String get connecting => 'درحال اتصال';
	@override String get connectTimeout => 'اتمام مهلت اتصال';
	@override String get timeout => 'تایم اوت';
	@override String get latencyTest => 'بررسی تاخیر';
	@override String get networkCheck => 'بررسی شبکه';
	@override String get language => 'زبان';
	@override String get next => 'بعدی';
	@override String get done => 'انجام‌شد';
	@override String get apply => 'درخواست دادن';
	@override String get refresh => 'بارگذاری مجدد';
	@override String get update => 'تجدید';
	@override String get updateInterval => 'فاصله‌ی به‌روزرسانی';
	@override String get updateInterval5mTips => 'حداقل: 5 متر';
	@override String get updateIntervalPreferByProfile => 'اولویت با تنظیمات ارائه‌دهنده';
	@override String updateFailed({required Object p}) => 'به‌روزرسانی ناموفق بود:${p}';
	@override String get none => 'هیچ‌کدام';
	@override String get reset => 'ریست';
	@override String get authentication => 'مجوز';
	@override String get user => 'کاربر';
	@override String get account => 'نام‌کاربری';
	@override String get password => 'رمز‌عبور';
	@override String get decryptPassword => 'دکريپت رمز‌عبور';
	@override String get required => 'الزامی';
	@override String get go => 'ادامه';
	@override String get other => 'دیگر';
	@override String get dns => 'DNS';
	@override String get url => 'URL';
	@override String get urlInvalid => 'URL نامعتبر';
	@override String get copyUrl => 'کپی‌کردن لینک';
	@override String get openUrl => 'بازکردن لینک';
	@override String get coreSettingTips => 'توجه: پس از تغییر پیکربندی، باید دوباره وصل شوید تا اعمال شود';
	@override String get overwrite => 'لغو';
	@override String get overwriteAppend => 'لغو الحاقی';
	@override String get overwriteTips => 'پیکربندی اصلی <- لغو سفارشی <- لغو برنامه';
	@override String get noOverwrite => 'رونویسی نکنید';
	@override String get diversionTemplates => 'الگوی تریاژ';
	@override String get ruleProviders => 'ارائه دهنده قانون';
	@override String get ruleTemplates => 'الگوی قانون';
	@override String get proxyGroupsTemplates => 'الگوی گروه نمایندگان';
	@override String get proxyGroups => 'گروه نمایندگان';
	@override String get proxyNodeList => 'فهرست گره‌های پروکسی';
	@override String proxyNodeFailure({required Object p}) => 'گره‌های پروکسی زیر منقضی شده و به طور خودکار حذف شده‌اند: ${p}';
	@override String get externalController => 'کنترل خارجی';
	@override String get secret => 'Secret';
	@override String get tcpConcurrent => 'دست دادن همزمان TCP';
	@override String get globalClientFingerprint => 'اثر انگشت جهانی TLS';
	@override String get allowLanAccess => 'دسترسی به دستگاه LAN';
	@override String get mixedPort => 'پورت پروکسی هیبریدی';
	@override String get logLevel => 'سطح ورود به سیستم';
	@override String get findProcessMode => 'حالت تطابق فرآیند';
	@override String get tcpkeepAliveInterval => 'فاصله حفظ زنده TCP';
	@override String get delayTestUrl => 'URL تست تأخیر';
	@override String get delayTestTimeout => 'مهلت زمانی تست تاخیری (میلی‌ثانیه)';
	@override String get tun => 'TUN';
	@override String get ntp => 'NTP';
	@override String get tls => 'TLS';
	@override String get geoDownloadByProxy => 'دانلود Geo RuleSet با استفاده از یک پروکسی';
	@override String get geoRulesetTips => 'Geosite/Geoip به RuleSet مربوطه تبدیل می شود';
	@override String get sniffer => 'بو کشیدن';
	@override String get userAgent => 'UserAgent';
	@override String get launchAtStartup => 'اجرا در راه‌اندازی';
	@override String get launchAtStartupRunAsAdmin => 'لطفاً Mclash را به عنوان مدیر راه اندازی مجدد کنید';
	@override String get tunModeRunAsAdmin => 'حالت TUN نیازمند مجوز مدیر سیستم می‌باشد لطفا نرم‌افزار را مجدد با حالت مدیر (administrator) راه‌اندازی کنید';
	@override String get portableMode => 'حالت قابل‌حمل';
	@override String get portableModeDisableTips => 'اگر نیاز دارین از حالت قابل‌حمل خارج شوید لطفا از [mclash] خارج شده و به‌صورت دستی پوشه [portable] هم مسیر با فایل [mclash.exe] را حذف کنید';
	@override String get autoConnectAfterLaunch => 'اتصال خودکار پس‌از راه‌اندازی';
	@override String get autoConnectAtBoot => 'اتصال خودکار پس از روشن شدن سیستم';
	@override String get autoConnectAtBootTips => 'پشتیبانی سیستم مورد نیاز است؛ برخی سیستم‌ها ممکن است نیاز به فعال بودن [شروع خودکار] نیز داشته باشند.';
	@override String get hideAfterLaunch => 'پنهان کردن پنجره پس از راه اندازی';
	@override String get autoSetSystemProxy => 'تنظیم خودکار حالت پروکسی سیستم پس‌از اتصال';
	@override String get bypassSystemProxy => 'نام های دامنه ای که مجاز به دور زدن پراکسی سیستم هستند';
	@override String get excludeFromRecent => 'پنهان شدن از وظایف اخیر';
	@override String get hideDockIcon => 'پنهان کردن آیکون داک';
	@override String get showTrayTraffic => 'نمایش اطلاعات ترافیک در سینی سیستم';
	@override String get wakeLock => 'قفل بیدارباش';
	@override String get website => 'وبسایت';
	@override String get rule => 'قانون';
	@override String get global => 'عمومی';
	@override String get direct => 'مستقیم';
	@override String get qrcode => 'کد QR';
	@override String get qrcodeTooLong => 'متن برای نمایش خیلی طولانی است';
	@override String get qrcodeShare => 'اشتراک کدQR';
	@override String get qrcodeScan => 'اسکن QRکد';
	@override String get qrcodeScanResult => 'نتایج اسکن';
	@override String get backupAndSync => 'پشتیبان‌گیری و همگام‌سازی';
	@override String get export => 'خروجی‌گرفتن';
	@override String get send => 'ارسال کنید';
	@override String get sendConfirm => 'ارسال را تایید کرد؟';
	@override String get log => 'ورود به سیستم';
	@override String get coreLog => 'گزارش هسته';
	@override String get appLog => 'گزارش برنامه';
	@override String get core => 'هسته';
	@override String get help => 'کمک کند';
	@override String get tutorial => 'آموزش';
	@override String get board => 'پانل';
	@override String get boardOnline => 'با استفاده از پنل آنلاین';
	@override String get boardOnlineUrl => 'آدرس پنل آنلاین';
	@override String get boardLocalPort => 'پورت پانل محلی';
	@override String get alwayOnVPN => 'اتصال همیشه باز';
	@override String get disableFontScaler => 'غیرفعال‌سازی مقیاس‌بندی فونت(با راه‌اندازی مجدد اعمال می‌شود)';
	@override String get autoOrientation => 'چرخش صفحه را دنبال کنید';
	@override String get restartTakesEffect => 'با راه‌اندازی مجدد اعمال می‌شود';
	@override String get reconnectTakesEffect => 'پس از اتصال مجدد، اعمال خواهد شد.';
	@override String get runtimeProfile => 'پیکربندی زمان اجرا';
	@override String get willCompleteAfterRebootInstall => 'لطفاً دستگاه خود را مجدداً راه اندازی کنید تا نصب افزونه سیستم تکمیل شود.';
	@override String get requestNeedsUserApproval => '۱. لطفاً به Mclash اجازه دهید افزونه‌های سیستمی را در [تنظیمات سیستم] - [حریم خصوصی و امنیت] نصب کند. ۲. : [تنظیمات سیستم] - [عمومی] - [موارد ورود و افزونه‌ها - افزونه‌های شبکه] [mclashServiceSE] را فعال کنید. پس از اتمام، دوباره متصل شوید.';
	@override String get FullDiskAccessPermissionRequired => 'لطفاً مجوز mclashServiceSE را در [تنظیمات سیستم]-[حریم خصوصی و امنیت]-[دسترسی کامل به دیسک] فعال کنید و دوباره متصل شوید.';
	@override String get proxy => 'بازیگری';
	@override String get theme => 'موضوع';
	@override String get tvMode => 'حالت تلویزیون';
	@override String get autoUpdate => 'به روز رسانی خودکار';
	@override String get updateChannel => 'کانال به‌روزرسانی خودکار';
	@override String hasNewVersion({required Object p}) => 'به‌روزرسانی نسخه ${p} ';
	@override String get autoDownloadPkg => 'دانلود خودکار بسته‌های به‌روزرسانی';
	@override String get devOptions => 'تنظیمات توسعه‌دهندگان';
	@override String get about => 'درباره';
	@override String get name => 'نام';
	@override String get version => 'نسخه';
	@override String get sort => 'مرتب‌سازی';
	@override String get share => 'اشتراک گذاری';
	@override String get importFromClipboard => 'افزودن از کلیپ‌برد';
	@override String get exportToClipboard => 'صادرات به کلیپ بورد';
	@override String get server => 'سرور';
	@override String get port => 'بندر';
	@override String get donate => 'اهدا کنید';
	@override String get setting => 'تنظیمات';
	@override String get settingCore => 'تنظیمات اصلی';
	@override String get settingApp => 'تنظیمات برنامه';
	@override String get coreOverwrite => 'Core Override';
	@override String get iCloud => 'iCloud';
	@override String get webdav => 'Webdav';
	@override String get lanSync => 'LAN Sync';
	@override String get lanSyncNotQuitTips => 'قبل از تکمیل همگام‌سازی از این قسمت خارج نشوید';
	@override String get deviceNoSpace => 'فضای خالی کافی ندارید';
	@override String get hideSystemApp => 'برنامه های سیستم را مخفی کنید';
	@override String get hideAppIcon => 'پنهان کردن نماد برنامه';
	@override String get openDir => 'بازکردن دایرکتوری فایل';
	@override String get type => 'نوع';
	@override String fileNotExist({required Object p}) => 'فایل وجود ندارد:${p}';
	@override String get buyProfile => 'خرید پروفایل';
	@override String get myProfiles => 'پروفایل‌ها';
	@override String get profileEdit => 'ویرایش پروفایل';
	@override String get profileNeedActive => 'ابتدا این پروفایل را به‌عنوان پروفایل فعلی تنظیم کنید، سپس اتصال را فعال/دوباره متصل کنید';
	@override String profileUrlOrContent({required Object p}) => 'پیوند پیکربندی ${p}';
	@override String get tabHome => 'خانه';
	@override String get tabNodes => 'گره‌ها';
	@override String get tabPlans => 'طرح‌ها';
	@override String get tabMe => 'من';
}

// Path: permission
class _Translations$permission$fa implements Translations$permission$en {
	_Translations$permission$fa._(this._root);

	final TranslationsFa _root; // ignore: unused_field

	// Translations
	@override String get camera => 'دوربین';
	@override String get screen => 'ضبط صفحه';
	@override String get appQuery => 'Get Application List';
	@override String request({required Object p}) => 'مجوزهای [${p}] را فعال کنید';
	@override String requestNeed({required Object p}) => 'لطفاً مجوز [${p}] را فعال کنید';
}

// Path: tls
class _Translations$tls$fa implements Translations$tls$en {
	_Translations$tls$fa._(this._root);

	final TranslationsFa _root; // ignore: unused_field

	// Translations
	@override String get certificate => 'گواهی';
	@override String get privateKey => 'کلید خصوصی';
	@override String get customTrustCert => 'گواهی های سفارشی';
}

// Path: tun
class _Translations$tun$fa implements Translations$tun$en {
	_Translations$tun$fa._(this._root);

	final TranslationsFa _root; // ignore: unused_field

	// Translations
	@override String get stack => 'پشته شبکه';
	@override String get inet4Address => 'محدوده آدرس IPv4';
	@override String get dnsHijack => 'ربودن DNS';
	@override String get strictRoute => 'مسیریابی دقیق';
	@override String get tunDefaultRoute => 'مسیر پیش‌فرض';
	@override String get icmpForward => 'ارسال ICMP';
	@override String get allowBypass => 'به برنامه‌ها اجازه دهید VPN را دور بزنند';
	@override String get appendHttpProxy => 'پیوست دادن پروکسی HTTP به وی‌پی‌ان';
	@override String get bypassHttpProxyDomain => 'دامنه ها مجاز به دور زدن پروکسی HTTP هستند';
}

// Path: dns
class _Translations$dns$fa implements Translations$dns$en {
	_Translations$dns$fa._(this._root);

	final TranslationsFa _root; // ignore: unused_field

	// Translations
	@override String get listen => 'آدرس گوش دادن';
	@override String get fakeIp => 'fake-ip';
	@override String get fallback => 'Fallback';
	@override String get preferH3 => 'اولویت DoH H3';
	@override String get useHosts => 'استفاده از هاست ها';
	@override String get useSystemHosts => 'استفاده از هاست های سیستم';
	@override String get enhancedMode => 'حالت پیشرفته';
	@override String get fakeIPFilterMode => 'حالت فیلتر ${_root.dns.fakeIp}';
	@override String get fakeIPFilter => 'فیلتر ${_root.dns.fakeIp}';
	@override String get respectRules => 'رعایت قوانین';
	@override String get nameServer => 'سرور DNS';
	@override String get defaultNameServer => '${_root.meta.byDefault} ${_root.dns.nameServer}';
	@override String get proxyNameServer => '${_root.meta.proxy} ${_root.dns.nameServer}';
	@override String get directNameServer => '${_root.meta.direct} ${_root.dns.nameServer}';
	@override String get fallbackNameServer => '${_root.dns.fallback} ${_root.dns.nameServer}';
	@override String get fallbackGeoIp => '${_root.dns.fallback} GeoIp';
	@override String get fallbackGeoIpCode => '${_root.dns.fallback} GeoIpCode';
}

// Path: sniffer
class _Translations$sniffer$fa implements Translations$sniffer$en {
	_Translations$sniffer$fa._(this._root);

	final TranslationsFa _root; // ignore: unused_field

	// Translations
	@override String get overrideDest => 'پوشش';
}

// Path: profilePatchMode
class _Translations$profilePatchMode$fa implements Translations$profilePatchMode$en {
	_Translations$profilePatchMode$fa._(this._root);

	final TranslationsFa _root; // ignore: unused_field

	// Translations
	@override String get currentSelected => 'فعلی انتخاب شده';
	@override String get overwrite => 'Overwrite داخلی';
	@override String get noOverwrite => 'داخلی - رونویسی نشده است';
}

// Path: meScreen
class _Translations$meScreen$fa implements Translations$meScreen$en {
	_Translations$meScreen$fa._(this._root);

	final TranslationsFa _root; // ignore: unused_field

	// Translations
	@override String get accountBalance => 'Balance';
	@override String get expireAt => 'Expires';
	@override String get remainingDays => 'Days Left';
	@override String get deviceCount => 'Devices';
	@override String get myOrders => 'My Orders';
	@override String get deviceManagement => 'Device Management';
	@override String get changePassword => 'Change Password';
	@override String get clearLocalData => 'Clear local data (before uninstall)';
	@override String get profileManagementDev => 'Profile management (developer)';
	@override String get tunAdapter => 'TUN virtual adapter';
	@override String get checkUpdate => 'Check for updates';
	@override String get retry => 'Retry';
	@override String get loadFailed => 'Failed to load account info: the sign-in may have expired or the network is unreachable.\nTap Refresh at the top right to retry; if it keeps failing, sign in again.';
	@override String get logoutConfirm => 'Sign out?';
	@override String get boardNoKernel => 'The dashboard shows the kernel\'s live data (connection, traffic, rule hits).\n\nThe kernel is not running, so the dashboard would be an empty shell.\nTap OK to open it anyway, or Cancel to connect on the Home tab first.';
	@override String get boardOpened => 'Opened the dashboard in your browser; switch nodes or rules there and the app follows within ~5 seconds.';
}

// Path: homeScreen
class _Translations$homeScreen$fa implements Translations$homeScreen$en {
	_Translations$homeScreen$fa._(this._root);

	final TranslationsFa _root; // ignore: unused_field

	// Translations
	@override String expiresOn({required Object date}) => 'Expires ${date}';
	@override String devicesText({required Object text}) => 'Devices ${text}';
	@override String get upgrade => 'Upgrade';
	@override String get quickCountries => 'Quick country filter';
	@override String nodeCount({required Object count}) => '${count} nodes';
	@override String get autoBestTip => 'Pick the lowest-latency available node across all countries (auto mode)';
	@override String get autoBest => 'Auto best';
	@override String pickCountryTip({required Object label}) => 'Auto-select the lowest-latency available node in "${label}" and pin it';
	@override String get autoNoBetter => 'Already in auto mode (no better node found)';
	@override String switchedBest({required Object name}) => 'Switched to the best node: ${name}';
	@override String switchedCountry({required Object country, required Object node, required Object ms}) => 'Switched to the fastest ${country} node: ${node}${ms}';
	@override String filterCountryFailed({required Object country, required Object err}) => 'Filtered by ${country}; switching failed: ${err}';
	@override String deviceFullCount({required Object used, required Object limit}) => 'Current devices ${used}/${limit}\n\n';
	@override String get deviceFullUpgradeHint => 'Upgrading the device limit restores the connection immediately (recommended); you can also delete unused devices to free a slot.';
	@override String get later => 'Later';
	@override String get upgradeDeviceCount => 'Upgrade device limit';
	@override String get cannotConnect => 'Cannot connect';
	@override String get freshnessNever => 'Not synced yet · tap to refresh';
	@override String get freshnessJustNow => 'Updated just now · tap Manage devices';
	@override String freshnessMinutes({required Object minutes}) => '${minutes} min ago · tap Manage devices';
	@override String freshnessStale({required Object minutes}) => '${minutes} min ago · tap to refresh';
	@override String get subscriptionAutoSync => 'Auto subscription sync';
	@override String get connecting => 'Connecting…';
	@override String get disconnecting => 'Disconnecting…';
	@override String get tapToDisconnect => 'Tap the switch to disconnect';
	@override String get tapToConnect => 'Tap the switch to connect';
	@override String get currentNode => 'Current node';
	@override String get noNodeSelected => 'No node selected';
	@override String get switchAction => 'Switch';
	@override String get realtimeSpeed => 'Real-time speed';
	@override String get totalTraffic => 'Total traffic';
	@override String get subSyncedNotReady => 'Subscription downloaded, but the profile is not ready yet. Please try again shortly.';
	@override String get noPlan => 'This account has no available plan yet. Please purchase one first.';
	@override String get loginExpired => 'Your sign-in has expired. Please sign in again.';
	@override String get syncingWait => 'Syncing subscription, please wait.';
	@override String syncFailedNetwork({required Object message}) => 'Subscription sync failed: ${message}\nCheck your network and try again.';
	@override String get syncFailed => 'Subscription sync failed, please try again later.';
	@override String get resetProxy => 'Reset';
}

// Path: nodesScreen
class _Translations$nodesScreen$fa implements Translations$nodesScreen$en {
	_Translations$nodesScreen$fa._(this._root);

	final TranslationsFa _root; // ignore: unused_field

	// Translations
	@override String updatedCount({required Object count}) => 'Subscription updated: ${count} nodes';
	@override String updateFailed({required Object message}) => 'Update failed: ${message}';
	@override String get updateFailedNetwork => 'Update failed, please check your network';
	@override String testDone({required Object ok, required Object fail}) => 'Speed test done: ${ok} reachable, ${fail} unreachable (may be offline)';
	@override String switchedTo({required Object name}) => 'Switched to ${name}';
	@override String switchFailed({required Object message}) => 'Switch failed: ${message}\n(Node switching needs a running kernel; turn on the switch on the Home tab first.)';
	@override String selectedAfterConnect({required Object name}) => 'Selected ${name} (takes effect after connecting)';
	@override String get title => 'Nodes';
	@override String get searchNode => 'Search nodes';
	@override String get sortByLatency => 'Sort by latency';
	@override String get updateSubscription => 'Update subscription';
	@override String get viewByGroup => 'View by proxy group';
	@override String get testAll => 'Test all';
	@override String get searchHint => 'Search node / country / protocol';
	@override String get emptyNoNodes => 'No nodes available yet.\nSubscriptions sync automatically; if you just signed in, wait a moment or tap reload below.';
	@override String get emptyNoMatch => 'No matching nodes.';
	@override String get reload => 'Reload';
	@override String get currentInUse => 'Current (in use)';
	@override String get current => 'Current';
	@override String get notTested => 'Not measured (kernel reload pending)';
	@override String get timeout => 'Timeout';
	@override String get clear => 'Clear';
	@override String get selectNode => 'Select node';
	@override String get emptyNoKernel => 'No nodes available yet.\nPlease turn on the connection switch on the Home tab first.';
	@override String get openFullList => 'Open the full node list (search / speed test / groups)';
}

// Path: nodeAuto
class _Translations$nodeAuto$fa implements Translations$nodeAuto$en {
	_Translations$nodeAuto$fa._(this._root);

	final TranslationsFa _root; // ignore: unused_field

	// Translations
	@override String get kernelStateUnavailable => 'Node status is temporarily unavailable from the kernel; will retry automatically.';
	@override String backToFixedNode({required Object fixed}) => 'Back to the pinned node: ${fixed}';
	@override String get noUsableNodePickOne => 'No usable node found. Please pick one manually in the node list.';
	@override String get noUsableNodeTryOne => 'No usable node found. Please try picking one in the node list.';
	@override String autoConnectedBest({required Object bestNode, required Object bestMs}) => 'Auto-connected to the best node: ${bestNode} (${bestMs} ms)';
	@override String get currentNodeUnreachable => 'The current node cannot reach the internet; switching automatically…';
	@override String autoSwitchedToUsable({required Object target}) => 'Automatically switched to a usable node: ${target}';
	@override String newNodesReloading({required Object missing}) => '${missing} new node(s) in the subscription are not in the kernel yet; reloading…';
	@override String get kernelReloadedRetest => 'The kernel reloaded with the new subscription; run the speed test again.';
}

// Path: accountBlock
class _Translations$accountBlock$fa implements Translations$accountBlock$en {
	_Translations$accountBlock$fa._(this._root);

	final TranslationsFa _root; // ignore: unused_field

	// Translations
	@override String quotaFull({required Object used, required Object limit}) => 'Device slots are full (${used}/${limit}): this device is still within the licensed range and can connect normally. To add another device, upgrade the device limit or remove unused ones.';
	@override String get banFallback => 'Your account has been disabled and can no longer be used.';
	@override String get titleExpired => 'Plan expired';
	@override String get titleDeviceFull => 'Device limit reached';
	@override String get titleAccountDisabled => 'Account disabled';
	@override String get titlePlanDisabled => 'Plan disabled';
	@override String get titleNoPlan => 'No plan yet';
	@override String get titleDeviceRemoved => 'This device was removed';
	@override String get titleServiceUnavailable => 'Service temporarily unavailable';
	@override String get textExpired => 'Your plan has expired. Purchase a plan to keep using global nodes.';
	@override String textDeviceFull({required Object used, required Object limit}) => 'The server has determined this device exceeds the plan device limit (${used}/${limit}), so it cannot connect for now. Remove unused devices in Me - Device Management, or upgrade to a plan with more devices.';
	@override String get textAccountDisabled => 'Your account has been disabled. Please contact support if you have questions.';
	@override String get textPlanDisabled => 'Your plan has been disabled or is in an abnormal state, so you cannot connect. Please contact support if you have questions.';
	@override String get textNoPlan => 'You have not purchased a plan yet. Purchase one to use global nodes.';
	@override String get textDeviceRemoved => 'This device was removed and signed out. Please sign in again.';
	@override String get textServiceUnavailable => 'The service is temporarily unavailable. Please try again later; if it persists, take a screenshot and contact support.';
	@override String remainingDays({required Object days}) => '${days} days left';
	@override String deviceUsage({required Object used, required Object limit}) => 'Devices ${used}/${limit}';
}

// Path: entitlementMsg
class _Translations$entitlementMsg$fa implements Translations$entitlementMsg$en {
	_Translations$entitlementMsg$fa._(this._root);

	final TranslationsFa _root; // ignore: unused_field

	// Translations
	@override String get tamperedTitle => 'Authorization state abnormal';
	@override String get tamperedClock => 'A system clock rollback (or local authorization data tampering) was detected. Please go online to complete a verification before connecting.';
	@override String get tamperedLocal => 'Local authorization data is corrupted or was modified. Please go online to complete a verification before connecting.';
	@override String get needVerifyTitle => 'Online verification required';
	@override String get needVerifyFirst => 'Cannot confirm your plan status: please connect to the network and sign in, then complete one verification before connecting.';
	@override String get needVerifyRetry => 'Cannot confirm your plan status. Please go online and try again.';
	@override String get verifyFailedTitle => 'Cannot verify plan status';
	@override String get verifyFailedText => 'The verification grace period has passed and the server is unreachable. Check your network and try again (if you just renewed, sign in again).';
	@override String get restrictedTitle => 'Account restricted';
	@override String get restrictedFallback => 'Your account or plan has been disabled, so you cannot connect.';
	@override String get expiredTitle => 'Plan expired';
	@override String expiredText({required Object date}) => 'Your plan expired on ${date}. The local subscription profile has been cleared. Renew and sign in again to restore it.';
}

// Path: devicesScreen
class _Translations$devicesScreen$fa implements Translations$devicesScreen$en {
	_Translations$devicesScreen$fa._(this._root);

	final TranslationsFa _root; // ignore: unused_field

	// Translations
	@override String get title => 'Device Management';
	@override String get currentPlan => 'Current plan';
	@override String devicesText({required Object text}) => 'Devices ${text}';
	@override String get upgradeTitle => 'Upgrade devices / extend time';
	@override String get upgradeSubtitle => 'Add devices and days together; one price, one payment';
	@override String get addDevices => 'Add devices';
	@override String get noAddDevices => 'No change';
	@override String addDevicesCount({required Object n}) => '+${n} devices';
	@override String get addDays => 'Add days';
	@override String get noExtend => 'No extension';
	@override String addDaysCount({required Object n, required Object months}) => '+${n} days (${months} months)';
	@override String get priceFailed => 'Failed to get the price';
	@override String amountDue({required Object amount}) => 'Total ¥${amount}';
	@override String get requote => 'Recalculate';
	@override String get goPay => 'Pay now';
	@override String get afterUpgrade => 'After upgrade: ';
	@override String afterLimit({required Object limit}) => 'device limit ${limit}';
	@override String afterExpire({required Object date}) => 'expires ${date}';
	@override String get pickSomething => 'Please add at least some devices or days';
	@override String get daysOnlyUnsupported => 'The panel does not support "extend time only" yet: please set "Add devices" to 1 or more and try again (or contact support to enable it).';
	@override String get paramsRejected => 'Parameters rejected: please pick the device count and days again.';
	@override String get subscriptionExpired => 'The subscription has expired, so it cannot be upgraded. Please renew or purchase a plan first.';
	@override String get orderIncomplete => 'Order information is incomplete. Tap "Recalculate" and try again.';
	@override String get orderRegenerated => 'The previous order expired; a new one was created with the same settings.';
	@override String get payChannelIncomplete => 'Order or payment channel information is incomplete. Please recalculate and try again.';
	@override String get noQrCode => 'The server did not return a payment QR code / link. Please pick another payment method or try later.';
	@override String payStartFailed({required Object err}) => 'Failed to start payment: ${err}';
	@override String get payCancelled => 'Payment cancelled; the draft order has been cleaned up.';
	@override String get balancePay => 'Balance';
	@override String get noPayMethod => 'No payment method is available right now. Please try later or contact support.';
	@override String balanceInsufficient({required Object balance, required Object amount}) => 'Insufficient balance (¥${balance}, need ¥${amount}).\nTop up first?';
	@override String get choosePayMethod => 'Choose a payment method';
	@override String balanceText({required Object balance}) => 'Balance ¥${balance}';
	@override String balanceShort({required Object balance}) => 'Balance ¥${balance} (insufficient, please top up)';
	@override String get unknownDevice => 'Unknown device';
	@override String get online => '● Online';
	@override String get offline => '○ Offline';
	@override String lastActive({required Object text}) => 'Last active ${text}';
	@override String get delete => 'Delete';
	@override String deleteConfirm({required Object name}) => 'Delete device "${name}"? It will be kicked offline immediately.';
}

// Path: sysProxySheet
class _Translations$sysProxySheet$fa implements Translations$sysProxySheet$en {
	_Translations$sysProxySheet$fa._(this._root);

	final TranslationsFa _root; // ignore: unused_field

	// Translations
	@override String get reading => 'Reading…';
	@override String get unknown => 'Unknown';
	@override String get kernelNotRunning => 'Kernel is not running (turn on the switch on the Home tab first)';
	@override String applied({required Object host, required Object port}) => 'Applied · ${host}:${port}';
	@override String notSet({required Object reason}) => 'System proxy not set — ${reason}';
	@override String notEffective({required Object port}) => 'Not effective (no system proxy pointing to ${port})';
	@override String readFailed({required Object err}) => 'Read failed: ${err}';
	@override String get setRejected => 'Failed to set: the system may have rejected the write (or another proxy app overwrote it)';
	@override String get disableFailed => 'Failed to turn off';
	@override String get portRange => 'Port must be between 1 and 65535';
	@override String portChanged({required Object value}) => 'Port changed to ${value}: disconnect and reconnect once so the kernel listens on the new port';
	@override String get title => 'System proxy';
	@override String desc({required Object host}) => 'The system proxy address is fixed to ${host} (local loopback) and the port is the kernel mixed port.';
	@override String get descWindows => 'This is exactly what you see in Windows Settings → Network & Internet → Proxy.';
	@override String get reset => 'Set again';
	@override String get disable => 'Turn off system proxy';
	@override String get diagnostics => 'Diagnostics (is the UI reading the same values as the registry?)';
	@override String get mixedPort => 'Mixed port';
	@override String get apply => 'Apply';
}

// Path: logScreen
class _Translations$logScreen$fa implements Translations$logScreen$en {
	_Translations$logScreen$fa._(this._root);

	final TranslationsFa _root; // ignore: unused_field

	// Translations
	@override String readAppFailed({required Object e}) => 'Failed to read the app log: ${e}';
	@override String readCoreFailed({required Object e}) => 'Failed to read the kernel log: ${e}';
	@override String get copied => 'Copied (subscription URLs and other secrets are masked; the log file itself may still contain the raw address)';
	@override String get copy => 'Copy';
	@override String get refresh => 'Refresh';
	@override String get empty => 'No content';
}

// Path: trayShell
class _Translations$trayShell$fa implements Translations$trayShell$en {
	_Translations$trayShell$fa._(this._root);

	final TranslationsFa _root; // ignore: unused_field

	// Translations
	@override String get closeTitle => 'Close window';
	@override String get closeBody => 'Closing the window just puts Mclash in the tray — the kernel and system proxy keep working, and your network stays connected.\n\n· OK: minimize to the tray (to quit completely, right-click the tray icon → Quit)\n· Cancel: quit Mclash completely, stop the kernel and restore the system proxy\n\n(Your choice is remembered; next time you can use the tray icon directly)';
}

// Path: main.tray
class _Translations$main$tray$fa implements Translations$main$tray$en {
	_Translations$main$tray$fa._(this._root);

	final TranslationsFa _root; // ignore: unused_field

	// Translations
	@override String get menuOpen => 'بازکردن';
	@override String get menuExit => 'بستن';
}

/// The flat map containing all translations for locale <fa>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on TranslationsFa {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'BackupAndSyncWebdavScreen.webdavServerUrl' => 'آدرس URL سرور',
			'BackupAndSyncWebdavScreen.webdavRequired' => 'نمی‌تواند خالی باشد',
			'BackupAndSyncWebdavScreen.webdavLoginFailed' => 'ورود ناموفق بود:',
			'BackupAndSyncWebdavScreen.webdavListFailed' => 'دریافت لیست فایل ناموفق بود:',
			'LaunchFailedScreen.invalidProcess' => 'اجرای نرم‌افزار ناموفق بود [نام‌ اجرایی پروسه نامعتبر]، لطفا مجدد نرم‌افزار را در دایرکتوری دیگری نصب کنید',
			'LaunchFailedScreen.invalidProfile' => 'اجرای نرم‌افزار ناموفق بود [دسترسی به پروفایل ناموفق بود]، لطفا مجدد نرم افزار را نصب کنید',
			'LaunchFailedScreen.invalidVersion' => 'اجرای نرم‌افزار ناموفق بود [ورژن نامعتبر]، لطفا مجدد نرم‌افزار را نصب کنید',
			'LaunchFailedScreen.systemVersionLow' => 'راه اندازی برنامه ناموفق بود [نسخه سیستم خیلی کم است]',
			'LaunchFailedScreen.invalidInstallPath' => 'مسیر نصب نامعتبر است، لطفا مجدد در مسیر معتبر نصب کنید',
			'PerAppAndroidScreen.title' => 'پروکسی به‌تفکیک برنامه',
			'PerAppAndroidScreen.whiteListMode' => 'حالت لیست سفید',
			'PerAppAndroidScreen.whiteListModeTip' => 'وقتی فعال باشد: فقط برنامه‌هایی که انتخاب شده‌اند پروکسی می‌شوند؛ وقتی فعال نباشد: فقط برنامه‌هایی که انتخاب نشده‌اند پروکسی می‌شوند',
			'UserAgreementScreen.privacyFirst' => 'حریم‌خصوصی شما اولویت دارد',
			'UserAgreementScreen.agreeAndContinue' => 'پذیرفتن و ادامه',
			'NetCheckScreen.enterDomain' => 'لطفاً نام دامنه را وارد کنید',
			'NetCheckScreen.checking' => 'در حال بررسی...',
			'NetCheckScreen.aQueryFailed' => ({required Object p}) => 'خطا در پرس‌وجوی A: ${p}',
			'NetCheckScreen.aaaaQueryFailed' => ({required Object p}) => 'خطا در پرس‌وجوی AAAA: ${p}',
			'NetCheckScreen.success' => 'موفق',
			'NetCheckScreen.failed' => 'ناموفق',
			'NetCheckScreen.suspectedPollution' => 'مشکوک به مسمومیت DNS',
			'NetCheckScreen.domainLabel' => 'دامنه',
			'NetCheckScreen.checkButton' => 'بررسی',
			'NetCheckScreen.dnsSection' => '1. پرس‌وجوی DNS',
			'NetCheckScreen.directHttpSection' => '2. HTTP (از طریق TUN، ابتدا TUN را فعال کنید)',
			'NetCheckScreen.proxyHttpSection' => ({required Object p}) => '3. HTTP (از طریق پروکسی، پورت: ${p})',
			'NetCheckScreen.tunNotEnabled' => 'TUN فعال نیست',
			'NetCheckScreen.routeTableSection' => '4. جدول مسیریابی',
			'VersionUpdateScreen.versionReady' => ({required Object p}) => 'نسخه جدید [${p}] آماده است',
			'VersionUpdateScreen.update' => 'راه‌اندازی مجدد برای به‌روزرسانی',
			'VersionUpdateScreen.cancel' => 'الان‌ نه',
			'loginScreen.login' => 'ورود',
			'loginScreen.register' => 'ایجاد حساب',
			'loginScreen.forgotPassword' => 'فراموشی رمز عبور',
			'loginScreen.provider' => 'ارائه دهنده خدمات',
			'loginScreen.providerName' => 'کد/نام مستعار/URL ${_root.loginScreen.provider}',
			'loginScreen.account' => 'حساب',
			'loginScreen.email' => 'ایمیل',
			'loginScreen.password' => 'رمز عبور',
			'main.tray.menuOpen' => 'بازکردن',
			'main.tray.menuExit' => 'بستن',
			'meta.enable' => 'فعال‌سازی',
			'meta.disable' => 'غیرفعال',
			'meta.open' => 'باز کن',
			'meta.close' => 'بسته',
			'meta.quit' => 'خروج',
			'meta.add' => 'افزودن',
			'meta.remove' => 'حذف',
			'meta.removeConfirm' => 'آیا از حذف اطمینان دارین؟',
			'meta.edit' => 'ویرایش کنید',
			'meta.view' => 'بررسی',
			'meta.remark' => 'ملاحضات',
			'meta.byDefault' => 'پیش‌فرض',
			'meta.more' => 'بیشتر',
			'meta.tips' => 'اطلاعات',
			'meta.selectAll' => 'انتخاب همه',
			'meta.copy' => 'کپی',
			'meta.paste' => 'چسباندن',
			'meta.cut' => 'برش',
			'meta.save' => 'ذخیره کنید',
			'meta.ok' => 'خُب',
			'meta.cancel' => 'لغو',
			'meta.faq' => 'سوالات متداول',
			'meta.doc' => 'سند',
			'meta.htmlTools' => 'مجموعه ابزارهای HTML',
			'meta.download' => 'دانلود',
			'meta.loading' => 'درحال بارگذاری…',
			'meta.days' => 'روز',
			'meta.hours' => 'ساعت',
			'meta.minutes' => 'دقیقه',
			'meta.seconds' => 'دومین',
			'meta.milliseconds' => 'میلی‌ثانیه',
			'meta.search' => 'جستجو',
			'meta.searchNodeHint' => 'فیلتر گره‌ها (نام یا پروتکل)',
			'meta.connect' => 'اتصال',
			'meta.disconnect' => 'قطع‌ اتصال',
			'meta.connected' => 'وصل شد',
			'meta.disconnected' => 'قطع شد',
			'meta.connecting' => 'درحال اتصال',
			'meta.connectTimeout' => 'اتمام مهلت اتصال',
			'meta.timeout' => 'تایم اوت',
			'meta.latencyTest' => 'بررسی تاخیر',
			'meta.networkCheck' => 'بررسی شبکه',
			'meta.language' => 'زبان',
			'meta.next' => 'بعدی',
			'meta.done' => 'انجام‌شد',
			'meta.apply' => 'درخواست دادن',
			'meta.refresh' => 'بارگذاری مجدد',
			'meta.update' => 'تجدید',
			'meta.updateInterval' => 'فاصله‌ی به‌روزرسانی',
			'meta.updateInterval5mTips' => 'حداقل: 5 متر',
			'meta.updateIntervalPreferByProfile' => 'اولویت با تنظیمات ارائه‌دهنده',
			'meta.updateFailed' => ({required Object p}) => 'به‌روزرسانی ناموفق بود:${p}',
			'meta.none' => 'هیچ‌کدام',
			'meta.reset' => 'ریست',
			'meta.authentication' => 'مجوز',
			'meta.user' => 'کاربر',
			'meta.account' => 'نام‌کاربری',
			'meta.password' => 'رمز‌عبور',
			'meta.decryptPassword' => 'دکريپت رمز‌عبور',
			'meta.required' => 'الزامی',
			'meta.go' => 'ادامه',
			'meta.other' => 'دیگر',
			'meta.dns' => 'DNS',
			'meta.url' => 'URL',
			'meta.urlInvalid' => 'URL نامعتبر',
			'meta.copyUrl' => 'کپی‌کردن لینک',
			'meta.openUrl' => 'بازکردن لینک',
			'meta.coreSettingTips' => 'توجه: پس از تغییر پیکربندی، باید دوباره وصل شوید تا اعمال شود',
			'meta.overwrite' => 'لغو',
			'meta.overwriteAppend' => 'لغو الحاقی',
			'meta.overwriteTips' => 'پیکربندی اصلی <- لغو سفارشی <- لغو برنامه',
			'meta.noOverwrite' => 'رونویسی نکنید',
			'meta.diversionTemplates' => 'الگوی تریاژ',
			'meta.ruleProviders' => 'ارائه دهنده قانون',
			'meta.ruleTemplates' => 'الگوی قانون',
			'meta.proxyGroupsTemplates' => 'الگوی گروه نمایندگان',
			'meta.proxyGroups' => 'گروه نمایندگان',
			'meta.proxyNodeList' => 'فهرست گره‌های پروکسی',
			'meta.proxyNodeFailure' => ({required Object p}) => 'گره‌های پروکسی زیر منقضی شده و به طور خودکار حذف شده‌اند: ${p}',
			'meta.externalController' => 'کنترل خارجی',
			'meta.secret' => 'Secret',
			'meta.tcpConcurrent' => 'دست دادن همزمان TCP',
			'meta.globalClientFingerprint' => 'اثر انگشت جهانی TLS',
			'meta.allowLanAccess' => 'دسترسی به دستگاه LAN',
			'meta.mixedPort' => 'پورت پروکسی هیبریدی',
			'meta.logLevel' => 'سطح ورود به سیستم',
			'meta.findProcessMode' => 'حالت تطابق فرآیند',
			'meta.tcpkeepAliveInterval' => 'فاصله حفظ زنده TCP',
			'meta.delayTestUrl' => 'URL تست تأخیر',
			'meta.delayTestTimeout' => 'مهلت زمانی تست تاخیری (میلی‌ثانیه)',
			'meta.tun' => 'TUN',
			'meta.ntp' => 'NTP',
			'meta.tls' => 'TLS',
			'meta.geoDownloadByProxy' => 'دانلود Geo RuleSet با استفاده از یک پروکسی',
			'meta.geoRulesetTips' => 'Geosite/Geoip به RuleSet مربوطه تبدیل می شود',
			'meta.sniffer' => 'بو کشیدن',
			'meta.userAgent' => 'UserAgent',
			'meta.launchAtStartup' => 'اجرا در راه‌اندازی',
			'meta.launchAtStartupRunAsAdmin' => 'لطفاً Mclash را به عنوان مدیر راه اندازی مجدد کنید',
			'meta.tunModeRunAsAdmin' => 'حالت TUN نیازمند مجوز مدیر سیستم می‌باشد لطفا نرم‌افزار را مجدد با حالت مدیر (administrator) راه‌اندازی کنید',
			'meta.portableMode' => 'حالت قابل‌حمل',
			'meta.portableModeDisableTips' => 'اگر نیاز دارین از حالت قابل‌حمل خارج شوید لطفا از [mclash] خارج شده و به‌صورت دستی پوشه [portable] هم مسیر با فایل [mclash.exe] را حذف کنید',
			'meta.autoConnectAfterLaunch' => 'اتصال خودکار پس‌از راه‌اندازی',
			'meta.autoConnectAtBoot' => 'اتصال خودکار پس از روشن شدن سیستم',
			'meta.autoConnectAtBootTips' => 'پشتیبانی سیستم مورد نیاز است؛ برخی سیستم‌ها ممکن است نیاز به فعال بودن [شروع خودکار] نیز داشته باشند.',
			'meta.hideAfterLaunch' => 'پنهان کردن پنجره پس از راه اندازی',
			'meta.autoSetSystemProxy' => 'تنظیم خودکار حالت پروکسی سیستم پس‌از اتصال',
			'meta.bypassSystemProxy' => 'نام های دامنه ای که مجاز به دور زدن پراکسی سیستم هستند',
			'meta.excludeFromRecent' => 'پنهان شدن از وظایف اخیر',
			'meta.hideDockIcon' => 'پنهان کردن آیکون داک',
			'meta.showTrayTraffic' => 'نمایش اطلاعات ترافیک در سینی سیستم',
			'meta.wakeLock' => 'قفل بیدارباش',
			'meta.website' => 'وبسایت',
			'meta.rule' => 'قانون',
			'meta.global' => 'عمومی',
			'meta.direct' => 'مستقیم',
			'meta.qrcode' => 'کد QR',
			'meta.qrcodeTooLong' => 'متن برای نمایش خیلی طولانی است',
			'meta.qrcodeShare' => 'اشتراک کدQR',
			'meta.qrcodeScan' => 'اسکن QRکد',
			'meta.qrcodeScanResult' => 'نتایج اسکن',
			'meta.backupAndSync' => 'پشتیبان‌گیری و همگام‌سازی',
			'meta.export' => 'خروجی‌گرفتن',
			'meta.send' => 'ارسال کنید',
			'meta.sendConfirm' => 'ارسال را تایید کرد؟',
			'meta.log' => 'ورود به سیستم',
			'meta.coreLog' => 'گزارش هسته',
			'meta.appLog' => 'گزارش برنامه',
			'meta.core' => 'هسته',
			'meta.help' => 'کمک کند',
			'meta.tutorial' => 'آموزش',
			'meta.board' => 'پانل',
			'meta.boardOnline' => 'با استفاده از پنل آنلاین',
			'meta.boardOnlineUrl' => 'آدرس پنل آنلاین',
			'meta.boardLocalPort' => 'پورت پانل محلی',
			'meta.alwayOnVPN' => 'اتصال همیشه باز',
			'meta.disableFontScaler' => 'غیرفعال‌سازی مقیاس‌بندی فونت(با راه‌اندازی مجدد اعمال می‌شود)',
			'meta.autoOrientation' => 'چرخش صفحه را دنبال کنید',
			'meta.restartTakesEffect' => 'با راه‌اندازی مجدد اعمال می‌شود',
			'meta.reconnectTakesEffect' => 'پس از اتصال مجدد، اعمال خواهد شد.',
			'meta.runtimeProfile' => 'پیکربندی زمان اجرا',
			'meta.willCompleteAfterRebootInstall' => 'لطفاً دستگاه خود را مجدداً راه اندازی کنید تا نصب افزونه سیستم تکمیل شود.',
			'meta.requestNeedsUserApproval' => '۱. لطفاً به Mclash اجازه دهید افزونه‌های سیستمی را در [تنظیمات سیستم] - [حریم خصوصی و امنیت] نصب کند. ۲. : [تنظیمات سیستم] - [عمومی] - [موارد ورود و افزونه‌ها - افزونه‌های شبکه] [mclashServiceSE] را فعال کنید. پس از اتمام، دوباره متصل شوید.',
			'meta.FullDiskAccessPermissionRequired' => 'لطفاً مجوز mclashServiceSE را در [تنظیمات سیستم]-[حریم خصوصی و امنیت]-[دسترسی کامل به دیسک] فعال کنید و دوباره متصل شوید.',
			'meta.proxy' => 'بازیگری',
			'meta.theme' => 'موضوع',
			'meta.tvMode' => 'حالت تلویزیون',
			'meta.autoUpdate' => 'به روز رسانی خودکار',
			'meta.updateChannel' => 'کانال به‌روزرسانی خودکار',
			'meta.hasNewVersion' => ({required Object p}) => 'به‌روزرسانی نسخه ${p} ',
			'meta.autoDownloadPkg' => 'دانلود خودکار بسته‌های به‌روزرسانی',
			'meta.devOptions' => 'تنظیمات توسعه‌دهندگان',
			'meta.about' => 'درباره',
			'meta.name' => 'نام',
			'meta.version' => 'نسخه',
			'meta.sort' => 'مرتب‌سازی',
			'meta.share' => 'اشتراک گذاری',
			'meta.importFromClipboard' => 'افزودن از کلیپ‌برد',
			'meta.exportToClipboard' => 'صادرات به کلیپ بورد',
			'meta.server' => 'سرور',
			'meta.port' => 'بندر',
			'meta.donate' => 'اهدا کنید',
			'meta.setting' => 'تنظیمات',
			'meta.settingCore' => 'تنظیمات اصلی',
			'meta.settingApp' => 'تنظیمات برنامه',
			'meta.coreOverwrite' => 'Core Override',
			'meta.iCloud' => 'iCloud',
			'meta.webdav' => 'Webdav',
			'meta.lanSync' => 'LAN Sync',
			'meta.lanSyncNotQuitTips' => 'قبل از تکمیل همگام‌سازی از این قسمت خارج نشوید',
			'meta.deviceNoSpace' => 'فضای خالی کافی ندارید',
			'meta.hideSystemApp' => 'برنامه های سیستم را مخفی کنید',
			'meta.hideAppIcon' => 'پنهان کردن نماد برنامه',
			'meta.openDir' => 'بازکردن دایرکتوری فایل',
			'meta.type' => 'نوع',
			'meta.fileNotExist' => ({required Object p}) => 'فایل وجود ندارد:${p}',
			'meta.buyProfile' => 'خرید پروفایل',
			'meta.myProfiles' => 'پروفایل‌ها',
			'meta.profileEdit' => 'ویرایش پروفایل',
			'meta.profileNeedActive' => 'ابتدا این پروفایل را به‌عنوان پروفایل فعلی تنظیم کنید، سپس اتصال را فعال/دوباره متصل کنید',
			'meta.profileUrlOrContent' => ({required Object p}) => 'پیوند پیکربندی ${p}',
			'meta.tabHome' => 'خانه',
			'meta.tabNodes' => 'گره‌ها',
			'meta.tabPlans' => 'طرح‌ها',
			'meta.tabMe' => 'من',
			'permission.camera' => 'دوربین',
			'permission.screen' => 'ضبط صفحه',
			'permission.appQuery' => 'Get Application List',
			'permission.request' => ({required Object p}) => 'مجوزهای [${p}] را فعال کنید',
			'permission.requestNeed' => ({required Object p}) => 'لطفاً مجوز [${p}] را فعال کنید',
			'tls.certificate' => 'گواهی',
			'tls.privateKey' => 'کلید خصوصی',
			'tls.customTrustCert' => 'گواهی های سفارشی',
			'tun.stack' => 'پشته شبکه',
			'tun.inet4Address' => 'محدوده آدرس IPv4',
			'tun.dnsHijack' => 'ربودن DNS',
			'tun.strictRoute' => 'مسیریابی دقیق',
			'tun.tunDefaultRoute' => 'مسیر پیش‌فرض',
			'tun.icmpForward' => 'ارسال ICMP',
			'tun.allowBypass' => 'به برنامه‌ها اجازه دهید VPN را دور بزنند',
			'tun.appendHttpProxy' => 'پیوست دادن پروکسی HTTP به وی‌پی‌ان',
			'tun.bypassHttpProxyDomain' => 'دامنه ها مجاز به دور زدن پروکسی HTTP هستند',
			'dns.listen' => 'آدرس گوش دادن',
			'dns.fakeIp' => 'fake-ip',
			'dns.fallback' => 'Fallback',
			'dns.preferH3' => 'اولویت DoH H3',
			'dns.useHosts' => 'استفاده از هاست ها',
			'dns.useSystemHosts' => 'استفاده از هاست های سیستم',
			'dns.enhancedMode' => 'حالت پیشرفته',
			'dns.fakeIPFilterMode' => 'حالت فیلتر ${_root.dns.fakeIp}',
			'dns.fakeIPFilter' => 'فیلتر ${_root.dns.fakeIp}',
			'dns.respectRules' => 'رعایت قوانین',
			'dns.nameServer' => 'سرور DNS',
			'dns.defaultNameServer' => '${_root.meta.byDefault} ${_root.dns.nameServer}',
			'dns.proxyNameServer' => '${_root.meta.proxy} ${_root.dns.nameServer}',
			'dns.directNameServer' => '${_root.meta.direct} ${_root.dns.nameServer}',
			'dns.fallbackNameServer' => '${_root.dns.fallback} ${_root.dns.nameServer}',
			'dns.fallbackGeoIp' => '${_root.dns.fallback} GeoIp',
			'dns.fallbackGeoIpCode' => '${_root.dns.fallback} GeoIpCode',
			'sniffer.overrideDest' => 'پوشش',
			'profilePatchMode.currentSelected' => 'فعلی انتخاب شده',
			'profilePatchMode.overwrite' => 'Overwrite داخلی',
			'profilePatchMode.noOverwrite' => 'داخلی - رونویسی نشده است',
			'sendOrReceiveNotMatch' => ({required Object p}) => 'لطفا از [${p}] استفاده کنید',
			'targetConnectFailed' => ({required Object p}) => 'اتصال به [${p}] ناموفق بود، لطفاً مطمئن شوید که دستگاه در همان LAN است',
			'edgeRuntimeNotInstalled' => 'زمان اجرا Edge WebView2 روی دستگاه فعلی نصب نشده است و صفحه قابل نمایش نیست لطفاً زمان اجرا Edge WebView2 (x64) را بارگیری و نصب کنید، برنامه را مجدداً راه اندازی کنید و دوباره امتحان کنید.',
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
			'logScreen.refresh' => 'Refresh',
			_ => null,
		} ?? switch (path) {
			'logScreen.empty' => 'No content',
			'trayShell.closeTitle' => 'Close window',
			'trayShell.closeBody' => 'Closing the window just puts Mclash in the tray — the kernel and system proxy keep working, and your network stays connected.\n\n· OK: minimize to the tray (to quit completely, right-click the tray icon → Quit)\n· Cancel: quit Mclash completely, stop the kernel and restore the system proxy\n\n(Your choice is remembered; next time you can use the tray icon directly)',
			_ => null,
		};
	}
}
