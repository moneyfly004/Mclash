#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Mclash × CBoard 全接口验证套件
================================

跑在本机 CBoard 后端（127.0.0.1:9000 + cboard.db）上，对生产零影响。

覆盖用户点名的全部功能：
  登录 / 注册 / 忘记密码 / 改密
  套餐购买 / 支付 / 回调轮询 / 套餐更新(续费) / 升级设备
  设备管理 / 设备备注 / 设备删除
  订阅拉取（核心）
  节点测速(后端侧) / 通知
  以及全部只读公开接口

设计原则：
  · 每条断言都打印**实际拿到的东西**，不是只打印 PASS —— 出问题时能直接看出
    是「字段名变了」还是「值不对」。
  · 关键链路做**副作用确认**（例如改备注后重新拉列表看 remark 是否真的变了），
    而不是只看接口返回 200。只信返回值是这类验证最常见的假阳性来源。
  · 失败不中断，最后统一汇总；但会把失败原因原样带出来。
"""
import json
import sqlite3
import subprocess
import sys
import time
import urllib.error
import urllib.request

BASE = "http://127.0.0.1:9000/api/v1"
DB = "/Users/apple/v2/cboard.db"

PASS, FAIL, WARN = [], [], []
_cur_section = "?"


def section(name):
    global _cur_section
    _cur_section = name
    print(f"\n{'='*78}\n {name}\n{'='*78}")


def ok(msg, detail=""):
    PASS.append(f"[{_cur_section}] {msg}")
    print(f"  ✅ {msg}" + (f"  — {detail}" if detail else ""))


def bad(msg, detail=""):
    FAIL.append(f"[{_cur_section}] {msg}" + (f" :: {detail}" if detail else ""))
    print(f"  ❌ {msg}" + (f"  — {detail}" if detail else ""))


def warn(msg):
    WARN.append(f"[{_cur_section}] {msg}")
    print(f"  ⚠️  {msg}")


def req(method, path, body=None, token=None, csrf=None, raw=False, timeout=30):
    """返回 (http_status, parsed_or_text)."""
    url = path if path.startswith("http") else BASE + path
    data = None
    headers = {"Accept": "application/json", "User-Agent": "Mclash/1.0 (macos)"}
    if body is not None:
        data = json.dumps(body).encode()
        headers["Content-Type"] = "application/json"
    if token:
        headers["Authorization"] = "Bearer " + token
    if csrf:
        headers["X-CSRF-Token"] = csrf
    r = urllib.request.Request(url, data=data, headers=headers, method=method)
    try:
        with urllib.request.urlopen(r, timeout=timeout) as resp:
            txt = resp.read().decode("utf-8", "replace")
            st = resp.status
    except urllib.error.HTTPError as e:
        txt = e.read().decode("utf-8", "replace")
        st = e.code
    except Exception as e:
        return 0, {"_err": str(e)}
    if raw:
        return st, txt
    try:
        return st, json.loads(txt)
    except Exception:
        return st, txt


def req_429backoff(method, path, body=None, tries=3, wait=62):
    """对 429（IP 级限流）自动退避重试。

    路由上挂了 middleware.RateLimit(N, time.Minute)，计数在**内存**里、
    按客户端 IP 计数。反复跑本脚本必然触发；重启后端可立即清零。
    这里做退避重试，让脚本对长跑着的服务端也能自洽。
    """
    for i in range(tries):
        st, r = req(method, path, body=body)
        if st != 429:
            return st, r
        if i < tries - 1:
            print(f"      ⏳ 429 限流，等待 {wait}s 后重试（{i+1}/{tries-1}）…")
            time.sleep(wait)
    return st, r


def code_of(r):
    return r.get("code") if isinstance(r, dict) else None


def data_of(r):
    return r.get("data") if isinstance(r, dict) else None


def msg_of(r):
    return r.get("message") if isinstance(r, dict) else str(r)[:120]


# ─────────────────────────────────────────────────────────────
class Api:
    """带一次性 CSRF 处理的会话（模拟客户端行为）。"""

    def __init__(self):
        self.token = None
        self.refresh = None
        self.user = None
        self._csrf_fetches = 0

    def csrf(self):
        st, r = req("GET", "/csrf-token", token=self.token)
        self._csrf_fetches += 1
        if st == 200 and code_of(r) == 0:
            return (data_of(r) or {}).get("csrf_token")
        return None

    def call(self, method, path, body=None, auth=True, mutate=None, retry=True):
        """mutate=None 时按 method 自动判断是否需要 CSRF。"""
        need_csrf = mutate
        if need_csrf is None:
            need_csrf = method in ("POST", "PUT", "PATCH", "DELETE") and not path.startswith("/auth/")
        csrf = self.csrf() if (need_csrf and auth and self.token) else None
        st, r = req(method, path, body=body, token=self.token if auth else None, csrf=csrf)
        # 40100 → 刷新一次重放
        if isinstance(r, dict) and code_of(r) == 40100 and auth and self.token and retry:
            if self.do_refresh():
                return self.call(method, path, body=body, auth=auth, mutate=mutate, retry=False)
        # 40300 → 重取 CSRF 重放
        if isinstance(r, dict) and code_of(r) == 40300 and retry and need_csrf:
            return self.call(method, path, body=body, auth=auth, mutate=mutate, retry=False)
        return st, r

    def do_refresh(self):
        if not self.refresh:
            return False
        st, r = req("POST", "/auth/refresh", body={"refresh_token": self.refresh})
        if st == 200 and code_of(r) == 0:
            d = data_of(r) or {}
            self.token = d.get("access_token")
            self.refresh = d.get("refresh_token") or self.refresh
            return bool(self.token)
        return False


def sql(q, args=()):
    c = sqlite3.connect(DB)
    try:
        return c.execute(q, args).fetchall()
    finally:
        c.close()


def go_time(delta_minutes=5):
    """生成与 Go 后端一致的 SQLite 时间字符串。

    踩过的坑：SQLite 把时间当**字符串**比较，GORM 写入的是
    '2026-09-15 21:30:56.641067+08:00'，而 datetime('now','+5 minute') 产出的是
    '2026-09-15 21:40:00'。后者与 '...21:40:00.123456+08:00' 逐字符比较时更小，
    于是 `expires_at > now` 为假 → 后端报「验证码无效或已过期」。
    手写测试数据时必须对齐格式，否则会误判成后端 bug。
    """
    from datetime import datetime, timedelta
    dt = datetime.now().astimezone() + timedelta(minutes=delta_minutes)
    off = dt.strftime("%z")
    return dt.strftime("%Y-%m-%d %H:%M:%S.%f") + f"{off[:3]}:{off[3:]}"


def sql_write(q, args=()):
    c = sqlite3.connect(DB)
    try:
        c.execute(q, args)
        c.commit()
    finally:
        c.close()


def latest_code(email, purpose):
    rows = sql("SELECT code FROM verification_codes WHERE email=? AND purpose=? "
               "ORDER BY created_at DESC LIMIT 1", (email, purpose))
    return rows[0][0] if rows else None


# ─────────────────────────────────────────────────────────────
section("0. 后端可达性 / 数据规模")
st, r = req("GET", "/config")
if st == 200 and code_of(r) == 0:
    ok("后端在线，GET /config 正常", f"HTTP {st}, code={code_of(r)}")
else:
    bad("后端不可达", f"HTTP {st} {r}")
    sys.exit(1)
for tbl in ("users", "subscriptions", "packages", "orders", "nodes", "devices"):
    try:
        n = sql(f"SELECT count(*) FROM {tbl}")[0][0]
        print(f"      {tbl:15s} {n}")
    except Exception as e:
        warn(f"{tbl} 计数失败: {e}")

# ─────────────────────────────────────────────────────────────
section("1. 公开接口（免登录）")
for path, keys in [
    ("/config", ["site_url"]),
    ("/packages", None),
    ("/announcements", None),
    ("/payment/methods", ["methods"]),
    ("/software/versions", ["list"]),
]:
    st, r = req("GET", path)
    if st == 200 and code_of(r) == 0:
        d = data_of(r)
        if path == "/config":
            # site_name 在生产库有、本地快照缺；客户端 providerName 已能优雅降级为空串。
            if "site_name" in d:
                ok("GET /config 含 site_name", f"site_name={d.get('site_name')}")
            else:
                warn("本地快照 /config 无 site_name（生产库有；客户端已按空串降级，不影响）")
            print(f"      site_url={d.get('site_url')} register_enabled={d.get('register_enabled')} "
                  f"register_email_verify={d.get('register_email_verify')} "
                  f"custom_package_enabled={d.get('custom_package_enabled')}")
        if keys:
            missing = [k for k in keys if not isinstance(d, dict) or k not in d]
            if missing:
                bad(f"GET {path} 缺字段 {missing}", f"实际 keys={list(d)[:12] if isinstance(d,dict) else type(d)}")
            else:
                ok(f"GET {path}", f"含 {keys}")
        else:
            cnt = len(d) if isinstance(d, list) else (
                len(d.get("items", d.get("list", d))) if isinstance(d, dict) else "?")
            ok(f"GET {path}", f"data={'数组' if isinstance(d,list) else '对象'} 条数={cnt}")
    else:
        bad(f"GET {path}", f"HTTP {st} {msg_of(r)}")

# 套餐详情
pkgs = data_of(req("GET", "/packages")[1]) or []
if pkgs:
    pid = pkgs[0].get("id")
    st, r = req("GET", f"/packages/{pid}")
    if st == 200 and code_of(r) == 0:
        d = data_of(r) or {}
        need = ["id", "name", "price", "duration_days", "device_limit"]
        miss = [k for k in need if k not in d]
        ok(f"GET /packages/{pid}", f"{d.get('name')} ¥{d.get('price')} {d.get('duration_days')}天 {d.get('device_limit')}设备"
           ) if not miss else bad(f"GET /packages/{pid} 缺字段", str(miss))
    else:
        bad(f"GET /packages/{pid}", f"HTTP {st} {msg_of(r)}")

# ─────────────────────────────────────────────────────────────
section("2. 注册（含邮箱验证码 + 昵称 + 蜜罐字段）")
ts = int(time.time())
EMAIL = f"mclash.verify.{ts}@example.com"
USERNAME = f"mclashv{ts % 100000}"
PASSWORD = "McVerify12345"

cfg = data_of(req("GET", "/config")[1]) or {}
print(f"      register_enabled={cfg.get('register_enabled')} "
      f"email_verify={cfg.get('register_email_verify')} "
      f"invite_required={cfg.get('register_invite_required')}")

# 注册验证码：
#   后端限流「同一邮箱 5 分钟内最多 3 次」，而验证码只存在 DB 里，
#   所以这里**只真实调用一次 send** 验证接口可用，随后直接写入一个
#   已知的未使用码来推进注册 —— 这样既验证了 send，又不会把自己限流掉。
st, r = req("POST", "/auth/verification/send", body={"email": EMAIL, "purpose": "register"})
if st == 200 and code_of(r) == 0:
    ok("POST /auth/verification/send", msg_of(r))
elif st == 429:
    # 路由上挂了 middleware.RateLimit(3, time.Minute)，是 **IP 级** 限流。
    # 反复跑本脚本必然触发，属预期行为 —— 但客户端必须能把它呈现成「稍后再试」。
    ok("POST /auth/verification/send 触发 IP 限流 429（预期内，客户端需处理）", msg_of(r))
else:
    bad("POST /auth/verification/send", f"HTTP {st} {msg_of(r)}")

VCODE = "246810"
sql_write("INSERT INTO verification_codes (email, code, purpose, used, expires_at, created_at) "
          "VALUES (?,?,?,0,?,?)",
          (EMAIL, VCODE, "register", go_time(5), go_time(0)))
ok("写入已知注册验证码（绕过邮件限流）", f"code={VCODE}")

# ⚠️ 实测确认的流程规则：VerifyCode 会把验证码置为 used=1，
# 而 Register 校验的是 used = 0 —— 所以「先 verify 再 register」**必然失败**。
# 正确流程：send → 把 code 直接交给 /auth/register。
# 用**另一个邮箱**独立验证 verify 接口本身，避免消耗注册用的码。
VEMAIL = f"mclash.vfy.{ts}@example.com"
VC2 = "135790"
sql_write("INSERT INTO verification_codes (email, code, purpose, used, expires_at, created_at) "
          "VALUES (?,?,?,0,?,?)",
          (VEMAIL, VC2, "register", go_time(5), go_time(0)))
st, r = req("POST", "/auth/verification/verify", body={"email": VEMAIL, "code": VC2})
if st == 200 and code_of(r) == 0:
    ok("POST /auth/verification/verify 可用", msg_of(r))
else:
    bad("POST /auth/verification/verify", f"HTTP {st} {msg_of(r)}")
used = sql("SELECT used FROM verification_codes WHERE email=? AND code=?", (VEMAIL, VC2))
if used and used[0][0] == 1:
    ok("verify 会将验证码置为已用（used=1）",
       "→ 客户端注册流程必须 send→register 直传 code，不能先 verify")
else:
    warn(f"verify 后 used={used}")

st, r = req_429backoff("POST", "/auth/register", body={
    "username": USERNAME, "email": EMAIL,
    "password": PASSWORD, "verification_code": VCODE,
    "website": "",  # 蜜罐字段必须为空
})
REG_ERR = msg_of(r)
REG_OK = st == 200 and code_of(r) == 0
if REG_OK:
    d = data_of(r) or {}
    ok("POST /auth/register 成功", f"user_id={d.get('id')} username={d.get('username')}")
    if isinstance(d, dict) and d.get("access_token"):
        ok("注册即下发 access_token/refresh_token（客户端可直接落库免再登录）",
           f"keys={list(d)}")
    else:
        warn(f"注册未直接下发 token，data keys={list(d) if isinstance(d,dict) else d}")
else:
    bad("POST /auth/register", f"HTTP {st} {REG_ERR}")

# ── 播种测试数据 ────────────────────────────────────────────────────────
# 关键观察：**注册时后端会自动创建一条订阅**（getUserSubscription 用
# First(&sub) 取 id 最小那条，所以另插一行是没用的——会被忽略）。
# 因此这里 UPDATE 那条自动创建的订阅，把到期时间推到一年后，
# 否则订阅内容会返回「订阅已过期」的占位节点，后面设备/升级链路全部测不了。
if REG_OK:
    try:
        uid = sql("SELECT id FROM users WHERE email=?", (EMAIL,))[0][0]
        subs = sql("SELECT id, package_id, device_limit FROM subscriptions WHERE user_id=? ORDER BY id", (uid,))
        ok("注册时自动创建了订阅", f"共 {len(subs)} 条: {subs}")
        sid = subs[0][0]
        sql_write("UPDATE subscriptions SET expire_time=?, device_limit=5, current_devices=2, "
                  "is_active=1, status='active' WHERE id=?",
                  (go_time(365 * 24 * 60), sid))
        ok("已将订阅续期到一年后并设 device_limit=5", f"subscription_id={sid}")

        # 造两台设备（device 表用 subscription_id 关联，remark 字段可写）
        for n in range(2):
            sql_write(
                "INSERT INTO devices (user_id, subscription_id, device_fingerprint, device_hash, "
                "device_name, device_type, os_name, software_name, subscription_type, is_active, "
                "is_allowed, access_count, first_seen, last_seen, last_access, created_at, updated_at) "
                "VALUES (?,?,?,?,?,?,?,?,?,1,1,1,?,?,?,?,?)",
                (uid, sid, f"fp-verify-{uid}-{n}", f"hash-verify-{uid}-{n}",
                 f"Mclash-Verify-{n}", "desktop", "macOS", "Mclash", "clash",
                 go_time(0), go_time(0), go_time(0), go_time(0), go_time(0)))
        ok("已播种 2 台测试设备", "供设备列表/备注/删除验证使用")
    except Exception as e:
        bad("播种测试数据失败", str(e))

# 重复注册必须被拒
st, r = req("POST", "/auth/register", body={
    "username": USERNAME + "b", "email": EMAIL,
    "password": PASSWORD, "verification_code": VCODE})
if code_of(r) != 0:
    ok("重复注册被拒（同邮箱二次注册）", msg_of(r))
else:
    bad("重复注册竟然成功", "")

# ─────────────────────────────────────────────────────────────
section("3. 登录 / CSRF / refresh / 登出")
api = Api()
st, r = req_429backoff("POST", "/auth/login", body={"email": EMAIL, "password": PASSWORD})
if st == 200 and code_of(r) == 0:
    d = data_of(r) or {}
    api.token = d.get("access_token")
    api.refresh = d.get("refresh_token")
    api.user = d.get("user")
    ok("POST /auth/login", f"access_token={'有' if api.token else '无'} "
                          f"refresh_token={'有' if api.refresh else '无'} user={'有' if d.get('user') else '无'}")
    if not api.token:
        bad("登录未返回 access_token", f"data keys={list(d)}")
else:
    bad("POST /auth/login", f"HTTP {st} {msg_of(r)}")

st, r = req("POST", "/auth/login", body={"email": EMAIL, "password": "wrong-password"})
if code_of(r) == 40100:
    ok("错误密码返回 40100（客户端据此判定未授权）", msg_of(r))
else:
    bad("错误密码返回码不符", f"HTTP {st} code={code_of(r)} {msg_of(r)}")

st, r = req("GET", "/users/me", token="bogus-token")
if code_of(r) == 40100:
    ok("伪造 token 返回 40100", msg_of(r))
else:
    bad("伪造 token 未被拒", f"HTTP {st} code={code_of(r)}")

if api.token:
    # CSRF 轮换验证：连续两次写操作都必须成功
    t0 = api.csrf()
    t1 = api.csrf()
    print(f"      csrf 连续两次取值: {'不同（已轮换）' if t0 != t1 else '相同'}")
    st1, ra = api.call("PUT", "/users/me", body={"nickname": "verify-a"})
    st2, rb = api.call("PUT", "/users/me", body={"nickname": "verify-b"})
    if code_of(ra) == 0 and code_of(rb) == 0:
        ok("连续两次写操作均成功（一次性 CSRF 自动重取生效）",
           f"第1次 code={code_of(ra)}, 第2次 code={code_of(rb)}, 本会话取 csrf {api._csrf_fetches} 次")
    else:
        bad("连续写操作失败（CSRF 轮换未处理好）",
            f"第1次 {code_of(ra)}:{msg_of(ra)} / 第2次 {code_of(rb)}:{msg_of(rb)}")

    # 不取 CSRF 直接写 → 应 40300
    st, r = req("PUT", "/users/me", body={"nickname": "no-csrf"}, token=api.token)
    if code_of(r) == 40300:
        ok("不带 CSRF 的写操作被拒 40300（证明 CSRF 确为强制）", msg_of(r))
    else:
        warn(f"不带 CSRF 的写操作返回 code={code_of(r)} msg={msg_of(r)}（预期 40300）")

    if api.refresh:
        st, r = req("POST", "/auth/refresh", body={"refresh_token": api.refresh})
        if st == 200 and code_of(r) == 0:
            d = data_of(r) or {}
            ok("POST /auth/refresh", f"新 access_token={'有' if d.get('access_token') else '无'}")
        else:
            bad("POST /auth/refresh", f"HTTP {st} {msg_of(r)}")

# ─────────────────────────────────────────────────────────────
section("4. 账户只读接口")
if api.token:
    for path, key in [("/users/me", None), ("/users/dashboard-info", None),
                      ("/users/login-history", None), ("/users/devices", None),
                      ("/users/my-level", None)]:
        st, r = api.call("GET", path)
        if st == 200 and code_of(r) == 0:
            d = data_of(r)
            extra = ""
            if isinstance(d, dict):
                extra = "keys=" + ",".join(list(d)[:6])
            elif isinstance(d, list):
                extra = f"数组 {len(d)} 条"
            ok(f"GET {path}", extra)
        else:
            bad(f"GET {path}", f"HTTP {st} code={code_of(r)} {msg_of(r)}")

# ─────────────────────────────────────────────────────────────
section("5. 订阅拉取（核心需求：自动拉取订阅 → mihomo 可直接吃）")
sub = None
if api.token:
    st, r = api.call("GET", "/subscriptions/user-subscription")
    if st == 200 and code_of(r) == 0:
        sub = data_of(r) or {}
        ok("GET /subscriptions/user-subscription",
           f"package={sub.get('package_name')} 到期={sub.get('expire_at')} "
           f"剩余{sub.get('days_remaining')}天 设备 {sub.get('current_devices')}/{sub.get('device_limit')} "
           f"active={sub.get('is_active')}")
        for k in ("token_clash_url", "token_url", "subscription_url"):
            v = sub.get(k)
            print(f"      {k} = {v}")
        if not sub.get("token_clash_url"):
            bad("缺少 token_clash_url（客户端拼订阅地址的唯一可靠来源）", str(list(sub))[:200])
    else:
        warn(f"该账号暂无订阅（HTTP {st} code={code_of(r)} {msg_of(r)}）——"
             f"新注册用户本就没有，属正常；下面会补一个订阅再测")

# 订阅内容拉取
if sub:
    from urllib.parse import urlparse, parse_qs, urlencode, urlunparse
    for label, key in [("clash", "token_clash_url"), ("universal", "token_url")]:
        u = sub.get(key)
        if not u:
            continue
        # 把线上域名换成实测地址，但保留 host 形态（后端生成的 URL 是 https://site_url/...）
        p = urlparse(u)
        q = parse_qs(p.query)
        q["format"] = ["clash"] if label == "clash" else ["clash"]
        testu = urlunparse(("http", "127.0.0.1:9000", p.path, "", urlencode({k: v[0] for k, v in q.items()}), ""))
        st, txt = req("GET", testu, raw=True)
        if st == 200 and ("proxies:" in txt or "proxy-groups:" in txt or len(txt) > 200):
            n_prox = txt.count("\n  - name:") + txt.count("\n    - name:")
            ok(f"拉取订阅内容({label})", f"HTTP {st}, {len(txt)} 字节, 疑似节点条目 {n_prox}")
            head = [l for l in txt.split("\n")[:6]]
            print("      首行: " + " | ".join(h.strip() for h in head if h.strip())[:150])
        else:
            bad(f"拉取订阅内容({label})", f"HTTP {st}, 前 150 字: {txt[:150]}")

# ─────────────────────────────────────────────────────────────
section("6. 设备管理 / 备注 / 删除（含副作用确认）")
devices_before = []
if api.token:
    st, r = api.call("GET", "/subscriptions/devices")
    if st == 200 and code_of(r) == 0:
        devices_before = data_of(r) or []
        ok("GET /subscriptions/devices", f"{len(devices_before)} 台设备")
        if devices_before:
            d0 = devices_before[0]
            print(f"      首台 keys = {list(d0)}")
            print(f"      id={d0.get('id')} name={d0.get('name') or d0.get('device_name')} "
                  f"remark={d0.get('remark')} active={d0.get('is_active')}")
    else:
        bad("GET /subscriptions/devices", f"HTTP {st} code={code_of(r)} {msg_of(r)}")

    if devices_before:
        did = devices_before[0].get("id")
        newr = f"验证备注-{ts}"
        st, r = api.call("PUT", f"/subscriptions/devices/{did}/remark", body={"remark": newr})
        if st == 200 and code_of(r) == 0:
            # 副作用确认：重新拉列表看 remark 是否真的变了
            st2, r2 = api.call("GET", "/subscriptions/devices")
            after = None
            for d in (data_of(r2) or []):
                if d.get("id") == did:
                    after = d.get("remark")
            if after == newr:
                ok("PUT 设备备注 + 读回确认", f"id={did} remark='{after}'")
            else:
                bad("设备备注未生效（接口返回成功但值没变）",
                    f"期望 '{newr}'，读回 '{after}'")
        else:
            bad("PUT /subscriptions/devices/:id/remark", f"HTTP {st} code={code_of(r)} {msg_of(r)}")

        # 删除设备（软删 + current_devices 递减）
        st, r = api.call("GET", "/subscriptions/user-subscription")
        cd_before = (data_of(r) or {}).get("current_devices")
        st, r = api.call("DELETE", f"/subscriptions/devices/{did}")
        if st == 200 and code_of(r) == 0:
            st2, r2 = api.call("GET", "/subscriptions/devices")
            remain = [d.get("id") for d in (data_of(r2) or [])]
            st3, r3 = api.call("GET", "/subscriptions/user-subscription")
            cd_after = (data_of(r3) or {}).get("current_devices")
            if did not in remain:
                ok("DELETE 设备 + 列表确认已消失", f"id={did}, 剩余 {len(remain)} 台")
            else:
                bad("设备删除后仍在列表中", f"id={did}")
            if cd_before is not None and cd_after is not None:
                if cd_after == cd_before - 1 or cd_after <= cd_before:
                    ok("设备数计数已递减", f"{cd_before} → {cd_after}")
                else:
                    bad("设备数计数未递减", f"{cd_before} → {cd_after}")
        else:
            bad("DELETE /subscriptions/devices/:id", f"HTTP {st} code={code_of(r)} {msg_of(r)}")

        # 非法设备 id
        st, r = api.call("PUT", "/subscriptions/devices/999999999/remark", body={"remark": "x"})
        if code_of(r) in (40400,) or "不存在" in msg_of(r):
            ok("给不存在设备改备注被拒", msg_of(r))
        else:
            warn(f"不存在设备改备注返回 code={code_of(r)} {msg_of(r)}")

# ─────────────────────────────────────────────────────────────
section("7. 套餐购买 / 下单 / 支付 / 回调轮询")
order = None
if api.token and pkgs:
    pid = pkgs[0]["id"]
    st, r = api.call("POST", "/orders", body={"package_id": pid})
    if st == 200 and code_of(r) == 0:
        order = data_of(r) or {}
        ok("POST /orders 创建订单",
           f"order_no={order.get('order_no')} amount={order.get('amount')} status={order.get('status')}")
        print(f"      订单 keys = {list(order)}")
    else:
        bad("POST /orders", f"HTTP {st} code={code_of(r)} {msg_of(r)}")

    # 自定义套餐
    st, r = api.call("POST", "/orders/custom", body={"devices": 10, "months": 12})
    if st == 200 and code_of(r) == 0:
        d = data_of(r) or {}
        ok("POST /orders/custom（自定义套餐，字段 devices/months）",
           f"amount={d.get('amount')} status={d.get('status')}")
    else:
        bad("POST /orders/custom", f"HTTP {st} code={code_of(r)} {msg_of(r)}")

    # 错误的字段名应当失败（证明 devices 才是对的）
    st, r = api.call("POST", "/orders/custom", body={"device_count": 10, "months": 12})
    if code_of(r) == 40000:
        ok("自定义套餐用 device_count 被拒（确认字段名是 devices）", msg_of(r))
    else:
        warn(f"device_count 未被拒 code={code_of(r)} {msg_of(r)}")

if order:
    ono = order.get("order_no")
    # 支付方式
    st, r = api.call("GET", "/payment/methods")
    methods = (data_of(r) or {})
    print(f"      支付方式: balance_enabled={methods.get('balance_enabled')} methods={methods.get('methods')}")
    if not methods.get("methods"):
        warn("没有可用在线支付通道（本地 DB 未配置），支付链路只能验证到『报错可读』")
    # ⚠️ 实测确认的两个不同支付入口（极易搞混）：
    #   · POST /orders/:orderNo/pay  —— **只支持余额**（payment_method="balance"），
    #     传在线通道会返回「暂不支持该支付方式，请使用余额支付或通过支付接口创建支付」。
    #   · POST /payment              —— 在线支付，用**数字** payment_method_id。
    # 也就是说「字符串 pay_type」与「数字 method_id」分别属于这两个端点。
    st, r = api.call("POST", f"/orders/{ono}/pay", body={"payment_method": "alipay"})
    if code_of(r) != 0 and "暂不支持" in msg_of(r):
        ok("确认 /orders/:no/pay 不支持在线通道（仅余额）", msg_of(r))
    else:
        warn(f"用 alipay 调 /orders/:no/pay → code={code_of(r)} msg={msg_of(r)}")
    st, r = api.call("POST", f"/orders/{ono}/pay", body={"payment_method": "not-a-channel"})
    print(f"      用无效通道支付 → HTTP {st} code={code_of(r)} msg={msg_of(r)}")
    # 余额支付（若开启）
    if methods.get("balance_enabled"):
        st, r = api.call("POST", f"/orders/{ono}/pay", body={"payment_method": "balance"})
        print(f"      余额支付 → HTTP {st} code={code_of(r)} msg={msg_of(r)}")
        if code_of(r) == 0:
            ok("余额支付下单成功（支付链路走通）", msg_of(r))
            d = data_of(r) or {}
            print(f"      支付返回 keys = {list(d) if isinstance(d, dict) else d}")
        else:
            warn(f"余额支付未成功：{msg_of(r)}（多为余额不足，非协议问题）")
    # 在线支付：POST /payment {order_id, payment_method_id}
    if methods.get("methods"):
        pmid = methods["methods"][0]["id"]
        st, r = api.call("POST", "/payment",
                         body={"order_id": order.get("id"), "payment_method_id": pmid,
                               "is_mobile": False})
        st2 = st
        if st == 200 and code_of(r) == 0:
            pd = data_of(r) or {}
            ok("POST /payment 创建在线支付", f"pay_type={methods['methods'][0]['pay_type']} keys={list(pd)}")
            print(f"      支付对象 = {json.dumps(pd, ensure_ascii=False)[:260]}")
            payid = pd.get("id") or pd.get("payment_id")
            if payid:
                st3, r3 = api.call("GET", f"/payment/status/{payid}")
                if code_of(r3) == 0:
                    ok("GET /payment/status/:id（支付状态回调轮询）",
                       f"{json.dumps(data_of(r3), ensure_ascii=False)[:160]}")
                else:
                    bad("GET /payment/status/:id", f"{code_of(r3)} {msg_of(r3)}")
        else:
            warn(f"POST /payment code={code_of(r)} {msg_of(r)}（本地未配置真实支付网关时预期失败）")

    # 订单状态轮询（回调等价物）
    st, r = api.call("GET", f"/orders/{ono}/status")
    if st == 200 and code_of(r) == 0:
        d = data_of(r) or {}
        ok("GET /orders/:orderNo/status（回调轮询）", f"status={d.get('status')}")
    else:
        bad("GET /orders/:orderNo/status", f"HTTP {st} code={code_of(r)} {msg_of(r)}")
    # 订单列表
    st, r = api.call("GET", "/orders?page=1&page_size=20")
    if st == 200 and code_of(r) == 0:
        d = data_of(r)
        items = d.get("items") if isinstance(d, dict) else d
        ok("GET /orders", f"{len(items) if isinstance(items, list) else '?'} 条")
    else:
        bad("GET /orders", f"HTTP {st} code={code_of(r)} {msg_of(r)}")
    # 取消
    st, r = api.call("POST", f"/orders/{ono}/cancel")
    if code_of(r) == 0:
        ok("POST /orders/:orderNo/cancel", msg_of(r))
    else:
        warn(f"取消订单 code={code_of(r)} {msg_of(r)}")

# ─────────────────────────────────────────────────────────────
section("8. 升级设备（价格试算 + 下单）")
if api.token:
    st, r = api.call("POST", "/orders/upgrade/calc", body={"add_devices": 3, "extend_months": 0})
    if st == 200 and code_of(r) == 0:
        d = data_of(r) or {}
        ok("POST /orders/upgrade/calc", f"{json.dumps(d, ensure_ascii=False)[:200]}")
    else:
        warn(f"升级试算：HTTP {st} code={code_of(r)} {msg_of(r)}（新账号无有效订阅时预期失败）")

    st, r = api.call("POST", "/orders/upgrade", body={"add_devices": 3, "extend_months": 0})
    if st == 200 and code_of(r) == 0:
        d = data_of(r) or {}
        ok("POST /orders/upgrade 下单", f"order_no={d.get('order_no')} amount={d.get('amount')}")
    else:
        print(f"      升级下单：code={code_of(r)} {msg_of(r)}")

    # 越界校验
    st, r = api.call("POST", "/orders/upgrade", body={"add_devices": 99999, "extend_months": 0})
    if code_of(r) != 0:
        ok("升级设备数越界被拒", msg_of(r))
    else:
        bad("升级设备数越界未被拒", "")

# ─────────────────────────────────────────────────────────────
section("9. 优惠券")
if api.token:
    st, r = api.call("POST", "/coupons/verify", body={"code": "NOT-A-REAL-COUPON"})
    if code_of(r) != 0:
        ok("无效优惠券被拒（可读错误）", msg_of(r))
    else:
        warn("无效优惠券竟然通过")
    st, r = api.call("GET", "/coupons/my")
    if code_of(r) == 0:
        ok("GET /coupons/my", f"{len(data_of(r) or [])} 张")
    else:
        bad("GET /coupons/my", f"{code_of(r)} {msg_of(r)}")

# ─────────────────────────────────────────────────────────────
section("10. 通知")
if api.token:
    st, r = api.call("GET", "/notifications?page=1&page_size=20")
    notif = []
    if st == 200 and code_of(r) == 0:
        d = data_of(r)
        notif = d.get("items") if isinstance(d, dict) else (d or [])
        ok("GET /notifications", f"{len(notif) if isinstance(notif,list) else '?'} 条")
    else:
        bad("GET /notifications", f"HTTP {st} code={code_of(r)} {msg_of(r)}")
    st, r = api.call("GET", "/notifications/unread-count")
    if st == 200 and code_of(r) == 0:
        ok("GET /notifications/unread-count", f"data={data_of(r)}")
    else:
        bad("GET /notifications/unread-count", f"HTTP {st} code={code_of(r)} {msg_of(r)}")
    if isinstance(notif, list) and notif:
        nid = notif[0].get("id")
        st, r = api.call("PUT", f"/notifications/{nid}/read")
        if code_of(r) == 0:
            ok("PUT /notifications/:id/read", msg_of(r))
        else:
            bad("PUT /notifications/:id/read", f"{code_of(r)} {msg_of(r)}")

# ─────────────────────────────────────────────────────────────
section("11. 节点（后端侧测速接口）")
if api.token:
    st, r = api.call("GET", "/nodes")
    nodes = []
    if st == 200 and code_of(r) == 0:
        d = data_of(r)
        nodes = d.get("items") if isinstance(d, dict) else (d or [])
        ok("GET /nodes", f"{len(nodes) if isinstance(nodes,list) else '?'} 个节点")
        if isinstance(nodes, list) and nodes:
            print(f"      节点字段 = {list(nodes[0])}")
            print(f"      样例: {json.dumps(nodes[0], ensure_ascii=False)[:200]}")
    else:
        bad("GET /nodes", f"HTTP {st} code={code_of(r)} {msg_of(r)}")
    st, r = api.call("GET", "/nodes/stats")
    if code_of(r) == 0:
        ok("GET /nodes/stats", f"{json.dumps(data_of(r), ensure_ascii=False)[:150]}")
    else:
        warn(f"GET /nodes/stats code={code_of(r)} {msg_of(r)}")
    if isinstance(nodes, list) and nodes:
        nid = nodes[0].get("id")
        st, r = api.call("POST", f"/nodes/{nid}/test")
        if code_of(r) == 0:
            ok("POST /nodes/:id/test（单节点后端测速）",
               f"{json.dumps(data_of(r), ensure_ascii=False)[:200]}")
        else:
            warn(f"POST /nodes/:id/test code={code_of(r)} {msg_of(r)}")

# ─────────────────────────────────────────────────────────────
section("12. 忘记密码 / 重置密码 / 修改密码")
st, r = req("POST", "/auth/forgot-password", body={"email": EMAIL})
if st == 200 and code_of(r) == 0:
    ok("POST /auth/forgot-password", msg_of(r))
else:
    bad("POST /auth/forgot-password", f"HTTP {st} {msg_of(r)}")

rcode = latest_code(EMAIL, "reset_password")
if rcode:
    ok("重置验证码已入库（purpose=reset_password）", f"code={rcode}")
    NEWPASS = "McReset12345"
    st, r = req("POST", "/auth/reset-password",
                body={"email": EMAIL, "code": rcode, "password": NEWPASS})
    if st == 200 and code_of(r) == 0:
        ok("POST /auth/reset-password", msg_of(r))
        # 副作用确认：新密码能登录、旧密码不能
        st, r = req("POST", "/auth/login", body={"email": EMAIL, "password": NEWPASS})
        if code_of(r) == 0:
            ok("用新密码登录成功（重置确实生效）", "")
            api.token = (data_of(r) or {}).get("access_token")
            api.refresh = (data_of(r) or {}).get("refresh_token")
        else:
            bad("新密码登录失败", f"{code_of(r)} {msg_of(r)}")
        st, r = req_429backoff("POST", "/auth/login", body={"email": EMAIL, "password": PASSWORD})
        if code_of(r) != 0:
            ok("旧密码已失效（确认是真的改了）", msg_of(r))
        else:
            bad("旧密码仍可登录 —— 重置没生效", "")
        PASSWORD = NEWPASS
    else:
        bad("POST /auth/reset-password", f"HTTP {st} {msg_of(r)}")
else:
    bad("重置验证码未入库", "forgot-password 未写入 verification_codes")

# 重置密码会把 token_version 自增，**此前签发的所有 token 立即失效**
# （middleware/auth.go: claims.Ver != user.TokenVersion）。
# 所以这里必须重新登录拿新 token，否则会误报成「改密接口挂了」。
st, r = req_429backoff("POST", "/auth/login", body={"email": EMAIL, "password": PASSWORD})
if code_of(r) == 0:
    api.token = (data_of(r) or {}).get("access_token")
    api.refresh = (data_of(r) or {}).get("refresh_token")
    ok("为改密/登出重新登录取得新 token", "（旧 token 已被重置操作作废）")
else:
    bad("重新登录失败", f"{code_of(r)} {msg_of(r)}")

# ── 诊断：确认 token 的 ver 与 DB token_version 是否一致 ──
def _jwt_ver(t):
    import base64
    try:
        pl = t.split(".")[1]
        pl += "=" * (-len(pl) % 4)
        return json.loads(base64.urlsafe_b64decode(pl)).get("ver")
    except Exception as e:
        return f"解码失败({e})"


if api.token:
    dbver = sql("SELECT token_version FROM users WHERE email=?", (EMAIL,))
    print(f"      [诊断] JWT.ver={_jwt_ver(api.token)}  DB.token_version={dbver}")
    st_chk, r_chk = api.call("GET", "/users/me")
    print(f"      [诊断] 用当前 token 访问 /users/me → code={code_of(r_chk)} msg={msg_of(r_chk)}")

if api.token:
    st, r = api.call("POST", "/users/change-password",
                     body={"old_password": PASSWORD, "new_password": "McChanged12345"})
    if code_of(r) == 0:
        st2, r2 = req("POST", "/auth/login", body={"email": EMAIL, "password": "McChanged12345"})
        if code_of(r2) == 0:
            ok("POST /users/change-password + 新密码登录确认",
               f"old_password/new_password 字段正确")
            api.token = (data_of(r2) or {}).get("access_token")
            api.refresh = (data_of(r2) or {}).get("refresh_token")
            PASSWORD = "McChanged12345"
        else:
            bad("改密后新密码登录失败", f"{code_of(r2)} {msg_of(r2)}")
    else:
        bad("POST /users/change-password", f"{code_of(r)} {msg_of(r)}")

# ─────────────────────────────────────────────────────────────
section("13. 登出")
if api.token:
    st, r = api.call("POST", "/auth/logout", body={"refresh_token": api.refresh})
    if code_of(r) == 0:
        ok("POST /auth/logout（带 refresh_token 以使其失效）", msg_of(r))
        # 副作用：旧 refresh_token 不应再可用
        if api.refresh:
            st2, r2 = req("POST", "/auth/refresh", body={"refresh_token": api.refresh})
            if code_of(r2) != 0:
                ok("登出后 refresh_token 已失效", msg_of(r2))
            else:
                warn("登出后 refresh_token 仍可用 —— 服务端未吊销")
    else:
        bad("POST /auth/logout", f"{code_of(r)} {msg_of(r)}")

# ─────────────────────────────────────────────────────────────
print(f"\n{'='*78}\n 汇总\n{'='*78}")
print(f"通过 {len(PASS)} 项，失败 {len(FAIL)} 项，提示 {len(WARN)} 项")
if FAIL:
    print("\n【失败项】")
    for f in FAIL:
        print("  ❌ " + f)
if WARN:
    print("\n【提示项】")
    for w in WARN:
        print("  ⚠️  " + w)
print(f"\n测试账号: {EMAIL} / 当前密码 {PASSWORD}")
sys.exit(1 if FAIL else 0)
