import '../../domain/models/cash_flow_model.dart';
import '../../domain/models/category_breakdown_model.dart';
import '../../domain/models/dashboard_overview_model.dart';
import '../../domain/models/report_overview_data.dart';
import '../../domain/models/report_period.dart';

class ReportMapper {
  ReportMapper._();

  static ReportOverviewData toDomain({
    required ReportPeriod period,
    required DateTime targetDate,
    DateTime? customStart,
    DateTime? customEnd,
    CategoryBreakdownModel? categoryBreakdown,
    DashboardOverviewModel? overview,
    CashFlowModel? cashFlow,
  }) {
    // 1. Phân bổ Categories và Slices
    final categories = <ReportCategoryBreakdown>[];
    final slices = <ReportDonutSlice>[];

    if (categoryBreakdown != null && categoryBreakdown.categories.isNotEmpty) {
      for (final cat in categoryBreakdown.categories) {
        final subCategories = cat.subCategories
            .map((sub) => ReportSubCategoryBreakdown(
                  id: sub.id,
                  name: sub.name,
                  amount: sub.amount,
                  percentage: sub.percentage,
                ))
            .toList();

        categories.add(ReportCategoryBreakdown(
          id: cat.id,
          name: cat.name,
          icon: cat.icon.isEmpty ? '🏷️' : cat.icon,
          colorHex: cat.color.isEmpty ? '#0072D6' : cat.color,
          amount: cat.amount,
          percentage: cat.percentage,
          subCategories: subCategories,
        ));

        slices.add(ReportDonutSlice(
          id: cat.id,
          name: cat.name,
          icon: cat.icon.isEmpty ? '🏷️' : cat.icon,
          colorHex: cat.color.isEmpty ? '#0072D6' : cat.color,
          amount: cat.amount,
          percentage: cat.percentage,
        ));
      }
    }

    // 2. Thống kê 4 Chỉ số Vàng (Stat 4-Box Grid)
    double totalIncome = 0;
    double totalExpense = 0;
    double netSavings = 0;
    double savingsRate = 0;
    double momIncomeChange = 0;
    double momExpenseChange = 0;

    if (cashFlow != null) {
      totalIncome = cashFlow.totalIncome;
      totalExpense = cashFlow.totalExpense;
      netSavings = cashFlow.netSavings;
      savingsRate = totalIncome > 0 ? ((netSavings / totalIncome) * 100) : 0.0;
    } else if (overview != null) {
      totalIncome = overview.monthlyCashflow.income;
      totalExpense = overview.monthlyCashflow.expense;
      netSavings = overview.monthlyCashflow.netCashflow;
      savingsRate = overview.monthlyCashflow.savingsRate;
    }

    final statMetrics = ReportStatMetrics(
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      netSavings: netSavings,
      savingsRate: savingsRate,
      momIncomeChange: momIncomeChange,
      momExpenseChange: momExpenseChange,
      comparePeriodLabel: 'so với kỳ trước',
    );

    return ReportOverviewData(
      period: period,
      targetDate: targetDate,
      statMetrics: statMetrics,
      slices: slices,
      categories: categories,
      customStart: customStart,
      customEnd: customEnd,
    );
  }
}

