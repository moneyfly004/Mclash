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
	@override String get edgeRuntimeNotInstalled => '현재 장치에 Edge WebView2 런타임이 설치되어 있지 않아 페이지를 표시할 수 없습니다. Edge WebView2 런타임(x64)을 다운로드해 설치한 뒤 앱을 다시 시작하고 다시 시도해 주세요.';
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
		'HK': '홍콩',
		'TW': '대만',
		'MO': '마카오',
		'CN': '중국',
		'JP': '일본',
		'KR': '대한민국',
		'SG': '싱가포르',
		'MY': '말레이시아',
		'TH': '태국',
		'VN': '베트남',
		'PH': '필리핀',
		'ID': '인도네시아',
		'KH': '캄보디아',
		'US': '미국',
		'CA': '캐나다',
		'MX': '멕시코',
		'GB': '영국',
		'DE': '독일',
		'FR': '프랑스',
		'NL': '네덜란드',
		'RU': '러시아',
		'IT': '이탈리아',
		'ES': '스페인',
		'CH': '스위스',
		'SE': '스웨덴',
		'NO': '노르웨이',
		'FI': '핀란드',
		'DK': '덴마크',
		'PL': '폴란드',
		'AT': '오스트리아',
		'IE': '아일랜드',
		'UA': '우크라이나',
		'TR': '튀르키예',
		'PT': '포르투갈',
		'CZ': '체코',
		'RO': '루마니아',
		'BE': '벨기에',
		'GR': '그리스',
		'HU': '헝가리',
		'IL': '이스라엘',
		'AE': '아랍에미리트',
		'SA': '사우디아라비아',
		'EG': '이집트',
		'ZA': '남아프리카 공화국',
		'NG': '나이지리아',
		'AU': '호주',
		'NZ': '뉴질랜드',
		'BR': '브라질',
		'AR': '아르헨티나',
		'CL': '칠레',
		'CO': '콜롬비아',
		'IN': '인도',
		'PK': '파키스탄',
		'XX': '기타',
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
	@override late final _Translations$ordersScreen$ko ordersScreen = _Translations$ordersScreen$ko._(_root);
	@override late final _Translations$payment$ko payment = _Translations$payment$ko._(_root);
	@override late final _Translations$planScreen$ko planScreen = _Translations$planScreen$ko._(_root);
	@override late final _Translations$authScreen$ko authScreen = _Translations$authScreen$ko._(_root);
	@override late final _Translations$updatePrompt$ko updatePrompt = _Translations$updatePrompt$ko._(_root);
	@override late final _Translations$clearData$ko clearData = _Translations$clearData$ko._(_root);
	@override late final _Translations$apiError$ko apiError = _Translations$apiError$ko._(_root);
	@override late final _Translations$subNotice$ko subNotice = _Translations$subNotice$ko._(_root);
	@override late final _Translations$settingItems$ko settingItems = _Translations$settingItems$ko._(_root);
	@override late final _Translations$tunScreen$ko tunScreen = _Translations$tunScreen$ko._(_root);
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
	@override String get paste => '붙여넣기';
	@override String get cut => '잘라내기';
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
	@override String get listen => '수신 주소';
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
	@override String get accountBalance => '잔액';
	@override String get expireAt => '만료일';
	@override String get remainingDays => '남은 일수';
	@override String get deviceCount => '기기';
	@override String get myOrders => '내 주문';
	@override String get deviceManagement => '기기 관리';
	@override String get changePassword => '비밀번호 변경';
	@override String get clearLocalData => '로컬 데이터 삭제 (제거 전)';
	@override String get profileManagementDev => '프로필 관리 (개발자)';
	@override String get tunAdapter => 'TUN 가상 어댑터';
	@override String get checkUpdate => '업데이트 확인';
	@override String get retry => '다시 시도';
	@override String get loadFailed => '계정 정보를 불러오지 못했습니다. 로그인이 만료되었거나 네트워크에 연결할 수 없습니다.\n오른쪽 위의 새로고침을 눌러 다시 시도하고, 계속 실패하면 다시 로그인하세요.';
	@override String get logoutConfirm => '로그아웃하시겠습니까?';
	@override String get boardNoKernel => '대시보드는 코어의 실시간 데이터(연결 상태, 트래픽, 규칙 적중)를 보여줍니다.\n\n코어가 실행 중이 아니면 대시보드는 빈 화면만 표시됩니다.\n확인을 누르면 그대로 열고, 취소를 누르면 홈 탭에서 먼저 연결하세요.';
	@override String get boardOpened => '브라우저에서 대시보드를 열었습니다. 노드나 규칙을 바꾸면 약 5초 안에 앱에 반영됩니다.';
}

