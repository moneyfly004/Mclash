# MoneyFly — UI/UX inventory, Part 1
### App shell · routing · auth (4 pages) · home · nodes · purchase (package / upgrade-devices / payment dialog)

Analyzed checkout: `/Users/apple/Downloads/mysoftware/moneyfly` (Flutter 3.11 / Dart SDK ^3.11.0, app version `2.2.5+164`).
No project file was modified. All strings quoted verbatim from source.

---

## 0. Application shell & routing (context for every page)

### `lib/main.dart` — `MoneyFlyApp` → `RootShell` → `MainShell`

**Providers installed above `MaterialApp`** (`MultiProvider`):

| provider | type | role |
|---|---|---|
| `SessionState` | ChangeNotifier | `loggedIn` flag; `restore()` reads SharedPreferences flag `moneyfly_auto_login` and `ApiClient.readAccessToken()` |
| `ConnectionController.instance` | ChangeNotifier | proxy engine status, nodes, current node, speed, error |
| `ThemeController.instance` | ChangeNotifier | appearance key |
| `LocaleController.instance` | ChangeNotifier | language |
| `AccountService.instance` | ChangeNotifier | account gate: expired / deviceFull / disabled / noSubscription |

**Routing model**
- No named routes, no router package. `home: RootShell()`.
- `RootShell`: `loggedIn ? const MainShell() : const LoginPage()`.
- Everything else is imperative `Navigator.of(context).push(MaterialPageRoute(builder: (_) => const XPage()))`.
- `rootNavigatorKey` (`GlobalKey<NavigatorState>`) is used for `popUntil((r) => r.isFirst)` on session expiry / logout, and to show the desktop close dialog from above the `MaterialApp`.
- `mainTabIndex` (`ValueNotifier<int>`) is the cross-page "jump to tab" bus: `mainTabIndex.value = 2` switches to the 套餐 (purchase) tab from home / profile / nodes.
- **Session expiry** (`ApiClient.onSessionExpired`): `AuthService.logout()` → `popUntil(isFirst)` → `SessionState.setLoggedIn(false)` → LoginPage.
- **`MaterialApp` config**: `title: AppStrings.t('app_name')`, `debugShowCheckedModeBanner: false`, `theme`/`darkTheme` = `buildMoneyFlyTheme(brightness: light/dark)`, `themeMode: themeCtrl.mode`, `locale` zh/en, `supportedLocales: [zh, en]`, 3 `Global*Localizations` delegates.

### `MainShell` — the 4-tab shell

| # | tab label key | label (zh) | icon / activeIcon | page |
|---|---|---|---|---|
| 0 | `home` | 首页 | `Icons.home_outlined` / `Icons.home` | `HomePage` |
| 1 | `nodes_title` | 节点列表 | `Icons.dns_outlined` / `Icons.dns` | `NodesPage` |
| 2 | `purchase_title` | 购买套餐 | `Icons.payments_outlined` / `Icons.payments` | `PackagePage` |
| 3 | `profile_title` | 我的 | `Icons.person_outline` / `Icons.person` | `ProfilePage` |

- Lazy build + keep-alive: `_visited` set; unvisited tabs render `SizedBox.shrink()`; visited pages wrapped in `TickerMode(enabled: i == _index)`; body is an `IndexedStack`.
- **Responsive navigation**: `_railBreakpoint = 840`; `MediaQuery.sizeOf(context).width >= 840` → left `NavigationRail` (`labelType: all`, `indicatorColor: brand @ .12`, selected `brandLight`, unselected `txt3`, labels 12px w500) + `Expanded(tabBody)`; otherwise the `BottomNavigationBar` (`type: fixed`, `selectedItemColor: brandLight`, `unselectedItemColor: txt3`) inside a `Container(color: bg, border: top line)` + `SafeArea(top:false)`.
- **Red-dot badge**: tab index 3 (我的) shows `RedDot(size: 7)` at `Positioned(right:-2, top:-2)` over both icon and activeIcon while `UpdateService.hasUpdate` is true; same `ValueListenableBuilder` drives the rail.
- Window chrome (`windowManager`): `setTitle('MoneyFly')`, `setMinimumSize(Size(380, 620))`, `setPreventClose(true)`.
- `onWindowClose` → `_loadCloseAction()` (`ask` / `hide` / `quit`); when `ask`, an `AlertDialog` (background `MFColors.card2`) is shown **with** `StatefulBuilder`:

| element | string | notes |
|---|---|---|
| title | `close_ask_title` = "关闭 MoneyFly？" | 16px w700 |
| body | `close_ask_body` = "选择关闭方式：\n· 最小化到托盘：继续在后台运行（代理保持连接）\n· 退出：断开连接并结束程序" | 13.5px `txt2`, height 1.6 |
| checkbox | `remember_choice` = "记住我的选择" | `CheckboxListTile`, dense, leading |
| action 1 | `cancel` = "取消" | closes, keeps window |
| action 2 | `minimize_tray_btn` = "最小化到托盘" | color `txt`; persists `closeAction='hide'` if remembered |
| action 3 | `quit_app_btn` = "退出" | color `red`; persists `closeAction='quit'`; runs `_quitApp()` (disconnect → `killStaleKernels()` → `windowManager.close()` → `exit(0)`) |

---

## 1. `lib/pages/auth/login_page.dart` — `LoginPage`

**Title / entry**: root page when logged out (`RootShell`). Not pushed; it *is* the root. Pushes `RegisterPage` and `ForgotPasswordPage`.
Doc comment: `/// 登录页（设计稿 01）`.

### State
| variable | type | initial | purpose |
|---|---|---|---|
| `_autoLoginKey` | `static const String` | `'moneyfly_auto_login'` | SharedPreferences key |
| `_account` | `TextEditingController` | — | account/email |
| `_password` | `TextEditingController` | — | password |
| `_obscure` | bool | `true` | password masking |
| `_autoLogin` | bool | `true` | restored in `initState` from SharedPreferences |
| `_loading` | bool | `false` | drives button spinner |

### Layout (top → bottom)
`Scaffold(body: SafeArea(SingleChildScrollView(padding: horizontal 24)))`, `compact = MediaQuery.of(context).size.height < 820`.

