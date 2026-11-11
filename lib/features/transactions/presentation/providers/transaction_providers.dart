import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_client.dart';
import '../../data/repositories/transaction_repository_impl.dart';
import '../../data/services/transaction_api_service.dart';
import '../../domain/repositories/transaction_repository.dart';

final transactionApiServiceProvider = Provider<TransactionApiService>((ref) {
  return DioTransactionApiService(ref.watch(dioProvider));
});

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepositoryImpl(ref.watch(transactionApiServiceProvider));
});

