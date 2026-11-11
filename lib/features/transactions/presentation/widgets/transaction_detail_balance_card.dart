import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/form_card.dart';

class TransactionDetailBalanceCard extends StatelessWidget {
  const TransactionDetailBalanceCard({
    super.key,
    required this.balanceAfter,
  });

  final double balanceAfter;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final foreground =
        isDark ? AppColors.darkForeground : AppColors.lightForeground;
    final muted = isDark ? AppColors.darkMuted : AppColors.lightMuted;

    final formatted =
        NumberFormat('#,###', 'vi_VN').format(balanceAfter.round());

    return FormCard(
      title: 'Tác động tài chính',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Số dư tài khoản sau giao dịch:',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: muted,
            ),
          ),
          Text(
            '₫ $formatted',
            style: GoogleFonts.outfit(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: foreground,
            ),
          ),
        ],
      ),
    );
  }
}

