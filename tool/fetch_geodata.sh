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
    echo "错误: $f 只有 $SIZE 字节（下限 ${MIN}），判定为残缺。" >&2
    FAIL=1
    continue
  fi

  # MaxMind DB 的魔数 `\xab\xcd\xefMaxMind.com` 位于**元数据段开头**，
  # 而元数据段本身跟在标记之后，所以标记并不在文件最后几个字节。
  # 实测：meta-rules-dat 的 country.mmdb 里标记距末尾 257 字节。
  #
  # 我第一版只 tail -c 32，于是把一个**完全合法**的 mmdb 判成非法并删掉重下 ——
  # 这是本仓库第二次因为「魔数窗口开得太窄」产生假阳性（另一次是把 mihomo
  # 规则的 no-resolve 修饰符误判成策略组名）。所以窗口放宽到 2KB，
  # 并改用精确的四字节前缀 `\xab\xcd\xef` 来避免误命中正文里的同名串。
  if [ "$f" = "country.mmdb" ]; then
    # LC_ALL=C 必须加：macOS 的 BSD grep 在 UTF-8 locale 下会把二进制字节
    # 当成非法多字节序列而直接报 "illegal byte sequence" 并返回非零 ——
    # 那又会被当成「文件不合法」。按字节匹配就绕开了 locale 这层。
    if ! tail -c 2048 "$PART" | LC_ALL=C grep -qa "$(printf '\253\315\357')MaxMind.com"; then
      echo "错误: country.mmdb 未找到 MaxMind DB 元数据标记，不是合法的 mmdb。" >&2
      FAIL=1
      continue
    fi
    echo "✓ mmdb 元数据标记检查通过"
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
