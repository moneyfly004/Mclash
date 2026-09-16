import 'dart:async';
import 'dart:io';

import 'package:mclash/app/clash/clash_config.dart';
import 'package:mclash/app/clash/clash_http_api.dart';
import 'package:mclash/app/local_services/vpn_service.dart';
import 'package:mclash/app/modules/biz.dart';
import 'package:mclash/app/modules/clash_setting_manager.dart';
import 'package:mclash/app/modules/profile_manager.dart';
import 'package:mclash/app/modules/setting_manager.dart';
import 'package:mclash/app/modules/zashboard.dart';
import 'package:mclash/app/utils/app_lifecycle_state_notify.dart';
import 'package:mclash/app/utils/app_scheme_actions.dart';
import 'package:mclash/app/utils/log.dart';
import 'package:mclash/app/utils/move_to_background_utils.dart';
import 'package:mclash/app/utils/platform_utils.dart';
import 'package:mclash/app/utils/vpn_action_handler.dart';
import 'package:mclash/i18n/strings.g.dart';
import 'package:mclash/screens/dialog_utils.dart';
import 'package:mclash/screens/theme_config.dart';
import 'package:mclash/mf/mclash_account_service.dart';
import 'package:mclash/mf/mclash_subscription_service.dart';
import 'package:mclash/mf/clash_traffic_watcher.dart';
import 'package:mclash/mf/mclash_mode_selection.dart';
import 'package:mclash/mf/mclash_nodes_store.dart';
import 'package:mclash/screens/home_mclash_widgets.dart';
import 'package:mclash/screens/mclash_mode_action.dart';
import 'package:mclash/screens/mclash_node_picker_sheet.dart';
import 'package:mclash/screens/mclash_system_proxy_sheet.dart';
import 'package:mclash/screens/theme_define.dart';
import 'package:mclash/screens/widgets/segmented_elevated_button.dart';
import 'package:flutter/material.dart';
import 'package:libclash_vpn_service/state.dart';
import 'package:quick_actions/quick_actions.dart';

class ProxyHttpOverrides extends HttpOverrides {
  ProxyHttpOverrides(this.proxyPort);

  final int proxyPort;

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = super.createHttpClient(context);
    client.findProxy = (Uri uri) => "PROXY 127.0.0.1:$proxyPort";
    return client;
  }
}

class HomeScreenWidgetPart1 extends StatefulWidget {
  const HomeScreenWidgetPart1({super.key});

  @override
  State<HomeScreenWidgetPart1> createState() => _HomeScreenWidgetPart1();
}

class _HomeScreenWidgetPart1 extends State<HomeScreenWidgetPart1> {

  static final String _kNoSpeed = "↑ 0 B/s   ↓ 0 B/s";
  static final String _kNoTrafficTotal = "↑ 0 B   ↓ 0 B";

  final FocusNode _focusNodeConnect = FocusNode();
  FlutterVpnServiceState _state = FlutterVpnServiceState.disconnected;

  DateTime? _connectedAt;
  Timer? _timerStateChecker;
  Timer? _timerConnectToCore;
  QuickActions? _quickActions;
  bool _quickActionWorking = false;

  final ValueNotifier<String> _trafficSpeed = ValueNotifier<String>(_kNoSpeed);
  final ValueNotifier<String> _trafficTotal = ValueNotifier<String>(
    _kNoTrafficTotal,
  );
  final ValueNotifier<String> _proxyNow = ValueNotifier<String>("");

  /// 当前「怎么走的代理」：系统代理已生效 / 未生效 / TUN。
  ///
  /// 用户反馈「连上之后系统代理没变，也不知道 App 到底怎么代理的」。
  /// 光靠日志解释不了，首页必须**直接显示**出来，并且点一下就能去修。
  final ValueNotifier<String> _proxyMode = ValueNotifier<String>("");
  Timer? _timerProxyMode;
  int _trafficLogTick = 0;
  bool _proxyNowUpdating = false;

