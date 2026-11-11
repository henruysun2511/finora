import '../../domain/models/currency_conversion_result.dart';
import 'exchange_rate_response_dto.dart';

class ConvertCurrencyResponseDto extends ExchangeRateResponseDto {
  const ConvertCurrencyResponseDto({
    required super.from,
    required super.to,
    required super.rate,
    required super.inverseRate,
    required super.updatedAt,
    required super.source,
    required super.isEstimated,
    required this.amount,
    required this.convertedAmount,
  });

  final double amount;
  final double convertedAmount;

  factory ConvertCurrencyResponseDto.fromJson(Map<String, dynamic> json) {
    return ConvertCurrencyResponseDto(
      from: (json['from'] as String? ?? '').toUpperCase(),
      to: (json['to'] as String? ?? '').toUpperCase(),
      rate: (json['rate'] as num?)?.toDouble() ?? 1.0,
      inverseRate: (json['inverseRate'] as num?)?.toDouble() ?? 1.0,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      source: json['source'] as String? ?? 'live',
      isEstimated: json['isEstimated'] as bool? ?? false,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      convertedAmount: (json['convertedAmount'] as num?)?.toDouble() ?? 0.0,
    );
  }

  CurrencyConversionResult toConversionResult() {
    return CurrencyConversionResult(
      from: from,
      to: to,
      amount: amount,
      convertedAmount: convertedAmount,
      rate: rate,
      inverseRate: inverseRate,
      updatedAt: updatedAt,
      source: source,
      isEstimated: isEstimated,
    );
  }
}

