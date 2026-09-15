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
      echo "警告: $f 不含 ${ARCH}（archs: ${archs}）"
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
  # 这里必须**失败退出**，不能只警告。
  #
  # 实测过的场景：对一个 universal 的 .app（主程序 x86_64+arm64，但内嵌内核
  # 只有 arm64）直接裁 x86_64，脚本会产出「主程序 x86_64 + 内核 arm64」的包，
  # 并打印「该包可能无法在对应架构上运行」，**但退出码是 0**。
  # 于是 CI 会兴高采烈地把这个包发出去，Intel 用户装上后的表现是
  # 「能打开、连不上」—— 正是本脚本注释开头警告的那种故障，只是方向相反。
  # 一个已经判定自己产出坏包的脚本不应该返回成功。
  #
  # 正确做法：先放入目标架构的内核，再裁剪（CI 的 macos-x64 job 就是这么做的，
  # 它在裁剪前先 lipo -verify_arch x86_64）。顺序错了这里会直接报错拦住。
  echo "" >&2
  echo "错误: 有组件缺少 ${ARCH}（见上方警告），此包在该架构上不可用。" >&2
  echo "      发布产物不应缺架构。若内嵌内核缺架构，请先放入目标架构的内核再裁剪：" >&2
  echo "        bash tool/fetch_mihomo.sh --target macos-$([ "$ARCH" = arm64 ] && echo arm64 || echo x64)" >&2
  echo "      然后重新执行本脚本。" >&2
  exit 1
fi
