import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/budget_filter.dart';

/// State quản lý bộ lọc danh sách ngân sách (lọc theo Ví hoặc Chu kỳ)
class BudgetFilterNotifier extends Notifier<BudgetFilter> {
  @override
  BudgetFilter build() => const BudgetFilter();

  void setWalletId(String? walletId) {
    state = state.copyWith(walletId: walletId, clearWalletId: walletId == null);
  }

  void setSearchQuery(String? query) {
    state = state.copyWith(searchQuery: query);
  }
}

final budgetFilterProvider = NotifierProvider<BudgetFilterNotifier, BudgetFilter>(
  BudgetFilterNotifier.new,
);

