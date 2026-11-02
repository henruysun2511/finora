import 'budget_enums.dart';

/// Dữ liệu tổng hợp toàn bộ ngân sách trong kỳ (dành cho Card Tổng quan ở Màn hình 1)
class BudgetSummary {
  const BudgetSummary({
    required this.totalLimit,
    required this.totalSpent,
    required this.periodLabel,
    this.daysRemaining = 0,
  });

  final double totalLimit;
  final double totalSpent;
  final String periodLabel;
  final int daysRemaining;

  double get totalRemaining => totalLimit - totalSpent;

  double get percentage => totalLimit > 0 ? (totalSpent / totalLimit) * 100 : 0.0;

  BudgetProgressStatus get status => BudgetProgressStatus.fromPercentage(percentage);
}

