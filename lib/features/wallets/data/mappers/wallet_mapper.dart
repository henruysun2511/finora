import '../../domain/enums/wallet_member_role.dart';
import '../../domain/models/wallet_balance_model.dart';
import '../../domain/models/wallet_model.dart';

class WalletMapper {
  WalletMapper._();

  static WalletModel fromJson(Map<String, dynamic> json) {
    return WalletModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      icon: json['icon'] as String?,
      description: json['description'] as String?,
      defaultCurrency: json['defaultCurrency'] as String? ?? 'VND',
      isShared: json['isShared'] as bool? ?? false,
      isActive: json['isActive'] as bool? ?? true,
      ownerId: json['ownerId'] as String? ?? '',
      currentUserRole: WalletMemberRole.fromString(
        json['currentUserRole'] as String?,
      ),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  static WalletBalanceModel balanceFromJson(Map<String, dynamic> json) {
    final rawBreakdown = json['breakdownByCurrency'] as Map<String, dynamic>?;
    final Map<String, double> breakdown = {};
    if (rawBreakdown != null) {
      rawBreakdown.forEach((key, val) {
        breakdown[key] = (val as num?)?.toDouble() ?? 0.0;
      });
    }

    return WalletBalanceModel(
      walletId: json['walletId'] as String? ?? '',
      walletName: json['walletName'] as String? ?? '',
      defaultCurrency: json['defaultCurrency'] as String? ?? 'VND',
      totalBalance: (json['totalBalance'] as num?)?.toDouble() ?? 0.0,
      breakdownByCurrency: breakdown,
      accountsCount: (json['accountsCount'] as num?)?.toInt() ?? 0,
    );
  }
}

