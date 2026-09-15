# Mclash 设计文档套件

> 版本 **v3.0** · 状态：待评审 · 对应仓库 `github.com/moneyfly004/Mclash`

---

## 三个版本演进（重要）

| 版本 | 视觉语言 | 能力范围 | 一级导航 | 结论 |
|---|---|---|---|---|
| v1.0 | MoneyFly 圆角渐变 | 砍到只剩业务 | 4 Tab | ❌ **废弃** —— 风格与能力都不对 |
| v2.0 | Clash Mi | Clash Mi 全保留 | 无（单页滚动） | ❌ **废弃** —— 用户需要 4 Tab |
| **v3.0** | **Clash Mi（逐值沿用）** | **Clash Mi 全保留** | **4 Tab 底部导航** | ✅ **当前版本** |

**v3.0 的定义**：

> **Mclash = Clash Mi 的界面与全部代理能力 + MoneyFly 的账号与商业化闭环 + 4 个底部 Tab。**

---

## 怎么读这套文档

**按顺序读**：`01 → 02 → 03 → 04 → 05 → 06/07 → 08 → 09 → 10`

**按角色读**：

| 角色 | 建议阅读顺序 |
|---|---|
| 产品 / 老板 | 01（产品定义）→ `mockups/index.html`（设计稿总览）→ 06 §6.1~6.5（4 个 Tab）→ 10（验收） |
| UI / 设计 | 03（设计系统）→ `mockups/mobile.html` + `desktop.html` → 06 / 07（逐页规格） |
| Flutter 开发 | 02（架构）→ 03 §3.4（组件）→ 03 §3.5（设置引擎）→ 05（流程）→ 06 / 07 → 08 → 09 |
| 后台开发 | 09（接口）→ 01 §1.4（功能范围）→ 05（流程） |
| 测试 | 10（验收）→ 05（边界）→ 06 / 07（状态与空态） |

---

## 目录

| # | 文档 | 一句话 |
|---|---|---|
| — | **[`mockups/index.html`](./mockups/index.html)** | 🎨 **设计稿总览（从这里开始看视觉）** |
| 01 | [产品定义与平台矩阵](./01-产品定义与平台矩阵.md) | 三条原则 · **R-01~R-15 保留清单** · B-01~B-12 新增 · D-01/D-02 移除 · M-01~M-07 最小改动 · P-01~P-10 移植 |
| 02 | [总体架构设计](./02-总体架构设计.md) | 分层架构 · 模块清单 · 内核三形态 · 数据流 · ADR · 可靠性基线 |
| 03 | [设计系统 / Design Tokens](./03-设计系统-Design-Tokens.md) | **Clash Mi 逐值令牌** · M3 派生调色板全表 · 16 类组件 · 🆕 导航组件 · 动效 · ADR-016 |
| 04 | [信息架构与导航地图](./04-信息架构与导航地图.md) | **4 Tab 定义与规格** · 47 页面清单 · 导航地图 · Tab 切换行为 · 深链接 |
| 05 | [核心流程设计](./05-核心流程设计.md) | 8 条流程时序图 · 订阅三重防护 · 测速选优 · 一键连接 · 断线自愈 |
| 06 | [页面设计 · 移动端](./06-页面设计-移动端.md) | **19 章节线框图 + 逐元素规格 + 19 条改造点** |
| 07 | [页面设计 · 桌面端](./07-页面设计-桌面端.md) | 左侧导航 88px · 窗口/托盘/关闭行为 · 系统代理 · 快捷键 · 双架构 macOS |
| 08 | [内核集成与平台构建发布](./08-内核集成与平台构建发布.md) | 内核来源总表 · 三平台集成 · CI 全流程 · 升级 SOP |
| 09 | [后台接口对接设计](./09-后台接口对接设计.md) | 接口约定 · 订阅模块 · 12 种协议解析 · 后台配合清单 |
| 10 | [交付计划与验收标准](./10-交付计划与验收标准.md) | 里程碑 · 改造任务 · 验收标准 · 风险 · Go/No-Go |

### 高保真设计稿（纯静态 HTML，双击即可打开）

| 文件 | 内容 |
|---|---|
| [`mockups/index.html`](./mockups/index.html) | 总览：North Star Flow · **4 Tab 规格** · 令牌表 · 全部文档索引 |
| [`mockups/mobile.html`](./mockups/mobile.html) | **移动端 25 屏** |
| [`mockups/desktop.html`](./mockups/desktop.html) | **桌面端 7 屏** |
| [`mockups/tokens.css`](./mockups/tokens.css) | 设计令牌（Clash Mi 逐值，与 `app_theme` 同源） |
| [`mockups/render.cjs`](./mockups/render.cjs) | PNG 导出脚本 → `docs/design/img/*.png`（35 张） |

