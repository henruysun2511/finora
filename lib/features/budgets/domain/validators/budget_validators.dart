/// Pure functions kiểm tra tính hợp lệ của dữ liệu đầu vào cho Ngân sách.
/// Tách biệt hoàn toàn khỏi Flutter UI, dễ dàng viết Unit Test.
class BudgetValidators {
  BudgetValidators._();

  /// Kiểm tra hạn mức chi tiêu: bắt buộc nhập, là số dương (> 0)
  static String? validateLimitAmount(String? value) {
    final t = (value ?? '').trim().replaceAll(RegExp(r'[\.,\s₫VND]'), '');
    if (t.isEmpty) return 'Vui lòng nhập hạn mức chi tiêu';
    final n = double.tryParse(t);
    if (n == null) return 'Hạn mức không hợp lệ';
    if (n <= 0) return 'Hạn mức phải lớn hơn 0 ₫';
    if (n > 10000000000) return 'Hạn mức tối đa 10 tỷ ₫';
    return null;
  }

  /// Kiểm tra ví: bắt buộc chọn
  static String? validateWalletId(String? value) {
    final t = value?.trim() ?? '';
    if (t.isEmpty) return 'Vui lòng chọn ví chi tiêu áp dụng';
    return null;
  }

  /// Kiểm tra danh mục chi tiêu: bắt buộc chọn
  static String? validateCategoryId(String? value) {
    final t = value?.trim() ?? '';
    if (t.isEmpty) return 'Vui lòng chọn danh mục chi tiêu';
    return null;
  }

  /// Kiểm tra ngày bắt đầu
  static String? validateStartDate(DateTime? value) {
    if (value == null) return 'Vui lòng chọn ngày bắt đầu áp dụng';
    return null;
  }
}

