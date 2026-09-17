import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

class BalanceSummary {
  final double totalBalance;
  final double monthlyIncome;
  final double monthlyExpense;

  const BalanceSummary({
    required this.totalBalance,
    required this.monthlyIncome,
    required this.monthlyExpense,
  });

  static const sample = BalanceSummary(
    totalBalance: 24850000,
    monthlyIncome: 15000000,
    monthlyExpense: 8320000,
  );
}

class AccountItem {
  final String id;
  final String name;
  final double balance;
  final String typeName;
  final Color badgeColor;
  final IconData icon;
  final bool isSelected;

  const AccountItem({
    required this.id,
    required this.name,
    required this.balance,
    required this.typeName,
    required this.badgeColor,
    required this.icon,
    this.isSelected = false,
  });

  static const List<AccountItem> sampleAccounts = [
    AccountItem(
      id: 'acc_cash',
      name: 'Tiền mặt',
      balance: 2500000,
      typeName: 'Ví tiền mặt',
      badgeColor: AppColors.success,
      icon: Icons.account_balance_wallet_rounded,
      isSelected: false,
    ),
    AccountItem(
      id: 'acc_vcb',
      name: 'Vietcombank',
      balance: 18350000,
      typeName: 'Tài khoản NH',
      badgeColor: AppColors.primary,
      icon: Icons.account_balance_rounded,
      isSelected: true,
    ),
    AccountItem(
      id: 'acc_momo',
      name: 'MoMo',
      balance: 4000000,
      typeName: 'Ví điện tử',
      badgeColor: AppColors.secondary,
      icon: Icons.phone_android_rounded,
      isSelected: false,
    ),
  ];
}

enum QuickActionType {
  incomeExpense,
  transfer,
  report,
  budget,
}

class QuickActionItem {
  final QuickActionType type;
  final String label;
  final IconData icon;
  final Color color;

  const QuickActionItem({
    required this.type,
    required this.label,
    required this.icon,
    required this.color,
  });

  static const List<QuickActionItem> sampleActions = [
    QuickActionItem(
      type: QuickActionType.incomeExpense,
      label: 'Thu/Chi',
      icon: Icons.add_rounded,
      color: AppColors.primary,
    ),
    QuickActionItem(
      type: QuickActionType.transfer,
      label: 'Chuyển',
      icon: Icons.sync_alt_rounded,
      color: AppColors.teal,
    ),
    QuickActionItem(
      type: QuickActionType.report,
      label: 'Báo cáo',
      icon: Icons.pie_chart_rounded,
      color: AppColors.orange,
    ),
    QuickActionItem(
      type: QuickActionType.budget,
      label: 'Ngân sách',
      icon: Icons.track_changes_rounded,
      color: AppColors.violet,
    ),
  ];
}

class TransactionItem {
  final String id;
  final String title;
  final String category;
  final String dateText;
  final double amount;
  final IconData icon;

  const TransactionItem({
    required this.id,
    required this.title,
    required this.category,
    required this.dateText,
    required this.amount,
    required this.icon,
  });

  bool get isIncome => amount > 0;

  static const List<TransactionItem> sampleTransactions = [
    TransactionItem(
      id: 'tx_1',
      title: 'Ăn trưa văn phòng',
      category: 'Ăn uống',
      dateText: 'Hôm nay 12:30',
      amount: -55000,
      icon: Icons.restaurant_rounded,
    ),
    TransactionItem(
      id: 'tx_2',
      title: 'Lương tháng 8',
      category: 'Thu nhập',
      dateText: 'Hôm qua',
      amount: 15000000,
      icon: Icons.payments_rounded,
    ),
    TransactionItem(
      id: 'tx_3',
      title: 'Siêu thị VinMart',
      category: 'Mua sắm',
      dateText: '08/08',
      amount: -420000,
      icon: Icons.shopping_bag_rounded,
    ),
    TransactionItem(
      id: 'tx_4',
      title: 'Cước Internet',
      category: 'Hóa đơn',
      dateText: '07/08',
      amount: -230000,
      icon: Icons.wifi_rounded,
    ),
  ];
}
