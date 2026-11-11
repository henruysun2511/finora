import '../../domain/models/currency_conversion_result.dart';
import '../../domain/models/exchange_rate.dart';
import '../../domain/repositories/exchange_rate_repository.dart';
import '../services/exchange_rate_api_service.dart';

class ExchangeRateRepositoryImpl implements ExchangeRateRepository {
  ExchangeRateRepositoryImpl(this._apiService);

  final ExchangeRateApiService _apiService;

  // Tỷ lệ biến động tham chiếu (24h) để hiển thị chỉ số thị trường
  static const Map<String, double> _referenceChanges = {
    'USD': 0.12,
    'EUR': 0.05,
    'JPY': -0.20,
    'GBP': 0.35,
    'SGD': 0.08,
    'AUD': -0.15,
    'CNY': 0.02,
    'KRW': -0.09,
    'CAD': 0.04,
    'THB': -0.03,
  };

  // Giá trị tỷ giá dự phòng so với VND khi mất mạng / offline
  static const Map<String, double> _fallbackVndRates = {
    'USD': 25450.0,
    'EUR': 27620.0,
    'JPY': 168.5,
    'GBP': 32850.0,
    'SGD': 19420.0,
    'AUD': 16740.0,
    'CNY': 3580.0,
    'KRW': 18.6,
    'CAD': 18520.0,
    'THB': 735.0,
  };

  @override
  Future<ExchangeRate> getExchangeRate(String from, String to) async {
    final f = from.trim().toUpperCase();
    final t = to.trim().toUpperCase();

    if (f == t) {
      return ExchangeRate(
        from: f,
        to: t,
        rate: 1.0,
        inverseRate: 1.0,
        updatedAt: DateTime.now(),
        source: 'live',
        isEstimated: false,
      );
    }

    try {
      final dto = await _apiService.getExchangeRate(f, t);
      return dto.toDomain(changePercentage: _referenceChanges[f]);
    } catch (_) {
      // Offline / fallback calculation nếu quy đổi với VND
      if (t == 'VND' && _fallbackVndRates.containsKey(f)) {
        final rate = _fallbackVndRates[f]!;
        return ExchangeRate(
          from: f,
          to: t,
          rate: rate,
          inverseRate: 1 / rate,
          updatedAt: DateTime.now(),
          source: 'fallback',
          isEstimated: true,
          changePercentage: _referenceChanges[f],
        );
      }
      rethrow;
    }
  }

  @override
  Future<CurrencyConversionResult> convertCurrency({
    required String from,
    required String to,
    required double amount,
  }) async {
    final f = from.trim().toUpperCase();
    final t = to.trim().toUpperCase();

    if (f == t) {
      return CurrencyConversionResult(
        from: f,
        to: t,
        amount: amount,
        convertedAmount: amount,
        rate: 1.0,
        inverseRate: 1.0,
        updatedAt: DateTime.now(),
        source: 'live',
        isEstimated: false,
      );
    }

    try {
      final dto = await _apiService.convertCurrency(
        from: f,
        to: t,
        amount: amount,
      );
      return dto.toConversionResult();
    } catch (_) {
      // Fallback offline calculation
      if (t == 'VND' && _fallbackVndRates.containsKey(f)) {
        final rate = _fallbackVndRates[f]!;
        final converted = amount * rate;
        return CurrencyConversionResult(
          from: f,
          to: t,
          amount: amount,
          convertedAmount: double.parse(converted.toStringAsFixed(2)),
          rate: rate,
          inverseRate: 1 / rate,
          updatedAt: DateTime.now(),
          source: 'fallback',
          isEstimated: true,
        );
      }
      rethrow;
    }
  }

  @override
  Future<List<ExchangeRate>> getPopularRatesAgainstVnd({
    List<String> currencies = const [
      'USD',
      'EUR',
      'JPY',
      'GBP',
      'SGD',
      'AUD',
      'CNY',
      'KRW',
    ],
  }) async {
    final results = await Future.wait(
      currencies.map((curr) async {
        try {
          return await getExchangeRate(curr, 'VND');
        } catch (_) {
          final fallbackRate = _fallbackVndRates[curr] ?? 1.0;
          return ExchangeRate(
            from: curr,
            to: 'VND',
            rate: fallbackRate,
            inverseRate: 1 / fallbackRate,
            updatedAt: DateTime.now(),
            source: 'fallback',
            isEstimated: true,
            changePercentage: _referenceChanges[curr],
          );
        }
      }),
    );
    return results;
  }
}

