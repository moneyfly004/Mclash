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
class TranslationsKo with BaseTranslations<AppLocale, Translations> implements Translations {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	TranslationsKo({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: AppLocale.ko,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <ko>.
	final TranslationMetadata<AppLocale, Translations> _meta;
	@override TranslationMetadata<AppLocale, Translations> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key);

	late final TranslationsKo _root = this; // ignore: unused_field

	@override 
	TranslationsKo $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => TranslationsKo(meta: meta ?? this.$meta);

	// Translations
	@override late final _Translations$BackupAndSyncWebdavScreen$ko BackupAndSyncWebdavScreen = _Translations$BackupAndSyncWebdavScreen$ko._(_root);
	@override late final _Translations$LaunchFailedScreen$ko LaunchFailedScreen = _Translations$LaunchFailedScreen$ko._(_root);
	@override late final _Translations$PerAppAndroidScreen$ko PerAppAndroidScreen = _Translations$PerAppAndroidScreen$ko._(_root);
	@override late final _Translations$UserAgreementScreen$ko UserAgreementScreen = _Translations$UserAgreementScreen$ko._(_root);
	@override late final _Translations$NetCheckScreen$ko NetCheckScreen = _Translations$NetCheckScreen$ko._(_root);
	@override late final _Translations$VersionUpdateScreen$ko VersionUpdateScreen = _Translations$VersionUpdateScreen$ko._(_root);
	@override late final _Translations$loginScreen$ko loginScreen = _Translations$loginScreen$ko._(_root);
	@override late final _Translations$main$ko main = _Translations$main$ko._(_root);
	@override late final _Translations$meta$ko meta = _Translations$meta$ko._(_root);
	@override late final _Translations$permission$ko permission = _Translations$permission$ko._(_root);
	@override late final _Translations$tls$ko tls = _Translations$tls$ko._(_root);
	@override late final _Translations$tun$ko tun = _Translations$tun$ko._(_root);
	@override late final _Translations$dns$ko dns = _Translations$dns$ko._(_root);
	@override late final _Translations$sniffer$ko sniffer = _Translations$sniffer$ko._(_root);
	@override late final _Translations$profilePatchMode$ko profilePatchMode = _Translations$profilePatchMode$ko._(_root);
	@override String sendOrReceiveNotMatch({required Object p}) => '[${p}]를 사용하십시오';
	@override String targetConnectFailed({required Object p}) => '[${p}] 연결 실패. 장치가 동일한 LAN에 있는지 확인하십시오';
	@override String get edgeRuntimeNotInstalled => '현재 장치에 Edge WebView2 런타임이 설치되어 있지 않아 페이지를 표시할 수 없습니다. Edge WebView2 런타임(x64)을 다운로드하여 설치하고 앱을 다시 시작한 후 다시 시도하십시오。';
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
	@override late final _Translations$meScreen$ko meScreen = _Translations$meScreen$ko._(_root);
	@override late final _Translations$homeScreen$ko homeScreen = _Translations$homeScreen$ko._(_root);
	@override late final _Translations$nodesScreen$ko nodesScreen = _Translations$nodesScreen$ko._(_root);
	@override late final _Translations$nodeAuto$ko nodeAuto = _Translations$nodeAuto$ko._(_root);
	@override late final _Translations$accountBlock$ko accountBlock = _Translations$accountBlock$ko._(_root);
	@override late final _Translations$entitlementMsg$ko entitlementMsg = _Translations$entitlementMsg$ko._(_root);
	@override late final _Translations$devicesScreen$ko devicesScreen = _Translations$devicesScreen$ko._(_root);
	@override late final _Translations$sysProxySheet$ko sysProxySheet = _Translations$sysProxySheet$ko._(_root);
	@override late final _Translations$logScreen$ko logScreen = _Translations$logScreen$ko._(_root);
	@override late final _Translations$trayShell$ko trayShell = _Translations$trayShell$ko._(_root);
}

// Path: BackupAndSyncWebdavScreen
class _Translations$BackupAndSyncWebdavScreen$ko implements Translations$BackupAndSyncWebdavScreen$en {
	_Translations$BackupAndSyncWebdavScreen$ko._(this._root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get webdavServerUrl => '서버 URL';
	@override String get webdavRequired => '비워둘 수 없습니다';
	@override String get webdavLoginFailed => '로그인 실패:';
	@override String get webdavListFailed => '파일 목록을 가져오지 못했습니다:';
}

// Path: LaunchFailedScreen
class _Translations$LaunchFailedScreen$ko implements Translations$LaunchFailedScreen$en {
	_Translations$LaunchFailedScreen$ko._(this._root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get invalidProcess => '앱 시작 실패 [유효하지 않은 프로세스 이름], 앱을 별도의 디렉토리에 다시 설치하십시오';
	@override String get invalidProfile => '앱 시작 실패 [프로필 액세스 실패], 앱을 다시 설치하십시오';
	@override String get invalidVersion => '앱 시작 실패 [유효하지 않은 버전], 앱을 다시 설치하십시오';
	@override String get systemVersionLow => '앱 시작 실패 [시스템 버전이 너무 낮음]';
	@override String get invalidInstallPath => '설치 경로가 유효하지 않습니다. 유효한 경로에 다시 설치하십시오';
}

// Path: PerAppAndroidScreen
class _Translations$PerAppAndroidScreen$ko implements Translations$PerAppAndroidScreen$en {
	_Translations$PerAppAndroidScreen$ko._(this._root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get title => '앱별 프록시';
	@override String get whiteListMode => '화이트리스트 모드';
	@override String get whiteListModeTip => '활성화 시: 체크된 앱만 프록시됩니다. 비활성화 시: 체크되지 않은 앱만 프록시됩니다';
}

// Path: UserAgreementScreen
class _Translations$UserAgreementScreen$ko implements Translations$UserAgreementScreen$en {
	_Translations$UserAgreementScreen$ko._(this._root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get privacyFirst => '개인 정보 보호 우선';
	@override String get agreeAndContinue => '동의 및 계속';
}

// Path: NetCheckScreen
class _Translations$NetCheckScreen$ko implements Translations$NetCheckScreen$en {
	_Translations$NetCheckScreen$ko._(this._root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get enterDomain => '도메인 이름을 입력하세요';
	@override String get checking => '점검 중...';
	@override String aQueryFailed({required Object p}) => 'A 쿼리 실패: ${p}';
	@override String aaaaQueryFailed({required Object p}) => 'AAAA 쿼리 실패: ${p}';
	@override String get success => '성공';
	@override String get failed => '실패';
	@override String get suspectedPollution => 'DNS 오염 의심';
	@override String get domainLabel => '도메인';
	@override String get checkButton => '점검';
	@override String get dnsSection => '1. DNS 조회';
	@override String get directHttpSection => '2. HTTP (TUN 경유, TUN 먼저 활성화 필요)';
	@override String proxyHttpSection({required Object p}) => '3. HTTP (프록시 경유, 포트: ${p})';
	@override String get tunNotEnabled => 'TUN이 활성화되지 않았습니다';
	@override String get routeTableSection => '4. 라우팅 테이블';
}

// Path: VersionUpdateScreen
class _Translations$VersionUpdateScreen$ko implements Translations$VersionUpdateScreen$en {
	_Translations$VersionUpdateScreen$ko._(this._root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String versionReady({required Object p}) => '새 버전 [${p}]이 준비되었습니다';
	@override String get update => '업데이트를 위해 재시작';
	@override String get cancel => '나중에';
}

// Path: loginScreen
class _Translations$loginScreen$ko implements Translations$loginScreen$en {
	_Translations$loginScreen$ko._(this._root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get login => '로그인';
	@override String get register => '계정 가입';
	@override String get forgotPassword => '비밀번호 찾기';
	@override String get provider => '서비스 제공자';
	@override String get providerName => '${_root.loginScreen.provider} 코드/별칭/URL';
	@override String get account => '계정';
	@override String get email => '이메일';
	@override String get password => '비밀번호';
}

// Path: main
class _Translations$main$ko implements Translations$main$en {
	_Translations$main$ko._(this._root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override late final _Translations$main$tray$ko tray = _Translations$main$tray$ko._(_root);
}

// Path: meta
class _Translations$meta$ko implements Translations$meta$en {
	_Translations$meta$ko._(this._root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get enable => '활성화';
	@override String get disable => '비활성화';
	@override String get open => '열기';
	@override String get close => '닫기';
	@override String get quit => '종료';
	@override String get add => '추가';
	@override String get remove => '제거';
	@override String get removeConfirm => '정말로 삭제하시겠습니까?';
	@override String get edit => '편집';
	@override String get view => '보기';
	@override String get remark => '메모';
	@override String get byDefault => '기본값';
	@override String get more => '더 보기';
	@override String get tips => '정보';
	@override String get selectAll => '전체 선택';
	@override String get copy => '복사';
	@override String get paste => '반죽';
	@override String get cut => '자르다';
	@override String get save => '저장';
	@override String get ok => '확인';
	@override String get cancel => '취소';
	@override String get faq => '자주 묻는 질문';
	@override String get doc => '문서';
	@override String get htmlTools => 'HTML 툴셋';
	@override String get download => '다운로드';
	@override String get loading => '로드 중...';
	@override String get days => '일';
	@override String get hours => '시간';
	@override String get minutes => '분';
	@override String get seconds => '초';
	@override String get milliseconds => '밀리초';
	@override String get search => '검색';
	@override String get searchNodeHint => '노드 필터 (이름 또는 프로토콜)';
	@override String get connect => '연결';
	@override String get disconnect => '연결 해제';
	@override String get connected => '연결됨';
	@override String get disconnected => '연결 해제됨';
	@override String get connecting => '연결 중';
	@override String get connectTimeout => '연결 시간 초과';
	@override String get timeout => '시간 초과';
	@override String get latencyTest => '지연 시간 확인';
	@override String get networkCheck => '네트워크 점검';
	@override String get language => '언어';
	@override String get next => '다음';
	@override String get done => '완료';
	@override String get apply => '적용';
	@override String get refresh => '새로고침';
	@override String get update => '업데이트';
	@override String get updateInterval => '업데이트 간격';
	@override String updateFailed({required Object p}) => '업데이트 실패: ${p}';
	@override String get updateInterval5mTips => '최소: 5분';
	@override String get updateIntervalPreferByProfile => '공급자 설정 우선';
	@override String get none => '없음';
	@override String get reset => '초기화';
	@override String get authentication => '인증';
	@override String get user => '사용자';
	@override String get account => '계정';
	@override String get password => '비밀번호';
	@override String get decryptPassword => '복호화 비밀번호';
	@override String get required => '필수';
	@override String get go => '계속';
	@override String get other => '기타';
	@override String get dns => 'DNS';
	@override String get url => 'URL';
	@override String get urlInvalid => '유효하지 않은 URL';
	@override String get copyUrl => '링크 복사';
	@override String get openUrl => '링크 열기';
	@override String get coreSettingTips => '참고: 설정을 수정한 후 적용하려면 다시 연결해야 합니다';
	@override String get overwrite => '덮어쓰기';
	@override String get overwriteAppend => '추가 덮어쓰기';
	@override String get overwriteTips => '원본 프로필 <- 사용자 정의 덮어쓰기 <- 앱 덮어쓰기';
	@override String get noOverwrite => '덮어쓰지 않음';
	@override String get diversionTemplates => '전환 템플릿';
	@override String get ruleProviders => '규칙 공급자';
	@override String get ruleTemplates => '규칙 템플릿';
	@override String get proxyGroupsTemplates => '프록시 그룹 템플릿';
	@override String get proxyGroups => '프록시 그룹';
	@override String get proxyNodeList => '프록시 노드 목록';
	@override String proxyNodeFailure({required Object p}) => '다음 프록시 노드가 만료되어 자동으로 제거되었습니다: ${p}';
	@override String get externalController => '외부 컨트롤러';
	@override String get secret => '비밀번호(Secret)';
	@override String get tcpConcurrent => 'TCP 동시 핸드셰이크';
	@override String get globalClientFingerprint => 'TLS 글로벌 핑거프린트';
	@override String get allowLanAccess => 'LAN 장치 액세스';
	@override String get mixedPort => '혼합 프록시 포트';
	@override String get logLevel => '로그 레벨';
	@override String get findProcessMode => '프로세스 매칭 모드';
	@override String get tcpkeepAliveInterval => 'TCP Keep-alive 간격';
	@override String get delayTestUrl => '지연 테스트 URL';
	@override String get delayTestTimeout => '지연 테스트 시간 초과(ms)';
	@override String get tun => 'TUN';
	@override String get ntp => 'NTP';
	@override String get tls => 'TLS';
	@override String get geoDownloadByProxy => '프록시를 통해 Geo RuleSet 다운로드';
	@override String get geoRulesetTips => 'Geosite/Geoip는 해당 RuleSet으로 변환됩니다';
	@override String get sniffer => '스니퍼';
	@override String get userAgent => 'UserAgent';
	@override String get launchAtStartup => '시작 시 실행';
	@override String get launchAtStartupRunAsAdmin => 'Mclash를 관리자 권한으로 다시 시작하십시오';
	@override String get tunModeRunAsAdmin => 'TUN 모드는 시스템 관리자 권한이 필요합니다. 앱을 관리자 권한으로 다시 시작하십시오';
	@override String get portableMode => '포터블 모드';
	@override String get portableModeDisableTips => '포터블 모드를 종료해야 하는 경우 [mclash]를 종료하고 [mclash.exe]와 동일한 디렉토리에 있는 [portable] 폴더를 수동으로 삭제하십시오';
	@override String get autoConnectAfterLaunch => '실행 후 자동 연결';
	@override String get autoConnectAtBoot => '시스템 시작 후 자동 연결';
	@override String get autoConnectAtBootTips => '시스템 지원이 필요합니다. 일부 시스템에서는 [자동 시작]을 활성화해야 할 수도 있습니다.';
	@override String get hideAfterLaunch => '실행 후 창 숨기기';
	@override String get autoSetSystemProxy => '연결 시 시스템 프록시 자동 설정';
	@override String get bypassSystemProxy => '시스템 프록시를 우회하도록 허용된 도메인 이름';
	@override String get excludeFromRecent => '[최근 작업]에서 숨기기';
	@override String get wakeLock => '절전 모드 방지';
	@override String get hideDockIcon => 'Dock 아이콘 숨기기';
	@override String get showTrayTraffic => '트레이에 트래픽 정보 표시';
	@override String get website => '웹사이트';
	@override String get rule => '규칙';
	@override String get global => '글로벌';
	@override String get direct => '직접 연결';
	@override String get qrcode => 'QR 코드';
	@override String get qrcodeTooLong => '텍스트가 너무 길어 표시할 수 없습니다';
	@override String get qrcodeShare => 'QR 코드 공유';
	@override String get qrcodeScan => 'QR 코드 스캔';
	@override String get qrcodeScanResult => '스캔 결과';
	@override String get backupAndSync => '백업 및 동기화';
	@override String get export => '내보내기';
	@override String get send => '보내기';
	@override String get sendConfirm => '보내기를 확인하시겠습니까?';
	@override String get log => '로그';
	@override String get coreLog => '코어 로그';
	@override String get appLog => '앱 로그';
	@override String get core => '코어';
	@override String get help => '도움말';
	@override String get tutorial => '튜토리얼';
	@override String get board => '보드';
	@override String get boardOnline => '온라인 보드 사용';
	@override String get boardOnlineUrl => '온라인 보드 URL';
	@override String get boardLocalPort => '로컬 보드 포트';
	@override String get alwayOnVPN => '상시 연결';
	@override String get disableFontScaler => '글꼴 크기 조정 비활성화 (재시작 후 적용)';
	@override String get autoOrientation => '화면 방향에 따라 회전';
	@override String get restartTakesEffect => '재시작 후 적용';
	@override String get reconnectTakesEffect => '다시 연결 후 적용';
	@override String get runtimeProfile => '런타임 프로필';
	@override String get willCompleteAfterRebootInstall => '시스템 확장 설치를 완료하려면 장치를 재시작하십시오';
	@override String get requestNeedsUserApproval => '1. [시스템 설정]-[개인정보 보호 및 보안]에서 Mclash의 시스템 확장 설치를 [허용]하십시오\n2. [시스템 설정]-[일반]-[로그인 항목 및 확장 프로그램]-[네트워크 확장 프로그램]에서 [mclashServiceSE]를 활성화하십시오\n완료 후 다시 연결하십시오';
	@override String get FullDiskAccessPermissionRequired => '[시스템 설정]-[개인정보 보호 및 보안]-[전체 디스크 액세스]에서 mclashServiceSE 권한을 활성화하고 다시 연결하십시오.';
	@override String get proxy => '프록시';
	@override String get theme => '테마';
	@override String get tvMode => 'TV 모드';
	@override String get autoUpdate => '자동 업데이트';
	@override String get updateChannel => '자동 업데이트 채널';
	@override String hasNewVersion({required Object p}) => '버전 ${p}로 업데이트';
	@override String get autoDownloadPkg => '업데이트 패키지 자동 다운로드';
	@override String get devOptions => '개발자 옵션';
	@override String get about => '정보';
	@override String get name => '이름';
	@override String get version => '버전';
	@override String get sort => '정렬';
	@override String get share => '공유';
	@override String get importFromClipboard => '클립보드에서 가져오기';
	@override String get exportToClipboard => '클립보드로 내보내기';
	@override String get server => '서버';
	@override String get port => '포트';
	@override String get donate => '후원';
	@override String get setting => '설정';
	@override String get settingCore => '코어 설정';
	@override String get settingApp => '앱 설정';
	@override String get coreOverwrite => '코어 덮어쓰기';
	@override String get iCloud => 'iCloud';
	@override String get webdav => 'Webdav';
	@override String get lanSync => 'LAN 동기화';
	@override String get lanSyncNotQuitTips => '동기화가 완료될 때까지 이 화면을 종료하지 마십시오';
	@override String get deviceNoSpace => '디스크 공간 부족';
	@override String get hideSystemApp => '시스템 앱 숨기기';
	@override String get hideAppIcon => '앱 아이콘 숨기기';
	@override String get openDir => '파일 디렉토리 열기';
	@override String get type => '유형';
	@override String fileNotExist({required Object p}) => '파일이 존재하지 않습니다: ${p}';
	@override String get buyProfile => '프로필 구매';
	@override String get myProfiles => '내 프로필';
	@override String get profileEdit => '프로필 편집';
	@override String get profileNeedActive => '먼저 이 프로필을 현재 프로필로 설정한 뒤 연결/재연결하세요';
	@override String profileUrlOrContent({required Object p}) => '${p} 설정 링크';
	@override String get tabHome => '홈';
	@override String get tabNodes => '노드';
	@override String get tabPlans => '요금제';
	@override String get tabMe => '내 정보';
}

// Path: permission
class _Translations$permission$ko implements Translations$permission$en {
	_Translations$permission$ko._(this._root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get camera => '카메라';
	@override String get screen => '화면 녹화';
	@override String get appQuery => '애플리케이션 목록 가져오기';
	@override String request({required Object p}) => '[${p}] 권한 켜기';
	@override String requestNeed({required Object p}) => '[${p}] 권한을 켜주십시오';
}

// Path: tls
class _Translations$tls$ko implements Translations$tls$en {
	_Translations$tls$ko._(this._root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get certificate => '인증서';
	@override String get privateKey => '개인 키';
	@override String get customTrustCert => '사용자 정의 인증서';
}

// Path: tun
class _Translations$tun$ko implements Translations$tun$en {
	_Translations$tun$ko._(this._root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get stack => '네트워크 스택';
	@override String get inet4Address => 'IPv4 주소 범위';
	@override String get dnsHijack => 'DNS 하이제킹';
	@override String get strictRoute => '엄격한 경로';
	@override String get tunDefaultRoute => '기본 경로';
	@override String get icmpForward => 'ICMP 전달';
	@override String get allowBypass => '앱이 VPN을 우회하도록 허용';
	@override String get appendHttpProxy => 'VPN에 HTTP 프록시 추가';
	@override String get bypassHttpProxyDomain => 'HTTP 프록시를 우회하도록 허용된 도메인';
}

// Path: dns
class _Translations$dns$ko implements Translations$dns$en {
	_Translations$dns$ko._(this._root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get listen => '청취 연설';
	@override String get fakeIp => 'fake-ip';
	@override String get fallback => '폴백(Fallback)';
	@override String get preferH3 => 'DoH H3 우선';
	@override String get useHosts => 'Hosts 사용';
	@override String get useSystemHosts => '시스템 Hosts 사용';
	@override String get enhancedMode => '향상된 모드';
	@override String get fakeIPFilterMode => '${_root.dns.fakeIp} 필터 모드';
	@override String get fakeIPFilter => '${_root.dns.fakeIp} 필터';
	@override String get respectRules => '규칙 준수';
	@override String get nameServer => '네임 서버';
	@override String get defaultNameServer => '${_root.meta.byDefault} ${_root.dns.nameServer}';
	@override String get proxyNameServer => '${_root.meta.proxy} ${_root.dns.nameServer}';
	@override String get directNameServer => '${_root.meta.direct} ${_root.dns.nameServer}';
	@override String get fallbackNameServer => '${_root.dns.fallback} ${_root.dns.nameServer}';
	@override String get fallbackGeoIp => '${_root.dns.fallback} GeoIp';
	@override String get fallbackGeoIpCode => '${_root.dns.fallback} GeoIpCode';
}

// Path: sniffer
class _Translations$sniffer$ko implements Translations$sniffer$en {
	_Translations$sniffer$ko._(this._root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get overrideDest => '덮어쓰기';
}

// Path: profilePatchMode
class _Translations$profilePatchMode$ko implements Translations$profilePatchMode$en {
	_Translations$profilePatchMode$ko._(this._root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get currentSelected => '현재 선택됨';
	@override String get overwrite => '내장 - 덮어쓰기';
	@override String get noOverwrite => '내장 - 덮어쓰지 않음';
}

// Path: meScreen
class _Translations$meScreen$ko implements Translations$meScreen$en {
	_Translations$meScreen$ko._(this._root);

