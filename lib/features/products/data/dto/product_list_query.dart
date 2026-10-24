/// Query string cho GET /products đồng bộ với ProductQueryDto của finora_be
class ProductListQuery {
  const ProductListQuery({
    required this.page,
    required this.limit,
    required this.sortBy,
    required this.sortOrder,
    this.search,
    this.category,
    this.minPrice,
    this.maxPrice,
    this.isAvailable,
  });

  final int page;
  final int limit;
  final String? search;
  final String? category;
  final double? minPrice;
  final double? maxPrice;
  final bool? isAvailable;
  final String sortBy;
  final String sortOrder;

  Map<String, dynamic> toQueryParameters() => {
        'page': page,
        'limit': limit,
        // finora_be nhận parameter 'keyword' cho tìm kiếm từ khóa
        if (search != null && search!.trim().isNotEmpty)
          'keyword': search!.trim(),
        if (category != null && category!.trim().isNotEmpty)
          'category': category!.trim(),
        if (minPrice != null) 'minPrice': minPrice,
        if (maxPrice != null) 'maxPrice': maxPrice,
        // finora_be nhận parameter 'isAvailable'
        if (isAvailable != null) 'isAvailable': isAvailable,
        'sortBy': sortBy,
        // finora_be SortOrder là Enum 'ASC' | 'DESC'
        'sortOrder': sortOrder.toUpperCase(),
      };
}
