#!/bin/bash
# 下载离线分流数据到 assets/rules/（智能模式 CN 直连用）
#
# 来源：MetaCubeX/meta-rules-dat 官方 release
#   geosite.dat   约 4MB  —— GEOSITE,cn 域名分类
#   country.mmdb  约 7.5MB —— GEOIP,CN IP 国家库（mihomo 默认文件名）
#
# 为什么必须内置：raw.githubusercontent.com 在国内不可达；
# 不内置的话首次连接在弱网环境会因 geo 拉取失败导致分流规则为空。
# 发布包由 CI 自动下载（见 .github/workflows/release.yml）。
set -euo pipefail

BASE="https://github.com/MetaCubeX/meta-rules-dat/releases/latest/download"
DIR="$(cd "$(dirname "$0")/.." && pwd)/assets/rules"
mkdir -p "$DIR"

for f in geosite.dat country.mmdb; do
  if [ -s "$DIR/$f" ]; then
    echo "已存在: $DIR/$f ($(du -h "$DIR/$f" | cut -f1))，跳过"
    continue
  fi
  echo "下载 $f ..."
  curl -fL --retry 5 --retry-delay 3 --retry-all-errors --max-time 600 -o "$DIR/$f" "$BASE/$f"
done
ls -lh "$DIR"
echo
echo "完成（这两个文件已在 .gitignore 中，不入库）。"
