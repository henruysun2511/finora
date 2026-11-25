class GeneralSettings {
  final String defaultCurrency;
  final String language;
  final String defaultTransactionVisibility;
  final bool defaultAmountHidden;

  const GeneralSettings({
    this.defaultCurrency = 'VND',
    this.language = 'vi',
    this.defaultTransactionVisibility = 'PRIVATE',
    this.defaultAmountHidden = true,
  });

  factory GeneralSettings.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const GeneralSettings();
    return GeneralSettings(
      defaultCurrency: (map['defaultCurrency'] as String?)?.toUpperCase() ?? 'VND',
      language: (map['language'] as String?)?.toLowerCase() ?? 'vi',
      defaultTransactionVisibility:
          (map['defaultTransactionVisibility'] as String?)?.toUpperCase() ?? 'PRIVATE',
      defaultAmountHidden: map['defaultAmountHidden'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'defaultCurrency': defaultCurrency,
      'language': language,
      'defaultTransactionVisibility': defaultTransactionVisibility,
      'defaultAmountHidden': defaultAmountHidden,
    };
  }

  GeneralSettings copyWith({
    String? defaultCurrency,
    String? language,
    String? defaultTransactionVisibility,
    bool? defaultAmountHidden,
  }) {
    return GeneralSettings(
      defaultCurrency: defaultCurrency ?? this.defaultCurrency,
      language: language ?? this.language,
      defaultTransactionVisibility:
          defaultTransactionVisibility ?? this.defaultTransactionVisibility,
      defaultAmountHidden: defaultAmountHidden ?? this.defaultAmountHidden,
    );
  }
}

