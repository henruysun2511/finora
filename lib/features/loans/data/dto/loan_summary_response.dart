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
    return LoanSummaryResponse(
      totalLent: (json['totalLent'] as num?) ?? 0,
      totalBorrowed: (json['totalBorrowed'] as num?) ?? 0,
      totalInstallment: (json['totalInstallment'] as num?) ?? 0,
      netPosition: (json['netPosition'] as num?) ?? 0,
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
    this.notes,
    this.createdAt,
  });

  final String id;
  final String loanId;
  final num amount;
  final DateTime paymentDate;
  final String? walletId;
  final String? walletName;
  final String? notes;
  final DateTime? createdAt;

  factory LoanPaymentResponse.fromJson(Map<String, dynamic> json) {
    return LoanPaymentResponse(
      id: json['id'] as String,
      loanId: json['loanId'] as String,
      amount: json['amount'] as num,
      paymentDate: DateTime.parse(json['paymentDate'] as String),
      walletId: json['walletId'] as String?,
      walletName: json['walletName'] as String?,
      notes: json['notes'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }
}
