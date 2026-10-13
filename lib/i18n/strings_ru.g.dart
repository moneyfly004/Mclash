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
class TranslationsRu with BaseTranslations<AppLocale, Translations> implements Translations {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	TranslationsRu({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: AppLocale.ru,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <ru>.
	final TranslationMetadata<AppLocale, Translations> _meta;
	@override TranslationMetadata<AppLocale, Translations> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key);

	late final TranslationsRu _root = this; // ignore: unused_field

	@override 
	TranslationsRu $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => TranslationsRu(meta: meta ?? this.$meta);

	// Translations
	@override late final _Translations$BackupAndSyncWebdavScreen$ru BackupAndSyncWebdavScreen = _Translations$BackupAndSyncWebdavScreen$ru._(_root);
	@override late final _Translations$LaunchFailedScreen$ru LaunchFailedScreen = _Translations$LaunchFailedScreen$ru._(_root);
	@override late final _Translations$PerAppAndroidScreen$ru PerAppAndroidScreen = _Translations$PerAppAndroidScreen$ru._(_root);
	@override late final _Translations$UserAgreementScreen$ru UserAgreementScreen = _Translations$UserAgreementScreen$ru._(_root);
	@override late final _Translations$NetCheckScreen$ru NetCheckScreen = _Translations$NetCheckScreen$ru._(_root);
	@override late final _Translations$VersionUpdateScreen$ru VersionUpdateScreen = _Translations$VersionUpdateScreen$ru._(_root);
	@override late final _Translations$loginScreen$ru loginScreen = _Translations$loginScreen$ru._(_root);
	@override late final _Translations$main$ru main = _Translations$main$ru._(_root);
	@override late final _Translations$meta$ru meta = _Translations$meta$ru._(_root);
	@override late final _Translations$permission$ru permission = _Translations$permission$ru._(_root);
	@override late final _Translations$tls$ru tls = _Translations$tls$ru._(_root);
	@override late final _Translations$tun$ru tun = _Translations$tun$ru._(_root);
	@override late final _Translations$dns$ru dns = _Translations$dns$ru._(_root);
	@override late final _Translations$sniffer$ru sniffer = _Translations$sniffer$ru._(_root);
	@override late final _Translations$profilePatchMode$ru profilePatchMode = _Translations$profilePatchMode$ru._(_root);
	@override String sendOrReceiveNotMatch({required Object p}) => 'Пожалуйста, используйте [${p}]';
	@override String targetConnectFailed({required Object p}) => 'Не удалось подключиться к [${p}]. Убедитесь, что устройство находится в той же локальной сети.';
	@override String get edgeRuntimeNotInstalled => 'Среда выполнения Edge WebView2 не установлена ​​на текущем устройстве, и страница не может быть отображена. Загрузите и установите среду выполнения Edge WebView2 (x64), перезапустите приложение и повторите попытку.';
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
	@override late final _Translations$meScreen$ru meScreen = _Translations$meScreen$ru._(_root);
	@override late final _Translations$homeScreen$ru homeScreen = _Translations$homeScreen$ru._(_root);
	@override late final _Translations$nodesScreen$ru nodesScreen = _Translations$nodesScreen$ru._(_root);
	@override late final _Translations$nodeAuto$ru nodeAuto = _Translations$nodeAuto$ru._(_root);
	@override late final _Translations$accountBlock$ru accountBlock = _Translations$accountBlock$ru._(_root);
	@override late final _Translations$entitlementMsg$ru entitlementMsg = _Translations$entitlementMsg$ru._(_root);
	@override late final _Translations$devicesScreen$ru devicesScreen = _Translations$devicesScreen$ru._(_root);
	@override late final _Translations$sysProxySheet$ru sysProxySheet = _Translations$sysProxySheet$ru._(_root);
	@override late final _Translations$logScreen$ru logScreen = _Translations$logScreen$ru._(_root);
	@override late final _Translations$trayShell$ru trayShell = _Translations$trayShell$ru._(_root);
}

// Path: BackupAndSyncWebdavScreen
class _Translations$BackupAndSyncWebdavScreen$ru implements Translations$BackupAndSyncWebdavScreen$en {
	_Translations$BackupAndSyncWebdavScreen$ru._(this._root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get webdavServerUrl => 'Адрес сервера';
	@override String get webdavRequired => 'Не может быть пустым';
	@override String get webdavLoginFailed => 'Ошибка входа:';
	@override String get webdavListFailed => 'Не удалось получить список файлов:';
}

// Path: LaunchFailedScreen
class _Translations$LaunchFailedScreen$ru implements Translations$LaunchFailedScreen$en {
	_Translations$LaunchFailedScreen$ru._(this._root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get invalidProcess => 'Не удалось запустить приложение [Неверное имя процесса], переустановите приложение в отдельную папку';
	@override String get invalidProfile => 'Не удалось запустить приложение [Не удалось получить доступ к профилю], переустановите приложение';
	@override String get invalidVersion => 'Не удалось запустить приложение [Неверная версия], переустановите приложение';
	@override String get systemVersionLow => 'Не удалось запустить приложение [Слишком низкая версия системы]';
	@override String get invalidInstallPath => 'Путь установки недействителен, переустановите его по допустимому пути';
}

// Path: PerAppAndroidScreen
class _Translations$PerAppAndroidScreen$ru implements Translations$PerAppAndroidScreen$en {
	_Translations$PerAppAndroidScreen$ru._(this._root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get title => 'Проксируемые приложения';
	@override String get whiteListMode => 'Режим белого списка';
	@override String get whiteListModeTip => 'Если включено: перенаправляются через прокси-сервер только те приложения, которые были отмечены. Если выключено: перенаправляются через прокси-сервер только те приложения, которые не были отмечены.';
}

// Path: UserAgreementScreen
class _Translations$UserAgreementScreen$ru implements Translations$UserAgreementScreen$en {
	_Translations$UserAgreementScreen$ru._(this._root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get privacyFirst => 'Ваша конфиденциальность превыше всего';
	@override String get agreeAndContinue => 'Принять и продолжить';
}

// Path: NetCheckScreen
class _Translations$NetCheckScreen$ru implements Translations$NetCheckScreen$en {
	_Translations$NetCheckScreen$ru._(this._root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get enterDomain => 'Введите доменное имя';
	@override String get checking => 'Проверка...';
	@override String aQueryFailed({required Object p}) => 'Ошибка запроса A: ${p}';
	@override String aaaaQueryFailed({required Object p}) => 'Ошибка запроса AAAA: ${p}';
	@override String get success => 'Успех';
	@override String get failed => 'Ошибка';
	@override String get suspectedPollution => 'Подозрение на DNS-отравление';
	@override String get domainLabel => 'Домен';
	@override String get checkButton => 'Проверить';
	@override String get dnsSection => '1. DNS-запрос';
	@override String get directHttpSection => '2. HTTP (через TUN, сначала включите TUN)';
	@override String proxyHttpSection({required Object p}) => '3. HTTP (через прокси, порт: ${p})';
	@override String get tunNotEnabled => 'TUN не включён';
	@override String get routeTableSection => '4. Таблица маршрутов';
}

// Path: VersionUpdateScreen
class _Translations$VersionUpdateScreen$ru implements Translations$VersionUpdateScreen$en {
	_Translations$VersionUpdateScreen$ru._(this._root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String versionReady({required Object p}) => 'Новая версия [${p}] доступна';
	@override String get update => 'Перезапустить';
	@override String get cancel => 'Не сейчас';
}

// Path: loginScreen
class _Translations$loginScreen$ru implements Translations$loginScreen$en {
	_Translations$loginScreen$ru._(this._root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get login => 'Вход';
	@override String get register => 'Зарегистрировать аккаунт';
	@override String get forgotPassword => 'Забыли пароль';
	@override String get provider => 'Провайдер';
	@override String get providerName => 'Код/алиас/URL ${_root.loginScreen.provider}';
	@override String get account => 'Аккаунт';
	@override String get email => 'Электронная почта';
	@override String get password => 'Пароль';
}

// Path: main
class _Translations$main$ru implements Translations$main$en {
	_Translations$main$ru._(this._root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override late final _Translations$main$tray$ru tray = _Translations$main$tray$ru._(_root);
}

// Path: meta
class _Translations$meta$ru implements Translations$meta$en {
	_Translations$meta$ru._(this._root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get enable => 'Включить';
	@override String get disable => 'Запретить';
	@override String get open => 'Открыть';
	@override String get close => 'Закрыть';
	@override String get quit => 'Выйти';
	@override String get add => 'Добавить';
	@override String get remove => 'Удалить';
	@override String get removeConfirm => 'Подтверждаете удаление?';
	@override String get edit => 'Редактировать';
	@override String get view => 'Просмотр';
	@override String get remark => 'Примечание';
	@override String get byDefault => 'по умолчанию';
	@override String get more => 'Больше';
	@override String get tips => 'Инфо';
	@override String get selectAll => 'Выбрать все';
	@override String get copy => 'Скопировать';
	@override String get paste => 'Вставить';
	@override String get cut => 'Вырезать';
	@override String get save => 'Сохранить';
	@override String get ok => 'Ок';
	@override String get cancel => 'Закрыть';
	@override String get faq => 'Часто задаваемые вопросы (FAQ)';
	@override String get doc => 'документ';
	@override String get htmlTools => 'HTML Toolset';
	@override String get download => 'Скачать';
	@override String get loading => 'Загрузка...';
	@override String get days => 'дни';
	@override String get hours => 'часы';
	@override String get minutes => 'минуты';
	@override String get seconds => 'секунды';
	@override String get milliseconds => 'миллисекунды';
	@override String get search => 'Поиск';
	@override String get searchNodeHint => 'Фильтр узлов (имя или протокол)';
	@override String get connect => 'Соединить';
	@override String get disconnect => 'Отключить';
	@override String get connected => 'Подключено';
	@override String get disconnected => 'Отключено';
	@override String get connecting => 'Подключение';
	@override String get connectTimeout => 'Таймаут при соединении';
	@override String get timeout => 'Тайм-аут';
	@override String get latencyTest => 'Обнаружение задержки';
	@override String get networkCheck => 'Проверка сети';
	@override String get language => 'Язык';
	@override String get next => 'Дальше';
	@override String get done => 'Готово';
	@override String get apply => 'Применить';
	@override String get refresh => 'Обновить';
	@override String get update => 'Обновить';
	@override String get updateInterval => 'Интервал обновления';
	@override String get updateInterval5mTips => 'Минимум: 5 м';
	@override String get updateIntervalPreferByProfile => 'Приоритет настроек провайдера';
	@override String updateFailed({required Object p}) => 'Не удалось обновить:${p}';
	@override String get none => 'Ничего не делать';
	@override String get reset => 'Перезагрузить';
	@override String get authentication => 'Авторизация';
	@override String get user => 'Пользователь';
	@override String get account => 'Аккаунт';
	@override String get password => 'Пароль';
	@override String get decryptPassword => 'Пароль расшифровки';
	@override String get required => 'Необходимо';
	@override String get go => 'Продолжить';
	@override String get other => 'Другой';
	@override String get dns => 'DNS';
	@override String get url => 'URL';
	@override String get urlInvalid => 'Неверный URL';
	@override String get copyUrl => 'Скопировать ссылку';
	@override String get openUrl => 'Открыть ссылку';
	@override String get coreSettingTips => 'Примечание: После изменения конфигурации необходимо повторно подключиться, чтобы изменения вступили в силу.';
	@override String get overwrite => 'Переопределить';
	@override String get overwriteAppend => 'Дополнительное переопределение';
	@override String get overwriteTips => 'Исходная конфигурация <- Пользовательское переопределение <- Переопределение приложения';
	@override String get noOverwrite => 'Не перезаписывать';
	@override String get diversionTemplates => 'Шаблон сортировки пациентов';
	@override String get ruleProviders => 'Поставщик правил';
	@override String get ruleTemplates => 'Шаблон правила';
	@override String get proxyGroupsTemplates => 'Шаблон группы агентов';
	@override String get proxyGroups => 'Группа агентов';
	@override String get proxyNodeList => 'Список прокси-узлов';
	@override String proxyNodeFailure({required Object p}) => 'Срок действия следующих прокси-узлов истек, и они были автоматически удалены: ${p}';
	@override String get externalController => 'Внешнее управление';
	@override String get secret => 'Пароль';
	@override String get tcpConcurrent => 'Параллельное TCP-подтверждение';
	@override String get globalClientFingerprint => 'Глобальный отпечаток пальца TLS';
	@override String get allowLanAccess => 'Доступ к локальной сети устройства';
	@override String get mixedPort => 'Порт mixed-прокси';
	@override String get logLevel => 'Уровень журнала';
	@override String get findProcessMode => 'Режим поиска процесса';
	@override String get tcpkeepAliveInterval => 'Интервал проверки активности TCP';
	@override String get delayTestUrl => 'URL-адрес теста задержки';
	@override String get delayTestTimeout => 'Время ожидания теста задержки (мс)';
	@override String get tun => 'TUN';
	@override String get ntp => 'NTP';
	@override String get tls => 'TLS';
	@override String get geoDownloadByProxy => 'Загрузка гео-правил через прокси';
	@override String get geoRulesetTips => 'Geosite/Geoip будет преобразован в соответствующий RuleSet';
	@override String get sniffer => 'Обнаружение доменов';
	@override String get userAgent => 'UserAgent';
	@override String get launchAtStartup => 'Запуск при включении';
	@override String get launchAtStartupRunAsAdmin => 'Пожалуйста, перезапустите Mclash от имени администратора.';
	@override String get tunModeRunAsAdmin => 'Для режима TUN требуются права администратора. Перезапустите приложение от имени администратора';
	@override String get portableMode => 'Портативный режим';
	@override String get portableModeDisableTips => 'Если вам нужно выйти из портативного режима, выйдите из [mclash] и вручную удалите папку [portable] в том же каталоге, что и [mclash.exe]';
	@override String get autoConnectAfterLaunch => 'Автоматическое подключение после запуска';
	@override String get autoConnectAtBoot => 'Автоматическое подключение после запуска системы';
	@override String get autoConnectAtBootTips => 'Требуется поддержка системы; некоторые системы также могут потребовать включения [автозапуска].';
	@override String get hideAfterLaunch => 'Скрыть окно после запуска';
	@override String get autoSetSystemProxy => 'Установить системный прокси после подключения';
	@override String get bypassSystemProxy => 'Доменные имена, которым разрешено обходить системный прокси-сервер';
	@override String get excludeFromRecent => 'Скрыть из недавних задач';
	@override String get wakeLock => 'Блокировка пробуждения';
	@override String get hideDockIcon => 'Скрыть значок дока';
	@override String get showTrayTraffic => 'Показывать трафик в трее';
	@override String get website => 'Веб-сайт';
	@override String get rule => 'Правила';
	@override String get global => 'Глобально';
	@override String get direct => 'Напрямую';
	@override String get qrcode => 'QR-код';
	@override String get qrcodeTooLong => 'Слишком большой текст для отображения';
	@override String get qrcodeShare => 'Поделиться QR-кодом';
	@override String get qrcodeScan => 'Сканировать QR-код';
	@override String get qrcodeScanResult => 'Результат сканирования';
	@override String get backupAndSync => 'Резервное копирование и синхронизация';
	@override String get export => 'Экспорт';
	@override String get send => 'Передать';
	@override String get sendConfirm => 'Подтверждаете передачу?';
	@override String get log => 'Журнал';
	@override String get coreLog => 'Журнал ядра';
	@override String get appLog => 'Журнал приложения';
	@override String get core => 'Ядро';
	@override String get help => 'Помощь';
	@override String get tutorial => 'Руководство';
	@override String get board => 'Панель';
	@override String get boardOnline => 'Использование онлайн-панели';
	@override String get boardOnlineUrl => 'URL-адрес онлайн-панели';
	@override String get boardLocalPort => 'Порт локальной панели';
	@override String get alwayOnVPN => 'VPN всегда включен';
	@override String get disableFontScaler => 'Отключить масштабирование шрифта';
	@override String get autoOrientation => 'Следовать за поворотом экрана';
	@override String get restartTakesEffect => 'Требуется перезапуск';
	@override String get reconnectTakesEffect => 'Изменения вступят в силу после повторного подключения.';
	@override String get runtimeProfile => 'Конфигурация времени выполнения';
	@override String get willCompleteAfterRebootInstall => 'Пожалуйста, перезагрузите устройство, чтобы завершить установку расширения системы.';
	@override String get requestNeedsUserApproval => '1. Пожалуйста, [разрешите] Mclash устанавливать системные расширения в [Системные настройки] - [Конфиденциальность и безопасность]. 2. : [Системные настройки] - [Основные] - [Элементы входа и расширения - Сетевые расширения] Включите [mclashServiceSE]. После завершения подключитесь снова.';
	@override String get FullDiskAccessPermissionRequired => 'Включите разрешение mclashServiceSE в [Системные настройки]-[Конфиденциальность и безопасность]-[Полный доступ к диску] и переподключитесь.';
	@override String get proxy => 'Прокси';
	@override String get theme => 'Тема';
	@override String get tvMode => 'Режим ТВ';
	@override String get autoUpdate => 'Автоматические обновления';
	@override String get updateChannel => 'Канал автоматического обновления';
	@override String hasNewVersion({required Object p}) => 'Обновить версию ${p}';
	@override String get autoDownloadPkg => 'Автоматически загружать пакеты обновлений';
	@override String get devOptions => 'Параметры разработчика';
	@override String get about => 'О приложении';
	@override String get name => 'Название';
	@override String get version => 'Версия';
	@override String get sort => 'Отсортировать';
	@override String get share => 'Поделиться';
	@override String get importFromClipboard => 'Импорт из буфера обмена';
	@override String get exportToClipboard => 'Экспорт в буфер обмена';
	@override String get server => 'Сервер';
	@override String get port => 'Порт';
	@override String get donate => 'Пожертвовать';
	@override String get setting => 'Настройки';
	@override String get settingCore => 'Настройки ядра';
	@override String get settingApp => 'Настройки приложения';
	@override String get coreOverwrite => 'Переопределение ядра';
	@override String get iCloud => 'iCloud';
	@override String get webdav => 'Webdav';
	@override String get lanSync => 'Синхронизация по локальной сети';
	@override String get lanSyncNotQuitTips => 'Не выходите из этого окна до завершения синхронизации.';
	@override String get deviceNoSpace => 'Недостаточно места на диске';
	@override String get hideSystemApp => 'Скрыть системные приложения';
	@override String get hideAppIcon => 'Скрыть значок приложения';
	@override String get openDir => 'Открыть каталог файлов';
	@override String get type => 'Тип';
	@override String fileNotExist({required Object p}) => 'Файла не существует:${p}';
	@override String get buyProfile => 'Купить профиль';
	@override String get myProfiles => 'Профили';
	@override String get profileEdit => 'Редактирование профилей';
	@override String get profileNeedActive => 'Сначала сделайте этот профиль текущим, затем включите подключение/переподключитесь';
	@override String profileUrlOrContent({required Object p}) => 'Ссылка на профиль ${p}';
	@override String get tabHome => 'Главная';
	@override String get tabNodes => 'Узлы';
	@override String get tabPlans => 'Тарифы';
	@override String get tabMe => 'Профиль';
}

// Path: permission
class _Translations$permission$ru implements Translations$permission$en {
	_Translations$permission$ru._(this._root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get camera => 'Камера';
	@override String get screen => 'Запись экрана';
	@override String get appQuery => 'Получить список приложений';
	@override String request({required Object p}) => 'Включить разрешения [${p}]';
	@override String requestNeed({required Object p}) => 'Пожалуйста, включите разрешение [${p}]';
}

// Path: tls
class _Translations$tls$ru implements Translations$tls$en {
	_Translations$tls$ru._(this._root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get certificate => 'Сертификат';
	@override String get privateKey => 'Закрытый ключ';
	@override String get customTrustCert => 'Индивидуальные сертификаты';
}

// Path: tun
class _Translations$tun$ru implements Translations$tun$en {
	_Translations$tun$ru._(this._root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get stack => 'Сетевой стек';
	@override String get inet4Address => 'Диапазон IPv4-адресов';
	@override String get dnsHijack => 'Перехват DNS';
	@override String get strictRoute => 'Строгая маршрутизация';
	@override String get tunDefaultRoute => 'Маршрут по умолчанию';
	@override String get icmpForward => 'Пересылка ICMP';
	@override String get allowBypass => 'Разрешить приложениям обходить VPN';
	@override String get appendHttpProxy => 'Подключите HTTP-прокси к VPN';
	@override String get bypassHttpProxyDomain => 'Домены, которым разрешено обходить HTTP-прокси';
}

// Path: dns
class _Translations$dns$ru implements Translations$dns$en {
	_Translations$dns$ru._(this._root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get listen => 'Аудиторское обращение';
	@override String get fakeIp => 'fake-ip';
	@override String get fallback => 'Fallback';
	@override String get preferH3 => 'Приоритет DoH H3';
	@override String get useHosts => 'Использование хостов';
	@override String get useSystemHosts => 'Использование системных хостов';
	@override String get enhancedMode => 'Расширенный режим';
	@override String get fakeIPFilterMode => '${_root.dns.fakeIp} режим фильтра';
	@override String get fakeIPFilter => '${_root.dns.fakeIp} фильтрация';
	@override String get respectRules => 'Соблюдайте правила.';
	@override String get nameServer => 'DNS-сервер';
	@override String get defaultNameServer => '${_root.meta.byDefault} ${_root.dns.nameServer}';
	@override String get proxyNameServer => '${_root.meta.proxy} ${_root.dns.nameServer}';
	@override String get directNameServer => '${_root.meta.direct} ${_root.dns.nameServer}';
	@override String get fallbackNameServer => '${_root.dns.fallback} ${_root.dns.nameServer}';
	@override String get fallbackGeoIp => '${_root.dns.fallback} GeoIp';
	@override String get fallbackGeoIpCode => '${_root.dns.fallback} GeoIpCode';
}

// Path: sniffer
class _Translations$sniffer$ru implements Translations$sniffer$en {
	_Translations$sniffer$ru._(this._root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get overrideDest => 'Переназначить';
}

// Path: profilePatchMode
class _Translations$profilePatchMode$ru implements Translations$profilePatchMode$en {
	_Translations$profilePatchMode$ru._(this._root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get currentSelected => 'Текущий сервер';
	@override String get overwrite => 'Встроенная функция переопределения';
	@override String get noOverwrite => 'Встроенный - не перезаписывается';
}

// Path: meScreen
class _Translations$meScreen$ru implements Translations$meScreen$en {
	_Translations$meScreen$ru._(this._root);

