import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/product_category.dart';
import '../../domain/models/product_filter.dart';

/// Giữ bộ lọc hiện tại. product_list_provider watch provider này nên mỗi khi
/// filter đổi, danh sách tự động tải lại từ trang 1.
class ProductFilterNotifier extends Notifier<ProductFilter> {
  @override
  ProductFilter build() => const ProductFilter();

  void setSearch(String text) {
    final t = text.trim();
    if (t == (state.search ?? '')) return;
    state = state.copyWith(search: t, clearSearch: t.isEmpty);
  }

  void apply(ProductFilter filter) => state = filter;

  void clearCategory() => state = state.copyWith(clearCategory: true);

  void clearPrice() =>
      state = state.copyWith(clearMinPrice: true, clearMaxPrice: true);

  void clearInStock() => state = state.copyWith(clearInStock: true);

  void setCategory(ProductCategory? c) => state = c == null
      ? state.copyWith(clearCategory: true)
      : state.copyWith(category: c);

  /// Xóa bộ lọc nhưng giữ lại từ khóa tìm kiếm và kiểu sắp xếp.
  void reset() => state = ProductFilter(
        search: state.search,
        sortBy: state.sortBy,
        sortOrder: state.sortOrder,
      );
}

final productFilterProvider =
    NotifierProvider<ProductFilterNotifier, ProductFilter>(
  ProductFilterNotifier.new,
);
