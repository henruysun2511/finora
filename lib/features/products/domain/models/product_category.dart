enum ProductCategory {
  electronics('electronics', 'Điện tử'),
  fashion('fashion', 'Thời trang'),
  home('home', 'Nhà cửa'),
  books('books', 'Sách'),
  sports('sports', 'Thể thao'),
  other('other', 'Khác');

  const ProductCategory(this.value, this.label);

  final String value;
  final String label;

  static ProductCategory fromValue(String? value) =>
      ProductCategory.values.firstWhere(
        (c) => c.value == value,
        orElse: () => ProductCategory.other,
      );
}
