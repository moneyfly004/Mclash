
library;

import 'package:flutter/material.dart';
import 'package:mclash/i18n/strings.g.dart';
import 'package:mclash/mf/mclash_api.dart';
import 'package:mclash/mf/password_policy.dart';
import 'package:mclash/screens/dialog_utils.dart';
import 'package:mclash/screens/theme_config.dart';
import 'package:mclash/screens/widgets/framework.dart';

class MclashChangePasswordScreen extends LasyRenderingStatefulWidget {
  const MclashChangePasswordScreen({super.key});

  @override
  State<MclashChangePasswordScreen> createState() =>
      _MclashChangePasswordScreenState();
}

class _MclashChangePasswordScreenState
    extends LasyRenderingState<MclashChangePasswordScreen> {
  final _old = TextEditingController();
  final _new = TextEditingController();
  final _confirm = TextEditingController();
  bool _busy = false;
  String? _err;

  @override
  void dispose() {
    _old.dispose();
    _new.dispose();
    _confirm.dispose();
    super.dispose();
  }

  /// 密码策略校验（文案走 i18n，规则仍以 PasswordPolicy 为准）。
  String? _check(Translations t, String pwd) {
    final raw = PasswordPolicy.validate(pwd);
    if (raw == null) {
      return null;
    }
    if (pwd.length < PasswordPolicy.kMinLength) {
      return t.authScreen.passwordTooShort(min: PasswordPolicy.kMinLength);
    }
    return t.authScreen.passwordNeedsLetterAndDigit;
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
                      t.authScreen.changePasswordTitle,
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
                    _field(t.authScreen.currentPassword, _old),
                    _field(t.authScreen.newPassword, _new),
                    _field(t.authScreen.confirmNewPassword, _confirm),
                    if (_err != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          _err!,
                          style: const TextStyle(color: Colors.red, fontSize: 13),
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
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(t.authScreen.saveNewPassword),
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

  Widget _field(String label, TextEditingController c) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: TextField(
          controller: c,
          obscureText: true,
          decoration: InputDecoration(labelText: label),
        ),
      );

  Future<void> _submit() async {
    final t = Translations.of(context);
    final err = _check(t, _new.text);
    if (err != null) {
      setState(() => _err = err);
      return;
    }
    if (_new.text != _confirm.text) {
      setState(() => _err = t.authScreen.newPasswordMismatch);
      return;
    }
    setState(() {
      _busy = true;
      _err = null;
    });
    try {
      await MclashApi.post("/users/change-password", {
        "old_password": _old.text,
        "new_password": _new.text,
      });
      if (!mounted) return;
      await DialogUtils.showAlertDialog(
          context, t.authScreen.changePasswordSuccess);
      if (!mounted) return;
      Navigator.of(context).popUntil((r) => r.isFirst);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _err = "$e";
        _busy = false;
      });
    }
  }
}
