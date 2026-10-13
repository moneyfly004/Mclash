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
class TranslationsAr with BaseTranslations<AppLocale, Translations> implements Translations {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	TranslationsAr({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: AppLocale.ar,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <ar>.
	final TranslationMetadata<AppLocale, Translations> _meta;
	@override TranslationMetadata<AppLocale, Translations> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key);

	late final TranslationsAr _root = this; // ignore: unused_field

	@override 
	TranslationsAr $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => TranslationsAr(meta: meta ?? this.$meta);

	// Translations
	@override late final _Translations$BackupAndSyncWebdavScreen$ar BackupAndSyncWebdavScreen = _Translations$BackupAndSyncWebdavScreen$ar._(_root);
	@override late final _Translations$LaunchFailedScreen$ar LaunchFailedScreen = _Translations$LaunchFailedScreen$ar._(_root);
	@override late final _Translations$PerAppAndroidScreen$ar PerAppAndroidScreen = _Translations$PerAppAndroidScreen$ar._(_root);
	@override late final _Translations$UserAgreementScreen$ar UserAgreementScreen = _Translations$UserAgreementScreen$ar._(_root);
	@override late final _Translations$NetCheckScreen$ar NetCheckScreen = _Translations$NetCheckScreen$ar._(_root);
	@override late final _Translations$VersionUpdateScreen$ar VersionUpdateScreen = _Translations$VersionUpdateScreen$ar._(_root);
	@override late final _Translations$loginScreen$ar loginScreen = _Translations$loginScreen$ar._(_root);
	@override late final _Translations$main$ar main = _Translations$main$ar._(_root);
	@override late final _Translations$meta$ar meta = _Translations$meta$ar._(_root);
	@override late final _Translations$permission$ar permission = _Translations$permission$ar._(_root);
	@override late final _Translations$tls$ar tls = _Translations$tls$ar._(_root);
	@override late final _Translations$tun$ar tun = _Translations$tun$ar._(_root);
	@override late final _Translations$dns$ar dns = _Translations$dns$ar._(_root);
	@override late final _Translations$sniffer$ar sniffer = _Translations$sniffer$ar._(_root);
	@override late final _Translations$profilePatchMode$ar profilePatchMode = _Translations$profilePatchMode$ar._(_root);
	@override String sendOrReceiveNotMatch({required Object p}) => 'الرجاء استخدام [${p}]';
	@override String targetConnectFailed({required Object p}) => 'فشل الاتصال بـ [${p}]، يرجى التأكد من وجود الجهاز في نفس الشبكة المحلية (LAN)';
	@override String get edgeRuntimeNotInstalled => 'لم يتم تثبيت وقت تشغيل Edge WebView2 على الجهاز الحالي ولا يمكن عرض الصفحة، يرجى تنزيل وتثبيت وقت تشغيل Edge WebView2 (x64)، وإعادة تشغيل التطبيق والمحاولة مرة أخرى.';
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
	@override late final _Translations$meScreen$ar meScreen = _Translations$meScreen$ar._(_root);
	@override late final _Translations$homeScreen$ar homeScreen = _Translations$homeScreen$ar._(_root);
	@override late final _Translations$nodesScreen$ar nodesScreen = _Translations$nodesScreen$ar._(_root);
	@override late final _Translations$nodeAuto$ar nodeAuto = _Translations$nodeAuto$ar._(_root);
	@override late final _Translations$accountBlock$ar accountBlock = _Translations$accountBlock$ar._(_root);
	@override late final _Translations$entitlementMsg$ar entitlementMsg = _Translations$entitlementMsg$ar._(_root);
	@override late final _Translations$devicesScreen$ar devicesScreen = _Translations$devicesScreen$ar._(_root);
	@override late final _Translations$sysProxySheet$ar sysProxySheet = _Translations$sysProxySheet$ar._(_root);
	@override late final _Translations$logScreen$ar logScreen = _Translations$logScreen$ar._(_root);
	@override late final _Translations$trayShell$ar trayShell = _Translations$trayShell$ar._(_root);
}

// Path: BackupAndSyncWebdavScreen
class _Translations$BackupAndSyncWebdavScreen$ar implements Translations$BackupAndSyncWebdavScreen$en {
	_Translations$BackupAndSyncWebdavScreen$ar._(this._root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get webdavServerUrl => 'عنوان URL الخادم';
	@override String get webdavRequired => 'لايمكن ان يكون فارغا';
	@override String get webdavLoginFailed => 'فشل تسجيل الدخول:';
	@override String get webdavListFailed => 'فشل في الحصول على قائمة الملفات:';
}

// Path: LaunchFailedScreen
class _Translations$LaunchFailedScreen$ar implements Translations$LaunchFailedScreen$en {
	_Translations$LaunchFailedScreen$ar._(this._root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get invalidProcess => 'فشل التطبيق في البدء [اسم عملية غير صالح] ، يرجى إعادة تثبيت التطبيق إلى دليل منفصل';
	@override String get invalidProfile => 'فشل التطبيق في البدء [فشل في الوصول إلى الملف الشخصي] ، يرجى إعادة تثبيت التطبيق';
	@override String get invalidVersion => 'فشل التطبيق في بدء [إصدار غير صالح] ، يرجى إعادة تثبيت التطبيق';
	@override String get systemVersionLow => 'فشل بدء تشغيل التطبيق [إصدار النظام منخفض جدًا]';
	@override String get invalidInstallPath => 'مسار التثبيت غير صالح ، يرجى إعادة تثبيته إلى مسار صالح';
}

// Path: PerAppAndroidScreen
class _Translations$PerAppAndroidScreen$ar implements Translations$PerAppAndroidScreen$en {
	_Translations$PerAppAndroidScreen$ar._(this._root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get title => 'لكل وكيل تطبيق';
	@override String get whiteListMode => 'وضع القائمة البيضاء';
	@override String get whiteListModeTip => 'عند التمكين: فقط التطبيقات التي تم فحصها هي وكلاء ؛عندما لا يتم تمكينها: فقط التطبيقات التي لم يتم فحصها هي وكلاء';
}

// Path: UserAgreementScreen
class _Translations$UserAgreementScreen$ar implements Translations$UserAgreementScreen$en {
	_Translations$UserAgreementScreen$ar._(this._root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get privacyFirst => 'خصوصيتك تأتي أولا';
	@override String get agreeAndContinue => 'قبول ومتابعة';
}

// Path: NetCheckScreen
class _Translations$NetCheckScreen$ar implements Translations$NetCheckScreen$en {
	_Translations$NetCheckScreen$ar._(this._root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get enterDomain => 'أدخل اسم النطاق';
	@override String get checking => 'جارٍ الفحص...';
	@override String aQueryFailed({required Object p}) => 'فشل استعلام A: ${p}';
	@override String aaaaQueryFailed({required Object p}) => 'فشل استعلام AAAA: ${p}';
	@override String get success => 'نجاح';
	@override String get failed => 'فشل';
	@override String get suspectedPollution => 'يُشتبه في تسميم DNS';
	@override String get domainLabel => 'النطاق';
	@override String get checkButton => 'فحص';
	@override String get dnsSection => '1. استعلام DNS';
	@override String get directHttpSection => '2. HTTP (عبر TUN، يرجى تفعيل TUN أولاً)';
	@override String proxyHttpSection({required Object p}) => '3. HTTP (عبر الوكيل، المنفذ: ${p})';
	@override String get tunNotEnabled => 'TUN غير مفعّل';
	@override String get routeTableSection => '4. جدول التوجيه';
}

// Path: VersionUpdateScreen
class _Translations$VersionUpdateScreen$ar implements Translations$VersionUpdateScreen$en {
	_Translations$VersionUpdateScreen$ar._(this._root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String versionReady({required Object p}) => 'الإصدار الجديد [${p}] جاهز';
	@override String get update => 'أعد التشغيل للتحديث';
	@override String get cancel => 'ليس الآن';
}

// Path: loginScreen
class _Translations$loginScreen$ar implements Translations$loginScreen$en {
	_Translations$loginScreen$ar._(this._root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get login => 'دخول';
	@override String get register => 'إنشاء حساب';
	@override String get forgotPassword => 'هل نسيت كلمة المرور';
	@override String get provider => 'مزود الخدمة';
	@override String get providerName => 'رمز/اسم مستعار/URL لـ ${_root.loginScreen.provider}';
	@override String get account => 'حساب';
	@override String get email => 'البريد الإلكتروني';
	@override String get password => 'كلمة المرور';
}

// Path: main
class _Translations$main$ar implements Translations$main$en {
	_Translations$main$ar._(this._root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override late final _Translations$main$tray$ar tray = _Translations$main$tray$ar._(_root);
}

// Path: meta
class _Translations$meta$ar implements Translations$meta$en {
	_Translations$meta$ar._(this._root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get enable => 'يُمكَِن';
	@override String get disable => 'إبطال';
	@override String get open => 'يفتح';
	@override String get close => 'إنهاء';
	@override String get quit => 'يترك';
	@override String get add => 'اضف إليه';
	@override String get remove => 'يمسح';
	@override String get removeConfirm => 'هل انت متأكد من الحذف؟';
	@override String get edit => 'يحرر';
	@override String get view => 'يفحص';
	@override String get remark => 'ملاحظة';
	@override String get byDefault => 'تقصير';
	@override String get more => 'أكثر';
	@override String get tips => 'معلومات';
	@override String get selectAll => 'تحديد الكل';
	@override String get copy => 'ينسخ';
	@override String get paste => 'لصق';
	@override String get cut => 'يقطع';
	@override String get save => 'يحفظ';
	@override String get ok => 'نعم';
	@override String get cancel => 'يلغي';
	@override String get faq => 'أسئلة مكررة';
	@override String get doc => 'وثيقة';
	@override String get htmlTools => 'مجموعة أدوات HTML';
	@override String get download => 'تحميل';
	@override String get loading => 'تحميل...';
	@override String get days => 'أيام';
	@override String get hours => 'ساعات';
	@override String get minutes => 'دقائق';
	@override String get seconds => 'ثانية';
	@override String get milliseconds => 'ميلي ثانية';
	@override String get search => 'يبحث';
	@override String get searchNodeHint => 'تصفية العُقد (الاسم أو البروتوكول)';
	@override String get connect => 'يتصل';
	@override String get disconnect => 'قطع الاتصال';
	@override String get connected => 'متصل';
	@override String get disconnected => 'انقطع الاتصال';
	@override String get connecting => 'توصيل';
	@override String get connectTimeout => 'ربط مهلة';
	@override String get timeout => 'نفذ الوقت';
	@override String get latencyTest => 'كشف التأخير';
	@override String get networkCheck => 'فحص الشبكة';
	@override String get language => 'لغة';
	@override String get next => 'التالي';
	@override String get done => 'منتهي';
	@override String get apply => 'يتقدم';
	@override String get refresh => 'ينعش';
	@override String get update => 'تجديد';
	@override String get updateInterval => 'الفاصل الزمني للتحديث';
	@override String get updateInterval5mTips => 'الحد الأدنى: 5 م';
	@override String get updateIntervalPreferByProfile => 'إعطاء الأولوية لإعدادات المزود';
	@override String updateFailed({required Object p}) => 'فشل التحديث:${p}';
	@override String get none => 'لا أحد';
	@override String get reset => 'إعادة ضبط';
	@override String get authentication => 'التفويض';
	@override String get user => 'مستخدم';
	@override String get account => 'حساب';
	@override String get password => 'كلمة المرور';
	@override String get decryptPassword => 'فك تشفير كلمة المرور';
	@override String get required => 'مطلوب';
	@override String get go => 'متابعة';
	@override String get other => 'آخر';
	@override String get dns => 'DNS';
	@override String get url => 'URL';
	@override String get urlInvalid => 'URL غير صالح';
	@override String get copyUrl => 'نسخ الرابط';
	@override String get openUrl => 'فتح الرابط';
	@override String get coreSettingTips => 'ملاحظة: بعد تعديل التكوين، تحتاج إلى إعادة الاتصال حتى يسري مفعوله';
	@override String get overwrite => 'تجاوز';
	@override String get overwriteAppend => 'تجاوز إضافي';
	@override String get overwriteTips => 'التكوين الأصلي <- تجاوز مخصص <- تجاوز التطبيق';
	@override String get noOverwrite => 'لا تكتب فوق';
	@override String get diversionTemplates => 'نموذج الفرز';
	@override String get ruleProviders => 'موفر القواعد';
	@override String get ruleTemplates => 'نموذج القاعدة';
	@override String get proxyGroupsTemplates => 'نموذج مجموعة الوكلاء';
	@override String get proxyGroups => 'مجموعة الوكلاء';
	@override String get proxyNodeList => 'قائمة عقد الوكيل';
	@override String proxyNodeFailure({required Object p}) => 'انتهت صلاحية عقد الوكيل التالية وتمت إزالتها تلقائيًا: ${p}';
	@override String get externalController => 'الرقابة الخارجية';
	@override String get secret => 'Secret';
	@override String get tcpConcurrent => 'مصافحة TCP المتزامنة';
	@override String get globalClientFingerprint => 'بصمة TLS العالمية';
	@override String get allowLanAccess => 'الوصول إلى جهاز LAN';
	@override String get mixedPort => 'منفذ الوكيل الهجين';
	@override String get logLevel => 'مستوى السجل';
	@override String get findProcessMode => 'وضع مطابقة العملية';
	@override String get tcpkeepAliveInterval => 'فترة الحفاظ على اتصال TCP';
	@override String get delayTestUrl => 'عنوان URL لاختبار زمن الوصول';
	@override String get delayTestTimeout => 'تأخير مهلة الاختبار (مللي ثانية)';
	@override String get tun => 'TUN';
	@override String get ntp => 'NTP';
	@override String get tls => 'TLS';
	@override String get geoDownloadByProxy => 'تنزيل Geo RuleSet باستخدام وكيل';
	@override String get geoRulesetTips => 'سيتم تحويل Geosite/Geoip إلى مجموعة القواعد المقابلة';
	@override String get sniffer => 'شم';
	@override String get userAgent => 'UserAgent';
	@override String get launchAtStartup => 'إطلاق عند بدء التشغيل';
	@override String get launchAtStartupRunAsAdmin => 'يرجى إعادة تشغيل Mclash كمسؤول';
	@override String get tunModeRunAsAdmin => 'يتطلب وضع TUN أذونات مسؤول النظام ، يرجى إعادة تشغيل التطبيق كمسؤول';
	@override String get portableMode => 'الوضع المحمول';
	@override String get portableModeDisableTips => 'إذا كنت بحاجة إلى الخروج من الوضع المحمول، فيرجى الخروج من [mclash] وحذف المجلد [portable] يدويًا في نفس الدليل مثل [mclash.exe]';
	@override String get autoConnectAfterLaunch => 'اتصال السيارات بعد الإطلاق';
	@override String get autoConnectAtBoot => 'الاتصال التلقائي بعد بدء تشغيل النظام';
	@override String get autoConnectAtBootTips => 'يجب دعم النظام؛ وقد تتطلب بعض الأنظمة أيضًا تمكين [البدء التلقائي].';
	@override String get hideAfterLaunch => 'إخفاء النافذة بعد بدء التشغيل';
	@override String get autoSetSystemProxy => 'وكيل نظام تعيين تلقائي عند الاتصال';
	@override String get bypassSystemProxy => 'أسماء النطاقات المسموح لها بتجاوز وكيل النظام';
	@override String get excludeFromRecent => 'إخفاء من المهام الأخيرة';
	@override String get wakeLock => 'قفل الاستيقاظ';
	@override String get hideDockIcon => 'إخفاء أيقونة Dock';
	@override String get showTrayTraffic => 'إظهار معلومات حركة المرور في شريط النظام';
	@override String get website => 'موقع إلكتروني';
	@override String get rule => 'قاعدة';
	@override String get global => 'عالمي';
	@override String get direct => 'مباشر';
	@override String get qrcode => 'رمز الاستجابة السريعة';
	@override String get qrcodeTooLong => 'النص طويل جدًا لعرضه';
	@override String get qrcodeShare => 'شارك رمز الاستجابة السريعة';
	@override String get qrcodeScan => 'مسح رمز الاستجابة السريعة';
	@override String get qrcodeScanResult => 'نتيجة المسح';
	@override String get backupAndSync => 'النسخ الاحتياطي والمزامنة';
	@override String get export => 'يصدّر';
	@override String get send => 'يرسل';
	@override String get sendConfirm => 'تأكيد الإرسال؟';
	@override String get log => 'سجل';
	@override String get coreLog => 'سجل النواة';
	@override String get appLog => 'سجل التطبيق';
	@override String get core => 'جوهر';
	@override String get help => 'يساعد';
	@override String get tutorial => 'درس تعليمي';
	@override String get board => 'لوحة';
	@override String get boardOnline => 'استخدام اللوحة عبر الإنترنت';
	@override String get boardOnlineUrl => 'عنوان URL للوحة عبر الإنترنت';
	@override String get boardLocalPort => 'منفذ اللوحة المحلية';
	@override String get alwayOnVPN => 'اتصال مفتوح دائمًا';
	@override String get disableFontScaler => 'تعطيل تحجيم الخط(يسري مفعوله بعد إعادة التشغيل)';
	@override String get autoOrientation => 'Rotate with the screen';
	@override String get restartTakesEffect => 'Restart takes effect';
	@override String get reconnectTakesEffect => 'سيتم تطبيقه بعد إعادة الاتصال.';
	@override String get runtimeProfile => 'تكوين وقت التشغيل';
	@override String get willCompleteAfterRebootInstall => 'يرجى إعادة تشغيل جهازك لإكمال تثبيت توسيع النظام';
	@override String get requestNeedsUserApproval => '١. يُرجى السماح لـ Mclash بتثبيت ملحقات النظام من [إعدادات النظام] - [الخصوصية والأمان]. ٢. : [إعدادات النظام] - [عام] - [عناصر تسجيل الدخول والملحقات - ملحقات الشبكة] فعّل [mclashServiceSE]. أعد الاتصال بعد الانتهاء.';
	@override String get FullDiskAccessPermissionRequired => 'يرجى تمكين إذن mclashServiceSE في [إعدادات النظام]-[الخصوصية والأمان]-[الوصول الكامل للقرص] وإعادة الاتصال.';
	@override String get proxy => 'التمثيل';
	@override String get theme => 'سمة';
	@override String get tvMode => 'وضع التلفزيون';
	@override String get autoUpdate => 'التحديثات التلقائية';
	@override String get updateChannel => 'تحديث القنوات تلقائيا';
	@override String hasNewVersion({required Object p}) => 'تحديث الإصدار ${p}';
	@override String get autoDownloadPkg => 'تنزيل حزم التحديث تلقائيًا';
	@override String get devOptions => 'خيارات للمطور';
	@override String get about => 'عن';
	@override String get name => 'اسم';
	@override String get version => 'إصدار';
	@override String get sort => 'إعادة ترتيب';
	@override String get share => 'يشارك';
	@override String get importFromClipboard => 'استيراد من الحافظة';
	@override String get exportToClipboard => 'تصدير إلى الحافظة';
	@override String get server => 'الخادم';
	@override String get port => 'ميناء';
	@override String get donate => 'يتبرع';
	@override String get setting => 'إعدادات';
	@override String get settingCore => 'الإعدادات الأساسية';
	@override String get settingApp => 'إعدادات التطبيق';
	@override String get coreOverwrite => 'تجاوز النواة';
	@override String get iCloud => 'iCloud';
	@override String get webdav => 'Webdav';
	@override String get lanSync => 'LAN SYNC';
	@override String get lanSyncNotQuitTips => 'لا تخرج من هذه الواجهة قبل اكتمال التزامن';
	@override String get deviceNoSpace => 'مساحة غير كافيه في القرص';
	@override String get hideSystemApp => 'إخفاء تطبيقات النظام';
	@override String get hideAppIcon => 'إخفاء أيقونة التطبيق';
	@override String get openDir => 'فتح دليل الملف';
	@override String get type => 'النوع';
	@override String fileNotExist({required Object p}) => 'الملف غير موجود: ${p}';
	@override String get buyProfile => 'شراء ملف تعريف';
	@override String get myProfiles => 'مظهر';
	@override String get profileEdit => 'تحرير الملف الشخصي';
	@override String get profileNeedActive => 'يرجى أولاً تعيين هذا الملف كملف التعريف الحالي، ثم بدء الاتصال/إعادة الاتصال';
	@override String profileUrlOrContent({required Object p}) => 'رابط إعداد ${p}';
	@override String get tabHome => 'الرئيسية';
	@override String get tabNodes => 'العُقد';
	@override String get tabPlans => 'الخطط';
	@override String get tabMe => 'حسابي';
}

// Path: permission
class _Translations$permission$ar implements Translations$permission$en {
	_Translations$permission$ar._(this._root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get camera => 'الكاميرا';
	@override String get screen => 'تسجيل الشاشة';
	@override String get appQuery => 'الحصول على قائمة التطبيقات';
	@override String request({required Object p}) => 'تمكين أذونات [${p}]';
	@override String requestNeed({required Object p}) => 'الرجاء تفعيل إذن [${p}]';
}

// Path: tls
class _Translations$tls$ar implements Translations$tls$en {
	_Translations$tls$ar._(this._root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get certificate => 'شهادة';
	@override String get privateKey => 'المفتاح الخاص';
	@override String get customTrustCert => 'شهادات مخصصة';
}

// Path: tun
class _Translations$tun$ar implements Translations$tun$en {
	_Translations$tun$ar._(this._root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get stack => 'مكدس الشبكة';
	@override String get inet4Address => 'نطاق عناوين IPv4';
	@override String get dnsHijack => 'اختطاف DNS';
	@override String get strictRoute => 'التوجيه الصارم';
	@override String get tunDefaultRoute => 'المسار الافتراضي';
	@override String get icmpForward => 'توجيه رسائل ICMP';
	@override String get allowBypass => 'السماح للتطبيقات بتجاوز VPN';
	@override String get appendHttpProxy => 'إلحاق وكيل HTTP إلى VPN';
	@override String get bypassHttpProxyDomain => 'المجالات المسموح لها بتجاوز وكيل HTTP';
}

// Path: dns
class _Translations$dns$ar implements Translations$dns$en {
	_Translations$dns$ar._(this._root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get listen => 'كلمة الاستماع';
	@override String get fakeIp => 'fake-ip';
	@override String get fallback => 'Fallback';
	@override String get preferH3 => 'أولوية DoH H3';
	@override String get useHosts => 'استخدام المضيفين';
	@override String get useSystemHosts => 'استخدام مضيفات النظام';
	@override String get enhancedMode => 'الوضع المحسّن';
	@override String get fakeIPFilterMode => 'وضع التصفية ${_root.dns.fakeIp}';
	@override String get fakeIPFilter => '${_root.dns.fakeIp} التصفية';
	@override String get respectRules => 'اتبع القواعد';
	@override String get nameServer => 'خادم DNS';
	@override String get defaultNameServer => '${_root.meta.byDefault} ${_root.dns.nameServer}';
	@override String get proxyNameServer => '${_root.meta.proxy} ${_root.dns.nameServer}';
	@override String get directNameServer => '${_root.meta.direct} ${_root.dns.nameServer}';
	@override String get fallbackNameServer => '${_root.dns.fallback} ${_root.dns.nameServer}';
	@override String get fallbackGeoIp => '${_root.dns.fallback} GeoIp';
	@override String get fallbackGeoIpCode => '${_root.dns.fallback} GeoIpCode';
}

// Path: sniffer
class _Translations$sniffer$ar implements Translations$sniffer$en {
	_Translations$sniffer$ar._(this._root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get overrideDest => 'غطاء';
}

// Path: profilePatchMode
class _Translations$profilePatchMode$ar implements Translations$profilePatchMode$en {
	_Translations$profilePatchMode$ar._(this._root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get currentSelected => 'المحدد الحالي';
	@override String get overwrite => 'التجاوز المدمج';
	@override String get noOverwrite => 'مُدمج - غير قابل للكتابة فوقه';
}

// Path: meScreen
class _Translations$meScreen$ar implements Translations$meScreen$en {
	_Translations$meScreen$ar._(this._root);

