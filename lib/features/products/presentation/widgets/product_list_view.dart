import 'package:flutter/material.dart';

import '../../../../core/errors/app_exception.dart';
import '../../domain/models/product.dart';
import '../providers/product_list_state.dart';
import 'product_card.dart';

class ProductListView extends StatelessWidget {
  const ProductListView({
    super.key,
    required this.state,
    required this.scrollController,
    required this.onOpenDetail,
    required this.onOpenEdit,
    required this.onDelete,
    required this.onLoadMoreRetry,
  });

  final ProductListState state;
  final ScrollController scrollController;
  final ValueChanged<Product> onOpenDetail;
  final ValueChanged<Product> onOpenEdit;
  final ValueChanged<Product> onDelete;
  final VoidCallback onLoadMoreRetry;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 88),
      itemCount: state.items.length + 2, // header + items + footer
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
            child: Text(
              'Hiển thị ${state.items.length} / ${state.total} sản phẩm',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          );
        }
        final i = index - 1;
        if (i < state.items.length) {
          final p = state.items[i];
          return ProductCard(
            key: ValueKey(p.id),
            product: p,
            onTap: () => onOpenDetail(p),
            onEdit: () => onOpenEdit(p),
            onDelete: () => onDelete(p),
          );
        }
        return ProductListFooter(
          state: state,
          onRetry: onLoadMoreRetry,
        );
      },
    );
  }
}

class ProductListFooter extends StatelessWidget {
  const ProductListFooter({
    super.key,
    required this.state,
    required this.onRetry,
  });

  final ProductListState state;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (state.isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (state.loadMoreError != null) {
      final msg = state.loadMoreError is AppException
          ? (state.loadMoreError as AppException).message
          : state.loadMoreError.toString();
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(msg),
            TextButton(onPressed: onRetry, child: const Text('Thử lại')),
          ],
        ),
      );
    }
    if (!state.hasMore) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Text(
            'Đã hiển thị tất cả',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      );
    }
    return const SizedBox(height: 56);
  }
}
