import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/category_icon.dart';
import '../../domain/models/budget.dart';

/// Thẻ ngân sách từng danh mục chuẩn Solarn FinTech Style (`static-ui/ui-sample-3`).
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
    final currencyFormatter = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '₫',
      decimalDigits: 0,
    );
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final pct = budget.percentage;
    final pctClamped = (pct / 100.0).clamp(0.0, 1.0);

    // Màu sắc và Pill trạng thái chuẩn ui-sample-3
    Color statusColor;
    Color pillBg;
    String pillText;
    IconData pillIcon;

    if (pct >= 100.0) {
      statusColor = AppColors.danger;
      pillBg = AppColors.danger.withValues(alpha: 0.12);
      pillText = 'Vượt';
      pillIcon = Icons.error_outline_rounded;
    } else if (pct >= 80.0) {
      statusColor = const Color(0xFFF97316); // Solarn Orange / Warn
      pillBg = const Color(0xFFF97316).withValues(alpha: 0.12);
      pillText = 'Gần vượt';
      pillIcon = Icons.warning_amber_rounded;
    } else {
      statusColor = AppColors.success;
      pillBg = AppColors.success.withValues(alpha: 0.12);
      pillText = 'Ổn';
      pillIcon = Icons.check_circle_outline_rounded;
    }

    final categoryName = budget.categoryName ?? 'Chi tiêu';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. bud-row: Icon + Tên + % Đã dùng
                Row(
                  children: [
                    CategoryIcon(
                      icon: budget.categoryIcon,
                      colorHex: budget.categoryColor,
                      size: 40,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        categoryName,
                        style: GoogleFonts.inter(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '${pct.toStringAsFixed(0)}%',
                      style: GoogleFonts.inter(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w900,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // 2. bud-bar-t: Thanh tiến độ mỏng thanh lịch 7px
                Container(
                  height: 7,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkBorder : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: budget.effectiveLimit > 0 ? pctClamped : 0.0,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(99),
                        color: statusColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // 3. bud-foot: ₫960,000 / ₫1,200,000 + Pill trạng thái Solarn
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${currencyFormatter.format(budget.spentAmount)} / ${currencyFormatter.format(budget.effectiveLimit)}',
                      style: GoogleFonts.inter(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                      decoration: BoxDecoration(
                        color: pillBg,
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(pillIcon, size: 12, color: statusColor),
                          const SizedBox(width: 4),
                          Text(
                            pillText,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
