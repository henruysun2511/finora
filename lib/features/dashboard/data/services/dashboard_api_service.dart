import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../domain/models/budget_health_model.dart';
import '../../domain/models/calendar_dashboard_model.dart';
import '../../domain/models/cash_flow_model.dart';
import '../../domain/models/category_breakdown_model.dart';
import '../../domain/models/dashboard_overview_model.dart';
import '../../domain/models/debts_dashboard_model.dart';

class DashboardApiService {
  final Dio _dio;

  DashboardApiService(this._dio);

  Map<String, dynamic> _extractData(dynamic responseData) {
    if (responseData is Map<String, dynamic>) {
      if (responseData['data'] is Map<String, dynamic>) {
        return responseData['data'] as Map<String, dynamic>;
      }
      return responseData;
    }
    return <String, dynamic>{};
  }

  // 1. GET /dashboard/overview
  Future<DashboardOverviewModel> getOverview({String? walletId}) async {
    try {
      final res = await _dio.get<dynamic>(
        ApiConstants.dashboardOverview,
        queryParameters: walletId != null ? {'walletId': walletId} : null,
      );
      final data = _extractData(res.data);
      if (data.isNotEmpty) {
        return DashboardOverviewModel.fromJson(data);
      }
    } catch (_) {}

    // Fallback Mock chuẩn FinTech
    return _mockOverview();
  }

  // 2. GET /dashboard/budget-health
  Future<BudgetHealthModel> getBudgetHealth({String? month}) async {
    try {
      final res = await _dio.get<dynamic>(
        '/dashboard/budget-health',
        queryParameters: month != null ? {'month': month} : null,
      );
      final data = _extractData(res.data);
      if (data.isNotEmpty) {
        return BudgetHealthModel.fromJson(data);
      }
    } catch (_) {}

    return _mockBudgetHealth();
  }

  // 3. GET /dashboard/cash-flow
  Future<CashFlowModel> getCashFlow({String? period}) async {
    try {
      final res = await _dio.get<dynamic>(
        ApiConstants.dashboardCashFlow,
        queryParameters: period != null ? {'period': period} : null,
      );
      final data = _extractData(res.data);
      if (data.isNotEmpty) {
        return CashFlowModel.fromJson(data);
      }
    } catch (_) {}

    return _mockCashFlow();
  }

  // 4. GET /dashboard/category-breakdown
  Future<CategoryBreakdownModel> getCategoryBreakdown({String? month, String? type}) async {
    try {
      final res = await _dio.get<dynamic>(
        '/dashboard/category-breakdown',
        queryParameters: {
          if (month != null) 'month': month,
          if (type != null) 'type': type,
        },
      );
      final data = _extractData(res.data);
      if (data.isNotEmpty) {
        return CategoryBreakdownModel.fromJson(data);
      }
    } catch (_) {}

    return _mockCategoryBreakdown();
  }

  // 5. GET /dashboard/debts
  Future<DebtsDashboardModel> getDebts({String? walletId}) async {
    try {
      final res = await _dio.get<dynamic>(
        '/dashboard/debts',
        queryParameters: walletId != null ? {'walletId': walletId} : null,
      );
      final data = _extractData(res.data);
      if (data.isNotEmpty) {
        return DebtsDashboardModel.fromJson(data);
      }
    } catch (_) {}

    return _mockDebts();
  }

  // 6. GET /dashboard/calendar
  Future<CalendarDashboardModel> getCalendar({String? month}) async {
    try {
      final res = await _dio.get<dynamic>(
        '/dashboard/calendar',
        queryParameters: month != null ? {'month': month} : null,
      );
      final data = _extractData(res.data);
      if (data.isNotEmpty) {
        return CalendarDashboardModel.fromJson(data);
      }
    } catch (_) {}

    return _mockCalendar();
  }

