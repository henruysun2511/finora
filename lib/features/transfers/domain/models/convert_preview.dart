class ConvertPreview {
  final String fromAccountId;
  final String fromAccountName;
  final String fromCurrency;
  final double fromAmount;
  final String toAccountId;
  final String toAccountName;
  final String toCurrency;
  final double toAmount;
  final double exchangeRate;
  final double inverseRate;
  final bool isEstimated;
  final String rateSource;

  const ConvertPreview({
    required this.fromAccountId,
    required this.fromAccountName,
    required this.fromCurrency,
    required this.fromAmount,
    required this.toAccountId,
    required this.toAccountName,
    required this.toCurrency,
    required this.toAmount,
    required this.exchangeRate,
    required this.inverseRate,
    required this.isEstimated,
    required this.rateSource,
  });

  factory ConvertPreview.fromJson(Map<String, dynamic> json) {
    return ConvertPreview(
      fromAccountId: json['fromAccountId'] as String? ?? '',
      fromAccountName: json['fromAccountName'] as String? ?? '',
      fromCurrency: json['fromCurrency'] as String? ?? 'VND',
      fromAmount: (json['fromAmount'] as num?)?.toDouble() ?? 0.0,
      toAccountId: json['toAccountId'] as String? ?? '',
      toAccountName: json['toAccountName'] as String? ?? '',
      toCurrency: json['toCurrency'] as String? ?? 'VND',
      toAmount: (json['toAmount'] as num?)?.toDouble() ?? 0.0,
      exchangeRate: (json['exchangeRate'] as num?)?.toDouble() ?? 1.0,
      inverseRate: (json['inverseRate'] as num?)?.toDouble() ?? 1.0,
      isEstimated: json['isEstimated'] as bool? ?? false,
      rateSource: json['rateSource'] as String? ?? 'live',
    );
  }
}
