import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_client.dart';
import '../../data/repositories/dashboard_repository_impl.dart';
import '../../data/services/dashboard_api_service.dart';
import '../../domain/models/budget_health_model.dart';
import '../../domain/models/calendar_dashboard_model.dart';
import '../../domain/models/cash_flow_model.dart';
import '../../domain/models/category_breakdown_model.dart';
import '../../domain/models/dashboard_overview_model.dart';
import '../../domain/models/debts_dashboard_model.dart';
import '../../domain/models/shared_wallet_dashboard_model.dart';
import '../../domain/repositories/dashboard_repository.dart';

final dashboardApiServiceProvider = Provider<DashboardApiService>((ref) {
  final dio = ref.watch(dioProvider);
  return DashboardApiService(dio);
});

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  final api = ref.watch(dashboardApiServiceProvider);
  return DashboardRepositoryImpl(api);
});

/// 1. Provider nạp Tổng quan tài chính & Tài sản ròng
final dashboardOverviewProvider =
    FutureProvider.autoDispose<DashboardOverviewModel>((ref) async {
  final repo = ref.watch(dashboardRepositoryProvider);
  return repo.getOverview();
});

/// 2. Provider nạp Sức khỏe ngân sách & Burn-rate
final dashboardBudgetHealthProvider =
    FutureProvider.autoDispose<BudgetHealthModel>((ref) async {
  final repo = ref.watch(dashboardRepositoryProvider);
  return repo.getBudgetHealth();
});

/// 3. Provider nạp Dòng tiền & Xu hướng chi tiêu
final dashboardCashFlowProvider =
    FutureProvider.autoDispose<CashFlowModel>((ref) async {
  final repo = ref.watch(dashboardRepositoryProvider);
  return repo.getCashFlow();
});

/// 4. Provider nạp Cơ cấu danh mục & Quy tắc 50/30/20
final dashboardCategoryBreakdownProvider =
    FutureProvider.autoDispose<CategoryBreakdownModel>((ref) async {
  final repo = ref.watch(dashboardRepositoryProvider);
  return repo.getCategoryBreakdown();
});

/// 5. Provider nạp Sổ nợ & Vị thế nợ ròng
final dashboardDebtsProvider =
    FutureProvider.autoDispose<DebtsDashboardModel>((ref) async {
  final repo = ref.watch(dashboardRepositoryProvider);
  return repo.getDebts();
});

/// 6. Provider nạp Lịch chi tiêu & Hóa đơn sắp tới
final dashboardCalendarProvider =
    FutureProvider.autoDispose<CalendarDashboardModel>((ref) async {
  final repo = ref.watch(dashboardRepositoryProvider);
  return repo.getCalendar();
});

/// 7. Provider nạp Thống kê ví chung & Ma trận cấn trừ nợ
final dashboardSharedWalletProvider =
    FutureProvider.autoDispose.family<SharedWalletDashboardModel, String>(
        (ref, walletId) async {
  final repo = ref.watch(dashboardRepositoryProvider);
  return repo.getSharedWalletDashboard(walletId);
});
