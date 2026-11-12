import 'package:flutter/material.dart';

enum AccountType {
  cash,
  bank,
  ewallet,
  credit;

  static const AccountType eWallet = AccountType.ewallet;
  static const AccountType savings = AccountType.bank;

  static AccountType fromString(String? type) {
    switch (type?.toLowerCase()) {
      case 'bank':
      case 'bank_account':
        return AccountType.bank;
      case 'ewallet':
      case 'e_wallet':
        return AccountType.ewallet;
      case 'credit':
      case 'credit_card':
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

  String get label => displayName;

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

  bool get isCash => this == AccountType.cash;
  bool get isBank => this == AccountType.bank;
  bool get isEWallet => this == AccountType.ewallet;
  bool get isCredit => this == AccountType.credit;
}
