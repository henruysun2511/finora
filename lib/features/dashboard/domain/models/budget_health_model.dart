class BurnRateMetricsModel {
  final double actualDailyBurnRate;
  final double recommendedDailyBurnRate;
  final double projectedMonthEndExpense;
  final String? projectedRunwayDate;
  final bool willOverspend;
  final double estimatedOverspendAmount;

  String get aiPredictionText => willOverspend
      ? 'Cảnh báo: Dự kiến vượt ngân sách ${estimatedOverspendAmount > 0 ? (estimatedOverspendAmount / 1000000).toStringAsFixed(1) + "M đ" : ""} vào cuối tháng.'
      : 'Tình trạng tốt: Tốc độ chi tiêu hiện tại đang nằm trong ngưỡng an toàn so với định mức ngân sách.';

  int get predictedRunwayDays => projectedRunwayDate != null ? 15 : 30;

  const BurnRateMetricsModel({
    required this.actualDailyBurnRate,
    required this.recommendedDailyBurnRate,
    required this.projectedMonthEndExpense,
    this.projectedRunwayDate,
    required this.willOverspend,
    required this.estimatedOverspendAmount,
  });

  factory BurnRateMetricsModel.fromJson(Map<String, dynamic> json) {
    return BurnRateMetricsModel(
      actualDailyBurnRate: (json['actualDailyBurnRate'] as num?)?.toDouble() ?? 0.0,
      recommendedDailyBurnRate: (json['recommendedDailyBurnRate'] as num?)?.toDouble() ?? 0.0,
      projectedMonthEndExpense: (json['projectedMonthEndExpense'] as num?)?.toDouble() ?? 0.0,
      projectedRunwayDate: json['projectedRunwayDate']?.toString(),
      willOverspend: json['willOverspend'] == true,
      estimatedOverspendAmount: (json['estimatedOverspendAmount'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class CategoryBudgetProgressModel {
  final String budgetId;
  final String categoryName;
  final String icon;
  final double limitAmount;
  final double spentAmount;
  final double remainingAmount;
  final double spentPercentage;
  final String status; // GOOD, WARNING, EXCEEDED
  final String colorStatus; // GREEN, ORANGE, RED

  const CategoryBudgetProgressModel({
    required this.budgetId,
    required this.categoryName,
    required this.icon,
    required this.limitAmount,
    required this.spentAmount,
    required this.remainingAmount,
    required this.spentPercentage,
    required this.status,
    required this.colorStatus,
  });

  factory CategoryBudgetProgressModel.fromJson(Map<String, dynamic> json) {
    return CategoryBudgetProgressModel(
      budgetId: json['budgetId']?.toString() ?? '',
      categoryName: json['categoryName']?.toString() ?? 'Ngân sách',
      icon: json['icon']?.toString() ?? '🏷️',
      limitAmount: (json['limitAmount'] as num?)?.toDouble() ?? 0.0,
      spentAmount: (json['spentAmount'] as num?)?.toDouble() ?? 0.0,
      remainingAmount: (json['remainingAmount'] as num?)?.toDouble() ?? 0.0,
      spentPercentage: (json['spentPercentage'] as num?)?.toDouble() ?? 0.0,
      status: json['status']?.toString() ?? 'GOOD',
      colorStatus: json['colorStatus']?.toString() ?? 'GREEN',
    );
  }
}

class BudgetHealthModel {
  final String month;
  final int daysPassed;
  final int daysRemaining;
  final double totalBudgetLimit;
  final double totalSpent;
  final double remainingBudget;
  final double spentPercentage;
  final BurnRateMetricsModel burnRateMetrics;
  final List<CategoryBudgetProgressModel> categoryBudgets;

  List<CategoryBudgetProgressModel> get budgets => categoryBudgets;
  double get totalBudget => totalBudgetLimit;

  const BudgetHealthModel({
    required this.month,
    required this.daysPassed,
    required this.daysRemaining,
    required this.totalBudgetLimit,
    required this.totalSpent,
    required this.remainingBudget,
    required this.spentPercentage,
    required this.burnRateMetrics,
    required this.categoryBudgets,
  });

  factory BudgetHealthModel.fromJson(Map<String, dynamic> json) {
    return BudgetHealthModel(
      month: json['month']?.toString() ?? '',
      daysPassed: (json['daysPassed'] as num?)?.toInt() ?? 0,
      daysRemaining: (json['daysRemaining'] as num?)?.toInt() ?? 0,
      totalBudgetLimit: (json['totalBudgetLimit'] as num?)?.toDouble() ?? 0.0,
      totalSpent: (json['totalSpent'] as num?)?.toDouble() ?? 0.0,
      remainingBudget: (json['remainingBudget'] as num?)?.toDouble() ?? 0.0,
      spentPercentage: (json['spentPercentage'] as num?)?.toDouble() ?? 0.0,
      burnRateMetrics: json['burnRateMetrics'] is Map<String, dynamic>
          ? BurnRateMetricsModel.fromJson(json['burnRateMetrics'] as Map<String, dynamic>)
          : const BurnRateMetricsModel(
              actualDailyBurnRate: 0,
              recommendedDailyBurnRate: 0,
              projectedMonthEndExpense: 0,
              willOverspend: false,
              estimatedOverspendAmount: 0,
            ),
      categoryBudgets: (json['categoryBudgets'] as List<dynamic>?)
              ?.whereType<Map<String, dynamic>>()
              .map(CategoryBudgetProgressModel.fromJson)
              .toList() ??
          const [],
    );
  }
}
