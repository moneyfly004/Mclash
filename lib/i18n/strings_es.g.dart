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
			_ => null,
		};
	}
}
