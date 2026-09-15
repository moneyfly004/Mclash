#!/bin/bash
# 下载 Android 内核库 libmihomo.aar（本地开发用；CI 由 release.yml 直接下载）
#
# 来源：moneyfly004/mihomo-lib —— 官方 MetaCubeX/mihomo 源码 + gomobile bind（**无 fork**）。
# 该仓库每日 UTC 03:00 自动检测官方新稳定版并编译发布，tag 与内核版本一致。
#
# 用法: bash tool/fetch_mihomo_aar.sh [版本号，默认 1.19.31]
#       SKIP_VERIFY=1 bash tool/fetch_mihomo_aar.sh   # 仅调试用，跳过校验
#
# ─────────────────────────────────────────────────────────────────────────
# 为什么必须「下载到临时文件 + 校验 + 原子改名」
#
# 早期版本直接 `curl -o "$DEST/libmihomo.aar"`，并且用「文件存在且非空」当
# 已完成判据。这个组合有一个很坏的失效模式：
#
#   网络中断 → 留下 55MB 的**残缺**文件（总大小 183MB）→ 下次运行看到
#   「存在且非空」直接跳过 → 构建期把残缺 AAR 当正常依赖链进去。
#
# 它不会在下载时报错（`curl -f` 对「传输中途断开」不一定非零退出），
# 而是推迟到 ndk/打包阶段炸出一堆与真实原因无关的符号缺失错误。
# 本机实测就踩到过：一个 55MB 的半截文件被静静地当成「已下载」。
#
# 所以现在的做法是：
#   1. 只往 libmihomo.aar.part 写；
#   2. 校验 sha256（发布仓库提供 .sha256sum）**并且**确认它是合法 zip（aar 即 zip）；
#   3. 全部通过才 mv 到最终路径 —— 同目录 mv 是原子的，绝不会出现半截成品；
#   4. 任何失败路径都清掉 .part（trap EXIT）。
#
# sha256 由「可选」改为**必需**：180MB 的 native 库直接链进 APK，
# 没有校验就接受等于把供应链风险留给使用者。确实需要跳过时用 SKIP_VERIFY=1，
# 但要显式写出来，并且会打印醒目警告。
# ─────────────────────────────────────────────────────────────────────────
set -euo pipefail

VERSION="${1:-1.19.31}"
REPO="moneyfly004/mihomo-lib"
DEST="$(cd "$(dirname "$0")/.." && pwd)/packages/libclash_vpn_service/android/libs"
TARGET="$DEST/libmihomo.aar"
PART="$TARGET.part"

mkdir -p "$DEST"
trap 'rm -f "$PART"' EXIT

# ── 已完成的判据：必须「够大」才算数，不能只判非空 ──────────────────────
# 阈值取 50MB：真实的 AAR 约 180MB，任何明显小于它的都视为残缺。
MIN_SIZE=$((50 * 1024 * 1024))
if [ -s "$TARGET" ]; then
  SIZE=$(wc -c <"$TARGET" | tr -d ' ')
  if [ "$SIZE" -ge "$MIN_SIZE" ]; then
    echo "已存在且大小合理: $TARGET ($(du -h "$TARGET" | cut -f1))，跳过"
    echo "如需重新下载请先删除该文件。"
    exit 0
  fi
  echo "警告: 已存在的 $TARGET 只有 $SIZE 字节（疑似残缺），删除后重新下载。" >&2
  rm -f "$TARGET"
fi

echo "下载 libmihomo.aar v$VERSION（约 180MB，请耐心等待）..."
curl -fL --retry 5 --retry-delay 3 --retry-all-errors --max-time 3600 \
  -o "$PART" \
  "https://github.com/$REPO/releases/download/v$VERSION/libmihomo.aar"

# ── 校验 1：大小 ────────────────────────────────────────────────────────
SIZE=$(wc -c <"$PART" | tr -d ' ')
if [ "$SIZE" -lt "$MIN_SIZE" ]; then
  echo "错误: 下载结果只有 $SIZE 字节，远小于预期（约 180MB），判定为残缺。" >&2
  exit 1
fi

# ── 校验 2：是不是一个合法 zip（aar 就是 zip；防截断/防 HTML 错误页） ──
MAGIC=$(head -c 2 "$PART")
if [ "$MAGIC" != "PK" ]; then
  echo "错误: 下载结果不是 zip（魔数='$MAGIC'，应为 'PK'）。" >&2
  echo "      常见原因是拿到的是 HTML 错误页或被劫持的响应。" >&2
  exit 1
fi
if command -v unzip >/dev/null 2>&1; then
  if ! unzip -qq -t "$PART" >/dev/null 2>&1; then
    echo "错误: zip 完整性检查未通过（归档已损坏/被截断）。" >&2
    exit 1
  fi
  echo "✓ zip 完整性检查通过"
fi

# ── 校验 3：sha256（必需） ──────────────────────────────────────────────
if [ "${SKIP_VERIFY:-0}" = "1" ]; then
  echo "⚠️  已按 SKIP_VERIFY=1 跳过 sha256 校验 —— 请勿用于发布构建！" >&2
else
  if ! curl -fsSL --max-time 60 -o "$PART.sha256" \
      "https://github.com/$REPO/releases/download/v$VERSION/libmihomo.aar.sha256sum"; then
    echo "错误: 无法获取 sha256sum，按策略拒绝未校验的 native 库。" >&2
    echo "      （发布仓库应提供 libmihomo.aar.sha256sum；" >&2
    echo "        仅调试时可 SKIP_VERIFY=1 强制继续。）" >&2
    exit 1
  fi
  EXPECT="$(awk '{print $1}' "$PART.sha256")"
  ACTUAL="$(shasum -a 256 "$PART" | awk '{print $1}')"
  if [ -z "$EXPECT" ] || [ "$EXPECT" != "$ACTUAL" ]; then
    echo "错误: sha256 校验失败（期望 '$EXPECT'，实际 '$ACTUAL'）。" >&2
    exit 1
  fi
  echo "✓ sha256 校验通过"
fi

# ── 全部通过才落位（同目录 mv 原子） ────────────────────────────────────
mv -f "$PART" "$TARGET"
ls -lh "$TARGET"
echo
echo "完成。注意：该 AAR 约 180MB，已在 .gitignore 中，**绝不入库**。"
