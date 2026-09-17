// ignore_for_file: prefer_interpolation_to_compose_strings, use_build_context_synchronously, empty_catches, unused_catch_stack

import 'dart:async';
import 'dart:io';

import 'package:after_layout/after_layout.dart';
import 'package:mclash/app/local_services/vpn_service.dart';
import 'package:mclash/app/modules/auto_update_manager.dart';
import 'package:mclash/app/modules/biz.dart';
import 'package:mclash/app/modules/remote_config_manager.dart';
import 'package:mclash/app/utils/error_reporter_utils.dart';
import 'package:mclash/app/utils/local_storage.dart';
import 'package:mclash/app/utils/log.dart';
import 'package:mclash/app/utils/system_scheme_utils.dart';
import 'package:mclash/i18n/strings.g.dart';
import 'package:mclash/mf/mclash_account_service.dart';
import 'package:mclash/screens/dialog_utils.dart';
import 'package:mclash/screens/home_mclash_widgets.dart';
import 'package:mclash/screens/home_screen_widgets.dart';
import 'package:mclash/screens/language_settings_screen.dart';
import 'package:mclash/screens/scheme_handler.dart';
import 'package:mclash/screens/mclash_update_prompt.dart';
import 'package:mclash/screens/themes.dart';
import 'package:mclash/screens/user_agreement_screen.dart';
import 'package:mclash/screens/webview_helper.dart';
import 'package:mclash/screens/widgets/framework.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:libclash_vpn_service/state.dart';
import 'package:protocol_handler/protocol_handler.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

class HomeScreen extends LasyRenderingStatefulWidget {
  static RouteSettings routeSettings() {
    return const RouteSettings(name: "/");
  }

  final String launchUrl;
  const HomeScreen({super.key, required this.launchUrl});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends LasyRenderingState<HomeScreen>
    with WidgetsBindingObserver, ProtocolListener, AfterLayoutMixin {
  static const String userAgreementAgreedIdKey = 'userAgreementAgreedKey';

  bool _onInitAllFinished = false;
  String _initUrl = "";

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    protocolHandler.addListener(this);
    Biz.onEventSingletonInstance = (String url) {
      Log.w("onEventSingletonInstance: $url");
      if (!mounted) {
        return;
      }
      SchemeHandler.handle(context, url);
    };
    _initUrl = widget.launchUrl;
    _init();
  }

  @override
  FutureOr<void> afterFirstLayout(BuildContext context) async {
    Biz.initHomeFinish();
    ErrorReporterUtils.register(() {
      if (!mounted) {
        return;
      }
      final tcontext = Translations.of(context);
      DialogUtils.showAlertDialog(
        context,
        tcontext.meta.deviceNoSpace,
        showCopy: true,
        showFAQ: true,
        withVersion: true,
      );
    });

    Future.delayed(const Duration(seconds: 0), () async {
      showAgreement();
    });

    Future.delayed(const Duration(seconds: 0), () async {
      if (Platform.isMacOS) {
        await hotKeyManager.unregisterAll();
        HotKey hotKey = HotKey(
          key: PhysicalKeyboardKey.keyW,
          modifiers: [HotKeyModifier.meta],
          scope: HotKeyScope.inapp,
        );
        await hotKeyManager.register(
          hotKey,
          keyDownHandler: (hotKey) {
            windowManager.hide();
          },
        );
      }
    });
  }

  Future<bool> futureBool(bool value) async {
    return value;
  }

