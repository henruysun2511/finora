/// DTO Response: Khoản nợ từ API Backend
class LoanResponse {
  const LoanResponse({
    required this.id,
    required this.type,
    required this.status,
    required this.counterpartyName,
    required this.principalAmount,
    required this.paidAmount,
    required this.remainingAmount,
    required this.affectsBalance,
    required this.createdAt,
    this.counterpartyUserId,
    this.counterpartyPhone,
    this.counterpartyAvatarUrl,
    this.sourceWalletId,
    this.sourceWalletName,
    this.dueDate,
    this.interestRate,
    this.interestPeriod,
    this.notes,
    this.installmentMonths,
    this.currentInstallment,
    this.updatedAt,
  });

  final String id;
  final String type;
  final String status;
  final String counterpartyName;
  final num principalAmount;
  final num paidAmount;
  final num remainingAmount;
  final bool affectsBalance;
  final DateTime createdAt;
  final String? counterpartyUserId;
  final String? counterpartyPhone;
  final String? counterpartyAvatarUrl;
  final String? sourceWalletId;
  final String? sourceWalletName;
  final DateTime? dueDate;
  final num? interestRate;
  final String? interestPeriod;
  final String? notes;
  final int? installmentMonths;
  final int? currentInstallment;
  final DateTime? updatedAt;

  factory LoanResponse.fromJson(Map<String, dynamic> json) {
    return LoanResponse(
      id: json['id'] as String,
      type: json['type'] as String,
      status: json['status'] as String,
      counterpartyName: json['counterpartyName'] as String,
      principalAmount: json['principalAmount'] as num,
      paidAmount: (json['paidAmount'] as num?) ?? 0,
      remainingAmount:
          (json['remainingAmount'] as num?) ?? json['principalAmount'] as num,
      affectsBalance: (json['affectsBalance'] as bool?) ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      counterpartyUserId: json['counterpartyUserId'] as String?,
      counterpartyPhone: json['counterpartyPhone'] as String?,
      counterpartyAvatarUrl: json['counterpartyAvatarUrl'] as String?,
      sourceWalletId: json['sourceWalletId'] as String?,
      sourceWalletName: json['sourceWalletName'] as String?,
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'] as String)
          : null,
      interestRate: json['interestRate'] as num?,
      interestPeriod: json['interestPeriod'] as String?,
      notes: json['notes'] as String?,
      installmentMonths: json['installmentMonths'] as int?,
      currentInstallment: json['currentInstallment'] as int?,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }
}
