enum ForgotPasswordStep {
  email,
  otp,
  newPassword,
  success,
}

class ForgotPasswordState {
  final ForgotPasswordStep step;
  final bool isLoading;
  final String? errorMessage;
  final String email;
  final String maskedEmail;
  final int expiresIn;
  final String resetToken;

  const ForgotPasswordState({
    this.step = ForgotPasswordStep.email,
    this.isLoading = false,
    this.errorMessage,
    this.email = '',
    this.maskedEmail = '',
    this.expiresIn = 30,
    this.resetToken = '',
  });

  ForgotPasswordState copyWith({
    ForgotPasswordStep? step,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    String? email,
    String? maskedEmail,
    int? expiresIn,
    String? resetToken,
  }) {
    return ForgotPasswordState(
      step: step ?? this.step,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      email: email ?? this.email,
      maskedEmail: maskedEmail ?? this.maskedEmail,
      expiresIn: expiresIn ?? this.expiresIn,
      resetToken: resetToken ?? this.resetToken,
    );
  }
}
