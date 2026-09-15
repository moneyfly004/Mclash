#!/bin/bash
# 起一个干净的本地 CBoard 后端并跑全接口验证套件
#
# 为什么要重启后端：路由上的 middleware.RateLimit 把计数放在**内存**里按 IP 统计，
# 反复跑测试必然触发 429。重启即清零，比在测试里等 60s 快得多。
#
# 全程只碰 127.0.0.1:9000 与本地 cboard.db，**不影响线上 new.moneyfly.top**。
set -uo pipefail

BACKEND_DIR="/Users/apple/v2"
DB="$BACKEND_DIR/cboard.db"
BIN="/tmp/cboard-test-server"
PORT=9000
SUITE="$(cd "$(dirname "$0")/.." && pwd)/tool/verify_cboard_api.py"

# 1) 备份 DB（测试会注册用户、写订阅、下单）
BK="/tmp/cboard.db.test-backup-$(date +%s)"
cp "$DB" "$BK" && echo "✓ 已备份 $DB → $BK"

# 2) 停掉旧实例
pkill -f "$BIN" 2>/dev/null && sleep 2
if lsof -nP -iTCP:$PORT -sTCP:LISTEN >/dev/null 2>&1; then
  echo "警告: 端口 $PORT 仍被占用，尝试强制释放" >&2
  lsof -nP -iTCP:$PORT -sTCP:LISTEN -t | xargs -r kill -9 2>/dev/null
  sleep 2
fi

# 3) 启动
[ -x "$BIN" ] || { echo "未找到 ${BIN}，请先: cd $BACKEND_DIR && go build -o $BIN ./cmd/server" >&2; exit 1; }
( cd "$BACKEND_DIR" && "$BIN" > /tmp/cboard-local.log 2>&1 & )
for i in $(seq 1 30); do
  if curl -s -m 3 -o /dev/null "http://127.0.0.1:$PORT/api/v1/config"; then
    echo "✓ 后端已就绪 (127.0.0.1:$PORT)"; break
  fi
  [ "$i" = 30 ] && { echo "后端启动超时，见 /tmp/cboard-local.log" >&2; exit 1; }
  sleep 1
done

# 4) 跑套件
echo
python3 "$SUITE"
RC=$?
echo
echo "备份位置: ${BK}（如需还原: cp ${BK} ${DB}，但请先停掉 ${BIN}）"
exit $RC
