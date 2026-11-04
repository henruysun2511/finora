import 'category_type.dart';

/// Entity thuần Domain cho Danh mục tài chính (Category).
class Category {
  const Category({
    required this.id,
    required this.name,
    required this.type,
    this.icon = '🏷️',
    this.color = '#1E5BD8',
    this.isDefault = false,
    this.parentId,
    this.children = const [],
    this.transactionCount = 0,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final CategoryType type;
  final String icon;
  final String color;
  final bool isDefault;
  final String? parentId;
  final List<Category> children;
  final int transactionCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get isExpense => type == CategoryType.expense;
  bool get isIncome => type == CategoryType.income;

  Category copyWith({
    String? id,
    String? name,
    CategoryType? type,
    String? icon,
    String? color,
    bool? isDefault,
    String? parentId,
    List<Category>? children,
    int? transactionCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      isDefault: isDefault ?? this.isDefault,
      parentId: parentId ?? this.parentId,
      children: children ?? this.children,
      transactionCount: transactionCount ?? this.transactionCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

