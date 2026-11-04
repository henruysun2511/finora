import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import 'auth_providers.dart';
import 'forgot_password_state.dart';

class ForgotPasswordNotifier extends AutoDisposeNotifier<ForgotPasswordState> {
  @override
  ForgotPasswordState build() => const ForgotPasswordState();

  /// Bước 1: Gửi mã OTP 6 số về email
  Future<bool> sendOtp(String email) async {
    if (state.isLoading) return false;
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final repo = ref.read(authRepositoryProvider);
      final res = await repo.forgotPassword(email.trim());

      state = state.copyWith(
        isLoading: false,
        step: ForgotPasswordStep.otp,
        email: email.trim(),
        maskedEmail: res.email,
        expiresIn: res.expiresIn,
      );

      return true;
    } catch (e) {
      final msg = e is AppException ? e.message : e.toString();
      state = state.copyWith(
        isLoading: false,
        errorMessage: msg,
      );
      return false;
    }
  }

  /// Bước 2: Xác thực mã OTP 6 số
  Future<bool> verifyOtp(String otp) async {
    if (state.isLoading) return false;
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final repo = ref.read(authRepositoryProvider);
      final resetToken = await repo.verifyOtp(state.email, otp.trim());

      state = state.copyWith(
        isLoading: false,
        step: ForgotPasswordStep.newPassword,
        resetToken: resetToken,
      );
      return true;
    } catch (e) {
      final msg = e is AppException ? e.message : e.toString();
      state = state.copyWith(
        isLoading: false,
        errorMessage: msg,
      );
      return false;
    }
  }

  /// Gửi lại mã OTP (Resend)
  Future<bool> resendOtp() async {
    if (state.isLoading || state.email.isEmpty) return false;
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final repo = ref.read(authRepositoryProvider);
      final res = await repo.forgotPassword(state.email);

      state = state.copyWith(
        isLoading: false,
        expiresIn: res.expiresIn,
      );

      return true;
    } catch (e) {
      final msg = e is AppException ? e.message : e.toString();
      state = state.copyWith(
        isLoading: false,
        errorMessage: msg,
      );
      return false;
    }
  }

  /// Bước 3: Đặt lại mật khẩu mới
  Future<bool> resetPassword(String newPassword) async {
    if (state.isLoading) return false;
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.resetPassword(state.resetToken, newPassword);

      state = state.copyWith(
        isLoading: false,
        step: ForgotPasswordStep.success,
      );
      return true;
    } catch (e) {
      final msg = e is AppException ? e.message : e.toString();
      state = state.copyWith(
        isLoading: false,
        errorMessage: msg,
      );
      return false;
    }
  }

  /// Quay lại bước nhập email
  void changeEmail() {
    state = state.copyWith(
      step: ForgotPasswordStep.email,
      clearError: true,
    );
  }
}

final forgotPasswordProvider =
    NotifierProvider.autoDispose<ForgotPasswordNotifier, ForgotPasswordState>(
  ForgotPasswordNotifier.new,
);