	final TranslationsAr _root; // ignore: unused_field

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
class _Translations$homeScreen$ar implements Translations$homeScreen$en {
	_Translations$homeScreen$ar._(this._root);

	final TranslationsAr _root; // ignore: unused_field

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
class _Translations$nodesScreen$ar implements Translations$nodesScreen$en {
	_Translations$nodesScreen$ar._(this._root);

	final TranslationsAr _root; // ignore: unused_field

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
class _Translations$nodeAuto$ar implements Translations$nodeAuto$en {
	_Translations$nodeAuto$ar._(this._root);

	final TranslationsAr _root; // ignore: unused_field

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
class _Translations$accountBlock$ar implements Translations$accountBlock$en {
	_Translations$accountBlock$ar._(this._root);

	final TranslationsAr _root; // ignore: unused_field

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
class _Translations$entitlementMsg$ar implements Translations$entitlementMsg$en {
	_Translations$entitlementMsg$ar._(this._root);

	final TranslationsAr _root; // ignore: unused_field

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
class _Translations$devicesScreen$ar implements Translations$devicesScreen$en {
	_Translations$devicesScreen$ar._(this._root);

	final TranslationsAr _root; // ignore: unused_field

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
class _Translations$sysProxySheet$ar implements Translations$sysProxySheet$en {
	_Translations$sysProxySheet$ar._(this._root);

