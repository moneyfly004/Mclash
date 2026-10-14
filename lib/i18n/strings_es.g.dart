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
class TranslationsEs with BaseTranslations<AppLocale, Translations> implements Translations {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	TranslationsEs({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: AppLocale.es,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <es>.
	final TranslationMetadata<AppLocale, Translations> _meta;
	@override TranslationMetadata<AppLocale, Translations> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key);

	late final TranslationsEs _root = this; // ignore: unused_field

	@override 
	TranslationsEs $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => TranslationsEs(meta: meta ?? this.$meta);

	// Translations
	@override late final _Translations$BackupAndSyncWebdavScreen$es BackupAndSyncWebdavScreen = _Translations$BackupAndSyncWebdavScreen$es._(_root);
	@override late final _Translations$LaunchFailedScreen$es LaunchFailedScreen = _Translations$LaunchFailedScreen$es._(_root);
	@override late final _Translations$PerAppAndroidScreen$es PerAppAndroidScreen = _Translations$PerAppAndroidScreen$es._(_root);
	@override late final _Translations$UserAgreementScreen$es UserAgreementScreen = _Translations$UserAgreementScreen$es._(_root);
	@override late final _Translations$VersionUpdateScreen$es VersionUpdateScreen = _Translations$VersionUpdateScreen$es._(_root);
	@override late final _Translations$NetCheckScreen$es NetCheckScreen = _Translations$NetCheckScreen$es._(_root);
	@override late final _Translations$loginScreen$es loginScreen = _Translations$loginScreen$es._(_root);
	@override late final _Translations$main$es main = _Translations$main$es._(_root);
	@override late final _Translations$meta$es meta = _Translations$meta$es._(_root);
	@override late final _Translations$permission$es permission = _Translations$permission$es._(_root);
	@override late final _Translations$tls$es tls = _Translations$tls$es._(_root);
	@override late final _Translations$tun$es tun = _Translations$tun$es._(_root);
	@override late final _Translations$dns$es dns = _Translations$dns$es._(_root);
	@override late final _Translations$sniffer$es sniffer = _Translations$sniffer$es._(_root);
	@override late final _Translations$profilePatchMode$es profilePatchMode = _Translations$profilePatchMode$es._(_root);
	@override String sendOrReceiveNotMatch({required Object p}) => 'Utilice [${p}]';
	@override String targetConnectFailed({required Object p}) => 'Error al conectar con [${p}]. Asegúrese de que los dispositivos estén en la misma LAN';
	@override String get edgeRuntimeNotInstalled => 'El dispositivo actual no ha instalado el motor de ejecución Edge WebView2, por lo que la página no se puede mostrar. Descargue e instale el motor de ejecución Edge WebView2 (x64), reinicie la App e inténtelo de nuevo.';
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
		'TW': 'Taiwán',
		'MO': 'Macao',
		'CN': 'China',
		'JP': 'Japón',
		'KR': 'Corea del Sur',
		'SG': 'Singapur',
		'MY': 'Malasia',
		'TH': 'Tailandia',
		'VN': 'Vietnam',
		'PH': 'Filipinas',
		'ID': 'Indonesia',
		'KH': 'Camboya',
		'US': 'Estados Unidos',
		'CA': 'Canadá',
		'MX': 'México',
		'GB': 'Reino Unido',
		'DE': 'Alemania',
		'FR': 'Francia',
		'NL': 'Países Bajos',
		'RU': 'Rusia',
		'IT': 'Italia',
		'ES': 'España',
		'CH': 'Suiza',
		'SE': 'Suecia',
		'NO': 'Noruega',
		'FI': 'Finlandia',
		'DK': 'Dinamarca',
		'PL': 'Polonia',
		'AT': 'Austria',
		'IE': 'Irlanda',
		'UA': 'Ucrania',
		'TR': 'Turquía',
		'PT': 'Portugal',
		'CZ': 'Chequia',
		'RO': 'Rumanía',
		'BE': 'Bélgica',
		'GR': 'Grecia',
		'HU': 'Hungría',
		'IL': 'Israel',
		'AE': 'Emiratos Árabes Unidos',
		'SA': 'Arabia Saudí',
		'EG': 'Egipto',
		'ZA': 'Sudáfrica',
		'NG': 'Nigeria',
		'AU': 'Australia',
		'NZ': 'Nueva Zelanda',
		'BR': 'Brasil',
		'AR': 'Argentina',
		'CL': 'Chile',
		'CO': 'Colombia',
		'IN': 'India',
		'PK': 'Pakistán',
		'XX': 'Otro',
	};
	@override late final _Translations$meScreen$es meScreen = _Translations$meScreen$es._(_root);
	@override late final _Translations$homeScreen$es homeScreen = _Translations$homeScreen$es._(_root);
	@override late final _Translations$nodesScreen$es nodesScreen = _Translations$nodesScreen$es._(_root);
	@override late final _Translations$nodeAuto$es nodeAuto = _Translations$nodeAuto$es._(_root);
	@override late final _Translations$accountBlock$es accountBlock = _Translations$accountBlock$es._(_root);
	@override late final _Translations$entitlementMsg$es entitlementMsg = _Translations$entitlementMsg$es._(_root);
	@override late final _Translations$devicesScreen$es devicesScreen = _Translations$devicesScreen$es._(_root);
	@override late final _Translations$sysProxySheet$es sysProxySheet = _Translations$sysProxySheet$es._(_root);
	@override late final _Translations$logScreen$es logScreen = _Translations$logScreen$es._(_root);
	@override late final _Translations$trayShell$es trayShell = _Translations$trayShell$es._(_root);
	@override late final _Translations$ordersScreen$es ordersScreen = _Translations$ordersScreen$es._(_root);
	@override late final _Translations$payment$es payment = _Translations$payment$es._(_root);
	@override late final _Translations$planScreen$es planScreen = _Translations$planScreen$es._(_root);
	@override late final _Translations$authScreen$es authScreen = _Translations$authScreen$es._(_root);
	@override late final _Translations$updatePrompt$es updatePrompt = _Translations$updatePrompt$es._(_root);
	@override late final _Translations$clearData$es clearData = _Translations$clearData$es._(_root);
	@override late final _Translations$apiError$es apiError = _Translations$apiError$es._(_root);
	@override late final _Translations$subNotice$es subNotice = _Translations$subNotice$es._(_root);
	@override late final _Translations$settingItems$es settingItems = _Translations$settingItems$es._(_root);
	@override late final _Translations$tunScreen$es tunScreen = _Translations$tunScreen$es._(_root);
}

