import '../../domain/models/budget.dart';
import '../../domain/models/budget_summary.dart';

class BudgetListState {
  const BudgetListState({
    required this.items,
    this.summary,
    this.isLoading = false,
    this.errorMessage,
  });

  final List<Budget> items;
  final BudgetSummary? summary;
  final bool isLoading;
  final String? errorMessage;

  BudgetListState copyWith({
    List<Budget>? items,
    BudgetSummary? summary,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return BudgetListState(
      items: items ?? this.items,
      summary: summary ?? this.summary,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

