class TransferAccount {
  final String id;
  final String name;
  final String currency;

  const TransferAccount({
    required this.id,
    required this.name,
    required this.currency,
  });

  factory TransferAccount.fromJson(Map<String, dynamic> json) {
    return TransferAccount(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      currency: json['currency'] as String? ?? 'VND',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'currency': currency,
      };
}
