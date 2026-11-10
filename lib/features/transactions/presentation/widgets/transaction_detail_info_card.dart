import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/form_card.dart';
import '../../domain/models/transaction_enums.dart';
import '../../domain/models/transaction_item.dart';

class TransactionDetailInfoCard extends StatelessWidget {
  const TransactionDetailInfoCard({
    super.key,
    required this.item,
    required this.dateStr,
  });

  final TransactionItem item;
  final String dateStr;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final foreground =
        isDark ? AppColors.darkForeground : AppColors.lightForeground;
    final muted = isDark ? AppColors.darkMuted : AppColors.lightMuted;

    return FormCard(
      title: 'Thông tin chi tiết',
      child: Column(
        children: [
          _buildRow(
            'Nguồn tiền',
            item.accountName ?? 'Tài khoản chính',
            Icons.account_balance_wallet_rounded,
            foreground,
            muted,
          ),
          Divider(height: 20, color: border.withValues(alpha: 0.4)),
          if (item.type == TransactionType.transfer &&
              item.toAccountName != null) ...[
            _buildRow(
              'Tài khoản đích',
              item.toAccountName!,
              Icons.download_rounded,
              foreground,
              muted,
            ),
            Divider(height: 20, color: border.withValues(alpha: 0.4)),
          ],
          _buildRow(
            'Ngày giờ',
            dateStr,
            Icons.access_time_rounded,
            foreground,
            muted,
          ),
          if (item.note != null && item.note!.isNotEmpty) ...[
            Divider(height: 20, color: border.withValues(alpha: 0.4)),
            _buildRow(
              'Ghi chú',
              item.note!,
              Icons.notes_rounded,
              foreground,
              muted,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRow(
    String label,
    String value,
    IconData icon,
    Color foreground,
    Color muted,
  ) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 10),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: muted,
          ),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: foreground,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}