// Path: BackupAndSyncWebdavScreen
class _Translations$BackupAndSyncWebdavScreen$es implements Translations$BackupAndSyncWebdavScreen$en {
	_Translations$BackupAndSyncWebdavScreen$es._(this._root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get webdavServerUrl => 'URL del Servidor';
	@override String get webdavRequired => 'No puede estar vacío';
	@override String get webdavLoginFailed => 'Fallo al iniciar sesión:';
	@override String get webdavListFailed => 'Fallo al obtener la lista de archivos:';
}

// Path: LaunchFailedScreen
class _Translations$LaunchFailedScreen$es implements Translations$LaunchFailedScreen$en {
	_Translations$LaunchFailedScreen$es._(this._root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get invalidProcess => 'La aplicación no pudo iniciarse [Nombre de proceso no válido], por favor reinstale la aplicación en un directorio separado';
	@override String get invalidProfile => 'La aplicación no pudo iniciarse [Fallo al acceder al perfil], por favor reinstale la aplicación';
	@override String get invalidVersion => 'La aplicación no pudo iniciarse [Versión no válida], por favor reinstale la aplicación';
	@override String get systemVersionLow => 'La aplicación no pudo iniciarse [versión del sistema demasiado baja]';
	@override String get invalidInstallPath => 'La ruta de instalación no es válida, por favor reinstálela en una ruta válida';
}

// Path: PerAppAndroidScreen
class _Translations$PerAppAndroidScreen$es implements Translations$PerAppAndroidScreen$en {
	_Translations$PerAppAndroidScreen$es._(this._root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Proxy por Aplicación';
	@override String get whiteListMode => 'Modo Lista Blanca';
	@override String get whiteListModeTip => 'Cuando está habilitado: solo las aplicaciones marcadas son proxies; cuando no está habilitado: solo las aplicaciones no marcadas son proxies';
}

// Path: UserAgreementScreen
class _Translations$UserAgreementScreen$es implements Translations$UserAgreementScreen$en {
	_Translations$UserAgreementScreen$es._(this._root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get privacyFirst => 'Su Privacidad es lo Primero';
	@override String get agreeAndContinue => 'Aceptar y Continuar';
}

// Path: VersionUpdateScreen
class _Translations$VersionUpdateScreen$es implements Translations$VersionUpdateScreen$en {
	_Translations$VersionUpdateScreen$es._(this._root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String versionReady({required Object p}) => 'La nueva versión [${p}] está lista';
	@override String get update => 'Reiniciar para Actualizar';
	@override String get cancel => 'Ahora no';
}

// Path: NetCheckScreen
class _Translations$NetCheckScreen$es implements Translations$NetCheckScreen$en {
	_Translations$NetCheckScreen$es._(this._root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get enterDomain => 'Por favor, introduzca un dominio';
	@override String get checking => 'Comprobando...';
	@override String aQueryFailed({required Object p}) => 'Fallo en la consulta A: ${p}';
	@override String aaaaQueryFailed({required Object p}) => 'Fallo en la consulta AAAA: ${p}';
	@override String get success => 'Éxito';
	@override String get failed => 'Fallo';
	@override String get suspectedPollution => 'Sospecha de envenenamiento DNS';
	@override String get domainLabel => 'Dominio';
	@override String get checkButton => 'Comprobar';
	@override String get dnsSection => '1. Consulta DNS';
	@override String get directHttpSection => '2. HTTP (vía TUN, habilite TUN primero)';
	@override String proxyHttpSection({required Object p}) => '3. HTTP (vía Proxy, puerto: ${p})';
	@override String get tunNotEnabled => 'TUN no está habilitado';
	@override String get routeTableSection => '4. Tabla de Rutas';
}

// Path: loginScreen
class _Translations$loginScreen$es implements Translations$loginScreen$en {
	_Translations$loginScreen$es._(this._root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get login => 'Iniciar sesión';
	@override String get register => 'Registrar cuenta';
	@override String get forgotPassword => 'Olvidé mi contraseña';
	@override String get provider => 'Proveedor';
	@override String get providerName => 'Código, alias o URL del ${_root.loginScreen.provider}';
	@override String get account => 'Cuenta';
	@override String get email => 'Correo electrónico';
	@override String get password => 'Contraseña';
}

// Path: main
class _Translations$main$es implements Translations$main$en {
	_Translations$main$es._(this._root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override late final _Translations$main$tray$es tray = _Translations$main$tray$es._(_root);
}

// Path: meta
class _Translations$meta$es implements Translations$meta$en {
	_Translations$meta$es._(this._root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get enable => 'Habilitar';
	@override String get disable => 'Deshabilitar';
	@override String get open => 'Abrir';
	@override String get close => 'Cerrar';
	@override String get quit => 'Salir';
	@override String get add => 'Añadir';
	@override String get remove => 'Eliminar';
	@override String get removeConfirm => '¿Está seguro de eliminar?';
	@override String get edit => 'Editar';
	@override String get view => 'Ver';
	@override String get remark => 'Observación';
	@override String get byDefault => 'Por defecto';
	@override String get more => 'Más';
	@override String get tips => 'Información';
	@override String get selectAll => 'Seleccionar Todo';
	@override String get copy => 'Copiar';
	@override String get paste => 'Pegar';
	@override String get cut => 'Cortar';
	@override String get save => 'Guardar';
	@override String get ok => 'Vale';
	@override String get cancel => 'Cancelar';
	@override String get faq => 'Preguntas frecuentes';
	@override String get doc => 'Documento';
	@override String get htmlTools => 'Herramientas HTML';
	@override String get download => 'Descargar';
	@override String get loading => 'Cargando...';
	@override String get days => 'Días';
	@override String get hours => 'Horas';
	@override String get minutes => 'Minutos';
	@override String get seconds => 'Segundos';
	@override String get milliseconds => 'Milisegundos';
	@override String get search => 'Buscar';
	@override String get searchNodeHint => 'Filtrar nodos (nombre o protocolo)';
	@override String get connect => 'Conectar';
	@override String get disconnect => 'Desconectar';
	@override String get connected => 'Conectado';
	@override String get disconnected => 'Desconectado';
	@override String get connecting => 'Conectando';
	@override String get connectTimeout => 'Tiempo de espera de conexión agotado';
	@override String get timeout => 'Tiempo de espera agotado';
	@override String get latencyTest => 'Comprobación de latencia';
	@override String get networkCheck => 'Comprobación de red';
	@override String get language => 'Idioma';
	@override String get next => 'Siguiente';
	@override String get done => 'Hecho';
	@override String get apply => 'Aplicar';
	@override String get refresh => 'Actualizar';
	@override String get update => 'Actualizar';
	@override String get updateInterval => 'Intervalo de actualización';
	@override String updateFailed({required Object p}) => 'Fallo al actualizar: ${p}';
	@override String get updateInterval5mTips => 'Mínimo: 5m';
	@override String get updateIntervalPreferByProfile => 'Preferir configuración del proveedor';
	@override String get none => 'Ninguno';
	@override String get reset => 'Restablecer';
	@override String get authentication => 'Autenticación';
	@override String get user => 'Usuario';
	@override String get account => 'Cuenta';
	@override String get password => 'Contraseña';
	@override String get decryptPassword => 'Descifrar Contraseña';
	@override String get required => 'Requerido';
	@override String get go => 'Continuar';
	@override String get other => 'Otro';
	@override String get dns => 'DNS';
	@override String get url => 'URL';
	@override String get urlInvalid => 'URL no válida';
	@override String get copyUrl => 'Copiar Enlace';
	@override String get openUrl => 'Abrir Enlace';
	@override String get coreSettingTips => 'Nota: Después de modificar la configuración, debe volver a conectar para que surta efecto';
	@override String get overwrite => 'Sobrescribir';
	@override String get overwriteAppend => 'Sobrescritura adicional';
	@override String get overwriteTips => 'Perfil Original <- Sobrescritura Personalizada <- Sobrescritura de App';
	@override String get noOverwrite => 'No sobrescribir';
	@override String get diversionTemplates => 'Plantilla de Enrutamiento';
	@override String get ruleProviders => 'Proveedores de Reglas';
	@override String get ruleTemplates => 'Plantillas de Reglas';
	@override String get proxyGroupsTemplates => 'Plantilla de Grupo de Proxy';
	@override String get proxyGroups => 'Grupo de Proxy';
	@override String get proxyNodeList => 'Lista de Nodos Proxy';
	@override String proxyNodeFailure({required Object p}) => 'Los siguientes nodos proxy han caducado y han sido eliminados automáticamente: ${p}';
	@override String get externalController => 'Controlador Externo';
	@override String get secret => 'Secreto';
	@override String get tcpConcurrent => 'Apretón de manos TCP Concurrente';
	@override String get globalClientFingerprint => 'Huella Digital Global TLS';
	@override String get allowLanAccess => 'Acceso de dispositivos LAN';
	@override String get mixedPort => 'Puerto Proxy Mixto';
	@override String get logLevel => 'Nivel de Registro';
	@override String get findProcessMode => 'Modo de Búsqueda de Procesos';
	@override String get tcpkeepAliveInterval => 'Intervalo Keep-alive TCP';
	@override String get delayTestUrl => 'URL de Prueba de Retraso';
	@override String get delayTestTimeout => 'Tiempo de Espera de Prueba de Retraso (ms)';
	@override String get tun => 'TUN';
	@override String get ntp => 'NTP';
	@override String get tls => 'TLS';
	@override String get geoDownloadByProxy => 'Descargando Geo RuleSet por proxy';
	@override String get geoRulesetTips => 'Geosite/Geoip se convertirán en el RuleSet correspondiente';
	@override String get sniffer => 'Sniffer';
	@override String get userAgent => 'UserAgent';
	@override String get launchAtStartup => 'Ejecutar al Inicio';
	@override String get launchAtStartupRunAsAdmin => 'Por favor, reinicie Mclash como administrador';
	@override String get tunModeRunAsAdmin => 'El modo TUN requiere permisos de administrador del sistema, por favor reinicie la aplicación como administrador';
	@override String get portableMode => 'Modo Portátil';
	@override String get portableModeDisableTips => 'Si necesita salir del modo portátil, cierre [mclash] y elimine manualmente la carpeta [portable] en el mismo directorio que [mclash.exe]';
	@override String get autoConnectAfterLaunch => 'Conexión Automática tras Inicio';
	@override String get autoConnectAtBoot => 'Conexión Automática tras Inicio del Sistema';
	@override String get autoConnectAtBootTips => 'Se requiere soporte del sistema; algunos sistemas también pueden requerir que el [autoinicio] esté habilitado.';
	@override String get hideAfterLaunch => 'Ocultar ventana después del inicio';
	@override String get autoSetSystemProxy => 'Autoestablecer Proxy del Sistema al Conectar';
	@override String get bypassSystemProxy => 'Nombres de dominio permitidos para omitir el proxy del sistema';
	@override String get excludeFromRecent => 'Ocultar de [Tareas Recientes]';
	@override String get wakeLock => 'Bloqueo de Despertar';
	@override String get hideDockIcon => 'Ocultar Icono del Dock';
	@override String get showTrayTraffic => 'Mostrar información de tráfico en la bandeja';
	@override String get website => 'Sitio Web';
	@override String get rule => 'Regla';
	@override String get global => 'Global';
	@override String get direct => 'Directo';
	@override String get qrcode => 'Código QR';
	@override String get qrcodeTooLong => 'El texto es demasiado largo para mostrarse';
	@override String get qrcodeShare => 'Compartir Código QR';
	@override String get qrcodeScan => 'Escanear Código QR';
	@override String get qrcodeScanResult => 'Resultado del Escaneo';
	@override String get backupAndSync => 'Copia de Seguridad y Sincronización';
	@override String get export => 'Exportar';
	@override String get send => 'Enviar';
	@override String get sendConfirm => '¿Confirmar envío?';
	@override String get log => 'Registro';
	@override String get coreLog => 'Registro del Núcleo';
	@override String get appLog => 'Registro de la app';
	@override String get core => 'Núcleo';
	@override String get help => 'Ayuda';
	@override String get tutorial => 'Tutorial';
	@override String get board => 'Tablero';
	@override String get boardOnline => 'Usar Tablero en Línea';
	@override String get boardOnlineUrl => 'URL del Tablero en Línea';
	@override String get boardLocalPort => 'Puerto del Tablero Local';
	@override String get alwayOnVPN => 'Conexión permanente';
	@override String get disableFontScaler => 'Deshabilitar escala de fuente (el reinicio surte efecto)';
	@override String get autoOrientation => 'Girar con la pantalla';
	@override String get restartTakesEffect => 'El reinicio surte efecto';
	@override String get reconnectTakesEffect => 'La reconexión surte efecto';
	@override String get runtimeProfile => 'Perfil de Tiempo de Ejecución';
	@override String get willCompleteAfterRebootInstall => 'Por favor, reinicie su dispositivo para completar la instalación de la extensión del sistema';
	@override String get requestNeedsUserApproval => '1. Por favor [Permitir] que Mclash instale extensiones del sistema en [Ajustes del Sistema]-[Privacidad y Seguridad]\n2. [Ajustes del Sistema]-[General]-[Extensiones de Ítems de Inicio]-[Extensión de Red] habilite [mclashServiceSE]\nreconnecte después de completar';
	@override String get FullDiskAccessPermissionRequired => 'Por favor, habilite el permiso mclashServiceSE en [Ajustes del Sistema]-[Privacidad y Seguridad]-[Acceso Total al Disco] y vuelva a conectar.';
	@override String get proxy => 'Proxy';
	@override String get theme => 'Tema';
	@override String get tvMode => 'Modo TV';
	@override String get autoUpdate => 'Actualización Automática';
	@override String get updateChannel => 'Canal de Actualización Automática';
	@override String hasNewVersion({required Object p}) => 'Actualizar Versión ${p}';
	@override String get autoDownloadPkg => 'Descargar Paquetes de Actualización Automáticamente';
	@override String get devOptions => 'Opciones de Desarrollador';
	@override String get about => 'Acerca de';
	@override String get name => 'Nombre';
	@override String get version => 'Versión';
	@override String get sort => 'Reordenar';
	@override String get share => 'Compartir';
	@override String get importFromClipboard => 'Importar desde el Portapapeles';
	@override String get exportToClipboard => 'Exportar al Portapapeles';
	@override String get server => 'Servidor';
	@override String get port => 'Puerto';
	@override String get donate => 'Donar';
	@override String get setting => 'Ajustes';
	@override String get settingCore => 'Ajustes del Núcleo';
	@override String get settingApp => 'Ajustes de la App';
	@override String get coreOverwrite => 'Sobrescritura del Núcleo';
	@override String get iCloud => 'iCloud';
	@override String get webdav => 'Webdav';
	@override String get lanSync => 'Sincronización LAN';
	@override String get lanSyncNotQuitTips => 'No salga de esta interfaz antes de que se complete la sincronización';
	@override String get deviceNoSpace => 'No hay suficiente espacio en disco';
	@override String get hideSystemApp => 'Ocultar Aplicaciones del Sistema';
	@override String get hideAppIcon => 'Ocultar Iconos de App';
	@override String get openDir => 'Abrir Directorio de Archivos';
	@override String get type => 'Tipo';
	@override String fileNotExist({required Object p}) => 'El archivo no existe: ${p}';
	@override String get buyProfile => 'Comprar Perfil';
	@override String get myProfiles => 'Mis Perfiles';
	@override String get profileEdit => 'Editar Perfil';
	@override String get profileNeedActive => 'Primero establece este perfil como perfil actual y luego inicia/reconecta';
	@override String profileUrlOrContent({required Object p}) => 'Enlace de Perfil ${p}';
	@override String get tabHome => 'Inicio';
	@override String get tabNodes => 'Nodos';
	@override String get tabPlans => 'Planes';
	@override String get tabMe => 'Yo';
}

// Path: permission
class _Translations$permission$es implements Translations$permission$en {
	_Translations$permission$es._(this._root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get camera => 'Cámara';
	@override String get screen => 'Grabación de Pantalla';
	@override String get appQuery => 'Obtener Lista de Aplicaciones';
	@override String request({required Object p}) => 'Activar permiso de [${p}]';
	@override String requestNeed({required Object p}) => 'Por favor, active el permiso de [${p}]';
}

// Path: tls
class _Translations$tls$es implements Translations$tls$en {
	_Translations$tls$es._(this._root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get certificate => 'Certificado';
	@override String get privateKey => 'Clave Privada';
	@override String get customTrustCert => 'Certificados Personalizados';
}

// Path: tun
class _Translations$tun$es implements Translations$tun$en {
	_Translations$tun$es._(this._root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get stack => 'Pila de red';
	@override String get inet4Address => 'Dirección de Puerta de Enlace IPv4';
	@override String get dnsHijack => 'Secuestro de DNS';
	@override String get strictRoute => 'Ruta Estricta';
	@override String get tunDefaultRoute => 'Ruta predeterminada';
	@override String get icmpForward => 'Reenvío ICMP';
	@override String get allowBypass => 'Permitir aplicaciones para omitir VPN';
	@override String get appendHttpProxy => 'Anexar Proxy HTTP a VPN';
	@override String get bypassHttpProxyDomain => 'Dominios permitidos para omitir el proxy HTTP';
}

// Path: dns
class _Translations$dns$es implements Translations$dns$en {
	_Translations$dns$es._(this._root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get listen => 'Escuchar';
	@override String get fakeIp => 'fake-ip';
	@override String get fallback => 'Fallback';
	@override String get preferH3 => 'Preferir DoH H3';
	@override String get useHosts => 'Usar Hosts';
	@override String get useSystemHosts => 'Usar Hosts del Sistema';
	@override String get enhancedMode => 'Modo Mejorado';
	@override String get fakeIPFilterMode => 'Modo de Filtro ${_root.dns.fakeIp}';
	@override String get fakeIPFilter => 'Filtro fake-ip';
	@override String get respectRules => 'Respetar Reglas';
	@override String get nameServer => 'Servidor de Nombres';
	@override String get defaultNameServer => '${_root.meta.byDefault} ${_root.dns.nameServer}';
	@override String get proxyNameServer => '${_root.meta.proxy} ${_root.dns.nameServer}';
	@override String get directNameServer => '${_root.meta.direct} ${_root.dns.nameServer}';
	@override String get fallbackNameServer => '${_root.dns.fallback} ${_root.dns.nameServer}';
	@override String get fallbackGeoIp => '${_root.dns.fallback} GeoIp';
	@override String get fallbackGeoIpCode => '${_root.dns.fallback} GeoIpCode';
}

// Path: sniffer
class _Translations$sniffer$es implements Translations$sniffer$en {
	_Translations$sniffer$es._(this._root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get overrideDest => 'Sobrescribir';
}

// Path: profilePatchMode
class _Translations$profilePatchMode$es implements Translations$profilePatchMode$en {
	_Translations$profilePatchMode$es._(this._root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get currentSelected => 'Seleccionado Actual';
	@override String get overwrite => 'Sobrescritura Integrada';
	@override String get noOverwrite => 'Integrado - sin sobrescritura';
}

// Path: meScreen
class _Translations$meScreen$es implements Translations$meScreen$en {
	_Translations$meScreen$es._(this._root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get accountBalance => 'Saldo';
	@override String get expireAt => 'Vence';
	@override String get remainingDays => 'Días restantes';
	@override String get deviceCount => 'Dispositivos';
	@override String get myOrders => 'Mis pedidos';
	@override String get deviceManagement => 'Gestión de dispositivos';
	@override String get changePassword => 'Cambiar contraseña';
	@override String get clearLocalData => 'Borrar datos locales (antes de desinstalar)';
	@override String get profileManagementDev => 'Gestión de perfiles (desarrollador)';
	@override String get tunAdapter => 'Adaptador virtual TUN';
	@override String get checkUpdate => 'Buscar actualizaciones';
	@override String get retry => 'Reintentar';
	@override String get loadFailed => 'No se pudo cargar la cuenta: la sesión pudo vencer o la red no está disponible.\nToca Actualizar arriba a la derecha para reintentar; si sigue fallando, inicia sesión de nuevo.';
	@override String get logoutConfirm => '¿Cerrar sesión?';
	@override String get boardNoKernel => 'El panel muestra los datos en vivo del núcleo (conexión, tráfico, reglas activadas).\n\nEl núcleo no está en ejecución, así que el panel estaría vacío.\nToca Aceptar para abrirlo igualmente, o Cancelar para conectar antes en Inicio.';
	@override String get boardOpened => 'Panel abierto en tu navegador; cambia nodos o reglas allí y la app se actualiza en unos 5 segundos.';
}

// Path: homeScreen
class _Translations$homeScreen$es implements Translations$homeScreen$en {
	_Translations$homeScreen$es._(this._root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String expiresOn({required Object date}) => 'Vence el ${date}';
	@override String devicesText({required Object text}) => 'Dispositivos ${text}';
	@override String get upgrade => 'Mejorar';
	@override String get quickCountries => 'Filtro rápido por país';
	@override String nodeCount({required Object count}) => '${count} nodos';
	@override String get autoBestTip => 'Elige el nodo disponible con menor latencia de todos los países (modo automático)';
	@override String get autoBest => 'Mejor automático';
	@override String pickCountryTip({required Object label}) => 'Selecciona y fija el nodo disponible con menor latencia en «${label}»';
	@override String get autoNoBetter => 'Ya estás en modo automático (no se encontró un nodo mejor)';
	@override String switchedBest({required Object name}) => 'Cambiado al mejor nodo: ${name}';
	@override String switchedCountry({required Object country, required Object node, required Object ms}) => 'Cambiado al nodo ${country} más rápido: ${node}${ms}';
	@override String filterCountryFailed({required Object country, required Object err}) => 'Filtrado por ${country}; fallo al cambiar: ${err}';
	@override String deviceFullCount({required Object used, required Object limit}) => 'Dispositivos actuales ${used}/${limit}\n\n';
	@override String get deviceFullUpgradeHint => 'Mejorar el límite de dispositivos restaura la conexión de inmediato (recomendado); también puedes eliminar dispositivos sin usar para liberar un espacio.';
	@override String get later => 'Más tarde';
	@override String get upgradeDeviceCount => 'Mejorar límite de dispositivos';
	@override String get cannotConnect => 'No se puede conectar';
	@override String get freshnessNever => 'Aún sin sincronizar · toca para actualizar';
	@override String get freshnessJustNow => 'Actualizado ahora mismo · toca Gestionar dispositivos';
	@override String freshnessMinutes({required Object minutes}) => 'Hace ${minutes} min · toca Gestionar dispositivos';
	@override String freshnessStale({required Object minutes}) => 'Hace ${minutes} min · toca para actualizar';
	@override String get subscriptionAutoSync => 'Sincronización automática';
	@override String get connecting => 'Conectando…';
	@override String get disconnecting => 'Desconectando…';
	@override String get tapToDisconnect => 'Toca el interruptor para desconectar';
	@override String get tapToConnect => 'Toca el interruptor para conectar';
	@override String get currentNode => 'Nodo actual';
	@override String get noNodeSelected => 'Ningún nodo seleccionado';
	@override String get switchAction => 'Cambiar';
	@override String get realtimeSpeed => 'Velocidad en tiempo real';
	@override String get totalTraffic => 'Tráfico total';
	@override String get subSyncedNotReady => 'Suscripción descargada, pero el perfil aún no está listo. Inténtalo de nuevo en un momento.';
	@override String get noPlan => 'Esta cuenta aún no tiene un plan disponible. Compra uno primero.';
	@override String get loginExpired => 'Tu sesión ha vencido. Inicia sesión de nuevo.';
	@override String get syncingWait => 'Sincronizando la suscripción, espera un momento.';
	@override String syncFailedNetwork({required Object message}) => 'Fallo al sincronizar la suscripción: ${message}\nComprueba tu red e inténtalo de nuevo.';
	@override String get syncFailed => 'Fallo al sincronizar la suscripción, inténtalo más tarde.';
	@override String get resetProxy => 'Restablecer';
	@override String latencySuffix({required Object ms}) => ' (${ms}ms)';
}

// Path: nodesScreen
class _Translations$nodesScreen$es implements Translations$nodesScreen$en {
	_Translations$nodesScreen$es._(this._root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String updatedCount({required Object count}) => 'Suscripción actualizada: ${count} nodos';
	@override String updateFailed({required Object message}) => 'Fallo al actualizar: ${message}';
	@override String get updateFailedNetwork => 'Fallo al actualizar, comprueba tu red';
	@override String testDone({required Object ok, required Object fail}) => 'Prueba completada: ${ok} accesibles, ${fail} inaccesibles (pueden estar sin conexión)';
	@override String switchedTo({required Object name}) => 'Cambiado a ${name}';
	@override String switchFailed({required Object message}) => 'Fallo al cambiar: ${message}\n(Cambiar de nodo requiere el núcleo en ejecución; activa antes el interruptor en Inicio.)';
	@override String selectedAfterConnect({required Object name}) => '${name} seleccionado (surte efecto al conectar)';
	@override String get title => 'Nodos';
	@override String get searchNode => 'Buscar nodos';
	@override String get sortByLatency => 'Ordenar por latencia';
	@override String get updateSubscription => 'Actualizar suscripción';
	@override String get viewByGroup => 'Ver por grupo de proxy';
	@override String get testAll => 'Probar todo';
	@override String get searchHint => 'Buscar nodo / país / protocolo';
	@override String get emptyNoNodes => 'Aún no hay nodos disponibles.\nLas suscripciones se sincronizan solas; si acabas de iniciar sesión, espera un momento o toca recargar abajo.';
	@override String get emptyNoMatch => 'No hay nodos coincidentes.';
	@override String get reload => 'Recargar';
	@override String get currentInUse => 'Actual (en uso)';
	@override String get current => 'Actual';
	@override String get notTested => 'Sin medir (reinicio del núcleo pendiente)';
	@override String get timeout => 'Tiempo agotado';
	@override String get clear => 'Limpiar';
	@override String get selectNode => 'Seleccionar nodo';
	@override String get emptyNoKernel => 'Aún no hay nodos disponibles.\nActiva antes el interruptor de conexión en Inicio.';
	@override String get openFullList => 'Abrir la lista completa de nodos (buscar / prueba de velocidad / grupos)';
}

// Path: nodeAuto
class _Translations$nodeAuto$es implements Translations$nodeAuto$en {
	_Translations$nodeAuto$es._(this._root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get kernelStateUnavailable => 'El estado de los nodos no está disponible temporalmente desde el núcleo; se reintentará automáticamente.';
	@override String backToFixedNode({required Object fixed}) => 'De vuelta al nodo fijado: ${fixed}';
	@override String get noUsableNodePickOne => 'No se encontró ningún nodo usable. Elige uno manualmente en la lista de nodos.';
	@override String get noUsableNodeTryOne => 'No se encontró ningún nodo usable. Prueba a elegir uno en la lista de nodos.';
	@override String autoConnectedBest({required Object bestNode, required Object bestMs}) => 'Conectado automáticamente al mejor nodo: ${bestNode} (${bestMs} ms)';
	@override String get currentNodeUnreachable => 'El nodo actual no tiene acceso a internet; cambiando automáticamente…';
	@override String autoSwitchedToUsable({required Object target}) => 'Cambiado automáticamente a un nodo usable: ${target}';
	@override String newNodesReloading({required Object missing}) => '${missing} nodo(s) nuevo(s) de la suscripción aún no están en el núcleo; recargando…';
	@override String get kernelReloadedRetest => 'El núcleo se recargó con la nueva suscripción; vuelve a ejecutar la prueba de velocidad.';
}

// Path: accountBlock
class _Translations$accountBlock$es implements Translations$accountBlock$en {
	_Translations$accountBlock$es._(this._root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String quotaFull({required Object used, required Object limit}) => 'Los espacios de dispositivos están llenos (${used}/${limit}): este dispositivo aún está dentro del rango con licencia y puede conectarse con normalidad. Para añadir otro dispositivo, mejora el límite de dispositivos o elimina los que no uses.';
	@override String get banFallback => 'Tu cuenta ha sido deshabilitada y ya no se puede usar.';
	@override String get titleExpired => 'Plan vencido';
	@override String get titleDeviceFull => 'Límite de dispositivos alcanzado';
	@override String get titleAccountDisabled => 'Cuenta deshabilitada';
	@override String get titlePlanDisabled => 'Plan deshabilitado';
	@override String get titleNoPlan => 'Aún sin plan';
	@override String get titleDeviceRemoved => 'Este dispositivo fue eliminado';
	@override String get titleServiceUnavailable => 'Servicio no disponible temporalmente';
	@override String get textExpired => 'Tu plan ha vencido. Compra un plan para seguir usando los nodos globales.';
	@override String textDeviceFull({required Object used, required Object limit}) => 'El servidor ha determinado que este dispositivo supera el límite de dispositivos del plan (${used}/${limit}), así que por ahora no puede conectarse. Elimina dispositivos sin usar en Yo - Gestión de dispositivos, o mejora a un plan con más dispositivos.';
	@override String get textAccountDisabled => 'Tu cuenta ha sido deshabilitada. Contacta con soporte si tienes dudas.';
	@override String get textPlanDisabled => 'Tu plan ha sido deshabilitado o está en un estado anómalo, así que no puedes conectarte. Contacta con soporte si tienes dudas.';
	@override String get textNoPlan => 'Aún no has comprado un plan. Compra uno para usar los nodos globales.';
	@override String get textDeviceRemoved => 'Este dispositivo fue eliminado y se cerró su sesión. Inicia sesión de nuevo.';
	@override String get textServiceUnavailable => 'El servicio no está disponible temporalmente. Inténtalo más tarde; si persiste, haz una captura y contacta con soporte.';
	@override String remainingDays({required Object days}) => 'Quedan ${days} días';
	@override String deviceUsage({required Object used, required Object limit}) => 'Dispositivos ${used}/${limit}';
}

// Path: entitlementMsg
class _Translations$entitlementMsg$es implements Translations$entitlementMsg$en {
	_Translations$entitlementMsg$es._(this._root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get tamperedTitle => 'Estado de autorización anómalo';
	@override String get tamperedClock => 'Se detectó un retroceso del reloj del sistema (o manipulación de los datos de autorización locales). Conéctate a internet para completar una verificación antes de conectar.';
	@override String get tamperedLocal => 'Los datos de autorización locales están dañados o han sido modificados. Conéctate a internet para completar una verificación antes de conectar.';
	@override String get needVerifyTitle => 'Se requiere verificación en línea';
	@override String get needVerifyFirst => 'No se puede confirmar el estado de tu plan: conéctate a la red e inicia sesión, y completa una verificación antes de conectar.';
	@override String get needVerifyRetry => 'No se puede confirmar el estado de tu plan. Conéctate a internet e inténtalo de nuevo.';
	@override String get verifyFailedTitle => 'No se puede verificar el estado del plan';
	@override String get verifyFailedText => 'El periodo de gracia de verificación ha terminado y el servidor no responde. Comprueba tu red e inténtalo de nuevo (si acabas de renovar, inicia sesión otra vez).';
	@override String get restrictedTitle => 'Cuenta restringida';
	@override String get restrictedFallback => 'Tu cuenta o tu plan ha sido deshabilitado, así que no puedes conectarte.';
	@override String get expiredTitle => 'Plan vencido';
	@override String expiredText({required Object date}) => 'Tu plan venció el ${date}. Se ha borrado el perfil de suscripción local. Renueva e inicia sesión de nuevo para restaurarlo.';
}

// Path: devicesScreen
class _Translations$devicesScreen$es implements Translations$devicesScreen$en {
	_Translations$devicesScreen$es._(this._root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Gestión de dispositivos';
	@override String get currentPlan => 'Plan actual';
	@override String devicesText({required Object text}) => 'Dispositivos ${text}';
	@override String get upgradeTitle => 'Mejorar dispositivos / ampliar tiempo';
	@override String get upgradeSubtitle => 'Añade dispositivos y días juntos; un solo precio, un solo pago';
	@override String get addDevices => 'Añadir dispositivos';
	@override String get noAddDevices => 'Sin cambios';
	@override String addDevicesCount({required Object n}) => '+${n} dispositivos';
	@override String get addDays => 'Añadir días';
	@override String get noExtend => 'Sin ampliación';
	@override String addDaysCount({required Object n, required Object months}) => '+${n} días (${months} meses)';
	@override String get priceFailed => 'No se pudo obtener el precio';
	@override String amountDue({required Object amount}) => 'Total ¥${amount}';
	@override String get requote => 'Recalcular';
	@override String get goPay => 'Pagar ahora';
	@override String get afterUpgrade => 'Tras mejorar: ';
	@override String afterLimit({required Object limit}) => 'límite de dispositivos ${limit}';
	@override String afterExpire({required Object date}) => 'vence el ${date}';
	@override String get pickSomething => 'Añade al menos algunos dispositivos o días';
	@override String get daysOnlyUnsupported => 'El panel aún no admite «solo ampliar tiempo»: pon «Añadir dispositivos» en 1 o más e inténtalo de nuevo (o contacta con soporte para habilitarlo).';
	@override String get paramsRejected => 'Parámetros rechazados: vuelve a elegir la cantidad de dispositivos y los días.';
	@override String get subscriptionExpired => 'La suscripción ha vencido, así que no se puede mejorar. Renueva o compra un plan primero.';
	@override String get orderIncomplete => 'La información del pedido está incompleta. Toca «Recalcular» e inténtalo de nuevo.';
	@override String get orderRegenerated => 'El pedido anterior venció; se ha creado uno nuevo con los mismos ajustes.';
	@override String get payChannelIncomplete => 'La información del pedido o del canal de pago está incompleta. Recalcula e inténtalo de nuevo.';
	@override String get noQrCode => 'El servidor no devolvió un código QR ni un enlace de pago. Elige otro método de pago o inténtalo más tarde.';
	@override String payStartFailed({required Object err}) => 'No se pudo iniciar el pago: ${err}';
	@override String get payCancelled => 'Pago cancelado; el pedido en borrador se ha eliminado.';
	@override String get balancePay => 'Saldo';
	@override String get noPayMethod => 'Ahora mismo no hay ningún método de pago disponible. Inténtalo más tarde o contacta con soporte.';
	@override String balanceInsufficient({required Object balance, required Object amount}) => 'Saldo insuficiente (¥${balance}, se necesitan ¥${amount}).\n¿Recargar primero?';
	@override String get choosePayMethod => 'Elige un método de pago';
	@override String balanceText({required Object balance}) => 'Saldo ¥${balance}';
	@override String balanceShort({required Object balance}) => 'Saldo ¥${balance} (insuficiente, recarga)';
	@override String get unknownDevice => 'Dispositivo desconocido';
	@override String get online => '● En línea';
	@override String get offline => '○ Sin conexión';
	@override String lastActive({required Object text}) => 'Última actividad ${text}';
	@override String get delete => 'Eliminar';
	@override String deleteConfirm({required Object name}) => '¿Eliminar el dispositivo «${name}»? Se desconectará de inmediato.';
	@override String get lastActiveJustNow => 'Ahora mismo';
	@override String lastActiveMinutes({required Object minutes}) => 'hace ${minutes} min';
	@override String lastActiveToday({required Object time}) => 'Hoy ${time}';
}

// Path: sysProxySheet
class _Translations$sysProxySheet$es implements Translations$sysProxySheet$en {
	_Translations$sysProxySheet$es._(this._root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get reading => 'Leyendo…';
	@override String get unknown => 'Desconocido';
	@override String get kernelNotRunning => 'El núcleo no está en ejecución (activa antes el interruptor en Inicio)';
	@override String applied({required Object host, required Object port}) => 'Aplicado · ${host}:${port}';
	@override String notSet({required Object reason}) => 'Proxy del sistema no configurado — ${reason}';
	@override String notEffective({required Object port}) => 'Sin efecto (ningún proxy del sistema apunta a ${port})';
	@override String readFailed({required Object err}) => 'Fallo al leer: ${err}';
	@override String get setRejected => 'No se pudo configurar: puede que el sistema rechazara la escritura (u otra app de proxy la sobrescribiera)';
	@override String get disableFailed => 'No se pudo desactivar';
	@override String get portRange => 'El puerto debe estar entre 1 y 65535';
	@override String portChanged({required Object value}) => 'Puerto cambiado a ${value}: desconecta y vuelve a conectar para que el núcleo escuche en el nuevo puerto';
	@override String get title => 'Proxy del sistema';
	@override String desc({required Object host}) => 'La dirección del proxy del sistema está fijada a ${host} (bucle local) y el puerto es el puerto mixto del núcleo.';
	@override String get descWindows => 'Esto es exactamente lo que ves en Ajustes de Windows → Red e Internet → Proxy.';
	@override String get reset => 'Volver a configurar';
	@override String get disable => 'Desactivar proxy del sistema';
	@override String get diagnostics => 'Diagnóstico (¿la interfaz lee los mismos valores que el registro?)';
	@override String get mixedPort => 'Puerto mixto';
	@override String get apply => 'Aplicar';
}

// Path: logScreen
class _Translations$logScreen$es implements Translations$logScreen$en {
	_Translations$logScreen$es._(this._root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String readAppFailed({required Object e}) => 'Fallo al leer el registro de la app: ${e}';
	@override String readCoreFailed({required Object e}) => 'Fallo al leer el registro del núcleo: ${e}';
	@override String get copied => 'Copiado (las URL de suscripción y otros secretos van ocultos; el archivo de registro puede contener aún la dirección real)';
	@override String get copy => 'Copiar';
	@override String get refresh => 'Actualizar';
	@override String get empty => 'Sin contenido';
}

// Path: trayShell
class _Translations$trayShell$es implements Translations$trayShell$en {
	_Translations$trayShell$es._(this._root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get closeTitle => 'Cerrar ventana';
	@override String get closeBody => 'Cerrar la ventana solo pone Mclash en la bandeja: el núcleo y el proxy del sistema siguen funcionando y tu red permanece conectada.\n\n· Aceptar: minimizar a la bandeja (para salir por completo, clic derecho en el icono de la bandeja → Salir)\n· Cancelar: cerrar Mclash por completo, detener el núcleo y restaurar el proxy del sistema\n\n(Tu elección se recuerda; la próxima vez puedes usar directamente el icono de la bandeja)';
}

// Path: ordersScreen
class _Translations$ordersScreen$es implements Translations$ordersScreen$en {
	_Translations$ordersScreen$es._(this._root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Mis pedidos';
	@override String get orderInfoIncomplete => 'La información del pedido está incompleta. Desliza hacia abajo para actualizar e inténtalo de nuevo.';
	@override String get payChannelIncomplete => 'La información del canal de pago está incompleta. Inténtalo más tarde.';
	@override String get noQrPayload => 'El servidor no devolvió un código QR ni un enlace de pago. Elige otro método de pago o inténtalo más tarde.';
	@override String payStartFailed({required Object err}) => 'No se pudo iniciar el pago: ${err}';
	@override String get noPayMethod => 'Ahora mismo no hay ningún método de pago disponible. Inténtalo más tarde o contacta con soporte.';
	@override String get choosePayMethod => 'Elige un método de pago';
	@override String amountDue({required Object amount}) => 'Importe a pagar ¥${amount}';
	@override String get paidLabel => '● Pagado';
	@override String get pendingLabel => '○ Sin pagar';
	@override String unknownStatus({required Object status}) => '✕ ${status}';
	@override String orderNoText({required Object orderNo}) => 'Pedido n.º ${orderNo}';
	@override String createdAtText({required Object createdAt}) => 'Creado el ${createdAt}';
	@override String get orderCanceled => 'Pedido cancelado';
	@override String cancelFailed({required Object err}) => 'Fallo al cancelar: ${err}\n(Si el pedido ya se ha pagado o cancelado, desliza hacia abajo para ver el estado más reciente.)';
	@override String get cancelOrder => 'Cancelar pedido';
	@override String get continuePay => 'Continuar pago';
}

// Path: payment
class _Translations$payment$es implements Translations$payment$en {
	_Translations$payment$es._(this._root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get balancePay => 'Pago con saldo';
	@override String get qrPay => 'Escanear para pagar';
	@override String get deductFromBalance => 'Se deduce del saldo de tu cuenta';
	@override String get openedInBrowser => 'La página de pago se ha abierto en tu navegador';
	@override String get scanWithAlipayWechat => 'Escanea con Alipay o WeChat';
	@override String orderNoText({required Object orderNo}) => 'Pedido n.º ${orderNo}';
	@override String payFailed({required Object err}) => 'Pago fallido: ${err}';
	@override String get notDetected => 'No se detectó ningún pago. Puedes continuar más tarde en «Mis pedidos».';
	@override String get charging => 'Cobrando…';
	@override String get processing => 'Procesando…';
	@override String get waitingPay => 'Esperando el pago…';
	@override String get openPageFailed => 'No se pudo abrir la página de pago. Toca el botón de abajo para reintentar, o escanea el código QR.';
	@override String get reopenPayPage => 'Reabrir página de pago';
	@override String get payInBrowser => 'Pagar en el navegador';
	@override String get openAlipay => 'Abrir Alipay';
	@override String get cancelOrder => 'Cancelar pedido';
	@override String get confirmPay => 'Confirmar pago';
	@override String get retry => 'Reintentar';
	@override String get paidAlready => 'Ya he pagado';
	@override String get channelAlipay => 'Alipay';
	@override String get channelCodepayAlipay => 'Pago con código · Alipay';
	@override String get channelCodepayWechat => 'Pago con código · WeChat';
	@override String get channelCodepay => 'Pago con código';
	@override String get channelWechat => 'WeChat Pay';
	@override String get channelUsdt => 'USDT';
	@override String get channelUsdtTrc20 => 'USDT · TRC20';
	@override String get payFallback => 'Pago';
	@override String get errCsrf => 'Tu credencial de acceso ha vencido (fallo en la comprobación CSRF).\nDesliza hacia abajo en la pestaña «Yo» para actualizar o inicia sesión de nuevo, y luego reintenta.';
	@override String get errAlipayLimit => 'El pago presencial de Alipay tiene un límite por transacción (¥1000 para este comercio) y este pedido lo supera.\nUsa «Pago con saldo» o «Pago con código», o contacta con soporte para aumentar el límite de Alipay.';
	@override String get errNotSigned => 'La app de Alipay no tiene dado de alta el producto de pago correspondiente, así que este canal no está disponible temporalmente.\nUsa «Pago con saldo» o «Pago con código», o contacta con soporte para habilitarlo.';
	@override String get errOrderGone => 'Este pedido se ha cancelado o ha vencido (los pedidos en borrador son válidos 30 minutos).\nToca «Recalcular» para crear un pedido nuevo y luego paga.';
	@override String errNetwork({required Object err}) => 'Red no disponible: ${err}';
}

// Path: planScreen
class _Translations$planScreen$es implements Translations$planScreen$en {
	_Translations$planScreen$es._(this._root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get recommended => 'Recomendado';
	@override String get devices => 'Dispositivos';
	@override String balanceLabel({required Object amount}) => 'Saldo ¥${amount}';
	@override String get balanceInsufficient => ' (Insuficiente, recarga primero)';
	@override String get total => 'Total';
	@override String get payNow => 'Pagar ahora';
	@override String get retry => 'Reintentar';
	@override String get errIncompleteOrder => 'La información del pedido o del canal de pago está incompleta; no se puede iniciar el pago.';
	@override String get payBalance => 'Pago con saldo';
	@override String get payAlipay => 'Alipay';
	@override String get payWechat => 'WeChat Pay';
	@override String get payCodepay => 'Pago con código';
	@override String get payCodepayAlipay => 'Pago con código · Alipay';
	@override String get payCodepayWechat => 'Pago con código · WeChat';
	@override String get payEpayAlipay => 'Epay · Alipay';
	@override String get payEpayWechat => 'Epay · WeChat';
	@override String get payUsdt => 'USDT';
	@override String get payUsdtTrc20 => 'USDT · TRC20';
	@override String get payStripe => 'Stripe';
	@override String get payPaypal => 'PayPal';
	@override String get payOnline => 'Pago en línea';
}

// Path: authScreen
class _Translations$authScreen$es implements Translations$authScreen$en {
	_Translations$authScreen$es._(this._root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get saveAccountInfo => 'Guardar datos de la cuenta';
	@override String get autoLoginNextTime => 'Iniciar sesión automáticamente la próxima vez';
	@override String get needLoginNextTime => 'La próxima vez tendrás que iniciar sesión de nuevo';
	@override String get invalidEmail => 'Introduce un correo electrónico válido';
	@override String get enterEmailFirst => 'Introduce primero un correo electrónico válido';
	@override String get passwordRequired => 'Introduce tu contraseña';
	@override String get wrongCredentials => 'Correo o contraseña incorrectos';
	@override String get requestRejected => 'Solicitud rechazada. Inténtalo más tarde.';
	@override String get tooFrequent => 'Demasiados intentos. Inténtalo más tarde.';
	@override String get loginFailed => 'Fallo al iniciar sesión';
	@override String get username => 'Nombre de usuario';
	@override String get confirmPassword => 'Confirmar contraseña';
	@override String get inviteCode => 'Código de invitación';
	@override String get emailCode => 'Código de verificación del correo';
	@override String get getCode => 'Obtener código';
	@override String get registerAndLogin => 'Registrarse e iniciar sesión';
	@override String usernameMinLength({required Object min}) => 'El nombre de usuario debe tener al menos ${min} caracteres';
	@override String get passwordMismatch => 'Las contraseñas no coinciden';
	@override String get emailCodeRequired => 'Introduce el código de verificación del correo';
	@override String get inviteCodeRequired => 'El registro en este sitio requiere un código de invitación';
	@override String get codeSentCheckEmail => 'Código de verificación enviado. Revisa tu correo.';
	@override String get registerSuccess => 'Registro correcto. Ya has iniciado sesión.';
	@override String passwordHint({required Object min}) => 'Al menos ${min} caracteres, con letras y números';
	@override String passwordTooShort({required Object min}) => 'La contraseña debe tener al menos ${min} caracteres';
	@override String get passwordNeedsLetterAndDigit => 'La contraseña debe contener letras y números';
	@override String get registeredEmail => 'Correo registrado';
	@override String get newPassword => 'Nueva contraseña';
	@override String get confirmNewPassword => 'Confirmar nueva contraseña';
	@override String get resetPassword => 'Restablecer contraseña';
	@override String get resetCodeSent => 'Si este correo está registrado, se ha enviado un código de restablecimiento (válido 15 minutos).';
	@override String get resetSuccess => 'Contraseña restablecida. Inicia sesión con tu nueva contraseña.';
	@override String get changePasswordTitle => 'Cambiar contraseña';
	@override String get currentPassword => 'Contraseña actual';
	@override String get saveNewPassword => 'Guardar nueva contraseña';
	@override String get newPasswordMismatch => 'Las nuevas contraseñas no coinciden';
	@override String get changePasswordSuccess => 'Contraseña cambiada. Inicia sesión de nuevo.';
}

// Path: updatePrompt
class _Translations$updatePrompt$es implements Translations$updatePrompt$en {
	_Translations$updatePrompt$es._(this._root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get checking => 'Buscando actualizaciones…';
	@override String get checkFailed => 'Fallo al buscar actualizaciones. Comprueba tu red e inténtalo de nuevo.';
	@override String alreadyLatest({required Object version}) => 'Ya tienes la última versión (${version}).';
	@override String newVersionFound({required Object version}) => 'La nueva versión ${version} ya está disponible';
	@override String get installerDownloaded => 'El instalador se ha descargado en segundo plano. Toca Actualizar ahora para completar la actualización.';
	@override String get downloadInBackground => 'Toca Actualizar ahora para descargarlo e instalarlo (puedes seguir usando la app; el instalador se descarga en segundo plano).';
	@override String get later => 'Más tarde';
	@override String get updateNow => 'Actualizar ahora';
	@override String installerNotReady({required Object version}) => 'El instalador aún no ha terminado de descargarse.\n\nToca Aceptar para abrir la página de descarga y descargar manualmente el instalador correspondiente a tu dispositivo (versión ${version}).';
}

// Path: clearData
class _Translations$clearData$es implements Translations$clearData$en {
	_Translations$clearData$es._(this._root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get itemLoginSession => 'Sesión de inicio de sesión';
	@override String get itemProfiles => 'Perfiles de suscripción (profiles/)';
	@override String get itemSettings => 'Ajustes de la app y del núcleo';
	@override String get itemLatencyCache => 'Caché de latencia de nodos';
	@override String get itemLogs => 'Registros de ejecución';
	@override String get itemRoutingData => 'Datos de enrutamiento y archivos temporales';
	@override String confirmBody({required Object items, required Object dir}) => 'Se borrarán los siguientes datos guardados en este dispositivo (no se puede deshacer):\n\n${items}\n\nLa cuenta en sí y cualquier plan que hayas comprado están en el servidor y no se ven afectados; inicia sesión de nuevo para restaurar tu suscripción.\n\nDirectorio de datos: ${dir}\n(Hazlo antes de desinstalar la app: solo así la reinstalación empezará limpia y te pedirá iniciar sesión de nuevo)';
	@override String get confirmAgain => '¿Borrar ahora? Después tendrás que iniciar sesión de nuevo.';
	@override String clearedNotice({required Object count, required Object dir}) => 'Se borraron ${count} elementos de datos locales (incluida la sesión, así que tendrás que iniciar sesión de nuevo la próxima vez que abras la app).\n\nYa puedes eliminar la app para terminar la desinstalación:\n· macOS: arrastra Mclash.app a la Papelera (el directorio de datos se ha vaciado: ${dir})\n· Windows: desinstala Mclash desde el Panel de control y elige No cuando el asistente pregunte si quieres conservar tus datos de usuario';
	@override String clearFailed({required Object error}) => 'Fallo al borrar: ${error}';
}

// Path: apiError
class _Translations$apiError$es implements Translations$apiError$en {
	_Translations$apiError$es._(this._root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String requestFailedHttp({required Object status, required Object domain}) => 'Solicitud fallida (HTTP ${status}); ya se probó ${domain}';
	@override String allDomainsFailed({required Object method, required Object path, required Object count}) => 'Solicitud fallida: ${method} ${path} (se probaron ${count} dominios)';
	@override String requestTimeout({required Object seconds, required Object method, required Object path}) => 'La solicitud agotó el tiempo de espera (${seconds}s): ${method} ${path}';
	@override String networkUnreachable({required Object detail}) => 'Red no disponible: ${detail}';
	@override String get tlsHandshakeFailed => 'Fallo en el handshake TLS. Comprueba tu conexión de red o la hora del sistema.';
	@override String connectionFailed({required Object detail}) => 'Fallo de conexión: ${detail}';
	@override String requestError({required Object error}) => 'Solicitud fallida: ${error}';
	@override String responseReadTimeout({required Object seconds, required Object method, required Object path}) => 'Se agotó el tiempo al leer la respuesta (${seconds}s): ${method} ${path}';
	@override String notJson({required Object status, required Object snippet}) => 'La respuesta no es JSON (HTTP ${status}): ${snippet}';
	@override String badStructure({required Object status}) => 'Estructura de respuesta inesperada (HTTP ${status})';
	@override String loginFailed({required Object code}) => 'Fallo al iniciar sesión (código ${code})';
	@override String get loginMissingData => 'A la respuesta de inicio de sesión le faltan datos';
	@override String get loginMissingToken => 'A la respuesta de inicio de sesión le falta access_token';
	@override String registerFailed({required Object code}) => 'Fallo en el registro (código ${code})';
	@override String get registerMissingToken => 'La respuesta de registro no trae access_token: puede haberse activado el control de riesgo, o el sitio está configurado de otra forma';
	@override String requestFailedCode({required Object code}) => 'Solicitud fallida (código ${code})';
}

// Path: subNotice
class _Translations$subNotice$es implements Translations$subNotice$en {
	_Translations$subNotice$es._(this._root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get titleNotFound => 'Suscripción no encontrada';
	@override String get titleExpired => 'Suscripción vencida';
	@override String get titleInactive => 'Suscripción inactiva';
	@override String get titleDeviceOverLimit => 'Límite de dispositivos superado';
	@override String get titleUnavailable => 'Suscripción no disponible';
	@override String titleWithReason({required Object emoji, required Object title, required Object reason}) => '${emoji} ${title} (${reason})';
	@override String deviceUsedOfLimit({required Object used, required Object limit}) => 'Dispositivos actuales ${used}/${limit}';
	@override String deviceUsedOnly({required Object used}) => 'Dispositivos actuales ${used}';
	@override String expireAt({required Object expire}) => 'Vence el ${expire}';
	@override String supportLine({required Object account}) => '💬 Soporte: ${account}';
	@override String siteLine({required Object url}) => '📢 Sitio web: ${url}';
}

// Path: settingItems
class _Translations$settingItems$es implements Translations$settingItems$en {
	_Translations$settingItems$es._(this._root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get subscriptionAutoUpdateInterval => 'Intervalo de actualización automática de la suscripción';
	@override String get speedTestMode => 'Método de prueba de velocidad';
	@override String get speedTestModeTcp => 'Prueba de velocidad TCP';
	@override String get speedTestModeKernel => 'Prueba de velocidad del núcleo';
	@override String get delayTestUrlTip => 'Tiempo de una solicitud HTTP completa a través de este nodo (no es un ping)\nPor defecto usa una respuesta vacía http 204; con https se añade el handshake TLS y el número es mayor';
	@override String get systemProxy => 'Proxy del sistema';
	@override String get systemProxyTip => 'Ver / restablecer dirección y puerto';
	@override String get tunMode => 'Modo TUN';
	@override String get tunModeTip => 'off=solo proxy del sistema / auto=TUN+proxy del sistema / force=solo TUN\nEn escritorio, TUN requiere permisos de administrador (wintun en Windows / utun en macOS)';
	@override String get tunOverwriteTip => 'overwrite\nActivado = los ajustes TUN de esta página sobrescriben la sección tun del perfil\nDesactivado = se usa la configuración tun del propio perfil (la app no interfiere)';
	@override String tunEnableByTunMode({required Object enable}) => '${enable} (según el modo TUN)';
	@override String get interval30Minutes => '30 minutos';
	@override String get interval1Hour => '1 hora';
	@override String get interval6Hours => '6 horas';
	@override String get interval12Hours => '12 horas';
	@override String get interval24Hours => '24 horas';
	@override String get interval3Days => '3 días';
	@override String get interval7Days => '7 días';
	@override String get intervalNever => 'Nunca';
	@override String intervalMinutes({required Object minutes}) => '${minutes} minutos';
	@override String intervalHours({required Object hours}) => '${hours} horas';
	@override String intervalDays({required Object days}) => '${days} días';
}

// Path: tunScreen
class _Translations$tunScreen$es implements Translations$tunScreen$en {
	_Translations$tunScreen$es._(this._root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get modeOff => 'Desactivado';
	@override String get modeAuto => 'Auto';
	@override String get modeForce => 'Forzado';
	@override String get modeOffDesc => 'Solo proxy del sistema: funciona para los programas que respetan el proxy del sistema (navegadores, etc.); UDP y juegos no pasan por el proxy';
	@override String get modeAutoDesc => 'TUN + proxy del sistema (doble seguridad): todo el tráfico pasa por el adaptador virtual, incluido UDP';
	@override String get modeForceDesc => 'Solo TUN: todo el tráfico pasa por el adaptador virtual y el proxy del sistema no se toca';
	@override String get modeOffOptionDesc => 'No toca la tabla de rutas del sistema; solo configura un proxy 127.0.0.1. Solo lo usan los programas que respetan el proxy del sistema; el tráfico UDP y los programas con su propio proxy, no.';
	@override String get modeAutoOptionDesc => 'Crea un adaptador virtual y toma todo el tráfico (incluidos UDP y juegos); el proxy del sistema se mantiene como respaldo. Recomendado: funciona globalmente y no te quedas sin red si faltan permisos.';
	@override String get modeForceOptionDesc => 'Usa solo el adaptador virtual y deja de cambiar el proxy del sistema. Todo el tráfico (incluido UDP) pasa por el túnel; la entrada «proxy» del sistema se mantiene igual.';
	@override String get adminRequiredDialog => 'El adaptador virtual TUN requiere permisos de administrador (wintun en Windows / utun en macOS).\n\nMclash no se está ejecutando como administrador ahora mismo, así que TUN no surtirá efecto tras activarlo (en modo «Auto» el proxy del sistema sigue funcionando como respaldo, así que la red sigue usable).\n\nAceptar = reiniciar Mclash como administrador ahora (aparecerá un aviso de UAC)\nCancelar = guardar esta opción igualmente (el proxy del sistema se usa automáticamente cuando TUN no está disponible)';
	@override String relaunchFailed({required Object message}) => 'Fallo al reiniciar: ${message}';
	@override String switchFailed({required Object message}) => 'Fallo al cambiar el modo TUN: ${message}\nSe han restaurado los ajustes anteriores.';
	@override String get setOffSnack => 'Configurado en «Desactivado»: solo proxy del sistema';
	@override String setModeSnack({required Object mode, required Object effect}) => 'Configurado en «${mode}», ${effect}';
	@override String get effectReconnected => 'reconectado y ya activo';
	@override String get effectAfterConnect => 'activo tras conectar';
	@override String get sheetTitle => 'Adaptador virtual TUN';
	@override String get advancedTitle => 'Parámetros avanzados (Ajustes del núcleo → TUN)';
	@override String get advancedSubtitle => 'Dirección del adaptador / pila / MTU / ruta automática / secuestro de DNS / sobrescritura';
	@override String get adminOk => 'TUN requiere permisos de administrador; los privilegios actuales son suficientes (ejecutar como administrador en Windows / como root en macOS)';
	@override String get adminMissing => 'TUN requiere permisos de administrador: Mclash no se ejecuta como administrador, así que TUN no surtirá efecto tras elegir «Auto/Forzado» («Auto» recurre al proxy del sistema, así que la red sigue usable)';
}

// Path: main.tray
class _Translations$main$tray$es implements Translations$main$tray$en {
	_Translations$main$tray$es._(this._root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get menuOpen => 'Abrir';
	@override String get menuExit => 'Salir';
}

/// The flat map containing all translations for locale <es>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on TranslationsEs {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'BackupAndSyncWebdavScreen.webdavServerUrl' => 'URL del Servidor',
			'BackupAndSyncWebdavScreen.webdavRequired' => 'No puede estar vacío',
			'BackupAndSyncWebdavScreen.webdavLoginFailed' => 'Fallo al iniciar sesión:',
			'BackupAndSyncWebdavScreen.webdavListFailed' => 'Fallo al obtener la lista de archivos:',
			'LaunchFailedScreen.invalidProcess' => 'La aplicación no pudo iniciarse [Nombre de proceso no válido], por favor reinstale la aplicación en un directorio separado',
			'LaunchFailedScreen.invalidProfile' => 'La aplicación no pudo iniciarse [Fallo al acceder al perfil], por favor reinstale la aplicación',
			'LaunchFailedScreen.invalidVersion' => 'La aplicación no pudo iniciarse [Versión no válida], por favor reinstale la aplicación',
			'LaunchFailedScreen.systemVersionLow' => 'La aplicación no pudo iniciarse [versión del sistema demasiado baja]',
			'LaunchFailedScreen.invalidInstallPath' => 'La ruta de instalación no es válida, por favor reinstálela en una ruta válida',
			'PerAppAndroidScreen.title' => 'Proxy por Aplicación',
			'PerAppAndroidScreen.whiteListMode' => 'Modo Lista Blanca',
			'PerAppAndroidScreen.whiteListModeTip' => 'Cuando está habilitado: solo las aplicaciones marcadas son proxies; cuando no está habilitado: solo las aplicaciones no marcadas son proxies',
			'UserAgreementScreen.privacyFirst' => 'Su Privacidad es lo Primero',
			'UserAgreementScreen.agreeAndContinue' => 'Aceptar y Continuar',
			'VersionUpdateScreen.versionReady' => ({required Object p}) => 'La nueva versión [${p}] está lista',
			'VersionUpdateScreen.update' => 'Reiniciar para Actualizar',
			'VersionUpdateScreen.cancel' => 'Ahora no',
			'NetCheckScreen.enterDomain' => 'Por favor, introduzca un dominio',
			'NetCheckScreen.checking' => 'Comprobando...',
			'NetCheckScreen.aQueryFailed' => ({required Object p}) => 'Fallo en la consulta A: ${p}',
			'NetCheckScreen.aaaaQueryFailed' => ({required Object p}) => 'Fallo en la consulta AAAA: ${p}',
			'NetCheckScreen.success' => 'Éxito',
			'NetCheckScreen.failed' => 'Fallo',
			'NetCheckScreen.suspectedPollution' => 'Sospecha de envenenamiento DNS',
			'NetCheckScreen.domainLabel' => 'Dominio',
			'NetCheckScreen.checkButton' => 'Comprobar',
			'NetCheckScreen.dnsSection' => '1. Consulta DNS',
			'NetCheckScreen.directHttpSection' => '2. HTTP (vía TUN, habilite TUN primero)',
			'NetCheckScreen.proxyHttpSection' => ({required Object p}) => '3. HTTP (vía Proxy, puerto: ${p})',
			'NetCheckScreen.tunNotEnabled' => 'TUN no está habilitado',
			'NetCheckScreen.routeTableSection' => '4. Tabla de Rutas',
			'loginScreen.login' => 'Iniciar sesión',
			'loginScreen.register' => 'Registrar cuenta',
			'loginScreen.forgotPassword' => 'Olvidé mi contraseña',
			'loginScreen.provider' => 'Proveedor',
			'loginScreen.providerName' => 'Código, alias o URL del ${_root.loginScreen.provider}',
			'loginScreen.account' => 'Cuenta',
			'loginScreen.email' => 'Correo electrónico',
			'loginScreen.password' => 'Contraseña',
			'main.tray.menuOpen' => 'Abrir',
			'main.tray.menuExit' => 'Salir',
			'meta.enable' => 'Habilitar',
			'meta.disable' => 'Deshabilitar',
			'meta.open' => 'Abrir',
			'meta.close' => 'Cerrar',
			'meta.quit' => 'Salir',
			'meta.add' => 'Añadir',
			'meta.remove' => 'Eliminar',
			'meta.removeConfirm' => '¿Está seguro de eliminar?',
			'meta.edit' => 'Editar',
			'meta.view' => 'Ver',
			'meta.remark' => 'Observación',
			'meta.byDefault' => 'Por defecto',
			'meta.more' => 'Más',
			'meta.tips' => 'Información',
			'meta.selectAll' => 'Seleccionar Todo',
			'meta.copy' => 'Copiar',
			'meta.paste' => 'Pegar',
			'meta.cut' => 'Cortar',
			'meta.save' => 'Guardar',
			'meta.ok' => 'Vale',
			'meta.cancel' => 'Cancelar',
			'meta.faq' => 'Preguntas frecuentes',
			'meta.doc' => 'Documento',
			'meta.htmlTools' => 'Herramientas HTML',
			'meta.download' => 'Descargar',
			'meta.loading' => 'Cargando...',
			'meta.days' => 'Días',
			'meta.hours' => 'Horas',
			'meta.minutes' => 'Minutos',
			'meta.seconds' => 'Segundos',
			'meta.milliseconds' => 'Milisegundos',
			'meta.search' => 'Buscar',
			'meta.searchNodeHint' => 'Filtrar nodos (nombre o protocolo)',
			'meta.connect' => 'Conectar',
			'meta.disconnect' => 'Desconectar',
			'meta.connected' => 'Conectado',
			'meta.disconnected' => 'Desconectado',
			'meta.connecting' => 'Conectando',
			'meta.connectTimeout' => 'Tiempo de espera de conexión agotado',
			'meta.timeout' => 'Tiempo de espera agotado',
			'meta.latencyTest' => 'Comprobación de latencia',
			'meta.networkCheck' => 'Comprobación de red',
			'meta.language' => 'Idioma',
			'meta.next' => 'Siguiente',
			'meta.done' => 'Hecho',
			'meta.apply' => 'Aplicar',
			'meta.refresh' => 'Actualizar',
			'meta.update' => 'Actualizar',
			'meta.updateInterval' => 'Intervalo de actualización',
			'meta.updateFailed' => ({required Object p}) => 'Fallo al actualizar: ${p}',
			'meta.updateInterval5mTips' => 'Mínimo: 5m',
			'meta.updateIntervalPreferByProfile' => 'Preferir configuración del proveedor',
			'meta.none' => 'Ninguno',
			'meta.reset' => 'Restablecer',
			'meta.authentication' => 'Autenticación',
			'meta.user' => 'Usuario',
			'meta.account' => 'Cuenta',
			'meta.password' => 'Contraseña',
			'meta.decryptPassword' => 'Descifrar Contraseña',
			'meta.required' => 'Requerido',
			'meta.go' => 'Continuar',
			'meta.other' => 'Otro',
			'meta.dns' => 'DNS',
			'meta.url' => 'URL',
			'meta.urlInvalid' => 'URL no válida',
			'meta.copyUrl' => 'Copiar Enlace',
			'meta.openUrl' => 'Abrir Enlace',
			'meta.coreSettingTips' => 'Nota: Después de modificar la configuración, debe volver a conectar para que surta efecto',
			'meta.overwrite' => 'Sobrescribir',
			'meta.overwriteAppend' => 'Sobrescritura adicional',
			'meta.overwriteTips' => 'Perfil Original <- Sobrescritura Personalizada <- Sobrescritura de App',
			'meta.noOverwrite' => 'No sobrescribir',
			'meta.diversionTemplates' => 'Plantilla de Enrutamiento',
			'meta.ruleProviders' => 'Proveedores de Reglas',
			'meta.ruleTemplates' => 'Plantillas de Reglas',
			'meta.proxyGroupsTemplates' => 'Plantilla de Grupo de Proxy',
			'meta.proxyGroups' => 'Grupo de Proxy',
			'meta.proxyNodeList' => 'Lista de Nodos Proxy',
			'meta.proxyNodeFailure' => ({required Object p}) => 'Los siguientes nodos proxy han caducado y han sido eliminados automáticamente: ${p}',
			'meta.externalController' => 'Controlador Externo',
			'meta.secret' => 'Secreto',
			'meta.tcpConcurrent' => 'Apretón de manos TCP Concurrente',
			'meta.globalClientFingerprint' => 'Huella Digital Global TLS',
			'meta.allowLanAccess' => 'Acceso de dispositivos LAN',
			'meta.mixedPort' => 'Puerto Proxy Mixto',
			'meta.logLevel' => 'Nivel de Registro',
			'meta.findProcessMode' => 'Modo de Búsqueda de Procesos',
			'meta.tcpkeepAliveInterval' => 'Intervalo Keep-alive TCP',
			'meta.delayTestUrl' => 'URL de Prueba de Retraso',
			'meta.delayTestTimeout' => 'Tiempo de Espera de Prueba de Retraso (ms)',
			'meta.tun' => 'TUN',
			'meta.ntp' => 'NTP',
			'meta.tls' => 'TLS',
			'meta.geoDownloadByProxy' => 'Descargando Geo RuleSet por proxy',
			'meta.geoRulesetTips' => 'Geosite/Geoip se convertirán en el RuleSet correspondiente',
			'meta.sniffer' => 'Sniffer',
			'meta.userAgent' => 'UserAgent',
			'meta.launchAtStartup' => 'Ejecutar al Inicio',
			'meta.launchAtStartupRunAsAdmin' => 'Por favor, reinicie Mclash como administrador',
			'meta.tunModeRunAsAdmin' => 'El modo TUN requiere permisos de administrador del sistema, por favor reinicie la aplicación como administrador',
			'meta.portableMode' => 'Modo Portátil',
			'meta.portableModeDisableTips' => 'Si necesita salir del modo portátil, cierre [mclash] y elimine manualmente la carpeta [portable] en el mismo directorio que [mclash.exe]',
			'meta.autoConnectAfterLaunch' => 'Conexión Automática tras Inicio',
			'meta.autoConnectAtBoot' => 'Conexión Automática tras Inicio del Sistema',
			'meta.autoConnectAtBootTips' => 'Se requiere soporte del sistema; algunos sistemas también pueden requerir que el [autoinicio] esté habilitado.',
			'meta.hideAfterLaunch' => 'Ocultar ventana después del inicio',
			'meta.autoSetSystemProxy' => 'Autoestablecer Proxy del Sistema al Conectar',
			'meta.bypassSystemProxy' => 'Nombres de dominio permitidos para omitir el proxy del sistema',
			'meta.excludeFromRecent' => 'Ocultar de [Tareas Recientes]',
			'meta.wakeLock' => 'Bloqueo de Despertar',
			'meta.hideDockIcon' => 'Ocultar Icono del Dock',
			'meta.showTrayTraffic' => 'Mostrar información de tráfico en la bandeja',
			'meta.website' => 'Sitio Web',
			'meta.rule' => 'Regla',
			'meta.global' => 'Global',
			'meta.direct' => 'Directo',
			'meta.qrcode' => 'Código QR',
			'meta.qrcodeTooLong' => 'El texto es demasiado largo para mostrarse',
			'meta.qrcodeShare' => 'Compartir Código QR',
			'meta.qrcodeScan' => 'Escanear Código QR',
			'meta.qrcodeScanResult' => 'Resultado del Escaneo',
			'meta.backupAndSync' => 'Copia de Seguridad y Sincronización',
			'meta.export' => 'Exportar',
			'meta.send' => 'Enviar',
			'meta.sendConfirm' => '¿Confirmar envío?',
			'meta.log' => 'Registro',
			'meta.coreLog' => 'Registro del Núcleo',
			'meta.appLog' => 'Registro de la app',
			'meta.core' => 'Núcleo',
			'meta.help' => 'Ayuda',
			'meta.tutorial' => 'Tutorial',
			'meta.board' => 'Tablero',
			'meta.boardOnline' => 'Usar Tablero en Línea',
			'meta.boardOnlineUrl' => 'URL del Tablero en Línea',
			'meta.boardLocalPort' => 'Puerto del Tablero Local',
			'meta.alwayOnVPN' => 'Conexión permanente',
			'meta.disableFontScaler' => 'Deshabilitar escala de fuente (el reinicio surte efecto)',
			'meta.autoOrientation' => 'Girar con la pantalla',
			'meta.restartTakesEffect' => 'El reinicio surte efecto',
			'meta.reconnectTakesEffect' => 'La reconexión surte efecto',
			'meta.runtimeProfile' => 'Perfil de Tiempo de Ejecución',
			'meta.willCompleteAfterRebootInstall' => 'Por favor, reinicie su dispositivo para completar la instalación de la extensión del sistema',
			'meta.requestNeedsUserApproval' => '1. Por favor [Permitir] que Mclash instale extensiones del sistema en [Ajustes del Sistema]-[Privacidad y Seguridad]\n2. [Ajustes del Sistema]-[General]-[Extensiones de Ítems de Inicio]-[Extensión de Red] habilite [mclashServiceSE]\nreconnecte después de completar',
			'meta.FullDiskAccessPermissionRequired' => 'Por favor, habilite el permiso mclashServiceSE en [Ajustes del Sistema]-[Privacidad y Seguridad]-[Acceso Total al Disco] y vuelva a conectar.',
			'meta.proxy' => 'Proxy',
			'meta.theme' => 'Tema',
			'meta.tvMode' => 'Modo TV',
			'meta.autoUpdate' => 'Actualización Automática',
			'meta.updateChannel' => 'Canal de Actualización Automática',
			'meta.hasNewVersion' => ({required Object p}) => 'Actualizar Versión ${p}',
			'meta.autoDownloadPkg' => 'Descargar Paquetes de Actualización Automáticamente',
			'meta.devOptions' => 'Opciones de Desarrollador',
			'meta.about' => 'Acerca de',
			'meta.name' => 'Nombre',
			'meta.version' => 'Versión',
			'meta.sort' => 'Reordenar',
			'meta.share' => 'Compartir',
			'meta.importFromClipboard' => 'Importar desde el Portapapeles',
			'meta.exportToClipboard' => 'Exportar al Portapapeles',
			'meta.server' => 'Servidor',
			'meta.port' => 'Puerto',
			'meta.donate' => 'Donar',
			'meta.setting' => 'Ajustes',
			'meta.settingCore' => 'Ajustes del Núcleo',
			'meta.settingApp' => 'Ajustes de la App',
			'meta.coreOverwrite' => 'Sobrescritura del Núcleo',
			'meta.iCloud' => 'iCloud',
			'meta.webdav' => 'Webdav',
			'meta.lanSync' => 'Sincronización LAN',
			'meta.lanSyncNotQuitTips' => 'No salga de esta interfaz antes de que se complete la sincronización',
			'meta.deviceNoSpace' => 'No hay suficiente espacio en disco',
			'meta.hideSystemApp' => 'Ocultar Aplicaciones del Sistema',
			'meta.hideAppIcon' => 'Ocultar Iconos de App',
			'meta.openDir' => 'Abrir Directorio de Archivos',
			'meta.type' => 'Tipo',
			'meta.fileNotExist' => ({required Object p}) => 'El archivo no existe: ${p}',
			'meta.buyProfile' => 'Comprar Perfil',
			'meta.myProfiles' => 'Mis Perfiles',
			'meta.profileEdit' => 'Editar Perfil',
			'meta.profileNeedActive' => 'Primero establece este perfil como perfil actual y luego inicia/reconecta',
			'meta.profileUrlOrContent' => ({required Object p}) => 'Enlace de Perfil ${p}',
			'meta.tabHome' => 'Inicio',
			'meta.tabNodes' => 'Nodos',
			'meta.tabPlans' => 'Planes',
			'meta.tabMe' => 'Yo',
			'permission.camera' => 'Cámara',
			'permission.screen' => 'Grabación de Pantalla',
			'permission.appQuery' => 'Obtener Lista de Aplicaciones',
			'permission.request' => ({required Object p}) => 'Activar permiso de [${p}]',
			'permission.requestNeed' => ({required Object p}) => 'Por favor, active el permiso de [${p}]',
			'tls.certificate' => 'Certificado',
			'tls.privateKey' => 'Clave Privada',
			'tls.customTrustCert' => 'Certificados Personalizados',
			'tun.stack' => 'Pila de red',
			'tun.inet4Address' => 'Dirección de Puerta de Enlace IPv4',
			'tun.dnsHijack' => 'Secuestro de DNS',
			'tun.strictRoute' => 'Ruta Estricta',
			'tun.tunDefaultRoute' => 'Ruta predeterminada',
			'tun.icmpForward' => 'Reenvío ICMP',
			'tun.allowBypass' => 'Permitir aplicaciones para omitir VPN',
			'tun.appendHttpProxy' => 'Anexar Proxy HTTP a VPN',
			'tun.bypassHttpProxyDomain' => 'Dominios permitidos para omitir el proxy HTTP',
			'dns.listen' => 'Escuchar',
			'dns.fakeIp' => 'fake-ip',
			'dns.fallback' => 'Fallback',
			'dns.preferH3' => 'Preferir DoH H3',
			'dns.useHosts' => 'Usar Hosts',
			'dns.useSystemHosts' => 'Usar Hosts del Sistema',
			'dns.enhancedMode' => 'Modo Mejorado',
			'dns.fakeIPFilterMode' => 'Modo de Filtro ${_root.dns.fakeIp}',
			'dns.fakeIPFilter' => 'Filtro fake-ip',
			'dns.respectRules' => 'Respetar Reglas',
			'dns.nameServer' => 'Servidor de Nombres',
			'dns.defaultNameServer' => '${_root.meta.byDefault} ${_root.dns.nameServer}',
			'dns.proxyNameServer' => '${_root.meta.proxy} ${_root.dns.nameServer}',
			'dns.directNameServer' => '${_root.meta.direct} ${_root.dns.nameServer}',
			'dns.fallbackNameServer' => '${_root.dns.fallback} ${_root.dns.nameServer}',
			'dns.fallbackGeoIp' => '${_root.dns.fallback} GeoIp',
			'dns.fallbackGeoIpCode' => '${_root.dns.fallback} GeoIpCode',
			'sniffer.overrideDest' => 'Sobrescribir',
			'profilePatchMode.currentSelected' => 'Seleccionado Actual',
			'profilePatchMode.overwrite' => 'Sobrescritura Integrada',
			'profilePatchMode.noOverwrite' => 'Integrado - sin sobrescritura',
			'sendOrReceiveNotMatch' => ({required Object p}) => 'Utilice [${p}]',
			'targetConnectFailed' => ({required Object p}) => 'Error al conectar con [${p}]. Asegúrese de que los dispositivos estén en la misma LAN',
			'edgeRuntimeNotInstalled' => 'El dispositivo actual no ha instalado el motor de ejecución Edge WebView2, por lo que la página no se puede mostrar. Descargue e instale el motor de ejecución Edge WebView2 (x64), reinicie la App e inténtelo de nuevo.',
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
			'countries.TW' => 'Taiwán',
			'countries.MO' => 'Macao',
			'countries.CN' => 'China',
			'countries.JP' => 'Japón',
			'countries.KR' => 'Corea del Sur',
			'countries.SG' => 'Singapur',
			'countries.MY' => 'Malasia',
			'countries.TH' => 'Tailandia',
			'countries.VN' => 'Vietnam',
			'countries.PH' => 'Filipinas',
			'countries.ID' => 'Indonesia',
			'countries.KH' => 'Camboya',
			'countries.US' => 'Estados Unidos',
			'countries.CA' => 'Canadá',
			'countries.MX' => 'México',
			'countries.GB' => 'Reino Unido',
			'countries.DE' => 'Alemania',
			'countries.FR' => 'Francia',
			'countries.NL' => 'Países Bajos',
			'countries.RU' => 'Rusia',
			'countries.IT' => 'Italia',
			'countries.ES' => 'España',
			'countries.CH' => 'Suiza',
			'countries.SE' => 'Suecia',
			'countries.NO' => 'Noruega',
			'countries.FI' => 'Finlandia',
			'countries.DK' => 'Dinamarca',
			'countries.PL' => 'Polonia',
			'countries.AT' => 'Austria',
			'countries.IE' => 'Irlanda',
			'countries.UA' => 'Ucrania',
			'countries.TR' => 'Turquía',
			'countries.PT' => 'Portugal',
			'countries.CZ' => 'Chequia',
			'countries.RO' => 'Rumanía',
			'countries.BE' => 'Bélgica',
			'countries.GR' => 'Grecia',
			'countries.HU' => 'Hungría',
			'countries.IL' => 'Israel',
			'countries.AE' => 'Emiratos Árabes Unidos',
			'countries.SA' => 'Arabia Saudí',
			'countries.EG' => 'Egipto',
			'countries.ZA' => 'Sudáfrica',
			'countries.NG' => 'Nigeria',
			'countries.AU' => 'Australia',
			'countries.NZ' => 'Nueva Zelanda',
			'countries.BR' => 'Brasil',
			'countries.AR' => 'Argentina',
			'countries.CL' => 'Chile',
			'countries.CO' => 'Colombia',
			'countries.IN' => 'India',
			'countries.PK' => 'Pakistán',
			'countries.XX' => 'Otro',
			'meScreen.accountBalance' => 'Saldo',
			'meScreen.expireAt' => 'Vence',
			'meScreen.remainingDays' => 'Días restantes',
			'meScreen.deviceCount' => 'Dispositivos',
			'meScreen.myOrders' => 'Mis pedidos',
			'meScreen.deviceManagement' => 'Gestión de dispositivos',
			'meScreen.changePassword' => 'Cambiar contraseña',
			'meScreen.clearLocalData' => 'Borrar datos locales (antes de desinstalar)',
			'meScreen.profileManagementDev' => 'Gestión de perfiles (desarrollador)',
			'meScreen.tunAdapter' => 'Adaptador virtual TUN',
			'meScreen.checkUpdate' => 'Buscar actualizaciones',
			'meScreen.retry' => 'Reintentar',
			'meScreen.loadFailed' => 'No se pudo cargar la cuenta: la sesión pudo vencer o la red no está disponible.\nToca Actualizar arriba a la derecha para reintentar; si sigue fallando, inicia sesión de nuevo.',
			'meScreen.logoutConfirm' => '¿Cerrar sesión?',
			'meScreen.boardNoKernel' => 'El panel muestra los datos en vivo del núcleo (conexión, tráfico, reglas activadas).\n\nEl núcleo no está en ejecución, así que el panel estaría vacío.\nToca Aceptar para abrirlo igualmente, o Cancelar para conectar antes en Inicio.',
			'meScreen.boardOpened' => 'Panel abierto en tu navegador; cambia nodos o reglas allí y la app se actualiza en unos 5 segundos.',
			'homeScreen.expiresOn' => ({required Object date}) => 'Vence el ${date}',
			'homeScreen.devicesText' => ({required Object text}) => 'Dispositivos ${text}',
			'homeScreen.upgrade' => 'Mejorar',
			'homeScreen.quickCountries' => 'Filtro rápido por país',
			'homeScreen.nodeCount' => ({required Object count}) => '${count} nodos',
			'homeScreen.autoBestTip' => 'Elige el nodo disponible con menor latencia de todos los países (modo automático)',
			'homeScreen.autoBest' => 'Mejor automático',
			'homeScreen.pickCountryTip' => ({required Object label}) => 'Selecciona y fija el nodo disponible con menor latencia en «${label}»',
			'homeScreen.autoNoBetter' => 'Ya estás en modo automático (no se encontró un nodo mejor)',
			'homeScreen.switchedBest' => ({required Object name}) => 'Cambiado al mejor nodo: ${name}',
			'homeScreen.switchedCountry' => ({required Object country, required Object node, required Object ms}) => 'Cambiado al nodo ${country} más rápido: ${node}${ms}',
			'homeScreen.filterCountryFailed' => ({required Object country, required Object err}) => 'Filtrado por ${country}; fallo al cambiar: ${err}',
			'homeScreen.deviceFullCount' => ({required Object used, required Object limit}) => 'Dispositivos actuales ${used}/${limit}\n\n',
			'homeScreen.deviceFullUpgradeHint' => 'Mejorar el límite de dispositivos restaura la conexión de inmediato (recomendado); también puedes eliminar dispositivos sin usar para liberar un espacio.',
			'homeScreen.later' => 'Más tarde',
			'homeScreen.upgradeDeviceCount' => 'Mejorar límite de dispositivos',
			'homeScreen.cannotConnect' => 'No se puede conectar',
			'homeScreen.freshnessNever' => 'Aún sin sincronizar · toca para actualizar',
			'homeScreen.freshnessJustNow' => 'Actualizado ahora mismo · toca Gestionar dispositivos',
			'homeScreen.freshnessMinutes' => ({required Object minutes}) => 'Hace ${minutes} min · toca Gestionar dispositivos',
			'homeScreen.freshnessStale' => ({required Object minutes}) => 'Hace ${minutes} min · toca para actualizar',
			'homeScreen.subscriptionAutoSync' => 'Sincronización automática',
			'homeScreen.connecting' => 'Conectando…',
			'homeScreen.disconnecting' => 'Desconectando…',
			'homeScreen.tapToDisconnect' => 'Toca el interruptor para desconectar',
			'homeScreen.tapToConnect' => 'Toca el interruptor para conectar',
			'homeScreen.currentNode' => 'Nodo actual',
			'homeScreen.noNodeSelected' => 'Ningún nodo seleccionado',
			'homeScreen.switchAction' => 'Cambiar',
			'homeScreen.realtimeSpeed' => 'Velocidad en tiempo real',
			'homeScreen.totalTraffic' => 'Tráfico total',
			'homeScreen.subSyncedNotReady' => 'Suscripción descargada, pero el perfil aún no está listo. Inténtalo de nuevo en un momento.',
			'homeScreen.noPlan' => 'Esta cuenta aún no tiene un plan disponible. Compra uno primero.',
			'homeScreen.loginExpired' => 'Tu sesión ha vencido. Inicia sesión de nuevo.',
			'homeScreen.syncingWait' => 'Sincronizando la suscripción, espera un momento.',
			'homeScreen.syncFailedNetwork' => ({required Object message}) => 'Fallo al sincronizar la suscripción: ${message}\nComprueba tu red e inténtalo de nuevo.',
			'homeScreen.syncFailed' => 'Fallo al sincronizar la suscripción, inténtalo más tarde.',
			'homeScreen.resetProxy' => 'Restablecer',
			'homeScreen.latencySuffix' => ({required Object ms}) => ' (${ms}ms)',
			'nodesScreen.updatedCount' => ({required Object count}) => 'Suscripción actualizada: ${count} nodos',
			'nodesScreen.updateFailed' => ({required Object message}) => 'Fallo al actualizar: ${message}',
			'nodesScreen.updateFailedNetwork' => 'Fallo al actualizar, comprueba tu red',
			'nodesScreen.testDone' => ({required Object ok, required Object fail}) => 'Prueba completada: ${ok} accesibles, ${fail} inaccesibles (pueden estar sin conexión)',
			'nodesScreen.switchedTo' => ({required Object name}) => 'Cambiado a ${name}',
			'nodesScreen.switchFailed' => ({required Object message}) => 'Fallo al cambiar: ${message}\n(Cambiar de nodo requiere el núcleo en ejecución; activa antes el interruptor en Inicio.)',
			'nodesScreen.selectedAfterConnect' => ({required Object name}) => '${name} seleccionado (surte efecto al conectar)',
			'nodesScreen.title' => 'Nodos',
			'nodesScreen.searchNode' => 'Buscar nodos',
			'nodesScreen.sortByLatency' => 'Ordenar por latencia',
			'nodesScreen.updateSubscription' => 'Actualizar suscripción',
			'nodesScreen.viewByGroup' => 'Ver por grupo de proxy',
			'nodesScreen.testAll' => 'Probar todo',
			'nodesScreen.searchHint' => 'Buscar nodo / país / protocolo',
			'nodesScreen.emptyNoNodes' => 'Aún no hay nodos disponibles.\nLas suscripciones se sincronizan solas; si acabas de iniciar sesión, espera un momento o toca recargar abajo.',
			'nodesScreen.emptyNoMatch' => 'No hay nodos coincidentes.',
			'nodesScreen.reload' => 'Recargar',
			'nodesScreen.currentInUse' => 'Actual (en uso)',
			'nodesScreen.current' => 'Actual',
			'nodesScreen.notTested' => 'Sin medir (reinicio del núcleo pendiente)',
			'nodesScreen.timeout' => 'Tiempo agotado',
			'nodesScreen.clear' => 'Limpiar',
			'nodesScreen.selectNode' => 'Seleccionar nodo',
			'nodesScreen.emptyNoKernel' => 'Aún no hay nodos disponibles.\nActiva antes el interruptor de conexión en Inicio.',
			'nodesScreen.openFullList' => 'Abrir la lista completa de nodos (buscar / prueba de velocidad / grupos)',
			'nodeAuto.kernelStateUnavailable' => 'El estado de los nodos no está disponible temporalmente desde el núcleo; se reintentará automáticamente.',
			'nodeAuto.backToFixedNode' => ({required Object fixed}) => 'De vuelta al nodo fijado: ${fixed}',
			'nodeAuto.noUsableNodePickOne' => 'No se encontró ningún nodo usable. Elige uno manualmente en la lista de nodos.',
			'nodeAuto.noUsableNodeTryOne' => 'No se encontró ningún nodo usable. Prueba a elegir uno en la lista de nodos.',
			'nodeAuto.autoConnectedBest' => ({required Object bestNode, required Object bestMs}) => 'Conectado automáticamente al mejor nodo: ${bestNode} (${bestMs} ms)',
			'nodeAuto.currentNodeUnreachable' => 'El nodo actual no tiene acceso a internet; cambiando automáticamente…',
			'nodeAuto.autoSwitchedToUsable' => ({required Object target}) => 'Cambiado automáticamente a un nodo usable: ${target}',
			'nodeAuto.newNodesReloading' => ({required Object missing}) => '${missing} nodo(s) nuevo(s) de la suscripción aún no están en el núcleo; recargando…',
			'nodeAuto.kernelReloadedRetest' => 'El núcleo se recargó con la nueva suscripción; vuelve a ejecutar la prueba de velocidad.',
			'accountBlock.quotaFull' => ({required Object used, required Object limit}) => 'Los espacios de dispositivos están llenos (${used}/${limit}): este dispositivo aún está dentro del rango con licencia y puede conectarse con normalidad. Para añadir otro dispositivo, mejora el límite de dispositivos o elimina los que no uses.',
			'accountBlock.banFallback' => 'Tu cuenta ha sido deshabilitada y ya no se puede usar.',
			'accountBlock.titleExpired' => 'Plan vencido',
			'accountBlock.titleDeviceFull' => 'Límite de dispositivos alcanzado',
			'accountBlock.titleAccountDisabled' => 'Cuenta deshabilitada',
			'accountBlock.titlePlanDisabled' => 'Plan deshabilitado',
			'accountBlock.titleNoPlan' => 'Aún sin plan',
			'accountBlock.titleDeviceRemoved' => 'Este dispositivo fue eliminado',
			'accountBlock.titleServiceUnavailable' => 'Servicio no disponible temporalmente',
			'accountBlock.textExpired' => 'Tu plan ha vencido. Compra un plan para seguir usando los nodos globales.',
			'accountBlock.textDeviceFull' => ({required Object used, required Object limit}) => 'El servidor ha determinado que este dispositivo supera el límite de dispositivos del plan (${used}/${limit}), así que por ahora no puede conectarse. Elimina dispositivos sin usar en Yo - Gestión de dispositivos, o mejora a un plan con más dispositivos.',
			'accountBlock.textAccountDisabled' => 'Tu cuenta ha sido deshabilitada. Contacta con soporte si tienes dudas.',
			'accountBlock.textPlanDisabled' => 'Tu plan ha sido deshabilitado o está en un estado anómalo, así que no puedes conectarte. Contacta con soporte si tienes dudas.',
			'accountBlock.textNoPlan' => 'Aún no has comprado un plan. Compra uno para usar los nodos globales.',
			'accountBlock.textDeviceRemoved' => 'Este dispositivo fue eliminado y se cerró su sesión. Inicia sesión de nuevo.',
			'accountBlock.textServiceUnavailable' => 'El servicio no está disponible temporalmente. Inténtalo más tarde; si persiste, haz una captura y contacta con soporte.',
			'accountBlock.remainingDays' => ({required Object days}) => 'Quedan ${days} días',
			'accountBlock.deviceUsage' => ({required Object used, required Object limit}) => 'Dispositivos ${used}/${limit}',
			'entitlementMsg.tamperedTitle' => 'Estado de autorización anómalo',
			'entitlementMsg.tamperedClock' => 'Se detectó un retroceso del reloj del sistema (o manipulación de los datos de autorización locales). Conéctate a internet para completar una verificación antes de conectar.',
			'entitlementMsg.tamperedLocal' => 'Los datos de autorización locales están dañados o han sido modificados. Conéctate a internet para completar una verificación antes de conectar.',
			'entitlementMsg.needVerifyTitle' => 'Se requiere verificación en línea',
			'entitlementMsg.needVerifyFirst' => 'No se puede confirmar el estado de tu plan: conéctate a la red e inicia sesión, y completa una verificación antes de conectar.',
			'entitlementMsg.needVerifyRetry' => 'No se puede confirmar el estado de tu plan. Conéctate a internet e inténtalo de nuevo.',
			'entitlementMsg.verifyFailedTitle' => 'No se puede verificar el estado del plan',
			'entitlementMsg.verifyFailedText' => 'El periodo de gracia de verificación ha terminado y el servidor no responde. Comprueba tu red e inténtalo de nuevo (si acabas de renovar, inicia sesión otra vez).',
			'entitlementMsg.restrictedTitle' => 'Cuenta restringida',
			'entitlementMsg.restrictedFallback' => 'Tu cuenta o tu plan ha sido deshabilitado, así que no puedes conectarte.',
			'entitlementMsg.expiredTitle' => 'Plan vencido',
			'entitlementMsg.expiredText' => ({required Object date}) => 'Tu plan venció el ${date}. Se ha borrado el perfil de suscripción local. Renueva e inicia sesión de nuevo para restaurarlo.',
			'devicesScreen.title' => 'Gestión de dispositivos',
			'devicesScreen.currentPlan' => 'Plan actual',
			'devicesScreen.devicesText' => ({required Object text}) => 'Dispositivos ${text}',
			'devicesScreen.upgradeTitle' => 'Mejorar dispositivos / ampliar tiempo',
			'devicesScreen.upgradeSubtitle' => 'Añade dispositivos y días juntos; un solo precio, un solo pago',
			'devicesScreen.addDevices' => 'Añadir dispositivos',
			'devicesScreen.noAddDevices' => 'Sin cambios',
			'devicesScreen.addDevicesCount' => ({required Object n}) => '+${n} dispositivos',
			'devicesScreen.addDays' => 'Añadir días',
			'devicesScreen.noExtend' => 'Sin ampliación',
			'devicesScreen.addDaysCount' => ({required Object n, required Object months}) => '+${n} días (${months} meses)',
			'devicesScreen.priceFailed' => 'No se pudo obtener el precio',
			'devicesScreen.amountDue' => ({required Object amount}) => 'Total ¥${amount}',
			'devicesScreen.requote' => 'Recalcular',
			'devicesScreen.goPay' => 'Pagar ahora',
			'devicesScreen.afterUpgrade' => 'Tras mejorar: ',
			'devicesScreen.afterLimit' => ({required Object limit}) => 'límite de dispositivos ${limit}',
			'devicesScreen.afterExpire' => ({required Object date}) => 'vence el ${date}',
			'devicesScreen.pickSomething' => 'Añade al menos algunos dispositivos o días',
			'devicesScreen.daysOnlyUnsupported' => 'El panel aún no admite «solo ampliar tiempo»: pon «Añadir dispositivos» en 1 o más e inténtalo de nuevo (o contacta con soporte para habilitarlo).',
			'devicesScreen.paramsRejected' => 'Parámetros rechazados: vuelve a elegir la cantidad de dispositivos y los días.',
			'devicesScreen.subscriptionExpired' => 'La suscripción ha vencido, así que no se puede mejorar. Renueva o compra un plan primero.',
			'devicesScreen.orderIncomplete' => 'La información del pedido está incompleta. Toca «Recalcular» e inténtalo de nuevo.',
			'devicesScreen.orderRegenerated' => 'El pedido anterior venció; se ha creado uno nuevo con los mismos ajustes.',
			'devicesScreen.payChannelIncomplete' => 'La información del pedido o del canal de pago está incompleta. Recalcula e inténtalo de nuevo.',
			'devicesScreen.noQrCode' => 'El servidor no devolvió un código QR ni un enlace de pago. Elige otro método de pago o inténtalo más tarde.',
			'devicesScreen.payStartFailed' => ({required Object err}) => 'No se pudo iniciar el pago: ${err}',
			'devicesScreen.payCancelled' => 'Pago cancelado; el pedido en borrador se ha eliminado.',
			'devicesScreen.balancePay' => 'Saldo',
			'devicesScreen.noPayMethod' => 'Ahora mismo no hay ningún método de pago disponible. Inténtalo más tarde o contacta con soporte.',
			'devicesScreen.balanceInsufficient' => ({required Object balance, required Object amount}) => 'Saldo insuficiente (¥${balance}, se necesitan ¥${amount}).\n¿Recargar primero?',
			'devicesScreen.choosePayMethod' => 'Elige un método de pago',
			'devicesScreen.balanceText' => ({required Object balance}) => 'Saldo ¥${balance}',
			'devicesScreen.balanceShort' => ({required Object balance}) => 'Saldo ¥${balance} (insuficiente, recarga)',
			'devicesScreen.unknownDevice' => 'Dispositivo desconocido',
			'devicesScreen.online' => '● En línea',
			'devicesScreen.offline' => '○ Sin conexión',
			'devicesScreen.lastActive' => ({required Object text}) => 'Última actividad ${text}',
			'devicesScreen.delete' => 'Eliminar',
			'devicesScreen.deleteConfirm' => ({required Object name}) => '¿Eliminar el dispositivo «${name}»? Se desconectará de inmediato.',
			'devicesScreen.lastActiveJustNow' => 'Ahora mismo',
			'devicesScreen.lastActiveMinutes' => ({required Object minutes}) => 'hace ${minutes} min',
			'devicesScreen.lastActiveToday' => ({required Object time}) => 'Hoy ${time}',
			'sysProxySheet.reading' => 'Leyendo…',
			'sysProxySheet.unknown' => 'Desconocido',
			'sysProxySheet.kernelNotRunning' => 'El núcleo no está en ejecución (activa antes el interruptor en Inicio)',
			'sysProxySheet.applied' => ({required Object host, required Object port}) => 'Aplicado · ${host}:${port}',
			'sysProxySheet.notSet' => ({required Object reason}) => 'Proxy del sistema no configurado — ${reason}',
			'sysProxySheet.notEffective' => ({required Object port}) => 'Sin efecto (ningún proxy del sistema apunta a ${port})',
			'sysProxySheet.readFailed' => ({required Object err}) => 'Fallo al leer: ${err}',
			'sysProxySheet.setRejected' => 'No se pudo configurar: puede que el sistema rechazara la escritura (u otra app de proxy la sobrescribiera)',
			'sysProxySheet.disableFailed' => 'No se pudo desactivar',
			'sysProxySheet.portRange' => 'El puerto debe estar entre 1 y 65535',
			'sysProxySheet.portChanged' => ({required Object value}) => 'Puerto cambiado a ${value}: desconecta y vuelve a conectar para que el núcleo escuche en el nuevo puerto',
			'sysProxySheet.title' => 'Proxy del sistema',
			'sysProxySheet.desc' => ({required Object host}) => 'La dirección del proxy del sistema está fijada a ${host} (bucle local) y el puerto es el puerto mixto del núcleo.',
			'sysProxySheet.descWindows' => 'Esto es exactamente lo que ves en Ajustes de Windows → Red e Internet → Proxy.',
			'sysProxySheet.reset' => 'Volver a configurar',
			'sysProxySheet.disable' => 'Desactivar proxy del sistema',
			'sysProxySheet.diagnostics' => 'Diagnóstico (¿la interfaz lee los mismos valores que el registro?)',
			'sysProxySheet.mixedPort' => 'Puerto mixto',
			'sysProxySheet.apply' => 'Aplicar',
			'logScreen.readAppFailed' => ({required Object e}) => 'Fallo al leer el registro de la app: ${e}',
			_ => null,
		} ?? switch (path) {
			'logScreen.readCoreFailed' => ({required Object e}) => 'Fallo al leer el registro del núcleo: ${e}',
			'logScreen.copied' => 'Copiado (las URL de suscripción y otros secretos van ocultos; el archivo de registro puede contener aún la dirección real)',
			'logScreen.copy' => 'Copiar',
			'logScreen.refresh' => 'Actualizar',
			'logScreen.empty' => 'Sin contenido',
			'trayShell.closeTitle' => 'Cerrar ventana',
			'trayShell.closeBody' => 'Cerrar la ventana solo pone Mclash en la bandeja: el núcleo y el proxy del sistema siguen funcionando y tu red permanece conectada.\n\n· Aceptar: minimizar a la bandeja (para salir por completo, clic derecho en el icono de la bandeja → Salir)\n· Cancelar: cerrar Mclash por completo, detener el núcleo y restaurar el proxy del sistema\n\n(Tu elección se recuerda; la próxima vez puedes usar directamente el icono de la bandeja)',
			'ordersScreen.title' => 'Mis pedidos',
			'ordersScreen.orderInfoIncomplete' => 'La información del pedido está incompleta. Desliza hacia abajo para actualizar e inténtalo de nuevo.',
			'ordersScreen.payChannelIncomplete' => 'La información del canal de pago está incompleta. Inténtalo más tarde.',
			'ordersScreen.noQrPayload' => 'El servidor no devolvió un código QR ni un enlace de pago. Elige otro método de pago o inténtalo más tarde.',
			'ordersScreen.payStartFailed' => ({required Object err}) => 'No se pudo iniciar el pago: ${err}',
			'ordersScreen.noPayMethod' => 'Ahora mismo no hay ningún método de pago disponible. Inténtalo más tarde o contacta con soporte.',
			'ordersScreen.choosePayMethod' => 'Elige un método de pago',
			'ordersScreen.amountDue' => ({required Object amount}) => 'Importe a pagar ¥${amount}',
			'ordersScreen.paidLabel' => '● Pagado',
			'ordersScreen.pendingLabel' => '○ Sin pagar',
			'ordersScreen.unknownStatus' => ({required Object status}) => '✕ ${status}',
			'ordersScreen.orderNoText' => ({required Object orderNo}) => 'Pedido n.º ${orderNo}',
			'ordersScreen.createdAtText' => ({required Object createdAt}) => 'Creado el ${createdAt}',
			'ordersScreen.orderCanceled' => 'Pedido cancelado',
			'ordersScreen.cancelFailed' => ({required Object err}) => 'Fallo al cancelar: ${err}\n(Si el pedido ya se ha pagado o cancelado, desliza hacia abajo para ver el estado más reciente.)',
			'ordersScreen.cancelOrder' => 'Cancelar pedido',
			'ordersScreen.continuePay' => 'Continuar pago',
			'payment.balancePay' => 'Pago con saldo',
			'payment.qrPay' => 'Escanear para pagar',
			'payment.deductFromBalance' => 'Se deduce del saldo de tu cuenta',
			'payment.openedInBrowser' => 'La página de pago se ha abierto en tu navegador',
			'payment.scanWithAlipayWechat' => 'Escanea con Alipay o WeChat',
			'payment.orderNoText' => ({required Object orderNo}) => 'Pedido n.º ${orderNo}',
			'payment.payFailed' => ({required Object err}) => 'Pago fallido: ${err}',
			'payment.notDetected' => 'No se detectó ningún pago. Puedes continuar más tarde en «Mis pedidos».',
			'payment.charging' => 'Cobrando…',
			'payment.processing' => 'Procesando…',
			'payment.waitingPay' => 'Esperando el pago…',
			'payment.openPageFailed' => 'No se pudo abrir la página de pago. Toca el botón de abajo para reintentar, o escanea el código QR.',
			'payment.reopenPayPage' => 'Reabrir página de pago',
			'payment.payInBrowser' => 'Pagar en el navegador',
			'payment.openAlipay' => 'Abrir Alipay',
			'payment.cancelOrder' => 'Cancelar pedido',
			'payment.confirmPay' => 'Confirmar pago',
			'payment.retry' => 'Reintentar',
			'payment.paidAlready' => 'Ya he pagado',
			'payment.channelAlipay' => 'Alipay',
			'payment.channelCodepayAlipay' => 'Pago con código · Alipay',
			'payment.channelCodepayWechat' => 'Pago con código · WeChat',
			'payment.channelCodepay' => 'Pago con código',
			'payment.channelWechat' => 'WeChat Pay',
			'payment.channelUsdt' => 'USDT',
			'payment.channelUsdtTrc20' => 'USDT · TRC20',
			'payment.payFallback' => 'Pago',
			'payment.errCsrf' => 'Tu credencial de acceso ha vencido (fallo en la comprobación CSRF).\nDesliza hacia abajo en la pestaña «Yo» para actualizar o inicia sesión de nuevo, y luego reintenta.',
			'payment.errAlipayLimit' => 'El pago presencial de Alipay tiene un límite por transacción (¥1000 para este comercio) y este pedido lo supera.\nUsa «Pago con saldo» o «Pago con código», o contacta con soporte para aumentar el límite de Alipay.',
			'payment.errNotSigned' => 'La app de Alipay no tiene dado de alta el producto de pago correspondiente, así que este canal no está disponible temporalmente.\nUsa «Pago con saldo» o «Pago con código», o contacta con soporte para habilitarlo.',
			'payment.errOrderGone' => 'Este pedido se ha cancelado o ha vencido (los pedidos en borrador son válidos 30 minutos).\nToca «Recalcular» para crear un pedido nuevo y luego paga.',
			'payment.errNetwork' => ({required Object err}) => 'Red no disponible: ${err}',
			'planScreen.recommended' => 'Recomendado',
			'planScreen.devices' => 'Dispositivos',
			'planScreen.balanceLabel' => ({required Object amount}) => 'Saldo ¥${amount}',
			'planScreen.balanceInsufficient' => ' (Insuficiente, recarga primero)',
			'planScreen.total' => 'Total',
			'planScreen.payNow' => 'Pagar ahora',
			'planScreen.retry' => 'Reintentar',
			'planScreen.errIncompleteOrder' => 'La información del pedido o del canal de pago está incompleta; no se puede iniciar el pago.',
			'planScreen.payBalance' => 'Pago con saldo',
			'planScreen.payAlipay' => 'Alipay',
			'planScreen.payWechat' => 'WeChat Pay',
			'planScreen.payCodepay' => 'Pago con código',
			'planScreen.payCodepayAlipay' => 'Pago con código · Alipay',
			'planScreen.payCodepayWechat' => 'Pago con código · WeChat',
			'planScreen.payEpayAlipay' => 'Epay · Alipay',
			'planScreen.payEpayWechat' => 'Epay · WeChat',
			'planScreen.payUsdt' => 'USDT',
			'planScreen.payUsdtTrc20' => 'USDT · TRC20',
			'planScreen.payStripe' => 'Stripe',
			'planScreen.payPaypal' => 'PayPal',
			'planScreen.payOnline' => 'Pago en línea',
			'authScreen.saveAccountInfo' => 'Guardar datos de la cuenta',
			'authScreen.autoLoginNextTime' => 'Iniciar sesión automáticamente la próxima vez',
			'authScreen.needLoginNextTime' => 'La próxima vez tendrás que iniciar sesión de nuevo',
			'authScreen.invalidEmail' => 'Introduce un correo electrónico válido',
			'authScreen.enterEmailFirst' => 'Introduce primero un correo electrónico válido',
			'authScreen.passwordRequired' => 'Introduce tu contraseña',
			'authScreen.wrongCredentials' => 'Correo o contraseña incorrectos',
			'authScreen.requestRejected' => 'Solicitud rechazada. Inténtalo más tarde.',
			'authScreen.tooFrequent' => 'Demasiados intentos. Inténtalo más tarde.',
			'authScreen.loginFailed' => 'Fallo al iniciar sesión',
			'authScreen.username' => 'Nombre de usuario',
			'authScreen.confirmPassword' => 'Confirmar contraseña',
			'authScreen.inviteCode' => 'Código de invitación',
			'authScreen.emailCode' => 'Código de verificación del correo',
			'authScreen.getCode' => 'Obtener código',
			'authScreen.registerAndLogin' => 'Registrarse e iniciar sesión',
			'authScreen.usernameMinLength' => ({required Object min}) => 'El nombre de usuario debe tener al menos ${min} caracteres',
			'authScreen.passwordMismatch' => 'Las contraseñas no coinciden',
			'authScreen.emailCodeRequired' => 'Introduce el código de verificación del correo',
			'authScreen.inviteCodeRequired' => 'El registro en este sitio requiere un código de invitación',
			'authScreen.codeSentCheckEmail' => 'Código de verificación enviado. Revisa tu correo.',
			'authScreen.registerSuccess' => 'Registro correcto. Ya has iniciado sesión.',
			'authScreen.passwordHint' => ({required Object min}) => 'Al menos ${min} caracteres, con letras y números',
			'authScreen.passwordTooShort' => ({required Object min}) => 'La contraseña debe tener al menos ${min} caracteres',
			'authScreen.passwordNeedsLetterAndDigit' => 'La contraseña debe contener letras y números',
			'authScreen.registeredEmail' => 'Correo registrado',
			'authScreen.newPassword' => 'Nueva contraseña',
			'authScreen.confirmNewPassword' => 'Confirmar nueva contraseña',
			'authScreen.resetPassword' => 'Restablecer contraseña',
			'authScreen.resetCodeSent' => 'Si este correo está registrado, se ha enviado un código de restablecimiento (válido 15 minutos).',
			'authScreen.resetSuccess' => 'Contraseña restablecida. Inicia sesión con tu nueva contraseña.',
			'authScreen.changePasswordTitle' => 'Cambiar contraseña',
			'authScreen.currentPassword' => 'Contraseña actual',
			'authScreen.saveNewPassword' => 'Guardar nueva contraseña',
			'authScreen.newPasswordMismatch' => 'Las nuevas contraseñas no coinciden',
			'authScreen.changePasswordSuccess' => 'Contraseña cambiada. Inicia sesión de nuevo.',
			'updatePrompt.checking' => 'Buscando actualizaciones…',
			'updatePrompt.checkFailed' => 'Fallo al buscar actualizaciones. Comprueba tu red e inténtalo de nuevo.',
			'updatePrompt.alreadyLatest' => ({required Object version}) => 'Ya tienes la última versión (${version}).',
			'updatePrompt.newVersionFound' => ({required Object version}) => 'La nueva versión ${version} ya está disponible',
			'updatePrompt.installerDownloaded' => 'El instalador se ha descargado en segundo plano. Toca Actualizar ahora para completar la actualización.',
			'updatePrompt.downloadInBackground' => 'Toca Actualizar ahora para descargarlo e instalarlo (puedes seguir usando la app; el instalador se descarga en segundo plano).',
			'updatePrompt.later' => 'Más tarde',
			'updatePrompt.updateNow' => 'Actualizar ahora',
			'updatePrompt.installerNotReady' => ({required Object version}) => 'El instalador aún no ha terminado de descargarse.\n\nToca Aceptar para abrir la página de descarga y descargar manualmente el instalador correspondiente a tu dispositivo (versión ${version}).',
			'clearData.itemLoginSession' => 'Sesión de inicio de sesión',
			'clearData.itemProfiles' => 'Perfiles de suscripción (profiles/)',
			'clearData.itemSettings' => 'Ajustes de la app y del núcleo',
			'clearData.itemLatencyCache' => 'Caché de latencia de nodos',
			'clearData.itemLogs' => 'Registros de ejecución',
			'clearData.itemRoutingData' => 'Datos de enrutamiento y archivos temporales',
			'clearData.confirmBody' => ({required Object items, required Object dir}) => 'Se borrarán los siguientes datos guardados en este dispositivo (no se puede deshacer):\n\n${items}\n\nLa cuenta en sí y cualquier plan que hayas comprado están en el servidor y no se ven afectados; inicia sesión de nuevo para restaurar tu suscripción.\n\nDirectorio de datos: ${dir}\n(Hazlo antes de desinstalar la app: solo así la reinstalación empezará limpia y te pedirá iniciar sesión de nuevo)',
			'clearData.confirmAgain' => '¿Borrar ahora? Después tendrás que iniciar sesión de nuevo.',
			'clearData.clearedNotice' => ({required Object count, required Object dir}) => 'Se borraron ${count} elementos de datos locales (incluida la sesión, así que tendrás que iniciar sesión de nuevo la próxima vez que abras la app).\n\nYa puedes eliminar la app para terminar la desinstalación:\n· macOS: arrastra Mclash.app a la Papelera (el directorio de datos se ha vaciado: ${dir})\n· Windows: desinstala Mclash desde el Panel de control y elige No cuando el asistente pregunte si quieres conservar tus datos de usuario',
			'clearData.clearFailed' => ({required Object error}) => 'Fallo al borrar: ${error}',
			'apiError.requestFailedHttp' => ({required Object status, required Object domain}) => 'Solicitud fallida (HTTP ${status}); ya se probó ${domain}',
			'apiError.allDomainsFailed' => ({required Object method, required Object path, required Object count}) => 'Solicitud fallida: ${method} ${path} (se probaron ${count} dominios)',
			'apiError.requestTimeout' => ({required Object seconds, required Object method, required Object path}) => 'La solicitud agotó el tiempo de espera (${seconds}s): ${method} ${path}',
			'apiError.networkUnreachable' => ({required Object detail}) => 'Red no disponible: ${detail}',
			'apiError.tlsHandshakeFailed' => 'Fallo en el handshake TLS. Comprueba tu conexión de red o la hora del sistema.',
			'apiError.connectionFailed' => ({required Object detail}) => 'Fallo de conexión: ${detail}',
			'apiError.requestError' => ({required Object error}) => 'Solicitud fallida: ${error}',
			'apiError.responseReadTimeout' => ({required Object seconds, required Object method, required Object path}) => 'Se agotó el tiempo al leer la respuesta (${seconds}s): ${method} ${path}',
			'apiError.notJson' => ({required Object status, required Object snippet}) => 'La respuesta no es JSON (HTTP ${status}): ${snippet}',
			'apiError.badStructure' => ({required Object status}) => 'Estructura de respuesta inesperada (HTTP ${status})',
			'apiError.loginFailed' => ({required Object code}) => 'Fallo al iniciar sesión (código ${code})',
			'apiError.loginMissingData' => 'A la respuesta de inicio de sesión le faltan datos',
			'apiError.loginMissingToken' => 'A la respuesta de inicio de sesión le falta access_token',
			'apiError.registerFailed' => ({required Object code}) => 'Fallo en el registro (código ${code})',
			'apiError.registerMissingToken' => 'La respuesta de registro no trae access_token: puede haberse activado el control de riesgo, o el sitio está configurado de otra forma',
			'apiError.requestFailedCode' => ({required Object code}) => 'Solicitud fallida (código ${code})',
			'subNotice.titleNotFound' => 'Suscripción no encontrada',
			'subNotice.titleExpired' => 'Suscripción vencida',
			'subNotice.titleInactive' => 'Suscripción inactiva',
			'subNotice.titleDeviceOverLimit' => 'Límite de dispositivos superado',
			'subNotice.titleUnavailable' => 'Suscripción no disponible',
			'subNotice.titleWithReason' => ({required Object emoji, required Object title, required Object reason}) => '${emoji} ${title} (${reason})',
			'subNotice.deviceUsedOfLimit' => ({required Object used, required Object limit}) => 'Dispositivos actuales ${used}/${limit}',
			'subNotice.deviceUsedOnly' => ({required Object used}) => 'Dispositivos actuales ${used}',
			'subNotice.expireAt' => ({required Object expire}) => 'Vence el ${expire}',
			'subNotice.supportLine' => ({required Object account}) => '💬 Soporte: ${account}',
			'subNotice.siteLine' => ({required Object url}) => '📢 Sitio web: ${url}',
			'settingItems.subscriptionAutoUpdateInterval' => 'Intervalo de actualización automática de la suscripción',
			'settingItems.speedTestMode' => 'Método de prueba de velocidad',
			'settingItems.speedTestModeTcp' => 'Prueba de velocidad TCP',
			'settingItems.speedTestModeKernel' => 'Prueba de velocidad del núcleo',
			'settingItems.delayTestUrlTip' => 'Tiempo de una solicitud HTTP completa a través de este nodo (no es un ping)\nPor defecto usa una respuesta vacía http 204; con https se añade el handshake TLS y el número es mayor',
			'settingItems.systemProxy' => 'Proxy del sistema',
			'settingItems.systemProxyTip' => 'Ver / restablecer dirección y puerto',
			'settingItems.tunMode' => 'Modo TUN',
			'settingItems.tunModeTip' => 'off=solo proxy del sistema / auto=TUN+proxy del sistema / force=solo TUN\nEn escritorio, TUN requiere permisos de administrador (wintun en Windows / utun en macOS)',
			'settingItems.tunOverwriteTip' => 'overwrite\nActivado = los ajustes TUN de esta página sobrescriben la sección tun del perfil\nDesactivado = se usa la configuración tun del propio perfil (la app no interfiere)',
			'settingItems.tunEnableByTunMode' => ({required Object enable}) => '${enable} (según el modo TUN)',
			'settingItems.interval30Minutes' => '30 minutos',
			'settingItems.interval1Hour' => '1 hora',
			'settingItems.interval6Hours' => '6 horas',
			'settingItems.interval12Hours' => '12 horas',
			'settingItems.interval24Hours' => '24 horas',
			'settingItems.interval3Days' => '3 días',
			'settingItems.interval7Days' => '7 días',
			'settingItems.intervalNever' => 'Nunca',
			'settingItems.intervalMinutes' => ({required Object minutes}) => '${minutes} minutos',
			'settingItems.intervalHours' => ({required Object hours}) => '${hours} horas',
			'settingItems.intervalDays' => ({required Object days}) => '${days} días',
			'tunScreen.modeOff' => 'Desactivado',
			'tunScreen.modeAuto' => 'Auto',
			'tunScreen.modeForce' => 'Forzado',
			'tunScreen.modeOffDesc' => 'Solo proxy del sistema: funciona para los programas que respetan el proxy del sistema (navegadores, etc.); UDP y juegos no pasan por el proxy',
			'tunScreen.modeAutoDesc' => 'TUN + proxy del sistema (doble seguridad): todo el tráfico pasa por el adaptador virtual, incluido UDP',
			'tunScreen.modeForceDesc' => 'Solo TUN: todo el tráfico pasa por el adaptador virtual y el proxy del sistema no se toca',
			'tunScreen.modeOffOptionDesc' => 'No toca la tabla de rutas del sistema; solo configura un proxy 127.0.0.1. Solo lo usan los programas que respetan el proxy del sistema; el tráfico UDP y los programas con su propio proxy, no.',
			'tunScreen.modeAutoOptionDesc' => 'Crea un adaptador virtual y toma todo el tráfico (incluidos UDP y juegos); el proxy del sistema se mantiene como respaldo. Recomendado: funciona globalmente y no te quedas sin red si faltan permisos.',
			'tunScreen.modeForceOptionDesc' => 'Usa solo el adaptador virtual y deja de cambiar el proxy del sistema. Todo el tráfico (incluido UDP) pasa por el túnel; la entrada «proxy» del sistema se mantiene igual.',
			'tunScreen.adminRequiredDialog' => 'El adaptador virtual TUN requiere permisos de administrador (wintun en Windows / utun en macOS).\n\nMclash no se está ejecutando como administrador ahora mismo, así que TUN no surtirá efecto tras activarlo (en modo «Auto» el proxy del sistema sigue funcionando como respaldo, así que la red sigue usable).\n\nAceptar = reiniciar Mclash como administrador ahora (aparecerá un aviso de UAC)\nCancelar = guardar esta opción igualmente (el proxy del sistema se usa automáticamente cuando TUN no está disponible)',
			'tunScreen.relaunchFailed' => ({required Object message}) => 'Fallo al reiniciar: ${message}',
			'tunScreen.switchFailed' => ({required Object message}) => 'Fallo al cambiar el modo TUN: ${message}\nSe han restaurado los ajustes anteriores.',
			'tunScreen.setOffSnack' => 'Configurado en «Desactivado»: solo proxy del sistema',
			'tunScreen.setModeSnack' => ({required Object mode, required Object effect}) => 'Configurado en «${mode}», ${effect}',
			'tunScreen.effectReconnected' => 'reconectado y ya activo',
			'tunScreen.effectAfterConnect' => 'activo tras conectar',
			'tunScreen.sheetTitle' => 'Adaptador virtual TUN',
			'tunScreen.advancedTitle' => 'Parámetros avanzados (Ajustes del núcleo → TUN)',
			'tunScreen.advancedSubtitle' => 'Dirección del adaptador / pila / MTU / ruta automática / secuestro de DNS / sobrescritura',
			'tunScreen.adminOk' => 'TUN requiere permisos de administrador; los privilegios actuales son suficientes (ejecutar como administrador en Windows / como root en macOS)',
			'tunScreen.adminMissing' => 'TUN requiere permisos de administrador: Mclash no se ejecuta como administrador, así que TUN no surtirá efecto tras elegir «Auto/Forzado» («Auto» recurre al proxy del sistema, así que la red sigue usable)',
			_ => null,
		};
	}
}
