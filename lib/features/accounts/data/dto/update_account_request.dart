import '../../domain/enums/account_type.dart';

class UpdateAccountRequest {
  final String? name;
  final AccountType? type;
  final String? icon;
  final String? color;
  final String? accountNumberLast4;

  const UpdateAccountRequest({
    this.name,
    this.type,
    this.icon,
    this.color,
    this.accountNumberLast4,
  });

  Map<String, dynamic> toJson() {
    return {
      if (name != null) 'name': name!.trim(),
      if (type != null) 'type': type!.toServerString(),
      if (icon != null) 'icon': icon,
      if (color != null) 'color': color,
      if (accountNumberLast4 != null)
        'accountNumberLast4': accountNumberLast4!.trim(),
    };
  }
}