1. `SizedBox(height: compact ? 32 : 70)`
2. **Logo**: `Center(Container 60×60 (compact) / 76×76, radius 20, boxShadow brand@.35 blur 40 offset(0,16))` → `ClipRRect(20)` → `Image.asset('assets/moneyfly-logo.png')`.
3. `SizedBox(height: compact ? 12 : 18)`
4. **App name**: `Text(AppStrings.t('app_name'))` = "MoneyFly", 24/28px, w700, `letterSpacing: 1.6`.
5. `SizedBox(6)`
6. **Slogan**: `Text(AppStrings.t('slogan'))` = "极速 · 稳定 · 全球畅连", 12.5px, `txt3`, `letterSpacing: 3`.
7. `SizedBox(height: compact ? 24 : 44)`
8. **Field 账号/邮箱** — label `account_label` "账号 / 邮箱" (12.5px `txt2` w500, padding left 2 bottom 7); hint `account_hint` "请输入账号或邮箱"; `textInputAction: next`; `onSubmitted` → `FocusScope.nextFocus()`.
9. `SizedBox(12)`
10. **Field 密码** — label `password_label` "密码"; hint `password_hint` "请输入密码"; `obscureText: _obscure`; `textInputAction: done`; `onSubmitted` → `_login()` (guarded by `_loading`); `suffixIcon: IconButton` with `Icons.visibility_off_outlined` / `Icons.visibility_outlined`, size 20, color `txt3` → toggles `_obscure`.
11. `SizedBox(8)`
12. **Auto-login row**: `Text(AppStrings.t('auto_login'))` "自动登录" (13px `txt2`) + `Spacer` + `Switch(value: _autoLogin)` → `setState` + `LoginPage.setAutoLogin(v)` (writes SharedPreferences). Note: this switch is **not** scaled down (unlike settings page's `Transform.scale(.82)`).
13. `SizedBox(height: compact ? 10 : 16)`
14. **Primary CTA**: `MFPrimaryButton(label: AppStrings.t('login_button'))` = "登 录" (note the full-width space), `loading: _loading`, `onPressed: _loading ? null : _login`.
15. `SizedBox(height: compact ? 16 : 26)`
16. **Footer row** (centered): `GestureDetector` → `Text.rich` `no_account` "还没有账号？" (13.5px `txt2`) + `register` "注册" (13.5px `brandLight` w600) → pushes `RegisterPage`; divider `Container(width:1, height:12, margin horizontal 18, color: line2)`; `GestureDetector` → `Text(AppStrings.t('forgot_password'))` "忘记密码" (13.5px `txt2`) → pushes `ForgotPasswordPage`.
17. `SizedBox(height: compact ? 16 : 40)`

### Private widget `_Field`
`Column[ Padding(left 2, bottom 7)[Text label 12.5px txt2 w500], TextField(style: onSurface 15px, cursorColor brand, decoration: InputDecoration(hintText, suffixIcon)) ]` — uses the global `inputDecorationTheme` (filled `card2`, radius 14, focused border brand w1.4).

### Logic / services
- `_login()`: empty account or password → SnackBar `input_account_pwd` "请输入账号和密码".
- `AuthService.instance.login(_account.text, _password.text)` → on success `context.read<SessionState>().setLoggedIn(true)`.
- Error handling: `ApiClient.errorMsg(e)`; if the message contains `禁用` / `禁止` / `disabled` / `banned` (lower-cased for the English checks) it shows `_showDisabledDialog(msg)` instead of a toast.
- `_showDisabledDialog`: `AlertDialog(backgroundColor: MFColors.card2, radius 18)`, title `account_disabled_title` "账号已被禁用" (16px w700, centered), content = server message (13.5px `txt2`, height 1.7, centered), single centered `TextButton` `ok_btn` "好的".
- `_toast` = `ScaffoldMessenger.showSnackBar` (SnackBar styling comes from `snackBarTheme`: `card2` bg, `txt` 13px, floating, radius 12).

### States
No loading skeleton; no empty state. Error = SnackBar (or disabled dialog). Busy = button spinner (`CircularProgressIndicator` 22×22 strokeWidth 2.4 white inside the gradient button).

### Responsive
Only the `compact` (<820 height) spacing/size switch. No width-based layout (desktop gets the same narrow single column).

---

## 2. `lib/pages/auth/register_page.dart` — `RegisterPage`

**Entry**: pushed from LoginPage footer (`MaterialPageRoute`). Doc: `/// 注册页（设计稿 07）：邮箱 + 验证码（60s 倒计时）+ 用户名 + 密码 + 邀请码`.

### AppBar
`leading: IconButton(Icons.arrow_back_ios_new, size 18)` → `Navigator.pop`; `title: AppStrings.t('register_title')` = "注册账号"; `actions: [TextButton(→pop) Text(AppStrings.t('login_title'))` "登录" `, color brandLight, w600)]`.

### State
| variable | type | initial |
|---|---|---|
| `_email`,`_code`,`_username`,`_password`,`_confirm`,`_invite` | `TextEditingController` ×6 | — |
| `_obscure` | bool | `true` (shared by both password fields) |
| `_agreed` | bool | `true` |
| `_sending` | bool | `false` |
| `_codeSent` | bool | `false` |
| `_countdown` | int | `0` (60 → 0) |
| `_timer` | `Timer?` | periodic 1s |
| `_loading` | bool | `false` |

### Layout (top → bottom, padding `fromLTRB(24, compact?4:8, 24, compact?16:32)`)
1. **Headline** `Text(AppStrings.t('join_moneyfly'))` = "加入 MoneyFly", 17px w700 `txt`.
2. `SizedBox(4)` + `Text(AppStrings.t('join_tip'))` = "注册后即可购买套餐开始加速", 11.5px `txt3`.
3. `SizedBox(compact?14:24)`
4. **邮箱** — `email_label` "邮箱"; hint `email_hint` "用于接收验证码".
5. `SizedBox(12)`
6. **验证码 row** — label `code_label` "验证码"; hint `code_hint` "6 位验证码"; `inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(6)]`; suffix `SizedBox(104×48)`:
   - `_countdown > 0` → `Container(color: card, radius 12, border line2)` showing `'$_countdown${AppStrings.t('resend_in')}'` e.g. "60s 后重发" (12px `txt3`, `kNumFont`).
   - otherwise → gradient `GestureDetector` (`onTap: _sending ? null : _sendCode`) with `Text(_sending ? AppStrings.t('sending') : AppStrings.t('send_code'))` = "发送中…" / "发送验证码" (12px white w600).
7. If `_codeSent`: `SizedBox(6)` + `Text(AppStrings.t('code_sent'))` = "验证码已发送至邮箱，5 分钟内有效" (10.5px `green` w600).
8. `SizedBox(12)` → **用户名** `username_label` "用户名"; hint `username_hint` "登录用户名（4-20 位）".
9. `SizedBox(12)` → **密码** `password_label` "密码"; hint `new_pwd_hint` "至少 8 位，大小写字母/数字/符号至少三种"; obscure; eye button (`Icons.visibility_off_outlined`/`visibility_outlined`, 19, `txt3`).
10. `PasswordRuleHints(controller: _password)` — live checklist (see §Widgets in Part 3).
11. `SizedBox(12)` → **确认新密码** `confirm_pwd` "确认新密码"; hint `confirm_pwd_hint` "再次输入新密码"; eye button.
12. `SizedBox(12)` → **邀请码（选填）** `invite_label`; hint `invite_hint` "如有邀请码请填写".
13. `SizedBox(14)` → **TOS checkbox row**: 18×18 `Container(radius 6)`; when `_agreed` → `gradient: brandGradient` + `Icon(Icons.check, size 12, white)`; when not → `color: card`, `border: line2`. `GestureDetector` toggles. Then `Expanded(Text.rich)` with **hard-coded (non-i18n) spans**: `'我已阅读并同意 '` (`txt2`) + `'《用户协议》'` (`brandLight` w600) + `' 与 '` (`txt2`) + `'《隐私政策》'` (`brandLight` w600), all 11.5px. (The `agree_tos` key exists but is unused here — flagged in `i18n-hygiene.md`.)
14. `SizedBox(22)` → `MFPrimaryButton(label: AppStrings.t('register_btn'))` = "注 册", `loading: _loading`.

### Logic / services
- `_sendCode()`: `looksLikeEmail(email)` (regex `^[\w.+-]+@[\w-]+(\.[\w-]+)+$`) else toast `email_invalid` "请先输入正确的邮箱"; then `ApiClient.instance.post(Endpoints.sendCode, data: {'type':'email','email':email})` → toast `code_sent_email` "验证码已发送到邮箱，5 分钟内有效", sets `_codeSent=true`, `_countdown=60`, starts the 1-s `Timer.periodic` (cancels itself at 0, cancels on unmount).
- `_register()` validation order → toast on first failure:
  1. `username.trim().length < 4` → `username_short` "用户名至少 4 位"
  2. `PasswordPolicy.errorFor(password)` → `pwd_short` "密码至少 8 位" or `pwd_weak` "密码强度不足：需包含大小写字母、数字、特殊字符中的至少三种"
  3. `password != confirm` → `pwd_mismatch` "两次输入的密码不一致"
  4. `!looksLikeEmail(email)` → `email_invalid`
  5. `!_agreed` → `agree_required` "请先阅读并同意用户协议与隐私政策"
  Then `ApiClient.instance.post(Endpoints.register, data: {username, email, password, verification_code, invite_code?})` → toast `registered` "注册成功，请登录" → `Navigator.pop()`.
- **Empty/loading/error**: no skeleton, no dedicated error UI — SnackBar only; the send-code button doubles as its own progress indicator; the primary button shows an inline spinner.

### Responsive
Same as login: only `compact` (<820 height). AppBar's `login_title` action is the only "back to login" affordance besides the arrow.

---

## 3. `lib/pages/auth/forgot_password_page.dart` — `ForgotPasswordPage`

**Entry**: pushed from LoginPage (`forgot_password` link).
Doc: `/// 找回密码（设计稿 08）：邮箱验证码两步重置。` Explicit design note: three-layer validation feedback (live rule checklist + persistent red error above the button + SnackBar) to fix the "clicked reset, nothing happened" bug.

### AppBar
`Icons.arrow_back_ios_new` (18) → pop; title `forgot_title` = "找回密码"; action `TextButton` `login_title` "登录" (`brandLight` w600) → pop.

### State
`_email`, `_code`, `_newPassword`, `_confirm` controllers; `_obscure=true`; `_sending=false`; `_codeSent=false`; `_countdown=0`; `_timer`; `_loading=false`; **`_formError`** (`String?`) — the last validation error, rendered persistently. All 4 controllers get `addListener(_clearFormError)` in `initState`, so typing clears the red line.

### Layout
Padding `fromLTRB(24, compact?6:12, 24, compact?16:32)`.

1. **Step indicator** (centered Row): `_Step(done:true, no:'✓', label: step_verify "验证身份")` → `Padding(horizontal 10)` → `SizedBox(26×1, ColoredBox(line2))` connector → `_Step(done:false, no:'2', label: step_new_pwd "设置新密码")`.
   `_Step`: 20×20 circle, bg = `green@.18` when done else `brand@.18`; text `✓` or `2` (10.5px, `kNumFont`, w700); label 11.5px w600; color = `green` when done else `brandLight`.
2. `SizedBox(compact?16:26)`
3. **邮箱** `email_label` "邮箱"; hint `email_reg_hint` "用于接收重置验证码".
4. `SizedBox(12)`
5. **验证码** `code_label` "验证码"; hint `code_hint` "6 位验证码"; digits-only + max 6; suffix 104×48 — countdown box (`'$_countdown${resend_in}'` e.g. "60s 后重发", `card` bg, `line2` border, `kNumFont`) or gradient 发送验证码 / 发送中… button.
6. If `_codeSent`: `identity_ok` "验证码已发送至邮箱，请查收" (10.5px `green` w600).
7. `SizedBox(12)` → **新密码** `new_pwd` "新密码"; hint = `PasswordPolicy.hint` = `new_pwd_hint`; eye button.
8. `PasswordRuleHints(controller: _newPassword)`.
9. `SizedBox(12)` → **确认新密码** `confirm_pwd`; hint `confirm_pwd_hint`; eye button.
10. `SizedBox(14)` → `Text(AppStrings.t('forgot_tip'))` = "验证码将发送到注册邮箱，5 分钟内有效；重置成功后请使用新密码登录。" (11px `txt3`, height 1.7).
11. If `_formError != null`: `SizedBox(10)` + `Text('⚠ $_formError')` — 12px `red`, height 1.5, **w600**, prefixed with a literal `⚠ `.
12. `SizedBox(22)` → `MFPrimaryButton(label: reset_pwd_btn "重置密码", loading: _loading)`.

### Logic / services
- `_sendCode()`: invalid email → SnackBar `email_reg_invalid` "请输入正确的邮箱地址"; else `POST Endpoints.forgotPassword {email}` → SnackBar `reset_code_sent` "重置验证码已发送到邮箱", `_codeSent=true`, 60-s countdown.
- `_fail(msg)` = `setState(_formError = msg)` **and** `_toast(msg)` (dual channel).
- `_reset()` validation order: email → `code_required` "请输入 6 位邮箱验证码" (code length must be exactly 6) → `PasswordPolicy.errorFor` → `pwd_mismatch`.
  Then `POST Endpoints.resetPassword {email, verification_code, new_password}` → SnackBar `pwd_reset` "密码已重置，请使用新密码登录" → `pop()`. Server rejection also goes through `_fail(ApiClient.errorMsg(e))` so the reason stays on screen.

---

## 4. `lib/pages/auth/change_password_page.dart` — `ChangePasswordPage`

**Entry**: pushed from Settings → 账户 → 修改密码 (`settings_change_pwd`). Doc: `/// 修改密码（登录态，需旧密码 + 新密码）`.

### AppBar
`Icons.arrow_back_ios_new` (18) → pop; title `change_pwd` = "修改密码". **No actions**.

### State
`_old`, `_newPwd`, `_confirm`; `_obscure=true`; `_loading=false`.

### Layout (padding `fromLTRB(24,12,24,32)`)
1. **Info line**: `Text('🔒 ${AppStrings.t('pwd_change_tip')}')` = "🔒 修改密码后，其他已登录设备将保持登录状态，下次登录请使用新密码。" (11.5px `txt3`, height 1.7) — the 🔒 is inline literal text.
2. `SizedBox(22)`
3. **当前密码** `cur_pwd` "当前密码"; hint `cur_pwd_hint` "请输入当前密码"; obscure; eye button.
4. `SizedBox(12)`
5. **新密码** `new_pwd` "新密码"; hint `new_pwd_hint`; obscure; eye.
6. `PasswordRuleHints(controller: _newPwd)`.
7. `SizedBox(12)`
8. **确认新密码** `confirm_pwd`; hint `confirm_pwd_hint`; obscure; eye.
9. `SizedBox(26)`
10. `MFPrimaryButton(save_pwd "保存新密码", loading: _loading)`.

### Logic
- `_submit()` order: empty old → `pwd_old_required` "请输入当前密码"; `PasswordPolicy.errorFor(new)`; `new != confirm` → `pwd_mismatch`. Then `AuthService.instance.changePassword(oldPassword:, newPassword:)` → SnackBar `pwd_changed` "密码修改成功" → `pop()`.
- Same `_eyeBtn()` helper as register/forgot (19px, `txt3`). Uses the global input decoration (no `mfInput`).

---

## 5. `lib/pages/home/home_page.dart` — `HomePage` (1800+ lines file; 1644 lines)

**Entry**: tab 0 of `MainShell`. Doc: `/// 首页 · 连接页（设计稿 02） 电源按钮 / 智能·全局模式 / 自动测速选优卡 / 快速切换国家 / 实时速率`.
**Pushes**: `SettingsPage` (header gear), `DevicesPage` (blocked dialog + banner), `UpgradeDevicesPage` (blocked dialog). Switches tab via `mainTabIndex.value = 2`.

### State (`_HomePageState with SingleTickerProviderStateMixin, WidgetsBindingObserver`)
| variable | type | purpose |
|---|---|---|
| `_loadingNodes` | bool | node fetch in flight |
| `_pillRadius` | `static final BorderRadius` | `circular(99)` for country pills |
| `_pulse` | `AnimationController(1800ms, lowerBound .35, upperBound 1)` | breathing glow, `repeat(reverse:true)` only while connected |
| `_refreshing` | bool | manual subscription refresh spinner |

### Data sources
- `ConnectionController.instance` (status, current node, nodes, speedTesting, smartMode, error, errorKind, syncingSubscription, realCountry, realCountryFailed, lockedCountry, speedNotifier, upHistory/downHistory, sessionUptime/sessionUpMB/sessionDownMB, switchingMode, autoTest).
- `AccountService.instance` / `context.watch<AccountService>()` — `sub`, `status`, `isBlocked`, `blockTitle`, `blockText`.
- `SubscriptionService.instance.fetchNodes(force:)`, `.loadCachedNodes()`, `.lastUpdatedAt`; `SubscriptionService.isKickedMessage(msg)`.
- `PermissionService.instance` — `isVpnPrepared()`, `ensureAllForConnect()`, `openVpnSettings()`.
- `GeoLookupService.countryName(code)`.
- `ApiClient.errorMsg(e)`; `UpdateService` indirectly via the shell badge.

### Layout: `Scaffold(body: SafeArea(RefreshIndicator(onRefresh: () => _ensureNodes(force: true), child: ListView(physics: AlwaysScrollableScrollPhysics, padding: horizontal pad))))`
`compact = MediaQuery.sizeOf(context).height < 820`; `pad = compact ? 16 : 22`; `gap = compact ? 8 : 12`; `gapL = compact ? 8 : 14`.

**1. `_buildHeader()`** — `Padding(vertical 8)` `Row`:
- Logo tile 36×36, `color: Colors.black`, radius 11, `ClipRRect(11)` + `Image.asset('assets/moneyfly-logo.png')` 36×36.
- `SizedBox(10)`.
- `Column`: `Text('MoneyFly')` (**hard-coded**, 15.5px w700) over `Text(AppStrings.t('home_ready'))` = "全球加速已就绪" (10.5px `txt3`).
- `Spacer`.
- `IconButton(Icons.refresh, size 20, color txt2, tooltip: refresh_sub "刷新订阅")`, `onPressed: _loadingNodes ? null : () => _ensureNodes(force: true)`.
- `IconButton(Icons.settings_outlined, size 20, color txt2)` → push `SettingsPage`.

**2. `_buildSubInfoBar(acc)`** — subscription summary strip. `Container(padding vertical 10, radius 15)`:
- Gradient: normal → `LinearGradient([Color(0x2E455FE9), Color(0x10455FE9)])`; warning (expired/deviceFull/disabled) → `[color@.18, color@.05]`.
- Border: `color @ (warn ? .55 : .4)` where `color = disabled→red, expired→red, deviceFull→amber, else brand`.
- Row of 4 cells, each `flex: 2` via `_InfoCell(label, value, flex, highlight)`:
  - `home_sub_expire` "到期" → value = `yyyy-MM-dd` from `sub.expireTime`, or `expired_short` "已到期" when expired, or `expire_na` "未设置"; `—` if no sub.
  - `home_sub_devices` "设备" → `"$_currentDevices / $_deviceLimit"` or `—`.
  - `home_sub_days` "剩余" → `"$remainingDays 天"` (uses `days` key), `highlight: !warn && !expired` (renders the number in `green`; otherwise `txt`). All values 13.5px w800 `kNumFont`; labels 9.5px `txt2`.
  - **Refresh cell** (not `_InfoCell`): `GestureDetector(onTap: _refreshSubManual, behavior: opaque)` → spinner 15×15 while `_refreshing`, else `Icon(Icons.refresh, size 15, color: color)`, plus `Text(_fmtSubTime())` = `HH:mm` (`kNumFont`, 10px `txt3`) or `--:--` when `lastUpdatedAt == null`.

**3. `_buildAccountBanner(acc)`** — shown only when `acc.isBlocked`. `(color, soft)` by status:
| status | color | soft | emoji |
|---|---|---|---|
| expired | `red` | `Color(0x2EFF5A5F)` | ⏰ |
| deviceFull | `amber` | `Color(0x33FFB020)` | 📱 |
| accountDisabled / subscriptionDisabled | `red` | `Color(0x2EFF5A5F)` | 🚫 |
| noSubscription | `amber` | `Color(0x33FFB020)` | 🛒 |
| default | `brand` | `Color(0x2E455FE9)` | ℹ️ |
Layout: `Container(padding 14/11, radius 14)` with `LinearGradient([soft, color@.06])`, border `color@.45`; `Row[emoji 16px, 9, Expanded(Text(acc.blockText) 12px txt, height 1.5), action]`. Action chip (gradient, radius 10, 13/7 padding, 12px white w600) rendered only when the status is **not** accountDisabled/subscriptionDisabled:
- expired → `go_renew` "去续费" → `mainTabIndex.value = 2`
- deviceFull → `manage_devices` "管理设备" → push `DevicesPage`
- default (noSubscription) → `go_purchase` "去开通" → tab 2

**4. `_buildConnectCard(conn, connected, busy, compact)`** — wrapped in a `Selector<ConnectionController, ({s, tag, err, st, sm, rc, rcf, sy})>` so it rebuilds on status/current tag/error/speedTesting/smartMode/realCountry/realCountryFailed/syncingSubscription.
`Container(padding fromLTRB(16, compact?12:20, 16, compact?10:16), radius 22)`:
- Gradient (fixed legacy blues): `LinearGradient(topLeft→bottomRight, [Color(0x38455FE9), Color(0x0F455FE9), Color(0x0AFFFFFF)])`.
- Border: `connected ? green@.55 : brand@.45`.
- **Status label** (13px w600): `switchingMode` → `switching_mode` "正在切换模式…"; else by `ConnStatus`: `testing`→"测速中", `connecting`→"连接中", `disconnecting`→`disconnecting_status` "断开中", `reconnecting`→"重连中", `connected`→(`speedTesting` ? `connected_speed_testing` "已连接 · 测速中" : `connected` "已连接"), `error`→`error` "连接失败", default→`disconnected` "已断开". Color: `busy ? amber : (connected ? green : txt3)`.
- **Connected session line** `_SessionInfo` (own 1-s timer, `StatefulWidget`): `'{connected_for} {sessionUptime} · ↑ {sessionUpMB} ↓ {sessionDownMB}'`, e.g. "已连接 00:12:30 · ↑ 1.2 MB ↓ 840.0 MB"; 10.5px `txt3` `kNumFont`; `_fmtMB` → `x.xx GB` when ≥1024 MB else `x.x MB`. Hidden unless connected with `connectedAt != null`.
- **Power button** (centered `GestureDetector(onTap: () => _toggleConnect(conn))`): outer `Container` 80×80 (compact) / 108×108, circle, `boxShadow: green@(.45*pulse)` when connected else `brand@.25`, blur 34, animated via `AnimatedBuilder(animation: _pulse)` inside a `RepaintBoundary`. Inner circle `margin: 8`, border 1.2 (`green@.5` connected else `line2`), `RadialGradient` — connected `[Color(0xFF1E3B3A), Color(0xFF0E1716)]` stops `[0,.75]`; idle `[Color(0xFF1B2233), Color(0xFF0E121B)]`. Center: while `busy` a `CircularProgressIndicator` 28×28 strokeWidth 2.5 in `statusColor`; else `Icon(Icons.power_settings_new_rounded, size compact?34:44, color connected ? green : txt2)`.
- **Current/will-connect node row** (only when a node exists):
  - `node = conn.current ?? first online node ?? first node` (the "将连接" preview).
  - `GestureDetector(onTap: () => _openNodePicker(conn))` → `Container(padding 14/12, color card2@.55, radius 14, border line)`.
  - `Row[CountryFlag(node.countryCode, size 20), 10, Expanded(Column[ Text(conn.current == null ? will_connect_node "将连接" : current_node "当前线路") 10px txt3, Text(node.tag) 14px w600 ellipsis ]), latency pill (only when `online && latencyMs >= 0`: `"$latencyMs ms"`, 12px, `kNumFont` w600, color `mfLatencyColor`, bg color@.12, border color@.25, radius 20), 6, Switch chip →` `Container(padding 10/5, color brand@.22, radius 9, border brand@.5)` with `Text(node_switch "切换")` (11.5px `brandLight` w700) + `Icon(Icons.chevron_right, 15, brandLight)`.
- **No-node branch**: centered `Column`.
  - Text = `acc.isBlocked ? no_nodes "暂无节点，请先刷新订阅" : (_loadingNodes ? loading "加载中…" : nodes_empty_retry "节点加载失败，请检查网络后重试")`, 13px `txt3` height 1.5.
  - When not blocked and not loading: retry chip `Container(color brand@.12, radius 10, border brand@.4)` with `Icon(Icons.refresh, 13, brandLight)` + `retry_btn` "重试" (11.5px `brandLight` w700) → `_ensureNodes(force: true)`.
- **Real-exit line** (connected only, `SizedBox(8)` gap):
  - `realCountry != null` → `Row[CountryFlag(realCountry, size 13, rounded: true), 5, Text('${real_exit} · ${GeoLookupService.countryName(realCountry)}')]` e.g. "真实出口 · 日本" — 11px `green`.
  - `realCountryFailed` → `GestureDetector(onTap: () => conn.refreshRealCountry(force: true))` → `real_exit_failed_retry` "真实出口 · 检测失败，点按重试" (11px `amber`).
  - else → `real_exit_detecting` "真实出口 · 检测中…" (11px `txt3`).
- **Error block** (`conn.error != null`): `Text(conn.error!)` centered 11px `red` height 1.5; then, unless `acc.isBlocked`, `_buildErrorActions(conn)`:
  - `guideForConnError(conn.errorKind)` → `ConnErrorUi{showGrantVpn, showGrantNotify, showRetry, foregroundHint}`.
  - `foregroundHint` adds `stay_foreground_hint` "请保持 App 在前台，再点重试" (10.5px `amber`).
  - Buttons are `_ErrorBtn` (gradient chip, radius 10, 11.5px white w700): `grant_vpn_btn` "授权 VPN 权限" → `_retryConnect(noVpnPermission)`; `grant_notify_btn` "允许通知" → `_retryConnect(noNotificationPermission)`; `retry_btn` "重试" → `_retryConnect(conn.errorKind)`. Laid out in a `Wrap(spacing 8, runSpacing 8, alignment center)`.
- **Syncing row** (only when `conn.error == null && conn.syncingSubscription`): `CircularProgressIndicator` 11×11 strokeWidth 1.5 `brandLight` + `sub_syncing` "正在同步订阅…" (11px `txt3`).
- `SizedBox(10)` → **mode switch `_buildModeSwitch(conn)`**:
  `Container(padding 4, color card, radius 14, border line)` + `Row[_ModeOption, _ModeOption]`.
  - `_ModeOption` = `Expanded(GestureDetector(AnimatedContainer(200ms, height 38, radius 11, gradient brandGradient + shadow brand@.4 blur 16 when selected)))` with `Icon` 15px + label 13px w600 — selected white, enabled `txt2`, disabled `txt3`.
  - Left: `smart_mode` "智能模式" + `Icons.gps_fixed`, selected when `conn.smartMode`, `onTap: conn.switchingMode ? null : () => conn.toggleMode(true)`.
  - Right: `global_mode` "全局模式" + `Icons.travel_explore`, selected when `!conn.smartMode`.
  - When `onTap == null` (mode switching) a 10×10 `CircularProgressIndicator` (strokeWidth 1.6) is appended to the option.

**5. `_buildStats(conn)`** — inside `RepaintBoundary`, a `ValueListenableBuilder<SpeedSnapshot>(conn.speedNotifier)`:
`Row[Expanded(_StatCard up), 12, Expanded(_StatCard down)]`.
`_StatCard(padding 16/14, color card, radius 16, border line)` = `Column[ Row[Icon 16px color, 6, Text(label 12px txt2 w600)], 10, Row(baseline)[Text(value 26px w700 color kNumFont height 1), 6, Text(unit 13px txt3 w500)], if spark.length>=2: 10, SizedBox(height 26, _Sparkline) ]`.
- Up card: `up_speed` "上行", `Icons.arrow_upward_rounded`, color `brandLight`.
- Down card: `down_speed` "下行", `Icons.arrow_downward_rounded`, color `green`.
- `_formatSpeed`: `≤0 → "0.0"`; `<0.1` → `(mbps*1024).toStringAsFixed(0)`; else `toStringAsFixed(1)`. `_speedUnit`: `≤0 → 'MB/s'`; `<0.1 → 'KB/s'`; else `'MB/s'`.
- `_Sparkline` = `CustomPaint` with `_SparkPainter`: stroke width 1.4 round cap in card color, plus a filled area under the curve at the same color @ .10; all-zero data uses a 0.1 baseline.

**6. `_buildQuickCountries(conn)`** — `Selector<ConnectionController, ({nodesHash, curTag, lock})>`:
- Aggregates `byCountry` = best (lowest latency) **online** node per `countryCode ?? 'XX'`, sorted by latency; renders nothing if empty.
- Label: `quick_switch_country` "快速切换国家 · 点按即切最优节点" (11.5px `txt2`, padding left 2 bottom 8).
- `Wrap(spacing 8, runSpacing 8)` of pills (radius 99):
  - **Auto pill**: `Icon(Icons.auto_awesome, 14)` + `auto_best` "自动选择最优节点" (12px w600). Selected state = `conn.lockedCountry == null` → bg `green@.18`, border `green@.7`, text/icon `green`; else bg `card`, border `line`, text `txt`.
  - Up to **6 country pills** (`entries.take(6)`): `CountryFlag(e.key, size 15)` + `GeoLookupService.countryName(e.key)` (12px w600) + `"${latencyMs}ms"` (10px `txt3` `kNumFont`). Current country → bg `brand@.2`, border `brand@.7`, text `brandLight`; else bg `card`, border `line`, text `txt`.
- Tap country → `conn.switchNode(e.value)` then toast `switched_to` "已切换到 {name}"; tap auto → `conn.unlockCountry()` then toast `auto_best_activated` "已切换为自动选择最优节点".

**Trailing**: `SizedBox(compact ? 10 : 16)`.

### Dialogs / sheets owned by HomePage

**(a) `_NodePickerSheet`** — `showModalBottomSheet(isScrollControlled: true, backgroundColor: card, radius top 20)`, content is a `DraggableScrollableSheet(expand:false, initialChildSize .62, minChildSize .35, maxChildSize .9)`.
- Grabber: 36×4 `line2`, radius 2, top margin 10.
- Header `Padding(20,14,20,8)`: `Text(nodes_title "节点列表")` 17px w700 + 10 + `Text(tap_switch_node "点击切换线路")` 11px `txt3` + `Spacer` + speed-test button: gradient `Container(padding 12/6, radius 10)` showing `'⚡ ${speed_test}'` (11.5px white w600) or a 13×13 white spinner; `onTap: conn.speedTesting ? null : () => conn.retestAll(switchToBest: false, userInitiated: true)`.
- Body: `ListView.builder` (controller = sheet scroll controller, padding `fromLTRB(16,0,16,20)`) of node rows:
  - Row `Container(margin bottom 8, padding 13/12, radius 14, border)`; current node → `color: brand@.09`, border `brand@.55`; else `card2` + `line`.
  - `CountryFlag(18)` + 10 + `Expanded(Text(tag, 13.5 w600 ellipsis))` + latency `"$ms ms"` (12px w600 `kNumFont`, `mfLatencyColor`) or `—` + `Icon(Icons.check_circle, 16, brandLight)` when current.
  - Tap → `Navigator.pop` → `conn.switchNode(n)` → toast `switched_to`.
- Sorting: online first, then ascending latency, untested last (alphabetical tiebreak). Re-sort is throttled to **300 ms** (`_sortGap`); other notifies only repaint.

**(b) `_showVpnExplainer()`** — `AlertDialog(backgroundColor: card2, radius 18)`: title `'🔐\n${vpn_guide_title}'` = "🔐\n开启 VPN 权限" (17px w700 centered, height 1.4); content `vpn_guide_text` = "连接需要系统 VPN 权限（仅用于建立加密隧道）。\n接下来系统会弹出连接请求，请点击「确定 / 允许」。" (13.5px `txt` centered, height 1.7); actions centered: `TextButton cancel` "取消" and `FilledButton(backgroundColor: brand, radius 12, padding 20/12)` with `vpn_guide_ok` "去授权" (white w700).

**(c) `_showVpnDeniedSheet()`** — `showModalBottomSheet<String>` (`backgroundColor: card`, radius top 20), returns `'retry' | 'settings' | null`:
- grabber 36×4 `line2`; title `'🚫 ${vpn_denied_title}'` = "🚫 未获得 VPN 权限" (16px w700 centered); body `vpn_denied_text` "刚才没有完成授权，无法建立连接。" (12.5px `txt` height 1.6); hint `vpn_denied_hint_always_on` "如果始终没有出现授权弹窗：可能有其他 VPN 应用开启了「始终开启的 VPN」，请打开系统 VPN 设置将其关闭后重试。" (11.5px `txt3` height 1.6).
- `FilledButton(brand, radius 12, vertical 13)` → `re_authorize` "重新授权" → returns `'retry'`.
- `OutlinedButton(side: brand@.5, radius 12, vertical 13)` → `open_vpn_settings` "打开系统 VPN 设置" → returns `'settings'` (then `ps.openVpnSettings()`).
- `TextButton` → `cancel` "取消" (`txt3`) → returns null.

**(d) `_showBlockedDialog(acc)`** — `AlertDialog(card2, radius 18)`:
- title `'$emoji\n${acc.blockTitle}'` (17px w700, height 1.4) with `emoji = expired→'⏰', deviceFull→'📱', accountDisabled|subscriptionDisabled→'🚫', noSubscription→'🛒', _→'⚠️'`; `blockTitle` ∈ {账号已被禁用 / 设备数量已达上限 / 套餐已被禁用 / 尚未开通套餐 / 套餐已到期}.
- content `acc.blockText`, 13.5px `txt`, height 1.7, centered.
- If accountDisabled / subscriptionDisabled: only `TextButton ok_btn` "好的".
- Otherwise: `cancel` "取消", optional `manage_devices` "管理设备" (only for deviceFull, w600, pushes `DevicesPage`), and a `FilledButton(brand, radius 12, padding 20/12)`:
  - deviceFull → `go_upgrade_devices` "升级设备套餐" → push `UpgradeDevicesPage()`
  - noSubscription → `go_purchase` "去开通" → `mainTabIndex.value = 2`
  - else → `go_renew` "去续费" → tab 2.

### Interaction logic (exact behavior)
- `_ensureNodes({force})` order: (1) `AccountService.refresh(force:)` if forced or not loaded → account gate decided **before** nodes; (2) if no nodes, disconnected **and** `!isBlocked`, inject `SubscriptionService.loadCachedNodes()` instantly (offline first paint); (3) `fetchNodes(force:)` → `conn.applySubscriptionNodes(nodes)`; (4) `conn.autoConnectIfEnabled()`. On error: `ApiClient.errorMsg`; if `SubscriptionService.isKickedMessage(msg)` → `conn.disconnect()` + `conn.loadNodes(const [])`; always toast.
- `_toggleConnect(conn)` (`HapticFeedback.mediumImpact()` first): ignores taps while `switchingMode`; `disconnecting` → ignore; `connected` → `disconnect()`; `testing|connecting|reconnecting` → `disconnect()` + toast `cancel_connect` "已取消连接"; `acc.isBlocked` → `_showBlockedDialog`; `syncingSubscription && nodes.isEmpty` → toast `sub_syncing_wait` "正在同步订阅，请稍候再连接"; `nodes.isEmpty` → toast `no_nodes`; else `_ensurePermissionsGuided()` then `conn.connect()`.
- `_ensurePermissionsGuided()` loops: explain once (`_showVpnExplainer`) → `ps.ensureAllForConnect()`; on failure show `_showVpnDeniedSheet()` → `'retry'` loops, `'settings'` opens system settings and aborts, anything else aborts. Desktop `isVpnPrepared` is always true.
- `didChangeAppLifecycleState(resumed)` → `_ensureNodes()`.

### Empty / loading / error states
- Nodes loading: header refresh button disabled + the connect card prints `loading` "加载中…".
- No nodes & blocked: `no_nodes`, no retry button (banner + dialog carry the CTA).
- No nodes & not blocked, not loading: `nodes_empty_retry` + retry chip.
- Sync in progress: `sub_syncing` spinner row (takes precedence over the retry UI, never over a real error).
- Error: red error text + kind-specific action buttons.
- No country data: the whole quick-country block is `SizedBox.shrink()`.
- Offline/first paint: disk-cached node list is injected before the network call.

### Responsive / desktop
Only the `compact` height switch (spacings + power-button size 80 vs 108). Wide screens simply stretch the `ListView` full width (no max-width constraint, no two-column layout) — the `NavigationRail` in the shell is the only width-driven change.

---

## 6. `lib/pages/nodes/nodes_page.dart` — `NodesPage`

**Entry**: tab 1 of `MainShell`. Doc: `/// 节点列表（设计稿 03）：自动选优条 + 分组 + 延迟徽标 + 真实测速`.
**Pushes**: `DevicesPage` (blocked empty-state).

### State (`_NodesPageState`)
| variable | type | initial | purpose |
|---|---|---|---|
| `_testing` | bool | false | full speed test running |
| `_refreshing` | bool | false | subscription fetch running |
| `_sort` | String | `'default'` | `default` / `latency` / `name` |
| `_testingNode` | `Set<String>` | {} | tags with individual latency test in flight |
| `_query` | String | `''` | debounced search text |
| `_testDone` / `_testTotal` | int | 0 / 0 | progress `done/total` |
| `_lastTick` / `_lastPct` | DateTime / double | epoch / -1 | progress throttling (≥120 ms or ≥5 %) |
| `_debounce` | `Timer?` | — | 300 ms search debounce |
| `_searchCtrl` | `TextEditingController` | — | search field |

Static layout constants: `_nodeRadius = circular(15)`, `_nodeMargin = fromLTRB(22,0,22,8)`, `_nodePadding = symmetric(13,12)`, `_flagRadius = circular(11)`, `_latencyRadius = circular(20)`.

### Layout
`Scaffold(body: SafeArea(Column(crossAxisAlignment: start)))`.
Rebuild trigger: `context.select((ConnectionController c) => (n: c.nodes.length, t: c.current?.tag))`.

**1. Title bar** `Padding(fromLTRB(22,10,22,4))` `Row`:
- `Text(nodes_title)` = "节点列表" 21px w700.
- `Spacer`.
- **Sort chip**: `GestureDetector(onTap: _pickSort)` → `Container(padding 9/5, color card2, radius 8, border line)` with `Icon(Icons.sort, 13, txt3)` + label (switch on `_sort`): `sort_default` "默认(国家/延迟)" / `sort_latency` "按延迟" / `sort_name` "按名称" (11px `txt3` w600).
- `SizedBox(8)`.
- **Refresh chip**: `GestureDetector(onTap: _refreshing ? null : () => _load(force: true))` → `Container(padding 10/5, color brand@.1, radius 8, border brand@.3)`; while refreshing a 14×14 spinner (`brandLight`), else `Text('🔄 ${refresh_sub}')` = "🔄 刷新订阅" (12px `brandLight` w600).

**2. Search + speed-test row** `Padding(fromLTRB(22,8,22,10))` `Row`:
- `Expanded(SizedBox(height 46, TextField))` with `mfInput(hint: search_hint "搜索节点 / 地区 / 协议")` + `prefixIcon: Icon(Icons.search, 17, txt3)` + `contentPadding: symmetric(12,11)` + `suffixIcon: Icon(Icons.close, 16, txt3)` shown only when `_query.isNotEmpty` (tap clears controller, cancels debounce, resets `_query`). `onChanged` restarts the 300 ms debounce before committing `_query`.
- `SizedBox(10)`.
- **Speed-test button**: `GestureDetector(onTap: _testing ? null : _runSpeedTest)` → `Container(height 44, padding horizontal 14, gradient brandGradient, radius 13, centered)`; while `_testing`: 12×12 white spinner + 7 + `'$_testDone/$_testTotal'` (12.5px white w600 `kNumFont`); else `Text('⚡ ${speed_test}')` = "⚡ 测速" (12.5px white w600).

**3. Body** `Expanded` — one of three branches:
- `conn.nodes.isEmpty` → `_EmptyNodesView(refreshing, onRefresh)`:
  - Not blocked: centered `Text(no_nodes "暂无节点，请先刷新订阅")` 14px `txt3` + gradient `Container(padding 20/10, radius 12)` with `refresh_sub` "刷新订阅" (13px white w600) or a 16×16 white spinner.
  - Blocked: centered `Padding(horizontal 30)` `Column[Text('⛔', 30px), 10, Text(acc.blockText, 13.5px txt2, centered, height 1.6), 16, if status ∈ {expired, noSubscription, deviceFull}: gradient chip (padding 22/10, radius 12) with `manage_devices` "管理设备" (deviceFull → push `DevicesPage`) else `go_purchase` "去开通" (→ tab 2)]`.
- `groups.isEmpty` (search matched nothing) → centered `Text(no_match_nodes "没有匹配的节点，换个关键词试试")` 13px `txt3`.
- else → `_NodeListView`.

**`_NodeListView`** (stateful, flattening + collapse):
- `_collapsed: Set<String>` initialized in `initState` to **all** country codes except the current node's country.
- Flat entry list: a `'__header__$code'` marker per country, followed by its nodes only when `searching || !_collapsed.contains(code)`.
- `ListView.builder(padding bottom 12)`.
- **`_CountryHeader`**: `InkWell(onTap: toggle, radius 10)` → `Padding(fromLTRB(24,8,20,8))` `Row[Text(regionFlag(code), 13px), 7, Expanded(Text(regionName(code), 12px txt3 w700 letterSpacing 1 ellipsis)), Text('$count ${nodes_count}') e.g. "23 个节点" (11px txt3 kNumFont), 6, AnimatedRotation(turns: collapsed ? -0.25 : 0, 180ms, child: Icon(Icons.keyboard_arrow_down, 20, txt3))]`.
- **Node row** (`_buildNodeRow`): `GestureDetector(onTap: switch + toast `switched_to`)` → `Container(margin/padding/radius as above)`; current node → bg `brand@.09`, border `brand@.6`; else `card` + `line`. `Row[Container(34×34, card2, radius 11, centered: CountryFlag(size 17)), 12, Expanded(Column[Text(tag, 13.5 w600 ellipsis), 2, Text('${n.type} · ${n.port}') 10.5px txt3 kNumFont, if current: 2 + Text('✨ ${selected}') = "✨ 已选中" 9.5px brandLight w600]), latency pill, if current: 8 + 18×18 gradient circle with Icon(Icons.check, 11, white)]`.
- **Latency pill** = `GestureDetector(onTap: _testing ? null : () => _testOne(n))` → `Container(padding 9/3, bg latencyColor@.1, radius 20, border latencyColor@.25)`; while that node is testing: 11×11 spinner strokeWidth 1.6; else `_latencyLabel(n)`:
  - UDP-only and untested → `node_need_connect_test` "连接后测速" (9.5px, no `kNumFont`)
  - online & measured → `"$ms ms"` (11.5px `kNumFont`)
  - else → `"— ms"` (9.5px)
  all w600, colored by `mfLatencyColor(latencyMs, online)`.

### Logic / services
- `_load({force})`: `SubscriptionService.fetchNodes(force:)` → `conn.applySubscriptionNodes(nodes)`; empty → toast `no_nodes_hint` "订阅中没有可用节点"; non-empty + force → toast `refresh_sub_ok` "订阅已刷新"; kicked → disconnect + clear nodes + toast.
- `_runSpeedTest()`: empty nodes → `no_nodes`; filtered empty → `no_match_nodes`; else `conn.speedTest(tags: filtered ? tagSet : null, switchToBest: conn.autoTest, userInitiated: true, onProgress: _onTestProgress)`; results: `tested == 0` → `speed_test_none` "测速未执行，请稍后重试"; filtered → `speed_done_filtered` "已测速筛选出的 {n} 个节点"; else `speed_done` "测速完成，已按延迟排序". **Only the filtered/visible subset is tested.**
- `_testOne(n)`: `conn.testOneNode(n)` → replaces that node with a clone carrying the fresh latency (`online = n.isUdpOnly ? true : mfLatencyUsable(ms)`) → `conn.loadNodes(list)`.
- `_pickSort()` → `showModalBottomSheet<String>(backgroundColor: card, radius top 20)`: `SizedBox(10)`, title `sort_title` "排序方式" (15px w700), then `ListTile`s for `('default', sort_default)`, `('latency', sort_latency)`, `('name', sort_name)` — 13.5px text, trailing `Icon(Icons.check, 16, brandLight)` when selected; `SizedBox(6)`.
- Group ordering: `ProxyNode.countryRank(a)` (HK/JP/SG/US first, then distance from China) with `regionName` as tiebreak. Intra-group: default → `ProxyNode.compareForList`; latency → online first then ascending; name → lowercase alphabetical.
- Helpers at file scope: `regionFlag(code) => ProxyNode.flagEmoji(code)`; `regionName(code) => ProxyNode.countryNames[code] ?? (2-letter && != 'XX' ? code : '其他')` (literal "其他").
- Search matches `tag`, `type`, `countryCode`, `regionName` (lowercased contains).

### Empty / loading / error
See body branches above. Subscription/API errors → `ApiClient.errorMsg` toast. Refresh spinner lives inside the refresh chip; speed-test progress lives inside the ⚡ button.

### Responsive / desktop
None. No `MediaQuery`, no `Platform` checks — identical layout on all platforms (only the flag rendering changes: local PNG with emoji fallback via `CountryFlag`).

---

## 7. `lib/pages/package/package_page.dart` — `PackagePage`

**Entry**: tab 2 of `MainShell`; also reached by `mainTabIndex.value = 2` from home/profile/nodes. Doc: `/// 购买套餐：上下列表模式（每行 = 名称/说明/价格/购买）＋ 支付方式。真实链路：选套餐 → 下单 → 发起支付 → 二维码轮询 → paid 后刷新订阅`.

### State
| variable | type | initial |
|---|---|---|
| `_plans` | `List<Plan>` | `[]` |
| `_methods` | `List<PayMethod>` | `[]` |
| `_loading` | bool | `true` (only when there is no cache) |
| `_selectedPlan` | `int?` | auto-selects the recommended plan, else index 0 |
| `_selectedMethod` | `int?` | 0 when methods exist |
| `_paying` | bool | false |
| `_error` | `String?` | load failure (distinct from "no plans") |

### Data sources
`PaymentService.instance.loadCatalog() / adoptCatalog() / plans(force:true) / methods(force:true)` → `GET /packages`, `GET /payment/methods`; `OrderService.instance.create(packageId:, paymentMethodKey:)` → `POST /orders`; `.pay(orderId:, paymentMethodId:)` → `POST /payment`; `AccountService.instance.refreshAfterPurchase()`; `ConnectionController.applySubscriptionNodes`. Cached catalog is shown instantly on cold start, then silently refreshed.

### Layout — `Scaffold(body: SafeArea(_loading ? _buildSkeleton() : RefreshIndicator(onRefresh: _load, child: ListView(padding fromLTRB(18,10,18,24)))))`

**Skeleton (`_buildSkeleton`)** — static grey blocks in `card2` mirroring the real layout (no shimmer animation): `ListView(NeverScrollableScrollPhysics)` with blocks 140×21, 200×12, three `planRow()`s (card radius 16, `card` bg, `line` border: 120×15 + 180×11 on the left, 54×22 on the right), block 80×13, two `methodRow()`s (34×34 r10 tile + 90×14 + 140×10), and a full-width 50×r14 block.

**Loaded content, top → bottom**:
1. Title `Text(purchase_title)` = "购买套餐" (21px w700).
2. `SizedBox(3)` + `Text(purchase_sub)` = "选择适合你的加速方案，付款后立即开通" (12px `txt3`).
3. `SizedBox(16)`.
4. **Error branch** (`_error != null`): `SizedBox(height 320, MFEmpty(title: _error!, icon: Icons.cloud_off_outlined, actionLabel: retry "重试", onAction: _load))`.
5. **Empty branch** (`_plans.isEmpty`): `SizedBox(height 320, MFEmpty(title: no_plans "暂无可用套餐"))` (default icon `Icons.inbox_outlined`).
6. **Plan rows** — `_buildPlanRow(i, plan)` for each plan:
   - `GestureDetector(onTap: select)` → `Container(margin bottom 10, padding fromLTRB(15,13,15,13), radius 16)`.
   - Selected: `LinearGradient([Color(0x2E455FE9), Color(0x0F455FE9)])`, border `brand@.7` width 1.3, shadow `brand@.18` blur 22.
   - Unselected: `color: card`, border `line` width 1.
   - Left `Column`: Row[`Flexible(Text(p.name, 15px w800 txt ellipsis))`, if `p.isRecommended`: 7 + `Container(padding 8/2, gradient brandGradient, radius 99)` with `recommended` "最划算" (9px white w700 letterSpacing .5)]; then 5 + `Text(_desc(p), 10.5px txt2, height 1.45, maxLines 2 ellipsis)`.
   - Right: `Text.rich('¥${formatPrice(p.price)}' 19px w800 kNumFont in (selected ? brandLight : txt) + _periodLabel(p) 10.5px txt3)`.
   - **`_desc(p)`**: if the backend `description` exists → it is normalized (`'有效期 '` removed, `'天 | '` → `' 天 · '`, `' | '` → `' · '`); else composed as `"{durationDays} 天 · {deviceLimit} 设备 · 不限"` (literal Chinese + `unlimited` "不限").
   - **`_periodLabel(p)`**: `≥365 → '/年'`, `≥90 → '/季'`, else `'/月'` (hard-coded Chinese, not i18n).
7. `SizedBox(6)` + section title `Text(pay_methods)` = "选择支付方式" (13px w600 `txt2`) + `SizedBox(10)`.
8. **Payment methods** — `_buildMethod(i, m)`; if empty → `Padding(vertical 12)` with `Text(no_pay_methods)` = "暂无可用的支付方式，请稍后再试" (12.5px `txt3`).
   Each row: `GestureDetector(onTap: select)` → `Container(margin bottom 8, padding 13/11, radius 15)`; selected → bg `brand@.08`, border `brand@.65`; else `card` + `line`. Content: 34×34 `Container(bg, radius 10, centered)` with a one-character badge, 12, `Expanded(Column[Text(label, 14px w600), Text(sub, 10.5px txt3)])`, then a 20×20 radio circle (border `brandLight` when selected else `line2`, width 2) with a 3-padded inner dot in `brandLight` when selected.
   Method mapping `(icon, bg, label, sub)`:
   | predicate | icon char | tile bg | label | sub |
   |---|---|---|---|---|
   | `m.isAlipay` | `支` | `MFColors.brand @ .85` | `alipay` "支付宝" | `recommended_sub` "推荐 · 扫码支付" |
   | `m.isWechat` | `微` | `Color(0xFF07C160)` | `wechat_pay` "微信支付" | `scan_pay` "扫码支付" |
   | `m.isCrypto` | `₮` (11px) | `Color(0xFF2A3242)` | `usdt` "USDT 加密货币" | `chain_confirm` "链上确认后开通" |
   | fallback | first char of `m.name` (or `支`) | `card2` | `m.name` | `scan_pay` |
   Badge text is always white w700 (13px, 11px for crypto).
9. `SizedBox(10)` + `Text(pay_hint)` = "支付方式随官网设置实时同步：dy.moneyfly.top 后台启用的支付渠道会自动出现在这里，默认支付宝。" (10.5px `txt3`, height 1.6).
10. `SizedBox(18)` + **Total card**: `Container(padding 16/14, card, radius 16, border line)` `Row[Text(total "合计") 13px txt2, Spacer, Text.rich('¥' 14px txt3 + formatPrice(_amount) 24px w700 kNumFont)]`.
11. `SizedBox(14)` + `MFPrimaryButton(pay_now "立即支付", loading: _paying)`.

### Purchase flow (`_pay`)
1. Guard: no plan → toast `select_plan` "请选择套餐"; no method → toast `select_pay` "请选择支付方式".
2. `OrderService.create(packageId: plan.id, paymentMethodKey: method.payType)` (one round trip: order + payment).
3. `orderId == 0` → throw `order_failed` "订单创建失败".
4. If returned `status == 'paid'` (free / fully discounted) → `activate()`: toast `activated` "开通成功！已为你准备最新节点" + `refreshAfterPurchase()` + apply nodes. **No QR.**
5. Amount precedence: `final_amount` → `amount` → plan price.
6. QR precedence: `payment_qr_code` → `payment_url` → else `OrderService.pay(...).qrCode`; empty → throw `no_qrcode` "未获取到支付二维码".
7. `showDialog(barrierDismissible: false, → PaymentQrDialog(qrContent, orderNo, amount, methodName, onPaid: () {}))`; `paid == true` → `activate()`.
8. Any exception → toast `ApiClient.errorMsg(e)`; `_paying` reset in `finally`.

### Responsive / desktop
None (no platform or media-query branching).

---

## 8. `lib/pages/package/upgrade_devices_page.dart` — `UpgradeDevicesPage`

**Entry**: pushed from `DevicesPage` upgrade card and from the home blocked dialog (deviceFull). Doc: `/// 设备增量升级：设备超限时 +N 台（可选顺带 +M 天到期）。调后端 POST /orders/upgrade-devices（preview_only 算价 → 下单 → 扫码支付）`.

### Constants & state
| item | value |
|---|---|
| `_deviceOptions` | `[1, 2, 3, 4, 5]` |
| `_dayOptions` | `[0, 30, 90, 180, 365]` |
| `_addDevices` | `1` |
| `_addDays` | `0` |
| `_methods` / `_selectedMethod` | payment methods, default index 0 |
| `_loading` | true during `_init` |
| `_previewing` | price recalculation in flight |
| `_paying` | order/payment in flight |
| `_finalAmount` / `_originalAmount` | `double?` (struck-through original when discounted) |
| `_previewError` | error text shown under the amount row |
| `_debounce` | 350 ms, restarts `_preview()` on every chip change |

Derived: `_sub => AccountService.instance.sub`; `_recommendedDays`: `0`, or `90` when expired or `remainingDays < 45`; `_expired => _sub?.isExpired ?? false`.

### AppBar
`Icons.arrow_back_ios_new` (18) → pop; title `upgrade_title` = "升级设备".

### Layout (`_loading` → centered `CircularProgressIndicator(brand)`, else `ListView(padding fromLTRB(20,8,20,28))`)
1. **Current-subscription card**: `Container(padding 14, radius 14, gradient [Color(0x38455FE9), Color(0x0F455FE9)], border brand@.3)` `Column[Text(upgrade_current "当前订阅", 11px txt3), 8, Text('$used / $limit ${devices_unit}' + ' · ${upgrade_expire} $expireText') e.g. "3 / 5 台 · 到期 2026-03-14" (15px w700 txt)]`. `expireText` = `yyyy-MM-dd` or `—`.
2. `SizedBox(16)` → section title `Text(upgrade_add_devices)` = "增加设备数量（立即生效，多台设备可同时在线）" (13px w700 `txt` via `_sectionStyle()`).
3. `SizedBox(8)` → `Wrap(spacing 8, runSpacing 8)` of **device chips**: labels `'${devices_unit} +$n'` e.g. "台 +1"…"台 +5" (12.5px; selected w700 white on `brandGradient` with transparent border; unselected w500 `txt` on `card` with `line` border; `recommended` chips get an `amber@.7` border). Chip padding 14/9, radius 10.
4. `SizedBox(16)` → Row[`Text(upgrade_add_days "顺带增加时长（到期顺延）")`, `Spacer`, if not expired and `_recommendedDays == 0`: `Text(upgrade_no_days_needed "到期时间充足，可不加时长")` (10px `txt3`)].
5. `SizedBox(8)` → **day chips**: `0` → label `upgrade_days_only` "不加时长"; else `'+$d ${days}'` e.g. "+90 天". The `0` chip is **disabled** (`onTap: null`) when `_expired` ("已过期必须顺带加时长"). The chip equal to `_recommendedDays` renders with the amber border **plus** a trailing `upgrade_recommend` "推荐" label (9.5px w700 amber).
6. If `_expired`: `Padding(top 6)` + `Text(upgrade_expired_hint "订阅已到期：增加设备需同时选择加时长")` (10.5px `amber`).
7. `SizedBox(16)` → **Amount card**: `Container(padding 14/12, card, radius 12, border line)` `Row[Text(upgrade_amount "应付金额") 13px txt2, Spacer, (_previewing ? 14×14 spinner : _finalAmount != null ? Row[if discounted: '¥${original.toStringAsFixed(2)}' 11px txt3 lineThrough, '¥${final.toStringAsFixed(2)}' 20px w800 brand kNumFont] : Text('—' 15px txt3 kNumFont))]`.
8. If `_previewError != null`: `Padding(top 6)` + `Text(_previewError!)` (10.5px `red`).
9. `SizedBox(16)` → `Text(pay_methods "选择支付方式")` + `SizedBox(8)`; empty → `Text(no_pay_methods)` (12px `txt3`); else `Wrap` of **payment chips** (`_payChip`): `Container(padding 14/8, radius 10)`, selected → bg `brand@.12` + border `brand@.7` + text `brand`; else `card` + `line` + `txt`; label = `m.name` (12.5px).
10. `SizedBox(20)` → **pay button** (`GestureDetector(onTap: (_paying || _finalAmount == null) ? null : _pay)`): `Container(height 50, radius 14)`, enabled → `brandGradient`; disabled → `color: card2`. Label: `_paying` → 20×20 white spinner; else `upgrade_pay_btn` "立即支付" (or `"立即支付 ¥{amount}"` when the amount is known), 15px w700, color `_paying ? white : txt3` (deliberately `txt3` so it stays readable on the light `card2` in light themes).
11. `SizedBox(10)` → `Text(upgrade_tip)` = "说明：支付成功后设备数立即增加、到期时间按所选天数顺延；新设备数对你名下所有节点生效。" (10.5px `txt3` height 1.6).

### Logic / services
- `_init()`: `PaymentService.methods()` (errors → `_previewError`), then `_preview()` after `_loading=false`.
- `_preview()`: `OrderService.previewDeviceUpgrade(addDevices:, addDays:)` → `final_amount ?? amount ?? 0`; keeps `amount` as `_originalAmount` for the strike-through. Errors → clear amount + `_previewError`.
- `_pay()`: no method → `select_pay`; `_finalAmount == null || <= 0` → `upgrade_no_amount` "金额未计算出来，请稍候重试"; then `OrderService.createDeviceUpgrade(...)`; `status == 'paid'` → `activate()`; else QR from `payment_qr_code`/`payment_url`/`pay()` → `PaymentQrDialog`; `paid == true` → `activate()`.
- `activate()`: toast `upgrade_done` "设备升级成功" → `refreshAfterPurchase()` → apply nodes → `Navigator.pop(true)`.

### Empty / loading / error
Full-page spinner while `_loading`; inline spinner in the amount row while previewing; `_previewError` in red under the amount; disabled pay button when the amount is unavailable. Toasts use an explicit style: `SnackBar(fontSize 13, behavior: floating, backgroundColor: MFColors.card2)`.

### Responsive / desktop
None.

---

## 9. `lib/pages/payment/payment_dialog.dart` — `PaymentQrDialog`

**Entry**: `showDialog<bool>(barrierDismissible: false)` from PackagePage, UpgradeDevicesPage and OrdersPage. Doc: `/// 支付二维码弹窗：渲染二维码 + 后台静默轮询订单状态。手机端对支付宝额外提供跳转 App 按钮（同机无法自扫屏幕）；桌面端仅二维码。`

### Constants / state
| item | value |
|---|---|
| `_timeoutSecs` | `900` (15 min, aligned with QR validity) |
| `_pollIntervalMs` | `3000` (same as the website; backend queries the gateway per call) |
| `_zoom` | bool, QR 196 → 250 |
| `_polling` | bool, false after timeout/terminal state |
| `_launching` | bool, anti-double-tap on the launch button |
| `_timer` | `Timer.periodic` |
| `_pollInFlight` | re-entrancy guard |
| `_startAt` | `DateTime`, timeout baseline |
| `createState` mixin | `WidgetsBindingObserver` — on `resumed` polls once immediately |

Widget params: `qrContent`, `orderNo`, `amount`, `methodName`, `onPaid`.

### Layout — `Dialog(backgroundColor: Colors.transparent, insetPadding: symmetric(horizontal 26))`
Container `padding fromLTRB(20,22,20,18)`, `radius 26`, **fixed dark gradient** `LinearGradient(topCenter→bottomCenter, [Color(0xFF171E2E), Color(0xFF10141F)])` (ignores light appearances), border `MFColors.line2`.

Top → bottom:
1. Title `Text(AppStrings.t('pay_with_method', {'method': methodName}))` e.g. "使用 支付宝 支付" (16.5px w700 white).
2. `SizedBox(3)` + `Text('${methodName.toUpperCase()} · SECURE PAYMENT')` (**hard-coded English**, 10px white60, letterSpacing 1.4).
3. `SizedBox(16)` + **QR** `GestureDetector(onTap: () => setState(_zoom = !_zoom))` → `AnimatedContainer(200ms, 196 or 250 square, padding 11, white, radius 17, shadow black@.5 blur 30)` containing `QrImageView(data, version: auto, size 174/228, backgroundColor white, eyeStyle square #111111, dataModuleStyle square #111111)`.
4. `SizedBox(6)` + `Text(qr_tap_zoom "点按二维码可放大")` (10px white60).
5. `SizedBox(12)` + amount `Text.rich('¥' 15px white + formatPrice(amount) 31px w700 white kNumFont)`.
6. `SizedBox(5)` + **order number row** `GestureDetector(onTap: Clipboard.setData(orderNo) + SnackBar(order_copied "订单号已复制", 1 s))` → `Row(centered)[Text('${order_no} ${orderNo}') e.g. "订单号 20260314…" (11px white70 kNumFont, letterSpacing .5), 5, Icon(Icons.copy, 12, white70)]`.
7. **Mobile-only launch button** (`showLaunch = _isMobile && _launchable`), `SizedBox(16)` gap: `GestureDetector(onTap: _launching ? null : _openPayApp)` → `Container(height 48, gradient brandGradient, radius 14, centered)`; while launching an 18×18 white spinner; else `Row[Icon(Icons.open_in_new, 16, white), 7, Text(open_pay_app {'method': methodName}) e.g. "打开支付宝支付" (14.5px white w700)]`.
8. `SizedBox(18)` + **action row**:
   - `Expanded(OutlinedButton(foregroundColor white70, side: BorderSide(Colors.white24), radius 14, padding vertical 14)` with `cancel` "取消" → `pop(false)`).
   - `SizedBox(10)`.
   - `Expanded(GestureDetector(onTap: _startPolling + SnackBar(confirming_pay "正在确认支付…")))` → `Container(height 50, gradient brandGradient, radius 14)` with `i_paid` "我已支付" (15px white w600).

