# MoneyFly i18n inventory / hygiene (machine-extracted)

- Total keys defined: **585** in `_zh`, identical set in `_en` (no missing/extra/duplicate keys).
- Keys referenced statically via `AppStrings.t('key')`: **484**.
- Keys resolved dynamically (theme label map + main-nav `labelKey`): **10** → `appearance_black`, `appearance_darkblue`, `appearance_darkgray`, `appearance_gray`, `appearance_light`, `appearance_warm`, `home`, `nodes_title`, `profile_title`, `purchase_title`
- Keys never referenced anywhere in `lib/` (dead copy, safe to delete or still TODO): **87**

## Never-referenced keys

| key | zh |
|---|---|
| `no_email` | 未登录邮箱 |
| `month` | 月 |
| `quarter` | 季 |
| `year` | 年 |
| `days_devices` | {days} 天 · {devices} 台 |
| `back` | 返回 |
| `agree_tos` | 我已阅读并同意 《用户协议》 与 《隐私政策》 |
| `mode_hint` | 智能 = 国内直连 · 国外代理 ｜ 全局 = 全部流量走代理 |
| `auto_test_title` | 自动测速 · 自动选优 |
| `auto_test_on` | 已开启 |
| `auto_test_off` | 已关闭 |
| `best` | 最优 |
| `retest` | 重新测速 |
| `quick_region` | 快速切换国家 |
| `region_hint` | 点按即切换该国最优节点 |
| `no_subscription` | 尚未开通套餐，开通后即可畅连全球节点 |
| `pick_best` | 立即选优 |
| `coupon_hint` | 优惠码（选填） |
| `verify` | 验证 |
| `pay_alipay_title` | 请使用支付宝扫码支付 |
| `waiting_pay` | 等待支付 |
| `profile_coupons` | 优惠券 |
| `settings_conn` | 连接设置 |
| `settings_protocol` | 协议过滤 |
| `settings_mode` | 模式 |
| `settings_network` | 网络 |
| `settings_appearance` | 外观 |
| `settings_privacy` | 隐私 |
| `settings_notify` | 允许通知 |
| `settings_notify_desc` | 套餐到期 / 连接状态提醒 |
| `settings_crash` | 崩溃日志上报 |
| `settings_crash_desc` | 本地记录崩溃日志，可导出反馈 |
| `settings_analytics` | 匿名使用统计 |
| `settings_analytics_desc` | 仅匿名统计（版本/成功率），不收集个人信息（预留） |
| `settings_account` | 账号 |
| `settings_about` | 关于 |
| `settings_log_desc` | 查看/导出诊断日志 |
| `settings_kernel_log_desc` | 实时查看代理引擎日志 |
| `kernel_log_title` | 内核日志 |
| `access_loading` | 加载应用列表… |
| `kernel_variant_in_use` | 使用中 |
| `kernel_variant_switch` | 切换 |
| `kernel_variant_tip` | 提示：标准版需要较新的 CPU（AVX2/新指令集），老电脑上会启动即崩溃（0xC0000005），请使用兼容版。切换后断开重连生效。 |
| `kernel_check_btn` | 检查更新 |
| `kernel_checking` | 检查中… |
| `kernel_update_btn` | 下载并更新内核 |
| `kernel_old_saved` | 旧内核已备份为 .old（更新失败可恢复） |
| `log_copied` | 日志已复制到剪贴板 |
| `log_cleared` | 日志已清空 |
| `settings_tos` | 用户协议 |
| `settings_privacy_policy` | 隐私政策 |
| `notify_expiry_title` | 套餐即将到期 |
| `notify_expiry_body` | 您的套餐还剩 {days} 天，请及时续费避免中断 |
| `notify_connected` | 连接成功 |
| `notify_disconnected` | 连接已断开 |
| `speed_testing` | 测速中… |
| `region_empty` | 该地区暂无可用节点 |
| `testing_all` | 正在测速全部节点… |
| `plan_duration` | 套餐时长 |
| `plan_traffic` | 流量 |
| `plan_nodes` | 节点 |
| `coupon_ok` | 优惠码已生效 |
| `order_status` | 订单状态：{status}，无法继续支付 |
| `remembered` | 想起来了？ |
| `back_login` | 返回登录 |
| `pay_success_auto` | 支付成功后自动开通套餐… |
| `no_update_source` | 暂未配置更新源，当前已是最新版本 |
| `all_protocols` | 全部协议 |
| `only_vless` | 仅 vless |
| `only_trojan` | 仅 trojan |
| `theme_light` | 浅色 |
| `buy_now` | 购买 |
| `theme_follow` | 跟随系统 |
| `expired_tip` | 您的套餐已到期，请续费后使用 |
| `tap_connect` | 点击连接 · 再次点击断开 |
| `tap_to_switch` | 点击切换节点 |
| `theme_dark` | 深色 |
| `theme_system` | 跟随系统 |
| `open_url_fail` | 无法打开链接，请检查网络后重试 |
| `connected_tip` | 已连接 |
| `connecting_tip` | 正在自动测速并选择最优节点… |
| `notify_reconnect_failed` | 重连失败，请手动重试 |
| `countdown_resend` | {n}s 后重发 |
| `disconnected_hint` | 连接已断开 |
| `poll_stopped` | 已停止轮询 |
| `auto_test_desc` | 连接后自动选择最快节点 |
| `last_test` | 上次测速 |

## Language mechanics

- `AppStrings._lang` defaults to `'zh'`; set by `AppStrings.setLang('zh'|'en')`, persisted in SharedPreferences key `moneyfly_lang`.
- `AppStrings.restore()`: saved value wins; otherwise first launch follows `PlatformDispatcher.instance.locale.languageCode` (zh / zh-cn / zh-tw → zh, everything else → en).
- `AppStrings.t(key, args)` → `_en` map when lang == 'en', else `_zh`; unknown key falls back to `_zh[key]` then to the raw key string. `{name}` placeholders replaced from `args`.
- `LocaleController` (ChangeNotifier singleton) notifies `MaterialApp` to rebuild; `MaterialApp.locale` is `Locale('en')` or `Locale('zh')`, and the `localizationsDelegates` are the three Global*Localizations delegates.
- Languages selectable in UI: **only zh and en** (`settings_language` row → SimpleDialog titled `Language` hard-coded English).

