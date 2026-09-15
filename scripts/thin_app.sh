#!/bin/bash
# 把 universal .app 裁剪为单一架构（发布 Apple 芯片版 / Intel 版用）
#
# 为什么需要它：Flutter 在 macOS 上的 release 构建**默认产出 universal**
# （arm64 + x86_64）。若直接把这个包标成 "arm64" 发布，Intel 用户装上去会
# 发现内置的 mihomo 内核是 arm64 的（或反之），表现为"连不上"。
# 因此发布 Apple 芯片 / Intel 专用包时，必须把 app 与内核**一起**裁成同一架构。
#
# 用法: scripts/thin_app.sh <arm64|x86_64> <Mclash.app 路径>
set -euo pipefail

ARCH="$1"
APP="$2"

case "$ARCH" in
  arm64|x86_64) ;;
  *) echo "错误: 架构只能是 arm64 或 x86_64（收到 '$ARCH'）" >&2; exit 1 ;;
esac

if [[ ! -d "$APP" ]]; then
  echo "错误: 找不到 $APP" >&2
  exit 1
fi

echo "裁剪 $APP → 仅保留 $ARCH"

# 递归处理所有 Mach-O（主程序 + App.framework + 各插件 dylib + 内嵌的 mihomo）
missing=0
while IFS= read -r -d '' f; do
  if file -b "$f" | grep -q 'Mach-O'; then
    archs="$(lipo -archs "$f" 2>/dev/null || echo '')"
    if echo "$archs" | grep -qw "$ARCH"; then
      if [ "$(echo "$archs" | wc -w)" -eq 1 ]; then
        continue  # 已经是单架构，跳过
      fi
      lipo -thin "$ARCH" "$f" -output "$f.thin"
      mv "$f.thin" "$f"
      chmod +x "$f" 2>/dev/null || true
    else
      echo "警告: $f 不含 $ARCH（archs: $archs）"
      missing=1
    fi
  fi
done < <(find "$APP" -type f -print0)

# 裁剪后重新 ad-hoc 签名（直接分发；正式分发请换 Developer ID 证书）
codesign --force --deep -s - "$APP"

FINAL="$(lipo -archs "$APP/Contents/MacOS/Mclash")"
echo "完成: $APP ($FINAL)"
if [ "$FINAL" != "$ARCH" ]; then
  echo "错误: 裁剪后架构为 '$FINAL'，期望 '$ARCH' —— 说明有组件缺该架构" >&2
  exit 1
fi
if [ "$missing" -eq 1 ]; then
  echo "警告: 有组件缺少 $ARCH（见上方），该包可能无法在对应架构上运行" >&2
fi
