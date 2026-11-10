import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/lucide_icon.dart';

/// Trạng thái trống khi không có bài đăng hoặc không tìm thấy bài phù hợp
class FeedEmptyState extends StatelessWidget {
  const FeedEmptyState({
    super.key,
    required this.onResetFilter,
  });

  final VoidCallback onResetFilter;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final foreground =
        dark ? AppColors.darkForeground : AppColors.lightForeground;
    final muted = dark ? AppColors.darkMuted : AppColors.lightMuted;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const LucideIcon(
                name: 'newspaper',
                size: 38,
                color: AppColors.primary,
                strokeWidth: 2.0,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Không tìm thấy bài đăng phù hợp',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: foreground,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Hãy thử chọn danh mục khác hoặc xóa bộ lọc để xem toàn bộ bảng tin bạn bè.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                height: 1.4,
                color: muted,
              ),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: onResetFilter,
              icon: const LucideIcon(name: 'refresh-cw', size: 16, color: AppColors.primary),
              label: const Text('Đặt lại bộ lọc'),
            ),
          ],
        ),
      ),
    );
  }
}
