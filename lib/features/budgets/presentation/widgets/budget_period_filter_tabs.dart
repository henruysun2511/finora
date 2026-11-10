import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../domain/models/budget_enums.dart';
import '../../domain/models/budget_filter.dart';

/// Bộ lọc chu kỳ ngân sách (Theo Tháng, Theo Tuần, Theo Năm)
/// Tuân thủ quy chuẩn ChoiceChip trong GEMINI.md
class BudgetPeriodFilterTabs extends StatelessWidget {
  const BudgetPeriodFilterTabs({
    super.key,
    required this.filter,
    required this.onPeriodChanged,
  });

  final BudgetFilter filter;
  final ValueChanged<BudgetPeriodType?> onPeriodChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final tabs = [
      (null, 'Tất cả', Icons.apps_rounded),
      (BudgetPeriodType.monthly, 'Theo Tháng', Icons.calendar_month_rounded),
      (BudgetPeriodType.weekly, 'Theo Tuần', Icons.view_week_rounded),
      (BudgetPeriodType.yearly, 'Theo Năm', Icons.event_note_rounded),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: tabs.map((tab) {
          final isSelected = filter.periodType == tab.$1;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              showCheckmark: false,
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    tab.$3,
                    size: 15,
                    color: isSelected
                        ? Colors.white
                        : (isDark ? AppColors.darkMuted : AppColors.lightMuted),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    tab.$2,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? Colors.white
                          : (isDark
                              ? AppColors.darkForeground
                              : AppColors.lightForeground),
                    ),
                  ),
                ],
              ),
              selected: isSelected,
              onSelected: (_) => onPeriodChanged(tab.$1),
              backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
              selectedColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: isSelected
                      ? AppColors.primary
                      : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            ),
          );
        }).toList(),
      ),
    );
  }
}