  @override
  void initState() {
    super.initState();
    VPNService.onEventStateChanged.add(_onStateChanged);

    MclashAccountService.instance.addListener(_onAccountChanged);
    AppLifecycleStateNofity.onStateResumed(hashCode, _onStateResumed);
    AppLifecycleStateNofity.onStatePaused(hashCode, _onStatePaused);
    ProfileManager.onEventCurrentChanged.add(_onCurrentChanged);
    ProfileManager.onEventUpdate.add(_onUpdate);
    if (!AppLifecycleStateNofity.isPaused()) {
      _onStateResumed();
    }
    Biz.onEventInitAllFinish.add(() async {
      if (Platform.isAndroid) {
        if (SettingManager.getConfig().excludeFromRecent) {
          FlutterVpnService.setExcludeFromRecents(true);
        }
      }
      await _onInitAllFinish();
    });
    ClashSettingManager.onEventModeChanged.add(() async {
      setState(() {});
    });
  }

  @override
  void dispose() {
    // 这两个定时器必须在这里取消：周期性状态检查（2s）会一直跑下去并持有
    // 已销毁的 State（测试里直接暴露成 "Pending timers"）。
    _timerStateChecker?.cancel();
    _timerStateChecker = null;
    _timerConnectToCore?.cancel();
    _timerConnectToCore = null;
    _stopProxyModeTimer();
    _proxyMode.dispose();
    _trafficSpeed.dispose();
    _trafficTotal.dispose();
    _proxyNow.dispose();
    VPNService.onEventStateChanged.remove(_onStateChanged);
    AppLifecycleStateNofity.onStateResumed(hashCode, null);
    AppLifecycleStateNofity.onStatePaused(hashCode, null);
    ProfileManager.onEventCurrentChanged.remove(_onCurrentChanged);
    ProfileManager.onEventUpdate.remove(_onUpdate);
    _focusNodeConnect.dispose();
    MclashAccountService.instance.removeListener(_onAccountChanged);
    super.dispose();
  }

  void initQuickAction() async {
    if (!Platform.isAndroid) {
      return;
    }
    String connect = AppSchemeActions.connectAction();
    String disconnect = AppSchemeActions.disconnectAction();
    try {
      _quickActions ??= QuickActions();
      await _quickActions!.initialize((String shortcutType) async {
        if (_quickActionWorking) {
          return;
        }
        _quickActionWorking = true;
        var state = await VPNService.getState();
        if (shortcutType == connect) {
          if (state != FlutterVpnServiceState.invalid &&
              state != FlutterVpnServiceState.disconnected) {
            MoveToBackgroundUtils.moveToBackground(
              duration: const Duration(milliseconds: 300),
            );
            _quickActionWorking = false;
            return;
          }

          bool ok = await start("quickAction");
          if (ok) {
            MoveToBackgroundUtils.moveToBackground(
              duration: const Duration(milliseconds: 300),
            );
          }
        } else if (shortcutType == disconnect) {
          if (state == FlutterVpnServiceState.connected) {
            await stop();
          }
          MoveToBackgroundUtils.moveToBackground(
            duration: const Duration(milliseconds: 300),
          );
        }
        _quickActionWorking = false;
      });

      await _quickActions!.setShortcutItems(<ShortcutItem>[
        ShortcutItem(type: connect, localizedTitle: 'ON', icon: 'ic_launcher'),
        ShortcutItem(
          type: disconnect,
          localizedTitle: 'OFF',
          icon: 'ic_launcher',
        ),
      ]);
    } catch (err, stacktrace) {
      Log.w("initQuickAction exception ${err.toString()}");
    }
  }

