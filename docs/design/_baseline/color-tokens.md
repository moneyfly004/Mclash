# MoneyFly color / design tokens (machine-extracted from `lib/theme/app_theme.dart`)

## 1. `MFTheme` — the 6 complete appearance palettes (`_mfThemes`)

| token | light | warm | gray | darkgray | darkblue | black |
|---|---|---|---|---|---|---|
| `isDark` | light | light | light | dark | dark | dark |
| `bg` | #FFF5F6FA | #FFFAF6F1 | #FFEEF0F4 | #FF1B1E24 | #FF0F1626 | #FF0A0A0C |
| `bg2` | #FFFFFFFF | #FFFFFFFF | #FFFFFFFF | #FF20232A | #FF141C2E | #FF101216 |
| `card` | #FFFFFFFF | #FFFFFFFF | #FFFFFFFF | #FF242830 | #FF182036 | #FF16181D |
| `card2` | #FFF0F2F8 | #FFF5EDE3 | #FFE8EBF0 | #FF2E333D | #FF222B44 | #FF20232A |
| `txt` | #FF1A2233 | #FF2A2118 | #FF22262E | #FFF2F4F8 | #FFF2F5FB | #FFF5F6F8 |
| `txt2` | #FF4A5568 | #FF5C5344 | #FF4B5058 | #FFB6BEC8 | #FFB4BFD2 | #FFB0B6C0 |
| `txt3` | #FF8A94A6 | #FF948A79 | #FF82868E | #FF8A929C | #FF8A97AC | #FF848A94 |
| `brand` | #FF455FE9 | #FFE8862E | #FF5B7CFA | #FF5B8DEF | #FF4E7CF6 | #FF6C7BFF |
| `brandLight` | #FF6C7BFF | #FFF0A35C | #FF7D97FB | #FF7DA6F2 | #FF729AF8 | #FF8B9BFF |
| `brandDeep` | #FF3346C4 | #FFC96E1E | #FF4560D8 | #FF4370CC | #FF3A5FD0 | #FF5560D8 |
| `line` | #FFE5E8F0 | #FFEDE4D8 | #FFDFE3EA | #FF343A45 | #FF2A3550 | #FF2A2D34 |
| `line2` | #FFD6DBE6 | #FFE0D4C4 | #FFCFD4DD | #FF3E4552 | #FF35415F | #FF363A43 |

## 2. Theme key order + label i18n keys

`mfThemeKeys = ['light', 'warm', 'gray', 'darkgray', 'darkblue', 'black']`

| key | label i18n key | isDark |
|---|---|---|
| light | appearance_light | false |
| warm | appearance_warm | false |
| gray | appearance_gray | false |
| darkgray | appearance_darkgray | true |
| darkblue | appearance_darkblue | true |
| black | appearance_black | true |

`mfThemeOf(key)` → falls back to `light` for unknown keys.
`ThemeController.mode` → `ThemeMode.dark` for darkgray/darkblue/black, else `ThemeMode.light` (no "follow system").
`_paletteFor(brightness)` → if selected appearance's isDark mismatches the requested brightness, falls back to `darkgray` (dark) / `light` (light).

## 3. Semantic colors (`MFColors` statics — identical in all appearances)

| token | dark appearances | light appearances |
|---|---|---|
| `MFColors.green` | `#2EE6A8` | `#0E9F6E` |
| `MFColors.greenDeep` | `#1FA97E` | `#0E9F6E` |
| `MFColors.red` | `#FF5A5F` | `#F04438` |
| `MFColors.amber` | `#FFB020` (const, all modes) | `#FFB020` |

## 4. Hard-coded accent colors still in use outside the palette

| hex | where | purpose |
|---|---|---|
| `#455FE9` (as `0x2E455FE9`, `0x0F455FE9`, `0x10455FE9`, `0x12455FE9`, `0x38455FE9`, `0x0AFFFFFF`) | home_page connect card / sub-info bar, package_page selected plan, profile_info card | legacy brand-blue soft-glow gradients, frozen to the `light` brand hue regardless of appearance |
| `#1E3B3A` → `#0E1716` | home_page connected power circle (RadialGradient) | connected "green core" |
| `#1B2233` → `#0E121B` | home_page disconnected power circle (RadialGradient) | idle "blue-black core" |
| `#2A3242` | app_theme `switchTheme` track (unselected) | switch off track |
| `#2A3242` | package_page USDT icon tile bg | crypto tile |
| `#07C160` | package_page WeChat tile bg | WeChat brand green |
| `#171E2E` → `#10141F` | payment_dialog container gradient | QR dialog dark surface (fixed, ignores appearance) |
| `#111111` | payment_dialog QR eye + data modules | QR contrast |
| `#FF6B6B` | log_center error lines | error log text |
| `#E0A93C` | log_center warning lines | warn log text |
| `#8FB4E8` | log_center debug lines | debug log text |
| `#2EFF5A5F` | home_page expired/disabled banner tint | error banner soft |
| `#33FFB020` | home_page device-full / no-sub banner tint | warn banner soft |

## 5. Radii / spacing / typography tokens found in the pages

| token | value | usage |
|---|---|---|
| card radius | 16 | `cardTheme`, MFEmpty?, order/device cards |
| app-theme input radius | 14 | `inputDecorationTheme` |
| `mfInput()` radius | 12 | all settings dialogs & search fields |
| primary button radius | 16 | `MFPrimaryButton` |
| MFPrimaryButton height | 54 (default), full width | all primary CTAs |
| brand glow shadow | `brand.withValues(alpha:.35)`, blur 24, offset (0,10) | MFPrimaryButton |
| setting row height | 52 | settings/kernel/geo rows |
| setting row radius | 14, icon tile 28×28 r9 | `_row()` |
| nav rail breakpoint | width ≥ 840 | MainShell |
| compact height breakpoint | height < 820 | home + all auth pages |
| number font | `kNumFont = 'Chakra Petch'` | all numeric readouts |
| global font family | `'PingFang SC'` | ThemeData |

