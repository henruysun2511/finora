/// DTO Response: Số liệu tóm tắt khoản nợ (Hero Card)
class LoanSummaryResponse {
  const LoanSummaryResponse({
    required this.totalLent,
    required this.totalBorrowed,
    required this.totalInstallment,
    required this.netPosition,
    required this.overdueCount,
    required this.activeCount,
  });

  final num totalLent;
  final num totalBorrowed;
  final num totalInstallment;
  final num netPosition;
  final int overdueCount;
  final int activeCount;

  factory LoanSummaryResponse.fromJson(Map<String, dynamic> json) {
    final lent = (json['totalLent'] as num?) ?? 0;
    final borrowed = (json['totalBorrowed'] as num?) ?? 0;
    final installment = (json['totalInstallment'] as num?) ?? 0;

    // Backend NestJS trả về netBalance = totalLent - totalBorrowed
    final net = (json['netBalance'] as num?) ??
        (json['netPosition'] as num?) ??
        (lent - (borrowed + installment));

    return LoanSummaryResponse(
      totalLent: lent,
      totalBorrowed: borrowed,
      totalInstallment: installment,
      netPosition: net,
      overdueCount: (json['overdueCount'] as int?) ?? 0,
      activeCount: (json['activeCount'] as int?) ?? 0,
    );
  }
}

/// DTO Response: Một đợt thanh toán nợ
class LoanPaymentResponse {
  const LoanPaymentResponse({
    required this.id,
    required this.loanId,
    required this.amount,
    required this.paymentDate,
    this.walletId,
    this.walletName,
    this.accountId,
    this.accountName,
    this.notes,
    this.createdAt,
  });

  final String id;
  final String loanId;
  final num amount;
  final DateTime paymentDate;
  final String? walletId;
  final String? walletName;
  final String? accountId;
  final String? accountName;
  final String? notes;
  final DateTime? createdAt;

  factory LoanPaymentResponse.fromJson(Map<String, dynamic> json) {
    return LoanPaymentResponse(
      id: (json['id'] ?? '') as String,
      loanId: (json['loanId'] ?? '') as String,
      amount: (json['amount'] as num?) ?? 0,
      paymentDate: json['paymentDate'] != null
          ? (DateTime.tryParse(json['paymentDate'] as String) ?? DateTime.now())
          : DateTime.now(),
      walletId: (json['walletId'] ?? json['accountId']) as String?,
      walletName: (json['walletName'] ?? json['accountName']) as String?,
      accountId: (json['accountId'] ?? json['walletId']) as String?,
      accountName: (json['accountName'] ?? json['walletName']) as String?,
      notes: (json['note'] ?? json['notes']) as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
    );
  }
}
