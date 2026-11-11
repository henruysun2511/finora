import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/exchange_rate.dart';
import 'exchange_rate_providers.dart';

final popularRatesProvider =
    AsyncNotifierProvider<PopularRatesNotifier, List<ExchangeRate>>(() {
  return PopularRatesNotifier();
});

class PopularRatesNotifier extends AsyncNotifier<List<ExchangeRate>> {
  @override
  Future<List<ExchangeRate>> build() async {
    return _fetchRates();
  }

  Future<List<ExchangeRate>> _fetchRates() async {
    final repo = ref.read(exchangeRateRepositoryProvider);
    return repo.getPopularRatesAgainstVnd();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchRates());
  }
}

