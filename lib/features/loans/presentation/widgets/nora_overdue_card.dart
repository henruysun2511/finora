import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/nora_avatar.dart';
import '../../domain/models/loan.dart';

class NoraOverdueCard extends StatelessWidget {
  const NoraOverdueCard({
    super.key,
    required this.loan,
    required this.onTap,
  });

  final Loan loan;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.primary.withValues(alpha: 0.15)
            : const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? AppColors.primary.withValues(alpha: 0.35)
              : const Color(0xFFBFDBFE),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const NoraAvatar(size: 42),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nora AI · Cảnh báo quá hạn',
                  style: AppTextStyles.labelSmall(color: AppColors.primary),
                ),
                const SizedBox(height: 3),
                RichText(
                  text: TextSpan(
                    style: AppTextStyles.bodySmall(
                      color: isDark
                          ? AppColors.darkForeground
                          : const Color(0xFF1E3A8A),
                    ),
                    children: [
                      TextSpan(
                        text: loan.counterpartyName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const TextSpan(text: ' còn nợ '),
                      TextSpan(
                        text: CurrencyFormatter.formatVnd(loan.remainingAmount),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: ' đã quá hạn ${loan.overdueDays ?? 0} ngày.',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          FilledButton.tonal(
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              visualDensity: VisualDensity.compact,
            ),
            onPressed: onTap,
            child: const Text('Xem nợ'),
          ),
        ],
      ),
    );
  }
}

