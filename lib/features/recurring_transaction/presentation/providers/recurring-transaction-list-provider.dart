import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/recurring-transaction.dart';
import '../../domain/models/recurring-transaction-filter.dart';
import '../../domain/models/recurring-transaction-input.dart';
import 'recurring-transaction-providers.dart';

// ─── Filter Provider ─────────────────────────────────────────────────────────

final recurringTransactionFilterProvider =
    StateProvider.autoDispose<RecurringTransactionFilter>((ref) {
  return const RecurringTransactionFilter();
});

// ─── List Provider ────────────────────────────────────────────────────────────

final recurringTransactionListProvider =
    AsyncNotifierProvider.autoDispose<RecurringTransactionListNotifier,
        List<RecurringTransaction>>(() {
  return RecurringTransactionListNotifier();
});

class RecurringTransactionListNotifier
    extends AutoDisposeAsyncNotifier<List<RecurringTransaction>> {
  @override
  Future<List<RecurringTransaction>> build() async {
    final filter = ref.watch(recurringTransactionFilterProvider);
    final repo = ref.read(recurringTransactionRepositoryProvider);
    return repo.getRecurringTransactions(filter);
  }

  Future<void> togglePause(String id) async {
    final repo = ref.read(recurringTransactionRepositoryProvider);
    await repo.togglePause(id);
    ref.invalidateSelf();
  }

  Future<void> executeNow(String id) async {
    final repo = ref.read(recurringTransactionRepositoryProvider);
    await repo.executeNow(id);
    ref.invalidateSelf();
  }

  Future<void> delete(String id) async {
    final repo = ref.read(recurringTransactionRepositoryProvider);
    await repo.deleteRecurringTransaction(id);
    // Cập nhật state cục bộ ngay lập tức, không cần tải lại
    final current = state.value;
    if (current != null) {
      state = AsyncData(current.where((item) => item.id != id).toList());
    }
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}

// ─── Detail Provider ─────────────────────────────────────────────────────────

final recurringTransactionDetailProvider = AsyncNotifierProvider.autoDispose
    .family<RecurringTransactionDetailNotifier, RecurringTransaction, String>(
        () {
  return RecurringTransactionDetailNotifier();
});

class RecurringTransactionDetailNotifier extends AutoDisposeFamilyAsyncNotifier<
    RecurringTransaction, String> {
  @override
  Future<RecurringTransaction> build(String arg) async {
    final repo = ref.read(recurringTransactionRepositoryProvider);
    return repo.getRecurringTransactionById(arg);
  }

  Future<void> togglePause() async {
    final repo = ref.read(recurringTransactionRepositoryProvider);
    final current = state.value;
    if (current == null) return;
    await repo.togglePause(current.id);
    // Refresh detail và list
    ref.invalidateSelf();
    ref.invalidate(recurringTransactionListProvider);
  }

  Future<void> executeNow() async {
    final repo = ref.read(recurringTransactionRepositoryProvider);
    final current = state.value;
    if (current == null) return;
    await repo.executeNow(current.id);
    ref.invalidateSelf();
    ref.invalidate(recurringTransactionListProvider);
  }

  Future<void> delete() async {
    final repo = ref.read(recurringTransactionRepositoryProvider);
    final current = state.value;
    if (current == null) return;
    await repo.deleteRecurringTransaction(current.id);
    ref.invalidate(recurringTransactionListProvider);
  }
}

// ─── Form State & Provider ────────────────────────────────────────────────────

class RecurringTransactionFormState {
  const RecurringTransactionFormState({
    this.isSubmitting = false,
    this.errorMessage,
    this.savedItem,
  });

  final bool isSubmitting;
  final String? errorMessage;
  final RecurringTransaction? savedItem;

  RecurringTransactionFormState copyWith({
    bool? isSubmitting,
    String? errorMessage,
    bool clearError = false,
    RecurringTransaction? savedItem,
  }) {
    return RecurringTransactionFormState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      savedItem: savedItem ?? this.savedItem,
    );
  }
}

final recurringTransactionFormProvider = AutoDisposeNotifierProvider<
    RecurringTransactionFormNotifier,
    RecurringTransactionFormState>(() {
  return RecurringTransactionFormNotifier();
});

class RecurringTransactionFormNotifier
    extends AutoDisposeNotifier<RecurringTransactionFormState> {
  @override
  RecurringTransactionFormState build() => const RecurringTransactionFormState();

  Future<RecurringTransaction?> submit(RecurringTransactionInput input) async {
    if (state.isSubmitting) return null;
    state = state.copyWith(isSubmitting: true, clearError: true);

    try {
      final repo = ref.read(recurringTransactionRepositoryProvider);
      final saved = await repo.createRecurringTransaction(input);

      // Invalidate list để refresh
      ref.invalidate(recurringTransactionListProvider);

      state = state.copyWith(isSubmitting: false, savedItem: saved);
      return saved;
    } catch (e) {
      final msg = e.toString();
      state = state.copyWith(isSubmitting: false, errorMessage: msg);
      return null;
    }
  }
}