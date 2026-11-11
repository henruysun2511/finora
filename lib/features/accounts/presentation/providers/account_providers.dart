import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_client.dart';
import '../../data/repositories/account_repository_impl.dart';
import '../../data/services/account_api_service.dart';
import '../../domain/repositories/account_repository.dart';

final accountApiServiceProvider = Provider<AccountApiService>((ref) {
  return DioAccountApiService(ref.watch(dioProvider));
});

final accountRepositoryProvider = Provider<AccountRepository>((ref) {
  return AccountRepositoryImpl(ref.watch(accountApiServiceProvider));
});

