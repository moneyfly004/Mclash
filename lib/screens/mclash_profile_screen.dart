
library;

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mclash/screens/group_helper.dart';
import 'package:mclash/app/modules/auto_update_manager.dart';
import 'package:mclash/app/modules/setting_manager.dart';
import 'package:mclash/app/modules/clash_setting_manager.dart';
import 'package:mclash/app/modules/zashboard.dart';
import 'package:mclash/app/modules/profile_manager.dart';
import 'package:mclash/app/utils/file_utils.dart';
import 'package:mclash/app/utils/log.dart';
import 'package:mclash/app/utils/platform_utils.dart';
import 'package:mclash/app/utils/path_utils.dart';
import 'package:mclash/i18n/strings.g.dart';
import 'package:mclash/mf/mclash_account_info.dart';
import 'package:mclash/app/local_services/vpn_service.dart';
import 'package:mclash/mf/mclash_account_service.dart';
import 'package:mclash/mf/mclash_data_cleaner.dart';
import 'package:mclash/mf/mclash_nodes_store.dart';
import 'package:mclash/mf/mclash_heartbeat_service.dart';
import 'package:mclash/mf/mclash_api.dart';
import 'package:mclash/screens/devices/mclash_devices_screen.dart';
import 'package:mclash/screens/dialog_utils.dart';
import 'package:mclash/screens/net_check_screen.dart';
import 'package:mclash/screens/mclash_orders_screen.dart';
import 'package:mclash/screens/profiles_board_screen.dart';
import 'package:mclash/screens/mclash_change_password_screen.dart';
import 'package:mclash/screens/mclash_update_prompt.dart';
import 'package:mclash/screens/mclash_tun_setting.dart';
import 'package:mclash/screens/mclash_diagnostics_screen.dart';
import 'package:mclash/screens/about_screen.dart';
import 'package:mclash/screens/file_view_screen.dart';
import 'package:mclash/screens/richtext_viewer.screen.dart';
import 'package:mclash/screens/theme_config.dart';
import 'package:mclash/screens/theme_define.dart';
import 'package:mclash/screens/webview_helper.dart';
import 'package:mclash/screens/widgets/framework.dart';
import 'package:mclash/screens/widgets/mclash_page_header.dart';

class MclashProfileScreen extends LasyRenderingStatefulWidget {
  const MclashProfileScreen({super.key});

  @override
  State<MclashProfileScreen> createState() => _MclashProfileScreenState();
}

/// 测试缝：返回 null 表示「运行时配置文件不存在」。
///
/// 运行时配置由内核启动后写出，测试环境没有内核，所以用这个口子覆盖
/// 「文件不存在 / 文件为空 / 有内容」三条分支。
@visibleForTesting
Future<String?> Function()? mclashRuntimeProfileReader;

