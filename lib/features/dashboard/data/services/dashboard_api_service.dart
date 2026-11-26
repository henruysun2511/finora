import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../domain/models/budget_health_model.dart';
import '../../domain/models/calendar_dashboard_model.dart';
import '../../domain/models/cash_flow_model.dart';
import '../../domain/models/category_breakdown_model.dart';
import '../../domain/models/dashboard_overview_model.dart';
import '../../domain/models/debts_dashboard_model.dart';
import '../../domain/models/shared_wallet_dashboard_model.dart';

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

    // Trả về dữ liệu trống mặc định khi chưa có dữ liệu hoặc lỗi
    return _emptyOverview();
  }

  // 2. GET /dashboard/budget-health
  Future<BudgetHealthModel> getBudgetHealth({String? month}) async {
    try {
      final res = await _dio.get<dynamic>(
        ApiConstants.dashboardBudgetHealth,
        queryParameters: month != null ? {'month': month} : null,
      );
      final data = _extractData(res.data);
      if (data.isNotEmpty) {
        return BudgetHealthModel.fromJson(data);
      }
    } catch (_) {}

    return _emptyBudgetHealth();
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

    return _emptyCashFlow(period);
  }

  // 4. GET /dashboard/category-breakdown
  Future<CategoryBreakdownModel> getCategoryBreakdown({String? month, String? type}) async {
    try {
      final res = await _dio.get<dynamic>(
        ApiConstants.dashboardCategoryBreakdown,
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

    return _emptyCategoryBreakdown(month, type);
  }

  // 5. GET /dashboard/debts
  Future<DebtsDashboardModel> getDebts({String? walletId}) async {
    try {
      final res = await _dio.get<dynamic>(
        ApiConstants.dashboardDebts,
        queryParameters: walletId != null ? {'walletId': walletId} : null,
      );
      final data = _extractData(res.data);
      if (data.isNotEmpty) {
        return DebtsDashboardModel.fromJson(data);
      }
    } catch (_) {}

    return _emptyDebts();
  }

  // 6. GET /dashboard/calendar
  Future<CalendarDashboardModel> getCalendar({String? month}) async {
    try {
      final res = await _dio.get<dynamic>(
        ApiConstants.dashboardCalendar,
        queryParameters: month != null ? {'month': month} : null,
      );
      final data = _extractData(res.data);
      if (data.isNotEmpty) {
        return CalendarDashboardModel.fromJson(data);
      }
    } catch (_) {}

    return _emptyCalendar(month);
  }

  // 7. GET /dashboard/shared-wallet/:walletId
  Future<SharedWalletDashboardModel> getSharedWalletDashboard(String walletId) async {
    try {
      final res = await _dio.get<dynamic>(
        ApiConstants.dashboardSharedWallet(walletId),
      );
      final data = _extractData(res.data);
      if (data.isNotEmpty) {
        return SharedWalletDashboardModel.fromJson(data);
      }
    } catch (_) {}

    return _emptySharedWallet(walletId);
  }

  // ── EMPTY STATE CHUẨN KHI CHƯA CÓ DỮ LIỆU HOẶC OFFLINE ───────────────────────
  DashboardOverviewModel _emptyOverview() {
    final now = DateTime.now();
    final monthStr = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    return DashboardOverviewModel(
      netWorth: 0.0,
      currency: 'VND',
      assetTier: const AssetTierModel(
        tier: 'START',
        title: 'Khởi đầu',
        mascotMood: 'HAPPY',
        nextTierThreshold: 10000000.0,
      ),
      monthlyCashflow: MonthlyCashflowModel(
        month: monthStr,
        income: 0.0,
        expense: 0.0,
        netCashflow: 0.0,
        savingsRate: 0.0,
        momIncomeChange: 0.0,
        momExpenseChange: 0.0,
      ),
      accountsSummary: const [],
      activeAlerts: const [],
      recentTransactions: const [],
    );
  }

  BudgetHealthModel _emptyBudgetHealth() {
    final now = DateTime.now();
    final monthStr = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    return BudgetHealthModel(
      month: monthStr,
      daysPassed: now.day,
      daysRemaining: daysInMonth - now.day,
      totalBudgetLimit: 0.0,
      totalSpent: 0.0,
      remainingBudget: 0.0,
      spentPercentage: 0.0,
      burnRateMetrics: const BurnRateMetricsModel(
        actualDailyBurnRate: 0.0,
        recommendedDailyBurnRate: 0.0,
        projectedMonthEndExpense: 0.0,
        projectedRunwayDate: '',
        willOverspend: false,
        estimatedOverspendAmount: 0.0,
      ),
      categoryBudgets: const [],
    );
  }

  CashFlowModel _emptyCashFlow(String? period) {
    return CashFlowModel(
      period: period ?? 'MONTH',
      totalIncome: 0.0,
      totalExpense: 0.0,
      netSavings: 0.0,
      timeline: const [],
      dayOfWeekHeatmap: const [],
      timeOfDayDistribution: const {},
    );
  }

  CategoryBreakdownModel _emptyCategoryBreakdown(String? month, String? type) {
    final now = DateTime.now();
    final monthStr = month ?? '${now.year}-${now.month.toString().padLeft(2, '0')}';
    return CategoryBreakdownModel(
      month: monthStr,
      type: type ?? 'EXPENSE',
      totalAmount: 0.0,
      currency: 'VND',
      rule503020Evaluation: const Rule503020EvaluationModel(
        needs: Rule503020MetricModel(amount: 0, percentage: 0, targetPercentage: 50.0, status: 'OPTIMAL'),
        wants: Rule503020MetricModel(amount: 0, percentage: 0, targetPercentage: 30.0, status: 'OPTIMAL'),
        savings: Rule503020MetricModel(amount: 0, percentage: 0, targetPercentage: 20.0, status: 'OPTIMAL'),
      ),
      categories: const [],
      topSpendingItems: const [],
    );
  }

  DebtsDashboardModel _emptyDebts() {
    return const DebtsDashboardModel(
      totalReceivables: 0.0,
      totalPayables: 0.0,
      netDebtPosition: 0.0,
      debtToAssetRatio: 0.0,
      overdueStats: OverdueStatsModel(
        overdueReceivableCount: 0,
        overdueReceivableAmount: 0.0,
        overduePayableCount: 0,
        overduePayableAmount: 0.0,
      ),
      topDebtors: [],
      installments: [],
    );
  }

  CalendarDashboardModel _emptyCalendar(String? month) {
    final now = DateTime.now();
    final monthStr = month ?? '${now.year}-${now.month.toString().padLeft(2, '0')}';
    return CalendarDashboardModel(
      month: monthStr,
      days: const [],
      upcomingBillsSummary: const UpcomingBillsSummaryModel(
        totalUpcoming30Days: 0.0,
        projectedDisposableCash: 0.0,
        bills: [],
      ),
    );
  }

  SharedWalletDashboardModel _emptySharedWallet(String walletId) {
    return SharedWalletDashboardModel(
      walletId: walletId,
      walletName: 'Ví chung',
      totalSpent: 0.0,
      currency: 'VND',
      memberContributions: const [],
      settlementMatrix: const SettlementMatrixModel(
        isBalanced: true,
        suggestedSettlements: [],
      ),
    );
  }
}
