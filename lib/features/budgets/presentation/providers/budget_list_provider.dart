import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/budget_summary.dart';
import 'budget_filter_provider.dart';
import 'budget_list_state.dart';
import 'budget_providers.dart';

class BudgetListNotifier extends AsyncNotifier<BudgetListState> {
  @override
  Future<BudgetListState> build() async {
    final filter = ref.watch(budgetFilterProvider);
    final repo = ref.watch(budgetRepositoryProvider);

    // Tối ưu hiệu năng: Chỉ gọi 1 API request duy nhất thay vì gọi 2 lần song song
    final items = await repo.getBudgets(filter);

    // Tính toán tổng quan trực tiếp từ danh sách items
    double totalLimit = 0;
    double totalSpent = 0;
    int maxDays = 0;

    for (final b in items) {
      totalLimit += b.effectiveLimit;
      totalSpent += b.spentAmount;
      if (b.daysRemaining > maxDays) maxDays = b.daysRemaining;
    }

    final now = DateTime.now();
    final monthStr = now.month.toString().padLeft(2, '0');
    final periodLabel = 'Tháng $monthStr/${now.year}';

    final summary = BudgetSummary(
      totalLimit: totalLimit,
      totalSpent: totalSpent,
      periodLabel: periodLabel,
      daysRemaining: maxDays,
    );

    return BudgetListState(
      items: items,
      summary: summary,
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
