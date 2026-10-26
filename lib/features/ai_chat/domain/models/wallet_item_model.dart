class WalletItemModel {
  final String id;
  final String name;
  final String defaultCurrency;
  final bool isShared;
  final String? icon;

  const WalletItemModel({
    required this.id,
    required this.name,
    this.defaultCurrency = 'VND',
    this.isShared = false,
    this.icon,
  });

  factory WalletItemModel.fromJson(Map<String, dynamic> json) {
    return WalletItemModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Ví tiền',
      defaultCurrency: json['defaultCurrency'] as String? ?? 'VND',
      isShared: json['isShared'] as bool? ?? false,
      icon: json['icon'] as String?,
    );
  }
}
