# Mclash 客户端全面代码审查报告

日期：2026-11-04
范围：`lib/`、`packages/libclash_vpn_service/`、Windows 安装包、Android 插件
方法：静态审查 + 针对性回归测试（未做 Windows / Android / macOS 真机端到端）

---

## 0. 结论摘要

本轮确认并修复了 **7 类可证实缺陷**，新增 35 条回归测试，全量 731 条测试通过。
其中两条属于高危：**更新包校验 fail-open**、**会话令牌竞态**。

但 **Windows TUN 的权限与进程所有权模型存在设计级缺陷**，不能靠隐藏控制台窗口解决，
也不应继续宣称当前安装包在 TUN 上"已修复"。详见第 3 节。

**本轮未发版。** 现有 release 不应被描述为已修复上述 Windows 问题。

---

## 1. 已修复

### 1.1 更新包完整性校验 fail-open — 高

- 现象：`sha256` 拉取失败被当成空值，而空值被当作"已校验"放行；镜像文件因此可被安装。
- 现象：安装包在哈希校验**之前**已落到最终路径，`checkReplace()` 只看文件是否存在；
  哈希中途失败或崩溃后，错误包会被永久复用。
- 现象：首个下载源返回 404 会中断整个候选链并清空版本元数据。
- 修复：强制合法 64 位十六进制 SHA-256；复用与安装前重新计算哈希；
  下载到独立 staging 目录，校验通过才提升到最终路径；404 继续尝试后续源。
- 测试：`test/auto_update_manager_verification_test.dart`（7 条）。

### 1.2 会话/令牌竞态 — 高

- 现象：`_refreshOnce` 的 `.timeout` 不会取消底层请求；旧的刷新在登出后完成会把会话"复活"，
  在切换账号后完成会把 A 的令牌写到 B 的会话上。
- 现象：账号刷新没有会话代际校验，旧响应可回填缓存、旧 401 会登出新账号。
- 修复：统一会话 generation，登录/登出/保存/清理时作废在途请求；
  超时显式撤销迟到结果的提交权；账号刷新校验会话 + 代际 + 操作归属。
- 测试：`test/mf/session_lifecycle_test.dart`（10 条）。

### 1.3 卸载忽略"保留用户数据" — 中

- 现象：`[UninstallDelete]` 无条件删除 `%APPDATA%\mclash` 等目录，
  绕过了 `CurUninstallStepChanged` 里的 `PreserveUserData` 判断。
- 修复：移除声明式删除，仅由受 `if not PreserveUserData then` 保护的代码删除。
- 测试：`test/windows_installer_preserve_data_test.dart`。

### 1.4 模式切换一致性 — 中

- 规则注入会选中成员全是 `DIRECT/REJECT` 的选择器，导致"走代理"的规则实际直连。
- TUN 切换重启失败时回滚值是凭空构造的 `off/auto`，而不是真实的历史值。
- Android 分支丢弃内核重启错误。
- 首页分段切换无并发保护、失败后不回滚、监听未 dispose。
- 修复：规则目标要求"确有代理能力"并支持嵌套组/供应商，前缀注入可幂等修复；
  TUN 同值 no-op + 精确回滚；Android 错误上抛；首页串行化 + 乐观状态回滚 + 解除监听。
- 测试：`test/libclash_vpn_service/always_proxy_rules_regression_test.dart` 等，
  针对性 47 条通过。

### 1.5 轮询重叠与资源泄漏 — 中

- 首页 2s 状态检查可重叠；延迟连接重试链会在 pause/dispose 后重新安装定时器。
- 付款页 3s 轮询与 resume/手动检查重叠，可能重复弹出路由；resume 忽略 15 分钟自动超时。
- 修复：单飞 + mounted/generation 守卫 + finally 释放；付款页合并请求并尊重超时。
- 测试：`test/screens/mclash_payment_polling_test.dart`。

### 1.6 订阅更新守卫永久占用 — 中

- 现象：`ProfileManager.update` 先占住 `updating` 集合，HWID 提前返回/异常路径不释放，
  该订阅直到重启前都无法再更新。
- 修复：获取守卫后统一 `try/finally` 释放，并覆盖异步清理阶段。
- 测试：`test/profile_manager_update_lifecycle_test.dart`（8 条，真实 loopback HTTP）。

### 1.7 系统代理自愈入口是死代码 — 高

- 现象：`Biz.restoreSystemProxyIfStale()` 定义完整却**没有任何调用点**。
  崩溃 / 强制结束 / macOS `Cmd+Q` 后，系统代理仍指向已消失的本机端口，
  浏览器与多数 App 表现为"整个网络不可用"，且不会自愈。
- 修复：在 `Biz.init()` 中、`VPNService.init()` 之后调用它（此时内核必然未运行）。
- 测试：`test/stale_system_proxy_wiring_test.dart`（静态接线守卫，防止再次退化为死代码）。

### 1.8 TUN 计划任务脚本语法错误（VM 实测）— 高

- 现象：安装包与 App 生成的 `kernel_host.vbs` 在每段路径两端都用三连引号，
  第一个字符串在 `-d` 之前就结束。Windows 11 虚拟机 `cscript //B` 实测：
  - 旧生成结果 → **exit=1（语法错误）**
  - 正确引号写法 → **exit=0**
  即「计划任务启动内核」这条路径**从未成功过**，且 `wscript` 遇到语法错误会弹
  脚本错误框 —— 这也是用户反复看到窗口弹出的来源之一。
- 修复：把 VBS 生成抽成纯函数 `buildKernelHostVbs` / `buildKernelWatchVbs`
  （`packages/libclash_vpn_service/lib/src/kernel_vbs.dart`），
  安装包同步改为 `QQ := Q + Q; QQQ := Q + Q + Q;` 只开一个字符串。
