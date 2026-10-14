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
class TranslationsJa with BaseTranslations<AppLocale, Translations> implements Translations {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	TranslationsJa({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: AppLocale.ja,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <ja>.
	final TranslationMetadata<AppLocale, Translations> _meta;
	@override TranslationMetadata<AppLocale, Translations> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key);

	late final TranslationsJa _root = this; // ignore: unused_field

	@override 
	TranslationsJa $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => TranslationsJa(meta: meta ?? this.$meta);

	// Translations
	@override late final _Translations$BackupAndSyncWebdavScreen$ja BackupAndSyncWebdavScreen = _Translations$BackupAndSyncWebdavScreen$ja._(_root);
	@override late final _Translations$LaunchFailedScreen$ja LaunchFailedScreen = _Translations$LaunchFailedScreen$ja._(_root);
	@override late final _Translations$PerAppAndroidScreen$ja PerAppAndroidScreen = _Translations$PerAppAndroidScreen$ja._(_root);
	@override late final _Translations$UserAgreementScreen$ja UserAgreementScreen = _Translations$UserAgreementScreen$ja._(_root);
	@override late final _Translations$NetCheckScreen$ja NetCheckScreen = _Translations$NetCheckScreen$ja._(_root);
	@override late final _Translations$VersionUpdateScreen$ja VersionUpdateScreen = _Translations$VersionUpdateScreen$ja._(_root);
	@override late final _Translations$loginScreen$ja loginScreen = _Translations$loginScreen$ja._(_root);
	@override late final _Translations$main$ja main = _Translations$main$ja._(_root);
	@override late final _Translations$meta$ja meta = _Translations$meta$ja._(_root);
	@override late final _Translations$permission$ja permission = _Translations$permission$ja._(_root);
	@override late final _Translations$tls$ja tls = _Translations$tls$ja._(_root);
	@override late final _Translations$tun$ja tun = _Translations$tun$ja._(_root);
	@override late final _Translations$dns$ja dns = _Translations$dns$ja._(_root);
	@override late final _Translations$sniffer$ja sniffer = _Translations$sniffer$ja._(_root);
	@override late final _Translations$profilePatchMode$ja profilePatchMode = _Translations$profilePatchMode$ja._(_root);
	@override String sendOrReceiveNotMatch({required Object p}) => '[${p}] を使用してください';
	@override String targetConnectFailed({required Object p}) => '[${p}] への接続に失敗しました。デバイスが同じ LAN 内にあることを確認してください';
	@override String get edgeRuntimeNotInstalled => '現在のデバイスには Edge WebView2 ランタイムがインストールされていないため、ページを表示できません。Edge WebView2 ランタイム (x64) をダウンロードしてインストールし、アプリを再起動してからもう一度お試しください。';
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
	@override late final _Translations$meScreen$ja meScreen = _Translations$meScreen$ja._(_root);
	@override late final _Translations$homeScreen$ja homeScreen = _Translations$homeScreen$ja._(_root);
	@override late final _Translations$nodesScreen$ja nodesScreen = _Translations$nodesScreen$ja._(_root);
	@override late final _Translations$nodeAuto$ja nodeAuto = _Translations$nodeAuto$ja._(_root);
	@override late final _Translations$accountBlock$ja accountBlock = _Translations$accountBlock$ja._(_root);
	@override late final _Translations$entitlementMsg$ja entitlementMsg = _Translations$entitlementMsg$ja._(_root);
	@override late final _Translations$devicesScreen$ja devicesScreen = _Translations$devicesScreen$ja._(_root);
	@override late final _Translations$sysProxySheet$ja sysProxySheet = _Translations$sysProxySheet$ja._(_root);
	@override late final _Translations$logScreen$ja logScreen = _Translations$logScreen$ja._(_root);
	@override late final _Translations$trayShell$ja trayShell = _Translations$trayShell$ja._(_root);
	@override late final _Translations$ordersScreen$ja ordersScreen = _Translations$ordersScreen$ja._(_root);
	@override late final _Translations$payment$ja payment = _Translations$payment$ja._(_root);
	@override late final _Translations$planScreen$ja planScreen = _Translations$planScreen$ja._(_root);
	@override late final _Translations$authScreen$ja authScreen = _Translations$authScreen$ja._(_root);
	@override late final _Translations$updatePrompt$ja updatePrompt = _Translations$updatePrompt$ja._(_root);
	@override late final _Translations$clearData$ja clearData = _Translations$clearData$ja._(_root);
	@override late final _Translations$apiError$ja apiError = _Translations$apiError$ja._(_root);
	@override late final _Translations$subNotice$ja subNotice = _Translations$subNotice$ja._(_root);
	@override late final _Translations$settingItems$ja settingItems = _Translations$settingItems$ja._(_root);
	@override late final _Translations$tunScreen$ja tunScreen = _Translations$tunScreen$ja._(_root);
}

// Path: BackupAndSyncWebdavScreen
class _Translations$BackupAndSyncWebdavScreen$ja implements Translations$BackupAndSyncWebdavScreen$en {
	_Translations$BackupAndSyncWebdavScreen$ja._(this._root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get webdavServerUrl => 'サーバーURL';
	@override String get webdavRequired => '空にすることはできません';
	@override String get webdavLoginFailed => 'ログインに失敗しました:';
	@override String get webdavListFailed => 'ファイルリストの取得に失敗しました:';
}

// Path: LaunchFailedScreen
class _Translations$LaunchFailedScreen$ja implements Translations$LaunchFailedScreen$en {
	_Translations$LaunchFailedScreen$ja._(this._root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get invalidProcess => 'アプリの起動に失敗しました [無効なプロセス名]。アプリを別のディレクトリに再インストールしてください';
	@override String get invalidProfile => 'アプリの起動に失敗しました [プロファイルへのアクセスに失敗]。アプリを再インストールしてください';
	@override String get invalidVersion => 'アプリの起動に失敗しました [無効なバージョン]。アプリを再インストールしてください';
	@override String get systemVersionLow => 'アプリの起動に失敗しました [システムバージョンが低すぎます]';
	@override String get invalidInstallPath => 'インストールパスが無効です。有効なパスに再インストールしてください';
}

// Path: PerAppAndroidScreen
class _Translations$PerAppAndroidScreen$ja implements Translations$PerAppAndroidScreen$en {
	_Translations$PerAppAndroidScreen$ja._(this._root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get title => 'アプリごとのプロキシ';
	@override String get whiteListMode => 'ホワイトリストモード';
	@override String get whiteListModeTip => '有効な場合：チェックされたアプリのみがプロキシされます。無効な場合：チェックされていないアプリのみがプロキシされます';
}

// Path: UserAgreementScreen
class _Translations$UserAgreementScreen$ja implements Translations$UserAgreementScreen$en {
	_Translations$UserAgreementScreen$ja._(this._root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get privacyFirst => 'プライバシーを第一に';
	@override String get agreeAndContinue => '同意して続行';
}

// Path: NetCheckScreen
class _Translations$NetCheckScreen$ja implements Translations$NetCheckScreen$en {
	_Translations$NetCheckScreen$ja._(this._root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get enterDomain => 'ドメイン名を入力してください';
	@override String get checking => '確認中...';
	@override String aQueryFailed({required Object p}) => 'Aレコード照会失敗: ${p}';
	@override String aaaaQueryFailed({required Object p}) => 'AAAAレコード照会失敗: ${p}';
	@override String get success => '成功';
	@override String get failed => '失敗';
	@override String get suspectedPollution => 'DNS汚染の疑い';
	@override String get domainLabel => 'ドメイン';
	@override String get checkButton => '診断';
	@override String get dnsSection => '1. DNS照会';
	@override String get directHttpSection => '2. HTTP (TUN経由、先にTUNを有効にしてください)';
	@override String proxyHttpSection({required Object p}) => '3. HTTP (プロキシ経由、ポート: ${p})';
	@override String get tunNotEnabled => 'TUN が有効になっていません';
	@override String get routeTableSection => '4. ルートテーブル';
}

// Path: VersionUpdateScreen
class _Translations$VersionUpdateScreen$ja implements Translations$VersionUpdateScreen$en {
	_Translations$VersionUpdateScreen$ja._(this._root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String versionReady({required Object p}) => '新しいバージョン [${p}] の準備ができました';
	@override String get update => '再起動して更新';
	@override String get cancel => '今はしない';
}

// Path: loginScreen
class _Translations$loginScreen$ja implements Translations$loginScreen$en {
	_Translations$loginScreen$ja._(this._root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get login => 'ログイン';
	@override String get register => 'アカウント登録';
	@override String get forgotPassword => 'パスワードを忘れた';
	@override String get provider => 'プロバイダー';
	@override String get providerName => '${_root.loginScreen.provider}コード/別名/URL';
	@override String get account => 'アカウント';
	@override String get email => 'メール';
	@override String get password => 'パスワード';
}

// Path: main
class _Translations$main$ja implements Translations$main$en {
	_Translations$main$ja._(this._root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override late final _Translations$main$tray$ja tray = _Translations$main$tray$ja._(_root);
}

// Path: meta
class _Translations$meta$ja implements Translations$meta$en {
	_Translations$meta$ja._(this._root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get enable => '有効';
	@override String get disable => '無効';
	@override String get open => '開く';
	@override String get close => '閉じる';
	@override String get quit => '終了';
	@override String get add => '追加';
	@override String get remove => '削除';
	@override String get removeConfirm => '本当に削除しますか？';
	@override String get edit => '編集';
	@override String get view => '表示';
	@override String get remark => '備考';
	@override String get byDefault => 'デフォルト';
	@override String get more => '詳細';
	@override String get tips => '情報';
	@override String get selectAll => 'すべて選択';
	@override String get copy => 'コピー';
	@override String get paste => '貼り付け';
	@override String get cut => '切り取り';
	@override String get save => '保存';
	@override String get ok => 'OK';
	@override String get cancel => 'キャンセル';
	@override String get faq => 'よくある質問';
	@override String get doc => 'ドキュメント';
	@override String get htmlTools => 'HTMLツールセット';
	@override String get download => 'ダウンロード';
	@override String get loading => '読み込み中...';
	@override String get days => '日';
	@override String get hours => '時間';
	@override String get minutes => '分';
	@override String get seconds => '秒';
	@override String get milliseconds => 'ミリ秒';
	@override String get search => '検索';
	@override String get searchNodeHint => 'ノードを絞り込む（名前またはプロトコル）';
	@override String get connect => '接続';
	@override String get disconnect => '切断';
	@override String get connected => '接続済み';
	@override String get disconnected => '切断済み';
	@override String get connecting => '接続中';
	@override String get connectTimeout => '接続タイムアウト';
	@override String get timeout => 'タイムアウト';
	@override String get latencyTest => '遅延チェック';
	@override String get networkCheck => 'ネットワーク診断';
	@override String get language => '言語';
	@override String get next => '次へ';
	@override String get done => '完了';
	@override String get apply => '適用';
	@override String get refresh => '更新';
	@override String get update => '更新';
	@override String get updateInterval => '更新間隔';
	@override String updateFailed({required Object p}) => '更新に失敗しました: ${p}';
	@override String get updateInterval5mTips => '最小: 5分';
	@override String get updateIntervalPreferByProfile => 'プロバイダーの設定を優先';
	@override String get none => 'なし';
	@override String get reset => 'リセット';
	@override String get authentication => '認証';
	@override String get user => 'ユーザー';
	@override String get account => 'アカウント';
	@override String get password => 'パスワード';
	@override String get decryptPassword => '複号化パスワード';
	@override String get required => '必須';
	@override String get go => '続行';
	@override String get other => 'その他';
	@override String get dns => 'DNS';
	@override String get url => 'URL';
	@override String get urlInvalid => '無効なURL';
	@override String get copyUrl => 'リンクをコピー';
	@override String get openUrl => 'リンクを開く';
	@override String get coreSettingTips => '注意：設定を変更した後、有効にするには再接続する必要があります';
	@override String get overwrite => '上書き';
	@override String get overwriteAppend => '追加上書き';
	@override String get overwriteTips => 'オリジナルプロファイル <- カスタム上書き <- アプリ上書き';
	@override String get noOverwrite => '上書きしない';
	@override String get diversionTemplates => '転送テンプレート';
	@override String get ruleProviders => 'ルールプロバイダー';
	@override String get ruleTemplates => 'ルールテンプレート';
	@override String get proxyGroupsTemplates => 'プロキシグループテンプレート';
	@override String get proxyGroups => 'プロキシグループ';
	@override String get proxyNodeList => 'プロキシノードリスト';
	@override String proxyNodeFailure({required Object p}) => '以下のプロキシノードは期限切れのため自動的に削除されました: ${p}';
	@override String get externalController => '外部コントローラー';
	@override String get secret => 'シークレット';
	@override String get tcpConcurrent => 'TCP並行ハンドシェイク';
	@override String get globalClientFingerprint => 'TLSグローバルフィンガープリント';
	@override String get allowLanAccess => 'LANデバイスアクセス';
	@override String get mixedPort => '混合プロキシポート';
	@override String get logLevel => 'ログレベル';
	@override String get findProcessMode => 'プロセスマッチングモード';
	@override String get tcpkeepAliveInterval => 'TCPキープアライブ間隔';
	@override String get delayTestUrl => '遅延テストURL';
	@override String get delayTestTimeout => '遅延テストタイムアウト(ms)';
	@override String get tun => 'TUN';
	@override String get ntp => 'NTP';
	@override String get tls => 'TLS';
	@override String get geoDownloadByProxy => 'プロキシ経由でGeo RuleSetをダウンロード';
	@override String get geoRulesetTips => 'Geosite/Geoipは対応するRuleSetに変換されます';
	@override String get sniffer => 'スニッファー';
	@override String get userAgent => 'UserAgent';
	@override String get launchAtStartup => 'スタートアップ時に起動';
	@override String get launchAtStartupRunAsAdmin => 'Mclashを管理者として再起動してください';
	@override String get tunModeRunAsAdmin => 'TUNモードにはシステム管理者権限が必要です。アプリを管理者として再起動してください';
	@override String get portableMode => 'ポータブルモード';
	@override String get portableModeDisableTips => 'ポータブルモードを終了する必要がある場合は、[mclash]を終了し、[mclash.exe]と同じディレクトリにある[portable]フォルダを手動で削除してください';
	@override String get autoConnectAfterLaunch => '起動後に自動接続';
	@override String get autoConnectAtBoot => 'システム起動後に自動接続';
	@override String get autoConnectAtBootTips => 'システムのサポートが必要です。一部のシステムでは[自動起動]を有効にする必要がある場合があります。';
	@override String get hideAfterLaunch => '起動後にウィンドウを隠す';
	@override String get autoSetSystemProxy => '接続時にシステムプロキシを自動設定';
	@override String get bypassSystemProxy => 'システムプロキシをバイパスすることを許可するドメイン名';
	@override String get excludeFromRecent => '[最近のタスク]から隠す';
	@override String get wakeLock => 'スリープ防止';
	@override String get hideDockIcon => 'Dockアイコンを隠す';
	@override String get showTrayTraffic => 'トレイに通信量情報を表示';
	@override String get website => 'ウェブサイト';
	@override String get rule => 'ルール';
	@override String get global => 'グローバル';
	@override String get direct => '直通';
	@override String get qrcode => 'QRコード';
	@override String get qrcodeTooLong => 'テキストが長すぎて表示できません';
	@override String get qrcodeShare => 'QRコードを共有';
	@override String get qrcodeScan => 'QRコードをスキャン';
	@override String get qrcodeScanResult => 'スキャン結果';
	@override String get backupAndSync => 'バックアップと同期';
	@override String get export => 'エクスポート';
	@override String get send => '送信';
	@override String get sendConfirm => '送信を確認しますか？';
	@override String get log => 'ログ';
	@override String get coreLog => 'コアログ';
	@override String get appLog => 'アプリログ';
	@override String get core => 'コア';
	@override String get help => 'ヘルプ';
	@override String get tutorial => 'チュートリアル';
	@override String get board => 'ボード';
	@override String get boardOnline => 'オンラインボードを使用';
	@override String get boardOnlineUrl => 'オンラインボードURL';
	@override String get boardLocalPort => 'ローカルボードポート';
	@override String get alwayOnVPN => '常時接続';
	@override String get disableFontScaler => 'フォントスケーリングを無効にする（再起動後に有効）';
	@override String get autoOrientation => '画面に合わせて回転';
	@override String get restartTakesEffect => '再起動後に有効';
	@override String get reconnectTakesEffect => '再接続後に有効';
	@override String get runtimeProfile => '実行時プロファイル';
	@override String get willCompleteAfterRebootInstall => 'システム拡張機能のインストールを完了するには、デバイスを再起動してください';
	@override String get requestNeedsUserApproval => '1. [システム設定]-[プライバシーとセキュリティ]でMclashによるシステム拡張機能のインストールを[許可]してください\n2. [システム設定]-[一般]-[ログイン項目と拡張機能]-[ネットワーク拡張機能]で[mclashServiceSE]を有効にしてください\n完了後に再接続してください';
	@override String get FullDiskAccessPermissionRequired => '[システム設定]-[プライバシーとセキュリティ]-[フルディスクアクセス]でmclashServiceSEの権限を有効にし、再接続してください。';
	@override String get proxy => 'プロキシ';
	@override String get theme => 'テーマ';
	@override String get tvMode => 'TVモード';
	@override String get autoUpdate => '自動更新';
	@override String get updateChannel => '自動更新チャンネル';
	@override String hasNewVersion({required Object p}) => 'バージョン ${p} に更新';
	@override String get autoDownloadPkg => '更新パッケージを自動ダウンロード';
	@override String get devOptions => '開発者オプション';
	@override String get about => 'このアプリについて';
	@override String get name => '名前';
	@override String get version => 'バージョン';
	@override String get sort => '並べ替え';
	@override String get share => '共有';
	@override String get importFromClipboard => 'クリップボードからインポート';
	@override String get exportToClipboard => 'クリップボードにエクスポート';
	@override String get server => 'サーバー';
	@override String get port => 'ポート';
	@override String get donate => '寄付';
	@override String get setting => '設定';
	@override String get settingCore => 'コア設定';
	@override String get settingApp => 'アプリ設定';
	@override String get coreOverwrite => 'コア上書き';
	@override String get iCloud => 'iCloud';
	@override String get webdav => 'Webdav';
	@override String get lanSync => 'LAN同期';
	@override String get lanSyncNotQuitTips => '同期が完了するまでこのインターフェースを終了しないでください';
	@override String get deviceNoSpace => 'ディスク容量不足';
	@override String get hideSystemApp => 'システムアプリを隠す';
	@override String get hideAppIcon => 'アプリアイコンを隠す';
	@override String get openDir => 'ファイルディレクトリを開く';
	@override String get type => 'タイプ';
	@override String fileNotExist({required Object p}) => 'ファイルが存在しません: ${p}';
	@override String get buyProfile => 'プロファイルを購入';
	@override String get myProfiles => 'マイプロファイル';
	@override String get profileEdit => 'プロファイルを編集';
	@override String get profileNeedActive => '先にこのプロファイルを現在のプロファイルに設定し、接続/再接続してください';
	@override String profileUrlOrContent({required Object p}) => '${p}設定リンク';
	@override String get tabHome => 'ホーム';
	@override String get tabNodes => 'ノード';
	@override String get tabPlans => 'プラン';
	@override String get tabMe => 'マイ';
}

// Path: permission
class _Translations$permission$ja implements Translations$permission$en {
	_Translations$permission$ja._(this._root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get camera => 'カメラ';
	@override String get screen => '画面録画';
	@override String get appQuery => 'アプリケーションリストを取得';
	@override String request({required Object p}) => '[${p}] 権限をオンにする';
	@override String requestNeed({required Object p}) => '[${p}] 権限をオンにしてください';
}

// Path: tls
class _Translations$tls$ja implements Translations$tls$en {
	_Translations$tls$ja._(this._root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get certificate => '証明書';
	@override String get privateKey => '秘密鍵';
	@override String get customTrustCert => 'カスタム証明書';
}

// Path: tun
class _Translations$tun$ja implements Translations$tun$en {
	_Translations$tun$ja._(this._root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get stack => 'ネットワークスタック';
	@override String get inet4Address => 'IPv4アドレス範囲';
	@override String get dnsHijack => 'DNSハイジャック';
	@override String get strictRoute => '厳格なルート';
	@override String get tunDefaultRoute => 'デフォルトルート';
	@override String get icmpForward => 'ICMP転送';
	@override String get allowBypass => 'アプリがVPNをバイパスすることを許可する';
	@override String get appendHttpProxy => 'VPNにHTTPプロキシを追加する';
	@override String get bypassHttpProxyDomain => 'HTTPプロキシをバイパスすることを許可するドメイン';
}

// Path: dns
class _Translations$dns$ja implements Translations$dns$en {
	_Translations$dns$ja._(this._root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get listen => 'リスニングアドレス';
	@override String get fakeIp => 'fake-ip';
	@override String get fallback => 'フォールバック';
	@override String get preferH3 => 'DoH H3を優先';
	@override String get useHosts => 'Hostsを使用';
	@override String get useSystemHosts => 'システムHostsを使用';
	@override String get enhancedMode => '拡張モード';
	@override String get fakeIPFilterMode => '${_root.dns.fakeIp} フィルターモード';
	@override String get fakeIPFilter => '${_root.dns.fakeIp} フィルター';
	@override String get respectRules => 'ルールを尊重する';
	@override String get nameServer => 'ネームサーバー';
	@override String get defaultNameServer => '${_root.meta.byDefault} ${_root.dns.nameServer}';
	@override String get proxyNameServer => '${_root.meta.proxy} ${_root.dns.nameServer}';
	@override String get directNameServer => '${_root.meta.direct} ${_root.dns.nameServer}';
	@override String get fallbackNameServer => '${_root.dns.fallback} ${_root.dns.nameServer}';
	@override String get fallbackGeoIp => '${_root.dns.fallback} GeoIp';
	@override String get fallbackGeoIpCode => '${_root.dns.fallback} GeoIpCode';
}

// Path: sniffer
class _Translations$sniffer$ja implements Translations$sniffer$en {
	_Translations$sniffer$ja._(this._root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get overrideDest => '上書き';
}

// Path: profilePatchMode
class _Translations$profilePatchMode$ja implements Translations$profilePatchMode$en {
	_Translations$profilePatchMode$ja._(this._root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get currentSelected => '現在選択中';
	@override String get overwrite => '内蔵 - 上書き';
	@override String get noOverwrite => '内蔵 - 上書きなし';
}

// Path: meScreen
class _Translations$meScreen$ja implements Translations$meScreen$en {
	_Translations$meScreen$ja._(this._root);

