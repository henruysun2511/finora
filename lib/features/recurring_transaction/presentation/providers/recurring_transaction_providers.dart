import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/services/recurring_transaction_api_service.dart';
import '../../data/repositories/recurring_transaction_repository_impl.dart';
import '../../domain/repositories/recurring_transaction_repository.dart';

final recurringTransactionApiServiceProvider =
    Provider<RecurringTransactionApiService>((ref) {
  return RecurringTransactionApiService(ref.watch(dioProvider));
});

final recurringTransactionRepositoryProvider =
    Provider<RecurringTransactionRepository>((ref) {
  final api = ref.watch(recurringTransactionApiServiceProvider);
  return RecurringTransactionRepositoryImpl(api);
});
