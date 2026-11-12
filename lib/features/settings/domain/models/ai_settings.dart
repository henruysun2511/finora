class AiSettings {
  final String provider;
  final String? model;
  final bool hasCustomApiKey;
  final String? maskedApiKey;

  const AiSettings({
    this.provider = 'GEMINI',
    this.model,
    this.hasCustomApiKey = false,
    this.maskedApiKey,
  });

  factory AiSettings.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const AiSettings();
    return AiSettings(
      provider: (map['aiProvider'] as String?)?.toUpperCase() ?? 'GEMINI',
      model: map['aiModel'] as String?,
      hasCustomApiKey: map['hasCustomApiKey'] as bool? ?? false,
      maskedApiKey: map['maskedApiKey'] as String?,
    );
  }

  AiSettings copyWith({
    String? provider,
    String? model,
    bool? hasCustomApiKey,
    String? maskedApiKey,
  }) {
    return AiSettings(
      provider: provider ?? this.provider,
      model: model ?? this.model,
      hasCustomApiKey: hasCustomApiKey ?? this.hasCustomApiKey,
      maskedApiKey: maskedApiKey ?? this.maskedApiKey,
    );
  }
}

