# MoneyFly — UI/UX inventory, Part 2
### Profile · Orders · Devices · Notifications · Settings (7 pages) · shared widgets · theme

Analyzed checkout: `/Users/apple/Downloads/mysoftware/moneyfly`. No project file was modified. Strings quoted verbatim.

---

## 10. `lib/pages/profile/profile_page.dart` — `ProfilePage`

**Entry**: tab 3 of `MainShell`. Doc: `/// 我的页：真实仪表盘数据（UserService 会话内缓存，进入不重复刷新）+ 各功能入口`.
**Pushes**: `DevicesPage`, `OrdersPage`, `NotificationsPage`, `SettingsPage`; `mainTabIndex.value = 2` for renew.

### State
| variable | type | purpose |
|---|---|---|
| `_dashboard` (getter) | `DashboardInfo?` | `UserService.instance.cachedDashboard` |
| `_loading` | bool | initial fetch (only when no cache) |
| `_loadFailed` | bool | last load failed and there is no cache → error+retry placeholder |

### Data sources
`UserService.instance.loadCachedDashboard() / adoptCachedDashboard() / dashboard(force: true)` (`GET /users/dashboard-info`), `UserService.instance.invalidateCache()`; `AuthService.instance.logout()`; `UpdateInfo.currentVersion`; `AccountService` indirectly through the dashboard fields.

### Layout — `Scaffold(body: SafeArea(RefreshIndicator(onRefresh: _load, child: ListView(physics: AlwaysScrollable, padding fromLTRB(22,14,22,24)))))`
1. **Header `_buildHeader(name, email, balance)`**:
   - Avatar: `Container(50×50, color: Colors.black, radius 15)` with `Icon(Icons.flight_takeoff, color: brand, size 26)` (a take-off jet, not a person icon).
   - `SizedBox(13)` + `Expanded(Column[Text(name, 16px w700 ellipsis), Text(email.isEmpty ? no_email_hint "未登录邮箱" : email, 11.5px txt3 ellipsis)])` — `name` falls back to `—`.
   - `SizedBox(8)` + right `Column(crossAxisAlignment: end)`: `Text('¥${balance.toStringAsFixed(2)}', 15px w700 brandLight kNumFont)` over `Text(balance "账户余额", 9.5px txt3)`.
2. `SizedBox(16)`.
3. **Loading**: `_loading && _dashboard == null` → `Padding(vertical 40)` + centered `CircularProgressIndicator(brand)`.
4. **Error `_loadFailed && _dashboard == null`** → `Padding(vertical 30)` `Column[Icon(Icons.cloud_off_outlined, 40, txt3), 10, Text(profile_load_fail "账户信息加载失败，请重试", 12.5px txt2), 14, GestureDetector retry: gradient Container(padding 24/10, radius 12) with Text(retry "重试", 13px white w600)]`.
5. **Loaded** → `..._buildStatusBanners(dashboard)`, then:
   - **`_buildInfoCard(hasSub, remaining, expireShort, online, total)`** — `Container(padding fromLTRB(6,15,6,14), radius 18, gradient [Color(0x2E455FE9), Color(0x12455FE9)], border brand@.38)`:
     - Top row: `Text(hasSub ? (membership.isNotEmpty ? membership : member "会员") : no_plan_yet "尚未开通套餐", 13.5px w700 txt)` + `Spacer` + status pill `Container(padding 9/3, radius 20, border (green|amber)@.35, bg (green|amber)@.15)` with `'● ${active "生效中" | inactive "未开通"}'` (10px, w600, colored green/amber).
     - `SizedBox(13)` + `Row` of three `_SubItem`s:
       - `value: remaining`, `unit: days "天"`, `label: remaining_days "剩余天数"`, `highlight: true` → value 18px w800 `green` kNumFont.
       - `value: expireShort` (first 10 chars of the expire string, `expire_na "未设置"` when empty), `label: expire_time "到期时间"` → 14.5px w800 `txt`.
       - `value: '$online/$total'`, `label: plan_devices "设备数"` → 14.5px w800 `txt`.
       - `_SubItem` layout: centered `Column[Row(baseline)[Text(value, ellipsis), if unit: 2 + Text(unit, 10px txt2)], 3, Text(label, 10px txt2, ellipsis)]`, each wrapped in `Expanded`.
   - `SizedBox(18)` + **menu `_buildMenu`** — 5 rows, each `Container(margin bottom 8, padding 15/13, card, radius 15, border line)` + `InkWell(radius 15)` + `Row[Text(emoji, 15px), 12, Expanded(Text(title, 14px w500 txt)), optional badge (card2 pill, 10.5px txt3 kNumFont), 4, Icon(Icons.chevron_right, 18, txt3)]`:

     | emoji | title key | label | badge | action |
     |---|---|---|---|---|
     | 📱 | `profile_devices` | 设备管理 | `'$online/$total'` | push `DevicesPage` |
     | 🧾 | `profile_orders` | 我的订单 | — | push `OrdersPage` |
     | 🔔 | `profile_notifications` | 通知中心 | — | push `NotificationsPage` |
     | ⚙️ | `settings` | 设置 | — | push `SettingsPage` |
     | ℹ️ | `profile_about` | 关于 MoneyFly | `'v${UpdateInfo.currentVersion}'` | `_showAbout` dialog |

   - `SizedBox(18)` + **logout `_buildLogout`**: `GestureDetector` → `Container(height 50, centered, color red@.07, radius 15, border red@.35)` with `Text(logout "退出登录", 14.5px red w600)`.
     Tap → `AlertDialog(card2)` title `logout "退出登录"` (16px), content `logout_confirm "确定要退出当前账号吗？"` (13.5px txt2), actions `cancel "取消"` and `logout_yes "退出"` (red). Confirmed → `AuthService.logout()` → `UserService.invalidateCache()` → `popUntil(isFirst)` → `SessionState.setLoggedIn(false)`.

### Status banners `_buildStatusBanners(dash)` (mutually exclusive, first match wins)
| condition | emoji | text key | color | button |
|---|---|---|---|---|
| `!dash.isActive` | 🚫 | `account_disabled_block` "您的账号已被禁用，无法使用服务。如有疑问，请联系客服" | red | none |
| `subscriptionStatus` non-empty and ≠ `'active'` | 🚫 | `sub_disabled_block` "您的套餐已被禁用或状态异常，无法连接。如有疑问，请联系客服" | red | none |
| `hasSub && remaining <= 0` | ⏰ | `account_expired_block` "您的套餐已到期，购买套餐后即可继续畅连全球节点" | red | `go_renew` → tab 2 |
| `hasSub && total > 0 && online >= total` | 📱 | `devices_full_hint {'cur','limit'}` "设备数已达上限（{cur}/{limit}）：删除不常用设备后，新设备才能连接" | amber | `manage_devices` → push `DevicesPage` |
| `hasSub && 0 < remaining < 7` | ⏰ | `expiring_days {'days'}` "套餐还剩 {days} 天，请及时续费避免中断" | amber | `renew` "去续费" → tab 2 |

`_buildNoticeBanner`: `Container(padding 14/11, radius 14)` gradient `[color@.2, color@.05]`, border `color@.45`, `Row[emoji 16px, 9, Expanded(Text(text, 12px txt, height 1.5)), optional gradient chip (13/7 padding, radius 10, 12px white w600)]`; each banner is followed by `SizedBox(12)`.
`_buildExpiringBanner`: own gradient `[Color(0x33FFB020), Color(0x0DFFB020)]`, border amber@.45, action `renew` "去续费".

### About dialog
`AlertDialog(card2)` title `profile_about` "关于 MoneyFly"; content `'MoneyFly v${UpdateInfo.currentVersion}\n\n${slogan}\ndy.moneyfly.top'` (13px txt2, centered, height 1.7; `slogan` = "极速 · 稳定 · 全球畅连"); single `TextButton ok_btn` "好的".

### Empty / loading / error
No skeleton; disk-cached dashboard is adopted first, then a silent refresh. Silent failure when a cache exists; otherwise spinner (first load) or the cloud-off error+retry block.

### Responsive / desktop
None.

---

## 11. `lib/pages/orders/orders_page.dart` — `OrdersPage`

**Entry**: pushed from ProfilePage (我的订单). Doc: `/// 我的订单：列表 + 待支付订单可继续支付/取消`.

### AppBar
`Icons.arrow_back_ios_new` (18) → pop; title `my_orders` = "我的订单"; action `TextButton(refresh "刷新", color brandLight)` → `_load()`.

### State
| variable | type | initial |
|---|---|---|
| `_orders` | `List<OrderItem>` | `[]` |
| `_loading` | bool | true |
| `_paying` | bool | false (busy guard against double QR dialogs) |
| `_error` | `String?` | load failure (kept distinct from "no orders") |

### Data sources
`OrderService.instance.list()` (`GET /orders`), `.status(orderNo)` (`GET /orders/{orderNo}/status`), `.pay(orderId:, paymentMethodId:)` (`POST /payment`), `.cancel(orderNo)` (`POST /orders/{orderNo}/cancel`); `PaymentService.instance.methods()`; `ApiClient.errorMsg`.

