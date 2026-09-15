# MoneyFly icon / emoji / hard-coded string inventory (machine-extracted)

## Material icons per file

- `lib/pages/auth/login_page.dart`: `Icons.visibility_off_outlined`, `Icons.visibility_outlined`
- `lib/pages/auth/register_page.dart`: `Icons.arrow_back_ios_new`, `Icons.check`, `Icons.visibility_off_outlined`, `Icons.visibility_outlined`
- `lib/pages/auth/forgot_password_page.dart`: `Icons.arrow_back_ios_new`, `Icons.visibility_off_outlined`, `Icons.visibility_outlined`
- `lib/pages/auth/change_password_page.dart`: `Icons.arrow_back_ios_new`, `Icons.visibility_off_outlined`, `Icons.visibility_outlined`
- `lib/pages/home/home_page.dart`: `Icons.arrow_downward_rounded`, `Icons.arrow_upward_rounded`, `Icons.auto_awesome`, `Icons.check_circle`, `Icons.chevron_right`, `Icons.gps_fixed`, `Icons.power_settings_new_rounded`, `Icons.refresh`, `Icons.settings_outlined`, `Icons.travel_explore`
- `lib/pages/nodes/nodes_page.dart`: `Icons.check`, `Icons.close`, `Icons.keyboard_arrow_down`, `Icons.search`, `Icons.sort`
- `lib/pages/package/package_page.dart`: `Icons.cloud_off_outlined`
- `lib/pages/package/upgrade_devices_page.dart`: `Icons.arrow_back_ios_new`
- `lib/pages/payment/payment_dialog.dart`: `Icons.copy`, `Icons.open_in_new`
- `lib/pages/profile/profile_page.dart`: `Icons.chevron_right`, `Icons.cloud_off_outlined`, `Icons.flight_takeoff`
- `lib/pages/orders/orders_page.dart`: `Icons.arrow_back_ios_new`, `Icons.cloud_off`
- `lib/pages/devices/devices_page.dart`: `Icons.arrow_back_ios_new`, `Icons.chevron_right`, `Icons.delete_outline`, `Icons.edit_outlined`
- `lib/pages/notifications/notifications_page.dart`: `Icons.arrow_back_ios_new`, `Icons.cloud_off`
- `lib/pages/settings/settings_page.dart`: `Icons.arrow_back_ios_new`, `Icons.check`, `Icons.chevron_right`
- `lib/pages/settings/kernel_page.dart`: `Icons.arrow_back_ios_new`, `Icons.check_circle`, `Icons.chevron_right`
- `lib/pages/settings/log_center_page.dart`: `Icons.arrow_back_ios_new`, `Icons.copy`, `Icons.delete_outline`, `Icons.filter_alt`, `Icons.filter_alt_outlined`, `Icons.refresh`
- `lib/pages/settings/access_page.dart`: `Icons.arrow_back_ios_new`, `Icons.search`
- `lib/pages/settings/bypass_page.dart`: `Icons.arrow_back_ios_new`, `Icons.close`
- `lib/pages/settings/geo_update_page.dart`: `Icons.arrow_back_ios_new`
- `lib/widgets/mf_empty.dart`: `Icons.cloud_off`, `Icons.inbox_outlined`
- `lib/widgets/password_rules.dart`: `Icons.check_circle`, `Icons.circle_outlined`
- `lib/main.dart`: `Icons.dns`, `Icons.dns_outlined`, `Icons.home`, `Icons.home_outlined`, `Icons.payments`, `Icons.payments_outlined`, `Icons.person`, `Icons.person_outline`

## Emoji / non-ASCII glyph literals per file (used as in-UI icons)

- `lib/pages/auth/forgot_password_page.dart`: L158 `✓`; L216 `⚠ $_formError`
- `lib/pages/auth/change_password_page.dart`: L72 `🔒 ${AppStrings.t(`
- `lib/pages/home/home_page.dart`: L261 `🚫 ${AppStrings.t(`; L315 `⏰`; L316 `📱`; L317 `🚫`; L318 `🛒`; L319 `⚠️`; L468 `—`; L470 `—`; L493 `—`; L565 `⏰`; L566 `📱`; L569 `🚫`; L570 `🛒`; L571 `ℹ️`; L1285 `⚡ ${AppStrings.t(`; L1331 `—`; L1639 `)} ${conn.sessionUptime} · `
- `lib/pages/nodes/nodes_page.dart`: L312 `🔄 ${AppStrings.t(`; L376 `⚡ ${AppStrings.t(`; L424 `— ms`; L460 `${n.type} · ${n.port}`; L464 `✨ ${AppStrings.t(`; L696 `⛔`
- `lib/pages/package/package_page.dart`: L186 ` · `; L189 ` · `; L319 `¥`; L391 `¥${formatPrice(p.price)}`; L412 `₮`
- `lib/pages/package/upgrade_devices_page.dart`: L206 `—`; L244 ` · ${AppStrings.t(`; L362 `—`
- `lib/pages/payment/payment_dialog.dart`: L210 `¥`
- `lib/pages/profile/profile_page.dart`: L81 `—`; L177 `¥${balance.toStringAsFixed(2)}`; L197 `⏰`; L231 `🚫`; L237 `🚫`; L243 `⏰`; L251 `📱`; L345 `● ${AppStrings.t(`; L366 `📱`; L367 `🧾`; L368 `🔔`; L369 `⚙️`; L370 `ℹ️`
- `lib/pages/devices/devices_page.dart`: L172 `—`; L193 `📈`; L193 `➕`; L242 `📱`; L255 ` · `
- `lib/pages/settings/settings_page.dart`: L98 `🎯`; L105 `🔌`; L108 `🚀`; L117 `🚪`; L121 `⚡`; L123 `🔁`; L125 `⏱️`; L127 `🧭`; L133 `🚀`; L142 `🧱`; L153 `🌐`; L157 `🧭`; L175 `🧩`; L182 `🔓`; L186 `🏠`; L188 `🚫`; L194 `📱`; L201 `🔢`; L205 `🔧`; L211 `🧩`; L215 `🌍`; L222 `🌏`; L225 `🪪`; L233 `🔑`; L235 `🧹`; L244 `🔄`; L251 `📋`; L255 `💥`; L379 `🎨`; L1038 ` · ${info.sizeText}`
- `lib/pages/settings/kernel_page.dart`: L373 `🧩`; L380 `⚡`; L400 `🆕`; L418 `⬇️`; L471 `🔀`; L474 `${_variantLabel(_variant)} ▾`
- `lib/pages/settings/access_page.dart`: L203 ` · ${AppStrings.t(`
- `lib/pages/settings/bypass_page.dart`: L171 `📡`; L172 `🎯`; L173 `🌐`; L304 ` · ${AppStrings.t(`
- `lib/pages/settings/geo_update_page.dart`: L67 `；`; L103 `🧠`; L108 `🧭`; L113 `📦`; L118 `🟢`; L118 `⚪`

