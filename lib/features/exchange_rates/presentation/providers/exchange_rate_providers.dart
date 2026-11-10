import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_client.dart';
import '../../data/repositories/exchange_rate_repository_impl.dart';
import '../../data/services/exchange_rate_api_service.dart';
import '../../domain/repositories/exchange_rate_repository.dart';

final exchangeRateApiServiceProvider = Provider<ExchangeRateApiService>((ref) {
  return DioExchangeRateApiService(ref.watch(dioProvider));
});

final exchangeRateRepositoryProvider = Provider<ExchangeRateRepository>((ref) {
  return ExchangeRateRepositoryImpl(ref.watch(exchangeRateApiServiceProvider));
});

