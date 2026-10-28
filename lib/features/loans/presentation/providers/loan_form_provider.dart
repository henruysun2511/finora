import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../domain/models/loan.dart';
import '../../domain/models/loan_input.dart';
import 'loan_list_provider.dart';
import 'loan_providers.dart';

class LoanFormState {
  const LoanFormState({
    this.isSubmitting = false,
    this.errorMessage,
  });

  final bool isSubmitting;
  final String? errorMessage;

  LoanFormState copyWith({
    bool? isSubmitting,
    String? errorMessage,
    bool clearError = false,
  }) {
    return LoanFormState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class LoanFormNotifier extends AutoDisposeNotifier<LoanFormState> {
  @override
  LoanFormState build() => const LoanFormState();

  Future<Loan?> submit(LoanInput input) async {
    if (state.isSubmitting) return null;
    state = state.copyWith(isSubmitting: true, clearError: true);

    try {
      final saved = await ref.read(loanRepositoryProvider).createLoan(input);
      ref.invalidate(loanListProvider);
      ref.invalidate(loanSummaryProvider);
      state = state.copyWith(isSubmitting: false);
      return saved;
    } catch (error) {
      final message = error is AppException ? error.message : error.toString();
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: message,
      );
      return null;
    }
  }
}

final loanFormProvider =
    AutoDisposeNotifierProvider<LoanFormNotifier, LoanFormState>(
  LoanFormNotifier.new,
);
