class FriendsValidators {
  FriendsValidators._();

  static final _emailRegex = RegExp(
    r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$',
  );

  static final _phoneRegex = RegExp(r'^(0|\+84)[3|5|7|8|9][0-9]{8}$');

  /// Kiểm tra từ khóa tìm kiếm bạn bè
  static String? validateSearchQuery(String? value) {
    final t = value?.trim() ?? '';
    if (t.isEmpty) return 'Vui lòng nhập từ khóa tìm kiếm';
    if (t.length < 2) return 'Từ khóa tìm kiếm tối thiểu 2 ký tự';
    if (t.length > 100) return 'Từ khóa tối đa 100 ký tự';
    return null;
  }

  /// Kiểm tra email hoặc số điện thoại khi kết bạn trực tiếp
  static String? validateEmailOrPhone(String? value) {
    final t = value?.trim() ?? '';
    if (t.isEmpty) return 'Vui lòng nhập email hoặc số điện thoại';
    if (t.contains('@')) {
      if (!_emailRegex.hasMatch(t)) return 'Email không đúng định dạng';
    } else {
      final cleanPhone = t.replaceAll(RegExp(r'\s+'), '');
      if (!_phoneRegex.hasMatch(cleanPhone)) {
        return 'Số điện thoại Việt Nam không hợp lệ (10 chữ số)';
      }
    }
    return null;
  }
}
