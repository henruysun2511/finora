import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';
import '../../domain/models/category_type.dart';

/// Bộ chọn chuyển đổi loại danh mục (Chi tiêu / Thu nhập)
/// Áp dụng chuẩn ChoiceChip đồng bộ form thiết lập ngân sách (active nền xanh primary, chữ trắng)
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

    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 6),
            child: ChoiceChip(
              avatar: Icon(
                Icons.arrow_upward_rounded,
                size: 16,
                color: selectedType == CategoryType.expense
                    ? Colors.white
                    : (isDark ? AppColors.darkMuted : AppColors.lightMuted),
              ),
              label: Center(
                child: Text(
                  'Chi tiêu (Expense)',
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
                    fontWeight: selectedType == CategoryType.expense
                        ? FontWeight.w700
                        : FontWeight.w500,
                    color: selectedType == CategoryType.expense
                        ? Colors.white
                        : (isDark
                            ? AppColors.darkForeground
                            : AppColors.lightForeground),
                  ),
                ),
              ),
              selected: selectedType == CategoryType.expense,
              selectedColor: AppColors.primary,
              backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
              side: BorderSide(
                color: selectedType == CategoryType.expense
                    ? AppColors.primary
                    : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              showCheckmark: false,
              onSelected: (_) => onChanged(CategoryType.expense),
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 6),
            child: ChoiceChip(
              avatar: Icon(
                Icons.arrow_downward_rounded,
                size: 16,
                color: selectedType == CategoryType.income
                    ? Colors.white
                    : (isDark ? AppColors.darkMuted : AppColors.lightMuted),
              ),
              label: Center(
                child: Text(
                  'Thu nhập (Income)',
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
                    fontWeight: selectedType == CategoryType.income
                        ? FontWeight.w700
                        : FontWeight.w500,
                    color: selectedType == CategoryType.income
                        ? Colors.white
                        : (isDark
                            ? AppColors.darkForeground
                            : AppColors.lightForeground),
                  ),
                ),
              ),
              selected: selectedType == CategoryType.income,
              selectedColor: AppColors.primary,
              backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
              side: BorderSide(
                color: selectedType == CategoryType.income
                    ? AppColors.primary
                    : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              showCheckmark: false,
              onSelected: (_) => onChanged(CategoryType.income),
            ),
          ),
        ),
      ],
    );
  }
}
