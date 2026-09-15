# 03 · 设计系统 / Design Tokens

> 文档版本 v1.0 · 单一事实来源：`lib/theme/app_theme.dart` + `docs/design/mockups/tokens.css`
> 实现约定：页面里**只准**写 `MFColors.xxx` / `kNumFont` / `mfLatencyColor()`，
> 不准出现裸 `Color(0x...)`（预览色卡、渐变定义除外）。

---

## 3.1 品牌

| 项 | 值 |
|---|---|
| 品牌名 | **MoneyFly** |
| 产品名（客户端） | **Mclash** |
| 图形标 | 黑色圆角方底 + 品牌蓝 `M` 折线（`M9 35V13l15 15L39 13v22`，stroke-width 6.5，linecap/linejoin round，48×48 viewBox） |
| 图形标圆角 | `rx=12`（48 基准）→ 实际界面 44px 标对应 `border-radius: 12px` |
| 字标 | `Money` + **`Fly`**（Fly 用 `brandLight`） |
| 字体（标/数字） | `Chakra Petch`（400/500/600/700） |
| 字体（正文） | `PingFang SC` → 回落 `Noto Sans SC` → `sans-serif` |
| Slogan | 极速 · 稳定 · 全球畅连 |
| 品牌色语义 | 蓝紫渐变 = 品牌与「可操作」；绿 = 连通/正常；琥珀 = 警告/中等延迟；红 = 危险/失败 |

---

## 3.2 颜色令牌

### 3.2.1 基础色板（设计稿基准 · 深色「暗夜蓝」）

| Token | Hex | 用途 |
|---|---|---|
| `--brand` | `#455FE9` | 品牌主色、主按钮渐变起点、选中态 |
| `--brand-2` | `#6C7BFF` | 品牌亮色、渐变中段、链接、数值强调 |
| `--brand-3` | `#7A5CFF` | 品牌紫、渐变终点、标签徽章 |
| `--bg` | `#0B0E14` | 页面背景（最深） |
| `--bg-2` | `#141926` | 次级背景 |
| `--card` | `#141926` | 卡片底 |
| `--card-2` | `#1A2132` | 卡片渐变下半 / 输入框底 / SnackBar 底 |
| `--line` | `rgba(255,255,255,.07)` | 1px 分隔线（弱） |
| `--line-2` | `rgba(255,255,255,.12)` | 1px 边框（强）、输入框边框 |
| `--txt` | `#F5F7FF` | 主文本 |
| `--txt-2` | `#9AA3B5` | 次文本、说明 |
| `--txt-3` | `#5E6778` | 三级文本、占位符、未选中图标 |
| `--green` | `#2EE6A8` | 已连接、低延迟（<100ms）、成功 |
| `--amber` | `#FFB020` | 中等延迟（100–300ms）、警告 |
| `--red` | `#FF5A5F` | 失败、高延迟（≥300ms）、危险操作 |

### 3.2.2 六套完整外观模式（**整套切换**，非只换品牌色）

> 设计要点：每个模式自带 `isDark` 属性与**完整**配色（背景/卡片/文字/品牌/边框）。
> 只换品牌色会导致「浅色卡片 + 浅色文字」这类自相矛盾的组合。

| # | key | 名称 | isDark | bg | card | txt | brand | brandLight | brandDeep | line |
|---|---|---|---|---|---|---|---|---|---|---|
| ① | `light` | 浅色 | ✗ | `#F5F6FA` | `#FFFFFF` | `#1A2233` | `#455FE9` | `#6C7BFF` | `#3346C4` | `#E5E8F0` |
| ② | `warm` | 暖白 | ✗ | `#FAF6F1` | `#FFFFFF` | `#2A2118` | `#E8862E` | `#F0A35C` | `#C96E1E` | `#EDE4D8` |
| ③ | `gray` | 浅灰 | ✗ | `#EEF0F4` | `#FFFFFF` | `#22262E` | `#5B7CFA` | `#7D97FB` | `#4560D8` | `#DFE3EA` |
| ④ | `darkgray` | 深灰 | ✓ | `#1B1E24` | `#242830` | `#F2F4F8` | `#5B8DEF` | `#7DA6F2` | `#4370CC` | `#343A45` |
| ⑤ | `darkblue` | 深蓝 | ✓ | `#0F1626` | `#182036` | `#F2F5FB` | `#4E7CF6` | `#729AF8` | `#3A5FD0` | `#2A3550` |
| ⑥ | `black` | 纯黑 | ✓ | `#0A0A0C` | `#16181D` | `#F5F6F8` | `#6C7BFF` | `#8B9BFF` | `#5560D8` | `#2A2D34` |

