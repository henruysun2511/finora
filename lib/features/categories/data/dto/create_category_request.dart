/// DTO gửi lên Backend NestJS để tạo danh mục (POST /categories)
class CreateCategoryRequest {
  const CreateCategoryRequest({
    required this.name,
    required this.type,
    this.icon,
    this.color,
    this.parentId,
  });

  final String name;
  final String type; // EXPENSE | INCOME
  final String? icon;
  final String? color;
  final String? parentId;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'name': name.trim(),
      'type': type.toUpperCase(),
    };
    if (icon != null && icon!.isNotEmpty) map['icon'] = icon;
    if (color != null && color!.isNotEmpty) map['color'] = color;
    if (parentId != null && parentId!.isNotEmpty) map['parentId'] = parentId;
    return map;
  }
}

