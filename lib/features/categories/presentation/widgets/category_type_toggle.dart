import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';
import '../../domain/models/category_type.dart';

class CategoryTypeToggle extends StatelessWidget {
  const CategoryTypeToggle({
    super.key,
    required this.selectedType,
    required this.onChanged,
  });

  final CategoryType selectedType;
  final ValueChanged<CategoryType> onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildItem(
              label: 'Chi tiêu (Expense)',
              isSelected: selectedType == CategoryType.expense,
              isDark: isDark,
              onTap: () => onChanged(CategoryType.expense),
            ),
          ),
          Expanded(
            child: _buildItem(
              label: 'Thu nhập (Income)',
              isSelected: selectedType == CategoryType.income,
              isDark: isDark,
              onTap: () => onChanged(CategoryType.income),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItem({
    required String label,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.primary : Colors.white)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12.5,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected
                ? (isDark ? Colors.white : AppColors.primary)
                : (isDark ? AppColors.darkMuted : AppColors.lightMuted),
          ),
        ),
      ),
    );
  }
}

