# Mclash

> MoneyFly 多平台加速客户端 · Android / Windows / macOS（Apple 芯片 + Intel）
> 基于 [mihomo](https://github.com/MetaCubeX/mihomo)（MetaCubeX，**官方源码，不使用 fork**）
> 后台：`https://new.moneyfly.top`

---

## 这是什么

> **Clash Mi 的界面与全部代理能力 + MoneyFly 的账号与商业化闭环。**

界面、排版、组件 **100% 沿用 [Clash Mi](https://github.com/KaringX/clashmi)**：
Material 3 + 种子色 `#293CA0` + 方角 + 高密度列表 + 唯一分隔线 `Divider(height:1, thickness:0.3)`
+ `SimpleDialog` 全家桶 + `platform: TargetPlatform.iOS` + 3 主题模式。

导航层新增 **4 个底部 Tab**：**主页 · 节点列表 · 套餐购买 · 我的**。

```
① 安装并打开  →  ② 登录 MoneyFly 账号（唯一一次手动输入）
                        ↓ 自动：拉订阅 → 解析节点 → 写入「我的配置」→ 并发测速 → 选中最优
               ③ 拨动首页连接开关  →  ✅ 上网
```

**从安装到上网 = 2 次操作。** 同时 Clash Mi 的代理管理、分流、规则、代理组、内核设置、
应用设置、网络检测、备份同步等能力 **一个不少** —— 进阶用户与客服排障需要的每一项都在。

---

## 平台支持

| 平台 | 架构 | 分发形态 | 内核 |
|---|---|---|---|
| Android | `arm64-v8a` / `armeabi-v7a` / `x86_64` | APK（分 ABI）+ AAB | **进程内** `libmihomo.aar`（gomobile bind） |
| Windows | `amd64` | `.exe` 安装包 + `.zip` 便携版 | 子进程 `mihomo.exe`（官方 compatible） |
| macOS | `arm64`（Apple 芯片） | `.dmg` | 子进程 `mihomo`（官方 arm64） |
| macOS | `x86_64`（Intel） | `.dmg`（原生 x86_64 构建） | 子进程 `mihomo`（官方 **compatible**） |

> ⚠️ 各架构安装包均为原生编译、内置匹配架构内核，**请勿跨架构混装**。
> Intel Mac 必须使用 `compatible` 内核（标准版要求 AVX2 指令集，老机器启动即崩）。

---

## 功能范围

### 保留的 Clash Mi 能力（**默认全部保留**）

| 模块 | 内容 |
|---|---|
| **连接卡** | 状态点 + 主开关 + 流量总量/速率 + **规则 / 全局 / 直连 / 拦截** 四模式 |
| **我的配置** | 多配置列表（可重排）· 当前配置高亮 · 更新全部 · 编辑 · 备注 · 覆写设置 · 备用下载通道 |
| **代理** | 代理组列表 · 延迟色阶 · 排序切换 · 批量测速（进度环+计数）· 节点选择弹层 |
| **模板与规则** | 代理组模板 · 规则提供者 · 规则模板 · 分流模板（四套可重排 CRUD） |
| **内核设置** | external-controller · secret · mixed-port · 日志等级 · Per-App · pprof · 统一延迟 · 进程匹配 · IPv6 · TUN · Geo RuleSet · 覆写 · tcp-concurrent · TCP 保活 · TLS 指纹 · 局域网接入 · DNS · NTP · TLS · 嗅探（**每项带原始 yaml 键提示**）+ 8 个子页 |
| **应用设置** | 34 项：语言 · 主题 · TV 模式 · 屏幕旋转 · 更新通道 · 自动下载 · 日志等级 · UserAgent · 延迟测试 URL/超时 · 在线面板 · 开机启动 · 便携模式 · 启动后隐藏/自动连接 · 自动设置系统代理 · 绕过域名 · 最近任务隐藏 · 唤醒锁 · 系统启动后自动连接 · 始终开启 VPN · 隐藏 Dock 图标 · 托盘流量 |
| **网络检测** | DNS 查询 · HTTP 经 TUN · HTTP 经代理 · 路由表（结果一键复制） |
| **备份与同步** | iCloud · WebDAV · 局域网同步（二维码）· 导入导出 |
| **分应用代理** | Android 白名单/黑名单 + 应用搜索 + 全选/粘贴/剪切/导出；Windows UWP 网络豁免 |
| **自动更新** | 通道选择 · 自动下载 · 版本更新页 · 启动失败诊断页（5 种原因） |
| **多语言** | **9 种**：en · zh-CN · zh-TW · ja · ko · ar · ru · fa · es |
| **其他** | 我的配置运行时查看 · 核心日志 · 帮助 · 关于 · 用户协议 · 深链接（`clash://`） |

### MoneyFly 新增业务能力

| 模块 | 内容 |
|---|---|
| **账号** | 邮箱+密码登录（JWT 双 token）· 注册 · 忘记密码 · 修改密码 |
| **自动拉取订阅** | 登录后无需任何操作；冷启动先秒显磁盘缓存（≤800ms）再后台刷新；30 分钟定时 + 回前台补拉 |
| **自动测速选优** | 订阅更新后自动并发测速（PC 10 / 移动 5 路）→ 延迟 + 负载惩罚选优 → 连接后经内核实测 |
| **一键连接** | 单一大开关；自动完成：准入判定 → 生成 YAML → 启动内核 → 就绪探测（API 200 **且** 端口探活）→ 置系统代理 |
| **准入闸门** | 到期 / 订阅停用 / 账号禁用 / 设备被踢 / 设备满 → 红色状态条 + 连接拦截 + 清空节点缓存（防绕过计费） |
| **断线自愈** | 内核被安全软件结束/崩溃后**始终**自动拉起（最多 3 次；10 分钟内 5 次崩退则熔断） |
| **套餐与支付** | 套餐列表 · 优惠券 · 支付宝/微信/USDT · 二维码轮询（3s / 15min）· 支付成功立即刷新订阅 |
| **订单 / 设备 / 通知** | 订单记录（待支付可继续支付）· 设备管理（踢下线/改备注）· 设备增量升级（+N 台，可顺延 +M 天）· 通知中心 |

### 明确移除的 2 项

| 项 | 理由 |
|---|---|
| 面板（zashboard 内嵌 Web 面板） | 已确认可删（省约 2.3 MB 资源） |
| 二维码工具（文本转二维码 / 独立扫码页） | 已确认可删 —— **例外**：局域网同步的扫码能力保留 |

### 导入入口的处理

用户确认：**保留但默认隐藏，放进「开发者选项」**（关于 → 长按「版本」）。

- 🙈 移入开发者选项：从剪贴板导入 · 扫描二维码 · 导入配置文件
- ✅ 始终可见：添加配置链接 · 我的配置列表 / 切换 / 编辑 / 重排 / 删除 / 更新
- ❌ 移除：「获取配置 / 购买配置」（走套餐 Tab）·「登录」（已由 MoneyFly 登录取代）
- **后台订阅自动成为「我的配置」中的第一条并自动设为当前配置**

### 内核管理

桌面端可在开发者选项中检测官方最新版、经隧道下载、热替换、变体切换（标准/兼容）、恢复内置。

---

## 兼容性说明（从 Clash Mi 继承）

- ✅ **全部代理协议**（mihomo 内核能力，与 Clash Mi 完全一致）
- ✅ **全部内核配置面**（DNS / TUN / TLS / 嗅探 / NTP / Hosts / GEO / 规则 / 代理组 / 覆写）
- ✅ **全部应用设置**（含便携模式、UWP 豁免、TV 模式、隐藏 Dock 图标、托盘流量）
- ✅ **全部备份与同步通道**（iCloud / WebDAV / 局域网）
- ✅ **9 种语言**
- ✅ **深链接**（`clash://install-config`、`clash://connect` 等）
- ⚠️ 视觉与交互风格 **100% 沿用 Clash Mi**，仅在导航层新增 4 Tab

---

## 设计文档（先看这里）

**完整设计文档套件在 [`docs/design/`](./docs/design/)** —— 每个页面都有详细设计图。

| 打开 | 内容 |
|---|---|
| **[`docs/design/mockups/index.html`](./docs/design/mockups/index.html)** | 🎨 **设计稿总览**（从这里开始） |
| [`docs/design/mockups/mobile.html`](./docs/design/mockups/mobile.html) | 移动端高保真设计稿（25 屏） |
| [`docs/design/mockups/desktop.html`](./docs/design/mockups/desktop.html) | 桌面端高保真设计稿（7 屏） |
| [`01 · 产品定义与平台矩阵`](./docs/design/01-产品定义与平台矩阵.md) | 三条设计原则、**保留清单 R-01~R-15**、新增 B-01~B-12、最小改动 M-01~M-07 |
| [`02 · 总体架构设计`](./docs/design/02-总体架构设计.md) | 七层架构、模块清单、内核三形态、数据流、15 条 ADR |
| [`03 · 设计系统 / Design Tokens`](./docs/design/03-设计系统-Design-Tokens.md) | **Clash Mi 逐值令牌**、M3 派生调色板、16 类组件、🆕 导航组件 |
| [`04 · 信息架构与导航地图`](./docs/design/04-信息架构与导航地图.md) | **4 Tab 定义与规格**、47 页面清单、导航地图、Tab 切换行为 |
| [`05 · 核心流程设计`](./docs/design/05-核心流程设计.md) | 8 条流程时序图（订阅三重防护 / 测速选优 / 一键连接 / 断线自愈） |
| [`06 · 页面设计 · 移动端`](./docs/design/06-页面设计-移动端.md) | **4 个 Tab + Clash Mi 全部页面逐页线框图 + 规格表 + 改造点** |
| [`07 · 页面设计 · 桌面端`](./docs/design/07-页面设计-桌面端.md) | 左侧导航 88px、托盘、关闭行为、系统代理、内核热替换、快捷键 |
| [`08 · 内核集成与平台构建发布`](./docs/design/08-内核集成与平台构建发布.md) | 内核来源、Android/Windows/macOS 集成、CI 全流程、升级 SOP |
| [`09 · 后台接口对接设计`](./docs/design/09-后台接口对接设计.md) | 接口约定、订阅模块、12 种协议解析、后台配合清单 |
| [`10 · 交付计划与验收标准`](./docs/design/10-交付计划与验收标准.md) | 6 里程碑、60+ 改造任务、验收标准、风险登记、Go/No-Go |

---

## 技术栈

| 层 | 技术 |
|---|---|
| UI | Flutter 3.44+ / Dart 3.11+ |
| 状态 | provider（`ChangeNotifier` + `ValueNotifier`） |
| 网络 | dio（JWT 注入 · CSRF · 401 并发静默刷新） |
| 存储 | flutter_secure_storage（token）· shared_preferences（设置）· 文件（订阅缓存/日志） |
| 内核 | mihomo（Android：`libmihomo.aar`；桌面：官方预编译二进制） |
| 桌面壳 | window_manager · tray_manager · launch_at_startup |
| 打包 | GitHub Actions（Android 分 ABI + Windows exe/zip + macOS arm64/x64/universal） |

---

## 开发环境

```bash
# 1) 依赖
flutter pub get

# 2) 离线分流数据（geosite.dat / country.mmdb，不入库，构建时下载）
bash tool/fetch_geodata.sh

# 3) 内核二进制
#    macOS：先构建一次再运行脚本，内核才会被放进 app bundle
flutter build macos --debug
bash tool/fetch_mihomo.sh 1.19.30

#    Windows：手动下载并解压到 exe 同目录
#    https://github.com/MetaCubeX/mihomo/releases/download/v1.19.30/mihomo-windows-amd64-compatible-v1.19.30.zip
#    → build/windows/x64/runner/Release/mihomo.exe

#    Android：下载 AAR
mkdir -p android/app/libs
curl -fL -o android/app/libs/libmihomo.aar \
  https://github.com/moneyfly004/mihomo-lib/releases/download/v1.19.30/libmihomo.aar

# 4) 测试（含真实内核端到端验证）
export MCLASH_MIHOMO="$PWD/build/mihomo/mihomo"
flutter analyze && flutter test --concurrency=1
```

**内核查找优先级**：`MCLASH_MIHOMO` 环境变量 → 用户副本目录 → 安装目录内置。

---

## 构建

```bash
flutter build apk --release --split-per-abi   # Android（需 android/app/libs/libmihomo.aar）
flutter build windows --release               # Windows（需 mihomo.exe 在 Release 目录）
flutter build macos --release                 # macOS（Apple 芯片）
arch -x86_64 flutter build macos --release    # macOS（Intel，Rosetta 整链）
```

发布由 `.github/workflows/release.yml` 自动完成（推 `v*` tag 触发），产物：
签名 APK ×3 + AAB · Windows exe + zip · macOS arm64 + x64 + universal DMG + `SHA256SUMS`。

---

## 内核来源

| 平台 | 资产 | 来源 |
|---|---|---|
| Android | `libmihomo.aar` | [`moneyfly004/mihomo-lib`](https://github.com/moneyfly004/mihomo-lib)（官方 mihomo 源码 + gomobile bind，每日自动跟随官方新版） |
| Windows | `mihomo-windows-amd64-compatible-*.zip` | [MetaCubeX/mihomo](https://github.com/MetaCubeX/mihomo) 官方 Release |
| macOS arm64 | `mihomo-darwin-arm64-*.gz` | 同上 |
| macOS x64 | `mihomo-darwin-amd64-compatible-*.gz` | 同上（**必须 compatible**） |
| 分流数据 | `geosite.dat` · `country.mmdb` | [MetaCubeX/meta-rules-dat](https://github.com/MetaCubeX/meta-rules-dat) |

升级内核：只改 `.github/workflows/release.yml` 中的 `MIHOMO_VERSION`（唯一真源）。

---

## 与参考项目的关系

本项目综合两个输入：

### 表现层与能力层 = Clash Mi

[clashmi-main](https://github.com/KaringX/clashmi) 提供了本项目的**全部视觉语言与全部代理能力**。
注意该仓库是**客户端壳**：`bind/{android,windows,linux,apple/Libclash.xcframework}` 均被 gitignore 且不存在，
且依赖两个不在仓库中的兄弟目录（`../libclash-vpn-service`、`../board-service`），**无法直接构建**。

Mclash **原样继承**（`docs/design/01` §1.6.3）：

- 设计系统 5 个文件（`theme_define` / `theme_config` / `theme_data_{dark,light}` / `themes`）
- 设置引擎 5 个文件（`group_screen` / `group_item_{creator,options,widgets}` / `group_helper` 的 22 个设置页）
- 通用弹层 7 个文件（`dialog_utils` 11 个 dialog / `sheet` / `framework` / `routes` / `text_field` / `dropdown` / `segmented_elevated_button`）
- 代理能力（`proxy_board_*` / `profiles_board_*` / `proxygroup_*` / `rule_*` / `diversion_template_manager`）
- 其他 13 个页面（网络检测 / 备份同步 / 分应用代理 / 文件查看 / 关于 / 启动失败 / 版本更新 …）
- 逻辑层（`app/modules/*` / `app/utils/*` / `app/clash/*`）+ 9 语言 i18n 体系

**仅做 7 处最小改动**（`docs/design/01` §1.6.4）：
移除面板与二维码工具 · 登录改为 MoneyFly 账号 · 4 个导入入口移入开发者选项 ·
首页加 1 行账户状态条 · 修复 3 处已知视觉缺陷 · 顶部栏命中区 30→44 · 新增 4 Tab 导航。

### 内核工程与业务层 = mysoftware/moneyfly

[mysoftware/moneyfly](https://github.com/moneyfly004) 提供了：
完整的 mihomo 内核集成（Android `libmihomo.aar` gomobile + 桌面官方二进制）、
三平台 CI 构建发布链路，以及自动拉订阅 / 自动测速 / 一键连接的业务闭环。
其 UI 层**不沿用**（风格与 Clash Mi 不同），只移植逻辑层与内核层（`docs/design/01` §1.6.5 的 P-01~P-10）。

### 明确不做

Mclash 是 **MoneyFly 的官方业务客户端 + Clash Mi 的完整能力**，不是通用代理工具的重写：
不重新设计视觉、不删减 Clash Mi 能力、不引入 Clash Mi 之外的第三方内核。

---

## 许可证

见 [LICENSE](./LICENSE)。
内核 [mihomo](https://github.com/MetaCubeX/mihomo) 遵循其原始许可证（GPL-3.0）。