### Body branches
1. `_loading` → centered `CircularProgressIndicator(brand)`.
2. `_error != null` → centered `Column[Icon(Icons.cloud_off, 40, txt3), 10, Text(_error!, 12.5px txt2 centered), 14, gradient retry chip (padding 24/10, radius 12) with `retry` "重试" 13px white w600]`.
3. `_orders.isEmpty` → `MFEmpty(title: no_orders "暂无订单", hint: no_orders_hint "购买套餐后订单会显示在这里")` (default `Icons.inbox_outlined`, 42px `txt3`).
4. else → `ListView.separated(padding fromLTRB(22,8,22,24), separator: SizedBox(10))` of `_buildOrderCard`.

### `_buildOrderCard(o)` — `Container(padding 14, card, radius 16, border line)`
- Row 1: `Expanded(Text(o.packageName ?? order_type {'type': o.type} i.e. "类型：{type}", 14px w600))` + status pill: `Container(padding 9/3, radius 20)` with `color = _statusColor(o.status)@.1` bg and `@.3` border, text `o.statusLabel` (10.5px w600 in that color).
  `_statusColor`: `paid → green`, `pending → amber`, anything else → `txt3`.
- `SizedBox(10)` + Row 2: `'¥${(finalAmount > 0 ? finalAmount : amount).toStringAsFixed(2)}'` (17px w700 kNumFont) + `Spacer` + order no (10.5px txt3 kNumFont).
- If `createdAt` non-empty: Row 3 `'${order_time {'time': ''}}${o.createdAt}'` → renders as "下单时间 2026-03-14 12:00:00" (10.5px txt3) — the placeholder is intentionally empty and the raw timestamp is appended.
- If `status == 'pending'`: `SizedBox(12)` + right-aligned action row:
  - **取消订单** `Container(height 32, padding 14, bg red@.08, radius 10, border red@.3)` with `cancel_order` "取消订单" (11.5px red w600) → `_cancelOrder`.
  - `SizedBox(10)`.
  - **继续支付** `Container(height 32, padding 16, gradient brandGradient, radius 10)` with `pay_again` "继续支付" (11.5px white w600) → `_payOrder`.

### Behavior
- `_payOrder(o)`: guard `_paying`; re-check status → `isPaid` → toast `order_paid` "该订单已支付"; `status != 'pending'` → toast `order_status_tip {'status': raw}` "订单状态：{status}，无法继续支付"; `methods.isEmpty` → `no_pay_methods`; `OrderService.pay(orderId, methods.first.id)`; empty QR → `no_qrcode_retry` "未获取到二维码，请重试"; else `PaymentQrDialog(amount: finalAmount > 0 ? finalAmount : amount, methodName: methods.first.name)`; then `_load()`.
- `_cancelOrder(o)`: `AlertDialog(card2)` title `cancel_order` "取消订单" (16px), content `order_cancel_confirm` "确定取消这笔待支付订单吗？" (13.5px txt2), actions `rethink` "再想想" and `cancel_order` "取消订单" (red). Confirmed → `OrderService.cancel` → reload → toast `order_cancelled` "订单已取消".

### Responsive / desktop
None.

---

## 12. `lib/pages/devices/devices_page.dart` — `DevicesPage`

**Entry**: pushed from ProfilePage, HomePage (banner/dialog), NodesPage (blocked empty state). Doc: `/// 设备管理：列表（全量）/ 删除（踢下线）/ 备注编辑 / 在线状态。` with a note that the top upgrade entry is always visible and online status comes from the backend's recent-activity window.

### AppBar
`Icons.arrow_back_ios_new` (18) → pop; title `device_manage` = "设备管理"; action `TextButton(refresh "刷新", brandLight)` → `_load()`.

### State
`_devices: List<DeviceInfo>`, `_loading = true`, `_deletingId: int?`, `_savingRemarkId: int?`.

### Data sources
`DeviceService.instance.list()` → `GET /subscriptions/devices`; `.delete(id)` → `DELETE /devices/{id}`; `.updateRemark(id, text)` → `PUT /subscriptions/devices/{id}/remark`; `AccountService.instance.sub` for the upgrade card; `ApiClient.errorMsg`.

### Layout (`_loading` → centered spinner; else `ListView(padding fromLTRB(22,8,22,24))`)
1. **Upgrade entry `_buildUpgradeEntry()`** (always rendered):
   `full = limit > 0 && used >= limit`. `GestureDetector` → push `UpgradeDevicesPage`.
   `Container(padding 14/13, radius 14)` with `LinearGradient` built from `[full ? amber : brand, brand@.06]` each `withValues(alpha: full ? .18 : .12)`, border `(full ? amber : brand)@.5`.
   `Row[Text(full ? '📈' : '➕', 17px), 11, Expanded(Column[Text(upgrade_devices_card "升级设备数量", 13.5px w700 txt), 3, Text(full ? device_full_upgrade_banner {'used','limit'} "设备名额已用满 ({used}/{limit}) · 点击增加设备名额" : upgrade_devices_card_sub {'used','limit','expire'} "当前 {used}/{limit} 台 · 到期 {expire} · 点击增加名额，可顺带延长到期时间", 11.5px txt2 height 1.4)]), Icon(Icons.chevron_right, 18, txt3)]`.
   `expireText` = `yyyy-MM-dd` or `—`.
2. `SizedBox(12)`.
3. **Empty**: `Padding(top 90)` + `MFEmpty(title: no_devices "暂无设备", hint: no_devices_hint "连接一次 VPN 后，这里会显示你的设备")`.
4. **Device cards** separated by `SizedBox(10)` — `_buildDeviceCard(d)`:
   - `Container(padding 14, card, radius 16, border line)`.
   - Header Row: `Container(38×38, card2, radius 11, centered)` with the first letter of `d.osName` uppercased (or `📱` fallback), 12, `Expanded(Column[Text(remark.isNotEmpty ? remark : displayName, 14.5px w600 ellipsis), 2, Text([osName, deviceModel].where(nonEmpty).join(' · '), 11px txt3)])`, then the online pill: `Container(padding 8/3, radius 20, bg (green|txt3)@.1, border @.3)` with `online "在线"` / `offline "离线"` (10px w600, color green / txt3).
   - `SizedBox(10)` + metadata `Wrap(spacing 14, runSpacing 6)` built by `_meta(k, v)` → `Row[Text('$k ', 10.5px txt3), Text(v, 10.5px txt2 kNumFont)]`; included only when non-empty:
     - `IP` → `d.ipAddress` (literal "IP")
     - `location` "位置" → `d.location`
     - `version` "版本" → `d.softwareVersion`
     - `access` "访问" → `'${d.accessCount}'` (always present)
     - `recent` "最近" → `d.lastSeen`
   - `SizedBox(12)` + action row of `_ActionBtn`s (`Container(height 34, padding 13, bg color@.08, radius 10, border color@.3)` → `Row[spinner 12×12 or Icon(icon, 14, color), 5, Text(label, 11.5px w600 color)]`):
     - `Icons.edit_outlined` + `edit_remark_btn` "改备注" in `brandLight`, loading while `_savingRemarkId == d.id` → `_editRemark`.
     - `SizedBox(8)`.
     - `Icons.delete_outline` + `delete` "删除" in `red`, loading while `_deletingId == d.id` → `_deleteDevice`.

### Dialogs
- **Edit remark**: `AlertDialog(card2)` title `edit_remark` "修改备注" (16px); content `TextField(autofocus, maxLength: 200, fontSize 14, hint: remark_hint "给这台设备起个名字（可清空）" 13px txt3)`; actions `cancel_text` "取消" and `save` "保存" (`brandLight` w600). Result → `updateRemark` → reload → toast `remark_saved` "备注已保存".
- **Delete device**: `AlertDialog(card2)` title `delete_device` "删除设备" (16px); content `delete_device_body {'name': displayName}` = "确定删除「{name}」吗？\n删除 = 踢下线：该设备将被移除并立即断开，再次拉取订阅会收到「已被移除」提示，无法继续使用。" (13.5px txt2, height 1.6); actions `cancel_text` "取消" and `delete` "删除" (red w600). Confirmed → delete → reload → toast `device_deleted` "设备已删除并下线".

### Empty / loading / error
Spinner while loading; `MFEmpty` for an empty list; API errors → `ApiClient.errorMsg` SnackBar (no dedicated error view — the upgrade entry stays visible).

### Responsive / desktop
None.

---

## 13. `lib/pages/notifications/notifications_page.dart` — `NotificationsPage`

**Entry**: pushed from ProfilePage (通知中心). Doc: `/// 通知中心：列表 / 已读 / 全部已读 / 删除`.

### AppBar
`Icons.arrow_back_ios_new` (18) → pop; title `notify_center` = "通知中心"; action shown **only when some item is unread**: `TextButton(mark_all_read "全部已读", brandLight)` → `_markAll()`.

### State
`_items: List<AppNotification>`, `_loading = true`, `_error: String?`.

### Data sources
`NotificationService.instance.list()` → `GET /notifications`; `.markRead(id)` → `PUT /notifications/{id}/read`; `.markAllRead()` → `PUT /notifications/read-all`; `.delete(id)` → `DELETE /notifications/{id}`; `ApiClient.errorMsg`.

### Body branches
Same 4-branch pattern as OrdersPage: spinner / cloud-off error + `retry` chip / `MFEmpty(title: no_notifications "暂无通知")` / `ListView.separated(padding fromLTRB(22,8,22,24), separator SizedBox(10))`.

