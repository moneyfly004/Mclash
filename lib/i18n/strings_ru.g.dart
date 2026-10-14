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
		'HK': 'Гонконг',
		'TW': 'Тайвань',
		'MO': 'Макао',
		'CN': 'Китай',
		'JP': 'Япония',
		'KR': 'Южная Корея',
		'SG': 'Сингапур',
		'MY': 'Малайзия',
		'TH': 'Таиланд',
		'VN': 'Вьетнам',
		'PH': 'Филиппины',
		'ID': 'Индонезия',
		'KH': 'Камбоджа',
		'US': 'США',
		'CA': 'Канада',
		'MX': 'Мексика',
		'GB': 'Великобритания',
		'DE': 'Германия',
		'FR': 'Франция',
		'NL': 'Нидерланды',
		'RU': 'Россия',
		'IT': 'Италия',
		'ES': 'Испания',
		'CH': 'Швейцария',
		'SE': 'Швеция',
		'NO': 'Норвегия',
		'FI': 'Финляндия',
		'DK': 'Дания',
		'PL': 'Польша',
		'AT': 'Австрия',
		'IE': 'Ирландия',
		'UA': 'Украина',
		'TR': 'Турция',
		'PT': 'Португалия',
		'CZ': 'Чехия',
		'RO': 'Румыния',
		'BE': 'Бельгия',
		'GR': 'Греция',
		'HU': 'Венгрия',
		'IL': 'Израиль',
		'AE': 'ОАЭ',
		'SA': 'Саудовская Аравия',
		'EG': 'Египет',
		'ZA': 'ЮАР',
		'NG': 'Нигерия',
		'AU': 'Австралия',
		'NZ': 'Новая Зеландия',
		'BR': 'Бразилия',
		'AR': 'Аргентина',
		'CL': 'Чили',
		'CO': 'Колумбия',
		'IN': 'Индия',
		'PK': 'Пакистан',
		'XX': 'Другие',
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
	@override late final _Translations$ordersScreen$ru ordersScreen = _Translations$ordersScreen$ru._(_root);
	@override late final _Translations$payment$ru payment = _Translations$payment$ru._(_root);
	@override late final _Translations$planScreen$ru planScreen = _Translations$planScreen$ru._(_root);
	@override late final _Translations$authScreen$ru authScreen = _Translations$authScreen$ru._(_root);
	@override late final _Translations$updatePrompt$ru updatePrompt = _Translations$updatePrompt$ru._(_root);
	@override late final _Translations$clearData$ru clearData = _Translations$clearData$ru._(_root);
	@override late final _Translations$apiError$ru apiError = _Translations$apiError$ru._(_root);
	@override late final _Translations$subNotice$ru subNotice = _Translations$subNotice$ru._(_root);
	@override late final _Translations$settingItems$ru settingItems = _Translations$settingItems$ru._(_root);
	@override late final _Translations$tunScreen$ru tunScreen = _Translations$tunScreen$ru._(_root);
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
	@override String get disable => 'Отключить';
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
	@override String get ok => 'ОК';
	@override String get cancel => 'Отмена';
	@override String get faq => 'Часто задаваемые вопросы (FAQ)';
	@override String get doc => 'документ';
	@override String get htmlTools => 'HTML-инструменты';
	@override String get download => 'Скачать';
	@override String get loading => 'Загрузка...';
	@override String get days => 'дни';
	@override String get hours => 'часы';
	@override String get minutes => 'минуты';
	@override String get seconds => 'секунды';
	@override String get milliseconds => 'миллисекунды';
	@override String get search => 'Поиск';
	@override String get searchNodeHint => 'Фильтр узлов (имя или протокол)';
	@override String get connect => 'Подключиться';
	@override String get disconnect => 'Отключиться';
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
	@override String updateFailed({required Object p}) => 'Не удалось обновить: ${p}';
	@override String get none => 'Нет';
	@override String get reset => 'Сбросить';
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
	@override String get diversionTemplates => 'Шаблон разделения трафика';
	@override String get ruleProviders => 'Поставщик правил';
	@override String get ruleTemplates => 'Шаблон правила';
	@override String get proxyGroupsTemplates => 'Шаблон группы прокси';
	@override String get proxyGroups => 'Группа прокси';
	@override String get proxyNodeList => 'Список прокси-узлов';
	@override String proxyNodeFailure({required Object p}) => 'Срок действия следующих прокси-узлов истек, и они были автоматически удалены: ${p}';
	@override String get externalController => 'Внешнее управление';
	@override String get secret => 'Секрет';
	@override String get tcpConcurrent => 'Параллельное TCP-рукопожатие';
	@override String get globalClientFingerprint => 'Глобальный отпечаток TLS';
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
	@override String get sniffer => 'Сниффер';
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
	@override String get requestNeedsUserApproval => '1. Пожалуйста, [разрешите] Mclash устанавливать системные расширения в [Системные настройки] - [Конфиденциальность и безопасность].\n2. В [Системные настройки] - [Основные] - [Элементы входа и расширения] - [Сетевые расширения] включите [mclashServiceSE].\nПосле этого подключитесь снова.';
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
	@override String fileNotExist({required Object p}) => 'Файл не существует: ${p}';
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
	@override String get customTrustCert => 'Пользовательские сертификаты';
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
	@override String get listen => 'Адрес прослушивания';
	@override String get fakeIp => 'fake-ip';
	@override String get fallback => 'Fallback';
	@override String get preferH3 => 'Приоритет DoH H3';
	@override String get useHosts => 'Использование хостов';
	@override String get useSystemHosts => 'Использование системных хостов';
	@override String get enhancedMode => 'Расширенный режим';
	@override String get fakeIPFilterMode => '${_root.dns.fakeIp} режим фильтра';
	@override String get fakeIPFilter => '${_root.dns.fakeIp} фильтрация';
	@override String get respectRules => 'Учитывать правила';
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
	@override String get currentSelected => 'Текущий выбор';
	@override String get overwrite => 'Встроенная функция переопределения';
	@override String get noOverwrite => 'Встроенный - не перезаписывается';
}

