/// DTO ánh xạ dữ liệu danh mục trả về từ NestJS Backend API
class CategoryResponse {
  const CategoryResponse({
    required this.id,
    required this.name,
    required this.type,
    this.icon = 'tag',
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
  final String type; // EXPENSE | INCOME
  final String icon;
  final String color;
  final bool isDefault;
  final String? parentId;
  final List<CategoryResponse> children;
  final int transactionCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory CategoryResponse.fromJson(Map<String, dynamic> json) {
    List<CategoryResponse> childList = const [];
    if (json['children'] is List) {
      childList = (json['children'] as List)
          .map((e) => CategoryResponse.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return CategoryResponse(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      type: json['type']?.toString().toUpperCase() ?? 'EXPENSE',
      icon: json['icon']?.toString() ?? 'tag',
      color: json['color']?.toString() ?? '#1E5BD8',
      isDefault: json['isDefault'] as bool? ?? false,
      parentId: json['parentId']?.toString(),
      children: childList,
      transactionCount: (json['transactionCount'] as num?)?.toInt() ??
          (json['count'] as num?)?.toInt() ??
          0,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type,
        'icon': icon,
        'color': color,
        'isDefault': isDefault,
        if (parentId != null) 'parentId': parentId,
      };
}

