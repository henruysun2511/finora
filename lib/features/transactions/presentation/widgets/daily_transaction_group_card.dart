import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../domain/models/daily_transaction_group.dart';
import '../../domain/models/transaction_item.dart';
import 'transaction_list_tile.dart';

class DailyTransactionGroupCard extends StatelessWidget {
  const DailyTransactionGroupCard({
    super.key,
    required this.group,
    required this.onTransactionTap,
  });

  final DailyTransactionGroup group;
  final ValueChanged<TransactionItem> onTransactionTap;

  String _formatCurrency(double amount) {
    return NumberFormat('#,###', 'vi_VN').format(amount.round());
  }

  String _formatDateHeader(DateTime date, String dayOfWeek) {
    final dateStr = DateFormat('dd/MM/yyyy').format(date);
    return '${dayOfWeek.toUpperCase()} - $dateStr';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.darkSurface : Colors.white;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final muted = isDark ? AppColors.darkMuted : AppColors.lightMuted;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Ngày
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 4,
              children: [
                Text(
                  _formatDateHeader(group.date, group.dayOfWeek),
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                    color: AppColors.primary,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (group.totalIncome > 0) ...[
                      Flexible(
                        child: Text(
                          '+₫ ${_formatCurrency(group.totalIncome)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.success,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    if (group.totalExpense > 0)
                      Flexible(
                        child: Text(
                          '-₫ ${_formatCurrency(group.totalExpense)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.danger,
                          ),
                        ),
                      ),
                    if (group.totalIncome == 0 && group.totalExpense == 0)
                      Text(
                        '₫ 0',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: muted,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          Divider(height: 1, color: border.withValues(alpha: 0.6)),

          // Danh sách các giao dịch trong ngày
          Column(
            children: [
              for (int i = 0; i < group.transactions.length; i++) ...[
                if (i > 0)
                  Divider(
                    height: 1,
                    indent: 68,
                    color: border.withValues(alpha: 0.4),
                  ),
                TransactionListTile(
                  item: group.transactions[i],
                  onTap: () => onTransactionTap(group.transactions[i]),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

