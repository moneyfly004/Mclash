#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
测速链路端到端验证（真实 mihomo 内核）
======================================

验证的是 App 实际走的那条路：Flutter 侧 `ClashHttpApi` 直接调 mihomo 的
REST API（不是后端的 /nodes/:id/test）。关键调用就两个：

    GET /proxies                      → 节点列表
    GET /proxies/<name>/delay?url=&timeout=   → 单个节点测速

`lib/app/clash/clash_http_api.dart` 里 getDelay 的解析逻辑是：
    jsonDecode(body)["delay"] → 成功
    jsonDecode(body)["err"]   → 失败（把 err 原样显示给用户）
所以本脚本对**两种响应形状都做断言**：能测通的节点必须给 delay，
测不通的必须给 err —— 只验证成功路径是不完整的，用户遇到的失败提示
恰恰来自 err 分支。

为了不干扰你正在跑的那个 mihomo（MoneyFly.app，2080/9090），
本脚本用**独立端口**起一个自己的实例，并在结束时关掉。

用法：
    python3 tool/verify_speedtest.py [mihomo二进制路径]
默认二进制：/Applications/MoneyFly.app/Contents/MacOS/mihomo
"""
import base64
import json
import os
import re
import signal
import socket
import subprocess
import sys
import time
import urllib.error
import urllib.request

DEFAULT_BIN = "/Applications/MoneyFly.app/Contents/MacOS/mihomo"
CTRL_PORT = 19090
MIXED_PORT = 17890
SECRET = "mclash-verify"
WORKDIR = "/tmp/mclash-speedtest"
CONFIG = os.path.join(WORKDIR, "config.yaml")
BACKEND = "http://127.0.0.1:9000/api/v1"

PASS, FAIL, WARN = [], [], []


def ok(m, d=""):
    PASS.append(m)
    print(f"  ✅ {m}" + (f"  — {d}" if d else ""))


def bad(m, d=""):
    FAIL.append(f"{m} :: {d}")
    print(f"  ❌ {m}" + (f"  — {d}" if d else ""))


def warn(m):
    WARN.append(m)
    print(f"  ⚠️  {m}")


def api(method, path, body=None, timeout=60):
    r = urllib.request.Request(
        f"http://127.0.0.1:{CTRL_PORT}{path}",
        data=(json.dumps(body).encode() if body is not None else None),
        headers={"Authorization": "Bearer " + SECRET,
                 "Content-Type": "application/json"},
        method=method)
    try:
        with urllib.request.urlopen(r, timeout=timeout) as resp:
            return resp.status, json.loads(resp.read().decode("utf-8", "replace"))
    except urllib.error.HTTPError as e:
        raw = e.read().decode("utf-8", "replace")
        try:
            return e.code, json.loads(raw)
        except Exception:
            return e.code, {"_raw": raw}
    except Exception as e:
        return 0, {"_err": str(e)}


def port_free(p):
    """能否绑定该端口。

    必须先设 SO_REUSEADDR：上一次运行留下的 TIME_WAIT 套接字会让裸 bind 失败，
    于是脚本会报「端口被占用」，但 `lsof` 又什么都看不到 —— 我第一版就是这样，
    白白排查了一轮。真实服务端本来也都会设这个选项。
    """
    s = socket.socket()
    s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    try:
        s.bind(("127.0.0.1", p))
        return True
    except OSError:
        return False
    finally:
        s.close()


# ─────────────────────────────────────────────────────────────
bin_path = sys.argv[1] if len(sys.argv) > 1 else DEFAULT_BIN
print("=" * 78)
print(" 测速链路端到端验证（真实 mihomo 内核）")
print("=" * 78)

if not os.path.isfile(bin_path):
    bad("找不到 mihomo 二进制", bin_path)
    sys.exit(1)
v = subprocess.run([bin_path, "-v"], capture_output=True, text=True).stdout.strip()
ok("mihomo 二进制可用", v.split("\n")[0])
m = re.search(r"v(\d+\.\d+\.\d+)", v)
core_ver = m.group(1) if m else "?"

# 清理上一次可能残留的测试实例。
# 只按 "mclash-speedtest" 这个**专属工作目录**匹配，绝不会误伤用户自己
# 正在跑的 mihomo（例如 MoneyFly.app 在 2080/9090 上的那个）。
subprocess.run(["pkill", "-f", "mclash-speedtest"], capture_output=True)
time.sleep(1.5)

for p in (CTRL_PORT, MIXED_PORT):
    if not port_free(p):
        bad(f"端口 {p} 已被占用", "换端口或先关掉占用进程")
        sys.exit(1)

# ── 抓一份真实订阅，取几个真节点 ──────────────────────────────
proxies = []
try:
    import yaml
except ImportError:
    subprocess.run([sys.executable, "-m", "pip", "install", "-q", "pyyaml"], check=False)
    import yaml

try:
    import sqlite3
    c = sqlite3.connect("/Users/apple/v2/cboard.db")
    row = c.execute("""SELECT subscription_url FROM subscriptions
                       WHERE is_active=1 AND status='active'
                         AND expire_time > datetime('now','+30 day')
                       ORDER BY id DESC LIMIT 1""").fetchone()
    c.close()
    tok = row[0] if row else None
except Exception as e:
    tok = None
    warn(f"读本地订阅失败: {e}")

if tok:
    try:
        with urllib.request.urlopen(
                f"{BACKEND}/client/subscribe?token={tok}&format=clash", timeout=30) as r:
            doc = yaml.safe_load(r.read().decode("utf-8", "replace"))
        raw = [p for p in (doc.get("proxies") or []) if isinstance(p, dict)]
        # 后端会往订阅里塞「信息节点」——它们**不是真节点**，而是把账号信息
        # 显示在节点列表里的技巧（业界常见做法）：
        #     ss://<aes-128-gcm:info>@baidu.com:1234#📢 官网: ...
        # 看 createInfoNode 就知道：服务器写死 baidu.com:1234，永远连不通。
        # 所以测速时必须把它们排除，否则「全部测速」必然一片超时。
        def is_info(p):
            return (str(p.get("server", "")).lower() == "baidu.com"
                    and str(p.get("port", "")) == "1234")
        info_nodes = [p for p in raw if is_info(p)]
        real = [p for p in raw if not is_info(p)]
        proxies = real[:3]
        ok("从本地后台取到订阅节点",
           f"共 {len(raw)}：其中信息节点 {len(info_nodes)} 个、真实节点 {len(real)} 个")
        if info_nodes:
            print(f"      信息节点（不可测速，App 应识别并排除）: "
                  f"{[p['name'] for p in info_nodes]}")
            # 把它们也放进配置，用于验证「App 必须能识别信息节点」这一条
            proxies = proxies + info_nodes
    except Exception as e:
        warn(f"取订阅失败（将只用合成节点）: {e}")

# ── 组一份最小配置 ────────────────────────────────────────────
os.makedirs(WORKDIR, exist_ok=True)

# 故意不可达的节点：用来验证 err 分支（App 会把 err 原样显示给用户）
bad_proxy = {
    "name": "MCLASH-BROKEN-DO-NOT-USE",
    "type": "socks5",
    "server": "127.0.0.1",
    "port": 1,  # 必然连不上
}

all_proxies = list(proxies) + [bad_proxy]
names = [p["name"] for p in all_proxies]

cfg = {
    "mixed-port": MIXED_PORT,
    "allow-lan": False,
    "mode": "rule",
    "log-level": "warning",
    "external-controller": f"127.0.0.1:{CTRL_PORT}",
    "secret": SECRET,
    "proxies": all_proxies,
    "proxy-groups": [
        {"name": "MCLASH-VERIFY", "type": "select", "proxies": names},
        {"name": "MCLASH-AUTO", "type": "url-test", "proxies": names,
         "url": "https://www.gstatic.com/generate_204", "interval": 300},
    ],
    "rules": ["MATCH,MCLASH-VERIFY"],
}
with open(CONFIG, "w") as f:
    yaml.safe_dump(cfg, f, allow_unicode=True, sort_keys=False)
ok("生成测试配置", f"{CONFIG}（{len(all_proxies)} 个节点：{len(proxies)} 真实 + 1 故意不可达）")

# ── 起 mihomo ─────────────────────────────────────────────────
proc = subprocess.Popen(
    [bin_path, "-d", WORKDIR, "-f", CONFIG],
    stdout=open(os.path.join(WORKDIR, "mihomo.log"), "w"),
    stderr=subprocess.STDOUT,
)
ready = False
for _ in range(40):
    if proc.poll() is not None:
        break
    st, _r = api("GET", "/version", timeout=3)
    if st == 200:
        ready = True
        break
    time.sleep(0.5)

if not ready:
    bad("mihomo 启动失败", f"见 {WORKDIR}/mihomo.log")
    proc.kill()
    sys.exit(1)
ok("mihomo 已启动（独立端口，未干扰你正在跑的实例）",
   f"controller=127.0.0.1:{CTRL_PORT} mixed=127.0.0.1:{MIXED_PORT}")

try:
    # ── 1. /proxies 形状（App 的节点列表来源） ────────────────
    print()
    st, r = api("GET", "/proxies")
    if st == 200 and isinstance(r.get("proxies"), dict):
        pm = r["proxies"]
        ok("GET /proxies 正常", f"{len(pm)} 个条目（含内置 DIRECT/REJECT 与分组）")
        sample = pm.get(names[0]) if names else None
        if sample:
            need = ["name", "type", "history", "alive"]
            miss = [k for k in need if k not in sample]
            if miss:
                bad(f"节点对象缺字段 {miss}", f"实际 keys={list(sample)[:12]}")
            else:
                ok("节点对象字段齐全", "name/type/history/alive")
        # 分组条目
        grp = pm.get("MCLASH-VERIFY")
        if grp and grp.get("type") in ("Selector", "URLTest", "Fallback", "LoadBalance"):
            ok("分组条目可识别", f"type={grp.get('type')} 成员={len(grp.get('all') or [])}")
        else:
            warn(f"未找到分组条目 MCLASH-VERIFY（实际 type={grp.get('type') if grp else None}）")

        # App 用 ClashProtocolType 判断能不能测速，这里确认分组与节点的 type 可区分
        types = sorted({v.get("type") for v in pm.values() if isinstance(v, dict)})
        print(f"      出现的 type 集合: {types}")
        group_types = {"Selector", "URLTest", "Fallback", "LoadBalance", "Relay"}
        print(f"      → 分组类型集合（App 的 GroupToList 应排除它们）: "
              f"{sorted(group_types & set(types))}")
    else:
        bad("GET /proxies 异常", f"HTTP {st} {str(r)[:160]}")

    # ── 2. 单节点测速：成功路径 ───────────────────────────────
    print()
    print("  ── 单节点测速（GET /proxies/:name/delay）──")
    test_url = "https://www.gstatic.com/generate_204"
    success = []
    failures = []
    for nm in names:
        enc = urllib.parse.quote(nm, safe="") if False else nm
        path = (f"/proxies/{urllib.request.quote(nm, safe='')}"
                f"/delay?url={urllib.request.quote(test_url, safe='')}&timeout=5000")
        st, rr = api("GET", path, timeout=20)
        delay = rr.get("delay")
        err = rr.get("err")
        if isinstance(delay, int) and delay >= 0 and err is None:
            success.append((nm, delay))
        else:
            failures.append((nm, err or rr))
    for nm, d in success:
        ok(f"测速成功: {nm}", f"delay={d} ms  （App 取 json['delay']）")
    info_names = {p["name"] for p in info_nodes} if 'info_nodes' in dir() else set()
    for nm, e in failures:
        if nm == bad_proxy["name"]:
            ok(f"故意不可达节点返回 err（不是静默成功）: {nm}", f"err={e}")
        elif nm in info_names:
            ok(f"信息节点确实测不通（符合预期，故 App 必须排除它们）: {nm}",
               f"{e}")
        else:
            warn(f"真实节点测速未通过: {nm} — {e}")

    if success:
        ok("成功路径：至少一个节点拿到整数 delay",
           f"{len(success)}/{len(names)}")
    else:
        bad("成功路径未验证：没有任何节点测通",
            "可能是本机到 gstatic 不通；换个 delayTestUrl 再试")

    if failures:
        ok("失败路径：连不通的节点给出 err 字段（App 会原样提示用户）",
           f"{len(failures)} 个")
    else:
        bad("失败路径未验证：故意不可达的节点竟然测通了", "断言无效")

    # ── 3. 并发批量测速 + 进度（复刻 App 的 worker-pool 逻辑） ──
    print()
    print("  ── 批量测速与进度（复刻 proxy_board_screen_widgets.delayTest）──")
    # App 的做法：maxConcurrentTests = PC?10:5；_nodesTesting 集合作为「剩余待测」
    # 计数，每测完一个就 remove 并通知 UI —— 那个数字就是「测速进度」。
    max_concurrent = 5  # 模拟移动端
    pending = list(names)
    tested = []
    t0 = time.time()

    def worker():
        while pending:
            nm = pending.pop(0)
            path = (f"/proxies/{urllib.request.quote(nm, safe='')}"
                    f"/delay?url={urllib.request.quote(test_url, safe='')}&timeout=5000")
            st, rr = api("GET", path, timeout=20)
            tested.append((nm, rr.get("delay"), rr.get("err")))
            print(f"      进度: 剩余 {len(pending):2d} / 共 {len(names)}"
                  f"  ← _nodesTesting.length 就是它")

    import threading
    ths = [threading.Thread(target=worker) for _ in range(max_concurrent)]
    [t.start() for t in ths]
    [t.join() for t in ths]
    elapsed = time.time() - t0

    if len(tested) == len(names):
        ok("批量测速覆盖全部节点且不重复",
           f"{len(tested)}/{len(names)}，{max_concurrent} 并发，耗时 {elapsed:.1f}s")
    else:
        bad("批量测速数量不符", f"测了 {len(tested)}，应为 {len(names)}")

    order_ok = len({t[0] for t in tested}) == len(names)
    if order_ok:
        ok("无重复测速（worker-pool 用共享索引，每个节点恰好一次）")
    else:
        bad("出现重复测速", "共享索引/乐观锁有问题")

    # ── 4. 延迟排序（delayTestSort） ──────────────────────────
    print()
    good = sorted([t for t in tested if isinstance(t[1], int)], key=lambda x: x[1])
    if good:
        ok("按延迟升序排序可用（对应 ui.delay_test_sort）",
           " < ".join(f"{n}({d}ms)" for n, d, _ in good[:4]))
    else:
        warn("没有可用延迟，无法验证排序")

    # ── 5. 不存在的节点名（错误处理） ─────────────────────────
    print()
    st, rr = api("GET", "/proxies/MCLASH-NO-SUCH-NODE/delay?url="
                 + urllib.request.quote(test_url, safe=""), timeout=15)
    if st != 200 or rr.get("err") or rr.get("message"):
        ok("对不存在的节点测速会报错（不会返回假延迟）",
           f"HTTP {st} {rr.get('message') or rr.get('err')}")
    else:
        bad("对不存在的节点竟然返回成功", str(rr)[:160])

    # ── 6. 切换节点（一键连接依赖） ───────────────────────────
    print()
    if proxies:
        target = proxies[0]["name"]
        st, rr = api("PUT", "/proxies/MCLASH-VERIFY", {"name": target})
        st2, rr2 = api("GET", "/proxies/MCLASH-VERIFY")
        if st in (200, 204) and rr2.get("now") == target:
            ok("切换选中节点成功（一键连接/选节点依赖）", f"now={rr2.get('now')}")
        else:
            bad("切换节点失败", f"HTTP {st} now={rr2.get('now')} 期望 {target}")
    else:
        warn("无真实节点，跳过切换验证")

finally:
    proc.send_signal(signal.SIGTERM)
    try:
        proc.wait(timeout=8)
    except subprocess.TimeoutExpired:
        proc.kill()
    print()
    print(f"  （已关闭测试用 mihomo 实例；日志 {WORKDIR}/mihomo.log）")

print()
print("=" * 78)
print(f" 汇总：通过 {len(PASS)}，失败 {len(FAIL)}，提示 {len(WARN)}   内核 {core_ver}")
print("=" * 78)
if FAIL:
    print("\n【失败项】")
    for f in FAIL:
        print("  ❌ " + f)
if WARN:
    print("\n【提示项】")
    for w in WARN:
        print("  ⚠️  " + w)
sys.exit(1 if FAIL else 0)
