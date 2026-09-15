# 03 · 设计系统 / Design Tokens（Clash Mi 风格）

> 文档版本 **v2.0**（v1.0 为 MoneyFly 圆角渐变风格，已废弃）
> **唯一事实来源 = Clash Mi 源码**：`lib/screens/theme_define.dart` · `theme_config.dart` ·
> `theme_data_dark.dart` · `theme_data_light.dart` · `themes.dart`
> Mclash 直接沿用这套令牌，**不做视觉再设计**。

---

## 3.0 设计基调（一句话）

> **Material 3 + 深靛蓝种子色 + 方角 + 高密度列表 + 单页滚动。**
> 没有渐变、没有大圆角、没有彩色卡片、没有底部导航、没有一句话营销。
> 整个 App 由四种元件构成：**Card / ListTile / BottomSheet / SimpleDialog**。

| 维度 | 值 |
|---|---|
| 框架 | Material 3（`useMaterial3: true`） |
| **强制平台** | `platform: TargetPlatform.iOS` —— **在所有平台上都是 iOS** |
| 种子色 | `Color(0xFF293CA0)` 深靛蓝 |
| 强调色 | `ThemeDefine.kColorBlue = Colors.blue = #FF2196F3` |
| "开启"绿 | `ThemeDefine.kColorGreenBright = Color.fromARGB(255, 8, 199, 15) = #FF08C70F` |
| 危险红 | `Colors.red = #FFF44336` |
| 连接绿点 | `Colors.green = #FF4CAF50` |
| 断开灰点 | `Colors.grey = #FF9E9E9E` |
| 圆角策略 | **方角**（`kBorderRadius = Radius.circular(0)`）；输入框 r4；卡片 r12（M3 默认）；弹窗 r28；按钮 r35 胶囊 |
| 主题模式 | **3 种**：`system` / `light` / `dark`（默认 `light`） |
| 字体 | **不设 `fontFamily`**，用系统字（`Typography.blackCupertino` → `CupertinoSystemText/Display`）；Windows 上 emoji 回退 `Emoji` 字体 |
| 字号 | 只有 4 个令牌（18 / 17 / 15·14 / 14）+ 少量 12px 字面量 |

---

## 3.1 颜色令牌

### 3.1.1 常量令牌（源码逐值）

| Token | 源码 | 解析值 | 用途 |
|---|---|---|---|
| `kColorBlue` | `Colors.blue` | `#FF2196F3` | **强调色**：选中行文字、链接、输入框浮动标签与边框、首页流量文字、下拉刷新 |
| `kColorBlue[800]` | `Colors.blue.shade800` | `#FF1565C0` | ElevatedButton 聚焦态背景 |
| `kColorBlue[200]` | `Colors.blue.shade200` | `#FF90CAF9` | ElevatedButton 选中态背景 |
| `kColorGrey` | `Colors.grey` | `#FF9E9E9E` | 次要文字、未聚焦输入框标签、hint、helper |
| `kColorGreenBright` | `Color.fromARGB(255, 8, 199, 15)` | `#FF08C70F` | **开关开启色**、延迟 < 800ms、连接中转圈、Checkbox 勾选色 |
| — | `Colors.green` | `#FF4CAF50` | 已连接状态点、排序按钮激活、内核设置提示文字 |
| — | `Colors.red` | `#FFF44336` | 错误文字、到期/超流量、延迟 ≥1500ms、删除、未读红点、扫码框 |
| — | `Colors.white` | `#FFFFFFFF` | 开关滑块、浅色卡片、浅色 BottomSheet |
| — | `Colors.black` | `#FF000000` | 深色主题 ElevatedButton 文字、延迟 800–1499ms（⚠️ 见 3.1.4 缺陷） |
| — | `Colors.transparent` | — | AppBar / 状态栏 / 导航栏 |

> **全 `lib/` 目录只有 6 个硬编码 hex**（不含生成文件）：
> `#7B5FF5`（登录页紫色渐变端点 ×3）、`#293CA0`（种子色 ×2）、`#F0F0F0`、`#303030`、`#121212`、`#08C70F`。
> **Mclash 保持这一纪律**：新增颜色必须先进入本表。

### 3.1.2 明暗两套主题的全部差异（只有 4 处）

```dart
// 深色
class ThemeDataDark {
  static const Color mainColor   = Color(0xFF303030);  // 卡片
  static const Color mainBgColor = Color(0xFF121212);  // 页面底
}
// 浅色
class ThemeDataLight {
  static const Color mainColor   = Colors.white;        // 卡片
  static const Color mainBgColor = Color(0xFFF0F0F0);   // 页面底
}
```

| 差异点 | 深色 | 浅色 |
|---|---|---|
| `cardTheme.color` | `#FF303030` | `#FFFFFFFF` |
| `elevatedButtonTheme.foregroundColor` | `Colors.black` | `Colors.white` |
| `checkboxTheme.fillColor` | `#FF303030` | `#FFFFFFFF` |
| `bottomSheetTheme.backgroundColor` | 未设 → M3 `#FF1B1B21` | `Colors.white`（浅色专属覆盖） |

**其余一切相同**：种子色、输入框、ListTile、进度条、强调色、开关绿。

### 3.1.3 M3 派生调色板（权威解析值）

两套主题均调用 `ColorScheme.fromSeed(seedColor: Color(0xFF293CA0), brightness: …, surface: …)`。
以下为**实际解析结果**（可直接当设计令牌用）：

#### 深色（surface `#121212`）

