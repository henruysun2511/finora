import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../domain/models/budget.dart';
import '../../domain/models/budget_enums.dart';
import 'budget_progress_bar.dart';

class BudgetProgressCard extends StatelessWidget {
  const BudgetProgressCard({
    super.key,
    required this.budget,
    required this.onTap,
  });

  final Budget budget;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final status = budget.status;
    Color statusColor;
    String statusIcon;
    String statusAlert = '';
    switch (status) {
      case BudgetProgressStatus.safe:
        statusColor = AppColors.success;
        statusIcon = '🟢';
        break;
      case BudgetProgressStatus.warning:
        statusColor = AppColors.warning;
        statusIcon = '🟡';
        statusAlert = ' · ⚠️ Sắp chạm trần';
        break;
      case BudgetProgressStatus.exceeded:
        statusColor = AppColors.danger;
        statusIcon = '🔴';
        statusAlert = ' · 🚨 ĐÃ VƯỢT HẠN MỨC!';
        break;
    }

    final categoryIcon = budget.categoryIcon ?? '📁';
    final categoryName = budget.categoryName ?? 'Chi tiêu';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Text(categoryIcon, style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          '$categoryName (${budget.periodType.label.replaceAll("Theo ", "")})',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '$statusIcon ${budget.percentage.toStringAsFixed(0)}%',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  'Hạn mức: ${currencyFormatter.format(budget.effectiveLimit)}',
                  style: GoogleFonts.inter(fontSize: 12, color: AppColors.lightMuted),
                ),
                const SizedBox(width: 6),
                const Text('·', style: TextStyle(color: AppColors.lightMuted)),
                const SizedBox(width: 6),
                Text(
                  'Đã chi: ${currencyFormatter.format(budget.spentAmount)}',
                  style: GoogleFonts.inter(fontSize: 12, color: AppColors.lightMuted),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Text(
                  budget.remainingAmount >= 0
                      ? 'Còn lại: ${currencyFormatter.format(budget.remainingAmount)}'
                      : 'Bội chi: -${currencyFormatter.format(budget.remainingAmount.abs())}',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: budget.remainingAmount >= 0 ? statusColor : AppColors.danger,
                  ),
                ),
                if (budget.rolloverAmount != 0)
                  Text(
                    ' (Rollover: ${budget.rolloverAmount > 0 ? "+" : ""}${currencyFormatter.format(budget.rolloverAmount)})',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppColors.lightMuted,
                    ),
                  ),
                if (statusAlert.isNotEmpty)
                  Text(
                    statusAlert,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            BudgetProgressBar(percentage: budget.percentage, height: 8),
          ],
        ),
      ),
    );
  }
}

