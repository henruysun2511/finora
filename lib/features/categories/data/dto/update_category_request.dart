/// DTO gửi lên Backend NestJS để cập nhật danh mục (PATCH /categories/:id)
class UpdateCategoryRequest {
  const UpdateCategoryRequest({
    this.name,
    this.type,
    this.icon,
    this.color,
    this.parentId,
  });

  final String? name;
  final String? type;
  final String? icon;
  final String? color;
  final String? parentId;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (name != null) map['name'] = name!.trim();
    if (type != null) map['type'] = type!.toUpperCase();
    if (icon != null) map['icon'] = icon;
    if (color != null) map['color'] = color;
    if (parentId != null) map['parentId'] = parentId;
    return map;
  }
}