  void showAgreement() async {
    String? agreement;
    try {
      if (Platform.isMacOS) {
        agreement = await LocalStorage.read(userAgreementAgreedIdKey);
      } else {
        agreement = "true";
      }
    } catch (e) {}

    if (agreement != null) {

      return;
    }
    if (Platform.isMacOS) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          settings: UserAgreementScreen.routeSettings(),
          fullscreenDialog: true,
          builder: (context) => const UserAgreementScreen(),
        ),
      );
      LocalStorage.write(userAgreementAgreedIdKey, "true");
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        settings: LanguageSettingsScreen.routeSettings(),
        fullscreenDialog: true,
        builder: (context) => LanguageSettingsScreen(
          canPop: false,
          canGoBack: false,
          nextText: () {
            var tcontext = Translations.of(context);
            return tcontext.meta.done;
          },
        ),
      ),
    );
  }

  void _init() async {
    Biz.onEventInitAllFinish.add(() async {
      await _onInitAllFinish();
    });
  }

  /// 检查更新回调（dispose 时必须移除，否则每次重建主界面都会多挂一个）。
  void _onUpdateChecked() {
    if (!mounted) {
      return;
    }
    setState(() {});
    // 有新版本时提示一次（同一版本用户点过「稍后」就不再打扰）
    MclashUpdatePrompt.maybePromptOnLaunch(context);
  }

  Future<void> _onInitAllFinish() async {
    if (!mounted) {
      return;
    }
    AutoUpdateManager.addCheckListener(_onUpdateChecked);
    DialogUtils.faqCallback = (BuildContext context, String text) async {
      final tcontext = Translations.of(context);
      var remoteConfig = RemoteConfigManager.getConfig();
      await WebviewHelper.loadUrl(
        context,
        remoteConfig.faq,
        "faqCallback",
        title: tcontext.meta.faq,
      );
    };
    VPNService.onEventStateChanged.add(_onStateChanged);

    if (Platform.isWindows) {
      final clashRegisterErr = await SystemSchemeUtils.register(
        SystemSchemeUtils.getClashScheme(),
      );
      if (clashRegisterErr != null) {
        Log.w("register clash scheme failed: $clashRegisterErr");
      }

      final clashMiRegisterErr = await SystemSchemeUtils.register(
        SystemSchemeUtils.getClashMiScheme(),
      );
      if (clashMiRegisterErr != null) {
        Log.w("register mclash scheme failed: $clashMiRegisterErr");
      }
    }

    _onInitAllFinished = true;

    setState(() {});

    if (_initUrl.isNotEmpty) {
      await SchemeHandler.handle(context, _initUrl);
      _initUrl = "";
    }

    setState(() {});
  }

  Future<void> _onStateChanged(
    FlutterVpnServiceState state,
    Map<String, String> params,
  ) async {
    if (!mounted) {
      return;
    }
    // 只有「连上 / 断开」需要通知外部（托盘图标、桌面小组件）；
    // 中间态（connecting / reasserting / disconnecting）界面自己会画转圈，
    // 以前那些空 else-if 分支只是噪音。
    if (state == FlutterVpnServiceState.connected) {
      Biz.vpnStateChanged(true);
    } else if (state == FlutterVpnServiceState.disconnected) {
      Biz.vpnStateChanged(false);
    }
    setState(() {});
  }

  @override
  void onProtocolUrlReceived(String url) {
    Log.i("onProtocolUrlReceived: $url");
    if (!mounted) {
      return;
    }
    if (!_onInitAllFinished) {
      _initUrl = url;
      return;
    }
    SchemeHandler.handle(context, url);
  }

  @override
  void dispose() {
    AutoUpdateManager.removeCheckListener(_onUpdateChecked);
    VPNService.onEventStateChanged.remove(_onStateChanged);
    protocolHandler.removeListener(this);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var themes = Provider.of<Themes>(context, listen: false);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.zero,
        child: AppBar(
          systemOverlayStyle: SystemUiOverlayStyle(
            systemNavigationBarIconBrightness: themes
                .getStatusBarIconBrightness(context),
            systemNavigationBarColor: Colors.transparent,
            systemNavigationBarDividerColor: Colors.transparent,
            statusBarBrightness: themes.getStatusBarBrightness(context),
            statusBarIconBrightness: themes.getStatusBarIconBrightness(context),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [

            // 顶栏：标志缩小靠左上，到期/设备信息条在标志右侧（连接卡**上方**）。
            // 以前是 18px 居中大标题 + 一整行副标题，把订阅信息挤到连接卡下方，
            // 用户要滚动/找才能看到「到期时间、设备数」。
            const MclashHomeHeader(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 15, 20, 0),
                child: SingleChildScrollView(
                  child: AnimatedBuilder(
                    animation: MclashAccountService.instance,
                    builder: (context, _) {
                      final blocked = MclashAccountService.instance.isBlocked;
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [

                          if (blocked) ...[
                            const MclashSubscriptionCard(
                              key: ValueKey('home-sub-bar'),
                            ),
                            const SizedBox(height: 12),
                          ],
                          HomeScreenWidgetPart1(
                            key: const ValueKey('home-connect-card'),
                          ),
                          const SizedBox(height: 12),
                          const MclashQuickCountries(
                            key: ValueKey('home-quick-countries'),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
