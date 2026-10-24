class CreateProductRequest {
  const CreateProductRequest({
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
  final String category;
  final String? imageUrl;
  final bool isAvailable;

  Map<String, dynamic> toJson() => {
        'name': name.trim(),
        'sku': sku.trim().toUpperCase(),
        'description': description.trim(),
        'price': price,
        'stock': stock,
        'category': category.trim(),
        if (imageUrl != null && imageUrl!.trim().isNotEmpty)
          'imageUrl': imageUrl!.trim(),
        'isAvailable': isAvailable,
      };
}
