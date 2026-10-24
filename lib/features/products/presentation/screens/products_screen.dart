import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../domain/models/product.dart';
import '../providers/product_filter_provider.dart';
import '../providers/product_list_provider.dart';
import '../providers/product_list_state.dart';
import '../widgets/product_card.dart';
import '../widgets/product_delete_dialog.dart';
import '../widgets/product_filter_chips.dart';
import '../widgets/product_filter_sheet.dart';
import '../widgets/product_search_bar.dart';
import 'product_detail_screen.dart';
import 'product_form_screen.dart';

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
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scroll.hasClients) return;
    final nearBottom =
        _scroll.position.pixels >= _scroll.position.maxScrollExtent - 240;
    if (nearBottom) ref.read(productListProvider.notifier).loadMore();
  }

  /// Nếu trang đầu chưa lấp đầy màn hình thì không thể cuộn -> tự tải tiếp.
  void _fillViewportIfNeeded(ProductListState s) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scroll.hasClients) return;
      if (_scroll.position.maxScrollExtent <= 0 &&
          s.hasMore &&
          !s.isLoadingMore &&
          s.loadMoreError == null) {
        ref.read(productListProvider.notifier).loadMore();
      }
    });
  }

  Future<void> _openCreate() => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const ProductFormScreen()),
      );

  Future<void> _openEdit(Product p) => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => ProductFormScreen(productId: p.id),
        ),
      );

  Future<void> _openDetail(Product p) => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => ProductDetailScreen(productId: p.id),
        ),
      );

  Future<void> _delete(Product p) async {
    final ok = await confirmDeleteProduct(context, p);
    if (!ok || !mounted) return;

    try {
      await ref.read(productListProvider.notifier).deleteProduct(p.id);
      if (mounted) {
        AppToast.success(context, 'Đã xóa sản phẩm thành công');
      }
    } catch (e) {
      if (mounted) {
        final msg = e is AppException ? e.message : e.toString();
        AppToast.error(context, msg);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final async = ref.watch(productListProvider);
    final filter = ref.watch(productFilterProvider);

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Quản lý Sản phẩm'),
        actions: [
          IconButton(
            tooltip: 'Bộ lọc & Sắp xếp',
            onPressed: () => showProductFilterSheet(context),
            icon: Badge(
              label: Text('${filter.activeCount}'),
              isLabelVisible: filter.activeCount > 0,
              backgroundColor: AppColors.orange,
              child: const Icon(Icons.tune_rounded),
            ),
          ),
        ],
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
                      : _buildList(state),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  bool _hasAnyFilter(filter) =>
      (filter.search != null) || filter.activeCount > 0;

  Widget _buildList(ProductListState state) {
    return ListView.builder(
      controller: _scroll,
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
            onTap: () => _openDetail(p),
            onEdit: () => _openEdit(p),
            onDelete: () => _delete(p),
          );
        }
        return _ListFooter(
          state: state,
          onRetry: () => ref.read(productListProvider.notifier).loadMore(),
        );
      },
    );
  }
}

class _ListFooter extends StatelessWidget {
  const _ListFooter({required this.state, required this.onRetry});

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
