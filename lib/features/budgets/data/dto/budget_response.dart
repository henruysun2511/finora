/// DTO biểu diễn dữ liệu ngân sách trả về từ NestJS Backend API
class BudgetResponse {
  const BudgetResponse({
    required this.id,
    required this.walletId,
    required this.categoryId,
    required this.limitAmount,
    this.spentAmount = 0.0,
    this.rolloverAmount = 0.0,
    this.periodType = 'MONTHLY',
    required this.startDate,
    this.endDate,
    this.isRolloverEnabled = true,
    this.walletName,
    this.categoryName,
    this.categoryIcon,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String walletId;
  final String categoryId;
  final double limitAmount;
  final double spentAmount;
  final double rolloverAmount;
  final String periodType;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isRolloverEnabled;
  final String? walletName;
  final String? categoryName;
  final String? categoryIcon;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory BudgetResponse.fromJson(Map<String, dynamic> json) {
    // Trích xuất quan hệ lồng nhau nếu backend populate (wallet, category)
    String? wName = json['walletName'] as String?;
    if (wName == null && json['wallet'] is Map<String, dynamic>) {
      wName = json['wallet']['name'] as String?;
    }

    String? cName = json['categoryName'] as String?;
    String? cIcon = json['categoryIcon'] as String?;
    if (json['category'] is Map<String, dynamic>) {
      cName ??= json['category']['name'] as String?;
      cIcon ??= json['category']['icon'] as String?;
    }

    return BudgetResponse(
      id: json['id']?.toString() ?? '',
      walletId: json['walletId']?.toString() ?? (json['wallet']?['id']?.toString() ?? ''),
      categoryId: json['categoryId']?.toString() ?? (json['category']?['id']?.toString() ?? ''),
      limitAmount: (json['limitAmount'] as num?)?.toDouble() ?? 0.0,
      spentAmount: (json['spentAmount'] as num?)?.toDouble() ?? 0.0,
      rolloverAmount: (json['rolloverAmount'] as num?)?.toDouble() ?? 0.0,
      periodType: (json['periodType'] as String?) ?? 'MONTHLY',
      startDate: json['startDate'] != null
          ? DateTime.tryParse(json['startDate'].toString()) ?? DateTime.now()
          : DateTime.now(),
      endDate: json['endDate'] != null
          ? DateTime.tryParse(json['endDate'].toString())
          : null,
      isRolloverEnabled: (json['isRolloverEnabled'] as bool?) ?? true,
      walletName: wName,
      categoryName: cName,
      categoryIcon: cIcon,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'walletId': walletId,
        'categoryId': categoryId,
        'limitAmount': limitAmount,
        'spentAmount': spentAmount,
        'rolloverAmount': rolloverAmount,
        'periodType': periodType,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate?.toIso8601String(),
        'isRolloverEnabled': isRolloverEnabled,
        'walletName': walletName,
        'categoryName': categoryName,
        'categoryIcon': categoryIcon,
      };
}

