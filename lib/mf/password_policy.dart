/// 密码策略 —— 与后台 `internal/utils/password.go` 的 `ValidatePasswordStrength` 逐字对齐。
///
/// ## 为什么需要这个文件
///
/// 原先「修改密码」页自带一份 `_check`，写的是「至少 8 位，且需包含大小写字母、
/// 数字、特殊字符中的至少三种」。但后台真正的校验是：
///
///     if len(password) < 8            → "密码长度不能少于8位"
///     if !hasLetter || !hasDigit      → "密码必须包含字母和数字"
///
/// 也就是说后台**只要求**「≥8 位 + 同时含字母和数字」。
/// 客户端那套「四种里凑三种」比后台更严，后果是：
///
///   · 用户输入的密码后台明明接受（例如 `abcd1234`），客户端却先拦下来；
///   · 提示文案描述的是一个后台并不存在的规则，用户按提示改也未必过得去；
///   · 三个入口（注册 / 改密 / 重置）各写一份，迟早再次跑偏。
///
/// 所以统一到这里：**以后端为准，一处定义，三处复用**。
/// 后台若改策略，只改 `kMinLength` 与 [validate] 即可。
///
/// 注意：登录接口的 `binding:"min=6"` 是**注册/重置请求体**的解析下限，
/// 真正的强度校验由上面的 `ValidatePasswordStrength` 完成，两者取严者生效，
/// 因此客户端按 8 位提示才是对的。
library;

class PasswordPolicy {
  PasswordPolicy._();

  /// 后台 `ValidatePasswordStrength` 的长度下限。
  static const int kMinLength = 8;

  /// 返回 null 表示通过；否则返回**与后台一致的**中文原因。
  ///
  /// 文案刻意与后台 `fmt.Errorf` 的字面量保持一致，避免用户看到两套说法。
  static String? validate(String password) {
    if (password.length < kMinLength) {
      return "密码长度不能少于$kMinLength位";
    }
    final hasLetter = RegExp(r"[A-Za-z]").hasMatch(password);
    final hasDigit = RegExp(r"[0-9]").hasMatch(password);
    if (!hasLetter || !hasDigit) {
      return "密码必须包含字母和数字";
    }
    return null;
  }

  /// 弱密码提示（仅用于 UI 展示强度，不参与校验）。
  static String hint() => "至少 $kMinLength 位，且同时包含字母和数字";
}