| 角色 | 值 | 角色 | 值 |
|---|---|---|---|
| `primary` | `#BAC3FF` | `onPrimary` | `#222C61` |
| `primaryContainer` | `#394379` | `onPrimaryContainer` | `#DEE0FF` |
| `secondary` | `#C3C5DD` | `onSecondary` | `#2D2F42` |
| `secondaryContainer` | `#434659` | `onSecondaryContainer` | `#E0E1F9` |
| `tertiary` | `#E5BAD7` | `onTertiary` | `#44263D` |
| `error` | `#FFB4AB` | `onError` | `#690005` |
| `errorContainer` | `#93000A` | `onErrorContainer` | `#FFDAD6` |
| **`surface`** | **`#121212`** | **`onSurface`** | **`#E4E1E9`** |
| `onSurfaceVariant` | `#C7C5D0` | `surfaceTint` | `#BAC3FF` |
| `surfaceDim` | `#121318` | `surfaceBright` | `#39393F` |
| `surfaceContainerLowest` | `#0D0E13` | `surfaceContainerLow` | `#1B1B21` |
| `surfaceContainer` | `#1F1F25` | `surfaceContainerHigh` | `#29292F` |
| `surfaceContainerHighest` | `#34343A` | `inverseSurface` | `#E4E1E9` |
| `outline` | `#90909A` | `outlineVariant` | `#46464F` |

#### 浅色（surface `#F0F0F0`）

| 角色 | 值 | 角色 | 值 |
|---|---|---|---|
| `primary` | `#515B92` | `onPrimary` | `#FFFFFF` |
| `primaryContainer` | `#DEE0FF` | `onPrimaryContainer` | `#394379` |
| `secondary` | `#5B5D72` | `onSecondary` | `#FFFFFF` |
| `secondaryContainer` | `#E0E1F9` | `onSecondaryContainer` | `#434659` |
| `tertiary` | `#77536D` | `onTertiary` | `#FFFFFF` |
| `error` | `#BA1A1A` | `onError` | `#FFFFFF` |
| `errorContainer` | `#FFDAD6` | `onErrorContainer` | `#93000A` |
| **`surface`** | **`#F0F0F0`** | **`onSurface`** | **`#1B1B21`** |
| `onSurfaceVariant` | `#46464F` | `surfaceTint` | `#515B92` |
| `surfaceDim` | `#DBD9E0` | `surfaceBright` | `#FBF8FF` |
| `surfaceContainerLowest` | `#FFFFFF` | `surfaceContainerLow` | `#F5F2FA` |
| `surfaceContainer` | `#EFEDF4` | `surfaceContainerHigh` | `#E9E7EF` |
| `surfaceContainerHighest` | `#E4E1E9` | `inverseSurface` | `#303036` |
| `outline` | `#767680` | `outlineVariant` | `#C7C5D0` |

> **实现约束**：Mclash 必须**同样用 `ColorScheme.fromSeed` 计算**，不要把这些值写死 ——
> 一旦 Flutter SDK 升级 M3 算法（tonal palette 微调），写死的值会与系统组件（Dialog/Sheet/Card 默认色）错位。

### 3.1.4 语义色阶（业务语义 → 令牌映射）

| 语义 | 颜色 | 出现位置 |
|---|---|---|
| 已连接 | `Colors.green` `#FF4CAF50` | 首页 8×8 状态圆点 |
| 未连接 | `Colors.grey` `#FF9E9E9E` | 首页 8×8 状态圆点 |
| 连接中 / 断开中 | `kColorGreenBright` `#FF08C70F` | 开关旁的 25×25 环形进度条 |
| 开关开启 | 轨道 `#FF08C70F`，滑块 `#FFFFFF` | 全 App 所有开关 |
| 开关关闭 | M3 默认灰轨道 | 同上 |
| 延迟优秀 (<800ms) | `kColorGreenBright` `#FF08C70F` | 代理页 / 节点选择 / 配置编辑 |
| 延迟一般 (800–1499ms) | `Colors.black` ⚠️ | 同上 |
| 延迟差 (≥1500ms) | `Colors.red` `#FFF44336` | 同上 |
| 订阅到期 / 超流量 | `Colors.red` | 首页"我的配置"副标题、配置列表 |
| 未读 / 新版本 | `Colors.red` 8×8 圆点、`fiber_new_outlined` 红色图标 | 首页、服务商信息页 |
| 选中行 | `kColorBlue` 文字色 | 配置列表、代理组选择、语言列表 |
| 提示文字 | `Colors.green` | 内核设置顶部提示条 |
| 删除 / 错误 | `Colors.red` | 列表删除、错误 dialog 正文 |

> ⚠️ **已知缺陷（必须修）**：延迟中间档用 `Colors.black`，在深色主题下**完全不可见**
> （`proxy_board_screen_widgets.dart:83,243`、`proxygroup_select_screen.dart:204`、
> `profile_settings_edit_screen.dart:531`）。
> **Mclash 修正为** `colorScheme.onSurfaceVariant`（深色 `#C7C5D0` / 浅色 `#46464F`）。
> 修正理由记入 ADR-016。

### 3.1.5 登录页专属渐变（唯一允许的渐变）

```dart
const primaryPurple = Color(0xFF7B5FF5);
LinearGradient(colors: [Colors.blue, primaryPurple])   // 蓝 → 紫
```
| 属性 | 值 |
|---|---|
| 圆角 | **14** |
| 高度 | 48 |
| 使用位置 | `login_screen.dart` · `login_step_account_screen.dart` · `login_step_provider_screen.dart`（3 处，仅这 3 处） |

---

## 3.2 字体与排版

### 3.2.1 字族（**不设全局 fontFamily**）

| 场景 | 字族 |
|---|---|
| 默认（所有平台） | `Typography.blackCupertino` 派生：标题 `CupertinoSystemDisplay`，正文 `CupertinoSystemText` |
| 实际渲染 | iOS/macOS `SF Pro`；Android `Roboto`；Windows `Segoe UI` |
| Windows emoji 回退 | `fontFamily: Platform.isWindows ? 'Emoji' : null`（9 处：首页代理副标题、配置编辑、代理页 6 处、代理组 2 处） |
| 全局禁用字号缩放 | 设置项 `disableFontScaling`（重启生效）→ `MediaQuery(textScaler: TextScaler.noScaling)` |

