class CurrencyItem {
  const CurrencyItem({
    required this.code,
    required this.name,
    required this.symbol,
    required this.flagEmoji,
    this.countryName,
  });

  final String code; // VD: USD, VND, EUR
  final String name; // VD: Đô la Mỹ, Đồng Việt Nam
  final String symbol; // VD: $, ₫, €
  final String flagEmoji; // VD: 🇺🇸, 🇻🇳, 🇪🇺
  final String? countryName; // VD: Hoa Kỳ, Việt Nam

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CurrencyItem &&
          runtimeType == other.runtimeType &&
          code == other.code;

  @override
  int get hashCode => code.hashCode;

  static const List<CurrencyItem> supportedCurrencies = [
    CurrencyItem(
      code: 'VND',
      name: 'Đồng Việt Nam',
      symbol: '₫',
      flagEmoji: '🇻🇳',
      countryName: 'Việt Nam',
    ),
    CurrencyItem(
      code: 'USD',
      name: 'Đô la Mỹ',
      symbol: '\$',
      flagEmoji: '🇺🇸',
      countryName: 'Hoa Kỳ',
    ),
    CurrencyItem(
      code: 'EUR',
      name: 'Euro',
      symbol: '€',
      flagEmoji: '🇪🇺',
      countryName: 'Liên minh Châu Âu',
    ),
    CurrencyItem(
      code: 'JPY',
      name: 'Yên Nhật',
      symbol: '¥',
      flagEmoji: '🇯🇵',
      countryName: 'Nhật Bản',
    ),
    CurrencyItem(
      code: 'GBP',
      name: 'Bảng Anh',
      symbol: '£',
      flagEmoji: '🇬🇧',
      countryName: 'Vương quốc Anh',
    ),
    CurrencyItem(
      code: 'SGD',
      name: 'Đô la Singapore',
      symbol: 'S\$',
      flagEmoji: '🇸🇬',
      countryName: 'Singapore',
    ),
    CurrencyItem(
      code: 'AUD',
      name: 'Đô la Úc',
      symbol: 'A\$',
      flagEmoji: '🇦🇺',
      countryName: 'Úc',
    ),
    CurrencyItem(
      code: 'CAD',
      name: 'Đô la Canada',
      symbol: 'C\$',
      flagEmoji: '🇨🇦',
      countryName: 'Canada',
    ),
    CurrencyItem(
      code: 'KRW',
      name: 'Won Hàn Quốc',
      symbol: '₩',
      flagEmoji: '🇰🇷',
      countryName: 'Hàn Quốc',
    ),
    CurrencyItem(
      code: 'CNY',
      name: 'Nhân dân tệ',
      symbol: '¥',
      flagEmoji: '🇨🇳',
      countryName: 'Trung Quốc',
    ),
    CurrencyItem(
      code: 'THB',
      name: 'Baht Thái',
      symbol: '฿',
      flagEmoji: '🇹🇭',
      countryName: 'Thái Lan',
    ),
  ];

  static CurrencyItem findByCode(String code, {CurrencyItem? fallback}) {
    final upper = code.trim().toUpperCase();
    return supportedCurrencies.firstWhere(
      (c) => c.code == upper,
      orElse: () =>
          fallback ??
          CurrencyItem(
            code: upper,
            name: upper,
            symbol: upper,
            flagEmoji: '🌐',
          ),
    );
  }
}

