#!/bin/bash
# 本地从源码编译 libmihomo.aar（调试用）
#
# ⚠️ 正常路径不该用到本脚本：直接 `bash tool/fetch_mihomo_aar.sh` 从
#    moneyfly004/mihomo-lib 的 Release 下载预编译产物即可（秒级）。
#    只有需要改 gomobile 包装代码（mihomelib.go / tunfd_*.go）时才本地现编。
#
# 依赖：
#   - Go 1.26+（与官方 mihomo 构建工具链一致）
#   - Android NDK 27.x
#   - golang.org/x/mobile/cmd/gomobile
#
# 用法: bash tool/build_mihomo_aar.sh [mihomo版本，默认 1.19.31]
set -euo pipefail

VERSION="${1:-1.19.31}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SRC="$ROOT/android/mihomo-core"
OUT="$ROOT/packages/libclash_vpn_service/android/libs"

if [ ! -d "$SRC" ]; then
  echo "错误: 未找到 $SRC" >&2
  echo "Mclash 的内核包装源码在独立仓库 moneyfly004/mihomo-lib。" >&2
  echo "请 clone 到 android/mihomo-core/ 后再运行本脚本，或直接用 fetch_mihomo_aar.sh。" >&2
  exit 1
fi

# NDK 探测
if [ -z "${ANDROID_NDK_HOME:-}" ]; then
  if [ -n "${ANDROID_HOME:-}" ] && [ -d "$ANDROID_HOME/ndk" ]; then
    NDK="$(ls -1d "$ANDROID_HOME/ndk/"* 2>/dev/null | sort -V | tail -1)"
    [ -n "${NDK:-}" ] && export ANDROID_NDK_HOME="$NDK"
  fi
fi
if [ -z "${ANDROID_NDK_HOME:-}" ] || [ ! -d "${ANDROID_NDK_HOME:-}" ]; then
  echo "错误: 未找到 Android NDK。请设置 ANDROID_NDK_HOME。" >&2
  exit 1
fi

export PATH="$PATH:$(go env GOPATH)/bin"
command -v gomobile >/dev/null 2>&1 || go install golang.org/x/mobile/cmd/gomobile@latest
gomobile init

mkdir -p "$OUT"
echo "编译 libmihomo.aar（mihomo v$VERSION, NDK=$ANDROID_NDK_HOME）..."
(
  cd "$SRC"
  go mod download
  go get "github.com/metacubex/mihomo@v$VERSION"
  # gomobile 新版要求模块里有 tool 指令，否则直接报
  # "requires golang.org/x/mobile in the current module"
  go get -tool golang.org/x/mobile/cmd/gobind || true
  gomobile bind \
    -target=android \
    -androidapi 21 \
    -tags "with_gvisor,cmfa" \
    -javapkg top.moneyfly \
    -o "$OUT/libmihomo.aar" .
)
ls -lh "$OUT/libmihomo.aar"
