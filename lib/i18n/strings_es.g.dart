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
	@override String get diversionTemplates => 'Plantilla de Diversión';
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
class _Translations$homeScreen$es implements Translations$homeScreen$en {
	_Translations$homeScreen$es._(this._root);

	final TranslationsEs _root; // ignore: unused_field

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
	@override String latencySuffix({required Object ms}) => ' (${ms}ms)';
}

// Path: nodesScreen
class _Translations$nodesScreen$es implements Translations$nodesScreen$en {
	_Translations$nodesScreen$es._(this._root);

	final TranslationsEs _root; // ignore: unused_field

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
class _Translations$nodeAuto$es implements Translations$nodeAuto$en {
	_Translations$nodeAuto$es._(this._root);

	final TranslationsEs _root; // ignore: unused_field

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
class _Translations$accountBlock$es implements Translations$accountBlock$en {
	_Translations$accountBlock$es._(this._root);

	final TranslationsEs _root; // ignore: unused_field

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
class _Translations$entitlementMsg$es implements Translations$entitlementMsg$en {
	_Translations$entitlementMsg$es._(this._root);

	final TranslationsEs _root; // ignore: unused_field

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
class _Translations$devicesScreen$es implements Translations$devicesScreen$en {
	_Translations$devicesScreen$es._(this._root);

	final TranslationsEs _root; // ignore: unused_field

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
class _Translations$sysProxySheet$es implements Translations$sysProxySheet$en {
	_Translations$sysProxySheet$es._(this._root);

	final TranslationsEs _root; // ignore: unused_field

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
class _Translations$logScreen$es implements Translations$logScreen$en {
	_Translations$logScreen$es._(this._root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String readAppFailed({required Object e}) => 'Failed to read the app log: ${e}';
	@override String readCoreFailed({required Object e}) => 'Failed to read the kernel log: ${e}';
	@override String get copied => 'Copied (subscription URLs and other secrets are masked; the log file itself may still contain the raw address)';
	@override String get copy => 'Copy';
	@override String get refresh => 'Refresh';
	@override String get empty => 'No content';
}

// Path: trayShell
class _Translations$trayShell$es implements Translations$trayShell$en {
	_Translations$trayShell$es._(this._root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get closeTitle => 'Close window';
	@override String get closeBody => 'Closing the window just puts Mclash in the tray — the kernel and system proxy keep working, and your network stays connected.\n\n· OK: minimize to the tray (to quit completely, right-click the tray icon → Quit)\n· Cancel: quit Mclash completely, stop the kernel and restore the system proxy\n\n(Your choice is remembered; next time you can use the tray icon directly)';
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
			'meta.diversionTemplates' => 'Plantilla de Diversión',
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
			_ => null,
		};
	}
}