// Path: meScreen
class _Translations$meScreen$ru implements Translations$meScreen$en {
	_Translations$meScreen$ru._(this._root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get accountBalance => 'Баланс';
	@override String get expireAt => 'Действует до';
	@override String get remainingDays => 'Осталось дней';
	@override String get deviceCount => 'Устройства';
	@override String get myOrders => 'Мои заказы';
	@override String get deviceManagement => 'Управление устройствами';
	@override String get changePassword => 'Сменить пароль';
	@override String get clearLocalData => 'Удалить локальные данные (перед удалением)';
	@override String get profileManagementDev => 'Управление профилями (для разработчика)';
	@override String get tunAdapter => 'Виртуальный адаптер TUN';
	@override String get checkUpdate => 'Проверить обновления';
	@override String get retry => 'Повторить';
	@override String get loadFailed => 'Не удалось загрузить данные аккаунта: возможно, вход устарел или нет сети.\nНажмите «Обновить» в правом верхнем углу, чтобы повторить; если снова не выйдет — войдите заново.';
	@override String get logoutConfirm => 'Выйти из аккаунта?';
	@override String get boardNoKernel => 'Панель показывает данные ядра в реальном времени (подключения, трафик, срабатывания правил).\n\nЯдро не запущено, поэтому панель будет пустой.\nНажмите «ОК», чтобы всё равно открыть её, или «Отмена», чтобы сначала подключиться на главной.';
	@override String get boardOpened => 'Панель открыта в браузере: меняйте там узлы или правила — приложение подхватит изменения примерно за 5 секунд.';
}

// Path: homeScreen
class _Translations$homeScreen$ru implements Translations$homeScreen$en {
	_Translations$homeScreen$ru._(this._root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String expiresOn({required Object date}) => 'До ${date}';
	@override String devicesText({required Object text}) => 'Устройства ${text}';
	@override String get upgrade => 'Улучшить';
	@override String get quickCountries => 'Быстрый выбор страны';
	@override String nodeCount({required Object count}) => 'Узлов: ${count}';
	@override String get autoBestTip => 'Выбрать доступный узел с наименьшей задержкой среди всех стран (автоматический режим)';
	@override String get autoBest => 'Автовыбор';
	@override String pickCountryTip({required Object label}) => 'Автоматически выбрать доступный узел с наименьшей задержкой в «${label}» и закрепить его';
	@override String get autoNoBetter => 'Уже включён автоматический режим (лучший узел не найден)';
	@override String switchedBest({required Object name}) => 'Переключено на лучший узел: ${name}';
	@override String switchedCountry({required Object country, required Object node, required Object ms}) => 'Переключено на самый быстрый узел (${country}): ${node}${ms}';
	@override String filterCountryFailed({required Object country, required Object err}) => 'Фильтр по стране: ${country}; переключение не удалось: ${err}';
	@override String deviceFullCount({required Object used, required Object limit}) => 'Сейчас устройств ${used}/${limit}\n\n';
	@override String get deviceFullUpgradeHint => 'После увеличения лимита устройств подключение восстановится сразу (рекомендуется); также можно удалить неиспользуемые устройства, чтобы освободить место.';
	@override String get later => 'Позже';
	@override String get upgradeDeviceCount => 'Увеличить лимит устройств';
	@override String get cannotConnect => 'Не удаётся подключиться';
	@override String get freshnessNever => 'Ещё не синхронизировано · нажмите, чтобы обновить';
	@override String get freshnessJustNow => 'Обновлено только что · нажмите «Устройства»';
	@override String freshnessMinutes({required Object minutes}) => '${minutes} мин назад · нажмите «Устройства»';
	@override String freshnessStale({required Object minutes}) => '${minutes} мин назад · нажмите, чтобы обновить';
	@override String get subscriptionAutoSync => 'Автосинхронизация подписки';
	@override String get connecting => 'Подключение…';
	@override String get disconnecting => 'Отключение…';
	@override String get tapToDisconnect => 'Нажмите переключатель, чтобы отключиться';
	@override String get tapToConnect => 'Нажмите переключатель, чтобы подключиться';
	@override String get currentNode => 'Текущий узел';
	@override String get noNodeSelected => 'Узел не выбран';
	@override String get switchAction => 'Сменить';
	@override String get realtimeSpeed => 'Скорость сейчас';
	@override String get totalTraffic => 'Всего трафика';
	@override String get subSyncedNotReady => 'Подписка загружена, но профиль ещё не готов. Попробуйте чуть позже.';
	@override String get noPlan => 'У этого аккаунта пока нет доступного тарифа. Сначала оформите тариф.';
	@override String get loginExpired => 'Ваш вход устарел. Войдите заново.';
	@override String get syncingWait => 'Идёт синхронизация подписки, подождите.';
	@override String syncFailedNetwork({required Object message}) => 'Не удалось синхронизировать подписку: ${message}\nПроверьте сеть и повторите.';
	@override String get syncFailed => 'Не удалось синхронизировать подписку, попробуйте позже.';
	@override String get resetProxy => 'Сбросить';
	@override String latencySuffix({required Object ms}) => ' (${ms} мс)';
}

// Path: nodesScreen
class _Translations$nodesScreen$ru implements Translations$nodesScreen$en {
	_Translations$nodesScreen$ru._(this._root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String updatedCount({required Object count}) => 'Подписка обновлена · узлов: ${count}';
	@override String updateFailed({required Object message}) => 'Не удалось обновить: ${message}';
	@override String get updateFailedNetwork => 'Не удалось обновить, проверьте сеть';
	@override String testDone({required Object ok, required Object fail}) => 'Тест скорости завершён: ${ok} доступно, ${fail} недоступно (возможно, офлайн)';
	@override String switchedTo({required Object name}) => 'Переключено на ${name}';
	@override String switchFailed({required Object message}) => 'Не удалось переключить: ${message}\n(Для смены узла нужно запущенное ядро; сначала включите переключатель на главной.)';
	@override String selectedAfterConnect({required Object name}) => 'Выбран ${name} (вступит в силу после подключения)';
	@override String get title => 'Узлы';
	@override String get searchNode => 'Поиск узлов';
	@override String get sortByLatency => 'Сортировать по задержке';
	@override String get updateSubscription => 'Обновить подписку';
	@override String get viewByGroup => 'По группам прокси';
	@override String get testAll => 'Проверить все';
	@override String get searchHint => 'Поиск: узел / страна / протокол';
	@override String get emptyNoNodes => 'Доступных узлов пока нет.\nПодписки синхронизируются автоматически; если вы только что вошли, подождите немного или нажмите «Загрузить заново» ниже.';
	@override String get emptyNoMatch => 'Подходящих узлов нет.';
	@override String get reload => 'Загрузить заново';
	@override String get currentInUse => 'Текущий (используется)';
	@override String get current => 'Текущий';
	@override String get notTested => 'Не измерено (ожидается перезагрузка ядра)';
	@override String get timeout => 'Тайм-аут';
	@override String get clear => 'Очистить';
	@override String get selectNode => 'Выбрать узел';
	@override String get emptyNoKernel => 'Доступных узлов пока нет.\nСначала включите переключатель подключения на главной.';
	@override String get openFullList => 'Открыть полный список узлов (поиск / тест скорости / группы)';
}

// Path: nodeAuto
class _Translations$nodeAuto$ru implements Translations$nodeAuto$en {
	_Translations$nodeAuto$ru._(this._root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get kernelStateUnavailable => 'Состояние узлов временно недоступно от ядра; повтор будет автоматически.';
	@override String backToFixedNode({required Object fixed}) => 'Возврат к закреплённому узлу: ${fixed}';
	@override String get noUsableNodePickOne => 'Рабочий узел не найден. Выберите его вручную в списке узлов.';
	@override String get noUsableNodeTryOne => 'Рабочий узел не найден. Попробуйте выбрать другой в списке узлов.';
	@override String autoConnectedBest({required Object bestNode, required Object bestMs}) => 'Автоматически подключено к лучшему узлу: ${bestNode} (${bestMs} мс)';
	@override String get currentNodeUnreachable => 'Текущий узел не выходит в интернет; переключаем автоматически…';
	@override String autoSwitchedToUsable({required Object target}) => 'Автоматически переключено на рабочий узел: ${target}';
	@override String newNodesReloading({required Object missing}) => '${missing} новых узлов из подписки ещё не в ядре; перезагружаем…';
	@override String get kernelReloadedRetest => 'Ядро перезагружено с новой подпиской; запустите тест скорости ещё раз.';
}

// Path: accountBlock
class _Translations$accountBlock$ru implements Translations$accountBlock$en {
	_Translations$accountBlock$ru._(this._root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String quotaFull({required Object used, required Object limit}) => 'Лимит устройств исчерпан (${used}/${limit}): это устройство всё ещё в пределах лицензии и может подключаться. Чтобы добавить ещё одно, увеличьте лимит устройств или удалите неиспользуемые.';
	@override String get banFallback => 'Ваш аккаунт заблокирован и больше не может использоваться.';
	@override String get titleExpired => 'Тариф истёк';
	@override String get titleDeviceFull => 'Достигнут лимит устройств';
	@override String get titleAccountDisabled => 'Аккаунт заблокирован';
	@override String get titlePlanDisabled => 'Тариф отключён';
	@override String get titleNoPlan => 'Тарифа пока нет';
	@override String get titleDeviceRemoved => 'Это устройство удалено';
	@override String get titleServiceUnavailable => 'Сервис временно недоступен';
	@override String get textExpired => 'Срок действия тарифа истёк. Оформите тариф, чтобы пользоваться узлами по всему миру.';
	@override String textDeviceFull({required Object used, required Object limit}) => 'Сервер определил, что устройство превышает лимит устройств тарифа (${used}/${limit}), поэтому подключение пока невозможно. Удалите неиспользуемые устройства в разделе «Профиль — Управление устройствами» или перейдите на тариф с большим числом устройств.';
	@override String get textAccountDisabled => 'Ваш аккаунт заблокирован. Если есть вопросы, обратитесь в поддержку.';
	@override String get textPlanDisabled => 'Ваш тариф отключён или находится в некорректном состоянии, поэтому подключение невозможно. Если есть вопросы, обратитесь в поддержку.';
	@override String get textNoPlan => 'Вы ещё не оформили тариф. Оформите его, чтобы пользоваться узлами по всему миру.';
	@override String get textDeviceRemoved => 'Это устройство было удалено и отключено. Войдите заново.';
	@override String get textServiceUnavailable => 'Сервис временно недоступен. Попробуйте позже; если это повторяется, сделайте скриншот и обратитесь в поддержку.';
	@override String remainingDays({required Object days}) => 'Осталось дней: ${days}';
	@override String deviceUsage({required Object used, required Object limit}) => 'Устройства ${used}/${limit}';
}

// Path: entitlementMsg
class _Translations$entitlementMsg$ru implements Translations$entitlementMsg$en {
	_Translations$entitlementMsg$ru._(this._root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get tamperedTitle => 'Нарушено состояние авторизации';
	@override String get tamperedClock => 'Обнаружен откат системных часов (или изменение локальных данных авторизации). Выйдите в сеть и пройдите проверку перед подключением.';
	@override String get tamperedLocal => 'Локальные данные авторизации повреждены или изменены. Выйдите в сеть и пройдите проверку перед подключением.';
	@override String get needVerifyTitle => 'Требуется онлайн-проверка';
	@override String get needVerifyFirst => 'Не удаётся подтвердить состояние тарифа: подключитесь к сети, войдите в аккаунт и пройдите одну проверку перед подключением.';
	@override String get needVerifyRetry => 'Не удаётся подтвердить состояние тарифа. Выйдите в сеть и повторите.';
	@override String get verifyFailedTitle => 'Не удаётся проверить состояние тарифа';
	@override String get verifyFailedText => 'Льготный период проверки истёк, а сервер недоступен. Проверьте сеть и повторите (если вы только что продлили тариф, войдите заново).';
	@override String get restrictedTitle => 'Аккаунт ограничен';
	@override String get restrictedFallback => 'Ваш аккаунт или тариф отключён, поэтому подключение невозможно.';
	@override String get expiredTitle => 'Тариф истёк';
	@override String expiredText({required Object date}) => 'Срок действия тарифа истёк ${date}. Локальный профиль подписки удалён. Продлите тариф и войдите заново, чтобы восстановить его.';
}

// Path: devicesScreen
class _Translations$devicesScreen$ru implements Translations$devicesScreen$en {
	_Translations$devicesScreen$ru._(this._root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get title => 'Управление устройствами';
	@override String get currentPlan => 'Текущий тариф';
	@override String devicesText({required Object text}) => 'Устройства ${text}';
	@override String get upgradeTitle => 'Добавить устройства / продлить срок';
	@override String get upgradeSubtitle => 'Добавьте устройства и дни вместе: одна цена, одна оплата';
	@override String get addDevices => 'Добавить устройства';
	@override String get noAddDevices => 'Без изменений';
	@override String addDevicesCount({required Object n}) => '+${n} устройств';
	@override String get addDays => 'Добавить дни';
	@override String get noExtend => 'Без продления';
	@override String addDaysCount({required Object n, required Object months}) => '+${n} дн. (${months} мес.)';
	@override String get priceFailed => 'Не удалось получить цену';
	@override String amountDue({required Object amount}) => 'К оплате ¥${amount}';
	@override String get requote => 'Пересчитать';
	@override String get goPay => 'Оплатить';
	@override String get afterUpgrade => 'После обновления: ';
	@override String afterLimit({required Object limit}) => 'лимит устройств ${limit}';
	@override String afterExpire({required Object date}) => 'до ${date}';
	@override String get pickSomething => 'Добавьте хотя бы устройства или дни';
	@override String get daysOnlyUnsupported => 'Панель пока не поддерживает «только продление срока»: укажите в поле «Добавить устройства» 1 или больше и повторите (либо обратитесь в поддержку, чтобы это включили).';
	@override String get paramsRejected => 'Параметры отклонены: выберите количество устройств и дни заново.';
	@override String get subscriptionExpired => 'Подписка истекла, поэтому обновить её нельзя. Сначала продлите или оформите тариф.';
	@override String get orderIncomplete => 'Данные заказа неполные. Нажмите «Пересчитать» и повторите.';
	@override String get orderRegenerated => 'Прежний заказ истёк; создан новый с теми же параметрами.';
	@override String get payChannelIncomplete => 'Данные заказа или платёжного канала неполные. Пересчитайте стоимость и повторите.';
	@override String get noQrCode => 'Сервер не вернул QR-код или ссылку для оплаты. Выберите другой способ оплаты или попробуйте позже.';
	@override String payStartFailed({required Object err}) => 'Не удалось начать оплату: ${err}';
	@override String get payCancelled => 'Оплата отменена; черновик заказа удалён.';
	@override String get balancePay => 'Баланс';
	@override String get noPayMethod => 'Сейчас нет доступных способов оплаты. Попробуйте позже или обратитесь в поддержку.';
	@override String balanceInsufficient({required Object balance, required Object amount}) => 'Недостаточно средств (¥${balance}, нужно ¥${amount}).\nПополнить баланс?';
	@override String get choosePayMethod => 'Выберите способ оплаты';
	@override String balanceText({required Object balance}) => 'Баланс ¥${balance}';
	@override String balanceShort({required Object balance}) => 'Баланс ¥${balance} (недостаточно, пополните)';
	@override String get unknownDevice => 'Неизвестное устройство';
	@override String get online => '● Онлайн';
	@override String get offline => '○ Офлайн';
	@override String lastActive({required Object text}) => 'Последняя активность: ${text}';
	@override String get delete => 'Удалить';
	@override String deleteConfirm({required Object name}) => 'Удалить устройство «${name}»? Оно будет сразу отключено.';
	@override String get lastActiveJustNow => 'Только что';
	@override String lastActiveMinutes({required Object minutes}) => '${minutes} мин назад';
	@override String lastActiveToday({required Object time}) => 'Сегодня ${time}';
}

// Path: sysProxySheet
class _Translations$sysProxySheet$ru implements Translations$sysProxySheet$en {
	_Translations$sysProxySheet$ru._(this._root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get reading => 'Чтение…';
	@override String get unknown => 'Неизвестно';
	@override String get kernelNotRunning => 'Ядро не запущено (сначала включите переключатель на главной)';
	@override String applied({required Object host, required Object port}) => 'Применено · ${host}:${port}';
	@override String notSet({required Object reason}) => 'Системный прокси не задан — ${reason}';
	@override String notEffective({required Object port}) => 'Не действует (в системе нет прокси, указывающего на ${port})';
	@override String readFailed({required Object err}) => 'Не удалось прочитать: ${err}';
	@override String get setRejected => 'Не удалось задать: возможно, система отклонила запись (или её перезаписала другая прокси-программа)';
	@override String get disableFailed => 'Не удалось отключить';
	@override String get portRange => 'Порт должен быть в диапазоне от 1 до 65535';
	@override String portChanged({required Object value}) => 'Порт изменён на ${value}: отключитесь и подключитесь снова, чтобы ядро слушало новый порт';
	@override String get title => 'Системный прокси';
	@override String desc({required Object host}) => 'Адрес системного прокси фиксирован: ${host} (локальная петля), а порт — это смешанный порт ядра.';
	@override String get descWindows => 'Именно это вы увидите в Windows: Параметры → Сеть и Интернет → Прокси.';
	@override String get reset => 'Задать снова';
	@override String get disable => 'Отключить системный прокси';
	@override String get diagnostics => 'Диагностика (совпадают ли значения в интерфейсе и в реестре?)';
	@override String get mixedPort => 'Смешанный порт';
	@override String get apply => 'Применить';
}

// Path: logScreen
class _Translations$logScreen$ru implements Translations$logScreen$en {
	_Translations$logScreen$ru._(this._root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String readAppFailed({required Object e}) => 'Не удалось прочитать журнал приложения: ${e}';
	@override String readCoreFailed({required Object e}) => 'Не удалось прочитать журнал ядра: ${e}';
	@override String get copied => 'Скопировано (адреса подписок и другие секреты замаскированы; сам файл журнала всё ещё может содержать исходный адрес)';
	@override String get copy => 'Копировать';
	@override String get refresh => 'Обновить';
	@override String get empty => 'Нет содержимого';
}

// Path: trayShell
class _Translations$trayShell$ru implements Translations$trayShell$en {
	_Translations$trayShell$ru._(this._root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get closeTitle => 'Закрыть окно';
	@override String get closeBody => 'Закрытие окна лишь сворачивает Mclash в трей — ядро и системный прокси продолжают работать, сеть остаётся подключённой.\n\n· ОК: свернуть в трей (чтобы выйти полностью, нажмите правой кнопкой по значку в трее → «Выйти»)\n· Отмена: полностью выйти из Mclash, остановить ядро и восстановить системный прокси\n\n(Ваш выбор запоминается; в следующий раз можно сразу пользоваться значком в трее)';
}

// Path: ordersScreen
class _Translations$ordersScreen$ru implements Translations$ordersScreen$en {
	_Translations$ordersScreen$ru._(this._root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get title => 'Мои заказы';
	@override String get orderInfoIncomplete => 'Данные заказа неполные. Потяните вниз, чтобы обновить, и повторите.';
	@override String get payChannelIncomplete => 'Данные платёжного канала неполные. Попробуйте позже.';
	@override String get noQrPayload => 'Сервер не вернул QR-код или ссылку для оплаты. Выберите другой способ оплаты или попробуйте позже.';
	@override String payStartFailed({required Object err}) => 'Не удалось начать оплату: ${err}';
	@override String get noPayMethod => 'Сейчас нет доступных способов оплаты. Попробуйте позже или обратитесь в поддержку.';
	@override String get choosePayMethod => 'Выберите способ оплаты';
	@override String amountDue({required Object amount}) => 'К оплате ¥${amount}';
	@override String get paidLabel => '● Оплачен';
	@override String get pendingLabel => '○ Не оплачен';
	@override String unknownStatus({required Object status}) => '✕ ${status}';
	@override String orderNoText({required Object orderNo}) => 'Заказ № ${orderNo}';
	@override String createdAtText({required Object createdAt}) => 'Создан ${createdAt}';
	@override String get orderCanceled => 'Заказ отменён';
	@override String cancelFailed({required Object err}) => 'Не удалось отменить: ${err}\n(Если заказ уже оплачен или отменён, потяните вниз, чтобы увидеть актуальный статус.)';
	@override String get cancelOrder => 'Отменить заказ';
	@override String get continuePay => 'Продолжить оплату';
}

// Path: payment
class _Translations$payment$ru implements Translations$payment$en {
	_Translations$payment$ru._(this._root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get balancePay => 'Оплата с баланса';
	@override String get qrPay => 'Оплата по QR-коду';
	@override String get deductFromBalance => 'Списано с баланса аккаунта';
	@override String get openedInBrowser => 'Страница оплаты открыта в браузере';
	@override String get scanWithAlipayWechat => 'Отсканируйте в Alipay или WeChat';
	@override String orderNoText({required Object orderNo}) => 'Заказ № ${orderNo}';
	@override String payFailed({required Object err}) => 'Оплата не прошла: ${err}';
	@override String get notDetected => 'Оплата не обнаружена. Продолжить можно позже в «Мои заказы».';
	@override String get charging => 'Списание…';
	@override String get processing => 'Обработка…';
	@override String get waitingPay => 'Ожидание оплаты…';
	@override String get openPageFailed => 'Не удалось открыть страницу оплаты. Нажмите кнопку ниже, чтобы повторить, или отсканируйте QR-код.';
	@override String get reopenPayPage => 'Открыть страницу оплаты снова';
	@override String get payInBrowser => 'Оплатить в браузере';
	@override String get openAlipay => 'Открыть Alipay';
	@override String get cancelOrder => 'Отменить заказ';
	@override String get confirmPay => 'Подтвердить оплату';
	@override String get retry => 'Повторить';
	@override String get paidAlready => 'Я уже оплатил';
	@override String get channelAlipay => 'Alipay';
	@override String get channelCodepayAlipay => 'Code Pay · Alipay';
	@override String get channelCodepayWechat => 'Code Pay · WeChat';
	@override String get channelCodepay => 'Code Pay';
	@override String get channelWechat => 'WeChat Pay';
	@override String get channelUsdt => 'USDT';
	@override String get channelUsdtTrc20 => 'USDT · TRC20';
	@override String get payFallback => 'Оплата';
	@override String get errCsrf => 'Учётные данные входа устарели (проверка CSRF не пройдена).\nПотяните вниз для обновления на вкладке «Профиль» или войдите заново, затем повторите.';
	@override String get errAlipayLimit => 'У оплаты Alipay «лицом к лицу» есть лимит на одну операцию (для этого продавца ¥1000), и этот заказ его превышает.\nИспользуйте «Оплату с баланса» или «Code Pay» либо обратитесь в поддержку, чтобы поднять лимит Alipay.';
	@override String get errNotSigned => 'Приложение Alipay не подключено к нужному платёжному продукту, поэтому этот канал временно недоступен.\nИспользуйте «Оплату с баланса» или «Code Pay» либо обратитесь в поддержку, чтобы его включили.';
	@override String get errOrderGone => 'Этот заказ отменён или истёк (черновики заказов действительны 30 минут).\nНажмите «Пересчитать», чтобы создать новый заказ, и оплатите.';
	@override String errNetwork({required Object err}) => 'Сеть недоступна: ${err}';
}

// Path: planScreen
class _Translations$planScreen$ru implements Translations$planScreen$en {
	_Translations$planScreen$ru._(this._root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get recommended => 'Рекомендуем';
	@override String get devices => 'Устройства';
	@override String balanceLabel({required Object amount}) => 'Баланс ¥${amount}';
	@override String get balanceInsufficient => ' (Недостаточно, сначала пополните)';
	@override String get total => 'Итого';
	@override String get payNow => 'Оплатить сейчас';
	@override String get retry => 'Повторить';
	@override String get errIncompleteOrder => 'Данные заказа или платёжного канала неполные; начать оплату невозможно.';
	@override String get payBalance => 'С баланса';
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
	@override String get payOnline => 'Онлайн-оплата';
}

// Path: authScreen
class _Translations$authScreen$ru implements Translations$authScreen$en {
	_Translations$authScreen$ru._(this._root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get saveAccountInfo => 'Сохранить данные аккаунта';
	@override String get autoLoginNextTime => 'В следующий раз входить автоматически';
	@override String get needLoginNextTime => 'В следующий раз нужно будет войти заново';
	@override String get invalidEmail => 'Введите корректный адрес эл. почты';
	@override String get enterEmailFirst => 'Сначала введите корректный адрес эл. почты';
	@override String get passwordRequired => 'Введите пароль';
	@override String get wrongCredentials => 'Неверная почта или пароль';
	@override String get requestRejected => 'Запрос отклонён. Попробуйте позже.';
	@override String get tooFrequent => 'Слишком много попыток. Попробуйте позже.';
	@override String get loginFailed => 'Не удалось войти';
	@override String get username => 'Имя пользователя';
	@override String get confirmPassword => 'Подтвердите пароль';
	@override String get inviteCode => 'Код приглашения';
	@override String get emailCode => 'Код из письма';
	@override String get getCode => 'Получить код';
	@override String get registerAndLogin => 'Зарегистрироваться и войти';
	@override String usernameMinLength({required Object min}) => 'Имя пользователя — не менее ${min} символов';
	@override String get passwordMismatch => 'Пароли не совпадают';
	@override String get emailCodeRequired => 'Введите код из письма';
	@override String get inviteCodeRequired => 'Для регистрации на этом сайте нужен код приглашения';
	@override String get codeSentCheckEmail => 'Код отправлен. Проверьте почту.';
	@override String get registerSuccess => 'Регистрация выполнена. Вы вошли в аккаунт.';
	@override String passwordHint({required Object min}) => 'Не менее ${min} символов, буквы и цифры';
	@override String passwordTooShort({required Object min}) => 'Пароль — не менее ${min} символов';
	@override String get passwordNeedsLetterAndDigit => 'Пароль должен содержать буквы и цифры';
	@override String get registeredEmail => 'Почта регистрации';
	@override String get newPassword => 'Новый пароль';
	@override String get confirmNewPassword => 'Подтвердите новый пароль';
	@override String get resetPassword => 'Сбросить пароль';
	@override String get resetCodeSent => 'Если эта почта зарегистрирована, код для сброса отправлен (действует 15 минут).';
	@override String get resetSuccess => 'Пароль сброшен. Войдите с новым паролем.';
	@override String get changePasswordTitle => 'Смена пароля';
	@override String get currentPassword => 'Текущий пароль';
	@override String get saveNewPassword => 'Сохранить новый пароль';
	@override String get newPasswordMismatch => 'Новые пароли не совпадают';
	@override String get changePasswordSuccess => 'Пароль изменён. Войдите заново.';
}

// Path: updatePrompt
class _Translations$updatePrompt$ru implements Translations$updatePrompt$en {
	_Translations$updatePrompt$ru._(this._root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get checking => 'Проверка обновлений…';
	@override String get checkFailed => 'Не удалось проверить обновления. Проверьте сеть и повторите.';
	@override String alreadyLatest({required Object version}) => 'У вас последняя версия (${version}).';
	@override String newVersionFound({required Object version}) => 'Доступна новая версия ${version}';
	@override String get installerDownloaded => 'Установщик загружен в фоне. Нажмите «Обновить сейчас», чтобы завершить обновление.';
	@override String get downloadInBackground => 'Нажмите «Обновить сейчас», чтобы скачать и установить обновление (приложением можно пользоваться дальше: установщик загружается в фоне).';
	@override String get later => 'Позже';
	@override String get updateNow => 'Обновить сейчас';
	@override String installerNotReady({required Object version}) => 'Установщик ещё не загружен.\n\nНажмите «ОК», чтобы открыть страницу загрузки и вручную скачать установщик для вашего устройства (версия ${version}).';
}

// Path: clearData
class _Translations$clearData$ru implements Translations$clearData$en {
	_Translations$clearData$ru._(this._root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get itemLoginSession => 'Сеанс входа';
	@override String get itemProfiles => 'Профили подписки (profiles/)';
	@override String get itemSettings => 'Настройки приложения и ядра';
	@override String get itemLatencyCache => 'Кэш задержек узлов';
	@override String get itemLogs => 'Журналы работы';
	@override String get itemRoutingData => 'Данные маршрутизации и временные файлы';
	@override String confirmBody({required Object items, required Object dir}) => 'Следующие данные, сохранённые на этом устройстве, будут удалены (отменить это нельзя):\n\n${items}\n\nСам аккаунт и купленный тариф хранятся на сервере и не затрагиваются; войдите заново, чтобы восстановить подписку.\n\nКаталог данных: ${dir}\n(Сделайте это перед удалением приложения: только тогда после переустановки всё будет с чистого листа и потребуется войти заново)';
	@override String get confirmAgain => 'Очистить сейчас? После этого нужно будет войти заново.';
	@override String clearedNotice({required Object count, required Object dir}) => 'Очищено локальных данных: ${count} (включая сеанс входа, поэтому при следующем запуске нужно будет войти заново).\n\nТеперь можно удалить приложение, чтобы завершить удаление:\n· macOS: перетащите Mclash.app в Корзину (каталог данных очищен: ${dir})\n· Windows: удалите Mclash через Панель управления и выберите «Нет», когда мастер спросит, сохранять ли пользовательские данные';
	@override String clearFailed({required Object error}) => 'Не удалось очистить: ${error}';
}

// Path: apiError
class _Translations$apiError$ru implements Translations$apiError$en {
	_Translations$apiError$ru._(this._root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String requestFailedHttp({required Object status, required Object domain}) => 'Запрос не выполнен (HTTP ${status}); уже пробовали: ${domain}';
	@override String allDomainsFailed({required Object method, required Object path, required Object count}) => 'Запрос не выполнен: ${method} ${path} (пробовали домены: ${count})';
	@override String requestTimeout({required Object seconds, required Object method, required Object path}) => 'Истекло время ожидания запроса (${seconds} с): ${method} ${path}';
	@override String networkUnreachable({required Object detail}) => 'Сеть недоступна: ${detail}';
	@override String get tlsHandshakeFailed => 'Сбой TLS-рукопожатия. Проверьте подключение к сети или системное время.';
	@override String connectionFailed({required Object detail}) => 'Не удалось подключиться: ${detail}';
	@override String requestError({required Object error}) => 'Запрос не выполнен: ${error}';
	@override String responseReadTimeout({required Object seconds, required Object method, required Object path}) => 'Истекло время ожидания ответа (${seconds} с): ${method} ${path}';
	@override String notJson({required Object status, required Object snippet}) => 'Ответ не является JSON (HTTP ${status}): ${snippet}';
	@override String badStructure({required Object status}) => 'Неожиданная структура ответа (HTTP ${status})';
	@override String loginFailed({required Object code}) => 'Не удалось войти (код ${code})';
	@override String get loginMissingData => 'В ответе на вход отсутствует data';
	@override String get loginMissingToken => 'В ответе на вход отсутствует access_token';
	@override String registerFailed({required Object code}) => 'Не удалось зарегистрироваться (код ${code})';
	@override String get registerMissingToken => 'В ответе на регистрацию нет access_token — возможно, сработала система контроля рисков или сайт настроен иначе';
	@override String requestFailedCode({required Object code}) => 'Запрос не выполнен (код ${code})';
}

// Path: subNotice
class _Translations$subNotice$ru implements Translations$subNotice$en {
	_Translations$subNotice$ru._(this._root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get titleNotFound => 'Подписка не найдена';
	@override String get titleExpired => 'Подписка истекла';
	@override String get titleInactive => 'Подписка неактивна';
	@override String get titleDeviceOverLimit => 'Превышен лимит устройств';
	@override String get titleUnavailable => 'Подписка недоступна';
	@override String titleWithReason({required Object emoji, required Object title, required Object reason}) => '${emoji} ${title} (${reason})';
	@override String deviceUsedOfLimit({required Object used, required Object limit}) => 'Сейчас устройств ${used}/${limit}';
	@override String deviceUsedOnly({required Object used}) => 'Сейчас устройств ${used}';
	@override String expireAt({required Object expire}) => 'Действует до ${expire}';
	@override String supportLine({required Object account}) => '💬 Поддержка: ${account}';
	@override String siteLine({required Object url}) => '📢 Сайт: ${url}';
}

// Path: settingItems
class _Translations$settingItems$ru implements Translations$settingItems$en {
	_Translations$settingItems$ru._(this._root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get subscriptionAutoUpdateInterval => 'Интервал автообновления подписки';
	@override String get speedTestMode => 'Способ теста скорости';
	@override String get speedTestModeTcp => 'Тест скорости TCP';
	@override String get speedTestModeKernel => 'Тест скорости ядра';
	@override String get delayTestUrlTip => 'Время одного полного HTTP-запроса через этот узел (это не ping)\nПо умолчанию — пустой ответ http 204; с https добавится TLS-рукопожатие, и число будет больше';
	@override String get systemProxy => 'Системный прокси';
	@override String get systemProxyTip => 'Просмотр и сброс адреса и порта';
	@override String get tunMode => 'Режим TUN';
	@override String get tunModeTip => 'off = только системный прокси / auto = TUN + системный прокси / force = только TUN\nНа десктопе для TUN нужны права администратора (wintun в Windows / utun в macOS)';
	@override String get tunOverwriteTip => 'overwrite\nВкл. — настройки TUN на этой странице перекрывают раздел tun из профиля\nВыкл. — используется собственная конфигурация tun из профиля (приложение не вмешивается)';
	@override String tunEnableByTunMode({required Object enable}) => '${enable} (определяется режимом TUN)';
	@override String get interval30Minutes => '30 минут';
	@override String get interval1Hour => '1 час';
	@override String get interval6Hours => '6 часов';
	@override String get interval12Hours => '12 часов';
	@override String get interval24Hours => '24 часа';
	@override String get interval3Days => '3 дня';
	@override String get interval7Days => '7 дней';
	@override String get intervalNever => 'Никогда';
	@override String intervalMinutes({required Object minutes}) => '${minutes} мин';
	@override String intervalHours({required Object hours}) => '${hours} ч';
	@override String intervalDays({required Object days}) => '${days} дн.';
}

// Path: tunScreen
class _Translations$tunScreen$ru implements Translations$tunScreen$en {
	_Translations$tunScreen$ru._(this._root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get modeOff => 'Выкл.';
	@override String get modeAuto => 'Авто';
	@override String get modeForce => 'Принудительно';
	@override String get modeOffDesc => 'Только системный прокси: работает для программ, которые соблюдают системный прокси (браузеры и т. п.); UDP и игры не проксируются';
	@override String get modeAutoDesc => 'TUN + системный прокси (двойная страховка): весь трафик идёт через виртуальный адаптер, включая UDP';
	@override String get modeForceDesc => 'Только TUN: весь трафик идёт через виртуальный адаптер, системный прокси не трогается';
	@override String get modeOffOptionDesc => 'Не изменяет системную таблицу маршрутизации; лишь задаёт в системе прокси 127.0.0.1. Через него идут только программы, соблюдающие системный прокси; UDP-трафик и программы с собственными настройками прокси — нет.';
	@override String get modeAutoOptionDesc => 'Создаёт виртуальный адаптер и забирает весь трафик (включая UDP и игры); системный прокси остаётся как запасной вариант. Рекомендуется: работает глобально, и при нехватке прав вы не останетесь без сети.';
	@override String get modeForceOptionDesc => 'Использует только виртуальный адаптер и больше не меняет системный прокси. Весь трафик (включая UDP) идёт через туннель; системный пункт «прокси» остаётся как есть.';
	@override String get adminRequiredDialog => 'Виртуальный адаптер TUN требует прав администратора (wintun в Windows / utun в macOS).\n\nMclash сейчас запущен не от имени администратора, поэтому после включения TUN не заработает (в режиме «Авто» системный прокси остаётся запасным вариантом, и сеть будет доступна).\n\nОК = перезапустить Mclash от имени администратора сейчас (появится запрос UAC)\nОтмена = всё равно сохранить этот выбор (при недоступности TUN автоматически используется системный прокси)';
	@override String relaunchFailed({required Object message}) => 'Не удалось перезапустить: ${message}';
	@override String switchFailed({required Object message}) => 'Не удалось переключить режим TUN: ${message}\nПрежние настройки восстановлены.';
	@override String get setOffSnack => 'Установлено «Выкл.»: только системный прокси';
	@override String setModeSnack({required Object mode, required Object effect}) => 'Установлено «${mode}», ${effect}';
	@override String get effectReconnected => 'переподключено и уже действует';
	@override String get effectAfterConnect => 'действует после подключения';
	@override String get sheetTitle => 'Виртуальный адаптер TUN';
	@override String get advancedTitle => 'Дополнительные параметры (Настройки ядра → TUN)';
	@override String get advancedSubtitle => 'Адрес адаптера / стек / MTU / авто-маршрут / перехват DNS / overwrite';
	@override String get adminOk => 'Для TUN нужны права администратора; текущих прав достаточно (запуск от администратора в Windows / от root в macOS)';
	@override String get adminMissing => 'Для TUN нужны права администратора: Mclash запущен не от администратора, поэтому после выбора «Авто/Принудительно» TUN не заработает (в режиме «Авто» используется системный прокси, и сеть остаётся доступной)';
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
			'meta.disable' => 'Отключить',
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
			'meta.ok' => 'ОК',
			'meta.cancel' => 'Отмена',
			'meta.faq' => 'Часто задаваемые вопросы (FAQ)',
			'meta.doc' => 'документ',
			'meta.htmlTools' => 'HTML-инструменты',
			'meta.download' => 'Скачать',
			'meta.loading' => 'Загрузка...',
			'meta.days' => 'дни',
			'meta.hours' => 'часы',
			'meta.minutes' => 'минуты',
			'meta.seconds' => 'секунды',
			'meta.milliseconds' => 'миллисекунды',
			'meta.search' => 'Поиск',
			'meta.searchNodeHint' => 'Фильтр узлов (имя или протокол)',
			'meta.connect' => 'Подключиться',
			'meta.disconnect' => 'Отключиться',
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
			'meta.updateFailed' => ({required Object p}) => 'Не удалось обновить: ${p}',
			'meta.none' => 'Нет',
			'meta.reset' => 'Сбросить',
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
			'meta.diversionTemplates' => 'Шаблон разделения трафика',
			'meta.ruleProviders' => 'Поставщик правил',
			'meta.ruleTemplates' => 'Шаблон правила',
			'meta.proxyGroupsTemplates' => 'Шаблон группы прокси',
			'meta.proxyGroups' => 'Группа прокси',
			'meta.proxyNodeList' => 'Список прокси-узлов',
			'meta.proxyNodeFailure' => ({required Object p}) => 'Срок действия следующих прокси-узлов истек, и они были автоматически удалены: ${p}',
			'meta.externalController' => 'Внешнее управление',
			'meta.secret' => 'Секрет',
			'meta.tcpConcurrent' => 'Параллельное TCP-рукопожатие',
			'meta.globalClientFingerprint' => 'Глобальный отпечаток TLS',
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
			'meta.sniffer' => 'Сниффер',
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
			'meta.requestNeedsUserApproval' => '1. Пожалуйста, [разрешите] Mclash устанавливать системные расширения в [Системные настройки] - [Конфиденциальность и безопасность].\n2. В [Системные настройки] - [Основные] - [Элементы входа и расширения] - [Сетевые расширения] включите [mclashServiceSE].\nПосле этого подключитесь снова.',
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
			'meta.fileNotExist' => ({required Object p}) => 'Файл не существует: ${p}',
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
			'tls.customTrustCert' => 'Пользовательские сертификаты',
			'tun.stack' => 'Сетевой стек',
			'tun.inet4Address' => 'Диапазон IPv4-адресов',
			'tun.dnsHijack' => 'Перехват DNS',
			'tun.strictRoute' => 'Строгая маршрутизация',
			'tun.tunDefaultRoute' => 'Маршрут по умолчанию',
			'tun.icmpForward' => 'Пересылка ICMP',
			'tun.allowBypass' => 'Разрешить приложениям обходить VPN',
			'tun.appendHttpProxy' => 'Подключите HTTP-прокси к VPN',
			'tun.bypassHttpProxyDomain' => 'Домены, которым разрешено обходить HTTP-прокси',
			'dns.listen' => 'Адрес прослушивания',
			'dns.fakeIp' => 'fake-ip',
			'dns.fallback' => 'Fallback',
			'dns.preferH3' => 'Приоритет DoH H3',
			'dns.useHosts' => 'Использование хостов',
			'dns.useSystemHosts' => 'Использование системных хостов',
			'dns.enhancedMode' => 'Расширенный режим',
			'dns.fakeIPFilterMode' => '${_root.dns.fakeIp} режим фильтра',
			'dns.fakeIPFilter' => '${_root.dns.fakeIp} фильтрация',
			'dns.respectRules' => 'Учитывать правила',
			'dns.nameServer' => 'DNS-сервер',
			'dns.defaultNameServer' => '${_root.meta.byDefault} ${_root.dns.nameServer}',
			'dns.proxyNameServer' => '${_root.meta.proxy} ${_root.dns.nameServer}',
			'dns.directNameServer' => '${_root.meta.direct} ${_root.dns.nameServer}',
			'dns.fallbackNameServer' => '${_root.dns.fallback} ${_root.dns.nameServer}',
			'dns.fallbackGeoIp' => '${_root.dns.fallback} GeoIp',
			'dns.fallbackGeoIpCode' => '${_root.dns.fallback} GeoIpCode',
			'sniffer.overrideDest' => 'Переназначить',
			'profilePatchMode.currentSelected' => 'Текущий выбор',
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
			'countries.HK' => 'Гонконг',
			'countries.TW' => 'Тайвань',
			'countries.MO' => 'Макао',
			'countries.CN' => 'Китай',
			'countries.JP' => 'Япония',
			'countries.KR' => 'Южная Корея',
			'countries.SG' => 'Сингапур',
			'countries.MY' => 'Малайзия',
			'countries.TH' => 'Таиланд',
			'countries.VN' => 'Вьетнам',
			'countries.PH' => 'Филиппины',
			'countries.ID' => 'Индонезия',
			'countries.KH' => 'Камбоджа',
			'countries.US' => 'США',
			'countries.CA' => 'Канада',
			'countries.MX' => 'Мексика',
			'countries.GB' => 'Великобритания',
			'countries.DE' => 'Германия',
			'countries.FR' => 'Франция',
			'countries.NL' => 'Нидерланды',
			'countries.RU' => 'Россия',
			'countries.IT' => 'Италия',
			'countries.ES' => 'Испания',
			'countries.CH' => 'Швейцария',
			'countries.SE' => 'Швеция',
			'countries.NO' => 'Норвегия',
			'countries.FI' => 'Финляндия',
			'countries.DK' => 'Дания',
			'countries.PL' => 'Польша',
			'countries.AT' => 'Австрия',
			'countries.IE' => 'Ирландия',
			'countries.UA' => 'Украина',
			'countries.TR' => 'Турция',
			'countries.PT' => 'Португалия',
			'countries.CZ' => 'Чехия',
			'countries.RO' => 'Румыния',
			'countries.BE' => 'Бельгия',
			'countries.GR' => 'Греция',
			'countries.HU' => 'Венгрия',
			'countries.IL' => 'Израиль',
			'countries.AE' => 'ОАЭ',
			'countries.SA' => 'Саудовская Аравия',
			'countries.EG' => 'Египет',
			'countries.ZA' => 'ЮАР',
			'countries.NG' => 'Нигерия',
			'countries.AU' => 'Австралия',
			'countries.NZ' => 'Новая Зеландия',
			'countries.BR' => 'Бразилия',
			'countries.AR' => 'Аргентина',
			'countries.CL' => 'Чили',
			'countries.CO' => 'Колумбия',
			'countries.IN' => 'Индия',
			'countries.PK' => 'Пакистан',
			'countries.XX' => 'Другие',
			'meScreen.accountBalance' => 'Баланс',
			'meScreen.expireAt' => 'Действует до',
			'meScreen.remainingDays' => 'Осталось дней',
			'meScreen.deviceCount' => 'Устройства',
			'meScreen.myOrders' => 'Мои заказы',
			'meScreen.deviceManagement' => 'Управление устройствами',
			'meScreen.changePassword' => 'Сменить пароль',
			'meScreen.clearLocalData' => 'Удалить локальные данные (перед удалением)',
			'meScreen.profileManagementDev' => 'Управление профилями (для разработчика)',
			'meScreen.tunAdapter' => 'Виртуальный адаптер TUN',
			'meScreen.checkUpdate' => 'Проверить обновления',
			'meScreen.retry' => 'Повторить',
			'meScreen.loadFailed' => 'Не удалось загрузить данные аккаунта: возможно, вход устарел или нет сети.\nНажмите «Обновить» в правом верхнем углу, чтобы повторить; если снова не выйдет — войдите заново.',
			'meScreen.logoutConfirm' => 'Выйти из аккаунта?',
			'meScreen.boardNoKernel' => 'Панель показывает данные ядра в реальном времени (подключения, трафик, срабатывания правил).\n\nЯдро не запущено, поэтому панель будет пустой.\nНажмите «ОК», чтобы всё равно открыть её, или «Отмена», чтобы сначала подключиться на главной.',
			'meScreen.boardOpened' => 'Панель открыта в браузере: меняйте там узлы или правила — приложение подхватит изменения примерно за 5 секунд.',
			'homeScreen.expiresOn' => ({required Object date}) => 'До ${date}',
			'homeScreen.devicesText' => ({required Object text}) => 'Устройства ${text}',
			'homeScreen.upgrade' => 'Улучшить',
			'homeScreen.quickCountries' => 'Быстрый выбор страны',
			'homeScreen.nodeCount' => ({required Object count}) => 'Узлов: ${count}',
			'homeScreen.autoBestTip' => 'Выбрать доступный узел с наименьшей задержкой среди всех стран (автоматический режим)',
			'homeScreen.autoBest' => 'Автовыбор',
			'homeScreen.pickCountryTip' => ({required Object label}) => 'Автоматически выбрать доступный узел с наименьшей задержкой в «${label}» и закрепить его',
			'homeScreen.autoNoBetter' => 'Уже включён автоматический режим (лучший узел не найден)',
			'homeScreen.switchedBest' => ({required Object name}) => 'Переключено на лучший узел: ${name}',
			'homeScreen.switchedCountry' => ({required Object country, required Object node, required Object ms}) => 'Переключено на самый быстрый узел (${country}): ${node}${ms}',
			'homeScreen.filterCountryFailed' => ({required Object country, required Object err}) => 'Фильтр по стране: ${country}; переключение не удалось: ${err}',
			'homeScreen.deviceFullCount' => ({required Object used, required Object limit}) => 'Сейчас устройств ${used}/${limit}\n\n',
			'homeScreen.deviceFullUpgradeHint' => 'После увеличения лимита устройств подключение восстановится сразу (рекомендуется); также можно удалить неиспользуемые устройства, чтобы освободить место.',
			'homeScreen.later' => 'Позже',
			'homeScreen.upgradeDeviceCount' => 'Увеличить лимит устройств',
			'homeScreen.cannotConnect' => 'Не удаётся подключиться',
			'homeScreen.freshnessNever' => 'Ещё не синхронизировано · нажмите, чтобы обновить',
			'homeScreen.freshnessJustNow' => 'Обновлено только что · нажмите «Устройства»',
			'homeScreen.freshnessMinutes' => ({required Object minutes}) => '${minutes} мин назад · нажмите «Устройства»',
			'homeScreen.freshnessStale' => ({required Object minutes}) => '${minutes} мин назад · нажмите, чтобы обновить',
			'homeScreen.subscriptionAutoSync' => 'Автосинхронизация подписки',
			'homeScreen.connecting' => 'Подключение…',
			'homeScreen.disconnecting' => 'Отключение…',
			'homeScreen.tapToDisconnect' => 'Нажмите переключатель, чтобы отключиться',
			'homeScreen.tapToConnect' => 'Нажмите переключатель, чтобы подключиться',
			'homeScreen.currentNode' => 'Текущий узел',
			'homeScreen.noNodeSelected' => 'Узел не выбран',
			'homeScreen.switchAction' => 'Сменить',
			'homeScreen.realtimeSpeed' => 'Скорость сейчас',
			'homeScreen.totalTraffic' => 'Всего трафика',
			'homeScreen.subSyncedNotReady' => 'Подписка загружена, но профиль ещё не готов. Попробуйте чуть позже.',
			'homeScreen.noPlan' => 'У этого аккаунта пока нет доступного тарифа. Сначала оформите тариф.',
			'homeScreen.loginExpired' => 'Ваш вход устарел. Войдите заново.',
			'homeScreen.syncingWait' => 'Идёт синхронизация подписки, подождите.',
			'homeScreen.syncFailedNetwork' => ({required Object message}) => 'Не удалось синхронизировать подписку: ${message}\nПроверьте сеть и повторите.',
			'homeScreen.syncFailed' => 'Не удалось синхронизировать подписку, попробуйте позже.',
			'homeScreen.resetProxy' => 'Сбросить',
			'homeScreen.latencySuffix' => ({required Object ms}) => ' (${ms} мс)',
			'nodesScreen.updatedCount' => ({required Object count}) => 'Подписка обновлена · узлов: ${count}',
			'nodesScreen.updateFailed' => ({required Object message}) => 'Не удалось обновить: ${message}',
			'nodesScreen.updateFailedNetwork' => 'Не удалось обновить, проверьте сеть',
			'nodesScreen.testDone' => ({required Object ok, required Object fail}) => 'Тест скорости завершён: ${ok} доступно, ${fail} недоступно (возможно, офлайн)',
			'nodesScreen.switchedTo' => ({required Object name}) => 'Переключено на ${name}',
			'nodesScreen.switchFailed' => ({required Object message}) => 'Не удалось переключить: ${message}\n(Для смены узла нужно запущенное ядро; сначала включите переключатель на главной.)',
			'nodesScreen.selectedAfterConnect' => ({required Object name}) => 'Выбран ${name} (вступит в силу после подключения)',
			'nodesScreen.title' => 'Узлы',
			'nodesScreen.searchNode' => 'Поиск узлов',
			'nodesScreen.sortByLatency' => 'Сортировать по задержке',
			'nodesScreen.updateSubscription' => 'Обновить подписку',
			'nodesScreen.viewByGroup' => 'По группам прокси',
			'nodesScreen.testAll' => 'Проверить все',
			'nodesScreen.searchHint' => 'Поиск: узел / страна / протокол',
			'nodesScreen.emptyNoNodes' => 'Доступных узлов пока нет.\nПодписки синхронизируются автоматически; если вы только что вошли, подождите немного или нажмите «Загрузить заново» ниже.',
			'nodesScreen.emptyNoMatch' => 'Подходящих узлов нет.',
			'nodesScreen.reload' => 'Загрузить заново',
			'nodesScreen.currentInUse' => 'Текущий (используется)',
			'nodesScreen.current' => 'Текущий',
			'nodesScreen.notTested' => 'Не измерено (ожидается перезагрузка ядра)',
			'nodesScreen.timeout' => 'Тайм-аут',
			'nodesScreen.clear' => 'Очистить',
			'nodesScreen.selectNode' => 'Выбрать узел',
			'nodesScreen.emptyNoKernel' => 'Доступных узлов пока нет.\nСначала включите переключатель подключения на главной.',
			'nodesScreen.openFullList' => 'Открыть полный список узлов (поиск / тест скорости / группы)',
			'nodeAuto.kernelStateUnavailable' => 'Состояние узлов временно недоступно от ядра; повтор будет автоматически.',
			'nodeAuto.backToFixedNode' => ({required Object fixed}) => 'Возврат к закреплённому узлу: ${fixed}',
			'nodeAuto.noUsableNodePickOne' => 'Рабочий узел не найден. Выберите его вручную в списке узлов.',
			'nodeAuto.noUsableNodeTryOne' => 'Рабочий узел не найден. Попробуйте выбрать другой в списке узлов.',
			'nodeAuto.autoConnectedBest' => ({required Object bestNode, required Object bestMs}) => 'Автоматически подключено к лучшему узлу: ${bestNode} (${bestMs} мс)',
			'nodeAuto.currentNodeUnreachable' => 'Текущий узел не выходит в интернет; переключаем автоматически…',
			'nodeAuto.autoSwitchedToUsable' => ({required Object target}) => 'Автоматически переключено на рабочий узел: ${target}',
			'nodeAuto.newNodesReloading' => ({required Object missing}) => '${missing} новых узлов из подписки ещё не в ядре; перезагружаем…',
			'nodeAuto.kernelReloadedRetest' => 'Ядро перезагружено с новой подпиской; запустите тест скорости ещё раз.',
			'accountBlock.quotaFull' => ({required Object used, required Object limit}) => 'Лимит устройств исчерпан (${used}/${limit}): это устройство всё ещё в пределах лицензии и может подключаться. Чтобы добавить ещё одно, увеличьте лимит устройств или удалите неиспользуемые.',
			'accountBlock.banFallback' => 'Ваш аккаунт заблокирован и больше не может использоваться.',
			'accountBlock.titleExpired' => 'Тариф истёк',
			'accountBlock.titleDeviceFull' => 'Достигнут лимит устройств',
			'accountBlock.titleAccountDisabled' => 'Аккаунт заблокирован',
			'accountBlock.titlePlanDisabled' => 'Тариф отключён',
			'accountBlock.titleNoPlan' => 'Тарифа пока нет',
			'accountBlock.titleDeviceRemoved' => 'Это устройство удалено',
			'accountBlock.titleServiceUnavailable' => 'Сервис временно недоступен',
			'accountBlock.textExpired' => 'Срок действия тарифа истёк. Оформите тариф, чтобы пользоваться узлами по всему миру.',
			'accountBlock.textDeviceFull' => ({required Object used, required Object limit}) => 'Сервер определил, что устройство превышает лимит устройств тарифа (${used}/${limit}), поэтому подключение пока невозможно. Удалите неиспользуемые устройства в разделе «Профиль — Управление устройствами» или перейдите на тариф с большим числом устройств.',
			'accountBlock.textAccountDisabled' => 'Ваш аккаунт заблокирован. Если есть вопросы, обратитесь в поддержку.',
			'accountBlock.textPlanDisabled' => 'Ваш тариф отключён или находится в некорректном состоянии, поэтому подключение невозможно. Если есть вопросы, обратитесь в поддержку.',
			'accountBlock.textNoPlan' => 'Вы ещё не оформили тариф. Оформите его, чтобы пользоваться узлами по всему миру.',
			'accountBlock.textDeviceRemoved' => 'Это устройство было удалено и отключено. Войдите заново.',
			'accountBlock.textServiceUnavailable' => 'Сервис временно недоступен. Попробуйте позже; если это повторяется, сделайте скриншот и обратитесь в поддержку.',
			'accountBlock.remainingDays' => ({required Object days}) => 'Осталось дней: ${days}',
			'accountBlock.deviceUsage' => ({required Object used, required Object limit}) => 'Устройства ${used}/${limit}',
			'entitlementMsg.tamperedTitle' => 'Нарушено состояние авторизации',
			'entitlementMsg.tamperedClock' => 'Обнаружен откат системных часов (или изменение локальных данных авторизации). Выйдите в сеть и пройдите проверку перед подключением.',
			'entitlementMsg.tamperedLocal' => 'Локальные данные авторизации повреждены или изменены. Выйдите в сеть и пройдите проверку перед подключением.',
			'entitlementMsg.needVerifyTitle' => 'Требуется онлайн-проверка',
			'entitlementMsg.needVerifyFirst' => 'Не удаётся подтвердить состояние тарифа: подключитесь к сети, войдите в аккаунт и пройдите одну проверку перед подключением.',
			'entitlementMsg.needVerifyRetry' => 'Не удаётся подтвердить состояние тарифа. Выйдите в сеть и повторите.',
			'entitlementMsg.verifyFailedTitle' => 'Не удаётся проверить состояние тарифа',
			'entitlementMsg.verifyFailedText' => 'Льготный период проверки истёк, а сервер недоступен. Проверьте сеть и повторите (если вы только что продлили тариф, войдите заново).',
			'entitlementMsg.restrictedTitle' => 'Аккаунт ограничен',
			'entitlementMsg.restrictedFallback' => 'Ваш аккаунт или тариф отключён, поэтому подключение невозможно.',
			'entitlementMsg.expiredTitle' => 'Тариф истёк',
			'entitlementMsg.expiredText' => ({required Object date}) => 'Срок действия тарифа истёк ${date}. Локальный профиль подписки удалён. Продлите тариф и войдите заново, чтобы восстановить его.',
			'devicesScreen.title' => 'Управление устройствами',
			'devicesScreen.currentPlan' => 'Текущий тариф',
			'devicesScreen.devicesText' => ({required Object text}) => 'Устройства ${text}',
			'devicesScreen.upgradeTitle' => 'Добавить устройства / продлить срок',
			'devicesScreen.upgradeSubtitle' => 'Добавьте устройства и дни вместе: одна цена, одна оплата',
			'devicesScreen.addDevices' => 'Добавить устройства',
			'devicesScreen.noAddDevices' => 'Без изменений',
			'devicesScreen.addDevicesCount' => ({required Object n}) => '+${n} устройств',
			'devicesScreen.addDays' => 'Добавить дни',
			'devicesScreen.noExtend' => 'Без продления',
			'devicesScreen.addDaysCount' => ({required Object n, required Object months}) => '+${n} дн. (${months} мес.)',
			'devicesScreen.priceFailed' => 'Не удалось получить цену',
			'devicesScreen.amountDue' => ({required Object amount}) => 'К оплате ¥${amount}',
			'devicesScreen.requote' => 'Пересчитать',
			'devicesScreen.goPay' => 'Оплатить',
			'devicesScreen.afterUpgrade' => 'После обновления: ',
			'devicesScreen.afterLimit' => ({required Object limit}) => 'лимит устройств ${limit}',
			'devicesScreen.afterExpire' => ({required Object date}) => 'до ${date}',
			'devicesScreen.pickSomething' => 'Добавьте хотя бы устройства или дни',
			'devicesScreen.daysOnlyUnsupported' => 'Панель пока не поддерживает «только продление срока»: укажите в поле «Добавить устройства» 1 или больше и повторите (либо обратитесь в поддержку, чтобы это включили).',
			'devicesScreen.paramsRejected' => 'Параметры отклонены: выберите количество устройств и дни заново.',
			'devicesScreen.subscriptionExpired' => 'Подписка истекла, поэтому обновить её нельзя. Сначала продлите или оформите тариф.',
			'devicesScreen.orderIncomplete' => 'Данные заказа неполные. Нажмите «Пересчитать» и повторите.',
			'devicesScreen.orderRegenerated' => 'Прежний заказ истёк; создан новый с теми же параметрами.',
			'devicesScreen.payChannelIncomplete' => 'Данные заказа или платёжного канала неполные. Пересчитайте стоимость и повторите.',
			'devicesScreen.noQrCode' => 'Сервер не вернул QR-код или ссылку для оплаты. Выберите другой способ оплаты или попробуйте позже.',
			'devicesScreen.payStartFailed' => ({required Object err}) => 'Не удалось начать оплату: ${err}',
			'devicesScreen.payCancelled' => 'Оплата отменена; черновик заказа удалён.',
			'devicesScreen.balancePay' => 'Баланс',
			'devicesScreen.noPayMethod' => 'Сейчас нет доступных способов оплаты. Попробуйте позже или обратитесь в поддержку.',
			'devicesScreen.balanceInsufficient' => ({required Object balance, required Object amount}) => 'Недостаточно средств (¥${balance}, нужно ¥${amount}).\nПополнить баланс?',
			'devicesScreen.choosePayMethod' => 'Выберите способ оплаты',
			'devicesScreen.balanceText' => ({required Object balance}) => 'Баланс ¥${balance}',
			'devicesScreen.balanceShort' => ({required Object balance}) => 'Баланс ¥${balance} (недостаточно, пополните)',
			'devicesScreen.unknownDevice' => 'Неизвестное устройство',
			'devicesScreen.online' => '● Онлайн',
			'devicesScreen.offline' => '○ Офлайн',
			'devicesScreen.lastActive' => ({required Object text}) => 'Последняя активность: ${text}',
			'devicesScreen.delete' => 'Удалить',
			'devicesScreen.deleteConfirm' => ({required Object name}) => 'Удалить устройство «${name}»? Оно будет сразу отключено.',
			'devicesScreen.lastActiveJustNow' => 'Только что',
			'devicesScreen.lastActiveMinutes' => ({required Object minutes}) => '${minutes} мин назад',
			'devicesScreen.lastActiveToday' => ({required Object time}) => 'Сегодня ${time}',
			'sysProxySheet.reading' => 'Чтение…',
			'sysProxySheet.unknown' => 'Неизвестно',
			'sysProxySheet.kernelNotRunning' => 'Ядро не запущено (сначала включите переключатель на главной)',
			'sysProxySheet.applied' => ({required Object host, required Object port}) => 'Применено · ${host}:${port}',
			'sysProxySheet.notSet' => ({required Object reason}) => 'Системный прокси не задан — ${reason}',
			'sysProxySheet.notEffective' => ({required Object port}) => 'Не действует (в системе нет прокси, указывающего на ${port})',
			'sysProxySheet.readFailed' => ({required Object err}) => 'Не удалось прочитать: ${err}',
			'sysProxySheet.setRejected' => 'Не удалось задать: возможно, система отклонила запись (или её перезаписала другая прокси-программа)',
			'sysProxySheet.disableFailed' => 'Не удалось отключить',
			'sysProxySheet.portRange' => 'Порт должен быть в диапазоне от 1 до 65535',
			'sysProxySheet.portChanged' => ({required Object value}) => 'Порт изменён на ${value}: отключитесь и подключитесь снова, чтобы ядро слушало новый порт',
			'sysProxySheet.title' => 'Системный прокси',
			'sysProxySheet.desc' => ({required Object host}) => 'Адрес системного прокси фиксирован: ${host} (локальная петля), а порт — это смешанный порт ядра.',
			'sysProxySheet.descWindows' => 'Именно это вы увидите в Windows: Параметры → Сеть и Интернет → Прокси.',
			'sysProxySheet.reset' => 'Задать снова',
			'sysProxySheet.disable' => 'Отключить системный прокси',
			'sysProxySheet.diagnostics' => 'Диагностика (совпадают ли значения в интерфейсе и в реестре?)',
			'sysProxySheet.mixedPort' => 'Смешанный порт',
			'sysProxySheet.apply' => 'Применить',
			'logScreen.readAppFailed' => ({required Object e}) => 'Не удалось прочитать журнал приложения: ${e}',
			_ => null,
		} ?? switch (path) {
			'logScreen.readCoreFailed' => ({required Object e}) => 'Не удалось прочитать журнал ядра: ${e}',
			'logScreen.copied' => 'Скопировано (адреса подписок и другие секреты замаскированы; сам файл журнала всё ещё может содержать исходный адрес)',
			'logScreen.copy' => 'Копировать',
			'logScreen.refresh' => 'Обновить',
			'logScreen.empty' => 'Нет содержимого',
			'trayShell.closeTitle' => 'Закрыть окно',
			'trayShell.closeBody' => 'Закрытие окна лишь сворачивает Mclash в трей — ядро и системный прокси продолжают работать, сеть остаётся подключённой.\n\n· ОК: свернуть в трей (чтобы выйти полностью, нажмите правой кнопкой по значку в трее → «Выйти»)\n· Отмена: полностью выйти из Mclash, остановить ядро и восстановить системный прокси\n\n(Ваш выбор запоминается; в следующий раз можно сразу пользоваться значком в трее)',
			'ordersScreen.title' => 'Мои заказы',
			'ordersScreen.orderInfoIncomplete' => 'Данные заказа неполные. Потяните вниз, чтобы обновить, и повторите.',
			'ordersScreen.payChannelIncomplete' => 'Данные платёжного канала неполные. Попробуйте позже.',
			'ordersScreen.noQrPayload' => 'Сервер не вернул QR-код или ссылку для оплаты. Выберите другой способ оплаты или попробуйте позже.',
			'ordersScreen.payStartFailed' => ({required Object err}) => 'Не удалось начать оплату: ${err}',
			'ordersScreen.noPayMethod' => 'Сейчас нет доступных способов оплаты. Попробуйте позже или обратитесь в поддержку.',
			'ordersScreen.choosePayMethod' => 'Выберите способ оплаты',
			'ordersScreen.amountDue' => ({required Object amount}) => 'К оплате ¥${amount}',
			'ordersScreen.paidLabel' => '● Оплачен',
			'ordersScreen.pendingLabel' => '○ Не оплачен',
			'ordersScreen.unknownStatus' => ({required Object status}) => '✕ ${status}',
			'ordersScreen.orderNoText' => ({required Object orderNo}) => 'Заказ № ${orderNo}',
			'ordersScreen.createdAtText' => ({required Object createdAt}) => 'Создан ${createdAt}',
			'ordersScreen.orderCanceled' => 'Заказ отменён',
			'ordersScreen.cancelFailed' => ({required Object err}) => 'Не удалось отменить: ${err}\n(Если заказ уже оплачен или отменён, потяните вниз, чтобы увидеть актуальный статус.)',
			'ordersScreen.cancelOrder' => 'Отменить заказ',
			'ordersScreen.continuePay' => 'Продолжить оплату',
			'payment.balancePay' => 'Оплата с баланса',
			'payment.qrPay' => 'Оплата по QR-коду',
			'payment.deductFromBalance' => 'Списано с баланса аккаунта',
			'payment.openedInBrowser' => 'Страница оплаты открыта в браузере',
			'payment.scanWithAlipayWechat' => 'Отсканируйте в Alipay или WeChat',
			'payment.orderNoText' => ({required Object orderNo}) => 'Заказ № ${orderNo}',
			'payment.payFailed' => ({required Object err}) => 'Оплата не прошла: ${err}',
			'payment.notDetected' => 'Оплата не обнаружена. Продолжить можно позже в «Мои заказы».',
			'payment.charging' => 'Списание…',
			'payment.processing' => 'Обработка…',
			'payment.waitingPay' => 'Ожидание оплаты…',
			'payment.openPageFailed' => 'Не удалось открыть страницу оплаты. Нажмите кнопку ниже, чтобы повторить, или отсканируйте QR-код.',
			'payment.reopenPayPage' => 'Открыть страницу оплаты снова',
			'payment.payInBrowser' => 'Оплатить в браузере',
			'payment.openAlipay' => 'Открыть Alipay',
			'payment.cancelOrder' => 'Отменить заказ',
			'payment.confirmPay' => 'Подтвердить оплату',
			'payment.retry' => 'Повторить',
			'payment.paidAlready' => 'Я уже оплатил',
			'payment.channelAlipay' => 'Alipay',
			'payment.channelCodepayAlipay' => 'Code Pay · Alipay',
			'payment.channelCodepayWechat' => 'Code Pay · WeChat',
			'payment.channelCodepay' => 'Code Pay',
			'payment.channelWechat' => 'WeChat Pay',
			'payment.channelUsdt' => 'USDT',
			'payment.channelUsdtTrc20' => 'USDT · TRC20',
			'payment.payFallback' => 'Оплата',
			'payment.errCsrf' => 'Учётные данные входа устарели (проверка CSRF не пройдена).\nПотяните вниз для обновления на вкладке «Профиль» или войдите заново, затем повторите.',
			'payment.errAlipayLimit' => 'У оплаты Alipay «лицом к лицу» есть лимит на одну операцию (для этого продавца ¥1000), и этот заказ его превышает.\nИспользуйте «Оплату с баланса» или «Code Pay» либо обратитесь в поддержку, чтобы поднять лимит Alipay.',
			'payment.errNotSigned' => 'Приложение Alipay не подключено к нужному платёжному продукту, поэтому этот канал временно недоступен.\nИспользуйте «Оплату с баланса» или «Code Pay» либо обратитесь в поддержку, чтобы его включили.',
			'payment.errOrderGone' => 'Этот заказ отменён или истёк (черновики заказов действительны 30 минут).\nНажмите «Пересчитать», чтобы создать новый заказ, и оплатите.',
			'payment.errNetwork' => ({required Object err}) => 'Сеть недоступна: ${err}',
			'planScreen.recommended' => 'Рекомендуем',
			'planScreen.devices' => 'Устройства',
			'planScreen.balanceLabel' => ({required Object amount}) => 'Баланс ¥${amount}',
			'planScreen.balanceInsufficient' => ' (Недостаточно, сначала пополните)',
			'planScreen.total' => 'Итого',
			'planScreen.payNow' => 'Оплатить сейчас',
			'planScreen.retry' => 'Повторить',
			'planScreen.errIncompleteOrder' => 'Данные заказа или платёжного канала неполные; начать оплату невозможно.',
			'planScreen.payBalance' => 'С баланса',
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
			'planScreen.payOnline' => 'Онлайн-оплата',
			'authScreen.saveAccountInfo' => 'Сохранить данные аккаунта',
			'authScreen.autoLoginNextTime' => 'В следующий раз входить автоматически',
			'authScreen.needLoginNextTime' => 'В следующий раз нужно будет войти заново',
			'authScreen.invalidEmail' => 'Введите корректный адрес эл. почты',
			'authScreen.enterEmailFirst' => 'Сначала введите корректный адрес эл. почты',
			'authScreen.passwordRequired' => 'Введите пароль',
			'authScreen.wrongCredentials' => 'Неверная почта или пароль',
			'authScreen.requestRejected' => 'Запрос отклонён. Попробуйте позже.',
			'authScreen.tooFrequent' => 'Слишком много попыток. Попробуйте позже.',
			'authScreen.loginFailed' => 'Не удалось войти',
			'authScreen.username' => 'Имя пользователя',
			'authScreen.confirmPassword' => 'Подтвердите пароль',
			'authScreen.inviteCode' => 'Код приглашения',
			'authScreen.emailCode' => 'Код из письма',
			'authScreen.getCode' => 'Получить код',
			'authScreen.registerAndLogin' => 'Зарегистрироваться и войти',
			'authScreen.usernameMinLength' => ({required Object min}) => 'Имя пользователя — не менее ${min} символов',
			'authScreen.passwordMismatch' => 'Пароли не совпадают',
			'authScreen.emailCodeRequired' => 'Введите код из письма',
			'authScreen.inviteCodeRequired' => 'Для регистрации на этом сайте нужен код приглашения',
			'authScreen.codeSentCheckEmail' => 'Код отправлен. Проверьте почту.',
			'authScreen.registerSuccess' => 'Регистрация выполнена. Вы вошли в аккаунт.',
			'authScreen.passwordHint' => ({required Object min}) => 'Не менее ${min} символов, буквы и цифры',
			'authScreen.passwordTooShort' => ({required Object min}) => 'Пароль — не менее ${min} символов',
			'authScreen.passwordNeedsLetterAndDigit' => 'Пароль должен содержать буквы и цифры',
			'authScreen.registeredEmail' => 'Почта регистрации',
			'authScreen.newPassword' => 'Новый пароль',
			'authScreen.confirmNewPassword' => 'Подтвердите новый пароль',
			'authScreen.resetPassword' => 'Сбросить пароль',
			'authScreen.resetCodeSent' => 'Если эта почта зарегистрирована, код для сброса отправлен (действует 15 минут).',
			'authScreen.resetSuccess' => 'Пароль сброшен. Войдите с новым паролем.',
			'authScreen.changePasswordTitle' => 'Смена пароля',
			'authScreen.currentPassword' => 'Текущий пароль',
			'authScreen.saveNewPassword' => 'Сохранить новый пароль',
			'authScreen.newPasswordMismatch' => 'Новые пароли не совпадают',
			'authScreen.changePasswordSuccess' => 'Пароль изменён. Войдите заново.',
			'updatePrompt.checking' => 'Проверка обновлений…',
			'updatePrompt.checkFailed' => 'Не удалось проверить обновления. Проверьте сеть и повторите.',
			'updatePrompt.alreadyLatest' => ({required Object version}) => 'У вас последняя версия (${version}).',
			'updatePrompt.newVersionFound' => ({required Object version}) => 'Доступна новая версия ${version}',
			'updatePrompt.installerDownloaded' => 'Установщик загружен в фоне. Нажмите «Обновить сейчас», чтобы завершить обновление.',
			'updatePrompt.downloadInBackground' => 'Нажмите «Обновить сейчас», чтобы скачать и установить обновление (приложением можно пользоваться дальше: установщик загружается в фоне).',
			'updatePrompt.later' => 'Позже',
			'updatePrompt.updateNow' => 'Обновить сейчас',
			'updatePrompt.installerNotReady' => ({required Object version}) => 'Установщик ещё не загружен.\n\nНажмите «ОК», чтобы открыть страницу загрузки и вручную скачать установщик для вашего устройства (версия ${version}).',
			'clearData.itemLoginSession' => 'Сеанс входа',
			'clearData.itemProfiles' => 'Профили подписки (profiles/)',
			'clearData.itemSettings' => 'Настройки приложения и ядра',
			'clearData.itemLatencyCache' => 'Кэш задержек узлов',
			'clearData.itemLogs' => 'Журналы работы',
			'clearData.itemRoutingData' => 'Данные маршрутизации и временные файлы',
			'clearData.confirmBody' => ({required Object items, required Object dir}) => 'Следующие данные, сохранённые на этом устройстве, будут удалены (отменить это нельзя):\n\n${items}\n\nСам аккаунт и купленный тариф хранятся на сервере и не затрагиваются; войдите заново, чтобы восстановить подписку.\n\nКаталог данных: ${dir}\n(Сделайте это перед удалением приложения: только тогда после переустановки всё будет с чистого листа и потребуется войти заново)',
			'clearData.confirmAgain' => 'Очистить сейчас? После этого нужно будет войти заново.',
			'clearData.clearedNotice' => ({required Object count, required Object dir}) => 'Очищено локальных данных: ${count} (включая сеанс входа, поэтому при следующем запуске нужно будет войти заново).\n\nТеперь можно удалить приложение, чтобы завершить удаление:\n· macOS: перетащите Mclash.app в Корзину (каталог данных очищен: ${dir})\n· Windows: удалите Mclash через Панель управления и выберите «Нет», когда мастер спросит, сохранять ли пользовательские данные',
			'clearData.clearFailed' => ({required Object error}) => 'Не удалось очистить: ${error}',
			'apiError.requestFailedHttp' => ({required Object status, required Object domain}) => 'Запрос не выполнен (HTTP ${status}); уже пробовали: ${domain}',
			'apiError.allDomainsFailed' => ({required Object method, required Object path, required Object count}) => 'Запрос не выполнен: ${method} ${path} (пробовали домены: ${count})',
			'apiError.requestTimeout' => ({required Object seconds, required Object method, required Object path}) => 'Истекло время ожидания запроса (${seconds} с): ${method} ${path}',
			'apiError.networkUnreachable' => ({required Object detail}) => 'Сеть недоступна: ${detail}',
			'apiError.tlsHandshakeFailed' => 'Сбой TLS-рукопожатия. Проверьте подключение к сети или системное время.',
			'apiError.connectionFailed' => ({required Object detail}) => 'Не удалось подключиться: ${detail}',
			'apiError.requestError' => ({required Object error}) => 'Запрос не выполнен: ${error}',
			'apiError.responseReadTimeout' => ({required Object seconds, required Object method, required Object path}) => 'Истекло время ожидания ответа (${seconds} с): ${method} ${path}',
			'apiError.notJson' => ({required Object status, required Object snippet}) => 'Ответ не является JSON (HTTP ${status}): ${snippet}',
			'apiError.badStructure' => ({required Object status}) => 'Неожиданная структура ответа (HTTP ${status})',
			'apiError.loginFailed' => ({required Object code}) => 'Не удалось войти (код ${code})',
			'apiError.loginMissingData' => 'В ответе на вход отсутствует data',
			'apiError.loginMissingToken' => 'В ответе на вход отсутствует access_token',
			'apiError.registerFailed' => ({required Object code}) => 'Не удалось зарегистрироваться (код ${code})',
			'apiError.registerMissingToken' => 'В ответе на регистрацию нет access_token — возможно, сработала система контроля рисков или сайт настроен иначе',
			'apiError.requestFailedCode' => ({required Object code}) => 'Запрос не выполнен (код ${code})',
			'subNotice.titleNotFound' => 'Подписка не найдена',
			'subNotice.titleExpired' => 'Подписка истекла',
			'subNotice.titleInactive' => 'Подписка неактивна',
			'subNotice.titleDeviceOverLimit' => 'Превышен лимит устройств',
			'subNotice.titleUnavailable' => 'Подписка недоступна',
			'subNotice.titleWithReason' => ({required Object emoji, required Object title, required Object reason}) => '${emoji} ${title} (${reason})',
			'subNotice.deviceUsedOfLimit' => ({required Object used, required Object limit}) => 'Сейчас устройств ${used}/${limit}',
			'subNotice.deviceUsedOnly' => ({required Object used}) => 'Сейчас устройств ${used}',
			'subNotice.expireAt' => ({required Object expire}) => 'Действует до ${expire}',
			'subNotice.supportLine' => ({required Object account}) => '💬 Поддержка: ${account}',
			'subNotice.siteLine' => ({required Object url}) => '📢 Сайт: ${url}',
			'settingItems.subscriptionAutoUpdateInterval' => 'Интервал автообновления подписки',
			'settingItems.speedTestMode' => 'Способ теста скорости',
			'settingItems.speedTestModeTcp' => 'Тест скорости TCP',
			'settingItems.speedTestModeKernel' => 'Тест скорости ядра',
			'settingItems.delayTestUrlTip' => 'Время одного полного HTTP-запроса через этот узел (это не ping)\nПо умолчанию — пустой ответ http 204; с https добавится TLS-рукопожатие, и число будет больше',
			'settingItems.systemProxy' => 'Системный прокси',
			'settingItems.systemProxyTip' => 'Просмотр и сброс адреса и порта',
			'settingItems.tunMode' => 'Режим TUN',
			'settingItems.tunModeTip' => 'off = только системный прокси / auto = TUN + системный прокси / force = только TUN\nНа десктопе для TUN нужны права администратора (wintun в Windows / utun в macOS)',
			'settingItems.tunOverwriteTip' => 'overwrite\nВкл. — настройки TUN на этой странице перекрывают раздел tun из профиля\nВыкл. — используется собственная конфигурация tun из профиля (приложение не вмешивается)',
			'settingItems.tunEnableByTunMode' => ({required Object enable}) => '${enable} (определяется режимом TUN)',
			'settingItems.interval30Minutes' => '30 минут',
			'settingItems.interval1Hour' => '1 час',
			'settingItems.interval6Hours' => '6 часов',
			'settingItems.interval12Hours' => '12 часов',
			'settingItems.interval24Hours' => '24 часа',
			'settingItems.interval3Days' => '3 дня',
			'settingItems.interval7Days' => '7 дней',
			'settingItems.intervalNever' => 'Никогда',
			'settingItems.intervalMinutes' => ({required Object minutes}) => '${minutes} мин',
			'settingItems.intervalHours' => ({required Object hours}) => '${hours} ч',
			'settingItems.intervalDays' => ({required Object days}) => '${days} дн.',
			'tunScreen.modeOff' => 'Выкл.',
			'tunScreen.modeAuto' => 'Авто',
			'tunScreen.modeForce' => 'Принудительно',
			'tunScreen.modeOffDesc' => 'Только системный прокси: работает для программ, которые соблюдают системный прокси (браузеры и т. п.); UDP и игры не проксируются',
			'tunScreen.modeAutoDesc' => 'TUN + системный прокси (двойная страховка): весь трафик идёт через виртуальный адаптер, включая UDP',
			'tunScreen.modeForceDesc' => 'Только TUN: весь трафик идёт через виртуальный адаптер, системный прокси не трогается',
			'tunScreen.modeOffOptionDesc' => 'Не изменяет системную таблицу маршрутизации; лишь задаёт в системе прокси 127.0.0.1. Через него идут только программы, соблюдающие системный прокси; UDP-трафик и программы с собственными настройками прокси — нет.',
			'tunScreen.modeAutoOptionDesc' => 'Создаёт виртуальный адаптер и забирает весь трафик (включая UDP и игры); системный прокси остаётся как запасной вариант. Рекомендуется: работает глобально, и при нехватке прав вы не останетесь без сети.',
			'tunScreen.modeForceOptionDesc' => 'Использует только виртуальный адаптер и больше не меняет системный прокси. Весь трафик (включая UDP) идёт через туннель; системный пункт «прокси» остаётся как есть.',
			'tunScreen.adminRequiredDialog' => 'Виртуальный адаптер TUN требует прав администратора (wintun в Windows / utun в macOS).\n\nMclash сейчас запущен не от имени администратора, поэтому после включения TUN не заработает (в режиме «Авто» системный прокси остаётся запасным вариантом, и сеть будет доступна).\n\nОК = перезапустить Mclash от имени администратора сейчас (появится запрос UAC)\nОтмена = всё равно сохранить этот выбор (при недоступности TUN автоматически используется системный прокси)',
			'tunScreen.relaunchFailed' => ({required Object message}) => 'Не удалось перезапустить: ${message}',
			'tunScreen.switchFailed' => ({required Object message}) => 'Не удалось переключить режим TUN: ${message}\nПрежние настройки восстановлены.',
			'tunScreen.setOffSnack' => 'Установлено «Выкл.»: только системный прокси',
			'tunScreen.setModeSnack' => ({required Object mode, required Object effect}) => 'Установлено «${mode}», ${effect}',
			'tunScreen.effectReconnected' => 'переподключено и уже действует',
			'tunScreen.effectAfterConnect' => 'действует после подключения',
			'tunScreen.sheetTitle' => 'Виртуальный адаптер TUN',
			'tunScreen.advancedTitle' => 'Дополнительные параметры (Настройки ядра → TUN)',
			'tunScreen.advancedSubtitle' => 'Адрес адаптера / стек / MTU / авто-маршрут / перехват DNS / overwrite',
			'tunScreen.adminOk' => 'Для TUN нужны права администратора; текущих прав достаточно (запуск от администратора в Windows / от root в macOS)',
			'tunScreen.adminMissing' => 'Для TUN нужны права администратора: Mclash запущен не от администратора, поэтому после выбора «Авто/Принудительно» TUN не заработает (в режиме «Авто» используется системный прокси, и сеть остаётся доступной)',
			_ => null,
		};
	}
}
