import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/loan.dart';
import 'loan_filter_provider.dart';
import 'loan_list_state.dart';
import 'loan_providers.dart';

/// Notifier cho danh sách khoản nợ.
/// Tự động reload khi filter thay đổi nhờ ref.watch(loanFilterProvider).
class LoanListNotifier extends AsyncNotifier<LoanListState> {
  @override
  Future<LoanListState> build() async {
    final filter = ref.watch(loanFilterProvider);
    final repo = ref.watch(loanRepositoryProvider);

    final loans = await repo.getLoans(
      type: filter.type?.value,
      status: filter.status?.value,
      search: filter.search,
      sortBy: filter.sortBy.value,
      sortOrder: filter.sortOrder.value,
    );

    return LoanListState(items: loans);
  }

  /// Pull-to-refresh
  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }

  /// Xóa khoản nợ rồi cập nhật danh sách cục bộ
  Future<void> deleteLoan(String id) async {
    await ref.read(loanRepositoryProvider).deleteLoan(id);
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(
      current.copyWith(items: current.items.where((l) => l.id != id).toList()),
    );
    // Invalidate summary để cập nhật hero card
    ref.invalidate(loanSummaryProvider);
  }

  /// Cập nhật 1 khoản nợ trong danh sách (sau khi payment hoặc edit)
  void updateLoanInList(Loan updated) {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(
      current.copyWith(
        items:
            current.items.map((l) => l.id == updated.id ? updated : l).toList(),
      ),
    );
    ref.invalidate(loanSummaryProvider);
  }
}

final loanListProvider = AsyncNotifierProvider<LoanListNotifier, LoanListState>(
    LoanListNotifier.new);

// ── Summary (Hero Card) ───────────────────────────────────────────────────────

final loanSummaryProvider = FutureProvider((ref) async {
  final repo = ref.watch(loanRepositoryProvider);
  return repo.getLoanSummary();
});

// ── Detail ────────────────────────────────────────────────────────────────────

final loanDetailProvider =
    FutureProvider.autoDispose.family<Loan, String>((ref, id) async {
  final repo = ref.watch(loanRepositoryProvider);
  return repo.getLoanById(id);
});

// ── Payments Timeline ─────────────────────────────────────────────────────────

final loanPaymentsProvider =
    FutureProvider.autoDispose.family((ref, String loanId) async {
  final repo = ref.watch(loanRepositoryProvider);
  return repo.getLoanPayments(loanId);
});

// ── Reminder Rate Limit State ─────────────────────────────────────────────────
// Lưu thời gian nhắc nợ cuối cùng theo loanId (phía client để update UI)
final reminderCooldownProvider =
    StateProvider.family<DateTime?, String>((ref, loanId) => null);