class _MclashProfileScreenState extends LasyRenderingState<MclashProfileScreen>
    with WidgetsBindingObserver {
  bool _loading = true;
  Map<String, dynamic>? _dash;
  String? _error;

  Future<String?> _readRuntimeProfile() async {
    final reader = mclashRuntimeProfileReader;
    if (reader != null) {
      return reader();
    }
    final path = await PathUtils.serviceCoreRuntimeProfileFilePath();
    final file = File(path);
    if (!await file.exists()) {
      return null;
    }
    return file.readAsString();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // 账号服务更新（面板改了设备上限/到期时间、余额变动…）时重建本页
    MclashAccountService.instance.addListener(_onAccountChanged);
    _load();
  }

  @override
  void dispose() {
    MclashAccountService.instance.removeListener(_onAccountChanged);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _onAccountChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {

    if (state == AppLifecycleState.resumed) {
      // 静默刷新：切回前台不该让整页跳一下
      _load(silent: true);
    }
  }

  /// 拉取账号信息。
  ///
  /// [silent] = 已经有数据时的静默刷新：**不**点亮转圈、**不**插入错误卡。
  /// 为什么：以前每次进页面 / 切回前台 / 点刷新都会 `_loading = true → false`，
  /// 头部在「转圈(20px)」和「刷新图标(44px)」之间切换，整页随之上下跳（UI 抖动）；
  /// 网络抖一下还会多出一张错误卡，把下面的卡片全顶下去。
  Future<void> _load({bool silent = false}) async {
    if (!mounted) {
      return;
    }
    final hadData = _dash != null;
    setState(() {
      _loading = !silent && !hadData;
      // 注意：这里**不清** _error。清掉会让「错误卡」在刷新期间消失、刷新完又出现，
      // 页面高度来回变（也是抖动的一种）。它只在新数据到达或新错误到来时更新。
    });
    try {
      Map<String, dynamic>? dash;
      await Future.wait([
        MclashApi.dashboard().then((v) => dash = v).catchError((e) {
          Log.w("profile: dashboard failed $e");
          return null;
        }),
        // 本页的订阅信息（到期时间/设备数）取的是账号服务里的快照，
        // 只刷自己的 dashboard 会让它一直是旧的 —— 一起刷新，界面才不会「不更新」。
        MclashAccountService.instance.refresh(),
      ]);
      if (!mounted) {
        return;
      }
      setState(() {
        if (dash != null) {
          _dash = dash;
          _error = null;
        } else if (!hadData) {
          // 账号接口失败时**不能**留一片空白：给出原因和「点右上角刷新重试」的提示
          // （用户实测：支付失败之后回到「我的」页面一片空白，不知道发生了什么）。
          _error = "账号信息读取失败：登录可能已过期或网络不通。\n请点右上角刷新重试；仍失败请重新登录。";
        } else {
          // 已经有旧数据：保留它、不插错误卡 —— 否则卡片会被顶下去再弹回来
          Log.w("profile: 刷新失败，保留上一次的数据");
        }
        _loading = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        if (!hadData) {
          _error = "$e";
        } else {
          Log.w("profile: 刷新异常，保留上一次的数据 $e");
        }
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: PreferredSize(preferredSize: Size.zero, child: AppBar()),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
          child: Column(
            children: [
              MclashPageHeader(
                title: t.meta.user,
                loading: _loading,
                onRefresh: () => _load(silent: true),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(bottom: 24),
                  children: [
                    if (_error != null) _buildError(),

                    _buildAccountCard(t),
                    _buildSettingsCard(t),
                    _buildToolsCard(t),
                    _buildLogout(t),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountCard(Translations t) {
    final info = MclashAccountInfo(
      _dash,
      MclashAccountService.instance.subscription,
    );
    final active = info.isActive;
    final username = info.username.isNotEmpty
        ? info.username
        : (ProfileManager.getCurrent()?.getShowName() ?? "Mclash");
    final email = _dash?["email"]?.toString() ?? MclashApi.account;

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const SizedBox(height: 14),
            Text(
              username,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: ThemeConfig.kFontWeightListItem,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              email,
              style: const TextStyle(
                fontSize: 12,
                color: ThemeDefine.kColorGrey,
              ),
            ),
            const Divider(height: 24, thickness: 0.3),
            Row(
              children: [
                const Text("账户余额", style: TextStyle(fontSize: 15)),
                const Spacer(),
                Text(
                  "¥ ${info.balance.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: ThemeConfig.kFontWeightListItem,
                  ),
                ),
              ],
            ),
            const Divider(height: 24, thickness: 0.3),

            Row(
              children: [
                Expanded(
                  child: Text(
                    info.planName.isNotEmpty ? info.planName : t.meta.none,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: ThemeConfig.kFontWeightListItem,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: (active ? ThemeDefine.kColorGreenBright : Colors.red)
                        .withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    active ? t.meta.enable : t.meta.disable,
                    style: TextStyle(
                      fontSize: 11,
                      color: active
                          ? ThemeDefine.kColorGreenBright
                          : Colors.red,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _cell(info.expireDate.isEmpty ? "-" : info.expireDate, "到期时间"),
                _cell(
                  info.remainingDays == null ? "-" : "${info.remainingDays}",
                  "剩余天数",
                ),
                _cell(info.deviceText ?? "-", "设备数"),
              ],
            ),
            const SizedBox(height: 6),
            const Divider(height: 1, thickness: 0.3),

            _row(
              "我的订单",
              trailing: const Icon(Icons.chevron_right, size: 20),
              onTap: () => _push(const MclashOrdersScreen()),
            ),
            _row(
              "设备管理",
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    info.deviceText ?? "-",
                    style: const TextStyle(
                      fontSize: 12,
                      color: ThemeDefine.kColorGrey,
                    ),
                  ),
                  const Icon(Icons.chevron_right, size: 20),
                ],
              ),
              onTap: () => _push(const MclashDevicesScreen()),
            ),
            _row(
              "修改密码",
              trailing: const Icon(Icons.chevron_right, size: 20),
              onTap: () => _push(const MclashChangePasswordScreen()),
            ),
            const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsCard(Translations t) {
    final rows = <Widget>[
      _settingRow(
        t.meta.settingApp,
        Icons.settings,
        () => GroupHelper.showAppSettings(context),
      ),
      _settingRow(
        t.meta.settingCore,
        Icons.settings,
        () => GroupHelper.showClashSettings(context),
      ),
      _settingRow(
        t.meta.coreLog,
        Icons.set_meal,
        _openCoreLog,
      ),

      _settingRow(
        t.meta.runtimeProfile,
        Icons.file_present,
        _openRuntimeProfile,
      ),
      _settingRow(
        t.meta.backupAndSync,
        Icons.cloud_sync_outlined,
        () => GroupHelper.showBackupAndSync(context),
      ),

      // 卸载前清数据：macOS/Windows 上「删除 App」不会删掉
      // ~/Library/Application Support/... 里的订阅与会话，必须给用户一个出口。
      if (PlatformUtils.isPC())
        _settingRow(
          "清除本地数据（卸载前使用）",
          Icons.delete_forever_outlined,
          _clearLocalData,
        ),

      if (SettingManager.getConfig().devMode)
        _settingRow(
          "配置档管理（开发者）",
          Icons.developer_mode,
          () => _push(const ProfilesBoardScreen()),
        ),
    ];
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        child: ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: rows.length,
          separatorBuilder: (_, _) => const Divider(height: 1, thickness: 0.3),
          itemBuilder: (_, i) => rows[i],
        ),
      ),
    );
  }

  Widget _buildToolsCard(Translations t) {
    final versionCheck = AutoUpdateManager.getVersionCheck();
    final rows = <Widget>[
      _settingRow(
        t.meta.board,
        Icons.dashboard_outlined,
        _openBoard,
      ),
      _settingRow(
        t.meta.networkCheck,
        Icons.network_check_outlined,
        () => _push(const NetCheckScreen()),
      ),
      if (versionCheck.newVersion)
        _settingRow(
          t.meta.hasNewVersion(p: versionCheck.version),
          Icons.fiber_new_outlined,
          () => GroupHelper.newVersionUpdate(context),
          iconColor: Colors.red,
        ),
      // TUN 虚拟网卡：桌面端的网络模式选择（关闭 / 自动 / 强制）。
      // 参考实现把它放在「设置 → 代理与分流」里；我们放在「我的 → 应用设置」。
      // 安卓不显示：那里的 VpnService 本身就是隧道，不是用户可选项
      // （显示了就是个点了没用的假开关）。
      if (PlatformUtils.isPC())
        _settingRow(
          "TUN 虚拟网卡",
          Icons.lan_outlined,
          () => MclashTunSetting.show(context),
          trailingText: MclashTunSetting.label(
            SettingManager.getConfig().tunMode,
          ),
          subtitle: MclashTunSetting.description(
            SettingManager.getConfig().tunMode,
          ),
        ),
      // 常驻的「检查更新」：手动查一次，有新版本就提示并给下载/安装入口
      _settingRow(
        "检查更新",
        Icons.system_update_alt_outlined,
        () => MclashUpdatePrompt.checkManually(context),
      ),
      // 连接自检：把「走的哪条通路 / 为什么没生效」摊开，可一键复制
      _settingRow(
        "连接自检",
        Icons.medical_information_outlined,
        () => showMclashDiagnostics(context),
      ),
      _settingRow(
        t.meta.about,
        Icons.info,
        () => _push(const AboutScreen()),
      ),
    ];
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        child: ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: rows.length,
          separatorBuilder: (_, _) => const Divider(height: 1, thickness: 0.3),
          itemBuilder: (_, i) => rows[i],
        ),
      ),
    );
  }

  Future<void> _openBoard() async {
    final tcontext = Translations.of(context);
    final setting = SettingManager.getConfig();
    if (setting.boardOnline && setting.boardUrl.isNotEmpty) {
      final uri = Uri.tryParse(setting.boardUrl);
      if (uri == null) {
        await DialogUtils.showAlertDialog(
          context,
          "${tcontext.meta.urlInvalid}:${setting.boardUrl}",
          withVersion: true,
        );
        return;
      }
      final shortUrl = Uri(
        scheme: uri.scheme,
        userInfo: uri.userInfo,
        host: uri.host,
        port: uri.port,
      );
      final secret = ClashSettingManager.getConfig().Secret ?? "";
      final url =
          '${shortUrl.toString()}/?hostname=127.0.0.1&port=${ClashSettingManager.getControlPort()}&secret=$secret&http=true';
      if (!mounted) {
        return;
      }
      await WebviewHelper.loadUrl(
        context,
        url,
        "onlineboard",
        title: tcontext.meta.board,
        inappWebViewOpenExternal: true,
      );
      return;
    }
    // 面板是内核数据的可视化界面（zashboard）：内核没跑时它只有空壳，
    // 用户会以为「面板坏了」。先如实说清，再决定要不要继续。
    if (!await VPNService.getStarted()) {
      if (!mounted) {
        return;
      }
      final go = await DialogUtils.showConfirmDialog(
        context,
        "面板显示的是内核的实时数据（连接、流量、规则命中）。\n\n"
        "当前内核没有运行，面板会是一个空壳。\n"
        "点「确定」仍然打开，点「取消」先去主页连接。",
      );
      if (go != true || !mounted) {
        return;
      }
    }
    final result = await Zashboard.start();
    if (!mounted) {
      return;
    }
    if (result.error != null) {
      await DialogUtils.showAlertDialog(
        context,
        result.error!.message,
        withVersion: true,
      );
      return;
    }
    final url = result.data!;
    await WebviewHelper.loadUrl(
      context,
      url,
      "board",
      title: tcontext.meta.board,
      inappWebViewOpenExternal: false,
      // 桌面端以前是**丢给系统浏览器**（点了就像什么都没发生，还得自己切回来）。
      // flutter_inappwebview 在 Windows/macOS 都支持 → 改成应用内窗口打开。
      useInappWebViewForPC: true,
    );
    // 面板是直接改内核的（在里面点节点 = 改内核选择），App 侧不会自动知道 ——
    // 关掉面板后立刻让首页重新读一次内核的当前节点，避免显示旧节点。
    MclashNodesStore.instance.notifyCurrentMaybeChanged();
    if (PlatformUtils.isMobile()) {
      await Zashboard.stop();
    }
  }

  Widget _buildLogout(Translations t) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        child: InkWell(
          onTap: _confirmLogout,
          child: SizedBox(
            height: 56,
            child: Center(
              child: Text(
                t.meta.quit,
                style: const TextStyle(fontSize: 15, color: Colors.red),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmLogout() async {
    final ok = await DialogUtils.showConfirmDialog(context, "确认退出登录？");
    if (ok != true || !mounted) {
      return;
    }
    try {
      await MclashApi.logout();
    } catch (_) {}
    // 退出登录后停止在线心跳（面板会按 3 分钟无心跳判为离线）
    MclashHeartbeatService.instance.stop();
    SettingManager.save();
    if (!mounted) {
      return;
    }

    Navigator.of(context).popUntil((r) => r.isFirst);
  }

  Future<void> _openCoreLog() async {
    try {
      final errPath = await PathUtils.serviceStdErrorFilePath();
      final logPath = await PathUtils.serviceLogFilePath();
      const split = "\n-------------------------------\n";
      var content = "";
      final errFile = File(errPath);
      if (await errFile.exists()) {
        final e = await errFile.readAsString();
        if (e.isNotEmpty) {
          content += split + e;
        }
      }
      final item = await FileUtils.readAsStringReverse(logPath, 50 * 1024, false);
      if (item != null) {
        if (content.isNotEmpty) {
          content += split;
        }
        content += item.item1;
      }
      if (!mounted) {
        return;
      }
      await Navigator.push(
        context,
        MaterialPageRoute(
          settings: RichtextViewScreen.routeSettings(),
          builder: (_) => RichtextViewScreen(
            title: Translations.of(context).meta.coreLog,
            file: "",
            content: content,
            showAction: true,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }
      await DialogUtils.showAlertDialog(context, "$e");
    }
  }

  /// 清除本地数据（含订阅配置档、登录会话、缓存与日志）。
  ///
  /// 两步确认：第一次说明会删什么，第二次要求再次确认 —— 这是不可撤销操作。
  Future<void> _clearLocalData() async {
    final items = MclashDataCleaner.items.map((e) => "· $e").join("\n");
    final dataDir = await MclashDataCleaner.dataDir();
    if (!mounted) {
      return;
    }
    final first = await DialogUtils.showConfirmDialog(
      context,
      "将删除本机保存的以下数据（不可恢复）：\n\n$items\n\n"
      "账号本身、已购买的套餐都在服务器上，不受影响；重新登录即可恢复订阅。\n\n"
      "数据目录：$dataDir\n"
      "（卸载 App 之前先点这里，重装后才会是干净的、需要重新登录的状态）",
    );
    if (first != true || !mounted) {
      return;
    }
    final second = await DialogUtils.showConfirmDialog(
      context,
      "确认清除？清除后需要重新登录。",
    );
    if (second != true || !mounted) {
      return;
    }

    try {
      // 顺序：先断开（顺带还原系统代理）、再关掉开机自启、最后清数据 ——
      // 否则清完数据后 App 还会以「上次的连接/自启状态」留在系统里。
      await VPNService.stop();
      await VPNService.restoreSystemProxy();
    } catch (e) {
      Log.w("清除数据前断开连接失败（忽略）$e");
    }
    try {
      await VPNService.setLaunchAtStartup(false);
    } catch (e) {
      Log.w("清除数据前关闭开机自启失败（忽略）$e");
    }
    try {
      final removed = await MclashDataCleaner.clearAll();
      final dir = await MclashDataCleaner.dataDir();
      if (!mounted) {
        return;
      }
      await DialogUtils.showAlertDialog(
        context,
        "已清除 $removed 项本地数据（含登录会话，下次打开需要重新登录）。\n\n"
        "现在可以删除 App 完成卸载：\n"
        "· macOS：把 Mclash.app 拖进废纸篓（数据目录已清空：$dir）\n"
        "· Windows：控制面板卸载 Mclash，卸载向导里的「是否保留用户数据」选「否」",
      );
    } catch (e) {
      if (!mounted) {
        return;
      }
      await DialogUtils.showAlertDialog(context, "清除失败：$e");
    }
  }

  Future<void> _openRuntimeProfile() async {
    String content;
    try {
      final raw = await _readRuntimeProfile();
      if (raw == null) {
        if (!mounted) {
          return;
        }
        await DialogUtils.showAlertDialog(
          context,
          "还没有生成运行时配置。\n内核成功启动后会写出实际生效的配置，请先在主页连接一次。",
        );
        return;
      }
      content = raw;
      if (content.trim().isEmpty) {
        if (!mounted) {
          return;
        }
        await DialogUtils.showAlertDialog(
          context,
          "运行时配置当前为空。\n请在主页连接一次让内核写入配置后再查看。",
        );
        return;
      }
    } catch (e) {
      if (!mounted) {
        return;
      }
      await DialogUtils.showAlertDialog(context, "$e");
      return;
    }
    if (!mounted) {
      return;
    }
    await Navigator.push(
      context,
      MaterialPageRoute(
        settings: FileViewScreen.routeSettings(),
        builder: (_) => FileViewScreen(
          title: Translations.of(context).meta.runtimeProfile,
          content: content,
        ),
      ),
    );
  }

  /// 出错时给一条**带重试按钮**的提示，而不是只留一行红字（或一片空白）。
  Widget _buildError() => Padding(
    padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
    child: Card(
      color: Colors.red.withValues(alpha: 0.06),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.error_outline, size: 16, color: Colors.red),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _error ?? "",
                    style: const TextStyle(fontSize: 13, color: Colors.red),
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                key: const ValueKey("profile-retry"),
                onPressed: _loading ? null : _load,
                child: const Text("重试"),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _cell(String value, String label) => Expanded(
    child: Column(
      children: [
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: ThemeConfig.kFontWeightListItem,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: ThemeDefine.kColorGrey),
        ),
      ],
    ),
  );

  Widget _row(
    String title, {
    required Widget trailing,
    required VoidCallback onTap,
  }) =>
      ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(title, style: const TextStyle(fontSize: 15)),
        trailing: trailing,
        onTap: onTap,
      );

  Widget _settingRow(
    String title,
    IconData icon,
    VoidCallback onTap, {
    Color? iconColor,
    String? trailingText,
    String? subtitle,
  }) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: Icon(icon, size: 20, color: iconColor),
    title: Text(title, style: const TextStyle(fontSize: 15)),
    subtitle: subtitle == null
        ? null
        : Text(
            subtitle,
            style: const TextStyle(
              fontSize: 11,
              height: 1.3,
              color: ThemeDefine.kColorGrey,
            ),
          ),
    trailing: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (trailingText != null && trailingText.isNotEmpty)
          Text(
            trailingText,
            style: const TextStyle(
              fontSize: 13,
              color: ThemeDefine.kColorGrey,
            ),
          ),
        const Icon(Icons.chevron_right, size: 20),
      ],
    ),
    onTap: onTap,
  );

  void _push(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }
}
