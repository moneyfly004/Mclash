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
		'HK': 'هنگ‌کنگ',
		'TW': 'تایوان',
		'MO': 'ماکائو',
		'CN': 'چین',
		'JP': 'ژاپن',
		'KR': 'کره جنوبی',
		'SG': 'سنگاپور',
		'MY': 'مالزی',
		'TH': 'تایلند',
		'VN': 'ویتنام',
		'PH': 'فیلیپین',
		'ID': 'اندونزی',
		'KH': 'کامبوج',
		'US': 'ایالات متحده',
		'CA': 'کانادا',
		'MX': 'مکزیک',
		'GB': 'بریتانیا',
		'DE': 'آلمان',
		'FR': 'فرانسه',
		'NL': 'هلند',
		'RU': 'روسیه',
		'IT': 'ایتالیا',
		'ES': 'اسپانیا',
		'CH': 'سوئیس',
		'SE': 'سوئد',
		'NO': 'نروژ',
		'FI': 'فنلاند',
		'DK': 'دانمارک',
		'PL': 'لهستان',
		'AT': 'اتریش',
		'IE': 'ایرلند',
		'UA': 'اوکراین',
		'TR': 'ترکیه',
		'PT': 'پرتغال',
		'CZ': 'چک',
		'RO': 'رومانی',
		'BE': 'بلژیک',
		'GR': 'یونان',
		'HU': 'مجارستان',
		'IL': 'اسرائیل',
		'AE': 'امارات متحده عربی',
		'SA': 'عربستان سعودی',
		'EG': 'مصر',
		'ZA': 'آفریقای جنوبی',
		'NG': 'نیجریه',
		'AU': 'استرالیا',
		'NZ': 'نیوزیلند',
		'BR': 'برزیل',
		'AR': 'آرژانتین',
		'CL': 'شیلی',
		'CO': 'کلمبیا',
		'IN': 'هند',
		'PK': 'پاکستان',
		'XX': 'سایر',
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
	@override late final _Translations$ordersScreen$fa ordersScreen = _Translations$ordersScreen$fa._(_root);
	@override late final _Translations$payment$fa payment = _Translations$payment$fa._(_root);
	@override late final _Translations$planScreen$fa planScreen = _Translations$planScreen$fa._(_root);
	@override late final _Translations$authScreen$fa authScreen = _Translations$authScreen$fa._(_root);
	@override late final _Translations$updatePrompt$fa updatePrompt = _Translations$updatePrompt$fa._(_root);
	@override late final _Translations$clearData$fa clearData = _Translations$clearData$fa._(_root);
	@override late final _Translations$apiError$fa apiError = _Translations$apiError$fa._(_root);
	@override late final _Translations$subNotice$fa subNotice = _Translations$subNotice$fa._(_root);
	@override late final _Translations$settingItems$fa settingItems = _Translations$settingItems$fa._(_root);
	@override late final _Translations$tunScreen$fa tunScreen = _Translations$tunScreen$fa._(_root);
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
	@override String get close => 'بستن';
	@override String get quit => 'خروج';
	@override String get add => 'افزودن';
	@override String get remove => 'حذف';
	@override String get removeConfirm => 'آیا از حذف اطمینان دارید؟';
	@override String get edit => 'ویرایش کنید';
	@override String get view => 'بررسی';
	@override String get remark => 'ملاحظات';
	@override String get byDefault => 'پیش‌فرض';
	@override String get more => 'بیشتر';
	@override String get tips => 'اطلاعات';
	@override String get selectAll => 'انتخاب همه';
	@override String get copy => 'کپی';
	@override String get paste => 'چسباندن';
	@override String get cut => 'برش';
	@override String get save => 'ذخیره کنید';
	@override String get ok => 'تأیید';
	@override String get cancel => 'لغو';
	@override String get faq => 'سوالات متداول';
	@override String get doc => 'سند';
	@override String get htmlTools => 'مجموعه ابزارهای HTML';
	@override String get download => 'دانلود';
	@override String get loading => 'درحال بارگذاری…';
	@override String get days => 'روز';
	@override String get hours => 'ساعت';
	@override String get minutes => 'دقیقه';
	@override String get seconds => 'ثانیه';
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
	@override String get apply => 'اعمال';
	@override String get refresh => 'بارگذاری مجدد';
	@override String get update => 'به‌روزرسانی';
	@override String get updateInterval => 'فاصله‌ی به‌روزرسانی';
	@override String get updateInterval5mTips => 'حداقل: ۵ دقیقه';
	@override String get updateIntervalPreferByProfile => 'اولویت با تنظیمات ارائه‌دهنده';
	@override String updateFailed({required Object p}) => 'به‌روزرسانی ناموفق بود:${p}';
	@override String get none => 'هیچ‌کدام';
	@override String get reset => 'ریست';
	@override String get authentication => 'احراز هویت';
	@override String get user => 'کاربر';
	@override String get account => 'نام‌کاربری';
	@override String get password => 'رمز‌عبور';
	@override String get decryptPassword => 'دکریپت رمز‌عبور';
	@override String get required => 'الزامی';
	@override String get go => 'ادامه';
	@override String get other => 'دیگر';
	@override String get dns => 'DNS';
	@override String get url => 'URL';
	@override String get urlInvalid => 'URL نامعتبر';
	@override String get copyUrl => 'کپی‌کردن لینک';
	@override String get openUrl => 'بازکردن لینک';
	@override String get coreSettingTips => 'توجه: پس از تغییر پیکربندی، باید دوباره وصل شوید تا اعمال شود';
	@override String get overwrite => 'بازنویسی';
	@override String get overwriteAppend => 'بازنویسی الحاقی';
	@override String get overwriteTips => 'پیکربندی اصلی <- بازنویسی سفارشی <- بازنویسی برنامه';
	@override String get noOverwrite => 'رونویسی نکنید';
	@override String get diversionTemplates => 'الگوی تریاژ';
	@override String get ruleProviders => 'ارائه دهنده قانون';
	@override String get ruleTemplates => 'الگوی قانون';
	@override String get proxyGroupsTemplates => 'الگوهای گروه پروکسی';
	@override String get proxyGroups => 'گروه‌های پروکسی';
	@override String get proxyNodeList => 'فهرست گره‌های پروکسی';
	@override String proxyNodeFailure({required Object p}) => 'گره‌های پروکسی زیر منقضی شده و به طور خودکار حذف شده‌اند: ${p}';
	@override String get externalController => 'کنترل خارجی';
	@override String get secret => 'کلید مخفی';
	@override String get tcpConcurrent => 'دست دادن همزمان TCP';
	@override String get globalClientFingerprint => 'اثر انگشت جهانی TLS';
	@override String get allowLanAccess => 'دسترسی به دستگاه LAN';
	@override String get mixedPort => 'پورت پروکسی هیبریدی';
	@override String get logLevel => 'سطح گزارش';
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
	@override String get portableModeDisableTips => 'اگر نیاز دارید از حالت قابل‌حمل خارج شوید لطفا از [mclash] خارج شده و به‌صورت دستی پوشه [portable] هم مسیر با فایل [mclash.exe] را حذف کنید';
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
	@override String get log => 'گزارش';
	@override String get coreLog => 'گزارش هسته';
	@override String get appLog => 'گزارش برنامه';
	@override String get core => 'هسته';
	@override String get help => 'راهنما';
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
	@override String get proxy => 'پروکسی';
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
	@override String get port => 'پورت';
	@override String get donate => 'اهدا کنید';
	@override String get setting => 'تنظیمات';
	@override String get settingCore => 'تنظیمات هسته';
	@override String get settingApp => 'تنظیمات برنامه';
	@override String get coreOverwrite => 'Core Override';
	@override String get iCloud => 'iCloud';
	@override String get webdav => 'Webdav';
	@override String get lanSync => 'همگام‌سازی LAN';
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
	@override String get appQuery => 'دریافت فهرست برنامه‌ها';
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
	@override String get listen => 'آدرس شنود';
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
	@override String get overrideDest => 'بازنویسی مقصد';
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
	@override String get accountBalance => 'موجودی';
	@override String get expireAt => 'انقضا';
	@override String get remainingDays => 'روز باقی‌مانده';
	@override String get deviceCount => 'دستگاه‌ها';
	@override String get myOrders => 'سفارش‌های من';
	@override String get deviceManagement => 'مدیریت دستگاه‌ها';
	@override String get changePassword => 'تغییر رمز عبور';
	@override String get clearLocalData => 'پاک کردن داده‌های محلی (پیش از حذف برنامه)';
	@override String get profileManagementDev => 'مدیریت پروفایل (توسعه‌دهنده)';
	@override String get tunAdapter => 'آداپتور مجازی TUN';
	@override String get checkUpdate => 'بررسی به‌روزرسانی';
	@override String get retry => 'تلاش مجدد';
	@override String get loadFailed => 'بارگذاری اطلاعات حساب ناموفق بود: ممکن است ورود منقضی شده یا شبکه در دسترس نباشد.\nبرای تلاش مجدد «بارگذاری مجدد» را در بالا سمت راست بزنید؛ اگر باز هم ناموفق بود، دوباره وارد شوید.';
	@override String get logoutConfirm => 'از حساب خارج می‌شوید؟';
	@override String get boardNoKernel => 'داشبورد داده‌های زنده هسته (اتصال، ترافیک، تطبیق قوانین) را نشان می‌دهد.\n\nهسته در حال اجرا نیست، پس داشبورد توخالی خواهد بود.\nبرای باز کردن آن به‌هرحال «تأیید» را بزنید، یا برای اتصال ابتدا از تب خانه وصل شوید و «لغو» را انتخاب کنید.';
	@override String get boardOpened => 'داشبورد در مرورگر شما باز شد؛ گره یا قانون را همان‌جا تغییر دهید و برنامه تا حدود ۵ ثانیه هم‌گام می‌شود.';
}

// Path: homeScreen
class _Translations$homeScreen$fa implements Translations$homeScreen$en {
	_Translations$homeScreen$fa._(this._root);

	final TranslationsFa _root; // ignore: unused_field

	// Translations
	@override String expiresOn({required Object date}) => 'انقضا ${date}';
	@override String devicesText({required Object text}) => 'دستگاه‌ها ${text}';
	@override String get upgrade => 'ارتقا';
	@override String get quickCountries => 'فیلتر سریع کشور';
	@override String nodeCount({required Object count}) => '${count} گره';
	@override String get autoBestTip => 'گرهی با کمترین تأخیر را از میان همه کشورها انتخاب می‌کند (حالت خودکار)';
	@override String get autoBest => 'بهترین خودکار';
	@override String pickCountryTip({required Object label}) => 'کم‌تأخیرترین گره موجود در «${label}» را خودکار انتخاب و ثابت می‌کند';
	@override String get autoNoBetter => 'از قبل در حالت خودکار هستید (گره بهتری پیدا نشد)';
	@override String switchedBest({required Object name}) => 'به بهترین گره تغییر یافت: ${name}';
	@override String switchedCountry({required Object country, required Object node, required Object ms}) => 'به سریع‌ترین گره ${country} تغییر یافت: ${node}${ms}';
	@override String filterCountryFailed({required Object country, required Object err}) => 'فیلتر بر اساس ${country} انجام شد؛ تغییر گره ناموفق بود: ${err}';
	@override String deviceFullCount({required Object used, required Object limit}) => 'دستگاه‌های فعلی ${used}/${limit}\n\n';
	@override String get deviceFullUpgradeHint => 'با ارتقای سقف دستگاه، اتصال بلافاصله برقرار می‌شود (پیشنهادی)؛ می‌توانید دستگاه‌های بی‌استفاده را هم حذف کنید تا یک جا آزاد شود.';
	@override String get later => 'بعداً';
	@override String get upgradeDeviceCount => 'ارتقای سقف دستگاه';
	@override String get cannotConnect => 'اتصال ممکن نیست';
	@override String get freshnessNever => 'هنوز هم‌گام نشده · برای بارگذاری مجدد بزنید';
	@override String get freshnessJustNow => 'همین حالا به‌روزرسانی شد · مدیریت دستگاه‌ها را بزنید';
	@override String freshnessMinutes({required Object minutes}) => '${minutes} دقیقه پیش · مدیریت دستگاه‌ها را بزنید';
	@override String freshnessStale({required Object minutes}) => '${minutes} دقیقه پیش · برای بارگذاری مجدد بزنید';
	@override String get subscriptionAutoSync => 'هم‌گام‌سازی خودکار اشتراک';
	@override String get connecting => 'در حال اتصال…';
	@override String get disconnecting => 'در حال قطع اتصال…';
	@override String get tapToDisconnect => 'برای قطع اتصال کلید را بزنید';
	@override String get tapToConnect => 'برای اتصال کلید را بزنید';
	@override String get currentNode => 'گره فعلی';
	@override String get noNodeSelected => 'هیچ گرهی انتخاب نشده';
	@override String get switchAction => 'تغییر';
	@override String get realtimeSpeed => 'سرعت لحظه‌ای';
	@override String get totalTraffic => 'کل ترافیک';
	@override String get subSyncedNotReady => 'اشتراک دانلود شد، اما پروفایل هنوز آماده نیست. کمی بعد دوباره تلاش کنید.';
	@override String get noPlan => 'این حساب هنوز طرح فعالی ندارد. ابتدا یک طرح بخرید.';
	@override String get loginExpired => 'ورود شما منقضی شده است. لطفاً دوباره وارد شوید.';
	@override String get syncingWait => 'در حال هم‌گام‌سازی اشتراک، کمی صبر کنید.';
	@override String syncFailedNetwork({required Object message}) => 'هم‌گام‌سازی اشتراک ناموفق بود: ${message}\nشبکه را بررسی کنید و دوباره تلاش کنید.';
	@override String get syncFailed => 'هم‌گام‌سازی اشتراک ناموفق بود، کمی بعد دوباره تلاش کنید.';
	@override String get resetProxy => 'ریست';
	@override String latencySuffix({required Object ms}) => ' (${ms} میلی‌ثانیه)';
}

