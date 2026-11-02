/// DTO Response: Khoản nợ từ API Backend (tương thích cả finora_be DTO và Mock)
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
    this.accountId,
    this.accountName,
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
  final String? accountId;
  final String? accountName;
  final DateTime? dueDate;
  final num? interestRate;
  final String? interestPeriod;
  final String? notes;
  final int? installmentMonths;
  final int? currentInstallment;
  final DateTime? updatedAt;

  factory LoanResponse.fromJson(Map<String, dynamic> json) {
    final principal = (json['principalAmount'] as num?) ?? 0;
    final remaining = (json['remainingAmount'] as num?) ?? principal;
    final paid = (json['paidAmount'] as num?) ?? (principal > remaining ? principal - remaining : 0);

    // Xử lý linh hoạt tên đối tác: backend dùng contactName, mockup/app dùng counterpartyName
    final contact = (json['contactName'] ?? json['counterpartyName'] ?? 'Không tên') as String;

    // Xử lý linh hoạt ngày tạo: nếu backend trả về null thì fallback về thời gian hiện tại
    final created = json['createdAt'] != null
        ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
        : DateTime.now();

    return LoanResponse(
      id: (json['id'] ?? '') as String,
      type: (json['type'] ?? 'LENT') as String,
      status: (json['status'] ?? 'ACTIVE') as String,
      counterpartyName: contact,
      principalAmount: principal,
      paidAmount: paid,
      remainingAmount: remaining,
      affectsBalance: (json['affectsBalance'] as bool?) ?? true,
      createdAt: created,
      counterpartyUserId: json['counterpartyUserId'] as String?,
      counterpartyPhone: (json['contactInfo'] ?? json['counterpartyPhone']) as String?,
      counterpartyAvatarUrl: json['counterpartyAvatarUrl'] as String?,
      sourceWalletId: (json['walletId'] ?? json['sourceWalletId']) as String?,
      sourceWalletName: (json['walletName'] ?? json['sourceWalletName']) as String?,
      accountId: json['accountId'] as String?,
      accountName: json['accountName'] as String?,
      dueDate: json['dueDate'] != null
          ? DateTime.tryParse(json['dueDate'] as String)
          : null,
      interestRate: json['interestRate'] as num?,
      interestPeriod: json['interestPeriod'] as String?,
      notes: (json['note'] ?? json['notes']) as String?,
      installmentMonths: json['installmentMonths'] as int?,
      currentInstallment: json['currentInstallment'] as int?,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
    );
  }
}
