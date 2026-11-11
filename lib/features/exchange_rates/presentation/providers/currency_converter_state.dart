import '../../domain/models/currency_item.dart';

class CurrencyConverterState {
  const CurrencyConverterState({
    required this.fromCurrency,
    required this.toCurrency,
    required this.amount,
    required this.convertedAmount,
    required this.currentRate,
    required this.inverseRate,
    this.updatedAt,
    this.isLoading = false,
    this.errorMessage,
    this.isEstimated = false,
    this.source = 'live',
  });

  final CurrencyItem fromCurrency;
  final CurrencyItem toCurrency;
  final double amount;
  final double convertedAmount;
  final double currentRate; // 1 from = currentRate to
  final double inverseRate; // 1 to = inverseRate from
  final DateTime? updatedAt;
  final bool isLoading;
  final String? errorMessage;
  final bool isEstimated;
  final String source;

  factory CurrencyConverterState.initial() {
    return CurrencyConverterState(
      fromCurrency: CurrencyItem.findByCode('USD'),
      toCurrency: CurrencyItem.findByCode('VND'),
      amount: 100.0,
      convertedAmount: 2545000.0,
      currentRate: 25450.0,
      inverseRate: 1 / 25450.0,
      updatedAt: DateTime.now(),
      isLoading: false,
    );
  }

  CurrencyConverterState copyWith({
    CurrencyItem? fromCurrency,
    CurrencyItem? toCurrency,
    double? amount,
    double? convertedAmount,
    double? currentRate,
    double? inverseRate,
    DateTime? updatedAt,
    bool? isLoading,
    String? errorMessage,
    bool? isEstimated,
    String? source,
  }) {
    return CurrencyConverterState(
      fromCurrency: fromCurrency ?? this.fromCurrency,
      toCurrency: toCurrency ?? this.toCurrency,
      amount: amount ?? this.amount,
      convertedAmount: convertedAmount ?? this.convertedAmount,
      currentRate: currentRate ?? this.currentRate,
      inverseRate: inverseRate ?? this.inverseRate,
      updatedAt: updatedAt ?? this.updatedAt,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isEstimated: isEstimated ?? this.isEstimated,
      source: source ?? this.source,
    );
  }
}

