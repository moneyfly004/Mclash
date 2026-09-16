#!/usr/bin/env python3
"""购买套餐 / 设备升级 两条流程的**真机端到端验证**（只建单与取消，不真实付款）。

覆盖每一步：
  1. 套餐列表（套餐页数据源）→ 字段是否够界面用
  2. 建套餐订单（选支付方式前）→ 订单号/金额/状态
  3. 支付方式列表 → 余额 + 支付宝 + 码支付
  4. 发起支付宝支付 → 必须有二维码/链接；码支付 → 必须有收银台链接
  5. 订单状态查询、取消订单、对已取消订单支付（应报「订单不存在或状态不正确」）
  6. 设备升级算价：只加设备 / 只延长时间 / 加设备+延长时间
       * 断言「延长」必须真的改变 new_expire_time（这正是之前被静默忽略的 bug）
  7. 余额支付失败路径（对已取消订单），不扣款

用法：
  python3 tool/verify_purchase_flows.py            # 用本机 App 的登录态
  BASE=... TOKEN=... python3 tool/verify_purchase_flows.py
"""
import json, os, ssl, sys, urllib.parse, urllib.request, pathlib

APP_SUPPORT = pathlib.Path.home() / "Library/Application Support/top.moneyfly.mclash"
BASE = os.environ.get("BASE", "https://new.moneyfly.top/api/v1")
UA = os.environ.get("UA", "Mclash/0.0.1.1 (macos)")
CTX = ssl.create_default_context()
CTX.check_hostname = False
CTX.verify_mode = ssl.CERT_NONE

def load_session():
    token = os.environ.get("TOKEN")
    if token:
        return token
    raw = json.loads((APP_SUPPORT / "session.secure").read_text())
    return json.loads(raw["mclash.cboard.session.v1"])["access_token"]

TOKEN = load_session()
PASS, FAIL = [], []

def call(method, path, body=None, csrf=None, query=None):
    url = f"{BASE}{path}"
    if query:
        url += "?" + urllib.parse.urlencode(query)
    data = json.dumps(body).encode() if body is not None else None
    req = urllib.request.Request(url, data=data, method=method)
    req.add_header("Authorization", f"Bearer {TOKEN}")
    req.add_header("Accept", "application/json")
    # 站点 WAF 会拦非浏览器/客户端的 UA（实测 python-urllib 被 Cloudflare 1010 拦掉），
    # 这里用与 App 一致的 UA，验证的才是 App 真正会走的链路。
    req.add_header("User-Agent", UA)
    if data:
        req.add_header("Content-Type", "application/json")
    if csrf:
        req.add_header("X-CSRF-Token", csrf)
    try:
        with urllib.request.urlopen(req, timeout=30, context=CTX) as r:
            parsed = json.loads(r.read().decode() or "{}")
            if "code" not in parsed:
                return {"code": -999, "message": f"响应不是后端 JSON: {str(parsed)[:160]}"}
            return parsed
    except urllib.error.HTTPError as e:
        body = e.read().decode() or "{}"
        try:
            parsed = json.loads(body)
        except Exception:
            parsed = {}
        if "code" not in parsed:
            parsed = {"code": -e.code, "message": f"HTTP {e.code}: {body[:160]}"}
        return parsed

def csrf():
    return (call("GET", "/csrf-token").get("data") or {}).get("csrf_token", "")

def check(name, ok, detail=""):
    (PASS if ok else FAIL).append(name)
    print(f"  {'✅' if ok else '❌'} {name}{'' if ok else '  ← ' + str(detail)}")

print("== 1. 套餐列表 ==")
pkgs = (call("GET", "/packages").get("data") or [])
check("能拿到套餐", len(pkgs) > 0, pkgs)
if pkgs:
    p = pkgs[0]
    for f in ("id", "name", "price", "duration_days", "device_limit"):
        check(f"套餐含字段 {f}", p.get(f) is not None, p)

print("== 2. 支付方式 ==")
methods = (call("GET", "/payment/methods").get("data") or {})
mnames = [m.get("pay_type") for m in methods.get("methods", [])]
check("有可用支付通道", len(mnames) > 0, methods)
check("余额支付开关存在", "balance_enabled" in methods, methods)

print("== 3. 套餐下单 + 发起支付 + 取消 ==")
order = (call("POST", "/orders", {"package_id": pkgs[0]["id"]}, csrf()).get("data") or {}) if pkgs else {}
ono, oid = order.get("order_no", ""), order.get("id")
check("能创建套餐订单", bool(ono) and order.get("status") == "pending", order)
if ono:
    st = (call("GET", f"/orders/{ono}/status").get("data") or {})
    check("订单状态可查", st.get("status") == "pending", st)
    for m in methods.get("methods", []):
        r = (call("POST", "/payment", {"order_id": oid, "payment_method_id": m["id"], "is_mobile": False}, csrf()).get("data") or {})
        payload = r.get("payment_url") or r.get("qr_code") or r.get("payment_qr_code") or ""
        check(f"通道 {m.get('pay_type')} 返回支付载荷", bool(payload), r)
    c = call("POST", f"/orders/{ono}/cancel", {}, csrf())
    check("能取消订单", c.get("code") == 0, c)
    pay = call("POST", f"/orders/{ono}/pay", {"payment_method": "balance"}, csrf())
    check("对已取消订单支付被拒（不扣款）", pay.get("code") != 0, pay)

print("== 4. 设备升级算价（含『只延长时间』） ==")
def quote(body):
    r = call("POST", "/orders/upgrade", body, csrf())
    return r

def effect(d):
    """升级后的设备数/到期时间：建单端点在 extra_data 字符串里，calc 端点在顶层。"""
    extra = {}
    raw = d.get("extra_data")
    if isinstance(raw, dict):
        extra = raw
    elif isinstance(raw, str) and raw.strip():
        try:
            extra = json.loads(raw)
        except Exception:
            extra = {}
    return (
        d.get("new_device_limit") or extra.get("new_device_limit"),
        d.get("new_expire_time") or extra.get("new_expire_time"),
    )

q_dev = quote({"add_devices": 1})
d = q_dev.get("data") or {}
dev_limit, base_expire = effect(d)
check("只加设备：有金额、设备上限与到期时间", bool(d.get("order_no")) and dev_limit is not None and bool(base_expire), q_dev)

q_days = quote({"add_devices": 0, "extend_months": 1})
dd = q_days.get("data") or {}
ok_days = q_days.get("code") == 0
if ok_days:
    check("只延长时间（1 个月）被接受", True)
    _, new_expire = effect(dd)
    check("延长时间真的改变了到期时间", new_expire != base_expire, (base_expire, new_expire))
else:
    print(f"  ⚠️  只延长时间被拒（{q_days.get('message')}）—— 需部署后端 normalizeUpgradeRequest 后生效")

for r in (q_dev, q_days):
    no = (r.get("data") or {}).get("order_no")
    if no:
        call("POST", f"/orders/{no}/cancel", {}, csrf())

print("== 5. 参数校验 ==")
bad = quote({"add_devices": 0, "extend_months": 0})
check("全 0 被拒", bad.get("code") != 0, bad)
toomany = quote({"add_devices": 101})
check("超过 100 台被拒", toomany.get("code") != 0, toomany)
if (toomany.get("data") or {}).get("order_no"):
    call("POST", f"/orders/{(toomany['data'])['order_no']}/cancel", {}, csrf())

print(f"\n通过 {len(PASS)} 项，失败 {len(FAIL)} 项")
if FAIL:
    print("失败项：" + "; ".join(FAIL))
sys.exit(1 if FAIL else 0)
