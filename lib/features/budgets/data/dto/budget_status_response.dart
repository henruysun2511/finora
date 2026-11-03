/// DTO trạng thái chi tiết theo thời gian thực: GET /api/v1/budgets/:id/status
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
    this.statusCode = 'SAFE',
  });

  final String budgetId;
  final double percentage;
  final double effectiveLimit;
  final double remainingAmount;
  final double spentAmount;
  final double dailyBudgetRemaining;
  final int daysRemaining;
  final double rolloverAmount;
  final String statusCode;

  factory BudgetStatusResponse.fromJson(Map<String, dynamic> json) {
    return BudgetStatusResponse(
      budgetId: json['budgetId']?.toString() ?? json['id']?.toString() ?? '',
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
      effectiveLimit: (json['effectiveLimit'] as num?)?.toDouble() ?? 0.0,
      remainingAmount: (json['remainingAmount'] as num?)?.toDouble() ?? 0.0,
      spentAmount: (json['spentAmount'] as num?)?.toDouble() ?? 0.0,
      dailyBudgetRemaining: (json['dailyBudgetRemaining'] as num?)?.toDouble() ?? 0.0,
      daysRemaining: (json['daysRemaining'] as num?)?.toInt() ?? 0,
      rolloverAmount: (json['rolloverAmount'] as num?)?.toDouble() ?? 0.0,
      statusCode: (json['status'] as String?) ?? (json['statusCode'] as String?) ?? 'SAFE',
    );
  }
}