// Path: homeScreen
class _Translations$homeScreen$ko implements Translations$homeScreen$en {
	_Translations$homeScreen$ko._(this._root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String expiresOn({required Object date}) => '${date} 만료';
	@override String devicesText({required Object text}) => '기기 ${text}';
	@override String get upgrade => '업그레이드';
	@override String get quickCountries => '빠른 국가 필터';
	@override String nodeCount({required Object count}) => '노드 ${count}개';
	@override String get autoBestTip => '모든 국가에서 지연 시간이 가장 낮은 사용 가능 노드를 자동으로 선택합니다 (자동 모드)';
	@override String get autoBest => '자동 최적';
	@override String pickCountryTip({required Object label}) => '"${label}"에서 지연 시간이 가장 낮은 사용 가능 노드를 자동으로 선택해 고정합니다';
	@override String get autoNoBetter => '이미 자동 모드입니다 (더 나은 노드가 없습니다)';
	@override String switchedBest({required Object name}) => '최적 노드로 전환했습니다: ${name}';
	@override String switchedCountry({required Object country, required Object node, required Object ms}) => '가장 빠른 ${country} 노드로 전환했습니다: ${node}${ms}';
	@override String filterCountryFailed({required Object country, required Object err}) => '${country} 필터가 적용되었으나 전환 실패: ${err}';
	@override String deviceFullCount({required Object used, required Object limit}) => '현재 기기 ${used}/${limit}\n\n';
	@override String get deviceFullUpgradeHint => '기기 한도를 업그레이드하면 즉시 연결이 복구됩니다(권장). 사용하지 않는 기기를 삭제해 자리를 확보할 수도 있습니다.';
	@override String get later => '나중에';
	@override String get upgradeDeviceCount => '기기 한도 업그레이드';
	@override String get cannotConnect => '연결할 수 없습니다';
	@override String get freshnessNever => '아직 동기화되지 않음 · 눌러서 새로고침';
	@override String get freshnessJustNow => '방금 업데이트됨 · 눌러서 기기 관리';
	@override String freshnessMinutes({required Object minutes}) => '${minutes}분 전 · 눌러서 기기 관리';
	@override String freshnessStale({required Object minutes}) => '${minutes}분 전 · 눌러서 새로고침';
	@override String get subscriptionAutoSync => '구독 자동 동기화';
	@override String get connecting => '연결 중…';
	@override String get disconnecting => '연결 해제 중…';
	@override String get tapToDisconnect => '스위치를 눌러 연결을 해제하세요';
	@override String get tapToConnect => '스위치를 눌러 연결하세요';
	@override String get currentNode => '현재 노드';
	@override String get noNodeSelected => '선택된 노드 없음';
	@override String get switchAction => '전환';
	@override String get realtimeSpeed => '실시간 속도';
	@override String get totalTraffic => '총 트래픽';
	@override String get subSyncedNotReady => '구독은 받았지만 프로필이 아직 준비되지 않았습니다. 잠시 후 다시 시도하세요.';
	@override String get noPlan => '이 계정에는 아직 사용할 수 있는 요금제가 없습니다. 먼저 구매하세요.';
	@override String get loginExpired => '로그인이 만료되었습니다. 다시 로그인하세요.';
	@override String get syncingWait => '구독을 동기화하는 중입니다. 잠시만 기다려 주세요.';
	@override String syncFailedNetwork({required Object message}) => '구독 동기화 실패: ${message}\n네트워크를 확인하고 다시 시도하세요.';
	@override String get syncFailed => '구독 동기화에 실패했습니다. 나중에 다시 시도하세요.';
	@override String get resetProxy => '초기화';
	@override String latencySuffix({required Object ms}) => ' (${ms}ms)';
}

// Path: nodesScreen
class _Translations$nodesScreen$ko implements Translations$nodesScreen$en {
	_Translations$nodesScreen$ko._(this._root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String updatedCount({required Object count}) => '구독 업데이트 완료: 노드 ${count}개';
	@override String updateFailed({required Object message}) => '업데이트 실패: ${message}';
	@override String get updateFailedNetwork => '업데이트 실패, 네트워크를 확인하세요';
	@override String testDone({required Object ok, required Object fail}) => '속도 테스트 완료: ${ok}개 연결 가능, ${fail}개 연결 불가 (오프라인일 수 있음)';
	@override String switchedTo({required Object name}) => '${name}(으)로 전환했습니다';
	@override String switchFailed({required Object message}) => '전환 실패: ${message}\n(노드 전환은 코어가 실행 중이어야 합니다. 홈 탭에서 스위치를 먼저 켜세요.)';
	@override String selectedAfterConnect({required Object name}) => '${name} 선택됨 (연결한 뒤 적용됩니다)';
	@override String get title => '노드';
	@override String get searchNode => '노드 검색';
	@override String get sortByLatency => '지연 시간순 정렬';
	@override String get updateSubscription => '구독 업데이트';
	@override String get viewByGroup => '프록시 그룹별 보기';
	@override String get testAll => '전체 테스트';
	@override String get searchHint => '노드 / 국가 / 프로토콜 검색';
	@override String get emptyNoNodes => '사용할 수 있는 노드가 아직 없습니다.\n구독은 자동으로 동기화됩니다. 방금 로그인했다면 잠시 기다리거나 아래에서 다시 불러오세요.';
	@override String get emptyNoMatch => '일치하는 노드가 없습니다.';
	@override String get reload => '다시 불러오기';
	@override String get currentInUse => '현재 (사용 중)';
	@override String get current => '현재';
	@override String get notTested => '측정 안 됨 (코어 재로드 대기)';
	@override String get timeout => '시간 초과';
	@override String get clear => '지우기';
	@override String get selectNode => '노드 선택';
	@override String get emptyNoKernel => '사용할 수 있는 노드가 아직 없습니다.\n홈 탭에서 연결 스위치를 먼저 켜세요.';
	@override String get openFullList => '전체 노드 목록 열기 (검색 / 속도 테스트 / 그룹)';
}

// Path: nodeAuto
class _Translations$nodeAuto$ko implements Translations$nodeAuto$en {
	_Translations$nodeAuto$ko._(this._root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get kernelStateUnavailable => '코어에서 노드 상태를 일시적으로 가져올 수 없습니다. 자동으로 다시 시도합니다.';
	@override String backToFixedNode({required Object fixed}) => '고정 노드로 복귀: ${fixed}';
	@override String get noUsableNodePickOne => '사용할 수 있는 노드를 찾지 못했습니다. 노드 목록에서 직접 선택하세요.';
	@override String get noUsableNodeTryOne => '사용할 수 있는 노드를 찾지 못했습니다. 노드 목록에서 선택해 보세요.';
	@override String autoConnectedBest({required Object bestNode, required Object bestMs}) => '최적 노드에 자동 연결했습니다: ${bestNode} (${bestMs} ms)';
	@override String get currentNodeUnreachable => '현재 노드로는 인터넷에 연결할 수 없습니다. 자동으로 전환합니다…';
	@override String autoSwitchedToUsable({required Object target}) => '사용할 수 있는 노드로 자동 전환했습니다: ${target}';
	@override String newNodesReloading({required Object missing}) => '구독의 새 노드 ${missing}개가 아직 코어에 없습니다. 다시 불러오는 중…';
	@override String get kernelReloadedRetest => '새 구독으로 코어를 다시 불러왔습니다. 속도 테스트를 다시 실행하세요.';
}

// Path: accountBlock
class _Translations$accountBlock$ko implements Translations$accountBlock$en {
	_Translations$accountBlock$ko._(this._root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String quotaFull({required Object used, required Object limit}) => '기기 자리가 가득 찼습니다 (${used}/${limit}). 이 기기는 허용 범위 안에 있어 정상적으로 연결할 수 있습니다. 기기를 추가하려면 기기 한도를 업그레이드하거나 사용하지 않는 기기를 삭제하세요.';
	@override String get banFallback => '계정이 비활성화되어 더 이상 사용할 수 없습니다.';
	@override String get titleExpired => '요금제 만료';
	@override String get titleDeviceFull => '기기 한도 도달';
	@override String get titleAccountDisabled => '계정 비활성화됨';
	@override String get titlePlanDisabled => '요금제 비활성화됨';
	@override String get titleNoPlan => '요금제 없음';
	@override String get titleDeviceRemoved => '이 기기가 제거되었습니다';
	@override String get titleServiceUnavailable => '서비스를 일시적으로 사용할 수 없음';
	@override String get textExpired => '요금제가 만료되었습니다. 글로벌 노드를 계속 사용하려면 요금제를 구매하세요.';
	@override String textDeviceFull({required Object used, required Object limit}) => '서버에서 이 기기가 요금제 기기 한도(${used}/${limit})를 초과한 것으로 확인되어 현재는 연결할 수 없습니다. 내 정보 - 기기 관리에서 사용하지 않는 기기를 삭제하거나, 기기 수가 더 많은 요금제로 업그레이드하세요.';
	@override String get textAccountDisabled => '계정이 비활성화되었습니다. 문의 사항이 있으면 고객 지원에 연락하세요.';
	@override String get textPlanDisabled => '요금제가 비활성화되었거나 비정상 상태여서 연결할 수 없습니다. 문의 사항이 있으면 고객 지원에 연락하세요.';
	@override String get textNoPlan => '아직 요금제를 구매하지 않았습니다. 구매하면 글로벌 노드를 사용할 수 있습니다.';
	@override String get textDeviceRemoved => '이 기기가 제거되어 로그아웃되었습니다. 다시 로그인하세요.';
	@override String get textServiceUnavailable => '서비스를 일시적으로 사용할 수 없습니다. 나중에 다시 시도하고, 계속 문제가 생기면 화면을 캡처해 고객 지원에 문의하세요.';
	@override String remainingDays({required Object days}) => '${days}일 남음';
	@override String deviceUsage({required Object used, required Object limit}) => '기기 ${used}/${limit}';
}

// Path: entitlementMsg
class _Translations$entitlementMsg$ko implements Translations$entitlementMsg$en {
	_Translations$entitlementMsg$ko._(this._root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get tamperedTitle => '인증 상태 비정상';
	@override String get tamperedClock => '시스템 시계 되돌림(또는 로컬 인증 데이터 변조)이 감지되었습니다. 연결하기 전에 네트워크에 접속해 인증을 완료하세요.';
	@override String get tamperedLocal => '로컬 인증 데이터가 손상되었거나 변조되었습니다. 연결하기 전에 네트워크에 접속해 인증을 완료하세요.';
	@override String get needVerifyTitle => '온라인 인증 필요';
	@override String get needVerifyFirst => '요금제 상태를 확인할 수 없습니다. 네트워크에 연결해 로그인한 뒤 연결하기 전에 인증을 한 번 완료하세요.';
	@override String get needVerifyRetry => '요금제 상태를 확인할 수 없습니다. 네트워크에 접속해 다시 시도하세요.';
	@override String get verifyFailedTitle => '요금제 상태를 확인할 수 없음';
	@override String get verifyFailedText => '인증 유예 기간이 지났고 서버에 연결할 수 없습니다. 네트워크를 확인하고 다시 시도하세요 (방금 갱신했다면 다시 로그인하세요).';
	@override String get restrictedTitle => '계정 제한됨';
	@override String get restrictedFallback => '계정 또는 요금제가 비활성화되어 연결할 수 없습니다.';
	@override String get expiredTitle => '요금제 만료';
	@override String expiredText({required Object date}) => '요금제가 ${date}에 만료되었습니다. 로컬 구독 프로필이 삭제되었습니다. 갱신하고 다시 로그인하면 복원됩니다.';
}

// Path: devicesScreen
class _Translations$devicesScreen$ko implements Translations$devicesScreen$en {
	_Translations$devicesScreen$ko._(this._root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get title => '기기 관리';
	@override String get currentPlan => '현재 요금제';
	@override String devicesText({required Object text}) => '기기 ${text}';
	@override String get upgradeTitle => '기기 추가 / 기간 연장';
	@override String get upgradeSubtitle => '기기와 일수를 함께 추가, 한 번의 결제';
	@override String get addDevices => '기기 추가';
	@override String get noAddDevices => '변경 없음';
	@override String addDevicesCount({required Object n}) => '기기 +${n}';
	@override String get addDays => '일수 추가';
	@override String get noExtend => '연장 없음';
	@override String addDaysCount({required Object n, required Object months}) => '+${n}일 (${months}개월)';
	@override String get priceFailed => '가격을 가져오지 못했습니다';
	@override String amountDue({required Object amount}) => '합계 ¥${amount}';
	@override String get requote => '다시 계산';
	@override String get goPay => '결제하기';
	@override String get afterUpgrade => '업그레이드 후: ';
	@override String afterLimit({required Object limit}) => '기기 한도 ${limit}';
	@override String afterExpire({required Object date}) => '${date} 만료';
	@override String get pickSomething => '기기나 일수를 하나 이상 추가하세요';
	@override String get daysOnlyUnsupported => '패널이 아직 "기간만 연장"을 지원하지 않습니다. "기기 추가"를 1 이상으로 설정하고 다시 시도하세요 (또는 고객 지원에 문의해 활성화하세요).';
	@override String get paramsRejected => '매개변수가 거부되었습니다. 기기 수와 일수를 다시 선택하세요.';
	@override String get subscriptionExpired => '구독이 만료되어 업그레이드할 수 없습니다. 먼저 갱신하거나 요금제를 구매하세요.';
	@override String get orderIncomplete => '주문 정보가 불완전합니다. "다시 계산"을 누르고 다시 시도하세요.';
	@override String get orderRegenerated => '이전 주문이 만료되어 같은 설정으로 새 주문이 생성되었습니다.';
	@override String get payChannelIncomplete => '주문 또는 결제 채널 정보가 불완전합니다. 다시 계산하고 시도하세요.';
	@override String get noQrCode => '서버가 결제 QR 코드나 링크를 반환하지 않았습니다. 다른 결제 수단을 선택하거나 나중에 시도하세요.';
	@override String payStartFailed({required Object err}) => '결제를 시작하지 못했습니다: ${err}';
	@override String get payCancelled => '결제가 취소되었고 임시 주문이 정리되었습니다.';
	@override String get balancePay => '잔액';
	@override String get noPayMethod => '지금은 사용할 수 있는 결제 수단이 없습니다. 나중에 다시 시도하거나 고객 지원에 문의하세요.';
	@override String balanceInsufficient({required Object balance, required Object amount}) => '잔액 부족 (¥${balance}, ¥${amount} 필요).\n먼저 충전하시겠습니까?';
	@override String get choosePayMethod => '결제 수단 선택';
	@override String balanceText({required Object balance}) => '잔액 ¥${balance}';
	@override String balanceShort({required Object balance}) => '잔액 ¥${balance} (부족, 충전 필요)';
	@override String get unknownDevice => '알 수 없는 기기';
	@override String get online => '● 온라인';
	@override String get offline => '○ 오프라인';
	@override String lastActive({required Object text}) => '최근 활동 ${text}';
	@override String get delete => '삭제';
	@override String deleteConfirm({required Object name}) => '기기 "${name}"을(를) 삭제하시겠습니까? 즉시 연결이 끊깁니다.';
	@override String get lastActiveJustNow => '방금 전';
	@override String lastActiveMinutes({required Object minutes}) => '${minutes}분 전';
	@override String lastActiveToday({required Object time}) => '오늘 ${time}';
}

// Path: sysProxySheet
class _Translations$sysProxySheet$ko implements Translations$sysProxySheet$en {
	_Translations$sysProxySheet$ko._(this._root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get reading => '읽는 중…';
	@override String get unknown => '알 수 없음';
	@override String get kernelNotRunning => '코어가 실행 중이 아닙니다 (홈 탭에서 스위치를 먼저 켜세요)';
	@override String applied({required Object host, required Object port}) => '적용됨 · ${host}:${port}';
	@override String notSet({required Object reason}) => '시스템 프록시가 설정되지 않음 — ${reason}';
	@override String notEffective({required Object port}) => '적용되지 않음 (${port}을(를) 가리키는 시스템 프록시 없음)';
	@override String readFailed({required Object err}) => '읽기 실패: ${err}';
	@override String get setRejected => '설정 실패: 시스템이 쓰기를 거부했거나 다른 프록시 앱이 덮어썼을 수 있습니다';
	@override String get disableFailed => '끄지 못했습니다';
	@override String get portRange => '포트는 1~65535 사이여야 합니다';
	@override String portChanged({required Object value}) => '포트가 ${value}(으)로 변경되었습니다. 코어가 새 포트에서 대기하도록 연결을 한 번 끊고 다시 연결하세요';
	@override String get title => '시스템 프록시';
	@override String desc({required Object host}) => '시스템 프록시 주소는 ${host}(로컬 루프백)로 고정되며 포트는 코어 혼합 포트입니다.';
	@override String get descWindows => 'Windows 설정 → 네트워크 및 인터넷 → 프록시에 표시되는 값과 정확히 같습니다.';
	@override String get reset => '다시 설정';
	@override String get disable => '시스템 프록시 끄기';
	@override String get diagnostics => '진단 (UI가 레지스트리와 같은 값을 읽고 있나요?)';
	@override String get mixedPort => '혼합 포트';
	@override String get apply => '적용';
}

// Path: logScreen
class _Translations$logScreen$ko implements Translations$logScreen$en {
	_Translations$logScreen$ko._(this._root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String readAppFailed({required Object e}) => '앱 로그를 읽지 못했습니다: ${e}';
	@override String readCoreFailed({required Object e}) => '코어 로그를 읽지 못했습니다: ${e}';
	@override String get copied => '복사했습니다 (구독 URL 등 민감 정보는 마스킹되지만, 로그 파일 자체에는 원본 주소가 남아 있을 수 있습니다)';
	@override String get copy => '복사';
	@override String get refresh => '새로고침';
	@override String get empty => '내용 없음';
}

// Path: trayShell
class _Translations$trayShell$ko implements Translations$trayShell$en {
	_Translations$trayShell$ko._(this._root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get closeTitle => '창 닫기';
	@override String get closeBody => '창을 닫아도 Mclash는 트레이로 들어갈 뿐이며, 코어와 시스템 프록시는 계속 동작하고 네트워크 연결도 유지됩니다.\n\n· 확인: 트레이로 최소화 (완전히 종료하려면 트레이 아이콘 우클릭 → 종료)\n· 취소: Mclash를 완전히 종료하고 코어를 중지하며 시스템 프록시를 복원합니다\n\n(선택한 내용이 기억되어 다음부터는 트레이 아이콘을 바로 사용할 수 있습니다)';
}

// Path: ordersScreen
class _Translations$ordersScreen$ko implements Translations$ordersScreen$en {
	_Translations$ordersScreen$ko._(this._root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get title => '내 주문';
	@override String get orderInfoIncomplete => '주문 정보가 불완전합니다. 아래로 당겨 새로고침하고 다시 시도하세요.';
	@override String get payChannelIncomplete => '결제 채널 정보가 불완전합니다. 나중에 다시 시도하세요.';
	@override String get noQrPayload => '서버가 결제 QR 코드나 링크를 반환하지 않았습니다. 다른 결제 수단을 선택하거나 나중에 다시 시도하세요.';
	@override String payStartFailed({required Object err}) => '결제를 시작하지 못했습니다: ${err}';
	@override String get noPayMethod => '지금은 사용할 수 있는 결제 수단이 없습니다. 나중에 다시 시도하거나 고객 지원에 문의하세요.';
	@override String get choosePayMethod => '결제 수단 선택';
	@override String amountDue({required Object amount}) => '결제 금액 ¥${amount}';
	@override String get paidLabel => '● 결제 완료';
	@override String get pendingLabel => '○ 미결제';
	@override String unknownStatus({required Object status}) => '✕ ${status}';
	@override String orderNoText({required Object orderNo}) => '주문 번호 ${orderNo}';
	@override String createdAtText({required Object createdAt}) => '생성 시각 ${createdAt}';
	@override String get orderCanceled => '주문이 취소되었습니다';
	@override String cancelFailed({required Object err}) => '취소 실패: ${err}\n(이미 결제되었거나 취소된 주문이라면 아래로 당겨 새로고침해 최신 상태를 확인하세요.)';
	@override String get cancelOrder => '주문 취소';
	@override String get continuePay => '결제 계속하기';
}

// Path: payment
class _Translations$payment$ko implements Translations$payment$en {
	_Translations$payment$ko._(this._root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get balancePay => '잔액 결제';
	@override String get qrPay => 'QR 코드 결제';
	@override String get deductFromBalance => '계정 잔액에서 차감됩니다';
	@override String get openedInBrowser => '브라우저에서 결제 페이지를 열었습니다';
	@override String get scanWithAlipayWechat => 'Alipay 또는 WeChat으로 스캔하세요';
	@override String orderNoText({required Object orderNo}) => '주문 번호 ${orderNo}';
	@override String payFailed({required Object err}) => '결제 실패: ${err}';
	@override String get notDetected => '결제가 감지되지 않았습니다. 나중에 "내 주문"에서 계속할 수 있습니다.';
	@override String get charging => '결제 중…';
	@override String get processing => '처리 중…';
	@override String get waitingPay => '결제를 기다리는 중…';
	@override String get openPageFailed => '결제 페이지를 열지 못했습니다. 아래 버튼을 눌러 다시 시도하거나 QR 코드를 스캔하세요.';
	@override String get reopenPayPage => '결제 페이지 다시 열기';
	@override String get payInBrowser => '브라우저에서 결제';
	@override String get openAlipay => 'Alipay 열기';
	@override String get cancelOrder => '주문 취소';
	@override String get confirmPay => '결제 확인';
	@override String get retry => '다시 시도';
	@override String get paidAlready => '결제했습니다';
	@override String get channelAlipay => 'Alipay';
	@override String get channelCodepayAlipay => '코드페이 · Alipay';
	@override String get channelCodepayWechat => '코드페이 · WeChat';
	@override String get channelCodepay => '코드페이';
	@override String get channelWechat => 'WeChat Pay';
	@override String get channelUsdt => 'USDT';
	@override String get channelUsdtTrc20 => 'USDT · TRC20';
	@override String get payFallback => '결제';
	@override String get errCsrf => '로그인 자격 증명이 만료되었습니다 (CSRF 검사 실패).\n"내 정보" 탭에서 아래로 당겨 새로고침하거나 다시 로그인한 뒤 재시도하세요.';
	@override String get errAlipayLimit => 'Alipay 대면 결제는 건당 한도(이 가맹점은 ¥1000)가 있어 이 주문은 한도를 초과합니다.\n"잔액 결제" 또는 "코드페이"를 사용하거나, 고객 지원에 문의해 Alipay 한도를 높이세요.';
	@override String get errNotSigned => 'Alipay 앱이 해당 결제 상품에 가입되어 있지 않아 이 채널을 일시적으로 사용할 수 없습니다.\n"잔액 결제" 또는 "코드페이"를 사용하거나, 고객 지원에 문의해 활성화하세요.';
	@override String get errOrderGone => '이 주문은 취소되었거나 만료되었습니다 (임시 주문은 30분간 유효합니다).\n"다시 계산"을 눌러 새 주문을 만든 뒤 결제하세요.';
	@override String errNetwork({required Object err}) => '네트워크에 연결할 수 없습니다: ${err}';
}

// Path: planScreen
class _Translations$planScreen$ko implements Translations$planScreen$en {
	_Translations$planScreen$ko._(this._root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get recommended => '추천';
	@override String get devices => '기기';
	@override String balanceLabel({required Object amount}) => '잔액 ¥${amount}';
	@override String get balanceInsufficient => ' (부족, 먼저 충전하세요)';
	@override String get total => '합계';
	@override String get payNow => '결제하기';
	@override String get retry => '다시 시도';
	@override String get errIncompleteOrder => '주문 또는 결제 채널 정보가 불완전하여 결제를 시작할 수 없습니다.';
	@override String get payBalance => '잔액 결제';
	@override String get payAlipay => 'Alipay';
	@override String get payWechat => 'WeChat Pay';
	@override String get payCodepay => '코드페이';
	@override String get payCodepayAlipay => '코드페이 · Alipay';
	@override String get payCodepayWechat => '코드페이 · WeChat';
	@override String get payEpayAlipay => '이페이 · Alipay';
	@override String get payEpayWechat => '이페이 · WeChat';
	@override String get payUsdt => 'USDT';
	@override String get payUsdtTrc20 => 'USDT · TRC20';
	@override String get payStripe => 'Stripe';
	@override String get payPaypal => 'PayPal';
	@override String get payOnline => '온라인 결제';
}

// Path: authScreen
class _Translations$authScreen$ko implements Translations$authScreen$en {
	_Translations$authScreen$ko._(this._root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get saveAccountInfo => '계정 정보 저장';
	@override String get autoLoginNextTime => '다음부터 자동 로그인';
	@override String get needLoginNextTime => '다음에는 다시 로그인해야 합니다';
	@override String get invalidEmail => '올바른 이메일 주소를 입력하세요';
	@override String get enterEmailFirst => '먼저 올바른 이메일 주소를 입력하세요';
	@override String get passwordRequired => '비밀번호를 입력하세요';
	@override String get wrongCredentials => '이메일 또는 비밀번호가 올바르지 않습니다';
	@override String get requestRejected => '요청이 거부되었습니다. 나중에 다시 시도하세요.';
	@override String get tooFrequent => '시도가 너무 많습니다. 나중에 다시 시도하세요.';
	@override String get loginFailed => '로그인 실패';
	@override String get username => '사용자 이름';
	@override String get confirmPassword => '비밀번호 확인';
	@override String get inviteCode => '초대 코드';
	@override String get emailCode => '이메일 인증 코드';
	@override String get getCode => '코드 받기';
	@override String get registerAndLogin => '가입하고 로그인';
	@override String usernameMinLength({required Object min}) => '사용자 이름은 ${min}자 이상이어야 합니다';
	@override String get passwordMismatch => '비밀번호가 일치하지 않습니다';
	@override String get emailCodeRequired => '이메일 인증 코드를 입력하세요';
	@override String get inviteCodeRequired => '이 사이트는 가입 시 초대 코드가 필요합니다';
	@override String get codeSentCheckEmail => '인증 코드를 보냈습니다. 이메일을 확인하세요.';
	@override String get registerSuccess => '가입이 완료되었습니다. 로그인되었습니다.';
	@override String passwordHint({required Object min}) => '${min}자 이상, 영문과 숫자를 모두 포함';
	@override String passwordTooShort({required Object min}) => '비밀번호는 ${min}자 이상이어야 합니다';
	@override String get passwordNeedsLetterAndDigit => '비밀번호에 영문과 숫자를 모두 포함해야 합니다';
	@override String get registeredEmail => '가입한 이메일';
	@override String get newPassword => '새 비밀번호';
	@override String get confirmNewPassword => '새 비밀번호 확인';
	@override String get resetPassword => '비밀번호 재설정';
	@override String get resetCodeSent => '이 이메일이 가입되어 있다면 재설정 코드를 보냈습니다 (15분간 유효).';
	@override String get resetSuccess => '비밀번호가 재설정되었습니다. 새 비밀번호로 로그인하세요.';
	@override String get changePasswordTitle => '비밀번호 변경';
	@override String get currentPassword => '현재 비밀번호';
	@override String get saveNewPassword => '새 비밀번호 저장';
	@override String get newPasswordMismatch => '새 비밀번호가 일치하지 않습니다';
	@override String get changePasswordSuccess => '비밀번호가 변경되었습니다. 다시 로그인하세요.';
}

// Path: updatePrompt
class _Translations$updatePrompt$ko implements Translations$updatePrompt$en {
	_Translations$updatePrompt$ko._(this._root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get checking => '업데이트 확인 중…';
	@override String get checkFailed => '업데이트 확인에 실패했습니다. 네트워크를 확인하고 다시 시도하세요.';
	@override String alreadyLatest({required Object version}) => '최신 버전(${version})을 사용 중입니다.';
	@override String newVersionFound({required Object version}) => '새 버전 ${version}이(가) 있습니다';
	@override String get installerDownloaded => '설치 파일이 백그라운드에서 다운로드를 마쳤습니다. 지금 업데이트를 눌러 업그레이드를 완료하세요.';
	@override String get downloadInBackground => '지금 업데이트를 누르면 다운로드 후 설치가 진행됩니다 (앱을 계속 사용할 수 있으며 설치 파일은 백그라운드에서 다운로드됩니다).';
	@override String get later => '나중에';
	@override String get updateNow => '지금 업데이트';
	@override String installerNotReady({required Object version}) => '설치 파일 다운로드가 아직 끝나지 않았습니다.\n\n확인을 누르면 다운로드 페이지를 열어 기기에 맞는 설치 파일(버전 ${version})을 직접 받을 수 있습니다.';
}

// Path: clearData
class _Translations$clearData$ko implements Translations$clearData$en {
	_Translations$clearData$ko._(this._root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get itemLoginSession => '로그인 세션';
	@override String get itemProfiles => '구독 프로필 (profiles/)';
	@override String get itemSettings => '앱 및 코어 설정';
	@override String get itemLatencyCache => '노드 지연 시간 캐시';
	@override String get itemLogs => '실행 로그';
	@override String get itemRoutingData => '라우팅 데이터 및 임시 파일';
	@override String confirmBody({required Object items, required Object dir}) => '이 기기에 저장된 다음 데이터가 삭제됩니다 (되돌릴 수 없습니다):\n\n${items}\n\n계정 자체와 구매한 요금제는 서버에 있으므로 영향을 받지 않습니다. 다시 로그인하면 구독이 복원됩니다.\n\n데이터 디렉토리: ${dir}\n(앱을 제거하기 전에 실행하세요. 그래야 재설치 시 깨끗하게 시작하고 다시 로그인을 요구합니다)';
	@override String get confirmAgain => '지금 삭제하시겠습니까? 이후 다시 로그인해야 합니다.';
	@override String clearedNotice({required Object count, required Object dir}) => '로컬 데이터 ${count}개를 삭제했습니다 (로그인 세션 포함, 다음에 앱을 열 때 다시 로그인해야 합니다).\n\n이제 앱을 삭제해 제거를 마무리할 수 있습니다:\n· macOS: Mclash.app을 휴지통으로 드래그 (데이터 디렉토리는 비워졌습니다: ${dir})\n· Windows: 제어판에서 Mclash를 제거하고, 사용자 데이터 유지 여부를 묻는 단계에서 "아니요"를 선택하세요';
	@override String clearFailed({required Object error}) => '삭제 실패: ${error}';
}

// Path: apiError
class _Translations$apiError$ko implements Translations$apiError$en {
	_Translations$apiError$ko._(this._root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String requestFailedHttp({required Object status, required Object domain}) => '요청 실패 (HTTP ${status}), ${domain} 시도함';
	@override String allDomainsFailed({required Object method, required Object path, required Object count}) => '요청 실패: ${method} ${path} (도메인 ${count}개 시도)';
	@override String requestTimeout({required Object seconds, required Object method, required Object path}) => '요청 시간 초과 (${seconds}초): ${method} ${path}';
	@override String networkUnreachable({required Object detail}) => '네트워크에 연결할 수 없습니다: ${detail}';
	@override String get tlsHandshakeFailed => 'TLS 핸드셰이크에 실패했습니다. 네트워크 연결이나 시스템 시간을 확인하세요.';
	@override String connectionFailed({required Object detail}) => '연결 실패: ${detail}';
	@override String requestError({required Object error}) => '요청 실패: ${error}';
	@override String responseReadTimeout({required Object seconds, required Object method, required Object path}) => '응답 읽기 시간 초과 (${seconds}초): ${method} ${path}';
	@override String notJson({required Object status, required Object snippet}) => '응답이 JSON이 아닙니다 (HTTP ${status}): ${snippet}';
	@override String badStructure({required Object status}) => '예상하지 못한 응답 구조 (HTTP ${status})';
	@override String loginFailed({required Object code}) => '로그인 실패 (코드 ${code})';
	@override String get loginMissingData => '로그인 응답에 데이터가 없습니다';
	@override String get loginMissingToken => '로그인 응답에 access_token이 없습니다';
	@override String registerFailed({required Object code}) => '가입 실패 (코드 ${code})';
	@override String get registerMissingToken => '가입 응답에 access_token이 없습니다. 리스크 컨트롤이 작동했거나 사이트 설정이 다를 수 있습니다';
	@override String requestFailedCode({required Object code}) => '요청 실패 (코드 ${code})';
}

// Path: subNotice
class _Translations$subNotice$ko implements Translations$subNotice$en {
	_Translations$subNotice$ko._(this._root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get titleNotFound => '구독을 찾을 수 없음';
	@override String get titleExpired => '구독 만료';
	@override String get titleInactive => '구독 비활성';
	@override String get titleDeviceOverLimit => '기기 한도 초과';
	@override String get titleUnavailable => '구독 사용 불가';
	@override String titleWithReason({required Object emoji, required Object title, required Object reason}) => '${emoji} ${title} (${reason})';
	@override String deviceUsedOfLimit({required Object used, required Object limit}) => '현재 기기 ${used}/${limit}';
	@override String deviceUsedOnly({required Object used}) => '현재 기기 ${used}';
	@override String expireAt({required Object expire}) => '${expire} 만료';
	@override String supportLine({required Object account}) => '💬 고객 지원: ${account}';
	@override String siteLine({required Object url}) => '📢 웹사이트: ${url}';
}

// Path: settingItems
class _Translations$settingItems$ko implements Translations$settingItems$en {
	_Translations$settingItems$ko._(this._root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get subscriptionAutoUpdateInterval => '구독 자동 업데이트 간격';
	@override String get speedTestMode => '속도 테스트 방식';
	@override String get speedTestModeTcp => 'TCP 속도 테스트';
	@override String get speedTestModeKernel => '코어 속도 테스트';
	@override String get delayTestUrlTip => '이 노드를 거쳐 HTTP 요청 한 번을 끝내는 데 걸리는 시간입니다 (핑이 아닙니다)\n기본값은 단순한 http 204 빈 응답이며, https를 쓰면 TLS 핸드셰이크가 더해져 값이 커집니다';
	@override String get systemProxy => '시스템 프록시';
	@override String get systemProxyTip => '주소와 포트 보기 / 재설정';
	@override String get tunMode => 'TUN 모드';
	@override String get tunModeTip => 'off=시스템 프록시만 / auto=TUN+시스템 프록시 / force=TUN만\n데스크톱에서 TUN은 관리자 권한이 필요합니다 (Windows는 wintun / macOS는 utun)';
	@override String get tunOverwriteTip => '덮어쓰기\n켜짐 = 이 페이지의 TUN 설정이 프로필의 tun 섹션을 덮어씁니다\n꺼짐 = 프로필 자체의 tun 설정을 사용합니다 (앱이 간섭하지 않음)';
	@override String tunEnableByTunMode({required Object enable}) => '${enable} (TUN 모드에 따라 결정됨)';
	@override String get interval30Minutes => '30분';
	@override String get interval1Hour => '1시간';
	@override String get interval6Hours => '6시간';
	@override String get interval12Hours => '12시간';
	@override String get interval24Hours => '24시간';
	@override String get interval3Days => '3일';
	@override String get interval7Days => '7일';
	@override String get intervalNever => '사용 안 함';
	@override String intervalMinutes({required Object minutes}) => '${minutes}분';
	@override String intervalHours({required Object hours}) => '${hours}시간';
	@override String intervalDays({required Object days}) => '${days}일';
}

// Path: tunScreen
class _Translations$tunScreen$ko implements Translations$tunScreen$en {
	_Translations$tunScreen$ko._(this._root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get modeOff => '끔';
	@override String get modeAuto => '자동';
	@override String get modeForce => '강제';
	@override String get modeOffDesc => '시스템 프록시만: 시스템 프록시를 따르는 프로그램(브라우저 등)에만 적용되며 UDP/게임은 프록시되지 않습니다';
	@override String get modeAutoDesc => 'TUN + 시스템 프록시 (이중 안전장치): UDP를 포함한 모든 트래픽이 가상 어댑터를 통과합니다';
	@override String get modeForceDesc => 'TUN만: 모든 트래픽이 가상 어댑터를 통과하고 시스템 프록시는 건드리지 않습니다';
	@override String get modeOffOptionDesc => '시스템 라우팅 테이블은 건드리지 않고 시스템에 127.0.0.1 프록시만 설정합니다. 시스템 프록시를 따르는 프로그램만 사용하며, UDP 트래픽과 자체 프록시 설정을 쓰는 프로그램은 해당되지 않습니다.';
	@override String get modeAutoOptionDesc => '가상 어댑터를 만들어 UDP와 게임을 포함한 모든 트래픽을 처리하고, 시스템 프록시는 대비책으로 유지합니다. 권장: 전역으로 동작하며 권한이 없어도 네트워크가 끊기지 않습니다.';
	@override String get modeForceOptionDesc => '가상 어댑터만 사용하고 시스템 프록시는 더 이상 변경하지 않습니다. UDP를 포함한 모든 트래픽이 터널을 통과하며 시스템의 "프록시" 항목은 그대로 유지됩니다.';
	@override String get adminRequiredDialog => 'TUN 가상 어댑터에는 관리자 권한이 필요합니다 (Windows는 wintun / macOS는 utun).\n\n현재 Mclash가 관리자 권한으로 실행되고 있지 않아 TUN을 켜도 적용되지 않습니다 ("자동" 모드에서는 시스템 프록시가 대비책으로 동작해 네트워크를 계속 사용할 수 있습니다).\n\n확인 = 지금 Mclash를 관리자 권한으로 다시 시작 (UAC 창이 표시됩니다)\n취소 = 이 선택을 그대로 저장 (TUN을 사용할 수 없으면 시스템 프록시를 자동으로 사용합니다)';
	@override String relaunchFailed({required Object message}) => '다시 시작 실패: ${message}';
	@override String switchFailed({required Object message}) => 'TUN 모드 전환 실패: ${message}\n이전 설정이 복원되었습니다.';
	@override String get setOffSnack => '"끔"으로 설정했습니다: 시스템 프록시만';
	@override String setModeSnack({required Object mode, required Object effect}) => '"${mode}"(으)로 설정했습니다, ${effect}';
	@override String get effectReconnected => '다시 연결되어 지금 적용되었습니다';
	@override String get effectAfterConnect => '연결 후 적용됩니다';
	@override String get sheetTitle => 'TUN 가상 어댑터';
	@override String get advancedTitle => '고급 매개변수 (코어 설정 → TUN)';
	@override String get advancedSubtitle => '어댑터 주소 / 스택 / MTU / 자동 라우트 / DNS 하이재킹 / 덮어쓰기';
	@override String get adminOk => 'TUN에는 관리자 권한이 필요하며 현재 권한으로 충분합니다 (Windows는 관리자 권한으로, macOS는 root로 실행)';
	@override String get adminMissing => 'TUN에는 관리자 권한이 필요합니다. Mclash가 관리자 권한으로 실행되고 있지 않아 "자동/강제"를 선택해도 TUN이 적용되지 않습니다 ("자동"은 시스템 프록시로 대체되어 네트워크는 계속 사용할 수 있습니다)';
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
			'meta.paste' => '붙여넣기',
			'meta.cut' => '잘라내기',
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
			'dns.listen' => '수신 주소',
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
			'edgeRuntimeNotInstalled' => '현재 장치에 Edge WebView2 런타임이 설치되어 있지 않아 페이지를 표시할 수 없습니다. Edge WebView2 런타임(x64)을 다운로드해 설치한 뒤 앱을 다시 시작하고 다시 시도해 주세요.',
			'locales.en' => 'English',
			'locales.zh-CN' => '简体中文',
			'locales.zh-TW' => '繁體中文',
			'locales.ja' => '日本語',
			'locales.ko' => '한국어',
			'locales.ar' => 'عربي',
			'locales.ru' => 'Русский',
			'locales.fa' => 'فارسی',
			'locales.es' => 'Español',
			'countries.HK' => '홍콩',
			'countries.TW' => '대만',
			'countries.MO' => '마카오',
			'countries.CN' => '중국',
			'countries.JP' => '일본',
			'countries.KR' => '대한민국',
			'countries.SG' => '싱가포르',
			'countries.MY' => '말레이시아',
			'countries.TH' => '태국',
			'countries.VN' => '베트남',
			'countries.PH' => '필리핀',
			'countries.ID' => '인도네시아',
			'countries.KH' => '캄보디아',
			'countries.US' => '미국',
			'countries.CA' => '캐나다',
			'countries.MX' => '멕시코',
			'countries.GB' => '영국',
			'countries.DE' => '독일',
			'countries.FR' => '프랑스',
			'countries.NL' => '네덜란드',
			'countries.RU' => '러시아',
			'countries.IT' => '이탈리아',
			'countries.ES' => '스페인',
			'countries.CH' => '스위스',
			'countries.SE' => '스웨덴',
			'countries.NO' => '노르웨이',
			'countries.FI' => '핀란드',
			'countries.DK' => '덴마크',
			'countries.PL' => '폴란드',
			'countries.AT' => '오스트리아',
			'countries.IE' => '아일랜드',
			'countries.UA' => '우크라이나',
			'countries.TR' => '튀르키예',
			'countries.PT' => '포르투갈',
			'countries.CZ' => '체코',
			'countries.RO' => '루마니아',
			'countries.BE' => '벨기에',
			'countries.GR' => '그리스',
			'countries.HU' => '헝가리',
			'countries.IL' => '이스라엘',
			'countries.AE' => '아랍에미리트',
			'countries.SA' => '사우디아라비아',
			'countries.EG' => '이집트',
			'countries.ZA' => '남아프리카 공화국',
			'countries.NG' => '나이지리아',
			'countries.AU' => '호주',
			'countries.NZ' => '뉴질랜드',
			'countries.BR' => '브라질',
			'countries.AR' => '아르헨티나',
			'countries.CL' => '칠레',
			'countries.CO' => '콜롬비아',
			'countries.IN' => '인도',
			'countries.PK' => '파키스탄',
			'countries.XX' => '기타',
			'meScreen.accountBalance' => '잔액',
			'meScreen.expireAt' => '만료일',
			'meScreen.remainingDays' => '남은 일수',
			'meScreen.deviceCount' => '기기',
			'meScreen.myOrders' => '내 주문',
			'meScreen.deviceManagement' => '기기 관리',
			'meScreen.changePassword' => '비밀번호 변경',
			'meScreen.clearLocalData' => '로컬 데이터 삭제 (제거 전)',
			'meScreen.profileManagementDev' => '프로필 관리 (개발자)',
			'meScreen.tunAdapter' => 'TUN 가상 어댑터',
			'meScreen.checkUpdate' => '업데이트 확인',
			'meScreen.retry' => '다시 시도',
			'meScreen.loadFailed' => '계정 정보를 불러오지 못했습니다. 로그인이 만료되었거나 네트워크에 연결할 수 없습니다.\n오른쪽 위의 새로고침을 눌러 다시 시도하고, 계속 실패하면 다시 로그인하세요.',
			'meScreen.logoutConfirm' => '로그아웃하시겠습니까?',
			'meScreen.boardNoKernel' => '대시보드는 코어의 실시간 데이터(연결 상태, 트래픽, 규칙 적중)를 보여줍니다.\n\n코어가 실행 중이 아니면 대시보드는 빈 화면만 표시됩니다.\n확인을 누르면 그대로 열고, 취소를 누르면 홈 탭에서 먼저 연결하세요.',
			'meScreen.boardOpened' => '브라우저에서 대시보드를 열었습니다. 노드나 규칙을 바꾸면 약 5초 안에 앱에 반영됩니다.',
			'homeScreen.expiresOn' => ({required Object date}) => '${date} 만료',
			'homeScreen.devicesText' => ({required Object text}) => '기기 ${text}',
			'homeScreen.upgrade' => '업그레이드',
			'homeScreen.quickCountries' => '빠른 국가 필터',
			'homeScreen.nodeCount' => ({required Object count}) => '노드 ${count}개',
			'homeScreen.autoBestTip' => '모든 국가에서 지연 시간이 가장 낮은 사용 가능 노드를 자동으로 선택합니다 (자동 모드)',
			'homeScreen.autoBest' => '자동 최적',
			'homeScreen.pickCountryTip' => ({required Object label}) => '"${label}"에서 지연 시간이 가장 낮은 사용 가능 노드를 자동으로 선택해 고정합니다',
			'homeScreen.autoNoBetter' => '이미 자동 모드입니다 (더 나은 노드가 없습니다)',
			'homeScreen.switchedBest' => ({required Object name}) => '최적 노드로 전환했습니다: ${name}',
			'homeScreen.switchedCountry' => ({required Object country, required Object node, required Object ms}) => '가장 빠른 ${country} 노드로 전환했습니다: ${node}${ms}',
			'homeScreen.filterCountryFailed' => ({required Object country, required Object err}) => '${country} 필터가 적용되었으나 전환 실패: ${err}',
			'homeScreen.deviceFullCount' => ({required Object used, required Object limit}) => '현재 기기 ${used}/${limit}\n\n',
			'homeScreen.deviceFullUpgradeHint' => '기기 한도를 업그레이드하면 즉시 연결이 복구됩니다(권장). 사용하지 않는 기기를 삭제해 자리를 확보할 수도 있습니다.',
			'homeScreen.later' => '나중에',
			'homeScreen.upgradeDeviceCount' => '기기 한도 업그레이드',
			'homeScreen.cannotConnect' => '연결할 수 없습니다',
			'homeScreen.freshnessNever' => '아직 동기화되지 않음 · 눌러서 새로고침',
			'homeScreen.freshnessJustNow' => '방금 업데이트됨 · 눌러서 기기 관리',
			'homeScreen.freshnessMinutes' => ({required Object minutes}) => '${minutes}분 전 · 눌러서 기기 관리',
			'homeScreen.freshnessStale' => ({required Object minutes}) => '${minutes}분 전 · 눌러서 새로고침',
			'homeScreen.subscriptionAutoSync' => '구독 자동 동기화',
			'homeScreen.connecting' => '연결 중…',
			'homeScreen.disconnecting' => '연결 해제 중…',
			'homeScreen.tapToDisconnect' => '스위치를 눌러 연결을 해제하세요',
			'homeScreen.tapToConnect' => '스위치를 눌러 연결하세요',
			'homeScreen.currentNode' => '현재 노드',
			'homeScreen.noNodeSelected' => '선택된 노드 없음',
			'homeScreen.switchAction' => '전환',
			'homeScreen.realtimeSpeed' => '실시간 속도',
			'homeScreen.totalTraffic' => '총 트래픽',
			'homeScreen.subSyncedNotReady' => '구독은 받았지만 프로필이 아직 준비되지 않았습니다. 잠시 후 다시 시도하세요.',
			'homeScreen.noPlan' => '이 계정에는 아직 사용할 수 있는 요금제가 없습니다. 먼저 구매하세요.',
			'homeScreen.loginExpired' => '로그인이 만료되었습니다. 다시 로그인하세요.',
			'homeScreen.syncingWait' => '구독을 동기화하는 중입니다. 잠시만 기다려 주세요.',
			'homeScreen.syncFailedNetwork' => ({required Object message}) => '구독 동기화 실패: ${message}\n네트워크를 확인하고 다시 시도하세요.',
			'homeScreen.syncFailed' => '구독 동기화에 실패했습니다. 나중에 다시 시도하세요.',
			'homeScreen.resetProxy' => '초기화',
			'homeScreen.latencySuffix' => ({required Object ms}) => ' (${ms}ms)',
			'nodesScreen.updatedCount' => ({required Object count}) => '구독 업데이트 완료: 노드 ${count}개',
			'nodesScreen.updateFailed' => ({required Object message}) => '업데이트 실패: ${message}',
			'nodesScreen.updateFailedNetwork' => '업데이트 실패, 네트워크를 확인하세요',
			'nodesScreen.testDone' => ({required Object ok, required Object fail}) => '속도 테스트 완료: ${ok}개 연결 가능, ${fail}개 연결 불가 (오프라인일 수 있음)',
			'nodesScreen.switchedTo' => ({required Object name}) => '${name}(으)로 전환했습니다',
			'nodesScreen.switchFailed' => ({required Object message}) => '전환 실패: ${message}\n(노드 전환은 코어가 실행 중이어야 합니다. 홈 탭에서 스위치를 먼저 켜세요.)',
			'nodesScreen.selectedAfterConnect' => ({required Object name}) => '${name} 선택됨 (연결한 뒤 적용됩니다)',
			'nodesScreen.title' => '노드',
			'nodesScreen.searchNode' => '노드 검색',
			'nodesScreen.sortByLatency' => '지연 시간순 정렬',
			'nodesScreen.updateSubscription' => '구독 업데이트',
			'nodesScreen.viewByGroup' => '프록시 그룹별 보기',
			'nodesScreen.testAll' => '전체 테스트',
			'nodesScreen.searchHint' => '노드 / 국가 / 프로토콜 검색',
			'nodesScreen.emptyNoNodes' => '사용할 수 있는 노드가 아직 없습니다.\n구독은 자동으로 동기화됩니다. 방금 로그인했다면 잠시 기다리거나 아래에서 다시 불러오세요.',
			'nodesScreen.emptyNoMatch' => '일치하는 노드가 없습니다.',
			'nodesScreen.reload' => '다시 불러오기',
			'nodesScreen.currentInUse' => '현재 (사용 중)',
			'nodesScreen.current' => '현재',
			'nodesScreen.notTested' => '측정 안 됨 (코어 재로드 대기)',
			'nodesScreen.timeout' => '시간 초과',
			'nodesScreen.clear' => '지우기',
			'nodesScreen.selectNode' => '노드 선택',
			'nodesScreen.emptyNoKernel' => '사용할 수 있는 노드가 아직 없습니다.\n홈 탭에서 연결 스위치를 먼저 켜세요.',
			'nodesScreen.openFullList' => '전체 노드 목록 열기 (검색 / 속도 테스트 / 그룹)',
			'nodeAuto.kernelStateUnavailable' => '코어에서 노드 상태를 일시적으로 가져올 수 없습니다. 자동으로 다시 시도합니다.',
			'nodeAuto.backToFixedNode' => ({required Object fixed}) => '고정 노드로 복귀: ${fixed}',
			'nodeAuto.noUsableNodePickOne' => '사용할 수 있는 노드를 찾지 못했습니다. 노드 목록에서 직접 선택하세요.',
			'nodeAuto.noUsableNodeTryOne' => '사용할 수 있는 노드를 찾지 못했습니다. 노드 목록에서 선택해 보세요.',
			'nodeAuto.autoConnectedBest' => ({required Object bestNode, required Object bestMs}) => '최적 노드에 자동 연결했습니다: ${bestNode} (${bestMs} ms)',
			'nodeAuto.currentNodeUnreachable' => '현재 노드로는 인터넷에 연결할 수 없습니다. 자동으로 전환합니다…',
			'nodeAuto.autoSwitchedToUsable' => ({required Object target}) => '사용할 수 있는 노드로 자동 전환했습니다: ${target}',
			'nodeAuto.newNodesReloading' => ({required Object missing}) => '구독의 새 노드 ${missing}개가 아직 코어에 없습니다. 다시 불러오는 중…',
			'nodeAuto.kernelReloadedRetest' => '새 구독으로 코어를 다시 불러왔습니다. 속도 테스트를 다시 실행하세요.',
			'accountBlock.quotaFull' => ({required Object used, required Object limit}) => '기기 자리가 가득 찼습니다 (${used}/${limit}). 이 기기는 허용 범위 안에 있어 정상적으로 연결할 수 있습니다. 기기를 추가하려면 기기 한도를 업그레이드하거나 사용하지 않는 기기를 삭제하세요.',
			'accountBlock.banFallback' => '계정이 비활성화되어 더 이상 사용할 수 없습니다.',
			'accountBlock.titleExpired' => '요금제 만료',
			'accountBlock.titleDeviceFull' => '기기 한도 도달',
			'accountBlock.titleAccountDisabled' => '계정 비활성화됨',
			'accountBlock.titlePlanDisabled' => '요금제 비활성화됨',
			'accountBlock.titleNoPlan' => '요금제 없음',
			'accountBlock.titleDeviceRemoved' => '이 기기가 제거되었습니다',
			'accountBlock.titleServiceUnavailable' => '서비스를 일시적으로 사용할 수 없음',
			'accountBlock.textExpired' => '요금제가 만료되었습니다. 글로벌 노드를 계속 사용하려면 요금제를 구매하세요.',
			'accountBlock.textDeviceFull' => ({required Object used, required Object limit}) => '서버에서 이 기기가 요금제 기기 한도(${used}/${limit})를 초과한 것으로 확인되어 현재는 연결할 수 없습니다. 내 정보 - 기기 관리에서 사용하지 않는 기기를 삭제하거나, 기기 수가 더 많은 요금제로 업그레이드하세요.',
			'accountBlock.textAccountDisabled' => '계정이 비활성화되었습니다. 문의 사항이 있으면 고객 지원에 연락하세요.',
			'accountBlock.textPlanDisabled' => '요금제가 비활성화되었거나 비정상 상태여서 연결할 수 없습니다. 문의 사항이 있으면 고객 지원에 연락하세요.',
			'accountBlock.textNoPlan' => '아직 요금제를 구매하지 않았습니다. 구매하면 글로벌 노드를 사용할 수 있습니다.',
			'accountBlock.textDeviceRemoved' => '이 기기가 제거되어 로그아웃되었습니다. 다시 로그인하세요.',
			'accountBlock.textServiceUnavailable' => '서비스를 일시적으로 사용할 수 없습니다. 나중에 다시 시도하고, 계속 문제가 생기면 화면을 캡처해 고객 지원에 문의하세요.',
			'accountBlock.remainingDays' => ({required Object days}) => '${days}일 남음',
			'accountBlock.deviceUsage' => ({required Object used, required Object limit}) => '기기 ${used}/${limit}',
			'entitlementMsg.tamperedTitle' => '인증 상태 비정상',
			'entitlementMsg.tamperedClock' => '시스템 시계 되돌림(또는 로컬 인증 데이터 변조)이 감지되었습니다. 연결하기 전에 네트워크에 접속해 인증을 완료하세요.',
			'entitlementMsg.tamperedLocal' => '로컬 인증 데이터가 손상되었거나 변조되었습니다. 연결하기 전에 네트워크에 접속해 인증을 완료하세요.',
			'entitlementMsg.needVerifyTitle' => '온라인 인증 필요',
			'entitlementMsg.needVerifyFirst' => '요금제 상태를 확인할 수 없습니다. 네트워크에 연결해 로그인한 뒤 연결하기 전에 인증을 한 번 완료하세요.',
			'entitlementMsg.needVerifyRetry' => '요금제 상태를 확인할 수 없습니다. 네트워크에 접속해 다시 시도하세요.',
			'entitlementMsg.verifyFailedTitle' => '요금제 상태를 확인할 수 없음',
			'entitlementMsg.verifyFailedText' => '인증 유예 기간이 지났고 서버에 연결할 수 없습니다. 네트워크를 확인하고 다시 시도하세요 (방금 갱신했다면 다시 로그인하세요).',
			'entitlementMsg.restrictedTitle' => '계정 제한됨',
			'entitlementMsg.restrictedFallback' => '계정 또는 요금제가 비활성화되어 연결할 수 없습니다.',
			'entitlementMsg.expiredTitle' => '요금제 만료',
			'entitlementMsg.expiredText' => ({required Object date}) => '요금제가 ${date}에 만료되었습니다. 로컬 구독 프로필이 삭제되었습니다. 갱신하고 다시 로그인하면 복원됩니다.',
			'devicesScreen.title' => '기기 관리',
			'devicesScreen.currentPlan' => '현재 요금제',
			'devicesScreen.devicesText' => ({required Object text}) => '기기 ${text}',
			'devicesScreen.upgradeTitle' => '기기 추가 / 기간 연장',
			'devicesScreen.upgradeSubtitle' => '기기와 일수를 함께 추가, 한 번의 결제',
			'devicesScreen.addDevices' => '기기 추가',
			'devicesScreen.noAddDevices' => '변경 없음',
			'devicesScreen.addDevicesCount' => ({required Object n}) => '기기 +${n}',
			'devicesScreen.addDays' => '일수 추가',
			'devicesScreen.noExtend' => '연장 없음',
			'devicesScreen.addDaysCount' => ({required Object n, required Object months}) => '+${n}일 (${months}개월)',
			'devicesScreen.priceFailed' => '가격을 가져오지 못했습니다',
			'devicesScreen.amountDue' => ({required Object amount}) => '합계 ¥${amount}',
			'devicesScreen.requote' => '다시 계산',
			'devicesScreen.goPay' => '결제하기',
			'devicesScreen.afterUpgrade' => '업그레이드 후: ',
			'devicesScreen.afterLimit' => ({required Object limit}) => '기기 한도 ${limit}',
			'devicesScreen.afterExpire' => ({required Object date}) => '${date} 만료',
			'devicesScreen.pickSomething' => '기기나 일수를 하나 이상 추가하세요',
			'devicesScreen.daysOnlyUnsupported' => '패널이 아직 "기간만 연장"을 지원하지 않습니다. "기기 추가"를 1 이상으로 설정하고 다시 시도하세요 (또는 고객 지원에 문의해 활성화하세요).',
			'devicesScreen.paramsRejected' => '매개변수가 거부되었습니다. 기기 수와 일수를 다시 선택하세요.',
			'devicesScreen.subscriptionExpired' => '구독이 만료되어 업그레이드할 수 없습니다. 먼저 갱신하거나 요금제를 구매하세요.',
			'devicesScreen.orderIncomplete' => '주문 정보가 불완전합니다. "다시 계산"을 누르고 다시 시도하세요.',
			'devicesScreen.orderRegenerated' => '이전 주문이 만료되어 같은 설정으로 새 주문이 생성되었습니다.',
			'devicesScreen.payChannelIncomplete' => '주문 또는 결제 채널 정보가 불완전합니다. 다시 계산하고 시도하세요.',
			'devicesScreen.noQrCode' => '서버가 결제 QR 코드나 링크를 반환하지 않았습니다. 다른 결제 수단을 선택하거나 나중에 시도하세요.',
			'devicesScreen.payStartFailed' => ({required Object err}) => '결제를 시작하지 못했습니다: ${err}',
			'devicesScreen.payCancelled' => '결제가 취소되었고 임시 주문이 정리되었습니다.',
			'devicesScreen.balancePay' => '잔액',
			'devicesScreen.noPayMethod' => '지금은 사용할 수 있는 결제 수단이 없습니다. 나중에 다시 시도하거나 고객 지원에 문의하세요.',
			'devicesScreen.balanceInsufficient' => ({required Object balance, required Object amount}) => '잔액 부족 (¥${balance}, ¥${amount} 필요).\n먼저 충전하시겠습니까?',
			'devicesScreen.choosePayMethod' => '결제 수단 선택',
			'devicesScreen.balanceText' => ({required Object balance}) => '잔액 ¥${balance}',
			'devicesScreen.balanceShort' => ({required Object balance}) => '잔액 ¥${balance} (부족, 충전 필요)',
			'devicesScreen.unknownDevice' => '알 수 없는 기기',
			'devicesScreen.online' => '● 온라인',
			'devicesScreen.offline' => '○ 오프라인',
			'devicesScreen.lastActive' => ({required Object text}) => '최근 활동 ${text}',
			'devicesScreen.delete' => '삭제',
			'devicesScreen.deleteConfirm' => ({required Object name}) => '기기 "${name}"을(를) 삭제하시겠습니까? 즉시 연결이 끊깁니다.',
			'devicesScreen.lastActiveJustNow' => '방금 전',
			'devicesScreen.lastActiveMinutes' => ({required Object minutes}) => '${minutes}분 전',
			'devicesScreen.lastActiveToday' => ({required Object time}) => '오늘 ${time}',
			'sysProxySheet.reading' => '읽는 중…',
			'sysProxySheet.unknown' => '알 수 없음',
			'sysProxySheet.kernelNotRunning' => '코어가 실행 중이 아닙니다 (홈 탭에서 스위치를 먼저 켜세요)',
			'sysProxySheet.applied' => ({required Object host, required Object port}) => '적용됨 · ${host}:${port}',
			'sysProxySheet.notSet' => ({required Object reason}) => '시스템 프록시가 설정되지 않음 — ${reason}',
			'sysProxySheet.notEffective' => ({required Object port}) => '적용되지 않음 (${port}을(를) 가리키는 시스템 프록시 없음)',
			'sysProxySheet.readFailed' => ({required Object err}) => '읽기 실패: ${err}',
			'sysProxySheet.setRejected' => '설정 실패: 시스템이 쓰기를 거부했거나 다른 프록시 앱이 덮어썼을 수 있습니다',
			'sysProxySheet.disableFailed' => '끄지 못했습니다',
			'sysProxySheet.portRange' => '포트는 1~65535 사이여야 합니다',
			'sysProxySheet.portChanged' => ({required Object value}) => '포트가 ${value}(으)로 변경되었습니다. 코어가 새 포트에서 대기하도록 연결을 한 번 끊고 다시 연결하세요',
			'sysProxySheet.title' => '시스템 프록시',
			'sysProxySheet.desc' => ({required Object host}) => '시스템 프록시 주소는 ${host}(로컬 루프백)로 고정되며 포트는 코어 혼합 포트입니다.',
			'sysProxySheet.descWindows' => 'Windows 설정 → 네트워크 및 인터넷 → 프록시에 표시되는 값과 정확히 같습니다.',
			'sysProxySheet.reset' => '다시 설정',
			'sysProxySheet.disable' => '시스템 프록시 끄기',
			'sysProxySheet.diagnostics' => '진단 (UI가 레지스트리와 같은 값을 읽고 있나요?)',
			'sysProxySheet.mixedPort' => '혼합 포트',
			'sysProxySheet.apply' => '적용',
			'logScreen.readAppFailed' => ({required Object e}) => '앱 로그를 읽지 못했습니다: ${e}',
			_ => null,
		} ?? switch (path) {
			'logScreen.readCoreFailed' => ({required Object e}) => '코어 로그를 읽지 못했습니다: ${e}',
			'logScreen.copied' => '복사했습니다 (구독 URL 등 민감 정보는 마스킹되지만, 로그 파일 자체에는 원본 주소가 남아 있을 수 있습니다)',
			'logScreen.copy' => '복사',
			'logScreen.refresh' => '새로고침',
			'logScreen.empty' => '내용 없음',
			'trayShell.closeTitle' => '창 닫기',
			'trayShell.closeBody' => '창을 닫아도 Mclash는 트레이로 들어갈 뿐이며, 코어와 시스템 프록시는 계속 동작하고 네트워크 연결도 유지됩니다.\n\n· 확인: 트레이로 최소화 (완전히 종료하려면 트레이 아이콘 우클릭 → 종료)\n· 취소: Mclash를 완전히 종료하고 코어를 중지하며 시스템 프록시를 복원합니다\n\n(선택한 내용이 기억되어 다음부터는 트레이 아이콘을 바로 사용할 수 있습니다)',
			'ordersScreen.title' => '내 주문',
			'ordersScreen.orderInfoIncomplete' => '주문 정보가 불완전합니다. 아래로 당겨 새로고침하고 다시 시도하세요.',
			'ordersScreen.payChannelIncomplete' => '결제 채널 정보가 불완전합니다. 나중에 다시 시도하세요.',
			'ordersScreen.noQrPayload' => '서버가 결제 QR 코드나 링크를 반환하지 않았습니다. 다른 결제 수단을 선택하거나 나중에 다시 시도하세요.',
			'ordersScreen.payStartFailed' => ({required Object err}) => '결제를 시작하지 못했습니다: ${err}',
			'ordersScreen.noPayMethod' => '지금은 사용할 수 있는 결제 수단이 없습니다. 나중에 다시 시도하거나 고객 지원에 문의하세요.',
			'ordersScreen.choosePayMethod' => '결제 수단 선택',
			'ordersScreen.amountDue' => ({required Object amount}) => '결제 금액 ¥${amount}',
			'ordersScreen.paidLabel' => '● 결제 완료',
			'ordersScreen.pendingLabel' => '○ 미결제',
			'ordersScreen.unknownStatus' => ({required Object status}) => '✕ ${status}',
			'ordersScreen.orderNoText' => ({required Object orderNo}) => '주문 번호 ${orderNo}',
			'ordersScreen.createdAtText' => ({required Object createdAt}) => '생성 시각 ${createdAt}',
			'ordersScreen.orderCanceled' => '주문이 취소되었습니다',
			'ordersScreen.cancelFailed' => ({required Object err}) => '취소 실패: ${err}\n(이미 결제되었거나 취소된 주문이라면 아래로 당겨 새로고침해 최신 상태를 확인하세요.)',
			'ordersScreen.cancelOrder' => '주문 취소',
			'ordersScreen.continuePay' => '결제 계속하기',
			'payment.balancePay' => '잔액 결제',
			'payment.qrPay' => 'QR 코드 결제',
			'payment.deductFromBalance' => '계정 잔액에서 차감됩니다',
			'payment.openedInBrowser' => '브라우저에서 결제 페이지를 열었습니다',
			'payment.scanWithAlipayWechat' => 'Alipay 또는 WeChat으로 스캔하세요',
			'payment.orderNoText' => ({required Object orderNo}) => '주문 번호 ${orderNo}',
			'payment.payFailed' => ({required Object err}) => '결제 실패: ${err}',
			'payment.notDetected' => '결제가 감지되지 않았습니다. 나중에 "내 주문"에서 계속할 수 있습니다.',
			'payment.charging' => '결제 중…',
			'payment.processing' => '처리 중…',
			'payment.waitingPay' => '결제를 기다리는 중…',
			'payment.openPageFailed' => '결제 페이지를 열지 못했습니다. 아래 버튼을 눌러 다시 시도하거나 QR 코드를 스캔하세요.',
			'payment.reopenPayPage' => '결제 페이지 다시 열기',
			'payment.payInBrowser' => '브라우저에서 결제',
			'payment.openAlipay' => 'Alipay 열기',
			'payment.cancelOrder' => '주문 취소',
			'payment.confirmPay' => '결제 확인',
			'payment.retry' => '다시 시도',
			'payment.paidAlready' => '결제했습니다',
			'payment.channelAlipay' => 'Alipay',
			'payment.channelCodepayAlipay' => '코드페이 · Alipay',
			'payment.channelCodepayWechat' => '코드페이 · WeChat',
			'payment.channelCodepay' => '코드페이',
			'payment.channelWechat' => 'WeChat Pay',
			'payment.channelUsdt' => 'USDT',
			'payment.channelUsdtTrc20' => 'USDT · TRC20',
			'payment.payFallback' => '결제',
			'payment.errCsrf' => '로그인 자격 증명이 만료되었습니다 (CSRF 검사 실패).\n"내 정보" 탭에서 아래로 당겨 새로고침하거나 다시 로그인한 뒤 재시도하세요.',
			'payment.errAlipayLimit' => 'Alipay 대면 결제는 건당 한도(이 가맹점은 ¥1000)가 있어 이 주문은 한도를 초과합니다.\n"잔액 결제" 또는 "코드페이"를 사용하거나, 고객 지원에 문의해 Alipay 한도를 높이세요.',
			'payment.errNotSigned' => 'Alipay 앱이 해당 결제 상품에 가입되어 있지 않아 이 채널을 일시적으로 사용할 수 없습니다.\n"잔액 결제" 또는 "코드페이"를 사용하거나, 고객 지원에 문의해 활성화하세요.',
			'payment.errOrderGone' => '이 주문은 취소되었거나 만료되었습니다 (임시 주문은 30분간 유효합니다).\n"다시 계산"을 눌러 새 주문을 만든 뒤 결제하세요.',
			'payment.errNetwork' => ({required Object err}) => '네트워크에 연결할 수 없습니다: ${err}',
			'planScreen.recommended' => '추천',
			'planScreen.devices' => '기기',
			'planScreen.balanceLabel' => ({required Object amount}) => '잔액 ¥${amount}',
			'planScreen.balanceInsufficient' => ' (부족, 먼저 충전하세요)',
			'planScreen.total' => '합계',
			'planScreen.payNow' => '결제하기',
			'planScreen.retry' => '다시 시도',
			'planScreen.errIncompleteOrder' => '주문 또는 결제 채널 정보가 불완전하여 결제를 시작할 수 없습니다.',
			'planScreen.payBalance' => '잔액 결제',
			'planScreen.payAlipay' => 'Alipay',
			'planScreen.payWechat' => 'WeChat Pay',
			'planScreen.payCodepay' => '코드페이',
			'planScreen.payCodepayAlipay' => '코드페이 · Alipay',
			'planScreen.payCodepayWechat' => '코드페이 · WeChat',
			'planScreen.payEpayAlipay' => '이페이 · Alipay',
			'planScreen.payEpayWechat' => '이페이 · WeChat',
			'planScreen.payUsdt' => 'USDT',
			'planScreen.payUsdtTrc20' => 'USDT · TRC20',
			'planScreen.payStripe' => 'Stripe',
			'planScreen.payPaypal' => 'PayPal',
			'planScreen.payOnline' => '온라인 결제',
			'authScreen.saveAccountInfo' => '계정 정보 저장',
			'authScreen.autoLoginNextTime' => '다음부터 자동 로그인',
			'authScreen.needLoginNextTime' => '다음에는 다시 로그인해야 합니다',
			'authScreen.invalidEmail' => '올바른 이메일 주소를 입력하세요',
			'authScreen.enterEmailFirst' => '먼저 올바른 이메일 주소를 입력하세요',
			'authScreen.passwordRequired' => '비밀번호를 입력하세요',
			'authScreen.wrongCredentials' => '이메일 또는 비밀번호가 올바르지 않습니다',
			'authScreen.requestRejected' => '요청이 거부되었습니다. 나중에 다시 시도하세요.',
			'authScreen.tooFrequent' => '시도가 너무 많습니다. 나중에 다시 시도하세요.',
			'authScreen.loginFailed' => '로그인 실패',
			'authScreen.username' => '사용자 이름',
			'authScreen.confirmPassword' => '비밀번호 확인',
			'authScreen.inviteCode' => '초대 코드',
			'authScreen.emailCode' => '이메일 인증 코드',
			'authScreen.getCode' => '코드 받기',
			'authScreen.registerAndLogin' => '가입하고 로그인',
			'authScreen.usernameMinLength' => ({required Object min}) => '사용자 이름은 ${min}자 이상이어야 합니다',
			'authScreen.passwordMismatch' => '비밀번호가 일치하지 않습니다',
			'authScreen.emailCodeRequired' => '이메일 인증 코드를 입력하세요',
			'authScreen.inviteCodeRequired' => '이 사이트는 가입 시 초대 코드가 필요합니다',
			'authScreen.codeSentCheckEmail' => '인증 코드를 보냈습니다. 이메일을 확인하세요.',
			'authScreen.registerSuccess' => '가입이 완료되었습니다. 로그인되었습니다.',
			'authScreen.passwordHint' => ({required Object min}) => '${min}자 이상, 영문과 숫자를 모두 포함',
			'authScreen.passwordTooShort' => ({required Object min}) => '비밀번호는 ${min}자 이상이어야 합니다',
			'authScreen.passwordNeedsLetterAndDigit' => '비밀번호에 영문과 숫자를 모두 포함해야 합니다',
			'authScreen.registeredEmail' => '가입한 이메일',
			'authScreen.newPassword' => '새 비밀번호',
			'authScreen.confirmNewPassword' => '새 비밀번호 확인',
			'authScreen.resetPassword' => '비밀번호 재설정',
			'authScreen.resetCodeSent' => '이 이메일이 가입되어 있다면 재설정 코드를 보냈습니다 (15분간 유효).',
			'authScreen.resetSuccess' => '비밀번호가 재설정되었습니다. 새 비밀번호로 로그인하세요.',
			'authScreen.changePasswordTitle' => '비밀번호 변경',
			'authScreen.currentPassword' => '현재 비밀번호',
			'authScreen.saveNewPassword' => '새 비밀번호 저장',
			'authScreen.newPasswordMismatch' => '새 비밀번호가 일치하지 않습니다',
			'authScreen.changePasswordSuccess' => '비밀번호가 변경되었습니다. 다시 로그인하세요.',
			'updatePrompt.checking' => '업데이트 확인 중…',
			'updatePrompt.checkFailed' => '업데이트 확인에 실패했습니다. 네트워크를 확인하고 다시 시도하세요.',
			'updatePrompt.alreadyLatest' => ({required Object version}) => '최신 버전(${version})을 사용 중입니다.',
			'updatePrompt.newVersionFound' => ({required Object version}) => '새 버전 ${version}이(가) 있습니다',
			'updatePrompt.installerDownloaded' => '설치 파일이 백그라운드에서 다운로드를 마쳤습니다. 지금 업데이트를 눌러 업그레이드를 완료하세요.',
			'updatePrompt.downloadInBackground' => '지금 업데이트를 누르면 다운로드 후 설치가 진행됩니다 (앱을 계속 사용할 수 있으며 설치 파일은 백그라운드에서 다운로드됩니다).',
			'updatePrompt.later' => '나중에',
			'updatePrompt.updateNow' => '지금 업데이트',
			'updatePrompt.installerNotReady' => ({required Object version}) => '설치 파일 다운로드가 아직 끝나지 않았습니다.\n\n확인을 누르면 다운로드 페이지를 열어 기기에 맞는 설치 파일(버전 ${version})을 직접 받을 수 있습니다.',
			'clearData.itemLoginSession' => '로그인 세션',
			'clearData.itemProfiles' => '구독 프로필 (profiles/)',
			'clearData.itemSettings' => '앱 및 코어 설정',
			'clearData.itemLatencyCache' => '노드 지연 시간 캐시',
			'clearData.itemLogs' => '실행 로그',
			'clearData.itemRoutingData' => '라우팅 데이터 및 임시 파일',
			'clearData.confirmBody' => ({required Object items, required Object dir}) => '이 기기에 저장된 다음 데이터가 삭제됩니다 (되돌릴 수 없습니다):\n\n${items}\n\n계정 자체와 구매한 요금제는 서버에 있으므로 영향을 받지 않습니다. 다시 로그인하면 구독이 복원됩니다.\n\n데이터 디렉토리: ${dir}\n(앱을 제거하기 전에 실행하세요. 그래야 재설치 시 깨끗하게 시작하고 다시 로그인을 요구합니다)',
			'clearData.confirmAgain' => '지금 삭제하시겠습니까? 이후 다시 로그인해야 합니다.',
			'clearData.clearedNotice' => ({required Object count, required Object dir}) => '로컬 데이터 ${count}개를 삭제했습니다 (로그인 세션 포함, 다음에 앱을 열 때 다시 로그인해야 합니다).\n\n이제 앱을 삭제해 제거를 마무리할 수 있습니다:\n· macOS: Mclash.app을 휴지통으로 드래그 (데이터 디렉토리는 비워졌습니다: ${dir})\n· Windows: 제어판에서 Mclash를 제거하고, 사용자 데이터 유지 여부를 묻는 단계에서 "아니요"를 선택하세요',
			'clearData.clearFailed' => ({required Object error}) => '삭제 실패: ${error}',
			'apiError.requestFailedHttp' => ({required Object status, required Object domain}) => '요청 실패 (HTTP ${status}), ${domain} 시도함',
			'apiError.allDomainsFailed' => ({required Object method, required Object path, required Object count}) => '요청 실패: ${method} ${path} (도메인 ${count}개 시도)',
			'apiError.requestTimeout' => ({required Object seconds, required Object method, required Object path}) => '요청 시간 초과 (${seconds}초): ${method} ${path}',
			'apiError.networkUnreachable' => ({required Object detail}) => '네트워크에 연결할 수 없습니다: ${detail}',
			'apiError.tlsHandshakeFailed' => 'TLS 핸드셰이크에 실패했습니다. 네트워크 연결이나 시스템 시간을 확인하세요.',
			'apiError.connectionFailed' => ({required Object detail}) => '연결 실패: ${detail}',
			'apiError.requestError' => ({required Object error}) => '요청 실패: ${error}',
			'apiError.responseReadTimeout' => ({required Object seconds, required Object method, required Object path}) => '응답 읽기 시간 초과 (${seconds}초): ${method} ${path}',
			'apiError.notJson' => ({required Object status, required Object snippet}) => '응답이 JSON이 아닙니다 (HTTP ${status}): ${snippet}',
			'apiError.badStructure' => ({required Object status}) => '예상하지 못한 응답 구조 (HTTP ${status})',
			'apiError.loginFailed' => ({required Object code}) => '로그인 실패 (코드 ${code})',
			'apiError.loginMissingData' => '로그인 응답에 데이터가 없습니다',
			'apiError.loginMissingToken' => '로그인 응답에 access_token이 없습니다',
			'apiError.registerFailed' => ({required Object code}) => '가입 실패 (코드 ${code})',
			'apiError.registerMissingToken' => '가입 응답에 access_token이 없습니다. 리스크 컨트롤이 작동했거나 사이트 설정이 다를 수 있습니다',
			'apiError.requestFailedCode' => ({required Object code}) => '요청 실패 (코드 ${code})',
			'subNotice.titleNotFound' => '구독을 찾을 수 없음',
			'subNotice.titleExpired' => '구독 만료',
			'subNotice.titleInactive' => '구독 비활성',
			'subNotice.titleDeviceOverLimit' => '기기 한도 초과',
			'subNotice.titleUnavailable' => '구독 사용 불가',
			'subNotice.titleWithReason' => ({required Object emoji, required Object title, required Object reason}) => '${emoji} ${title} (${reason})',
			'subNotice.deviceUsedOfLimit' => ({required Object used, required Object limit}) => '현재 기기 ${used}/${limit}',
			'subNotice.deviceUsedOnly' => ({required Object used}) => '현재 기기 ${used}',
			'subNotice.expireAt' => ({required Object expire}) => '${expire} 만료',
			'subNotice.supportLine' => ({required Object account}) => '💬 고객 지원: ${account}',
			'subNotice.siteLine' => ({required Object url}) => '📢 웹사이트: ${url}',
			'settingItems.subscriptionAutoUpdateInterval' => '구독 자동 업데이트 간격',
			'settingItems.speedTestMode' => '속도 테스트 방식',
			'settingItems.speedTestModeTcp' => 'TCP 속도 테스트',
			'settingItems.speedTestModeKernel' => '코어 속도 테스트',
			'settingItems.delayTestUrlTip' => '이 노드를 거쳐 HTTP 요청 한 번을 끝내는 데 걸리는 시간입니다 (핑이 아닙니다)\n기본값은 단순한 http 204 빈 응답이며, https를 쓰면 TLS 핸드셰이크가 더해져 값이 커집니다',
			'settingItems.systemProxy' => '시스템 프록시',
			'settingItems.systemProxyTip' => '주소와 포트 보기 / 재설정',
			'settingItems.tunMode' => 'TUN 모드',
			'settingItems.tunModeTip' => 'off=시스템 프록시만 / auto=TUN+시스템 프록시 / force=TUN만\n데스크톱에서 TUN은 관리자 권한이 필요합니다 (Windows는 wintun / macOS는 utun)',
			'settingItems.tunOverwriteTip' => '덮어쓰기\n켜짐 = 이 페이지의 TUN 설정이 프로필의 tun 섹션을 덮어씁니다\n꺼짐 = 프로필 자체의 tun 설정을 사용합니다 (앱이 간섭하지 않음)',
			'settingItems.tunEnableByTunMode' => ({required Object enable}) => '${enable} (TUN 모드에 따라 결정됨)',
			'settingItems.interval30Minutes' => '30분',
			'settingItems.interval1Hour' => '1시간',
			'settingItems.interval6Hours' => '6시간',
			'settingItems.interval12Hours' => '12시간',
			'settingItems.interval24Hours' => '24시간',
			'settingItems.interval3Days' => '3일',
			'settingItems.interval7Days' => '7일',
			'settingItems.intervalNever' => '사용 안 함',
			'settingItems.intervalMinutes' => ({required Object minutes}) => '${minutes}분',
			'settingItems.intervalHours' => ({required Object hours}) => '${hours}시간',
			'settingItems.intervalDays' => ({required Object days}) => '${days}일',
			'tunScreen.modeOff' => '끔',
			'tunScreen.modeAuto' => '자동',
			'tunScreen.modeForce' => '강제',
			'tunScreen.modeOffDesc' => '시스템 프록시만: 시스템 프록시를 따르는 프로그램(브라우저 등)에만 적용되며 UDP/게임은 프록시되지 않습니다',
			'tunScreen.modeAutoDesc' => 'TUN + 시스템 프록시 (이중 안전장치): UDP를 포함한 모든 트래픽이 가상 어댑터를 통과합니다',
			'tunScreen.modeForceDesc' => 'TUN만: 모든 트래픽이 가상 어댑터를 통과하고 시스템 프록시는 건드리지 않습니다',
			'tunScreen.modeOffOptionDesc' => '시스템 라우팅 테이블은 건드리지 않고 시스템에 127.0.0.1 프록시만 설정합니다. 시스템 프록시를 따르는 프로그램만 사용하며, UDP 트래픽과 자체 프록시 설정을 쓰는 프로그램은 해당되지 않습니다.',
			'tunScreen.modeAutoOptionDesc' => '가상 어댑터를 만들어 UDP와 게임을 포함한 모든 트래픽을 처리하고, 시스템 프록시는 대비책으로 유지합니다. 권장: 전역으로 동작하며 권한이 없어도 네트워크가 끊기지 않습니다.',
			'tunScreen.modeForceOptionDesc' => '가상 어댑터만 사용하고 시스템 프록시는 더 이상 변경하지 않습니다. UDP를 포함한 모든 트래픽이 터널을 통과하며 시스템의 "프록시" 항목은 그대로 유지됩니다.',
			'tunScreen.adminRequiredDialog' => 'TUN 가상 어댑터에는 관리자 권한이 필요합니다 (Windows는 wintun / macOS는 utun).\n\n현재 Mclash가 관리자 권한으로 실행되고 있지 않아 TUN을 켜도 적용되지 않습니다 ("자동" 모드에서는 시스템 프록시가 대비책으로 동작해 네트워크를 계속 사용할 수 있습니다).\n\n확인 = 지금 Mclash를 관리자 권한으로 다시 시작 (UAC 창이 표시됩니다)\n취소 = 이 선택을 그대로 저장 (TUN을 사용할 수 없으면 시스템 프록시를 자동으로 사용합니다)',
			'tunScreen.relaunchFailed' => ({required Object message}) => '다시 시작 실패: ${message}',
			'tunScreen.switchFailed' => ({required Object message}) => 'TUN 모드 전환 실패: ${message}\n이전 설정이 복원되었습니다.',
			'tunScreen.setOffSnack' => '"끔"으로 설정했습니다: 시스템 프록시만',
			'tunScreen.setModeSnack' => ({required Object mode, required Object effect}) => '"${mode}"(으)로 설정했습니다, ${effect}',
			'tunScreen.effectReconnected' => '다시 연결되어 지금 적용되었습니다',
			'tunScreen.effectAfterConnect' => '연결 후 적용됩니다',
			'tunScreen.sheetTitle' => 'TUN 가상 어댑터',
			'tunScreen.advancedTitle' => '고급 매개변수 (코어 설정 → TUN)',
			'tunScreen.advancedSubtitle' => '어댑터 주소 / 스택 / MTU / 자동 라우트 / DNS 하이재킹 / 덮어쓰기',
			'tunScreen.adminOk' => 'TUN에는 관리자 권한이 필요하며 현재 권한으로 충분합니다 (Windows는 관리자 권한으로, macOS는 root로 실행)',
			'tunScreen.adminMissing' => 'TUN에는 관리자 권한이 필요합니다. Mclash가 관리자 권한으로 실행되고 있지 않아 "자동/강제"를 선택해도 TUN이 적용되지 않습니다 ("자동"은 시스템 프록시로 대체되어 네트워크는 계속 사용할 수 있습니다)',
			_ => null,
		};
	}
}