### Notification card
`GestureDetector(onTap: _markRead(n), onLongPress: _delete(n))` → `Container(padding 14, radius 15)`:
- Read: `color: card`, `border: line`, title color `txt2`.
- Unread: `color: brand@.07`, `border: brand@.35`, title color `txt`, plus a 7×7 `brandLight` dot before the title (`SizedBox(7)` gap).
- Row: `[optional dot] Expanded(Text(n.title, 13.5px w600)) Text(_formatTime(n.createdAt), 10px txt3 kNumFont)`.
- If content non-empty: `SizedBox(8)` + `Text(n.content, 12.5px txt2, height 1.6)`.
- `_formatTime`: RFC3339 (contains `T`) → `'MM-dd HH:mm'`; otherwise `raw.substring(5,16)` when longer than 16 chars (yields `MM-dd HH:mm:ss`-style).

### Dialogs / toasts
- Long-press → `AlertDialog(card2)` title `delete_notify` "删除通知" (16px), content `delete_notify_body` "确定删除这条通知吗？" (13.5px txt2), actions `cancel` "取消" / `delete` "删除" (red).
- `_markAll` success → toast `marked_read` "已全部标记为已读".
- Errors → `ApiClient.errorMsg` toast. Marking read is a no-op when already read (`if (n.isRead) return`).

### Responsive / desktop
None. Note: the "delete" affordance is **long-press only** — on desktop this is a discoverability gap (no context menu, no trailing button).

---

## 14. `lib/pages/settings/settings_page.dart` — `SettingsPage` (1105 lines)

**Entry**: pushed from HomePage header gear and ProfilePage menu row (设置). Doc: `/// 设置页（设计稿 09）：完整清单 + 持久化`.

### State
`_s: Map<String, dynamic>` (merged `SettingsStore.load()`), `_loaded: bool`, `_checkingUpdate: bool`.
Statics: `_rowRadius = circular(14)`, `_iconRadius = circular(9)`, `_defaultDnsServers = ['223.5.5.5','119.29.29.29']`.
Constants used inside: `_defaultDnsServers`; `ConnectionController.defaultTestUrl` = `https://www.gstatic.com/generate_204`.

### Persistence
`_set(key, value)` → `setState(_s[key] = value)` → `ConnectionController.instance.applySettings(_s)` (immediate effect for autoTest / reconnect / defaultMode / testUrl / tunMode) → `SettingsStore.instance.update((s) => s[key] = value)` (single-key serial queue).

### AppBar
`Icons.arrow_back_ios_new` (18) → pop; title `settings_title` "设置"; action `TextButton(restore_default "恢复默认", 12.5px txt3)` → `SettingsStore.reset()` + reload + `applySettings(defaults)` + `ThemeController.setAppearance(defaults['appearance'] ?? 'light')` + toast `restored` "已恢复默认设置".

### Body — `ListView(padding fromLTRB(22,4,22,32))`; while `!_loaded` a full-page spinner (`brand`)

Row primitives:
- `_section(title)` → `Padding(fromLTRB(2,14,2,8))` + `Text(title, 11px txt3 w700 letterSpacing 2)`.
- `_row({icon, title, desc, value, trailing, danger, showDot, onTap})` → `Container(margin bottom 8, padding horizontal 15, **height 52**, card, radius 14, border line)` + `InkWell(radius 14, onTap)`:
  `Row[Container(28×28, bg danger ? red@.12 : card2, radius 9, centered: Text(icon, 12px)), 11, Expanded(Column(center,start)[Text(title, 13.5px w500, color danger ? red : txt), if desc: Text(desc, 10px txt3)]), if value: ConstrainedBox(maxWidth 150, Text(value, 12px txt3 kNumFont, end-aligned, ellipsis)), if showDot: 5 + RedDot(7), if value != null || onTap != null: 4 + Icon(Icons.chevron_right, 17, txt3), ?trailing]`.
- `_switch(value, onChanged)` → `Transform.scale(scale: .82, child: Switch(...))`.
- `_seg2({left, right, selectedLeft, onLeft, onRight})` → `Container(padding 2, color card2, radius 9)` + two chips (padding 11/6, radius 7; selected has `brandGradient` + white text; unselected transparent + `txt3`), 11px w600.

### Complete row list, in source order

**§ `group_connect` "连接与线路"**
| # | icon | title key | label | desc | value / trailing | action |
|---|---|---|---|---|---|---|
| 1 | 🎯 | `settings_default_mode` | 默认模式 | — | `_seg2(left: smart_mode "智能模式", right: global_mode "全局模式", selectedLeft: _s['defaultMode'] != 'global')` | sets `defaultMode` = `smart` / `global` |
| 2 | 🔌 | `settings_auto_connect` | 启动时自动连接 | — | `_switch(_s['autoConnect'] == true)` | `autoConnect` |
| 3* | 🚀 | `settings_launch_startup` | 开机自启动 | — | `_switch(_s['launchAtStartup'] == true)` | sets key then `launchAtStartup.enable()/disable()` |
| 4* | 🚪 | `close_action` | 关闭窗口行为 | — | `_closeActionLabel()` ∈ {`close_action_ask` "每次询问", `close_action_hide` "最小化到托盘", `close_action_quit` "退出程序"} | `_pickCloseAction()` → `_picker` |
| 5 | ⚡ | `settings_auto_test` | 自动测速并选最优 | `settings_auto_test_desc` "连接前测速全部节点" | `_switch(_s['autoTest'] == true)` | `autoTest` |
| 6 | 🔁 | `settings_reconnect` | 断线自动重连 | `settings_reconnect_desc` "断线后自动换最优节点重连；内核异常退出时始终自动恢复" | `_switch(_s['autoReconnect'] == true)` | `autoReconnect` |
| 7 | ⏱️ | `settings_test_interval` | 后台测速间隔 | — | `'${_s['testIntervalMin'] ?? 30} 分钟'` | `_picker(['15 分钟','30 分钟','60 分钟'])` → `testIntervalMin` |
| 8 | 🧭 | `settings_test_url` | 测速地址 | `settings_test_url_desc` "测速/延迟测试探测地址，默认谷歌 204" | `_testUrlHost()` = `Uri.host` of the configured URL | `_pickTestUrl()` dialog |

`*` rows 3 and 4 are rendered only when `Platform.isMacOS || Platform.isWindows || Platform.isLinux`.

**§ `group_proxy` "代理与分流"**
| # | icon | title | desc | value | action |
|---|---|---|---|---|---|
| 9 | 🚀 | `settings_tun` "TUN 虚拟网卡" (only when `!Platform.isAndroid`) | `_tunDesc()` | `tun_off` "关闭" / `tun_force` "强制" / `tun_auto` "自动" | `_pickTunMode()` |
| 9-alt | 🧱 | `settings_tun_stack` "TUN 内核栈" (only when `Platform.isAndroid`) | `settings_tun_stack_desc` "连接异常（打不开网页等）时可切换试试" | `tun_stack_gvisor` "gvisor（兼容优先）" / `tun_stack_mixed` "mixed（速度优先）" | `_picker` → `tunStack` |
| 10 | 🌐 | `settings_dns` "DNS 服务器" | `settings_dns_desc` "主 DNS 列表，逗号分隔；多个可提升解析成功率" | `_dnsList().join(', ')` | `_pickDnsList()` |
| 11 | 🧭 | `settings_dns_mode` "DNS 模式" | `settings_dns_mode_desc` "解析异常（打不开网页/部分站点失败）时可切换" | `dns_mode_auto` "自动（推荐）" / `dns_mode_fakeip` "fake-ip" / `dns_mode_redirhost` "redir-host（传统）" | `_picker` → `dnsMode` |
| 12 | 🧩 | `settings_fakeip_extra` "fake-ip 过滤域名" | `settings_fakeip_extra_desc` "追加保留真实解析、不映射 fake-ip 的域名" | count of `_fakeIpExtra()` | `_pickFakeIpFilter()` |
| 13 | 🔓 | `settings_udp_insecure` "放宽 hy2/tuic 证书校验" | `settings_udp_insecure_desc` "hysteria2/tuic 节点普遍使用伪装 SNI，证书必然对不上；关闭校验才能连上（默认开）" | `_switch(_s['udpSkipCertVerify'] != false)` (default ON) | `udpSkipCertVerify` |
| 14 | 🏠 | `settings_bypass_lan` "绕过局域网流量" | — | `_switch(_s['bypassLan'] == true)` (default ON) | `bypassLan` |
| 15 | 🚫 | `settings_bypass` "直连名单" | `settings_bypass_desc` "指定域名不走代理" | `'${bypassDomains.length}'` | push `BypassPage` |
| 16 | 📱 | `settings_access` "应用代理" (Android only) | `settings_access_desc` "按 App 分流 / 排除（Android）" | `_accessModeValue()` ∈ {`access_mode_all` "全部走代理", `access_mode_selected` "仅以下应用走代理", `access_mode_denied` "排除以下应用"} | push `AccessPage` |

`_tunDesc()`: `off` → `tun_off_hint` "仅系统代理：仅浏览器等 HTTP 应用生效，Steam/游戏等 UDP 流量不走代理"; Android/iOS → null; Windows → `tun_need_admin` "需要以管理员身份运行"; macOS → `tun_need_root` "需要管理员权限"; else null.

