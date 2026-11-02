/// DTO Request: Tạo khoản nợ mới (Tương thích đồng thời NestJS BE và Mock)
class CreateLoanRequest {
  const CreateLoanRequest({
    required this.type,
    required this.counterpartyName,
    required this.principalAmount,
    required this.affectsBalance,
    this.counterpartyUserId,
    this.counterpartyPhone,
    this.sourceWalletId,
    this.accountId,
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
  final String? accountId;
  final DateTime? dueDate;
  final double? interestRate;
  final String? interestPeriod;
  final String? notes;
  final int? installmentMonths;

  Map<String, dynamic> toJson() {
    final effectiveWalletId = sourceWalletId ?? '00000000-0000-0000-0000-000000000001';
    final effectiveAccountId = accountId ?? '00000000-0000-0000-0000-000000000001';

    return {
      'type': type,
      'contactName': counterpartyName,
      'counterpartyName': counterpartyName,
      'principalAmount': principalAmount,
      'affectsBalance': affectsBalance,
      'walletId': effectiveWalletId,
      'sourceWalletId': effectiveWalletId,
      'accountId': effectiveAccountId,
      if (counterpartyUserId != null) 'counterpartyUserId': counterpartyUserId,
      if (counterpartyPhone != null) ...{
        'contactInfo': counterpartyPhone,
        'counterpartyPhone': counterpartyPhone,
      },
      if (dueDate != null) 'dueDate': dueDate!.toIso8601String(),
      if (interestRate != null) ...{
        'isInterestBearing': interestRate! > 0,
        'interestRate': interestRate,
      },
      if (interestPeriod != null) 'interestPeriod': interestPeriod,
      if (notes != null) ...{
        'note': notes,
        'notes': notes,
      },
      if (installmentMonths != null) 'installmentMonths': installmentMonths,
    };
  }
}

/// DTO Request: Cập nhật khoản nợ
class UpdateLoanRequest {
  const UpdateLoanRequest({
    this.counterpartyName,
    this.counterpartyUserId,
    this.counterpartyPhone,
    this.dueDate,
    this.notes,
    this.principalAmount,
  });

  final String? counterpartyName;
  final String? counterpartyUserId;
  final String? counterpartyPhone;
  final DateTime? dueDate;
  final String? notes;
  final double? principalAmount;

  Map<String, dynamic> toJson() => {
        if (counterpartyName != null) ...{
          'contactName': counterpartyName,
          'counterpartyName': counterpartyName,
        },
        if (counterpartyUserId != null)
          'counterpartyUserId': counterpartyUserId,
        if (counterpartyPhone != null) ...{
          'contactInfo': counterpartyPhone,
          'counterpartyPhone': counterpartyPhone,
        },
        if (dueDate != null) 'dueDate': dueDate!.toIso8601String(),
        if (notes != null) ...{
          'note': notes,
          'notes': notes,
        },
        if (principalAmount != null) 'principalAmount': principalAmount,
      };
}

/// DTO Request: Ghi nhận đợt thanh toán nợ
class CreateLoanPaymentRequest {
  const CreateLoanPaymentRequest({
    required this.amount,
    required this.paymentDate,
    required this.affectsBalance,
    this.walletId,
    this.accountId,
    this.notes,
  });

  final double amount;
  final DateTime paymentDate;
  final bool affectsBalance;
  final String? walletId;
  final String? accountId;
  final String? notes;

  Map<String, dynamic> toJson() {
    final effectiveAccId = accountId ?? walletId ?? '00000000-0000-0000-0000-000000000001';
    return {
      'amount': amount,
      'paymentDate': paymentDate.toIso8601String(),
      'affectsBalance': affectsBalance,
      'accountId': effectiveAccId,
      'walletId': effectiveAccId,
      if (notes != null) ...{
        'note': notes,
        'notes': notes,
      },
    };
  }
}
