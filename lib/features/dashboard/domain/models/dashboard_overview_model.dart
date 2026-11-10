class AssetTierModel {
  final String tier;
  final String title;
  final String mascotMood;
  final double nextTierThreshold;

  const AssetTierModel({
    required this.tier,
    required this.title,
    required this.mascotMood,
    required this.nextTierThreshold,
  });

  factory AssetTierModel.fromJson(Map<String, dynamic> json) {
    return AssetTierModel(
      tier: json['tier']?.toString() ?? 'GOLD',
      title: json['title']?.toString() ?? 'Nhà Tích Lũy Vàng',
      mascotMood: json['mascotMood']?.toString() ?? 'HAPPY',
      nextTierThreshold: (json['nextTierThreshold'] as num?)?.toDouble() ?? 200000000.0,
    );
  }
}

class MonthlyCashflowModel {
  final String month;
  final double income;
  final double expense;
  final double netCashflow;
  final double savingsRate;
  final double momIncomeChange;
  final double momExpenseChange;

  const MonthlyCashflowModel({
    required this.month,
    required this.income,
    required this.expense,
    required this.netCashflow,
    required this.savingsRate,
    required this.momIncomeChange,
    required this.momExpenseChange,
  });

  factory MonthlyCashflowModel.fromJson(Map<String, dynamic> json) {
    return MonthlyCashflowModel(
      month: json['month']?.toString() ?? '',
      income: (json['income'] as num?)?.toDouble() ?? 0.0,
      expense: (json['expense'] as num?)?.toDouble() ?? 0.0,
      netCashflow: (json['netCashflow'] as num?)?.toDouble() ?? 0.0,
      savingsRate: (json['savingsRate'] as num?)?.toDouble() ?? 0.0,
      momIncomeChange: (json['momIncomeChange'] as num?)?.toDouble() ?? 0.0,
      momExpenseChange: (json['momExpenseChange'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class DashboardAccountSummaryModel {
  final String id;
  final String name;
  final String type;
  final double balance;
  final bool isExcludedFromNetWorth;

  const DashboardAccountSummaryModel({
    required this.id,
    required this.name,
    required this.type,
    required this.balance,
    required this.isExcludedFromNetWorth,
  });

  factory DashboardAccountSummaryModel.fromJson(Map<String, dynamic> json) {
    return DashboardAccountSummaryModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      type: json['type']?.toString() ?? 'CASH',
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      isExcludedFromNetWorth: json['isExcludedFromNetWorth'] == true,
    );
  }
}

class DashboardAlertModel {
  final String type;
  final String severity;
  final String message;
  final String? relatedEntityId;

  const DashboardAlertModel({
    required this.type,
    required this.severity,
    required this.message,
    this.relatedEntityId,
  });

  factory DashboardAlertModel.fromJson(Map<String, dynamic> json) {
    return DashboardAlertModel(
      type: json['type']?.toString() ?? 'GENERAL',
      severity: json['severity']?.toString() ?? 'MEDIUM',
      message: json['message']?.toString() ?? '',
      relatedEntityId: json['relatedEntityId']?.toString(),
    );
  }
}

class DashboardRecentTransactionModel {
  final String id;
  final String name;
  final double amount;
  final String type; // EXPENSE | INCOME | TRANSFER
  final String categoryName;
  final String? categoryIcon;
  final DateTime transactionDate;

  const DashboardRecentTransactionModel({
    required this.id,
    required this.name,
    required this.amount,
    required this.type,
    required this.categoryName,
    this.categoryIcon,
    required this.transactionDate,
  });

  factory DashboardRecentTransactionModel.fromJson(Map<String, dynamic> json) {
    return DashboardRecentTransactionModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      type: json['type']?.toString() ?? 'EXPENSE',
      categoryName: json['categoryName']?.toString() ?? 'Chi tiêu',
      categoryIcon: json['categoryIcon']?.toString(),
      transactionDate: json['transactionDate'] != null
          ? DateTime.tryParse(json['transactionDate'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

class DashboardOverviewModel {
  final double netWorth;
  final String currency;
  final AssetTierModel assetTier;
  final MonthlyCashflowModel monthlyCashflow;
  final List<DashboardAccountSummaryModel> accountsSummary;
  final List<DashboardAlertModel> activeAlerts;
  final List<DashboardRecentTransactionModel> recentTransactions;

  const DashboardOverviewModel({
    required this.netWorth,
    required this.currency,
    required this.assetTier,
    required this.monthlyCashflow,
    required this.accountsSummary,
    required this.activeAlerts,
    required this.recentTransactions,
  });

  factory DashboardOverviewModel.fromJson(Map<String, dynamic> json) {
    return DashboardOverviewModel(
      netWorth: (json['netWorth'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency']?.toString() ?? 'VND',
      assetTier: json['assetTier'] is Map<String, dynamic>
          ? AssetTierModel.fromJson(json['assetTier'] as Map<String, dynamic>)
          : const AssetTierModel(
              tier: 'GOLD',
              title: 'Gold Tier',
              mascotMood: 'HAPPY',
              nextTierThreshold: 200000000,
            ),
      monthlyCashflow: json['monthlyCashflow'] is Map<String, dynamic>
          ? MonthlyCashflowModel.fromJson(json['monthlyCashflow'] as Map<String, dynamic>)
          : const MonthlyCashflowModel(
              month: '',
              income: 0,
              expense: 0,
              netCashflow: 0,
              savingsRate: 0,
              momIncomeChange: 0,
              momExpenseChange: 0,
            ),
      accountsSummary: (json['accountsSummary'] as List<dynamic>?)
              ?.whereType<Map<String, dynamic>>()
              .map(DashboardAccountSummaryModel.fromJson)
              .toList() ??
          const [],
      activeAlerts: (json['activeAlerts'] as List<dynamic>?)
              ?.whereType<Map<String, dynamic>>()
              .map(DashboardAlertModel.fromJson)
              .toList() ??
          const [],
      recentTransactions: (json['recentTransactions'] as List<dynamic>?)
              ?.whereType<Map<String, dynamic>>()
              .map(DashboardRecentTransactionModel.fromJson)
              .toList() ??
          const [],
    );
  }
}
