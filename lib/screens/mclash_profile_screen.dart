/// T-3 · 我的（一级 Tab 根页）
///
/// 结构（见 docs/design/06 §6.5）：
///   用户卡 → 订阅卡 → 账户菜单（套餐/订单/设备/通知/修改密码/客服）
///   → **Clash Mi 设置卡（原样 7 行）** → 退出登录
///
/// 说明：设置卡同时出现在「主页」与「我的」两处是**刻意的** ——
/// Clash Mi 用户习惯在主页找设置，订阅制用户习惯在「我的」找设置，
/// 两条路径都通，且指向**同一个** GroupScreen，无逻辑重复。
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mclash/screens/group_helper.dart';
import 'package:mclash/app/modules/auto_update_manager.dart';
import 'package:mclash/app/modules/setting_manager.dart';
import 'package:mclash/app/modules/profile_manager.dart';
import 'package:mclash/app/utils/file_utils.dart';
import 'package:mclash/app/utils/log.dart';
import 'package:mclash/app/utils/path_utils.dart';
import 'package:mclash/i18n/strings.g.dart';
import 'package:mclash/mf/mclash_api.dart';
import 'package:mclash/screens/devices/mclash_devices_screen.dart';
import 'package:mclash/screens/dialog_utils.dart';
import 'package:mclash/screens/main_tab_shell.dart';
import 'package:mclash/screens/mclash_orders_screen.dart';
import 'package:mclash/screens/mclash_change_password_screen.dart';
import 'package:mclash/screens/notifications/mclash_notifications_screen.dart';
import 'package:mclash/screens/about_screen.dart';
import 'package:mclash/screens/richtext_viewer.screen.dart';
import 'package:mclash/screens/theme_config.dart';
import 'package:mclash/screens/theme_define.dart';
import 'package:mclash/screens/webview_helper.dart';
import 'package:mclash/screens/widgets/framework.dart';

class MclashProfileScreen extends LasyRenderingStatefulWidget {
  const MclashProfileScreen({super.key});

  @override
  State<MclashProfileScreen> createState() => _MclashProfileScreenState();
}