**§ `group_network` "网络与端口"**
| # | icon | title | desc | value | action |
|---|---|---|---|---|---|
| 17 | 🔢 | `settings_local_port` "本地代理端口" | `settings_local_port_desc` "自定义本机代理端口（默认 2080）" | `'${_s['localPort'] ?? 2080}'` | `_pickLocalPort()` |
| 18 | 🔧 | `settings_clash_api_port` "Clash API 端口" | `settings_clash_api_port_desc` "内核管理端口（切节点/测速/流量），默认 9090" | `'${_s['clashApiPort'] ?? 9090}'` | `_pickClashApiPort()` |

**§ `group_kernel` "内核与数据"**
| # | icon | title | desc | action |
|---|---|---|---|---|
| 19 | 🧩 | `settings_kernel` "内核管理" | `'MetaCubeX/mihomo'` (literal) | push `KernelPage` |
| 20 | 🌍 | `settings_geo_data` "更新分流数据" | `settings_geo_data_desc` "国家 IP 库 / 分流规则（内置，可手动更新）" | push `GeoUpdatePage` |

**§ `group_appearance` "外观"**
| # | icon | title | value | action |
|---|---|---|---|---|
| 21 | 🎨 | `settings_theme` "外观模式" (special `_appearanceRow`) | current label in `brand` w600 | 6 tappable swatches |
| 22 | 🌏 | `settings_language` "语言" | `AppStrings.lang == 'en' ? 'English' : '简体中文'` | `_pickLanguage()` |
| 23 | 🪪 | `settings_subscribe_ua` "订阅 User-Agent" | `settings_subscribe_ua_default` "默认" or the stored UA | `_pickSubscribeUa()` |

**`_appearanceRow()`** — `Container(margin bottom 8, padding horizontal 15 / vertical 12, card, radius 15, border line)`:
- Header Row: 28×28 `card2` tile with `Text('🎨', 12px)`, 11, `Expanded(Text(settings_theme "外观模式", 13.5px w500 txt))`, current appearmance label (`AppStrings.t(mfThemeLabels[current])`) in 12px `brand` w600.
- `SizedBox(12)` + `Wrap(spacing 10, runSpacing 10)` of 6 swatches (`for (final key in mfThemeKeys)`), each `GestureDetector(onTap: setAppearance(key) + _set('appearance', key))`:
  - `Container(42×30, color: mfThemeOf(key).card, radius 8, border current ? brand w2 : mfThemeOf(key).line w1)` with an inner 11×11 circle in `mfThemeOf(key).brand`.
  - `SizedBox(4)` + `Text(AppStrings.t(mfThemeLabels[key]), 10px, color current ? brand : txt3, weight current ? w700 : w500)`.
  - Labels: 浅色 / 暖白 / 浅灰 / 深灰 / 深蓝 / 纯黑 (en: Light / Warm / Light Gray / Dark Gray / Dark Blue / Pure Black).

**§ `group_account` "账户"**
| # | icon | title | desc | danger | action |
|---|---|---|---|---|---|
| 24 | 🔑 | `settings_change_pwd` "修改密码" | `cur_pwd` "当前密码" | — | push `ChangePasswordPage` |
| 25 | 🧹 | `settings_clear_data` "清除本地数据" | `settings_clear_data_desc` "清空订阅配置缓存、节点与运行日志（保留登录）" | **danger** (red text + `red@.12` icon tile) | `_clearLocalData()` |

**§ `group_about` "关于与诊断"**
| # | icon | title | desc | value | notes |
|---|---|---|---|---|---|
| 26 | 🔄 | `settings_check_update` "检查更新" | — | `'v${UpdateInfo.currentVersion}'`, `showDot: hasUpdate` (wrapped in `ValueListenableBuilder(UpdateService.hasUpdate)`) | `_checkUpdate()` |
| 27 | 📋 | `log_center_title` "日志中心" | `log_center_desc` "内核引擎与 App 运行日志" | — | push `LogCenterPage` |
| 28 | 💥 | `settings_crash_report` "崩溃日志记录" | `settings_crash_report_desc` "开启后在本地记录崩溃详情，便于向客服反馈排查（不会自动上传）" | `_switch(_s['crashReport'] == true)` → `CrashLogger.setEnabled(v)` | |

**Footer**: `SizedBox(12)` + `Center(Text('MoneyFly v${UpdateInfo.currentVersion} · dy.moneyfly.top', 10.5px txt3 kNumFont))` (hard-coded, not i18n).

### Dialogs owned by SettingsPage
| dialog | title | content | actions |
|---|---|---|---|
| port (`_askPort`) | row title | `TextField` (numeric, autofocus) with `mfInput(hint, helper: settings_local_port_desc or clash_api_port_desc)`, style `txt` | `cancel_text` "取消" / `save` "保存" (`brandLight`) |
| `_pickTestUrl` | `settings_test_url` (15px w700) | `TextField(url, autofocus)` `mfInput(hint: defaultTestUrl, helper: settings_test_url_desc)` | 取消 / 保存 |
| `_pickSubscribeUa` | `settings_subscribe_ua` | `TextField(autofocus)` `mfInput(hint: 'clash-verge/v2.0.0', helper: settings_subscribe_ua_desc)` | 取消 / 保存 |
| `_pickDnsList` | `settings_dns` | `TextField(minLines 2, maxLines 5, url keyboard)` `mfInput(hint: dns_list_hint "用逗号分隔，如 223.5.5.5,119.29.29.29")` | 取消 / 保存 |
| `_pickFakeIpFilter` | `settings_fakeip_extra` | `TextField(minLines 3, maxLines 6, multiline, 13px)` `mfInput(hint: fakeip_extra_hint "每行一个域名，如 *.lan 或 router.local")` | 取消 / 保存 |
| `_pickTunMode` | `SimpleDialog(card2)` title `tun_title` "TUN 虚拟网卡" | desktop warning box (`amber@.1` bg, `amber@.3` border, radius 10) with `tun_win_hint` or `tun_mac_hint`; 3 `SimpleDialogOption`s `tun_auto/tun_force/tun_off` each with a right-aligned sub-label (`tun_dual` "TUN+代理" / `tun_full_intercept` "全局接管" / `tun_only_proxy` "仅系统代理"); trailing amber box with `tun_game_tip` "提示：游戏/语音等 UDP 应用需选择「自动」或「强制」TUN 模式（Windows/macOS 需以管理员权限运行）" | — |
| `_pickLanguage` | `SimpleDialog` title **hard-coded `Text('Language')`** | options `AppStrings.t('zh')` "简体中文" and `AppStrings.t('en')` "English"; the active one shows a trailing `Icon(Icons.check, 16, brandLight)` | — |
| `_clearLocalData` | `AlertDialog` title `settings_clear_data` (16px w700) | `clear_data_confirm` "将断开连接并清除已缓存的订阅配置、节点与运行日志，保留登录状态。卸载或换机前建议先清除。是否继续？" (13.5px txt2 height 1.6) | `cancel_text` / `confirm` "确定" (**red** w600) |
| `_checkUpdate` result | `new_version` "发现新版本" or `new_version_forced` "发现新版本（强制更新）" (16px w700; `barrierDismissible: !info.forced`) | `update_body {'cur','latest','size'}` = "当前版本 v{cur}\n最新版本 v{latest}{size}\n\n请下载最新安装包体验新功能。" (13px txt2 height 1.7) | if not forced: `later` "稍后"; `download_now` "立即下载" (`brandLight` w600) → `launchUrl(downloadUrl, externalApplication)`; missing URL → `no_download_url` "下载链接暂未配置"; open failure → `cannot_open_url` "无法打开下载链接" |
| `_picker` generic | `SimpleDialog(card2)` title `pick_option` "请选择" | `SimpleDialogOption` per string (13.5px `txt`) | — |

### Behaviors / toasts
- `_pickLocalPort` / `_pickClashApiPort`: validation 1024–65535 and must differ from the other port → `local_port_invalid` "端口需在 1024–65535，且不能与 Clash API 端口相同" / `clash_api_port_invalid` "端口需在 1024–65535，且不能与本地代理端口相同"; then `_applyPortChange`: if connected → toast `local_port_reconnect` "端口已更新，正在自动重连…" + disconnect/connect; else toast `local_port_saved` "端口已保存，下次连接生效".
- `_pickTestUrl` must start with `http://`/`https://` else `test_url_invalid` "请输入 http:// 或 https:// 开头的有效地址".
- DNS list: split on `,`/`，`/newlines, dedupe case-insensitively; empty → `dns_list_required` "请至少保留一个 DNS 服务器"; invalid entry #n → `dns_list_invalid {'n'}` "第 {n} 个 DNS 服务器格式不正确". Valid forms: IPv4 (`_isIpv4`), IPv6, hostname (`_isHostname`, ≤253 chars, no `..`, regex), or URL with `://` and a non-empty host.
- fake-ip entries: normalized lowercase, optional `*.` wildcard kept, invalid line → `fakeip_invalid {'line'}` "第 {line} 行不是合法的域名".
- `_pickTunMode` applies immediately: connected → toast `setting_reconnect_applied` "设置已更新，正在重连以生效…" + disconnect/connect; else `setting_saved_next_connect` "已保存，下次连接生效".
- `_clearLocalData`: disconnect when connected/connecting/reconnecting → `SubscriptionService.clearCache()` → `conn.loadNodes(const [])` → `AppLog.clear()` → toast `clear_data_done` "本地数据已清除" or `clear_data_failed` "清除失败，请重试".
- `_checkUpdate`: `_checkingUpdate` guard; `null` → `check_update_fail` "检查更新失败，请检查网络后重试"; not newer → `latest_version {'ver'}` "已是最新版本 v{ver}".
- All toasts use the default SnackBar.

