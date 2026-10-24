import '../../domain/models/paged_result.dart';
import '../../domain/models/product.dart';

class ProductListState {
  const ProductListState({
    required this.items,
    required this.page,
    required this.total,
    required this.hasMore,
    this.isLoadingMore = false,
    this.loadMoreError,
  });

  factory ProductListState.fromResult(PagedResult<Product> r) =>
      ProductListState(
        items: r.items,
        page: r.page,
        total: r.total,
        hasMore: r.hasNext,
      );

  final List<Product> items;
  final int page;
  final int total;
  final bool hasMore;
  final bool isLoadingMore;
  final Object? loadMoreError;

  ProductListState copyWith({
    List<Product>? items,
    int? page,
    int? total,
    bool? hasMore,
    bool? isLoadingMore,
    Object? loadMoreError,
    bool clearLoadMoreError = false,
  }) {
    return ProductListState(
      items: items ?? this.items,
      page: page ?? this.page,
      total: total ?? this.total,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      loadMoreError:
          clearLoadMoreError ? null : (loadMoreError ?? this.loadMoreError),
    );
  }
}