> ⚠️ **关键事实**：`Typography.blackCupertino` **只提供颜色与 fontFamily，不提供任何 `fontSize` / `fontWeight` /
> `letterSpacing` / `height`（全部为 `null`）**。
> 因此**所有字号都必须显式指定**，否则落到引擎默认（约 14 逻辑像素）。

### 3.2.2 字号令牌（`ThemeConfig`，源码逐值）

```dart
class ThemeConfig {
  static const double kListItemHeight = 62;
  static const double kListItemHeight2 = 50;
  static const double kGroupItemHeight = 46;

  static const double kFontSizeTitle = 18;
  static const FontWeight kFontWeightTitle = FontWeight.w600;

  static const double kFontSizeListItem = 17;
  static const FontWeight kFontWeightListItem = FontWeight.w500;

  static const double kFontSizeListSubItem = 14;
  static const FontWeight kFontWeightListSubItem = FontWeight.w400;

  static double kFontSizeGroupItem = (Platform.isAndroid || Platform.isIOS) ? 15 : 14;
  static const FontWeight kFontWeightGroupItem = FontWeight.w400;
}
```

| 令牌 | 字号 / 字重 | 使用次数 | 用途 |
|---|---|---|---|
| `kFontSizeTitle` | **18 / w600** | 42 | **每个页面的顶部标题**（居中） |
| `kFontSizeListItem` | **17 / w500** | 4 | 分组名（设置页的组标题） |
| `kFontSizeGroupItem` | **15**（移动）/ **14**（桌面）/ w400 | 13 | 设置行文字、代理组行、节点行、语言行 |
| `kFontSizeListSubItem` | **14 / w400** | 16 | **所有 dialog 正文**、首页流量文字 |
| 字面量 `12` | 12 / — | 19 | 副标题元信息（配置名、流量、到期、错误） |
| 字面量 `16` / `15` / `14` | — | 5 | 零散（网络检测小节标题 15/w600 等） |
| `delayTesting > 999 ? 8 : 10` | 8/10 | 1 | 批量测速时进度环中间的数字 |

**字重全项目只有 5 种写法**：`w700` ×5、`w600` ×5、`w500` ×5、`w400` ×2，其余继承默认。

### 3.2.3 排版规则

| 规则 | 说明 |
|---|---|
| 页面标题**永远居中** | `Text(textAlign: TextAlign.center, overflow: TextOverflow.ellipsis)` |
| 长文本**永远单行省略** | 配置名、节点名、代理链、组名 |
| 无 letter-spacing / 无行高覆盖 | M3 默认 |
| 数字**不特殊处理** | 不用等宽字体；延迟/流量用普通字体 |
| 不设富文本标题层级 | 全 App 无 `headline*` / `title*` 风格的显式使用 |

---

## 3.3 间距 / 圆角 / 高度 / 阴影

### 3.3.1 页面骨架（**30+ 页面完全相同**）

```dart
Scaffold(
  appBar: PreferredSize(preferredSize: Size.zero, child: AppBar(...)),
  body: SafeArea(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),   // ← 39 次
      child: Column(children: [
        /* 顶部栏 Row */
        const SizedBox(height: 10),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 15, 20, 0),  // ← 23 次
            child: /* 内容 */
          ),
        ),
      ]),
    ),
  ),
)
```

### 3.3.2 间距常量（按出现频次）

| 值 | 次数 | 角色 |
|---|---|---|
| `EdgeInsets.fromLTRB(0, 20, 0, 0)` | **39** | 页面顶部偏移（状态栏之下） |
| `EdgeInsets.fromLTRB(20, 0, 20, 0)` | **24** | 卡片 / 弹层内部左右 20 |
| `EdgeInsets.fromLTRB(20, 15, 20, 0)` | **23** | 内容区 |
| `EdgeInsets.symmetric(horizontal: 10)` | 12 | 列表行内部 |
| `EdgeInsets.only(bottom: 2)` | 11 | 可重排列表行间距 |
| `EdgeInsets.fromLTRB(5, 0, 5, 0)` | 8 | dialog 字段间隔 |
| `EdgeInsets.all(8)` | 2 | `InputDecoration.contentPadding` |
| `SizedBox(height: 10)` | — | 顶部栏与内容之间 |
| `SizedBox(height: 15)` | — | 两张 Card 之间（首页） |
| `SizedBox(width: 5)` | — | 行内图标与文字 |
| `SizedBox(width: 12)` | — | 加载指示器两侧 |
| `SizedBox(height: 400)` | 10 | **弹层 body 的固定高度** |

> **没有 8/12/16/24 的设计栅格体系**。只有 `20`（页边距/卡内边距）、`15`、`10`、`5` 四个数字。

### 3.3.3 圆角令牌

| 值 | 用于 | 来源 |
|---|---|---|
| **0** | 列表行 `Material(borderRadius:)`、搜索框容器、可重排行 | `ThemeDefine.kBorderRadius`（×15） |
| **4** | 输入框四边 | `InputDecorationTheme` |
| **10** | 扫码取景框 | `QrScannerOverlayShape`（已随二维码工具一并移除） |
| **12** | **卡片** | M3 `_CardDefaultsM3` 隐式 |
| **14** | **登录页渐变按钮** | 3 处 |
| **25** | 模式分段控件轨道 | `SegmentedElevatedButton` |
| **28** | **对话框** + 模态底部弹层顶部 | M3 隐式 |
| **35** | **ElevatedButton（胶囊）** | `elevatedButtonTheme.shape` |

### 3.3.4 高度令牌

