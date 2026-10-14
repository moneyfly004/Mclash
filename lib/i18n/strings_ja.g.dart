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
		'HK': '香港',
		'TW': '台湾',
		'MO': 'マカオ',
		'CN': '中国',
		'JP': '日本',
		'KR': '韓国',
		'SG': 'シンガポール',
		'MY': 'マレーシア',
		'TH': 'タイ',
		'VN': 'ベトナム',
		'PH': 'フィリピン',
		'ID': 'インドネシア',
		'KH': 'カンボジア',
		'US': 'アメリカ',
		'CA': 'カナダ',
		'MX': 'メキシコ',
		'GB': 'イギリス',
		'DE': 'ドイツ',
		'FR': 'フランス',
		'NL': 'オランダ',
		'RU': 'ロシア',
		'IT': 'イタリア',
		'ES': 'スペイン',
		'CH': 'スイス',
		'SE': 'スウェーデン',
		'NO': 'ノルウェー',
		'FI': 'フィンランド',
		'DK': 'デンマーク',
		'PL': 'ポーランド',
		'AT': 'オーストリア',
		'IE': 'アイルランド',
		'UA': 'ウクライナ',
		'TR': 'トルコ',
		'PT': 'ポルトガル',
		'CZ': 'チェコ',
		'RO': 'ルーマニア',
		'BE': 'ベルギー',
		'GR': 'ギリシャ',
		'HU': 'ハンガリー',
		'IL': 'イスラエル',
		'AE': 'アラブ首長国連邦',
		'SA': 'サウジアラビア',
		'EG': 'エジプト',
		'ZA': '南アフリカ',
		'NG': 'ナイジェリア',
		'AU': 'オーストラリア',
		'NZ': 'ニュージーランド',
		'BR': 'ブラジル',
		'AR': 'アルゼンチン',
		'CL': 'チリ',
		'CO': 'コロンビア',
		'IN': 'インド',
		'PK': 'パキスタン',
		'XX': 'その他',
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
	@override String get decryptPassword => '復号パスワード';
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
	@override String get userAgent => 'ユーザーエージェント';
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
	@override String get accountBalance => '残高';
	@override String get expireAt => '有効期限';
	@override String get remainingDays => '残り日数';
	@override String get deviceCount => 'デバイス';
	@override String get myOrders => '注文履歴';
	@override String get deviceManagement => 'デバイス管理';
	@override String get changePassword => 'パスワード変更';
	@override String get clearLocalData => 'ローカルデータを削除 (アンインストール前)';
	@override String get profileManagementDev => 'プロファイル管理 (開発者向け)';
	@override String get tunAdapter => 'TUN仮想アダプター';
	@override String get checkUpdate => 'アップデートを確認';
	@override String get retry => '再試行';
	@override String get loadFailed => 'アカウント情報の読み込みに失敗しました。ログインの有効期限が切れているか、ネットワークに接続できない可能性があります。\n右上の更新をタップして再試行してください。それでも失敗する場合は再度ログインしてください。';
	@override String get logoutConfirm => 'ログアウトしますか？';
	@override String get boardNoKernel => 'ダッシュボードにはカーネルのリアルタイムデータ (接続状況、通信量、ルール一致) が表示されます。\n\nカーネルが起動していないため、ダッシュボードは空の状態になります。\nOKでそのまま開き、キャンセルで先にホームタブから接続してください。';
	@override String get boardOpened => 'ブラウザでダッシュボードを開きました。そこでノードやルールを切り替えると、約5秒以内にアプリ側へ反映されます。';
}

