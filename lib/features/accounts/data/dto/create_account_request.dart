import '../../domain/enums/account_type.dart';

class CreateAccountRequest {
  final String walletId;
  final String name;
  final AccountType type;
  final String? currency;
  final double initialBalance;
  final String? accountNumberLast4;
  final String? icon;
  final String? color;

  const CreateAccountRequest({
    required this.walletId,
    required this.name,
    required this.type,
    this.currency,
    this.initialBalance = 0.0,
    this.accountNumberLast4,
    this.icon,
    this.color,
  });

  Map<String, dynamic> toJson() {
    return {
      'walletId': walletId,
      'name': name.trim(),
      'type': type.toServerString(),
      if (currency != null && currency!.isNotEmpty)
        'currency': currency!.trim().toUpperCase(),
      'initialBalance': initialBalance,
      if (accountNumberLast4 != null && accountNumberLast4!.isNotEmpty)
        'accountNumberLast4': accountNumberLast4!.trim(),
      if (icon != null && icon!.isNotEmpty) 'icon': icon,
      if (color != null && color!.isNotEmpty) 'color': color,
    };
  }
}