	final TranslationsJa _root; // ignore: unused_field

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
class _Translations$homeScreen$ja implements Translations$homeScreen$en {
	_Translations$homeScreen$ja._(this._root);

	final TranslationsJa _root; // ignore: unused_field

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
class _Translations$nodesScreen$ja implements Translations$nodesScreen$en {
	_Translations$nodesScreen$ja._(this._root);

	final TranslationsJa _root; // ignore: unused_field

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
class _Translations$nodeAuto$ja implements Translations$nodeAuto$en {
	_Translations$nodeAuto$ja._(this._root);

	final TranslationsJa _root; // ignore: unused_field

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
class _Translations$accountBlock$ja implements Translations$accountBlock$en {
	_Translations$accountBlock$ja._(this._root);

	final TranslationsJa _root; // ignore: unused_field

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
class _Translations$entitlementMsg$ja implements Translations$entitlementMsg$en {
	_Translations$entitlementMsg$ja._(this._root);

	final TranslationsJa _root; // ignore: unused_field

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
class _Translations$devicesScreen$ja implements Translations$devicesScreen$en {
	_Translations$devicesScreen$ja._(this._root);

	final TranslationsJa _root; // ignore: unused_field

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
class _Translations$sysProxySheet$ja implements Translations$sysProxySheet$en {
	_Translations$sysProxySheet$ja._(this._root);

