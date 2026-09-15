# MoneyFly — complete UI/UX inventory (index)

Target analyzed: `/Users/apple/Downloads/mysoftware/moneyfly` — Flutter "MoneyFly" subscription-VPN client, app version `2.2.5+164`, Dart SDK `^3.11.0`, deps: dio, provider, url_launcher, flutter_secure_storage, shared_preferences, qr_flutter, yaml, device_info_plus, package_info_plus, path_provider, connectivity_plus, wakelock_plus, flutter_local_notifications, tray_manager, window_manager, launch_at_startup, ffi.
**No file in the analyzed project was modified.** This artifact set was written into the agent workspace only. Total app source read: 21,389 LOC across 63 Dart files; every file requested by the task was read in full.

## Files in this artifact set

| file | contents |
|---|---|
| `pages-part1-shell-auth-home-nodes-purchase.md` | App shell + routing model + `MainShell` (bottom nav / NavigationRail / window-close dialog), `LoginPage`, `RegisterPage`, `ForgotPasswordPage`, `ChangePasswordPage`, `HomePage` (+ `_NodePickerSheet` + 4 dialogs), `NodesPage`, `PackagePage`, `UpgradeDevicesPage`, `PaymentQrDialog` |
| `pages-part2-profile-settings-widgets.md` | `ProfilePage`, `OrdersPage`, `DevicesPage`, `NotificationsPage`, `SettingsPage` (all 28 rows), `KernelPage`, `LogCenterPage` (2 tabs), `AccessPage`, `BypassPage`, `GeoUpdatePage`, `MFEmpty`, `mfInput`, `CountryFlag`, `PasswordRuleHints`, theme summary, cross-cutting state table, complete list of every responsive/desktop behavior in the app |
| `strings-zh-en.md` | **All 585 `AppStrings` keys with verbatim zh and en values** (machine-extracted, numbered) |
| `color-tokens.md` | All 6 appearances × 13 tokens with exact hex; semantic colors; every hard-coded accent hex still in use; radii/spacing/typography/breakpoint tokens; theme-controller mechanics |
| `i18n-hygiene.md` | Language mechanics + the 87 keys never referenced anywhere in `lib/` (dead copy) + the 10 dynamically-referenced keys (theme labels, nav `labelKey`) |
| `icons-and-hardcoded-strings.md` | Every `Icons.*` per file; every emoji/glyph literal per file with line numbers; every hard-coded user-visible CJK literal not in `AppStrings`; runtime-composed strings (`¥…`, `… ms`, `/年`…) |
| `INDEX.md` | this file: summary, service→endpoint map, network error string inventory, page→file map |

## Page → file → entry point map (complete, all 19 pages + 1 dialog)

| page | file | LOC | entered by | AppBar back? |
|---|---|---|---|---|
| `RootShell` / `MainShell` | `lib/main.dart` | 635 | `MaterialApp.home` | — |
| `LoginPage` | `lib/pages/auth/login_page.dart` | 254 | root when logged out | no AppBar |
| `RegisterPage` | `lib/pages/auth/register_page.dart` | 256 | Login footer link | yes + "登录" action |
| `ForgotPasswordPage` | `lib/pages/auth/forgot_password_page.dart` | 293 | Login footer link | yes + "登录" action |
| `ChangePasswordPage` | `lib/pages/auth/change_password_page.dart` | 122 | Settings → 账户 → 修改密码 | yes |
| `HomePage` | `lib/pages/home/home_page.dart` | 1644 | shell tab 0 | no AppBar (custom header) |
| `NodesPage` | `lib/pages/nodes/nodes_page.dart` | 742 | shell tab 1 | no AppBar (custom title row) |
| `PackagePage` | `lib/pages/package/package_page.dart` | 460 | shell tab 2 / `mainTabIndex.value = 2` | no AppBar (in-list title) |
| `UpgradeDevicesPage` | `lib/pages/package/upgrade_devices_page.dart` | 514 | DevicesPage upgrade card; Home blocked dialog | yes |
| `PaymentQrDialog` | `lib/pages/payment/payment_dialog.dart` | 296 | PackagePage / UpgradeDevicesPage / OrdersPage | dialog |
| `ProfilePage` | `lib/pages/profile/profile_page.dart` | 501 | shell tab 3 | no AppBar (header row) |
| `OrdersPage` | `lib/pages/orders/orders_page.dart` | 259 | Profile menu | yes + 刷新 action |
| `DevicesPage` | `lib/pages/devices/devices_page.dart` | 370 | Profile menu; Home banner/dialog; Nodes empty state | yes + 刷新 action |
| `NotificationsPage` | `lib/pages/notifications/notifications_page.dart` | 204 | Profile menu | yes + 全部已读 (conditional) |
| `SettingsPage` | `lib/pages/settings/settings_page.dart` | 1105 | Home gear; Profile menu | yes + 恢复默认 action |
| `KernelPage` | `lib/pages/settings/kernel_page.dart` | 584 | Settings → 内核管理 | yes |
| `LogCenterPage` | `lib/pages/settings/log_center_page.dart` | 559 | Settings → 日志中心 | yes + TabBar |
| `AccessPage` | `lib/pages/settings/access_page.dart` | 311 | Settings → 应用代理 (Android only) | yes + reconnect action |
| `BypassPage` | `lib/pages/settings/bypass_page.dart` | 383 | Settings → 直连名单 | yes |
| `GeoUpdatePage` | `lib/pages/settings/geo_update_page.dart` | 236 | Settings → 更新分流数据 | yes |
| widgets | `mf_empty.dart` 93 · `mf_input.dart` 30 · `country_flag.dart` 36 · `password_rules.dart` 57 | 216 | — | — |
| theme | `app_theme.dart` 338 · `theme_controller.dart` 48 | 386 | — | — |
| i18n | `l10n/app_strings.dart` | 1292 | — | — |