**语义色的明暗自适应**（保证对比度）：

| Token | 深色模式 | 浅色模式 | 说明 |
|---|---|---|---|
| `green` | `#2EE6A8` | `#0E9F6E` | 浅底用深绿保证可读 |
| `greenDeep` | `#1FA97E` | `#0E9F6E` | 进度条实心 |
| `red` | `#FF5A5F` | `#F04438` | 浅底用深红 |
| `amber` | `#FFB020` | `#FFB020` | 两模式通用（本身足够醒目） |

### 3.2.3 延迟色阶（**全局唯一口径**）

```dart
Color mfLatencyColor(int latencyMs, bool online) {
  if (!online)        return MFColors.red;     // 离线
  if (latencyMs < 0)  return MFColors.txt3;    // 在线但延迟未知（UDP 协议未测）
  if (latencyMs < 100) return MFColors.green;  // 优秀
  if (latencyMs < 300) return MFColors.amber;  // 良好
  return MFColors.red;                          // 较差
}
```

> 该函数必须被 **列表 / 弹层 / 当前节点卡 / 国家快捷卡** 共用，禁止各页面自己写阈值。

**延迟可信度过滤**（`mfLatencyUsable`）：

```dart
bool mfLatencyUsable(int ms) => ms > 0 && ms <= 5000;
```

- `ms == 0` → 通常来自被劫持/污染的探测（中间设备直接应答明文 204），会被误排成「最快」→ **判为不可信**
- `ms >= 5000` → 等同失败 → **不参与自动选优**

### 3.2.4 渐变

| 名称 | 定义 | 用途 |
|---|---|---|
| `brandGradient` | `linear-gradient(135deg, brand, brandLight, brandDeep)` | 主按钮、选中分段、激活态 |
| 主按钮内高光 | `linear-gradient(180deg, rgba(255,255,255,.18), transparent 45%)` | `::after` 伪元素，制造玻璃质感 |
| 连接卡描边 | `linear-gradient(160deg, rgba(46,230,168,.6), rgba(255,255,255,.06) 30%, rgba(69,95,233,.6))` | 已连接态发光边框（mask-composite 实现 1px 渐变边） |
| 自动测速卡底 | `linear-gradient(120deg, rgba(69,95,233,.16), rgba(69,95,233,.04) 60%, transparent)` | 蓝调功能卡 |
| 订阅卡底 | `linear-gradient(135deg, #1A2140, #141926 60%, #10141F)` | 我的页订阅卡 |

---

## 3.3 字体与排版

### 3.3.1 字族

| 用途 | 字族 | 回退链 |
|---|---|---|
| 数字 / 品牌字标 / 版本号 / 延迟值 / 流量值 / 订单号 | `Chakra Petch` | `'SF Mono', ui-monospace, monospace` |
| 全部正文 | 系统中文黑体 | macOS/iOS `PingFang SC`；Windows `Microsoft YaHei UI`；Android `Noto Sans SC` |
| Emoji（旗帜/状态） | 内置 `Emoji` 字体（来源 hiddify） | 平台 emoji |
| 国旗 | **PNG 图片**（`assets/flags/{cc}.png`，约 140 国） | Windows 上 emoji 国旗会渲染成字母对，必须用图片 |

### 3.3.2 字号阶梯

| Token | size / weight / line-height | 用途 |
|---|---|---|
| `display` | 32 / 700 / 1.1 · `Chakra Petch` | 支付金额 |
| `h1` | 26 / 700 / 1.2 · `Chakra Petch` | 登录页品牌字标 |
| `h2` | 22 / 700 / 1.25 | 页面大标题（套餐页标题） |
| `h3` | 18 / 700 / 1.3 | AppBar 标题、子页标题 |
| `h4` | 17 / 700 / 1.3 | 弹窗标题、卡片主标 |
| `body-lg` | 16 / 600 | 主按钮文字 |
| `body` | 14–14.5 / 400–600 | 正文、列表主标 |
| `body-sm` | 13.5 / 400–500 | 设置行标题、输入值 |
| `caption` | 12.5–13 / 400–500 | 说明文字、标签 |
| `micro` | 10.5–11 / 500–700 | 徽章、提示、角标（常配 `letter-spacing: .06em`） |
| `section` | 11 / 700 · `letter-spacing: .14em` | 设置页分组标题（全大写字距感） |

