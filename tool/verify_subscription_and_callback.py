#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Mclash × CBoard 补充验证：订阅内容有效性与支付回调安全性
=========================================================

单靠「接口返回 200」不足以说明功能可用，本脚本验证两件更实质的事：

A. 拉到的订阅内容**真的是 mihomo 能吃的配置**吗？
   —— 解析 YAML、检查必备顶层键、逐条校验 proxy 的 name/type/server/port。
   只统计字节数是没意义的：一份「结构不对但非空」的 YAML 同样会返回 200，
   而用户看到的是「导入成功但一个节点都没有」。

B. 伪造支付回调能不能把订单标记为已支付？
   —— 这是支付链路最要紧的一条安全断言。若能，攻击者无需付款即可开通订阅。
   预期：无有效签名的回调必须被拒，订单状态保持 pending。

用法：python3 tool/verify_subscription_and_callback.py
前提：本地后端已起（tool/run_local_verify.sh 会负责）。
"""
import json
import sqlite3
import sys
import time
import urllib.error
import urllib.request
from datetime import datetime, timedelta
from urllib.parse import urlencode

BASE = "http://127.0.0.1:9000/api/v1"
DB = "/Users/apple/v2/cboard.db"

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


def req(method, path, body=None, form=None, token=None, csrf=None, raw=False):
    url = BASE + path
    headers = {"Accept": "application/json", "User-Agent": "Mclash/1.0 (verify)"}
    data = None
    if form is not None:
        data = urlencode(form).encode()
        headers["Content-Type"] = "application/x-www-form-urlencoded"
    elif body is not None:
        data = json.dumps(body).encode()
        headers["Content-Type"] = "application/json"
    if token:
        headers["Authorization"] = "Bearer " + token
    if csrf:
        headers["X-CSRF-Token"] = csrf
    r = urllib.request.Request(url, data=data, headers=headers, method=method)
    try:
        with urllib.request.urlopen(r, timeout=30) as resp:
            t = resp.read().decode("utf-8", "replace")
            st = resp.status
    except urllib.error.HTTPError as e:
        t = e.read().decode("utf-8", "replace")
        st = e.code
    except Exception as e:
        return 0, {"_err": str(e)}
    if raw:
        return st, t
    try:
        return st, json.loads(t)
    except Exception:
        return st, t


def sql(q, a=()):
    c = sqlite3.connect(DB)
    try:
        return c.execute(q, a).fetchall()
    finally:
        c.close()


def sql_write(q, a=()):
    c = sqlite3.connect(DB)
    try:
        c.execute(q, a)
        c.commit()
    finally:
        c.close()


def go_time(mins=5):
    dt = datetime.now().astimezone() + timedelta(minutes=mins)
    off = dt.strftime("%z")
    return dt.strftime("%Y-%m-%d %H:%M:%S.%f") + f"{off[:3]}:{off[3:]}"


def data_of(r):
    return r.get("data") if isinstance(r, dict) else None


def code_of(r):
    return r.get("code") if isinstance(r, dict) else None


# 找一个已有有效订阅的真实用户来验证「订阅内容」——不新建账号，
# 因为新账号的自动订阅当天到期，返回的是「订阅已过期」占位节点。
def pick_user_with_valid_sub():
    rows = sql("""SELECT s.user_id, s.id, s.subscription_url, s.device_limit
                  FROM subscriptions s
                  WHERE s.is_active = 1 AND s.status = 'active'
                    AND s.expire_time > datetime('now','+30 day')
                  ORDER BY s.id DESC LIMIT 1""")
    return rows[0] if rows else None


print("=" * 78)
print(" A. 订阅内容有效性（是不是 mihomo 真能吃的配置）")
print("=" * 78)

try:
    import yaml
except ImportError:
    print("  ⚠️  未安装 PyYAML，尝试 pip 安装…")
    import subprocess

    subprocess.run([sys.executable, "-m", "pip", "install", "-q", "pyyaml"], check=False)
    import yaml

sub = pick_user_with_valid_sub()
if not sub:
    warn("库里没有「有效期 >30 天」的订阅，跳过内容有效性验证")
else:
    uid, sid, token_url, dlimit = sub
    print(f"      使用订阅 id={sid} user_id={uid} token={str(token_url)[:16]}…")

    st, txt = req("GET", f"/client/subscribe?token={token_url}&format=clash", raw=True)
    if st != 200:
        bad("拉取订阅内容失败", f"HTTP {st} {str(txt)[:160]}")
    else:
        ok("拉取订阅内容返回 200", f"{len(txt)} 字节")
        # 订阅名等元数据在后端是走响应头的（不是正文），这里确认正文是 YAML
        try:
            doc = yaml.safe_load(txt)
        except Exception as e:
            doc = None
            bad("订阅内容不是合法 YAML", f"{e}; 前 200 字: {txt[:200]}")

        if isinstance(doc, dict):
            need = ["proxies", "proxy-groups", "rules"]
            miss = [k for k in need if k not in doc]
            if miss:
                bad(f"订阅 YAML 缺顶层键 {miss}", f"实际顶层键: {list(doc)[:15]}")
            else:
                ok("订阅 YAML 顶层键齐全", f"proxies/proxy-groups/rules 都在")

            proxies = doc.get("proxies") or []
            ok("proxies 数量", f"{len(proxies)} 条")

            # 逐条校验节点必备字段：mihomo 缺 name/type/server/port 会直接报错
            bad_nodes = []
            types = {}
            for p in proxies:
                if not isinstance(p, dict):
                    bad_nodes.append(("非字典项", p))
                    continue
                for k in ("name", "type", "server", "port"):
                    if k not in p or p[k] in (None, ""):
                        bad_nodes.append((p.get("name", "?"), f"缺 {k}"))
                types[p.get("type")] = types.get(p.get("type"), 0) + 1
            if bad_nodes:
                bad("存在字段不全的节点（mihomo 会加载失败）", str(bad_nodes[:5]))
            else:
                ok("所有节点必备字段齐全（name/type/server/port）")

            if types:
                print(f"      协议分布: {dict(sorted(types.items(), key=lambda x: -x[1]))}")

            groups = doc.get("proxy-groups") or []
            ok("proxy-groups 数量", f"{len(groups)} 个")
            gnames = {g.get("name") for g in groups if isinstance(g, dict)}
            pnames = {p.get("name") for p in proxies if isinstance(p, dict)}
            # 分组引用了不存在的节点 → mihomo 启动即报错，这是最常见的订阅坑
            dangling = set()
            for g in groups:
                if not isinstance(g, dict):
                    continue
                for m in (g.get("proxies") or []):
                    if m not in gnames and m not in pnames and m not in (
                            "DIRECT", "REJECT", "REJECT-DROP", "PASS", "COMPATIBLE"):
                        dangling.add(f"{g.get('name')} -> {m}")
            if dangling:
                bad("分组引用了不存在的节点（mihomo 会启动失败）", str(sorted(dangling)[:6]))
            else:
                ok("分组引用无悬空（所有成员都存在）")

            rules = doc.get("rules") or []
            ok("rules 数量", f"{len(rules)} 条")
            print(f"      前 3 条规则: {rules[:3]}")
            # 规则里引用的策略组也必须存在。
            #
            # 注意：`no-resolve` 是 mihomo 规则的**修饰符**，不是策略名：
            #     GEOIP,CN,DIRECT,no-resolve
            #     规则类型,匹配值,策略,[no-resolve]
            # 直接取最后一段会把 "no-resolve" 误判成「不存在的策略组」——
            # 我第一版就是这么写的，结果对着 3376 条合法规则报了个假阳性。
            rule_targets = set()
            for r in rules:
                if not (isinstance(r, str) and "," in r):
                    continue
                parts = [x.strip() for x in r.split(",")]
                # 去掉尾部的修饰符，再取策略位
                while parts and parts[-1] in ("no-resolve", "src", "dns"):
                    parts.pop()
                if len(parts) >= 3:
                    rule_targets.add(parts[-1])
                elif len(parts) == 2 and parts[0] in ("MATCH", "FINAL"):
                    # MATCH 是终结规则，只有两段：MATCH,<策略>
                    rule_targets.add(parts[1])
                else:
                    warn(f"疑似异常规则（字段不足）: {r}")
            dangling_t = {t for t in rule_targets
                          if t not in gnames and t not in (
                              "DIRECT", "REJECT", "REJECT-DROP", "PASS", "COMPATIBLE")}
            if dangling_t:
                bad("规则引用了不存在的策略组", str(sorted(dangling_t)[:6]))
            else:
                ok("规则引用的策略组都存在")
        elif doc is not None:
            bad("订阅 YAML 顶层不是字典", f"实际类型 {type(doc).__name__}")

# ─────────────────────────────────────────────────────────────
print()
print("=" * 78)
print(" B. 支付回调安全性（伪造回调不能把订单变成已支付）")
print("=" * 78)

# 准备一个测试用户 + 订单
ts = int(time.time())
EM = f"cb.{ts}@example.com"
UN = f"cb{ts % 100000}"
PW = "CbVerify123"
sql_write("INSERT INTO verification_codes (email,code,purpose,used,expires_at,created_at) "
          "VALUES (?,?,?,0,?,?)", (EM, "909090", "register", go_time(5), go_time(0)))
st, r = req("POST", "/auth/register",
            body={"username": UN, "email": EM, "password": PW,
                  "verification_code": "909090"})
if code_of(r) != 0:
    bad("准备测试账号失败（可能触发 IP 限流）", f"{code_of(r)} {r.get('message')}")
    print("\n（跳过 B 段。稍后重跑 tool/run_local_verify.sh 会重启后端清除限流）")
else:
    token = (data_of(r) or {}).get("access_token")
    ok("测试账号就绪", EM)

    pkgs = data_of(req("GET", "/packages")[1]) or []
    pid = pkgs[0]["id"]
    # 需要 CSRF 才能下单
    csrf = (data_of(req("GET", "/csrf-token", token=token)[1]) or {}).get("csrf_token")
    st, r = req("POST", "/orders", body={"package_id": pid}, token=token, csrf=csrf)
    if code_of(r) != 0:
        bad("创建订单失败", f"{code_of(r)} {r.get('message')}")
    else:
        order = data_of(r) or {}
        ono, oid = order.get("order_no"), order.get("id")
        ok("创建待支付订单", f"order_no={ono} amount={order.get('amount')}")

        def order_status():
            cs = (data_of(req("GET", "/csrf-token", token=token)[1]) or {}).get("csrf_token")
            st, r = req("GET", f"/orders/{ono}/status", token=token, csrf=cs)
            d = data_of(r) or {}
            return d.get("status")

        before = order_status()
        print(f"      回调前订单状态: {before}")

        # 1) 未知回调类型 → 应被拒
        st, r = req("POST", "/payment/notify/definitely-not-a-gateway",
                    form={"trade_status": "TRADE_SUCCESS", "out_trade_no": ono})
        if st in (400, 403, 404) or code_of(r) not in (0, None):
            ok("未知回调类型被拒", f"HTTP {st} code={code_of(r)}")
        else:
            warn(f"未知回调类型返回 HTTP {st} code={code_of(r)}（预期被拒）")

        # 2) 伪造 epay 成功回调（无有效签名）→ 订单必须保持 pending
        for t in ("epay", "alipay", "codepay_alipay"):
            st, r = req("POST", f"/payment/notify/{t}", form={
                "trade_status": "TRADE_SUCCESS",
                "out_trade_no": ono,
                "trade_no": "FORGED-TXN-0001",
                "money": str(order.get("amount")),
                "sign": "deadbeefdeadbeefdeadbeefdeadbeef",
                "sign_type": "MD5",
                "pid": "1",
            })
            after = order_status()
            if after == "pending":
                ok(f"伪造 {t} 回调未生效，订单仍为 pending",
                   f"HTTP {st} code={code_of(r)}")
            else:
                bad(f"★ 伪造 {t} 回调把订单变成了 {after}",
                    "存在未付款即开通订阅的风险，必须修")

        # 3) 空签名 / 缺参数
        st, r = req("POST", "/payment/notify/epay", form={"out_trade_no": ono})
        after = order_status()
        if after == "pending":
            ok("缺参数回调未生效", f"HTTP {st} code={code_of(r)}")
        else:
            bad(f"★ 缺参数回调把订单变成了 {after}", "必须修")

        # 4) 确认订阅没有被凭空开通
        cnt = sql("SELECT count(*) FROM subscriptions WHERE user_id="
                  "(SELECT id FROM users WHERE email=?) AND is_active=1", (EM,))[0][0]
        pk = sql("SELECT package_id FROM orders WHERE order_no=?", (ono,))
        paid = sql("SELECT status FROM orders WHERE order_no=?", (ono,))[0][0]
        if paid == "pending":
            ok("订单未被伪造回调改成已支付", f"status={paid}")
        else:
            bad("★ 订单支付状态被伪造回调篡改", f"status={paid}")

print()
print("=" * 78)
print(f" 汇总：通过 {len(PASS)}，失败 {len(FAIL)}，提示 {len(WARN)}")
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