	final TranslationsRu _root; // ignore: unused_field

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
class _Translations$homeScreen$ru implements Translations$homeScreen$en {
	_Translations$homeScreen$ru._(this._root);

	final TranslationsRu _root; // ignore: unused_field

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
class _Translations$nodesScreen$ru implements Translations$nodesScreen$en {
	_Translations$nodesScreen$ru._(this._root);

	final TranslationsRu _root; // ignore: unused_field

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
class _Translations$nodeAuto$ru implements Translations$nodeAuto$en {
	_Translations$nodeAuto$ru._(this._root);

	final TranslationsRu _root; // ignore: unused_field

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
class _Translations$accountBlock$ru implements Translations$accountBlock$en {
	_Translations$accountBlock$ru._(this._root);

	final TranslationsRu _root; // ignore: unused_field

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
class _Translations$entitlementMsg$ru implements Translations$entitlementMsg$en {
	_Translations$entitlementMsg$ru._(this._root);

	final TranslationsRu _root; // ignore: unused_field

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
class _Translations$devicesScreen$ru implements Translations$devicesScreen$en {
	_Translations$devicesScreen$ru._(this._root);

	final TranslationsRu _root; // ignore: unused_field

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
class _Translations$sysProxySheet$ru implements Translations$sysProxySheet$en {
	_Translations$sysProxySheet$ru._(this._root);

