/// 修改密码（M-08）。成功后按设计清会话并要求重新登录。
library;

import 'package:flutter/material.dart';
import 'package:mclash/mf/mclash_api.dart';
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

  /// 与后台 `auth.ValidatePasswordStrength` 逐字对齐
  static const _specials = "!@#\$%^&*()_+-=[]{}|;:,.<>?";

  static String? _check(String pwd) {
    if (pwd.length < 8) return "密码至少 8 位";
    var kinds = 0;
    if (RegExp(r"[A-Z]").hasMatch(pwd)) kinds++;
    if (RegExp(r"[a-z]").hasMatch(pwd)) kinds++;
    if (RegExp(r"[0-9]").hasMatch(pwd)) kinds++;
    if (pwd.split("").any(_specials.contains)) kinds++;
    if (kinds < 3) {
      return "密码强度不足：需包含大小写字母、数字、特殊字符中的至少三种";
    }
    return null;
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
                      "修改密码",
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
                    _field("当前密码", _old),
                    _field("新密码", _new),
                    _field("确认新密码", _confirm),
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
                            : const Text("保存新密码"),
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
    final err = _check(_new.text);
    if (err != null) {
      setState(() => _err = err);
      return;
    }
    if (_new.text != _confirm.text) {
      setState(() => _err = "两次输入的新密码不一致");
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
      await DialogUtils.showAlertDialog(context, "密码已修改，请重新登录");
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
