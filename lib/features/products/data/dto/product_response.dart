class ProductResponse {
  const ProductResponse({
    required this.id,
    required this.name,
    required this.sku,
    required this.description,
    required this.price,
    required this.stock,
    required this.category,
    required this.isAvailable,
    required this.createdAt,
    required this.updatedAt,
    this.imageUrl,
  });

  final String id;
  final String name;
  final String sku;
  final String description;
  final double price;
  final int stock;
  final String category;
  final String? imageUrl;
  final bool isAvailable;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isActive => isAvailable;

  factory ProductResponse.fromJson(Map<String, dynamic> json) {
    final image = json['imageUrl'] as String?;
    return ProductResponse(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      sku: json['sku'] as String? ?? '',
      description: (json['description'] as String?) ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      category: (json['category'] as String?) ?? 'other',
      imageUrl: (image == null || image.isEmpty) ? null : image,
      isAvailable: (json['isAvailable'] as bool?) ??
          (json['isActive'] as bool?) ??
          true,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'sku': sku,
        'description': description,
        'price': price,
        'stock': stock,
        'category': category,
        if (imageUrl != null) 'imageUrl': imageUrl,
        'isAvailable': isAvailable,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };
}
