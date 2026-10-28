import 'loan_type.dart';

/// Dữ liệu đầu vào khi tạo khoản Vay/Nợ mới (Form Input)
class LoanInput {
  const LoanInput({
    required this.type,
    required this.counterpartyName,
    required this.principalAmount,
    required this.affectsBalance,
    this.counterpartyUserId,
    this.counterpartyPhone,
    this.sourceWalletId,
    this.dueDate,
    this.interestRate,
    this.interestPeriod = 'month',
    this.notes,
    this.installmentMonths,
  });

  final LoanType type;
  final String counterpartyName;
  final double principalAmount;
  final bool affectsBalance;
  final String? counterpartyUserId;
  final String? counterpartyPhone;
  final String? sourceWalletId;
  final DateTime? dueDate;
  final double? interestRate;
  final String? interestPeriod;
  final String? notes;
  final int? installmentMonths; // Dành cho INSTALLMENT type

  /// Số tiền mỗi kỳ trả góp
  double? get monthlyInstallmentAmount {
    if (installmentMonths == null || installmentMonths! <= 0) return null;
    return principalAmount / installmentMonths!;
  }
}

/// Dữ liệu đầu vào khi cập nhật khoản nợ
class LoanUpdateInput {
  const LoanUpdateInput({
    this.counterpartyName,
    this.counterpartyUserId,
    this.counterpartyPhone,
    this.dueDate,
    this.notes,
  });

  final String? counterpartyName;
  final String? counterpartyUserId;
  final String? counterpartyPhone;
  final DateTime? dueDate;
  final String? notes;
}

/// Dữ liệu đầu vào khi ghi nhận một đợt thanh toán nợ
class LoanPaymentInput {
  const LoanPaymentInput({
    required this.amount,
    required this.paymentDate,
    required this.affectsBalance,
    this.walletId,
    this.notes,
  });

  final double amount;
  final DateTime paymentDate;
  final bool affectsBalance;
  final String? walletId;
  final String? notes;
}