| 值 | 用途 |
|---|---|
| `kListItemHeight = 62` | 标准列表行 |
| `kListItemHeight2 = 50` | 紧凑列表行（代理组模板行实际用 `-2` = **48**） |
| `kGroupItemHeight = 46` | **设置行默认高度**（`GroupItemOptions.itemHeight`） |
| **70** | 首页模式分段控件容器（含上下 15 内边距） |
| **66** | 代理节点列表行 |
| **44** | 搜索框 |
| **48** | 登录渐变按钮 |
| **400** | 弹层 body |

### 3.3.5 阴影 / 层次（**全部走 M3 默认，不自定义任何 shadow**）

| 元件 | elevation | shape |
|---|---|---|
| Card | **1.0** | `RoundedRectangleBorder(r12)`，`margin: EdgeInsets.all(4)` |
| 模态底部弹层 | **1.0** | 顶部 `RoundedRectangleBorder(top r28)` |
| Dialog (`SimpleDialog`) | **6.0** | `RoundedRectangleBorder(r28)` |
| AppBar | **0**（且高度为 0） | — |

**全项目从不显式指定 `BoxShadow`。**

---

## 3.4 组件规范

> 全 App 只有 **4 类容器元件**。任何新页面都必须由这 4 类拼出。

### 3.4.1 Card（区块容器）

```dart
Card(                                    // color: theme.cardTheme.color; elevation 1; margin all(4); r12
  child: Padding(
    padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
    child: ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (_, i) => widgets[i],
      separatorBuilder: (_, __) => const Divider(height: 1, thickness: 0.3),  // ← 全 App 唯一分隔线
      itemCount: widgets.length,
    ),
  ),
)
```

| 属性 | 值 |
|---|---|
| 颜色 | 深色 `#FF303030` / 浅色 `#FFFFFFFF` |
| elevation | 1.0 |
| 圆角 | 12 |
| margin | `EdgeInsets.all(4)` |
| 内边距 | `fromLTRB(20, 0, 20, 0)` |
| 有效左右留白 | 页面 `fromLTRB(...,20,...)` + `margin 4` ≈ 视觉 24 |

### 3.4.2 Divider（**全 App 唯一分隔线形式**）

```dart
const Divider(height: 1, thickness: 0.3)
```
共 **24 处**，全部一模一样。颜色走 M3 `dividerTheme` 默认 = `colorScheme.outlineVariant`。

### 3.4.3 ListTile（列表行）

| 变体 | 规格 |
|---|---|
| **首页设置行** | `title` + `leading: Icon(size: 20)` + `trailing: Icon(Icons.keyboard_arrow_right, size: 20)` + `minVerticalPadding: 22` |
| **首页"我的配置"行** | `title` + `subtitle`（多行 12px）+ `trailing: SizedBox(width: 100, child: Row([服务商图标 40×40 ×可选, 「+」按钮 40×40, chevron 20]))` + `minVerticalPadding: 20` |
| **节点选择行** | `selected:` + `selectedColor: kColorBlue` |
| **代理组行** | `title`（Row：可选 16×16 图标 + 名称）、`subtitle`（类型 + 延迟）、`trailing`（当前节点名 + chevron 20）、`minVerticalPadding: 10` |
| **弹层行** | 纯 `ListTile`，`leading` 图标 24（默认尺寸） |
| 全局 | `listTileTheme: ListTileThemeData(dense: true)` |
| leading/trailing 图标 | **20**（首页、代理页）；**24**（弹层）；**30**（`add` / `cloud_download_outlined`） |

### 3.4.4 顶部栏（**不是 AppBar，是手写 Row**）

```dart
Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
  // 左：返回
  InkWell(
    onTap: () => Navigator.pop(context),
    child: const SizedBox(width: 50, height: 30,
      child: Icon(Icons.arrow_back_ios_outlined, size: 26)),
  ),
  // 中：标题
  SizedBox(
    width: windowSize.width - 50 * 2,       // 有右侧动作时 50*3
    child: Text(title, textAlign: TextAlign.center, overflow: TextOverflow.ellipsis,
      style: const TextStyle(fontWeight: ThemeConfig.kFontWeightTitle,
                             fontSize: ThemeConfig.kFontSizeTitle)),
  ),
  // 右：动作（50×30 命区，图标 size 26）
  InkWell(onTap: ..., child: const SizedBox(width: 50, height: 30,
    child: Icon(Icons.done_outlined, size: 26))),
])
```

| 属性 | 值 |
|---|---|
| 命中区 | **`SizedBox(width: 50, height: 30)`** |
| 图标尺寸 | **26**（全项目 90 处用 26） |
| 返回图标 | `Icons.arrow_back_ios_outlined`（38 处） |
| 标题 | 18 / w600 / 居中 / 单行省略 |
| 左侧占位（无返回时） | `const SizedBox(width: 50)` |
| 右侧占位（无动作时） | `const SizedBox(width: 50)`，或 `Tooltip` + `Icon(Icons.info_outlined, size: 20)` |
| 右侧加载态 | `Row([SizedBox(width:12), SizedBox(26×26, CircularProgressIndicator()), SizedBox(width:12)])` |

### 3.4.5 ElevatedButton（**胶囊**）

| 状态 | 背景 | 文字 |
|---|---|---|
| 默认 | `Colors.blue` `#FF2196F3` | 深色→`Colors.black`；浅色→`Colors.white` |
| focused | `Colors.blue[800]` `#FF1565C0` | 同上 |
| selected | `Colors.blue[200]` `#FF90CAF9` | 同上 |
| 形状 | `RoundedRectangleBorder(borderRadius: BorderRadius.circular(35))` | — |
| padding / minimumSize | **未设置**（走 M3 默认），调用方用 `SizedBox(height: 45/48)` 或 `styleFrom(padding: EdgeInsets.zero)` 控制 |

