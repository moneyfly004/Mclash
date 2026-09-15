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
#
# ─────────────────────────────────────────────────────────────────────────
# 与 fetch_mihomo_aar.sh 同样的理由：**不能**直接下载到最终路径。
#
# 早期版本 `curl -o "$DIR/$f"` + 判据「存在且非空」，于是网络中断留下的残缺
# 文件会在下次运行时被当成「已下载」永久保留。这两个文件的残缺比 AAR 更隐蔽：
# 构建完全正常，直到用户连上之后发现分流规则为空 / GEOIP 匹配不到，
# 表现为「国内网站也走代理」这类很难归因的现象。
#
# 现在：写 .part → 校验大小和魔数 → 原子 mv；失败一律清理。
#
# 校验强度的取舍：官方 release 未提供这两个文件的 sha256 清单，
# 因此这里做「体积下限 + 文件魔数」检查，而不是假装有校验和。
#   geosite.dat  = protobuf，无固定魔数，只查体积；
#   country.mmdb = MaxMind DB，魔数在文件末尾（\xab\xcd\xefMaxMind.com），
#                  这里用体积下限 + 非空即可，逐字节校验留给上游。
# ─────────────────────────────────────────────────────────────────────────
set -euo pipefail

BASE="https://github.com/MetaCubeX/meta-rules-dat/releases/latest/download"
DIR="$(cd "$(dirname "$0")/.." && pwd)/assets/rules"
mkdir -p "$DIR"

# 体积下限（字节）：真实大小见文件头注释，取约一半作为「明显残缺」的门槛。
min_size_for() {
  case "$1" in
    geosite.dat) echo $((1500 * 1024)) ;;   # 真实约 4MB
    country.mmdb) echo $((3000 * 1024)) ;;  # 真实约 7.5MB
    *) echo $((1024)) ;;
  esac
}

FAIL=0
for f in geosite.dat country.mmdb; do
  TARGET="$DIR/$f"
  PART="$DIR/$f.part"
  trap 'rm -f "$PART"' EXIT

  MIN="$(min_size_for "$f")"
  if [ -s "$TARGET" ]; then
    SIZE=$(wc -c <"$TARGET" | tr -d ' ')
    if [ "$SIZE" -ge "$MIN" ]; then
      echo "已存在且大小合理: $TARGET ($(du -h "$TARGET" | cut -f1))，跳过"
      continue
    fi
    echo "警告: 已存在的 $TARGET 只有 $SIZE 字节（疑似残缺），重新下载。" >&2
    rm -f "$TARGET"
  fi

  echo "下载 $f ..."
  if ! curl -fL --retry 5 --retry-delay 3 --retry-all-errors --max-time 600 \
      -o "$PART" "$BASE/$f"; then
    echo "错误: $f 下载失败。" >&2
    FAIL=1
    continue
  fi

  SIZE=$(wc -c <"$PART" | tr -d ' ')
  if [ "$SIZE" -lt "$MIN" ]; then
    echo "错误: $f 只有 $SIZE 字节（下限 $MIN），判定为残缺。" >&2
    FAIL=1
    continue
  fi

  # MaxMind DB 的魔数在文件尾部；geosite.dat 是 protobuf 无魔数，跳过此项。
  if [ "$f" = "country.mmdb" ]; then
    if ! tail -c 32 "$PART" | grep -q "MaxMind.com"; then
      echo "错误: country.mmdb 尾部缺少 'MaxMind.com' 标记，不是合法的 mmdb。" >&2
      FAIL=1
      continue
    fi
    echo "✓ mmdb 魔数检查通过"
  fi

  mv -f "$PART" "$TARGET"
done

rm -f "$DIR/geosite.dat.part" "$DIR/country.mmdb.part"

ls -lh "$DIR"
echo
if [ "$FAIL" -ne 0 ]; then
  echo "有文件下载失败，见上方错误。" >&2
  exit 1
fi
echo "完成（这两个文件已在 .gitignore 中，不入库）。"