	final TranslationsKo _root; // ignore: unused_field

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
class _Translations$homeScreen$ko implements Translations$homeScreen$en {
	_Translations$homeScreen$ko._(this._root);

	final TranslationsKo _root; // ignore: unused_field

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
class _Translations$nodesScreen$ko implements Translations$nodesScreen$en {
	_Translations$nodesScreen$ko._(this._root);

	final TranslationsKo _root; // ignore: unused_field

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
class _Translations$nodeAuto$ko implements Translations$nodeAuto$en {
	_Translations$nodeAuto$ko._(this._root);

	final TranslationsKo _root; // ignore: unused_field

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
class _Translations$accountBlock$ko implements Translations$accountBlock$en {
	_Translations$accountBlock$ko._(this._root);

	final TranslationsKo _root; // ignore: unused_field

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
class _Translations$entitlementMsg$ko implements Translations$entitlementMsg$en {
	_Translations$entitlementMsg$ko._(this._root);

	final TranslationsKo _root; // ignore: unused_field

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
class _Translations$devicesScreen$ko implements Translations$devicesScreen$en {
	_Translations$devicesScreen$ko._(this._root);

	final TranslationsKo _root; // ignore: unused_field

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
class _Translations$sysProxySheet$ko implements Translations$sysProxySheet$en {
	_Translations$sysProxySheet$ko._(this._root);