  // ── MOCK DATA CHUẨN FINTECH KHI OFFLINE ─────────────────────────────────────
  DashboardOverviewModel _mockOverview() {
    return DashboardOverviewModel(
      netWorth: 24850000.0,
      currency: 'VND',
      assetTier: const AssetTierModel(
        tier: 'GOLD',
        title: 'Gold Tier',
        mascotMood: 'HAPPY',
        nextTierThreshold: 50000000.0,
      ),
      monthlyCashflow: const MonthlyCashflowModel(
        month: '2026-11',
        income: 18500000.0,
        expense: 9680000.0,
        netCashflow: 8820000.0,
        savingsRate: 47.6,
        momIncomeChange: 12.5,
        momExpenseChange: -4.2,
      ),
      accountsSummary: const [
        DashboardAccountSummaryModel(
          id: 'acc-1',
          name: 'Vietcombank Priority',
          type: 'BANK',
          balance: 18350000.0,
          isExcludedFromNetWorth: false,
        ),
        DashboardAccountSummaryModel(
          id: 'acc-2',
          name: 'Ví Tiền mặt',
          type: 'CASH',
          balance: 2500000.0,
          isExcludedFromNetWorth: false,
        ),
        DashboardAccountSummaryModel(
          id: 'acc-3',
          name: 'Ví MoMo',
          type: 'E_WALLET',
          balance: 4000000.0,
          isExcludedFromNetWorth: false,
        ),
      ],
      activeAlerts: const [
        DashboardAlertModel(
          type: 'BUDGET_WARNING',
          severity: 'HIGH',
          message: "Danh mục 'Ăn uống' đã sử dụng 85% ngân sách tháng",
          relatedEntityId: 'b-1',
        ),
        DashboardAlertModel(
          type: 'RECURRING_DUE_SOON',
          severity: 'MEDIUM',
          message: 'Tiền mạng Internet (230.000₫) sẽ gia hạn vào ngày 15/11',
          relatedEntityId: 'rec-1',
        ),
      ],
      recentTransactions: [
        DashboardRecentTransactionModel(
          id: 'tx-1',
          name: 'Ăn trưa văn phòng',
          amount: 55000.0,
          type: 'EXPENSE',
          categoryName: 'Ăn uống',
          categoryIcon: '🍜',
          transactionDate: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        DashboardRecentTransactionModel(
          id: 'tx-2',
          name: 'Nhận lương tháng 11',
          amount: 15000000.0,
          type: 'INCOME',
          categoryName: 'Thu nhập',
          categoryIcon: '💰',
          transactionDate: DateTime.now().subtract(const Duration(days: 1)),
        ),
        DashboardRecentTransactionModel(
          id: 'tx-3',
          name: 'Siêu thị WinMart',
          amount: 420000.0,
          type: 'EXPENSE',
          categoryName: 'Mua sắm',
          categoryIcon: '🛒',
          transactionDate: DateTime.now().subtract(const Duration(days: 2)),
        ),
        DashboardRecentTransactionModel(
          id: 'tx-4',
          name: 'Cước Internet FPT',
          amount: 230000.0,
          type: 'EXPENSE',
          categoryName: 'Hóa đơn',
          categoryIcon: '🌐',
          transactionDate: DateTime.now().subtract(const Duration(days: 3)),
        ),
      ],
    );
  }

  BudgetHealthModel _mockBudgetHealth() {
    return const BudgetHealthModel(
      month: '2026-11',
      daysPassed: 10,
      daysRemaining: 20,
      totalBudgetLimit: 14000000.0,
      totalSpent: 4850000.0,
      remainingBudget: 9150000.0,
      spentPercentage: 34.6,
      burnRateMetrics: BurnRateMetricsModel(
        actualDailyBurnRate: 485000.0,
        recommendedDailyBurnRate: 457500.0,
        projectedMonthEndExpense: 14550000.0,
        projectedRunwayDate: '2026-11-29',
        willOverspend: true,
        estimatedOverspendAmount: 550000.0,
      ),
      categoryBudgets: [
        CategoryBudgetProgressModel(
          budgetId: 'b-1',
          categoryName: 'Ăn uống',
          icon: '🍜',
          limitAmount: 4500000.0,
          spentAmount: 3825000.0,
          remainingAmount: 675000.0,
          spentPercentage: 85.0,
          status: 'WARNING',
          colorStatus: 'ORANGE',
        ),
        CategoryBudgetProgressModel(
          budgetId: 'b-2',
          categoryName: 'Di chuyển',
          icon: '🚗',
          limitAmount: 2000000.0,
          spentAmount: 850000.0,
          remainingAmount: 1150000.0,
          spentPercentage: 42.5,
          status: 'GOOD',
          colorStatus: 'GREEN',
        ),
        CategoryBudgetProgressModel(
          budgetId: 'b-3',
          categoryName: 'Mua sắm',
          icon: '🛒',
          limitAmount: 2500000.0,
          spentAmount: 2650000.0,
          remainingAmount: 0.0,
          spentPercentage: 106.0,
          status: 'EXCEEDED',
          colorStatus: 'RED',
        ),
      ],
    );
  }

  CashFlowModel _mockCashFlow() {
    return CashFlowModel(
      period: 'MONTH',
      totalIncome: 18500000.0,
      totalExpense: 9680000.0,
      netSavings: 8820000.0,
      timeline: const [
        CashFlowTimelineItemModel(dateLabel: '01/11', income: 15000000, expense: 1200000, net: 13800000),
        CashFlowTimelineItemModel(dateLabel: '03/11', income: 0, expense: 850000, net: -850000),
        CashFlowTimelineItemModel(dateLabel: '05/11', income: 1000000, expense: 2100000, net: -1100000),
        CashFlowTimelineItemModel(dateLabel: '07/11', income: 0, expense: 450000, net: -450000),
        CashFlowTimelineItemModel(dateLabel: '09/11', income: 2500000, expense: 3100000, net: -600000),
        CashFlowTimelineItemModel(dateLabel: '10/11', income: 0, expense: 1980000, net: -1980000),
      ],
      dayOfWeekHeatmap: const [
        DayOfWeekHeatmapItemModel(dayOfWeek: 'T2', averageExpense: 350000),
        DayOfWeekHeatmapItemModel(dayOfWeek: 'T3', averageExpense: 420000),
        DayOfWeekHeatmapItemModel(dayOfWeek: 'T4', averageExpense: 280000),
        DayOfWeekHeatmapItemModel(dayOfWeek: 'T5', averageExpense: 510000),
        DayOfWeekHeatmapItemModel(dayOfWeek: 'T6', averageExpense: 720000),
        DayOfWeekHeatmapItemModel(dayOfWeek: 'T7', averageExpense: 1450000),
        DayOfWeekHeatmapItemModel(dayOfWeek: 'CN', averageExpense: 1120000),
      ],
      timeOfDayDistribution: const {
        'morning': TimeOfDayDistributionItemModel(label: 'Sáng (06h - 11h)', amount: 1850000, percentage: 19.1),
        'lunch': TimeOfDayDistributionItemModel(label: 'Trưa (11h - 14h)', amount: 3250000, percentage: 33.6),
        'afternoon': TimeOfDayDistributionItemModel(label: 'Chiều (14h - 18h)', amount: 1580000, percentage: 16.3),
        'evening': TimeOfDayDistributionItemModel(label: 'Tối (18h - 23h)', amount: 3000000, percentage: 31.0),
      },
    );
  }

  CategoryBreakdownModel _mockCategoryBreakdown() {
    return const CategoryBreakdownModel(
      month: '2026-11',
      type: 'EXPENSE',
      totalAmount: 9680000.0,
      currency: 'VND',
      rule503020Evaluation: Rule503020EvaluationModel(
        needs: Rule503020MetricModel(amount: 5033600, percentage: 52.0, targetPercentage: 50.0, status: 'SLIGHT_OVER'),
        wants: Rule503020MetricModel(amount: 2807200, percentage: 29.0, targetPercentage: 30.0, status: 'OPTIMAL'),
        savings: Rule503020MetricModel(amount: 1839200, percentage: 19.0, targetPercentage: 20.0, status: 'OPTIMAL'),
      ),
      categories: [
        CategoryBreakdownItemModel(
          id: 'cat-1',
          name: 'Ăn uống',
          icon: '🍜',
          color: '#FF6B6B',
          amount: 3825000.0,
          percentage: 39.5,
          subCategories: [
            SubCategoryBreakdownItemModel(id: 'sub-1', name: 'Cơm trưa văn phòng', amount: 1450000, percentage: 15.0),
            SubCategoryBreakdownItemModel(id: 'sub-2', name: 'Cafe & Trà sữa', amount: 850000, percentage: 8.8),
            SubCategoryBreakdownItemModel(id: 'sub-3', name: 'Đi chợ & Siêu thị', amount: 1525000, percentage: 15.7),
          ],
        ),
        CategoryBreakdownItemModel(
          id: 'cat-2',
          name: 'Mua sắm',
          icon: '🛒',
          color: '#845EC2',
          amount: 2650000.0,
          percentage: 27.4,
          subCategories: [
            SubCategoryBreakdownItemModel(id: 'sub-4', name: 'Quần áo & Phụ kiện', amount: 1650000, percentage: 17.0),
            SubCategoryBreakdownItemModel(id: 'sub-5', name: 'Đồ gia dụng', amount: 1000000, percentage: 10.4),
          ],
        ),
        CategoryBreakdownItemModel(
          id: 'cat-3',
          name: 'Di chuyển',
          icon: '🚗',
          color: '#4B4453',
          amount: 850000.0,
          percentage: 8.8,
          subCategories: [
            SubCategoryBreakdownItemModel(id: 'sub-6', name: 'Xăng xe', amount: 450000, percentage: 4.6),
            SubCategoryBreakdownItemModel(id: 'sub-7', name: 'Grab / Be', amount: 400000, percentage: 4.2),
          ],
        ),
        CategoryBreakdownItemModel(
          id: 'cat-4',
          name: 'Hóa đơn & Dịch vụ',
          icon: '🌐',
          color: '#008F7A',
          amount: 1450000.0,
          percentage: 15.0,
          subCategories: [
            SubCategoryBreakdownItemModel(id: 'sub-8', name: 'Điện nước', amount: 980000, percentage: 10.1),
            SubCategoryBreakdownItemModel(id: 'sub-9', name: 'Internet cáp quang', amount: 230000, percentage: 2.4),
            SubCategoryBreakdownItemModel(id: 'sub-10', name: 'Gói Netflix 4K', amount: 240000, percentage: 2.5),
          ],
        ),
      ],
      topSpendingItems: [
        TopSpendingItemModel(name: 'Mua áo khoác Uniqlo', amount: 1290000, categoryName: 'Mua sắm', date: '04/11/2026'),
        TopSpendingItemModel(name: 'Tiền điện sinh hoạt', amount: 980000, categoryName: 'Hóa đơn', date: '06/11/2026'),
        TopSpendingItemModel(name: 'Tiệc liên hoan cuối tuần', amount: 750000, categoryName: 'Ăn uống', date: '08/11/2026'),
      ],
    );
  }

  DebtsDashboardModel _mockDebts() {
    return const DebtsDashboardModel(
      totalReceivables: 5000000.0,
      totalPayables: 2500000.0,
      netDebtPosition: 2500000.0,
      debtToAssetRatio: 10.05,
      overdueStats: OverdueStatsModel(
        overdueReceivableCount: 0,
        overdueReceivableAmount: 0.0,
        overduePayableCount: 1,
        overduePayableAmount: 1500000.0,
      ),
      topDebtors: [
        TopDebtorItemModel(
          counterpartyName: 'Nguyễn Văn A',
          type: 'LENT',
          remainingAmount: 3000000.0,
          dueDate: '20/11/2026',
          isOverdue: false,
          daysOverdue: 0,
        ),
        TopDebtorItemModel(
          counterpartyName: 'Trần Thị B',
          type: 'BORROWED',
          remainingAmount: 1500000.0,
          dueDate: '01/11/2026',
          isOverdue: true,
          daysOverdue: 9,
        ),
        TopDebtorItemModel(
          counterpartyName: 'Lê Hoàng C',
          type: 'LENT',
          remainingAmount: 2000000.0,
          dueDate: '30/11/2026',
          isOverdue: false,
          daysOverdue: 0,
        ),
      ],
      installments: [
        InstallmentItemModel(
          loanId: 'inst-1',
          counterpartyName: 'Trả góp iPhone 15 Pro',
          totalPrincipal: 24000000.0,
          paidAmount: 16000000.0,
          remainingAmount: 8000000.0,
          progressPercentage: 66.7,
          nextDueDate: '25/11/2026',
        ),
      ],
    );
  }

  CalendarDashboardModel _mockCalendar() {
    return CalendarDashboardModel(
      month: '2026-11',
      days: List.generate(10, (i) {
        final day = i + 1;
        return CalendarDayItemModel(
          date: '2026-11-${day < 10 ? '0$day' : '$day'}',
          totalIncome: day == 1 ? 15000000.0 : (day == 8 ? 2500000.0 : 0.0),
          totalExpense: (300000 + (day * 45000)).toDouble(),
          transactionCount: 2 + (day % 3),
          hasSpikeExpense: day == 4,
        );
      }),
      upcomingBillsSummary: const UpcomingBillsSummaryModel(
        totalUpcoming30Days: 2450000.0,
        projectedDisposableCash: 12500000.0,
        bills: [
          UpcomingBillItemModel(
            id: 'bill-1',
            name: 'Tiền mạng Internet FPT',
            amount: 230000.0,
            nextRunDate: '15/11/2026',
            frequency: 'MONTHLY',
            daysRemaining: 5,
          ),
          UpcomingBillItemModel(
            id: 'bill-2',
            name: 'Gói Netflix 4K',
            amount: 260000.0,
            nextRunDate: '20/11/2026',
            frequency: 'MONTHLY',
            daysRemaining: 10,
          ),
          UpcomingBillItemModel(
            id: 'bill-3',
            name: 'Tiền nhà tháng 12',
            amount: 4500000.0,
            nextRunDate: '01/12/2026',
            frequency: 'MONTHLY',
            daysRemaining: 21,
          ),
        ],
      ),
    );
  }
}
