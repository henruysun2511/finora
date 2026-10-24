import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../domain/models/product.dart';
import '../providers/product_detail_provider.dart';
import '../providers/product_list_provider.dart';
import '../widgets/product_delete_dialog.dart';
import '../widgets/stock_badge.dart';
import 'product_form_screen.dart';

class ProductDetailScreen extends ConsumerWidget {
  const ProductDetailScreen({super.key, required this.productId});

  final String productId;

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    Product product,
  ) async {
    final ok = await confirmDeleteProduct(context, product);
    if (!ok || !context.mounted) return;

    final navigator = Navigator.of(context);
    try {
      await ref.read(productListProvider.notifier).deleteProduct(product.id);
      if (context.mounted) {
        AppToast.success(context, 'Đã xóa sản phẩm thành công');
      }
      navigator.pop();
    } catch (e) {
      if (context.mounted) {
        final msg = e is AppException ? e.message : e.toString();
        AppToast.error(context, msg);
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final async = ref.watch(productDetailProvider(productId));
    final product = async.valueOrNull;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Chi tiết sản phẩm'),
        actions: [
          if (product != null) ...[
            IconButton(
              tooltip: 'Chỉnh sửa',
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => ProductFormScreen(productId: product.id),
                ),
              ),
            ),
            IconButton(
              tooltip: 'Xóa',
              icon: const Icon(Icons.delete_outline, color: AppColors.danger),
              onPressed: () => _delete(context, ref, product),
            ),
          ],
        ],
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) {
          final msg = e is AppException ? e.message : e.toString();
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline_rounded,
                      size: 48, color: AppColors.danger),
                  const SizedBox(height: 12),
                  Text(msg, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        ref.invalidate(productDetailProvider(productId)),
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            ),
          );
        },
        data: (p) => _DetailBody(product: p),
      ),
    );
  }
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppColors.radiusLg),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: product.imageUrl == null || product.imageUrl!.trim().isEmpty
                ? Container(
                    color: AppColors.primaryLight,
                    child: const Icon(
                      Icons.inventory_2_outlined,
                      size: 64,
                      color: AppColors.primary,
                    ),
                  )
                : Image.network(
                    product.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: AppColors.primaryLight,
                      child: const Icon(Icons.broken_image_outlined, size: 48),
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 16),

        // Solarn Hero Card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(AppColors.radiusMd),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      product.category.label,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: product.isAvailable
                          ? AppColors.success.withValues(alpha: 0.12)
                          : AppColors.danger.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      product.isAvailable ? 'Đang mở bán' : 'Tạm dừng',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: product.isAvailable
                            ? AppColors.success
                            : AppColors.danger,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                product.name,
                style: AppTextStyles.h3.copyWith(
                  color: isDark
                      ? AppColors.darkForeground
                      : AppColors.lightForeground,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    CurrencyFormatter.formatVnd(product.price),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  StockBadge(product: product),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Bảng thông số chi tiết
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(AppColors.radiusMd),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Thông số sản phẩm',
                style: AppTextStyles.h4.copyWith(
                  color: isDark
                      ? AppColors.darkForeground
                      : AppColors.lightForeground,
                ),
              ),
              const SizedBox(height: 12),
              _InfoRow(label: 'Mã định danh (ID)', value: product.id),
              const Divider(height: 18),
              _InfoRow(
                label: 'Mã SKU',
                value: product.sku.isNotEmpty ? product.sku : 'Chưa có SKU',
              ),
              const Divider(height: 18),
              _InfoRow(label: 'Số lượng tồn kho', value: '${product.stock} đơn vị'),
              const Divider(height: 18),
              _InfoRow(label: 'Ngày tạo', value: dateFormat.format(product.createdAt)),
              const Divider(height: 18),
              _InfoRow(label: 'Cập nhật', value: dateFormat.format(product.updatedAt)),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Mô tả chi tiết
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(AppColors.radiusMd),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mô tả chi tiết',
                style: AppTextStyles.h4.copyWith(
                  color: isDark
                      ? AppColors.darkForeground
                      : AppColors.lightForeground,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                product.description.isEmpty
                    ? 'Chưa có mô tả chi tiết cho sản phẩm này.'
                    : product.description,
                style: AppTextStyles.body.copyWith(
                  color: isDark
                      ? AppColors.darkForeground
                      : AppColors.lightForeground,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: isDark
                ? AppColors.darkForeground
                : AppColors.lightForeground,
          ),
        ),
      ],
    );
  }
}