### Polling logic
- `_startPolling()`: cancel timer, `_startAt = now`, `_pollInFlight = false`, `_polling = true`, `_pollOnce()` immediately, then `Timer.periodic(3 s)`.
- `_pollOnce()`: `OrderService.status(orderNo)` (`GET /orders/{orderNo}/status`) → `isPaid` → cancel timer, `_polling = false`, `onPaid?.call()`, `Navigator.pop(true)`; `cancelled`/`expired` → cancel + SnackBar `order_status_tip {'status': cancelled|expired}` e.g. "订单状态：已取消"; `pending` and transient network errors → silent, retried next tick.
- Timeout: from the periodic callback, `now - _startAt >= 900 s` → cancel + stop polling (dialog stays open; 我已支付 restarts it).
- `_launchable`: false for `weixin://`, `wxp://`, `usdt:` prefixes; true for `http://`, `https://`, `alipay://`, `alipays://`. `qr.alipay.com` content is rewritten to `alipays://platformapi/startapp?saId=10000007&qrcode=<encoded>` and opened with `LaunchMode.externalApplication`; failure → SnackBar `open_pay_failed` "未能打开支付应用，请改用扫码支付".

### Responsive / desktop
`_isMobile` = `defaultTargetPlatform` is Android or iOS → the launch button appears **only** on mobile; desktop and web show QR + order number + actions. Everything else is platform-agnostic. No width adaptation (fixed 196/250 QR, fixed dialog padding).