	final TranslationsKo _root; // ignore: unused_field

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
class _Translations$logScreen$ko implements Translations$logScreen$en {
	_Translations$logScreen$ko._(this._root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String readAppFailed({required Object e}) => 'Failed to read the app log: ${e}';
	@override String readCoreFailed({required Object e}) => 'Failed to read the kernel log: ${e}';
	@override String get copied => 'Copied (subscription URLs and other secrets are masked; the log file itself may still contain the raw address)';
	@override String get copy => 'Copy';
	@override String get refresh => 'Refresh';
	@override String get empty => 'No content';
}

// Path: trayShell
class _Translations$trayShell$ko implements Translations$trayShell$en {
	_Translations$trayShell$ko._(this._root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get closeTitle => 'Close window';
	@override String get closeBody => 'Closing the window just puts Mclash in the tray — the kernel and system proxy keep working, and your network stays connected.\n\n· OK: minimize to the tray (to quit completely, right-click the tray icon → Quit)\n· Cancel: quit Mclash completely, stop the kernel and restore the system proxy\n\n(Your choice is remembered; next time you can use the tray icon directly)';
}

// Path: main.tray
class _Translations$main$tray$ko implements Translations$main$tray$en {
	_Translations$main$tray$ko._(this._root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get menuOpen => '열기';
	@override String get menuExit => '종료';
}

/// The flat map containing all translations for locale <ko>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on TranslationsKo {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'BackupAndSyncWebdavScreen.webdavServerUrl' => '서버 URL',
			'BackupAndSyncWebdavScreen.webdavRequired' => '비워둘 수 없습니다',
			'BackupAndSyncWebdavScreen.webdavLoginFailed' => '로그인 실패:',
			'BackupAndSyncWebdavScreen.webdavListFailed' => '파일 목록을 가져오지 못했습니다:',
			'LaunchFailedScreen.invalidProcess' => '앱 시작 실패 [유효하지 않은 프로세스 이름], 앱을 별도의 디렉토리에 다시 설치하십시오',
			'LaunchFailedScreen.invalidProfile' => '앱 시작 실패 [프로필 액세스 실패], 앱을 다시 설치하십시오',
			'LaunchFailedScreen.invalidVersion' => '앱 시작 실패 [유효하지 않은 버전], 앱을 다시 설치하십시오',
			'LaunchFailedScreen.systemVersionLow' => '앱 시작 실패 [시스템 버전이 너무 낮음]',
			'LaunchFailedScreen.invalidInstallPath' => '설치 경로가 유효하지 않습니다. 유효한 경로에 다시 설치하십시오',
			'PerAppAndroidScreen.title' => '앱별 프록시',
			'PerAppAndroidScreen.whiteListMode' => '화이트리스트 모드',
			'PerAppAndroidScreen.whiteListModeTip' => '활성화 시: 체크된 앱만 프록시됩니다. 비활성화 시: 체크되지 않은 앱만 프록시됩니다',
			'UserAgreementScreen.privacyFirst' => '개인 정보 보호 우선',
			'UserAgreementScreen.agreeAndContinue' => '동의 및 계속',
			'NetCheckScreen.enterDomain' => '도메인 이름을 입력하세요',
			'NetCheckScreen.checking' => '점검 중...',
			'NetCheckScreen.aQueryFailed' => ({required Object p}) => 'A 쿼리 실패: ${p}',
			'NetCheckScreen.aaaaQueryFailed' => ({required Object p}) => 'AAAA 쿼리 실패: ${p}',
			'NetCheckScreen.success' => '성공',
			'NetCheckScreen.failed' => '실패',
			'NetCheckScreen.suspectedPollution' => 'DNS 오염 의심',
			'NetCheckScreen.domainLabel' => '도메인',
			'NetCheckScreen.checkButton' => '점검',
			'NetCheckScreen.dnsSection' => '1. DNS 조회',
			'NetCheckScreen.directHttpSection' => '2. HTTP (TUN 경유, TUN 먼저 활성화 필요)',
			'NetCheckScreen.proxyHttpSection' => ({required Object p}) => '3. HTTP (프록시 경유, 포트: ${p})',
			'NetCheckScreen.tunNotEnabled' => 'TUN이 활성화되지 않았습니다',
			'NetCheckScreen.routeTableSection' => '4. 라우팅 테이블',
			'VersionUpdateScreen.versionReady' => ({required Object p}) => '새 버전 [${p}]이 준비되었습니다',
			'VersionUpdateScreen.update' => '업데이트를 위해 재시작',
			'VersionUpdateScreen.cancel' => '나중에',
			'loginScreen.login' => '로그인',
			'loginScreen.register' => '계정 가입',
			'loginScreen.forgotPassword' => '비밀번호 찾기',
			'loginScreen.provider' => '서비스 제공자',
			'loginScreen.providerName' => '${_root.loginScreen.provider} 코드/별칭/URL',
			'loginScreen.account' => '계정',
			'loginScreen.email' => '이메일',
			'loginScreen.password' => '비밀번호',
			'main.tray.menuOpen' => '열기',
			'main.tray.menuExit' => '종료',
			'meta.enable' => '활성화',
			'meta.disable' => '비활성화',
			'meta.open' => '열기',
			'meta.close' => '닫기',
			'meta.quit' => '종료',
			'meta.add' => '추가',
			'meta.remove' => '제거',
			'meta.removeConfirm' => '정말로 삭제하시겠습니까?',
			'meta.edit' => '편집',
			'meta.view' => '보기',
			'meta.remark' => '메모',
			'meta.byDefault' => '기본값',
			'meta.more' => '더 보기',
			'meta.tips' => '정보',
			'meta.selectAll' => '전체 선택',
			'meta.copy' => '복사',
			'meta.paste' => '반죽',
			'meta.cut' => '자르다',
			'meta.save' => '저장',
			'meta.ok' => '확인',
			'meta.cancel' => '취소',
			'meta.faq' => '자주 묻는 질문',
			'meta.doc' => '문서',
			'meta.htmlTools' => 'HTML 툴셋',
			'meta.download' => '다운로드',
			'meta.loading' => '로드 중...',
			'meta.days' => '일',
			'meta.hours' => '시간',
			'meta.minutes' => '분',
			'meta.seconds' => '초',
			'meta.milliseconds' => '밀리초',
			'meta.search' => '검색',
			'meta.searchNodeHint' => '노드 필터 (이름 또는 프로토콜)',
			'meta.connect' => '연결',
			'meta.disconnect' => '연결 해제',
			'meta.connected' => '연결됨',
			'meta.disconnected' => '연결 해제됨',
			'meta.connecting' => '연결 중',
			'meta.connectTimeout' => '연결 시간 초과',
			'meta.timeout' => '시간 초과',
			'meta.latencyTest' => '지연 시간 확인',
			'meta.networkCheck' => '네트워크 점검',
			'meta.language' => '언어',
			'meta.next' => '다음',
			'meta.done' => '완료',
			'meta.apply' => '적용',
			'meta.refresh' => '새로고침',
			'meta.update' => '업데이트',
			'meta.updateInterval' => '업데이트 간격',
			'meta.updateFailed' => ({required Object p}) => '업데이트 실패: ${p}',
			'meta.updateInterval5mTips' => '최소: 5분',
			'meta.updateIntervalPreferByProfile' => '공급자 설정 우선',
			'meta.none' => '없음',
			'meta.reset' => '초기화',
			'meta.authentication' => '인증',
			'meta.user' => '사용자',
			'meta.account' => '계정',
			'meta.password' => '비밀번호',
			'meta.decryptPassword' => '복호화 비밀번호',
			'meta.required' => '필수',
			'meta.go' => '계속',
			'meta.other' => '기타',
			'meta.dns' => 'DNS',
			'meta.url' => 'URL',
			'meta.urlInvalid' => '유효하지 않은 URL',
			'meta.copyUrl' => '링크 복사',
			'meta.openUrl' => '링크 열기',
			'meta.coreSettingTips' => '참고: 설정을 수정한 후 적용하려면 다시 연결해야 합니다',
			'meta.overwrite' => '덮어쓰기',
			'meta.overwriteAppend' => '추가 덮어쓰기',
			'meta.overwriteTips' => '원본 프로필 <- 사용자 정의 덮어쓰기 <- 앱 덮어쓰기',
			'meta.noOverwrite' => '덮어쓰지 않음',
			'meta.diversionTemplates' => '전환 템플릿',
			'meta.ruleProviders' => '규칙 공급자',
			'meta.ruleTemplates' => '규칙 템플릿',
			'meta.proxyGroupsTemplates' => '프록시 그룹 템플릿',
			'meta.proxyGroups' => '프록시 그룹',
			'meta.proxyNodeList' => '프록시 노드 목록',
			'meta.proxyNodeFailure' => ({required Object p}) => '다음 프록시 노드가 만료되어 자동으로 제거되었습니다: ${p}',
			'meta.externalController' => '외부 컨트롤러',
			'meta.secret' => '비밀번호(Secret)',
			'meta.tcpConcurrent' => 'TCP 동시 핸드셰이크',
			'meta.globalClientFingerprint' => 'TLS 글로벌 핑거프린트',
			'meta.allowLanAccess' => 'LAN 장치 액세스',
			'meta.mixedPort' => '혼합 프록시 포트',
			'meta.logLevel' => '로그 레벨',
			'meta.findProcessMode' => '프로세스 매칭 모드',
			'meta.tcpkeepAliveInterval' => 'TCP Keep-alive 간격',
			'meta.delayTestUrl' => '지연 테스트 URL',
			'meta.delayTestTimeout' => '지연 테스트 시간 초과(ms)',
			'meta.tun' => 'TUN',
			'meta.ntp' => 'NTP',
			'meta.tls' => 'TLS',
			'meta.geoDownloadByProxy' => '프록시를 통해 Geo RuleSet 다운로드',
			'meta.geoRulesetTips' => 'Geosite/Geoip는 해당 RuleSet으로 변환됩니다',
			'meta.sniffer' => '스니퍼',
			'meta.userAgent' => 'UserAgent',
			'meta.launchAtStartup' => '시작 시 실행',
			'meta.launchAtStartupRunAsAdmin' => 'Mclash를 관리자 권한으로 다시 시작하십시오',
			'meta.tunModeRunAsAdmin' => 'TUN 모드는 시스템 관리자 권한이 필요합니다. 앱을 관리자 권한으로 다시 시작하십시오',
			'meta.portableMode' => '포터블 모드',
			'meta.portableModeDisableTips' => '포터블 모드를 종료해야 하는 경우 [mclash]를 종료하고 [mclash.exe]와 동일한 디렉토리에 있는 [portable] 폴더를 수동으로 삭제하십시오',
			'meta.autoConnectAfterLaunch' => '실행 후 자동 연결',
			'meta.autoConnectAtBoot' => '시스템 시작 후 자동 연결',
			'meta.autoConnectAtBootTips' => '시스템 지원이 필요합니다. 일부 시스템에서는 [자동 시작]을 활성화해야 할 수도 있습니다.',
			'meta.hideAfterLaunch' => '실행 후 창 숨기기',
			'meta.autoSetSystemProxy' => '연결 시 시스템 프록시 자동 설정',
			'meta.bypassSystemProxy' => '시스템 프록시를 우회하도록 허용된 도메인 이름',
			'meta.excludeFromRecent' => '[최근 작업]에서 숨기기',
			'meta.wakeLock' => '절전 모드 방지',
			'meta.hideDockIcon' => 'Dock 아이콘 숨기기',
			'meta.showTrayTraffic' => '트레이에 트래픽 정보 표시',
			'meta.website' => '웹사이트',
			'meta.rule' => '규칙',
			'meta.global' => '글로벌',
			'meta.direct' => '직접 연결',
			'meta.qrcode' => 'QR 코드',
			'meta.qrcodeTooLong' => '텍스트가 너무 길어 표시할 수 없습니다',
			'meta.qrcodeShare' => 'QR 코드 공유',
			'meta.qrcodeScan' => 'QR 코드 스캔',
			'meta.qrcodeScanResult' => '스캔 결과',
			'meta.backupAndSync' => '백업 및 동기화',
			'meta.export' => '내보내기',
			'meta.send' => '보내기',
			'meta.sendConfirm' => '보내기를 확인하시겠습니까?',
			'meta.log' => '로그',
			'meta.coreLog' => '코어 로그',
			'meta.appLog' => '앱 로그',
			'meta.core' => '코어',
			'meta.help' => '도움말',
			'meta.tutorial' => '튜토리얼',
			'meta.board' => '보드',
			'meta.boardOnline' => '온라인 보드 사용',
			'meta.boardOnlineUrl' => '온라인 보드 URL',
			'meta.boardLocalPort' => '로컬 보드 포트',
			'meta.alwayOnVPN' => '상시 연결',
			'meta.disableFontScaler' => '글꼴 크기 조정 비활성화 (재시작 후 적용)',
			'meta.autoOrientation' => '화면 방향에 따라 회전',
			'meta.restartTakesEffect' => '재시작 후 적용',
			'meta.reconnectTakesEffect' => '다시 연결 후 적용',
			'meta.runtimeProfile' => '런타임 프로필',
			'meta.willCompleteAfterRebootInstall' => '시스템 확장 설치를 완료하려면 장치를 재시작하십시오',
			'meta.requestNeedsUserApproval' => '1. [시스템 설정]-[개인정보 보호 및 보안]에서 Mclash의 시스템 확장 설치를 [허용]하십시오\n2. [시스템 설정]-[일반]-[로그인 항목 및 확장 프로그램]-[네트워크 확장 프로그램]에서 [mclashServiceSE]를 활성화하십시오\n완료 후 다시 연결하십시오',
			'meta.FullDiskAccessPermissionRequired' => '[시스템 설정]-[개인정보 보호 및 보안]-[전체 디스크 액세스]에서 mclashServiceSE 권한을 활성화하고 다시 연결하십시오.',
			'meta.proxy' => '프록시',
			'meta.theme' => '테마',
			'meta.tvMode' => 'TV 모드',
			'meta.autoUpdate' => '자동 업데이트',
			'meta.updateChannel' => '자동 업데이트 채널',
			'meta.hasNewVersion' => ({required Object p}) => '버전 ${p}로 업데이트',
			'meta.autoDownloadPkg' => '업데이트 패키지 자동 다운로드',
			'meta.devOptions' => '개발자 옵션',
			'meta.about' => '정보',
			'meta.name' => '이름',
			'meta.version' => '버전',
			'meta.sort' => '정렬',
			'meta.share' => '공유',
			'meta.importFromClipboard' => '클립보드에서 가져오기',
			'meta.exportToClipboard' => '클립보드로 내보내기',
			'meta.server' => '서버',
			'meta.port' => '포트',
			'meta.donate' => '후원',
			'meta.setting' => '설정',
			'meta.settingCore' => '코어 설정',
			'meta.settingApp' => '앱 설정',
			'meta.coreOverwrite' => '코어 덮어쓰기',
			'meta.iCloud' => 'iCloud',
			'meta.webdav' => 'Webdav',
			'meta.lanSync' => 'LAN 동기화',
			'meta.lanSyncNotQuitTips' => '동기화가 완료될 때까지 이 화면을 종료하지 마십시오',
			'meta.deviceNoSpace' => '디스크 공간 부족',
			'meta.hideSystemApp' => '시스템 앱 숨기기',
			'meta.hideAppIcon' => '앱 아이콘 숨기기',
			'meta.openDir' => '파일 디렉토리 열기',
			'meta.type' => '유형',
			'meta.fileNotExist' => ({required Object p}) => '파일이 존재하지 않습니다: ${p}',
			'meta.buyProfile' => '프로필 구매',
			'meta.myProfiles' => '내 프로필',
			'meta.profileEdit' => '프로필 편집',
			'meta.profileNeedActive' => '먼저 이 프로필을 현재 프로필로 설정한 뒤 연결/재연결하세요',
			'meta.profileUrlOrContent' => ({required Object p}) => '${p} 설정 링크',
			'meta.tabHome' => '홈',
			'meta.tabNodes' => '노드',
			'meta.tabPlans' => '요금제',
			'meta.tabMe' => '내 정보',
			'permission.camera' => '카메라',
			'permission.screen' => '화면 녹화',
			'permission.appQuery' => '애플리케이션 목록 가져오기',
			'permission.request' => ({required Object p}) => '[${p}] 권한 켜기',
			'permission.requestNeed' => ({required Object p}) => '[${p}] 권한을 켜주십시오',
			'tls.certificate' => '인증서',
			'tls.privateKey' => '개인 키',
			'tls.customTrustCert' => '사용자 정의 인증서',
			'tun.stack' => '네트워크 스택',
			'tun.inet4Address' => 'IPv4 주소 범위',
			'tun.dnsHijack' => 'DNS 하이제킹',
			'tun.strictRoute' => '엄격한 경로',
			'tun.tunDefaultRoute' => '기본 경로',
			'tun.icmpForward' => 'ICMP 전달',
			'tun.allowBypass' => '앱이 VPN을 우회하도록 허용',
			'tun.appendHttpProxy' => 'VPN에 HTTP 프록시 추가',
			'tun.bypassHttpProxyDomain' => 'HTTP 프록시를 우회하도록 허용된 도메인',
			'dns.listen' => '청취 연설',
			'dns.fakeIp' => 'fake-ip',
			'dns.fallback' => '폴백(Fallback)',
			'dns.preferH3' => 'DoH H3 우선',
			'dns.useHosts' => 'Hosts 사용',
			'dns.useSystemHosts' => '시스템 Hosts 사용',
			'dns.enhancedMode' => '향상된 모드',
			'dns.fakeIPFilterMode' => '${_root.dns.fakeIp} 필터 모드',
			'dns.fakeIPFilter' => '${_root.dns.fakeIp} 필터',
			'dns.respectRules' => '규칙 준수',
			'dns.nameServer' => '네임 서버',
			'dns.defaultNameServer' => '${_root.meta.byDefault} ${_root.dns.nameServer}',
			'dns.proxyNameServer' => '${_root.meta.proxy} ${_root.dns.nameServer}',
			'dns.directNameServer' => '${_root.meta.direct} ${_root.dns.nameServer}',
			'dns.fallbackNameServer' => '${_root.dns.fallback} ${_root.dns.nameServer}',
			'dns.fallbackGeoIp' => '${_root.dns.fallback} GeoIp',
			'dns.fallbackGeoIpCode' => '${_root.dns.fallback} GeoIpCode',
			'sniffer.overrideDest' => '덮어쓰기',
			'profilePatchMode.currentSelected' => '현재 선택됨',
			'profilePatchMode.overwrite' => '내장 - 덮어쓰기',
			'profilePatchMode.noOverwrite' => '내장 - 덮어쓰지 않음',
			'sendOrReceiveNotMatch' => ({required Object p}) => '[${p}]를 사용하십시오',
			'targetConnectFailed' => ({required Object p}) => '[${p}] 연결 실패. 장치가 동일한 LAN에 있는지 확인하십시오',
			'edgeRuntimeNotInstalled' => '현재 장치에 Edge WebView2 런타임이 설치되어 있지 않아 페이지를 표시할 수 없습니다. Edge WebView2 런타임(x64)을 다운로드하여 설치하고 앱을 다시 시작한 후 다시 시도하십시오。',
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
