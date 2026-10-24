import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../providers/product_filter_provider.dart';

/// Hiển thị các bộ lọc đang bật dưới dạng chip, bấm x để bỏ từng cái.
class ProductFilterChips extends ConsumerWidget {
  const ProductFilterChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final f = ref.watch(productFilterProvider);
    final n = ref.read(productFilterProvider.notifier);

    final chips = <Widget>[
      if (f.category != null)
        InputChip(
          label: Text(f.category!.label),
          onDeleted: n.clearCategory,
        ),
      if (f.hasPriceRange)
        InputChip(
          label: Text(_priceLabel(f.minPrice, f.maxPrice)),
          onDeleted: n.clearPrice,
        ),
      if (f.inStock != null)
        InputChip(
          label: Text(f.inStock! ? 'Còn hàng' : 'Hết hàng'),
          onDeleted: n.clearInStock,
        ),
    ];

    if (chips.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          for (final c in chips)
            Padding(padding: const EdgeInsets.only(right: 8), child: c),
          TextButton(onPressed: n.reset, child: const Text('Xóa tất cả')),
        ],
      ),
    );
  }

  String _priceLabel(double? min, double? max) {
    if (min != null && max != null) {
      return '${CurrencyFormatter.formatVnd(min)} - ${CurrencyFormatter.formatVnd(max)}';
    }
    if (min != null) return 'Từ ${CurrencyFormatter.formatVnd(min)}';
    return 'Đến ${CurrencyFormatter.formatVnd(max!)}';
  }
}
