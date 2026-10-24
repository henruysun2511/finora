import 'product_category.dart';

enum ProductSortField {
  createdAt('createdAt', 'Mới nhất'),
  price('price', 'Giá'),
  name('name', 'Tên');

  const ProductSortField(this.value, this.label);
  final String value;
  final String label;
}

enum SortOrder {
  asc('asc', 'Tăng dần'),
  desc('desc', 'Giảm dần');

  const SortOrder(this.value, this.label);
  final String value;
  final String label;
}

class ProductFilter {
  const ProductFilter({
    this.search,
    this.category,
    this.minPrice,
    this.maxPrice,
    this.inStock,
    this.sortBy = ProductSortField.createdAt,
    this.sortOrder = SortOrder.desc,
  });

  final String? search;
  final ProductCategory? category;
  final double? minPrice;
  final double? maxPrice;

  /// null = tất cả, true = còn hàng, false = hết hàng
  final bool? inStock;
  final ProductSortField sortBy;
  final SortOrder sortOrder;

  bool get hasPriceRange => minPrice != null || maxPrice != null;

  /// Số bộ lọc đang bật (không tính search và sort).
  int get activeCount => [
        category != null,
        hasPriceRange,
        inStock != null,
      ].where((e) => e).length;

  ProductFilter copyWith({
    String? search,
    ProductCategory? category,
    double? minPrice,
    double? maxPrice,
    bool? inStock,
    ProductSortField? sortBy,
    SortOrder? sortOrder,
    bool clearSearch = false,
    bool clearCategory = false,
    bool clearMinPrice = false,
    bool clearMaxPrice = false,
    bool clearInStock = false,
  }) {
    return ProductFilter(
      search: clearSearch ? null : (search ?? this.search),
      category: clearCategory ? null : (category ?? this.category),
      minPrice: clearMinPrice ? null : (minPrice ?? this.minPrice),
      maxPrice: clearMaxPrice ? null : (maxPrice ?? this.maxPrice),
      inStock: clearInStock ? null : (inStock ?? this.inStock),
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is ProductFilter &&
      other.search == search &&
      other.category == category &&
      other.minPrice == minPrice &&
      other.maxPrice == maxPrice &&
      other.inStock == inStock &&
      other.sortBy == sortBy &&
      other.sortOrder == sortOrder;

  @override
  int get hashCode => Object.hash(
        search,
        category,
        minPrice,
        maxPrice,
        inStock,
        sortBy,
        sortOrder,
      );
}
