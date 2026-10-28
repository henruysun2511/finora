/// Phân loại khoản nợ (Loan Type)
enum LoanType {
  /// Cho vay (Tiền mình cho người khác mượn)
  lent('LENT'),

  /// Đi vay (Tiền mình đang nợ người khác)
  borrowed('BORROWED'),

  /// Mua trả góp (Hợp đồng định kỳ)
  installment('INSTALLMENT');

  const LoanType(this.value);
  final String value;

  static LoanType fromValue(String v) => LoanType.values.firstWhere(
        (e) => e.value == v,
        orElse: () => LoanType.borrowed,
      );

  String get displayName {
    switch (this) {
      case LoanType.lent:
        return '🤝 Cho vay';
      case LoanType.borrowed:
        return '💸 Đi vay';
      case LoanType.installment:
        return '🛵 Trả góp';
    }
  }
}
