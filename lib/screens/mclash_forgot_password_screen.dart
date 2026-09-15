/// 忘记密码 / 重置密码（M-10）。
///
/// 两步同页：先发验证码，再提交「验证码 + 新密码」。
///
/// 后端行为（`internal/api/handlers/auth.go`，已实测）：
///   · `POST /auth/forgot-password {email}` —— 对**不存在的邮箱也返回成功**，
///     文案固定「如果邮箱存在，重置链接已发送」。这是防账号枚举的正确做法，
///     所以界面**不能**说「已发送到你的邮箱」，只能照实说「如果该邮箱已注册…」。
///   · 重置码有效期 **15 分钟**（注册码只有 5 分钟），同邮箱 15 分钟内最多 3 次。
///   · `POST /auth/reset-password {email, code, password}` 成功后会把
///     `token_version` 自增 → 所有旧 token 立即失效（客户端会被踢回登录页）。
///   · 密码策略与注册一致：≥8 位且含字母和数字（见 PasswordPolicy）。
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mclash/mf/mclash_api.dart';
import 'package:mclash/mf/password_policy.dart';
import 'package:mclash/screens/dialog_utils.dart';
import 'package:mclash/screens/theme_config.dart';
import 'package:mclash/screens/theme_define.dart';
import 'package:mclash/screens/widgets/framework.dart';

class MclashForgotPasswordScreen extends LasyRenderingStatefulWidget {
  const MclashForgotPasswordScreen({super.key, this.email = ""});

  /// 从登录页带过来的邮箱，省得用户再输一遍。
  final String email;

  @override
  State<MclashForgotPasswordScreen> createState() =>
      _MclashForgotPasswordScreenState();
}

class _MclashForgotPasswordScreenState
    extends LasyRenderingState<MclashForgotPasswordScreen> {
  late final TextEditingController _email =
      TextEditingController(text: widget.email);
  final _code = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  bool _busy = false;
  bool _sending = false;
  bool _codeSent = false;
  String? _err;
  String? _info;

  int _countdown = 0;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    _email.dispose();
    _code.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: PreferredSize(preferredSize: Size.zero, child: AppBar()),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: const SizedBox(
                      width: 50,
                      height: 44,
                      child: Icon(Icons.arrow_back_ios_outlined, size: 26),
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      "找回密码",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: ThemeConfig.kFontWeightTitle,
                        fontSize: ThemeConfig.kFontSizeTitle,
                      ),
                    ),
                  ),
                  const SizedBox(width: 50, height: 44),
                ],
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  children: [
                    const SizedBox(height: 8),
                    TextField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      enabled: !_codeSent,
                      decoration: const InputDecoration(labelText: "注册邮箱"),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _code,
                            keyboardType: TextInputType.number,
                            decoration:
                                const InputDecoration(labelText: "邮箱验证码"),
                          ),
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          height: 48,
                          child: OutlinedButton(
                            onPressed:
                                (_sending || _countdown > 0) ? null : _sendCode,
                            child: Text(
                                _countdown > 0 ? "${_countdown}s" : "获取验证码"),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _password,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: "新密码"),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      PasswordPolicy.hint(),
                      style: const TextStyle(
                        fontSize: 12,
                        color: ThemeDefine.kColorGrey,
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _confirm,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: "确认新密码"),
                    ),
                    if (_info != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(
                          _info!,
                          style: const TextStyle(
                            fontSize: 13,
                            color: ThemeDefine.kColorGrey,
                          ),
                        ),
                      ),
                    if (_err != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          _err!,
                          style:
                              const TextStyle(color: Colors.red, fontSize: 13),
                        ),
                      ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _busy ? null : _submit,
                        child: _busy
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text("重置密码"),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startCountdown() {
    setState(() => _countdown = 60);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() => _countdown--);
      if (_countdown <= 0) {
        t.cancel();
      }
    });
  }

  Future<void> _sendCode() async {
    final email = _email.text.trim();
    if (email.isEmpty || !email.contains("@")) {
      setState(() => _err = "请填写有效邮箱");
      return;
    }
    setState(() {
      _sending = true;
      _err = null;
    });
    try {
      await MclashApi.forgotPassword(email);
      if (!mounted) return;
      setState(() {
        _sending = false;
        _codeSent = true;
        // 防枚举：后端对未注册邮箱也返回成功，所以只能说「如果已注册」。
        _info = "如果该邮箱已注册，重置验证码已发送（15 分钟内有效）。";
      });
      _startCountdown();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _sending = false;
        _err = "$e";
      });
    }
  }

  Future<void> _submit() async {
    final email = _email.text.trim();
    if (email.isEmpty || !email.contains("@")) {
      setState(() => _err = "请填写有效邮箱");
      return;
    }
    if (_code.text.trim().isEmpty) {
      setState(() => _err = "请填写邮箱验证码");
      return;
    }
    final pwdErr = PasswordPolicy.validate(_password.text);
    if (pwdErr != null) {
      setState(() => _err = pwdErr);
      return;
    }
    if (_password.text != _confirm.text) {
      setState(() => _err = "两次输入的密码不一致");
      return;
    }

    setState(() {
      _busy = true;
      _err = null;
    });
    try {
      await MclashApi.resetPassword(
        email: email,
        code: _code.text.trim(),
        password: _password.text,
      );
      if (!mounted) return;
      await DialogUtils.showAlertDialog(context, "密码已重置，请用新密码登录");
      if (!mounted) return;
      // 重置会让所有旧 token 失效，回到登录页重登才是正确归宿。
      Navigator.of(context).popUntil((r) => r.isFirst);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _err = "$e";
      });
    }
  }
}
