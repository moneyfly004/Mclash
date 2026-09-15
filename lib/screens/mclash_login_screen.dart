/// Mclash 登录页（CBoard 账号）。
///
/// ## 为什么新写一个而不是复用 Clash Mi 的 `login_screen.dart`
///
/// Clash Mi 那套是「多面板」登录：先选面板类型（XBoard / V2Board / SSPanel-UIM），
/// 再按对应协议登录，凭据走 Cookie 会话。而 Mclash 的产品模型是
/// **只有一个自有后台**（CBoard，Bearer token），面板选择毫无意义 ——
/// 更要紧的是协议不同，那条路径对 CBoard 根本走不通。
/// 所以这里按 Clash Mi 的**视觉语言**重写，但业务走 `MclashApi`。
///
/// Clash Mi 原页面保留在树里（供「开发者选项」下的面板导入入口复用）。
///
/// ## 视觉
///
/// 沿用 Clash Mi 的登录页专属样式：登录按钮是全 App 唯一的渐变按钮
/// （`[Colors.blue, #7B5FF5]`，圆角 14，高 48）—— 这不是 MoneyFly 风格，
/// 而是 Clash Mi 设计系统里对登录页的既定例外。
library;

import 'package:flutter/material.dart';
import 'package:mclash/mf/mclash_api.dart';
import 'package:mclash/screens/mclash_forgot_password_screen.dart';
import 'package:mclash/screens/mclash_register_screen.dart';
import 'package:mclash/screens/theme_config.dart';
import 'package:mclash/screens/theme_define.dart';
import 'package:mclash/screens/widgets/framework.dart';

class MclashLoginScreen extends LasyRenderingStatefulWidget {
  const MclashLoginScreen({super.key});

  @override
  State<MclashLoginScreen> createState() => _MclashLoginScreenState();
}

class _MclashLoginScreenState extends LasyRenderingState<MclashLoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;
  bool _obscure = true;
  String? _err;

  /// 站点配置（站点名/注册开关）。登录页**不要求登录**即可取，
  /// 用它决定是否显示「注册」入口 —— 站点关了注册就不该给入口。
  Map<String, dynamic> _cfg = const {};

  @override
  void initState() {
    super.initState();
    MclashApi.siteConfig().then((c) {
      if (mounted) {
        setState(() => _cfg = c);
      }
    });
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  bool get _registerEnabled => MclashApi.registerEnabledFrom(_cfg);

  @override
  Widget build(BuildContext context) {
    final siteName = (_cfg["site_name"] ?? "").toString();
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: PreferredSize(preferredSize: Size.zero, child: AppBar()),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(28, 24, 28, 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    "Mclash",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (siteName.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      siteName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: ThemeDefine.kColorGrey,
                      ),
                    ),
                  ],
                  const SizedBox(height: 32),
                  TextField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    decoration: const InputDecoration(labelText: "邮箱"),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _password,
                    obscureText: _obscure,
                    autofillHints: const [AutofillHints.password],
                    onSubmitted: (_) => _busy ? null : _login(),
                    decoration: InputDecoration(
                      labelText: "密码",
                      suffixIcon: InkWell(
                        onTap: () => setState(() => _obscure = !_obscure),
                        child: Icon(
                          _obscure
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                  if (_err != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        _err!,
                        style: const TextStyle(
                            color: Colors.red, fontSize: 13),
                      ),
                    ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _busy ? null : _login,
                      style: ElevatedButton.styleFrom(padding: EdgeInsets.zero),
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [ThemeDefine.kColorBlue, _primaryPurple],
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Container(
                          alignment: Alignment.center,
                          child: _busy
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: RepaintBoundary(
                                    child: CircularProgressIndicator(
                                      valueColor:
                                          AlwaysStoppedAnimation<Color>(
                                              Colors.white),
                                      strokeWidth: 2,
                                    ),
                                  ),
                                )
                              : const Text(
                                  "登录",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MclashForgotPasswordScreen(
                                email: _email.text.trim(),
                              ),
                            ),
                          );
                        },
                        child: const Text(
                          "忘记密码",
                          style: TextStyle(
                            color: ThemeDefine.kColorBlue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (_registerEnabled)
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    MclashRegisterScreen(siteConfig: _cfg),
                              ),
                            );
                          },
                          child: const Text(
                            "注册",
                            style: TextStyle(
                              color: ThemeDefine.kColorBlue,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Clash Mi 登录页专属渐变第二色（设计系统里仅登录页使用）。
  static const Color _primaryPurple = Color(0xFF7B5FF5);

  Future<void> _login() async {
    final email = _email.text.trim();
    if (email.isEmpty || !email.contains("@")) {
      setState(() => _err = "请填写有效邮箱");
      return;
    }
    if (_password.text.isEmpty) {
      setState(() => _err = "请填写密码");
      return;
    }
    setState(() {
      _busy = true;
      _err = null;
    });
    try {
      // 密码策略只在**注册/重置**时强校验；登录不该拿强度规则拦人 ——
      // 老账号的密码可能早于规则变更，拦下来会让用户永远登不进去。
      await MclashApi.login(email, _password.text);
      // 登录成功后不需要在这里跳转：门禁监听了 CBoardClient.sessionChanges，
      // 会话一变就会自动切到主界面。
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _busy = false;
        _err = _friendly(e);
      });
    }
  }

  /// 把后端/网络异常转成用户看得懂的话。
  ///
  /// 后端登录失败统一返回 40100「用户名或密码错误」，不区分账号是否存在
  /// （防枚举），所以这里也不能自作聪明地区分。
  String _friendly(Object e) {
    if (e is CBoardException) {
      if (e.code == 40100 || e.httpStatus == 401) {
        return "邮箱或密码错误";
      }
      if (e.code == 40300) {
        return "请求被拒绝，请稍后重试";
      }
      if (e.httpStatus == 429) {
        return "操作过于频繁，请稍后再试";
      }
      return e.message.isEmpty ? "登录失败" : e.message;
    }
    return "$e";
  }
}
