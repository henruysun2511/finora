import '../../domain/enums/account_type.dart';
import '../../domain/models/account_model.dart';

class AccountMapper {
  AccountMapper._();

  static AccountModel fromJson(Map<String, dynamic> json) {
    return AccountModel(
      id: json['id'] as String? ?? '',
      walletId: json['walletId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      type: AccountType.fromString(json['type'] as String?),
      currency: json['currency'] as String? ?? 'VND',
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      initialBalance: (json['initialBalance'] as num?)?.toDouble() ?? 0.0,
      isArchived: json['isArchived'] as bool? ?? false,
      accountNumberLast4: json['accountNumberLast4'] as String?,
      icon: json['icon'] as String?,
      color: json['color'] as String?,
      archivedAt: json['archivedAt'] != null
          ? DateTime.tryParse(json['archivedAt'].toString())
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

