/// DTO trạng thái chi tiết theo thời gian thực: GET /api/v1/budgets/:id/status
/// Đồng bộ 100% với BudgetStatusResponseDto của NestJS backend.
class BudgetStatusResponse {
  const BudgetStatusResponse({
    required this.budgetId,
    required this.percentage,
    required this.effectiveLimit,
    required this.remainingAmount,
    required this.spentAmount,
    required this.dailyBudgetRemaining,
    required this.daysRemaining,
    this.rolloverAmount = 0.0,
    this.limitAmount = 0.0,
    this.statusCode = 'SAFE',
    this.period,
    this.categoryName,
    this.categoryIcon,
  });

  final String budgetId;
  final double percentage;
  final double effectiveLimit;
  final double remainingAmount;
  final double spentAmount;
  final double dailyBudgetRemaining;
  final int daysRemaining;
  final double rolloverAmount;
  final double limitAmount;
  final String statusCode; // SAFE, WARNING, EXCEEDED
  final String? period;
  final String? categoryName;
  final String? categoryIcon;

  factory BudgetStatusResponse.fromJson(Map<String, dynamic> json) {
    String? cName;
    String? cIcon;
    if (json['category'] is Map<String, dynamic>) {
      cName = json['category']['name'] as String?;
      cIcon = json['category']['icon'] as String?;
    }

    final alert = json['alertStatus']?.toString() ??
        json['status']?.toString() ??
        json['statusCode']?.toString() ??
        'SAFE';

    return BudgetStatusResponse(
      budgetId: json['budgetId']?.toString() ?? json['id']?.toString() ?? '',
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
      effectiveLimit: (json['effectiveLimit'] as num?)?.toDouble() ?? 0.0,
      remainingAmount: (json['remainingAmount'] as num?)?.toDouble() ?? 0.0,
      spentAmount: (json['spentAmount'] as num?)?.toDouble() ?? 0.0,
      dailyBudgetRemaining: (json['dailyBudgetRemaining'] as num?)?.toDouble() ?? 0.0,
      daysRemaining: (json['daysRemaining'] as num?)?.toInt() ?? 0,
      rolloverAmount: (json['rolloverAmount'] as num?)?.toDouble() ?? 0.0,
      limitAmount: (json['limitAmount'] as num?)?.toDouble() ?? 0.0,
      statusCode: alert.toUpperCase(),
      period: json['period']?.toString(),
      categoryName: cName,
      categoryIcon: cIcon,
    );
  }

  Map<String, dynamic> toJson() => {
        'budgetId': budgetId,
        'percentage': percentage,
        'effectiveLimit': effectiveLimit,
        'remainingAmount': remainingAmount,
        'spentAmount': spentAmount,
        'dailyBudgetRemaining': dailyBudgetRemaining,
        'daysRemaining': daysRemaining,
        'rolloverAmount': rolloverAmount,
        'limitAmount': limitAmount,
        'alertStatus': statusCode,
        'statusCode': statusCode,
        'period': period,
      };
}