### Responsive / desktop / platform-specific
- Rows 3–4 (开机自启动 / 关闭窗口行为) desktop-only.
- Row 9 TUN desktop (non-Android); row 9-alt TUN stack Android-only; row 16 应用代理 Android-only.
- TUN dialog shows the platform-specific warning box and `_tunDesc()` text differs per platform.
- No width-based layout adaptation.

---

## 15. `lib/pages/settings/kernel_page.dart` — `KernelPage`

**Entry**: pushed from SettingsPage (内核管理). Doc: `/// 内核管理页：显示当前内置 mihomo 版本、官方最新版本；桌面端可直接下载官方预编译内核并替换（FlClash 同款能力）。`

### AppBar
`Icons.arrow_back_ios_new` (18) → pop; title `kernel_title` "内核管理".

### State
`_current: String?`, `_latest: String?`, `_checking = false`, `_downloading = false`, `_progress = 0.0`, `_error: String?`, `_supportsVariant = false`, `_hasUserKernel = false`, `_restoring = false`, `_variant: KernelVariant = compatible`. Statics `_radius = 14`, `_iconRadius = 9`.

### Data sources
`KernelManager.instance.detectCurrent() / currentVariant() / fetchLatest() / downloadToCache(version, variant, onProgress) / activateCached(version, variant) / setVariant(v)`; `KernelManager.supportsVariant`, `KernelManager.hasUserKernel()`, `KernelManager.isDesktop`, `KernelManager.compare(l, c)`, `KernelManager.restoreBuiltin()`, `KernelManager.builtinVariantForPlatform()`; `ConnectionController.instance.status / disconnect() / connect()`.

### Layout — `ListView(padding fromLTRB(22,4,22,32))`, rows via local `_row` (same 52-px card pattern as settings) + `_section`
1. `_section(settings_kernel "内核管理")`
2. `_row(🧩, kernel_current "当前内核", value: 'v$_current' or kernel_version_unknown "未知")` — no tap.
3. `_row(⚡, kernel_running_state "连接状态", value: kernel_running "运行中" / kernel_stopped "未连接")` — driven by `ConnectionController.status == connected`.
4. **Desktop branch** (`KernelManager.isDesktop`):
   - `_section('mihomo')` (literal).
   - While `_checking`: `Padding(vertical 10)` + centered 18×18 spinner.
   - Else: `_row(🆕, kernel_latest "官方最新", value 'v$_latest' or 未知, onTap: _check)`; then
     - if `_error != null`: red 11px text (`kernel_fetch_latest_fail {'err':'network'}` = "检查更新失败：{err}").
     - if `_hasNewer`: `Container(margin top 4)` → `_row(⬇️, kernel_new_found {'ver': 'v$_latest'} "发现新内核 v{ver}", desc: kernel_update_desc "更新后需重新连接生效；连接中请先断开", onTap: _downloading ? null : _update)`.
     - else if `_current != null`: `Padding(fromLTRB(4,2,4,4))` + `Text(kernel_up_to_date {'ver': 'v$_current'} "已是最新内核 v{ver}", 12px txt2)`.
   - While `_downloading`: `Padding(vertical 8)` + `Column[Text(kernel_downloading {'pct'} "下载中 {pct}%", 12px txt2), 6, LinearProgressIndicator(value: _progress, minHeight 4, radius 2, backgroundColor: card2)]`.
   - While `_restoring`: `Padding(vertical 8)` + `Row[14×14 spinner, 10, Text(kernel_restoring "正在恢复内置内核…", 12px txt2)]`.
   - If `_supportsVariant`: `_row(🔀, kernel_variant_title "内核变体", desc: kernel_variant_desc "下拉切换构建类型；同版本已下载过的不再重复下载", value: '${_variantLabel(_variant)} ▾', onTap: _downloading ? null : _pickVariant)`.
5. **Android branch**: `Padding(fromLTRB(4,10,4,4))` + `Text(kernel_android_ver {'ver'} "内置 v{ver}"`, 13px txt) and `Padding(fromLTRB(4,4,4,4))` + `Text(kernel_android_update_tip "Android 端内核随 App 版本一起发布，请留意新版 App", 11.5px txt3)`.
6. `SizedBox(14)` + `Text(kernel_source "内核来源：MetaCubeX/mihomo（官方原版，非 fork）", 10.5px txt3)`.

### Variant bottom sheet `_pickVariant()` — `showModalBottomSheet<String>(backgroundColor: card, radius top 20)`
- `SizedBox(10)` + title `kernel_variant_title` "内核变体" (16px w700).
- `_sheetOption(compatible)`: label `kernel_variant_compatible` "兼容版", desc `kernel_variant_compatible_desc` "兼容老 CPU，启动稳定（默认，推荐）".
- `_sheetOption(standard)`: label `kernel_variant_standard` "标准版", desc `kernel_variant_standard_desc` "按新指令集编译，较新 CPU 性能更好".
- If `_hasUserKernel`: `Divider(color: line)` + `_sheetOption(restore)` label `kernel_restore_builtin` "恢复内置内核" (red = danger), desc `kernel_restore_builtin_desc` "删除用户切换的副本，回到安装包自带内核（无需下载）".
- `_sheetOption` = `InkWell(pop(value))` → `Padding(horizontal 24, vertical 12)` `Row[Expanded(Column[Text(label, 14px w600, danger ? red : txt), 2, Text(desc, 11px txt3, height 1.4)]), if selected: Icon(Icons.check_circle, 18, brandLight)]`.
- `SizedBox(8)`.

### Dialogs / flows
- `_switchVariant(v)`: ignores when downloading or already active; unknown current version → toast `kernel_version_unknown` "未知"; confirmation `AlertDialog(card2)` title `kernel_switch_title` "切换内核变体" (16px w700), content `kernel_switch_confirm {'label'}` "切换为「{label}」：本地已缓存同版本则立即生效，否则需下载一次（约 40MB，连接中经隧道下载）。是否继续？", actions `cancel_text` "取消" / `confirm` "确定" (`brandLight` w600). On success → `setVariant(v)`, `_variant = v`, `_hasUserKernel = true`.
- `_downloadAndApply(version, variant, doneMsg, onApplied)` two-phase flow: download to cache (allowed **while connected**, tunneled) → if `ConnectionController.status == connected`, ask `AlertDialog(card2)` title `kernel_apply_now_title` "内核已下载完成", content `kernel_apply_now_text` "替换内核需要先断开当前连接。\n立即断开替换并自动重连，还是稍后手动断开再替换？", actions `kernel_apply_later` "稍后替换" / `kernel_apply_now` "立即替换并重连" (`brandLight` w600). Choosing later → toast `kernel_apply_later_tip` "内核已下载到本地缓存，断开连接后再来本页替换（无需重新下载）". Choosing now → disconnect → `activateCached` → toast `doneMsg()` → auto `connect()`. Errors: `kernel_update_desc` when `err == 'kernel_running'`, else `kernel_update_fail {'err'}` "内核更新失败：{err}" (floating SnackBar, `card2` bg, 13px).
- `_update()` → `kernel_download_done {'ver'}` "内核已更新至 v{ver}，重新连接即生效".
- `_switchVariant` success message → `kernel_switch_done {'label'}` "内核已切换为{label}（无需重复下载），断开重连后生效".
- `_restoreKernel()`: refuses while connected → toast `kernel_update_desc`; else `AlertDialog(card2)` title `kernel_restore_builtin` "恢复内置内核", content `kernel_restore_confirm` "将删除用户切换/更新的内核副本，恢复为安装包内置内核（无需下载）。是否继续？", actions `cancel_text` / `confirm` (**red** w600) → `restoreBuiltin()` → `kernel_restore_done` "已恢复为内置内核" or `kernel_update_fail {'err':'restore'}`.

### Empty / loading / error
Checking spinner row; download progress bar; `_error` red text under the latest row; toasts for every failure path. No empty state (row-based status display).

### Responsive / desktop
The entire update/variant/download UI is desktop-only (`KernelManager.isDesktop`); Android gets a static two-line version notice. No width adaptation.

---

## 16. `lib/pages/settings/log_center_page.dart` — `LogCenterPage`

**Entry**: pushed from SettingsPage (日志中心). Doc: `/// 日志中心：两个 Tab — 内核日志（实时）… 运行日志…`.

### Structure — `DefaultTabController(length: 2)`
- AppBar: `Icons.arrow_back_ios_new` (18) → pop; title `log_center_title` "日志中心"; `bottom: TabBar(indicatorColor: brand, indicatorSize: label, labelColor: brand, unselectedLabelColor: txt3, labelStyle 13.5px w600, unselectedLabelStyle 13.5px)` with tabs `settings_kernel_log` "内核日志" and `settings_log` "运行日志".
- Body: `TabBarView([_KernelLogTab(), _AppLogTab()])`.