## Hard-coded user-visible CJK / mixed literals NOT in AppStrings

| file:line | literal | note |
|---|---|---|
| lib/pages/auth/login_page.dart:68 | `禁用` | |
| lib/pages/auth/login_page.dart:69 | `禁止` | |
| lib/pages/auth/register_page.dart:205 | `我已阅读并同意 ` | |
| lib/pages/auth/register_page.dart:206 | `《用户协议》` | |
| lib/pages/auth/register_page.dart:207 | ` 与 ` | |
| lib/pages/auth/register_page.dart:208 | `《隐私政策》` | |
| lib/pages/nodes/nodes_page.dart:742 | `其他` | |
| lib/pages/package/package_page.dart:171 | `/年` | |
| lib/pages/package/package_page.dart:172 | `/季` | |
| lib/pages/package/package_page.dart:173 | `/月` | |
| lib/pages/package/package_page.dart:178 | `${p.durationDays} 天` | |
| lib/pages/package/package_page.dart:179 | `${p.deviceLimit} 设备` | |
| lib/pages/package/package_page.dart:184 | `有效期 ` | |
| lib/pages/package/package_page.dart:185 | `天 | ` | |
| lib/pages/package/package_page.dart:185 | ` 天 · ` | |
| lib/pages/package/package_page.dart:408 | `支` | |
| lib/pages/package/package_page.dart:410 | `微` | |
| lib/pages/package/package_page.dart:413 | `支` | |
| lib/pages/settings/settings_page.dart:223 | `简体中文` | |

## Runtime-generated user-visible strings (composed in code, not in AppStrings)

| composed string | where | example output |
|---|---|---|
| `¥{amount}` / `¥{formatPrice}` | package_page, payment_dialog, upgrade_devices_page, profile_page, orders_page | `¥19.9` |
| `{ms} ms` / `{ms}ms` / `— ms` | home_page node pill & picker, nodes_page latency pill | `88 ms` |
| `{n}/{total}` | nodes_page speed-test progress, profile_page devices | `12/50` |
| `{h}:{m}` | home_page subscription refresh time | `14:07` |
| `--:--` | home_page when never refreshed | |
| `{used} / {limit} {devices_unit}` | upgrade_devices_page | `3 / 5 台` |
| `/年` `/季` `/月` | package_page `_periodLabel` (duration ≥365 / ≥90 / else) | hard-coded Chinese |
| `{days} 天`, `{deviceLimit} 设备` | package_page `_desc` fallback | hard-coded Chinese |
| `{type} · {port}` | nodes_page node row subtitle | `vless · 443` |
| `{osName} · {deviceModel}` | devices_page | `iOS · iPhone15,2` |
| `● {active|inactive}` | profile_page status pill | `● 生效中` |
| `v{version}` | profile/settings/kernel/geo rows | `v2.2.5` |
| `MoneyFly v{ver} · dy.moneyfly.top` | settings_page footer (fixed, not i18n) | |
| `MoneyFly v{ver}\n\n{slogan}\ndy.moneyfly.top` | profile_page About dialog | |
| `{METHOD} · SECURE PAYMENT` | payment_dialog subtitle, English-only | `ALIPAY · SECURE PAYMENT` |
| `↑ {MB} ↓ {MB}` + `{uptime}` | home_page `_SessionInfo` | `已连接 00:12:30 · ↑ 1.2 MB ↓ 8.4 MB` |
| `{n} {nodes_count}` | nodes_page country header | `23 个节点` |
| `MB/s`, `KB/s` | home_page `_speedUnit` | |
| `IP`, `Location/位置`, `Version/版本`, `Access/访问`, `Recent/最近` meta keys | devices_page `_meta` (labels themselves are i18n) | |
| `country.mmdb`, `geosite.dat`, `mihomo`, `MetaCubeX/mihomo` | kernel_page / geo_update_page / settings_page | technical names, not translated |
| `Language` (dialog title) | settings_page:934 | English-only, even in zh |
| `简体中文` / `English` | settings_page:223 language row value | |
| `其他` | nodes_page:742 unknown-region fallback | |

