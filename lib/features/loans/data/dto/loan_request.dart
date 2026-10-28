/// DTO Request: Tạo khoản nợ mới
class CreateLoanRequest {
  const CreateLoanRequest({
    required this.type,
    required this.counterpartyName,
    required this.principalAmount,
    required this.affectsBalance,
    this.counterpartyUserId,
    this.counterpartyPhone,
    this.sourceWalletId,
    this.dueDate,
    this.interestRate,
    this.interestPeriod,
    this.notes,
    this.installmentMonths,
  });

  final String type;
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
  final int? installmentMonths;

  Map<String, dynamic> toJson() => {
        'type': type,
        'counterpartyName': counterpartyName,
        'principalAmount': principalAmount,
        'affectsBalance': affectsBalance,
        if (counterpartyUserId != null)
          'counterpartyUserId': counterpartyUserId,
        if (counterpartyPhone != null) 'counterpartyPhone': counterpartyPhone,
        if (sourceWalletId != null) 'sourceWalletId': sourceWalletId,
        if (dueDate != null) 'dueDate': dueDate!.toIso8601String(),
        if (interestRate != null) 'interestRate': interestRate,
        if (interestPeriod != null) 'interestPeriod': interestPeriod,
        if (notes != null) 'notes': notes,
        if (installmentMonths != null) 'installmentMonths': installmentMonths,
      };
}

/// DTO Request: Cập nhật khoản nợ
class UpdateLoanRequest {
  const UpdateLoanRequest({
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

  Map<String, dynamic> toJson() => {
        if (counterpartyName != null) 'counterpartyName': counterpartyName,
        if (counterpartyUserId != null)
          'counterpartyUserId': counterpartyUserId,
        if (counterpartyPhone != null) 'counterpartyPhone': counterpartyPhone,
        if (dueDate != null) 'dueDate': dueDate!.toIso8601String(),
        if (notes != null) 'notes': notes,
      };
}

/// DTO Request: Ghi nhận đợt thanh toán nợ
class CreateLoanPaymentRequest {
  const CreateLoanPaymentRequest({
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

  Map<String, dynamic> toJson() => {
        'amount': amount,
        'paymentDate': paymentDate.toIso8601String(),
        'affectsBalance': affectsBalance,
        if (walletId != null) 'walletId': walletId,
        if (notes != null) 'notes': notes,
      };
}