| 使用场景 | 尺寸 |
|---|---|
| Dialog 按钮（确定 / 取消 / 拷贝 / FAQ） | 默认，居中 `Row` + `SizedBox(width: 20 或 60)` 间隔 |
| 网络检测「检测」按钮 | 全宽，`SizedBox(width: 18, height: 18, CircularProgressIndicator(strokeWidth: 2))` 替代文字 |
| 登录 / 注册按钮 | 渐变 + **r14** + 高 48（**唯一不用 35 胶囊的按钮**） |
| 启动失败页 | `ElevatedButton.icon(icon: Icon(Icons.webhook_rounded), label: 官网)` + `ElevatedButton(退出)` |

### 3.4.6 SegmentedElevatedButton（模式分段控件）

```dart
Container(
  width: constraints.maxWidth - 40,
  decoration: BoxDecoration(
    color: background ?? theme.colorScheme.surface,
    borderRadius: BorderRadius.all(Radius.circular(25)),
  ),
  child: Padding(
    padding: padding ?? const EdgeInsets.fromLTRB(0, 3, 0, 3),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [...]),
  ),
)
// 每段：
SizedBox(
  width: (constraints.maxWidth - (n + 1) * 5) / n,
  child: ElevatedButton(
    style: ButtonStyle(
      backgroundColor: /* focused|selected → Colors.white; else Colors.white@30% */,
      shadowColor: Colors.white@0%,
    ),
    child: FittedBox(fit: BoxFit.fill, child: Text(text,
      style: TextStyle(color: selected == i ? ThemeDefine.kColorBlue : Colors.black))),
  ),
)
```

| 属性 | 值 |
|---|---|
| 轨道圆角 | **25** |
| 段间距 | **5**（`space = 5`，共 `(n+1)*5` 的扣除量） |
| 段背景（选中） | `Colors.white` |
| 段背景（未选中） | `Colors.white @ 30%` |
| 段文字（选中） | `kColorBlue` `#FF2196F3` |
| 段文字（未选中） | `Colors.black` |
| 段形状 | 继承 theme 的 **r35 胶囊** |
| 首页用法 | 高 **70**，`padding: fromLTRB(0, 3, 0, 3)`，4 段：**规则 / 全局 / 直连 / 拦截** |

> ⚠️ **已知缺陷（必须修）**：浅色主题下轨道是 `#F0F0F0`、段是纯白胶囊、未选中文字是 `Colors.black` ——
> 但选中段 `Colors.white` 与浅色卡片同色，**未选中段 30% 白在浅底上几乎不可见**。
> **Mclash 修正**：轨道改 `colorScheme.surfaceContainerHighest`，未选中段改 `Colors.transparent`，
> 未选中文字改 `colorScheme.onSurfaceVariant`。记入 ADR-016。

### 3.4.7 Switch（**全 App 开关**）

```dart
SizedBox(
  width: 60,
  child: FittedBox(fit: BoxFit.fill, child: Switch.adaptive(
    value: ...,
    activeThumbColor: Colors.white,
    activeTrackColor: ThemeDefine.kColorGreenBright,   // #FF08C70F
    onChanged: ...,
  )),
)
```

| 属性 | 值 |
|---|---|
| 外框 | **`SizedBox(width: 60)` 强制宽度**（因 iOS 几何轨道为 51×31，需放大） |
| 轨道（开） | `#FF08C70F` 亮绿 |
| 滑块 | `Colors.white` |
| 轨道（关） | M3 默认灰 |
| 滑块阴影 | `0x26000000 / offset(0,3) / blur 8` + `0x0F000000 / offset(0,3) / blur 1`（iOS 几何自带） |

### 3.4.8 Checkbox

| 属性 | 值 |
|---|---|
| `fillColor` | 深色 `#FF303030` / 浅色 `#FFFFFFFF`（= 卡片色） |
| `checkColor` | `#FF08C70F` |
| `overlayColor` | `Colors.grey` |
| 使用 | 仅「分应用代理」与「代理节点多选」 |
| 三态 | `Checkbox(tristate: true, ...)`（节点多选） |

### 3.4.9 输入框

```dart
InputDecorationTheme(
  fillColor: mainBgColor.withValues(alpha: 0.5),   // 深 #121212@50% / 浅 #F0F0F0@50%
  filled: true,
  labelStyle: TextStyle(color: Colors.grey),
  floatingLabelStyle: TextStyle(color: ThemeDefine.kColorBlue),
  helperStyle: TextStyle(color: Colors.grey),
  hintStyle: TextStyle(color: Colors.grey),
  errorStyle: TextStyle(color: Colors.red),
  isDense: true,
  contentPadding: EdgeInsets.all(8),
  border: OutlineInputBorder(borderSide: BorderSide(color: ThemeDefine.kColorBlue),
                             borderRadius: BorderRadius.all(Radius.circular(4))),
  focusedBorder: /* 同上 */,
)
```

| 属性 | 值 |
|---|---|
| 圆角 | **4** |
| 填充 | 页面底 @ 50% |
| 边框（默认 & 聚焦） | `kColorBlue` 1px |
| 浮动标签 | `kColorBlue` |
| hint / label / helper | `Colors.grey` |
| error | `Colors.red` |
| 内边距 | `EdgeInsets.all(8)`，`isDense: true` |
| 右侧对齐（设置行内） | `textAlign: TextAlign.right` + `border: InputBorder.none` |

> ⚠️ **已知缺陷（必须修）**：只定义了 `border` / `focusedBorder`，
> `enabledBorder` / `errorBorder` / `disabledBorder` 落到 M3 默认（`outlineVariant` / `error`），
> 导致填充态输入框在**未聚焦**时外观与聚焦态不一致。
> **Mclash 修正**：补齐 5 个 border 状态。记入 ADR-016。

