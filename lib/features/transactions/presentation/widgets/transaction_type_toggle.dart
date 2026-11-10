import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';
import '../../domain/models/transaction_enums.dart';

class TransactionTypeToggle extends StatelessWidget {
  const TransactionTypeToggle({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
  });

  final TransactionType selectedType;
  final ValueChanged<TransactionType> onTypeChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.darkSurface : Colors.white;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final foreground =
        isDark ? AppColors.darkForeground : AppColors.lightForeground;

    return Row(
      children: [
        _buildChip(
          label: 'CHI TIÊU',
          isSelected: selectedType == TransactionType.expense,
          onSelected: () => onTypeChanged(TransactionType.expense),
          isDark: isDark,
          surface: surface,
          border: border,
          foreground: foreground,
        ),
        const SizedBox(width: 8),
        _buildChip(
          label: 'THU NHẬP',
          isSelected: selectedType == TransactionType.income,
          onSelected: () => onTypeChanged(TransactionType.income),
          isDark: isDark,
          surface: surface,
          border: border,
          foreground: foreground,
        ),
        const SizedBox(width: 8),
        _buildChip(
          label: 'CHUYỂN TIỀN',
          isSelected: selectedType == TransactionType.transfer,
          onSelected: () => onTypeChanged(TransactionType.transfer),
          isDark: isDark,
          surface: surface,
          border: border,
          foreground: foreground,
        ),
      ],
    );
  }

  Widget _buildChip({
    required String label,
    required bool isSelected,
    required VoidCallback onSelected,
    required bool isDark,
    required Color surface,
    required Color border,
    required Color foreground,
  }) {
    return Expanded(
      child: Material(
        color: isSelected ? AppColors.primary : surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isSelected ? AppColors.primary : border,
          ),
        ),
        child: InkWell(
          onTap: onSelected,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 42,
            alignment: Alignment.center,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? Colors.white : foreground,
                letterSpacing: 0.4,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
