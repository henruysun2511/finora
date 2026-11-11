import '../../domain/models/exchange_rate.dart';

class ExchangeRateResponseDto {
  const ExchangeRateResponseDto({
    required this.from,
    required this.to,
    required this.rate,
    required this.inverseRate,
    required this.updatedAt,
    required this.source,
    required this.isEstimated,
  });

  final String from;
  final String to;
  final double rate;
  final double inverseRate;
  final DateTime updatedAt;
  final String source;
  final bool isEstimated;

  factory ExchangeRateResponseDto.fromJson(Map<String, dynamic> json) {
    return ExchangeRateResponseDto(
      from: (json['from'] as String? ?? '').toUpperCase(),
      to: (json['to'] as String? ?? '').toUpperCase(),
      rate: (json['rate'] as num?)?.toDouble() ?? 1.0,
      inverseRate: (json['inverseRate'] as num?)?.toDouble() ?? 1.0,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      source: json['source'] as String? ?? 'live',
      isEstimated: json['isEstimated'] as bool? ?? false,
    );
  }

  ExchangeRate toDomain({double? changePercentage}) {
    return ExchangeRate(
      from: from,
      to: to,
      rate: rate,
      inverseRate: inverseRate,
      updatedAt: updatedAt,
      source: source,
      isEstimated: isEstimated,
      changePercentage: changePercentage,
    );
  }
}

