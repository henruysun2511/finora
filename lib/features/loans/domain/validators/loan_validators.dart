/// Validators thuần domain cho module Loans.
/// Pure static functions – không phụ thuộc Flutter, test được ngay.
class LoanValidators {
  LoanValidators._();

  /// Tên người vay/cho vay
  static String? validateCounterpartyName(String? value) {
    final t = value?.trim() ?? '';
    if (t.isEmpty) return 'Vui lòng nhập tên người vay/cho vay';
    if (t.length < 2) return 'Tên tối thiểu 2 ký tự';
    if (t.length > 100) return 'Tên tối đa 100 ký tự';
    return null;
  }

  /// Số tiền gốc (VND)
  static String? validatePrincipalAmount(String? value) {
    final t = value?.trim() ?? '';
    if (t.isEmpty) return 'Vui lòng nhập số tiền';
    final amount = double.tryParse(t.replaceAll(RegExp(r'[.,]'), ''));
    if (amount == null) return 'Số tiền không hợp lệ';
    if (amount <= 0) return 'Số tiền phải lớn hơn 0';
    if (amount < 1000) return 'Số tiền tối thiểu 1.000 ₫';
    if (amount > 10000000000) return 'Số tiền vượt quá giới hạn cho phép';
    return null;
  }

  /// Số tiền thanh toán (so với số nợ còn lại)
  static String? validatePaymentAmount(String? value, double remainingAmount) {
    final t = value?.trim() ?? '';
    if (t.isEmpty) return 'Vui lòng nhập số tiền thanh toán';
    final amount = double.tryParse(t.replaceAll(RegExp(r'[.,]'), ''));
    if (amount == null) return 'Số tiền không hợp lệ';
    if (amount <= 0) return 'Số tiền phải lớn hơn 0';
    if (amount > remainingAmount) {
      return 'Số tiền thanh toán không được vượt quá số nợ còn lại';
    }
    return null;
  }

  /// Số điện thoại (tuỳ chọn)
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) return null; // Tuỳ chọn
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 9 || digits.length > 11) {
      return 'Số điện thoại không hợp lệ';
    }
    return null;
  }

  /// Lãi suất (tuỳ chọn)
  static String? validateInterestRate(String? value) {
    if (value == null || value.trim().isEmpty) return null; // Tuỳ chọn
    final rate = double.tryParse(value.trim());
    if (rate == null) return 'Lãi suất không hợp lệ';
    if (rate < 0) return 'Lãi suất không được âm';
    if (rate > 100) return 'Lãi suất tối đa 100%';
    return null;
  }

  /// Số kỳ trả góp (tuỳ chọn, chỉ dành cho INSTALLMENT)
  static String? validateInstallmentMonths(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final months = int.tryParse(value.trim());
    if (months == null) return 'Số kỳ không hợp lệ';
    if (months < 1) return 'Số kỳ tối thiểu 1';
    if (months > 120) return 'Số kỳ tối đa 120 tháng';
    return null;
  }
}