// Path: nodesScreen
class _Translations$nodesScreen$fa implements Translations$nodesScreen$en {
	_Translations$nodesScreen$fa._(this._root);

	final TranslationsFa _root; // ignore: unused_field

	// Translations
	@override String updatedCount({required Object count}) => 'اشتراک به‌روزرسانی شد: ${count} گره';
	@override String updateFailed({required Object message}) => 'به‌روزرسانی ناموفق بود: ${message}';
	@override String get updateFailedNetwork => 'به‌روزرسانی ناموفق بود، شبکه را بررسی کنید';
	@override String testDone({required Object ok, required Object fail}) => 'تست سرعت تمام شد: ${ok} در دسترس، ${fail} بی‌پاسخ (ممکن است آفلاین باشد)';
	@override String switchedTo({required Object name}) => 'به ${name} تغییر یافت';
	@override String switchFailed({required Object message}) => 'تغییر گره ناموفق بود: ${message}\n(تغییر گره به هسته در حال اجرا نیاز دارد؛ ابتدا کلید را از تب خانه روشن کنید.)';
	@override String selectedAfterConnect({required Object name}) => '${name} انتخاب شد (پس از اتصال اعمال می‌شود)';
	@override String get title => 'گره‌ها';
	@override String get searchNode => 'جستجوی گره';
	@override String get sortByLatency => 'مرتب‌سازی بر اساس تأخیر';
	@override String get updateSubscription => 'به‌روزرسانی اشتراک';
	@override String get viewByGroup => 'نمایش بر اساس گروه پروکسی';
	@override String get testAll => 'تست همه';
	@override String get searchHint => 'جستجوی گره / کشور / پروتکل';
	@override String get emptyNoNodes => 'هنوز گرهی در دسترس نیست.\nاشتراک‌ها خودکار هم‌گام می‌شوند؛ اگر همین حالا وارد شده‌اید کمی صبر کنید یا پایین را بارگذاری مجدد کنید.';
	@override String get emptyNoMatch => 'گرهی مطابق پیدا نشد.';
	@override String get reload => 'بارگذاری مجدد';
	@override String get currentInUse => 'فعلی (در استفاده)';
	@override String get current => 'فعلی';
	@override String get notTested => 'اندازه‌گیری نشده (در انتظار بارگذاری مجدد هسته)';
	@override String get timeout => 'تایم اوت';
	@override String get clear => 'پاک کردن';
	@override String get selectNode => 'انتخاب گره';
	@override String get emptyNoKernel => 'هنوز گرهی در دسترس نیست.\nابتدا کلید اتصال را از تب خانه روشن کنید.';
	@override String get openFullList => 'باز کردن فهرست کامل گره‌ها (جستجو / تست سرعت / گروه‌ها)';
}

// Path: nodeAuto
class _Translations$nodeAuto$fa implements Translations$nodeAuto$en {
	_Translations$nodeAuto$fa._(this._root);

	final TranslationsFa _root; // ignore: unused_field

	// Translations
	@override String get kernelStateUnavailable => 'وضعیت گره موقتاً از هسته در دسترس نیست؛ به‌طور خودکار دوباره تلاش می‌شود.';
	@override String backToFixedNode({required Object fixed}) => 'بازگشت به گره ثابت‌شده: ${fixed}';
	@override String get noUsableNodePickOne => 'گره قابل استفاده‌ای پیدا نشد. لطفاً از فهرست گره‌ها یکی را دستی انتخاب کنید.';
	@override String get noUsableNodeTryOne => 'گره قابل استفاده‌ای پیدا نشد. لطفاً از فهرست گره‌ها یکی را انتخاب کنید.';
	@override String autoConnectedBest({required Object bestNode, required Object bestMs}) => 'به‌طور خودکار به بهترین گره متصل شد: ${bestNode} (${bestMs} میلی‌ثانیه)';
	@override String get currentNodeUnreachable => 'گره فعلی به اینترنت دسترسی ندارد؛ به‌طور خودکار تغییر داده می‌شود…';
	@override String autoSwitchedToUsable({required Object target}) => 'به‌طور خودکار به یک گره قابل استفاده تغییر یافت: ${target}';
	@override String newNodesReloading({required Object missing}) => '${missing} گره تازه در اشتراک هنوز در هسته نیست؛ در حال بارگذاری مجدد…';
	@override String get kernelReloadedRetest => 'هسته با اشتراک جدید بارگذاری مجدد شد؛ تست سرعت را دوباره اجرا کنید.';
}

// Path: accountBlock
class _Translations$accountBlock$fa implements Translations$accountBlock$en {
	_Translations$accountBlock$fa._(this._root);

	final TranslationsFa _root; // ignore: unused_field

	// Translations
	@override String quotaFull({required Object used, required Object limit}) => 'جای دستگاه‌ها پر است (${used}/${limit}): این دستگاه هنوز در محدوده مجاز است و می‌تواند عادی وصل شود. برای افزودن دستگاه دیگر، سقف دستگاه را ارتقا دهید یا دستگاه‌های بی‌استفاده را حذف کنید.';
	@override String get banFallback => 'حساب شما غیرفعال شده و دیگر قابل استفاده نیست.';
	@override String get titleExpired => 'طرح منقضی شد';
	@override String get titleDeviceFull => 'سقف دستگاه پر شد';
	@override String get titleAccountDisabled => 'حساب غیرفعال شد';
	@override String get titlePlanDisabled => 'طرح غیرفعال شد';
	@override String get titleNoPlan => 'طرحی وجود ندارد';
	@override String get titleDeviceRemoved => 'این دستگاه حذف شد';
	@override String get titleServiceUnavailable => 'سرویس موقتاً در دسترس نیست';
	@override String get textExpired => 'طرح شما منقضی شده است. برای ادامه استفاده از گره‌های جهانی یک طرح بخرید.';
	@override String textDeviceFull({required Object used, required Object limit}) => 'سرور تشخیص داده است که این دستگاه از سقف دستگاه طرح (${used}/${limit}) فراتر رفته و در حال حاضر نمی‌تواند وصل شود. دستگاه‌های بی‌استفاده را در «من - مدیریت دستگاه‌ها» حذف کنید یا به طرحی با دستگاه بیشتر ارتقا دهید.';
	@override String get textAccountDisabled => 'حساب شما غیرفعال شده است. در صورت داشتن پرسش با پشتیبانی تماس بگیرید.';
	@override String get textPlanDisabled => 'طرح شما غیرفعال یا در وضعیت غیرعادی است، بنابراین امکان اتصال نیست. در صورت داشتن پرسش با پشتیبانی تماس بگیرید.';
	@override String get textNoPlan => 'هنوز طرحی نخریده‌اید. برای استفاده از گره‌های جهانی یکی بخرید.';
	@override String get textDeviceRemoved => 'این دستگاه حذف و از حساب خارج شد. لطفاً دوباره وارد شوید.';
	@override String get textServiceUnavailable => 'سرویس موقتاً در دسترس نیست. کمی بعد دوباره تلاش کنید؛ اگر ادامه داشت، اسکرین‌شات بگیرید و با پشتیبانی تماس بگیرید.';
	@override String remainingDays({required Object days}) => '${days} روز باقی مانده';
	@override String deviceUsage({required Object used, required Object limit}) => 'دستگاه‌ها ${used}/${limit}';
}

// Path: entitlementMsg
class _Translations$entitlementMsg$fa implements Translations$entitlementMsg$en {
	_Translations$entitlementMsg$fa._(this._root);

	final TranslationsFa _root; // ignore: unused_field

	// Translations
	@override String get tamperedTitle => 'وضعیت مجوز غیرعادی است';
	@override String get tamperedClock => 'عقب رفتن ساعت سیستم (یا دستکاری داده‌های مجوز محلی) شناسایی شد. لطفاً پیش از اتصال آنلاین شوید و یک بار تأیید انجام دهید.';
	@override String get tamperedLocal => 'داده‌های مجوز محلی خراب شده یا تغییر کرده‌اند. لطفاً پیش از اتصال آنلاین شوید و یک بار تأیید انجام دهید.';
	@override String get needVerifyTitle => 'تأیید آنلاین لازم است';
	@override String get needVerifyFirst => 'وضعیت طرح شما تأیید نشد: لطفاً به شبکه وصل شوید و وارد حساب شوید، سپس پیش از اتصال یک بار تأیید انجام دهید.';
	@override String get needVerifyRetry => 'وضعیت طرح شما تأیید نشد. لطفاً آنلاین شوید و دوباره تلاش کنید.';
	@override String get verifyFailedTitle => 'تأیید وضعیت طرح ممکن نیست';
	@override String get verifyFailedText => 'مهلت تأیید گذشته و سرور در دسترس نیست. شبکه را بررسی کنید و دوباره تلاش کنید (اگر همین حالا تمدید کرده‌اید، دوباره وارد شوید).';
	@override String get restrictedTitle => 'حساب محدود شده است';
	@override String get restrictedFallback => 'حساب یا طرح شما غیرفعال شده است، بنابراین امکان اتصال نیست.';
	@override String get expiredTitle => 'طرح منقضی شد';
	@override String expiredText({required Object date}) => 'طرح شما در ${date} منقضی شد. پروفایل اشتراک محلی پاک شده است. برای بازگرداندن آن، تمدید کنید و دوباره وارد شوید.';
}

// Path: devicesScreen
class _Translations$devicesScreen$fa implements Translations$devicesScreen$en {
	_Translations$devicesScreen$fa._(this._root);

	final TranslationsFa _root; // ignore: unused_field

	// Translations
	@override String get title => 'مدیریت دستگاه‌ها';
	@override String get currentPlan => 'طرح فعلی';
	@override String devicesText({required Object text}) => 'دستگاه‌ها ${text}';
	@override String get upgradeTitle => 'ارتقای دستگاه / تمدید زمان';
	@override String get upgradeSubtitle => 'دستگاه و روز را با هم اضافه کنید؛ یک قیمت، یک پرداخت';
	@override String get addDevices => 'افزودن دستگاه';
	@override String get noAddDevices => 'بدون تغییر';
	@override String addDevicesCount({required Object n}) => '+${n} دستگاه';
	@override String get addDays => 'افزودن روز';
	@override String get noExtend => 'بدون تمدید';
	@override String addDaysCount({required Object n, required Object months}) => '+${n} روز (${months} ماه)';
	@override String get priceFailed => 'دریافت قیمت ناموفق بود';
	@override String amountDue({required Object amount}) => 'مجموع ¥${amount}';
	@override String get requote => 'محاسبه مجدد';
	@override String get goPay => 'پرداخت';
	@override String get afterUpgrade => 'پس از ارتقا: ';
	@override String afterLimit({required Object limit}) => 'سقف دستگاه ${limit}';
	@override String afterExpire({required Object date}) => 'انقضا ${date}';
	@override String get pickSomething => 'حداقل چند دستگاه یا چند روز اضافه کنید';
	@override String get daysOnlyUnsupported => 'پنل هنوز «فقط تمدید زمان» را پشتیبانی نمی‌کند: لطفاً «افزودن دستگاه» را روی ۱ یا بیشتر بگذارید و دوباره تلاش کنید (یا برای فعال‌سازی با پشتیبانی تماس بگیرید).';
	@override String get paramsRejected => 'پارامترها پذیرفته نشد: لطفاً تعداد دستگاه و روز را دوباره انتخاب کنید.';
	@override String get subscriptionExpired => 'اشتراک منقضی شده و قابل ارتقا نیست. ابتدا آن را تمدید کنید یا طرح جدید بخرید.';
	@override String get orderIncomplete => 'اطلاعات سفارش کامل نیست. «محاسبه مجدد» را بزنید و دوباره تلاش کنید.';
	@override String get orderRegenerated => 'سفارش قبلی منقضی شد؛ سفارش تازه‌ای با همان تنظیمات ساخته شد.';
	@override String get payChannelIncomplete => 'اطلاعات سفارش یا کانال پرداخت کامل نیست. لطفاً محاسبه مجدد کنید و دوباره تلاش کنید.';
	@override String get noQrCode => 'سرور کد QR یا لینک پرداخت برنگرداند. لطفاً روش پرداخت دیگری انتخاب کنید یا بعداً تلاش کنید.';
	@override String payStartFailed({required Object err}) => 'شروع پرداخت ناموفق بود: ${err}';
	@override String get payCancelled => 'پرداخت لغو شد؛ پیش‌سفارش پاک شد.';
	@override String get balancePay => 'موجودی';
	@override String get noPayMethod => 'در حال حاضر روش پرداختی در دسترس نیست. بعداً تلاش کنید یا با پشتیبانی تماس بگیرید.';
	@override String balanceInsufficient({required Object balance, required Object amount}) => 'موجودی کافی نیست (¥${balance}، لازم: ¥${amount}).\nابتدا شارژ می‌کنید؟';
	@override String get choosePayMethod => 'انتخاب روش پرداخت';
	@override String balanceText({required Object balance}) => 'موجودی ¥${balance}';
	@override String balanceShort({required Object balance}) => 'موجودی ¥${balance} (کافی نیست، شارژ کنید)';
	@override String get unknownDevice => 'دستگاه ناشناس';
	@override String get online => '● آنلاین';
	@override String get offline => '○ آفلاین';
	@override String lastActive({required Object text}) => 'آخرین فعالیت ${text}';
	@override String get delete => 'حذف';
	@override String deleteConfirm({required Object name}) => 'دستگاه «${name}» حذف شود؟ بلافاصله از اتصال خارج می‌شود.';
	@override String get lastActiveJustNow => 'همین حالا';
	@override String lastActiveMinutes({required Object minutes}) => '${minutes} دقیقه پیش';
	@override String lastActiveToday({required Object time}) => 'امروز ${time}';
}

