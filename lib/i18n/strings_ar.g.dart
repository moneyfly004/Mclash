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
		'HK': 'هونغ كونغ',
		'TW': 'تايوان',
		'MO': 'ماكاو',
		'CN': 'الصين',
		'JP': 'اليابان',
		'KR': 'كوريا الجنوبية',
		'SG': 'سنغافورة',
		'MY': 'ماليزيا',
		'TH': 'تايلاند',
		'VN': 'فيتنام',
		'PH': 'الفلبين',
		'ID': 'إندونيسيا',
		'KH': 'كمبوديا',
		'US': 'الولايات المتحدة',
		'CA': 'كندا',
		'MX': 'المكسيك',
		'GB': 'المملكة المتحدة',
		'DE': 'ألمانيا',
		'FR': 'فرنسا',
		'NL': 'هولندا',
		'RU': 'روسيا',
		'IT': 'إيطاليا',
		'ES': 'إسبانيا',
		'CH': 'سويسرا',
		'SE': 'السويد',
		'NO': 'النرويج',
		'FI': 'فنلندا',
		'DK': 'الدنمارك',
		'PL': 'بولندا',
		'AT': 'النمسا',
		'IE': 'أيرلندا',
		'UA': 'أوكرانيا',
		'TR': 'تركيا',
		'PT': 'البرتغال',
		'CZ': 'التشيك',
		'RO': 'رومانيا',
		'BE': 'بلجيكا',
		'GR': 'اليونان',
		'HU': 'هنغاريا',
		'IL': 'إسرائيل',
		'AE': 'الإمارات',
		'SA': 'السعودية',
		'EG': 'مصر',
		'ZA': 'جنوب أفريقيا',
		'NG': 'نيجيريا',
		'AU': 'أستراليا',
		'NZ': 'نيوزيلندا',
		'BR': 'البرازيل',
		'AR': 'الأرجنتين',
		'CL': 'تشيلي',
		'CO': 'كولومبيا',
		'IN': 'الهند',
		'PK': 'باكستان',
		'XX': 'أخرى',
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
	@override late final _Translations$ordersScreen$ar ordersScreen = _Translations$ordersScreen$ar._(_root);
	@override late final _Translations$payment$ar payment = _Translations$payment$ar._(_root);
	@override late final _Translations$planScreen$ar planScreen = _Translations$planScreen$ar._(_root);
	@override late final _Translations$authScreen$ar authScreen = _Translations$authScreen$ar._(_root);
	@override late final _Translations$updatePrompt$ar updatePrompt = _Translations$updatePrompt$ar._(_root);
	@override late final _Translations$clearData$ar clearData = _Translations$clearData$ar._(_root);
	@override late final _Translations$apiError$ar apiError = _Translations$apiError$ar._(_root);
	@override late final _Translations$subNotice$ar subNotice = _Translations$subNotice$ar._(_root);
	@override late final _Translations$settingItems$ar settingItems = _Translations$settingItems$ar._(_root);
	@override late final _Translations$tunScreen$ar tunScreen = _Translations$tunScreen$ar._(_root);
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
	@override String get enable => 'تشغيل';
	@override String get disable => 'تعطيل';
	@override String get open => 'فتح';
	@override String get close => 'إغلاق';
	@override String get quit => 'خروج';
	@override String get add => 'إضافة';
	@override String get remove => 'إزالة';
	@override String get removeConfirm => 'هل انت متأكد من الحذف؟';
	@override String get edit => 'تحرير';
	@override String get view => 'عرض';
	@override String get remark => 'ملاحظة';
	@override String get byDefault => 'افتراضي';
	@override String get more => 'أكثر';
	@override String get tips => 'معلومات';
	@override String get selectAll => 'تحديد الكل';
	@override String get copy => 'نسخ';
	@override String get paste => 'لصق';
	@override String get cut => 'قص';
	@override String get save => 'حفظ';
	@override String get ok => 'موافق';
	@override String get cancel => 'إلغاء';
	@override String get faq => 'الأسئلة الشائعة';
	@override String get doc => 'وثيقة';
	@override String get htmlTools => 'مجموعة أدوات HTML';
	@override String get download => 'تحميل';
	@override String get loading => 'تحميل...';
	@override String get days => 'أيام';
	@override String get hours => 'ساعات';
	@override String get minutes => 'دقائق';
	@override String get seconds => 'ثانية';
	@override String get milliseconds => 'ميلي ثانية';
	@override String get search => 'بحث';
	@override String get searchNodeHint => 'تصفية العُقد (الاسم أو البروتوكول)';
	@override String get connect => 'اتصال';
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
	@override String get apply => 'تطبيق';
	@override String get refresh => 'تحديث';
	@override String get update => 'تحديث';
	@override String get updateInterval => 'الفاصل الزمني للتحديث';
	@override String get updateInterval5mTips => 'الحد الأدنى: 5 دقائق';
	@override String get updateIntervalPreferByProfile => 'إعطاء الأولوية لإعدادات المزود';
	@override String updateFailed({required Object p}) => 'فشل التحديث:${p}';
	@override String get none => 'لا شيء';
	@override String get reset => 'إعادة ضبط';
	@override String get authentication => 'المصادقة';
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
	@override String get externalController => 'التحكم الخارجي';
	@override String get secret => 'السر';
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
	@override String get autoConnectAfterLaunch => 'الاتصال التلقائي بعد التشغيل';
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
	@override String get export => 'تصدير';
	@override String get send => 'إرسال';
	@override String get sendConfirm => 'تأكيد الإرسال؟';
	@override String get log => 'سجل';
	@override String get coreLog => 'سجل النواة';
	@override String get appLog => 'سجل التطبيق';
	@override String get core => 'النواة';
	@override String get help => 'مساعدة';
	@override String get tutorial => 'درس تعليمي';
	@override String get board => 'لوحة';
	@override String get boardOnline => 'استخدام اللوحة عبر الإنترنت';
	@override String get boardOnlineUrl => 'عنوان URL للوحة عبر الإنترنت';
	@override String get boardLocalPort => 'منفذ اللوحة المحلية';
	@override String get alwayOnVPN => 'اتصال مفتوح دائمًا';
	@override String get disableFontScaler => 'تعطيل تحجيم الخط(يسري مفعوله بعد إعادة التشغيل)';
	@override String get autoOrientation => 'التدوير مع الشاشة';
	@override String get restartTakesEffect => 'يسري بعد إعادة التشغيل';
	@override String get reconnectTakesEffect => 'سيتم تطبيقه بعد إعادة الاتصال.';
	@override String get runtimeProfile => 'تكوين وقت التشغيل';
	@override String get willCompleteAfterRebootInstall => 'يرجى إعادة تشغيل جهازك لإكمال تثبيت توسيع النظام';
	@override String get requestNeedsUserApproval => '١. يُرجى السماح لـ Mclash بتثبيت ملحقات النظام من [إعدادات النظام] - [الخصوصية والأمان]. ٢. : [إعدادات النظام] - [عام] - [عناصر تسجيل الدخول والملحقات - ملحقات الشبكة] فعّل [mclashServiceSE]. أعد الاتصال بعد الانتهاء.';
	@override String get FullDiskAccessPermissionRequired => 'يرجى تمكين إذن mclashServiceSE في [إعدادات النظام]-[الخصوصية والأمان]-[الوصول الكامل للقرص] وإعادة الاتصال.';
	@override String get proxy => 'الوكيل';
	@override String get theme => 'سمة';
	@override String get tvMode => 'وضع التلفزيون';
	@override String get autoUpdate => 'التحديثات التلقائية';
	@override String get updateChannel => 'تحديث القنوات تلقائيا';
	@override String hasNewVersion({required Object p}) => 'تحديث الإصدار ${p}';
	@override String get autoDownloadPkg => 'تنزيل حزم التحديث تلقائيًا';
	@override String get devOptions => 'خيارات للمطور';
	@override String get about => 'حول';
	@override String get name => 'اسم';
	@override String get version => 'إصدار';
	@override String get sort => 'إعادة ترتيب';
	@override String get share => 'مشاركة';
	@override String get importFromClipboard => 'استيراد من الحافظة';
	@override String get exportToClipboard => 'تصدير إلى الحافظة';
	@override String get server => 'الخادم';
	@override String get port => 'المنفذ';
	@override String get donate => 'تبرع';
	@override String get setting => 'إعدادات';
	@override String get settingCore => 'إعدادات النواة';
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
	@override String get myProfiles => 'ملفات التعريف';
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
	@override String get listen => 'عنوان الاستماع';
	@override String get fakeIp => 'fake-ip';
	@override String get fallback => 'احتياطي';
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
	@override String get overrideDest => 'تجاوز الوجهة';
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
	@override String get accountBalance => 'الرصيد';
	@override String get expireAt => 'ينتهي';
	@override String get remainingDays => 'الأيام المتبقية';
	@override String get deviceCount => 'الأجهزة';
	@override String get myOrders => 'طلباتي';
	@override String get deviceManagement => 'إدارة الأجهزة';
	@override String get changePassword => 'تغيير كلمة المرور';
	@override String get clearLocalData => 'مسح البيانات المحلية (قبل إلغاء التثبيت)';
	@override String get profileManagementDev => 'إدارة الملفات الشخصية (للمطور)';
	@override String get tunAdapter => 'محول TUN الافتراضي';
	@override String get checkUpdate => 'التحقق من التحديثات';
	@override String get retry => 'إعادة المحاولة';
	@override String get loadFailed => 'فشل تحميل معلومات الحساب: ربما انتهت صلاحية تسجيل الدخول أو أن الشبكة غير متاحة.\nانقر «تحديث» في أعلى الصفحة لإعادة المحاولة؛ وإن استمر الفشل فسجّل الدخول مجددًا.';
	@override String get logoutConfirm => 'تسجيل الخروج؟';
	@override String get boardNoKernel => 'تعرض اللوحة بيانات النواة الحية (الاتصال، حركة المرور، تطابق القواعد).\n\nالنواة لا تعمل، لذا ستكون اللوحة بلا محتوى.\nانقر «موافق» لفتحها على أي حال، أو «إلغاء» للاتصال من تبويب الرئيسية أولًا.';
	@override String get boardOpened => 'تم فتح اللوحة في متصفحك؛ بدّل العُقد أو القواعد هناك وسيتبع التطبيق خلال ~5 ثوانٍ.';
}

