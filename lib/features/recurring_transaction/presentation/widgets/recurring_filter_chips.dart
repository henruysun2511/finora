import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../domain/models/recurring_enums.dart';
import '../../domain/models/recurring_transaction_filter.dart';

/// Bộ lọc các trạng thái của giao dịch định kỳ
/// Tuân thủ quy chuẩn ChoiceChip trong GEMINI.md
class RecurringFilterChips extends StatelessWidget {
  const RecurringFilterChips({
    super.key,
    required this.filter,
    required this.onFilterChanged,
  });

  final RecurringTransactionFilter filter;
  final ValueChanged<RecurringTransactionFilter> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildChip(
            context,
            'Tất cả',
            Icons.all_inclusive_rounded,
            filter.isPaused == null && filter.type == null,
            () => onFilterChanged(
              filter.copyWith(clearPaused: true, clearType: true),
            ),
          ),
          const SizedBox(width: 8),
          _buildChip(
            context,
            'Chi tiêu',
            Icons.arrow_downward_rounded,
            filter.type == TransactionType.expense,
            () => onFilterChanged(
              filter.copyWith(
                type: TransactionType.expense,
                clearPaused: true,
              ),
            ),
          ),
          const SizedBox(width: 8),
          _buildChip(
            context,
            'Thu nhập',
            Icons.arrow_upward_rounded,
            filter.type == TransactionType.income,
            () => onFilterChanged(
              filter.copyWith(
                type: TransactionType.income,
                clearPaused: true,
              ),
            ),
          ),
          const SizedBox(width: 8),
          _buildChip(
            context,
            'Đang chạy',
            Icons.play_arrow_rounded,
            filter.isPaused == false,
            () => onFilterChanged(
              filter.copyWith(isPaused: false, clearType: true),
            ),
          ),
          const SizedBox(width: 8),
          _buildChip(
            context,
            'Tạm dừng',
            Icons.pause_rounded,
            filter.isPaused == true,
            () => onFilterChanged(
              filter.copyWith(isPaused: true, clearType: true),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(
    BuildContext context,
    String label,
    IconData icon,
    bool selected,
    VoidCallback onTap,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ChoiceChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 15,
            color: selected
                ? Colors.white
                : (isDark ? AppColors.darkMuted : AppColors.lightMuted),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: selected
                  ? Colors.white
                  : (isDark
                      ? AppColors.darkForeground
                      : AppColors.lightForeground),
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ],
      ),
      selected: selected,
      onSelected: (_) => onTap(),
      showCheckmark: false,
      selectedColor: AppColors.primary,
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      side: BorderSide(
        color: selected
            ? AppColors.primary
            : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    );
  }
}
