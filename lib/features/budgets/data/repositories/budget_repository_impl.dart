import '../../domain/models/budget.dart';
import '../../domain/models/budget_filter.dart';
import '../../domain/models/budget_input.dart';
import '../../domain/models/budget_live_status.dart';
import '../../domain/models/budget_period.dart';
import '../../domain/models/budget_summary.dart';
import '../../domain/repositories/budget_repository.dart';
import '../mappers/budget_mapper.dart';
import '../services/budget_api_service.dart';

class BudgetRepositoryImpl implements BudgetRepository {
  BudgetRepositoryImpl(this._service);

  final BudgetApiService _service;

  @override
  Future<List<Budget>> getBudgets(BudgetFilter filter) async {
    final responseList = await _service.getBudgets(
      walletId: filter.walletId,
      periodType: filter.periodType?.value,
    );
    final items = responseList.map(BudgetMapper.toDomain).toList();

    // Lọc theo search query ở client nếu có
    if (filter.searchQuery != null && filter.searchQuery!.trim().isNotEmpty) {
      final q = filter.searchQuery!.trim().toLowerCase();
      return items.where((b) {
        final cat = (b.categoryName ?? '').toLowerCase();
        final wal = (b.walletName ?? '').toLowerCase();
        return cat.contains(q) || wal.contains(q);
      }).toList();
    }
    return items;
  }

  @override
  Future<BudgetSummary> getBudgetSummary({String? walletId}) async {
    final items = await getBudgets(BudgetFilter(walletId: walletId));
    double totalLimit = 0;
    double totalSpent = 0;
    int maxDays = 0;

    for (final b in items) {
      totalLimit += b.effectiveLimit;
      totalSpent += b.spentAmount;
      if (b.daysRemaining > maxDays) maxDays = b.daysRemaining;
    }

    final now = DateTime.now();
    final periodLabel = 'Tháng ${now.month.toString().padLeft(2, '0')}/${now.year}';

    return BudgetSummary(
      totalLimit: totalLimit,
      totalSpent: totalSpent,
      periodLabel: periodLabel,
      daysRemaining: maxDays,
    );
  }

  @override
  Future<Budget> getBudgetById(String id) async {
    final res = await _service.getBudgetById(id);
    return BudgetMapper.toDomain(res);
  }

  @override
  Future<BudgetLiveStatus> getBudgetStatus(String id) async {
    final res = await _service.getBudgetStatus(id);
    return BudgetMapper.toStatusDomain(res);
  }

  @override
  Future<List<BudgetPeriod>> getBudgetHistory(String id) async {
    final res = await _service.getBudgetHistory(id);
    return res.map(BudgetMapper.toPeriodDomain).toList();
  }

  @override
  Future<Budget> createBudget(BudgetInput input) async {
    final req = BudgetMapper.toCreateRequest(input);
    final res = await _service.createBudget(req);
    return BudgetMapper.toDomain(res);
  }

  @override
  Future<Budget> updateBudget(String id, BudgetInput input) async {
    final req = BudgetMapper.toUpdateRequest(input);
    final res = await _service.updateBudget(id, req);
    return BudgetMapper.toDomain(res);
  }

  @override
  Future<void> deleteBudget(String id) => _service.deleteBudget(id);

  @override
  Future<Budget> resetBudgetPeriod(String id) async {
    final res = await _service.resetBudgetPeriod(id);
    return BudgetMapper.toDomain(res);
  }
}
