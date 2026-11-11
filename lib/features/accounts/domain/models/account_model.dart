import 'package:flutter/material.dart';

import '../enums/account_type.dart';

class AccountModel {
  final String id;
  final String walletId;
  final String name;
  final AccountType type;
  final String currency;
  final double balance;
  final double initialBalance;
  final bool isArchived;
  final String? accountNumberLast4;
  final String? icon;
  final String? color;
  final DateTime? archivedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AccountModel({
    required this.id,
    required this.walletId,
    required this.name,
    required this.type,
    required this.currency,
    required this.balance,
    this.initialBalance = 0.0,
    required this.isArchived,
    this.accountNumberLast4,
    this.icon,
    this.color,
    this.archivedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  Color get displayColor {
    if (color != null && color!.isNotEmpty) {
      try {
        final hexStr = color!.replaceAll('#', '');
        return Color(int.parse('0xFF$hexStr'));
      } catch (_) {}
    }
    return type.defaultColor;
  }

  IconData get displayIcon => type.defaultIcon;

  String get maskedNumber {
    if (accountNumberLast4 != null && accountNumberLast4!.isNotEmpty) {
      return '•••• $accountNumberLast4';
    }
    return '';
  }

  AccountModel copyWith({
    String? id,
    String? walletId,
    String? name,
    AccountType? type,
    String? currency,
    double? balance,
    double? initialBalance,
    bool? isArchived,
    String? accountNumberLast4,
    String? icon,
    String? color,
    DateTime? archivedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AccountModel(
      id: id ?? this.id,
      walletId: walletId ?? this.walletId,
      name: name ?? this.name,
      type: type ?? this.type,
      currency: currency ?? this.currency,
      balance: balance ?? this.balance,
      initialBalance: initialBalance ?? this.initialBalance,
      isArchived: isArchived ?? this.isArchived,
      accountNumberLast4: accountNumberLast4 ?? this.accountNumberLast4,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      archivedAt: archivedAt ?? this.archivedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