- 验证：Dart 生成的脚本在 VM 上 `cscript //B` **exit=0**；
  观察者脚本 `kernel_watch.vbs` 语法有效（进入等待循环）；
  安装包创建的任务动作为 `wscript.exe` + 正确脚本路径。
- 测试：`test/libclash_vpn_service/kernel_vbs_test.dart`（6 条）。

### 1.9 Android 授权回调生命周期 — 中

- 现象：并发 `prepare` 覆盖 `pendingResult`；detach 不清理 Activity 监听、不结束挂起请求。
- 修复：并发 prepare 返回 false 且不覆盖原请求；所有 detach 路径移除监听并结束请求；
  配置变更保留挂起请求并重新绑定。
- 测试：`packages/libclash_vpn_service/android/src/test/plugin_lifecycle_test.py`
  （真实 Kotlin 插件 + JVM 假实现，仅验证控制流）。

---

## 2. 验证结果

| 项目 | 结果 |
|---|---|
| `flutter analyze --no-pub` | No issues found |
| `flutter test --no-pub` | **738 / 738 通过**（基线 696，新增 42） |
| Android 插件宿主 JVM 回归 | PASS |
| `git diff --check` | 通过 |
| `flutter build macos --debug` | 构建成功，启动/退出冒烟正常 |
| 生成的 sudoers 内容 `visudo -cf` | parsed OK |
| 生成的 `kernel_host.vbs` `cscript //B` | exit=0（修复前 exit=1） |
| 计划任务注册结果 | `wscript.exe` + 正确脚本路径 |

---

## 3. 未修复：设计级问题（建议作为发布门槛）

### 3.1 高权限任务执行用户可写脚本 — 高

`windows/packaging/exe/inno_setup.iss:250-291` 与 `lib/app/local_services/vpn_service.dart:1035-1107`
都会把 `kernel_host.vbs` 写到 `%APPDATA%\mclash\mclash\`，再注册最高权限任务执行它。
同一用户的中完整性进程可替换该脚本，下次任务触发即以高权限执行。
这是权限边界问题，改脚本引号或换成 `wscript` 都无法消除。

### 3.2 任务存在 23:59 定时触发 — 中

`/SC ONCE /ST 23:59` 是真实时间触发器，与"用户点击才启动"的语义不符；
若脚本被替换，可在当天 23:59 无用户意图地提权执行。

### 3.3 内核身份按进程名推断 — 中

`desktop_impl.dart:509-535` 取系统里第一个 `mihomo.exe`，并等待"所有 mihomo 消失"。
其他客户端的内核会掩盖自身内核退出；PID 文件可被用户改写。
UAC 路径只在 8 秒内读取 PID，超时同意后高权限子进程完全脱离应用管理。

### 3.4 高权限内核日志未捕获 — 中

`desktop_impl.dart:655-656` 的 stdout/stderr 属于观察者脚本而非内核，
`_applyDataPathFallback` 却据此判断 TUN 是否启动，可能出现"内核健康但被判定失败并切系统代理"。

### 3.5 卸载按镜像名杀进程 — 低

`inno_setup.iss:96-97` 的 `/IM mihomo.exe` 会误杀其他客户端的内核。

### 3.6 macOS `Cmd+Q` 退出不经过 Dart 清理 — 中（部分缓解）

`applicationWillTerminate` 原本为空，Dart 的断开清理不会执行 → 内核成为 root 孤儿，
TUN 继续接管流量。

已做：
- `AppDelegate.applicationWillTerminate` 按**内核绝对路径**执行
  `sudo -n pkill -f <kernel>`（三个候选路径，绝不用进程名通配）。
- `MacTunHelper.grant()` 的 sudoers 规则新增 `pkill -f` / `pkill -9 -f` 授权；
  已用 `visudo -cf` 验证生成的规则可解析。

限制：
- **旧用户的 sudoers 里没有 pkill 规则**，需重新授权一次该清理才生效；
  未重新授权时 `sudo -n` 会失败（静默跳过，不影响退出）。
- 内核被清理后，系统代理依赖下一轮启动的自愈（见 1.7）。

### 3.7 配置合并不是能力白名单 — 设计风险

`kernel_config.dart:593-644` 直接合并订阅 profile 与 patch 后交给高权限内核，
没有对可执行钩子/插件/任意路径等能力做白名单过滤。

**注意**：1.8 修复的是"脚本语法错误"，不改变 3.1 的权限边界结论 ——
脚本仍然是用户可写的，只是现在它能跑起来了。

**建议方向**：改为受保护目录中的原生 broker 服务 + 受限命名管道 IPC，
由服务创建内核（`CREATE_NO_WINDOW` + Job Object），按实例 ID 停止，
只暴露类型化操作，不接受任意命令/路径/PID；彻底移除计划任务与用户可写脚本。

---

## 4. 尚未验证的内容

- 未在 Windows 实机验证 TUN 启动/停止、UAC 迟到同意、任务注册失败等场景。
- 未在 Android 真机/模拟器验证授权弹窗生命周期（仅 JVM 假实现控制流）。
- 未做 macOS 原生生命周期专项审查。
- 未做 CPU/内存/网络基准，因此不给出"更流畅"的量化结论。

## 5. 建议的下一步

1. 先落地第 3 节的 broker 架构，再对 TUN 做一次完整真机验收（含失败注入）。
2. 需要更快止损时，可先发一个**禁用旧提权路径、仅保留系统代理**的版本，
   并引导用户卸载并删除旧的 `Mclash Kernel` 任务。
3. 完成后再统一发版，避免把"隐藏了窗口"误当成"解决了权限模型问题"。