class _MclashProfileScreenState extends LasyRenderingState<MclashProfileScreen>
    with WidgetsBindingObserver {
  bool _loading = true;
  Map<String, dynamic>? _dash;
  int _unread = 0;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _load();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // 回前台补一次刷新（未读数与订阅状态可能已变）
    if (state == AppLifecycleState.resumed) {
      _load();
    }
  }

  Future<void> _load() async {
    if (!mounted) {
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      Map<String, dynamic>? dash;
      var unread = 0;
      await Future.wait([
        MclashApi.dashboard().then((v) => dash = v).catchError((e) {
          Log.w("profile: dashboard failed $e");
          return null;
        }),
        MclashApi.unreadNoticeCount().then((v) => unread = v).catchError((e) {
          Log.w("profile: unread failed $e");
          return 0;
        }),
      ]);
      if (!mounted) {
        return;
      }
      MclashUnreadNotice.update(unread);
      setState(() {
        _dash = dash;
        _unread = unread;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = "$e";
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
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: Row(
                  children: [
                    Text(
                      t.meta.user,
                      style: const TextStyle(
                        fontWeight: ThemeConfig.kFontWeightTitle,
                        fontSize: ThemeConfig.kFontSizeTitle,
                      ),
                    ),
                    const Spacer(),
                    if (_loading)
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    else
                      InkWell(
                        onTap: _load,
                        child: const SizedBox(
                          width: 44,
                          height: 44,
                          child: Icon(Icons.refresh, size: 26),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(bottom: 24),
                  children: [
                    if (_error != null) _buildError(),
                    _buildUserCard(t),
                    _buildSubCard(t),
                    _buildAccountMenu(t),
                    _buildSettingsCard(t),
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

  // ---------------------------------------------------------------------
  Widget _buildUserCard(Translations t) {
    final username = _dash?["username"]?.toString() ??
        ProfileManager.getCurrent()?.getShowName() ??
        "Mclash";
    final email = _dash?["email"]?.toString() ?? MclashApi.account;
    final balance = (_dash?["balance"] as num?)?.toDouble() ?? 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        child: ListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
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
              style: const TextStyle(fontSize: 12, color: ThemeDefine.kColorGrey),
            ),
            const Divider(height: 24, thickness: 0.3),
            Row(
              children: [
                const Text("账户余额", style: TextStyle(fontSize: 15)),
                const Spacer(),
                Text(
                  "¥ ${balance.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: ThemeConfig.kFontWeightListItem,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildSubCard(Translations t) {
    final status = _dash?["subscription_status"]?.toString() ?? "";
    final active = status == "active";
    final expire = _dash?["expire_time"]?.toString() ?? "";
    final remaining = (_dash?["remaining_days"] as num?)?.toInt() ?? 0;
    final online = (_dash?["online_devices"] as num?)?.toInt() ?? 0;
    final totalDevices = (_dash?["total_devices"] as num?)?.toInt() ?? 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _dash?["membership"]?.toString().isNotEmpty == true
                        ? _dash!["membership"].toString()
                        : t.meta.none,
                    style: const TextStyle(
                      fontSize: 17,
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
            const Divider(height: 24, thickness: 0.3),
            Row(
              children: [
                _cell(expire.isEmpty ? "-" : expire, "到期时间"),
                _cell("$remaining ${t.meta.days}", "剩余天数"),
                _cell("$online / $totalDevices", "设备数"),
              ],
            ),
            const SizedBox(height: 14),
          ],
        ),
      ),
    );
  }

  Widget _cell(String value, String label) => Expanded(
        child: Column(
          children: [
            Text(
              value,
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

  Widget _buildAccountMenu(Translations t) {
    final online = (_dash?["online_devices"] as num?)?.toInt() ?? 0;
    final totalDevices = (_dash?["total_devices"] as num?)?.toInt() ?? 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        child: ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 6,
          separatorBuilder: (_, _) => const Divider(height: 1, thickness: 0.3),
          itemBuilder: (context, i) {
            switch (i) {
              case 0:
                return _row(
                  t.meta.buyProfile,
                  trailing: const Icon(Icons.chevron_right, size: 20),
                  onTap: () => MainTabController.instance?.setTab(2),
                );
              case 1:
                return _row(
                  t.meta.myProfiles,
                  trailing: const Icon(Icons.chevron_right, size: 20),
                  onTap: () => _push(const MclashOrdersScreen()),
                );
              case 2:
                return _row(
                  t.PerAppAndroidScreen.title,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "$online/$totalDevices",
                        style: const TextStyle(
                          fontSize: 12,
                          color: ThemeDefine.kColorGrey,
                        ),
                      ),
                      const Icon(Icons.chevron_right, size: 20),
                    ],
                  ),
                  onTap: () => _push(const MclashDevicesScreen()),
                );
              case 3:
                return _row(
                  t.meta.notice,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_unread > 0)
                        Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      const Icon(Icons.chevron_right, size: 20),
                    ],
                  ),
                  onTap: () => _push(const MclashNotificationsScreen()),
                );
              case 4:
                return _row(
                  "修改密码",
                  trailing: const Icon(Icons.chevron_right, size: 20),
                  onTap: () => _push(const MclashChangePasswordScreen()),
                );
              default:
                return _row(
                  t.meta.onlineCustomerService,
                  trailing: const Icon(Icons.chevron_right, size: 20),
                  onTap: () => WebviewHelper.loadUrl(
                    context,
                    "https://new.moneyfly.top",
                    "support",
                    title: t.meta.onlineCustomerService,
                  ),
                );
            }
          },
        ),
      ),
    );
  }

  /// Clash Mi 设置卡 —— **原样 7 行**，与主页 Card② 完全一致
  Widget _buildSettingsCard(Translations t) {
    final versionCheck = AutoUpdateManager.getVersionCheck();
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        child: ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: versionCheck.newVersion ? 7 : 6,
          separatorBuilder: (_, _) => const Divider(height: 1, thickness: 0.3),
          itemBuilder: (context, i) {
            switch (i) {
              case 0:
                return _settingRow(
                  t.meta.settingApp,
                  Icons.settings,
                  () => GroupHelper.showAppSettings(context),
                );
              case 1:
                return _settingRow(
                  t.meta.settingCore,
                  Icons.settings,
                  () => GroupHelper.showClashSettings(context),
                );
              case 2:
                return _settingRow(
                  t.meta.coreLog,
                  Icons.set_meal,
                  _openCoreLog,
                );
              case 3:
                return _settingRow(
                  t.meta.backupAndSync,
                  Icons.cloud_sync_outlined,
                  () => GroupHelper.showBackupAndSync(context),
                );
              case 4:
                if (versionCheck.newVersion) {
                  return _settingRow(
                    t.meta.hasNewVersion(p: versionCheck.version),
                    Icons.fiber_new_outlined,
                    () => GroupHelper.newVersionUpdate(context),
                    iconColor: Colors.red,
                  );
                }
                return _settingRow(
                  t.meta.help,
                  Icons.help,
                  () => GroupHelper.showHelp(context),
                );
              case 5:
                if (versionCheck.newVersion) {
                  return _settingRow(
                    t.meta.help,
                    Icons.help,
                    () => GroupHelper.showHelp(context),
                  );
                }
                return _settingRow(
                  t.meta.about,
                  Icons.info,
                  () => _push(const AboutScreen()),
                );
              default:
                return _settingRow(
                  t.meta.about,
                  Icons.info,
                  () => _push(const AboutScreen()),
                );
            }
          },
        ),
      ),
    );
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
    SettingManager.save();
    if (!mounted) {
      return;
    }
    // 回到登录页：清空当前页栈，避免上一个账号的页面残留
    Navigator.of(context).popUntil((r) => r.isFirst);
  }

  /// 核心日志：stderr 全文 + stdout 末 50KB（与 Clash Mi 逐值一致）。
  /// 抽成本方法是因为原实现内联在 home_screen_widgets 里，
  /// 「我的」页也要有同一个入口。
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

  Widget _buildError() => Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
        child: Text(
          _error ?? "",
          style: const TextStyle(fontSize: 13, color: Colors.red),
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
  }) =>
      ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(icon, size: 20, color: iconColor),
        title: Text(title, style: const TextStyle(fontSize: 15)),
        trailing: const Icon(Icons.chevron_right, size: 20),
        onTap: onTap,
      );

  void _push(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }
}
