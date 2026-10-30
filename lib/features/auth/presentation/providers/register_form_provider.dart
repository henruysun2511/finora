import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../domain/models/register_input.dart';
import '../../domain/models/user.dart';
import 'auth_provider.dart';
import 'auth_providers.dart';
import 'register_form_state.dart';

class RegisterFormNotifier extends AutoDisposeNotifier<RegisterFormState> {
  @override
  RegisterFormState build() => const RegisterFormState();

  /// Đăng ký tài khoản: trả về User nếu thành công, hoặc null nếu gặp lỗi (lỗi lưu trong state.errorMessage)
  Future<User?> submit(RegisterInput input) async {
    if (state.isSubmitting) return null;
    state = state.copyWith(isSubmitting: true, clearError: true);

    try {
      final repo = ref.read(authRepositoryProvider);
      final user = await repo.register(input);

      // Cập nhật người dùng vào phiên đăng nhập toàn cục
      ref.read(authNotifierProvider.notifier).updateLocalUser(user);

      state = state.copyWith(isSubmitting: false);
      return user;
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

final registerFormProvider =
    NotifierProvider.autoDispose<RegisterFormNotifier, RegisterFormState>(
  RegisterFormNotifier.new,
);
