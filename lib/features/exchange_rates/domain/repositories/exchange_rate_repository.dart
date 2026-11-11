import '../models/currency_conversion_result.dart';
import '../models/exchange_rate.dart';

abstract class ExchangeRateRepository {
  /// Lấy tỷ giá tham chiếu hiện tại giữa 2 đồng tiền
  Future<ExchangeRate> getExchangeRate(String from, String to);

  /// Quy đổi một lượng tiền cụ thể giữa 2 đồng tiền
  Future<CurrencyConversionResult> convertCurrency({
    required String from,
    required String to,
    required double amount,
  });

  /// Lấy danh sách tỷ giá các cặp tiền phổ biến so với VND
  Future<List<ExchangeRate>> getPopularRatesAgainstVnd({
    List<String> currencies = const ['USD', 'EUR', 'JPY', 'GBP', 'SGD', 'AUD', 'CNY', 'KRW'],
  });
}