## Service → API endpoint map (what each screen actually calls)

Base URL is obfuscated in source (`Endpoints._d([...])` XOR `0x5A`); path constants are plain.

| service (file) | method | endpoint |
|---|---|---|
| `AuthService` | `login` | `POST /auth/login-json` |
| | `sendCode` | `POST /auth/verification/send` |
| | `register` | `POST /auth/register` |
| | `forgotPassword` | `POST /auth/forgot-password` |
| | `resetPassword` | `POST /auth/reset-password` |
| | `changePassword` | `POST /users/change-password` |
| | `logout` | `POST /auth/logout` (`extra: {'_noSessionExpired': true}`) |
| `ApiClient` | token refresh | `POST /auth/refresh` |
| `UserService` | `dashboard` | `GET /users/dashboard-info` |
| | `me` | `GET /users/me` |
| `SubscriptionService` | `fetchInfo` | `GET /user/subscribe` |
| | `fetchNodes` | fetches the returned `subscribe_url` as text (`fetchText`, custom UA) with disk cache fallback |
| `DeviceService` | `list` | `GET /subscriptions/devices` |
| | `delete` | `DELETE /devices/{id}` |
| | `updateRemark` | `PUT /subscriptions/devices/{id}/remark` |
| `PaymentService` | `plans` | `GET /packages` |
| | `methods` | `GET /payment/methods` |
| `OrderService` | `create` | `POST /orders` |
| | `createDeviceUpgrade` | `POST /orders/upgrade-devices` |
| | `previewDeviceUpgrade` | `POST /orders/upgrade-devices` (`preview_only`) |
| | `pay` | `POST /payment` |
| | `status` | `GET /orders/{orderNo}/status` |
| | `cancel` | `POST /orders/{orderNo}/cancel` |
| | `list` | `GET /orders` |
| `CouponService` | `verify` | `POST /coupons/verify` |
| | `my` | `GET /coupons/my` |
| `NotificationService` | `list` | `GET /notifications` |
| | `unreadCount` | `GET /notifications/unread-count` |
| | `markRead` | `PUT /notifications/{id}/read` |
| | `markAllRead` | `PUT /notifications/read-all` |
| | `delete` | `DELETE /notifications/{id}` |
| `UpdateService` | version check | `GET /software/versions`, `GET /software-config` |
| node latency | — | `POST /nodes/batch-test`, `GET /nodes` (declared; kernel delay is the primary path) |
| `AccessPage` | — | `MethodChannel('top.moneyfly/vpn_core').invokeListMethod('getInstalledApps')` |
| `LogCenterPage` (Android) | — | `MethodChannel('top.moneyfly/vpn_core').invokeMethod('fetchKernelLogs', {incremental, reset})` |
| `main.dart` | — | `MethodChannel('top.moneyfly/lifecycle')` method `systemShutdown` |

## Network-layer error strings that reach the UI (`ApiClient.errorMsg`, hard-coded Chinese, **not** i18n)

| condition | string |
|---|---|
| backend `message` / `detail` / `error` present | that server string verbatim (this is how "账户已被禁用…", "此设备已被移除并踢下线…" reach dialogs) |
| connection timeout / connection error | `网络连接失败，请检查网络后重试` |
| receive timeout | `服务器响应超时，请稍后重试` |
| send timeout | `发送请求超时，请稍后重试` |
| request cancelled | `请求已取消` |
| HTTP 401 | `登录已过期，请重新登录` |
| HTTP 403 | `没有权限执行此操作` |
| HTTP 404 | `请求的资源不存在` |
| HTTP 429 | `操作过于频繁，请稍后再试` |
| HTTP 500 | `服务器开小差了，请稍后重试` |
| other status | `请求失败（{code|未知}）` |
| `FormatException` | `数据解析失败` |
| default | `e.toString()` |
| subscription returned a zip | `订阅返回的是 zip 压缩包，请在服务端改为直接返回 Clash 配置` |
| missing backend message | `请求失败，请稍后重试` |

