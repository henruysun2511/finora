import '../models/budget_health_model.dart';
import '../models/calendar_dashboard_model.dart';
import '../models/cash_flow_model.dart';
import '../models/category_breakdown_model.dart';
import '../models/dashboard_overview_model.dart';
import '../models/debts_dashboard_model.dart';

abstract class DashboardRepository {
  Future<DashboardOverviewModel> getOverview({String? walletId});
  Future<BudgetHealthModel> getBudgetHealth({String? month});
  Future<CashFlowModel> getCashFlow({String? period});
  Future<CategoryBreakdownModel> getCategoryBreakdown({String? month, String? type});
  Future<DebtsDashboardModel> getDebts({String? walletId});
  Future<CalendarDashboardModel> getCalendar({String? month});
}