**移动端 25 屏**：T-0 主页（已连接 / 未连接 / 受限）· T-1 节点列表（含测速中）· T-2 套餐购买 · T-3 我的 ·
M-01 登录 · M-02 注册 · M-03 忘记密码 · C-01 我的配置 + C-05 弹层 · C-11 代理 + C-12 弹层 ·
C-41 应用设置 · C-42 内核设置 · C-22 网络检测 · M-04~M-07 业务页 · S-12 支付 · D-09 准入弹窗 ·
C-24 核心日志 · 通用规范汇总

**桌面端 7 屏**：四个 Tab（左侧导航 88px）· 关闭询问 + 托盘菜单 · 内核热替换 · 窄窗退化

### 基线分析资料（设计输入素材，非交付物）

> 这是对两个参考项目逐文件读完后产出的清单，描述**现状**，不是目标形态。

| 文件 | 内容 |
|---|---|
| [`_baseline/INDEX.md`](./_baseline/INDEX.md) | 页面↔文件↔入口 · 服务↔接口 · 错误文案 · 账号闸门 · 设置默认值 |
| [`_baseline/pages-part1-*.md`](./_baseline/pages-part1-shell-auth-home-nodes-purchase.md) | MoneyFly 壳与路由 · 认证 · 首页 · 节点 · 套餐 · 支付 |
| [`_baseline/pages-part2-*.md`](./_baseline/pages-part2-settings-widgets.md) | MoneyFly 我的 · 订单 · 设备 · 通知 · 设置 · 内核 · 日志 · 分流 |
| [`_baseline/color-tokens.md`](./_baseline/color-tokens.md) | MoneyFly 6 × 13 令牌色值 |
| [`_baseline/strings-zh-en.md`](./_baseline/strings-zh-en.md) | MoneyFly 585 个 i18n key 中英对照 |
| [`_baseline/i18n-hygiene.md`](./_baseline/i18n-hygiene.md) | MoneyFly 87 个死 key |
| [`_baseline/icons-and-hardcoded-strings.md`](./_baseline/icons-and-hardcoded-strings.md) | MoneyFly 图标与硬编码中文 |

---

## 三条设计原则（v3.0）

| 原则 | 含义 |
|---|---|
| **P1 · 风格是 Clash Mi 的** | Material 3 + 种子色 `#293CA0` + 方角 + 高密度列表 + 唯一分隔线 `Divider(1, 0.3)` + `SimpleDialog` 全家桶 + `platform: TargetPlatform.iOS` + 3 主题模式。**不做视觉再设计。** |
| **P2 · 能力是 Clash Mi 的** | Clash Mi 的功能**默认全部保留**（R-01~R-15）。可删的只有已确认的 2 项（zashboard 面板、二维码工具）。任何"简化"都必须先经确认。 |
| **P3 · 开箱即用是 MoneyFly 的** | 订阅不需要导入（后台随账号下发）；连接不需要选节点（自动测速选优）；续费/设备/通知都在同一 App 内。**但不以此为由删除任何现有能力。** |

---

## 核心旅程

```
安装并打开 → 登录 MoneyFly 账号（唯一一次手动输入）
                    ↓ 自动：拉订阅 → 解析节点 → 写入「我的配置」→ 并发测速 → 选中最优
             拨动首页连接开关（唯一一次手动操作）→ ✅ 上网
```

**进阶用户路径（完整保留）**：

```
主页 → 内核设置 → DNS / TUN / TLS / 嗅探 / Geo RuleSet / 分流模板 / 覆写
主页 → 我的配置 → 编辑配置 → 覆写设置
主页 → 代理 → 代理组 → 选节点 / 测速 / 排序
主页 → 网络检测（DNS / TUN / 代理 / 路由表四段诊断）
我的 → 备份与同步（iCloud / WebDAV / 局域网）
```

---

## 平台矩阵

| 平台 | 架构 | 分发 | 内核 |
|---|---|---|---|
| Android | `arm64-v8a` / `armeabi-v7a` / `x86_64` | APK（分 ABI）+ AAB | 进程内 `libmihomo.aar`（gomobile bind） |
| Windows | `amd64` | `.exe` + `.zip` | 子进程 `mihomo.exe`（官方 compatible） |
| macOS | `arm64`（Apple 芯片） | `.dmg` | 子进程 `mihomo`（官方 arm64） |
| macOS | `x86_64`（Intel） | `.dmg`（原生 x86_64 构建） | 子进程 `mihomo`（官方 **compatible**） |

---

## 变更记录

| 版本 | 变更 |
|---|---|
| v1.0 | 以 mysoftware/moneyfly 为基线、自研圆角渐变风格，并列出「明确不做」清单砍掉 Clash Mi 的配置/分流/规则/代理组/同步能力 |
| v2.0 | 按用户反馈改为极简底部导航：视觉与能力全部取 clashmi，**无一级导航**（单页滚动首页） |
| **v3.0** | **按用户反馈恢复 4 个底部 Tab**（主页 / 节点列表 / 套餐购买 / 我的），按 Clash Mi 视觉语言新造导航组件；桌面 ≥840px 转左侧导航 88px |
