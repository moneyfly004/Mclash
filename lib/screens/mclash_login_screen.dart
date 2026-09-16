
library;

import 'package:flutter/material.dart';
import 'package:mclash/app/modules/setting_manager.dart';
import 'package:mclash/app/utils/log.dart';
import 'package:mclash/mf/cboard_client.dart';
import 'package:mclash/mf/mclash_api.dart';
import 'package:mclash/screens/mclash_forgot_password_screen.dart';
import 'package:mclash/screens/mclash_register_screen.dart';
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
  bool _remember = SettingManager.getConfig().rememberAccount;
  String? _err;

  Map<String, dynamic> _cfg = const {};

  @override
  void initState() {
    super.initState();
    // 上次登录用的邮箱（只记邮箱、不存密码）：不勾选保存也预填，少输一次
    final last = SettingManager.getConfig().lastAccountEmail;
    if (last.isNotEmpty) {
      _email.text = last;
    }
    MclashApi.siteConfig().then((c) {
      if (mounted) {
        setState(() => _cfg = c);
      }
    });
  }

  /// 勾选/取消「保存账号信息」。
  ///
  /// 勾选 = 会话落盘 → 下次打开自动登录；
  /// 取消 = 会话只留在内存 → 下次打开停在登录窗口。
  /// 取消时立即清掉磁盘上的旧会话，否则对已登录过的用户不生效。
  Future<void> _setRemember(bool value) async {
    setState(() => _remember = value);
    SettingManager.getConfig().rememberAccount = value;
    SettingManager.save();
    if (!value) {
      await CBoardSessionStore.clear();
      // 「保存账号信息」不勾 = 什么都不留（连上次登录的邮箱也清掉）
      SettingManager.getConfig().lastAccountEmail = "";
      SettingManager.save();
    }
    Log.i("MclashLoginScreen: 保存账号信息 = $value");
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
                  CheckboxListTile(
                    value: _remember,
                    onChanged: _busy
                        ? null
                        : (v) => _setRemember(v ?? false),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    title: const Text(
                      "保存账号信息",
                      style: TextStyle(fontSize: 14),
                    ),
                    subtitle: Text(
                      _remember ? "下次打开自动登录" : "下次打开需要重新登录",
                      style: const TextStyle(
                        fontSize: 12,
                        color: ThemeDefine.kColorGrey,
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
      await MclashApi.login(email, _password.text);
      // 勾选了保存才记邮箱（**绝不存密码**）：不勾就什么都不留
      SettingManager.getConfig().lastAccountEmail = _remember ? email : "";
      SettingManager.save();
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
