import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/form_card.dart';
import '../../domain/models/transaction_item.dart';
import 'split_bill_bottom_sheet.dart';

/// Khối chia tiền hóa đơn cho bạn bè trong màn hình chi tiết giao dịch
class TransactionDetailSplitCard extends StatelessWidget {
  const TransactionDetailSplitCard({
    super.key,
    required this.amount,
    this.transaction,
  });

  final double amount;
  final TransactionItem? transaction;

  void _handleOpenSplit(BuildContext context) {
    if (transaction != null) {
      SplitBillBottomSheet.show(context, transaction: transaction!);
    } else {
      context.push(RoutePaths.splitExpenses);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FormCard(
      title: 'Chia tiền nhóm (Split Bill)',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.group_work_rounded,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Chia tiền cho bạn bè',
                      style: GoogleFonts.inter(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.darkForeground
                            : AppColors.lightForeground,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Chia đều hoặc tùy chỉnh số tiền để bạn bè cùng hoàn trả',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color:
                            isDark ? AppColors.darkMuted : AppColors.lightMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Nút duy nhất: "Chia tiền ngay"
          SizedBox(
            height: 44,
            child: ElevatedButton.icon(
              onPressed: () => _handleOpenSplit(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.share_rounded, size: 18),
              label: Text(
                'Chia tiền ngay',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
