import '../../../dashboard/domain/models/cash_flow_model.dart';
import '../../../dashboard/domain/models/category_breakdown_model.dart';
import '../../../dashboard/domain/models/dashboard_overview_model.dart';
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
    String compareLabel = 'so với kỳ trước';

    if (overview != null) {
      final monthly = overview.monthlyCashflow;
      totalIncome = monthly.income;
      totalExpense = monthly.expense;
      netSavings = monthly.netCashflow;
      savingsRate = monthly.savingsRate;
      momIncomeChange = monthly.momIncomeChange;
      momExpenseChange = monthly.momExpenseChange;

      final prevMonthNumber = targetDate.month == 1 ? 12 : targetDate.month - 1;
      compareLabel = 'so với T$prevMonthNumber';
    } else if (cashFlow != null) {
      totalIncome = cashFlow.totalIncome;
      totalExpense = cashFlow.totalExpense;
      netSavings = cashFlow.netSavings;
      savingsRate = totalIncome > 0 ? (netSavings / totalIncome) * 100 : 0;
      compareLabel = 'so với kỳ trước';
    }

    // Nếu category breakdown có tổng chi tiêu khác 0 và tổng chi tiêu của stat đang là 0
    if (totalExpense == 0 && categoryBreakdown != null && categoryBreakdown.totalAmount > 0) {
      totalExpense = categoryBreakdown.totalAmount;
      if (totalIncome > 0) {
        netSavings = totalIncome - totalExpense;
        savingsRate = (netSavings / totalIncome) * 100;
      }
    }

    return ReportOverviewData(
      period: period,
      targetDate: targetDate,
      customStart: customStart,
      customEnd: customEnd,
      statMetrics: ReportStatMetrics(
        totalIncome: totalIncome,
        totalExpense: totalExpense,
        netSavings: netSavings,
        savingsRate: savingsRate,
        momIncomeChange: momIncomeChange,
        momExpenseChange: momExpenseChange,
        targetSavingsRate: 40.0,
        comparePeriodLabel: compareLabel,
      ),
      slices: slices,
      categories: categories,
      currency: 'VND',
    );
  }
}