### 3.4.10 底部弹层（`showSheet`）—— 全 App 唯一弹层形式

```dart
Future<T?> showSheet<T>({
  required BuildContext context,
  required Widget body,
  bool isScrollControlled = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    builder: (context) => SafeArea(child: body),
    showDragHandle: true,
    useSafeArea: true,
  );
}

// 标准 body
Widget showSheetWidgets({ required List<Widget> widgets }) => SizedBox(
  height: 400,                                    // ← 11 处调用中 10 处用 400
  child: Padding(
    padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
    child: Scrollbar(
      child: ListView.separated(
        separatorBuilder: (_, __) => const Divider(height: 1, thickness: 0.3),
        ...),
    ),
  ),
);
```

| 属性 | 值 |
|---|---|
| 圆角 | 顶部 **28**（M3 默认） |
| 拖拽手柄 | `showDragHandle: true` |
| 背景 | 深 `#FF1B1B21`（M3 `surfaceContainerLow`）/ 浅 `Colors.white` |
| elevation | 1.0 |
| 高度 | **400**（固定） |
| 行内容 | 纯 `ListTile` |
| 调用点 | 11 处（节点选择、配置详情、更多操作、选择器、文本编辑…） |

### 3.4.11 Dialog（`DialogUtils`，**全 App 无 SnackBar**）

所有提示都是 `SimpleDialog(barrierDismissible: false)`：

```dart
SimpleDialog(
  title: Text(tcontext.meta.tips,                       // "提示"
    style: TextStyle(fontSize: ThemeConfig.kFontSizeListSubItem)),   // 14
  children: [
    Padding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Text(text, maxLines: 20, style: TextStyle(fontSize: 14))),
    const SizedBox(height: 20),
    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      ElevatedButton(child: Text(cancel)),
      SizedBox(width: showCopy ? 20 : 60),
      ElevatedButton(child: Text(ok)),
    ]),
    const SizedBox(height: 20),
    if (showFAQ) Padding(padding: fromLTRB(20,0,20,0),
      child: ElevatedButton(child: Text("常见问题"))),   // 全宽
  ],
)
```

| 方法 | 用途 |
|---|---|
| `showAlertDialog(text, {showCopy, showFAQ, withVersion})` | 通用提示；正文**硬截断 1024 字**；`withVersion` 前置 `"<版本> <系统>\n\n"` |
| `showConfirmDialog(text, {showCopy, withVersion})` | 确认（取消 / 确定居中） |
| `showTextInputDialog(...)` | 单行文本输入 |
| `showIntInputDialog` / `showIntRangeInputDialog` / `showTextIntRangeInputDialog` | 数字 / 数字区间 |
| `showTimeIntervalPickerDialog` | 时间间隔（天/时/分/秒/毫秒 + 禁用） |
| `showStringPickerDialog` | 下拉选择 |
| `showLoadingDialog({text})` | 加载中（`PopScope(canPop: false)` + 环形 + "加载中…"） |
| `showPasswordInputDialog` | sudo 密码（TUN 模式） |

| 属性 | 值 |
|---|---|
| 形状 | r28 |
| elevation | 6.0 |
| `barrierDismissible` | **false**（必须点按钮） |
| 标题 | "提示" 14px |
| 正文 | 14px，`maxLines: 20` |
| 按钮 | `ElevatedButton`（胶囊 35），居中 |
| 按钮间隔 | 拷贝按钮存在时 20，否则 60 |
| 底部 | `SizedBox(height: 20)` |
| FAQ 按钮 | 全宽 `ElevatedButton`（Android 8.1 上静默隐藏） |

### 3.4.12 进度指示器

```dart
progressIndicatorTheme: ProgressIndicatorThemeData(strokeWidth: 2)
```
| 尺寸 | 位置 |
|---|---|
| 25×25 | 首页连接开关旁（`color: kColorGreenBright`） |
| 26×26 | 顶部栏右侧加载 + 批量测速（中间叠数字 8/10px） |
| 20×20 | 配置行右侧的更新中 |
| 18×18 | 按钮内（`strokeWidth: 2`） |
| 16×16 | 代理行内单节点测速 |

### 3.4.13 图标规范

| 尺寸 | 次数 | 用途 |
|---|---|---|
| **26** | **90** | **顶部栏动作图标（默认尺寸）** |
| 20 | 19 | ListTile 的 leading / trailing、`keyboard_arrow_right` |
| 30 | 7 | `add`、`cloud_download_outlined`、`contact_support_outlined` |
| 24 | — | 弹层 ListTile leading（默认）、首页底部 3 个入口 |
| 32 | 2 | 服务商图标回退 `Icons.business` |
| 16 | 3 | 节点前置小图标（`node.icon`）、收藏 |
| 14 | — | `arrow_forward_ios_rounded`（设置行右侧 chevron） |

**两套 chevron 并存（**这是刻意的**）**：

| 场景 | 图标 | 尺寸 |
|---|---|---|
| 首页 / 一般页面行 | `Icons.keyboard_arrow_right` | 20 |
| 设置页（`GroupItemPush`） | `Icons.arrow_forward_ios_rounded` | 14 |

**图标风格**：绝大多数是 **`_outlined` 变体**（38 处 `arrow_back_ios_outlined` 为最多）。
实心例外：`Icons.done`（12 处）、`add`、`settings`、`sort`、`copy`、`search`、`cut`、`paste`、`refresh`、`help`、`info`、`person`、`lock`、`visibility(_off)`、`business`、`set_meal`、`file_present`。

### 3.4.14 状态点（8×8 圆）

