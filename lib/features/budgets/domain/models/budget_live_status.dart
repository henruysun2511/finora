import 'budget_enums.dart';

/// Mô hình tiến độ thời gian thực của ngân sách trả về từ API `GET /budgets/:id/status`
class BudgetLiveStatus {
  const BudgetLiveStatus({
    required this.budgetId,
    required this.effectiveLimit,
    required this.spentAmount,
    required this.remainingAmount,
    required this.percentage,
    required this.dailyBudgetRemaining,
    required this.daysRemaining,
    required this.status,
    this.rolloverAmount = 0.0,
    this.limitAmount = 0.0,
  });

  final String budgetId;
  final double effectiveLimit;
  final double spentAmount;
  final double remainingAmount;
  final double percentage;
  final double dailyBudgetRemaining;
  final int daysRemaining;
  final BudgetProgressStatus status;
  final double rolloverAmount;
  final double limitAmount;
}

