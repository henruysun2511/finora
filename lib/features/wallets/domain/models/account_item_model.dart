import 'package:flutter/material.dart';

class AccountItemModel {
  const AccountItemModel({
    required this.id,
    required this.name,
    this.walletId,
    this.walletName,
    this.type = 'bank',
    this.balance = 0.0,
    this.currency = 'VND',
    this.accountNumberLast4,
    this.icon,
    this.color,
  });

  final String id;
  final String name;
  final String? walletId;
  final String? walletName;
  final String type; // cash, bank, ewallet, credit
  final double balance;
  final String currency;
  final String? accountNumberLast4;
  final String? icon;
  final String? color;

  factory AccountItemModel.fromJson(Map<String, dynamic> json) {
    return AccountItemModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      walletId: json['walletId']?.toString(),
      type: json['type']?.toString().toLowerCase() ?? 'bank',
      balance: (json['balance'] is num)
          ? (json['balance'] as num).toDouble()
          : (double.tryParse(json['balance']?.toString() ?? '0') ?? 0.0),
      currency: json['currency']?.toString() ?? 'VND',
      accountNumberLast4: json['accountNumberLast4']?.toString(),
      icon: json['icon']?.toString(),
      color: json['color']?.toString(),
    );
  }

  IconData get defaultIcon {
    switch (type) {
      case 'cash':
        return Icons.payments_rounded;
      case 'bank':
        return Icons.account_balance_rounded;
      case 'ewallet':
        return Icons.account_balance_wallet_rounded;
      case 'credit':
        return Icons.credit_card_rounded;
      default:
        return Icons.account_balance_wallet_rounded;
    }
  }

  String get typeLabel {
    switch (type) {
      case 'cash':
        return 'Tiền mặt';
      case 'bank':
        return 'Ngân hàng';
      case 'ewallet':
        return 'Ví điện tử';
      case 'credit':
        return 'Thẻ tín dụng';
      default:
        return 'Tài khoản';
    }
  }
}

