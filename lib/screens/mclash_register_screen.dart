
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mclash/mf/mclash_api.dart';
import 'package:mclash/mf/password_policy.dart';
import 'package:mclash/screens/dialog_utils.dart';
import 'package:mclash/screens/theme_config.dart';
import 'package:mclash/screens/theme_define.dart';
import 'package:mclash/screens/widgets/framework.dart';

class MclashRegisterScreen extends LasyRenderingStatefulWidget {
  const MclashRegisterScreen({super.key, this.siteConfig = const {}});

  final Map<String, dynamic> siteConfig;

  @override
  State<MclashRegisterScreen> createState() => _MclashRegisterScreenState();
}

class _MclashRegisterScreenState
    extends LasyRenderingState<MclashRegisterScreen> {
  final _email = TextEditingController();
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _code = TextEditingController();
  final _invite = TextEditingController();

  bool _busy = false;
  bool _sending = false;
  String? _err;

  int _countdown = 0;
  Timer? _timer;

  bool get _needCode => MclashApi.registerEmailVerifyFrom(widget.siteConfig);
  bool get _needInvite => MclashApi.registerInviteRequiredFrom(widget.siteConfig);

  @override
  void dispose() {
    _timer?.cancel();
    _email.dispose();
    _username.dispose();
    _password.dispose();
    _confirm.dispose();
    _code.dispose();
    _invite.dispose();
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
                      "注册",
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
                    _field("邮箱", _email,
                        keyboard: TextInputType.emailAddress),
                    _field("用户名", _username),
                    _field("密码", _password, obscure: true),
                    Text(
                      PasswordPolicy.hint(),
                      style: const TextStyle(
                        fontSize: 12,
                        color: ThemeDefine.kColorGrey,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _field("确认密码", _confirm, obscure: true),
                    if (_needCode) _codeRow(),
                    if (_needInvite) _field("邀请码", _invite),
                    if (_err != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          _err!,
                          style: const TextStyle(
                              color: Colors.red, fontSize: 13),
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
                            : const Text("注册并登录"),
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

  Widget _field(
    String label,
    TextEditingController c, {
    bool obscure = false,
    TextInputType? keyboard,
  }) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: TextField(
          controller: c,
          obscureText: obscure,
          keyboardType: keyboard,
          decoration: InputDecoration(labelText: label),
        ),
      );

  Widget _codeRow() => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: _code,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "邮箱验证码"),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              height: 48,
              child: OutlinedButton(
                onPressed: (_sending || _countdown > 0) ? null : _sendCode,
                child: Text(_countdown > 0 ? "${_countdown}s" : "获取验证码"),
              ),
            ),
          ],
        ),
      );

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
      setState(() => _err = "请先填写有效邮箱");
      return;
    }
    setState(() {
      _sending = true;
      _err = null;
    });
    try {
      await MclashApi.sendVerificationCode(email);
      if (!mounted) return;
      setState(() => _sending = false);
      _startCountdown();
      await DialogUtils.showAlertDialog(context, "验证码已发送，请查收邮件");
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
    final username = _username.text.trim();

    if (email.isEmpty || !email.contains("@")) {
      setState(() => _err = "请填写有效邮箱");
      return;
    }
    if (username.length < 3) {
      setState(() => _err = "用户名至少 3 位");
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
    if (_needCode && _code.text.trim().isEmpty) {
      setState(() => _err = "请填写邮箱验证码");
      return;
    }
    if (_needInvite && _invite.text.trim().isEmpty) {
      setState(() => _err = "本站注册需要邀请码");
      return;
    }

    setState(() {
      _busy = true;
      _err = null;
    });
    try {

      await MclashApi.register(
        username: username,
        email: email,
        password: _password.text,
        verificationCode: _code.text.trim(),
        inviteCode: _invite.text.trim(),
      );
      if (!mounted) return;
      await DialogUtils.showAlertDialog(context, "注册成功，已自动登录");
      if (!mounted) return;

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
