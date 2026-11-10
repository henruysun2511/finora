import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';

class NotificationBannerHero extends StatelessWidget {
  const NotificationBannerHero({
    super.key,
    required this.unreadCount,
  });

  final int unreadCount;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final foreground =
        isDark ? AppColors.darkForeground : AppColors.lightForeground;
    final muted = isDark ? AppColors.darkMuted : AppColors.lightMuted;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TRUNG TÂM THÔNG BÁO',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    letterSpacing: 0.8,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  unreadCount == 0
                      ? 'Bạn đã xem hết thông báo'
                      : 'Bạn có $unreadCount tin chưa đọc',
                  style: GoogleFonts.inter(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: foreground,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Cập nhật tự động về ngân sách, khoản nợ và dòng tiền.',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    height: 1.4,
                    color: muted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.notifications_active_rounded,
              color: AppColors.primary,
              size: 26,
            ),
          ),
        ],
      ),
    );
  }
}
