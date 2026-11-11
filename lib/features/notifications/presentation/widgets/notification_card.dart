import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:finora_mb/app/theme/app_colors.dart';
import '../../domain/models/notification_item.dart';

class NotificationCard extends StatelessWidget {
  const NotificationCard({
    super.key,
    required this.title,
    required this.message,
    required this.time,
    required this.icon,
    this.iconColor,
    this.iconBgColor,
    this.isRead = false,
    this.onTap,
    this.onDelete,
  });

  factory NotificationCard.fromItem({
    Key? key,
    required NotificationItem item,
    VoidCallback? onTap,
    VoidCallback? onDelete,
  }) {
    return NotificationCard(
      key: key,
      title: item.title,
      message: item.body,
      time: _formatRelativeTime(item.createdAt),
      icon: item.type.icon,
      iconColor: item.type.color,
      isRead: item.isRead,
      onTap: onTap,
      onDelete: onDelete,
    );
  }

  final String title;
  final String message;
  final String time;
  final IconData icon;
  final Color? iconColor;
  final Color? iconBgColor;
  final bool isRead;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final foreground =
        isDark ? AppColors.darkForeground : AppColors.lightForeground;
    final muted = isDark ? AppColors.darkMuted : AppColors.lightMuted;

    final effectiveColor = iconColor ?? AppColors.primary;
    final effectiveBgColor = iconBgColor ??
        effectiveColor.withValues(alpha: isDark ? 0.16 : 0.10);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? AppColors.darkBorder
              : (isRead
                  ? AppColors.lightBorder
                  : effectiveColor.withValues(alpha: 0.22)),
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.035),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Icon đa dạng màu sắc ────────────────────────────────
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: effectiveBgColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    icon,
                    size: 22,
                    color: effectiveColor,
                  ),
                ),
                const SizedBox(width: 14),

                // ── Nội dung thông báo ──────────────────────────────────
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight:
                                    isRead ? FontWeight.w600 : FontWeight.w700,
                                color: foreground,
                              ),
                            ),
                          ),
                          if (!isRead)
                            Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.only(left: 8),
                              decoration: BoxDecoration(
                                color: effectiveColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        message,
                        style: GoogleFonts.inter(
                          fontSize: 12.5,
                          height: 1.5,
                          color: muted,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 13,
                            color: muted,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            time,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: muted,
                            ),
                          ),
                          const Spacer(),
                          if (onDelete != null)
                            GestureDetector(
                              onTap: onDelete,
                              child: Icon(
                                Icons.close_rounded,
                                size: 16,
                                color: muted.withValues(alpha: 0.6),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Vừa xong';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} phút trước';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inDays == 1) {
      return 'Hôm qua';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    } else {
      return DateFormat('dd/MM/yyyy').format(dateTime);
    }
  }
}
