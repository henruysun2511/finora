import 'package:flutter/material.dart';

enum AccountType {
  cash,
  bank,
  ewallet,
  credit;

  static AccountType fromString(String? type) {
    switch (type?.toLowerCase()) {
      case 'bank':
        return AccountType.bank;
      case 'ewallet':
        return AccountType.ewallet;
      case 'credit':
        return AccountType.credit;
      case 'cash':
      default:
        return AccountType.cash;
    }
  }

  String toServerString() {
    switch (this) {
      case AccountType.cash:
        return 'cash';
      case AccountType.bank:
        return 'bank';
      case AccountType.ewallet:
        return 'ewallet';
      case AccountType.credit:
        return 'credit';
    }
  }

  String get displayName {
    switch (this) {
      case AccountType.cash:
        return 'Tiền mặt';
      case AccountType.bank:
        return 'Tài khoản Ngân hàng';
      case AccountType.ewallet:
        return 'Ví điện tử';
      case AccountType.credit:
        return 'Thẻ tín dụng';
    }
  }

  String get shortName {
    switch (this) {
      case AccountType.cash:
        return 'Tiền mặt';
      case AccountType.bank:
        return 'Ngân hàng';
      case AccountType.ewallet:
        return 'Ví ĐT';
      case AccountType.credit:
        return 'Tín dụng';
    }
  }

  Color get defaultColor {
    switch (this) {
      case AccountType.cash:
        return const Color(0xFF10B981); // Emerald Green
      case AccountType.bank:
        return const Color(0xFF0072D5); // Finora Blue
      case AccountType.ewallet:
        return const Color(0xFFA50064); // MoMo Magenta
      case AccountType.credit:
        return const Color(0xFFF59E0B); // Amber Orange
    }
  }

  IconData get defaultIcon {
    switch (this) {
      case AccountType.cash:
        return Icons.payments_rounded;
      case AccountType.bank:
        return Icons.account_balance_rounded;
      case AccountType.ewallet:
        return Icons.account_balance_wallet_rounded;
      case AccountType.credit:
        return Icons.credit_card_rounded;
    }
  }

  bool get isCredit => this == AccountType.credit;
}

