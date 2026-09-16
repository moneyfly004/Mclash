#!/usr/bin/env bash
#
# Mclash 彻底卸载（macOS）。
#
# 为什么需要它：macOS 上「把 Mclash.app 拖进废纸篓」**不会**删掉应用数据
# （`~/Library/Application Support/top.moneyfly.mclash`：登录会话、订阅配置档、
# 设置、缓存、日志都在里面）。于是用户"卸载"后重装新版本，App 直接读回上次的
# 登录会话 —— 用户看到的正是「卸载没卸干净，装完还是上次的账号」。
#
# 这个脚本做四件事：
#   1. 退出 App / 停掉残留内核（否则删不干净）；
#   2. 还原系统代理（只还原**指向本机回环**的那一项，不动用户自己的代理设置）；
#   3. 删除开机自启的 LaunchAgent；
#   4. 删除 App 本体与数据目录。
#
# 用法：
#   bash tool/uninstall_macos.sh                 # 交互确认后卸载
#   bash tool/uninstall_macos.sh --yes           # 不确认（脚本化）
#   bash tool/uninstall_macos.sh --keep-data     # 只删 App，保留账号/订阅数据
#   MCLASH_APP=/Applications/Mclash.app bash tool/uninstall_macos.sh
#
set -euo pipefail

APP_PATH="${MCLASH_APP:-/Applications/Mclash.app}"
DATA_DIR="${MCLASH_DATA_DIR:-$HOME/Library/Application Support/top.moneyfly.mclash}"
BUNDLE_ID="top.moneyfly.mclash"
AGENT_PLIST="$HOME/Library/LaunchAgents/$BUNDLE_ID.plist"
ASSUME_YES=0
KEEP_DATA=0

for arg in "$@"; do
  case "$arg" in
    --yes|-y) ASSUME_YES=1 ;;
    --keep-data) KEEP_DATA=1 ;;
    -h|--help) sed -n '2,30p' "$0"; exit 0 ;;
    *) echo "未知参数: $arg" >&2; exit 2 ;;
  esac
done

say() { printf '%s\n' "$*"; }

say "将卸载 Mclash："
say "  App:      $APP_PATH"
if [ "$KEEP_DATA" = "1" ]; then
  say "  数据:     保留（--keep-data）"
else
  say "  数据目录: $DATA_DIR   ← 会被删除（登录会话 / 订阅 / 设置 / 缓存 / 日志）"
fi

if [ "$ASSUME_YES" != "1" ]; then
  read -r -p "继续？(y/N) " ans
  case "$ans" in
    y|Y|yes|YES) ;;
    *) say "已取消。"; exit 0 ;;
  esac
fi

# ① 退出 App 与残留内核
say "→ 停止 App 与内核…"
osascript -e 'tell application "Mclash" to quit' >/dev/null 2>&1 || true
pkill -x mclash >/dev/null 2>&1 || true
sleep 1
pkill -f "Mclash.app/Contents/MacOS/mihomo" >/dev/null 2>&1 || true
pkill -f "mclash/mihomo" >/dev/null 2>&1 || true
sleep 1

# ② 还原系统代理：**只**处理指向本机回环的代理，避免误删用户自己的代理
say "→ 还原系统代理（仅本机回环项）…"
# MCLASH_SKIP_SYSTEM=1：跳过所有系统级改动（只用于自动化测试本脚本的删除逻辑）
if [ "${MCLASH_SKIP_SYSTEM:-0}" = "1" ]; then
  say "   · 已按 MCLASH_SKIP_SYSTEM=1 跳过系统代理还原"
elif command -v networksetup >/dev/null 2>&1; then
  while IFS= read -r service; do
    [ -z "$service" ] && continue
    web=$(networksetup -getwebproxy "$service" 2>/dev/null || true)
    secure=$(networksetup -getsecurewebproxy "$service" 2>/dev/null || true)
    if printf '%s\n' "$web" | grep -q "Server: 127.0.0.1"; then
      networksetup -setwebproxystate "$service" off >/dev/null 2>&1 || true
      say "   · $service 的 HTTP 代理已关闭"
    fi
    if printf '%s\n' "$secure" | grep -q "Server: 127.0.0.1"; then
      networksetup -setsecurewebproxystate "$service" off >/dev/null 2>&1 || true
      say "   · $service 的 HTTPS 代理已关闭"
    fi
  done < <(networksetup -listallnetworkservices 2>/dev/null | tail -n +2)
fi

# ③ 开机自启
if [ -f "$AGENT_PLIST" ]; then
  say "→ 移除开机自启：$AGENT_PLIST"
  launchctl unload "$AGENT_PLIST" >/dev/null 2>&1 || true
  rm -f "$AGENT_PLIST"
fi

# ④ 删除 App 与数据
if [ -d "$APP_PATH" ]; then
  say "→ 删除 App：$APP_PATH"
  rm -rf "$APP_PATH"
else
  say "· App 目录不存在，跳过：$APP_PATH"
fi

if [ "$KEEP_DATA" = "1" ]; then
  say "· 已按 --keep-data 保留数据目录：$DATA_DIR"
else
  if [ -d "$DATA_DIR" ]; then
    say "→ 删除数据目录：$DATA_DIR"
    rm -rf "$DATA_DIR"
  else
    say "· 数据目录不存在，跳过：$DATA_DIR"
  fi
  # 桌面端会话写在数据目录里的 session.secure 文件（不用钥匙串），随目录一起删掉了；
  # 下面只是兼容早期版本可能写入过的钥匙串项。
  if security find-generic-password -s "$BUNDLE_ID" >/dev/null 2>&1; then
    say "→ 清理钥匙串里的旧会话项…"
    security delete-generic-password -s "$BUNDLE_ID" >/dev/null 2>&1 || true
  fi
fi

say "✅ 卸载完成。重新安装后需要重新登录（不会再自动进入上次的账号）。"