	final TranslationsAr _root; // ignore: unused_field

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
class _Translations$logScreen$ar implements Translations$logScreen$en {
	_Translations$logScreen$ar._(this._root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String readAppFailed({required Object e}) => 'Failed to read the app log: ${e}';
	@override String readCoreFailed({required Object e}) => 'Failed to read the kernel log: ${e}';
	@override String get copied => 'Copied (subscription URLs and other secrets are masked; the log file itself may still contain the raw address)';
	@override String get copy => 'Copy';
	@override String get refresh => 'Refresh';
	@override String get empty => 'No content';
}

// Path: trayShell
class _Translations$trayShell$ar implements Translations$trayShell$en {
	_Translations$trayShell$ar._(this._root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get closeTitle => 'Close window';
	@override String get closeBody => 'Closing the window just puts Mclash in the tray — the kernel and system proxy keep working, and your network stays connected.\n\n· OK: minimize to the tray (to quit completely, right-click the tray icon → Quit)\n· Cancel: quit Mclash completely, stop the kernel and restore the system proxy\n\n(Your choice is remembered; next time you can use the tray icon directly)';
}

// Path: main.tray
class _Translations$main$tray$ar implements Translations$main$tray$en {
	_Translations$main$tray$ar._(this._root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get menuOpen => 'يفتح';
	@override String get menuExit => 'مخرج';
}

/// The flat map containing all translations for locale <ar>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on TranslationsAr {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'BackupAndSyncWebdavScreen.webdavServerUrl' => 'عنوان URL الخادم',
			'BackupAndSyncWebdavScreen.webdavRequired' => 'لايمكن ان يكون فارغا',
			'BackupAndSyncWebdavScreen.webdavLoginFailed' => 'فشل تسجيل الدخول:',
			'BackupAndSyncWebdavScreen.webdavListFailed' => 'فشل في الحصول على قائمة الملفات:',
			'LaunchFailedScreen.invalidProcess' => 'فشل التطبيق في البدء [اسم عملية غير صالح] ، يرجى إعادة تثبيت التطبيق إلى دليل منفصل',
			'LaunchFailedScreen.invalidProfile' => 'فشل التطبيق في البدء [فشل في الوصول إلى الملف الشخصي] ، يرجى إعادة تثبيت التطبيق',
			'LaunchFailedScreen.invalidVersion' => 'فشل التطبيق في بدء [إصدار غير صالح] ، يرجى إعادة تثبيت التطبيق',
			'LaunchFailedScreen.systemVersionLow' => 'فشل بدء تشغيل التطبيق [إصدار النظام منخفض جدًا]',
			'LaunchFailedScreen.invalidInstallPath' => 'مسار التثبيت غير صالح ، يرجى إعادة تثبيته إلى مسار صالح',
			'PerAppAndroidScreen.title' => 'لكل وكيل تطبيق',
			'PerAppAndroidScreen.whiteListMode' => 'وضع القائمة البيضاء',
			'PerAppAndroidScreen.whiteListModeTip' => 'عند التمكين: فقط التطبيقات التي تم فحصها هي وكلاء ؛عندما لا يتم تمكينها: فقط التطبيقات التي لم يتم فحصها هي وكلاء',
			'UserAgreementScreen.privacyFirst' => 'خصوصيتك تأتي أولا',
			'UserAgreementScreen.agreeAndContinue' => 'قبول ومتابعة',
			'NetCheckScreen.enterDomain' => 'أدخل اسم النطاق',
			'NetCheckScreen.checking' => 'جارٍ الفحص...',
			'NetCheckScreen.aQueryFailed' => ({required Object p}) => 'فشل استعلام A: ${p}',
			'NetCheckScreen.aaaaQueryFailed' => ({required Object p}) => 'فشل استعلام AAAA: ${p}',
			'NetCheckScreen.success' => 'نجاح',
			'NetCheckScreen.failed' => 'فشل',
			'NetCheckScreen.suspectedPollution' => 'يُشتبه في تسميم DNS',
			'NetCheckScreen.domainLabel' => 'النطاق',
			'NetCheckScreen.checkButton' => 'فحص',
			'NetCheckScreen.dnsSection' => '1. استعلام DNS',
			'NetCheckScreen.directHttpSection' => '2. HTTP (عبر TUN، يرجى تفعيل TUN أولاً)',
			'NetCheckScreen.proxyHttpSection' => ({required Object p}) => '3. HTTP (عبر الوكيل، المنفذ: ${p})',
			'NetCheckScreen.tunNotEnabled' => 'TUN غير مفعّل',
			'NetCheckScreen.routeTableSection' => '4. جدول التوجيه',
			'VersionUpdateScreen.versionReady' => ({required Object p}) => 'الإصدار الجديد [${p}] جاهز',
			'VersionUpdateScreen.update' => 'أعد التشغيل للتحديث',
			'VersionUpdateScreen.cancel' => 'ليس الآن',
			'loginScreen.login' => 'دخول',
			'loginScreen.register' => 'إنشاء حساب',
			'loginScreen.forgotPassword' => 'هل نسيت كلمة المرور',
			'loginScreen.provider' => 'مزود الخدمة',
			'loginScreen.providerName' => 'رمز/اسم مستعار/URL لـ ${_root.loginScreen.provider}',
			'loginScreen.account' => 'حساب',
			'loginScreen.email' => 'البريد الإلكتروني',
			'loginScreen.password' => 'كلمة المرور',
			'main.tray.menuOpen' => 'يفتح',
			'main.tray.menuExit' => 'مخرج',
			'meta.enable' => 'يُمكَِن',
			'meta.disable' => 'إبطال',
			'meta.open' => 'يفتح',
			'meta.close' => 'إنهاء',
			'meta.quit' => 'يترك',
			'meta.add' => 'اضف إليه',
			'meta.remove' => 'يمسح',
			'meta.removeConfirm' => 'هل انت متأكد من الحذف؟',
			'meta.edit' => 'يحرر',
			'meta.view' => 'يفحص',
			'meta.remark' => 'ملاحظة',
			'meta.byDefault' => 'تقصير',
			'meta.more' => 'أكثر',
			'meta.tips' => 'معلومات',
			'meta.selectAll' => 'تحديد الكل',
			'meta.copy' => 'ينسخ',
			'meta.paste' => 'لصق',
			'meta.cut' => 'يقطع',
			'meta.save' => 'يحفظ',
			'meta.ok' => 'نعم',
			'meta.cancel' => 'يلغي',
			'meta.faq' => 'أسئلة مكررة',
			'meta.doc' => 'وثيقة',
			'meta.htmlTools' => 'مجموعة أدوات HTML',
			'meta.download' => 'تحميل',
			'meta.loading' => 'تحميل...',
			'meta.days' => 'أيام',
			'meta.hours' => 'ساعات',
			'meta.minutes' => 'دقائق',
			'meta.seconds' => 'ثانية',
			'meta.milliseconds' => 'ميلي ثانية',
			'meta.search' => 'يبحث',
			'meta.searchNodeHint' => 'تصفية العُقد (الاسم أو البروتوكول)',
			'meta.connect' => 'يتصل',
			'meta.disconnect' => 'قطع الاتصال',
			'meta.connected' => 'متصل',
			'meta.disconnected' => 'انقطع الاتصال',
			'meta.connecting' => 'توصيل',
			'meta.connectTimeout' => 'ربط مهلة',
			'meta.timeout' => 'نفذ الوقت',
			'meta.latencyTest' => 'كشف التأخير',
			'meta.networkCheck' => 'فحص الشبكة',
			'meta.language' => 'لغة',
			'meta.next' => 'التالي',
			'meta.done' => 'منتهي',
			'meta.apply' => 'يتقدم',
			'meta.refresh' => 'ينعش',
			'meta.update' => 'تجديد',
			'meta.updateInterval' => 'الفاصل الزمني للتحديث',
			'meta.updateInterval5mTips' => 'الحد الأدنى: 5 م',
			'meta.updateIntervalPreferByProfile' => 'إعطاء الأولوية لإعدادات المزود',
			'meta.updateFailed' => ({required Object p}) => 'فشل التحديث:${p}',
			'meta.none' => 'لا أحد',
			'meta.reset' => 'إعادة ضبط',
			'meta.authentication' => 'التفويض',
			'meta.user' => 'مستخدم',
			'meta.account' => 'حساب',
			'meta.password' => 'كلمة المرور',
			'meta.decryptPassword' => 'فك تشفير كلمة المرور',
			'meta.required' => 'مطلوب',
			'meta.go' => 'متابعة',
			'meta.other' => 'آخر',
			'meta.dns' => 'DNS',
			'meta.url' => 'URL',
			'meta.urlInvalid' => 'URL غير صالح',
			'meta.copyUrl' => 'نسخ الرابط',
			'meta.openUrl' => 'فتح الرابط',
			'meta.coreSettingTips' => 'ملاحظة: بعد تعديل التكوين، تحتاج إلى إعادة الاتصال حتى يسري مفعوله',
			'meta.overwrite' => 'تجاوز',
			'meta.overwriteAppend' => 'تجاوز إضافي',
			'meta.overwriteTips' => 'التكوين الأصلي <- تجاوز مخصص <- تجاوز التطبيق',
			'meta.noOverwrite' => 'لا تكتب فوق',
			'meta.diversionTemplates' => 'نموذج الفرز',
			'meta.ruleProviders' => 'موفر القواعد',
			'meta.ruleTemplates' => 'نموذج القاعدة',
			'meta.proxyGroupsTemplates' => 'نموذج مجموعة الوكلاء',
			'meta.proxyGroups' => 'مجموعة الوكلاء',
			'meta.proxyNodeList' => 'قائمة عقد الوكيل',
			'meta.proxyNodeFailure' => ({required Object p}) => 'انتهت صلاحية عقد الوكيل التالية وتمت إزالتها تلقائيًا: ${p}',
			'meta.externalController' => 'الرقابة الخارجية',
			'meta.secret' => 'Secret',
			'meta.tcpConcurrent' => 'مصافحة TCP المتزامنة',
			'meta.globalClientFingerprint' => 'بصمة TLS العالمية',
			'meta.allowLanAccess' => 'الوصول إلى جهاز LAN',
			'meta.mixedPort' => 'منفذ الوكيل الهجين',
			'meta.logLevel' => 'مستوى السجل',
			'meta.findProcessMode' => 'وضع مطابقة العملية',
			'meta.tcpkeepAliveInterval' => 'فترة الحفاظ على اتصال TCP',
			'meta.delayTestUrl' => 'عنوان URL لاختبار زمن الوصول',
			'meta.delayTestTimeout' => 'تأخير مهلة الاختبار (مللي ثانية)',
			'meta.tun' => 'TUN',
			'meta.ntp' => 'NTP',
			'meta.tls' => 'TLS',
			'meta.geoDownloadByProxy' => 'تنزيل Geo RuleSet باستخدام وكيل',
			'meta.geoRulesetTips' => 'سيتم تحويل Geosite/Geoip إلى مجموعة القواعد المقابلة',
			'meta.sniffer' => 'شم',
			'meta.userAgent' => 'UserAgent',
			'meta.launchAtStartup' => 'إطلاق عند بدء التشغيل',
			'meta.launchAtStartupRunAsAdmin' => 'يرجى إعادة تشغيل Mclash كمسؤول',
			'meta.tunModeRunAsAdmin' => 'يتطلب وضع TUN أذونات مسؤول النظام ، يرجى إعادة تشغيل التطبيق كمسؤول',
			'meta.portableMode' => 'الوضع المحمول',
			'meta.portableModeDisableTips' => 'إذا كنت بحاجة إلى الخروج من الوضع المحمول، فيرجى الخروج من [mclash] وحذف المجلد [portable] يدويًا في نفس الدليل مثل [mclash.exe]',
			'meta.autoConnectAfterLaunch' => 'اتصال السيارات بعد الإطلاق',
			'meta.autoConnectAtBoot' => 'الاتصال التلقائي بعد بدء تشغيل النظام',
			'meta.autoConnectAtBootTips' => 'يجب دعم النظام؛ وقد تتطلب بعض الأنظمة أيضًا تمكين [البدء التلقائي].',
			'meta.hideAfterLaunch' => 'إخفاء النافذة بعد بدء التشغيل',
			'meta.autoSetSystemProxy' => 'وكيل نظام تعيين تلقائي عند الاتصال',
			'meta.bypassSystemProxy' => 'أسماء النطاقات المسموح لها بتجاوز وكيل النظام',
			'meta.excludeFromRecent' => 'إخفاء من المهام الأخيرة',
			'meta.wakeLock' => 'قفل الاستيقاظ',
			'meta.hideDockIcon' => 'إخفاء أيقونة Dock',
			'meta.showTrayTraffic' => 'إظهار معلومات حركة المرور في شريط النظام',
			'meta.website' => 'موقع إلكتروني',
			'meta.rule' => 'قاعدة',
			'meta.global' => 'عالمي',
			'meta.direct' => 'مباشر',
			'meta.qrcode' => 'رمز الاستجابة السريعة',
			'meta.qrcodeTooLong' => 'النص طويل جدًا لعرضه',
			'meta.qrcodeShare' => 'شارك رمز الاستجابة السريعة',
			'meta.qrcodeScan' => 'مسح رمز الاستجابة السريعة',
			'meta.qrcodeScanResult' => 'نتيجة المسح',
			'meta.backupAndSync' => 'النسخ الاحتياطي والمزامنة',
			'meta.export' => 'يصدّر',
			'meta.send' => 'يرسل',
			'meta.sendConfirm' => 'تأكيد الإرسال؟',
			'meta.log' => 'سجل',
			'meta.coreLog' => 'سجل النواة',
			'meta.appLog' => 'سجل التطبيق',
			'meta.core' => 'جوهر',
			'meta.help' => 'يساعد',
			'meta.tutorial' => 'درس تعليمي',
			'meta.board' => 'لوحة',
			'meta.boardOnline' => 'استخدام اللوحة عبر الإنترنت',
			'meta.boardOnlineUrl' => 'عنوان URL للوحة عبر الإنترنت',
			'meta.boardLocalPort' => 'منفذ اللوحة المحلية',
			'meta.alwayOnVPN' => 'اتصال مفتوح دائمًا',
			'meta.disableFontScaler' => 'تعطيل تحجيم الخط(يسري مفعوله بعد إعادة التشغيل)',
			'meta.autoOrientation' => 'Rotate with the screen',
			'meta.restartTakesEffect' => 'Restart takes effect',
			'meta.reconnectTakesEffect' => 'سيتم تطبيقه بعد إعادة الاتصال.',
			'meta.runtimeProfile' => 'تكوين وقت التشغيل',
			'meta.willCompleteAfterRebootInstall' => 'يرجى إعادة تشغيل جهازك لإكمال تثبيت توسيع النظام',
			'meta.requestNeedsUserApproval' => '١. يُرجى السماح لـ Mclash بتثبيت ملحقات النظام من [إعدادات النظام] - [الخصوصية والأمان]. ٢. : [إعدادات النظام] - [عام] - [عناصر تسجيل الدخول والملحقات - ملحقات الشبكة] فعّل [mclashServiceSE]. أعد الاتصال بعد الانتهاء.',
			'meta.FullDiskAccessPermissionRequired' => 'يرجى تمكين إذن mclashServiceSE في [إعدادات النظام]-[الخصوصية والأمان]-[الوصول الكامل للقرص] وإعادة الاتصال.',
			'meta.proxy' => 'التمثيل',
			'meta.theme' => 'سمة',
			'meta.tvMode' => 'وضع التلفزيون',
			'meta.autoUpdate' => 'التحديثات التلقائية',
			'meta.updateChannel' => 'تحديث القنوات تلقائيا',
			'meta.hasNewVersion' => ({required Object p}) => 'تحديث الإصدار ${p}',
			'meta.autoDownloadPkg' => 'تنزيل حزم التحديث تلقائيًا',
			'meta.devOptions' => 'خيارات للمطور',
			'meta.about' => 'عن',
			'meta.name' => 'اسم',
			'meta.version' => 'إصدار',
			'meta.sort' => 'إعادة ترتيب',
			'meta.share' => 'يشارك',
			'meta.importFromClipboard' => 'استيراد من الحافظة',
			'meta.exportToClipboard' => 'تصدير إلى الحافظة',
			'meta.server' => 'الخادم',
			'meta.port' => 'ميناء',
			'meta.donate' => 'يتبرع',
			'meta.setting' => 'إعدادات',
			'meta.settingCore' => 'الإعدادات الأساسية',
			'meta.settingApp' => 'إعدادات التطبيق',
			'meta.coreOverwrite' => 'تجاوز النواة',
			'meta.iCloud' => 'iCloud',
			'meta.webdav' => 'Webdav',
			'meta.lanSync' => 'LAN SYNC',
			'meta.lanSyncNotQuitTips' => 'لا تخرج من هذه الواجهة قبل اكتمال التزامن',
			'meta.deviceNoSpace' => 'مساحة غير كافيه في القرص',
			'meta.hideSystemApp' => 'إخفاء تطبيقات النظام',
			'meta.hideAppIcon' => 'إخفاء أيقونة التطبيق',
			'meta.openDir' => 'فتح دليل الملف',
			'meta.type' => 'النوع',
			'meta.fileNotExist' => ({required Object p}) => 'الملف غير موجود: ${p}',
			'meta.buyProfile' => 'شراء ملف تعريف',
			'meta.myProfiles' => 'مظهر',
			'meta.profileEdit' => 'تحرير الملف الشخصي',
			'meta.profileNeedActive' => 'يرجى أولاً تعيين هذا الملف كملف التعريف الحالي، ثم بدء الاتصال/إعادة الاتصال',
			'meta.profileUrlOrContent' => ({required Object p}) => 'رابط إعداد ${p}',
			'meta.tabHome' => 'الرئيسية',
			'meta.tabNodes' => 'العُقد',
			'meta.tabPlans' => 'الخطط',
			'meta.tabMe' => 'حسابي',
			'permission.camera' => 'الكاميرا',
			'permission.screen' => 'تسجيل الشاشة',
			'permission.appQuery' => 'الحصول على قائمة التطبيقات',
			'permission.request' => ({required Object p}) => 'تمكين أذونات [${p}]',
			'permission.requestNeed' => ({required Object p}) => 'الرجاء تفعيل إذن [${p}]',
			'tls.certificate' => 'شهادة',
			'tls.privateKey' => 'المفتاح الخاص',
			'tls.customTrustCert' => 'شهادات مخصصة',
			'tun.stack' => 'مكدس الشبكة',
			'tun.inet4Address' => 'نطاق عناوين IPv4',
			'tun.dnsHijack' => 'اختطاف DNS',
			'tun.strictRoute' => 'التوجيه الصارم',
			'tun.tunDefaultRoute' => 'المسار الافتراضي',
			'tun.icmpForward' => 'توجيه رسائل ICMP',
			'tun.allowBypass' => 'السماح للتطبيقات بتجاوز VPN',
			'tun.appendHttpProxy' => 'إلحاق وكيل HTTP إلى VPN',
			'tun.bypassHttpProxyDomain' => 'المجالات المسموح لها بتجاوز وكيل HTTP',
			'dns.listen' => 'كلمة الاستماع',
			'dns.fakeIp' => 'fake-ip',
			'dns.fallback' => 'Fallback',
			'dns.preferH3' => 'أولوية DoH H3',
			'dns.useHosts' => 'استخدام المضيفين',
			'dns.useSystemHosts' => 'استخدام مضيفات النظام',
			'dns.enhancedMode' => 'الوضع المحسّن',
			'dns.fakeIPFilterMode' => 'وضع التصفية ${_root.dns.fakeIp}',
			'dns.fakeIPFilter' => '${_root.dns.fakeIp} التصفية',
			'dns.respectRules' => 'اتبع القواعد',
			'dns.nameServer' => 'خادم DNS',
			'dns.defaultNameServer' => '${_root.meta.byDefault} ${_root.dns.nameServer}',
			'dns.proxyNameServer' => '${_root.meta.proxy} ${_root.dns.nameServer}',
			'dns.directNameServer' => '${_root.meta.direct} ${_root.dns.nameServer}',
			'dns.fallbackNameServer' => '${_root.dns.fallback} ${_root.dns.nameServer}',
			'dns.fallbackGeoIp' => '${_root.dns.fallback} GeoIp',
			'dns.fallbackGeoIpCode' => '${_root.dns.fallback} GeoIpCode',
			'sniffer.overrideDest' => 'غطاء',
			'profilePatchMode.currentSelected' => 'المحدد الحالي',
			'profilePatchMode.overwrite' => 'التجاوز المدمج',
			'profilePatchMode.noOverwrite' => 'مُدمج - غير قابل للكتابة فوقه',
			'sendOrReceiveNotMatch' => ({required Object p}) => 'الرجاء استخدام [${p}]',
			'targetConnectFailed' => ({required Object p}) => 'فشل الاتصال بـ [${p}]، يرجى التأكد من وجود الجهاز في نفس الشبكة المحلية (LAN)',
			'edgeRuntimeNotInstalled' => 'لم يتم تثبيت وقت تشغيل Edge WebView2 على الجهاز الحالي ولا يمكن عرض الصفحة، يرجى تنزيل وتثبيت وقت تشغيل Edge WebView2 (x64)، وإعادة تشغيل التطبيق والمحاولة مرة أخرى.',
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
