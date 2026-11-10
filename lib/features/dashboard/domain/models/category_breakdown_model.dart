class SubCategoryBreakdownItemModel {
  final String id;
  final String name;
  final double amount;
  final double percentage;

  const SubCategoryBreakdownItemModel({
    required this.id,
    required this.name,
    required this.amount,
    required this.percentage,
  });

  factory SubCategoryBreakdownItemModel.fromJson(Map<String, dynamic> json) {
    return SubCategoryBreakdownItemModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class CategoryBreakdownItemModel {
  final String id;
  final String name;
  final String icon;
  final String color;
  final double amount;
  final double percentage;
  final List<SubCategoryBreakdownItemModel> subCategories;

  const CategoryBreakdownItemModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.amount,
    required this.percentage,
    required this.subCategories,
  });

  factory CategoryBreakdownItemModel.fromJson(Map<String, dynamic> json) {
    return CategoryBreakdownItemModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      icon: json['icon']?.toString() ?? '🏷️',
      color: json['color']?.toString() ?? '#3B82F6',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
      subCategories: (json['subCategories'] as List<dynamic>?)
              ?.whereType<Map<String, dynamic>>()
              .map(SubCategoryBreakdownItemModel.fromJson)
              .toList() ??
          const [],
    );
  }
}

class TopSpendingItemModel {
  final String name;
  final double amount;
  final String categoryName;
  final String date;

  const TopSpendingItemModel({
    required this.name,
    required this.amount,
    required this.categoryName,
    required this.date,
  });

  factory TopSpendingItemModel.fromJson(Map<String, dynamic> json) {
    return TopSpendingItemModel(
      name: json['name']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      categoryName: json['categoryName']?.toString() ?? 'Chi tiêu',
      date: json['date']?.toString() ?? '',
    );
  }
}

class Rule503020MetricModel {
  final double amount;
  final double percentage;
  final double targetPercentage;
  final String status; // OPTIMAL, SLIGHT_OVER, NEEDS_IMPROVEMENT

  const Rule503020MetricModel({
    required this.amount,
    required this.percentage,
    required this.targetPercentage,
    required this.status,
  });

  factory Rule503020MetricModel.fromJson(Map<String, dynamic> json) {
    return Rule503020MetricModel(
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
      targetPercentage: (json['targetPercentage'] as num?)?.toDouble() ?? 0.0,
      status: json['status']?.toString() ?? 'OPTIMAL',
    );
  }
}

class Rule503020EvaluationModel {
  final Rule503020MetricModel needs;
  final Rule503020MetricModel wants;
  final Rule503020MetricModel savings;

  const Rule503020EvaluationModel({
    required this.needs,
    required this.wants,
    required this.savings,
  });

  factory Rule503020EvaluationModel.fromJson(Map<String, dynamic> json) {
    return Rule503020EvaluationModel(
      needs: json['needs'] is Map<String, dynamic>
          ? Rule503020MetricModel.fromJson(json['needs'] as Map<String, dynamic>)
          : const Rule503020MetricModel(amount: 0, percentage: 0, targetPercentage: 50, status: 'OPTIMAL'),
      wants: json['wants'] is Map<String, dynamic>
          ? Rule503020MetricModel.fromJson(json['wants'] as Map<String, dynamic>)
          : const Rule503020MetricModel(amount: 0, percentage: 0, targetPercentage: 30, status: 'OPTIMAL'),
      savings: json['savings'] is Map<String, dynamic>
          ? Rule503020MetricModel.fromJson(json['savings'] as Map<String, dynamic>)
          : const Rule503020MetricModel(amount: 0, percentage: 0, targetPercentage: 20, status: 'OPTIMAL'),
    );
  }
}

class CategoryBreakdownModel {
  final String month;
  final String type;
  final double totalAmount;
  final String currency;
  final Rule503020EvaluationModel? rule503020Evaluation;
  final List<CategoryBreakdownItemModel> categories;
  final List<TopSpendingItemModel> topSpendingItems;

  const CategoryBreakdownModel({
    required this.month,
    required this.type,
    required this.totalAmount,
    required this.currency,
    this.rule503020Evaluation,
    required this.categories,
    required this.topSpendingItems,
  });

  factory CategoryBreakdownModel.fromJson(Map<String, dynamic> json) {
    return CategoryBreakdownModel(
      month: json['month']?.toString() ?? '',
      type: json['type']?.toString() ?? 'EXPENSE',
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency']?.toString() ?? 'VND',
      rule503020Evaluation: json['rule503020Evaluation'] is Map<String, dynamic>
          ? Rule503020EvaluationModel.fromJson(json['rule503020Evaluation'] as Map<String, dynamic>)
          : null,
      categories: (json['categories'] as List<dynamic>?)
              ?.whereType<Map<String, dynamic>>()
              .map(CategoryBreakdownItemModel.fromJson)
              .toList() ??
          const [],
      topSpendingItems: (json['topSpendingItems'] as List<dynamic>?)
              ?.whereType<Map<String, dynamic>>()
              .map(TopSpendingItemModel.fromJson)
              .toList() ??
          const [],
    );
  }
}
