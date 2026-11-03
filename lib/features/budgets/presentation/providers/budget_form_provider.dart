import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../domain/models/budget.dart';
import '../../domain/models/budget_input.dart';
import 'budget_detail_provider.dart';
import 'budget_form_state.dart';
import 'budget_list_provider.dart';
import 'budget_providers.dart';

/// Notifier quản lý trạng thái form tạo / sửa ngân sách.
/// Tham số family: `id` ngân sách khi sửa, `null` khi tạo mới.
class BudgetFormNotifier
    extends AutoDisposeFamilyNotifier<BudgetFormState, String?> {
  @override
  BudgetFormState build(String? arg) => const BudgetFormState();

  Future<Budget?> submit(BudgetInput input) async {
    // Chặn người dùng bấm liên tiếp (FinTech safety)
    if (state.isSubmitting) return null;
    state = state.copyWith(isSubmitting: true, clearError: true);

    try {
      final repo = ref.read(budgetRepositoryProvider);
      final id = arg;
      final saved = id == null
          ? await repo.createBudget(input)
          : await repo.updateBudget(id, input);

      // Invalidate các provider liên quan để làm mới dữ liệu
      ref.invalidate(budgetListProvider);
      if (id != null) ref.invalidate(budgetDetailProvider(id));

      state = state.copyWith(isSubmitting: false);
      return saved;
    } catch (e) {
      final msg = e is AppException ? e.message : e.toString();
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: msg,
      );
      return null;
    }
  }
}

final budgetFormProvider = NotifierProvider.autoDispose
    .family<BudgetFormNotifier, BudgetFormState, String?>(
  BudgetFormNotifier.new,
);

