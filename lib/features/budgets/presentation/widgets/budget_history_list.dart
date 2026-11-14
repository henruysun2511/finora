import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../domain/models/budget_period.dart';

class BudgetHistoryList extends StatelessWidget {
  const BudgetHistoryList({
    super.key,
    required this.history,
  });

  final List<BudgetPeriod> history;

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (history.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        child: Center(
          child: Text(
            'Chưa có dữ liệu lịch sử các chu kỳ trước.',
            style: GoogleFonts.inter(fontSize: 13, color: AppColors.lightMuted),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('📜', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'LỊCH SỬ CÁC CHU KỲ TRƯỚC',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: history.length,
            separatorBuilder: (_, __) => Divider(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              height: 20,
            ),
            itemBuilder: (context, index) {
              final item = history[index];
              final isSaved = item.varianceAmount >= 0;
              final monthLabel = 'Tháng ${item.startDate.month.toString().padLeft(2, '0')}/${item.startDate.year}';

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '• $monthLabel: Chi ${currencyFormatter.format(item.spentAmount)} / ${currencyFormatter.format(item.effectiveLimit)}',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isSaved
                        ? 'Tiết kiệm được: +${currencyFormatter.format(item.varianceAmount)} ➔ Đã cộng dồn vào chu kỳ tiếp theo'
                        : 'Bội chi: -${currencyFormatter.format(item.varianceAmount.abs())} ➔ Đã khấu trừ vào chu kỳ tiếp theo',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isSaved ? AppColors.success : AppColors.danger,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

