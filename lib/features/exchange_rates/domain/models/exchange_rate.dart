class ExchangeRate {
  const ExchangeRate({
    required this.from,
    required this.to,
    required this.rate,
    required this.inverseRate,
    required this.updatedAt,
    this.source = 'live',
    this.isEstimated = false,
    this.changePercentage,
  });

  final String from;
  final String to;
  final double rate;
  final double inverseRate;
  final DateTime updatedAt;
  final String source; // 'live', 'cache', 'fallback'
  final bool isEstimated;
  final double? changePercentage; // e.g. +0.12 or -0.20

  String get pairCode => '$from/$to';

  ExchangeRate copyWith({
    String? from,
    String? to,
    double? rate,
    double? inverseRate,
    DateTime? updatedAt,
    String? source,
    bool? isEstimated,
    double? changePercentage,
  }) {
    return ExchangeRate(
      from: from ?? this.from,
      to: to ?? this.to,
      rate: rate ?? this.rate,
      inverseRate: inverseRate ?? this.inverseRate,
      updatedAt: updatedAt ?? this.updatedAt,
      source: source ?? this.source,
      isEstimated: isEstimated ?? this.isEstimated,
      changePercentage: changePercentage ?? this.changePercentage,
    );
  }
}

