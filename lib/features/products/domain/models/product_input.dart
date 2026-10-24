import 'product_category.dart';

/// Dữ liệu người dùng nhập khi tạo / sửa sản phẩm.
class ProductInput {
  const ProductInput({
    required this.name,
    required this.sku,
    required this.description,
    required this.price,
    required this.stock,
    required this.category,
    required this.isAvailable,
    this.imageUrl,
  });

  final String name;
  final String sku;
  final String description;
  final double price;
  final int stock;
  final ProductCategory category;
  final String? imageUrl;
  final bool isAvailable;

  bool get isActive => isAvailable;
}