### 16a. `_KernelLogTab` (stateful, `AutomaticKeepAliveClientMixin`, `wantKeepAlive = true`)
State: `_lines: List<String>` (cap `_maxLines = 600`), `_streamSub`, `_pollTimer`, `_level = 'warning'`, `_levels = ['debug','info','warning','error','silent']`, `_pollBusy`, `_cursorReset`.
Sources: `SettingsStore['kernelLogLevel']`; desktop → `ProxyCoreCli.logTailSnapshot()` + `ProxyCoreCli.kernelLogStream.stream`; Android → `MethodChannel('top.moneyfly/vpn_core').invokeMethod('fetchKernelLogs', {incremental: true, reset: _cursorReset})` polled every 1200 ms with up to 8 drain rounds per tick; `ConnectionController.instance.setKernelLogLevel(lv)`.

Layout:
1. **Toolbar** `Padding(fromLTRB(16,6,8,4))` `Row`:
   - `Text(kernel_log_level "级别", 11px txt3)`, 8.
   - `Flexible(SingleChildScrollView(horizontal))` of 5 level chips (padding 10/5, margin-right 6, radius 8): selected → `brandGradient` + white text, transparent border; unselected → `card` + `line` + `txt2`; text `lv.toUpperCase()` (10.5px w700) → `_setLevel(lv)`.
   - 8 · a 7×7 status dot (`green` when connected else `txt3`) · 4 · `Text(running ? '' : kernel_stopped "未连接", 10px, green/txt3)`.
   - `IconButton(Icons.copy, 17, tooltip: copy "复制")` → `_copyAll()` (copies the **visible/filtered** lines; empty → no-op; success SnackBar `kernel_log_copied` "日志已复制", floating `card2`, 1 s).
   - `IconButton(Icons.delete_outline, 18, tooltip: clear_log "清空")` → `setState(_lines.clear)`.
2. `Padding(fromLTRB(16,0,16,6))` + `Text(kernel_log_level_desc "级别同时作用于内核输出与本页显示：debug 最详细，error 只显示错误行", 10px txt3 height 1.4)`.
3. `Divider(height 1, color line)`.
4. **Log area** `Expanded`: empty → centered `Text(_lines.isEmpty ? kernel_log_empty "暂无日志\n连接后实时产生（切 debug 可看更多）" : kernel_log_empty_at_level {'level'} "当前级别（{level}）下暂无日志\n切到 debug 可看全部输出", 12px txt3 height 1.7, centered)`; else `ListView.builder(padding symmetric(14,10))` rendering `_visibleLines[length-1-i]` (**newest first**, no `reverse`) as `SelectableText(line, 10.5px, height 1.55, color `_lineColor`, kNumFont)` with `vertical 1` padding per row.
   - `_lineColor`: error/panic/fatal/exception → `Color(0xFFFF6B6B)`; warning/warn → `Color(0xFFE0A93C)`; debug → `Color(0xFF8FB4E8)`; else `MFColors.txt2`.
   - `_visibleLines`: filters by `_levelRank(_lineLevel(l)) >= _levelRank(_level)` (debug 0 / info 1 / warning 2 / error 3 / silent 4), level parsed from `level=xxx` in the mihomo line.
   - `_setLevel` also PATCHes the kernel level; if connected but the hot update failed → SnackBar `log_level_need_reconnect` "日志级别已保存，重连后生效" (floating card2, 2 s).

### 16b. `_AppLogTab` (stateful, keep-alive too)
State: `_lines`, `_loading = true`, `_filterError = false`. Source: `AppLog.read()` / `AppLog.clear()`.
Layout:
1. **Toolbar** `Padding(fromLTRB(16,6,8,0))` `Row`:
   - `Expanded(Text(app_log_desc "运行记录（[APP]/[NET]/[KERNEL]）。[ERROR] 是「错误级别的一条记录」（如连接失败），不等于崩溃；崩溃日志是 Dart 未捕获异常，单独存于文档目录 crash_logs/。", 10.5px txt3))`.
   - `IconButton(Icons.refresh, 17, tooltip: refresh "刷新")` → `_load()`.
   - `IconButton(_filterError ? Icons.filter_alt : Icons.filter_alt_outlined, 17, tooltip: log_only_errors "只看错误", color: _filterError ? brandLight : null)` → toggles.
   - `IconButton(Icons.copy, 17, tooltip: copy "复制")` → copies visible lines → SnackBar `kernel_log_copied`.
   - `IconButton(Icons.delete_outline, 18, tooltip: clear_log "清空")` → `_clear()` (confirm dialog).
2. `Divider(height 1, line)`.
3. `Expanded`: `_loading` → centered spinner; `_lines.isEmpty` → `log_empty "暂无日志"`; `_visible.isEmpty` → `log_no_errors "暂无错误日志"`; else `ListView.builder` with newest-first `SelectableText` (10.5px, height 1.6, `kNumFont`), error lines in `Color(0xFFFF6B6B)` else `txt2`.
   `_isErrorLine`: contains `[ERROR]` or lowercased `level=error`.
4. Clear confirm: `AlertDialog(card2)` title `clear_log` "清空" (15px), content `log_clear_confirm` "清空全部运行日志？" (13px txt2), actions `cancel_text` "取消" / `clear_log` (red).

### Responsive / desktop
Only the log source differs (`Platform.isAndroid` → MethodChannel polling; desktop → file tail snapshot + stream). No layout adaptation.

---

## 17. `lib/pages/settings/access_page.dart` — `AccessPage` (Android only)

**Entry**: pushed from SettingsPage (应用代理 row, Android only). Doc: `/// 按 App 分流/排除（Android AccessControl）… 三种模式…更改即时保存；重连（或下次连接）后生效`.

### AppBar
`Icons.arrow_back_ios_new` (18) → pop; title `access_title` "应用代理"; action `TextButton` showing `access_reconnect_btn` "重连生效" (when connected, `brand`) or `access_saved_tip` "更改已保存 · 重连或下次连接后生效" (when not connected, `txt3`), 11.5px → `_reconnect()`.

### State
`_apps: List<Map<String,String>>`, `_mode = 'all'`, `_selected: Set<String>`, `_query = ''`, `_loading = true`. Channel: `MethodChannel('top.moneyfly/vpn_core')`.

### Data sources
`SettingsStore.load()` → `accessControlMode` / `accessControlApps`; `SettingsStore.update(...)` on every change; `_channel.invokeListMethod<Map>('getInstalledApps')` → package/label pairs (app label falls back to the package name); `ConnectionController.instance.status / disconnect() / connect()`.

### Layout — `Column(crossAxisAlignment: start)`
1. `Padding(fromLTRB(20,4,20,0))` + `Text(access_desc)` = "控制哪些 App 走代理。支付/银行类 App 建议排除（避免异地风控），需要原生 IP 的 App（如某些游戏）也建议排除。" (11.5px txt3 height 1.6).
2. `SizedBox(10)`.
3. **Mode selector** `Padding(horizontal 20)` + `Container(padding 3, card2, radius 11)` + `Row` of three equal `_modeBtn`s:
   - `all` → `access_mode_all` "全部走代理"
   - `selected` → `access_mode_selected` "仅以下应用走代理"
   - `denied` → `access_mode_denied` "排除以下应用"
   `_modeBtn` = `Expanded(GestureDetector)` → `Container(padding vertical 8, radius 8, gradient brandGradient when active)` with centered `Text(label, 11px w600, active ? white : txt3)`. Tap → `_setMode` + `_save()`.
4. **Hint box** `Padding(fromLTRB(20,8,20,0))` + `Container(padding 12/8, bg brand@.07, radius 10, border brand@.18)` with `Text` switching on `_mode`: `access_hint_all` "所有应用的流量都走代理" / `access_hint_selected` "✓ 勾选的应用走代理 · 未勾选的应用直连（含 MoneyFly 自身）" / `access_hint_denied` "勾选的应用直连（绕过代理）· 其余应用走代理" (11px txt2, height 1.5).
5. `Padding(fromLTRB(20,6,20,0))` + `Text('${access_sel_count {'n'}} · ${access_saved_tip}')` e.g. "已选 3 个 · 更改已保存 · 重连或下次连接后生效" (10.5px txt3).
6. **Search** `Padding(fromLTRB(20,10,20,4))` + `SizedBox(height 44, TextField)` `mfInput(hint: access_search_hint "搜索应用")` + `prefixIcon: Icon(Icons.search, 17, txt3)` + `contentPadding symmetric(12,11)`; filters on label **or** package substring.
7. **List** `Expanded`:
   - `_loading` → centered spinner (`brand`).
   - `_filtered.isEmpty` → centered `Text(_apps.isEmpty ? access_empty_perm "未能读取应用列表\n请到系统设置 → 应用 → MoneyFly → 权限，允许「查看所有应用」后重新进入" : access_none "未找到应用", 12px txt3 height 1.7, centered, horizontal 30)`.
   - else `ListView.builder(padding fromLTRB(12,6,12,24))` of `Container(margin vertical 2, radius 10, color: checked ? brand@.06 : transparent)` wrapping `CheckboxListTile(value: checked, activeColor: brand, dense: true, controlAffinity: trailing, onChanged: _mode == 'all' ? null : (_) => _toggle(pkg), title: Text(label, 13.5px txt), subtitle: Text(pkg, 9.5px txt3))`.
   `checked` is `_selected.contains(pkg)` when the mode is `selected`/`denied`, and always `false` in `all` mode (checkboxes disabled there).

