import 'budget_period_response.dart';

/// DTO biểu diễn dữ liệu ngân sách trả về từ NestJS Backend API
/// Hỗ trợ đầy đủ quan hệ lồng nhau: currentPeriod và periods (lịch sử chu kỳ).
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
    this.categoryColor,
    this.currentPeriod,
    this.periods,
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
  final String? categoryColor;
  final BudgetPeriodResponse? currentPeriod;
  final List<BudgetPeriodResponse>? periods;
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
    String? cColor = json['categoryColor'] as String?;
    if (json['category'] is Map<String, dynamic>) {
      cName ??= json['category']['name'] as String?;
      cIcon ??= json['category']['icon'] as String?;
      cColor ??= json['category']['color'] as String?;
    }

    // Backend NestJS trả về 'period' (hoặc 'periodType')
    final periodStr = (json['period'] as String?) ??
        (json['periodType'] as String?) ??
        'MONTHLY';

    // Backend NestJS trả về 'isRollover' (hoặc 'isRolloverEnabled')
    final isRollover = (json['isRollover'] as bool?) ??
        (json['isRolloverEnabled'] as bool?) ??
        true;

    // Phân tích currentPeriod nếu có
    BudgetPeriodResponse? curPeriod;
    if (json['currentPeriod'] is Map<String, dynamic>) {
      curPeriod = BudgetPeriodResponse.fromJson(
        json['currentPeriod'] as Map<String, dynamic>,
      );
    }

    // Phân tích danh sách chu kỳ periods nếu có
    List<BudgetPeriodResponse>? periodList;
    if (json['periods'] is List) {
      periodList = (json['periods'] as List)
          .map((e) => BudgetPeriodResponse.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    // Ưu tiên lấy spentAmount & rolloverAmount từ currentPeriod của backend
    final spent = curPeriod?.spentAmount ??
        (json['spentAmount'] as num?)?.toDouble() ??
        0.0;

    final rollover = curPeriod?.rolloverAmount ??
        (json['rolloverAmount'] as num?)?.toDouble() ??
        0.0;

    final rootLimit = (json['limitAmount'] as num?)?.toDouble() ?? 0.0;
    final limit = rootLimit > 0 ? rootLimit : (curPeriod?.limitAmount ?? 0.0);

    // Ngày bắt đầu & kết thúc
    final sDate = curPeriod?.startDate ??
        (json['startDate'] != null
            ? DateTime.tryParse(json['startDate'].toString()) ?? DateTime.now()
            : DateTime.now());

    final eDate = curPeriod?.endDate ??
        (json['endDate'] != null
            ? DateTime.tryParse(json['endDate'].toString())
            : null);

    return BudgetResponse(
      id: json['id']?.toString() ?? '',
      walletId: json['walletId']?.toString() ??
          (json['wallet']?['id']?.toString() ?? ''),
      categoryId: json['categoryId']?.toString() ??
          (json['category']?['id']?.toString() ?? ''),
      limitAmount: limit,
      spentAmount: spent,
      rolloverAmount: rollover,
      periodType: periodStr.toUpperCase(),
      startDate: sDate,
      endDate: eDate,
      isRolloverEnabled: isRollover,
      walletName: wName,
      categoryName: cName,
      categoryIcon: cIcon,
      categoryColor: cColor,
      currentPeriod: curPeriod,
      periods: periodList,
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
        'period': periodType,
        'periodType': periodType,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate?.toIso8601String(),
        'isRollover': isRolloverEnabled,
        'isRolloverEnabled': isRolloverEnabled,
        'walletName': walletName,
        'categoryName': categoryName,
        'categoryIcon': categoryIcon,
        'categoryColor': categoryColor,
        'currentPeriod': currentPeriod?.toJson(),
        'periods': periods?.map((e) => e.toJson()).toList(),
      };
}