  @override
  Widget build(BuildContext context) {
    final tcontext = Translations.of(context);
    bool connected = _state == FlutterVpnServiceState.connected;
    final connecting = _state == FlutterVpnServiceState.connecting ||
        _state == FlutterVpnServiceState.reasserting;
    final disconnecting = _state == FlutterVpnServiceState.disconnecting;

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Row(
              children: [
                // 连接中/断开中显示转圈动画：以前连接过程没有任何反馈，
                // 用户点完开关看不出"正在连"，会以为没反应。
                connecting || disconnecting
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: RepaintBoundary(
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: ThemeDefine.kColorGreenBright,
                          ),
                        ),
                      )
                    : Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: connected ? Colors.green : Colors.grey,
                          shape: BoxShape.circle,
                        ),
                      ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _stateText(context, connected),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: ThemeConfig.kFontWeightTitle,
                        ),
                      ),
                      Text(
                        connecting
                            ? "正在连接…"
                            : (disconnecting
                                  ? "正在断开…"
                                  : (connected ? "点击开关断开" : "点击开关连接")),
                        style: const TextStyle(
                          fontSize: 12,
                          color: ThemeDefine.kColorGrey,
                        ),
                      ),
                    ],
                  ),
                ),

                Transform.scale(
                  scale: 1.15,
                  child: Switch.adaptive(
                    value: _state == FlutterVpnServiceState.connected,
                    activeThumbColor: Colors.white,
                    activeTrackColor: ThemeDefine.kColorGreenBright,
                    onChanged: MclashAccountService.instance.isBlocked
                        ? null
                        : (bool value) async {
                            if (value &&
                                !(await mclashCheckAccountGate(context))) {
                              return;
                            }
                            if (value) {
                              await start("switch");
                            } else {
                              await stop();
                            }
                          },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 节点切换入口。
            //
            // 用户反馈：「连接按钮下方的节点切换不够明显」。旧样子是一行灰字 +
            // 一个灰色箭头，看着像静态文本，没人知道能点。现在做成**明确的按钮行**：
            //   * 左侧「当前节点」小标题 + 节点名（可换行省略）；
            //   * 右侧一个实心「切换」按钮（图标 + 文字），颜色与连接状态呼应；
            //   * 整行可点，且带边框/底色，一眼看出是可操作控件。
            InkWell(
              key: const ValueKey("home-node-row"),
              borderRadius: BorderRadius.circular(10),
              onTap: () => showMclashNodePickerSheet(
                context,
                current: _proxyNow.value,
              ),
              child: Container(
                padding: const EdgeInsets.fromLTRB(12, 8, 10, 8),
                decoration: BoxDecoration(
                  color: ThemeDefine.kColorBlue.withValues(alpha: 0.06),
                  border: Border.all(
                    color: ThemeDefine.kColorBlue.withValues(alpha: 0.35),
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.dns_outlined,
                      size: 18,
                      color: connected
                          ? ThemeDefine.kColorBlue
                          : ThemeDefine.kColorGrey,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            "当前节点",
                            style: TextStyle(
                              fontSize: 11,
                              color: ThemeDefine.kColorGrey,
                            ),
                          ),
                          const SizedBox(height: 2),
                          ValueListenableBuilder<String>(
                            valueListenable: _proxyNow,
                            builder: (context, value, _) => Text(
                              value.isEmpty ? "未选择节点" : value,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: ThemeConfig.kFontWeightListItem,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // 明确的「切换」按钮：以前只有一个灰箭头，用户不知道能点
                    Container(
                      key: const ValueKey("home-node-switch-button"),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: ThemeDefine.kColorBlue,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.swap_horiz, size: 14, color: Colors.white),
                          SizedBox(width: 4),
                          Text(
                            "切换",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 4),

            if (connected)
              AnimatedBuilder(
                animation: MclashNodesStore.instance,
                builder: (context, _) {
                  final note = MclashNodesStore.instance.autoPickNote;
                  if (note.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.auto_awesome,
                          size: 14,
                          color: ThemeDefine.kColorBlue,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            note,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: ThemeDefine.kColorBlue,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            if (connected) ...[
              const SizedBox(height: 12),

              ValueListenableBuilder<String>(
                valueListenable: _trafficSpeed,
                builder: (context, v, _) => _trafficLine("实时速度", v),
              ),
              const SizedBox(height: 4),
              ValueListenableBuilder<String>(
                valueListenable: _trafficTotal,
                builder: (context, v, _) => _trafficLine("累计流量", v),
              ),
              const SizedBox(height: 6),
              // 「到底怎么走的代理」——直接写在首页，别让用户猜
              ValueListenableBuilder<String>(
                valueListenable: _proxyMode,
                builder: (context, v, _) => v.isEmpty
                    ? const SizedBox.shrink()
                    : InkWell(
                        onTap: () =>
                            showMclashSystemProxySheet(context).then((_) {
                              if (mounted) {
                                unawaited(_updateProxyMode());
                              }
                            }),
                        child: Row(
                          children: [
                            Icon(
                              v.contains("已生效")
                                  ? Icons.verified_user_outlined
                                  : Icons.info_outline,
                              size: 14,
                              color: v.contains("已生效")
                                  ? ThemeDefine.kColorGreenBright
                                  : ThemeDefine.kColorGrey,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                v,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: ThemeDefine.kColorGrey,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ],
            const Divider(height: 22, thickness: 0.3),
            SegmentedElevatedButton(
              segments: [
                SegemntedElevatedButtonItem(
                  value: ClashConfigsMode.rule.index,
                  text: tcontext.meta.rule,
                ),
                SegemntedElevatedButtonItem(
                  value: ClashConfigsMode.global.index,
                  text: tcontext.meta.global,
                ),
                SegemntedElevatedButtonItem(
                  value: ClashConfigsMode.direct.index,
                  text: tcontext.meta.direct,
                ),
              ],
              selected: ClashSettingManager.getConfigsMode().index,
              padding: const EdgeInsets.fromLTRB(0, 3, 0, 3),
              onPressed: (int value) async {
                ClashConfigsMode type = ClashConfigsMode.values[value];
                var error = await mclashSetMode(type);
                if (!context.mounted) {
                  return;
                }
                if (error != null) {
                  DialogUtils.showAlertDialog(
                    context,
                    error.message,
                    withVersion: true,
                  );
                  return;
                }
                _updateProxyNow();
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  String _stateText(BuildContext context, bool connected) {
    final tcontext = Translations.of(context);
    if (_state == FlutterVpnServiceState.connecting) {
      return tcontext.meta.connecting;
    }
    if (!connected) {
      return tcontext.meta.disconnected;
    }
    final secs = _connectedSeconds();
    final h = secs ~/ 3600;
    final m = (secs % 3600) ~/ 60;
    final s = secs % 60;
    String two(int v) => v.toString().padLeft(2, "0");
    return h > 0 ? "$h:${two(m)}:${two(s)}" : "${two(m)}:${two(s)}";
  }

  int _connectedSeconds() {
    final start = _connectedAt;
    if (start == null) {
      return 0;
    }
    return DateTime.now().difference(start).inSeconds;
  }

  Widget _trafficLine(String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: ThemeDefine.kColorGrey),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            value.isEmpty ? "-" : value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 13),
          ),
        ),
      ],
    );
  }

  Future<void> _onInitAllFinish() async {

    MclashNodesStore.instance.onNodeSwitched = _updateProxyNow;
    VpnActionHandler.vpnConnect = _vpnConnect;
    VpnActionHandler.vpnDisconnect = _vpnDisconnect;
    VpnActionHandler.vpnReconnect = _vpnReconnect;
    initQuickAction();
    if (PlatformUtils.isPC()) {
      if (SettingManager.getConfig().autoConnectAfterLaunch) {
        await start("launch");
      }
    }
  }

  Future<void> stop() async {
    await VPNService.stop();
  }

  Future<bool> start(String from) async {
    // 每一处连接入口都先过账户门禁：托盘菜单、快捷键、桌面小组件都会直接调到这里，
    // 只在开关的 onChanged 里判断会漏（用户会用托盘连接）。
    if (!await mclashCheckAccountGate(context)) {
      return false;
    }
    if (ProfileManager.getCurrent() == null) {
      // 还没有配置档（首次登录 / 刚安装 / 启动时还没加载完）→ 先同步再**继续连接**。
      //
      // 用户反馈的「我已经点了连接，它却让我再点一次」就是这里：旧实现在同步成功后
      // 只弹一句「订阅已同步，请再次点击连接。」然后 return —— 用户点了一次开关却
      // 什么都没发生，只能再点第二次。既然用户已经表达了「我要连」，同步完就接着连。
      if (!mounted) {
        return false;
      }
      MclashSubSyncResult? result;
      try {
        result = await MclashSubscriptionService.sync();
      } catch (_) {}
      await MclashAccountService.instance.refresh();
      if (!mounted) {
        return false;
      }
      setState(() {});
      // 同步期间列表可能还在加载：再等一小会儿，别把「刚好没加载完」当成失败
      for (var i = 0;
          i < 10 && result?.status == MclashSubSyncStatus.ok &&
              ProfileManager.getCurrent() == null;
          i++) {
        await Future<void>.delayed(const Duration(milliseconds: 200));
      }
      if (!mounted) {
        return false;
      }
      if (ProfileManager.getCurrent() == null) {
        final msg = switch (result?.status) {
          MclashSubSyncStatus.ok => "订阅已下载，但配置档还没就绪，请稍后再试。",
          MclashSubSyncStatus.noSubscription => "该账号暂无可用套餐，请先购买套餐。",
          MclashSubSyncStatus.notLoggedIn => "登录已失效，请重新登录。",
          MclashSubSyncStatus.skipped => "正在同步订阅，请稍候再试。",
          MclashSubSyncStatus.failed =>
            "订阅同步失败：${result?.message ?? ""}\n请检查网络后重试。",
          null => "订阅同步失败，请稍后重试。",
        };
        await DialogUtils.showAlertDialog(context, msg, withVersion: true);
        return false;
      }
      Log.i("VPNService: 连接前已同步订阅并拿到配置档，直接继续连接（不需要用户再点一次）");
    }
    var state = await VPNService.getState();
    if (state == FlutterVpnServiceState.connecting ||
        state == FlutterVpnServiceState.disconnecting ||
        state == FlutterVpnServiceState.reasserting) {
      setState(() {});
      return false;
    }

    var err = await VPNService.start(const Duration(seconds: 60));
    if (!mounted) {
      return false;
    }
    setState(() {});
    if (err != null) {
      if (err.message == "willCompleteAfterRebootInstall") {
        err.message = t.meta.willCompleteAfterRebootInstall;
      } else if (err.message == "requestNeedsUserApproval") {
        err.message = t.meta.requestNeedsUserApproval;
      } else if (err.message.contains("FullDiskAccessPermissionRequired")) {
        err.message = t.meta.FullDiskAccessPermissionRequired;
      } else if (err.message.contains(
        "configure tun interface: Access is denied",
      )) {
        err.message += "\n${t.meta.tunModeRunAsAdmin}";
      }

      DialogUtils.showAlertDialog(context, err.message, withVersion: true);
      return false;
    }
    return true;
  }

  Future<void> _vpnConnect(String from, bool background) async {
    Future.delayed(const Duration(seconds: 0), () async {
      bool ok = await start(from);
      if (ok) {
        if (background) {
          MoveToBackgroundUtils.moveToBackground(
            duration: const Duration(milliseconds: 300),
          );
        }
      }
    });
  }

  Future<void> _vpnDisconnect(String from, bool background) async {
    Future.delayed(const Duration(seconds: 0), () async {
      await stop();
      if (background) {
        MoveToBackgroundUtils.moveToBackground(
          duration: const Duration(milliseconds: 300),
        );
      }
    });
  }

  Future<void> _vpnReconnect(String from, bool background) async {
    Future.delayed(const Duration(seconds: 0), () async {
      await stop();
      bool ok = await start(from);
      if (ok) {
        if (background) {
          MoveToBackgroundUtils.moveToBackground(
            duration: const Duration(milliseconds: 300),
          );
        }
      }
    });
  }

  Future<void> _onStateChanged(
    FlutterVpnServiceState state,
    Map<String, String> params,
  ) async {
    if (_state == state) {
      return;
    }
    _state = state;
    if (state == FlutterVpnServiceState.connected) {
      _connectedAt ??= DateTime.now();
    } else if (state == FlutterVpnServiceState.disconnected) {
      _connectedAt = null;
    }
    if (state == FlutterVpnServiceState.disconnected) {
      _disconnectToCore();
      Biz.vpnStateChanged(false);
    } else if (state == FlutterVpnServiceState.connecting) {
    } else if (state == FlutterVpnServiceState.connected) {
      if (!AppLifecycleStateNofity.isPaused()) {
        _connectToCore();
      }
      Biz.vpnStateChanged(true);
    } else if (state == FlutterVpnServiceState.reasserting) {
      _disconnectToCore();
    } else if (state == FlutterVpnServiceState.disconnecting) {
      _stopStateCheckTimer();
      Zashboard.stop();
    } else {
      _disconnectToCore();
      Biz.vpnStateChanged(false);
    }
    if (!mounted) {
      return;
    }
    setState(() {});
  }

  Future<void> _onStateResumed() async {
    _checkState();
    _startStateCheckTimer();
    _connectToCore();

    _updateProxyNow();
  }

  Future<void> _onStatePaused() async {
    _stopStateCheckTimer();
    if (Platform.isMacOS && SettingManager.getConfig().showTrayTraffic) {
      return;
    }
    _disconnectToCore(resetUI: false);
  }

  void _onAccountChanged() {
    if (!mounted) {
      return;
    }
    setState(() {});
  }

  Future<void> _onCurrentChanged(String id) async {
    if (id.isEmpty) {
      await VPNService.stop();
      return;
    }

    final err = await VPNService.restart(const Duration(seconds: 60));
    if (err != null) {
      if (!mounted) {
        return;
      }
      DialogUtils.showAlertDialog(context, err.message, withVersion: true);
    }
  }

  Future<void> _onUpdate(String id, bool finish) async {
    setState(() {});
  }

  Future<void> _checkState() async {
    var state = await VPNService.getState();
    await _onStateChanged(state, {});
  }

  void _startStateCheckTimer() {
    // 2 秒一次：连接/断开状态的主通道是**内核与原生侧推过来的事件**
    // （VPNService.onEventStateChanged / 原生 notifyState），这个定时器只是
    // 兜底对账。1 秒一次纯属多余唤醒（手机上是实打实的耗电），2 秒足够。
    const Duration duration = Duration(seconds: 2);
    _timerStateChecker ??= Timer.periodic(duration, (timer) async {
      if (!Platform.isMacOS) {
        if (AppLifecycleStateNofity.isPaused()) {
          return;
        }
      }
      await _checkState();
    });
  }

  void _stopStateCheckTimer() {
    if (!Platform.isMacOS) {
      _timerStateChecker?.cancel();
      _timerStateChecker = null;
    }
  }

  /// 刷新首页的「实时速度 / 累计流量」。
  ///
  /// 数据来源是 [ClashTrafficWatcher]（内核 `/traffic` 的 WebSocket 推送）。
  /// 旧实现每秒发一次普通 GET 再 `jsonDecode` 整段响应 —— 而 `/traffic` 推的是
  /// **多行 JSON 流**，解析必然抛异常并被吞掉，于是这两行永远停在 0
  /// （用户反馈的「上传/下载、总流量没有任何变化」就是这个）。
  Future<void> _updateConnections() async {
    final traffic = ClashTrafficWatcher.instance;
    final speed =
        "↑ ${ClashHttpApi.convertTrafficToStringDouble(traffic.upload.value)}/s"
        "  ↓ ${ClashHttpApi.convertTrafficToStringDouble(traffic.download.value)}/s";
    final total =
        "↑ ${ClashHttpApi.convertTrafficToStringDouble(traffic.uploadTotal.value)}"
        "  ↓ ${ClashHttpApi.convertTrafficToStringDouble(traffic.downloadTotal.value)}";
    Biz.trafficChanged(total, speed);
    if (AppLifecycleStateNofity.isPaused()) {
      return;
    }
    _trafficTotal.value = total;
    _trafficSpeed.value = speed;

    // 每 ~10 秒留一条流量日志：用户反馈「流量不动」时，日志里能直接看出
    // 是「内核没推数据」还是「界面没刷新」，不用再靠猜。
    _trafficLogTick++;
    if (_trafficLogTick % 10 == 0) {
      Log.i(
        "流量: 速度 ${traffic.upload.value}/${traffic.download.value} B/s "
        "累计 ${traffic.uploadTotal.value}/${traffic.downloadTotal.value} B "
        "（流量流已连接=${traffic.connected}）",
      );
    }
  }

  /// 判断并显示当前数据通路，直接回答「我到底是怎么被代理的」。
  ///
  /// 两种可能：
  ///   * **TUN 模式**：内核创建虚拟网卡接管全部流量，此时**不需要**系统代理，
  ///     Windows 的「设置 → 代理」保持原样是正常的（用户反馈的
  ///     「系统代理没改却可以上网」就是这种情况）；
  ///   * **系统代理**：TUN 起不来（Windows/macOS 需要管理员权限）时退而设置
  ///     系统代理，此时必须能在系统里看到 `127.0.0.1:<port>`。
  Future<void> _updateProxyMode() async {
    try {
      final enabled = await VPNService.getSystemProxyEnable();
      final port = ClashSettingManager.getMixedPort();
      // TUN 是否**真的**在接管：开关打开 + 内核没有回退到系统代理。
      // 只看 systemProxyFallbackActive 是不够的 —— TUN 关掉时它同样是 false，
      // 那样会把「系统代理」错报成「TUN 模式」（TUN 变成可开关之后的新坑）。
      final tunWanted =
          PlatformUtils.isPC() && SettingManager.getConfig().tunEnabled;
      final tunDriving = tunWanted && !VPNService.systemProxyFallbackActive;
      if (tunDriving) {
        _proxyMode.value = enabled
            ? "TUN + 系统代理 127.0.0.1:$port · 均已生效"
            : "TUN 模式 · 内核接管全部流量（无需系统代理）";
      } else if (tunWanted) {
        // 想用 TUN 但没起来（桌面端需要管理员权限）→ 如实说明原因与当前通路。
        // 原因用内核侧的**分类结果**（权限 / 网卡残留 / 驱动被拦），不是一句万能话。
        final short = switch (VPNService.tunFailureKind) {
          TunStartFailureKind.privilege => "需管理员权限",
          TunStartFailureKind.adapterBusy => "虚拟网卡被占用",
          TunStartFailureKind.driver => "网卡驱动被拦截",
          TunStartFailureKind.unknown => "原因未归类（见连接自检）",
          TunStartFailureKind.none => "未生效",
        };
        _proxyMode.value = enabled
            ? "TUN 未生效（$short）· 已用系统代理 127.0.0.1:$port"
            : "TUN 未生效（$short）· 系统代理未生效";
      } else {
        _proxyMode.value = enabled
            ? "系统代理 127.0.0.1:$port · 已生效"
            : "系统代理未生效 · 点此设置";
      }
    } catch (_) {
      _proxyMode.value = "";
    }
  }

  void _startProxyModeTimer() {
    _timerProxyMode?.cancel();
    _timerProxyMode = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _updateProxyMode(),
    );
  }

  void _stopProxyModeTimer() {
    _timerProxyMode?.cancel();
    _timerProxyMode = null;
  }

  Future<void> _connectToCore() async {
    bool started = await VPNService.getStarted();
    if (!started) {
      return;
    }
    if (AppLifecycleStateNofity.isPaused()) {
      return;
    }
    unawaited(_updateProxyMode());
    _startProxyModeTimer();
    // 起流量监听（内核控制端口 + 密钥）；幂等，重复调用只是刷新一次显示
    ClashTrafficWatcher.instance.start(
      port: ClashSettingManager.getControlPort(),
      secret: ClashSettingManager.getConfig().Secret ?? "",
    );
    await _updateConnections();
    // 2 秒刷新一次界面：流量数字本身是 ClashTrafficWatcher 每 3 秒从内核推来的，
    // 以前 1 秒刷一次只是把同一份数据重复渲染一遍（多出来的唤醒没有收益）。
    const Duration duration = Duration(seconds: 2);
    _timerConnectToCore ??= Timer.periodic(duration, (timer) async {
      if (AppLifecycleStateNofity.isPaused()) {
        return;
      }
      await _updateConnections();
      if (_proxyNow.value.isEmpty) {
        Future.delayed(Duration(seconds: 1), () async {
          _updateProxyNow();
        });
      }
    });
  }

  Future<void> _disconnectToCore({bool resetUI = true}) async {
    _timerConnectToCore?.cancel();
    _timerConnectToCore = null;
    _stopProxyModeTimer();
    _proxyMode.value = "";
    ClashTrafficWatcher.instance.stop();
    if (resetUI) {
      _trafficTotal.value = _kNoTrafficTotal;
      _trafficSpeed.value = _kNoSpeed;
      Biz.trafficChanged("", "");

      _proxyNow.value = "";
    }
  }

  Future<void> _updateProxyNow() async {
    if (_state == FlutterVpnServiceState.connected) {
      if (AppLifecycleStateNofity.isPaused()) {
        return;
      }
      if (_proxyNowUpdating) {
        return;
      }
      _proxyNowUpdating = true;

      final result = await ClashHttpApi.getNowProxy(
        ClashSettingManager.getConfig().Mode ?? ClashConfigsMode.rule.name,
      );
      if (result.error != null || result.data!.isEmpty) {
        _proxyNow.value = "";
      } else {
        // 只显示**节点本身**（跳过内核内置的 GLOBAL 等组名）：
        // 全局模式下内核会把链路报成 "GLOBAL -> 节点"，直接摊给用户看会让人
        // 以为「选的是 global 而不是节点」（参考客户端就是只显示节点）。
        _proxyNow.value = formatCurrentProxyName(
          result.data!.map((e) => e.name),
          delayMs: result.data!.first.delay,
        );
      }
      _proxyNowUpdating = false;
    } else {
      _proxyNow.value = "";
    }
  }

}