#!/bin/bash
# 获取桌面端 mihomo 内核二进制（Windows / macOS 双架构）
#
# 来源：MetaCubeX/mihomo 官方 release（预编译产物，无需自行编译）
#
# 用法:
#   bash tool/fetch_mihomo.sh                     # 按当前系统/架构自动选择
#   bash tool/fetch_mihomo.sh --target windows    # 显式指定目标（跨平台预置）
#   bash tool/fetch_mihomo.sh --target macos-x64
#   bash tool/fetch_mihomo.sh --target macos-arm64
#   bash tool/fetch_mihomo.sh 1.19.32             # 指定版本（默认 1.19.31）
#
# 为什么要有 --target：
#   原脚本只能按 uname 判断当前平台，于是在 macOS 上**无法预置 Windows 内核**，
#   反之亦然。而「在任意一台机器上把各平台内核都拉下来核对」是常见需求：
#   本地想确认 Windows 产物是不是合法的 x86-64 PE、或想提前把内核放进
#   build/mihomo/ 供打包，都需要这个能力。
#
# 落点：
#   macOS-arm64 → 已构建的 Mclash.app/Contents/MacOS/mihomo（Debug/Release 都放）
#                 + build/mihomo/mihomo
#   macOS-x64   → build/mihomo/mihomo-x64（不与 arm64 互相覆盖）
#   Windows     → build/mihomo/mihomo.exe
set -euo pipefail

VERSION="1.19.31"
TARGET=""

while [ $# -gt 0 ]; do
  case "$1" in
    --target) TARGET="${2:-}"; shift 2 ;;
    --target=*) TARGET="${1#--target=}"; shift ;;
    -h|--help) sed -n '2,22p' "$0"; exit 0 ;;
    *) VERSION="$1"; shift ;;
  esac
done

BASE="https://github.com/MetaCubeX/mihomo/releases/download/v${VERSION}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "${TMP}"' EXIT

# 本机目标（用于决定要不要做「跑起来看版本」的验证）
HOST_TARGET=""
case "$(uname -s)" in
  Darwin)
    case "$(uname -m)" in
      arm64) HOST_TARGET="macos-arm64" ;;
      x86_64) HOST_TARGET="macos-x64" ;;
    esac ;;
  MINGW*|MSYS*|CYGWIN*) HOST_TARGET="windows" ;;
esac

if [ -z "${TARGET}" ]; then
  if [ -z "${HOST_TARGET}" ]; then
    echo "无法推断目标平台；请用 --target 显式指定（windows / macos-arm64 / macos-x64）" >&2
    exit 1
  fi
  TARGET="${HOST_TARGET}"
fi

# 两处资产选择都是踩过坑的，不要"优化"：
#   · Intel Mac 必须用 compatible：官方标准版按 AMD64 v3(AVX2) 编译，
#     2015 年前的老 Intel 与 Rosetta 都不支持 → 启动即崩。
#   · Windows amd64 同理必须 compatible：标准版要求 AVX2，老 CPU 会以
#     0xC0000005 闪退。用户可在开发者选项切标准版。
case "${TARGET}" in
  macos-arm64)
    ASSET="mihomo-darwin-arm64-v${VERSION}.gz"
    OUT="${ROOT}/build/mihomo/mihomo"
    WANT_ARCH="arm64"
    ;;
  macos-x64)
    ASSET="mihomo-darwin-amd64-compatible-v${VERSION}.gz"
    OUT="${ROOT}/build/mihomo/mihomo-x64"
    WANT_ARCH="x86_64"
    ;;
  windows)
    ASSET="mihomo-windows-amd64-compatible-v${VERSION}.zip"
    OUT="${ROOT}/build/mihomo/mihomo.exe"
    WANT_ARCH="x86-64"
    ;;
  *) echo "未知 --target: ${TARGET}" >&2; exit 1 ;;
esac

echo "目标 ${TARGET} / 版本 v${VERSION}"
echo "下载 ${ASSET} ..."
mkdir -p "${ROOT}/build/mihomo"

