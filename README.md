# Mclash

> **Clash Mi 的界面与全部代理能力 + 自建后台的账号与商业化闭环。**
> 平台：Android（3 ABI）· Windows（amd64）· macOS（Apple 芯片 / Intel / universal）
> 内核：[MetaCubeX/mihomo](https://github.com/MetaCubeX/mihomo)（官方源码，**不使用 fork**）

---

## 这是什么

界面、排版、组件 **100% 沿用 [Clash Mi](https://github.com/KaringX/clashmi)**：
Material 3 + 种子色 `#293CA0` + 方角 + 高密度列表 + 唯一分隔线
`Divider(height:1, thickness:0.3)` + `SimpleDialog` 全家桶 + `platform: TargetPlatform.iOS` + 3 主题模式。

导航层新增 **4 个底部 Tab**：**主页 · 节点列表 · 套餐购买 · 我的**（桌面 ≥840px 转左侧导航 88px）。

```
① 安装并打开  →  ② 登录账号（唯一一次手动输入）
                        ↓ 自动：拉订阅 → 解析节点 → 写入「我的配置」→ 并发测速 → 选中最优
               ③ 拨动首页连接开关  →  ✅ 上网
```

**从安装到上网 = 2 次操作**；同时 Clash Mi 的代理管理、分流、规则、代理组、内核设置、
应用设置、网络检测、备份同步等能力**一个不少**。

---

## 平台与内核

| 平台 | 架构 | 分发 | 内核资产 |
|---|---|---|---|
| Android | `arm64-v8a` / `armeabi-v7a` / `x86_64` | APK + AAB | `libmihomo.aar`（[moneyfly004/mihomo-lib](https://github.com/moneyfly004/mihomo-lib)，gomobile bind 官方源码） |
| Windows | `amd64` | `.exe` + `.zip` | `mihomo-windows-amd64-**compatible**` |
| macOS | `arm64`（Apple 芯片） | `.dmg`（纯 arm64） | `mihomo-darwin-arm64` |
| macOS | `x86_64`（Intel） | `.dmg`（纯 x86_64，Rosetta 整链） | `mihomo-darwin-amd64-**compatible**` |
| macOS | `universal` | `.dmg` | 上面两个 `lipo -create` 合并 |

> ⚠️ **请勿跨架构混装。** Intel Mac 必须用 `compatible` 内核 —— 官方标准版按
> AMD64 v3（AVX2）编译，2015 年前的老 Intel 与 Rosetta 都不支持，启动即崩。
> CI 里每个 macOS 产物都用 `lipo -archs` **断言**主程序与内核架构一致。

---

## 架构

```
┌──────────────────────────────────────────────────────────────┐
│ 表现层  Clash Mi 的 Material 3 设计系统（原样沿用）             │
├──────────────────────────────────────────────────────────────┤
│ 导航层  4 Tab（主页/节点列表/套餐购买/我的）—— 按 Clash Mi      │
│         视觉语言新造：高 56 · 图标 24 · 无指示器 · 无动画        │
├──────────────────────────────────────────────────────────────┤
│ 能力层  Clash Mi 全部功能（仅移除 zashboard 面板与二维码工具）   │
├──────────────────────────────────────────────────────────────┤
│ 业务层  账号 / 订阅 / 套餐 / 支付 / 订单 / 设备 / 通知           │
├──────────────────────────────────────────────────────────────┤
│ 内核层  packages/libclash_vpn_service                         │
│         Android  : MethodChannel → Kotlin VpnService + AAR    │
│         Win/mac  : 纯 Dart，mihomo 子进程 + 系统代理            │
└──────────────────────────────────────────────────────────────┘
```

**两个自有插件**（替代原 Clash Mi 依赖的外置包）：

| 包 | 作用 |
|---|---|
| `packages/libclash_vpn_service` | VPN 服务。Android 走 `VpnService.establish()` 拿 TUN fd 注入内核；桌面端**纯 Dart**（`Process.start(mihomo)` + Clash REST API 双条件就绪探测 + `reg`/`networksetup` 系统代理）—— 少一层原生服务二进制 |
| `packages/board_service` | 后台客户端。保留 Clash Mi 的类名契约（`V2BoardClient`/`XboardClient`/`SSPanelUimClient`），底层指向自有后台，使其约 3000 行会话/配置管理零改动可用 |

---

## 目录

```
lib/
├── main.dart                     入口（注册 VPN 插件 → 启动账户轮询 → TabShell）
├── screens/
│   ├── main_tab_shell.dart       ★ 4 Tab 容器（每个 Tab 独立 Navigator）
│   ├── mclash_nodes_screen.dart  T-1 节点列表
│   ├── mclash_plan_screen.dart   T-2 套餐购买
│   ├── mclash_profile_screen.dart T-3 我的
│   ├── home_mclash_widgets.dart  首页账户状态条 + 准入闸门
│   ├── home_screen*.dart         T-0 主页（Clash Mi 原样）
│   ├── proxy_board_*.dart        代理 / 代理组 / 节点（Clash Mi 原样）
│   ├── group_helper.dart         22 个设置页的声明式定义
│   └── …                         Clash Mi 的其余页面
├── mf/                           业务层
│   ├── mclash_api.dart           后台接口封装
│   └── mclash_account_service.dart 账户状态 + 5 态准入判定
└── i18n/                         9 语言（slang 代码生成）

packages/                         自有插件（见上）
docs/design/                      ★ 设计文档套件 + 高保真设计稿
tool/                             开发工具链（拉内核/geo 数据）
scripts/thin_app.sh               macOS universal → 单架构裁剪
```

---

## 开发

```bash
# 1) 依赖（国内镜像快很多）
export PUB_HOSTED_URL=https://pub.flutter-io.cn
export FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn
flutter pub get
dart run slang                    # 生成本地化

# 2) 离线分流数据（不入库）
bash tool/fetch_geodata.sh

# 3) 内核
bash tool/fetch_mihomo_aar.sh     # Android（约 185MB，含 sha256 校验）
bash tool/fetch_mihomo.sh         # 桌面（macOS 会自动放进已构建的 .app）

# 4) 静态检查与测试
flutter analyze                   # 必须 0 error
flutter test --concurrency=1

# 5) 构建
flutter build apk --split-per-abi
flutter build windows --release
flutter build macos --release
arch -x86_64 flutter build macos --release    # Intel（Rosetta 整链）
bash scripts/thin_app.sh arm64 build/macos/Build/Products/Release/Mclash.app
```

**内核查找优先级**：环境变量 `MCLASH_MIHOMO` → 用户副本目录（设置页切换/更新过的）
→ 安装目录内置。

---

## 发布

推 `v*` tag 触发 `.github/workflows/release.yml`，产出：

```
Mclash-android-{arm64-v8a,armeabi-v7a,x86_64}-*.apk + Mclash-android-*.aab
Mclash-windows-x64-portable-*.zip + Mclash-setup-*.exe
Mclash-macos-arm64-*.dmg        （纯 arm64）
Mclash-macos-x64-*.dmg          （纯 x86_64，Rosetta 整链）
Mclash-macos-universal-*.dmg    （arm64 + x86_64）
SHA256SUMS-*.txt
```

Android 正式签名需要在仓库 Secrets 里配置
`KEYSTORE_BASE64` / `KEYSTORE_PASSWORD` / `KEY_ALIAS` / `KEY_PASSWORD`
（缺失时回退 debug 签名并打印警告 —— 仅可用于本地验证，不可分发）。

**升级内核只改一处**：`release.yml` 里的 `MIHOMO_VERSION`。

---

## 设计文档

完整套件在 [`docs/design/`](./docs/design/README.md) —— 每个页面都有详细设计图。

| 入口 | 内容 |
|---|---|
| [`docs/design/mockups/index.html`](./docs/design/mockups/index.html) | 🎨 **设计稿总览**（从这里开始看视觉） |
| [`docs/design/mockups/mobile.html`](./docs/design/mockups/mobile.html) | 移动端 25 屏 |
| [`docs/design/mockups/desktop.html`](./docs/design/mockups/desktop.html) | 桌面端 7 屏 |
| [`01 · 产品定义与平台矩阵`](./docs/design/01-产品定义与平台矩阵.md) | 三条原则 · 保留清单 R-01~R-15 · 最小改动 M-01~M-07 |
| [`03 · 设计系统`](./docs/design/03-设计系统-Design-Tokens.md) | Clash Mi 逐值令牌 · M3 派生调色板 · 16 类组件 |
| [`04 · 信息架构`](./docs/design/04-信息架构与导航地图.md) | 4 Tab 规格 · 47 页面清单 · 导航地图 |
| [`06 · 页面设计 · 移动端`](./docs/design/06-页面设计-移动端.md) | 逐页线框图 + 规格表 |
| [`08 · 内核集成与构建发布`](./docs/design/08-内核集成与平台构建发布.md) | 内核来源 · CI 全流程 |

---

## 与参考项目的关系

- **表现层与能力层** = [Clash Mi](https://github.com/KaringX/clashmi)。
  注意其仓库是**客户端壳**：`bind/*` 全被 gitignore、且依赖两个不存在的兄弟目录
  （`../libclash-vpn-service`、`../board-service`），**无法直接构建**。
  Mclash 用自己的两个插件替代之，并删除了它桌面端那套 NetworkExtension 系统扩展
  （本项目桌面端不需要 NE）。
- **内核工程与 CI** 参考 [MoneyFly 客户端](https://github.com/moneyfly004) 的成熟做法。
- **明确不做**：重新设计视觉、删减 Clash Mi 能力、引入第三方内核。

---

## 许可证

见 [LICENSE](./LICENSE)（GPL-3.0）。
内核 [mihomo](https://github.com/MetaCubeX/mihomo) 遵循其原始许可证（GPL-3.0）。
