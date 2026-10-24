import 'product_category.dart';

/// Entity thuần Domain cho Sản phẩm theo chuẩn Clean Architecture.
/// Tầng domain hoàn toàn độc lập, không phụ thuộc vào Flutter hay Dio.
class Product {
  const Product({
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
  final ProductCategory category;
  final String? imageUrl;
  final bool isAvailable;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get inStock => stock > 0;
  bool get isLowStock => stock > 0 && stock <= 5;
  bool get isActive => isAvailable;

  Product copyWith({
    String? id,
    String? name,
    String? sku,
    String? description,
    double? price,
    int? stock,
    ProductCategory? category,
    String? imageUrl,
    bool? isAvailable,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      sku: sku ?? this.sku,
      description: description ?? this.description,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      isAvailable: isAvailable ?? this.isAvailable,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