### 3.3.3 数字排版规则

- 所有**数值**（延迟、速率、流量、天数、金额、订单号、端口）一律 `Chakra Petch` + `font-variant-numeric: tabular-nums`，保证纵向对齐不跳动。
- 金额去掉无意义尾零：`0.02 → "0.02"`、`200 → "200"`、`200.5 → "200.5"`（**禁止** `toStringAsFixed(0)`，会把 0.02 元显示成 0 元）。
- 速率单位与数值分离：数值 17px / 单位 12px + `txt-3`。

---

## 3.4 间距 / 圆角 / 阴影

### 间距（4px 基准）

| Token | 值 | 用途 |
|---|---|---|
| `space-1` | 4px | 图标与文字间隙 |
| `space-2` | 8px | 行内元素间距 |
| `space-3` | 12px | 卡片内元素、列表项间距 |
| `space-4` | 16px | 卡片内边距、字段间距 |
| `space-5` | 18px | 区块间距（移动） |
| `space-6` | 22px | **页面左右安全边距（移动端）** |
| `space-7` | 24–28px | 弹窗内边距、引导页 |
| `space-8` | 48–56px | 移动端 mockup 画布留白 |

> **移动端页面左右边距统一 22px**（`margin: 0 22px`）—— 这是设计稿的硬性约定。

### 圆角

| Token | 值 | 用途 |
|---|---|---|
| `r-xs` | 6px | 复选框 |
| `r-sm` | 9–10px | 小图标底、分段选项 |
| `r-md` | 11–13px | 小按钮、国家卡、搜索框内元素 |
| `r-lg` | 14–16px | 输入框、设置行、列表项、主按钮 |
| `r-xl` | 18–20px | 套餐卡、订阅卡、节点卡 |
| `r-2xl` | 22–26px | 连接卡、支付弹窗 |
| `r-full` | 20px+ / 50% | 徽章、圆形按钮、开关 |

### 阴影

| Token | 定义 | 用途 |
|---|---|---|
| `shadow-brand` | `0 10px 30px rgba(69,95,233,.35)` | 主按钮 |
| `shadow-brand-sm` | `0 5px 16px rgba(69,95,233,.35)` | 小主按钮 |
| `shadow-card` | `0 6px 22px rgba(69,95,233,.18)` | 选中节点卡 |
| `shadow-modal` | `0 30px 80px rgba(0,0,0,.6), 0 0 60px rgba(69,95,233,.18)` | 支付弹窗 |
| `glow-green` | `0 0 34px rgba(46,230,168,.5)` | 已连接电源环 |
| `glow-brand` | `0 6px 18px rgba(69,95,233,.4)` | 选中分段、最优标记 |

---

## 3.5 组件规范

### 3.5.1 主按钮 `MFPrimaryButton`

| 属性 | 值 |
|---|---|
| 高度 | 54px（移动主按钮）/ 48–50px（弹窗按钮）/ 46px（次按钮） |
| 圆角 | 16px |
| 背景 | `brandGradient` |
| 阴影 | `shadow-brand` |
| 文字 | 16px / 600 / `#FFFFFF` |
| 内高光 | 顶部 45% 高度的白色 18% 渐隐 |
| Loading | 22×22 `CircularProgressIndicator`（strokeWidth 2.4，白色）替代文字 |
| Disabled | 不透明度 45%，`onTap = null` |
| 图标 | 可选前置图标，与文字间距 8px |

**变体**

| 变体 | 背景 | 边框 | 文字 |
|---|---|---|---|
| `primary` | 品牌渐变 | 无 | `#FFFFFF` |
| `ghost` | 透明 | `1px --line-2` | `--txt` |
| `danger-ghost` | `rgba(255,90,95,.07)` | `1px rgba(255,90,95,.35)` | `--red` |
| `action`（顶部小按钮） | 品牌渐变 | 无 | `#FFFFFF`，高 30–36px，圆角 9–11px，13px 字 |

