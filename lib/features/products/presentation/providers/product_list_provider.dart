import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'product_filter_provider.dart';
import 'product_list_state.dart';
import 'product_providers.dart';

const kProductPageSize = 10;

class ProductListNotifier extends AsyncNotifier<ProductListState> {
  /// Chạy lại (về trang 1) mỗi khi productFilterProvider thay đổi.
  @override
  Future<ProductListState> build() async {
    final filter = ref.watch(productFilterProvider);
    final repo = ref.watch(productRepositoryProvider);
    final result = await repo.getProducts(
      page: 1,
      limit: kProductPageSize,
      filter: filter,
    );
    return ProductListState.fromResult(result);
  }

  /// Pull-to-refresh: tải lại từ trang 1, giữ danh sách cũ trong lúc chờ.
  Future<void> refresh() async {
    ref.invalidateSelf();
    try {
      await future;
    } catch (_) {
      // Lỗi đã nằm trong state, UI tự hiển thị.
    }
  }

  /// Tải trang kế tiếp (infinite scroll).
  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasMore || current.isLoadingMore) return;

    final filter = ref.read(productFilterProvider);
    state = AsyncData(
      current.copyWith(isLoadingMore: true, clearLoadMoreError: true),
    );

    try {
      final result = await ref.read(productRepositoryProvider).getProducts(
            page: current.page + 1,
            limit: kProductPageSize,
            filter: filter,
          );

      // Filter đã đổi trong lúc chờ -> bỏ kết quả cũ.
      if (ref.read(productFilterProvider) != filter) return;

      state = AsyncData(
        current.copyWith(
          items: [...current.items, ...result.items],
          page: result.page,
          total: result.total,
          hasMore: result.hasNext,
          isLoadingMore: false,
        ),
      );
    } catch (e) {
      if (ref.read(productFilterProvider) != filter) return;
      state = AsyncData(
        current.copyWith(isLoadingMore: false, loadMoreError: e),
      );
    }
  }

  /// Xóa trên server rồi bỏ khỏi danh sách hiện tại (không reset phân trang).
  Future<void> deleteProduct(String id) async {
    await ref.read(productRepositoryProvider).deleteProduct(id);
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(
      current.copyWith(
        items: current.items.where((p) => p.id != id).toList(),
        total: current.total - 1,
      ),
    );
  }
}

final productListProvider =
    AsyncNotifierProvider<ProductListNotifier, ProductListState>(
  ProductListNotifier.new,
);