```dart
Container(width: 8, height: 8, decoration: BoxDecoration(color: c, shape: BoxShape.circle))
```
| 颜色 | 含义 |
|---|---|
| `Colors.green` | 已连接 |
| `Colors.grey` | 未连接 |
| `Colors.red` | 未读 / 有新版本 / 需注意的设置项（`GroupItemSwitchOptions.reddot`） |

### 3.4.15 底部导航 / 左侧导航（🆕 **Mclash 新增，按 Clash Mi 视觉语言制造**）

> Clash Mi **没有任何一级导航**（`BottomNavigationBar` / `NavigationBar` / `NavigationRail` /
> `Drawer` / `TabBar` 全部零出现）。Mclash 需要 4 个 Tab，因此**按 Clash Mi 的语言新造**，
> 而**不是**套用 M3 默认 `NavigationBar`。

**为什么不用 M3 `NavigationBar`**

| M3 `NavigationBar` 默认 | Mclash 导航（Clash Mi 风格） |
|---|---|
| 高 80 | **高 56**（+ 安全区） |
| 选中项 `secondaryContainer` 胶囊指示器 | **无指示器**（方角风格不配胶囊） |
| 背景 `surfaceContainer` | 背景 `colorScheme.surface`（与页面同底） |
| 无顶边 | **`Divider(height: 1, thickness: 0.3)`**（全 App 唯一分隔线形式） |
| label 带 letterSpacing | 无 letterSpacing |
| 选中色 `onSecondaryContainer` | 选中 **`ThemeDefine.kColorBlue` `#FF2196F3`** |
| 有水波纹扩散的胶囊高亮 | 仅整格 `InkRipple` |

```dart
// 底部导航（< 840px）
Container(
  decoration: BoxDecoration(color: theme.colorScheme.surface),
  child: SafeArea(
    top: false,
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Divider(height: 1, thickness: 0.3),          // ← 全 App 唯一分隔线
      SizedBox(
        height: 56,
        child: Row(children: [
          for (final e in _mainNavEntries)
            Expanded(
              child: InkWell(
                onTap: () => setTab(e.index),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(clipBehavior: Clip.none, children: [
                      Icon(e.index == _index ? e.activeIcon : e.icon,
                        size: 24,
                        color: e.index == _index
                          ? ThemeDefine.kColorBlue
                          : theme.colorScheme.onSurfaceVariant),
                      if (e.badge && hasUnread)
                        Positioned(top: 2, right: -2,
                          child: Container(width: 8, height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.red, shape: BoxShape.circle))),
                    ]),
                    const SizedBox(height: 3),
                    Text(AppStrings.t(e.labelKey),
                      style: TextStyle(fontSize: 12,
                        color: e.index == _index
                          ? ThemeDefine.kColorBlue
                          : theme.colorScheme.onSurfaceVariant)),
                  ]),
                ),
              ),
            ),
        ]),
      ),
    ]),
  ),
)
```

| 属性 | 值 |
|---|---|
| 高度 | **56**（+ `SafeArea(top: false)`） |
| 背景 | `colorScheme.surface`（深 `#121212` / 浅 `#F0F0F0`） |
| 顶边 | `const Divider(height: 1, thickness: 0.3)` |
| 图标 | **24** |
| label | **12** |
| 图标与 label 间距 | `SizedBox(height: 3)` |
| 选中色 | `#FF2196F3` |
| 未选中色 | `colorScheme.onSurfaceVariant`（深 `#C7C5D0` / 浅 `#46464F`） |
| 指示器 | **无** |
| badge | 8×8 `Colors.red`，`Positioned(top: 2, right: -2)` |
| 切换动画 | **无自定义动画**（颜色瞬时切换，符合 3.6 纪律） |
| 每格 | `Expanded` + `InkWell`，整格整高可点 |

**左侧导航（≥ 840px，桌面）**

| 属性 | 值 |
|---|---|
| 宽度 | **88** |
| 背景 | `colorScheme.surface` |
| 右分隔 | `VerticalDivider(width: 1, thickness: 0.3)` |
| 图标 | **26**（桌面用 26，与顶部栏动作图标一致） |
| label | **12** |
| 每项高度 | **56**，垂直居中排列 |
| 其余 | 同底部导航（无指示器、同选中色、同 badge） |

> **两套导航共用同一份 `_mainNavEntries` 定义**（index / icon / activeIcon / labelKey / badge），
> 切换宽度时不重建页面状态（每 Tab 一个保活的 `Navigator`）。

### 3.4.16 网络检测卡片（唯一的"自有"卡片样式）

```dart
Card(child: Padding(padding: const EdgeInsets.all(12), child: Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
    if (content.isNotEmpty) ...[
      const SizedBox(height: 8),
      SelectableText(content),      // ← 可选中复制
    ],
  ])))
```

---

## 3.5 设置页渲染引擎（`GroupScreen` + `GroupItem*`）

> Mclash **保留这套引擎**，它是 Clash Mi 能用 3000 行声明式代码撑起 22 个设置页的根本原因。

### 3.5.1 数据流

```
GroupHelper.showAppSettings(context)
      ↓ 返回 Future<List<GroupItem>>  ← 声明式，纯数据
GroupScreen(title, getGroupOptions, onDone?, tipsIfNoOnDone?)
      ↓ 构建
GroupItemCreator.createGroups(context, data)
      ↓ 每组一张 Card，每项一个 SizedBox(height: itemHeight)
GroupItemWidgets.{Text|TextField|Switch|Push|TimerIntervalPicker|StringPicker}
```

### 3.5.2 组与项

| 概念 | 规格 |
|---|---|
| `GroupItem` | 有 `name` 的 → 渲染为组标题（`17 / w500`）；无 `name` 的 → 直接渲染项 |
| `GroupItemOptions.itemHeight` | 默认 **46** |
| 组标题外的每一项 | 包在 `SizedBox(height: itemHeight)` 中 |
| 组与组之间 | `SizedBox` + 再次 `Card` |

