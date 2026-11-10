import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../dashboard/domain/models/cash_flow_model.dart';
import '../../../dashboard/domain/models/category_breakdown_model.dart';
import '../../../dashboard/domain/models/dashboard_overview_model.dart';
import '../dto/report_query_dto.dart';

class ReportsApiService {
  final Dio _dio;

  ReportsApiService(this._dio);

  Map<String, dynamic> _extractData(dynamic responseData) {
    if (responseData is Map<String, dynamic>) {
      if (responseData['data'] is Map<String, dynamic>) {
        return responseData['data'] as Map<String, dynamic>;
      }
      return responseData;
    }
    return <String, dynamic>{};
  }

  Future<CategoryBreakdownModel> getCategoryBreakdown(ReportQueryDto query) async {
    try {
      final res = await _dio.get<dynamic>(
        '/dashboard/category-breakdown',
        queryParameters: query.toCategoryQueryParams(),
      );
      final data = _extractData(res.data);
      if (data.isNotEmpty) {
        return CategoryBreakdownModel.fromJson(data);
      }
    } catch (_) {}

    return _mockCategoryBreakdown();
  }

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

    return _mockOverview();
  }

  Future<CashFlowModel> getCashFlow(ReportQueryDto query) async {
    try {
      final res = await _dio.get<dynamic>(
        ApiConstants.dashboardCashFlow,
        queryParameters: query.toCashFlowQueryParams(),
      );
      final data = _extractData(res.data);
      if (data.isNotEmpty) {
        return CashFlowModel.fromJson(data);
      }
    } catch (_) {}

    return _mockCashFlow();
  }

  CategoryBreakdownModel _mockCategoryBreakdown() {
    return const CategoryBreakdownModel(
      month: '2026-10',
      type: 'EXPENSE',
      totalAmount: 18200000,
      currency: 'VND',
      categories: [
        CategoryBreakdownItemModel(
          id: 'cat-food',
          name: 'Ăn uống & Ẩm thực',
          icon: '🍜',
          color: '#FF5733',
          amount: 6916000,
          percentage: 38.0,
          subCategories: [
            SubCategoryBreakdownItemModel(
              id: 'sub-rest',
              name: 'Nhà hàng',
              amount: 4200000,
              percentage: 23.08,
            ),
            SubCategoryBreakdownItemModel(
              id: 'sub-cafe',
              name: 'Cà phê & Trà',
              amount: 1500000,
              percentage: 8.24,
            ),
            SubCategoryBreakdownItemModel(
              id: 'sub-market',
              name: 'Đi chợ',
              amount: 1216000,
              percentage: 6.68,
            ),
          ],
        ),
        CategoryBreakdownItemModel(
          id: 'cat-housing',
          name: 'Nhà cửa & Tiện ích',
          icon: '🏠',
          color: '#3B82F6',
          amount: 4004000,
          percentage: 22.0,
          subCategories: [
            SubCategoryBreakdownItemModel(
              id: 'sub-rent',
              name: 'Tiền nhà',
              amount: 3500000,
              percentage: 19.23,
            ),
            SubCategoryBreakdownItemModel(
              id: 'sub-bills',
              name: 'Điện nước & Net',
              amount: 504000,
              percentage: 2.77,
            ),
          ],
        ),
        CategoryBreakdownItemModel(
          id: 'cat-transport',
          name: 'Di chuyển & Đi lại',
          icon: '🚗',
          color: '#F59E0B',
          amount: 2730000,
          percentage: 15.0,
          subCategories: [
            SubCategoryBreakdownItemModel(
              id: 'sub-gas',
              name: 'Xăng xe',
              amount: 1800000,
              percentage: 9.89,
            ),
            SubCategoryBreakdownItemModel(
              id: 'sub-taxi',
              name: 'Grab & Taxi',
              amount: 930000,
              percentage: 5.11,
            ),
          ],
        ),
        CategoryBreakdownItemModel(
          id: 'cat-shopping',
          name: 'Mua sắm & Giải trí',
          icon: '🛍️',
          color: '#8B5CF6',
          amount: 2730000,
          percentage: 15.0,
          subCategories: [
            SubCategoryBreakdownItemModel(
              id: 'sub-clothes',
              name: 'Quần áo',
              amount: 1700000,
              percentage: 9.34,
            ),
            SubCategoryBreakdownItemModel(
              id: 'sub-movie',
              name: 'Phim & Giải trí',
              amount: 1030000,
              percentage: 5.66,
            ),
          ],
        ),
        CategoryBreakdownItemModel(
          id: 'cat-health',
          name: 'Y tế & Khác',
          icon: '💊',
          color: '#10B981',
          amount: 1820000,
          percentage: 10.0,
          subCategories: [
            SubCategoryBreakdownItemModel(
              id: 'sub-med',
              name: 'Thuốc & Khám',
              amount: 1200000,
              percentage: 6.59,
            ),
            SubCategoryBreakdownItemModel(
              id: 'sub-other',
              name: 'Linh tinh',
              amount: 620000,
              percentage: 3.41,
            ),
          ],
        ),
      ],
      topSpendingItems: [],
    );
  }

  DashboardOverviewModel _mockOverview() {
    return const DashboardOverviewModel(
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
  }

  CashFlowModel _mockCashFlow() {
    return const CashFlowModel(
      period: 'MONTH',
      totalIncome: 35000000,
      totalExpense: 18200000,
      netSavings: 16800000,
      timeline: [],
      dayOfWeekHeatmap: [],
      timeOfDayDistribution: {},
    );
  }
}
