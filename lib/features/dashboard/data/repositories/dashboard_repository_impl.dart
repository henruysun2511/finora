import '../../domain/models/budget_health_model.dart';
import '../../domain/models/calendar_dashboard_model.dart';
import '../../domain/models/cash_flow_model.dart';
import '../../domain/models/category_breakdown_model.dart';
import '../../domain/models/dashboard_overview_model.dart';
import '../../domain/models/debts_dashboard_model.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../services/dashboard_api_service.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardApiService _service;

  DashboardRepositoryImpl(this._service);

  @override
  Future<DashboardOverviewModel> getOverview({String? walletId}) {
    return _service.getOverview(walletId: walletId);
  }

  @override
  Future<BudgetHealthModel> getBudgetHealth({String? month}) {
    return _service.getBudgetHealth(month: month);
  }

  @override
  Future<CashFlowModel> getCashFlow({String? period}) {
    return _service.getCashFlow(period: period);
  }

  @override
  Future<CategoryBreakdownModel> getCategoryBreakdown({String? month, String? type}) {
    return _service.getCategoryBreakdown(month: month, type: type);
  }

  @override
  Future<DebtsDashboardModel> getDebts({String? walletId}) {
    return _service.getDebts(walletId: walletId);
  }

  @override
  Future<CalendarDashboardModel> getCalendar({String? month}) {
    return _service.getCalendar(month: month);
  }
}
