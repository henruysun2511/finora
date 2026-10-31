import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/services/recurring-transaction-api-service.dart';
import '../../data/repositories/recurring-transaction-repository-impl.dart';
import '../../domain/repositories/recurring-transaction-repository.dart';

final recurringTransactionApiServiceProvider = Provider<RecurringTransactionApiService>((ref) {
  return RecurringTransactionApiService(ref.watch(dioProvider));
});

final recurringTransactionRepositoryProvider = Provider<RecurringTransactionRepository>((ref) {
  final api = ref.watch(recurringTransactionApiServiceProvider);
  return RecurringTransactionRepositoryImpl(api);
});