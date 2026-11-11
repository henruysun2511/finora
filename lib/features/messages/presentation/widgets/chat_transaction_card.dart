import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../domain/models/related_transaction.dart';

class ChatTransactionCard extends StatelessWidget {
  const ChatTransactionCard({
    super.key,
    required this.transaction,
    required this.isMe,
    required this.time,
    this.onViewDetail,
  });

  final RelatedTransaction transaction;
  final bool isMe;
  final String time;
  final VoidCallback? onViewDetail;

  String _formatAmount(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}tr';
    }
    if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}k';
    }
    return amount.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.darkSurface : Colors.white;
    final foreground = isDark ? AppColors.darkForeground : AppColors.lightForeground;
    final muted = isDark ? AppColors.darkMuted : AppColors.lightMuted;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    final amountColor = transaction.isExpense ? AppColors.danger : AppColors.success;
    final amountText = '${transaction.isExpense ? '-' : '+'}${_formatAmount(transaction.amount)}đ';

    return Container(
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.74),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.receipt_long_rounded, size: 12, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text(
                      transaction.groupWalletName ?? 'Chia bill hóa đơn',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(time, style: TextStyle(fontSize: 10.5, color: muted)),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            transaction.name,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: foreground),
          ),
          const SizedBox(height: 6),
          Text(
            amountText,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: amountColor),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              minimumSize: Size.zero,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: onViewDetail,
            icon: const Icon(Icons.arrow_forward_rounded, size: 14),
            label: const Text('Xem chi tiết hóa đơn', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
