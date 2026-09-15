# MoneyFly AppStrings — complete zh / en table (machine-extracted from source)

Source: `lib/l10n/app_strings.dart` — **585 keys**, zh and en key sets identical (verified programmatically), zero duplicate keys.

Placeholders use `{name}` and are substituted at runtime by `AppStrings.t(key, {..})`. `\n` = real newline in the string.

| # | key | zh | en |
|---|-----|----|----|
| 1 | `app_name` | MoneyFly | MoneyFly |
| 2 | `bypass_help` | 支持：域名后缀 company.com（含子域名）｜精确域名 DOMAIN:app.example.com｜IP 段 IP-CIDR:192.168.1.0/24 | Supported: domain suffix company.com (incl. subdomains) \| exact domain DOMAIN:app.example.com \| IP range IP-CIDR:192.168.1.0/24 |
| 3 | `bypass_invalid_format` | 格式不支持，请输入：域名后缀、IP-CIDR:IP段 或 DOMAIN:精确域名 | Unsupported format — use a domain suffix, IP-CIDR:range, or DOMAIN:exact domain |
| 4 | `bypass_invalid_cidr` | IP 段格式不正确，示例：IP-CIDR:192.168.1.0/24 | Invalid IP range — e.g. IP-CIDR:192.168.1.0/24 |
| 5 | `bypass_invalid_domain` | 精确域名格式不正确，示例：DOMAIN:portal.example.com | Invalid exact domain — e.g. DOMAIN:portal.example.com |
| 6 | `bypass_type_suffix` | 域名后缀 | Suffix |
| 7 | `bypass_type_domain` | 精确域名 | Exact |
| 8 | `bypass_type_cidr` | IP 段 | IP range |
| 9 | `settings_dns_desc` | 主 DNS 列表，逗号分隔；多个可提升解析成功率 | Primary DNS servers, comma separated (multiple improves resolution) |
| 10 | `dns_list_hint` | 用逗号分隔，如 223.5.5.5,119.29.29.29 | Comma separated, e.g. 223.5.5.5,119.29.29.29 |
| 11 | `dns_list_required` | 请至少保留一个 DNS 服务器 | Keep at least one DNS server |
| 12 | `dns_list_invalid` | 第 {n} 个 DNS 服务器格式不正确 | DNS server #{n} is not a valid address |
| 13 | `settings_fakeip_extra` | fake-ip 过滤域名 | fake-ip filter domains |
| 14 | `settings_fakeip_extra_desc` | 追加保留真实解析、不映射 fake-ip 的域名 | Extra domains that keep real IPs instead of fake-ip |
| 15 | `fakeip_extra_hint` | 每行一个域名，如 *.lan 或 router.local | One domain per line, e.g. *.lan or router.local |
| 16 | `fakeip_invalid` | 第 {line} 行不是合法的域名 | Line {line} is not a valid domain |
| 17 | `connect` | 连接 | Connect |
| 18 | `disconnect` | 断开 | Disconnect |
| 19 | `connected` | 已连接 | Connected |
| 20 | `connected_for` | 已连接 | Connected |
| 21 | `connected_speed_testing` | 已连接 · 测速中 | Connected · Testing… |
| 22 | `disconnected` | 已断开 | Disconnected |
| 23 | `connecting` | 连接中 | Connecting… |
| 24 | `testing` | 测速中 | Testing… |
| 25 | `reconnecting` | 重连中 | Reconnecting… |
| 26 | `switching_mode` | 正在切换模式… | Switching mode… |
| 27 | `disconnecting_status` | 断开中 | Disconnecting… |
| 28 | `error` | 连接失败 | Connection failed |
| 29 | `loading` | 加载中… | Loading… |
| 30 | `retry` | 重试 | Retry |
| 31 | `refresh` | 刷新 | Refresh |
| 32 | `confirm` | 确定 | OK |
| 33 | `cancel` | 取消 | Cancel |
| 34 | `save` | 保存 | Save |
| 35 | `delete` | 删除 | Delete |
| 36 | `copy` | 复制 | Copy |
| 37 | `settings` | 设置 | Settings |
| 38 | `home` | 首页 | Home |
| 39 | `no_email` | 未登录邮箱 | Not signed in |
| 40 | `month` | 月 | mo |
| 41 | `quarter` | 季 | qtr |
| 42 | `year` | 年 | yr |
| 43 | `days_devices` | {days} 天 · {devices} 台 | {days} days · {devices} devices |
| 44 | `alipay` | 支付宝 | Alipay |
| 45 | `wechat_pay` | 微信支付 | WeChat Pay |
| 46 | `usdt` | USDT 加密货币 | USDT Crypto |
| 47 | `scan_pay` | 扫码支付 | Scan to pay |
| 48 | `recommended_sub` | 推荐 · 扫码支付 | Recommended · Scan to pay |
| 49 | `chain_confirm` | 链上确认后开通 | Activated after chain confirm |
| 50 | `profile_title` | 我的 | Me |
| 51 | `back` | 返回 | Back |
| 52 | `login_title` | 登录 | Sign In |
| 53 | `account_label` | 账号 / 邮箱 | Account / Email |
| 54 | `account_hint` | 请输入账号或邮箱 | Enter account or email |
| 55 | `password_label` | 密码 | Password |
| 56 | `password_hint` | 请输入密码 | Enter password |
| 57 | `auto_login` | 自动登录 | Auto sign-in |
| 58 | `login_button` | 登 录 | Sign In |
| 59 | `no_account` | 还没有账号？ | Don't have an account?  |
| 60 | `register` | 注册 | Sign Up |
| 61 | `forgot_password` | 忘记密码 | Forgot password |
| 62 | `slogan` | 极速 · 稳定 · 全球畅连 | Fast · Stable · Global Access |
| 63 | `register_title` | 注册账号 | Sign Up |
| 64 | `email_label` | 邮箱 | Email |
| 65 | `email_hint` | 用于接收验证码 | For verification code |
| 66 | `code_label` | 验证码 | Code |
| 67 | `code_hint` | 6 位验证码 | 6-digit code |
| 68 | `send_code` | 发送验证码 | Send Code |
| 69 | `resend_in` | s 后重发 | s to resend |
| 70 | `username_label` | 用户名 | Username |
| 71 | `username_hint` | 登录用户名（4-20 位） | 4-20 characters |
| 72 | `invite_label` | 邀请码（选填） | Invite code (optional) |
| 73 | `invite_hint` | 如有邀请码请填写 | Enter invite code if any |
| 74 | `agree_tos` | 我已阅读并同意 《用户协议》 与 《隐私政策》 | I agree to the Terms of Service and Privacy Policy |
| 75 | `home_ready` | 全球加速已就绪 | Ready for global access |
| 76 | `smart_mode` | 智能模式 | Smart Mode |
| 77 | `global_mode` | 全局模式 | Global Mode |
| 78 | `mode_hint` | 智能 = 国内直连 · 国外代理 ｜ 全局 = 全部流量走代理 | Smart = direct CN, proxy others \| Global = proxy all |
| 79 | `auto_test_title` | 自动测速 · 自动选优 | Auto Speed Test |
| 80 | `auto_test_on` | 已开启 | ON |
| 81 | `auto_test_off` | 已关闭 | OFF |
| 82 | `best` | 最优 | BEST |
| 83 | `retest` | 重新测速 | Retest |
| 84 | `quick_region` | 快速切换国家 | Quick Region |
| 85 | `region_hint` | 点按即切换该国最优节点 | Tap to switch to best node |
| 86 | `no_nodes` | 暂无节点，请先刷新订阅 | No nodes. Refresh subscription. |
| 87 | `no_subscription` | 尚未开通套餐，开通后即可畅连全球节点 | Subscribe a plan to unlock global nodes |
| 88 | `go_purchase` | 去开通 | Buy Now |
| 89 | `up_speed` | 上行 | Upload |
| 90 | `down_speed` | 下行 | Download |
| 91 | `current_node` | 当前线路 | Current Node |
| 92 | `tap_switch_node` | 点击切换线路 | Tap to switch |
| 93 | `nodes_title` | 节点列表 | Nodes |
| 94 | `search_hint` | 搜索节点 / 地区 / 协议 | Search node / region / protocol |
| 95 | `no_match_nodes` | 没有匹配的节点，换个关键词试试 | No matching nodes. Try another keyword |
| 96 | `speed_test` | 测速 | Speed Test |
| 97 | `sort_title` | 排序方式 | Sort by |
| 98 | `sort_default` | 默认(国家/延迟) | Default (region / latency) |
| 99 | `sort_latency` | 按延迟 | Latency |
| 100 | `sort_name` | 按名称 | Name |
| 101 | `auto_best` | 自动选择最优节点 | Auto-select best node |
| 102 | `pick_best` | 立即选优 | Select Best |
| 103 | `nodes_count` | 个节点 | nodes |
| 104 | `purchase_title` | 购买套餐 | Plans |
| 105 | `purchase_sub` | 选择适合你的加速方案，付款后立即开通 | Pick a plan, pay and activate instantly |
| 106 | `coupon_hint` | 优惠码（选填） | Coupon (optional) |
| 107 | `verify` | 验证 | Verify |
| 108 | `pay_methods` | 选择支付方式 | Payment Method |
| 109 | `pay_now` | 立即支付 | Pay Now |
| 110 | `total` | 合计 | Total |
| 111 | `pay_alipay_title` | 请使用支付宝扫码支付 | Scan with Alipay |
| 112 | `order_no` | 订单号 | Order No. |
| 113 | `waiting_pay` | 等待支付 | Waiting for payment |
| 114 | `i_paid` | 我已支付 | I have paid |
| 115 | `profile_devices` | 设备管理 | Devices |
| 116 | `profile_orders` | 我的订单 | Orders |
| 117 | `profile_coupons` | 优惠券 | Coupons |
| 118 | `profile_load_fail` | 账户信息加载失败，请重试 | Failed to load account info. Please retry |
| 119 | `profile_notifications` | 通知中心 | Notifications |
| 120 | `profile_about` | 关于 MoneyFly | About MoneyFly |
| 121 | `logout` | 退出登录 | Sign Out |
| 122 | `balance` | 账户余额 | Balance |
| 123 | `remaining_days` | 剩余天数 | Days left |
| 124 | `expire_time` | 到期时间 | Expires |
| 125 | `settings_conn` | 连接设置 | Connection |
| 126 | `settings_auto_connect` | 启动时自动连接 | Auto-connect on launch |
| 127 | `settings_launch_startup` | 开机自启动 | Launch at startup |
| 128 | `settings_auto_test` | 自动测速并选最优 | Auto speed test |
| 129 | `settings_auto_test_desc` | 连接前测速全部节点 | Test all nodes before connecting |
| 130 | `settings_reconnect` | 断线自动重连 | Auto-reconnect |
| 131 | `settings_reconnect_desc` | 断线后自动换最优节点重连；内核异常退出时始终自动恢复 | Reconnect with the best node after a drop; core crashes always auto-recover |
| 132 | `settings_test_interval` | 后台测速间隔 | Background test interval |
| 133 | `settings_dns` | DNS 服务器 | DNS Server |
| 134 | `settings_local_port` | 本地代理端口 | Local proxy port |
| 135 | `settings_local_port_desc` | 自定义本机代理端口（默认 2080） | Custom local proxy port (default 2080) |
| 136 | `local_port_invalid` | 端口需在 1024–65535，且不能与 Clash API 端口相同 | Port must be 1024-65535 and not equal to the Clash API port |
| 137 | `local_port_saved` | 端口已保存，下次连接生效 | Port saved, effective on next connect |
| 138 | `local_port_reconnect` | 端口已更新，正在自动重连… | Port updated, reconnecting... |
| 139 | `setting_saved_next_connect` | 已保存，下次连接生效 | Saved, effective on next connect |
| 140 | `setting_reconnect_applied` | 设置已更新，正在重连以生效… | Setting updated, reconnecting to apply... |
| 141 | `log_level_need_reconnect` | 日志级别已保存，重连后生效 | Log level saved, effective after reconnect |
| 142 | `settings_clash_api_port` | Clash API 端口 | Clash API Port |
| 143 | `settings_clash_api_port_desc` | 内核管理端口（切节点/测速/流量），默认 9090 | Core admin port (switch/test/traffic), default 9090 |
| 144 | `clash_api_port_invalid` | 端口需在 1024–65535，且不能与本地代理端口相同 | Port must be 1024-65535 and not equal to the local proxy port |
| 145 | `settings_test_url` | 测速地址 | Test URL |
| 146 | `settings_test_url_desc` | 测速/延迟测试探测地址，默认谷歌 204 | Speed-test probe URL (default Google 204) |
| 147 | `test_url_invalid` | 请输入 http:// 或 https:// 开头的有效地址 | Enter a valid URL starting with http:// or https:// |
| 148 | `tun_off_hint` | 仅系统代理：仅浏览器等 HTTP 应用生效，Steam/游戏等 UDP 流量不走代理 | System proxy only: works for HTTP apps like browsers; Steam/games over UDP will not use it |
| 149 | `tun_game_tip` | 提示：游戏/语音等 UDP 应用需选择「自动」或「强制」TUN 模式（Windows/macOS 需以管理员权限运行） | Tip: games/VoIP (UDP) need TUN Auto or Force (run as Administrator on Windows/macOS) |
| 150 | `settings_protocol` | 协议过滤 | Protocol filter |
| 151 | `settings_mode` | 模式 | Mode |
| 152 | `settings_default_mode` | 默认模式 | Default mode |
| 153 | `settings_network` | 网络 | Network |
| 154 | `settings_tun` | TUN 虚拟网卡 | TUN Virtual NIC |
| 155 | `settings_udp_insecure` | 放宽 hy2/tuic 证书校验 | Relax hy2/tuic certificate check |
| 156 | `settings_udp_insecure_desc` | hysteria2/tuic 节点普遍使用伪装 SNI，证书必然对不上；关闭校验才能连上（默认开） | hysteria2/tuic nodes usually use a spoofed SNI, so the certificate never matches; disabling verification is required to connect (on by default) |
| 157 | `settings_bypass_lan` | 绕过局域网流量 | Bypass LAN traffic |
| 158 | `settings_appearance` | 外观 | Appearance |
| 159 | `settings_theme` | 外观模式 | Appearance Mode |
| 160 | `appearance_light` | 浅色 | Light |
| 161 | `appearance_warm` | 暖白 | Warm |
| 162 | `appearance_gray` | 浅灰 | Light Gray |
| 163 | `appearance_darkgray` | 深灰 | Dark Gray |
| 164 | `appearance_darkblue` | 深蓝 | Dark Blue |
| 165 | `appearance_black` | 纯黑 | Pure Black |
| 166 | `settings_language` | 语言 | Language |
| 167 | `settings_subscribe_ua` | 订阅 User-Agent | Subscription User-Agent |
| 168 | `settings_subscribe_ua_desc` | 部分机场按 UA 返回不同格式；留空用默认 | Some providers return different formats by UA; leave empty for default |
| 169 | `settings_subscribe_ua_default` | 默认 | Default |
| 170 | `settings_privacy` | 隐私 | Privacy |
| 171 | `settings_notify` | 允许通知 | Notifications |
| 172 | `settings_notify_desc` | 套餐到期 / 连接状态提醒 | Expiry & connection status alerts |
| 173 | `settings_crash` | 崩溃日志上报 | Crash log |
| 174 | `settings_crash_desc` | 本地记录崩溃日志，可导出反馈 | Save crash logs locally for feedback |
| 175 | `settings_analytics` | 匿名使用统计 | Anonymous analytics |
| 176 | `settings_analytics_desc` | 仅匿名统计（版本/成功率），不收集个人信息（预留） | Anonymous stats only (version/success), no personal data (planned) |
| 177 | `settings_account` | 账号 | Account |
| 178 | `settings_change_pwd` | 修改密码 | Change password |
| 179 | `settings_about` | 关于 | About |
| 180 | `settings_check_update` | 检查更新 | Check for updates |
| 181 | `settings_log` | 运行日志 | Diagnostics Log |
| 182 | `settings_log_desc` | 查看/导出诊断日志 | View/export diagnostic logs |
| 183 | `settings_kernel_log` | 内核日志 | Kernel log |
| 184 | `settings_kernel_log_desc` | 实时查看代理引擎日志 | Live kernel (engine) log |
| 185 | `kernel_log_title` | 内核日志 | Kernel Log |
| 186 | `kernel_log_level` | 级别 | Level |
| 187 | `kernel_log_empty` | 暂无日志\n连接后实时产生（切 debug 可看更多） | No log yet\nGenerated live while connected (debug shows more) |
| 188 | `kernel_log_copied` | 日志已复制 | Log copied |
| 189 | `kernel_log_level_desc` | 级别同时作用于内核输出与本页显示：debug 最详细，error 只显示错误行 | Level applies to both kernel output and this page: debug is most verbose, error shows only errors |
| 190 | `kernel_log_empty_at_level` | 当前级别（{level}）下暂无日志\n切到 debug 可看全部输出 | No log at level {level}\nSwitch to debug to see everything |
| 191 | `log_center_title` | 日志中心 | Log Center |
| 192 | `settings_crash_report` | 崩溃日志记录 | Crash Log |
| 193 | `settings_crash_report_desc` | 开启后在本地记录崩溃详情，便于向客服反馈排查（不会自动上传） | Record crash details locally for support (never uploaded automatically) |
| 194 | `close_ask_title` | 关闭 MoneyFly？ | Close MoneyFly? |
| 195 | `close_ask_body` | 选择关闭方式：\n· 最小化到托盘：继续在后台运行（代理保持连接）\n· 退出：断开连接并结束程序 | How do you want to close?\n· Minimize to tray: keep running in background (proxy stays connected)\n· Quit: disconnect and exit |
| 196 | `minimize_tray_btn` | 最小化到托盘 | Minimize to tray |
| 197 | `quit_app_btn` | 退出 | Quit |
| 198 | `remember_choice` | 记住我的选择 | Remember my choice |
| 199 | `close_action` | 关闭窗口行为 | Close window action |
| 200 | `close_action_ask` | 每次询问 | Ask every time |
| 201 | `close_action_hide` | 最小化到托盘 | Minimize to tray |
| 202 | `close_action_quit` | 退出程序 | Quit |
| 203 | `log_center_desc` | 内核引擎与 App 运行日志 | Kernel engine & app runtime logs |
| 204 | `log_clear_confirm` | 清空全部运行日志？ | Clear all runtime logs? |
| 205 | `settings_kernel` | 内核管理 | Kernel |
| 206 | `settings_geo_data` | 更新分流数据 | Geo Data |
| 207 | `settings_geo_data_desc` | 国家 IP 库 / 分流规则（内置，可手动更新） | Country IP DB & routing rules (bundled, updatable) |
| 208 | `settings_bypass` | 直连名单 | Bypass list |
| 209 | `settings_bypass_desc` | 指定域名不走代理 | Domains that skip the proxy |
| 210 | `bypass_title` | 直连名单 | Bypass list |
| 211 | `bypass_desc` | 名单内的域名及其子域名将不走代理、直连网络。适合内网站点、被错误代理的域名等。 | Domains (and subdomains) here connect directly, skipping the proxy. For intranet sites or domains that should not be proxied. |
| 212 | `bypass_hint` | 输入域名，如 company.com | Enter a domain, e.g. company.com |
| 213 | `bypass_add` | 添加 | Add |
| 214 | `bypass_count` | 共 {n} 条 | {n} entries |
| 215 | `bypass_effect` | 更改在下次连接时生效 | Takes effect on next connection |
| 216 | `bypass_empty` | 还没有直连域名\n添加后该域名将绕过代理 | No bypass domains yet\nAdd one to route it directly |
| 217 | `bypass_invalid` | 域名格式不正确 | Invalid domain format |
| 218 | `bypass_exists` | 该域名已在名单中 | Domain already in the list |
| 219 | `settings_tun_stack` | TUN 内核栈 | TUN stack |
| 220 | `settings_tun_stack_desc` | 连接异常（打不开网页等）时可切换试试 | Switch if websites fail to load while connected |
| 221 | `settings_access` | 应用代理 | App proxy |
| 222 | `settings_access_desc` | 按 App 分流 / 排除（Android） | Per-app routing / exclusion (Android) |
| 223 | `access_title` | 应用代理 | App Proxy |
| 224 | `access_desc` | 控制哪些 App 走代理。支付/银行类 App 建议排除（避免异地风控），需要原生 IP 的 App（如某些游戏）也建议排除。 | Choose which apps go through the proxy. Consider excluding banking/payment apps (risk control) and apps that need a local IP. |
| 225 | `access_mode_all` | 全部走代理 | All apps |
| 226 | `access_mode_selected` | 仅以下应用走代理 | Selected apps only |
| 227 | `access_mode_denied` | 排除以下应用 | Exclude selected |
| 228 | `access_search_hint` | 搜索应用 | Search apps |
| 229 | `access_loading` | 加载应用列表… | Loading apps… |
| 230 | `access_none` | 未找到应用 | No apps found |
| 231 | `access_sel_count` | 已选 {n} 个 | {n} selected |
| 232 | `access_reconnect_btn` | 重连生效 | Reconnect to apply |
| 233 | `access_hint_all` | 所有应用的流量都走代理 | All app traffic goes through the proxy |
| 234 | `access_hint_selected` | ✓ 勾选的应用走代理 · 未勾选的应用直连（含 MoneyFly 自身） | Checked apps use the proxy · unchecked apps connect directly (MoneyFly itself always direct) |
| 235 | `access_hint_denied` | 勾选的应用直连（绕过代理）· 其余应用走代理 | Checked apps bypass the proxy (direct) · others use the proxy |
| 236 | `access_empty_perm` | 未能读取应用列表\n请到系统设置 → 应用 → MoneyFly → 权限，允许「查看所有应用」后重新进入 | Could not read app list\nAllow "View all apps" for MoneyFly in System settings → Apps → MoneyFly → Permissions, then reopen |
| 237 | `access_saved_tip` | 更改已保存 · 重连或下次连接后生效 | Saved · applies after reconnect or next connection |
| 238 | `tun_stack_gvisor` | gvisor（兼容优先） | gvisor (compatibility first) |
| 239 | `tun_stack_mixed` | mixed（速度优先） | mixed (speed first) |
| 240 | `settings_dns_mode` | DNS 模式 | DNS mode |
| 241 | `settings_dns_mode_desc` | 解析异常（打不开网页/部分站点失败）时可切换 | Switch if sites fail to resolve / open |
| 242 | `dns_mode_auto` | 自动（推荐） | Auto (recommended) |
| 243 | `dns_mode_fakeip` | fake-ip | fake-ip |
| 244 | `dns_mode_redirhost` | redir-host（传统） | redir-host (classic) |
| 245 | `kernel_title` | 内核管理 | Kernel |
| 246 | `kernel_current` | 当前内核 | Installed kernel |
| 247 | `kernel_running_state` | 连接状态 | Status |
| 248 | `kernel_running` | 运行中 | Running |
| 249 | `kernel_stopped` | 未连接 | Disconnected |
| 250 | `kernel_latest` | 官方最新 | Latest upstream |
| 251 | `kernel_source` | 内核来源：MetaCubeX/mihomo（官方原版，非 fork） | Kernel: MetaCubeX/mihomo (official, not a fork) |
| 252 | `kernel_variant_title` | 内核变体 | Kernel Variant |
| 253 | `kernel_variant_desc` | 下拉切换构建类型；同版本已下载过的不再重复下载 | Switch build via dropdown; same version cached locally is not re-downloaded |
| 254 | `kernel_variant_compatible` | 兼容版 | Compatible |
| 255 | `kernel_variant_compatible_desc` | 兼容老 CPU，启动稳定（默认，推荐） | Works on older CPUs, stable (default, recommended) |
| 256 | `kernel_variant_standard` | 标准版 | Standard |
| 257 | `kernel_variant_standard_desc` | 按新指令集编译，较新 CPU 性能更好 | Compiled with newer instruction sets; better on newer CPUs |
| 258 | `kernel_variant_in_use` | 使用中 | In use |
| 259 | `kernel_variant_switch` | 切换 | Switch |
| 260 | `kernel_restore_builtin` | 恢复内置内核 | Restore built-in kernel |
| 261 | `kernel_restore_builtin_desc` | 删除用户切换的副本，回到安装包自带内核（无需下载） | Remove the user-switched copy and go back to the bundled kernel (no download) |
| 262 | `kernel_restore_confirm` | 将删除用户切换/更新的内核副本，恢复为安装包内置内核（无需下载）。是否继续？ | This removes the user-switched/updated kernel copy and restores the kernel bundled with the app (no download). Continue? |
| 263 | `kernel_restore_done` | 已恢复为内置内核 | Restored to the built-in kernel |
| 264 | `kernel_restoring` | 正在恢复内置内核… | Restoring built-in kernel… |
| 265 | `kernel_variant_tip` | 提示：标准版需要较新的 CPU（AVX2/新指令集），老电脑上会启动即崩溃（0xC0000005），请使用兼容版。切换后断开重连生效。 | Note: the standard build needs a newer CPU (AVX2). On older PCs it crashes on startup (0xC0000005) — use Compatible. Takes effect after reconnect. |
| 266 | `kernel_switch_title` | 切换内核变体 | Switch Kernel Variant |
| 267 | `kernel_switch_confirm` | 切换为「{label}」：本地已缓存同版本则立即生效，否则需下载一次（约 40MB，连接中经隧道下载）。是否继续？ | Switch to "{label}": instant if this version is cached locally, otherwise one download (~40MB, via tunnel while connected). Continue? |
| 268 | `kernel_switch_done` | 内核已切换为{label}（无需重复下载），断开重连后生效 | Kernel switched to {label} (no re-download). Reconnect to apply |
| 269 | `kernel_apply_now_title` | 内核已下载完成 | Kernel downloaded |
| 270 | `kernel_apply_now_text` | 替换内核需要先断开当前连接。\n立即断开替换并自动重连，还是稍后手动断开再替换？ | Swapping the kernel requires disconnecting first.\nDisconnect now, swap and auto-reconnect — or do it later manually? |
| 271 | `kernel_apply_now` | 立即替换并重连 | Swap now & reconnect |
| 272 | `kernel_apply_later` | 稍后替换 | Later |
| 273 | `kernel_apply_later_tip` | 内核已下载到本地缓存，断开连接后再来本页替换（无需重新下载） | Kernel cached locally. Disconnect, then return here to swap (no re-download). |
| 274 | `geo_title` | 分流数据 | Geo Data |
| 275 | `geo_status` | 当前数据 | Current data |
| 276 | `geo_country_lib` | 国家 IP 库 | Country IP database |
| 277 | `geo_rules` | 分流规则 | Routing rules |
| 278 | `geo_builtin` | 随 App 内置 | Bundled in app |
| 279 | `geo_manual_copy` | 手动更新副本 | Manual update copy |
| 280 | `geo_none` | 无 | None |
| 281 | `geo_tip` | 说明：国家库与分流规则在构建时随 App 自带（每次发布都是当时最新版），启动与连接全程本地读取、不联网下载，任何缺失都不会影响软件与内核启动。如需最新数据请点击下方按钮手动更新（联网下载一次），更新后下次连接生效。 | Note: the country database and routing rules are bundled with each release. Startup and connection read them locally — no downloads, and a missing file never blocks the app or kernel from starting. Tap the button below to manually fetch the latest data (one-time download); it takes effect on the next connection. |
| 282 | `geo_check_update` | 检查并更新 | Check & Update |
| 283 | `geo_downloading` | 下载中 {pct} | Downloading {pct} |
| 284 | `geo_update_done` | 分流数据已更新，下次连接生效 | Geo data updated. Takes effect on next connect |
| 285 | `geo_update_fail` | 更新失败：{err} | Update failed: {err} |
| 286 | `geo_source` | 数据来源：MetaCubeX/meta-rules-dat（官方源） | Data source: MetaCubeX/meta-rules-dat (official) |
| 287 | `kernel_check_btn` | 检查更新 | Check updates |
| 288 | `kernel_checking` | 检查中… | Checking… |
| 289 | `kernel_up_to_date` | 已是最新内核 v{ver} | Kernel is up to date (v{ver}) |
| 290 | `kernel_new_found` | 发现新内核 v{ver} | New kernel v{ver} available |
| 291 | `kernel_update_btn` | 下载并更新内核 | Download & update kernel |
| 292 | `kernel_update_desc` | 更新后需重新连接生效；连接中请先断开 | Reconnect after updating; disconnect first if connected |
| 293 | `kernel_downloading` | 下载中 {pct}% | Downloading {pct}% |
| 294 | `kernel_download_done` | 内核已更新至 v{ver}，重新连接即生效 | Kernel updated to v{ver}. Reconnect to apply. |
| 295 | `kernel_update_fail` | 内核更新失败：{err} | Kernel update failed: {err} |
| 296 | `kernel_fetch_latest_fail` | 检查更新失败：{err} | Check failed: {err} |
| 297 | `kernel_version_unknown` | 未知 | Unknown |
| 298 | `kernel_android_update_tip` | Android 端内核随 App 版本一起发布，请留意新版 App | The Android kernel ships with the app — install a newer app version to update it. |
| 299 | `kernel_android_ver` | 内置 v{ver} | Bundled v{ver} |
| 300 | `kernel_old_saved` | 旧内核已备份为 .old（更新失败可恢复） | Old kernel backed up as .old (restored on failure) |
| 301 | `log_copied` | 日志已复制到剪贴板 | Log copied to clipboard |
| 302 | `log_cleared` | 日志已清空 | Log cleared |
| 303 | `log_empty` | 暂无日志 | No logs yet |
| 304 | `log_only_errors` | 只看错误 | Errors only |
| 305 | `app_log_desc` | 运行记录（[APP]/[NET]/[KERNEL]）。[ERROR] 是「错误级别的一条记录」（如连接失败），不等于崩溃；崩溃日志是 Dart 未捕获异常，单独存于文档目录 crash_logs/。 | Runtime records ([APP]/[NET]/[KERNEL]). [ERROR] is an error-level record (e.g. a failed connect), not a crash; crash logs are uncaught Dart exceptions kept in Documents/crash_logs/. |
| 306 | `log_no_errors` | 暂无错误日志 | No error logs |
| 307 | `clear_log` | 清空 | Clear |
| 308 | `settings_tos` | 用户协议 | Terms of Service |
| 309 | `settings_privacy_policy` | 隐私政策 | Privacy Policy |
| 310 | `restore_default` | 恢复默认 | Reset |
| 311 | `zh` | 简体中文 | 简体中文 |
| 312 | `en` | English | English |
| 313 | `notify_expiry_title` | 套餐即将到期 | Subscription expiring soon |
| 314 | `notify_expiry_body` | 您的套餐还剩 {days} 天，请及时续费避免中断 | Your plan expires in {days} days. Renew to avoid interruption. |
| 315 | `notify_connected` | 连接成功 | Connected |
| 316 | `notify_disconnected` | 连接已断开 | Disconnected |
| 317 | `refresh_sub` | 刷新订阅 | Refresh Subscription |
| 318 | `refresh_sub_ok` | 订阅已刷新 | Subscription refreshed |
| 319 | `no_nodes_hint` | 订阅中没有可用节点 | No nodes in subscription |
| 320 | `speed_testing` | 测速中… | Testing… |
| 321 | `speed_done_filtered` | 已测速筛选出的 {n} 个节点 | Speed-tested the {n} filtered node(s) |
| 322 | `speed_done` | 测速完成，已按延迟排序 | Test done, sorted by latency |
| 323 | `speed_test_none` | 测速未执行，请稍后重试 | Speed test did not run. Try again shortly. |
| 324 | `sub_syncing` | 正在同步订阅… | Syncing subscription… |
| 325 | `sub_syncing_wait` | 正在同步订阅，请稍候再连接 | Subscription is syncing, please wait before connecting |
| 326 | `node_need_connect_test` | 连接后测速 | Connect to test |
| 327 | `switched_to` | 已切换到 {name} | Switched to {name} |
| 328 | `region_empty` | 该地区暂无可用节点 | No available nodes in this region |
| 329 | `testing_all` | 正在测速全部节点… | Testing all nodes… |
| 330 | `selected` | 已选中 | Selected |
| 331 | `online` | 在线 | Online |
| 332 | `offline` | 离线 | Offline |
| 333 | `plan_duration` | 套餐时长 | Duration |
| 334 | `plan_devices` | 设备数 | Devices |
| 335 | `plan_traffic` | 流量 | Traffic |
| 336 | `plan_nodes` | 节点 | Nodes |
| 337 | `unlimited` | 不限 | Unlimited |
| 338 | `recommended` | 最划算 | BEST VALUE |
| 339 | `pay_hint` | 支付方式随官网设置实时同步：dy.moneyfly.top 后台启用的支付渠道会自动出现在这里，默认支付宝。 | Payment methods sync with the website: dy.moneyfly.top enabled channels appear here automatically. Default Alipay. |
| 340 | `no_pay_methods` | 暂无可用的支付方式，请稍后再试 | No payment method available, try again later |
| 341 | `select_plan` | 请选择套餐 | Please select a plan |
| 342 | `select_pay` | 请选择支付方式 | Please select a payment method |
| 343 | `order_failed` | 订单创建失败 | Failed to create order |
| 344 | `no_qrcode` | 未获取到支付二维码 | No payment QR code received |
| 345 | `activated` | 开通成功！已为你准备最新节点 | Activated! Your latest nodes are ready |
| 346 | `coupon_ok` | 优惠码已生效 | Coupon applied |
| 347 | `no_plan_yet` | 尚未开通套餐 | No active plan |
| 348 | `active` | 生效中 | Active |
| 349 | `inactive` | 未开通 | Not activated |
| 350 | `expiring_days` | 套餐还剩 {days} 天，请及时续费避免中断 | Your plan expires in {days} days. Renew to avoid interruption. |
| 351 | `renew` | 去续费 | Renew |
| 352 | `logout_confirm` | 确定要退出当前账号吗？ | Sign out of this account? |
| 353 | `logout_yes` | 退出 | Sign Out |
| 354 | `device_manage` | 设备管理 | Devices |
| 355 | `no_devices` | 暂无设备 | No devices |
| 356 | `no_devices_hint` | 连接一次 VPN 后，这里会显示你的设备 | Your devices will show here after connecting |
| 357 | `edit_remark` | 修改备注 | Edit Remark |
| 358 | `remark_hint` | 给这台设备起个名字（可清空） | Name this device (can be empty) |
| 359 | `remark_saved` | 备注已保存 | Remark saved |
| 360 | `save_failed` | 保存失败，请重试 | Failed to save. Please retry |
| 361 | `delete_device` | 删除设备 | Delete Device |
| 362 | `delete_device_body` | 确定删除「{name}」吗？\n删除 = 踢下线：该设备将被移除并立即断开，再次拉取订阅会收到「已被移除」提示，无法继续使用。 | Delete "{name}"?\nDeleting kicks the device offline: it will be removed and disconnected. Its next subscription pull will be rejected with a "removed" notice. |
| 363 | `device_deleted` | 设备已删除并下线 | Device deleted & kicked offline |
| 364 | `remark` | 备注 | Remark |
| 365 | `edit_remark_btn` | 改备注 | Edit |
| 366 | `my_orders` | 我的订单 | My Orders |
| 367 | `no_orders` | 暂无订单 | No orders |
| 368 | `no_orders_hint` | 购买套餐后订单会显示在这里 | Orders will show here after purchase |
| 369 | `pending` | 待支付 | Pending |
| 370 | `paid` | 已支付 | Paid |
| 371 | `cancelled` | 已取消 | Cancelled |
| 372 | `expired` | 已过期 | Expired |
| 373 | `location` | 位置 | Location |
| 374 | `version` | 版本 | Version |
| 375 | `access` | 访问 | Access |
| 376 | `recent` | 最近 | Recent |
| 377 | `order_type` | 类型：{type} | Type: {type} |
| 378 | `order_status_tip` | 订单状态：{status} | Order status: {status} |
| 379 | `no_qrcode_retry` | 未获取到二维码，请重试 | Failed to get QR code. Please retry |
| 380 | `pay_with_method` | 使用 {method} 支付 | Pay with {method} |
| 381 | `order_cancel_confirm` | 确定取消这笔待支付订单吗？ | Cancel this pending order? |
| 382 | `order_cancelled` | 订单已取消 | Order cancelled |
| 383 | `order_paid` | 该订单已支付 | This order is already paid |
| 384 | `order_status` | 订单状态：{status}，无法继续支付 | Order status: {status}, cannot pay |
| 385 | `order_time` | 下单时间 {time} | Placed at {time} |
| 386 | `pay_again` | 继续支付 | Pay Again |
| 387 | `cancel_order` | 取消订单 | Cancel |
| 388 | `rethink` | 再想想 | Keep It |
| 389 | `notify_center` | 通知中心 | Notifications |
| 390 | `mark_all_read` | 全部已读 | Mark all read |
| 391 | `no_notifications` | 暂无通知 | No notifications |
| 392 | `delete_notify` | 删除通知 | Delete Notification |
| 393 | `delete_notify_body` | 确定删除这条通知吗？ | Delete this notification? |
| 394 | `marked_read` | 已全部标记为已读 | All marked as read |
| 395 | `change_pwd` | 修改密码 | Change Password |
| 396 | `cur_pwd` | 当前密码 | Current Password |
| 397 | `cur_pwd_hint` | 请输入当前密码 | Enter current password |
| 398 | `settings_clear_data` | 清除本地数据 | Clear Local Data |
| 399 | `settings_clear_data_desc` | 清空订阅配置缓存、节点与运行日志（保留登录） | Clear cached subscription config, nodes & logs (stay signed in) |
| 400 | `clear_data_confirm` | 将断开连接并清除已缓存的订阅配置、节点与运行日志，保留登录状态。卸载或换机前建议先清除。是否继续？ | This will disconnect and clear cached subscription config, nodes and logs, keeping you signed in. Recommended before uninstalling. Continue? |
| 401 | `clear_data_done` | 本地数据已清除 | Local data cleared |
| 402 | `clear_data_failed` | 清除失败，请重试 | Failed to clear, please retry |
| 403 | `new_pwd` | 新密码 | New Password |
| 404 | `new_pwd_hint` | 至少 8 位，大小写字母/数字/符号至少三种 | 8+ chars incl. at least 3 of upper/lower/digit/symbol |
| 405 | `pwd_weak` | 密码强度不足：需包含大小写字母、数字、特殊字符中的至少三种 | Weak password: include at least 3 of upper/lower case, digits and symbols |
| 406 | `pwd_rule_len` | 长度不少于 8 位 | At least 8 characters |
| 407 | `pwd_rule_kinds` | 大写 / 小写 / 数字 / 符号 至少三种（当前 {n} 种） | At least 3 of: upper / lower / digit / symbol (now {n}) |
| 408 | `code_required` | 请输入 6 位邮箱验证码 | Enter the 6-digit email code |
| 409 | `confirm_pwd` | 确认新密码 | Confirm New Password |
| 410 | `confirm_pwd_hint` | 再次输入新密码 | Enter new password again |
| 411 | `save_pwd` | 保存新密码 | Save New Password |
| 412 | `pwd_changed` | 密码修改成功 | Password changed |
| 413 | `pwd_change_tip` | 修改密码后，其他已登录设备将保持登录状态，下次登录请使用新密码。 | Other signed-in devices stay signed in. Use the new password next time. |
| 414 | `join_moneyfly` | 加入 MoneyFly | Join MoneyFly |
| 415 | `join_tip` | 注册后即可购买套餐开始加速 | Subscribe a plan to start accelerating |
| 416 | `code_sent` | 验证码已发送至邮箱，5 分钟内有效 | Code sent to your email, valid for 5 minutes |
| 417 | `register_btn` | 注 册 | Sign Up |
| 418 | `forgot_title` | 找回密码 | Reset Password |
| 419 | `step_verify` | 验证身份 | Verify |
| 420 | `step_new_pwd` | 设置新密码 | Set New Password |
| 421 | `forgot_tip` | 验证码将发送到注册邮箱，5 分钟内有效；重置成功后请使用新密码登录。 | A code will be sent to your email (valid 5 min). Sign in with the new password after reset. |
| 422 | `reset_pwd_btn` | 重置密码 | Reset Password |
| 423 | `remembered` | 想起来了？ | Remembered it? |
| 424 | `back_login` | 返回登录 | Back to Sign In |
| 425 | `pwd_reset` | 密码已重置，请使用新密码登录 | Password reset. Sign in with the new password. |
| 426 | `registered` | 注册成功，请登录 | Registered. Please sign in. |
| 427 | `qr_tap_zoom` | 点按二维码可放大 | Tap QR to zoom |
| 428 | `order_copied` | 订单号已复制 | Order No. copied |
| 429 | `pay_success_auto` | 支付成功后自动开通套餐… | Activating automatically after payment… |
| 430 | `open_pay_app` | 打开{method}支付 | Open {method} |
| 431 | `open_pay_failed` | 未能打开支付应用，请改用扫码支付 | Could not open the payment app, please scan the QR code |
| 432 | `confirming_pay` | 正在确认支付… | Confirming payment… |
| 433 | `pick_option` | 请选择 | Select |
| 434 | `latest_version` | 已是最新版本 v{ver} | Already latest v{ver} |
| 435 | `check_update_fail` | 检查更新失败，请检查网络后重试 | Update check failed. Check your network and retry |
| 436 | `no_update_source` | 暂未配置更新源，当前已是最新版本 | No update source configured. You are on the latest version. |
| 437 | `new_version` | 发现新版本 | Update Available |
| 438 | `new_version_forced` | 发现新版本（强制更新） | Update Required |
| 439 | `update_body` | 当前版本 v{cur}\n最新版本 v{latest}{size}\n\n请下载最新安装包体验新功能。 | Current v{cur}\nLatest v{latest}{size}\n\nDownload the latest package for new features. |
| 440 | `download_now` | 立即下载 | Download |
| 441 | `later` | 稍后 | Later |
| 442 | `no_download_url` | 下载链接暂未配置 | Download link not configured |
| 443 | `cannot_open_url` | 无法打开下载链接 | Cannot open download link |
| 444 | `language` | 语言 | Language |
| 445 | `settings_minutes` | 分钟 | min |
| 446 | `all_protocols` | 全部协议 | All protocols |
| 447 | `only_vless` | 仅 vless | Vless only |
| 448 | `only_trojan` | 仅 trojan | Trojan only |
| 449 | `tun_off` | 关闭 | Off |
| 450 | `tun_force` | 强制 | Force |
| 451 | `tun_auto` | 自动 | Auto |
| 452 | `theme_light` | 浅色 | Light |
| 453 | `quick_switch_country` | 快速切换国家 · 点按即切最优节点 | Quick country switch · tap for best node |
| 454 | `auto_best_activated` | 已切换为自动选择最优节点 | Switched to auto-select best node |
| 455 | `member` | 会员 | Member |
| 456 | `days` | 天 | days |
| 457 | `no_plans` | 暂无可用套餐 | No plans available |
| 458 | `buy_now` | 购买 | Buy |
| 459 | `theme_follow` | 跟随系统 | Follow system |
| 460 | `expired_tip` | 您的套餐已到期，请续费后使用 | Your plan has expired. Please renew to continue. |
| 461 | `go_renew` | 去续费 | Renew |
| 462 | `account_expired_title` | 套餐已到期 | Plan Expired |
| 463 | `account_expired_block` | 您的套餐已到期，购买套餐后即可继续畅连全球节点 | Your plan has expired. Purchase a plan to keep enjoying global access. |
| 464 | `device_full_title` | 设备数量已达上限 | Device Limit Reached |
| 465 | `device_full_block` | 设备数量已达上限（{cur}/{limit}），无法连接新设备。可在「我的 - 设备管理」中删除不常用设备，或升级更高设备数的套餐 | Device limit reached ({cur}/{limit}) — no new device can connect. Remove unused devices under Me → Devices, or upgrade to a plan with more devices. |
| 466 | `account_disabled_title` | 账号已被禁用 | Account Disabled |
| 467 | `account_disabled_block` | 您的账号已被禁用，无法使用服务。如有疑问，请联系客服 | Your account has been disabled. Please contact support if you have questions. |
| 468 | `sub_disabled_title` | 套餐已被禁用 | Plan Disabled |
| 469 | `sub_disabled_block` | 您的套餐已被禁用或状态异常，无法连接。如有疑问，请联系客服 | Your plan has been disabled or is in an abnormal state. Please contact support. |
| 470 | `no_sub_title` | 尚未开通套餐 | No Active Plan |
| 471 | `no_sub_block` | 您还没有开通套餐，开通后即可畅连全球节点 | You have no active plan. Subscribe a plan to unlock global nodes. |
| 472 | `go_upgrade_devices` | 升级设备套餐 | Upgrade Devices |
| 473 | `device_full_upgrade_banner` | 设备名额已用满 ({used}/{limit}) · 点击增加设备名额 | Device slots full ({used}/{limit}) · Tap to add more |
| 474 | `upgrade_devices_card` | 升级设备数量 | Add More Devices |
| 475 | `upgrade_devices_card_sub` | 当前 {used}/{limit} 台 · 到期 {expire} · 点击增加名额，可顺带延长到期时间 | {used}/{limit} used · Expires {expire} · Add slots, optionally extend expiry |
| 476 | `upgrade_title` | 升级设备 | Upgrade Devices |
| 477 | `upgrade_current` | 当前订阅 | Current plan |
| 478 | `upgrade_expire` | 到期 | Expires |
| 479 | `devices_unit` | 台 | devices |
| 480 | `upgrade_add_devices` | 增加设备数量（立即生效，多台设备可同时在线） | Add device slots (effective immediately) |
| 481 | `upgrade_add_days` | 顺带增加时长（到期顺延） | Also extend duration |
| 482 | `upgrade_days_only` | 不加时长 | No extra days |
| 483 | `upgrade_no_days_needed` | 到期时间充足，可不加时长 | Plenty of time left — no extra days needed |
| 484 | `upgrade_recommend` | 推荐 | Recommended |
| 485 | `upgrade_amount` | 应付金额 | Payable |
| 486 | `upgrade_expired_hint` | 订阅已到期：增加设备需同时选择加时长 | Plan expired: adding devices requires choosing extra days |
| 487 | `upgrade_no_amount` | 金额未计算出来，请稍候重试 | Amount not ready, retry in a moment |
| 488 | `upgrade_pay_btn` | 立即支付 | Pay Now |
| 489 | `upgrade_tip` | 说明：支付成功后设备数立即增加、到期时间按所选天数顺延；新设备数对你名下所有节点生效。 | After payment, device slots increase immediately and expiry extends by the chosen days for all nodes. |
| 490 | `upgrade_done` | 设备升级成功 | Devices upgraded |
| 491 | `manage_devices` | 管理设备 | Manage Devices |
| 492 | `devices_full_hint` | 设备数已达上限（{cur}/{limit}）：删除不常用设备后，新设备才能连接 | Device limit reached ({cur}/{limit}): new devices can connect only after you remove an unused one. |
| 493 | `nodes_empty_retry` | 节点加载失败，请检查网络后重试 | Failed to load nodes. Check your network and retry. |
| 494 | `retry_btn` | 重试 | Retry |
| 495 | `tap_connect` | 点击连接 · 再次点击断开 | Tap to connect · tap again to disconnect |
| 496 | `tap_to_switch` | 点击切换节点 | Tap to switch node |
| 497 | `node_switch` | 切换 | Switch |
| 498 | `home_sub_expire` | 到期 | Expires |
| 499 | `home_sub_devices` | 设备 | Devices |
| 500 | `home_sub_days` | 剩余 | Days |
| 501 | `theme_dark` | 深色 | Dark |
| 502 | `theme_system` | 跟随系统 | System |
| 503 | `smart` | 智能 | Smart |
| 504 | `global` | 全局 | Global |
| 505 | `restored` | 已恢复默认设置 | Settings restored to defaults |
| 506 | `open_url_fail` | 无法打开链接，请检查网络后重试 | Cannot open link, check your network |
| 507 | `vpn_permission_needed` | 需要授予 VPN 权限才能连接 | VPN permission required to connect |
| 508 | `grant_vpn_btn` | 授权 VPN 权限 | Grant VPN permission |
| 509 | `grant_notify_btn` | 允许通知 | Allow notifications |
| 510 | `stay_foreground_hint` | 请保持 App 在前台，再点重试 | Keep the app in the foreground, then retry |
| 511 | `vpn_guide_title` | 开启 VPN 权限 | Enable VPN permission |
| 512 | `vpn_guide_text` | 连接需要系统 VPN 权限（仅用于建立加密隧道）。\n接下来系统会弹出连接请求，请点击「确定 / 允许」。 | A system VPN permission is required to connect (used only to establish the encrypted tunnel).\nThe system will now show a connection request — please tap "OK / Allow". |
| 513 | `vpn_guide_ok` | 去授权 | Continue |
| 514 | `vpn_denied_title` | 未获得 VPN 权限 | VPN permission not granted |
| 515 | `vpn_denied_text` | 刚才没有完成授权，无法建立连接。 | Authorization was not completed, so the connection cannot be established. |
| 516 | `vpn_denied_hint_always_on` | 如果始终没有出现授权弹窗：可能有其他 VPN 应用开启了「始终开启的 VPN」，请打开系统 VPN 设置将其关闭后重试。 | If no permission dialog ever appears: another VPN app may have "Always-on VPN" enabled. Open the system VPN settings, disable it, then retry. |
| 517 | `open_vpn_settings` | 打开系统 VPN 设置 | Open system VPN settings |
| 518 | `re_authorize` | 重新授权 | Re-authorize |
| 519 | `input_account_pwd` | 请输入账号和密码 | Enter account and password |
| 520 | `email_invalid` | 请先输入正确的邮箱 | Enter a valid email first |
| 521 | `pwd_short` | 密码至少 8 位 | Password must be at least 8 characters |
| 522 | `pwd_mismatch` | 两次输入的密码不一致 | Passwords do not match |
| 523 | `agree_required` | 请先阅读并同意用户协议与隐私政策 | Please agree to the Terms and Privacy Policy first |
| 524 | `username_short` | 用户名至少 4 位 | Username must be at least 4 characters |
| 525 | `pwd_old_required` | 请输入当前密码 | Enter current password |
| 526 | `connected_tip` | 已连接 | Connected |
| 527 | `connecting_tip` | 正在自动测速并选择最优节点… | Auto-testing and selecting the best node… |
| 528 | `notify_reconnect_failed` | 重连失败，请手动重试 | Reconnect failed. Please retry manually. |
| 529 | `cancel_text` | 取消 | Cancel |
| 530 | `settings_title` | 设置 | Settings |
| 531 | `group_connect` | 连接与线路 | Connection & Routing |
| 532 | `group_proxy` | 代理与分流 | Proxy & Split |
| 533 | `group_network` | 网络与端口 | Network & Ports |
| 534 | `group_kernel` | 内核与数据 | Kernel & Data |
| 535 | `group_appearance` | 外观 | Appearance |
| 536 | `group_account` | 账户 | Account |
| 537 | `group_about` | 关于与诊断 | About & Diagnostics |
| 538 | `tun_title` | TUN 虚拟网卡 | TUN Virtual NIC |
| 539 | `real_exit` | 真实出口 | Real exit |
| 540 | `real_exit_detecting` | 真实出口 · 检测中… | Real exit · detecting… |
| 541 | `real_exit_failed_retry` | 真实出口 · 检测失败，点按重试 | Real exit · detection failed, tap to retry |
| 542 | `countdown_resend` | {n}s 后重发 | {n}s to resend |
| 543 | `code_sent_email` | 验证码已发送到邮箱，5 分钟内有效 | Code sent to your email, valid for 5 minutes |
| 544 | `reset_code_sent` | 重置验证码已发送到邮箱 | Reset code sent to your email |
| 545 | `cancel_connect` | 已取消连接 | Connection cancelled |
| 546 | `no_available_nodes` | 没有可用节点，请先刷新订阅 | No nodes available. Refresh subscription. |
| 547 | `all_nodes_offline` | 所有节点均不可用 | All nodes are offline |
| 548 | `node_switch_fail` | 节点热切换失败：{err} | Node switch failed: {err} |
| 549 | `mode_switch_fail` | 模式切换失败：{err} | Mode switch failed: {err} |
| 550 | `reconnect_exhausted` | 重连 3 次仍失败，已断开 | Reconnect failed 3 times, disconnected |
| 551 | `kernel_crash_recover_failed` | 内核进程反复异常退出，已停止自动恢复。请检查安全软件是否拦截内核进程 | The core process keeps exiting; auto-recovery stopped. Check if antivirus is blocking it |
| 552 | `show_window` | 显示窗口 | Show Window |
| 553 | `tray_mode` | 模式 | Mode |
| 554 | `tray_country` | 切换地区 | Region |
| 555 | `quit` | 退出 | Quit |
| 556 | `expiry_notify_title` | 订阅即将到期 | Subscription Expiring |
| 557 | `expiry_notify_body` | 您的订阅还剩 {days} 天，请及时续费 | Your subscription expires in {days} days, please renew |
| 558 | `reconnect_fail_notify_title` | 连接已断开 | Disconnected |
| 559 | `reconnect_fail_notify_body` | 自动重连失败，请打开 App 重新连接 | Auto-reconnect failed, please reopen the app |
| 560 | `disconnected_hint` | 连接已断开 | Disconnected |
| 561 | `tun_need_admin_mac` | TUN 模式需要管理员权限。请在设置中切换为「仅系统代理」，或使用 sudo 启动应用。 | TUN requires admin privileges. Switch to system proxy in settings, or run with sudo. |
| 562 | `tun_need_admin_win` | TUN 模式需要管理员权限。请在设置中切换为「关闭」（仅系统代理），或以管理员身份运行。 | TUN requires admin privileges. Switch to Off (system proxy) in settings, or run as Administrator. |
| 563 | `tun_win_hint` | ⚠️ 自动/强制模式需要以管理员身份运行软件。\n右键 MoneyFly → 以管理员身份运行。\n普通模式建议选择「关闭」（使用系统代理）。 | ⚠️ Auto/Force mode requires running as Administrator.\nRight-click MoneyFly → Run as administrator.\nFor normal use, select Off (system proxy). |
| 564 | `tun_mac_hint` | ⚠️ 自动/强制模式需要管理员权限。\nmacOS 暂建议使用「关闭」（系统代理模式），\n后续版本将支持特权助手。 | ⚠️ Auto/Force mode requires admin privileges.\nmacOS: recommended to use Off (system proxy).\nPrivileged helper support coming soon. |
| 565 | `tun_only_proxy` | 仅系统代理 | System proxy only |
| 566 | `tun_full_intercept` | 全局接管 | Full intercept |
| 567 | `tun_dual` | TUN+代理 | TUN + proxy |
| 568 | `tun_need_admin` | 需要以管理员身份运行 | Run as Administrator required |
| 569 | `tun_need_root` | 需要管理员权限 | Admin privileges required |
| 570 | `ok_btn` | 好的 | OK |
| 571 | `no_email_hint` | 未登录邮箱 | Not signed in |
| 572 | `email_reg_hint` | 用于接收重置验证码 | For reset verification code |
| 573 | `email_reg_invalid` | 请输入正确的邮箱地址 | Enter a valid email address |
| 574 | `sending` | 发送中… | Sending… |
| 575 | `identity_ok` | 验证码已发送至邮箱，请查收 | Verification code sent to your email |
| 576 | `expire_na` | 未设置 | Not set |
| 577 | `poll_stopped` | 已停止轮询 | Polling stopped |
| 578 | `vpn_start_fail` | VPN 启动失败：{err} | VPN start failed: {err} |
| 579 | `kernel_timeout` | 内核启动超时 | Kernel startup timed out |
| 580 | `kernel_exit` | 内核异常退出 | Kernel exited unexpectedly |
| 581 | `kernel_busy` | 内核正在启动中，请稍候 | Kernel is starting, please wait |
| 582 | `expired_short` | 已到期 | Expired |
| 583 | `will_connect_node` | 将连接 | Will connect |
| 584 | `auto_test_desc` | 连接后自动选择最快节点 | Auto-select fastest node after connecting |
| 585 | `last_test` | 上次测速 | Last test |
