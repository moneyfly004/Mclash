#!/bin/bash
# Mclash 卸载（macOS）—— 双击运行，或 `bash scripts/uninstall_macos.command --yes`
#
# 为什么必须要有它：macOS 把 App 拖进废纸篓**不会**删除
#   ~/Library/Application Support/top.moneyfly.mclash
# 里的订阅地址、登录会话、节点缓存与日志。残留数据会导致「重装后还是旧配置 /
# 旧账号」这类问题；用户报的「卸载了配置文件还在」就是这个原因。
set -uo pipefail

APP="/Applications/Mclash.app"
DATA="$HOME/Library/Application Support/top.moneyfly.mclash"
PREFS="$HOME/Library/Preferences/top.moneyfly.mclash.plist"
CACHE="$HOME/Library/Caches/top.moneyfly.mclash"

KEEP_APP=0
ASSUME_YES=0
for arg in "$@"; do
  case "$arg" in
    --keep-app) KEEP_APP=1 ;;
    --yes|-y)   ASSUME_YES=1 ;;
    *) echo "未知参数：$arg"; exit 2 ;;
  esac
done

echo "======================================"
echo " Mclash 卸载"
echo "======================================"
echo "将删除："
[ "$KEEP_APP" -eq 0 ] && echo "  · 应用程序  $APP"
echo "  · 配置与订阅 $DATA"
echo "  · 偏好设置   $PREFS"
echo "  · 缓存       $CACHE"
echo
echo "账号与已购套餐在服务器上，不受影响；重新安装后登录即可恢复。"
echo

if [ "$ASSUME_YES" -eq 0 ]; then
  printf "确认卸载？输入 y 回车继续："
  read -r answer
  case "$answer" in
    y|Y|yes|YES) ;;
    *) echo "已取消。"; exit 0 ;;
  esac
fi

# 先退出正在运行的进程，避免删到一半文件仍被占用
if pgrep -f "Mclash.app/Contents/MacOS" >/dev/null 2>&1; then
  echo "· 正在退出 Mclash…"
  pkill -f "Mclash.app/Contents/MacOS" || true
  sleep 2
fi

remove_path() {
  if [ -e "$1" ]; then
    rm -rf "$1" && echo "· 已删除 $1"
  fi
}

remove_path "$DATA"
remove_path "$PREFS"
remove_path "$CACHE"
if [ "$KEEP_APP" -eq 0 ]; then
  remove_path "$APP"
else
  echo "· 保留 $APP（--keep-app）"
fi

echo
echo "卸载完成。"
if [ "$ASSUME_YES" -eq 0 ]; then
  printf "按回车关闭窗口…"
  read -r _
fi
