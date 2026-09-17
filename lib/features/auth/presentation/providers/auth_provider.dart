import 'dart:convert';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/auth_interceptor.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../data/models/user_model.dart';
import '../../domain/entities/user.dart';

part 'auth_provider.g.dart';

@Riverpod(keepAlive: true)
class AuthNotifier extends _$AuthNotifier {
  @override
  Future<User?> build() async {
    final sub = AuthInterceptor.onUnauthorized.listen((_) {
      logout();
    });
    ref.onDispose(sub.cancel);

    final token = await ref.watch(secureStorageProvider).getAccessToken();
    if (token == null || token.isEmpty) {
      // Cho mục đích demo / offline ban đầu: trả về User mặc định phong cách ui-sample-3
      return const User(
        id: '1',
        name: 'Nguyễn Văn A',
        email: 'nguyenvana@finora.vn',
        avatarUrl: null,
      );
    }

    final cached = ref.watch(localStorageProvider).getCachedUser();
    if (cached != null) {
      try {
        return UserModel.fromJson(jsonDecode(cached) as Map<String, dynamic>);
      } catch (_) {}
    }

    return const User(
      id: '1',
      name: 'Nguyễn Văn A',
      email: 'nguyenvana@finora.vn',
    );
  }

  Future<void> login({required String email, required String password}) async {
    state = const AsyncValue.loading();
    await Future.delayed(const Duration(milliseconds: 600)); // Simulating network
    const user = User(
      id: '1',
      name: 'Nguyễn Văn A',
      email: 'nguyenvana@finora.vn',
    );
    await ref.read(secureStorageProvider).saveAccessToken('mock_access_token');
    state = const AsyncValue.data(user);
  }

  Future<void> logout() async {
    await ref.read(secureStorageProvider).clearTokens();
    await ref.read(localStorageProvider).clearCachedUser();
    state = const AsyncValue.data(null);
  }
}