// Path: sysProxySheet
class _Translations$sysProxySheet$fa implements Translations$sysProxySheet$en {
	_Translations$sysProxySheet$fa._(this._root);

	final TranslationsFa _root; // ignore: unused_field

	// Translations
	@override String get reading => 'در حال خواندن…';
	@override String get unknown => 'نامشخص';
	@override String get kernelNotRunning => 'هسته در حال اجرا نیست (ابتدا کلید را از تب خانه روشن کنید)';
	@override String applied({required Object host, required Object port}) => 'اعمال شد · ${host}:${port}';
	@override String notSet({required Object reason}) => 'پروکسی سیستم تنظیم نشده — ${reason}';
	@override String notEffective({required Object port}) => 'بی‌اثر است (هیچ پروکسی سیستمی به ${port} اشاره نمی‌کند)';
	@override String readFailed({required Object err}) => 'خواندن ناموفق بود: ${err}';
	@override String get setRejected => 'تنظیم ناموفق بود: احتمالاً سیستم نوشتن را رد کرده است (یا برنامه پروکسی دیگری آن را بازنویسی کرده)';
	@override String get disableFailed => 'خاموش کردن ناموفق بود';
	@override String get portRange => 'پورت باید بین 1 و 65535 باشد';
	@override String portChanged({required Object value}) => 'پورت به ${value} تغییر کرد: یک بار اتصال را قطع و وصل کنید تا هسته روی پورت جدید گوش دهد';
	@override String get title => 'پروکسی سیستم';
	@override String desc({required Object host}) => 'آدرس پروکسی سیستم ثابت و برابر ${host} (بازگشت محلی) است و پورت همان پورت ترکیبی هسته است.';
	@override String get descWindows => 'این دقیقاً همان چیزی است که در تنظیمات Windows → شبکه و اینترنت → پروکسی می‌بینید.';
	@override String get reset => 'تنظیم مجدد';
	@override String get disable => 'خاموش کردن پروکسی سیستم';
	@override String get diagnostics => 'عیب‌یابی (آیا رابط کاربری همان مقادیر رجیستری را می‌خواند؟)';
	@override String get mixedPort => 'پورت ترکیبی';
	@override String get apply => 'اعمال';
}

// Path: logScreen
class _Translations$logScreen$fa implements Translations$logScreen$en {
	_Translations$logScreen$fa._(this._root);

	final TranslationsFa _root; // ignore: unused_field

	// Translations
	@override String readAppFailed({required Object e}) => 'خواندن گزارش برنامه ناموفق بود: ${e}';
	@override String readCoreFailed({required Object e}) => 'خواندن گزارش هسته ناموفق بود: ${e}';
	@override String get copied => 'کپی شد (URLهای اشتراک و دیگر داده‌های حساس پوشانده شده‌اند؛ شاید خود فایل گزارش هنوز آدرس خام را داشته باشد)';
	@override String get copy => 'کپی';
	@override String get refresh => 'بارگذاری مجدد';
	@override String get empty => 'محتوایی نیست';
}

// Path: trayShell
class _Translations$trayShell$fa implements Translations$trayShell$en {
	_Translations$trayShell$fa._(this._root);

	final TranslationsFa _root; // ignore: unused_field

	// Translations
	@override String get closeTitle => 'بستن پنجره';
	@override String get closeBody => 'بستن پنجره فقط Mclash را به سینی سیستم می‌فرستد — هسته و پروکسی سیستم به کار خود ادامه می‌دهند و اتصال شبکه شما برقرار می‌ماند.\n\n· تأیید: کوچک شدن به سینی سیستم (برای خروج کامل، روی آیکون سینی راست‌کلیک کنید → خروج)\n· لغو: خروج کامل از Mclash، توقف هسته و بازگرداندن پروکسی سیستم\n\n(انتخاب شما به خاطر سپرده می‌شود؛ بار بعد می‌توانید مستقیم از آیکون سینی استفاده کنید)';
}

// Path: ordersScreen
class _Translations$ordersScreen$fa implements Translations$ordersScreen$en {
	_Translations$ordersScreen$fa._(this._root);

	final TranslationsFa _root; // ignore: unused_field

	// Translations
	@override String get title => 'سفارش‌های من';
	@override String get orderInfoIncomplete => 'اطلاعات سفارش کامل نیست. صفحه را پایین بکشید تا بارگذاری مجدد شود و دوباره تلاش کنید.';
	@override String get payChannelIncomplete => 'اطلاعات کانال پرداخت کامل نیست. کمی بعد دوباره تلاش کنید.';
	@override String get noQrPayload => 'سرور کد QR یا لینک پرداخت برنگرداند. لطفاً روش پرداخت دیگری انتخاب کنید یا بعداً تلاش کنید.';
	@override String payStartFailed({required Object err}) => 'شروع پرداخت ناموفق بود: ${err}';
	@override String get noPayMethod => 'در حال حاضر روش پرداختی در دسترس نیست. کمی بعد دوباره تلاش کنید یا با پشتیبانی تماس بگیرید.';
	@override String get choosePayMethod => 'انتخاب روش پرداخت';
	@override String amountDue({required Object amount}) => 'مبلغ قابل پرداخت ¥${amount}';
	@override String get paidLabel => '● پرداخت‌شده';
	@override String get pendingLabel => '○ پرداخت‌نشده';
	@override String unknownStatus({required Object status}) => '✕ ${status}';
	@override String orderNoText({required Object orderNo}) => 'شماره سفارش ${orderNo}';
	@override String createdAtText({required Object createdAt}) => 'زمان ایجاد ${createdAt}';
	@override String get orderCanceled => 'سفارش لغو شد';
	@override String cancelFailed({required Object err}) => 'لغو ناموفق بود: ${err}\n(اگر سفارش قبلاً پرداخت یا لغو شده است، برای دیدن آخرین وضعیت صفحه را پایین بکشید.)';
	@override String get cancelOrder => 'لغو سفارش';
	@override String get continuePay => 'ادامه پرداخت';
}

// Path: payment
class _Translations$payment$fa implements Translations$payment$en {
	_Translations$payment$fa._(this._root);

	final TranslationsFa _root; // ignore: unused_field

	// Translations
	@override String get balancePay => 'پرداخت با موجودی';
	@override String get qrPay => 'پرداخت با اسکن';
	@override String get deductFromBalance => 'از موجودی حساب شما کسر می‌شود';
	@override String get openedInBrowser => 'صفحه پرداخت در مرورگر شما باز شد';
	@override String get scanWithAlipayWechat => 'با Alipay یا WeChat اسکن کنید';
	@override String orderNoText({required Object orderNo}) => 'شماره سفارش ${orderNo}';
	@override String payFailed({required Object err}) => 'پرداخت ناموفق بود: ${err}';
	@override String get notDetected => 'پرداختی شناسایی نشد. می‌توانید بعداً از «سفارش‌های من» ادامه دهید.';
	@override String get charging => 'در حال ارسال…';
	@override String get processing => 'در حال پردازش…';
	@override String get waitingPay => 'در انتظار پرداخت…';
	@override String get openPageFailed => 'صفحه پرداخت باز نشد. برای تلاش مجدد دکمه زیر را بزنید یا کد QR را اسکن کنید.';
	@override String get reopenPayPage => 'باز کردن دوباره صفحه پرداخت';
	@override String get payInBrowser => 'پرداخت در مرورگر';
	@override String get openAlipay => 'باز کردن Alipay';
	@override String get cancelOrder => 'لغو سفارش';
	@override String get confirmPay => 'تأیید پرداخت';
	@override String get retry => 'تلاش مجدد';
	@override String get paidAlready => 'پرداخت کرده‌ام';
	@override String get channelAlipay => 'Alipay';
	@override String get channelCodepayAlipay => 'Code Pay · Alipay';
	@override String get channelCodepayWechat => 'Code Pay · WeChat';
	@override String get channelCodepay => 'Code Pay';
	@override String get channelWechat => 'WeChat Pay';
	@override String get channelUsdt => 'USDT';
	@override String get channelUsdtTrc20 => 'USDT · TRC20';
	@override String get payFallback => 'پرداخت';
	@override String get errCsrf => 'مجوز ورود شما منقضی شده است (بررسی CSRF ناموفق بود).\nدر تب «من» صفحه را پایین بکشید یا دوباره وارد شوید، سپس تلاش کنید.';
	@override String get errAlipayLimit => 'پرداخت حضوری Alipay سقف هر تراکنش دارد (برای این فروشنده ¥1000) و این سفارش از آن بیشتر است.\nلطفاً از «پرداخت با موجودی» یا «Code Pay» استفاده کنید، یا برای افزایش سقف Alipay با پشتیبانی تماس بگیرید.';
	@override String get errNotSigned => 'اپلیکیشن Alipay برای این محصول پرداخت ثبت‌نام نکرده و این کانال موقتاً در دسترس نیست.\nلطفاً از «پرداخت با موجودی» یا «Code Pay» استفاده کنید، یا برای فعال‌سازی با پشتیبانی تماس بگیرید.';
	@override String get errOrderGone => 'این سفارش لغو یا منقضی شده است (پیش‌سفارش‌ها ۳۰ دقیقه اعتبار دارند).\n«محاسبه مجدد» را بزنید تا سفارش تازه‌ای ساخته شود، سپس پرداخت کنید.';
	@override String errNetwork({required Object err}) => 'شبکه در دسترس نیست: ${err}';
}

// Path: planScreen
class _Translations$planScreen$fa implements Translations$planScreen$en {
	_Translations$planScreen$fa._(this._root);

	final TranslationsFa _root; // ignore: unused_field

	// Translations
	@override String get recommended => 'پیشنهادی';
	@override String get devices => 'دستگاه‌ها';
	@override String balanceLabel({required Object amount}) => 'موجودی ¥${amount}';
	@override String get balanceInsufficient => ' (موجودی کافی نیست، ابتدا شارژ کنید)';
	@override String get total => 'مجموع';
	@override String get payNow => 'پرداخت';
	@override String get retry => 'تلاش مجدد';
	@override String get errIncompleteOrder => 'اطلاعات سفارش یا کانال پرداخت کامل نیست؛ پرداخت آغاز نمی‌شود.';
	@override String get payBalance => 'پرداخت با موجودی';
	@override String get payAlipay => 'Alipay';
	@override String get payWechat => 'WeChat Pay';
	@override String get payCodepay => 'Codepay';
	@override String get payCodepayAlipay => 'Codepay · Alipay';
	@override String get payCodepayWechat => 'Codepay · WeChat';
	@override String get payEpayAlipay => 'Epay · Alipay';
	@override String get payEpayWechat => 'Epay · WeChat';
	@override String get payUsdt => 'USDT';
	@override String get payUsdtTrc20 => 'USDT · TRC20';
	@override String get payStripe => 'Stripe';
	@override String get payPaypal => 'PayPal';
	@override String get payOnline => 'پرداخت آنلاین';
}

// Path: authScreen
class _Translations$authScreen$fa implements Translations$authScreen$en {
	_Translations$authScreen$fa._(this._root);

	final TranslationsFa _root; // ignore: unused_field

	// Translations
	@override String get saveAccountInfo => 'ذخیره اطلاعات حساب';
	@override String get autoLoginNextTime => 'دفعه بعد خودکار وارد شوید';
	@override String get needLoginNextTime => 'دفعه بعد باید دوباره وارد شوید';
	@override String get invalidEmail => 'لطفاً یک ایمیل معتبر وارد کنید';
	@override String get enterEmailFirst => 'لطفاً ابتدا یک ایمیل معتبر وارد کنید';
	@override String get passwordRequired => 'لطفاً رمز عبور را وارد کنید';
	@override String get wrongCredentials => 'ایمیل یا رمز عبور نادرست است';
	@override String get requestRejected => 'درخواست رد شد. کمی بعد دوباره تلاش کنید.';
	@override String get tooFrequent => 'تلاش‌های بیش از حد. کمی بعد دوباره تلاش کنید.';
	@override String get loginFailed => 'ورود ناموفق بود';
	@override String get username => 'نام کاربری';
	@override String get confirmPassword => 'تکرار رمز عبور';
	@override String get inviteCode => 'کد دعوت';
	@override String get emailCode => 'کد تأیید ایمیل';
	@override String get getCode => 'دریافت کد';
	@override String get registerAndLogin => 'ثبت‌نام و ورود';
	@override String usernameMinLength({required Object min}) => 'نام کاربری باید حداقل ${min} کاراکتر باشد';
	@override String get passwordMismatch => 'رمزهای عبور یکسان نیستند';
	@override String get emailCodeRequired => 'لطفاً کد تأیید ایمیل را وارد کنید';
	@override String get inviteCodeRequired => 'ثبت‌نام در این سایت به کد دعوت نیاز دارد';
	@override String get codeSentCheckEmail => 'کد تأیید ارسال شد. ایمیل خود را بررسی کنید.';
	@override String get registerSuccess => 'ثبت‌نام موفق بود. اکنون وارد شده‌اید.';
	@override String passwordHint({required Object min}) => 'حداقل ${min} کاراکتر، شامل حرف و رقم';
	@override String passwordTooShort({required Object min}) => 'رمز عبور باید حداقل ${min} کاراکتر باشد';
	@override String get passwordNeedsLetterAndDigit => 'رمز عبور باید هم حرف و هم رقم داشته باشد';
	@override String get registeredEmail => 'ایمیل ثبت‌شده';
	@override String get newPassword => 'رمز عبور جدید';
	@override String get confirmNewPassword => 'تکرار رمز عبور جدید';
	@override String get resetPassword => 'بازنشانی رمز عبور';
	@override String get resetCodeSent => 'اگر این ایمیل ثبت شده باشد، کد بازنشانی ارسال شده است (تا ۱۵ دقیقه معتبر است).';
	@override String get resetSuccess => 'رمز عبور بازنشانی شد. با رمز جدید وارد شوید.';
	@override String get changePasswordTitle => 'تغییر رمز عبور';
	@override String get currentPassword => 'رمز عبور فعلی';
	@override String get saveNewPassword => 'ذخیره رمز عبور جدید';
	@override String get newPasswordMismatch => 'رمزهای عبور جدید یکسان نیستند';
	@override String get changePasswordSuccess => 'رمز عبور تغییر کرد. لطفاً دوباره وارد شوید.';
}