	final TranslationsJa _root; // ignore: unused_field

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
class _Translations$logScreen$ja implements Translations$logScreen$en {
	_Translations$logScreen$ja._(this._root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String readAppFailed({required Object e}) => 'Failed to read the app log: ${e}';
	@override String readCoreFailed({required Object e}) => 'Failed to read the kernel log: ${e}';
	@override String get copied => 'Copied (subscription URLs and other secrets are masked; the log file itself may still contain the raw address)';
	@override String get copy => 'Copy';
	@override String get refresh => 'Refresh';
	@override String get empty => 'No content';
}

// Path: trayShell
class _Translations$trayShell$ja implements Translations$trayShell$en {
	_Translations$trayShell$ja._(this._root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get closeTitle => 'Close window';
	@override String get closeBody => 'Closing the window just puts Mclash in the tray — the kernel and system proxy keep working, and your network stays connected.\n\n· OK: minimize to the tray (to quit completely, right-click the tray icon → Quit)\n· Cancel: quit Mclash completely, stop the kernel and restore the system proxy\n\n(Your choice is remembered; next time you can use the tray icon directly)';
}

// Path: ordersScreen
class _Translations$ordersScreen$ja implements Translations$ordersScreen$en {
	_Translations$ordersScreen$ja._(this._root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get title => 'My Orders';
	@override String get orderInfoIncomplete => 'Order information is incomplete. Pull down to refresh and try again.';
	@override String get payChannelIncomplete => 'Payment channel information is incomplete. Please try again later.';
	@override String get noQrPayload => 'The server did not return a payment QR code or link. Please choose another payment method or try again later.';
	@override String payStartFailed({required Object err}) => 'Failed to start payment: ${err}';
	@override String get noPayMethod => 'No payment method is available right now. Please try again later or contact support.';
	@override String get choosePayMethod => 'Choose a payment method';
	@override String amountDue({required Object amount}) => 'Amount due ¥${amount}';
	@override String get paidLabel => '● Paid';
	@override String get pendingLabel => '○ Unpaid';
	@override String unknownStatus({required Object status}) => '✕ ${status}';
	@override String orderNoText({required Object orderNo}) => 'Order No. ${orderNo}';
	@override String createdAtText({required Object createdAt}) => 'Created at ${createdAt}';
	@override String get orderCanceled => 'Order canceled';
	@override String cancelFailed({required Object err}) => 'Cancel failed: ${err}\n(If the order has already been paid or canceled, pull down to refresh to see the latest status.)';
	@override String get cancelOrder => 'Cancel order';
	@override String get continuePay => 'Continue payment';
}

// Path: payment
class _Translations$payment$ja implements Translations$payment$en {
	_Translations$payment$ja._(this._root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get balancePay => 'Balance payment';
	@override String get qrPay => 'Scan to pay';
	@override String get deductFromBalance => 'Deducted from your account balance';
	@override String get openedInBrowser => 'The payment page has been opened in your browser';
	@override String get scanWithAlipayWechat => 'Scan with Alipay or WeChat';
	@override String orderNoText({required Object orderNo}) => 'Order No. ${orderNo}';
	@override String payFailed({required Object err}) => 'Payment failed: ${err}';
	@override String get notDetected => 'No payment detected. You can continue later in "My Orders".';
	@override String get charging => 'Charging…';
	@override String get processing => 'Processing…';
	@override String get waitingPay => 'Waiting for payment…';
	@override String get openPageFailed => 'Could not open the payment page. Tap the button below to retry, or scan the QR code instead.';
	@override String get reopenPayPage => 'Reopen payment page';
	@override String get payInBrowser => 'Pay in browser';
	@override String get openAlipay => 'Open Alipay';
	@override String get cancelOrder => 'Cancel order';
	@override String get confirmPay => 'Confirm payment';
	@override String get retry => 'Retry';
	@override String get paidAlready => 'I have paid';
	@override String get channelAlipay => 'Alipay';
	@override String get channelCodepayAlipay => 'Code Pay · Alipay';
	@override String get channelCodepayWechat => 'Code Pay · WeChat';
	@override String get channelCodepay => 'Code Pay';
	@override String get channelWechat => 'WeChat Pay';
	@override String get channelUsdt => 'USDT';
	@override String get channelUsdtTrc20 => 'USDT · TRC20';
	@override String get payFallback => 'Payment';
	@override String get errCsrf => 'Your login credential has expired (CSRF check failed).\nPull down to refresh on the "Me" tab or sign in again, then retry.';
	@override String get errAlipayLimit => 'Alipay face-to-face payment has a per-transaction limit (¥1000 for this merchant), and this order exceeds it.\nPlease use "Balance payment" or "Code Pay" instead, or contact support to raise the Alipay limit.';
	@override String get errNotSigned => 'The Alipay app has not signed up for the matching payment product, so this channel is temporarily unavailable.\nPlease use "Balance payment" or "Code Pay" instead, or contact support to enable it.';
	@override String get errOrderGone => 'This order has been canceled or has expired (draft orders are valid for 30 minutes).\nTap "Re-quote" to create a new order, then pay.';
	@override String errNetwork({required Object err}) => 'Network unreachable: ${err}';
}

// Path: planScreen
class _Translations$planScreen$ja implements Translations$planScreen$en {
	_Translations$planScreen$ja._(this._root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get recommended => 'Recommended';
	@override String get devices => 'Devices';
	@override String balanceLabel({required Object amount}) => 'Balance ¥${amount}';
	@override String get balanceInsufficient => ' (Insufficient, please top up first)';
	@override String get total => 'Total';
	@override String get payNow => 'Pay Now';
	@override String get retry => 'Retry';
	@override String get errIncompleteOrder => 'Order or payment channel information is incomplete; payment cannot be started.';
	@override String get payBalance => 'Balance Pay';
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
	@override String get payOnline => 'Online Payment';
}

// Path: authScreen
class _Translations$authScreen$ja implements Translations$authScreen$en {
	_Translations$authScreen$ja._(this._root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get saveAccountInfo => 'Save account info';
	@override String get autoLoginNextTime => 'Sign in automatically next time';
	@override String get needLoginNextTime => 'You\'ll need to sign in again next time';
	@override String get invalidEmail => 'Please enter a valid email address';
	@override String get enterEmailFirst => 'Please enter a valid email address first';
	@override String get passwordRequired => 'Please enter your password';
	@override String get wrongCredentials => 'Incorrect email or password';
	@override String get requestRejected => 'Request rejected. Please try again later.';
	@override String get tooFrequent => 'Too many attempts. Please try again later.';
	@override String get loginFailed => 'Login failed';
	@override String get username => 'Username';
	@override String get confirmPassword => 'Confirm password';
	@override String get inviteCode => 'Invite code';
	@override String get emailCode => 'Email verification code';
	@override String get getCode => 'Get code';
	@override String get registerAndLogin => 'Register and log in';
	@override String usernameMinLength({required Object min}) => 'Username must be at least ${min} characters';
	@override String get passwordMismatch => 'The passwords do not match';
	@override String get emailCodeRequired => 'Please enter the email verification code';
	@override String get inviteCodeRequired => 'Registration on this site requires an invite code';
	@override String get codeSentCheckEmail => 'Verification code sent. Please check your email.';
	@override String get registerSuccess => 'Registration successful. You are now logged in.';
	@override String passwordHint({required Object min}) => 'At least ${min} characters, including both letters and digits';
	@override String passwordTooShort({required Object min}) => 'Password must be at least ${min} characters';
	@override String get passwordNeedsLetterAndDigit => 'Password must contain both letters and digits';
	@override String get registeredEmail => 'Registered email';
	@override String get newPassword => 'New password';
	@override String get confirmNewPassword => 'Confirm new password';
	@override String get resetPassword => 'Reset password';
	@override String get resetCodeSent => 'If this email is registered, a reset code has been sent (valid for 15 minutes).';
	@override String get resetSuccess => 'Password reset. Please log in with your new password.';
	@override String get changePasswordTitle => 'Change password';
	@override String get currentPassword => 'Current password';
	@override String get saveNewPassword => 'Save new password';
	@override String get newPasswordMismatch => 'The new passwords do not match';
	@override String get changePasswordSuccess => 'Password changed. Please log in again.';
}

// Path: updatePrompt
class _Translations$updatePrompt$ja implements Translations$updatePrompt$en {
	_Translations$updatePrompt$ja._(this._root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get checking => 'Checking for updates…';
	@override String get checkFailed => 'Update check failed. Please check your network and try again.';
	@override String alreadyLatest({required Object version}) => 'You\'re on the latest version (${version}).';
	@override String newVersionFound({required Object version}) => 'New version ${version} is available';
	@override String get installerDownloaded => 'The installer has finished downloading in the background. Tap Update Now to complete the upgrade.';
	@override String get downloadInBackground => 'Tap Update Now to download and install it (you can keep using the app; the installer downloads in the background).';
	@override String get later => 'Later';
	@override String get updateNow => 'Update Now';
	@override String installerNotReady({required Object version}) => 'The installer has not finished downloading yet.\n\nTap OK to open the download page and manually download the installer that matches your device (version ${version}).';
}

// Path: clearData
class _Translations$clearData$ja implements Translations$clearData$en {
	_Translations$clearData$ja._(this._root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get itemLoginSession => 'Login session';
	@override String get itemProfiles => 'Subscription profiles (profiles/)';
	@override String get itemSettings => 'App and core settings';
	@override String get itemLatencyCache => 'Node latency cache';
	@override String get itemLogs => 'Runtime logs';
	@override String get itemRoutingData => 'Routing data and temporary files';
	@override String confirmBody({required Object items, required Object dir}) => 'The following data saved on this device will be deleted (this cannot be undone):\n\n${items}\n\nThe account itself and any plan you purchased live on the server and are not affected; sign in again to restore your subscription.\n\nData directory: ${dir}\n(Do this before uninstalling the app: only then will reinstalling start clean and ask you to sign in again)';
	@override String get confirmAgain => 'Clear now? You will need to sign in again afterwards.';
	@override String clearedNotice({required Object count, required Object dir}) => 'Cleared ${count} local data items (including the login session, so you will need to sign in again next time you open the app).\n\nYou can now delete the app to finish uninstalling:\n· macOS: drag Mclash.app to the Trash (the data directory has been emptied: ${dir})\n· Windows: uninstall Mclash from Control Panel and choose No when the wizard asks whether to keep your user data';
	@override String clearFailed({required Object error}) => 'Clear failed: ${error}';
}

// Path: apiError
class _Translations$apiError$ja implements Translations$apiError$en {
	_Translations$apiError$ja._(this._root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String requestFailedHttp({required Object status, required Object domain}) => 'Request failed (HTTP ${status}); already tried ${domain}';
	@override String allDomainsFailed({required Object method, required Object path, required Object count}) => 'Request failed: ${method} ${path} (tried ${count} domains)';
	@override String requestTimeout({required Object seconds, required Object method, required Object path}) => 'Request timed out (${seconds}s): ${method} ${path}';
	@override String networkUnreachable({required Object detail}) => 'Network unreachable: ${detail}';
	@override String get tlsHandshakeFailed => 'TLS handshake failed. Check your network connection or system time.';
	@override String connectionFailed({required Object detail}) => 'Connection failed: ${detail}';
	@override String requestError({required Object error}) => 'Request failed: ${error}';
	@override String responseReadTimeout({required Object seconds, required Object method, required Object path}) => 'Reading the response timed out (${seconds}s): ${method} ${path}';
	@override String notJson({required Object status, required Object snippet}) => 'Response is not JSON (HTTP ${status}): ${snippet}';
	@override String badStructure({required Object status}) => 'Unexpected response structure (HTTP ${status})';
	@override String loginFailed({required Object code}) => 'Login failed (code ${code})';
	@override String get loginMissingData => 'Login response is missing data';
	@override String get loginMissingToken => 'Login response is missing access_token';
	@override String registerFailed({required Object code}) => 'Registration failed (code ${code})';
	@override String get registerMissingToken => 'Registration response has no access_token - risk control may have been triggered, or the site is configured differently';
	@override String requestFailedCode({required Object code}) => 'Request failed (code ${code})';
}

// Path: subNotice
class _Translations$subNotice$ja implements Translations$subNotice$en {
	_Translations$subNotice$ja._(this._root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get titleNotFound => 'Subscription not found';
	@override String get titleExpired => 'Subscription expired';
	@override String get titleInactive => 'Subscription inactive';
	@override String get titleDeviceOverLimit => 'Device limit exceeded';
	@override String get titleUnavailable => 'Subscription unavailable';
	@override String titleWithReason({required Object emoji, required Object title, required Object reason}) => '${emoji} ${title} (${reason})';
	@override String deviceUsedOfLimit({required Object used, required Object limit}) => 'Current devices ${used}/${limit}';
	@override String deviceUsedOnly({required Object used}) => 'Current devices ${used}';
	@override String expireAt({required Object expire}) => 'Expires at ${expire}';
	@override String supportLine({required Object account}) => '💬 Support: ${account}';
	@override String siteLine({required Object url}) => '📢 Website: ${url}';
}

// Path: settingItems
class _Translations$settingItems$ja implements Translations$settingItems$en {
	_Translations$settingItems$ja._(this._root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get subscriptionAutoUpdateInterval => 'Subscription auto-update interval';
	@override String get speedTestMode => 'Speed test method';
	@override String get speedTestModeTcp => 'TCP speed test';
	@override String get speedTestModeKernel => 'Kernel speed test';
	@override String get delayTestUrlTip => 'Time for one full HTTP request through this node (it is not a ping)\nDefaults to a plain http 204 empty response; using https adds a TLS handshake and a larger number';
	@override String get systemProxy => 'System proxy';
	@override String get systemProxyTip => 'View / reset address and port';
	@override String get tunMode => 'TUN mode';
	@override String get tunModeTip => 'off=system proxy only / auto=TUN+system proxy / force=TUN only\nOn desktop, TUN requires administrator privileges (wintun on Windows / utun on macOS)';
	@override String get tunOverwriteTip => 'overwrite\nOn = the TUN settings on this page override the tun section of the profile\nOff = the profile\'s own tun configuration is used (the app does not interfere)';
	@override String tunEnableByTunMode({required Object enable}) => '${enable} (decided by TUN mode)';
	@override String get interval30Minutes => '30 minutes';
	@override String get interval1Hour => '1 hour';
	@override String get interval6Hours => '6 hours';
	@override String get interval12Hours => '12 hours';
	@override String get interval24Hours => '24 hours';
	@override String get interval3Days => '3 days';
	@override String get interval7Days => '7 days';
	@override String get intervalNever => 'Never';
	@override String intervalMinutes({required Object minutes}) => '${minutes} minutes';
	@override String intervalHours({required Object hours}) => '${hours} hours';
	@override String intervalDays({required Object days}) => '${days} days';
}

// Path: tunScreen
class _Translations$tunScreen$ja implements Translations$tunScreen$en {
	_Translations$tunScreen$ja._(this._root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get modeOff => 'Off';
	@override String get modeAuto => 'Auto';
	@override String get modeForce => 'Force';
	@override String get modeOffDesc => 'System proxy only: works for programs that honor the system proxy (browsers and so on); UDP/games are not proxied';
	@override String get modeAutoDesc => 'TUN + system proxy (belt and braces): all traffic goes through the virtual adapter, including UDP';
	@override String get modeForceDesc => 'TUN only: all traffic goes through the virtual adapter, the system proxy is left untouched';
	@override String get modeOffOptionDesc => 'Does not touch the system routing table; only sets a 127.0.0.1 proxy in the system. Only programs that honor the system proxy use it; UDP traffic and programs with their own proxy settings do not.';
	@override String get modeAutoOptionDesc => 'Creates a virtual adapter and takes over all traffic (including UDP and games); the system proxy is kept as a fallback. Recommended: it works globally and you are not left without network access if permissions are missing.';
	@override String get modeForceOptionDesc => 'Uses only the virtual adapter and no longer changes the system proxy. All traffic (including UDP) goes through the tunnel; the "proxy" entry in the system stays as it is.';
	@override String get adminRequiredDialog => 'The TUN virtual adapter requires administrator privileges (wintun on Windows / utun on macOS).\n\nMclash is not running as administrator right now, so TUN will not take effect after enabling it (in "Auto" mode the system proxy still works as a fallback, so the network stays usable).\n\nOK = restart Mclash as administrator now (a UAC prompt will appear)\nCancel = still save this choice (the system proxy is used automatically when TUN is unavailable)';
	@override String relaunchFailed({required Object message}) => 'Restart failed: ${message}';
	@override String switchFailed({required Object message}) => 'Failed to switch TUN mode: ${message}\nThe previous settings have been restored.';
	@override String get setOffSnack => 'Set to "Off": system proxy only';
	@override String setModeSnack({required Object mode, required Object effect}) => 'Set to "${mode}", ${effect}';
	@override String get effectReconnected => 'reconnected and now active';
	@override String get effectAfterConnect => 'active after connecting';
	@override String get sheetTitle => 'TUN Virtual Adapter';
	@override String get advancedTitle => 'Advanced parameters (Core Settings → TUN)';
	@override String get advancedSubtitle => 'Adapter address / stack / MTU / auto route / DNS hijack / overwrite';
	@override String get adminOk => 'TUN requires administrator privileges; the current privileges are sufficient (run as administrator on Windows / as root on macOS)';
	@override String get adminMissing => 'TUN requires administrator privileges: Mclash is not running as administrator, so TUN will not take effect after selecting "Auto/Force" ("Auto" falls back to the system proxy, so the network stays usable)';
}

// Path: main.tray
class _Translations$main$tray$ja implements Translations$main$tray$en {
	_Translations$main$tray$ja._(this._root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get menuOpen => '開く';
	@override String get menuExit => '終了';
}

/// The flat map containing all translations for locale <ja>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on TranslationsJa {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'BackupAndSyncWebdavScreen.webdavServerUrl' => 'サーバーURL',
			'BackupAndSyncWebdavScreen.webdavRequired' => '空にすることはできません',
			'BackupAndSyncWebdavScreen.webdavLoginFailed' => 'ログインに失敗しました:',
			'BackupAndSyncWebdavScreen.webdavListFailed' => 'ファイルリストの取得に失敗しました:',
			'LaunchFailedScreen.invalidProcess' => 'アプリの起動に失敗しました [無効なプロセス名]。アプリを別のディレクトリに再インストールしてください',
			'LaunchFailedScreen.invalidProfile' => 'アプリの起動に失敗しました [プロファイルへのアクセスに失敗]。アプリを再インストールしてください',
			'LaunchFailedScreen.invalidVersion' => 'アプリの起動に失敗しました [無効なバージョン]。アプリを再インストールしてください',
			'LaunchFailedScreen.systemVersionLow' => 'アプリの起動に失敗しました [システムバージョンが低すぎます]',
			'LaunchFailedScreen.invalidInstallPath' => 'インストールパスが無効です。有効なパスに再インストールしてください',
			'PerAppAndroidScreen.title' => 'アプリごとのプロキシ',
			'PerAppAndroidScreen.whiteListMode' => 'ホワイトリストモード',
			'PerAppAndroidScreen.whiteListModeTip' => '有効な場合：チェックされたアプリのみがプロキシされます。無効な場合：チェックされていないアプリのみがプロキシされます',
			'UserAgreementScreen.privacyFirst' => 'プライバシーを第一に',
			'UserAgreementScreen.agreeAndContinue' => '同意して続行',
			'NetCheckScreen.enterDomain' => 'ドメイン名を入力してください',
			'NetCheckScreen.checking' => '確認中...',
			'NetCheckScreen.aQueryFailed' => ({required Object p}) => 'Aレコード照会失敗: ${p}',
			'NetCheckScreen.aaaaQueryFailed' => ({required Object p}) => 'AAAAレコード照会失敗: ${p}',
			'NetCheckScreen.success' => '成功',
			'NetCheckScreen.failed' => '失敗',
			'NetCheckScreen.suspectedPollution' => 'DNS汚染の疑い',
			'NetCheckScreen.domainLabel' => 'ドメイン',
			'NetCheckScreen.checkButton' => '診断',
			'NetCheckScreen.dnsSection' => '1. DNS照会',
			'NetCheckScreen.directHttpSection' => '2. HTTP (TUN経由、先にTUNを有効にしてください)',
			'NetCheckScreen.proxyHttpSection' => ({required Object p}) => '3. HTTP (プロキシ経由、ポート: ${p})',
			'NetCheckScreen.tunNotEnabled' => 'TUN が有効になっていません',
			'NetCheckScreen.routeTableSection' => '4. ルートテーブル',
			'VersionUpdateScreen.versionReady' => ({required Object p}) => '新しいバージョン [${p}] の準備ができました',
			'VersionUpdateScreen.update' => '再起動して更新',
			'VersionUpdateScreen.cancel' => '今はしない',
			'loginScreen.login' => 'ログイン',
			'loginScreen.register' => 'アカウント登録',
			'loginScreen.forgotPassword' => 'パスワードを忘れた',
			'loginScreen.provider' => 'プロバイダー',
			'loginScreen.providerName' => '${_root.loginScreen.provider}コード/別名/URL',
			'loginScreen.account' => 'アカウント',
			'loginScreen.email' => 'メール',
			'loginScreen.password' => 'パスワード',
			'main.tray.menuOpen' => '開く',
			'main.tray.menuExit' => '終了',
			'meta.enable' => '有効',
			'meta.disable' => '無効',
			'meta.open' => '開く',
			'meta.close' => '閉じる',
			'meta.quit' => '終了',
			'meta.add' => '追加',
			'meta.remove' => '削除',
			'meta.removeConfirm' => '本当に削除しますか？',
			'meta.edit' => '編集',
			'meta.view' => '表示',
			'meta.remark' => '備考',
			'meta.byDefault' => 'デフォルト',
			'meta.more' => '詳細',
			'meta.tips' => '情報',
			'meta.selectAll' => 'すべて選択',
			'meta.copy' => 'コピー',
			'meta.paste' => '貼り付け',
			'meta.cut' => '切り取り',
			'meta.save' => '保存',
			'meta.ok' => 'OK',
			'meta.cancel' => 'キャンセル',
			'meta.faq' => 'よくある質問',
			'meta.doc' => 'ドキュメント',
			'meta.htmlTools' => 'HTMLツールセット',
			'meta.download' => 'ダウンロード',
			'meta.loading' => '読み込み中...',
			'meta.days' => '日',
			'meta.hours' => '時間',
			'meta.minutes' => '分',
			'meta.seconds' => '秒',
			'meta.milliseconds' => 'ミリ秒',
			'meta.search' => '検索',
			'meta.searchNodeHint' => 'ノードを絞り込む（名前またはプロトコル）',
			'meta.connect' => '接続',
			'meta.disconnect' => '切断',
			'meta.connected' => '接続済み',
			'meta.disconnected' => '切断済み',
			'meta.connecting' => '接続中',
			'meta.connectTimeout' => '接続タイムアウト',
			'meta.timeout' => 'タイムアウト',
			'meta.latencyTest' => '遅延チェック',
			'meta.networkCheck' => 'ネットワーク診断',
			'meta.language' => '言語',
			'meta.next' => '次へ',
			'meta.done' => '完了',
			'meta.apply' => '適用',
			'meta.refresh' => '更新',
			'meta.update' => '更新',
			'meta.updateInterval' => '更新間隔',
			'meta.updateFailed' => ({required Object p}) => '更新に失敗しました: ${p}',
			'meta.updateInterval5mTips' => '最小: 5分',
			'meta.updateIntervalPreferByProfile' => 'プロバイダーの設定を優先',
			'meta.none' => 'なし',
			'meta.reset' => 'リセット',
			'meta.authentication' => '認証',
			'meta.user' => 'ユーザー',
			'meta.account' => 'アカウント',
			'meta.password' => 'パスワード',
			'meta.decryptPassword' => '複号化パスワード',
			'meta.required' => '必須',
			'meta.go' => '続行',
			'meta.other' => 'その他',
			'meta.dns' => 'DNS',
			'meta.url' => 'URL',
			'meta.urlInvalid' => '無効なURL',
			'meta.copyUrl' => 'リンクをコピー',
			'meta.openUrl' => 'リンクを開く',
			'meta.coreSettingTips' => '注意：設定を変更した後、有効にするには再接続する必要があります',
			'meta.overwrite' => '上書き',
			'meta.overwriteAppend' => '追加上書き',
			'meta.overwriteTips' => 'オリジナルプロファイル <- カスタム上書き <- アプリ上書き',
			'meta.noOverwrite' => '上書きしない',
			'meta.diversionTemplates' => '転送テンプレート',
			'meta.ruleProviders' => 'ルールプロバイダー',
			'meta.ruleTemplates' => 'ルールテンプレート',
			'meta.proxyGroupsTemplates' => 'プロキシグループテンプレート',
			'meta.proxyGroups' => 'プロキシグループ',
			'meta.proxyNodeList' => 'プロキシノードリスト',
			'meta.proxyNodeFailure' => ({required Object p}) => '以下のプロキシノードは期限切れのため自動的に削除されました: ${p}',
			'meta.externalController' => '外部コントローラー',
			'meta.secret' => 'シークレット',
			'meta.tcpConcurrent' => 'TCP並行ハンドシェイク',
			'meta.globalClientFingerprint' => 'TLSグローバルフィンガープリント',
			'meta.allowLanAccess' => 'LANデバイスアクセス',
			'meta.mixedPort' => '混合プロキシポート',
			'meta.logLevel' => 'ログレベル',
			'meta.findProcessMode' => 'プロセスマッチングモード',
			'meta.tcpkeepAliveInterval' => 'TCPキープアライブ間隔',
			'meta.delayTestUrl' => '遅延テストURL',
			'meta.delayTestTimeout' => '遅延テストタイムアウト(ms)',
			'meta.tun' => 'TUN',
			'meta.ntp' => 'NTP',
			'meta.tls' => 'TLS',
			'meta.geoDownloadByProxy' => 'プロキシ経由でGeo RuleSetをダウンロード',
			'meta.geoRulesetTips' => 'Geosite/Geoipは対応するRuleSetに変換されます',
			'meta.sniffer' => 'スニッファー',
			'meta.userAgent' => 'UserAgent',
			'meta.launchAtStartup' => 'スタートアップ時に起動',
			'meta.launchAtStartupRunAsAdmin' => 'Mclashを管理者として再起動してください',
			'meta.tunModeRunAsAdmin' => 'TUNモードにはシステム管理者権限が必要です。アプリを管理者として再起動してください',
			'meta.portableMode' => 'ポータブルモード',
			'meta.portableModeDisableTips' => 'ポータブルモードを終了する必要がある場合は、[mclash]を終了し、[mclash.exe]と同じディレクトリにある[portable]フォルダを手動で削除してください',
			'meta.autoConnectAfterLaunch' => '起動後に自動接続',
			'meta.autoConnectAtBoot' => 'システム起動後に自動接続',
			'meta.autoConnectAtBootTips' => 'システムのサポートが必要です。一部のシステムでは[自動起動]を有効にする必要がある場合があります。',
			'meta.hideAfterLaunch' => '起動後にウィンドウを隠す',
			'meta.autoSetSystemProxy' => '接続時にシステムプロキシを自動設定',
			'meta.bypassSystemProxy' => 'システムプロキシをバイパスすることを許可するドメイン名',
			'meta.excludeFromRecent' => '[最近のタスク]から隠す',
			'meta.wakeLock' => 'スリープ防止',
			'meta.hideDockIcon' => 'Dockアイコンを隠す',
			'meta.showTrayTraffic' => 'トレイに通信量情報を表示',
			'meta.website' => 'ウェブサイト',
			'meta.rule' => 'ルール',
			'meta.global' => 'グローバル',
			'meta.direct' => '直通',
			'meta.qrcode' => 'QRコード',
			'meta.qrcodeTooLong' => 'テキストが長すぎて表示できません',
			'meta.qrcodeShare' => 'QRコードを共有',
			'meta.qrcodeScan' => 'QRコードをスキャン',
			'meta.qrcodeScanResult' => 'スキャン結果',
			'meta.backupAndSync' => 'バックアップと同期',
			'meta.export' => 'エクスポート',
			'meta.send' => '送信',
			'meta.sendConfirm' => '送信を確認しますか？',
			'meta.log' => 'ログ',
			'meta.coreLog' => 'コアログ',
			'meta.appLog' => 'アプリログ',
			'meta.core' => 'コア',
			'meta.help' => 'ヘルプ',
			'meta.tutorial' => 'チュートリアル',
			'meta.board' => 'ボード',
			'meta.boardOnline' => 'オンラインボードを使用',
			'meta.boardOnlineUrl' => 'オンラインボードURL',
			'meta.boardLocalPort' => 'ローカルボードポート',
			'meta.alwayOnVPN' => '常時接続',
			'meta.disableFontScaler' => 'フォントスケーリングを無効にする（再起動後に有効）',
			'meta.autoOrientation' => '画面に合わせて回転',
			'meta.restartTakesEffect' => '再起動後に有効',
			'meta.reconnectTakesEffect' => '再接続後に有効',
			'meta.runtimeProfile' => '実行時プロファイル',
			'meta.willCompleteAfterRebootInstall' => 'システム拡張機能のインストールを完了するには、デバイスを再起動してください',
			'meta.requestNeedsUserApproval' => '1. [システム設定]-[プライバシーとセキュリティ]でMclashによるシステム拡張機能のインストールを[許可]してください\n2. [システム設定]-[一般]-[ログイン項目と拡張機能]-[ネットワーク拡張機能]で[mclashServiceSE]を有効にしてください\n完了後に再接続してください',
			'meta.FullDiskAccessPermissionRequired' => '[システム設定]-[プライバシーとセキュリティ]-[フルディスクアクセス]でmclashServiceSEの権限を有効にし、再接続してください。',
			'meta.proxy' => 'プロキシ',
			'meta.theme' => 'テーマ',
			'meta.tvMode' => 'TVモード',
			'meta.autoUpdate' => '自動更新',
			'meta.updateChannel' => '自動更新チャンネル',
			'meta.hasNewVersion' => ({required Object p}) => 'バージョン ${p} に更新',
			'meta.autoDownloadPkg' => '更新パッケージを自動ダウンロード',
			'meta.devOptions' => '開発者オプション',
			'meta.about' => 'このアプリについて',
			'meta.name' => '名前',
			'meta.version' => 'バージョン',
			'meta.sort' => '並べ替え',
			'meta.share' => '共有',
			'meta.importFromClipboard' => 'クリップボードからインポート',
			'meta.exportToClipboard' => 'クリップボードにエクスポート',
			'meta.server' => 'サーバー',
			'meta.port' => 'ポート',
			'meta.donate' => '寄付',
			'meta.setting' => '設定',
			'meta.settingCore' => 'コア設定',
			'meta.settingApp' => 'アプリ設定',
			'meta.coreOverwrite' => 'コア上書き',
			'meta.iCloud' => 'iCloud',
			'meta.webdav' => 'Webdav',
			'meta.lanSync' => 'LAN同期',
			'meta.lanSyncNotQuitTips' => '同期が完了するまでこのインターフェースを終了しないでください',
			'meta.deviceNoSpace' => 'ディスク容量不足',
			'meta.hideSystemApp' => 'システムアプリを隠す',
			'meta.hideAppIcon' => 'アプリアイコンを隠す',
			'meta.openDir' => 'ファイルディレクトリを開く',
			'meta.type' => 'タイプ',
			'meta.fileNotExist' => ({required Object p}) => 'ファイルが存在しません: ${p}',
			'meta.buyProfile' => 'プロファイルを購入',
			'meta.myProfiles' => 'マイプロファイル',
			'meta.profileEdit' => 'プロファイルを編集',
			'meta.profileNeedActive' => '先にこのプロファイルを現在のプロファイルに設定し、接続/再接続してください',
			'meta.profileUrlOrContent' => ({required Object p}) => '${p}設定リンク',
			'meta.tabHome' => 'ホーム',
			'meta.tabNodes' => 'ノード',
			'meta.tabPlans' => 'プラン',
			'meta.tabMe' => 'マイ',
			'permission.camera' => 'カメラ',
			'permission.screen' => '画面録画',
			'permission.appQuery' => 'アプリケーションリストを取得',
			'permission.request' => ({required Object p}) => '[${p}] 権限をオンにする',
			'permission.requestNeed' => ({required Object p}) => '[${p}] 権限をオンにしてください',
			'tls.certificate' => '証明書',
			'tls.privateKey' => '秘密鍵',
			'tls.customTrustCert' => 'カスタム証明書',
			'tun.stack' => 'ネットワークスタック',
			'tun.inet4Address' => 'IPv4アドレス範囲',
			'tun.dnsHijack' => 'DNSハイジャック',
			'tun.strictRoute' => '厳格なルート',
			'tun.tunDefaultRoute' => 'デフォルトルート',
			'tun.icmpForward' => 'ICMP転送',
			'tun.allowBypass' => 'アプリがVPNをバイパスすることを許可する',
			'tun.appendHttpProxy' => 'VPNにHTTPプロキシを追加する',
			'tun.bypassHttpProxyDomain' => 'HTTPプロキシをバイパスすることを許可するドメイン',
			'dns.listen' => 'リスニングアドレス',
			'dns.fakeIp' => 'fake-ip',
			'dns.fallback' => 'フォールバック',
			'dns.preferH3' => 'DoH H3を優先',
			'dns.useHosts' => 'Hostsを使用',
			'dns.useSystemHosts' => 'システムHostsを使用',
			'dns.enhancedMode' => '拡張モード',
			'dns.fakeIPFilterMode' => '${_root.dns.fakeIp} フィルターモード',
			'dns.fakeIPFilter' => '${_root.dns.fakeIp} フィルター',
			'dns.respectRules' => 'ルールを尊重する',
			'dns.nameServer' => 'ネームサーバー',
			'dns.defaultNameServer' => '${_root.meta.byDefault} ${_root.dns.nameServer}',
			'dns.proxyNameServer' => '${_root.meta.proxy} ${_root.dns.nameServer}',
			'dns.directNameServer' => '${_root.meta.direct} ${_root.dns.nameServer}',
			'dns.fallbackNameServer' => '${_root.dns.fallback} ${_root.dns.nameServer}',
			'dns.fallbackGeoIp' => '${_root.dns.fallback} GeoIp',
			'dns.fallbackGeoIpCode' => '${_root.dns.fallback} GeoIpCode',
			'sniffer.overrideDest' => '上書き',
			'profilePatchMode.currentSelected' => '現在選択中',
			'profilePatchMode.overwrite' => '内蔵 - 上書き',
			'profilePatchMode.noOverwrite' => '内蔵 - 上書きなし',
			'sendOrReceiveNotMatch' => ({required Object p}) => '[${p}] を使用してください',
			'targetConnectFailed' => ({required Object p}) => '[${p}] への接続に失敗しました。デバイスが同じ LAN 内にあることを確認してください',
			'edgeRuntimeNotInstalled' => '現在のデバイスには Edge WebView2 ランタイムがインストールされていないため、ページを表示できません。Edge WebView2 ランタイム (x64) をダウンロードしてインストールし、アプリを再起動してからもう一度お試しください。',
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
			'ordersScreen.title' => 'My Orders',
			'ordersScreen.orderInfoIncomplete' => 'Order information is incomplete. Pull down to refresh and try again.',
			'ordersScreen.payChannelIncomplete' => 'Payment channel information is incomplete. Please try again later.',
			'ordersScreen.noQrPayload' => 'The server did not return a payment QR code or link. Please choose another payment method or try again later.',
			'ordersScreen.payStartFailed' => ({required Object err}) => 'Failed to start payment: ${err}',
			'ordersScreen.noPayMethod' => 'No payment method is available right now. Please try again later or contact support.',
			'ordersScreen.choosePayMethod' => 'Choose a payment method',
			'ordersScreen.amountDue' => ({required Object amount}) => 'Amount due ¥${amount}',
			'ordersScreen.paidLabel' => '● Paid',
			'ordersScreen.pendingLabel' => '○ Unpaid',
			'ordersScreen.unknownStatus' => ({required Object status}) => '✕ ${status}',
			'ordersScreen.orderNoText' => ({required Object orderNo}) => 'Order No. ${orderNo}',
			'ordersScreen.createdAtText' => ({required Object createdAt}) => 'Created at ${createdAt}',
			'ordersScreen.orderCanceled' => 'Order canceled',
			'ordersScreen.cancelFailed' => ({required Object err}) => 'Cancel failed: ${err}\n(If the order has already been paid or canceled, pull down to refresh to see the latest status.)',
			'ordersScreen.cancelOrder' => 'Cancel order',
			'ordersScreen.continuePay' => 'Continue payment',
			'payment.balancePay' => 'Balance payment',
			'payment.qrPay' => 'Scan to pay',
			'payment.deductFromBalance' => 'Deducted from your account balance',
			'payment.openedInBrowser' => 'The payment page has been opened in your browser',
			'payment.scanWithAlipayWechat' => 'Scan with Alipay or WeChat',
			'payment.orderNoText' => ({required Object orderNo}) => 'Order No. ${orderNo}',
			'payment.payFailed' => ({required Object err}) => 'Payment failed: ${err}',
			'payment.notDetected' => 'No payment detected. You can continue later in "My Orders".',
			'payment.charging' => 'Charging…',
			'payment.processing' => 'Processing…',
			'payment.waitingPay' => 'Waiting for payment…',
			'payment.openPageFailed' => 'Could not open the payment page. Tap the button below to retry, or scan the QR code instead.',
			'payment.reopenPayPage' => 'Reopen payment page',
			'payment.payInBrowser' => 'Pay in browser',
			'payment.openAlipay' => 'Open Alipay',
			'payment.cancelOrder' => 'Cancel order',
			'payment.confirmPay' => 'Confirm payment',
			'payment.retry' => 'Retry',
			'payment.paidAlready' => 'I have paid',
			'payment.channelAlipay' => 'Alipay',
			'payment.channelCodepayAlipay' => 'Code Pay · Alipay',
			'payment.channelCodepayWechat' => 'Code Pay · WeChat',
			'payment.channelCodepay' => 'Code Pay',
			'payment.channelWechat' => 'WeChat Pay',
			'payment.channelUsdt' => 'USDT',
			'payment.channelUsdtTrc20' => 'USDT · TRC20',
			'payment.payFallback' => 'Payment',
			'payment.errCsrf' => 'Your login credential has expired (CSRF check failed).\nPull down to refresh on the "Me" tab or sign in again, then retry.',
			'payment.errAlipayLimit' => 'Alipay face-to-face payment has a per-transaction limit (¥1000 for this merchant), and this order exceeds it.\nPlease use "Balance payment" or "Code Pay" instead, or contact support to raise the Alipay limit.',
			'payment.errNotSigned' => 'The Alipay app has not signed up for the matching payment product, so this channel is temporarily unavailable.\nPlease use "Balance payment" or "Code Pay" instead, or contact support to enable it.',
			'payment.errOrderGone' => 'This order has been canceled or has expired (draft orders are valid for 30 minutes).\nTap "Re-quote" to create a new order, then pay.',
			'payment.errNetwork' => ({required Object err}) => 'Network unreachable: ${err}',
			'planScreen.recommended' => 'Recommended',
			'planScreen.devices' => 'Devices',
			'planScreen.balanceLabel' => ({required Object amount}) => 'Balance ¥${amount}',
			'planScreen.balanceInsufficient' => ' (Insufficient, please top up first)',
			'planScreen.total' => 'Total',
			'planScreen.payNow' => 'Pay Now',
			'planScreen.retry' => 'Retry',
			'planScreen.errIncompleteOrder' => 'Order or payment channel information is incomplete; payment cannot be started.',
			'planScreen.payBalance' => 'Balance Pay',
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
			'planScreen.payOnline' => 'Online Payment',
			'authScreen.saveAccountInfo' => 'Save account info',
			'authScreen.autoLoginNextTime' => 'Sign in automatically next time',
			'authScreen.needLoginNextTime' => 'You\'ll need to sign in again next time',
			'authScreen.invalidEmail' => 'Please enter a valid email address',
			'authScreen.enterEmailFirst' => 'Please enter a valid email address first',
			'authScreen.passwordRequired' => 'Please enter your password',
			'authScreen.wrongCredentials' => 'Incorrect email or password',
			'authScreen.requestRejected' => 'Request rejected. Please try again later.',
			'authScreen.tooFrequent' => 'Too many attempts. Please try again later.',
			'authScreen.loginFailed' => 'Login failed',
			'authScreen.username' => 'Username',
			'authScreen.confirmPassword' => 'Confirm password',
			'authScreen.inviteCode' => 'Invite code',
			'authScreen.emailCode' => 'Email verification code',
			'authScreen.getCode' => 'Get code',
			'authScreen.registerAndLogin' => 'Register and log in',
			'authScreen.usernameMinLength' => ({required Object min}) => 'Username must be at least ${min} characters',
			'authScreen.passwordMismatch' => 'The passwords do not match',
			'authScreen.emailCodeRequired' => 'Please enter the email verification code',
			'authScreen.inviteCodeRequired' => 'Registration on this site requires an invite code',
			'authScreen.codeSentCheckEmail' => 'Verification code sent. Please check your email.',
			'authScreen.registerSuccess' => 'Registration successful. You are now logged in.',
			'authScreen.passwordHint' => ({required Object min}) => 'At least ${min} characters, including both letters and digits',
			'authScreen.passwordTooShort' => ({required Object min}) => 'Password must be at least ${min} characters',
			'authScreen.passwordNeedsLetterAndDigit' => 'Password must contain both letters and digits',
			'authScreen.registeredEmail' => 'Registered email',
			'authScreen.newPassword' => 'New password',
			'authScreen.confirmNewPassword' => 'Confirm new password',
			'authScreen.resetPassword' => 'Reset password',
			'authScreen.resetCodeSent' => 'If this email is registered, a reset code has been sent (valid for 15 minutes).',
			'authScreen.resetSuccess' => 'Password reset. Please log in with your new password.',
			'authScreen.changePasswordTitle' => 'Change password',
			'authScreen.currentPassword' => 'Current password',
			'authScreen.saveNewPassword' => 'Save new password',
			'authScreen.newPasswordMismatch' => 'The new passwords do not match',
			'authScreen.changePasswordSuccess' => 'Password changed. Please log in again.',
			'updatePrompt.checking' => 'Checking for updates…',
			'updatePrompt.checkFailed' => 'Update check failed. Please check your network and try again.',
			'updatePrompt.alreadyLatest' => ({required Object version}) => 'You\'re on the latest version (${version}).',
			'updatePrompt.newVersionFound' => ({required Object version}) => 'New version ${version} is available',
			'updatePrompt.installerDownloaded' => 'The installer has finished downloading in the background. Tap Update Now to complete the upgrade.',
			'updatePrompt.downloadInBackground' => 'Tap Update Now to download and install it (you can keep using the app; the installer downloads in the background).',
			'updatePrompt.later' => 'Later',
			'updatePrompt.updateNow' => 'Update Now',
			'updatePrompt.installerNotReady' => ({required Object version}) => 'The installer has not finished downloading yet.\n\nTap OK to open the download page and manually download the installer that matches your device (version ${version}).',
			'clearData.itemLoginSession' => 'Login session',
			'clearData.itemProfiles' => 'Subscription profiles (profiles/)',
			'clearData.itemSettings' => 'App and core settings',
			'clearData.itemLatencyCache' => 'Node latency cache',
			'clearData.itemLogs' => 'Runtime logs',
			'clearData.itemRoutingData' => 'Routing data and temporary files',
			'clearData.confirmBody' => ({required Object items, required Object dir}) => 'The following data saved on this device will be deleted (this cannot be undone):\n\n${items}\n\nThe account itself and any plan you purchased live on the server and are not affected; sign in again to restore your subscription.\n\nData directory: ${dir}\n(Do this before uninstalling the app: only then will reinstalling start clean and ask you to sign in again)',
			'clearData.confirmAgain' => 'Clear now? You will need to sign in again afterwards.',
			'clearData.clearedNotice' => ({required Object count, required Object dir}) => 'Cleared ${count} local data items (including the login session, so you will need to sign in again next time you open the app).\n\nYou can now delete the app to finish uninstalling:\n· macOS: drag Mclash.app to the Trash (the data directory has been emptied: ${dir})\n· Windows: uninstall Mclash from Control Panel and choose No when the wizard asks whether to keep your user data',
			'clearData.clearFailed' => ({required Object error}) => 'Clear failed: ${error}',
			'apiError.requestFailedHttp' => ({required Object status, required Object domain}) => 'Request failed (HTTP ${status}); already tried ${domain}',
			'apiError.allDomainsFailed' => ({required Object method, required Object path, required Object count}) => 'Request failed: ${method} ${path} (tried ${count} domains)',
			'apiError.requestTimeout' => ({required Object seconds, required Object method, required Object path}) => 'Request timed out (${seconds}s): ${method} ${path}',
			'apiError.networkUnreachable' => ({required Object detail}) => 'Network unreachable: ${detail}',
			'apiError.tlsHandshakeFailed' => 'TLS handshake failed. Check your network connection or system time.',
			'apiError.connectionFailed' => ({required Object detail}) => 'Connection failed: ${detail}',
			'apiError.requestError' => ({required Object error}) => 'Request failed: ${error}',
			'apiError.responseReadTimeout' => ({required Object seconds, required Object method, required Object path}) => 'Reading the response timed out (${seconds}s): ${method} ${path}',
			'apiError.notJson' => ({required Object status, required Object snippet}) => 'Response is not JSON (HTTP ${status}): ${snippet}',
			'apiError.badStructure' => ({required Object status}) => 'Unexpected response structure (HTTP ${status})',
			'apiError.loginFailed' => ({required Object code}) => 'Login failed (code ${code})',
			'apiError.loginMissingData' => 'Login response is missing data',
			'apiError.loginMissingToken' => 'Login response is missing access_token',
			'apiError.registerFailed' => ({required Object code}) => 'Registration failed (code ${code})',
			'apiError.registerMissingToken' => 'Registration response has no access_token - risk control may have been triggered, or the site is configured differently',
			'apiError.requestFailedCode' => ({required Object code}) => 'Request failed (code ${code})',
			'subNotice.titleNotFound' => 'Subscription not found',
			'subNotice.titleExpired' => 'Subscription expired',
			'subNotice.titleInactive' => 'Subscription inactive',
			'subNotice.titleDeviceOverLimit' => 'Device limit exceeded',
			'subNotice.titleUnavailable' => 'Subscription unavailable',
			'subNotice.titleWithReason' => ({required Object emoji, required Object title, required Object reason}) => '${emoji} ${title} (${reason})',
			'subNotice.deviceUsedOfLimit' => ({required Object used, required Object limit}) => 'Current devices ${used}/${limit}',
			'subNotice.deviceUsedOnly' => ({required Object used}) => 'Current devices ${used}',
			'subNotice.expireAt' => ({required Object expire}) => 'Expires at ${expire}',
			'subNotice.supportLine' => ({required Object account}) => '💬 Support: ${account}',
			'subNotice.siteLine' => ({required Object url}) => '📢 Website: ${url}',
			'settingItems.subscriptionAutoUpdateInterval' => 'Subscription auto-update interval',
			'settingItems.speedTestMode' => 'Speed test method',
			'settingItems.speedTestModeTcp' => 'TCP speed test',
			'settingItems.speedTestModeKernel' => 'Kernel speed test',
			'settingItems.delayTestUrlTip' => 'Time for one full HTTP request through this node (it is not a ping)\nDefaults to a plain http 204 empty response; using https adds a TLS handshake and a larger number',
			'settingItems.systemProxy' => 'System proxy',
			'settingItems.systemProxyTip' => 'View / reset address and port',
			'settingItems.tunMode' => 'TUN mode',
			'settingItems.tunModeTip' => 'off=system proxy only / auto=TUN+system proxy / force=TUN only\nOn desktop, TUN requires administrator privileges (wintun on Windows / utun on macOS)',
			'settingItems.tunOverwriteTip' => 'overwrite\nOn = the TUN settings on this page override the tun section of the profile\nOff = the profile\'s own tun configuration is used (the app does not interfere)',
			'settingItems.tunEnableByTunMode' => ({required Object enable}) => '${enable} (decided by TUN mode)',
			'settingItems.interval30Minutes' => '30 minutes',
			'settingItems.interval1Hour' => '1 hour',
			'settingItems.interval6Hours' => '6 hours',
			'settingItems.interval12Hours' => '12 hours',
			'settingItems.interval24Hours' => '24 hours',
			'settingItems.interval3Days' => '3 days',
			'settingItems.interval7Days' => '7 days',
			'settingItems.intervalNever' => 'Never',
			'settingItems.intervalMinutes' => ({required Object minutes}) => '${minutes} minutes',
			'settingItems.intervalHours' => ({required Object hours}) => '${hours} hours',
			'settingItems.intervalDays' => ({required Object days}) => '${days} days',
			'tunScreen.modeOff' => 'Off',
			'tunScreen.modeAuto' => 'Auto',
			'tunScreen.modeForce' => 'Force',
			'tunScreen.modeOffDesc' => 'System proxy only: works for programs that honor the system proxy (browsers and so on); UDP/games are not proxied',
			'tunScreen.modeAutoDesc' => 'TUN + system proxy (belt and braces): all traffic goes through the virtual adapter, including UDP',
			'tunScreen.modeForceDesc' => 'TUN only: all traffic goes through the virtual adapter, the system proxy is left untouched',
			'tunScreen.modeOffOptionDesc' => 'Does not touch the system routing table; only sets a 127.0.0.1 proxy in the system. Only programs that honor the system proxy use it; UDP traffic and programs with their own proxy settings do not.',
			'tunScreen.modeAutoOptionDesc' => 'Creates a virtual adapter and takes over all traffic (including UDP and games); the system proxy is kept as a fallback. Recommended: it works globally and you are not left without network access if permissions are missing.',
			'tunScreen.modeForceOptionDesc' => 'Uses only the virtual adapter and no longer changes the system proxy. All traffic (including UDP) goes through the tunnel; the "proxy" entry in the system stays as it is.',
			'tunScreen.adminRequiredDialog' => 'The TUN virtual adapter requires administrator privileges (wintun on Windows / utun on macOS).\n\nMclash is not running as administrator right now, so TUN will not take effect after enabling it (in "Auto" mode the system proxy still works as a fallback, so the network stays usable).\n\nOK = restart Mclash as administrator now (a UAC prompt will appear)\nCancel = still save this choice (the system proxy is used automatically when TUN is unavailable)',
			'tunScreen.relaunchFailed' => ({required Object message}) => 'Restart failed: ${message}',
			'tunScreen.switchFailed' => ({required Object message}) => 'Failed to switch TUN mode: ${message}\nThe previous settings have been restored.',
			'tunScreen.setOffSnack' => 'Set to "Off": system proxy only',
			'tunScreen.setModeSnack' => ({required Object mode, required Object effect}) => 'Set to "${mode}", ${effect}',
			'tunScreen.effectReconnected' => 'reconnected and now active',
			'tunScreen.effectAfterConnect' => 'active after connecting',
			'tunScreen.sheetTitle' => 'TUN Virtual Adapter',
			'tunScreen.advancedTitle' => 'Advanced parameters (Core Settings → TUN)',
			'tunScreen.advancedSubtitle' => 'Adapter address / stack / MTU / auto route / DNS hijack / overwrite',
			'tunScreen.adminOk' => 'TUN requires administrator privileges; the current privileges are sufficient (run as administrator on Windows / as root on macOS)',
			'tunScreen.adminMissing' => 'TUN requires administrator privileges: Mclash is not running as administrator, so TUN will not take effect after selecting "Auto/Force" ("Auto" falls back to the system proxy, so the network stays usable)',
			_ => null,
		};
	}
}
