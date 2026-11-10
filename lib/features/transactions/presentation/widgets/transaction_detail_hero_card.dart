import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/category_icon.dart';
import '../../domain/models/transaction_enums.dart';
import '../../domain/models/transaction_item.dart';

class TransactionDetailHeroCard extends StatelessWidget {
  const TransactionDetailHeroCard({super.key, required this.item});

  final TransactionItem item;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.darkSurface : Colors.white;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final foreground =
        isDark ? AppColors.darkForeground : AppColors.lightForeground;

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

    final formattedAmount =
        NumberFormat('#,###', 'vi_VN').format(item.amount.round());

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: border),
      ),
      child: Column(
        children: [
          CategoryIcon(
            icon: item.categoryIcon,
            colorHex: item.categoryColor,
            size: 64,
          ),
          const SizedBox(height: 12),
          Text(
            item.name,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: foreground,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            '$prefix$formattedAmount',
            style: GoogleFonts.outfit(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: amountColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Đã hoàn tất • ${item.type.label}',
              style: GoogleFonts.inter(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: AppColors.success,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

