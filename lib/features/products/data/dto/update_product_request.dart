/// PATCH /products/:id - chỉ gửi những field khác null.
class UpdateProductRequest {
  const UpdateProductRequest({
    this.name,
    this.sku,
    this.description,
    this.price,
    this.stock,
    this.category,
    this.imageUrl,
    this.isAvailable,
  });

  final String? name;
  final String? sku;
  final String? description;
  final double? price;
  final int? stock;
  final String? category;

  /// Chuỗi rỗng = xóa ảnh.
  final String? imageUrl;
  final bool? isAvailable;

  Map<String, dynamic> toJson() => {
        if (name != null) 'name': name,
        if (sku != null) 'sku': sku!.toUpperCase(),
        if (description != null) 'description': description,
        if (price != null) 'price': price,
        if (stock != null) 'stock': stock,
        if (category != null) 'category': category,
        if (imageUrl != null) 'imageUrl': imageUrl,
        if (isAvailable != null) 'isAvailable': isAvailable,
      };
}
