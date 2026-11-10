import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/page_header.dart';
import '../../domain/models/product.dart';
import '../providers/product_filter_provider.dart';
import '../providers/product_list_provider.dart';
import '../widgets/product_filter_chips.dart';
import '../widgets/product_list_view.dart';
import '../widgets/product_search_bar.dart';

class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key});

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scroll.hasClients) return;
    final max = _scroll.position.maxScrollExtent;
    final current = _scroll.position.pixels;
    if (current >= max - 300) {
      ref.read(productListProvider.notifier).loadMore();
    }
  }

  void _fillViewportIfNeeded(dynamic state) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (!_scroll.hasClients) return;
      if (state.hasMore &&
          !state.isLoadingMore &&
          state.loadMoreError == null &&
          _scroll.position.maxScrollExtent <= 0) {
        ref.read(productListProvider.notifier).loadMore();
      }
    });
  }

  void _openCreate() => context.push(RoutePaths.createProduct);

  void _openDetail(Product product) {
    context.push(RoutePaths.productDetail.replaceFirst(':id', product.id));
  }

  void _openEdit(Product product) {
    context.push(RoutePaths.editProduct.replaceFirst(':id', product.id));
  }

  Future<void> _delete(Product product) async {
    final ok = await showConfirmDialog(
      context,
      title: 'Xóa sản phẩm',
      message:
          'Bạn có chắc muốn xóa "${product.name}"? Hành động này không thể hoàn tác.',
      confirmText: 'Xóa',
      isDestructive: true,
    );
    if (!ok || !mounted) return;

    try {
      await ref.read(productListProvider.notifier).deleteProduct(product.id);
      if (mounted) {
        AppToast.show(
          context,
          message: 'Đã xóa sản phẩm',
          type: ToastType.success,
        );
      }
    } catch (e) {
      if (mounted) {
        final msg = e is AppException ? e.message : e.toString();
        AppToast.show(context, message: msg, type: ToastType.error);
      }
    }
  }

  bool _hasAnyFilter(dynamic filter) =>
      (filter.search != null) || filter.activeCount > 0;

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(productListProvider);
    final filter = ref.watch(productFilterProvider);

    return Scaffold(
      appBar: const PageHeader.subPage(
        title: 'Kho sản phẩm',
        subtitle: 'Quản lý danh mục hàng hóa & giá bán',
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: _openCreate,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Thêm sản phẩm'),
      ),
      body: Column(
        children: [
          const ProductSearchBar(),
          const ProductFilterChips(),
          Expanded(
            child: async.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) {
                final msg = e is AppException ? e.message : e.toString();
                return _ErrorView(
                  message: msg,
                  onRetry: () => ref.invalidate(productListProvider),
                );
              },
              data: (state) {
                _fillViewportIfNeeded(state);
                return RefreshIndicator(
                  onRefresh: () =>
                      ref.read(productListProvider.notifier).refresh(),
                  child: state.items.isEmpty
                      ? _EmptyView(hasFilter: _hasAnyFilter(filter))
                      : ProductListView(
                          state: state,
                          scrollController: _scroll,
                          onOpenDetail: _openDetail,
                          onOpenEdit: _openEdit,
                          onDelete: _delete,
                          onLoadMoreRetry: () => ref
                              .read(productListProvider.notifier)
                              .loadMore(),
                        ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.hasFilter});

  final bool hasFilter;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 100),
        Icon(
          Icons.inventory_2_outlined,
          size: 64,
          color: Theme.of(context).colorScheme.outline,
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
            hasFilter
                ? 'Không có sản phẩm phù hợp'
                : 'Chưa có sản phẩm nào',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded,
                size: 48, color: AppColors.danger),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              onPressed: onRetry,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }
}
