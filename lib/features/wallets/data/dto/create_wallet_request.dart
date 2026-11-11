class CreateWalletRequest {
  final String name;
  final String? icon;
  final String? description;
  final String defaultCurrency;
  final bool isShared;

  const CreateWalletRequest({
    required this.name,
    this.icon,
    this.description,
    this.defaultCurrency = 'VND',
    this.isShared = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name.trim(),
      if (icon != null && icon!.isNotEmpty) 'icon': icon,
      if (description != null && description!.isNotEmpty)
        'description': description!.trim(),
      'defaultCurrency': defaultCurrency.trim().toUpperCase(),
      'isShared': isShared,
    };
  }
}

