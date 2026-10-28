/// Trạng thái khoản nợ (Loan Status)
enum LoanStatus {
  /// Đang còn nợ, chưa đến hạn
  active('ACTIVE'),

  /// Quá hạn chưa thanh toán
  overdue('OVERDUE'),

  /// Đã tất toán hoàn toàn
  settled('SETTLED');

  const LoanStatus(this.value);
  final String value;

  static LoanStatus fromValue(String v) => LoanStatus.values.firstWhere(
        (e) => e.value == v,
        orElse: () => LoanStatus.active,
      );

  String get displayName {
    switch (this) {
      case LoanStatus.active:
        return 'Đang nợ';
      case LoanStatus.overdue:
        return 'Quá hạn';
      case LoanStatus.settled:
        return 'Đã tất toán';
    }
  }
}
