# Mclash

> MoneyFly 多平台加速客户端 · Android / Windows / macOS（Apple 芯片 + Intel）
> 基于 [mihomo](https://github.com/MetaCubeX/mihomo)（MetaCubeX，**官方源码，不使用 fork**）
> 后台：`https://new.moneyfly.top`

---

## 这是什么

Mclash 是 MoneyFly 订阅服务的官方客户端。**用户不需要导入订阅、不需要看配置、不需要装内核** ——
只要登录账号，软件自动从后台拉取订阅、自动测速挑出最快线路、一键连上。

```
① 安装并打开  →  ② 登录（唯一一次手动输入）
                        ↓ 自动：拉订阅 → 解析节点 → 并发测速 → 选出最快
               ③ 点一下「连接」  →  ✅ 上网
```

**从安装到上网 = 2 次操作。**

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

## 核心能力

| 能力 | 说明 |
|---|---|
| **自动拉取订阅** | 登录后无需任何操作；冷启动先秒显磁盘缓存（≤800ms）再后台刷新；定时 30 分钟 + 回前台补拉 |
| **自动测速选优** | 订阅更新后自动并发测速（12 路并发 · 3 次取中位数）→ 延迟 + 负载惩罚选优 → 连接后经内核实测 |
| **一键连接** | 单一大按钮；自动选节点、生成配置、启动内核、就绪探测、置系统代理（桌面） |
| **断线自愈** | 内核被安全软件结束/崩溃后**始终**自动拉起（最多 3 次；10 分钟内 5 次崩退则熔断） |
| **准入闸门** | 到期 / 订阅停用 / 账号禁用 / 设备被踢 → 首页横幅 + 连接拦截 + 清空缓存（防绕过计费） |
| **支付续费** | 支付宝 / 微信 / USDT；二维码轮询；支付成功立即刷新订阅 |
| **设备管理** | 在线设备列表、踢下线、备注、设备数增量升级（+N 台，可顺延天数） |
| **内核管理** | 桌面端可检测官方最新版、经隧道下载、热替换、变体切换（标准/兼容）、恢复内置 |

---

## 设计文档（先看这里）

**完整设计文档套件在 [`docs/design/`](./docs/design/)** —— 每个页面都有详细设计图。

| 打开 | 内容 |
|---|---|
| **[`docs/design/mockups/index.html`](./docs/design/mockups/index.html)** | 🎨 **设计稿总览**（从这里开始） |
| [`docs/design/mockups/mobile.html`](./docs/design/mockups/mobile.html) | 移动端高保真设计稿（20 屏） |
| [`docs/design/mockups/desktop.html`](./docs/design/mockups/desktop.html) | 桌面端高保真设计稿（8 屏） |
| [`01 · 产品定义与平台矩阵`](./docs/design/01-产品定义与平台矩阵.md) | 三条设计原则、功能范围、与参考项目的取舍决策 |
| [`02 · 总体架构设计`](./docs/design/02-总体架构设计.md) | 七层架构、模块清单、内核三形态、数据流、15 条 ADR |
| [`03 · 设计系统 / Design Tokens`](./docs/design/03-设计系统-Design-Tokens.md) | 6 套配色、延迟色阶、字号/间距/圆角、12 类组件规范 |
| [`04 · 信息架构与导航地图`](./docs/design/04-信息架构与导航地图.md) | 24 页面 + 6 弹层、导航结构、页面跳转矩阵 |
| [`05 · 核心流程设计`](./docs/design/05-核心流程设计.md) | 8 条流程时序图（订阅三重防护 / 测速选优 / 一键连接 / 断线自愈） |
| [`06 · 页面设计 · 移动端`](./docs/design/06-页面设计-移动端.md) | **20 页逐页线框图 + 规格表 + 改造点** |
| [`07 · 页面设计 · 桌面端`](./docs/design/07-页面设计-桌面端.md) | 双栏布局、托盘、关闭行为、系统代理、快捷键 |
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

本项目综合了两个输入：

- **[clashmi-main](https://github.com/KaringX/clashmi)**（Clash Mi）—— 提供**工程组织与 UX 参照**。
  注意该仓库是**客户端壳**：`bind/{android,windows,linux,apple/Libclash.xcframework}` 均被 gitignore 且不存在，
  且依赖两个不在仓库中的兄弟目录（`../libclash-vpn-service`、`../board-service`），**无法直接构建**。
  本项目吸收其 VpnService 前台服务健壮性细节、快捷磁贴、内核日志实时流、深链接等（见设计文档 01 §1.6.3）。
- **[mysoftware/moneyfly](./docs/design/01-产品定义与平台矩阵.md)** —— 提供**可构建可发布的落地基线**：
  完整的内核集成、多平台 CI、以及订阅/测速/连接业务闭环。

**明确不做**（与 Clash Mi 这类通用工具的分野）：手动导入订阅、代理组/规则编辑器、多 profile 切换、
WebDAV/iCloud 同步。Mclash 是 **MoneyFly 的官方业务客户端**，不是通用代理工具。

---

## 许可证

见 [LICENSE](./LICENSE)。
内核 [mihomo](https://github.com/MetaCubeX/mihomo) 遵循其原始许可证（GPL-3.0）。
