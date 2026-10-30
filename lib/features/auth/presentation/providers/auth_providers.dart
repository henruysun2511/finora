import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_client.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/services/auth_api_service.dart';
import '../../data/services/mock_auth_api_service.dart';
import '../../domain/repositories/auth_repository.dart';

const bool kUseMockAuthApi =
    bool.fromEnvironment('USE_MOCK_API', defaultValue: false);

final authApiServiceProvider = Provider<AuthApiService>((ref) {
  if (kUseMockAuthApi) {
    return MockAuthApiService();
  }
  return DioAuthApiService(ref.watch(dioProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    api: ref.watch(authApiServiceProvider),
    secureStorage: ref.watch(secureStorageProvider),
    localStorage: ref.watch(localStorageProvider),
  );
});
