import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';

class FilterOption<T> {
  const FilterOption({
    required this.label,
    required this.value,
    this.icon,
  });

  final String label;
  final T value;
  final IconData? icon;
}

class LoanFilterRow<T> extends StatelessWidget {
  const LoanFilterRow({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  final List<FilterOption<T>> options;
  final T selected;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: 48,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        scrollDirection: Axis.horizontal,
        itemCount: options.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final option = options[index];
          final isSelected = option.value == selected;
          return ChoiceChip(
            avatar: option.icon != null
                ? Icon(
                    option.icon,
                    size: 16,
                    color: isSelected
                        ? AppColors.primary
                        : (isDark ? AppColors.darkMuted : AppColors.lightMuted),
                  )
                : null,
            label: Text(option.label),
            selected: isSelected,
            onSelected: (_) => onSelected(option.value),
            selectedColor: AppColors.primary.withValues(alpha: 0.14),
            backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
            labelStyle: AppTextStyles.bodySmall(
              color: isSelected
                  ? AppColors.primary
                  : isDark
                      ? AppColors.darkForeground
                      : AppColors.lightForeground,
            ).copyWith(
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            ),
            side: BorderSide(
              color: isSelected
                  ? AppColors.primary
                  : isDark
                      ? AppColors.darkBorder
                      : AppColors.lightBorder,
              width: isSelected ? 1.4 : 1,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            showCheckmark: false,
          );
        },
      ),
    );
  }
}