### 3.5.2 卡片

```
background : linear-gradient(180deg, var(--card), var(--card-2))
border     : 1px solid var(--line)
border-radius : 20px（大卡）/ 16px（列表卡）
padding    : 16px（大卡）/ 13–14px 14px（列表卡）
```

**状态变体**

| 状态 | 表现 |
|---|---|
| 默认 | 上述 |
| 选中（当前节点） | `border-color: rgba(69,95,233,.7)`；`background: linear-gradient(180deg, rgba(69,95,233,.16), rgba(69,95,233,.05))`；`shadow-card` |
| 最优节点 | 卡片左上角浮出 `最优` 徽章（`-7px` 上移，品牌渐变，9.5px/700，圆角 10px） |
| 危险/到期 | `border-color: rgba(255,90,95,.35)`；`background: rgba(255,90,95,.07)` |

### 3.5.3 输入框

| 属性 | 值 |
|---|---|
| 高度 | 54px |
| 背景 | `--card` |
| 边框 | `1px --line-2`，圆角 16px |
| 内边距 | `0 16px` |
| 文字 | 15px，`--txt` |
| 占位符 | `--txt-3` |
| Focus | `border-color: --brand` + `box-shadow: 0 0 0 3px rgba(69,95,233,.22)` |
| 错误 | `border-color: --red` + 下方 10.5px 红字提示 |
| 标签 | 上方 12.5px / 500 / `--txt-2`，间距 7px |
| 右侧图标 | 绝对定位 `right:14px; top:37px`（密码眼睛） |

### 3.5.4 开关 `Switch`

| 属性 | 值 |
|---|---|
| 尺寸 | 44×26，圆角 13 |
| 开 | `background: --brand`，滑块 `right: 3px` |
| 关 | `background: #2A3242`，滑块 `left: 3px` |
| 滑块 | 20×20 白色圆，`0 2px 6px rgba(0,0,0,.35)` |
| 过渡 | `.25s` |
| 列表内 | `transform: scale(.82)`，`transform-origin: right center` |

### 3.5.5 设置行 `srow`

```
margin: 0 22px 8px; padding: 0 16px; height: 48px;
background: var(--card); border: 1px solid var(--line); border-radius: 14px;
```
| 槽位 | 规格 |
|---|---|
| 图标 | 28×28，圆角 9px，底 `#1B2233`，居中 |
| 标题 | `flex:1`，13.5px / 500 / `--txt` |
| 副标题 | 10px / `--txt-3`，标题下 1px |
| 值 | 12px / `--txt-3` / `Chakra Petch` |
| 箭头 | 12px / `--txt-3`（`›`） |
| 分段控件 | 底 `#1B2233` 圆角 9px 内 padding 2px；选中项品牌渐变 + 圆角 7px + 11px/600 白字 |
| 危险行 | 标题 `--red`，图标底 `rgba(255,90,95,.12)` 图标 `--red` |

**设置页分组标题 `sect-h`**：`11px / 700 / --txt-3 / letter-spacing: .14em / margin: 14px 24px 8px`

### 3.5.6 列表项（节点行）

| 槽位 | 规格 |
|---|---|
| 容器 | `margin: 0 22px 8px; padding: 13px 14px; border-radius: 16px; gap: 12px` |
| 国旗 | 34×34，圆角 11px，底 `#1B2233`，PNG 图片 |
| 名称 | 14px / 600 / `--txt`，单行省略 |
| 副标题 | 11px / `--txt-3` / `Chakra Petch`，上边距 2px |
| 延迟徽章 | `Chakra Petch` 12.5px / 600，`padding: 3px 9px`，圆角 20px，三色（green/amber/red 各配 10% 底 + 22~25% 边） |
| 当前标记 | 18×18 圆形，品牌渐变底，白色对勾 SVG，`glow-brand` |
| 负载条 | 3×26px 圆角条，底 `#232B3D`，内部 `i` 高度 = 负载百分比 |

### 3.5.7 徽章 / 标签