## Connection-layer strings surfaced on the home card (`ConnectionController`)

| key | zh | trigger |
|---|---|---|
| `no_available_nodes` | 没有可用节点，请先刷新订阅 | connect with zero nodes |
| `all_nodes_offline` | 所有节点均不可用 | no online node |
| `kernel_busy` | 内核正在启动中，请稍候 | `StateError` during start |
| `kernel_timeout` | 内核启动超时 | kernel start timeout |
| `kernel_exit` | 内核异常退出 | kernel exited |
| `tun_need_admin_mac` / `tun_need_admin_win` | TUN 模式需要管理员权限… | TUN without privileges |
| `node_switch_fail {'err'}` | 节点热切换失败：{err} | hot switch failure |
| `mode_switch_fail {'err'}` | 模式切换失败：{err} | smart/global toggle failure |
| `reconnect_exhausted` | 重连 3 次仍失败，已断开 | reconnect budget exhausted |
| `kernel_crash_recover_failed` | 内核进程反复异常退出，已停止自动恢复。请检查安全软件是否拦截内核进程 | crash loop |

Error-action gating (`guideForConnError` in `lib/core/proxy/conn_error.dart`):
`noVpnPermission` → VPN button only; `noNotificationPermission` → notify button only; `backgroundStartBlocked` → retry **+** "请保持 App 在前台" hint; everything else → retry.

## Account gate (`AccountService` + `AccountStatus`) — drives home banner/dialog, nodes empty state, connect interception

| status | blockTitle | blockText |
|---|---|---|
| `expired` | 套餐已到期 | 您的套餐已到期，购买套餐后即可继续畅连全球节点 |
| `deviceFull` | 设备数量已达上限 | 设备数量已达上限（{cur}/{limit}），无法连接新设备。可在「我的 - 设备管理」中删除不常用设备，或升级更高设备数的套餐 |
| `accountDisabled` | 账号已被禁用 | server message, fallback 您的账号已被禁用，无法使用服务。如有疑问，请联系客服 |
| `subscriptionDisabled` | 套餐已被禁用 | 您的套餐已被禁用或状态异常，无法连接。如有疑问，请联系客服 |
| `noSubscription` | 尚未开通套餐 | 您还没有开通套餐，开通后即可畅连全球节点 |
| `ok` / `unknown` | '' | '' (unknown deliberately does not block connections) |

`isBlocked` = expired ∨ deviceFull ∨ subscriptionDisabled ∨ accountDisabled ∨ noSubscription.
Classification priority: subscription inactive → expired (backend `is_expired`, never local clock) → deviceFull (`limit > 0 && used >= limit`) → noSubscription (empty subscribe_url) → ok.
Kick-off detection (`SubscriptionService.isKickedMessage`): message contains 已被移除 / 踢下线 / `removed` / `kicked` → the UI disconnects and clears nodes.

## Password policy (`lib/core/services/password_policy.dart`) — used by register / forgot / change

- `looksLikeEmail`: `^[\w.+-]+@[\w-]+(\.[\w-]+)+$` on the trimmed value.
- `specials = '!@#$%^&*()_+-=[]{}|;:,.<>?'` (matches backend `auth.ValidatePasswordStrength`).
- `kindsOf(pwd)`: counts upper / lower / digit / special kinds (0–4) by rune range.
- `errorFor(pwd)`: `< 8` → `pwd_short` "密码至少 8 位"; `kinds < 3` → `pwd_weak` "密码强度不足：需包含大小写字母、数字、特殊字符中的至少三种"; else `null`.
- `hint` = `new_pwd_hint` "至少 8 位，大小写字母/数字/符号至少三种".

## Settings defaults (`SettingsStore._defaults()`) — the values the settings rows display

`autoConnect:false`, `autoTest:true`, `autoReconnect:false`, `reconnectTimes:3`, `testIntervalMin:30`, `dns:'223.5.5.5'`, `dnsNameservers:['223.5.5.5','119.29.29.29']`, `fakeIpFilterExtra:[]`, `defaultMode:'smart'`, `localPort:2080`, `clashApiPort:9090`, `testUrl:'https://www.gstatic.com/generate_204'` (legacy HTTP variant auto-migrated), `tunMode: android/iOS → 'auto' else 'off'`, `tunStack:'gvisor'`, `kernelLogLevel:'warning'`, `dnsMode:'auto'`, `udpSkipCertVerify:true`, `accessControlMode:'all'`, `accessControlApps:[]`, `bypassDomains:[]`, `bypassLan:true`, `appearance:'light'`, `subscribeUserAgent:''`, `language:'zh'`, `notify:true`, `crashReport:false`, `analytics:false`, `launchAtStartup:false`, `closeAction:'ask'`, plus `lastSelectedTag`, `kernelVariant`.
