class RecurringTransactionValidators {
  RecurringTransactionValidators._();

  static String? validateName(String? value) {
    final t = value?.trim() ?? '';
    if (t.isEmpty) return 'Vui lòng nhập tên khoản thanh toán';
    if (t.length < 2) return 'Tên quá ngắn (tối thiểu 2 ký tự)';
    if (t.length > 150) return 'Tên tối đa 150 ký tự';
    return null;
  }

  static String? validateAmount(String? value) {
    final t = value?.trim() ?? '';
    if (t.isEmpty) return 'Vui lòng nhập số tiền';
    final parsed = double.tryParse(t);
    if (parsed == null || parsed <= 0) return 'Số tiền phải lớn hơn 0';
    return null;
  }

  static String? validateDayOfMonth(String? value) {
    final t = value?.trim() ?? '';
    if (t.isEmpty) return 'Vui lòng chọn ngày trong tháng';
    final day = int.tryParse(t);
    if (day == null || day < 1 || day > 31) return 'Ngày trong tháng từ 1 đến 31';
    return null;
  }
}