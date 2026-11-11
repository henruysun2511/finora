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
      savingsRate = cashFlow.savingsRate;
      momIncomeChange = cashFlow.momIncomeChange;
      momExpenseChange = cashFlow.momExpenseChange;
    } else if (overview != null) {
      totalIncome = overview.monthlyCashflow.income;
      totalExpense = overview.monthlyCashflow.expense;
      netSavings = overview.monthlyCashflow.netCashflow;
      savingsRate = overview.monthlyCashflow.savingsRate;
    }

    final summary = ReportFinancialSummary(
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      netSavings: netSavings,
      savingsRate: savingsRate,
      momIncomeChange: momIncomeChange,
      momExpenseChange: momExpenseChange,
    );

    // 3. Quy tắc 50/30/20
    ReportRule503020? rule503020;
    if (categoryBreakdown?.rule503020Evaluation != null) {
      final r = categoryBreakdown!.rule503020Evaluation!;
      rule503020 = ReportRule503020(
        needsAmount: r.needs.amount,
        needsPercentage: r.needs.percentage,
        wantsAmount: r.wants.amount,
        wantsPercentage: r.wants.percentage,
        savingsAmount: r.savings.amount,
        savingsPercentage: r.savings.percentage,
        isNeedsCompliant: r.needs.percentage <= 50,
        isWantsCompliant: r.wants.percentage <= 30,
        isSavingsCompliant: r.savings.percentage >= 20,
      );
    }

    return ReportOverviewData(
      period: period,
      targetDate: targetDate,
      summary: summary,
      slices: slices,
      categories: categories,
      rule503020: rule503020,
      customStart: customStart,
      customEnd: customEnd,
    );
  }
}
