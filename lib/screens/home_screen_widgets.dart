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
import 'package:mclash/mf/mclash_kernel_sync.dart';
import 'package:mclash/mf/mclash_nodes_store.dart';
import 'package:mclash/screens/home_mclash_widgets.dart';
import 'package:mclash/screens/mclash_mode_action.dart';
import 'package:mclash/screens/mclash_node_picker_sheet.dart';
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
  @visibleForTesting
  static Future<bool> Function(String from)? debugStartOverride;

  @visibleForTesting
  static Future<void> Function()? debugStopOverride;

  const HomeScreenWidgetPart1({super.key});

  @override
  State<HomeScreenWidgetPart1> createState() => _HomeScreenWidgetPart1();
}

class _HomeScreenWidgetPart1 extends State<HomeScreenWidgetPart1> {

  static final String _kNoSpeed = "↑ 0 B/s   ↓ 0 B/s";
  static final String _kNoTrafficTotal = "↑ 0 B   ↓ 0 B";

  final FocusNode _focusNodeConnect = FocusNode();
  FlutterVpnServiceState _state = FlutterVpnServiceState.disconnected;

  FlutterVpnServiceState? _pendingState;

  void _setPending(FlutterVpnServiceState s) {
    if (!mounted || _pendingState == s) {
      return;
    }
    setState(() => _pendingState = s);
  }

  void _clearPending() {
    if (_pendingState == null) {
      return;
    }
    if (!mounted) {
      _pendingState = null;
      return;
    }
    setState(() => _pendingState = null);
  }

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
    _timerStateChecker?.cancel();
    _timerStateChecker = null;
    _timerConnectToCore?.cancel();
    _timerConnectToCore = null;
    _stopProxyModeTimer();
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
    final shownState = _pendingState ?? _state;
    bool connected = shownState == FlutterVpnServiceState.connected;
    final connecting = shownState == FlutterVpnServiceState.connecting ||
        shownState == FlutterVpnServiceState.reasserting;
    final disconnecting = shownState == FlutterVpnServiceState.disconnecting;
    final switchOn = _pendingState == FlutterVpnServiceState.connecting ||
        (_pendingState == null && connected);

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Row(
              children: [
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
                    value: switchOn,
                    activeThumbColor: Colors.white,
                    activeTrackColor: ThemeDefine.kColorGreenBright,
                    onChanged: MclashAccountService.instance.isBlocked
                        ? null
                        : (bool value) async {
                            _setPending(
                              value
                                  ? FlutterVpnServiceState.connecting
                                  : FlutterVpnServiceState.disconnecting,
                            );
                            if (value &&
                                !(await mclashCheckAccountGate(context))) {
                              _clearPending();
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
    final sw = Stopwatch()..start();
    _setPending(FlutterVpnServiceState.disconnecting);
    try {
      final override = HomeScreenWidgetPart1.debugStopOverride;
      if (override != null) {
        await override();
        return;
      }
      await VPNService.stop();
    } finally {
      Log.i("[perf] 断开：从点击到 VPNService.stop 返回 ${sw.elapsedMilliseconds} ms");
      _clearPendingIfSettled();
    }
  }

  void _clearPendingIfSettled() {
    final s = _state;
    if (s == FlutterVpnServiceState.connecting ||
        s == FlutterVpnServiceState.disconnecting ||
        s == FlutterVpnServiceState.reasserting) {
      return;
    }
    _clearPending();
  }

  Future<bool> start(String from) async {
    final sw = Stopwatch()..start();
    _setPending(FlutterVpnServiceState.connecting);
    try {
      final override = HomeScreenWidgetPart1.debugStartOverride;
      if (override != null) {
        return await override(from);
      }
      return await _startInner();
    } finally {
      Log.i(
        "[perf] 连接($from)：从点击到 VPNService.start 返回 ${sw.elapsedMilliseconds} ms",
      );
      _clearPendingIfSettled();
    }
  }

  Future<bool> _startInner() async {
    if (!await mclashCheckAccountGate(context)) {
      return false;
    }
    if (ProfileManager.getCurrent() == null) {
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
    final hadPending = _pendingState != null;
    if (state == FlutterVpnServiceState.connected ||
        state == FlutterVpnServiceState.disconnected) {
      _pendingState = null;
    }
    if (_state == state) {
      if (hadPending && mounted) {
        setState(() {});
      }
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

    _trafficLogTick++;
    if (_trafficLogTick % 10 == 0) {
      Log.i(
        "流量: 速度 ${traffic.upload.value}/${traffic.download.value} B/s "
        "累计 ${traffic.uploadTotal.value}/${traffic.downloadTotal.value} B "
        "（流量流已连接=${traffic.connected}）",
      );
    }
  }

  void _startProxyModeTimer() {
    _timerProxyMode?.cancel();
    _timerProxyMode = Timer.periodic(const Duration(seconds: 15), (_) {
      if (_state != FlutterVpnServiceState.connected) {
        return;
      }
      if (MclashNodesStore.instance.isTesting) {
        return;
      }
      unawaited(() async {
        await MclashKernelSync.syncFromKernel();
        await _updateProxyNow();
      }());
    });
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
    ClashTrafficWatcher.instance.start(
      port: ClashSettingManager.getControlPort(),
      secret: ClashSettingManager.getConfig().Secret ?? "",
    );
    await _updateConnections();

    unawaited(() async {
      await Future<void>.delayed(const Duration(seconds: 3));
      if (_state != FlutterVpnServiceState.connected) {
        return;
      }
      _startProxyModeTimer();
      unawaited(MclashKernelSync.syncFromKernel());
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
    }());
  }

  Future<void> _disconnectToCore({bool resetUI = true}) async {
    _timerConnectToCore?.cancel();
    _timerConnectToCore = null;
    _stopProxyModeTimer();
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
      if (ClashSettingManager.getConfigsMode() == ClashConfigsMode.direct) {
        _proxyNow.value = "DIRECT";
        return;
      }
      _proxyNowUpdating = true;

      final result = await ClashHttpApi.getNowProxy(
        ClashSettingManager.getConfig().Mode ?? ClashConfigsMode.rule.name,
      );
      final chain = result.data;
      if (result.error != null || chain == null || chain.isEmpty) {
        _proxyNow.value = "";
      } else {
        final groupTypes = ClashProtocolType.GroupToList();
        ClashProxiesNode? real;
        for (final n in chain) {
          if (!groupTypes.contains(n.type)) {
            real = n;
            break;
          }
        }
        final ownDelay = real == null
            ? null
            : MclashNodesStore.instance.latencyByName()[real.name];
        _proxyNow.value = real == null
            ? ""
            : formatCurrentProxyName(
                [real.name],
                delayMs: ownDelay ?? real.delay,
              );
      }
      _proxyNowUpdating = false;
    } else {
      _proxyNow.value = "";
    }
  }

}