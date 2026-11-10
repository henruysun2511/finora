import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';

class QuickAmountChips extends StatelessWidget {
  const QuickAmountChips({
    super.key,
    required this.onAddAmount,
  });

  final ValueChanged<double> onAddAmount;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildChip('+50.000', 50000, border),
        _buildChip('+100.000', 100000, border),
        _buildChip('+200.000', 200000, border),
        _buildChip('+500.000', 500000, border),
      ],
    );
  }

  Widget _buildChip(String label, double addAmount, Color border) {
    return InkWell(
      onTap: () => onAddAmount(addAmount),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: border),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}
