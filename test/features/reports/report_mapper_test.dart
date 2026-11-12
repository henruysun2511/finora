import 'package:finora_mb/features/dashboard/domain/models/category_breakdown_model.dart';
import 'package:finora_mb/features/dashboard/domain/models/dashboard_overview_model.dart';
import 'package:finora_mb/features/reports/data/mappers/report_mapper.dart';
import 'package:finora_mb/features/reports/domain/models/report_period.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ReportMapper - toDomain', () {
    test('chuyển đổi đúng CategoryBreakdownModel và Overview sang ReportOverviewData', () {
      const breakdown = CategoryBreakdownModel(
        month: '2026-10',
        type: 'EXPENSE',
        totalAmount: 18200000,
        currency: 'VND',
        categories: [
          CategoryBreakdownItemModel(
            id: 'cat-1',
            name: 'Ăn uống & Ẩm thực',
            icon: '🍜',
            color: '#FF5733',
            amount: 6916000,
            percentage: 38.0,
            subCategories: [
              SubCategoryBreakdownItemModel(
                id: 'sub-1',
                name: 'Nhà hàng',
                amount: 4200000,
                percentage: 23.08,
              ),
            ],
          ),
        ],
        topSpendingItems: [],
      );

      const overview = DashboardOverviewModel(
        netWorth: 158500000,
        currency: 'VND',
        assetTier: AssetTierModel(
          tier: 'GOLD',
          title: 'Nhà Tích Lũy Vàng',
          mascotMood: 'HAPPY',
          nextTierThreshold: 200000000,
        ),
        monthlyCashflow: MonthlyCashflowModel(
          month: '2026-10',
          income: 35000000,
          expense: 18200000,
          netCashflow: 16800000,
          savingsRate: 48.0,
          momIncomeChange: 12.5,
          momExpenseChange: -5.2,
        ),
        accountsSummary: [],
        activeAlerts: [],
        recentTransactions: [],
      );

      final domain = ReportMapper.toDomain(
        period: ReportPeriod.month,
        targetDate: DateTime(2026, 10, 1),
        categoryBreakdown: breakdown,
        overview: overview,
      );

      expect(domain.period, ReportPeriod.month);
      expect(domain.totalExpense, 18200000);
      expect(domain.totalIncome, 35000000);
      expect(domain.netSavings, 16800000);
      expect(domain.savingsRate, 48.0);
      expect(domain.statMetrics.isSavingsRateExceeded, isTrue);

      expect(domain.slices.length, 1);
      expect(domain.slices.first.name, 'Ăn uống & Ẩm thực');
      expect(domain.slices.first.percentage, 38.0);

      expect(domain.categories.length, 1);
      expect(domain.categories.first.subCategories.length, 1);
      expect(domain.categories.first.subCategories.first.name, 'Nhà hàng');
    });
  });
}
