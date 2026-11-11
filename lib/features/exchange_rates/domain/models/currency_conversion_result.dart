import 'exchange_rate.dart';

class CurrencyConversionResult {
  const CurrencyConversionResult({
    required this.from,
    required this.to,
    required this.amount,
    required this.convertedAmount,
    required this.rate,
    required this.inverseRate,
    required this.updatedAt,
    this.source = 'live',
    this.isEstimated = false,
  });

  final String from;
  final String to;
  final double amount;
  final double convertedAmount;
  final double rate;
  final double inverseRate;
  final DateTime updatedAt;
  final String source;
  final bool isEstimated;

  ExchangeRate toExchangeRate() {
    return ExchangeRate(
      from: from,
      to: to,
      rate: rate,
      inverseRate: inverseRate,
      updatedAt: updatedAt,
      source: source,
      isEstimated: isEstimated,
    );
  }
}

