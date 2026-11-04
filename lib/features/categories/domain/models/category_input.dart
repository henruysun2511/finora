import 'category_type.dart';

/// Dữ liệu đầu vào để tạo hoặc sửa danh mục
class CategoryInput {
  const CategoryInput({
    required this.name,
    required this.type,
    this.icon = '🏷️',
    this.color = '#1E5BD8',
    this.parentId,
  });

  final String name;
  final CategoryType type;
  final String icon;
  final String color;
  final String? parentId;

  CategoryInput copyWith({
    String? name,
    CategoryType? type,
    String? icon,
    String? color,
    String? parentId,
  }) {
    return CategoryInput(
      name: name ?? this.name,
      type: type ?? this.type,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      parentId: parentId ?? this.parentId,
    );
  }
}