	final TranslationsRu _root; // ignore: unused_field

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
class _Translations$logScreen$ru implements Translations$logScreen$en {
	_Translations$logScreen$ru._(this._root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String readAppFailed({required Object e}) => 'Failed to read the app log: ${e}';
	@override String readCoreFailed({required Object e}) => 'Failed to read the kernel log: ${e}';
	@override String get copied => 'Copied (subscription URLs and other secrets are masked; the log file itself may still contain the raw address)';
	@override String get copy => 'Copy';
	@override String get refresh => 'Refresh';
	@override String get empty => 'No content';
}

// Path: trayShell
class _Translations$trayShell$ru implements Translations$trayShell$en {
	_Translations$trayShell$ru._(this._root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get closeTitle => 'Close window';
	@override String get closeBody => 'Closing the window just puts Mclash in the tray — the kernel and system proxy keep working, and your network stays connected.\n\n· OK: minimize to the tray (to quit completely, right-click the tray icon → Quit)\n· Cancel: quit Mclash completely, stop the kernel and restore the system proxy\n\n(Your choice is remembered; next time you can use the tray icon directly)';
}

// Path: main.tray
class _Translations$main$tray$ru implements Translations$main$tray$en {
	_Translations$main$tray$ru._(this._root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get menuOpen => 'Открыть';
	@override String get menuExit => 'Выйти';
}

/// The flat map containing all translations for locale <ru>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on TranslationsRu {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'BackupAndSyncWebdavScreen.webdavServerUrl' => 'Адрес сервера',
			'BackupAndSyncWebdavScreen.webdavRequired' => 'Не может быть пустым',
			'BackupAndSyncWebdavScreen.webdavLoginFailed' => 'Ошибка входа:',
			'BackupAndSyncWebdavScreen.webdavListFailed' => 'Не удалось получить список файлов:',
			'LaunchFailedScreen.invalidProcess' => 'Не удалось запустить приложение [Неверное имя процесса], переустановите приложение в отдельную папку',
			'LaunchFailedScreen.invalidProfile' => 'Не удалось запустить приложение [Не удалось получить доступ к профилю], переустановите приложение',
			'LaunchFailedScreen.invalidVersion' => 'Не удалось запустить приложение [Неверная версия], переустановите приложение',
			'LaunchFailedScreen.systemVersionLow' => 'Не удалось запустить приложение [Слишком низкая версия системы]',
			'LaunchFailedScreen.invalidInstallPath' => 'Путь установки недействителен, переустановите его по допустимому пути',
			'PerAppAndroidScreen.title' => 'Проксируемые приложения',
			'PerAppAndroidScreen.whiteListMode' => 'Режим белого списка',
			'PerAppAndroidScreen.whiteListModeTip' => 'Если включено: перенаправляются через прокси-сервер только те приложения, которые были отмечены. Если выключено: перенаправляются через прокси-сервер только те приложения, которые не были отмечены.',
			'UserAgreementScreen.privacyFirst' => 'Ваша конфиденциальность превыше всего',
			'UserAgreementScreen.agreeAndContinue' => 'Принять и продолжить',
			'NetCheckScreen.enterDomain' => 'Введите доменное имя',
			'NetCheckScreen.checking' => 'Проверка...',
			'NetCheckScreen.aQueryFailed' => ({required Object p}) => 'Ошибка запроса A: ${p}',
			'NetCheckScreen.aaaaQueryFailed' => ({required Object p}) => 'Ошибка запроса AAAA: ${p}',
			'NetCheckScreen.success' => 'Успех',
			'NetCheckScreen.failed' => 'Ошибка',
			'NetCheckScreen.suspectedPollution' => 'Подозрение на DNS-отравление',
			'NetCheckScreen.domainLabel' => 'Домен',
			'NetCheckScreen.checkButton' => 'Проверить',
			'NetCheckScreen.dnsSection' => '1. DNS-запрос',
			'NetCheckScreen.directHttpSection' => '2. HTTP (через TUN, сначала включите TUN)',
			'NetCheckScreen.proxyHttpSection' => ({required Object p}) => '3. HTTP (через прокси, порт: ${p})',
			'NetCheckScreen.tunNotEnabled' => 'TUN не включён',
			'NetCheckScreen.routeTableSection' => '4. Таблица маршрутов',
			'VersionUpdateScreen.versionReady' => ({required Object p}) => 'Новая версия [${p}] доступна',
			'VersionUpdateScreen.update' => 'Перезапустить',
			'VersionUpdateScreen.cancel' => 'Не сейчас',
			'loginScreen.login' => 'Вход',
			'loginScreen.register' => 'Зарегистрировать аккаунт',
			'loginScreen.forgotPassword' => 'Забыли пароль',
			'loginScreen.provider' => 'Провайдер',
			'loginScreen.providerName' => 'Код/алиас/URL ${_root.loginScreen.provider}',
			'loginScreen.account' => 'Аккаунт',
			'loginScreen.email' => 'Электронная почта',
			'loginScreen.password' => 'Пароль',
			'main.tray.menuOpen' => 'Открыть',
			'main.tray.menuExit' => 'Выйти',
			'meta.enable' => 'Включить',
			'meta.disable' => 'Запретить',
			'meta.open' => 'Открыть',
			'meta.close' => 'Закрыть',
			'meta.quit' => 'Выйти',
			'meta.add' => 'Добавить',
			'meta.remove' => 'Удалить',
			'meta.removeConfirm' => 'Подтверждаете удаление?',
			'meta.edit' => 'Редактировать',
			'meta.view' => 'Просмотр',
			'meta.remark' => 'Примечание',
			'meta.byDefault' => 'по умолчанию',
			'meta.more' => 'Больше',
			'meta.tips' => 'Инфо',
			'meta.selectAll' => 'Выбрать все',
			'meta.copy' => 'Скопировать',
			'meta.paste' => 'Вставить',
			'meta.cut' => 'Вырезать',
			'meta.save' => 'Сохранить',
			'meta.ok' => 'Ок',
			'meta.cancel' => 'Закрыть',
			'meta.faq' => 'Часто задаваемые вопросы (FAQ)',
			'meta.doc' => 'документ',
			'meta.htmlTools' => 'HTML Toolset',
			'meta.download' => 'Скачать',
			'meta.loading' => 'Загрузка...',
			'meta.days' => 'дни',
			'meta.hours' => 'часы',
			'meta.minutes' => 'минуты',
			'meta.seconds' => 'секунды',
			'meta.milliseconds' => 'миллисекунды',
			'meta.search' => 'Поиск',
			'meta.searchNodeHint' => 'Фильтр узлов (имя или протокол)',
			'meta.connect' => 'Соединить',
			'meta.disconnect' => 'Отключить',
			'meta.connected' => 'Подключено',
			'meta.disconnected' => 'Отключено',
			'meta.connecting' => 'Подключение',
			'meta.connectTimeout' => 'Таймаут при соединении',
			'meta.timeout' => 'Тайм-аут',
			'meta.latencyTest' => 'Обнаружение задержки',
			'meta.networkCheck' => 'Проверка сети',
			'meta.language' => 'Язык',
			'meta.next' => 'Дальше',
			'meta.done' => 'Готово',
			'meta.apply' => 'Применить',
			'meta.refresh' => 'Обновить',
			'meta.update' => 'Обновить',
			'meta.updateInterval' => 'Интервал обновления',
			'meta.updateInterval5mTips' => 'Минимум: 5 м',
			'meta.updateIntervalPreferByProfile' => 'Приоритет настроек провайдера',
			'meta.updateFailed' => ({required Object p}) => 'Не удалось обновить:${p}',
			'meta.none' => 'Ничего не делать',
			'meta.reset' => 'Перезагрузить',
			'meta.authentication' => 'Авторизация',
			'meta.user' => 'Пользователь',
			'meta.account' => 'Аккаунт',
			'meta.password' => 'Пароль',
			'meta.decryptPassword' => 'Пароль расшифровки',
			'meta.required' => 'Необходимо',
			'meta.go' => 'Продолжить',
			'meta.other' => 'Другой',
			'meta.dns' => 'DNS',
			'meta.url' => 'URL',
			'meta.urlInvalid' => 'Неверный URL',
			'meta.copyUrl' => 'Скопировать ссылку',
			'meta.openUrl' => 'Открыть ссылку',
			'meta.coreSettingTips' => 'Примечание: После изменения конфигурации необходимо повторно подключиться, чтобы изменения вступили в силу.',
			'meta.overwrite' => 'Переопределить',
			'meta.overwriteAppend' => 'Дополнительное переопределение',
			'meta.overwriteTips' => 'Исходная конфигурация <- Пользовательское переопределение <- Переопределение приложения',
			'meta.noOverwrite' => 'Не перезаписывать',
			'meta.diversionTemplates' => 'Шаблон сортировки пациентов',
			'meta.ruleProviders' => 'Поставщик правил',
			'meta.ruleTemplates' => 'Шаблон правила',
			'meta.proxyGroupsTemplates' => 'Шаблон группы агентов',
			'meta.proxyGroups' => 'Группа агентов',
			'meta.proxyNodeList' => 'Список прокси-узлов',
			'meta.proxyNodeFailure' => ({required Object p}) => 'Срок действия следующих прокси-узлов истек, и они были автоматически удалены: ${p}',
			'meta.externalController' => 'Внешнее управление',
			'meta.secret' => 'Пароль',
			'meta.tcpConcurrent' => 'Параллельное TCP-подтверждение',
			'meta.globalClientFingerprint' => 'Глобальный отпечаток пальца TLS',
			'meta.allowLanAccess' => 'Доступ к локальной сети устройства',
			'meta.mixedPort' => 'Порт mixed-прокси',
			'meta.logLevel' => 'Уровень журнала',
			'meta.findProcessMode' => 'Режим поиска процесса',
			'meta.tcpkeepAliveInterval' => 'Интервал проверки активности TCP',
			'meta.delayTestUrl' => 'URL-адрес теста задержки',
			'meta.delayTestTimeout' => 'Время ожидания теста задержки (мс)',
			'meta.tun' => 'TUN',
			'meta.ntp' => 'NTP',
			'meta.tls' => 'TLS',
			'meta.geoDownloadByProxy' => 'Загрузка гео-правил через прокси',
			'meta.geoRulesetTips' => 'Geosite/Geoip будет преобразован в соответствующий RuleSet',
			'meta.sniffer' => 'Обнаружение доменов',
			'meta.userAgent' => 'UserAgent',
			'meta.launchAtStartup' => 'Запуск при включении',
			'meta.launchAtStartupRunAsAdmin' => 'Пожалуйста, перезапустите Mclash от имени администратора.',
			'meta.tunModeRunAsAdmin' => 'Для режима TUN требуются права администратора. Перезапустите приложение от имени администратора',
			'meta.portableMode' => 'Портативный режим',
			'meta.portableModeDisableTips' => 'Если вам нужно выйти из портативного режима, выйдите из [mclash] и вручную удалите папку [portable] в том же каталоге, что и [mclash.exe]',
			'meta.autoConnectAfterLaunch' => 'Автоматическое подключение после запуска',
			'meta.autoConnectAtBoot' => 'Автоматическое подключение после запуска системы',
			'meta.autoConnectAtBootTips' => 'Требуется поддержка системы; некоторые системы также могут потребовать включения [автозапуска].',
			'meta.hideAfterLaunch' => 'Скрыть окно после запуска',
			'meta.autoSetSystemProxy' => 'Установить системный прокси после подключения',
			'meta.bypassSystemProxy' => 'Доменные имена, которым разрешено обходить системный прокси-сервер',
			'meta.excludeFromRecent' => 'Скрыть из недавних задач',
			'meta.wakeLock' => 'Блокировка пробуждения',
			'meta.hideDockIcon' => 'Скрыть значок дока',
			'meta.showTrayTraffic' => 'Показывать трафик в трее',
			'meta.website' => 'Веб-сайт',
			'meta.rule' => 'Правила',
			'meta.global' => 'Глобально',
			'meta.direct' => 'Напрямую',
			'meta.qrcode' => 'QR-код',
			'meta.qrcodeTooLong' => 'Слишком большой текст для отображения',
			'meta.qrcodeShare' => 'Поделиться QR-кодом',
			'meta.qrcodeScan' => 'Сканировать QR-код',
			'meta.qrcodeScanResult' => 'Результат сканирования',
			'meta.backupAndSync' => 'Резервное копирование и синхронизация',
			'meta.export' => 'Экспорт',
			'meta.send' => 'Передать',
			'meta.sendConfirm' => 'Подтверждаете передачу?',
			'meta.log' => 'Журнал',
			'meta.coreLog' => 'Журнал ядра',
			'meta.appLog' => 'Журнал приложения',
			'meta.core' => 'Ядро',
			'meta.help' => 'Помощь',
			'meta.tutorial' => 'Руководство',
			'meta.board' => 'Панель',
			'meta.boardOnline' => 'Использование онлайн-панели',
			'meta.boardOnlineUrl' => 'URL-адрес онлайн-панели',
			'meta.boardLocalPort' => 'Порт локальной панели',
			'meta.alwayOnVPN' => 'VPN всегда включен',
			'meta.disableFontScaler' => 'Отключить масштабирование шрифта',
			'meta.autoOrientation' => 'Следовать за поворотом экрана',
			'meta.restartTakesEffect' => 'Требуется перезапуск',
			'meta.reconnectTakesEffect' => 'Изменения вступят в силу после повторного подключения.',
			'meta.runtimeProfile' => 'Конфигурация времени выполнения',
			'meta.willCompleteAfterRebootInstall' => 'Пожалуйста, перезагрузите устройство, чтобы завершить установку расширения системы.',
			'meta.requestNeedsUserApproval' => '1. Пожалуйста, [разрешите] Mclash устанавливать системные расширения в [Системные настройки] - [Конфиденциальность и безопасность]. 2. : [Системные настройки] - [Основные] - [Элементы входа и расширения - Сетевые расширения] Включите [mclashServiceSE]. После завершения подключитесь снова.',
			'meta.FullDiskAccessPermissionRequired' => 'Включите разрешение mclashServiceSE в [Системные настройки]-[Конфиденциальность и безопасность]-[Полный доступ к диску] и переподключитесь.',
			'meta.proxy' => 'Прокси',
			'meta.theme' => 'Тема',
			'meta.tvMode' => 'Режим ТВ',
			'meta.autoUpdate' => 'Автоматические обновления',
			'meta.updateChannel' => 'Канал автоматического обновления',
			'meta.hasNewVersion' => ({required Object p}) => 'Обновить версию ${p}',
			'meta.autoDownloadPkg' => 'Автоматически загружать пакеты обновлений',
			'meta.devOptions' => 'Параметры разработчика',
			'meta.about' => 'О приложении',
			'meta.name' => 'Название',
			'meta.version' => 'Версия',
			'meta.sort' => 'Отсортировать',
			'meta.share' => 'Поделиться',
			'meta.importFromClipboard' => 'Импорт из буфера обмена',
			'meta.exportToClipboard' => 'Экспорт в буфер обмена',
			'meta.server' => 'Сервер',
			'meta.port' => 'Порт',
			'meta.donate' => 'Пожертвовать',
			'meta.setting' => 'Настройки',
			'meta.settingCore' => 'Настройки ядра',
			'meta.settingApp' => 'Настройки приложения',
			'meta.coreOverwrite' => 'Переопределение ядра',
			'meta.iCloud' => 'iCloud',
			'meta.webdav' => 'Webdav',
			'meta.lanSync' => 'Синхронизация по локальной сети',
			'meta.lanSyncNotQuitTips' => 'Не выходите из этого окна до завершения синхронизации.',
			'meta.deviceNoSpace' => 'Недостаточно места на диске',
			'meta.hideSystemApp' => 'Скрыть системные приложения',
			'meta.hideAppIcon' => 'Скрыть значок приложения',
			'meta.openDir' => 'Открыть каталог файлов',
			'meta.type' => 'Тип',
			'meta.fileNotExist' => ({required Object p}) => 'Файла не существует:${p}',
			'meta.buyProfile' => 'Купить профиль',
			'meta.myProfiles' => 'Профили',
			'meta.profileEdit' => 'Редактирование профилей',
			'meta.profileNeedActive' => 'Сначала сделайте этот профиль текущим, затем включите подключение/переподключитесь',
			'meta.profileUrlOrContent' => ({required Object p}) => 'Ссылка на профиль ${p}',
			'meta.tabHome' => 'Главная',
			'meta.tabNodes' => 'Узлы',
			'meta.tabPlans' => 'Тарифы',
			'meta.tabMe' => 'Профиль',
			'permission.camera' => 'Камера',
			'permission.screen' => 'Запись экрана',
			'permission.appQuery' => 'Получить список приложений',
			'permission.request' => ({required Object p}) => 'Включить разрешения [${p}]',
			'permission.requestNeed' => ({required Object p}) => 'Пожалуйста, включите разрешение [${p}]',
			'tls.certificate' => 'Сертификат',
			'tls.privateKey' => 'Закрытый ключ',
			'tls.customTrustCert' => 'Индивидуальные сертификаты',
			'tun.stack' => 'Сетевой стек',
			'tun.inet4Address' => 'Диапазон IPv4-адресов',
			'tun.dnsHijack' => 'Перехват DNS',
			'tun.strictRoute' => 'Строгая маршрутизация',
			'tun.tunDefaultRoute' => 'Маршрут по умолчанию',
			'tun.icmpForward' => 'Пересылка ICMP',
			'tun.allowBypass' => 'Разрешить приложениям обходить VPN',
			'tun.appendHttpProxy' => 'Подключите HTTP-прокси к VPN',
			'tun.bypassHttpProxyDomain' => 'Домены, которым разрешено обходить HTTP-прокси',
			'dns.listen' => 'Аудиторское обращение',
			'dns.fakeIp' => 'fake-ip',
			'dns.fallback' => 'Fallback',
			'dns.preferH3' => 'Приоритет DoH H3',
			'dns.useHosts' => 'Использование хостов',
			'dns.useSystemHosts' => 'Использование системных хостов',
			'dns.enhancedMode' => 'Расширенный режим',
			'dns.fakeIPFilterMode' => '${_root.dns.fakeIp} режим фильтра',
			'dns.fakeIPFilter' => '${_root.dns.fakeIp} фильтрация',
			'dns.respectRules' => 'Соблюдайте правила.',
			'dns.nameServer' => 'DNS-сервер',
			'dns.defaultNameServer' => '${_root.meta.byDefault} ${_root.dns.nameServer}',
			'dns.proxyNameServer' => '${_root.meta.proxy} ${_root.dns.nameServer}',
			'dns.directNameServer' => '${_root.meta.direct} ${_root.dns.nameServer}',
			'dns.fallbackNameServer' => '${_root.dns.fallback} ${_root.dns.nameServer}',
			'dns.fallbackGeoIp' => '${_root.dns.fallback} GeoIp',
			'dns.fallbackGeoIpCode' => '${_root.dns.fallback} GeoIpCode',
			'sniffer.overrideDest' => 'Переназначить',
			'profilePatchMode.currentSelected' => 'Текущий сервер',
			'profilePatchMode.overwrite' => 'Встроенная функция переопределения',
			'profilePatchMode.noOverwrite' => 'Встроенный - не перезаписывается',
			'sendOrReceiveNotMatch' => ({required Object p}) => 'Пожалуйста, используйте [${p}]',
			'targetConnectFailed' => ({required Object p}) => 'Не удалось подключиться к [${p}]. Убедитесь, что устройство находится в той же локальной сети.',
			'edgeRuntimeNotInstalled' => 'Среда выполнения Edge WebView2 не установлена ​​на текущем устройстве, и страница не может быть отображена. Загрузите и установите среду выполнения Edge WebView2 (x64), перезапустите приложение и повторите попытку.',
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