// Path: homeScreen
class _Translations$homeScreen$ja implements Translations$homeScreen$en {
	_Translations$homeScreen$ja._(this._root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String expiresOn({required Object date}) => '有効期限 ${date}';
	@override String devicesText({required Object text}) => 'デバイス ${text}';
	@override String get upgrade => 'アップグレード';
	@override String get quickCountries => '国・地域で絞り込み';
	@override String nodeCount({required Object count}) => '${count} ノード';
	@override String get autoBestTip => 'すべての国・地域から最も低遅延の利用可能ノードを選択します (自動モード)';
	@override String get autoBest => '自動最適';
	@override String pickCountryTip({required Object label}) => '「${label}」の中で最も低遅延の利用可能ノードを自動選択して固定します';
	@override String get autoNoBetter => 'すでに自動モードです (より良いノードは見つかりませんでした)';
	@override String switchedBest({required Object name}) => '最適なノードに切り替えました: ${name}';
	@override String switchedCountry({required Object country, required Object node, required Object ms}) => '最速の${country}ノードに切り替えました: ${node}${ms}';
	@override String filterCountryFailed({required Object country, required Object err}) => '${country}で絞り込みました。切り替えに失敗しました: ${err}';
	@override String deviceFullCount({required Object used, required Object limit}) => '現在のデバイス ${used}/${limit}\n\n';
	@override String get deviceFullUpgradeHint => 'デバイス上限をアップグレードするとすぐに接続が復旧します (推奨)。未使用のデバイスを削除して枠を空けることもできます。';
	@override String get later => '後で';
	@override String get upgradeDeviceCount => 'デバイス上限をアップグレード';
	@override String get cannotConnect => '接続できません';
	@override String get freshnessNever => '未同期 · タップして更新';
	@override String get freshnessJustNow => 'たった今更新 · タップしてデバイス管理';
	@override String freshnessMinutes({required Object minutes}) => '${minutes}分前 · タップしてデバイス管理';
	@override String freshnessStale({required Object minutes}) => '${minutes}分前 · タップして更新';
	@override String get subscriptionAutoSync => 'サブスクリプションの自動同期';
	@override String get connecting => '接続中…';
	@override String get disconnecting => '切断中…';
	@override String get tapToDisconnect => 'スイッチをタップして切断';
	@override String get tapToConnect => 'スイッチをタップして接続';
	@override String get currentNode => '現在のノード';
	@override String get noNodeSelected => 'ノードが選択されていません';
	@override String get switchAction => '切り替え';
	@override String get realtimeSpeed => 'リアルタイム速度';
	@override String get totalTraffic => '累計通信量';
	@override String get subSyncedNotReady => 'サブスクリプションは取得しましたが、プロファイルの準備がまだ整っていません。しばらくしてから再試行してください。';
	@override String get noPlan => 'このアカウントには利用可能なプランがまだありません。先にプランをご購入ください。';
	@override String get loginExpired => 'ログインの有効期限が切れました。再度ログインしてください。';
	@override String get syncingWait => 'サブスクリプションを同期中です。しばらくお待ちください。';
	@override String syncFailedNetwork({required Object message}) => 'サブスクリプションの同期に失敗しました: ${message}\nネットワークを確認して再試行してください。';
	@override String get syncFailed => 'サブスクリプションの同期に失敗しました。しばらくしてから再試行してください。';
	@override String get resetProxy => 'リセット';
	@override String latencySuffix({required Object ms}) => ' (${ms}ms)';
}

// Path: nodesScreen
class _Translations$nodesScreen$ja implements Translations$nodesScreen$en {
	_Translations$nodesScreen$ja._(this._root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String updatedCount({required Object count}) => 'サブスクリプションを更新しました: ${count} ノード';
	@override String updateFailed({required Object message}) => '更新に失敗しました: ${message}';
	@override String get updateFailedNetwork => '更新に失敗しました。ネットワークを確認してください';
	@override String testDone({required Object ok, required Object fail}) => '速度テスト完了: 到達可能 ${ok} 件、到達不可 ${fail} 件 (オフラインの可能性)';
	@override String switchedTo({required Object name}) => '${name} に切り替えました';
	@override String switchFailed({required Object message}) => '切り替えに失敗しました: ${message}\n(ノードの切り替えにはカーネルの起動が必要です。先にホームタブでスイッチをオンにしてください)';
	@override String selectedAfterConnect({required Object name}) => '${name} を選択しました (接続後に有効になります)';
	@override String get title => 'ノード';
	@override String get searchNode => 'ノードを検索';
	@override String get sortByLatency => '遅延の小さい順に並べ替え';
	@override String get updateSubscription => 'サブスクリプションを更新';
	@override String get viewByGroup => 'プロキシグループ別に表示';
	@override String get testAll => '一括テスト';
	@override String get searchHint => 'ノード / 国・地域 / プロトコルで検索';
	@override String get emptyNoNodes => '利用可能なノードがまだありません。\nサブスクリプションは自動で同期されます。ログインしたばかりの場合は少し待つか、下の再読み込みをタップしてください。';
	@override String get emptyNoMatch => '該当するノードがありません。';
	@override String get reload => '再読み込み';
	@override String get currentInUse => '現在 (使用中)';
	@override String get current => '現在';
	@override String get notTested => '未計測 (カーネルの再読み込み待ち)';
	@override String get timeout => 'タイムアウト';
	@override String get clear => 'クリア';
	@override String get selectNode => 'ノードを選択';
	@override String get emptyNoKernel => '利用可能なノードがまだありません。\n先にホームタブで接続スイッチをオンにしてください。';
	@override String get openFullList => 'ノード一覧を開く (検索 / 速度テスト / グループ)';
}

// Path: nodeAuto
class _Translations$nodeAuto$ja implements Translations$nodeAuto$en {
	_Translations$nodeAuto$ja._(this._root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get kernelStateUnavailable => 'カーネルからノードの状態を一時的に取得できません。自動的に再試行します。';
	@override String backToFixedNode({required Object fixed}) => '固定ノードに戻しました: ${fixed}';
	@override String get noUsableNodePickOne => '利用可能なノードが見つかりません。ノード一覧から手動で選択してください。';
	@override String get noUsableNodeTryOne => '利用可能なノードが見つかりません。ノード一覧から選択してみてください。';
	@override String autoConnectedBest({required Object bestNode, required Object bestMs}) => '最適なノードに自動接続しました: ${bestNode} (${bestMs} ms)';
	@override String get currentNodeUnreachable => '現在のノードがインターネットに接続できません。自動的に切り替えます…';
	@override String autoSwitchedToUsable({required Object target}) => '利用可能なノードに自動で切り替えました: ${target}';
	@override String newNodesReloading({required Object missing}) => 'サブスクリプションの新規ノード ${missing} 件がまだカーネルにありません。再読み込み中…';
	@override String get kernelReloadedRetest => '新しいサブスクリプションでカーネルを再読み込みしました。速度テストを再実行してください。';
}

// Path: accountBlock
class _Translations$accountBlock$ja implements Translations$accountBlock$en {
	_Translations$accountBlock$ja._(this._root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String quotaFull({required Object used, required Object limit}) => 'デバイス枠が満杯です (${used}/${limit})。このデバイスはライセンス範囲内のため通常どおり接続できます。別のデバイスを追加するには、デバイス上限をアップグレードするか未使用のデバイスを削除してください。';
	@override String get banFallback => 'このアカウントは無効化されたため、利用できません。';
	@override String get titleExpired => 'プランの有効期限切れ';
	@override String get titleDeviceFull => 'デバイス上限に達しました';
	@override String get titleAccountDisabled => 'アカウントが無効です';
	@override String get titlePlanDisabled => 'プランが無効です';
	@override String get titleNoPlan => 'プラン未購入';
	@override String get titleDeviceRemoved => 'このデバイスは削除されました';
	@override String get titleServiceUnavailable => 'サービスが一時的に利用できません';
	@override String get textExpired => 'プランの有効期限が切れました。グローバルノードを引き続き利用するにはプランをご購入ください。';
	@override String textDeviceFull({required Object used, required Object limit}) => 'このデバイスはプランのデバイス上限 (${used}/${limit}) を超えているとサーバーが判定したため、現在は接続できません。マイページ - デバイス管理で未使用のデバイスを削除するか、より多くのデバイスが使えるプランにアップグレードしてください。';
	@override String get textAccountDisabled => 'このアカウントは無効化されました。ご不明な点はサポートまでお問い合わせください。';
	@override String get textPlanDisabled => 'プランが無効または異常な状態のため接続できません。ご不明な点はサポートまでお問い合わせください。';
	@override String get textNoPlan => 'まだプランを購入していません。購入するとグローバルノードを利用できます。';
	@override String get textDeviceRemoved => 'このデバイスは削除され、ログアウトされました。再度ログインしてください。';
	@override String get textServiceUnavailable => 'サービスが一時的に利用できません。しばらくしてから再試行してください。解消しない場合はスクリーンショットを添えてサポートまでご連絡ください。';
	@override String remainingDays({required Object days}) => '残り ${days} 日';
	@override String deviceUsage({required Object used, required Object limit}) => 'デバイス ${used}/${limit}';
}

// Path: entitlementMsg
class _Translations$entitlementMsg$ja implements Translations$entitlementMsg$en {
	_Translations$entitlementMsg$ja._(this._root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get tamperedTitle => '認証状態が異常です';
	@override String get tamperedClock => 'システム時計の巻き戻し (またはローカル認証データの改ざん) を検出しました。オンラインで認証を完了してから接続してください。';
	@override String get tamperedLocal => 'ローカル認証データが破損または変更されています。オンラインで認証を完了してから接続してください。';
	@override String get needVerifyTitle => 'オンライン認証が必要です';
	@override String get needVerifyFirst => 'プランの状態を確認できません。ネットワークに接続してログインし、認証を1回完了してから接続してください。';
	@override String get needVerifyRetry => 'プランの状態を確認できません。オンラインにして再試行してください。';
	@override String get verifyFailedTitle => 'プランの状態を確認できません';
	@override String get verifyFailedText => '認証の猶予期間を過ぎ、サーバーに接続できません。ネットワークを確認して再試行してください (更新したばかりの場合は再度ログインしてください)。';
	@override String get restrictedTitle => 'アカウントが制限されています';
	@override String get restrictedFallback => 'アカウントまたはプランが無効化されたため、接続できません。';
	@override String get expiredTitle => 'プランの有効期限切れ';
	@override String expiredText({required Object date}) => 'プランは ${date} に期限切れになりました。ローカルのサブスクリプションプロファイルは削除されました。更新して再度ログインすると復元されます。';
}

// Path: devicesScreen
class _Translations$devicesScreen$ja implements Translations$devicesScreen$en {
	_Translations$devicesScreen$ja._(this._root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get title => 'デバイス管理';
	@override String get currentPlan => '現在のプラン';
	@override String devicesText({required Object text}) => 'デバイス ${text}';
	@override String get upgradeTitle => 'デバイス追加 / 期間延長';
	@override String get upgradeSubtitle => 'デバイスと日数をまとめて追加。料金も支払いも1回だけ';
	@override String get addDevices => 'デバイスを追加';
	@override String get noAddDevices => '変更なし';
	@override String addDevicesCount({required Object n}) => '+${n} デバイス';
	@override String get addDays => '日数を追加';
	@override String get noExtend => '延長なし';
	@override String addDaysCount({required Object n, required Object months}) => '+${n} 日 (${months} ヶ月)';
	@override String get priceFailed => '料金の取得に失敗しました';
	@override String amountDue({required Object amount}) => '合計 ¥${amount}';
	@override String get requote => '再計算';
	@override String get goPay => '今すぐ支払う';
	@override String get afterUpgrade => 'アップグレード後: ';
	@override String afterLimit({required Object limit}) => 'デバイス上限 ${limit}';
	@override String afterExpire({required Object date}) => '${date} に期限切れ';
	@override String get pickSomething => 'デバイスまたは日数を少なくとも1つ追加してください';
	@override String get daysOnlyUnsupported => '管理パネルは「期間延長のみ」にまだ対応していません。「デバイスを追加」を1以上に設定して再試行してください (またはサポートに有効化をご依頼ください)。';
	@override String get paramsRejected => 'パラメータが拒否されました。デバイス数と日数を選び直してください。';
	@override String get subscriptionExpired => 'サブスクリプションの有効期限が切れているためアップグレードできません。先に更新するかプランをご購入ください。';
	@override String get orderIncomplete => '注文情報が不完全です。「再計算」をタップして再試行してください。';
	@override String get orderRegenerated => '前回の注文が期限切れになったため、同じ設定で新しい注文を作成しました。';
	@override String get payChannelIncomplete => '注文または支払いチャネルの情報が不完全です。再計算してから再試行してください。';
	@override String get noQrCode => 'サーバーから支払い用のQRコード / リンクが返されませんでした。別の支払い方法を選ぶか、しばらくしてから再試行してください。';
	@override String payStartFailed({required Object err}) => '支払いを開始できませんでした: ${err}';
	@override String get payCancelled => '支払いをキャンセルしました。下書きの注文は削除されました。';
	@override String get balancePay => '残高';
	@override String get noPayMethod => '現在利用できる支払い方法がありません。しばらくしてから再試行するか、サポートまでお問い合わせください。';
	@override String balanceInsufficient({required Object balance, required Object amount}) => '残高が不足しています (¥${balance}、必要額 ¥${amount})。\n先にチャージしますか？';
	@override String get choosePayMethod => '支払い方法を選択';
	@override String balanceText({required Object balance}) => '残高 ¥${balance}';
	@override String balanceShort({required Object balance}) => '残高 ¥${balance} (不足しています。チャージしてください)';
	@override String get unknownDevice => '不明なデバイス';
	@override String get online => '● オンライン';
	@override String get offline => '○ オフライン';
	@override String lastActive({required Object text}) => '最終利用 ${text}';
	@override String get delete => '削除';
	@override String deleteConfirm({required Object name}) => 'デバイス「${name}」を削除しますか？すぐに強制オフラインになります。';
	@override String get lastActiveJustNow => 'たった今';
	@override String lastActiveMinutes({required Object minutes}) => '${minutes}分前';
	@override String lastActiveToday({required Object time}) => '今日 ${time}';
}

// Path: sysProxySheet
class _Translations$sysProxySheet$ja implements Translations$sysProxySheet$en {
	_Translations$sysProxySheet$ja._(this._root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get reading => '読み取り中…';
	@override String get unknown => '不明';
	@override String get kernelNotRunning => 'カーネルが起動していません (先にホームタブでスイッチをオンにしてください)';
	@override String applied({required Object host, required Object port}) => '適用済み · ${host}:${port}';
	@override String notSet({required Object reason}) => 'システムプロキシが未設定 — ${reason}';
	@override String notEffective({required Object port}) => '有効ではありません (${port} を指すシステムプロキシがありません)';
	@override String readFailed({required Object err}) => '読み取りに失敗しました: ${err}';
	@override String get setRejected => '設定に失敗しました。システムが書き込みを拒否したか、他のプロキシアプリが上書きした可能性があります';
	@override String get disableFailed => 'オフにできませんでした';
	@override String get portRange => 'ポートは 1〜65535 の範囲で指定してください';
	@override String portChanged({required Object value}) => 'ポートを ${value} に変更しました。カーネルが新しいポートで待ち受けるよう、一度切断して再接続してください';
	@override String get title => 'システムプロキシ';
	@override String desc({required Object host}) => 'システムプロキシのアドレスは ${host} (ローカルループバック) に固定され、ポートはカーネルの混合ポートです。';
	@override String get descWindows => 'これは Windows の設定 → ネットワークとインターネット → プロキシに表示される内容と同じです。';
	@override String get reset => '再設定';
	@override String get disable => 'システムプロキシをオフにする';
	@override String get diagnostics => '診断 (UI がレジストリと同じ値を読んでいるか)';
	@override String get mixedPort => '混合ポート';
	@override String get apply => '適用';
}

// Path: logScreen
class _Translations$logScreen$ja implements Translations$logScreen$en {
	_Translations$logScreen$ja._(this._root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String readAppFailed({required Object e}) => 'アプリログの読み取りに失敗しました: ${e}';
	@override String readCoreFailed({required Object e}) => 'カーネルログの読み取りに失敗しました: ${e}';
	@override String get copied => 'コピーしました (サブスクリプションURLなどの機密情報は伏せ字にしていますが、ログファイル自体には元のアドレスが残っている場合があります)';
	@override String get copy => 'コピー';
	@override String get refresh => '更新';
	@override String get empty => '内容がありません';
}

// Path: trayShell
class _Translations$trayShell$ja implements Translations$trayShell$en {
	_Translations$trayShell$ja._(this._root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get closeTitle => 'ウィンドウを閉じる';
	@override String get closeBody => 'ウィンドウを閉じても Mclash はトレイに残るだけで、カーネルとシステムプロキシは動作を続け、ネットワークは接続されたままです。\n\n· OK: トレイに最小化します (完全に終了するには、トレイアイコンを右クリック → 終了)\n· キャンセル: Mclash を完全に終了し、カーネルを停止してシステムプロキシを元に戻します\n\n(選択内容は記憶されます。次回はトレイアイコンから直接操作できます)';
}

// Path: ordersScreen
class _Translations$ordersScreen$ja implements Translations$ordersScreen$en {
	_Translations$ordersScreen$ja._(this._root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get title => '注文履歴';
	@override String get orderInfoIncomplete => '注文情報が不完全です。下に引いて更新してから再試行してください。';
	@override String get payChannelIncomplete => '支払いチャネルの情報が不完全です。しばらくしてから再試行してください。';
	@override String get noQrPayload => 'サーバーから支払い用のQRコードまたはリンクが返されませんでした。別の支払い方法を選ぶか、しばらくしてから再試行してください。';
	@override String payStartFailed({required Object err}) => '支払いを開始できませんでした: ${err}';
	@override String get noPayMethod => '現在利用できる支払い方法がありません。しばらくしてから再試行するか、サポートまでお問い合わせください。';
	@override String get choosePayMethod => '支払い方法を選択';
	@override String amountDue({required Object amount}) => 'お支払い金額 ¥${amount}';
	@override String get paidLabel => '● 支払い済み';
	@override String get pendingLabel => '○ 未払い';
	@override String unknownStatus({required Object status}) => '✕ ${status}';
	@override String orderNoText({required Object orderNo}) => '注文番号 ${orderNo}';
	@override String createdAtText({required Object createdAt}) => '作成日時 ${createdAt}';
	@override String get orderCanceled => '注文をキャンセルしました';
	@override String cancelFailed({required Object err}) => 'キャンセルに失敗しました: ${err}\n(すでに支払い済みまたはキャンセル済みの場合は、下に引いて更新すると最新の状態を確認できます)';
	@override String get cancelOrder => '注文をキャンセル';
	@override String get continuePay => '支払いを続ける';
}

// Path: payment
class _Translations$payment$ja implements Translations$payment$en {
	_Translations$payment$ja._(this._root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get balancePay => '残高払い';
	@override String get qrPay => 'QRコードで支払う';
	@override String get deductFromBalance => 'アカウント残高から差し引かれます';
	@override String get openedInBrowser => 'ブラウザで支払いページを開きました';
	@override String get scanWithAlipayWechat => 'Alipay または WeChat でスキャン';
	@override String orderNoText({required Object orderNo}) => '注文番号 ${orderNo}';
	@override String payFailed({required Object err}) => '支払いに失敗しました: ${err}';
	@override String get notDetected => '支払いを確認できませんでした。あとで「注文履歴」から続けられます。';
	@override String get charging => 'チャージ中…';
	@override String get processing => '処理中…';
	@override String get waitingPay => '支払いを待っています…';
	@override String get openPageFailed => '支払いページを開けませんでした。下のボタンをタップして再試行するか、QRコードをスキャンしてください。';
	@override String get reopenPayPage => '支払いページを再度開く';
	@override String get payInBrowser => 'ブラウザで支払う';
	@override String get openAlipay => 'Alipay を開く';
	@override String get cancelOrder => '注文をキャンセル';
	@override String get confirmPay => '支払いを確定';
	@override String get retry => '再試行';
	@override String get paidAlready => '支払い済みです';
	@override String get channelAlipay => 'Alipay';
	@override String get channelCodepayAlipay => 'コード決済 · Alipay';
	@override String get channelCodepayWechat => 'コード決済 · WeChat';
	@override String get channelCodepay => 'コード決済';
	@override String get channelWechat => 'WeChatペイ';
	@override String get channelUsdt => 'USDT';
	@override String get channelUsdtTrc20 => 'USDT · TRC20';
	@override String get payFallback => '支払い';
	@override String get errCsrf => 'ログイン情報の有効期限が切れています (CSRFチェックに失敗)。\n「マイページ」タブで下に引いて更新するか、再度ログインしてから再試行してください。';
	@override String get errAlipayLimit => 'Alipay の対面支払いには1回あたりの上限があり (この加盟店では ¥1000)、この注文は上限を超えています。\n「残高払い」または「コード決済」をご利用いただくか、サポートまでお問い合わせのうえ Alipay の上限を引き上げてください。';
	@override String get errNotSigned => 'Alipay アプリが対応する支払い商品に申し込んでいないため、このチャネルは一時的に利用できません。\n「残高払い」または「コード決済」をご利用いただくか、サポートまでお問い合わせのうえ有効化してください。';
	@override String get errOrderGone => 'この注文はキャンセル済みか期限切れです (下書き注文の有効期間は30分です)。\n「再計算」をタップして新しい注文を作成してから支払ってください。';
	@override String errNetwork({required Object err}) => 'ネットワークに接続できません: ${err}';
}

// Path: planScreen
class _Translations$planScreen$ja implements Translations$planScreen$en {
	_Translations$planScreen$ja._(this._root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get recommended => 'おすすめ';
	@override String get devices => 'デバイス';
	@override String balanceLabel({required Object amount}) => '残高 ¥${amount}';
	@override String get balanceInsufficient => ' (不足しています。先にチャージしてください)';
	@override String get total => '合計';
	@override String get payNow => '今すぐ支払う';
	@override String get retry => '再試行';
	@override String get errIncompleteOrder => '注文または支払いチャネルの情報が不完全なため、支払いを開始できません。';
	@override String get payBalance => '残高払い';
	@override String get payAlipay => 'Alipay';
	@override String get payWechat => 'WeChatペイ';
	@override String get payCodepay => 'コード決済';
	@override String get payCodepayAlipay => 'コード決済 · Alipay';
	@override String get payCodepayWechat => 'コード決済 · WeChat';
	@override String get payEpayAlipay => 'Epay · Alipay';
	@override String get payEpayWechat => 'Epay · WeChat';
	@override String get payUsdt => 'USDT';
	@override String get payUsdtTrc20 => 'USDT · TRC20';
	@override String get payStripe => 'Stripe';
	@override String get payPaypal => 'PayPal';
	@override String get payOnline => 'オンライン決済';
}

// Path: authScreen
class _Translations$authScreen$ja implements Translations$authScreen$en {
	_Translations$authScreen$ja._(this._root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get saveAccountInfo => 'アカウント情報を保存';
	@override String get autoLoginNextTime => '次回から自動ログイン';
	@override String get needLoginNextTime => '次回は再度ログインが必要です';
	@override String get invalidEmail => '有効なメールアドレスを入力してください';
	@override String get enterEmailFirst => '先に有効なメールアドレスを入力してください';
	@override String get passwordRequired => 'パスワードを入力してください';
	@override String get wrongCredentials => 'メールアドレスまたはパスワードが正しくありません';
	@override String get requestRejected => 'リクエストが拒否されました。しばらくしてから再試行してください。';
	@override String get tooFrequent => '試行回数が多すぎます。しばらくしてから再試行してください。';
	@override String get loginFailed => 'ログインに失敗しました';
	@override String get username => 'ユーザー名';
	@override String get confirmPassword => 'パスワードの確認';
	@override String get inviteCode => '招待コード';
	@override String get emailCode => 'メール認証コード';
	@override String get getCode => 'コードを取得';
	@override String get registerAndLogin => '登録してログイン';
	@override String usernameMinLength({required Object min}) => 'ユーザー名は ${min} 文字以上で入力してください';
	@override String get passwordMismatch => 'パスワードが一致しません';
	@override String get emailCodeRequired => 'メール認証コードを入力してください';
	@override String get inviteCodeRequired => 'このサイトの登録には招待コードが必要です';
	@override String get codeSentCheckEmail => '認証コードを送信しました。メールをご確認ください。';
	@override String get registerSuccess => '登録が完了しました。ログイン済みです。';
	@override String passwordHint({required Object min}) => '${min} 文字以上で、英字と数字の両方を含めてください';
	@override String passwordTooShort({required Object min}) => 'パスワードは ${min} 文字以上で入力してください';
	@override String get passwordNeedsLetterAndDigit => 'パスワードには英字と数字の両方を含めてください';
	@override String get registeredEmail => '登録済みのメールアドレス';
	@override String get newPassword => '新しいパスワード';
	@override String get confirmNewPassword => '新しいパスワードの確認';
	@override String get resetPassword => 'パスワードをリセット';
	@override String get resetCodeSent => 'このメールアドレスが登録済みの場合、リセットコードを送信しました (有効期限15分)。';
	@override String get resetSuccess => 'パスワードをリセットしました。新しいパスワードでログインしてください。';
	@override String get changePasswordTitle => 'パスワード変更';
	@override String get currentPassword => '現在のパスワード';
	@override String get saveNewPassword => '新しいパスワードを保存';
	@override String get newPasswordMismatch => '新しいパスワードが一致しません';
	@override String get changePasswordSuccess => 'パスワードを変更しました。再度ログインしてください。';
}

// Path: updatePrompt
class _Translations$updatePrompt$ja implements Translations$updatePrompt$en {
	_Translations$updatePrompt$ja._(this._root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get checking => 'アップデートを確認中…';
	@override String get checkFailed => 'アップデートの確認に失敗しました。ネットワークを確認して再試行してください。';
	@override String alreadyLatest({required Object version}) => '最新バージョンです (${version})。';
	@override String newVersionFound({required Object version}) => '新しいバージョン ${version} があります';
	@override String get installerDownloaded => 'インストーラのバックグラウンドダウンロードが完了しました。「今すぐ更新」をタップしてアップグレードを完了してください。';
	@override String get downloadInBackground => '「今すぐ更新」をタップするとダウンロードとインストールを行います (アプリはそのまま利用でき、インストーラはバックグラウンドでダウンロードされます)。';
	@override String get later => '後で';
	@override String get updateNow => '今すぐ更新';
	@override String installerNotReady({required Object version}) => 'インストーラのダウンロードがまだ完了していません。\n\nOKをタップするとダウンロードページを開きます。お使いの環境に合ったインストーラ (バージョン ${version}) を手動でダウンロードしてください。';
}

// Path: clearData
class _Translations$clearData$ja implements Translations$clearData$en {
	_Translations$clearData$ja._(this._root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get itemLoginSession => 'ログインセッション';
	@override String get itemProfiles => 'サブスクリプションプロファイル (profiles/)';
	@override String get itemSettings => 'アプリとカーネルの設定';
	@override String get itemLatencyCache => 'ノード遅延キャッシュ';
	@override String get itemLogs => '実行時ログ';
	@override String get itemRoutingData => 'ルーティングデータと一時ファイル';
	@override String confirmBody({required Object items, required Object dir}) => 'このデバイスに保存されている以下のデータを削除します (元に戻せません):\n\n${items}\n\nアカウント自体と購入済みのプランはサーバー側にあるため影響ありません。再度ログインするとサブスクリプションが復元されます。\n\nデータディレクトリ: ${dir}\n(アプリをアンインストールする前に実行してください。そうすることで再インストール時にまっさらな状態から始まり、再度ログインが求められます)';
	@override String get confirmAgain => '今すぐ削除しますか？削除後は再度ログインが必要になります。';
	@override String clearedNotice({required Object count, required Object dir}) => 'ローカルデータ ${count} 件を削除しました (ログインセッションを含むため、次回アプリを開くときに再度ログインが必要です)。\n\nアプリを削除してアンインストールを完了できます:\n· macOS: Mclash.app をゴミ箱にドラッグ (データディレクトリは空になっています: ${dir})\n· Windows: コントロールパネルから Mclash をアンインストールし、ウィザードでユーザーデータを保持するかを聞かれたら「いいえ」を選択してください';
	@override String clearFailed({required Object error}) => '削除に失敗しました: ${error}';
}

// Path: apiError
class _Translations$apiError$ja implements Translations$apiError$en {
	_Translations$apiError$ja._(this._root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String requestFailedHttp({required Object status, required Object domain}) => 'リクエストに失敗しました (HTTP ${status})。${domain} は試行済みです';
	@override String allDomainsFailed({required Object method, required Object path, required Object count}) => 'リクエストに失敗しました: ${method} ${path} (${count} 件のドメインを試行)';
	@override String requestTimeout({required Object seconds, required Object method, required Object path}) => 'リクエストがタイムアウトしました (${seconds}秒): ${method} ${path}';
	@override String networkUnreachable({required Object detail}) => 'ネットワークに接続できません: ${detail}';
	@override String get tlsHandshakeFailed => 'TLS ハンドシェイクに失敗しました。ネットワーク接続またはシステム時刻を確認してください。';
	@override String connectionFailed({required Object detail}) => '接続に失敗しました: ${detail}';
	@override String requestError({required Object error}) => 'リクエストに失敗しました: ${error}';
	@override String responseReadTimeout({required Object seconds, required Object method, required Object path}) => 'レスポンスの読み取りがタイムアウトしました (${seconds}秒): ${method} ${path}';
	@override String notJson({required Object status, required Object snippet}) => 'レスポンスが JSON ではありません (HTTP ${status}): ${snippet}';
	@override String badStructure({required Object status}) => '想定外のレスポンス構造です (HTTP ${status})';
	@override String loginFailed({required Object code}) => 'ログインに失敗しました (コード ${code})';
	@override String get loginMissingData => 'ログインレスポンスにデータがありません';
	@override String get loginMissingToken => 'ログインレスポンスに access_token がありません';
	@override String registerFailed({required Object code}) => '登録に失敗しました (コード ${code})';
	@override String get registerMissingToken => '登録レスポンスに access_token がありません。リスク管理が作動したか、サイトの設定が異なる可能性があります';
	@override String requestFailedCode({required Object code}) => 'リクエストに失敗しました (コード ${code})';
}

// Path: subNotice
class _Translations$subNotice$ja implements Translations$subNotice$en {
	_Translations$subNotice$ja._(this._root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get titleNotFound => 'サブスクリプションが見つかりません';
	@override String get titleExpired => 'サブスクリプションの有効期限切れ';
	@override String get titleInactive => 'サブスクリプションが無効です';
	@override String get titleDeviceOverLimit => 'デバイス上限を超えています';
	@override String get titleUnavailable => 'サブスクリプションを利用できません';
	@override String titleWithReason({required Object emoji, required Object title, required Object reason}) => '${emoji} ${title} (${reason})';
	@override String deviceUsedOfLimit({required Object used, required Object limit}) => '現在のデバイス ${used}/${limit}';
	@override String deviceUsedOnly({required Object used}) => '現在のデバイス ${used}';
	@override String expireAt({required Object expire}) => '有効期限 ${expire}';
	@override String supportLine({required Object account}) => '💬 サポート: ${account}';
	@override String siteLine({required Object url}) => '📢 ウェブサイト: ${url}';
}

// Path: settingItems
class _Translations$settingItems$ja implements Translations$settingItems$en {
	_Translations$settingItems$ja._(this._root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get subscriptionAutoUpdateInterval => 'サブスクリプションの自動更新間隔';
	@override String get speedTestMode => '速度テスト方式';
	@override String get speedTestModeTcp => 'TCP 速度テスト';
	@override String get speedTestModeKernel => 'カーネル速度テスト';
	@override String get delayTestUrlTip => 'このノード経由で HTTP リクエスト1回にかかる時間です (ping ではありません)\n既定はプレーンな http 204 の空レスポンスです。https を使うと TLS ハンドシェイク分が加算され、値が大きくなります';
	@override String get systemProxy => 'システムプロキシ';
	@override String get systemProxyTip => 'アドレスとポートの確認 / 再設定';
	@override String get tunMode => 'TUNモード';
	@override String get tunModeTip => 'off=システムプロキシのみ / auto=TUN+システムプロキシ / force=TUNのみ\nデスクトップでは TUN に管理者権限が必要です (Windows は wintun / macOS は utun)';
	@override String get tunOverwriteTip => 'overwrite\nオン = このページの TUN 設定がプロファイルの tun セクションを上書きします\nオフ = プロファイル自身の tun 設定を使用します (アプリは干渉しません)';
	@override String tunEnableByTunMode({required Object enable}) => '${enable} (TUNモードにより決定)';
	@override String get interval30Minutes => '30分';
	@override String get interval1Hour => '1時間';
	@override String get interval6Hours => '6時間';
	@override String get interval12Hours => '12時間';
	@override String get interval24Hours => '24時間';
	@override String get interval3Days => '3日';
	@override String get interval7Days => '7日';
	@override String get intervalNever => 'なし';
	@override String intervalMinutes({required Object minutes}) => '${minutes}分';
	@override String intervalHours({required Object hours}) => '${hours}時間';
	@override String intervalDays({required Object days}) => '${days}日';
}

// Path: tunScreen
class _Translations$tunScreen$ja implements Translations$tunScreen$en {
	_Translations$tunScreen$ja._(this._root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get modeOff => 'オフ';
	@override String get modeAuto => '自動';
	@override String get modeForce => '強制';
	@override String get modeOffDesc => 'システムプロキシのみ: システムプロキシに従うプログラム (ブラウザなど) では有効ですが、UDP / ゲームはプロキシされません';
	@override String get modeAutoDesc => 'TUN + システムプロキシ (併用): UDP を含むすべての通信が仮想アダプターを経由します';
	@override String get modeForceDesc => 'TUNのみ: すべての通信が仮想アダプターを経由し、システムプロキシには触れません';
	@override String get modeOffOptionDesc => 'システムのルーティングテーブルには触れず、システムに 127.0.0.1 のプロキシを設定するだけです。システムプロキシに従うプログラムのみが利用し、UDP 通信や独自のプロキシ設定を持つプログラムは利用しません。';
	@override String get modeAutoOptionDesc => '仮想アダプターを作成し、すべての通信 (UDP やゲームを含む) を引き受けます。システムプロキシはフォールバックとして維持されます。推奨: 全体的に機能し、権限が不足していてもネットワークが使えなくなりません。';
	@override String get modeForceOptionDesc => '仮想アダプターのみを使用し、システムプロキシは変更しません。すべての通信 (UDP を含む) がトンネルを経由し、システムの「プロキシ」設定はそのまま残ります。';
	@override String get adminRequiredDialog => 'TUN仮想アダプターには管理者権限が必要です (Windows は wintun / macOS は utun)。\n\n現在 Mclash は管理者として実行されていないため、有効にしても TUN は反映されません (「自動」モードではシステムプロキシがフォールバックとして機能するため、ネットワークは利用できます)。\n\nOK = 今すぐ管理者として Mclash を再起動します (UAC の確認が表示されます)\nキャンセル = この選択を保存します (TUN が利用できない場合は自動的にシステムプロキシを使用します)';
	@override String relaunchFailed({required Object message}) => '再起動に失敗しました: ${message}';
	@override String switchFailed({required Object message}) => 'TUNモードの切り替えに失敗しました: ${message}\n以前の設定に戻しました。';
	@override String get setOffSnack => '「オフ」に設定しました: システムプロキシのみ';
	@override String setModeSnack({required Object mode, required Object effect}) => '「${mode}」に設定しました。${effect}';
	@override String get effectReconnected => '再接続済みで有効です';
	@override String get effectAfterConnect => '接続後に有効になります';
	@override String get sheetTitle => 'TUN仮想アダプター';
	@override String get advancedTitle => '詳細パラメータ (コア設定 → TUN)';
	@override String get advancedSubtitle => 'アダプターアドレス / スタック / MTU / 自動ルート / DNSハイジャック / 上書き';
	@override String get adminOk => 'TUN には管理者権限が必要です。現在の権限で十分です (Windows は管理者として実行 / macOS は root で実行)';
	@override String get adminMissing => 'TUN には管理者権限が必要です: Mclash が管理者として実行されていないため、「自動 / 強制」を選んでも TUN は反映されません (「自動」ではシステムプロキシにフォールバックするため、ネットワークは利用できます)';
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
			'meta.decryptPassword' => '復号パスワード',
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
			'meta.userAgent' => 'ユーザーエージェント',
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
			'countries.HK' => '香港',
			'countries.TW' => '台湾',
			'countries.MO' => 'マカオ',
			'countries.CN' => '中国',
			'countries.JP' => '日本',
			'countries.KR' => '韓国',
			'countries.SG' => 'シンガポール',
			'countries.MY' => 'マレーシア',
			'countries.TH' => 'タイ',
			'countries.VN' => 'ベトナム',
			'countries.PH' => 'フィリピン',
			'countries.ID' => 'インドネシア',
			'countries.KH' => 'カンボジア',
			'countries.US' => 'アメリカ',
			'countries.CA' => 'カナダ',
			'countries.MX' => 'メキシコ',
			'countries.GB' => 'イギリス',
			'countries.DE' => 'ドイツ',
			'countries.FR' => 'フランス',
			'countries.NL' => 'オランダ',
			'countries.RU' => 'ロシア',
			'countries.IT' => 'イタリア',
			'countries.ES' => 'スペイン',
			'countries.CH' => 'スイス',
			'countries.SE' => 'スウェーデン',
			'countries.NO' => 'ノルウェー',
			'countries.FI' => 'フィンランド',
			'countries.DK' => 'デンマーク',
			'countries.PL' => 'ポーランド',
			'countries.AT' => 'オーストリア',
			'countries.IE' => 'アイルランド',
			'countries.UA' => 'ウクライナ',
			'countries.TR' => 'トルコ',
			'countries.PT' => 'ポルトガル',
			'countries.CZ' => 'チェコ',
			'countries.RO' => 'ルーマニア',
			'countries.BE' => 'ベルギー',
			'countries.GR' => 'ギリシャ',
			'countries.HU' => 'ハンガリー',
			'countries.IL' => 'イスラエル',
			'countries.AE' => 'アラブ首長国連邦',
			'countries.SA' => 'サウジアラビア',
			'countries.EG' => 'エジプト',
			'countries.ZA' => '南アフリカ',
			'countries.NG' => 'ナイジェリア',
			'countries.AU' => 'オーストラリア',
			'countries.NZ' => 'ニュージーランド',
			'countries.BR' => 'ブラジル',
			'countries.AR' => 'アルゼンチン',
			'countries.CL' => 'チリ',
			'countries.CO' => 'コロンビア',
			'countries.IN' => 'インド',
			'countries.PK' => 'パキスタン',
			'countries.XX' => 'その他',
			'meScreen.accountBalance' => '残高',
			'meScreen.expireAt' => '有効期限',
			'meScreen.remainingDays' => '残り日数',
			'meScreen.deviceCount' => 'デバイス',
			'meScreen.myOrders' => '注文履歴',
			'meScreen.deviceManagement' => 'デバイス管理',
			'meScreen.changePassword' => 'パスワード変更',
			'meScreen.clearLocalData' => 'ローカルデータを削除 (アンインストール前)',
			'meScreen.profileManagementDev' => 'プロファイル管理 (開発者向け)',
			'meScreen.tunAdapter' => 'TUN仮想アダプター',
			'meScreen.checkUpdate' => 'アップデートを確認',
			'meScreen.retry' => '再試行',
			'meScreen.loadFailed' => 'アカウント情報の読み込みに失敗しました。ログインの有効期限が切れているか、ネットワークに接続できない可能性があります。\n右上の更新をタップして再試行してください。それでも失敗する場合は再度ログインしてください。',
			'meScreen.logoutConfirm' => 'ログアウトしますか？',
			'meScreen.boardNoKernel' => 'ダッシュボードにはカーネルのリアルタイムデータ (接続状況、通信量、ルール一致) が表示されます。\n\nカーネルが起動していないため、ダッシュボードは空の状態になります。\nOKでそのまま開き、キャンセルで先にホームタブから接続してください。',
			'meScreen.boardOpened' => 'ブラウザでダッシュボードを開きました。そこでノードやルールを切り替えると、約5秒以内にアプリ側へ反映されます。',
			'homeScreen.expiresOn' => ({required Object date}) => '有効期限 ${date}',
			'homeScreen.devicesText' => ({required Object text}) => 'デバイス ${text}',
			'homeScreen.upgrade' => 'アップグレード',
			'homeScreen.quickCountries' => '国・地域で絞り込み',
			'homeScreen.nodeCount' => ({required Object count}) => '${count} ノード',
			'homeScreen.autoBestTip' => 'すべての国・地域から最も低遅延の利用可能ノードを選択します (自動モード)',
			'homeScreen.autoBest' => '自動最適',
			'homeScreen.pickCountryTip' => ({required Object label}) => '「${label}」の中で最も低遅延の利用可能ノードを自動選択して固定します',
			'homeScreen.autoNoBetter' => 'すでに自動モードです (より良いノードは見つかりませんでした)',
			'homeScreen.switchedBest' => ({required Object name}) => '最適なノードに切り替えました: ${name}',
			'homeScreen.switchedCountry' => ({required Object country, required Object node, required Object ms}) => '最速の${country}ノードに切り替えました: ${node}${ms}',
			'homeScreen.filterCountryFailed' => ({required Object country, required Object err}) => '${country}で絞り込みました。切り替えに失敗しました: ${err}',
			'homeScreen.deviceFullCount' => ({required Object used, required Object limit}) => '現在のデバイス ${used}/${limit}\n\n',
			'homeScreen.deviceFullUpgradeHint' => 'デバイス上限をアップグレードするとすぐに接続が復旧します (推奨)。未使用のデバイスを削除して枠を空けることもできます。',
			'homeScreen.later' => '後で',
			'homeScreen.upgradeDeviceCount' => 'デバイス上限をアップグレード',
			'homeScreen.cannotConnect' => '接続できません',
			'homeScreen.freshnessNever' => '未同期 · タップして更新',
			'homeScreen.freshnessJustNow' => 'たった今更新 · タップしてデバイス管理',
			'homeScreen.freshnessMinutes' => ({required Object minutes}) => '${minutes}分前 · タップしてデバイス管理',
			'homeScreen.freshnessStale' => ({required Object minutes}) => '${minutes}分前 · タップして更新',
			'homeScreen.subscriptionAutoSync' => 'サブスクリプションの自動同期',
			'homeScreen.connecting' => '接続中…',
			'homeScreen.disconnecting' => '切断中…',
			'homeScreen.tapToDisconnect' => 'スイッチをタップして切断',
			'homeScreen.tapToConnect' => 'スイッチをタップして接続',
			'homeScreen.currentNode' => '現在のノード',
			'homeScreen.noNodeSelected' => 'ノードが選択されていません',
			'homeScreen.switchAction' => '切り替え',
			'homeScreen.realtimeSpeed' => 'リアルタイム速度',
			'homeScreen.totalTraffic' => '累計通信量',
			'homeScreen.subSyncedNotReady' => 'サブスクリプションは取得しましたが、プロファイルの準備がまだ整っていません。しばらくしてから再試行してください。',
			'homeScreen.noPlan' => 'このアカウントには利用可能なプランがまだありません。先にプランをご購入ください。',
			'homeScreen.loginExpired' => 'ログインの有効期限が切れました。再度ログインしてください。',
			'homeScreen.syncingWait' => 'サブスクリプションを同期中です。しばらくお待ちください。',
			'homeScreen.syncFailedNetwork' => ({required Object message}) => 'サブスクリプションの同期に失敗しました: ${message}\nネットワークを確認して再試行してください。',
			'homeScreen.syncFailed' => 'サブスクリプションの同期に失敗しました。しばらくしてから再試行してください。',
			'homeScreen.resetProxy' => 'リセット',
			'homeScreen.latencySuffix' => ({required Object ms}) => ' (${ms}ms)',
			'nodesScreen.updatedCount' => ({required Object count}) => 'サブスクリプションを更新しました: ${count} ノード',
			'nodesScreen.updateFailed' => ({required Object message}) => '更新に失敗しました: ${message}',
			'nodesScreen.updateFailedNetwork' => '更新に失敗しました。ネットワークを確認してください',
			'nodesScreen.testDone' => ({required Object ok, required Object fail}) => '速度テスト完了: 到達可能 ${ok} 件、到達不可 ${fail} 件 (オフラインの可能性)',
			'nodesScreen.switchedTo' => ({required Object name}) => '${name} に切り替えました',
			'nodesScreen.switchFailed' => ({required Object message}) => '切り替えに失敗しました: ${message}\n(ノードの切り替えにはカーネルの起動が必要です。先にホームタブでスイッチをオンにしてください)',
			'nodesScreen.selectedAfterConnect' => ({required Object name}) => '${name} を選択しました (接続後に有効になります)',
			'nodesScreen.title' => 'ノード',
			'nodesScreen.searchNode' => 'ノードを検索',
			'nodesScreen.sortByLatency' => '遅延の小さい順に並べ替え',
			'nodesScreen.updateSubscription' => 'サブスクリプションを更新',
			'nodesScreen.viewByGroup' => 'プロキシグループ別に表示',
			'nodesScreen.testAll' => '一括テスト',
			'nodesScreen.searchHint' => 'ノード / 国・地域 / プロトコルで検索',
			'nodesScreen.emptyNoNodes' => '利用可能なノードがまだありません。\nサブスクリプションは自動で同期されます。ログインしたばかりの場合は少し待つか、下の再読み込みをタップしてください。',
			'nodesScreen.emptyNoMatch' => '該当するノードがありません。',
			'nodesScreen.reload' => '再読み込み',
			'nodesScreen.currentInUse' => '現在 (使用中)',
			'nodesScreen.current' => '現在',
			'nodesScreen.notTested' => '未計測 (カーネルの再読み込み待ち)',
			'nodesScreen.timeout' => 'タイムアウト',
			'nodesScreen.clear' => 'クリア',
			'nodesScreen.selectNode' => 'ノードを選択',
			'nodesScreen.emptyNoKernel' => '利用可能なノードがまだありません。\n先にホームタブで接続スイッチをオンにしてください。',
			'nodesScreen.openFullList' => 'ノード一覧を開く (検索 / 速度テスト / グループ)',
			'nodeAuto.kernelStateUnavailable' => 'カーネルからノードの状態を一時的に取得できません。自動的に再試行します。',
			'nodeAuto.backToFixedNode' => ({required Object fixed}) => '固定ノードに戻しました: ${fixed}',
			'nodeAuto.noUsableNodePickOne' => '利用可能なノードが見つかりません。ノード一覧から手動で選択してください。',
			'nodeAuto.noUsableNodeTryOne' => '利用可能なノードが見つかりません。ノード一覧から選択してみてください。',
			'nodeAuto.autoConnectedBest' => ({required Object bestNode, required Object bestMs}) => '最適なノードに自動接続しました: ${bestNode} (${bestMs} ms)',
			'nodeAuto.currentNodeUnreachable' => '現在のノードがインターネットに接続できません。自動的に切り替えます…',
			'nodeAuto.autoSwitchedToUsable' => ({required Object target}) => '利用可能なノードに自動で切り替えました: ${target}',
			'nodeAuto.newNodesReloading' => ({required Object missing}) => 'サブスクリプションの新規ノード ${missing} 件がまだカーネルにありません。再読み込み中…',
			'nodeAuto.kernelReloadedRetest' => '新しいサブスクリプションでカーネルを再読み込みしました。速度テストを再実行してください。',
			'accountBlock.quotaFull' => ({required Object used, required Object limit}) => 'デバイス枠が満杯です (${used}/${limit})。このデバイスはライセンス範囲内のため通常どおり接続できます。別のデバイスを追加するには、デバイス上限をアップグレードするか未使用のデバイスを削除してください。',
			'accountBlock.banFallback' => 'このアカウントは無効化されたため、利用できません。',
			'accountBlock.titleExpired' => 'プランの有効期限切れ',
			'accountBlock.titleDeviceFull' => 'デバイス上限に達しました',
			'accountBlock.titleAccountDisabled' => 'アカウントが無効です',
			'accountBlock.titlePlanDisabled' => 'プランが無効です',
			'accountBlock.titleNoPlan' => 'プラン未購入',
			'accountBlock.titleDeviceRemoved' => 'このデバイスは削除されました',
			'accountBlock.titleServiceUnavailable' => 'サービスが一時的に利用できません',
			'accountBlock.textExpired' => 'プランの有効期限が切れました。グローバルノードを引き続き利用するにはプランをご購入ください。',
			'accountBlock.textDeviceFull' => ({required Object used, required Object limit}) => 'このデバイスはプランのデバイス上限 (${used}/${limit}) を超えているとサーバーが判定したため、現在は接続できません。マイページ - デバイス管理で未使用のデバイスを削除するか、より多くのデバイスが使えるプランにアップグレードしてください。',
			'accountBlock.textAccountDisabled' => 'このアカウントは無効化されました。ご不明な点はサポートまでお問い合わせください。',
			'accountBlock.textPlanDisabled' => 'プランが無効または異常な状態のため接続できません。ご不明な点はサポートまでお問い合わせください。',
			'accountBlock.textNoPlan' => 'まだプランを購入していません。購入するとグローバルノードを利用できます。',
			'accountBlock.textDeviceRemoved' => 'このデバイスは削除され、ログアウトされました。再度ログインしてください。',
			'accountBlock.textServiceUnavailable' => 'サービスが一時的に利用できません。しばらくしてから再試行してください。解消しない場合はスクリーンショットを添えてサポートまでご連絡ください。',
			'accountBlock.remainingDays' => ({required Object days}) => '残り ${days} 日',
			'accountBlock.deviceUsage' => ({required Object used, required Object limit}) => 'デバイス ${used}/${limit}',
			'entitlementMsg.tamperedTitle' => '認証状態が異常です',
			'entitlementMsg.tamperedClock' => 'システム時計の巻き戻し (またはローカル認証データの改ざん) を検出しました。オンラインで認証を完了してから接続してください。',
			'entitlementMsg.tamperedLocal' => 'ローカル認証データが破損または変更されています。オンラインで認証を完了してから接続してください。',
			'entitlementMsg.needVerifyTitle' => 'オンライン認証が必要です',
			'entitlementMsg.needVerifyFirst' => 'プランの状態を確認できません。ネットワークに接続してログインし、認証を1回完了してから接続してください。',
			'entitlementMsg.needVerifyRetry' => 'プランの状態を確認できません。オンラインにして再試行してください。',
			'entitlementMsg.verifyFailedTitle' => 'プランの状態を確認できません',
			'entitlementMsg.verifyFailedText' => '認証の猶予期間を過ぎ、サーバーに接続できません。ネットワークを確認して再試行してください (更新したばかりの場合は再度ログインしてください)。',
			'entitlementMsg.restrictedTitle' => 'アカウントが制限されています',
			'entitlementMsg.restrictedFallback' => 'アカウントまたはプランが無効化されたため、接続できません。',
			'entitlementMsg.expiredTitle' => 'プランの有効期限切れ',
			'entitlementMsg.expiredText' => ({required Object date}) => 'プランは ${date} に期限切れになりました。ローカルのサブスクリプションプロファイルは削除されました。更新して再度ログインすると復元されます。',
			'devicesScreen.title' => 'デバイス管理',
			'devicesScreen.currentPlan' => '現在のプラン',
			'devicesScreen.devicesText' => ({required Object text}) => 'デバイス ${text}',
			'devicesScreen.upgradeTitle' => 'デバイス追加 / 期間延長',
			'devicesScreen.upgradeSubtitle' => 'デバイスと日数をまとめて追加。料金も支払いも1回だけ',
			'devicesScreen.addDevices' => 'デバイスを追加',
			'devicesScreen.noAddDevices' => '変更なし',
			'devicesScreen.addDevicesCount' => ({required Object n}) => '+${n} デバイス',
			'devicesScreen.addDays' => '日数を追加',
			'devicesScreen.noExtend' => '延長なし',
			'devicesScreen.addDaysCount' => ({required Object n, required Object months}) => '+${n} 日 (${months} ヶ月)',
			'devicesScreen.priceFailed' => '料金の取得に失敗しました',
			'devicesScreen.amountDue' => ({required Object amount}) => '合計 ¥${amount}',
			'devicesScreen.requote' => '再計算',
			'devicesScreen.goPay' => '今すぐ支払う',
			'devicesScreen.afterUpgrade' => 'アップグレード後: ',
			'devicesScreen.afterLimit' => ({required Object limit}) => 'デバイス上限 ${limit}',
			'devicesScreen.afterExpire' => ({required Object date}) => '${date} に期限切れ',
			'devicesScreen.pickSomething' => 'デバイスまたは日数を少なくとも1つ追加してください',
			'devicesScreen.daysOnlyUnsupported' => '管理パネルは「期間延長のみ」にまだ対応していません。「デバイスを追加」を1以上に設定して再試行してください (またはサポートに有効化をご依頼ください)。',
			'devicesScreen.paramsRejected' => 'パラメータが拒否されました。デバイス数と日数を選び直してください。',
			'devicesScreen.subscriptionExpired' => 'サブスクリプションの有効期限が切れているためアップグレードできません。先に更新するかプランをご購入ください。',
			'devicesScreen.orderIncomplete' => '注文情報が不完全です。「再計算」をタップして再試行してください。',
			'devicesScreen.orderRegenerated' => '前回の注文が期限切れになったため、同じ設定で新しい注文を作成しました。',
			'devicesScreen.payChannelIncomplete' => '注文または支払いチャネルの情報が不完全です。再計算してから再試行してください。',
			'devicesScreen.noQrCode' => 'サーバーから支払い用のQRコード / リンクが返されませんでした。別の支払い方法を選ぶか、しばらくしてから再試行してください。',
			'devicesScreen.payStartFailed' => ({required Object err}) => '支払いを開始できませんでした: ${err}',
			'devicesScreen.payCancelled' => '支払いをキャンセルしました。下書きの注文は削除されました。',
			'devicesScreen.balancePay' => '残高',
			'devicesScreen.noPayMethod' => '現在利用できる支払い方法がありません。しばらくしてから再試行するか、サポートまでお問い合わせください。',
			'devicesScreen.balanceInsufficient' => ({required Object balance, required Object amount}) => '残高が不足しています (¥${balance}、必要額 ¥${amount})。\n先にチャージしますか？',
			'devicesScreen.choosePayMethod' => '支払い方法を選択',
			'devicesScreen.balanceText' => ({required Object balance}) => '残高 ¥${balance}',
			'devicesScreen.balanceShort' => ({required Object balance}) => '残高 ¥${balance} (不足しています。チャージしてください)',
			'devicesScreen.unknownDevice' => '不明なデバイス',
			'devicesScreen.online' => '● オンライン',
			'devicesScreen.offline' => '○ オフライン',
			'devicesScreen.lastActive' => ({required Object text}) => '最終利用 ${text}',
			'devicesScreen.delete' => '削除',
			'devicesScreen.deleteConfirm' => ({required Object name}) => 'デバイス「${name}」を削除しますか？すぐに強制オフラインになります。',
			'devicesScreen.lastActiveJustNow' => 'たった今',
			'devicesScreen.lastActiveMinutes' => ({required Object minutes}) => '${minutes}分前',
			'devicesScreen.lastActiveToday' => ({required Object time}) => '今日 ${time}',
			'sysProxySheet.reading' => '読み取り中…',
			'sysProxySheet.unknown' => '不明',
			'sysProxySheet.kernelNotRunning' => 'カーネルが起動していません (先にホームタブでスイッチをオンにしてください)',
			'sysProxySheet.applied' => ({required Object host, required Object port}) => '適用済み · ${host}:${port}',
			'sysProxySheet.notSet' => ({required Object reason}) => 'システムプロキシが未設定 — ${reason}',
			'sysProxySheet.notEffective' => ({required Object port}) => '有効ではありません (${port} を指すシステムプロキシがありません)',
			'sysProxySheet.readFailed' => ({required Object err}) => '読み取りに失敗しました: ${err}',
			'sysProxySheet.setRejected' => '設定に失敗しました。システムが書き込みを拒否したか、他のプロキシアプリが上書きした可能性があります',
			'sysProxySheet.disableFailed' => 'オフにできませんでした',
			'sysProxySheet.portRange' => 'ポートは 1〜65535 の範囲で指定してください',
			'sysProxySheet.portChanged' => ({required Object value}) => 'ポートを ${value} に変更しました。カーネルが新しいポートで待ち受けるよう、一度切断して再接続してください',
			'sysProxySheet.title' => 'システムプロキシ',
			'sysProxySheet.desc' => ({required Object host}) => 'システムプロキシのアドレスは ${host} (ローカルループバック) に固定され、ポートはカーネルの混合ポートです。',
			'sysProxySheet.descWindows' => 'これは Windows の設定 → ネットワークとインターネット → プロキシに表示される内容と同じです。',
			'sysProxySheet.reset' => '再設定',
			'sysProxySheet.disable' => 'システムプロキシをオフにする',
			'sysProxySheet.diagnostics' => '診断 (UI がレジストリと同じ値を読んでいるか)',
			'sysProxySheet.mixedPort' => '混合ポート',
			'sysProxySheet.apply' => '適用',
			'logScreen.readAppFailed' => ({required Object e}) => 'アプリログの読み取りに失敗しました: ${e}',
			_ => null,
		} ?? switch (path) {
			'logScreen.readCoreFailed' => ({required Object e}) => 'カーネルログの読み取りに失敗しました: ${e}',
			'logScreen.copied' => 'コピーしました (サブスクリプションURLなどの機密情報は伏せ字にしていますが、ログファイル自体には元のアドレスが残っている場合があります)',
			'logScreen.copy' => 'コピー',
			'logScreen.refresh' => '更新',
			'logScreen.empty' => '内容がありません',
			'trayShell.closeTitle' => 'ウィンドウを閉じる',
			'trayShell.closeBody' => 'ウィンドウを閉じても Mclash はトレイに残るだけで、カーネルとシステムプロキシは動作を続け、ネットワークは接続されたままです。\n\n· OK: トレイに最小化します (完全に終了するには、トレイアイコンを右クリック → 終了)\n· キャンセル: Mclash を完全に終了し、カーネルを停止してシステムプロキシを元に戻します\n\n(選択内容は記憶されます。次回はトレイアイコンから直接操作できます)',
			'ordersScreen.title' => '注文履歴',
			'ordersScreen.orderInfoIncomplete' => '注文情報が不完全です。下に引いて更新してから再試行してください。',
			'ordersScreen.payChannelIncomplete' => '支払いチャネルの情報が不完全です。しばらくしてから再試行してください。',
			'ordersScreen.noQrPayload' => 'サーバーから支払い用のQRコードまたはリンクが返されませんでした。別の支払い方法を選ぶか、しばらくしてから再試行してください。',
			'ordersScreen.payStartFailed' => ({required Object err}) => '支払いを開始できませんでした: ${err}',
			'ordersScreen.noPayMethod' => '現在利用できる支払い方法がありません。しばらくしてから再試行するか、サポートまでお問い合わせください。',
			'ordersScreen.choosePayMethod' => '支払い方法を選択',
			'ordersScreen.amountDue' => ({required Object amount}) => 'お支払い金額 ¥${amount}',
			'ordersScreen.paidLabel' => '● 支払い済み',
			'ordersScreen.pendingLabel' => '○ 未払い',
			'ordersScreen.unknownStatus' => ({required Object status}) => '✕ ${status}',
			'ordersScreen.orderNoText' => ({required Object orderNo}) => '注文番号 ${orderNo}',
			'ordersScreen.createdAtText' => ({required Object createdAt}) => '作成日時 ${createdAt}',
			'ordersScreen.orderCanceled' => '注文をキャンセルしました',
			'ordersScreen.cancelFailed' => ({required Object err}) => 'キャンセルに失敗しました: ${err}\n(すでに支払い済みまたはキャンセル済みの場合は、下に引いて更新すると最新の状態を確認できます)',
			'ordersScreen.cancelOrder' => '注文をキャンセル',
			'ordersScreen.continuePay' => '支払いを続ける',
			'payment.balancePay' => '残高払い',
			'payment.qrPay' => 'QRコードで支払う',
			'payment.deductFromBalance' => 'アカウント残高から差し引かれます',
			'payment.openedInBrowser' => 'ブラウザで支払いページを開きました',
			'payment.scanWithAlipayWechat' => 'Alipay または WeChat でスキャン',
			'payment.orderNoText' => ({required Object orderNo}) => '注文番号 ${orderNo}',
			'payment.payFailed' => ({required Object err}) => '支払いに失敗しました: ${err}',
			'payment.notDetected' => '支払いを確認できませんでした。あとで「注文履歴」から続けられます。',
			'payment.charging' => 'チャージ中…',
			'payment.processing' => '処理中…',
			'payment.waitingPay' => '支払いを待っています…',
			'payment.openPageFailed' => '支払いページを開けませんでした。下のボタンをタップして再試行するか、QRコードをスキャンしてください。',
			'payment.reopenPayPage' => '支払いページを再度開く',
			'payment.payInBrowser' => 'ブラウザで支払う',
			'payment.openAlipay' => 'Alipay を開く',
			'payment.cancelOrder' => '注文をキャンセル',
			'payment.confirmPay' => '支払いを確定',
			'payment.retry' => '再試行',
			'payment.paidAlready' => '支払い済みです',
			'payment.channelAlipay' => 'Alipay',
			'payment.channelCodepayAlipay' => 'コード決済 · Alipay',
			'payment.channelCodepayWechat' => 'コード決済 · WeChat',
			'payment.channelCodepay' => 'コード決済',
			'payment.channelWechat' => 'WeChatペイ',
			'payment.channelUsdt' => 'USDT',
			'payment.channelUsdtTrc20' => 'USDT · TRC20',
			'payment.payFallback' => '支払い',
			'payment.errCsrf' => 'ログイン情報の有効期限が切れています (CSRFチェックに失敗)。\n「マイページ」タブで下に引いて更新するか、再度ログインしてから再試行してください。',
			'payment.errAlipayLimit' => 'Alipay の対面支払いには1回あたりの上限があり (この加盟店では ¥1000)、この注文は上限を超えています。\n「残高払い」または「コード決済」をご利用いただくか、サポートまでお問い合わせのうえ Alipay の上限を引き上げてください。',
			'payment.errNotSigned' => 'Alipay アプリが対応する支払い商品に申し込んでいないため、このチャネルは一時的に利用できません。\n「残高払い」または「コード決済」をご利用いただくか、サポートまでお問い合わせのうえ有効化してください。',
			'payment.errOrderGone' => 'この注文はキャンセル済みか期限切れです (下書き注文の有効期間は30分です)。\n「再計算」をタップして新しい注文を作成してから支払ってください。',
			'payment.errNetwork' => ({required Object err}) => 'ネットワークに接続できません: ${err}',
			'planScreen.recommended' => 'おすすめ',
			'planScreen.devices' => 'デバイス',
			'planScreen.balanceLabel' => ({required Object amount}) => '残高 ¥${amount}',
			'planScreen.balanceInsufficient' => ' (不足しています。先にチャージしてください)',
			'planScreen.total' => '合計',
			'planScreen.payNow' => '今すぐ支払う',
			'planScreen.retry' => '再試行',
			'planScreen.errIncompleteOrder' => '注文または支払いチャネルの情報が不完全なため、支払いを開始できません。',
			'planScreen.payBalance' => '残高払い',
			'planScreen.payAlipay' => 'Alipay',
			'planScreen.payWechat' => 'WeChatペイ',
			'planScreen.payCodepay' => 'コード決済',
			'planScreen.payCodepayAlipay' => 'コード決済 · Alipay',
			'planScreen.payCodepayWechat' => 'コード決済 · WeChat',
			'planScreen.payEpayAlipay' => 'Epay · Alipay',
			'planScreen.payEpayWechat' => 'Epay · WeChat',
			'planScreen.payUsdt' => 'USDT',
			'planScreen.payUsdtTrc20' => 'USDT · TRC20',
			'planScreen.payStripe' => 'Stripe',
			'planScreen.payPaypal' => 'PayPal',
			'planScreen.payOnline' => 'オンライン決済',
			'authScreen.saveAccountInfo' => 'アカウント情報を保存',
			'authScreen.autoLoginNextTime' => '次回から自動ログイン',
			'authScreen.needLoginNextTime' => '次回は再度ログインが必要です',
			'authScreen.invalidEmail' => '有効なメールアドレスを入力してください',
			'authScreen.enterEmailFirst' => '先に有効なメールアドレスを入力してください',
			'authScreen.passwordRequired' => 'パスワードを入力してください',
			'authScreen.wrongCredentials' => 'メールアドレスまたはパスワードが正しくありません',
			'authScreen.requestRejected' => 'リクエストが拒否されました。しばらくしてから再試行してください。',
			'authScreen.tooFrequent' => '試行回数が多すぎます。しばらくしてから再試行してください。',
			'authScreen.loginFailed' => 'ログインに失敗しました',
			'authScreen.username' => 'ユーザー名',
			'authScreen.confirmPassword' => 'パスワードの確認',
			'authScreen.inviteCode' => '招待コード',
			'authScreen.emailCode' => 'メール認証コード',
			'authScreen.getCode' => 'コードを取得',
			'authScreen.registerAndLogin' => '登録してログイン',
			'authScreen.usernameMinLength' => ({required Object min}) => 'ユーザー名は ${min} 文字以上で入力してください',
			'authScreen.passwordMismatch' => 'パスワードが一致しません',
			'authScreen.emailCodeRequired' => 'メール認証コードを入力してください',
			'authScreen.inviteCodeRequired' => 'このサイトの登録には招待コードが必要です',
			'authScreen.codeSentCheckEmail' => '認証コードを送信しました。メールをご確認ください。',
			'authScreen.registerSuccess' => '登録が完了しました。ログイン済みです。',
			'authScreen.passwordHint' => ({required Object min}) => '${min} 文字以上で、英字と数字の両方を含めてください',
			'authScreen.passwordTooShort' => ({required Object min}) => 'パスワードは ${min} 文字以上で入力してください',
			'authScreen.passwordNeedsLetterAndDigit' => 'パスワードには英字と数字の両方を含めてください',
			'authScreen.registeredEmail' => '登録済みのメールアドレス',
			'authScreen.newPassword' => '新しいパスワード',
			'authScreen.confirmNewPassword' => '新しいパスワードの確認',
			'authScreen.resetPassword' => 'パスワードをリセット',
			'authScreen.resetCodeSent' => 'このメールアドレスが登録済みの場合、リセットコードを送信しました (有効期限15分)。',
			'authScreen.resetSuccess' => 'パスワードをリセットしました。新しいパスワードでログインしてください。',
			'authScreen.changePasswordTitle' => 'パスワード変更',
			'authScreen.currentPassword' => '現在のパスワード',
			'authScreen.saveNewPassword' => '新しいパスワードを保存',
			'authScreen.newPasswordMismatch' => '新しいパスワードが一致しません',
			'authScreen.changePasswordSuccess' => 'パスワードを変更しました。再度ログインしてください。',
			'updatePrompt.checking' => 'アップデートを確認中…',
			'updatePrompt.checkFailed' => 'アップデートの確認に失敗しました。ネットワークを確認して再試行してください。',
			'updatePrompt.alreadyLatest' => ({required Object version}) => '最新バージョンです (${version})。',
			'updatePrompt.newVersionFound' => ({required Object version}) => '新しいバージョン ${version} があります',
			'updatePrompt.installerDownloaded' => 'インストーラのバックグラウンドダウンロードが完了しました。「今すぐ更新」をタップしてアップグレードを完了してください。',
			'updatePrompt.downloadInBackground' => '「今すぐ更新」をタップするとダウンロードとインストールを行います (アプリはそのまま利用でき、インストーラはバックグラウンドでダウンロードされます)。',
			'updatePrompt.later' => '後で',
			'updatePrompt.updateNow' => '今すぐ更新',
			'updatePrompt.installerNotReady' => ({required Object version}) => 'インストーラのダウンロードがまだ完了していません。\n\nOKをタップするとダウンロードページを開きます。お使いの環境に合ったインストーラ (バージョン ${version}) を手動でダウンロードしてください。',
			'clearData.itemLoginSession' => 'ログインセッション',
			'clearData.itemProfiles' => 'サブスクリプションプロファイル (profiles/)',
			'clearData.itemSettings' => 'アプリとカーネルの設定',
			'clearData.itemLatencyCache' => 'ノード遅延キャッシュ',
			'clearData.itemLogs' => '実行時ログ',
			'clearData.itemRoutingData' => 'ルーティングデータと一時ファイル',
			'clearData.confirmBody' => ({required Object items, required Object dir}) => 'このデバイスに保存されている以下のデータを削除します (元に戻せません):\n\n${items}\n\nアカウント自体と購入済みのプランはサーバー側にあるため影響ありません。再度ログインするとサブスクリプションが復元されます。\n\nデータディレクトリ: ${dir}\n(アプリをアンインストールする前に実行してください。そうすることで再インストール時にまっさらな状態から始まり、再度ログインが求められます)',
			'clearData.confirmAgain' => '今すぐ削除しますか？削除後は再度ログインが必要になります。',
			'clearData.clearedNotice' => ({required Object count, required Object dir}) => 'ローカルデータ ${count} 件を削除しました (ログインセッションを含むため、次回アプリを開くときに再度ログインが必要です)。\n\nアプリを削除してアンインストールを完了できます:\n· macOS: Mclash.app をゴミ箱にドラッグ (データディレクトリは空になっています: ${dir})\n· Windows: コントロールパネルから Mclash をアンインストールし、ウィザードでユーザーデータを保持するかを聞かれたら「いいえ」を選択してください',
			'clearData.clearFailed' => ({required Object error}) => '削除に失敗しました: ${error}',
			'apiError.requestFailedHttp' => ({required Object status, required Object domain}) => 'リクエストに失敗しました (HTTP ${status})。${domain} は試行済みです',
			'apiError.allDomainsFailed' => ({required Object method, required Object path, required Object count}) => 'リクエストに失敗しました: ${method} ${path} (${count} 件のドメインを試行)',
			'apiError.requestTimeout' => ({required Object seconds, required Object method, required Object path}) => 'リクエストがタイムアウトしました (${seconds}秒): ${method} ${path}',
			'apiError.networkUnreachable' => ({required Object detail}) => 'ネットワークに接続できません: ${detail}',
			'apiError.tlsHandshakeFailed' => 'TLS ハンドシェイクに失敗しました。ネットワーク接続またはシステム時刻を確認してください。',
			'apiError.connectionFailed' => ({required Object detail}) => '接続に失敗しました: ${detail}',
			'apiError.requestError' => ({required Object error}) => 'リクエストに失敗しました: ${error}',
			'apiError.responseReadTimeout' => ({required Object seconds, required Object method, required Object path}) => 'レスポンスの読み取りがタイムアウトしました (${seconds}秒): ${method} ${path}',
			'apiError.notJson' => ({required Object status, required Object snippet}) => 'レスポンスが JSON ではありません (HTTP ${status}): ${snippet}',
			'apiError.badStructure' => ({required Object status}) => '想定外のレスポンス構造です (HTTP ${status})',
			'apiError.loginFailed' => ({required Object code}) => 'ログインに失敗しました (コード ${code})',
			'apiError.loginMissingData' => 'ログインレスポンスにデータがありません',
			'apiError.loginMissingToken' => 'ログインレスポンスに access_token がありません',
			'apiError.registerFailed' => ({required Object code}) => '登録に失敗しました (コード ${code})',
			'apiError.registerMissingToken' => '登録レスポンスに access_token がありません。リスク管理が作動したか、サイトの設定が異なる可能性があります',
			'apiError.requestFailedCode' => ({required Object code}) => 'リクエストに失敗しました (コード ${code})',
			'subNotice.titleNotFound' => 'サブスクリプションが見つかりません',
			'subNotice.titleExpired' => 'サブスクリプションの有効期限切れ',
			'subNotice.titleInactive' => 'サブスクリプションが無効です',
			'subNotice.titleDeviceOverLimit' => 'デバイス上限を超えています',
			'subNotice.titleUnavailable' => 'サブスクリプションを利用できません',
			'subNotice.titleWithReason' => ({required Object emoji, required Object title, required Object reason}) => '${emoji} ${title} (${reason})',
			'subNotice.deviceUsedOfLimit' => ({required Object used, required Object limit}) => '現在のデバイス ${used}/${limit}',
			'subNotice.deviceUsedOnly' => ({required Object used}) => '現在のデバイス ${used}',
			'subNotice.expireAt' => ({required Object expire}) => '有効期限 ${expire}',
			'subNotice.supportLine' => ({required Object account}) => '💬 サポート: ${account}',
			'subNotice.siteLine' => ({required Object url}) => '📢 ウェブサイト: ${url}',
			'settingItems.subscriptionAutoUpdateInterval' => 'サブスクリプションの自動更新間隔',
			'settingItems.speedTestMode' => '速度テスト方式',
			'settingItems.speedTestModeTcp' => 'TCP 速度テスト',
			'settingItems.speedTestModeKernel' => 'カーネル速度テスト',
			'settingItems.delayTestUrlTip' => 'このノード経由で HTTP リクエスト1回にかかる時間です (ping ではありません)\n既定はプレーンな http 204 の空レスポンスです。https を使うと TLS ハンドシェイク分が加算され、値が大きくなります',
			'settingItems.systemProxy' => 'システムプロキシ',
			'settingItems.systemProxyTip' => 'アドレスとポートの確認 / 再設定',
			'settingItems.tunMode' => 'TUNモード',
			'settingItems.tunModeTip' => 'off=システムプロキシのみ / auto=TUN+システムプロキシ / force=TUNのみ\nデスクトップでは TUN に管理者権限が必要です (Windows は wintun / macOS は utun)',
			'settingItems.tunOverwriteTip' => 'overwrite\nオン = このページの TUN 設定がプロファイルの tun セクションを上書きします\nオフ = プロファイル自身の tun 設定を使用します (アプリは干渉しません)',
			'settingItems.tunEnableByTunMode' => ({required Object enable}) => '${enable} (TUNモードにより決定)',
			'settingItems.interval30Minutes' => '30分',
			'settingItems.interval1Hour' => '1時間',
			'settingItems.interval6Hours' => '6時間',
			'settingItems.interval12Hours' => '12時間',
			'settingItems.interval24Hours' => '24時間',
			'settingItems.interval3Days' => '3日',
			'settingItems.interval7Days' => '7日',
			'settingItems.intervalNever' => 'なし',
			'settingItems.intervalMinutes' => ({required Object minutes}) => '${minutes}分',
			'settingItems.intervalHours' => ({required Object hours}) => '${hours}時間',
			'settingItems.intervalDays' => ({required Object days}) => '${days}日',
			'tunScreen.modeOff' => 'オフ',
			'tunScreen.modeAuto' => '自動',
			'tunScreen.modeForce' => '強制',
			'tunScreen.modeOffDesc' => 'システムプロキシのみ: システムプロキシに従うプログラム (ブラウザなど) では有効ですが、UDP / ゲームはプロキシされません',
			'tunScreen.modeAutoDesc' => 'TUN + システムプロキシ (併用): UDP を含むすべての通信が仮想アダプターを経由します',
			'tunScreen.modeForceDesc' => 'TUNのみ: すべての通信が仮想アダプターを経由し、システムプロキシには触れません',
			'tunScreen.modeOffOptionDesc' => 'システムのルーティングテーブルには触れず、システムに 127.0.0.1 のプロキシを設定するだけです。システムプロキシに従うプログラムのみが利用し、UDP 通信や独自のプロキシ設定を持つプログラムは利用しません。',
			'tunScreen.modeAutoOptionDesc' => '仮想アダプターを作成し、すべての通信 (UDP やゲームを含む) を引き受けます。システムプロキシはフォールバックとして維持されます。推奨: 全体的に機能し、権限が不足していてもネットワークが使えなくなりません。',
			'tunScreen.modeForceOptionDesc' => '仮想アダプターのみを使用し、システムプロキシは変更しません。すべての通信 (UDP を含む) がトンネルを経由し、システムの「プロキシ」設定はそのまま残ります。',
			'tunScreen.adminRequiredDialog' => 'TUN仮想アダプターには管理者権限が必要です (Windows は wintun / macOS は utun)。\n\n現在 Mclash は管理者として実行されていないため、有効にしても TUN は反映されません (「自動」モードではシステムプロキシがフォールバックとして機能するため、ネットワークは利用できます)。\n\nOK = 今すぐ管理者として Mclash を再起動します (UAC の確認が表示されます)\nキャンセル = この選択を保存します (TUN が利用できない場合は自動的にシステムプロキシを使用します)',
			'tunScreen.relaunchFailed' => ({required Object message}) => '再起動に失敗しました: ${message}',
			'tunScreen.switchFailed' => ({required Object message}) => 'TUNモードの切り替えに失敗しました: ${message}\n以前の設定に戻しました。',
			'tunScreen.setOffSnack' => '「オフ」に設定しました: システムプロキシのみ',
			'tunScreen.setModeSnack' => ({required Object mode, required Object effect}) => '「${mode}」に設定しました。${effect}',
			'tunScreen.effectReconnected' => '再接続済みで有効です',
			'tunScreen.effectAfterConnect' => '接続後に有効になります',
			'tunScreen.sheetTitle' => 'TUN仮想アダプター',
			'tunScreen.advancedTitle' => '詳細パラメータ (コア設定 → TUN)',
			'tunScreen.advancedSubtitle' => 'アダプターアドレス / スタック / MTU / 自動ルート / DNSハイジャック / 上書き',
			'tunScreen.adminOk' => 'TUN には管理者権限が必要です。現在の権限で十分です (Windows は管理者として実行 / macOS は root で実行)',
			'tunScreen.adminMissing' => 'TUN には管理者権限が必要です: Mclash が管理者として実行されていないため、「自動 / 強制」を選んでも TUN は反映されません (「自動」ではシステムプロキシにフォールバックするため、ネットワークは利用できます)',
			_ => null,
		};
	}
}