// Path: updatePrompt
class _Translations$updatePrompt$fa implements Translations$updatePrompt$en {
	_Translations$updatePrompt$fa._(this._root);

	final TranslationsFa _root; // ignore: unused_field

	// Translations
	@override String get checking => 'در حال بررسی به‌روزرسانی…';
	@override String get checkFailed => 'بررسی به‌روزرسانی ناموفق بود. شبکه را بررسی کنید و دوباره تلاش کنید.';
	@override String alreadyLatest({required Object version}) => 'شما آخرین نسخه را دارید (${version}).';
	@override String newVersionFound({required Object version}) => 'نسخه جدید ${version} در دسترس است';
	@override String get installerDownloaded => 'نصب‌کننده در پس‌زمینه دانلود شد. برای تکمیل ارتقا «به‌روزرسانی» را بزنید.';
	@override String get downloadInBackground => 'برای دانلود و نصب آن «به‌روزرسانی» را بزنید (می‌توانید به استفاده از برنامه ادامه دهید؛ نصب‌کننده در پس‌زمینه دانلود می‌شود).';
	@override String get later => 'بعداً';
	@override String get updateNow => 'به‌روزرسانی';
	@override String installerNotReady({required Object version}) => 'نصب‌کننده هنوز دانلود نشده است.\n\nبرای باز کردن صفحه دانلود و دریافت دستی نصب‌کننده مناسب دستگاه خود «تأیید» را بزنید (نسخه ${version}).';
}

// Path: clearData
class _Translations$clearData$fa implements Translations$clearData$en {
	_Translations$clearData$fa._(this._root);

	final TranslationsFa _root; // ignore: unused_field

	// Translations
	@override String get itemLoginSession => 'نشست ورود';
	@override String get itemProfiles => 'پروفایل‌های اشتراک (profiles/)';
	@override String get itemSettings => 'تنظیمات برنامه و هسته';
	@override String get itemLatencyCache => 'کش تأخیر گره‌ها';
	@override String get itemLogs => 'گزارش‌های اجرا';
	@override String get itemRoutingData => 'داده‌های مسیریابی و فایل‌های موقت';
	@override String confirmBody({required Object items, required Object dir}) => 'داده‌های زیر که روی این دستگاه ذخیره شده‌اند پاک می‌شوند (این کار بازگشت‌پذیر نیست):\n\n${items}\n\nخودِ حساب و طرحی که خریده‌اید روی سرور هستند و آسیب نمی‌بینند؛ برای بازگرداندن اشتراک دوباره وارد شوید.\n\nپوشه داده‌ها: ${dir}\n(این کار را پیش از حذف برنامه انجام دهید: تنها در این صورت نصب دوباره از صفر شروع می‌شود و دوباره از شما ورود می‌خواهد)';
	@override String get confirmAgain => 'همین حالا پاک شود؟ پس از آن باید دوباره وارد شوید.';
	@override String clearedNotice({required Object count, required Object dir}) => '${count} مورد از داده‌های محلی پاک شد (شامل نشست ورود، بنابراین دفعه بعد که برنامه را باز کنید باید دوباره وارد شوید).\n\nحالا می‌توانید برای تکمیل حذف، خودِ برنامه را پاک کنید:\n· macOS: فایل Mclash.app را به سطل زباله بکشید (پوشه داده‌ها خالی شده است: ${dir})\n· Windows: Mclash را از کنترل پنل حذف کنید و وقتی پرسید داده‌های کاربر نگه داشته شود، «خیر» را انتخاب کنید';
	@override String clearFailed({required Object error}) => 'پاک کردن ناموفق بود: ${error}';
}

// Path: apiError
class _Translations$apiError$fa implements Translations$apiError$en {
	_Translations$apiError$fa._(this._root);

	final TranslationsFa _root; // ignore: unused_field

	// Translations
	@override String requestFailedHttp({required Object status, required Object domain}) => 'درخواست ناموفق بود (HTTP ${status})؛ قبلاً ${domain} امتحان شد';
	@override String allDomainsFailed({required Object method, required Object path, required Object count}) => 'درخواست ناموفق بود: ${method} ${path} (${count} دامنه امتحان شد)';
	@override String requestTimeout({required Object seconds, required Object method, required Object path}) => 'مهلت درخواست تمام شد (${seconds} ثانیه): ${method} ${path}';
	@override String networkUnreachable({required Object detail}) => 'شبکه در دسترس نیست: ${detail}';
	@override String get tlsHandshakeFailed => 'دست‌دادن TLS ناموفق بود. اتصال شبکه یا ساعت سیستم را بررسی کنید.';
	@override String connectionFailed({required Object detail}) => 'اتصال ناموفق بود: ${detail}';
	@override String requestError({required Object error}) => 'درخواست ناموفق بود: ${error}';
	@override String responseReadTimeout({required Object seconds, required Object method, required Object path}) => 'مهلت خواندن پاسخ تمام شد (${seconds} ثانیه): ${method} ${path}';
	@override String notJson({required Object status, required Object snippet}) => 'پاسخ JSON نیست (HTTP ${status}): ${snippet}';
	@override String badStructure({required Object status}) => 'ساختار پاسخ غیرمنتظره است (HTTP ${status})';
	@override String loginFailed({required Object code}) => 'ورود ناموفق بود (کد ${code})';
	@override String get loginMissingData => 'پاسخ ورود فاقد داده است';
	@override String get loginMissingToken => 'پاسخ ورود فاقد access_token است';
	@override String registerFailed({required Object code}) => 'ثبت‌نام ناموفق بود (کد ${code})';
	@override String get registerMissingToken => 'پاسخ ثبت‌نام access_token ندارد - ممکن است کنترل ریسک فعال شده باشد یا سایت متفاوت پیکربندی شده باشد';
	@override String requestFailedCode({required Object code}) => 'درخواست ناموفق بود (کد ${code})';
}

// Path: subNotice
class _Translations$subNotice$fa implements Translations$subNotice$en {
	_Translations$subNotice$fa._(this._root);

	final TranslationsFa _root; // ignore: unused_field

	// Translations
	@override String get titleNotFound => 'اشتراک پیدا نشد';
	@override String get titleExpired => 'اشتراک منقضی شده';
	@override String get titleInactive => 'اشتراک غیرفعال است';
	@override String get titleDeviceOverLimit => 'از سقف دستگاه فراتر رفت';
	@override String get titleUnavailable => 'اشتراک در دسترس نیست';
	@override String titleWithReason({required Object emoji, required Object title, required Object reason}) => '${emoji} ${title} (${reason})';
	@override String deviceUsedOfLimit({required Object used, required Object limit}) => 'دستگاه‌های فعلی ${used}/${limit}';
	@override String deviceUsedOnly({required Object used}) => 'دستگاه‌های فعلی ${used}';
	@override String expireAt({required Object expire}) => 'انقضا ${expire}';
	@override String supportLine({required Object account}) => '💬 پشتیبانی: ${account}';
	@override String siteLine({required Object url}) => '📢 وب‌سایت: ${url}';
}

// Path: settingItems
class _Translations$settingItems$fa implements Translations$settingItems$en {
	_Translations$settingItems$fa._(this._root);

	final TranslationsFa _root; // ignore: unused_field

	// Translations
	@override String get subscriptionAutoUpdateInterval => 'بازه به‌روزرسانی خودکار اشتراک';
	@override String get speedTestMode => 'روش تست سرعت';
	@override String get speedTestModeTcp => 'تست سرعت TCP';
	@override String get speedTestModeKernel => 'تست سرعت هسته';
	@override String get delayTestUrlTip => 'زمان یک درخواست کامل HTTP از این گره (پینگ نیست)\nبه‌طور پیش‌فرض یک پاسخ خالی http 204 است؛ استفاده از https یک دست‌دادن TLS اضافه می‌کند و عدد بزرگ‌تر می‌شود';
	@override String get systemProxy => 'پروکسی سیستم';
	@override String get systemProxyTip => 'مشاهده / تنظیم مجدد آدرس و پورت';
	@override String get tunMode => 'حالت TUN';
	@override String get tunModeTip => 'off=فقط پروکسی سیستم / auto=TUN+پروکسی سیستم / force=فقط TUN\nدر دسکتاپ، TUN به دسترسی مدیر نیاز دارد (wintun در Windows / utun در macOS)';
	@override String get tunOverwriteTip => 'overwrite\nروشن = تنظیمات TUN این صفحه بخش tun پروفایل را بازنویسی می‌کند\nخاموش = از پیکربندی tun خود پروفایل استفاده می‌شود (برنامه دخالت نمی‌کند)';
	@override String tunEnableByTunMode({required Object enable}) => '${enable} (بر اساس حالت TUN)';
	@override String get interval30Minutes => '۳۰ دقیقه';
	@override String get interval1Hour => '۱ ساعت';
	@override String get interval6Hours => '۶ ساعت';
	@override String get interval12Hours => '۱۲ ساعت';
	@override String get interval24Hours => '۲۴ ساعت';
	@override String get interval3Days => '۳ روز';
	@override String get interval7Days => '۷ روز';
	@override String get intervalNever => 'هرگز';
	@override String intervalMinutes({required Object minutes}) => '${minutes} دقیقه';
	@override String intervalHours({required Object hours}) => '${hours} ساعت';
	@override String intervalDays({required Object days}) => '${days} روز';
}

// Path: tunScreen
class _Translations$tunScreen$fa implements Translations$tunScreen$en {
	_Translations$tunScreen$fa._(this._root);

	final TranslationsFa _root; // ignore: unused_field

	// Translations
	@override String get modeOff => 'خاموش';
	@override String get modeAuto => 'خودکار';
	@override String get modeForce => 'اجباری';
	@override String get modeOffDesc => 'فقط پروکسی سیستم: برای برنامه‌هایی که پروکسی سیستم را رعایت می‌کنند کار می‌کند (مرورگرها و مانند آن)؛ UDP و بازی‌ها پروکسی نمی‌شوند';
	@override String get modeAutoDesc => 'TUN + پروکسی سیستم (دو لایه ایمنی): همه ترافیک از آداپتور مجازی عبور می‌کند، از جمله UDP';
	@override String get modeForceDesc => 'فقط TUN: همه ترافیک از آداپتور مجازی عبور می‌کند و پروکسی سیستم دست‌نخورده می‌ماند';
	@override String get modeOffOptionDesc => 'جدول مسیریابی سیستم را تغییر نمی‌دهد؛ فقط یک پروکسی 127.0.0.1 در سیستم تنظیم می‌کند. تنها برنامه‌هایی که پروکسی سیستم را رعایت می‌کنند از آن استفاده می‌کنند؛ ترافیک UDP و برنامه‌هایی که پروکسی اختصاصی دارند، نه.';
	@override String get modeAutoOptionDesc => 'یک آداپتور مجازی می‌سازد و همه ترافیک را در اختیار می‌گیرد (از جمله UDP و بازی‌ها)؛ پروکسی سیستم به‌عنوان پشتیبان باقی می‌ماند. پیشنهادی: سراسری کار می‌کند و اگر مجوزها موجود نباشند، بدون اینترنت نمی‌مانید.';
	@override String get modeForceOptionDesc => 'فقط از آداپتور مجازی استفاده می‌کند و دیگر پروکسی سیستم را تغییر نمی‌دهد. همه ترافیک (از جمله UDP) از تونل عبور می‌کند؛ گزینه «proxy» در سیستم دست‌نخورده می‌ماند.';
	@override String get adminRequiredDialog => 'آداپتور مجازی TUN به دسترسی مدیر نیاز دارد (wintun در Windows / utun در macOS).\n\nMclash در حال حاضر با دسترسی مدیر اجرا نشده است، بنابراین TUN پس از فعال‌سازی اعمال نمی‌شود (در حالت «خودکار» پروکسی سیستم به‌عنوان پشتیبان کار می‌کند و شبکه قابل استفاده می‌ماند).\n\nتأیید = Mclash همین حالا با دسترسی مدیر دوباره اجرا شود (پنجره UAC نمایش داده می‌شود)\nلغو = این انتخاب ذخیره شود (وقتی TUN در دسترس نباشد از پروکسی سیستم استفاده می‌شود)';
	@override String relaunchFailed({required Object message}) => 'راه‌اندازی مجدد ناموفق بود: ${message}';
	@override String switchFailed({required Object message}) => 'تغییر حالت TUN ناموفق بود: ${message}\nتنظیمات قبلی بازگردانده شد.';
	@override String get setOffSnack => 'روی «خاموش» تنظیم شد: فقط پروکسی سیستم';
	@override String setModeSnack({required Object mode, required Object effect}) => 'روی «${mode}» تنظیم شد، ${effect}';
	@override String get effectReconnected => 'دوباره متصل شد و اکنون فعال است';
	@override String get effectAfterConnect => 'پس از اتصال فعال می‌شود';
	@override String get sheetTitle => 'آداپتور مجازی TUN';
	@override String get advancedTitle => 'پارامترهای پیشرفته (تنظیمات هسته → TUN)';
	@override String get advancedSubtitle => 'آدرس آداپتور / پشته / MTU / مسیریابی خودکار / ربودن DNS / بازنویسی';
	@override String get adminOk => 'TUN به دسترسی مدیر نیاز دارد؛ دسترسی فعلی کافی است (در Windows با دسترسی مدیر / در macOS با کاربر root اجرا کنید)';
	@override String get adminMissing => 'TUN به دسترسی مدیر نیاز دارد: Mclash با دسترسی مدیر اجرا نمی‌شود، بنابراین پس از انتخاب «خودکار/اجباری» TUN اعمال نمی‌شود (حالت «خودکار» به پروکسی سیستم برمی‌گردد و شبکه قابل استفاده می‌ماند)';
}

