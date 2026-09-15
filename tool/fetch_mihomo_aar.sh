#!/bin/bash
# 下载 Android 内核库 libmihomo.aar（本地开发用；CI 由 release.yml 直接下载）
#
# 来源：moneyfly004/mihomo-lib —— 官方 MetaCubeX/mihomo 源码 + gomobile bind（**无 fork**）。
# 该仓库每日 UTC 03:00 自动检测官方新稳定版并编译发布，tag 与内核版本一致。
#
# 用法: bash tool/fetch_mihomo_aar.sh [版本号，默认 1.19.31]
set -euo pipefail

VERSION="${1:-1.19.31}"
REPO="moneyfly004/mihomo-lib"
DEST="$(cd "$(dirname "$0")/.." && pwd)/packages/libclash_vpn_service/android/libs"

mkdir -p "$DEST"
if [ -s "$DEST/libmihomo.aar" ]; then
  echo "已存在: $DEST/libmihomo.aar ($(du -h "$DEST/libmihomo.aar" | cut -f1))，跳过"
  echo "如需重新下载请先删除该文件。"
  exit 0
fi

echo "下载 libmihomo.aar v$VERSION（约 180MB，请耐心等待）..."
curl -fL --retry 5 --retry-delay 3 --retry-all-errors --max-time 3600 \
  -o "$DEST/libmihomo.aar" \
  "https://github.com/$REPO/releases/download/v$VERSION/libmihomo.aar"

# 与发布仓库的 sha256 校验和对齐（下载失败/.被劫持时必须大声报错）
if curl -fsSL --max-time 60 -o /tmp/libmihomo.aar.sha256 \
    "https://github.com/$REPO/releases/download/v$VERSION/libmihomo.aar.sha256sum" 2>/dev/null; then
  EXPECT="$(awk '{print $1}' /tmp/libmihomo.aar.sha256)"
  ACTUAL="$(shasum -a 256 "$DEST/libmihomo.aar" | awk '{print $1}')"
  if [ "$EXPECT" != "$ACTUAL" ]; then
    rm -f "$DEST/libmihomo.aar"
    echo "错误: sha256 校验失败（期望 $EXPECT，实际 $ACTUAL）。已删除损坏文件。" >&2
    exit 1
  fi
  echo "✓ sha256 校验通过"
fi

ls -lh "$DEST/libmihomo.aar"
echo
echo "完成。注意：该 AAR 约 180MB，已在 .gitignore 中，**绝不入库**。"