### Behavior
- `_save()` writes both `accessControlMode` and `accessControlApps` via the serial `update` queue; failure → toast `save_failed` "保存失败，请重试".
- `_reconnect()`: no-op unless connected; `AlertDialog(card2)` title `access_reconnect_btn` "重连生效" (16px), content `access_saved_tip` (13.5px txt2), actions `cancel_text` "取消" / `access_reconnect_btn` (`brand`) → `disconnect()` + `connect()`.
- Toasts are floating `card2` SnackBars, 13px.

### Empty / loading / error
Loading spinner; two distinct empty messages (permission failure vs no match); errors during app-list read are swallowed (`catch (_) {}`) → shows the permission-hint empty state.

### Responsive / desktop
None inside the page; the row that links to it is Android-only.

---

## 18. `lib/pages/settings/bypass_page.dart` — `BypassPage`

**Entry**: pushed from SettingsPage (直连名单). Doc block documents three entry kinds: domain suffix (bare), `IP-CIDR:`, `DOMAIN:`.

### State
`_input: TextEditingController`, `_inputFocus: FocusNode`, `_errorText: String?`, `_domains: List<String>`, `_loaded = false`. Source: `SettingsStore['bypassDomains']`, persisted on every add/remove.

### AppBar
`Icons.arrow_back_ios_new` (18) → pop; title `bypass_title` "直连名单". While `!_loaded` the whole scaffold is a centered spinner.

### Layout — `Padding(fromLTRB(22,8,22,24))` `Column(crossAxisAlignment: start)`
1. `Text(bypass_desc)` = "名单内的域名及其子域名将不走代理、直连网络。适合内网站点、被错误代理的域名等。" (11.5px txt3 height 1.6).
2. `SizedBox(12)`.
3. **Input row** (aligned heights): `Expanded(SizedBox(height 48, TextField(controller: _input, focusNode: _inputFocus, fontSize 13.5 txt, keyboardType: url, autocorrect false, enableSuggestions false, decoration: mfInput(hint: bypass_hint "输入域名，如 company.com").copyWith(errorText: _errorText), onChanged: clears the error, onSubmitted: _add, textInputAction: done)))` + `SizedBox(10)` + **添加** `GestureDetector(onTap: _add)` → `Container(height 48, padding horizontal 20, gradient brandGradient, radius 12)` with `Text(bypass_add "添加", 13.5px w600 white)`.
4. `SizedBox(6)` + `Text(bypass_help)` = "支持：域名后缀 company.com（含子域名）｜精确域名 DOMAIN:app.example.com｜IP 段 IP-CIDR:192.168.1.0/24" (10px txt3 height 1.6).
5. `SizedBox(12)` + `Text('${bypass_count {'n'}} · ${bypass_effect}')` e.g. "共 3 条 · 更改在下次连接时生效" (11px txt3).
6. `SizedBox(8)` + `Expanded`:
   - Empty → centered `Text(bypass_empty "还没有直连域名\n添加后该域名将绕过代理", 12.5px txt3)`.
   - else `ListView.separated(separator: SizedBox(8))` of entry cards: `Container(padding symmetric(16,4), **height 48**, card, radius 12, border line)` `Row[Text(_kindIcon(kind), 13px), 10, Expanded(Text(d, 13.5px txt w500 ellipsis)), 8, kind label pill (padding 7/2, bg kindColor@.13, radius 6, text 9.5px w600 in kindColor), 8, delete button Container(30×30, bg red@.1, radius 9) with Icon(Icons.close, 15, red) → `_remove(d)`]`.
   - Kind mapping: `cidr` → icon 📡, label `bypass_type_cidr` "IP 段", color `green`; `domain` → 🎯, `bypass_type_domain` "精确域名", `amber`; `suffix` → 🌐, `bypass_type_suffix` "域名后缀", `brand`.

### Parsing / validation (`_parseInput`)
| input form | result | error key |
|---|---|---|
| empty | no-op (clears the error only) | — |
| `IP-CIDR:<cidr>` (case-insensitive prefix) | normalized `IP-CIDR:<cidr>` | `bypass_invalid_cidr` "IP 段格式不正确，示例：IP-CIDR:192.168.1.0/24" |
| `DOMAIN:<host>` | normalized `DOMAIN:<lowercased host>` (single-label allowed) | `bypass_invalid_domain` "精确域名格式不正确，示例：DOMAIN:portal.example.com" |
| bare CIDR-looking input (`1.2.3.4/24`, IPv6/…) | rejected with a format hint | `bypass_invalid_format` "格式不支持，请输入：域名后缀、IP-CIDR:IP段 或 DOMAIN:精确域名" |
| otherwise (domain suffix) | lowercased, protocol/path/port stripped, leading `*.`/`.` stripped, must match a multi-label hostname regex | `bypass_invalid` "域名格式不正确" |

`_isValidCidr` accepts IPv4 with each octet ≤255 and prefix ≤32, or IPv6 containing `:` with `::` or ≥2 colons and prefix ≤128.
Duplicate (case-insensitive) → toast `bypass_exists` "该域名已在名单中"; new entries are inserted at index 0. Save failure → toast `save_failed`. Errors set `_errorText` (rendered inline via `errorText`, `red` 11px per `mfInput`) **and** re-focus the field.

### Responsive / desktop
None.

---

## 19. `lib/pages/settings/geo_update_page.dart` — `GeoUpdatePage`

**Entry**: pushed from SettingsPage (更新分流数据). Doc: `/// 分流数据管理页（国家 IP 库 country.mmdb / 分流规则 geosite.dat）… 手动检查更新`.

### AppBar
`Icons.arrow_back_ios_new` (18) → pop; title `geo_title` "分流数据".

### State
`_updating = false`, `_doneFiles = 0`, `_totalFiles = GeoUpdateService.files.length`, `_hasCopy = false`, `_updatedAt: DateTime?`. Statics `_radius = 14`, `_iconRadius = 9`.

### Data sources
`GeoUpdateService.hasManualCopy(GeoUpdateService.files.first)`, `GeoAssets.manualUpdatedAt()`, `GeoUpdateService.instance.update(onFile: (done,total) {…})`; `UpdateInfo.currentVersion`.

