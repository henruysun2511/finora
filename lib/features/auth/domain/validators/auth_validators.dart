class AuthValidators {
  AuthValidators._();

  static final RegExp _emailRegex =
      RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

  /// Kiểm tra họ và tên: không để trống, từ 2 đến 100 ký tự
  static String? validateFullName(String? value) {
    final t = value?.trim() ?? '';
    if (t.isEmpty) return 'Vui lòng nhập họ và tên';
    if (t.length < 2) return 'Họ và tên quá ngắn (tối thiểu 2 ký tự)';
    if (t.length > 100) return 'Họ và tên tối đa 100 ký tự';
    return null;
  }

  /// Kiểm tra tên đăng nhập hoặc email (hỗ trợ cả đăng nhập lẫn đăng ký)
  static String? validateUsername(String? value) {
    final t = value?.trim() ?? '';
    if (t.isEmpty) return 'Vui lòng nhập tên đăng nhập hoặc email';
    if (t.length < 3) return 'Tên đăng nhập tối thiểu 3 ký tự';
    if (t.length > 100) return 'Tối đa 100 ký tự';
    return null;
  }

  /// Kiểm tra email: không để trống, đúng định dạng tiêu chuẩn RFC
  static String? validateEmail(String? value) {
    final t = value?.trim() ?? '';
    if (t.isEmpty) return 'Vui lòng nhập email';
    if (!_emailRegex.hasMatch(t)) {
      return 'Địa chỉ email không đúng định dạng';
    }
    return null;
  }

  /// Kiểm tra mật khẩu: không để trống, tối thiểu 6 ký tự, tối đa 50 ký tự
  static String? validatePassword(String? value) {
    final t = value ?? '';
    if (t.isEmpty) return 'Vui lòng nhập mật khẩu';
    if (t.length < 6) return 'Mật khẩu tối thiểu 6 ký tự';
    if (t.length > 50) return 'Mật khẩu tối đa 50 ký tự';
    return null;
  }
}
