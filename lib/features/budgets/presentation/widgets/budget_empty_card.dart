import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../app/theme/app_colors.dart';

/// Thẻ thông báo trạng thái rỗng khi chưa có ngân sách nào
class BudgetEmptyCard extends StatelessWidget {
  const BudgetEmptyCard({
    super.key,
    required this.isDark,
  });

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.savings_outlined,
            size: 48,
            color: AppColors.lightMuted,
          ),
          const SizedBox(height: 12),
          Text(
            'Chưa có ngân sách nào được thiết lập.',
            style: GoogleFonts.inter(
              color: AppColors.lightMuted,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