### Layout — `ListView(padding fromLTRB(22,4,22,32))`, rows via a local `_row` (52-px card, **no chevron/onTap** — read-only)
1. `_section(geo_status "当前数据")`
2. `_row(🧠, geo_country_lib "国家 IP 库", value: 'country.mmdb')`
3. `_row(🧭, geo_rules "分流规则", value: 'geosite.dat')`
4. `_row(📦, geo_builtin "随 App 内置", value: 'v${UpdateInfo.currentVersion}')`
5. `_row(_hasCopy ? '🟢' : '⚪', geo_manual_copy "手动更新副本", value: `_updatedAt == null ? geo_none "无" : _fmt(_updatedAt!)` where `_fmt` = `yyyy-MM-dd HH:mm` local)
6. `SizedBox(12)` + `Text(geo_tip)` = "说明：国家库与分流规则在构建时随 App 自带（每次发布都是当时最新版），启动与连接全程本地读取、不联网下载，任何缺失都不会影响软件与内核启动。如需最新数据请点击下方按钮手动更新（联网下载一次），更新后下次连接生效。" (11.5px txt3 height 1.6)
7. `SizedBox(16)` + **update button** `GestureDetector(onTap: _updating ? null : _update)` → `Container(height 46, gradient brandGradient, radius 13, centered)`:
   - `_updating` → `Row[14×14 white spinner, 8, Text(geo_downloading {'pct': '$_doneFiles/$_totalFiles'}) e.g. "下载中 1/2" (13px white w600)]`
   - else → `Text(geo_check_update "检查并更新", 13.5px white w700)`
8. `SizedBox(12)` + `Text(geo_source "数据来源：MetaCubeX/meta-rules-dat（官方源）", 10.5px txt3)`.

### Behavior
`_update()` → per-file progress callback drives the button label; on completion `_loadStatus()` refreshes the copy/date; no errors → toast `geo_update_done` "分流数据已更新，下次连接生效"; any file errors → toast `geo_update_fail {'err': errors.join('；')}` "更新失败：{err}" (errors joined with a **full-width semicolon**). Toasts are floating `card2` 13px SnackBars.

### Empty / loading / error
No page-level loading state; "no manual copy" renders as `geo_none` "无" with a ⚪ icon. Progress only inside the button.

### Responsive / desktop
None.

---

## 20. `lib/widgets/mf_empty.dart` — `MFEmpty`

Unified empty/error state. Doc example usage in the file header.
Params: `icon = Icons.inbox_outlined`, `title` (required), `hint`, `actionLabel`, `onAction` (button rendered only when **both** actionLabel and onAction are provided).

Layout: `Center(Padding(symmetric(horizontal 32, vertical 16), Column(mainAxisSize: min)))`:
- `Icon(icon, size 42, color: txt3)`
- `SizedBox(14)`
- `Text(title, 14px, txt3, centered)`
- if hint: `SizedBox(6)` + `Text(hint, 12px, txt3, centered)`
- if action: `SizedBox(20)` + `GestureDetector(onTap: onAction)` → `Container(padding symmetric(horizontal 26, vertical 11), gradient brandGradient, radius 12)` with `Text(actionLabel, 13px white w600)`.

Used by: PackagePage (error/empty), OrdersPage (empty), NotificationsPage (empty), DevicesPage (empty). Callers pass a height-constrained parent (`SizedBox(height: 320)`) or a `Padding(top: 90)`.

---

## 21. `lib/widgets/mf_input.dart` — `mfInput({hint, helper})`

**Not a widget — an `InputDecoration` factory**; the shared style for every settings/dialog/search text field.
Returns: `InputDecoration(hintText: hint, helperText: helper, filled: true, fillColor: MFColors.card, isDense: true, contentPadding: symmetric(horizontal 14, vertical 13), hintStyle: 12.5px txt3, helperStyle: 10.5px txt3, errorStyle: 11px red, enabledBorder: OutlineInputBorder(radius 12, line w1), focusedBorder: (radius 12, brand w1.4), disabledBorder: (radius 12, line w1))`.
Note the difference vs the global `inputDecorationTheme` (radius 14, fill `card2`, padding 16/16, focused w1.4 brand): pages that call `mfInput()` switch to radius 12 + `card` fill; the auth pages use the global theme instead.

---

## 22. `lib/widgets/country_flag.dart` — `CountryFlag`

`CountryFlag(String? code, {double size = 17, bool rounded = false})`.
- Uppercases the code; `ProxyNode.flagEmoji(c)` provides the emoji fallback.
- If the code is a valid 2-letter A–Z code and not `XX` → `Image.asset('assets/flags/<lower>.png', width: size, height: size * 0.72, fit: BoxFit.fill, errorBuilder → Text(emoji, fontSize: size))`; otherwise the emoji text directly. 144 PNG flags ship in `assets/flags/`.
- `rounded: true` wraps in `ClipRRect(radius 2.5)`.
Rationale in the doc comment: Windows renders emoji flags as letters (HK/TW), so bundled images are the primary path.
Used with sizes 13 (real exit), 15 (quick-country pills), 17 (default, node rows), 18 (node picker), 20 (home current-node row).

---

## 23. `lib/widgets/password_rules.dart` — `PasswordRuleHints`

`PasswordRuleHints({required TextEditingController controller})` — live password-rule checklist; self-wired via `ValueListenableBuilder<TextEditingValue>` on the controller (parent passes nothing else).
Layout: `Padding(only(left 2, top 7))` + `Column(crossAxisAlignment: start)` with two `_rule` rows separated by `SizedBox(3)`:
- `_rule(lenOk, AppStrings.t('pwd_rule_len'))` → "长度不少于 8 位" where `lenOk = pwd.length >= 8`
- `_rule(kindsOk, AppStrings.t('pwd_rule_kinds', {'n': '$kinds'}))` → "大写 / 小写 / 数字 / 符号 至少三种（当前 {n} 种）" where `kinds = PasswordPolicy.kindsOf(pwd)`, `kindsOk = kinds >= 3`
`_rule`: `Row[Icon(ok ? Icons.check_circle : Icons.circle_outlined, size 12, color ok ? green : txt3), 5, Expanded(Text(text, 10.5px, height 1.4, color ok ? green : txt3))]`.
Design intent (doc comment): fixes "clicked reset and nothing happened" where the only feedback was a SnackBar hidden by the keyboard.
Used by: RegisterPage, ForgotPasswordPage, ChangePasswordPage.

---

## 24. Theme summary (`lib/theme/app_theme.dart`, `theme_controller.dart`)

Full machine-extracted tables (all 6 palettes, every hex) are in **`color-tokens.md`**. Key points:

- `MFTheme` = 13 fields: `isDark`, `bg`, `bg2`, `card`, `card2`, `txt`, `txt2`, `txt3`, `brand`, `brandLight`, `brandDeep`, `line`, `line2`. Six complete palettes: `light`, `warm`, `gray` (light) and `darkgray`, `darkblue`, `black` (dark) — documented as matching `design/theme_design.html`.
- `MFColors` exposes them as **static getters** that read `ThemeController.instance.appearance`, so page code never changes when the appearance changes. `MFColors.isDark`, `brandGradient` (`topLeft→bottomRight` through brand → brandLight → brandDeep).
- Semantic: `green`, `greenDeep`, `red` are brightness-dependent; `amber = Color(0xFFFFB020)` is a plain const.
- `buildMoneyFlyTheme({brightness})`: M3, `scaffoldBackgroundColor: t.bg`, `fontFamily: 'PingFang SC'`, `titleLarge` 20/w700, `bodyMedium` 14, `bodySmall` 12, `labelMedium` 12.5/w500; `appBarTheme` (bg `t.bg`, elevation 0, `centerTitle: false`, title 18/w700, icons `t.txt`); `cardTheme` (color `t.card`, elevation 0, radius 16, side `t.line`); `switchTheme` (white thumb, track `brand` when selected else `Color(0xFF2A3242)`, transparent outline); `inputDecorationTheme` (filled `card2`, hint `txt3` 14, padding 16/16, radius 14, enabled `line2`, focused `brand` w1.4); `dividerTheme` (line, 1, space 1); `bottomNavigationBarTheme` (bg `t.bg`, selected `brandLight`, unselected `txt3`, fixed type); `snackBarTheme` (`card2` bg, `txt` 13px, floating, radius 12).
- `MFPrimaryButton({label, onPressed, height = 54, loading, icon})`: full-width, gradient `brandGradient`, radius 16, shadow `brand@.35` blur 24 offset (0,10); content is a 22×22 white spinner (strokeWidth 2.4) when `loading`, else `Row[optional icon, 8, Text(label, 16px w600 white)]`.
- `mfLatencyColor(ms, online)` — the single global latency scale: offline → `red`; `ms < 0` (untested) → `txt3`; `< 100` → `green`; `< 300` → `amber`; else `red`.
- `formatPrice(double)` — strips meaningless trailing zeros (`0.02 → "0.02"`, `200 → "200"`, `200.5 → "200.5"`, `0 → "0"`), fixing the "0.02 元 shown as 0 元" bug.
- `RedDot({size = 8})` — 8-px `red` circle; used at `size: 7` for tab badges and settings rows.
- `kNumFont = 'Chakra Petch'` — used for every numeric readout (with mobile monospace-ish fallback per the comment).
- `ThemeController`: singleton, `appearance = 'light'` default, `isDark` for the 3 dark keys, `mode` = `ThemeMode.dark|light` (explicitly **no "follow system"**), `setAppearance(key)` (persists via `SettingsStore.update`), `restore()` on launch.

---

## 25. Cross-cutting state inventory (what each page watches)

| page | reactive source | loading flag | error surface |
|---|---|---|---|
| Login | `SessionState.setLoggedIn` | `_loading` (button) | SnackBar / disabled AlertDialog |
| Register | none | `_sending`, `_loading`, `_countdown` | SnackBar only |
| ForgotPassword | none | `_sending`, `_loading`, `_countdown` | SnackBar **+** persistent `_formError` |
| ChangePassword | none | `_loading` | SnackBar only |
| Home | `AccountService` (watch), `Selector<ConnectionController>` ×2, `ValueListenableBuilder(speedNotifier)`, local 1-s timer | `_loadingNodes`, `_refreshing`, `_pulse` animation | in-card error text + kind-specific buttons + SnackBar |
| Nodes | `context.select(nodes.length, current.tag)` | `_testing`, `_refreshing`, `_testingNode` | SnackBar + `_EmptyNodesView` |
| Package | none (imperative setState) | `_loading` (skeleton), `_paying` | `MFEmpty` error + retry, SnackBar |
| UpgradeDevices | `AccountService.instance.sub` (read) | `_loading`, `_previewing`, `_paying` | `_previewError` line + SnackBar |
| Payment dialog | local `Timer` + `WidgetsBindingObserver` | `_launching`, `_polling`, `_pollInFlight` | SnackBar (status/launch) |
| Profile | none (imperative) | `_loading` | cloud-off block + retry, SnackBar |
| Orders | none | `_loading`, `_paying` | cloud-off block + retry, SnackBar |
| Devices | `AccountService.sub` (read) | `_loading`, `_deletingId`, `_savingRemarkId` | SnackBar only |
| Notifications | none | `_loading` | cloud-off block + retry, SnackBar |
| Settings | `ValueListenableBuilder(UpdateService.hasUpdate)`, `ThemeController` | `_loaded`, `_checkingUpdate` | SnackBar only |
| Kernel | `ConnectionController.status` (read) | `_checking`, `_downloading`, `_restoring` | `_error` line + SnackBar |
| LogCenter | `ConnectionController.status` (read), streams/timers | `_loading`, `_pollBusy` | empty-state text only |
| Access | `ConnectionController.status` | `_loading` | permission-hint empty state + SnackBar |
| Bypass | none | `_loaded` | inline `errorText` + SnackBar |
| GeoUpdate | none | `_updating` | SnackBar only |

**Responsive surface of the whole app (complete list)**
1. `MainShell`: width ≥ 840 → `NavigationRail` instead of `BottomNavigationBar`.
2. `compact = height < 820` spacing/size switch: HomePage, LoginPage, RegisterPage, ForgotPasswordPage.
3. `PaymentQrDialog`: mobile-only launch button.
4. `SettingsPage` / `KernelPage` / `AccessPage` / `LogCenterPage`: `Platform.is*` row gating, not width.
5. Window minimum `380×620`; every page is a single full-width column — **no max-width container, no two-pane desktop layout anywhere**.
