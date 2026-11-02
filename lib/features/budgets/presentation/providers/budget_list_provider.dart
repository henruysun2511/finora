import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'budget_filter_provider.dart';
import 'budget_list_state.dart';
import 'budget_providers.dart';

class BudgetListNotifier extends AsyncNotifier<BudgetListState> {
  @override
  Future<BudgetListState> build() async {
    final filter = ref.watch(budgetFilterProvider);
    final repo = ref.watch(budgetRepositoryProvider);

    final itemsFuture = repo.getBudgets(filter);
    final summaryFuture = repo.getBudgetSummary(walletId: filter.walletId);

    final results = await Future.wait([itemsFuture, summaryFuture]);

    return BudgetListState(
      items: results[0] as dynamic,
      summary: results[1] as dynamic,
    );
  }

  /// Làm mới toàn bộ dữ liệu (Pull to refresh)
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => build());
  }

  /// Xóa ngân sách và cập nhật UI tức thì
  Future<void> deleteBudget(String id) async {
    await ref.read(budgetRepositoryProvider).deleteBudget(id);
    final cur = state.value;
    if (cur != null) {
      final updatedItems = cur.items.where((b) => b.id != id).toList();
      state = AsyncData(cur.copyWith(items: updatedItems));
      // Tải lại summary mới
      ref.invalidateSelf();
    }
  }
}

final budgetListProvider =
    AsyncNotifierProvider<BudgetListNotifier, BudgetListState>(
  BudgetListNotifier.new,
);