// Path: main.tray
class _Translations$main$tray$fa implements Translations$main$tray$en {
	_Translations$main$tray$fa._(this._root);

	final TranslationsFa _root; // ignore: unused_field

	// Translations
	@override String get menuOpen => 'بازکردن';
	@override String get menuExit => 'خروج';
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
			'main.tray.menuExit' => 'خروج',
			'meta.enable' => 'فعال‌سازی',
			'meta.disable' => 'غیرفعال',
			'meta.open' => 'باز کن',
			'meta.close' => 'بستن',
			'meta.quit' => 'خروج',
			'meta.add' => 'افزودن',
			'meta.remove' => 'حذف',
			'meta.removeConfirm' => 'آیا از حذف اطمینان دارید؟',
			'meta.edit' => 'ویرایش کنید',
			'meta.view' => 'بررسی',
			'meta.remark' => 'ملاحظات',
			'meta.byDefault' => 'پیش‌فرض',
			'meta.more' => 'بیشتر',
			'meta.tips' => 'اطلاعات',
			'meta.selectAll' => 'انتخاب همه',
			'meta.copy' => 'کپی',
			'meta.paste' => 'چسباندن',
			'meta.cut' => 'برش',
			'meta.save' => 'ذخیره کنید',
			'meta.ok' => 'تأیید',
			'meta.cancel' => 'لغو',
			'meta.faq' => 'سوالات متداول',
			'meta.doc' => 'سند',
			'meta.htmlTools' => 'مجموعه ابزارهای HTML',
			'meta.download' => 'دانلود',
			'meta.loading' => 'درحال بارگذاری…',
			'meta.days' => 'روز',
			'meta.hours' => 'ساعت',
			'meta.minutes' => 'دقیقه',
			'meta.seconds' => 'ثانیه',
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
			'meta.apply' => 'اعمال',
			'meta.refresh' => 'بارگذاری مجدد',
			'meta.update' => 'به‌روزرسانی',
			'meta.updateInterval' => 'فاصله‌ی به‌روزرسانی',
			'meta.updateInterval5mTips' => 'حداقل: ۵ دقیقه',
			'meta.updateIntervalPreferByProfile' => 'اولویت با تنظیمات ارائه‌دهنده',
			'meta.updateFailed' => ({required Object p}) => 'به‌روزرسانی ناموفق بود:${p}',
			'meta.none' => 'هیچ‌کدام',
			'meta.reset' => 'ریست',
			'meta.authentication' => 'احراز هویت',
			'meta.user' => 'کاربر',
			'meta.account' => 'نام‌کاربری',
			'meta.password' => 'رمز‌عبور',
			'meta.decryptPassword' => 'دکریپت رمز‌عبور',
			'meta.required' => 'الزامی',
			'meta.go' => 'ادامه',
			'meta.other' => 'دیگر',
			'meta.dns' => 'DNS',
			'meta.url' => 'URL',
			'meta.urlInvalid' => 'URL نامعتبر',
			'meta.copyUrl' => 'کپی‌کردن لینک',
			'meta.openUrl' => 'بازکردن لینک',
			'meta.coreSettingTips' => 'توجه: پس از تغییر پیکربندی، باید دوباره وصل شوید تا اعمال شود',
			'meta.overwrite' => 'بازنویسی',
			'meta.overwriteAppend' => 'بازنویسی الحاقی',
			'meta.overwriteTips' => 'پیکربندی اصلی <- بازنویسی سفارشی <- بازنویسی برنامه',
			'meta.noOverwrite' => 'رونویسی نکنید',
			'meta.diversionTemplates' => 'الگوی تریاژ',
			'meta.ruleProviders' => 'ارائه دهنده قانون',
			'meta.ruleTemplates' => 'الگوی قانون',
			'meta.proxyGroupsTemplates' => 'الگوهای گروه پروکسی',
			'meta.proxyGroups' => 'گروه‌های پروکسی',
			'meta.proxyNodeList' => 'فهرست گره‌های پروکسی',
			'meta.proxyNodeFailure' => ({required Object p}) => 'گره‌های پروکسی زیر منقضی شده و به طور خودکار حذف شده‌اند: ${p}',
			'meta.externalController' => 'کنترل خارجی',
			'meta.secret' => 'کلید مخفی',
			'meta.tcpConcurrent' => 'دست دادن همزمان TCP',
			'meta.globalClientFingerprint' => 'اثر انگشت جهانی TLS',
			'meta.allowLanAccess' => 'دسترسی به دستگاه LAN',
			'meta.mixedPort' => 'پورت پروکسی هیبریدی',
			'meta.logLevel' => 'سطح گزارش',
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
			'meta.portableModeDisableTips' => 'اگر نیاز دارید از حالت قابل‌حمل خارج شوید لطفا از [mclash] خارج شده و به‌صورت دستی پوشه [portable] هم مسیر با فایل [mclash.exe] را حذف کنید',
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
			'meta.log' => 'گزارش',
			'meta.coreLog' => 'گزارش هسته',
			'meta.appLog' => 'گزارش برنامه',
			'meta.core' => 'هسته',
			'meta.help' => 'راهنما',
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
			'meta.proxy' => 'پروکسی',
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
			'meta.port' => 'پورت',
			'meta.donate' => 'اهدا کنید',
			'meta.setting' => 'تنظیمات',
			'meta.settingCore' => 'تنظیمات هسته',
			'meta.settingApp' => 'تنظیمات برنامه',
			'meta.coreOverwrite' => 'Core Override',
			'meta.iCloud' => 'iCloud',
			'meta.webdav' => 'Webdav',
			'meta.lanSync' => 'همگام‌سازی LAN',
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
			'permission.appQuery' => 'دریافت فهرست برنامه‌ها',
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
			'dns.listen' => 'آدرس شنود',
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
			'sniffer.overrideDest' => 'بازنویسی مقصد',
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
			'countries.HK' => 'هنگ‌کنگ',
			'countries.TW' => 'تایوان',
			'countries.MO' => 'ماکائو',
			'countries.CN' => 'چین',
			'countries.JP' => 'ژاپن',
			'countries.KR' => 'کره جنوبی',
			'countries.SG' => 'سنگاپور',
			'countries.MY' => 'مالزی',
			'countries.TH' => 'تایلند',
			'countries.VN' => 'ویتنام',
			'countries.PH' => 'فیلیپین',
			'countries.ID' => 'اندونزی',
			'countries.KH' => 'کامبوج',
			'countries.US' => 'ایالات متحده',
			'countries.CA' => 'کانادا',
			'countries.MX' => 'مکزیک',
			'countries.GB' => 'بریتانیا',
			'countries.DE' => 'آلمان',
			'countries.FR' => 'فرانسه',
			'countries.NL' => 'هلند',
			'countries.RU' => 'روسیه',
			'countries.IT' => 'ایتالیا',
			'countries.ES' => 'اسپانیا',
			'countries.CH' => 'سوئیس',
			'countries.SE' => 'سوئد',
			'countries.NO' => 'نروژ',
			'countries.FI' => 'فنلاند',
			'countries.DK' => 'دانمارک',
			'countries.PL' => 'لهستان',
			'countries.AT' => 'اتریش',
			'countries.IE' => 'ایرلند',
			'countries.UA' => 'اوکراین',
			'countries.TR' => 'ترکیه',
			'countries.PT' => 'پرتغال',
			'countries.CZ' => 'چک',
			'countries.RO' => 'رومانی',
			'countries.BE' => 'بلژیک',
			'countries.GR' => 'یونان',
			'countries.HU' => 'مجارستان',
			'countries.IL' => 'اسرائیل',
			'countries.AE' => 'امارات متحده عربی',
			'countries.SA' => 'عربستان سعودی',
			'countries.EG' => 'مصر',
			'countries.ZA' => 'آفریقای جنوبی',
			'countries.NG' => 'نیجریه',
			'countries.AU' => 'استرالیا',
			'countries.NZ' => 'نیوزیلند',
			'countries.BR' => 'برزیل',
			'countries.AR' => 'آرژانتین',
			'countries.CL' => 'شیلی',
			'countries.CO' => 'کلمبیا',
			'countries.IN' => 'هند',
			'countries.PK' => 'پاکستان',
			'countries.XX' => 'سایر',
			'meScreen.accountBalance' => 'موجودی',
			'meScreen.expireAt' => 'انقضا',
			'meScreen.remainingDays' => 'روز باقی‌مانده',
			'meScreen.deviceCount' => 'دستگاه‌ها',
			'meScreen.myOrders' => 'سفارش‌های من',
			'meScreen.deviceManagement' => 'مدیریت دستگاه‌ها',
			'meScreen.changePassword' => 'تغییر رمز عبور',
			'meScreen.clearLocalData' => 'پاک کردن داده‌های محلی (پیش از حذف برنامه)',
			'meScreen.profileManagementDev' => 'مدیریت پروفایل (توسعه‌دهنده)',
			'meScreen.tunAdapter' => 'آداپتور مجازی TUN',
			'meScreen.checkUpdate' => 'بررسی به‌روزرسانی',
			'meScreen.retry' => 'تلاش مجدد',
			'meScreen.loadFailed' => 'بارگذاری اطلاعات حساب ناموفق بود: ممکن است ورود منقضی شده یا شبکه در دسترس نباشد.\nبرای تلاش مجدد «بارگذاری مجدد» را در بالا سمت راست بزنید؛ اگر باز هم ناموفق بود، دوباره وارد شوید.',
			'meScreen.logoutConfirm' => 'از حساب خارج می‌شوید؟',
			'meScreen.boardNoKernel' => 'داشبورد داده‌های زنده هسته (اتصال، ترافیک، تطبیق قوانین) را نشان می‌دهد.\n\nهسته در حال اجرا نیست، پس داشبورد توخالی خواهد بود.\nبرای باز کردن آن به‌هرحال «تأیید» را بزنید، یا برای اتصال ابتدا از تب خانه وصل شوید و «لغو» را انتخاب کنید.',
			'meScreen.boardOpened' => 'داشبورد در مرورگر شما باز شد؛ گره یا قانون را همان‌جا تغییر دهید و برنامه تا حدود ۵ ثانیه هم‌گام می‌شود.',
			'homeScreen.expiresOn' => ({required Object date}) => 'انقضا ${date}',
			'homeScreen.devicesText' => ({required Object text}) => 'دستگاه‌ها ${text}',
			'homeScreen.upgrade' => 'ارتقا',
			'homeScreen.quickCountries' => 'فیلتر سریع کشور',
			'homeScreen.nodeCount' => ({required Object count}) => '${count} گره',
			'homeScreen.autoBestTip' => 'گرهی با کمترین تأخیر را از میان همه کشورها انتخاب می‌کند (حالت خودکار)',
			'homeScreen.autoBest' => 'بهترین خودکار',
			'homeScreen.pickCountryTip' => ({required Object label}) => 'کم‌تأخیرترین گره موجود در «${label}» را خودکار انتخاب و ثابت می‌کند',
			'homeScreen.autoNoBetter' => 'از قبل در حالت خودکار هستید (گره بهتری پیدا نشد)',
			'homeScreen.switchedBest' => ({required Object name}) => 'به بهترین گره تغییر یافت: ${name}',
			'homeScreen.switchedCountry' => ({required Object country, required Object node, required Object ms}) => 'به سریع‌ترین گره ${country} تغییر یافت: ${node}${ms}',
			'homeScreen.filterCountryFailed' => ({required Object country, required Object err}) => 'فیلتر بر اساس ${country} انجام شد؛ تغییر گره ناموفق بود: ${err}',
			'homeScreen.deviceFullCount' => ({required Object used, required Object limit}) => 'دستگاه‌های فعلی ${used}/${limit}\n\n',
			'homeScreen.deviceFullUpgradeHint' => 'با ارتقای سقف دستگاه، اتصال بلافاصله برقرار می‌شود (پیشنهادی)؛ می‌توانید دستگاه‌های بی‌استفاده را هم حذف کنید تا یک جا آزاد شود.',
			'homeScreen.later' => 'بعداً',
			'homeScreen.upgradeDeviceCount' => 'ارتقای سقف دستگاه',
			'homeScreen.cannotConnect' => 'اتصال ممکن نیست',
			'homeScreen.freshnessNever' => 'هنوز هم‌گام نشده · برای بارگذاری مجدد بزنید',
			'homeScreen.freshnessJustNow' => 'همین حالا به‌روزرسانی شد · مدیریت دستگاه‌ها را بزنید',
			'homeScreen.freshnessMinutes' => ({required Object minutes}) => '${minutes} دقیقه پیش · مدیریت دستگاه‌ها را بزنید',
			'homeScreen.freshnessStale' => ({required Object minutes}) => '${minutes} دقیقه پیش · برای بارگذاری مجدد بزنید',
			'homeScreen.subscriptionAutoSync' => 'هم‌گام‌سازی خودکار اشتراک',
			'homeScreen.connecting' => 'در حال اتصال…',
			'homeScreen.disconnecting' => 'در حال قطع اتصال…',
			'homeScreen.tapToDisconnect' => 'برای قطع اتصال کلید را بزنید',
			'homeScreen.tapToConnect' => 'برای اتصال کلید را بزنید',
			'homeScreen.currentNode' => 'گره فعلی',
			'homeScreen.noNodeSelected' => 'هیچ گرهی انتخاب نشده',
			'homeScreen.switchAction' => 'تغییر',
			'homeScreen.realtimeSpeed' => 'سرعت لحظه‌ای',
			'homeScreen.totalTraffic' => 'کل ترافیک',
			'homeScreen.subSyncedNotReady' => 'اشتراک دانلود شد، اما پروفایل هنوز آماده نیست. کمی بعد دوباره تلاش کنید.',
			'homeScreen.noPlan' => 'این حساب هنوز طرح فعالی ندارد. ابتدا یک طرح بخرید.',
			'homeScreen.loginExpired' => 'ورود شما منقضی شده است. لطفاً دوباره وارد شوید.',
			'homeScreen.syncingWait' => 'در حال هم‌گام‌سازی اشتراک، کمی صبر کنید.',
			'homeScreen.syncFailedNetwork' => ({required Object message}) => 'هم‌گام‌سازی اشتراک ناموفق بود: ${message}\nشبکه را بررسی کنید و دوباره تلاش کنید.',
			'homeScreen.syncFailed' => 'هم‌گام‌سازی اشتراک ناموفق بود، کمی بعد دوباره تلاش کنید.',
			'homeScreen.resetProxy' => 'ریست',
			'homeScreen.latencySuffix' => ({required Object ms}) => ' (${ms} میلی‌ثانیه)',
			'nodesScreen.updatedCount' => ({required Object count}) => 'اشتراک به‌روزرسانی شد: ${count} گره',
			'nodesScreen.updateFailed' => ({required Object message}) => 'به‌روزرسانی ناموفق بود: ${message}',
			'nodesScreen.updateFailedNetwork' => 'به‌روزرسانی ناموفق بود، شبکه را بررسی کنید',
			'nodesScreen.testDone' => ({required Object ok, required Object fail}) => 'تست سرعت تمام شد: ${ok} در دسترس، ${fail} بی‌پاسخ (ممکن است آفلاین باشد)',
			'nodesScreen.switchedTo' => ({required Object name}) => 'به ${name} تغییر یافت',
			'nodesScreen.switchFailed' => ({required Object message}) => 'تغییر گره ناموفق بود: ${message}\n(تغییر گره به هسته در حال اجرا نیاز دارد؛ ابتدا کلید را از تب خانه روشن کنید.)',
			'nodesScreen.selectedAfterConnect' => ({required Object name}) => '${name} انتخاب شد (پس از اتصال اعمال می‌شود)',
			'nodesScreen.title' => 'گره‌ها',
			'nodesScreen.searchNode' => 'جستجوی گره',
			'nodesScreen.sortByLatency' => 'مرتب‌سازی بر اساس تأخیر',
			'nodesScreen.updateSubscription' => 'به‌روزرسانی اشتراک',
			'nodesScreen.viewByGroup' => 'نمایش بر اساس گروه پروکسی',
			'nodesScreen.testAll' => 'تست همه',
			'nodesScreen.searchHint' => 'جستجوی گره / کشور / پروتکل',
			'nodesScreen.emptyNoNodes' => 'هنوز گرهی در دسترس نیست.\nاشتراک‌ها خودکار هم‌گام می‌شوند؛ اگر همین حالا وارد شده‌اید کمی صبر کنید یا پایین را بارگذاری مجدد کنید.',
			'nodesScreen.emptyNoMatch' => 'گرهی مطابق پیدا نشد.',
			'nodesScreen.reload' => 'بارگذاری مجدد',
			'nodesScreen.currentInUse' => 'فعلی (در استفاده)',
			'nodesScreen.current' => 'فعلی',
			'nodesScreen.notTested' => 'اندازه‌گیری نشده (در انتظار بارگذاری مجدد هسته)',
			'nodesScreen.timeout' => 'تایم اوت',
			'nodesScreen.clear' => 'پاک کردن',
			'nodesScreen.selectNode' => 'انتخاب گره',
			'nodesScreen.emptyNoKernel' => 'هنوز گرهی در دسترس نیست.\nابتدا کلید اتصال را از تب خانه روشن کنید.',
			'nodesScreen.openFullList' => 'باز کردن فهرست کامل گره‌ها (جستجو / تست سرعت / گروه‌ها)',
			'nodeAuto.kernelStateUnavailable' => 'وضعیت گره موقتاً از هسته در دسترس نیست؛ به‌طور خودکار دوباره تلاش می‌شود.',
			'nodeAuto.backToFixedNode' => ({required Object fixed}) => 'بازگشت به گره ثابت‌شده: ${fixed}',
			'nodeAuto.noUsableNodePickOne' => 'گره قابل استفاده‌ای پیدا نشد. لطفاً از فهرست گره‌ها یکی را دستی انتخاب کنید.',
			'nodeAuto.noUsableNodeTryOne' => 'گره قابل استفاده‌ای پیدا نشد. لطفاً از فهرست گره‌ها یکی را انتخاب کنید.',
			'nodeAuto.autoConnectedBest' => ({required Object bestNode, required Object bestMs}) => 'به‌طور خودکار به بهترین گره متصل شد: ${bestNode} (${bestMs} میلی‌ثانیه)',
			'nodeAuto.currentNodeUnreachable' => 'گره فعلی به اینترنت دسترسی ندارد؛ به‌طور خودکار تغییر داده می‌شود…',
			'nodeAuto.autoSwitchedToUsable' => ({required Object target}) => 'به‌طور خودکار به یک گره قابل استفاده تغییر یافت: ${target}',
			'nodeAuto.newNodesReloading' => ({required Object missing}) => '${missing} گره تازه در اشتراک هنوز در هسته نیست؛ در حال بارگذاری مجدد…',
			'nodeAuto.kernelReloadedRetest' => 'هسته با اشتراک جدید بارگذاری مجدد شد؛ تست سرعت را دوباره اجرا کنید.',
			'accountBlock.quotaFull' => ({required Object used, required Object limit}) => 'جای دستگاه‌ها پر است (${used}/${limit}): این دستگاه هنوز در محدوده مجاز است و می‌تواند عادی وصل شود. برای افزودن دستگاه دیگر، سقف دستگاه را ارتقا دهید یا دستگاه‌های بی‌استفاده را حذف کنید.',
			'accountBlock.banFallback' => 'حساب شما غیرفعال شده و دیگر قابل استفاده نیست.',
			'accountBlock.titleExpired' => 'طرح منقضی شد',
			'accountBlock.titleDeviceFull' => 'سقف دستگاه پر شد',
			'accountBlock.titleAccountDisabled' => 'حساب غیرفعال شد',
			'accountBlock.titlePlanDisabled' => 'طرح غیرفعال شد',
			'accountBlock.titleNoPlan' => 'طرحی وجود ندارد',
			'accountBlock.titleDeviceRemoved' => 'این دستگاه حذف شد',
			'accountBlock.titleServiceUnavailable' => 'سرویس موقتاً در دسترس نیست',
			'accountBlock.textExpired' => 'طرح شما منقضی شده است. برای ادامه استفاده از گره‌های جهانی یک طرح بخرید.',
			'accountBlock.textDeviceFull' => ({required Object used, required Object limit}) => 'سرور تشخیص داده است که این دستگاه از سقف دستگاه طرح (${used}/${limit}) فراتر رفته و در حال حاضر نمی‌تواند وصل شود. دستگاه‌های بی‌استفاده را در «من - مدیریت دستگاه‌ها» حذف کنید یا به طرحی با دستگاه بیشتر ارتقا دهید.',
			'accountBlock.textAccountDisabled' => 'حساب شما غیرفعال شده است. در صورت داشتن پرسش با پشتیبانی تماس بگیرید.',
			'accountBlock.textPlanDisabled' => 'طرح شما غیرفعال یا در وضعیت غیرعادی است، بنابراین امکان اتصال نیست. در صورت داشتن پرسش با پشتیبانی تماس بگیرید.',
			'accountBlock.textNoPlan' => 'هنوز طرحی نخریده‌اید. برای استفاده از گره‌های جهانی یکی بخرید.',
			'accountBlock.textDeviceRemoved' => 'این دستگاه حذف و از حساب خارج شد. لطفاً دوباره وارد شوید.',
			'accountBlock.textServiceUnavailable' => 'سرویس موقتاً در دسترس نیست. کمی بعد دوباره تلاش کنید؛ اگر ادامه داشت، اسکرین‌شات بگیرید و با پشتیبانی تماس بگیرید.',
			'accountBlock.remainingDays' => ({required Object days}) => '${days} روز باقی مانده',
			'accountBlock.deviceUsage' => ({required Object used, required Object limit}) => 'دستگاه‌ها ${used}/${limit}',
			'entitlementMsg.tamperedTitle' => 'وضعیت مجوز غیرعادی است',
			'entitlementMsg.tamperedClock' => 'عقب رفتن ساعت سیستم (یا دستکاری داده‌های مجوز محلی) شناسایی شد. لطفاً پیش از اتصال آنلاین شوید و یک بار تأیید انجام دهید.',
			'entitlementMsg.tamperedLocal' => 'داده‌های مجوز محلی خراب شده یا تغییر کرده‌اند. لطفاً پیش از اتصال آنلاین شوید و یک بار تأیید انجام دهید.',
			'entitlementMsg.needVerifyTitle' => 'تأیید آنلاین لازم است',
			'entitlementMsg.needVerifyFirst' => 'وضعیت طرح شما تأیید نشد: لطفاً به شبکه وصل شوید و وارد حساب شوید، سپس پیش از اتصال یک بار تأیید انجام دهید.',
			'entitlementMsg.needVerifyRetry' => 'وضعیت طرح شما تأیید نشد. لطفاً آنلاین شوید و دوباره تلاش کنید.',
			'entitlementMsg.verifyFailedTitle' => 'تأیید وضعیت طرح ممکن نیست',
			'entitlementMsg.verifyFailedText' => 'مهلت تأیید گذشته و سرور در دسترس نیست. شبکه را بررسی کنید و دوباره تلاش کنید (اگر همین حالا تمدید کرده‌اید، دوباره وارد شوید).',
			'entitlementMsg.restrictedTitle' => 'حساب محدود شده است',
			'entitlementMsg.restrictedFallback' => 'حساب یا طرح شما غیرفعال شده است، بنابراین امکان اتصال نیست.',
			'entitlementMsg.expiredTitle' => 'طرح منقضی شد',
			'entitlementMsg.expiredText' => ({required Object date}) => 'طرح شما در ${date} منقضی شد. پروفایل اشتراک محلی پاک شده است. برای بازگرداندن آن، تمدید کنید و دوباره وارد شوید.',
			'devicesScreen.title' => 'مدیریت دستگاه‌ها',
			'devicesScreen.currentPlan' => 'طرح فعلی',
			'devicesScreen.devicesText' => ({required Object text}) => 'دستگاه‌ها ${text}',
			'devicesScreen.upgradeTitle' => 'ارتقای دستگاه / تمدید زمان',
			'devicesScreen.upgradeSubtitle' => 'دستگاه و روز را با هم اضافه کنید؛ یک قیمت، یک پرداخت',
			'devicesScreen.addDevices' => 'افزودن دستگاه',
			'devicesScreen.noAddDevices' => 'بدون تغییر',
			'devicesScreen.addDevicesCount' => ({required Object n}) => '+${n} دستگاه',
			'devicesScreen.addDays' => 'افزودن روز',
			'devicesScreen.noExtend' => 'بدون تمدید',
			'devicesScreen.addDaysCount' => ({required Object n, required Object months}) => '+${n} روز (${months} ماه)',
			'devicesScreen.priceFailed' => 'دریافت قیمت ناموفق بود',
			'devicesScreen.amountDue' => ({required Object amount}) => 'مجموع ¥${amount}',
			'devicesScreen.requote' => 'محاسبه مجدد',
			'devicesScreen.goPay' => 'پرداخت',
			'devicesScreen.afterUpgrade' => 'پس از ارتقا: ',
			'devicesScreen.afterLimit' => ({required Object limit}) => 'سقف دستگاه ${limit}',
			'devicesScreen.afterExpire' => ({required Object date}) => 'انقضا ${date}',
			'devicesScreen.pickSomething' => 'حداقل چند دستگاه یا چند روز اضافه کنید',
			'devicesScreen.daysOnlyUnsupported' => 'پنل هنوز «فقط تمدید زمان» را پشتیبانی نمی‌کند: لطفاً «افزودن دستگاه» را روی ۱ یا بیشتر بگذارید و دوباره تلاش کنید (یا برای فعال‌سازی با پشتیبانی تماس بگیرید).',
			'devicesScreen.paramsRejected' => 'پارامترها پذیرفته نشد: لطفاً تعداد دستگاه و روز را دوباره انتخاب کنید.',
			'devicesScreen.subscriptionExpired' => 'اشتراک منقضی شده و قابل ارتقا نیست. ابتدا آن را تمدید کنید یا طرح جدید بخرید.',
			'devicesScreen.orderIncomplete' => 'اطلاعات سفارش کامل نیست. «محاسبه مجدد» را بزنید و دوباره تلاش کنید.',
			'devicesScreen.orderRegenerated' => 'سفارش قبلی منقضی شد؛ سفارش تازه‌ای با همان تنظیمات ساخته شد.',
			'devicesScreen.payChannelIncomplete' => 'اطلاعات سفارش یا کانال پرداخت کامل نیست. لطفاً محاسبه مجدد کنید و دوباره تلاش کنید.',
			'devicesScreen.noQrCode' => 'سرور کد QR یا لینک پرداخت برنگرداند. لطفاً روش پرداخت دیگری انتخاب کنید یا بعداً تلاش کنید.',
			'devicesScreen.payStartFailed' => ({required Object err}) => 'شروع پرداخت ناموفق بود: ${err}',
			'devicesScreen.payCancelled' => 'پرداخت لغو شد؛ پیش‌سفارش پاک شد.',
			'devicesScreen.balancePay' => 'موجودی',
			'devicesScreen.noPayMethod' => 'در حال حاضر روش پرداختی در دسترس نیست. بعداً تلاش کنید یا با پشتیبانی تماس بگیرید.',
			'devicesScreen.balanceInsufficient' => ({required Object balance, required Object amount}) => 'موجودی کافی نیست (¥${balance}، لازم: ¥${amount}).\nابتدا شارژ می‌کنید؟',
			'devicesScreen.choosePayMethod' => 'انتخاب روش پرداخت',
			'devicesScreen.balanceText' => ({required Object balance}) => 'موجودی ¥${balance}',
			'devicesScreen.balanceShort' => ({required Object balance}) => 'موجودی ¥${balance} (کافی نیست، شارژ کنید)',
			'devicesScreen.unknownDevice' => 'دستگاه ناشناس',
			'devicesScreen.online' => '● آنلاین',
			'devicesScreen.offline' => '○ آفلاین',
			'devicesScreen.lastActive' => ({required Object text}) => 'آخرین فعالیت ${text}',
			'devicesScreen.delete' => 'حذف',
			'devicesScreen.deleteConfirm' => ({required Object name}) => 'دستگاه «${name}» حذف شود؟ بلافاصله از اتصال خارج می‌شود.',
			'devicesScreen.lastActiveJustNow' => 'همین حالا',
			'devicesScreen.lastActiveMinutes' => ({required Object minutes}) => '${minutes} دقیقه پیش',
			'devicesScreen.lastActiveToday' => ({required Object time}) => 'امروز ${time}',
			'sysProxySheet.reading' => 'در حال خواندن…',
			'sysProxySheet.unknown' => 'نامشخص',
			'sysProxySheet.kernelNotRunning' => 'هسته در حال اجرا نیست (ابتدا کلید را از تب خانه روشن کنید)',
			'sysProxySheet.applied' => ({required Object host, required Object port}) => 'اعمال شد · ${host}:${port}',
			'sysProxySheet.notSet' => ({required Object reason}) => 'پروکسی سیستم تنظیم نشده — ${reason}',
			'sysProxySheet.notEffective' => ({required Object port}) => 'بی‌اثر است (هیچ پروکسی سیستمی به ${port} اشاره نمی‌کند)',
			'sysProxySheet.readFailed' => ({required Object err}) => 'خواندن ناموفق بود: ${err}',
			'sysProxySheet.setRejected' => 'تنظیم ناموفق بود: احتمالاً سیستم نوشتن را رد کرده است (یا برنامه پروکسی دیگری آن را بازنویسی کرده)',
			'sysProxySheet.disableFailed' => 'خاموش کردن ناموفق بود',
			'sysProxySheet.portRange' => 'پورت باید بین 1 و 65535 باشد',
			'sysProxySheet.portChanged' => ({required Object value}) => 'پورت به ${value} تغییر کرد: یک بار اتصال را قطع و وصل کنید تا هسته روی پورت جدید گوش دهد',
			'sysProxySheet.title' => 'پروکسی سیستم',
			'sysProxySheet.desc' => ({required Object host}) => 'آدرس پروکسی سیستم ثابت و برابر ${host} (بازگشت محلی) است و پورت همان پورت ترکیبی هسته است.',
			'sysProxySheet.descWindows' => 'این دقیقاً همان چیزی است که در تنظیمات Windows → شبکه و اینترنت → پروکسی می‌بینید.',
			'sysProxySheet.reset' => 'تنظیم مجدد',
			'sysProxySheet.disable' => 'خاموش کردن پروکسی سیستم',
			'sysProxySheet.diagnostics' => 'عیب‌یابی (آیا رابط کاربری همان مقادیر رجیستری را می‌خواند؟)',
			'sysProxySheet.mixedPort' => 'پورت ترکیبی',
			'sysProxySheet.apply' => 'اعمال',
			'logScreen.readAppFailed' => ({required Object e}) => 'خواندن گزارش برنامه ناموفق بود: ${e}',
			_ => null,
		} ?? switch (path) {
			'logScreen.readCoreFailed' => ({required Object e}) => 'خواندن گزارش هسته ناموفق بود: ${e}',
			'logScreen.copied' => 'کپی شد (URLهای اشتراک و دیگر داده‌های حساس پوشانده شده‌اند؛ شاید خود فایل گزارش هنوز آدرس خام را داشته باشد)',
			'logScreen.copy' => 'کپی',
			'logScreen.refresh' => 'بارگذاری مجدد',
			'logScreen.empty' => 'محتوایی نیست',
			'trayShell.closeTitle' => 'بستن پنجره',
			'trayShell.closeBody' => 'بستن پنجره فقط Mclash را به سینی سیستم می‌فرستد — هسته و پروکسی سیستم به کار خود ادامه می‌دهند و اتصال شبکه شما برقرار می‌ماند.\n\n· تأیید: کوچک شدن به سینی سیستم (برای خروج کامل، روی آیکون سینی راست‌کلیک کنید → خروج)\n· لغو: خروج کامل از Mclash، توقف هسته و بازگرداندن پروکسی سیستم\n\n(انتخاب شما به خاطر سپرده می‌شود؛ بار بعد می‌توانید مستقیم از آیکون سینی استفاده کنید)',
			'ordersScreen.title' => 'سفارش‌های من',
			'ordersScreen.orderInfoIncomplete' => 'اطلاعات سفارش کامل نیست. صفحه را پایین بکشید تا بارگذاری مجدد شود و دوباره تلاش کنید.',
			'ordersScreen.payChannelIncomplete' => 'اطلاعات کانال پرداخت کامل نیست. کمی بعد دوباره تلاش کنید.',
			'ordersScreen.noQrPayload' => 'سرور کد QR یا لینک پرداخت برنگرداند. لطفاً روش پرداخت دیگری انتخاب کنید یا بعداً تلاش کنید.',
			'ordersScreen.payStartFailed' => ({required Object err}) => 'شروع پرداخت ناموفق بود: ${err}',
			'ordersScreen.noPayMethod' => 'در حال حاضر روش پرداختی در دسترس نیست. کمی بعد دوباره تلاش کنید یا با پشتیبانی تماس بگیرید.',
			'ordersScreen.choosePayMethod' => 'انتخاب روش پرداخت',
			'ordersScreen.amountDue' => ({required Object amount}) => 'مبلغ قابل پرداخت ¥${amount}',
			'ordersScreen.paidLabel' => '● پرداخت‌شده',
			'ordersScreen.pendingLabel' => '○ پرداخت‌نشده',
			'ordersScreen.unknownStatus' => ({required Object status}) => '✕ ${status}',
			'ordersScreen.orderNoText' => ({required Object orderNo}) => 'شماره سفارش ${orderNo}',
			'ordersScreen.createdAtText' => ({required Object createdAt}) => 'زمان ایجاد ${createdAt}',
			'ordersScreen.orderCanceled' => 'سفارش لغو شد',
			'ordersScreen.cancelFailed' => ({required Object err}) => 'لغو ناموفق بود: ${err}\n(اگر سفارش قبلاً پرداخت یا لغو شده است، برای دیدن آخرین وضعیت صفحه را پایین بکشید.)',
			'ordersScreen.cancelOrder' => 'لغو سفارش',
			'ordersScreen.continuePay' => 'ادامه پرداخت',
			'payment.balancePay' => 'پرداخت با موجودی',
			'payment.qrPay' => 'پرداخت با اسکن',
			'payment.deductFromBalance' => 'از موجودی حساب شما کسر می‌شود',
			'payment.openedInBrowser' => 'صفحه پرداخت در مرورگر شما باز شد',
			'payment.scanWithAlipayWechat' => 'با Alipay یا WeChat اسکن کنید',
			'payment.orderNoText' => ({required Object orderNo}) => 'شماره سفارش ${orderNo}',
			'payment.payFailed' => ({required Object err}) => 'پرداخت ناموفق بود: ${err}',
			'payment.notDetected' => 'پرداختی شناسایی نشد. می‌توانید بعداً از «سفارش‌های من» ادامه دهید.',
			'payment.charging' => 'در حال ارسال…',
			'payment.processing' => 'در حال پردازش…',
			'payment.waitingPay' => 'در انتظار پرداخت…',
			'payment.openPageFailed' => 'صفحه پرداخت باز نشد. برای تلاش مجدد دکمه زیر را بزنید یا کد QR را اسکن کنید.',
			'payment.reopenPayPage' => 'باز کردن دوباره صفحه پرداخت',
			'payment.payInBrowser' => 'پرداخت در مرورگر',
			'payment.openAlipay' => 'باز کردن Alipay',
			'payment.cancelOrder' => 'لغو سفارش',
			'payment.confirmPay' => 'تأیید پرداخت',
			'payment.retry' => 'تلاش مجدد',
			'payment.paidAlready' => 'پرداخت کرده‌ام',
			'payment.channelAlipay' => 'Alipay',
			'payment.channelCodepayAlipay' => 'Code Pay · Alipay',
			'payment.channelCodepayWechat' => 'Code Pay · WeChat',
			'payment.channelCodepay' => 'Code Pay',
			'payment.channelWechat' => 'WeChat Pay',
			'payment.channelUsdt' => 'USDT',
			'payment.channelUsdtTrc20' => 'USDT · TRC20',
			'payment.payFallback' => 'پرداخت',
			'payment.errCsrf' => 'مجوز ورود شما منقضی شده است (بررسی CSRF ناموفق بود).\nدر تب «من» صفحه را پایین بکشید یا دوباره وارد شوید، سپس تلاش کنید.',
			'payment.errAlipayLimit' => 'پرداخت حضوری Alipay سقف هر تراکنش دارد (برای این فروشنده ¥1000) و این سفارش از آن بیشتر است.\nلطفاً از «پرداخت با موجودی» یا «Code Pay» استفاده کنید، یا برای افزایش سقف Alipay با پشتیبانی تماس بگیرید.',
			'payment.errNotSigned' => 'اپلیکیشن Alipay برای این محصول پرداخت ثبت‌نام نکرده و این کانال موقتاً در دسترس نیست.\nلطفاً از «پرداخت با موجودی» یا «Code Pay» استفاده کنید، یا برای فعال‌سازی با پشتیبانی تماس بگیرید.',
			'payment.errOrderGone' => 'این سفارش لغو یا منقضی شده است (پیش‌سفارش‌ها ۳۰ دقیقه اعتبار دارند).\n«محاسبه مجدد» را بزنید تا سفارش تازه‌ای ساخته شود، سپس پرداخت کنید.',
			'payment.errNetwork' => ({required Object err}) => 'شبکه در دسترس نیست: ${err}',
			'planScreen.recommended' => 'پیشنهادی',
			'planScreen.devices' => 'دستگاه‌ها',
			'planScreen.balanceLabel' => ({required Object amount}) => 'موجودی ¥${amount}',
			'planScreen.balanceInsufficient' => ' (موجودی کافی نیست، ابتدا شارژ کنید)',
			'planScreen.total' => 'مجموع',
			'planScreen.payNow' => 'پرداخت',
			'planScreen.retry' => 'تلاش مجدد',
			'planScreen.errIncompleteOrder' => 'اطلاعات سفارش یا کانال پرداخت کامل نیست؛ پرداخت آغاز نمی‌شود.',
			'planScreen.payBalance' => 'پرداخت با موجودی',
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
			'planScreen.payOnline' => 'پرداخت آنلاین',
			'authScreen.saveAccountInfo' => 'ذخیره اطلاعات حساب',
			'authScreen.autoLoginNextTime' => 'دفعه بعد خودکار وارد شوید',
			'authScreen.needLoginNextTime' => 'دفعه بعد باید دوباره وارد شوید',
			'authScreen.invalidEmail' => 'لطفاً یک ایمیل معتبر وارد کنید',
			'authScreen.enterEmailFirst' => 'لطفاً ابتدا یک ایمیل معتبر وارد کنید',
			'authScreen.passwordRequired' => 'لطفاً رمز عبور را وارد کنید',
			'authScreen.wrongCredentials' => 'ایمیل یا رمز عبور نادرست است',
			'authScreen.requestRejected' => 'درخواست رد شد. کمی بعد دوباره تلاش کنید.',
			'authScreen.tooFrequent' => 'تلاش‌های بیش از حد. کمی بعد دوباره تلاش کنید.',
			'authScreen.loginFailed' => 'ورود ناموفق بود',
			'authScreen.username' => 'نام کاربری',
			'authScreen.confirmPassword' => 'تکرار رمز عبور',
			'authScreen.inviteCode' => 'کد دعوت',
			'authScreen.emailCode' => 'کد تأیید ایمیل',
			'authScreen.getCode' => 'دریافت کد',
			'authScreen.registerAndLogin' => 'ثبت‌نام و ورود',
			'authScreen.usernameMinLength' => ({required Object min}) => 'نام کاربری باید حداقل ${min} کاراکتر باشد',
			'authScreen.passwordMismatch' => 'رمزهای عبور یکسان نیستند',
			'authScreen.emailCodeRequired' => 'لطفاً کد تأیید ایمیل را وارد کنید',
			'authScreen.inviteCodeRequired' => 'ثبت‌نام در این سایت به کد دعوت نیاز دارد',
			'authScreen.codeSentCheckEmail' => 'کد تأیید ارسال شد. ایمیل خود را بررسی کنید.',
			'authScreen.registerSuccess' => 'ثبت‌نام موفق بود. اکنون وارد شده‌اید.',
			'authScreen.passwordHint' => ({required Object min}) => 'حداقل ${min} کاراکتر، شامل حرف و رقم',
			'authScreen.passwordTooShort' => ({required Object min}) => 'رمز عبور باید حداقل ${min} کاراکتر باشد',
			'authScreen.passwordNeedsLetterAndDigit' => 'رمز عبور باید هم حرف و هم رقم داشته باشد',
			'authScreen.registeredEmail' => 'ایمیل ثبت‌شده',
			'authScreen.newPassword' => 'رمز عبور جدید',
			'authScreen.confirmNewPassword' => 'تکرار رمز عبور جدید',
			'authScreen.resetPassword' => 'بازنشانی رمز عبور',
			'authScreen.resetCodeSent' => 'اگر این ایمیل ثبت شده باشد، کد بازنشانی ارسال شده است (تا ۱۵ دقیقه معتبر است).',
			'authScreen.resetSuccess' => 'رمز عبور بازنشانی شد. با رمز جدید وارد شوید.',
			'authScreen.changePasswordTitle' => 'تغییر رمز عبور',
			'authScreen.currentPassword' => 'رمز عبور فعلی',
			'authScreen.saveNewPassword' => 'ذخیره رمز عبور جدید',
			'authScreen.newPasswordMismatch' => 'رمزهای عبور جدید یکسان نیستند',
			'authScreen.changePasswordSuccess' => 'رمز عبور تغییر کرد. لطفاً دوباره وارد شوید.',
			'updatePrompt.checking' => 'در حال بررسی به‌روزرسانی…',
			'updatePrompt.checkFailed' => 'بررسی به‌روزرسانی ناموفق بود. شبکه را بررسی کنید و دوباره تلاش کنید.',
			'updatePrompt.alreadyLatest' => ({required Object version}) => 'شما آخرین نسخه را دارید (${version}).',
			'updatePrompt.newVersionFound' => ({required Object version}) => 'نسخه جدید ${version} در دسترس است',
			'updatePrompt.installerDownloaded' => 'نصب‌کننده در پس‌زمینه دانلود شد. برای تکمیل ارتقا «به‌روزرسانی» را بزنید.',
			'updatePrompt.downloadInBackground' => 'برای دانلود و نصب آن «به‌روزرسانی» را بزنید (می‌توانید به استفاده از برنامه ادامه دهید؛ نصب‌کننده در پس‌زمینه دانلود می‌شود).',
			'updatePrompt.later' => 'بعداً',
			'updatePrompt.updateNow' => 'به‌روزرسانی',
			'updatePrompt.installerNotReady' => ({required Object version}) => 'نصب‌کننده هنوز دانلود نشده است.\n\nبرای باز کردن صفحه دانلود و دریافت دستی نصب‌کننده مناسب دستگاه خود «تأیید» را بزنید (نسخه ${version}).',
			'clearData.itemLoginSession' => 'نشست ورود',
			'clearData.itemProfiles' => 'پروفایل‌های اشتراک (profiles/)',
			'clearData.itemSettings' => 'تنظیمات برنامه و هسته',
			'clearData.itemLatencyCache' => 'کش تأخیر گره‌ها',
			'clearData.itemLogs' => 'گزارش‌های اجرا',
			'clearData.itemRoutingData' => 'داده‌های مسیریابی و فایل‌های موقت',
			'clearData.confirmBody' => ({required Object items, required Object dir}) => 'داده‌های زیر که روی این دستگاه ذخیره شده‌اند پاک می‌شوند (این کار بازگشت‌پذیر نیست):\n\n${items}\n\nخودِ حساب و طرحی که خریده‌اید روی سرور هستند و آسیب نمی‌بینند؛ برای بازگرداندن اشتراک دوباره وارد شوید.\n\nپوشه داده‌ها: ${dir}\n(این کار را پیش از حذف برنامه انجام دهید: تنها در این صورت نصب دوباره از صفر شروع می‌شود و دوباره از شما ورود می‌خواهد)',
			'clearData.confirmAgain' => 'همین حالا پاک شود؟ پس از آن باید دوباره وارد شوید.',
			'clearData.clearedNotice' => ({required Object count, required Object dir}) => '${count} مورد از داده‌های محلی پاک شد (شامل نشست ورود، بنابراین دفعه بعد که برنامه را باز کنید باید دوباره وارد شوید).\n\nحالا می‌توانید برای تکمیل حذف، خودِ برنامه را پاک کنید:\n· macOS: فایل Mclash.app را به سطل زباله بکشید (پوشه داده‌ها خالی شده است: ${dir})\n· Windows: Mclash را از کنترل پنل حذف کنید و وقتی پرسید داده‌های کاربر نگه داشته شود، «خیر» را انتخاب کنید',
			'clearData.clearFailed' => ({required Object error}) => 'پاک کردن ناموفق بود: ${error}',
			'apiError.requestFailedHttp' => ({required Object status, required Object domain}) => 'درخواست ناموفق بود (HTTP ${status})؛ قبلاً ${domain} امتحان شد',
			'apiError.allDomainsFailed' => ({required Object method, required Object path, required Object count}) => 'درخواست ناموفق بود: ${method} ${path} (${count} دامنه امتحان شد)',
			'apiError.requestTimeout' => ({required Object seconds, required Object method, required Object path}) => 'مهلت درخواست تمام شد (${seconds} ثانیه): ${method} ${path}',
			'apiError.networkUnreachable' => ({required Object detail}) => 'شبکه در دسترس نیست: ${detail}',
			'apiError.tlsHandshakeFailed' => 'دست‌دادن TLS ناموفق بود. اتصال شبکه یا ساعت سیستم را بررسی کنید.',
			'apiError.connectionFailed' => ({required Object detail}) => 'اتصال ناموفق بود: ${detail}',
			'apiError.requestError' => ({required Object error}) => 'درخواست ناموفق بود: ${error}',
			'apiError.responseReadTimeout' => ({required Object seconds, required Object method, required Object path}) => 'مهلت خواندن پاسخ تمام شد (${seconds} ثانیه): ${method} ${path}',
			'apiError.notJson' => ({required Object status, required Object snippet}) => 'پاسخ JSON نیست (HTTP ${status}): ${snippet}',
			'apiError.badStructure' => ({required Object status}) => 'ساختار پاسخ غیرمنتظره است (HTTP ${status})',
			'apiError.loginFailed' => ({required Object code}) => 'ورود ناموفق بود (کد ${code})',
			'apiError.loginMissingData' => 'پاسخ ورود فاقد داده است',
			'apiError.loginMissingToken' => 'پاسخ ورود فاقد access_token است',
			'apiError.registerFailed' => ({required Object code}) => 'ثبت‌نام ناموفق بود (کد ${code})',
			'apiError.registerMissingToken' => 'پاسخ ثبت‌نام access_token ندارد - ممکن است کنترل ریسک فعال شده باشد یا سایت متفاوت پیکربندی شده باشد',
			'apiError.requestFailedCode' => ({required Object code}) => 'درخواست ناموفق بود (کد ${code})',
			'subNotice.titleNotFound' => 'اشتراک پیدا نشد',
			'subNotice.titleExpired' => 'اشتراک منقضی شده',
			'subNotice.titleInactive' => 'اشتراک غیرفعال است',
			'subNotice.titleDeviceOverLimit' => 'از سقف دستگاه فراتر رفت',
			'subNotice.titleUnavailable' => 'اشتراک در دسترس نیست',
			'subNotice.titleWithReason' => ({required Object emoji, required Object title, required Object reason}) => '${emoji} ${title} (${reason})',
			'subNotice.deviceUsedOfLimit' => ({required Object used, required Object limit}) => 'دستگاه‌های فعلی ${used}/${limit}',
			'subNotice.deviceUsedOnly' => ({required Object used}) => 'دستگاه‌های فعلی ${used}',
			'subNotice.expireAt' => ({required Object expire}) => 'انقضا ${expire}',
			'subNotice.supportLine' => ({required Object account}) => '💬 پشتیبانی: ${account}',
			'subNotice.siteLine' => ({required Object url}) => '📢 وب‌سایت: ${url}',
			'settingItems.subscriptionAutoUpdateInterval' => 'بازه به‌روزرسانی خودکار اشتراک',
			'settingItems.speedTestMode' => 'روش تست سرعت',
			'settingItems.speedTestModeTcp' => 'تست سرعت TCP',
			'settingItems.speedTestModeKernel' => 'تست سرعت هسته',
			'settingItems.delayTestUrlTip' => 'زمان یک درخواست کامل HTTP از این گره (پینگ نیست)\nبه‌طور پیش‌فرض یک پاسخ خالی http 204 است؛ استفاده از https یک دست‌دادن TLS اضافه می‌کند و عدد بزرگ‌تر می‌شود',
			'settingItems.systemProxy' => 'پروکسی سیستم',
			'settingItems.systemProxyTip' => 'مشاهده / تنظیم مجدد آدرس و پورت',
			'settingItems.tunMode' => 'حالت TUN',
			'settingItems.tunModeTip' => 'off=فقط پروکسی سیستم / auto=TUN+پروکسی سیستم / force=فقط TUN\nدر دسکتاپ، TUN به دسترسی مدیر نیاز دارد (wintun در Windows / utun در macOS)',
			'settingItems.tunOverwriteTip' => 'overwrite\nروشن = تنظیمات TUN این صفحه بخش tun پروفایل را بازنویسی می‌کند\nخاموش = از پیکربندی tun خود پروفایل استفاده می‌شود (برنامه دخالت نمی‌کند)',
			'settingItems.tunEnableByTunMode' => ({required Object enable}) => '${enable} (بر اساس حالت TUN)',
			'settingItems.interval30Minutes' => '۳۰ دقیقه',
			'settingItems.interval1Hour' => '۱ ساعت',
			'settingItems.interval6Hours' => '۶ ساعت',
			'settingItems.interval12Hours' => '۱۲ ساعت',
			'settingItems.interval24Hours' => '۲۴ ساعت',
			'settingItems.interval3Days' => '۳ روز',
			'settingItems.interval7Days' => '۷ روز',
			'settingItems.intervalNever' => 'هرگز',
			'settingItems.intervalMinutes' => ({required Object minutes}) => '${minutes} دقیقه',
			'settingItems.intervalHours' => ({required Object hours}) => '${hours} ساعت',
			'settingItems.intervalDays' => ({required Object days}) => '${days} روز',
			'tunScreen.modeOff' => 'خاموش',
			'tunScreen.modeAuto' => 'خودکار',
			'tunScreen.modeForce' => 'اجباری',
			'tunScreen.modeOffDesc' => 'فقط پروکسی سیستم: برای برنامه‌هایی که پروکسی سیستم را رعایت می‌کنند کار می‌کند (مرورگرها و مانند آن)؛ UDP و بازی‌ها پروکسی نمی‌شوند',
			'tunScreen.modeAutoDesc' => 'TUN + پروکسی سیستم (دو لایه ایمنی): همه ترافیک از آداپتور مجازی عبور می‌کند، از جمله UDP',
			'tunScreen.modeForceDesc' => 'فقط TUN: همه ترافیک از آداپتور مجازی عبور می‌کند و پروکسی سیستم دست‌نخورده می‌ماند',
			'tunScreen.modeOffOptionDesc' => 'جدول مسیریابی سیستم را تغییر نمی‌دهد؛ فقط یک پروکسی 127.0.0.1 در سیستم تنظیم می‌کند. تنها برنامه‌هایی که پروکسی سیستم را رعایت می‌کنند از آن استفاده می‌کنند؛ ترافیک UDP و برنامه‌هایی که پروکسی اختصاصی دارند، نه.',
			'tunScreen.modeAutoOptionDesc' => 'یک آداپتور مجازی می‌سازد و همه ترافیک را در اختیار می‌گیرد (از جمله UDP و بازی‌ها)؛ پروکسی سیستم به‌عنوان پشتیبان باقی می‌ماند. پیشنهادی: سراسری کار می‌کند و اگر مجوزها موجود نباشند، بدون اینترنت نمی‌مانید.',
			'tunScreen.modeForceOptionDesc' => 'فقط از آداپتور مجازی استفاده می‌کند و دیگر پروکسی سیستم را تغییر نمی‌دهد. همه ترافیک (از جمله UDP) از تونل عبور می‌کند؛ گزینه «proxy» در سیستم دست‌نخورده می‌ماند.',
			'tunScreen.adminRequiredDialog' => 'آداپتور مجازی TUN به دسترسی مدیر نیاز دارد (wintun در Windows / utun در macOS).\n\nMclash در حال حاضر با دسترسی مدیر اجرا نشده است، بنابراین TUN پس از فعال‌سازی اعمال نمی‌شود (در حالت «خودکار» پروکسی سیستم به‌عنوان پشتیبان کار می‌کند و شبکه قابل استفاده می‌ماند).\n\nتأیید = Mclash همین حالا با دسترسی مدیر دوباره اجرا شود (پنجره UAC نمایش داده می‌شود)\nلغو = این انتخاب ذخیره شود (وقتی TUN در دسترس نباشد از پروکسی سیستم استفاده می‌شود)',
			'tunScreen.relaunchFailed' => ({required Object message}) => 'راه‌اندازی مجدد ناموفق بود: ${message}',
			'tunScreen.switchFailed' => ({required Object message}) => 'تغییر حالت TUN ناموفق بود: ${message}\nتنظیمات قبلی بازگردانده شد.',
			'tunScreen.setOffSnack' => 'روی «خاموش» تنظیم شد: فقط پروکسی سیستم',
			'tunScreen.setModeSnack' => ({required Object mode, required Object effect}) => 'روی «${mode}» تنظیم شد، ${effect}',
			'tunScreen.effectReconnected' => 'دوباره متصل شد و اکنون فعال است',
			'tunScreen.effectAfterConnect' => 'پس از اتصال فعال می‌شود',
			'tunScreen.sheetTitle' => 'آداپتور مجازی TUN',
			'tunScreen.advancedTitle' => 'پارامترهای پیشرفته (تنظیمات هسته → TUN)',
			'tunScreen.advancedSubtitle' => 'آدرس آداپتور / پشته / MTU / مسیریابی خودکار / ربودن DNS / بازنویسی',
			'tunScreen.adminOk' => 'TUN به دسترسی مدیر نیاز دارد؛ دسترسی فعلی کافی است (در Windows با دسترسی مدیر / در macOS با کاربر root اجرا کنید)',
			'tunScreen.adminMissing' => 'TUN به دسترسی مدیر نیاز دارد: Mclash با دسترسی مدیر اجرا نمی‌شود، بنابراین پس از انتخاب «خودکار/اجباری» TUN اعمال نمی‌شود (حالت «خودکار» به پروکسی سیستم برمی‌گردد و شبکه قابل استفاده می‌ماند)',
			_ => null,
		};
	}
}
