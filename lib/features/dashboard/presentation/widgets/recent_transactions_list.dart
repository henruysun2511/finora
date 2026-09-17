import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/models/dashboard_data.dart';

class RecentTransactionsList extends StatelessWidget {
  final List<TransactionItem> transactions;
  final ValueChanged<TransactionItem>? onTransactionTap;

  const RecentTransactionsList({
    super.key,
    this.transactions = TransactionItem.sampleTransactions,
    this.onTransactionTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: List.generate(transactions.length, (index) {
          final tx = transactions[index];
          final isLast = index == transactions.length - 1;

          return InkWell(
            onTap: () => onTransactionTap?.call(tx),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: isLast
                    ? null
                    : Border(
                        bottom: BorderSide(
                          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                          width: 1,
                        ),
                      ),
              ),
              child: Row(
                children: [
                  // Icon square
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      tx.icon,
                      size: 20,
                      color: isDark ? AppColors.darkForeground : const Color(0xFF334155),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Info col: Title & meta
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          tx.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${tx.category} · ${tx.dateText}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.darkMuted : const Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Amount
                  Text(
                    '${tx.isIncome ? '+' : '-'}${CurrencyFormatter.formatVnd(tx.amount.abs())}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: tx.isIncome ? AppColors.success : AppColors.danger,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