### 3.5.3 六种行类型

| 类型 | 外观 | 使用量（应用设置） |
|---|---|---|
| `GroupItemText` | 左标签 / 右值，`textWidthPercent` 默认 **0.5**；值可用 `textColor` | 0 |
| `GroupItemTextField` | 右侧内联 `TextFieldEx`，`InputBorder.none`，`textAlign: right` | **6** |
| `GroupItemSwitch` | 右侧 `Switch.adaptive`（60 宽 / `#08C70F`） | **17** |
| `GroupItemPush` | 右侧 `Icons.arrow_forward_ios_rounded, size: 14` + 可选前置 icon 26 | **3** |
| `GroupItemTimerIntervalPicker` | 值带下划线，点击开时间间隔 dialog。`Expanded(flex: 8)` / `flex: 2` | 1（内核设置 TCP 保活） |
| `GroupItemStringPicker` | 右侧 `Icons.arrow_drop_down, size: 16`，点击开 BottomSheet 选择器；选中项文字 `kColorBlue` | **3** |

### 3.5.4 每个可选项都带 "yaml 键" 提示

设置项右侧有一个幽灵按钮：
```dart
Tooltip(message: options.tips,
  child: InkWell(onTap: () => DialogUtils.showAlertDialog(context, options.tips!),
    child: const Icon(Icons.info_outlined, size: 26)))
```
`tips` 内容是**原始 mihomo yaml 键**（多键用 `\n` 分隔），例如：
`"ipv6\ndns.ipv6"`、`"disable-keep-alive\nkeep-alive-idle\nkeep-alive-interval"`、`"external-controller"`。
**Mclash 保留这个"面向高级用户的自解释"设计。**

### 3.5.5 首页行 vs 设置行的勾选差异（刻意不同）

| | 首页设置卡 | 设置页（GroupScreen） |
|---|---|---|
| 右侧箭头 | `Icons.keyboard_arrow_right` **size 20** | `Icons.arrow_forward_ios_rounded` **size 14** |
| leading 图标 | **有**（`Icons.settings` size 20 等） | **无**（应用设置 34 项中只有 1 个 icon） |
| 垂直内边距 | `minVerticalPadding: 22` | 行高 46 |

---

## 3.6 动效

**全项目没有任何显式动画、没有 `AnimatedContainer`、没有自定义 `Transition`、没有 `Hero`。**
动效 100% 来自：

| 来源 | 表现 |
|---|---|
| `platform: TargetPlatform.iOS` | Cupertino 页面转场（横向滑入 + 上一页视差）；Cupertino 滚动物理（回弹） |
| M3 InkWell | 涟漪（`_InkRippleFactory`，非 InkSparkle） |
| `CircularProgressIndicator` | 旋转（`strokeWidth: 2`） |
| `Dismissible` / 无 | 无滑动删除 |
| `showModalBottomSheet` | M3 默认上滑 + 拖拽手柄 |
| `ReorderableListView` | 长按拖动 + 位移动画（代理组 / 规则 / 模板 / 配置列表） |

> **Mclash 纪律**：**不引入任何自定义动画**。要动效就改 M3 主题令牌，不要写 `AnimationController`。

---

## 3.7 无障碍

| 项 | 现状（Clash Mi） | Mclash 处理 |
|---|---|---|
| 触摸目标 | `SizedBox(50, 30)` = 高度不足 44 | 🔧 **改为 `SizedBox(50, 44)`**（视觉不变，命中区达标） |
| 对比度 | 深色卡 `#303030` + `onSurface #E4E1E9` ✅ 高对比 | 保留 |
| 延迟中间档不可见 | ⚠️ `Colors.black` on dark | 🔧 修正（ADR-016） |
| 浅色分段控件不可见 | ⚠️ 白胶囊在白底 | 🔧 修正（ADR-016） |
| 状态仅用颜色 | 状态点 + 文字（"已连接"/"未连接"）✅ 已达标 | 保留 |
| 语义标签 | 顶部栏图标无 `Semantics` | 🔧 加 `tooltip` / `Semantics(label:)` |
| 字体缩放 | 可全局禁用（设置项） | 保留，但**默认允许缩放**，验证 130% 不破版 |
| 键盘导航（桌面） | `TextFieldEx` 支持方向键遍历 | 保留并扩展为全局 Tab 遍历 |

---

## 3.8 设计令牌落地检查清单

- [ ] `lib/screens/theme_define.dart` 与 `theme_config.dart` 逐值等同 Clash Mi
- [ ] `ThemeData` 只自定义 7 个槽位（`cardTheme` / `inputDecorationTheme` / `listTileTheme` / `elevatedButtonTheme` / `checkboxTheme` / `progressIndicatorTheme` / `bottomSheetTheme(light)`），其余**全走 M3 默认**
- [ ] `platform: TargetPlatform.iOS` **必须保留**（否则默认字号、转场、开关几何全变）
- [ ] `ColorScheme.fromSeed(seedColor: Color(0xFF293CA0))` —— 不得写死派生色
- [ ] 全项目硬编码 hex ≤ **6 个**（见 3.1.1），新增必须先进本表
- [ ] `Divider` 只有一种写法：`const Divider(height: 1, thickness: 0.3)`
- [ ] 顶部栏命中区统一 `SizedBox(width: 50, height: 44)`（修正后）
- [ ] 图标尺寸只用 14 / 16 / 20 / 24 / 26 / 30 / 32
- [ ] 无自定义 `BoxShadow`、无自定义动画
- [ ] **无** `SnackBar` / `Chip` / `Slider` / `PopupMenuButton` / `TabBar` / `Drawer` / `BottomNavigationBar` / `FloatingActionButton`
- [ ] ADR-016 的三处修正（延迟中间档、浅色分段控件、输入框 border 状态）已落地