// Path: homeScreen
class _Translations$homeScreen$ar implements Translations$homeScreen$en {
	_Translations$homeScreen$ar._(this._root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String expiresOn({required Object date}) => 'ينتهي ${date}';
	@override String devicesText({required Object text}) => 'الأجهزة ${text}';
	@override String get upgrade => 'ترقية';
	@override String get quickCountries => 'تصفية سريعة حسب الدولة';
	@override String nodeCount({required Object count}) => '${count} عقدة';
	@override String get autoBestTip => 'اختيار أسرع عقدة متاحة في كل الدول (الوضع التلقائي)';
	@override String get autoBest => 'الأفضل تلقائيًا';
	@override String pickCountryTip({required Object label}) => 'اختيار أسرع عقدة متاحة في «${label}» وتثبيتها';
	@override String get autoNoBetter => 'الوضع التلقائي مفعّل بالفعل (لم تُوجد عقدة أفضل)';
	@override String switchedBest({required Object name}) => 'تم التبديل إلى أفضل عقدة: ${name}';
	@override String switchedCountry({required Object country, required Object node, required Object ms}) => 'تم التبديل إلى أسرع عقدة في ${country}: ${node}${ms}';
	@override String filterCountryFailed({required Object country, required Object err}) => 'تمت التصفية حسب ${country}؛ وفشل التبديل: ${err}';
	@override String deviceFullCount({required Object used, required Object limit}) => 'الأجهزة الحالية ${used}/${limit}\n\n';
	@override String get deviceFullUpgradeHint => 'ترقية حد الأجهزة تعيد الاتصال فورًا (مُوصى بها)؛ ويمكنك أيضًا حذف الأجهزة غير المستخدمة لتحرير مكان.';
	@override String get later => 'لاحقًا';
	@override String get upgradeDeviceCount => 'ترقية حد الأجهزة';
	@override String get cannotConnect => 'تعذّر الاتصال';
	@override String get freshnessNever => 'لم تتم المزامنة بعد · انقر للتحديث';
	@override String get freshnessJustNow => 'تم التحديث للتو · انقر لإدارة الأجهزة';
	@override String freshnessMinutes({required Object minutes}) => 'قبل ${minutes} دقيقة · انقر لإدارة الأجهزة';
	@override String freshnessStale({required Object minutes}) => 'قبل ${minutes} دقيقة · انقر للتحديث';
	@override String get subscriptionAutoSync => 'مزامنة الاشتراك تلقائيًا';
	@override String get connecting => 'جارٍ الاتصال…';
	@override String get disconnecting => 'جارٍ قطع الاتصال…';
	@override String get tapToDisconnect => 'انقر المفتاح لقطع الاتصال';
	@override String get tapToConnect => 'انقر المفتاح للاتصال';
	@override String get currentNode => 'العقدة الحالية';
	@override String get noNodeSelected => 'لم تُحدَّد أي عقدة';
	@override String get switchAction => 'تبديل';
	@override String get realtimeSpeed => 'السرعة الفورية';
	@override String get totalTraffic => 'إجمالي حركة المرور';
	@override String get subSyncedNotReady => 'تم تنزيل الاشتراك، لكن الملف غير جاهز بعد. حاول مجددًا بعد قليل.';
	@override String get noPlan => 'لا توجد خطة متاحة لهذا الحساب بعد. يرجى شراء خطة أولًا.';
	@override String get loginExpired => 'انتهت صلاحية تسجيل الدخول. يرجى تسجيل الدخول مجددًا.';
	@override String get syncingWait => 'جارٍ مزامنة الاشتراك، يرجى الانتظار.';
	@override String syncFailedNetwork({required Object message}) => 'فشلت مزامنة الاشتراك: ${message}\nتحقق من شبكتك وحاول مجددًا.';
	@override String get syncFailed => 'فشلت مزامنة الاشتراك، حاول مجددًا لاحقًا.';
	@override String get resetProxy => 'إعادة تعيين';
	@override String latencySuffix({required Object ms}) => ' (${ms}ms)';
}

// Path: nodesScreen
class _Translations$nodesScreen$ar implements Translations$nodesScreen$en {
	_Translations$nodesScreen$ar._(this._root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String updatedCount({required Object count}) => 'تم تحديث الاشتراك: ${count} عقدة';
	@override String updateFailed({required Object message}) => 'فشل التحديث: ${message}';
	@override String get updateFailedNetwork => 'فشل التحديث، يرجى التحقق من شبكتك';
	@override String testDone({required Object ok, required Object fail}) => 'اكتمل اختبار السرعة: ${ok} قابلة للوصول، ${fail} غير قابلة (قد تكون غير متصلة)';
	@override String switchedTo({required Object name}) => 'تم التبديل إلى ${name}';
	@override String switchFailed({required Object message}) => 'فشل التبديل: ${message}\n(يحتاج تبديل العُقد إلى نواة تعمل؛ شغّل المفتاح من تبويب الرئيسية أولًا.)';
	@override String selectedAfterConnect({required Object name}) => 'تم اختيار ${name} (يسري بعد الاتصال)';
	@override String get title => 'العُقد';
	@override String get searchNode => 'البحث في العُقد';
	@override String get sortByLatency => 'الترتيب حسب زمن الاستجابة';
	@override String get updateSubscription => 'تحديث الاشتراك';
	@override String get viewByGroup => 'العرض حسب مجموعة الوكلاء';
	@override String get testAll => 'اختبار الكل';
	@override String get searchHint => 'ابحث عن عقدة / دولة / بروتوكول';
	@override String get emptyNoNodes => 'لا توجد عُقد متاحة بعد.\nتتم مزامنة الاشتراكات تلقائيًا؛ وإن كنت قد سجّلت الدخول للتو فانتظر قليلًا أو انقر «إعادة التحميل» أدناه.';
	@override String get emptyNoMatch => 'لا توجد عُقد مطابقة.';
	@override String get reload => 'إعادة التحميل';
	@override String get currentInUse => 'الحالية (قيد الاستخدام)';
	@override String get current => 'الحالية';
	@override String get notTested => 'لم يُقس (بانتظار إعادة تحميل النواة)';
	@override String get timeout => 'انتهت المهلة';
	@override String get clear => 'مسح';
	@override String get selectNode => 'اختيار عقدة';
	@override String get emptyNoKernel => 'لا توجد عُقد متاحة بعد.\nيرجى تشغيل مفتاح الاتصال من تبويب الرئيسية أولًا.';
	@override String get openFullList => 'فتح قائمة العُقد الكاملة (بحث / اختبار سرعة / مجموعات)';
}

// Path: nodeAuto
class _Translations$nodeAuto$ar implements Translations$nodeAuto$en {
	_Translations$nodeAuto$ar._(this._root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get kernelStateUnavailable => 'حالة العُقدة غير متاحة مؤقتًا من النواة؛ وستُعاد المحاولة تلقائيًا.';
	@override String backToFixedNode({required Object fixed}) => 'العودة إلى العقدة المثبَّتة: ${fixed}';
	@override String get noUsableNodePickOne => 'لم تُوجد عقدة قابلة للاستخدام. يرجى اختيار واحدة يدويًا من قائمة العُقد.';
	@override String get noUsableNodeTryOne => 'لم تُوجد عقدة قابلة للاستخدام. جرّب اختيار واحدة من قائمة العُقد.';
	@override String autoConnectedBest({required Object bestNode, required Object bestMs}) => 'تم الاتصال تلقائيًا بأفضل عقدة: ${bestNode} (${bestMs} ms)';
	@override String get currentNodeUnreachable => 'العقدة الحالية لا تصل إلى الإنترنت؛ جارٍ التبديل تلقائيًا…';
	@override String autoSwitchedToUsable({required Object target}) => 'تم التبديل تلقائيًا إلى عقدة صالحة: ${target}';
	@override String newNodesReloading({required Object missing}) => '${missing} عقدة جديدة في الاشتراك لم تُحمَّل في النواة بعد؛ جارٍ إعادة التحميل…';
	@override String get kernelReloadedRetest => 'أُعيد تحميل النواة بالاشتراك الجديد؛ شغّل اختبار السرعة مجددًا.';
}

// Path: accountBlock
class _Translations$accountBlock$ar implements Translations$accountBlock$en {
	_Translations$accountBlock$ar._(this._root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String quotaFull({required Object used, required Object limit}) => 'أماكن الأجهزة ممتلئة (${used}/${limit}): هذا الجهاز ما زال ضمن النطاق المرخّص ويمكنه الاتصال بشكل طبيعي. لإضافة جهاز آخر، ارقِ حد الأجهزة أو احذف الأجهزة غير المستخدمة.';
	@override String get banFallback => 'تم تعطيل حسابك ولم يعد صالحًا للاستخدام.';
	@override String get titleExpired => 'انتهت الخطة';
	@override String get titleDeviceFull => 'بلغت حد الأجهزة';
	@override String get titleAccountDisabled => 'الحساب معطّل';
	@override String get titlePlanDisabled => 'الخطة معطّلة';
	@override String get titleNoPlan => 'لا توجد خطة بعد';
	@override String get titleDeviceRemoved => 'تمت إزالة هذا الجهاز';
	@override String get titleServiceUnavailable => 'الخدمة غير متاحة مؤقتًا';
	@override String get textExpired => 'انتهت خطتك. اشترِ خطة لمتابعة استخدام العُقد العالمية.';
	@override String textDeviceFull({required Object used, required Object limit}) => 'وجد الخادم أن هذا الجهاز يتجاوز حد أجهزة الخطة (${used}/${limit})، لذا لا يمكنه الاتصال حاليًا. احذف الأجهزة غير المستخدمة من «حسابي ← إدارة الأجهزة»، أو ارتقِ إلى خطة بأجهزة أكثر.';
	@override String get textAccountDisabled => 'تم تعطيل حسابك. يرجى التواصل مع الدعم إن كان لديك أي استفسار.';
	@override String get textPlanDisabled => 'تم تعطيل خطتك أو أنها في حالة غير طبيعية، لذا لا يمكنك الاتصال. يرجى التواصل مع الدعم إن كان لديك استفسار.';
	@override String get textNoPlan => 'لم تشترِ خطة بعد. اشترِ واحدة لاستخدام العُقد العالمية.';
	@override String get textDeviceRemoved => 'تمت إزالة هذا الجهاز وتسجيل خروجه. يرجى تسجيل الدخول مجددًا.';
	@override String get textServiceUnavailable => 'الخدمة غير متاحة مؤقتًا. حاول لاحقًا؛ وإن استمر الأمر، التقط صورة للشاشة وتواصل مع الدعم.';
	@override String remainingDays({required Object days}) => 'بقي ${days} يومًا';
	@override String deviceUsage({required Object used, required Object limit}) => 'الأجهزة ${used}/${limit}';
}

// Path: entitlementMsg
class _Translations$entitlementMsg$ar implements Translations$entitlementMsg$en {
	_Translations$entitlementMsg$ar._(this._root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get tamperedTitle => 'حالة الترخيص غير طبيعية';
	@override String get tamperedClock => 'تم رصد تراجع في ساعة النظام (أو تلاعب ببيانات الترخيص المحلية). يرجى الاتصال بالشبكة لإتمام عملية تحقق قبل الاتصال.';
	@override String get tamperedLocal => 'بيانات الترخيص المحلية تالفة أو عُدِّلت. يرجى الاتصال بالشبكة لإتمام عملية تحقق قبل الاتصال.';
	@override String get needVerifyTitle => 'يلزم التحقق عبر الإنترنت';
	@override String get needVerifyFirst => 'تعذّر تأكيد حالة خطتك: يرجى الاتصال بالشبكة وتسجيل الدخول، ثم إتمام عملية تحقق واحدة قبل الاتصال.';
	@override String get needVerifyRetry => 'تعذّر تأكيد حالة خطتك. يرجى الاتصال بالشبكة والمحاولة مجددًا.';
	@override String get verifyFailedTitle => 'تعذّر التحقق من حالة الخطة';
	@override String get verifyFailedText => 'انتهت فترة السماح للتحقق والخادم غير متاح. تحقق من شبكتك وحاول مجددًا (وإن كنت قد جدّدت للتو، فسجّل الدخول مجددًا).';
	@override String get restrictedTitle => 'الحساب مقيَّد';
	@override String get restrictedFallback => 'تم تعطيل حسابك أو خطتك، لذا لا يمكنك الاتصال.';
	@override String get expiredTitle => 'انتهت الخطة';
	@override String expiredText({required Object date}) => 'انتهت خطتك في ${date}. وتم مسح ملف الاشتراك المحلي. جدّد وسجّل الدخول مجددًا لاستعادته.';
}

// Path: devicesScreen
class _Translations$devicesScreen$ar implements Translations$devicesScreen$en {
	_Translations$devicesScreen$ar._(this._root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get title => 'إدارة الأجهزة';
	@override String get currentPlan => 'الخطة الحالية';
	@override String devicesText({required Object text}) => 'الأجهزة ${text}';
	@override String get upgradeTitle => 'ترقية الأجهزة / تمديد المدة';
	@override String get upgradeSubtitle => 'أضف أجهزة وأيامًا معًا؛ سعر واحد ودفعة واحدة';
	@override String get addDevices => 'إضافة أجهزة';
	@override String get noAddDevices => 'بلا تغيير';
	@override String addDevicesCount({required Object n}) => '+${n} جهاز';
	@override String get addDays => 'إضافة أيام';
	@override String get noExtend => 'بلا تمديد';
	@override String addDaysCount({required Object n, required Object months}) => '+${n} يوم (${months} شهرًا)';
	@override String get priceFailed => 'فشل الحصول على السعر';
	@override String amountDue({required Object amount}) => 'الإجمالي ¥${amount}';
	@override String get requote => 'إعادة الاحتساب';
	@override String get goPay => 'ادفع الآن';
	@override String get afterUpgrade => 'بعد الترقية: ';
	@override String afterLimit({required Object limit}) => 'حد الأجهزة ${limit}';
	@override String afterExpire({required Object date}) => 'ينتهي ${date}';
	@override String get pickSomething => 'يرجى إضافة أجهزة أو أيام على الأقل';
	@override String get daysOnlyUnsupported => 'لا تدعم اللوحة «تمديد المدة فقط» بعد: يرجى ضبط «إضافة أجهزة» على 1 أو أكثر والمحاولة مجددًا (أو تواصل مع الدعم لتفعيلها).';
	@override String get paramsRejected => 'تم رفض المعاملات: يرجى اختيار عدد الأجهزة والأيام مجددًا.';
	@override String get subscriptionExpired => 'انتهى الاشتراك، لذا لا يمكن ترقيته. يرجى التجديد أو شراء خطة أولًا.';
	@override String get orderIncomplete => 'معلومات الطلب غير مكتملة. انقر «إعادة الاحتساب» وحاول مجددًا.';
	@override String get orderRegenerated => 'انتهت صلاحية الطلب السابق؛ وأُنشئ طلب جديد بالإعدادات نفسها.';
	@override String get payChannelIncomplete => 'معلومات الطلب أو قناة الدفع غير مكتملة. يرجى إعادة الاحتساب والمحاولة مجددًا.';
	@override String get noQrCode => 'لم يُرجع الخادم رمز QR أو رابط دفع. اختر طريقة دفع أخرى أو حاول لاحقًا.';
	@override String payStartFailed({required Object err}) => 'فشل بدء الدفع: ${err}';
	@override String get payCancelled => 'أُلغي الدفع؛ وتم حذف الطلب المبدئي.';
	@override String get balancePay => 'الرصيد';
	@override String get noPayMethod => 'لا تتوفر طريقة دفع حاليًا. حاول لاحقًا أو تواصل مع الدعم.';
	@override String balanceInsufficient({required Object balance, required Object amount}) => 'الرصيد غير كافٍ (¥${balance}، والمطلوب ¥${amount}).\nهل تريد الشحن أولًا؟';
	@override String get choosePayMethod => 'اختر طريقة الدفع';
	@override String balanceText({required Object balance}) => 'الرصيد ¥${balance}';
	@override String balanceShort({required Object balance}) => 'الرصيد ¥${balance} (غير كافٍ، يرجى الشحن)';
	@override String get unknownDevice => 'جهاز غير معروف';
	@override String get online => '● متصل';
	@override String get offline => '○ غير متصل';
	@override String lastActive({required Object text}) => 'آخر نشاط ${text}';
	@override String get delete => 'حذف';
	@override String deleteConfirm({required Object name}) => 'حذف الجهاز «${name}»؟ سيُفصل عن الشبكة فورًا.';
	@override String get lastActiveJustNow => 'الآن';
	@override String lastActiveMinutes({required Object minutes}) => 'قبل ${minutes} دقيقة';
	@override String lastActiveToday({required Object time}) => 'اليوم ${time}';
}

// Path: sysProxySheet
class _Translations$sysProxySheet$ar implements Translations$sysProxySheet$en {
	_Translations$sysProxySheet$ar._(this._root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get reading => 'جارٍ القراءة…';
	@override String get unknown => 'غير معروف';
	@override String get kernelNotRunning => 'النواة لا تعمل (شغّل المفتاح من تبويب الرئيسية أولًا)';
	@override String applied({required Object host, required Object port}) => 'مُطبَّق · ${host}:${port}';
	@override String notSet({required Object reason}) => 'لم يُضبط وكيل النظام — ${reason}';
	@override String notEffective({required Object port}) => 'غير فعّال (لا يوجد وكيل نظام يشير إلى ${port})';
	@override String readFailed({required Object err}) => 'فشلت القراءة: ${err}';
	@override String get setRejected => 'فشل الضبط: ربما رفض النظام الكتابة (أو استبدلته برمجية وكيل أخرى)';
	@override String get disableFailed => 'فشل الإيقاف';
	@override String get portRange => 'يجب أن يكون المنفذ بين 1 و65535';
	@override String portChanged({required Object value}) => 'تم تغيير المنفذ إلى ${value}: اقطع الاتصال وأعد الاتصال مرة حتى تستمع النواة إلى المنفذ الجديد';
	@override String get title => 'وكيل النظام';
	@override String desc({required Object host}) => 'عنوان وكيل النظام ثابت على ${host} (الاسترجاع المحلي)، والمنفذ هو المنفذ الهجين للنواة.';
	@override String get descWindows => 'هذا هو نفسه ما تراه في إعدادات Windows ← الشبكة والإنترنت ← الوكيل.';
	@override String get reset => 'إعادة الضبط';
	@override String get disable => 'إيقاف وكيل النظام';
	@override String get diagnostics => 'تشخيص (هل تقرأ الواجهة القيم نفسها من السجل؟)';
	@override String get mixedPort => 'المنفذ الهجين';
	@override String get apply => 'تطبيق';
}

// Path: logScreen
class _Translations$logScreen$ar implements Translations$logScreen$en {
	_Translations$logScreen$ar._(this._root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String readAppFailed({required Object e}) => 'فشلت قراءة سجل التطبيق: ${e}';
	@override String readCoreFailed({required Object e}) => 'فشلت قراءة سجل النواة: ${e}';
	@override String get copied => 'تم النسخ (روابط الاشتراك وأسرار أخرى محجوبة؛ لكن ملف السجل نفسه قد يحتوي العنوان الخام)';
	@override String get copy => 'نسخ';
	@override String get refresh => 'تحديث';
	@override String get empty => 'لا يوجد محتوى';
}

// Path: trayShell
class _Translations$trayShell$ar implements Translations$trayShell$en {
	_Translations$trayShell$ar._(this._root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get closeTitle => 'إغلاق النافذة';
	@override String get closeBody => 'إغلاق النافذة يضع Mclash في شريط النظام فقط — فتستمر النواة ووكيل النظام في العمل وتبقى شبكتك متصلة.\n\n· موافق: التصغير إلى شريط النظام (للخروج نهائيًا، انقر بزر الفأرة الأيمن على أيقونة شريط النظام ← خروج)\n· إلغاء: إغلاق Mclash نهائيًا وإيقاف النواة واستعادة وكيل النظام\n\n(سيُحفظ اختيارك؛ وفي المرة القادمة يمكنك استخدام أيقونة شريط النظام مباشرة)';
}

// Path: ordersScreen
class _Translations$ordersScreen$ar implements Translations$ordersScreen$en {
	_Translations$ordersScreen$ar._(this._root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get title => 'طلباتي';
	@override String get orderInfoIncomplete => 'معلومات الطلب غير مكتملة. اسحب إلى الأسفل للتحديث ثم حاول مجددًا.';
	@override String get payChannelIncomplete => 'معلومات قناة الدفع غير مكتملة. حاول مجددًا لاحقًا.';
	@override String get noQrPayload => 'لم يُرجع الخادم رمز QR أو رابط دفع. اختر طريقة دفع أخرى أو حاول لاحقًا.';
	@override String payStartFailed({required Object err}) => 'فشل بدء الدفع: ${err}';
	@override String get noPayMethod => 'لا تتوفر طريقة دفع حاليًا. حاول مجددًا لاحقًا أو تواصل مع الدعم.';
	@override String get choosePayMethod => 'اختر طريقة الدفع';
	@override String amountDue({required Object amount}) => 'المبلغ المستحق ¥${amount}';
	@override String get paidLabel => '● مدفوع';
	@override String get pendingLabel => '○ غير مدفوع';
	@override String unknownStatus({required Object status}) => '✕ ${status}';
	@override String orderNoText({required Object orderNo}) => 'رقم الطلب ${orderNo}';
	@override String createdAtText({required Object createdAt}) => 'أُنشئ في ${createdAt}';
	@override String get orderCanceled => 'تم إلغاء الطلب';
	@override String cancelFailed({required Object err}) => 'فشل الإلغاء: ${err}\n(إذا كان الطلب مدفوعًا أو ملغى بالفعل، فاسحب إلى الأسفل للتحديث لرؤية أحدث حالة.)';
	@override String get cancelOrder => 'إلغاء الطلب';
	@override String get continuePay => 'متابعة الدفع';
}

// Path: payment
class _Translations$payment$ar implements Translations$payment$en {
	_Translations$payment$ar._(this._root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get balancePay => 'الدفع من الرصيد';
	@override String get qrPay => 'امسح للدفع';
	@override String get deductFromBalance => 'يُخصم من رصيد حسابك';
	@override String get openedInBrowser => 'تم فتح صفحة الدفع في متصفحك';
	@override String get scanWithAlipayWechat => 'امسح باستخدام Alipay أو WeChat';
	@override String orderNoText({required Object orderNo}) => 'رقم الطلب ${orderNo}';
	@override String payFailed({required Object err}) => 'فشل الدفع: ${err}';
	@override String get notDetected => 'لم يُرصد أي دفع. يمكنك المتابعة لاحقًا من «طلباتي».';
	@override String get charging => 'جارٍ التحصيل…';
	@override String get processing => 'جارٍ المعالجة…';
	@override String get waitingPay => 'في انتظار الدفع…';
	@override String get openPageFailed => 'تعذّر فتح صفحة الدفع. انقر الزر أدناه لإعادة المحاولة، أو امسح رمز QR بدلًا من ذلك.';
	@override String get reopenPayPage => 'إعادة فتح صفحة الدفع';
	@override String get payInBrowser => 'الدفع في المتصفح';
	@override String get openAlipay => 'فتح Alipay';
	@override String get cancelOrder => 'إلغاء الطلب';
	@override String get confirmPay => 'تأكيد الدفع';
	@override String get retry => 'إعادة المحاولة';
	@override String get paidAlready => 'لقد دفعت';
	@override String get channelAlipay => 'Alipay';
	@override String get channelCodepayAlipay => 'Code Pay · Alipay';
	@override String get channelCodepayWechat => 'Code Pay · WeChat';
	@override String get channelCodepay => 'Code Pay';
	@override String get channelWechat => 'WeChat Pay';
	@override String get channelUsdt => 'USDT';
	@override String get channelUsdtTrc20 => 'USDT · TRC20';
	@override String get payFallback => 'دفع';
	@override String get errCsrf => 'انتهت صلاحية بيانات تسجيل الدخول (فشل فحص CSRF).\nاسحب إلى الأسفل للتحديث في تبويب «حسابي» أو سجّل الدخول مجددًا، ثم أعد المحاولة.';
	@override String get errAlipayLimit => 'للدفع وجهًا لوجه عبر Alipay حد أقصى لكل عملية (1000 ¥ لهذا التاجر)، وطلبك يتجاوزه.\nيرجى استخدام «الدفع من الرصيد» أو «الدفع بالرمز» بدلًا منه، أو تواصل مع الدعم لرفع حد Alipay.';
	@override String get errNotSigned => 'لم يشترك تطبيق Alipay في منتج الدفع المطابق، لذا هذه القناة غير متاحة مؤقتًا.\nيرجى استخدام «الدفع من الرصيد» أو «الدفع بالرمز» بدلًا منه، أو تواصل مع الدعم لتفعيله.';
	@override String get errOrderGone => 'تم إلغاء هذا الطلب أو انتهت صلاحيته (الطلبات المبدئية صالحة 30 دقيقة).\nانقر «إعادة الاحتساب» لإنشاء طلب جديد ثم ادفع.';
	@override String errNetwork({required Object err}) => 'الشبكة غير متاحة: ${err}';
}

// Path: planScreen
class _Translations$planScreen$ar implements Translations$planScreen$en {
	_Translations$planScreen$ar._(this._root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get recommended => 'مُوصى به';
	@override String get devices => 'الأجهزة';
	@override String balanceLabel({required Object amount}) => 'الرصيد ¥${amount}';
	@override String get balanceInsufficient => ' (الرصيد غير كافٍ، يرجى الشحن أولًا)';
	@override String get total => 'الإجمالي';
	@override String get payNow => 'ادفع الآن';
	@override String get retry => 'إعادة المحاولة';
	@override String get errIncompleteOrder => 'معلومات الطلب أو قناة الدفع غير مكتملة؛ لا يمكن بدء الدفع.';
	@override String get payBalance => 'الدفع من الرصيد';
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
	@override String get payOnline => 'دفع إلكتروني';
}

// Path: authScreen
class _Translations$authScreen$ar implements Translations$authScreen$en {
	_Translations$authScreen$ar._(this._root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get saveAccountInfo => 'حفظ معلومات الحساب';
	@override String get autoLoginNextTime => 'تسجيل الدخول تلقائيًا في المرة القادمة';
	@override String get needLoginNextTime => 'ستحتاج إلى تسجيل الدخول مجددًا في المرة القادمة';
	@override String get invalidEmail => 'يرجى إدخال بريد إلكتروني صالح';
	@override String get enterEmailFirst => 'يرجى إدخال بريد إلكتروني صالح أولًا';
	@override String get passwordRequired => 'يرجى إدخال كلمة المرور';
	@override String get wrongCredentials => 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
	@override String get requestRejected => 'تم رفض الطلب. حاول مجددًا لاحقًا.';
	@override String get tooFrequent => 'محاولات كثيرة جدًا. حاول مجددًا لاحقًا.';
	@override String get loginFailed => 'فشل تسجيل الدخول';
	@override String get username => 'اسم المستخدم';
	@override String get confirmPassword => 'تأكيد كلمة المرور';
	@override String get inviteCode => 'رمز الدعوة';
	@override String get emailCode => 'رمز التحقق بالبريد';
	@override String get getCode => 'احصل على الرمز';
	@override String get registerAndLogin => 'التسجيل وتسجيل الدخول';
	@override String usernameMinLength({required Object min}) => 'يجب ألا يقل اسم المستخدم عن ${min} أحرف';
	@override String get passwordMismatch => 'كلمتا المرور غير متطابقتين';
	@override String get emailCodeRequired => 'يرجى إدخال رمز التحقق المرسل بالبريد';
	@override String get inviteCodeRequired => 'يتطلب التسجيل في هذا الموقع رمز دعوة';
	@override String get codeSentCheckEmail => 'تم إرسال رمز التحقق. يرجى التحقق من بريدك.';
	@override String get registerSuccess => 'تم التسجيل بنجاح، وأنت مسجّل الدخول الآن.';
	@override String passwordHint({required Object min}) => '${min} أحرف على الأقل، تشمل حروفًا وأرقامًا';
	@override String passwordTooShort({required Object min}) => 'يجب ألا تقل كلمة المرور عن ${min} أحرف';
	@override String get passwordNeedsLetterAndDigit => 'يجب أن تحتوي كلمة المرور على حروف وأرقام معًا';
	@override String get registeredEmail => 'البريد الإلكتروني المسجَّل';
	@override String get newPassword => 'كلمة المرور الجديدة';
	@override String get confirmNewPassword => 'تأكيد كلمة المرور الجديدة';
	@override String get resetPassword => 'إعادة تعيين كلمة المرور';
	@override String get resetCodeSent => 'إذا كان هذا البريد مسجّلًا، فقد أُرسل رمز إعادة التعيين (صالح 15 دقيقة).';
	@override String get resetSuccess => 'تمت إعادة تعيين كلمة المرور. يرجى تسجيل الدخول بكلمتك الجديدة.';
	@override String get changePasswordTitle => 'تغيير كلمة المرور';
	@override String get currentPassword => 'كلمة المرور الحالية';
	@override String get saveNewPassword => 'حفظ كلمة المرور الجديدة';
	@override String get newPasswordMismatch => 'كلمتا المرور الجديدتان غير متطابقتين';
	@override String get changePasswordSuccess => 'تم تغيير كلمة المرور. يرجى تسجيل الدخول مجددًا.';
}

// Path: updatePrompt
class _Translations$updatePrompt$ar implements Translations$updatePrompt$en {
	_Translations$updatePrompt$ar._(this._root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get checking => 'جارٍ التحقق من التحديثات…';
	@override String get checkFailed => 'فشل التحقق من التحديث. تحقق من شبكتك وحاول مجددًا.';
	@override String alreadyLatest({required Object version}) => 'لديك أحدث إصدار (${version}).';
	@override String newVersionFound({required Object version}) => 'يتوفر إصدار جديد ${version}';
	@override String get installerDownloaded => 'اكتمل تنزيل المثبّت في الخلفية. انقر «التحديث الآن» لإتمام الترقية.';
	@override String get downloadInBackground => 'انقر «التحديث الآن» لتنزيله وتثبيته (يمكنك متابعة استخدام التطبيق؛ فالمثبّت يُنزَّل في الخلفية).';
	@override String get later => 'لاحقًا';
	@override String get updateNow => 'التحديث الآن';
	@override String installerNotReady({required Object version}) => 'لم يكتمل تنزيل المثبّت بعد.\n\nانقر «موافق» لفتح صفحة التنزيل وتحميل المثبّت المناسب لجهازك يدويًا (الإصدار ${version}).';
}

// Path: clearData
class _Translations$clearData$ar implements Translations$clearData$en {
	_Translations$clearData$ar._(this._root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get itemLoginSession => 'جلسة تسجيل الدخول';
	@override String get itemProfiles => 'ملفات الاشتراك الشخصية (profiles/)';
	@override String get itemSettings => 'إعدادات التطبيق والنواة';
	@override String get itemLatencyCache => 'ذاكرة زمن استجابة العُقد';
	@override String get itemLogs => 'سجلات التشغيل';
	@override String get itemRoutingData => 'بيانات التوجيه والملفات المؤقتة';
	@override String confirmBody({required Object items, required Object dir}) => 'سيتم حذف البيانات التالية المحفوظة على هذا الجهاز (ولا يمكن التراجع عن ذلك):\n\n${items}\n\nالحساب نفسه وأي خطة اشتريتها موجودة على الخادم ولن تتأثر؛ سجّل الدخول مجددًا لاستعادة اشتراكك.\n\nدليل البيانات: ${dir}\n(افعل ذلك قبل إلغاء تثبيت التطبيق: عندها فقط تبدأ إعادة التثبيت نظيفة وتطلب منك تسجيل الدخول مجددًا)';
	@override String get confirmAgain => 'المسح الآن؟ ستحتاج إلى تسجيل الدخول مجددًا بعد ذلك.';
	@override String clearedNotice({required Object count, required Object dir}) => 'تم مسح ${count} من عناصر البيانات المحلية (بما فيها جلسة تسجيل الدخول، لذا ستحتاج إلى تسجيل الدخول مجددًا عند فتح التطبيق في المرة القادمة).\n\nيمكنك الآن حذف التطبيق لإتمام إلغاء التثبيت:\n· macOS: اسحب Mclash.app إلى سلة المهملات (تم إفراغ دليل البيانات: ${dir})\n· Windows: أزل تثبيت Mclash من «لوحة التحكم» واختر «لا» عندما يسألك المعالج عن الاحتفاظ ببياناتك';
	@override String clearFailed({required Object error}) => 'فشل المسح: ${error}';
}

// Path: apiError
class _Translations$apiError$ar implements Translations$apiError$en {
	_Translations$apiError$ar._(this._root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String requestFailedHttp({required Object status, required Object domain}) => 'فشل الطلب (HTTP ${status})؛ وقد جُرِّب ${domain} بالفعل';
	@override String allDomainsFailed({required Object method, required Object path, required Object count}) => 'فشل الطلب: ${method} ${path} (جُرِّبت ${count} نطاقات)';
	@override String requestTimeout({required Object seconds, required Object method, required Object path}) => 'انتهت مهلة الطلب (${seconds} ث): ${method} ${path}';
	@override String networkUnreachable({required Object detail}) => 'الشبكة غير متاحة: ${detail}';
	@override String get tlsHandshakeFailed => 'فشلت مصافحة TLS. تحقق من اتصال الشبكة أو من وقت النظام.';
	@override String connectionFailed({required Object detail}) => 'فشل الاتصال: ${detail}';
	@override String requestError({required Object error}) => 'فشل الطلب: ${error}';
	@override String responseReadTimeout({required Object seconds, required Object method, required Object path}) => 'انتهت مهلة قراءة الاستجابة (${seconds} ث): ${method} ${path}';
	@override String notJson({required Object status, required Object snippet}) => 'الاستجابة ليست JSON (HTTP ${status}): ${snippet}';
	@override String badStructure({required Object status}) => 'بنية استجابة غير متوقعة (HTTP ${status})';
	@override String loginFailed({required Object code}) => 'فشل تسجيل الدخول (الرمز ${code})';
	@override String get loginMissingData => 'استجابة تسجيل الدخول تفتقد البيانات';
	@override String get loginMissingToken => 'استجابة تسجيل الدخول لا تحتوي access_token';
	@override String registerFailed({required Object code}) => 'فشل التسجيل (الرمز ${code})';
	@override String get registerMissingToken => 'استجابة التسجيل لا تحتوي access_token — ربما فُعِّل نظام مكافحة المخاطر، أو أن إعداد الموقع مختلف';
	@override String requestFailedCode({required Object code}) => 'فشل الطلب (الرمز ${code})';
}

// Path: subNotice
class _Translations$subNotice$ar implements Translations$subNotice$en {
	_Translations$subNotice$ar._(this._root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get titleNotFound => 'الاشتراك غير موجود';
	@override String get titleExpired => 'انتهى الاشتراك';
	@override String get titleInactive => 'الاشتراك غير مفعّل';
	@override String get titleDeviceOverLimit => 'تجاوز حد الأجهزة';
	@override String get titleUnavailable => 'الاشتراك غير متاح';
	@override String titleWithReason({required Object emoji, required Object title, required Object reason}) => '${emoji} ${title} (${reason})';
	@override String deviceUsedOfLimit({required Object used, required Object limit}) => 'الأجهزة الحالية ${used}/${limit}';
	@override String deviceUsedOnly({required Object used}) => 'الأجهزة الحالية ${used}';
	@override String expireAt({required Object expire}) => 'ينتهي في ${expire}';
	@override String supportLine({required Object account}) => '💬 الدعم: ${account}';
	@override String siteLine({required Object url}) => '📢 الموقع: ${url}';
}

// Path: settingItems
class _Translations$settingItems$ar implements Translations$settingItems$en {
	_Translations$settingItems$ar._(this._root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get subscriptionAutoUpdateInterval => 'الفاصل الزمني للتحديث التلقائي للاشتراك';
	@override String get speedTestMode => 'طريقة اختبار السرعة';
	@override String get speedTestModeTcp => 'اختبار السرعة عبر TCP';
	@override String get speedTestModeKernel => 'اختبار السرعة عبر النواة';
	@override String get delayTestUrlTip => 'زمن طلب HTTP كامل واحد عبر هذه العقدة (وليس ping)\nالقيمة الافتراضية استجابة http 204 فارغة؛ واستخدام https يضيف مصافحة TLS ورقمًا أكبر';
	@override String get systemProxy => 'وكيل النظام';
	@override String get systemProxyTip => 'عرض/إعادة تعيين العنوان والمنفذ';
	@override String get tunMode => 'وضع TUN';
	@override String get tunModeTip => 'إيقاف=وكيل النظام فقط / تلقائي=TUN+وكيل النظام / فرض=TUN فقط\nعلى سطح المكتب يتطلب TUN صلاحيات المسؤول (wintun على Windows / utun على macOS)';
	@override String get tunOverwriteTip => 'تجاوز\nتشغيل = إعدادات TUN في هذه الصفحة تتجاوز قسم tun في الملف الشخصي\nإيقاف = يُستخدم إعداد tun الخاص بالملف الشخصي (دون تدخل التطبيق)';
	@override String tunEnableByTunMode({required Object enable}) => '${enable} (يحدده وضع TUN)';
	@override String get interval30Minutes => '30 دقيقة';
	@override String get interval1Hour => 'ساعة واحدة';
	@override String get interval6Hours => '6 ساعات';
	@override String get interval12Hours => '12 ساعة';
	@override String get interval24Hours => '24 ساعة';
	@override String get interval3Days => '3 أيام';
	@override String get interval7Days => '7 أيام';
	@override String get intervalNever => 'أبدًا';
	@override String intervalMinutes({required Object minutes}) => '${minutes} دقيقة';
	@override String intervalHours({required Object hours}) => '${hours} ساعة';
	@override String intervalDays({required Object days}) => '${days} أيام';
}

// Path: tunScreen
class _Translations$tunScreen$ar implements Translations$tunScreen$en {
	_Translations$tunScreen$ar._(this._root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get modeOff => 'إيقاف';
	@override String get modeAuto => 'تلقائي';
	@override String get modeForce => 'فرض';
	@override String get modeOffDesc => 'وكيل النظام فقط: يعمل مع البرامج التي تحترم وكيل النظام (المتصفحات وغيرها)؛ ولا تمر UDP/الألعاب عبر الوكيل';
	@override String get modeAutoDesc => 'TUN + وكيل النظام (احتياط مزدوج): تمر كل حركة المرور عبر المحول الافتراضي، بما فيها UDP';
	@override String get modeForceDesc => 'TUN فقط: تمر كل حركة المرور عبر المحول الافتراضي، دون المساس بوكيل النظام';
	@override String get modeOffOptionDesc => 'لا يمس جدول التوجيه في النظام؛ بل يضبط وكيلًا على 127.0.0.1 فقط. ولا تستخدمه إلا البرامج التي تحترم وكيل النظام؛ أما حركة UDP والبرامج ذات إعدادات الوكيل الخاصة فلا.';
	@override String get modeAutoOptionDesc => 'ينشئ محولًا افتراضيًا ويتولى كل حركة المرور (بما فيها UDP والألعاب)؛ ويبقى وكيل النظام خيارًا احتياطيًا. مُوصى به: يعمل على مستوى النظام ولا تفقد الاتصال عند غياب الصلاحيات.';
	@override String get modeForceOptionDesc => 'يستخدم المحول الافتراضي فقط ولم يعد يغيّر وكيل النظام. تمر كل حركة المرور (بما فيها UDP) عبر النفق؛ ويبقى إدخال «الوكيل» في النظام كما هو.';
	@override String get adminRequiredDialog => 'يتطلب محول TUN الافتراضي صلاحيات المسؤول (wintun على Windows / utun على macOS).\n\nMclash لا يعمل كمسؤول الآن، لذا لن يعمل TUN بعد تفعيله (في الوضع «تلقائي» يظل وكيل النظام يعمل كخيار احتياطي، فتبقى الشبكة صالحة).\n\nموافق = إعادة تشغيل Mclash كمسؤول الآن (سيظهر طلب UAC)\nإلغاء = حفظ هذا الاختيار على أي حال (يُستخدم وكيل النظام تلقائيًا عند تعذّر TUN)';
	@override String relaunchFailed({required Object message}) => 'فشلت إعادة التشغيل: ${message}';
	@override String switchFailed({required Object message}) => 'فشل تبديل وضع TUN: ${message}\nتمت استعادة الإعدادات السابقة.';
	@override String get setOffSnack => 'تم الضبط على «إيقاف»: وكيل النظام فقط';
	@override String setModeSnack({required Object mode, required Object effect}) => 'تم الضبط على «${mode}»، ${effect}';
	@override String get effectReconnected => 'أُعيد الاتصال وهو فعّال الآن';
	@override String get effectAfterConnect => 'فعّال بعد الاتصال';
	@override String get sheetTitle => 'محول TUN الافتراضي';
	@override String get advancedTitle => 'معاملات متقدمة (إعدادات النواة ← TUN)';
	@override String get advancedSubtitle => 'عنوان المحول / المكدس / MTU / التوجيه التلقائي / اعتراض DNS / التجاوز';
	@override String get adminOk => 'يتطلب TUN صلاحيات المسؤول؛ والصلاحيات الحالية كافية (التشغيل كمسؤول على Windows / كالجذر على macOS)';
	@override String get adminMissing => 'يتطلب TUN صلاحيات المسؤول: Mclash لا يعمل كمسؤول، لذا لن يعمل TUN بعد اختيار «تلقائي/فرض» (يتراجع «تلقائي» إلى وكيل النظام، فتبقى الشبكة صالحة)';
}

// Path: main.tray
class _Translations$main$tray$ar implements Translations$main$tray$en {
	_Translations$main$tray$ar._(this._root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get menuOpen => 'فتح';
	@override String get menuExit => 'خروج';
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
			'main.tray.menuOpen' => 'فتح',
			'main.tray.menuExit' => 'خروج',
			'meta.enable' => 'تشغيل',
			'meta.disable' => 'تعطيل',
			'meta.open' => 'فتح',
			'meta.close' => 'إغلاق',
			'meta.quit' => 'خروج',
			'meta.add' => 'إضافة',
			'meta.remove' => 'إزالة',
			'meta.removeConfirm' => 'هل انت متأكد من الحذف؟',
			'meta.edit' => 'تحرير',
			'meta.view' => 'عرض',
			'meta.remark' => 'ملاحظة',
			'meta.byDefault' => 'افتراضي',
			'meta.more' => 'أكثر',
			'meta.tips' => 'معلومات',
			'meta.selectAll' => 'تحديد الكل',
			'meta.copy' => 'نسخ',
			'meta.paste' => 'لصق',
			'meta.cut' => 'قص',
			'meta.save' => 'حفظ',
			'meta.ok' => 'موافق',
			'meta.cancel' => 'إلغاء',
			'meta.faq' => 'الأسئلة الشائعة',
			'meta.doc' => 'وثيقة',
			'meta.htmlTools' => 'مجموعة أدوات HTML',
			'meta.download' => 'تحميل',
			'meta.loading' => 'تحميل...',
			'meta.days' => 'أيام',
			'meta.hours' => 'ساعات',
			'meta.minutes' => 'دقائق',
			'meta.seconds' => 'ثانية',
			'meta.milliseconds' => 'ميلي ثانية',
			'meta.search' => 'بحث',
			'meta.searchNodeHint' => 'تصفية العُقد (الاسم أو البروتوكول)',
			'meta.connect' => 'اتصال',
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
			'meta.apply' => 'تطبيق',
			'meta.refresh' => 'تحديث',
			'meta.update' => 'تحديث',
			'meta.updateInterval' => 'الفاصل الزمني للتحديث',
			'meta.updateInterval5mTips' => 'الحد الأدنى: 5 دقائق',
			'meta.updateIntervalPreferByProfile' => 'إعطاء الأولوية لإعدادات المزود',
			'meta.updateFailed' => ({required Object p}) => 'فشل التحديث:${p}',
			'meta.none' => 'لا شيء',
			'meta.reset' => 'إعادة ضبط',
			'meta.authentication' => 'المصادقة',
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
			'meta.externalController' => 'التحكم الخارجي',
			'meta.secret' => 'السر',
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
			'meta.autoConnectAfterLaunch' => 'الاتصال التلقائي بعد التشغيل',
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
			'meta.export' => 'تصدير',
			'meta.send' => 'إرسال',
			'meta.sendConfirm' => 'تأكيد الإرسال؟',
			'meta.log' => 'سجل',
			'meta.coreLog' => 'سجل النواة',
			'meta.appLog' => 'سجل التطبيق',
			'meta.core' => 'النواة',
			'meta.help' => 'مساعدة',
			'meta.tutorial' => 'درس تعليمي',
			'meta.board' => 'لوحة',
			'meta.boardOnline' => 'استخدام اللوحة عبر الإنترنت',
			'meta.boardOnlineUrl' => 'عنوان URL للوحة عبر الإنترنت',
			'meta.boardLocalPort' => 'منفذ اللوحة المحلية',
			'meta.alwayOnVPN' => 'اتصال مفتوح دائمًا',
			'meta.disableFontScaler' => 'تعطيل تحجيم الخط(يسري مفعوله بعد إعادة التشغيل)',
			'meta.autoOrientation' => 'التدوير مع الشاشة',
			'meta.restartTakesEffect' => 'يسري بعد إعادة التشغيل',
			'meta.reconnectTakesEffect' => 'سيتم تطبيقه بعد إعادة الاتصال.',
			'meta.runtimeProfile' => 'تكوين وقت التشغيل',
			'meta.willCompleteAfterRebootInstall' => 'يرجى إعادة تشغيل جهازك لإكمال تثبيت توسيع النظام',
			'meta.requestNeedsUserApproval' => '١. يُرجى السماح لـ Mclash بتثبيت ملحقات النظام من [إعدادات النظام] - [الخصوصية والأمان]. ٢. : [إعدادات النظام] - [عام] - [عناصر تسجيل الدخول والملحقات - ملحقات الشبكة] فعّل [mclashServiceSE]. أعد الاتصال بعد الانتهاء.',
			'meta.FullDiskAccessPermissionRequired' => 'يرجى تمكين إذن mclashServiceSE في [إعدادات النظام]-[الخصوصية والأمان]-[الوصول الكامل للقرص] وإعادة الاتصال.',
			'meta.proxy' => 'الوكيل',
			'meta.theme' => 'سمة',
			'meta.tvMode' => 'وضع التلفزيون',
			'meta.autoUpdate' => 'التحديثات التلقائية',
			'meta.updateChannel' => 'تحديث القنوات تلقائيا',
			'meta.hasNewVersion' => ({required Object p}) => 'تحديث الإصدار ${p}',
			'meta.autoDownloadPkg' => 'تنزيل حزم التحديث تلقائيًا',
			'meta.devOptions' => 'خيارات للمطور',
			'meta.about' => 'حول',
			'meta.name' => 'اسم',
			'meta.version' => 'إصدار',
			'meta.sort' => 'إعادة ترتيب',
			'meta.share' => 'مشاركة',
			'meta.importFromClipboard' => 'استيراد من الحافظة',
			'meta.exportToClipboard' => 'تصدير إلى الحافظة',
			'meta.server' => 'الخادم',
			'meta.port' => 'المنفذ',
			'meta.donate' => 'تبرع',
			'meta.setting' => 'إعدادات',
			'meta.settingCore' => 'إعدادات النواة',
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
			'meta.myProfiles' => 'ملفات التعريف',
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
			'dns.listen' => 'عنوان الاستماع',
			'dns.fakeIp' => 'fake-ip',
			'dns.fallback' => 'احتياطي',
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
			'sniffer.overrideDest' => 'تجاوز الوجهة',
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
			'countries.HK' => 'هونغ كونغ',
			'countries.TW' => 'تايوان',
			'countries.MO' => 'ماكاو',
			'countries.CN' => 'الصين',
			'countries.JP' => 'اليابان',
			'countries.KR' => 'كوريا الجنوبية',
			'countries.SG' => 'سنغافورة',
			'countries.MY' => 'ماليزيا',
			'countries.TH' => 'تايلاند',
			'countries.VN' => 'فيتنام',
			'countries.PH' => 'الفلبين',
			'countries.ID' => 'إندونيسيا',
			'countries.KH' => 'كمبوديا',
			'countries.US' => 'الولايات المتحدة',
			'countries.CA' => 'كندا',
			'countries.MX' => 'المكسيك',
			'countries.GB' => 'المملكة المتحدة',
			'countries.DE' => 'ألمانيا',
			'countries.FR' => 'فرنسا',
			'countries.NL' => 'هولندا',
			'countries.RU' => 'روسيا',
			'countries.IT' => 'إيطاليا',
			'countries.ES' => 'إسبانيا',
			'countries.CH' => 'سويسرا',
			'countries.SE' => 'السويد',
			'countries.NO' => 'النرويج',
			'countries.FI' => 'فنلندا',
			'countries.DK' => 'الدنمارك',
			'countries.PL' => 'بولندا',
			'countries.AT' => 'النمسا',
			'countries.IE' => 'أيرلندا',
			'countries.UA' => 'أوكرانيا',
			'countries.TR' => 'تركيا',
			'countries.PT' => 'البرتغال',
			'countries.CZ' => 'التشيك',
			'countries.RO' => 'رومانيا',
			'countries.BE' => 'بلجيكا',
			'countries.GR' => 'اليونان',
			'countries.HU' => 'هنغاريا',
			'countries.IL' => 'إسرائيل',
			'countries.AE' => 'الإمارات',
			'countries.SA' => 'السعودية',
			'countries.EG' => 'مصر',
			'countries.ZA' => 'جنوب أفريقيا',
			'countries.NG' => 'نيجيريا',
			'countries.AU' => 'أستراليا',
			'countries.NZ' => 'نيوزيلندا',
			'countries.BR' => 'البرازيل',
			'countries.AR' => 'الأرجنتين',
			'countries.CL' => 'تشيلي',
			'countries.CO' => 'كولومبيا',
			'countries.IN' => 'الهند',
			'countries.PK' => 'باكستان',
			'countries.XX' => 'أخرى',
			'meScreen.accountBalance' => 'الرصيد',
			'meScreen.expireAt' => 'ينتهي',
			'meScreen.remainingDays' => 'الأيام المتبقية',
			'meScreen.deviceCount' => 'الأجهزة',
			'meScreen.myOrders' => 'طلباتي',
			'meScreen.deviceManagement' => 'إدارة الأجهزة',
			'meScreen.changePassword' => 'تغيير كلمة المرور',
			'meScreen.clearLocalData' => 'مسح البيانات المحلية (قبل إلغاء التثبيت)',
			'meScreen.profileManagementDev' => 'إدارة الملفات الشخصية (للمطور)',
			'meScreen.tunAdapter' => 'محول TUN الافتراضي',
			'meScreen.checkUpdate' => 'التحقق من التحديثات',
			'meScreen.retry' => 'إعادة المحاولة',
			'meScreen.loadFailed' => 'فشل تحميل معلومات الحساب: ربما انتهت صلاحية تسجيل الدخول أو أن الشبكة غير متاحة.\nانقر «تحديث» في أعلى الصفحة لإعادة المحاولة؛ وإن استمر الفشل فسجّل الدخول مجددًا.',
			'meScreen.logoutConfirm' => 'تسجيل الخروج؟',
			'meScreen.boardNoKernel' => 'تعرض اللوحة بيانات النواة الحية (الاتصال، حركة المرور، تطابق القواعد).\n\nالنواة لا تعمل، لذا ستكون اللوحة بلا محتوى.\nانقر «موافق» لفتحها على أي حال، أو «إلغاء» للاتصال من تبويب الرئيسية أولًا.',
			'meScreen.boardOpened' => 'تم فتح اللوحة في متصفحك؛ بدّل العُقد أو القواعد هناك وسيتبع التطبيق خلال ~5 ثوانٍ.',
			'homeScreen.expiresOn' => ({required Object date}) => 'ينتهي ${date}',
			'homeScreen.devicesText' => ({required Object text}) => 'الأجهزة ${text}',
			'homeScreen.upgrade' => 'ترقية',
			'homeScreen.quickCountries' => 'تصفية سريعة حسب الدولة',
			'homeScreen.nodeCount' => ({required Object count}) => '${count} عقدة',
			'homeScreen.autoBestTip' => 'اختيار أسرع عقدة متاحة في كل الدول (الوضع التلقائي)',
			'homeScreen.autoBest' => 'الأفضل تلقائيًا',
			'homeScreen.pickCountryTip' => ({required Object label}) => 'اختيار أسرع عقدة متاحة في «${label}» وتثبيتها',
			'homeScreen.autoNoBetter' => 'الوضع التلقائي مفعّل بالفعل (لم تُوجد عقدة أفضل)',
			'homeScreen.switchedBest' => ({required Object name}) => 'تم التبديل إلى أفضل عقدة: ${name}',
			'homeScreen.switchedCountry' => ({required Object country, required Object node, required Object ms}) => 'تم التبديل إلى أسرع عقدة في ${country}: ${node}${ms}',
			'homeScreen.filterCountryFailed' => ({required Object country, required Object err}) => 'تمت التصفية حسب ${country}؛ وفشل التبديل: ${err}',
			'homeScreen.deviceFullCount' => ({required Object used, required Object limit}) => 'الأجهزة الحالية ${used}/${limit}\n\n',
			'homeScreen.deviceFullUpgradeHint' => 'ترقية حد الأجهزة تعيد الاتصال فورًا (مُوصى بها)؛ ويمكنك أيضًا حذف الأجهزة غير المستخدمة لتحرير مكان.',
			'homeScreen.later' => 'لاحقًا',
			'homeScreen.upgradeDeviceCount' => 'ترقية حد الأجهزة',
			'homeScreen.cannotConnect' => 'تعذّر الاتصال',
			'homeScreen.freshnessNever' => 'لم تتم المزامنة بعد · انقر للتحديث',
			'homeScreen.freshnessJustNow' => 'تم التحديث للتو · انقر لإدارة الأجهزة',
			'homeScreen.freshnessMinutes' => ({required Object minutes}) => 'قبل ${minutes} دقيقة · انقر لإدارة الأجهزة',
			'homeScreen.freshnessStale' => ({required Object minutes}) => 'قبل ${minutes} دقيقة · انقر للتحديث',
			'homeScreen.subscriptionAutoSync' => 'مزامنة الاشتراك تلقائيًا',
			'homeScreen.connecting' => 'جارٍ الاتصال…',
			'homeScreen.disconnecting' => 'جارٍ قطع الاتصال…',
			'homeScreen.tapToDisconnect' => 'انقر المفتاح لقطع الاتصال',
			'homeScreen.tapToConnect' => 'انقر المفتاح للاتصال',
			'homeScreen.currentNode' => 'العقدة الحالية',
			'homeScreen.noNodeSelected' => 'لم تُحدَّد أي عقدة',
			'homeScreen.switchAction' => 'تبديل',
			'homeScreen.realtimeSpeed' => 'السرعة الفورية',
			'homeScreen.totalTraffic' => 'إجمالي حركة المرور',
			'homeScreen.subSyncedNotReady' => 'تم تنزيل الاشتراك، لكن الملف غير جاهز بعد. حاول مجددًا بعد قليل.',
			'homeScreen.noPlan' => 'لا توجد خطة متاحة لهذا الحساب بعد. يرجى شراء خطة أولًا.',
			'homeScreen.loginExpired' => 'انتهت صلاحية تسجيل الدخول. يرجى تسجيل الدخول مجددًا.',
			'homeScreen.syncingWait' => 'جارٍ مزامنة الاشتراك، يرجى الانتظار.',
			'homeScreen.syncFailedNetwork' => ({required Object message}) => 'فشلت مزامنة الاشتراك: ${message}\nتحقق من شبكتك وحاول مجددًا.',
			'homeScreen.syncFailed' => 'فشلت مزامنة الاشتراك، حاول مجددًا لاحقًا.',
			'homeScreen.resetProxy' => 'إعادة تعيين',
			'homeScreen.latencySuffix' => ({required Object ms}) => ' (${ms}ms)',
			'nodesScreen.updatedCount' => ({required Object count}) => 'تم تحديث الاشتراك: ${count} عقدة',
			'nodesScreen.updateFailed' => ({required Object message}) => 'فشل التحديث: ${message}',
			'nodesScreen.updateFailedNetwork' => 'فشل التحديث، يرجى التحقق من شبكتك',
			'nodesScreen.testDone' => ({required Object ok, required Object fail}) => 'اكتمل اختبار السرعة: ${ok} قابلة للوصول، ${fail} غير قابلة (قد تكون غير متصلة)',
			'nodesScreen.switchedTo' => ({required Object name}) => 'تم التبديل إلى ${name}',
			'nodesScreen.switchFailed' => ({required Object message}) => 'فشل التبديل: ${message}\n(يحتاج تبديل العُقد إلى نواة تعمل؛ شغّل المفتاح من تبويب الرئيسية أولًا.)',
			'nodesScreen.selectedAfterConnect' => ({required Object name}) => 'تم اختيار ${name} (يسري بعد الاتصال)',
			'nodesScreen.title' => 'العُقد',
			'nodesScreen.searchNode' => 'البحث في العُقد',
			'nodesScreen.sortByLatency' => 'الترتيب حسب زمن الاستجابة',
			'nodesScreen.updateSubscription' => 'تحديث الاشتراك',
			'nodesScreen.viewByGroup' => 'العرض حسب مجموعة الوكلاء',
			'nodesScreen.testAll' => 'اختبار الكل',
			'nodesScreen.searchHint' => 'ابحث عن عقدة / دولة / بروتوكول',
			'nodesScreen.emptyNoNodes' => 'لا توجد عُقد متاحة بعد.\nتتم مزامنة الاشتراكات تلقائيًا؛ وإن كنت قد سجّلت الدخول للتو فانتظر قليلًا أو انقر «إعادة التحميل» أدناه.',
			'nodesScreen.emptyNoMatch' => 'لا توجد عُقد مطابقة.',
			'nodesScreen.reload' => 'إعادة التحميل',
			'nodesScreen.currentInUse' => 'الحالية (قيد الاستخدام)',
			'nodesScreen.current' => 'الحالية',
			'nodesScreen.notTested' => 'لم يُقس (بانتظار إعادة تحميل النواة)',
			'nodesScreen.timeout' => 'انتهت المهلة',
			'nodesScreen.clear' => 'مسح',
			'nodesScreen.selectNode' => 'اختيار عقدة',
			'nodesScreen.emptyNoKernel' => 'لا توجد عُقد متاحة بعد.\nيرجى تشغيل مفتاح الاتصال من تبويب الرئيسية أولًا.',
			'nodesScreen.openFullList' => 'فتح قائمة العُقد الكاملة (بحث / اختبار سرعة / مجموعات)',
			'nodeAuto.kernelStateUnavailable' => 'حالة العُقدة غير متاحة مؤقتًا من النواة؛ وستُعاد المحاولة تلقائيًا.',
			'nodeAuto.backToFixedNode' => ({required Object fixed}) => 'العودة إلى العقدة المثبَّتة: ${fixed}',
			'nodeAuto.noUsableNodePickOne' => 'لم تُوجد عقدة قابلة للاستخدام. يرجى اختيار واحدة يدويًا من قائمة العُقد.',
			'nodeAuto.noUsableNodeTryOne' => 'لم تُوجد عقدة قابلة للاستخدام. جرّب اختيار واحدة من قائمة العُقد.',
			'nodeAuto.autoConnectedBest' => ({required Object bestNode, required Object bestMs}) => 'تم الاتصال تلقائيًا بأفضل عقدة: ${bestNode} (${bestMs} ms)',
			'nodeAuto.currentNodeUnreachable' => 'العقدة الحالية لا تصل إلى الإنترنت؛ جارٍ التبديل تلقائيًا…',
			'nodeAuto.autoSwitchedToUsable' => ({required Object target}) => 'تم التبديل تلقائيًا إلى عقدة صالحة: ${target}',
			'nodeAuto.newNodesReloading' => ({required Object missing}) => '${missing} عقدة جديدة في الاشتراك لم تُحمَّل في النواة بعد؛ جارٍ إعادة التحميل…',
			'nodeAuto.kernelReloadedRetest' => 'أُعيد تحميل النواة بالاشتراك الجديد؛ شغّل اختبار السرعة مجددًا.',
			'accountBlock.quotaFull' => ({required Object used, required Object limit}) => 'أماكن الأجهزة ممتلئة (${used}/${limit}): هذا الجهاز ما زال ضمن النطاق المرخّص ويمكنه الاتصال بشكل طبيعي. لإضافة جهاز آخر، ارقِ حد الأجهزة أو احذف الأجهزة غير المستخدمة.',
			'accountBlock.banFallback' => 'تم تعطيل حسابك ولم يعد صالحًا للاستخدام.',
			'accountBlock.titleExpired' => 'انتهت الخطة',
			'accountBlock.titleDeviceFull' => 'بلغت حد الأجهزة',
			'accountBlock.titleAccountDisabled' => 'الحساب معطّل',
			'accountBlock.titlePlanDisabled' => 'الخطة معطّلة',
			'accountBlock.titleNoPlan' => 'لا توجد خطة بعد',
			'accountBlock.titleDeviceRemoved' => 'تمت إزالة هذا الجهاز',
			'accountBlock.titleServiceUnavailable' => 'الخدمة غير متاحة مؤقتًا',
			'accountBlock.textExpired' => 'انتهت خطتك. اشترِ خطة لمتابعة استخدام العُقد العالمية.',
			'accountBlock.textDeviceFull' => ({required Object used, required Object limit}) => 'وجد الخادم أن هذا الجهاز يتجاوز حد أجهزة الخطة (${used}/${limit})، لذا لا يمكنه الاتصال حاليًا. احذف الأجهزة غير المستخدمة من «حسابي ← إدارة الأجهزة»، أو ارتقِ إلى خطة بأجهزة أكثر.',
			'accountBlock.textAccountDisabled' => 'تم تعطيل حسابك. يرجى التواصل مع الدعم إن كان لديك أي استفسار.',
			'accountBlock.textPlanDisabled' => 'تم تعطيل خطتك أو أنها في حالة غير طبيعية، لذا لا يمكنك الاتصال. يرجى التواصل مع الدعم إن كان لديك استفسار.',
			'accountBlock.textNoPlan' => 'لم تشترِ خطة بعد. اشترِ واحدة لاستخدام العُقد العالمية.',
			'accountBlock.textDeviceRemoved' => 'تمت إزالة هذا الجهاز وتسجيل خروجه. يرجى تسجيل الدخول مجددًا.',
			'accountBlock.textServiceUnavailable' => 'الخدمة غير متاحة مؤقتًا. حاول لاحقًا؛ وإن استمر الأمر، التقط صورة للشاشة وتواصل مع الدعم.',
			'accountBlock.remainingDays' => ({required Object days}) => 'بقي ${days} يومًا',
			'accountBlock.deviceUsage' => ({required Object used, required Object limit}) => 'الأجهزة ${used}/${limit}',
			'entitlementMsg.tamperedTitle' => 'حالة الترخيص غير طبيعية',
			'entitlementMsg.tamperedClock' => 'تم رصد تراجع في ساعة النظام (أو تلاعب ببيانات الترخيص المحلية). يرجى الاتصال بالشبكة لإتمام عملية تحقق قبل الاتصال.',
			'entitlementMsg.tamperedLocal' => 'بيانات الترخيص المحلية تالفة أو عُدِّلت. يرجى الاتصال بالشبكة لإتمام عملية تحقق قبل الاتصال.',
			'entitlementMsg.needVerifyTitle' => 'يلزم التحقق عبر الإنترنت',
			'entitlementMsg.needVerifyFirst' => 'تعذّر تأكيد حالة خطتك: يرجى الاتصال بالشبكة وتسجيل الدخول، ثم إتمام عملية تحقق واحدة قبل الاتصال.',
			'entitlementMsg.needVerifyRetry' => 'تعذّر تأكيد حالة خطتك. يرجى الاتصال بالشبكة والمحاولة مجددًا.',
			'entitlementMsg.verifyFailedTitle' => 'تعذّر التحقق من حالة الخطة',
			'entitlementMsg.verifyFailedText' => 'انتهت فترة السماح للتحقق والخادم غير متاح. تحقق من شبكتك وحاول مجددًا (وإن كنت قد جدّدت للتو، فسجّل الدخول مجددًا).',
			'entitlementMsg.restrictedTitle' => 'الحساب مقيَّد',
			'entitlementMsg.restrictedFallback' => 'تم تعطيل حسابك أو خطتك، لذا لا يمكنك الاتصال.',
			'entitlementMsg.expiredTitle' => 'انتهت الخطة',
			'entitlementMsg.expiredText' => ({required Object date}) => 'انتهت خطتك في ${date}. وتم مسح ملف الاشتراك المحلي. جدّد وسجّل الدخول مجددًا لاستعادته.',
			'devicesScreen.title' => 'إدارة الأجهزة',
			'devicesScreen.currentPlan' => 'الخطة الحالية',
			'devicesScreen.devicesText' => ({required Object text}) => 'الأجهزة ${text}',
			'devicesScreen.upgradeTitle' => 'ترقية الأجهزة / تمديد المدة',
			'devicesScreen.upgradeSubtitle' => 'أضف أجهزة وأيامًا معًا؛ سعر واحد ودفعة واحدة',
			'devicesScreen.addDevices' => 'إضافة أجهزة',
			'devicesScreen.noAddDevices' => 'بلا تغيير',
			'devicesScreen.addDevicesCount' => ({required Object n}) => '+${n} جهاز',
			'devicesScreen.addDays' => 'إضافة أيام',
			'devicesScreen.noExtend' => 'بلا تمديد',
			'devicesScreen.addDaysCount' => ({required Object n, required Object months}) => '+${n} يوم (${months} شهرًا)',
			'devicesScreen.priceFailed' => 'فشل الحصول على السعر',
			'devicesScreen.amountDue' => ({required Object amount}) => 'الإجمالي ¥${amount}',
			'devicesScreen.requote' => 'إعادة الاحتساب',
			'devicesScreen.goPay' => 'ادفع الآن',
			'devicesScreen.afterUpgrade' => 'بعد الترقية: ',
			'devicesScreen.afterLimit' => ({required Object limit}) => 'حد الأجهزة ${limit}',
			'devicesScreen.afterExpire' => ({required Object date}) => 'ينتهي ${date}',
			'devicesScreen.pickSomething' => 'يرجى إضافة أجهزة أو أيام على الأقل',
			'devicesScreen.daysOnlyUnsupported' => 'لا تدعم اللوحة «تمديد المدة فقط» بعد: يرجى ضبط «إضافة أجهزة» على 1 أو أكثر والمحاولة مجددًا (أو تواصل مع الدعم لتفعيلها).',
			'devicesScreen.paramsRejected' => 'تم رفض المعاملات: يرجى اختيار عدد الأجهزة والأيام مجددًا.',
			'devicesScreen.subscriptionExpired' => 'انتهى الاشتراك، لذا لا يمكن ترقيته. يرجى التجديد أو شراء خطة أولًا.',
			'devicesScreen.orderIncomplete' => 'معلومات الطلب غير مكتملة. انقر «إعادة الاحتساب» وحاول مجددًا.',
			'devicesScreen.orderRegenerated' => 'انتهت صلاحية الطلب السابق؛ وأُنشئ طلب جديد بالإعدادات نفسها.',
			'devicesScreen.payChannelIncomplete' => 'معلومات الطلب أو قناة الدفع غير مكتملة. يرجى إعادة الاحتساب والمحاولة مجددًا.',
			'devicesScreen.noQrCode' => 'لم يُرجع الخادم رمز QR أو رابط دفع. اختر طريقة دفع أخرى أو حاول لاحقًا.',
			'devicesScreen.payStartFailed' => ({required Object err}) => 'فشل بدء الدفع: ${err}',
			'devicesScreen.payCancelled' => 'أُلغي الدفع؛ وتم حذف الطلب المبدئي.',
			'devicesScreen.balancePay' => 'الرصيد',
			'devicesScreen.noPayMethod' => 'لا تتوفر طريقة دفع حاليًا. حاول لاحقًا أو تواصل مع الدعم.',
			'devicesScreen.balanceInsufficient' => ({required Object balance, required Object amount}) => 'الرصيد غير كافٍ (¥${balance}، والمطلوب ¥${amount}).\nهل تريد الشحن أولًا؟',
			'devicesScreen.choosePayMethod' => 'اختر طريقة الدفع',
			'devicesScreen.balanceText' => ({required Object balance}) => 'الرصيد ¥${balance}',
			'devicesScreen.balanceShort' => ({required Object balance}) => 'الرصيد ¥${balance} (غير كافٍ، يرجى الشحن)',
			'devicesScreen.unknownDevice' => 'جهاز غير معروف',
			'devicesScreen.online' => '● متصل',
			'devicesScreen.offline' => '○ غير متصل',
			'devicesScreen.lastActive' => ({required Object text}) => 'آخر نشاط ${text}',
			'devicesScreen.delete' => 'حذف',
			'devicesScreen.deleteConfirm' => ({required Object name}) => 'حذف الجهاز «${name}»؟ سيُفصل عن الشبكة فورًا.',
			'devicesScreen.lastActiveJustNow' => 'الآن',
			'devicesScreen.lastActiveMinutes' => ({required Object minutes}) => 'قبل ${minutes} دقيقة',
			'devicesScreen.lastActiveToday' => ({required Object time}) => 'اليوم ${time}',
			'sysProxySheet.reading' => 'جارٍ القراءة…',
			'sysProxySheet.unknown' => 'غير معروف',
			'sysProxySheet.kernelNotRunning' => 'النواة لا تعمل (شغّل المفتاح من تبويب الرئيسية أولًا)',
			'sysProxySheet.applied' => ({required Object host, required Object port}) => 'مُطبَّق · ${host}:${port}',
			'sysProxySheet.notSet' => ({required Object reason}) => 'لم يُضبط وكيل النظام — ${reason}',
			'sysProxySheet.notEffective' => ({required Object port}) => 'غير فعّال (لا يوجد وكيل نظام يشير إلى ${port})',
			'sysProxySheet.readFailed' => ({required Object err}) => 'فشلت القراءة: ${err}',
			'sysProxySheet.setRejected' => 'فشل الضبط: ربما رفض النظام الكتابة (أو استبدلته برمجية وكيل أخرى)',
			'sysProxySheet.disableFailed' => 'فشل الإيقاف',
			'sysProxySheet.portRange' => 'يجب أن يكون المنفذ بين 1 و65535',
			'sysProxySheet.portChanged' => ({required Object value}) => 'تم تغيير المنفذ إلى ${value}: اقطع الاتصال وأعد الاتصال مرة حتى تستمع النواة إلى المنفذ الجديد',
			'sysProxySheet.title' => 'وكيل النظام',
			'sysProxySheet.desc' => ({required Object host}) => 'عنوان وكيل النظام ثابت على ${host} (الاسترجاع المحلي)، والمنفذ هو المنفذ الهجين للنواة.',
			'sysProxySheet.descWindows' => 'هذا هو نفسه ما تراه في إعدادات Windows ← الشبكة والإنترنت ← الوكيل.',
			'sysProxySheet.reset' => 'إعادة الضبط',
			'sysProxySheet.disable' => 'إيقاف وكيل النظام',
			'sysProxySheet.diagnostics' => 'تشخيص (هل تقرأ الواجهة القيم نفسها من السجل؟)',
			'sysProxySheet.mixedPort' => 'المنفذ الهجين',
			'sysProxySheet.apply' => 'تطبيق',
			'logScreen.readAppFailed' => ({required Object e}) => 'فشلت قراءة سجل التطبيق: ${e}',
			_ => null,
		} ?? switch (path) {
			'logScreen.readCoreFailed' => ({required Object e}) => 'فشلت قراءة سجل النواة: ${e}',
			'logScreen.copied' => 'تم النسخ (روابط الاشتراك وأسرار أخرى محجوبة؛ لكن ملف السجل نفسه قد يحتوي العنوان الخام)',
			'logScreen.copy' => 'نسخ',
			'logScreen.refresh' => 'تحديث',
			'logScreen.empty' => 'لا يوجد محتوى',
			'trayShell.closeTitle' => 'إغلاق النافذة',
			'trayShell.closeBody' => 'إغلاق النافذة يضع Mclash في شريط النظام فقط — فتستمر النواة ووكيل النظام في العمل وتبقى شبكتك متصلة.\n\n· موافق: التصغير إلى شريط النظام (للخروج نهائيًا، انقر بزر الفأرة الأيمن على أيقونة شريط النظام ← خروج)\n· إلغاء: إغلاق Mclash نهائيًا وإيقاف النواة واستعادة وكيل النظام\n\n(سيُحفظ اختيارك؛ وفي المرة القادمة يمكنك استخدام أيقونة شريط النظام مباشرة)',
			'ordersScreen.title' => 'طلباتي',
			'ordersScreen.orderInfoIncomplete' => 'معلومات الطلب غير مكتملة. اسحب إلى الأسفل للتحديث ثم حاول مجددًا.',
			'ordersScreen.payChannelIncomplete' => 'معلومات قناة الدفع غير مكتملة. حاول مجددًا لاحقًا.',
			'ordersScreen.noQrPayload' => 'لم يُرجع الخادم رمز QR أو رابط دفع. اختر طريقة دفع أخرى أو حاول لاحقًا.',
			'ordersScreen.payStartFailed' => ({required Object err}) => 'فشل بدء الدفع: ${err}',
			'ordersScreen.noPayMethod' => 'لا تتوفر طريقة دفع حاليًا. حاول مجددًا لاحقًا أو تواصل مع الدعم.',
			'ordersScreen.choosePayMethod' => 'اختر طريقة الدفع',
			'ordersScreen.amountDue' => ({required Object amount}) => 'المبلغ المستحق ¥${amount}',
			'ordersScreen.paidLabel' => '● مدفوع',
			'ordersScreen.pendingLabel' => '○ غير مدفوع',
			'ordersScreen.unknownStatus' => ({required Object status}) => '✕ ${status}',
			'ordersScreen.orderNoText' => ({required Object orderNo}) => 'رقم الطلب ${orderNo}',
			'ordersScreen.createdAtText' => ({required Object createdAt}) => 'أُنشئ في ${createdAt}',
			'ordersScreen.orderCanceled' => 'تم إلغاء الطلب',
			'ordersScreen.cancelFailed' => ({required Object err}) => 'فشل الإلغاء: ${err}\n(إذا كان الطلب مدفوعًا أو ملغى بالفعل، فاسحب إلى الأسفل للتحديث لرؤية أحدث حالة.)',
			'ordersScreen.cancelOrder' => 'إلغاء الطلب',
			'ordersScreen.continuePay' => 'متابعة الدفع',
			'payment.balancePay' => 'الدفع من الرصيد',
			'payment.qrPay' => 'امسح للدفع',
			'payment.deductFromBalance' => 'يُخصم من رصيد حسابك',
			'payment.openedInBrowser' => 'تم فتح صفحة الدفع في متصفحك',
			'payment.scanWithAlipayWechat' => 'امسح باستخدام Alipay أو WeChat',
			'payment.orderNoText' => ({required Object orderNo}) => 'رقم الطلب ${orderNo}',
			'payment.payFailed' => ({required Object err}) => 'فشل الدفع: ${err}',
			'payment.notDetected' => 'لم يُرصد أي دفع. يمكنك المتابعة لاحقًا من «طلباتي».',
			'payment.charging' => 'جارٍ التحصيل…',
			'payment.processing' => 'جارٍ المعالجة…',
			'payment.waitingPay' => 'في انتظار الدفع…',
			'payment.openPageFailed' => 'تعذّر فتح صفحة الدفع. انقر الزر أدناه لإعادة المحاولة، أو امسح رمز QR بدلًا من ذلك.',
			'payment.reopenPayPage' => 'إعادة فتح صفحة الدفع',
			'payment.payInBrowser' => 'الدفع في المتصفح',
			'payment.openAlipay' => 'فتح Alipay',
			'payment.cancelOrder' => 'إلغاء الطلب',
			'payment.confirmPay' => 'تأكيد الدفع',
			'payment.retry' => 'إعادة المحاولة',
			'payment.paidAlready' => 'لقد دفعت',
			'payment.channelAlipay' => 'Alipay',
			'payment.channelCodepayAlipay' => 'Code Pay · Alipay',
			'payment.channelCodepayWechat' => 'Code Pay · WeChat',
			'payment.channelCodepay' => 'Code Pay',
			'payment.channelWechat' => 'WeChat Pay',
			'payment.channelUsdt' => 'USDT',
			'payment.channelUsdtTrc20' => 'USDT · TRC20',
			'payment.payFallback' => 'دفع',
			'payment.errCsrf' => 'انتهت صلاحية بيانات تسجيل الدخول (فشل فحص CSRF).\nاسحب إلى الأسفل للتحديث في تبويب «حسابي» أو سجّل الدخول مجددًا، ثم أعد المحاولة.',
			'payment.errAlipayLimit' => 'للدفع وجهًا لوجه عبر Alipay حد أقصى لكل عملية (1000 ¥ لهذا التاجر)، وطلبك يتجاوزه.\nيرجى استخدام «الدفع من الرصيد» أو «الدفع بالرمز» بدلًا منه، أو تواصل مع الدعم لرفع حد Alipay.',
			'payment.errNotSigned' => 'لم يشترك تطبيق Alipay في منتج الدفع المطابق، لذا هذه القناة غير متاحة مؤقتًا.\nيرجى استخدام «الدفع من الرصيد» أو «الدفع بالرمز» بدلًا منه، أو تواصل مع الدعم لتفعيله.',
			'payment.errOrderGone' => 'تم إلغاء هذا الطلب أو انتهت صلاحيته (الطلبات المبدئية صالحة 30 دقيقة).\nانقر «إعادة الاحتساب» لإنشاء طلب جديد ثم ادفع.',
			'payment.errNetwork' => ({required Object err}) => 'الشبكة غير متاحة: ${err}',
			'planScreen.recommended' => 'مُوصى به',
			'planScreen.devices' => 'الأجهزة',
			'planScreen.balanceLabel' => ({required Object amount}) => 'الرصيد ¥${amount}',
			'planScreen.balanceInsufficient' => ' (الرصيد غير كافٍ، يرجى الشحن أولًا)',
			'planScreen.total' => 'الإجمالي',
			'planScreen.payNow' => 'ادفع الآن',
			'planScreen.retry' => 'إعادة المحاولة',
			'planScreen.errIncompleteOrder' => 'معلومات الطلب أو قناة الدفع غير مكتملة؛ لا يمكن بدء الدفع.',
			'planScreen.payBalance' => 'الدفع من الرصيد',
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
			'planScreen.payOnline' => 'دفع إلكتروني',
			'authScreen.saveAccountInfo' => 'حفظ معلومات الحساب',
			'authScreen.autoLoginNextTime' => 'تسجيل الدخول تلقائيًا في المرة القادمة',
			'authScreen.needLoginNextTime' => 'ستحتاج إلى تسجيل الدخول مجددًا في المرة القادمة',
			'authScreen.invalidEmail' => 'يرجى إدخال بريد إلكتروني صالح',
			'authScreen.enterEmailFirst' => 'يرجى إدخال بريد إلكتروني صالح أولًا',
			'authScreen.passwordRequired' => 'يرجى إدخال كلمة المرور',
			'authScreen.wrongCredentials' => 'البريد الإلكتروني أو كلمة المرور غير صحيحة',
			'authScreen.requestRejected' => 'تم رفض الطلب. حاول مجددًا لاحقًا.',
			'authScreen.tooFrequent' => 'محاولات كثيرة جدًا. حاول مجددًا لاحقًا.',
			'authScreen.loginFailed' => 'فشل تسجيل الدخول',
			'authScreen.username' => 'اسم المستخدم',
			'authScreen.confirmPassword' => 'تأكيد كلمة المرور',
			'authScreen.inviteCode' => 'رمز الدعوة',
			'authScreen.emailCode' => 'رمز التحقق بالبريد',
			'authScreen.getCode' => 'احصل على الرمز',
			'authScreen.registerAndLogin' => 'التسجيل وتسجيل الدخول',
			'authScreen.usernameMinLength' => ({required Object min}) => 'يجب ألا يقل اسم المستخدم عن ${min} أحرف',
			'authScreen.passwordMismatch' => 'كلمتا المرور غير متطابقتين',
			'authScreen.emailCodeRequired' => 'يرجى إدخال رمز التحقق المرسل بالبريد',
			'authScreen.inviteCodeRequired' => 'يتطلب التسجيل في هذا الموقع رمز دعوة',
			'authScreen.codeSentCheckEmail' => 'تم إرسال رمز التحقق. يرجى التحقق من بريدك.',
			'authScreen.registerSuccess' => 'تم التسجيل بنجاح، وأنت مسجّل الدخول الآن.',
			'authScreen.passwordHint' => ({required Object min}) => '${min} أحرف على الأقل، تشمل حروفًا وأرقامًا',
			'authScreen.passwordTooShort' => ({required Object min}) => 'يجب ألا تقل كلمة المرور عن ${min} أحرف',
			'authScreen.passwordNeedsLetterAndDigit' => 'يجب أن تحتوي كلمة المرور على حروف وأرقام معًا',
			'authScreen.registeredEmail' => 'البريد الإلكتروني المسجَّل',
			'authScreen.newPassword' => 'كلمة المرور الجديدة',
			'authScreen.confirmNewPassword' => 'تأكيد كلمة المرور الجديدة',
			'authScreen.resetPassword' => 'إعادة تعيين كلمة المرور',
			'authScreen.resetCodeSent' => 'إذا كان هذا البريد مسجّلًا، فقد أُرسل رمز إعادة التعيين (صالح 15 دقيقة).',
			'authScreen.resetSuccess' => 'تمت إعادة تعيين كلمة المرور. يرجى تسجيل الدخول بكلمتك الجديدة.',
			'authScreen.changePasswordTitle' => 'تغيير كلمة المرور',
			'authScreen.currentPassword' => 'كلمة المرور الحالية',
			'authScreen.saveNewPassword' => 'حفظ كلمة المرور الجديدة',
			'authScreen.newPasswordMismatch' => 'كلمتا المرور الجديدتان غير متطابقتين',
			'authScreen.changePasswordSuccess' => 'تم تغيير كلمة المرور. يرجى تسجيل الدخول مجددًا.',
			'updatePrompt.checking' => 'جارٍ التحقق من التحديثات…',
			'updatePrompt.checkFailed' => 'فشل التحقق من التحديث. تحقق من شبكتك وحاول مجددًا.',
			'updatePrompt.alreadyLatest' => ({required Object version}) => 'لديك أحدث إصدار (${version}).',
			'updatePrompt.newVersionFound' => ({required Object version}) => 'يتوفر إصدار جديد ${version}',
			'updatePrompt.installerDownloaded' => 'اكتمل تنزيل المثبّت في الخلفية. انقر «التحديث الآن» لإتمام الترقية.',
			'updatePrompt.downloadInBackground' => 'انقر «التحديث الآن» لتنزيله وتثبيته (يمكنك متابعة استخدام التطبيق؛ فالمثبّت يُنزَّل في الخلفية).',
			'updatePrompt.later' => 'لاحقًا',
			'updatePrompt.updateNow' => 'التحديث الآن',
			'updatePrompt.installerNotReady' => ({required Object version}) => 'لم يكتمل تنزيل المثبّت بعد.\n\nانقر «موافق» لفتح صفحة التنزيل وتحميل المثبّت المناسب لجهازك يدويًا (الإصدار ${version}).',
			'clearData.itemLoginSession' => 'جلسة تسجيل الدخول',
			'clearData.itemProfiles' => 'ملفات الاشتراك الشخصية (profiles/)',
			'clearData.itemSettings' => 'إعدادات التطبيق والنواة',
			'clearData.itemLatencyCache' => 'ذاكرة زمن استجابة العُقد',
			'clearData.itemLogs' => 'سجلات التشغيل',
			'clearData.itemRoutingData' => 'بيانات التوجيه والملفات المؤقتة',
			'clearData.confirmBody' => ({required Object items, required Object dir}) => 'سيتم حذف البيانات التالية المحفوظة على هذا الجهاز (ولا يمكن التراجع عن ذلك):\n\n${items}\n\nالحساب نفسه وأي خطة اشتريتها موجودة على الخادم ولن تتأثر؛ سجّل الدخول مجددًا لاستعادة اشتراكك.\n\nدليل البيانات: ${dir}\n(افعل ذلك قبل إلغاء تثبيت التطبيق: عندها فقط تبدأ إعادة التثبيت نظيفة وتطلب منك تسجيل الدخول مجددًا)',
			'clearData.confirmAgain' => 'المسح الآن؟ ستحتاج إلى تسجيل الدخول مجددًا بعد ذلك.',
			'clearData.clearedNotice' => ({required Object count, required Object dir}) => 'تم مسح ${count} من عناصر البيانات المحلية (بما فيها جلسة تسجيل الدخول، لذا ستحتاج إلى تسجيل الدخول مجددًا عند فتح التطبيق في المرة القادمة).\n\nيمكنك الآن حذف التطبيق لإتمام إلغاء التثبيت:\n· macOS: اسحب Mclash.app إلى سلة المهملات (تم إفراغ دليل البيانات: ${dir})\n· Windows: أزل تثبيت Mclash من «لوحة التحكم» واختر «لا» عندما يسألك المعالج عن الاحتفاظ ببياناتك',
			'clearData.clearFailed' => ({required Object error}) => 'فشل المسح: ${error}',
			'apiError.requestFailedHttp' => ({required Object status, required Object domain}) => 'فشل الطلب (HTTP ${status})؛ وقد جُرِّب ${domain} بالفعل',
			'apiError.allDomainsFailed' => ({required Object method, required Object path, required Object count}) => 'فشل الطلب: ${method} ${path} (جُرِّبت ${count} نطاقات)',
			'apiError.requestTimeout' => ({required Object seconds, required Object method, required Object path}) => 'انتهت مهلة الطلب (${seconds} ث): ${method} ${path}',
			'apiError.networkUnreachable' => ({required Object detail}) => 'الشبكة غير متاحة: ${detail}',
			'apiError.tlsHandshakeFailed' => 'فشلت مصافحة TLS. تحقق من اتصال الشبكة أو من وقت النظام.',
			'apiError.connectionFailed' => ({required Object detail}) => 'فشل الاتصال: ${detail}',
			'apiError.requestError' => ({required Object error}) => 'فشل الطلب: ${error}',
			'apiError.responseReadTimeout' => ({required Object seconds, required Object method, required Object path}) => 'انتهت مهلة قراءة الاستجابة (${seconds} ث): ${method} ${path}',
			'apiError.notJson' => ({required Object status, required Object snippet}) => 'الاستجابة ليست JSON (HTTP ${status}): ${snippet}',
			'apiError.badStructure' => ({required Object status}) => 'بنية استجابة غير متوقعة (HTTP ${status})',
			'apiError.loginFailed' => ({required Object code}) => 'فشل تسجيل الدخول (الرمز ${code})',
			'apiError.loginMissingData' => 'استجابة تسجيل الدخول تفتقد البيانات',
			'apiError.loginMissingToken' => 'استجابة تسجيل الدخول لا تحتوي access_token',
			'apiError.registerFailed' => ({required Object code}) => 'فشل التسجيل (الرمز ${code})',
			'apiError.registerMissingToken' => 'استجابة التسجيل لا تحتوي access_token — ربما فُعِّل نظام مكافحة المخاطر، أو أن إعداد الموقع مختلف',
			'apiError.requestFailedCode' => ({required Object code}) => 'فشل الطلب (الرمز ${code})',
			'subNotice.titleNotFound' => 'الاشتراك غير موجود',
			'subNotice.titleExpired' => 'انتهى الاشتراك',
			'subNotice.titleInactive' => 'الاشتراك غير مفعّل',
			'subNotice.titleDeviceOverLimit' => 'تجاوز حد الأجهزة',
			'subNotice.titleUnavailable' => 'الاشتراك غير متاح',
			'subNotice.titleWithReason' => ({required Object emoji, required Object title, required Object reason}) => '${emoji} ${title} (${reason})',
			'subNotice.deviceUsedOfLimit' => ({required Object used, required Object limit}) => 'الأجهزة الحالية ${used}/${limit}',
			'subNotice.deviceUsedOnly' => ({required Object used}) => 'الأجهزة الحالية ${used}',
			'subNotice.expireAt' => ({required Object expire}) => 'ينتهي في ${expire}',
			'subNotice.supportLine' => ({required Object account}) => '💬 الدعم: ${account}',
			'subNotice.siteLine' => ({required Object url}) => '📢 الموقع: ${url}',
			'settingItems.subscriptionAutoUpdateInterval' => 'الفاصل الزمني للتحديث التلقائي للاشتراك',
			'settingItems.speedTestMode' => 'طريقة اختبار السرعة',
			'settingItems.speedTestModeTcp' => 'اختبار السرعة عبر TCP',
			'settingItems.speedTestModeKernel' => 'اختبار السرعة عبر النواة',
			'settingItems.delayTestUrlTip' => 'زمن طلب HTTP كامل واحد عبر هذه العقدة (وليس ping)\nالقيمة الافتراضية استجابة http 204 فارغة؛ واستخدام https يضيف مصافحة TLS ورقمًا أكبر',
			'settingItems.systemProxy' => 'وكيل النظام',
			'settingItems.systemProxyTip' => 'عرض/إعادة تعيين العنوان والمنفذ',
			'settingItems.tunMode' => 'وضع TUN',
			'settingItems.tunModeTip' => 'إيقاف=وكيل النظام فقط / تلقائي=TUN+وكيل النظام / فرض=TUN فقط\nعلى سطح المكتب يتطلب TUN صلاحيات المسؤول (wintun على Windows / utun على macOS)',
			'settingItems.tunOverwriteTip' => 'تجاوز\nتشغيل = إعدادات TUN في هذه الصفحة تتجاوز قسم tun في الملف الشخصي\nإيقاف = يُستخدم إعداد tun الخاص بالملف الشخصي (دون تدخل التطبيق)',
			'settingItems.tunEnableByTunMode' => ({required Object enable}) => '${enable} (يحدده وضع TUN)',
			'settingItems.interval30Minutes' => '30 دقيقة',
			'settingItems.interval1Hour' => 'ساعة واحدة',
			'settingItems.interval6Hours' => '6 ساعات',
			'settingItems.interval12Hours' => '12 ساعة',
			'settingItems.interval24Hours' => '24 ساعة',
			'settingItems.interval3Days' => '3 أيام',
			'settingItems.interval7Days' => '7 أيام',
			'settingItems.intervalNever' => 'أبدًا',
			'settingItems.intervalMinutes' => ({required Object minutes}) => '${minutes} دقيقة',
			'settingItems.intervalHours' => ({required Object hours}) => '${hours} ساعة',
			'settingItems.intervalDays' => ({required Object days}) => '${days} أيام',
			'tunScreen.modeOff' => 'إيقاف',
			'tunScreen.modeAuto' => 'تلقائي',
			'tunScreen.modeForce' => 'فرض',
			'tunScreen.modeOffDesc' => 'وكيل النظام فقط: يعمل مع البرامج التي تحترم وكيل النظام (المتصفحات وغيرها)؛ ولا تمر UDP/الألعاب عبر الوكيل',
			'tunScreen.modeAutoDesc' => 'TUN + وكيل النظام (احتياط مزدوج): تمر كل حركة المرور عبر المحول الافتراضي، بما فيها UDP',
			'tunScreen.modeForceDesc' => 'TUN فقط: تمر كل حركة المرور عبر المحول الافتراضي، دون المساس بوكيل النظام',
			'tunScreen.modeOffOptionDesc' => 'لا يمس جدول التوجيه في النظام؛ بل يضبط وكيلًا على 127.0.0.1 فقط. ولا تستخدمه إلا البرامج التي تحترم وكيل النظام؛ أما حركة UDP والبرامج ذات إعدادات الوكيل الخاصة فلا.',
			'tunScreen.modeAutoOptionDesc' => 'ينشئ محولًا افتراضيًا ويتولى كل حركة المرور (بما فيها UDP والألعاب)؛ ويبقى وكيل النظام خيارًا احتياطيًا. مُوصى به: يعمل على مستوى النظام ولا تفقد الاتصال عند غياب الصلاحيات.',
			'tunScreen.modeForceOptionDesc' => 'يستخدم المحول الافتراضي فقط ولم يعد يغيّر وكيل النظام. تمر كل حركة المرور (بما فيها UDP) عبر النفق؛ ويبقى إدخال «الوكيل» في النظام كما هو.',
			'tunScreen.adminRequiredDialog' => 'يتطلب محول TUN الافتراضي صلاحيات المسؤول (wintun على Windows / utun على macOS).\n\nMclash لا يعمل كمسؤول الآن، لذا لن يعمل TUN بعد تفعيله (في الوضع «تلقائي» يظل وكيل النظام يعمل كخيار احتياطي، فتبقى الشبكة صالحة).\n\nموافق = إعادة تشغيل Mclash كمسؤول الآن (سيظهر طلب UAC)\nإلغاء = حفظ هذا الاختيار على أي حال (يُستخدم وكيل النظام تلقائيًا عند تعذّر TUN)',
			'tunScreen.relaunchFailed' => ({required Object message}) => 'فشلت إعادة التشغيل: ${message}',
			'tunScreen.switchFailed' => ({required Object message}) => 'فشل تبديل وضع TUN: ${message}\nتمت استعادة الإعدادات السابقة.',
			'tunScreen.setOffSnack' => 'تم الضبط على «إيقاف»: وكيل النظام فقط',
			'tunScreen.setModeSnack' => ({required Object mode, required Object effect}) => 'تم الضبط على «${mode}»، ${effect}',
			'tunScreen.effectReconnected' => 'أُعيد الاتصال وهو فعّال الآن',
			'tunScreen.effectAfterConnect' => 'فعّال بعد الاتصال',
			'tunScreen.sheetTitle' => 'محول TUN الافتراضي',
			'tunScreen.advancedTitle' => 'معاملات متقدمة (إعدادات النواة ← TUN)',
			'tunScreen.advancedSubtitle' => 'عنوان المحول / المكدس / MTU / التوجيه التلقائي / اعتراض DNS / التجاوز',
			'tunScreen.adminOk' => 'يتطلب TUN صلاحيات المسؤول؛ والصلاحيات الحالية كافية (التشغيل كمسؤول على Windows / كالجذر على macOS)',
			'tunScreen.adminMissing' => 'يتطلب TUN صلاحيات المسؤول: Mclash لا يعمل كمسؤول، لذا لن يعمل TUN بعد اختيار «تلقائي/فرض» (يتراجع «تلقائي» إلى وكيل النظام، فتبقى الشبكة صالحة)',
			_ => null,
		};
	}
}
