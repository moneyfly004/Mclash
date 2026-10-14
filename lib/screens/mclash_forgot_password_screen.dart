
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mclash/i18n/strings.g.dart';
import 'package:mclash/mf/mclash_api.dart';
import 'package:mclash/mf/password_policy.dart';
import 'package:mclash/screens/dialog_utils.dart';
import 'package:mclash/screens/theme_config.dart';
import 'package:mclash/screens/theme_define.dart';
import 'package:mclash/screens/widgets/framework.dart';

class MclashForgotPasswordScreen extends LasyRenderingStatefulWidget {
  const MclashForgotPasswordScreen({super.key, this.email = ""});

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
    final t = Translations.of(context);
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
                  Expanded(
                    child: Text(
                      t.loginScreen.forgotPassword,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
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
                      decoration: InputDecoration(
                          labelText: t.authScreen.registeredEmail),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _code,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                                labelText: t.authScreen.emailCode),
                          ),
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          height: 48,
                          child: OutlinedButton(
                            onPressed:
                                (_sending || _countdown > 0) ? null : _sendCode,
                            child: Text(_countdown > 0
                                ? "${_countdown}s"
                                : t.authScreen.getCode),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _password,
                      obscureText: true,
                      decoration:
                          InputDecoration(labelText: t.authScreen.newPassword),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      t.authScreen.passwordHint(min: PasswordPolicy.kMinLength),
                      style: const TextStyle(
                        fontSize: 12,
                        color: ThemeDefine.kColorGrey,
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _confirm,
                      obscureText: true,
                      decoration: InputDecoration(
                          labelText: t.authScreen.confirmNewPassword),
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
                            : Text(t.authScreen.resetPassword),
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

  /// 密码策略校验（文案走 i18n，规则仍以 PasswordPolicy 为准）。
  String? _policyError(Translations t, String pwd) {
    final raw = PasswordPolicy.validate(pwd);
    if (raw == null) {
      return null;
    }
    if (pwd.length < PasswordPolicy.kMinLength) {
      return t.authScreen.passwordTooShort(min: PasswordPolicy.kMinLength);
    }
    return t.authScreen.passwordNeedsLetterAndDigit;
  }

  Future<void> _sendCode() async {
    final t = Translations.of(context);
    final email = _email.text.trim();
    if (email.isEmpty || !email.contains("@")) {
      setState(() => _err = t.authScreen.invalidEmail);
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

        _info = t.authScreen.resetCodeSent;
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
    final t = Translations.of(context);
    final email = _email.text.trim();
    if (email.isEmpty || !email.contains("@")) {
      setState(() => _err = t.authScreen.invalidEmail);
      return;
    }
    if (_code.text.trim().isEmpty) {
      setState(() => _err = t.authScreen.emailCodeRequired);
      return;
    }
    final pwdErr = _policyError(t, _password.text);
    if (pwdErr != null) {
      setState(() => _err = pwdErr);
      return;
    }
    if (_password.text != _confirm.text) {
      setState(() => _err = t.authScreen.passwordMismatch);
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
      await DialogUtils.showAlertDialog(context, t.authScreen.resetSuccess);
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
