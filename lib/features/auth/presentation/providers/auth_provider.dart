import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/auth_interceptor.dart';
import '../../domain/models/login_input.dart';
import '../../domain/models/user.dart';
import 'auth_providers.dart';

part 'auth_provider.g.dart';

@Riverpod(keepAlive: true)
class AuthNotifier extends _$AuthNotifier {
  @override
  Future<User?> build() async {
    final sub = AuthInterceptor.onUnauthorized.listen((_) {
      clearLocalSession();
    });
    ref.onDispose(sub.cancel);

    try {
      return await ref.watch(authRepositoryProvider).getCurrentUser();
    } catch (_) {
      return null;
    }
  }

  /// Đăng nhập bằng username hoặc email
  Future<void> login({
    String? username,
    String? email,
    required String password,
  }) async {
    final account = (username ?? email ?? '').trim();
    state = const AsyncValue.loading();
    try {
      final user = await ref
          .read(authRepositoryProvider)
          .login(LoginInput(username: account, password: password));
      state = AsyncValue.data(user);
    } on AppException catch (e, st) {
      state = AsyncValue.error(e, st);
    } catch (e, st) {
      state = AsyncValue.error(AppException.unknown(e.toString()), st);
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    try {
      final user = await ref
          .read(authRepositoryProvider)
          .register(name: name, email: email, password: password);
      state = AsyncValue.data(user);
    } on AppException catch (e, st) {
      state = AsyncValue.error(e, st);
    } catch (e, st) {
      state = AsyncValue.error(AppException.unknown(e.toString()), st);
    }
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    state = const AsyncValue.data(null);
  }

  Future<void> clearLocalSession() async {
    await ref.read(authRepositoryProvider).clearLocalSession();
    state = const AsyncValue.data(null);
  }

  void updateLocalUser(User user) {
    state = AsyncValue.data(user);
  }

  Future<User> updateProfile({
    String? name,
    String? phone,
    String? avatarUrl,
  }) async {
    final updated = await ref.read(authRepositoryProvider).updateProfile(
          name: name,
          phone: phone,
          avatarUrl: avatarUrl,
        );
    state = AsyncValue.data(updated);
    return updated;
  }
}
