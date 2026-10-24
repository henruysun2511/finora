import 'package:flutter/material.dart';

import '../../domain/models/product.dart';

class StockBadge extends StatelessWidget {
  const StockBadge({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color fg;
    final String text;

    if (!product.inStock) {
      bg = Colors.red.shade50;
      fg = Colors.red.shade800;
      text = 'Hết hàng';
    } else if (product.isLowStock) {
      bg = Colors.orange.shade50;
      fg = Colors.orange.shade900;
      text = 'Còn ${product.stock} (Sắp hết)';
    } else {
      bg = Colors.green.shade50;
      fg = Colors.green.shade800;
      text = 'Còn ${product.stock}';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: Theme.of(context)
            .textTheme
            .labelSmall
            ?.copyWith(color: fg, fontWeight: FontWeight.w600),
      ),
    );
  }
}
