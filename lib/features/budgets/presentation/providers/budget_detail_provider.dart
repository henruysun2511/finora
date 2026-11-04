import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/budget.dart';
import '../../domain/models/budget_live_status.dart';
import '../../domain/models/budget_period.dart';
import 'budget_list_provider.dart';
import 'budget_providers.dart';

class BudgetDetailData {
  const BudgetDetailData({
    required this.budget,
    required this.history,
    this.liveStatus,
  });

  final Budget budget;
  final List<BudgetPeriod> history;
  final BudgetLiveStatus? liveStatus;
}

final budgetDetailProvider =
    FutureProvider.family<BudgetDetailData, String>((ref, id) async {
  final repo = ref.watch(budgetRepositoryProvider);
  final budget = await repo.getBudgetById(id);

  BudgetLiveStatus? liveStatus;
  try {
    liveStatus = await repo.getBudgetStatus(id);
  } catch (_) {
    // Fallback an toàn nếu status api gặp vấn đề mạng
  }

  final history = budget.historyPeriods.isNotEmpty
      ? budget.historyPeriods
      : await repo.getBudgetHistory(id);

  return BudgetDetailData(
    budget: budget,
    history: history,
    liveStatus: liveStatus,
  );
});

/// Action Provider để chốt kỳ ngân sách sớm (Reset period)
final budgetResetPeriodProvider =
    Provider.family<Future<Budget> Function(), String>((ref, id) {
  return () async {
    final repo = ref.read(budgetRepositoryProvider);
    final updated = await repo.resetBudgetPeriod(id);
    ref.invalidate(budgetDetailProvider(id));
    ref.invalidate(budgetListProvider);
    return updated;
  };
});
