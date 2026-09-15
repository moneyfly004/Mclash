#!/bin/bash
# 获取桌面端 mihomo 内核二进制（Windows / macOS）
#
# 来源：MetaCubeX/mihomo 官方 release（预编译产物，无需自行编译）
# 用法: bash tool/fetch_mihomo.sh [版本号，默认 1.19.31]
#
# 落点：
#   macOS  → 已构建的 Mclash.app/Contents/MacOS/mihomo（Debug 与 Release 都放），
#            并备份一份到 build/mihomo/mihomo（可用 MCLASH_MIHOMO 指向它）
#   Windows → build/mihomo/mihomo.exe（由调用方拷到 exe 同目录）
set -euo pipefail

VERSION="${1:-1.19.31}"
BASE="https://github.com/MetaCubeX/mihomo/releases/download/v$VERSION"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

case "$(uname -s)" in
  Darwin)
    ARCH="$(uname -m)"
    case "$ARCH" in
      arm64)
        ASSET="mihomo-darwin-arm64-v$VERSION.gz"
        ;;
      x86_64)
        # ⚠️ Intel 必须用 compatible：官方标准版按 AMD64 v3(AVX2) 编译，
        #    2015 年前的老 Intel 与 Rosetta 都不支持 → 启动即崩。
        ASSET="mihomo-darwin-amd64-compatible-v$VERSION.gz"
        ;;
      *) echo "不支持的架构: $ARCH" >&2; exit 1 ;;
    esac
    echo "下载 $ASSET ..."
    curl -fL --retry 5 --retry-delay 3 --retry-all-errors --max-time 600 -o "$TMP/mihomo.gz" "$BASE/$ASSET"
    gunzip -f "$TMP/mihomo.gz"
    chmod +x "$TMP/mihomo"
    "$TMP/mihomo" -v | head -1

    for CONF in Debug Release; do
      APP="$ROOT/build/macos/Build/Products/$CONF/Mclash.app"
      if [ -d "$APP" ]; then
        mkdir -p "$APP/Contents/MacOS"
        cp "$TMP/mihomo" "$APP/Contents/MacOS/mihomo"
        chmod +x "$APP/Contents/MacOS/mihomo"
        codesign --force -s - "$APP/Contents/MacOS/mihomo" 2>/dev/null || true
        echo "已放入 $APP/Contents/MacOS/mihomo"
      fi
    done
    mkdir -p "$ROOT/build/mihomo"
    cp "$TMP/mihomo" "$ROOT/build/mihomo/mihomo"
    chmod +x "$ROOT/build/mihomo/mihomo"
    echo "备用: build/mihomo/mihomo"
    echo "  export MCLASH_MIHOMO=$ROOT/build/mihomo/mihomo"
    ;;
  MINGW*|MSYS*|CYGWIN*)
    # ⚠️ amd64 默认 compatible：标准版要求 AVX2，老 CPU 跑标准版会
    #    启动即崩（0xC0000005）。用户可在开发者选项切标准版。
    ASSET="mihomo-windows-amd64-compatible-v$VERSION.zip"
    echo "下载 $ASSET ..."
    curl -fL --retry 5 --retry-delay 3 --retry-all-errors --max-time 600 -o "$TMP/mihomo.zip" "$BASE/$ASSET"
    unzip -oq "$TMP/mihomo.zip" -d "$TMP/sb"
    EXE="$(find "$TMP/sb" -iname '*.exe' | head -1)"
    [ -n "$EXE" ] || { echo "zip 内未找到 exe" >&2; exit 1; }
    mkdir -p "$ROOT/build/mihomo"
    cp "$EXE" "$ROOT/build/mihomo/mihomo.exe"
    echo "已放入 build/mihomo/mihomo.exe"
    echo "请再拷到与 Mclash.exe 同目录：build/windows/x64/runner/Release/mihomo.exe"
    ;;
  *)
    echo "本脚本支持 macOS / Windows(MSYS)。Linux 请手动下载 $BASE/mihomo-linux-amd64-v$VERSION.gz" >&2
    exit 1
    ;;
esac
