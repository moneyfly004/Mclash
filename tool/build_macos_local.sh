#!/usr/bin/env bash
# 本地 macOS 构建：flutter build → 内置 mihomo 内核 → 稳定签名（LocalDev）
#
# 为什么需要这个脚本：
#   1. `flutter build macos` 只产出 App 壳，**不带 mihomo 内核**。直接安装这种
#      产物，内核起不来、系统代理指向死端口，用户看到的是「整机断网」。
#   2. 构建阶段是 ad-hoc 签名，每次重编译 cdhash 都变，钥匙串授权随之失效
#      （「想使用钥匙串机密信息」反复弹窗）。这里统一用 LocalDev 重签。
#
# 用法：
#   bash tool/build_macos_local.sh            # 构建 + 补内核 + 签名
#   bash tool/build_macos_local.sh --install  # 再装到 /Applications
set -euo pipefail
cd "$(dirname "$0")/.."

APP="build/macos/Build/Products/Release/Mclash.app"
IDENT="${MCLASH_SIGN_IDENTITY:-LocalDev}"
KERNEL_CACHE="build/mihomo/mihomo"

flutter build macos --release

# 1) 补内核：优先用本地缓存，避免每次重新下载 56MB
if [ ! -x "$APP/Contents/MacOS/mihomo" ]; then
  if [ -x "$KERNEL_CACHE" ]; then
    echo "使用缓存内核: $KERNEL_CACHE"
    cp "$KERNEL_CACHE" "$APP/Contents/MacOS/mihomo"
    chmod +x "$APP/Contents/MacOS/mihomo"
  else
    bash tool/fetch_mihomo.sh --target macos-arm64
  fi
fi
[ -x "$APP/Contents/MacOS/mihomo" ] || { echo "错误: 内核未就位，安装后必然断网" >&2; exit 1; }

# 2) 抄内核会破坏签名封印 → 重签
if security find-identity -p codesigning 2>/dev/null | grep -q "$IDENT"; then
  codesign --force --deep --sign "$IDENT" --timestamp=none \
    --entitlements macos/Runner/Runner.entitlements "$APP"
  codesign --verify --deep --strict "$APP"
  echo "✅ 已用 $IDENT 签名"
else
  echo "⚠️ 未找到 $IDENT，保持 ad-hoc 签名（钥匙串授权会随重编译失效）"
fi

echo "产物: $APP"

if [ "${1:-}" = "--install" ]; then
  echo "安装到 /Applications …"
  pkill -x Mclash 2>/dev/null || true
  sleep 2
  rm -rf /Applications/Mclash.app
  ditto "$APP" /Applications/Mclash.app
  codesign --verify --deep --strict /Applications/Mclash.app
  echo "✅ 已安装: /Applications/Mclash.app"
fi
