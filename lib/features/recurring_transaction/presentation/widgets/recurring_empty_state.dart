import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';

/// Trạng thái trống khi chưa có giao dịch định kỳ
class RecurringEmptyState extends StatelessWidget {
  const RecurringEmptyState({
    super.key,
    required this.isDark,
  });

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final muted = isDark ? AppColors.darkMuted : AppColors.lightMuted;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.event_repeat_rounded,
              size: 36,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Chưa có giao dịch định kỳ nào',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isDark
                  ? AppColors.darkForeground
                  : AppColors.lightForeground,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Tự động hóa các khoản chi tiêu lặp lại hàng tháng',
            style: TextStyle(fontSize: 13, color: muted),
          ),
        ],
      ),
    );
  }
}
