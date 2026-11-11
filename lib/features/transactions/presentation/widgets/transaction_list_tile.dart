import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/category_icon.dart';
import '../../domain/models/transaction_enums.dart';
import '../../domain/models/transaction_item.dart';

class TransactionListTile extends StatelessWidget {
  const TransactionListTile({
    super.key,
    required this.item,
    required this.onTap,
  });

  final TransactionItem item;
  final VoidCallback onTap;

  String _formatAmount(double amount) {
    return NumberFormat('#,###', 'vi_VN').format(amount.round());
  }

  String _formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final foreground =
        isDark ? AppColors.darkForeground : AppColors.lightForeground;
    final muted = isDark ? AppColors.darkMuted : AppColors.lightMuted;

    // Phối màu và ký hiệu theo loại giao dịch
    Color amountColor;
    String prefix;

    switch (item.type) {
      case TransactionType.expense:
        amountColor = AppColors.danger;
        prefix = '- ₫ ';
        break;
      case TransactionType.income:
        amountColor = AppColors.success;
        prefix = '+ ₫ ';
        break;
      case TransactionType.transfer:
        amountColor = AppColors.primary;
        prefix = '⇄ ₫ ';
        break;
    }

    // Subtitle text: [Ghi chú / Danh mục] • [Tài khoản] (HH:mm)
    final parts = <String>[];
    if (item.categoryName != null && item.categoryName!.isNotEmpty) {
      parts.add(item.categoryName!);
    }
    if (item.accountName != null && item.accountName!.isNotEmpty) {
      parts.add(item.accountName!);
    }
    parts.add(_formatTime(item.transactionDate));
    final subText = parts.join(' • ');

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            // Icon Danh mục
            CategoryIcon(
              icon: item.categoryIcon,
              colorHex: item.categoryColor,
              size: 42,
            ),
            const SizedBox(width: 12),

            // Tiêu đề & Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: GoogleFonts.inter(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: foreground,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subText,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: muted,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Số tiền
            Text(
              '$prefix${_formatAmount(item.amount)}',
              style: GoogleFonts.outfit(
                fontSize: 15.5,
                fontWeight: FontWeight.w800,
                color: amountColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

