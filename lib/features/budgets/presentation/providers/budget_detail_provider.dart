import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/budget.dart';
import '../../domain/models/budget_period.dart';
import 'budget_list_provider.dart';
import 'budget_providers.dart';

class BudgetDetailData {
  const BudgetDetailData({
    required this.budget,
    required this.history,
  });

  final Budget budget;
  final List<BudgetPeriod> history;
}

final budgetDetailProvider =
    FutureProvider.family<BudgetDetailData, String>((ref, id) async {
  final repo = ref.watch(budgetRepositoryProvider);
  final budgetFuture = repo.getBudgetById(id);
  final historyFuture = repo.getBudgetHistory(id);

  final res = await Future.wait([budgetFuture, historyFuture]);
  return BudgetDetailData(
    budget: res[0] as Budget,
    history: res[1] as List<BudgetPeriod>,
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