| 类型 | 规格 |
|---|---|
| 状态徽章（已连接） | 11px / 600，`--green` 文字，`rgba(46,230,168,.12)` 底，`rgba(46,230,168,.3)` 边，圆角 20px，`padding: 3px 10px` |
| 最优标记 | 9.5px / 700 / 白字，品牌渐变底，圆角 10px，`padding: 2px 8px` |
| 计划「热门」标签 | 10px / 700 / 白字，品牌渐变，圆角 20px，`padding: 3px 10px`，水平居中、上移 9px |
| 红点 | 8px 圆（tab 角标 7px），`--red` |
| 计数胶囊 | `Chakra Petch` 11px / `--txt-3`，`#232B3D` 底，圆角 12px |

### 3.5.8 底部弹层（Bottom Sheet）

| 属性 | 值 |
|---|---|
| 圆角 | 顶部 24px |
| 背景 | `--bg-2` |
| 遮罩 | `rgba(3,5,10,.7)` + `backdrop-filter: blur(6px)` |
| 抓手 | 36×4px 圆角条，`--line-2`，居中，上边距 10px |
| 内边距 | `16px 0`（列表自带左右 22px） |
| 最大高度 | `0.75 × 屏高`，内部滚动 |

### 3.5.9 对话框（Dialog）

| 属性 | 值 |
|---|---|
| 宽 | 移动：左右 22px；桌面：`min(420px, 90vw)` |
| 圆角 | 26px（支付）/ 20px（确认） |
| 背景 | `linear-gradient(180deg, #171E2E, #10141F)` |
| 边框 | `1px --line-2` |
| 阴影 | `shadow-modal` |
| 标题 | 17px / 700 |
| 副标题 | 11px / `--txt-3` / `letter-spacing: .08em` |
| 按钮行 | `display:flex; gap:10px`，两按钮等宽，高 48px |

### 3.5.10 Toast / SnackBar

| 属性 | 值 |
|---|---|
| 位置 | 底部浮动，距底 16px |
| 背景 | `--card-2` |
| 圆角 | 12px |
| 文字 | 13px / `--txt` |
| 时长 | 2.5s（错误 4s） |
| 图标 | 可选前置提示图标；错误用 `--red` |

### 3.5.11 骨架屏 / 空态 / 错误态

| 状态 | 规范 |
|---|---|
| **骨架屏** | 灰块 `#232B3D`，`shimmer` 动画 1.2s 循环；套餐页加载时展示 3 行骨架 |
| **空态 `mfEmpty`** | 居中图标（48px，`--txt-3`，透明度 40%）+ 主文案 14px `--txt-2` + 副文案 12px `--txt-3` + 可选行动按钮 |
| **错误态** | 红色卡（`rgba(255,90,95,.07)` 底 + `.35` 边）+ 错误文案 + `[重试]` `[换节点]` 两个行动按钮 |
| **加载中** | 全局：`ConnectionController` 状态文字（「正在同步订阅…」/「正在连接…」）；**过程态不得显示为错误** |

### 3.5.12 连接按钮（核心组件）

| 状态 | 环 | 内核 | 文字 | 徽章 |
|---|---|---|---|---|
| 未连接 | 双层静态环（`rgba(46,230,168,.18/.35)`） | `radial-gradient(circle at 50% 32%, #1E3B3A, #0E1716)`，绿边 | 「未连接」+ `--txt-3` | 无 |
| 连接中/测速中 | 环加 `spin` 1.4s 旋转动画 | 同上 + 呼吸（opacity 0.5↔1，1.6s） | 「正在连接…」+ `--amber` | 进度条 |
| 已连接 | 环加 `pulse` 2.2s 扩散动画 | `box-shadow: 0 0 34px rgba(46,230,168,.5)` | 「已连接」+ `--green` | 节点名 + 延迟胶囊 |
| 错误 | 红色环 | 红边 + `rgba(255,90,95,.15)` 底 | 「连接失败」+ `--red` | 错误原因 |

尺寸：外环 96×96（移动）/ 88×88（桌面紧凑）；内核 76×76 / 70×70。

---

## 3.6 图标规范

