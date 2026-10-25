class AuthValidators {
  AuthValidators._();

  /// Validate username hoặc email đăng nhập
  static String? validateUsername(String? value) {
    final t = value?.trim() ?? '';
    if (t.isEmpty) return 'Vui lòng nhập tên đăng nhập hoặc email';
    if (t.length < 3) return 'Tên đăng nhập tối thiểu 3 ký tự';
    if (t.length > 100) return 'Tối đa 100 ký tự';
    return null;
  }

  /// Validate mật khẩu đăng nhập
  static String? validatePassword(String? value) {
    final t = value ?? '';
    if (t.isEmpty) return 'Vui lòng nhập mật khẩu';
    if (t.length < 6) return 'Mật khẩu tối thiểu 6 ký tự';
    if (t.length > 50) return 'Mật khẩu tối đa 50 ký tự';
    return null;
  }
}
