import 'report_period.dart';

class ReportSubCategoryBreakdown {
  final String id;
  final String name;
  final double amount;
  final double percentage;

  const ReportSubCategoryBreakdown({
    required this.id,
    required this.name,
    required this.amount,
    required this.percentage,
  });
}

class ReportCategoryBreakdown {
  final String id;
  final String name;
  final String icon;
  final String colorHex;
  final double amount;
  final double percentage;
  final List<ReportSubCategoryBreakdown> subCategories;

  const ReportCategoryBreakdown({
    required this.id,
    required this.name,
    required this.icon,
    required this.colorHex,
    required this.amount,
    required this.percentage,
    required this.subCategories,
  });
}

class ReportDonutSlice {
  final String id;
  final String name;
  final String icon;
  final String colorHex;
  final double amount;
  final double percentage;

  const ReportDonutSlice({
    required this.id,
    required this.name,
    required this.icon,
    required this.colorHex,
    required this.amount,
    required this.percentage,
  });
}

class ReportStatMetrics {
  final double totalIncome;
  final double totalExpense;
  final double netSavings;
  final double savingsRate;
  final double momIncomeChange;
  final double momExpenseChange;
  final double targetSavingsRate;
  final String comparePeriodLabel;

  const ReportStatMetrics({
    required this.totalIncome,
    required this.totalExpense,
    required this.netSavings,
    required this.savingsRate,
    required this.momIncomeChange,
    required this.momExpenseChange,
    this.targetSavingsRate = 40.0,
    required this.comparePeriodLabel,
  });

  bool get isSavingsRateExceeded => savingsRate >= targetSavingsRate;
}

class ReportOverviewData {
  final ReportPeriod period;
  final DateTime targetDate;
  final DateTime? customStart;
  final DateTime? customEnd;
  final ReportStatMetrics statMetrics;
  final List<ReportDonutSlice> slices;
  final List<ReportCategoryBreakdown> categories;
  final String currency;

  const ReportOverviewData({
    required this.period,
    required this.targetDate,
    this.customStart,
    this.customEnd,
    required this.statMetrics,
    required this.slices,
    required this.categories,
    this.currency = 'VND',
  });

  double get totalExpense => statMetrics.totalExpense;
  double get totalIncome => statMetrics.totalIncome;
  double get netSavings => statMetrics.netSavings;
  double get savingsRate => statMetrics.savingsRate;
}