| 项 | 规范 |
|---|---|
| 图标库 | Material Icons（`Icons.*_outlined` 未选中 / `Icons.*` 选中） |
| 移动端 Tab 图标 | 22px |
| 桌面端 Rail 图标 | 24px |
| 行内图标 | 16–20px |
| 卡片头图标 | 26×26，圆角 8px，品牌渐变底，白色，13px |
| 设置行图标 | 28×28，圆角 9px，底 `#1B2233` |
| 我的页菜单图标 | 34×34，圆角 10px，底 `#1B2233`，图标色 `--brandLight` |
| 国旗 | **PNG**，34×34（列表）/ 16–20px 内联（卡片） |
| 描边 | 统一 1.5–2px；品牌标 6.5px（48 viewBox） |

---

## 3.7 动效规范

| 场景 | 时长 | 缓动 | 说明 |
|---|---|---|---|
| 颜色/边框/阴影过渡 | 180–250ms | `ease` / `cubic-bezier(.4,0,.2,1)` | hover、选中态切换 |
| 卡片出现 | 220ms | `ease-out` | 位移 8px + 透明度 0→1 |
| 底部弹层 | 260ms | `cubic-bezier(.32,.72,0,1)` | 位移 100%→0 |
| 页面转场 | 300ms | 平台默认 | iOS 风格右滑；Android 使用 FadeThrough |
| 连接环呼吸 | 1600ms | `ease-in-out` 无限往复 | opacity .5↔1 |
| 已连接脉冲 | 2200ms | `ease-out` 无限 | `scale(1)→scale(1.25)` + opacity 1→0 |
| 加载旋转 | 900–1400ms | `linear` 无限 | spinner |
| 延迟数字跳动 | 300ms | `ease-out` | 数字变化时纵向滑入 |
| 骨架 shimmer | 1200ms | `linear` 无限 | 渐变位移动画 |

**减少动效**：遵循系统「减弱动态效果」设置 → 关闭所有无限循环动画（脉冲/呼吸/shimmer），仅保留 ≤150ms 的状态过渡。

---

## 3.8 响应式断点

| 断点 | 宽度 | 导航形态 | 内容最大宽 |
|---|---|---|---|
| `compact`（手机竖屏） | < 600px | 底部 `BottomNavigationBar` 4 Tab | 全宽 |
| `medium`（手机横屏 / 小窗） | 600–839px | 底部导航（保持） | 720px 居中 |
| `wide`（**桌面**） | ≥ 840px | 左侧 `NavigationRail`（labelType: all） | 1040px 居中 |

> 临界值 **840px** 与设计稿一致。窗口最小尺寸 **380×620**（桌面）。
> `IndexedStack` 保活已访问 Tab + `TickerMode` 停用非活动 Tab 动画（省电省 CPU）。

---

## 3.9 无障碍（Accessibility）

| 项 | 要求 |
|---|---|
| 对比度 | 正文文本 ≥ 4.5:1；大字 ≥ 3:1（六套主题均已校验） |
| 最小点击区 | 44×44（移动）/ 32×32（桌面） |
| 语义标签 | 所有图标按钮必须有 `tooltip` 或 `Semantics(label:)` |
| 连接状态 | 不能只用颜色表达（绿/红）→ 必须同时有文字（「已连接」/「连接失败」） |
| 延迟色阶 | 徽章内始终带数字（`86ms`），色仅作辅助 |
| 动态字号 | 支持系统字号放大至 130% 不溢出（列表项名称省略、徽章不换行） |
| 键盘导航（桌面） | Tab 顺序 = 视觉顺序；`Esc` 关闭弹层；`Enter` 触发主按钮 |
| 焦点环 | 桌面端键盘焦点必须有 2px 品牌色外环 |

---

## 3.10 设计令牌落地检查清单

- [ ] `lib/theme/app_theme.dart` 中 `_mfThemes` 六套配色与 §3.2.2 表格逐值一致
- [ ] `MFColors` 全部为 **getter**（随 `ThemeController.appearance` 动态切换），页面无需改写法
- [ ] `buildMoneyFlyTheme(brightness)` 的颜色与 `brightness` 参数**绑定**（避免白底白字/黑底黑字错位）
- [ ] `mfLatencyColor` / `mfLatencyUsable` / `formatPrice` / `kNumFont` 全局唯一实现
- [ ] 页面中无裸 `Color(0x...)`（grep 校验）
- [ ] `docs/design/mockups/tokens.css` 与 Dart 常量保持同步（CI 可加 diff 校验）