if [ "${TARGET}" = "windows" ]; then
  curl -fL --retry 5 --retry-delay 3 --retry-all-errors --max-time 600 \
    -o "${TMP}/mihomo.zip" "${BASE}/${ASSET}"
  # zip 完整性：截断的包会在解到一半才报错，且错误很难懂
  unzip -qq -t "${TMP}/mihomo.zip" >/dev/null || { echo "错误: zip 完整性检查未通过" >&2; exit 1; }
  unzip -oq "${TMP}/mihomo.zip" -d "${TMP}/sb"
  EXE="$(find "${TMP}/sb" -iname '*.exe' | head -1)"
  [ -n "${EXE}" ] || { echo "错误: zip 内未找到 exe" >&2; exit 1; }
  cp "${EXE}" "${OUT}"

  # 校验确实是 x86-64 的 Windows PE。
  #
  # 只看「解出一个 exe」是不够的：目录里躺一个错误架构的产物，
  # 会一路潜伏到用户机器上才闪退（正是 compatible/标准版选错时的表现）。
  # 这里直接读 PE 头判断，不依赖在 Windows 上运行：
  #   offset 0x00      : "MZ"
  #   offset 0x3C (u32): e_lfanew → "PE\0\0"
  #   PE+4        (u16): COFF machine，0x8664 = x86-64
  python3 - "${OUT}" <<'PYCHK'
import struct, sys
p = sys.argv[1]
d = open(p, 'rb').read(0x400)
if d[:2] != b'MZ':
    sys.exit("错误: 不是 PE 文件（缺少 MZ 头）")
e = struct.unpack_from('<I', d, 0x3C)[0]
if d[e:e + 4] != b'PE\0\0':
    sys.exit("错误: 不是 PE 文件（缺少 PE 签名）")
machine = struct.unpack_from('<H', d, e + 4)[0]
names = {0x8664: 'x86-64', 0x014c: 'i386', 0xAA64: 'ARM64'}
if machine != 0x8664:
    sys.exit(f"错误: 期望 x86-64 (0x8664)，实际 {names.get(machine, hex(machine))}")
print("  ✓ PE 校验通过: x86-64")
PYCHK
else
  curl -fL --retry 5 --retry-delay 3 --retry-all-errors --max-time 600 \
    -o "${TMP}/mihomo.gz" "${BASE}/${ASSET}"
  gunzip -t "${TMP}/mihomo.gz" || { echo "错误: gzip 完整性检查未通过" >&2; exit 1; }
  gunzip -f "${TMP}/mihomo.gz"
  chmod +x "${TMP}/mihomo"

  # Mach-O 架构断言：防止「要 arm64 却拿到 x86_64」这类静默错配
  GOT_ARCH="$(lipo -archs "${TMP}/mihomo" 2>/dev/null || true)"
  case "${GOT_ARCH}" in
    *"${WANT_ARCH}"*) echo "  ✓ Mach-O 架构校验通过: ${GOT_ARCH}" ;;
    *) echo "错误: 期望 ${WANT_ARCH}，实际 '${GOT_ARCH}'" >&2; exit 1 ;;
  esac

  cp "${TMP}/mihomo" "${OUT}"
  chmod +x "${OUT}"

  # 只有本机架构才跑得起来；跑一次确认版本是最强的验证
  if [ "${TARGET}" = "${HOST_TARGET}" ]; then
    "${OUT}" -v | head -1
  else
    echo "  （非本机架构，跳过执行验证）"
  fi

  # macOS 目标才需要放进已构建的 .app bundle，且**只在目标与本机架构一致时**。
  #
  # 这里修掉了一个我自己刚引入的 bug：`--target macos-x64` 在 arm64 机器上
  # 也会把 x86_64 的 mihomo 拷进 arm64 的 .app 里。后果是运行时 arm64 主程序
  # 去 spawn 一个 x86_64 子进程 —— 装了 Rosetta 才"能跑"（性能与行为都错位），
  # 没装则直接启动失败。本地 .app 只应使用与本机一致的架构；
  # 双架构发布由 CI 分两个 job 各自 thin + 放入对应内核来完成。
  if [ "${TARGET}" = "${HOST_TARGET}" ]; then
    for CONF in Debug Release; do
      APP="${ROOT}/build/macos/Build/Products/${CONF}/Mclash.app"
      if [ -d "${APP}" ]; then
        cp "${OUT}" "${APP}/Contents/MacOS/mihomo"
        chmod +x "${APP}/Contents/MacOS/mihomo"
        codesign --force -s - "${APP}/Contents/MacOS/mihomo" 2>/dev/null || true
        echo "  已放入 ${APP}/Contents/MacOS/mihomo"
      fi
    done
  else
    echo "  （目标 ${TARGET} ≠ 本机 ${HOST_TARGET}，不写入 .app bundle）"
  fi
fi

ls -lh "${OUT}"
echo
echo "备用位置: ${OUT}"
echo "  export MCLASH_MIHOMO=${OUT}"
