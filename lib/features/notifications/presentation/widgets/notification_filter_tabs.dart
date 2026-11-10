import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../domain/models/notification_filter.dart';

class NotificationFilterTabs extends StatelessWidget {
  const NotificationFilterTabs({
    super.key,
    required this.filter,
    required this.unreadCount,
    required this.onSelectFilter,
  });

  final NotificationFilter filter;
  final int unreadCount;
  final ValueChanged<NotificationFilter> onSelectFilter;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildChip(
            context: context,
            label: 'Tất cả',
            selected: filter.isRead == null,
            onSelected: () => onSelectFilter(filter.copyWith(clearRead: true)),
          ),
          const SizedBox(width: 8),
          _buildChip(
            context: context,
            label: 'Chưa đọc',
            selected: filter.isRead == false,
            badgeCount: unreadCount > 0 ? unreadCount : null,
            onSelected: () => onSelectFilter(filter.copyWith(isRead: false)),
          ),
          const SizedBox(width: 8),
          _buildChip(
            context: context,
            label: 'Đã đọc',
            selected: filter.isRead == true,
            onSelected: () => onSelectFilter(filter.copyWith(isRead: true)),
          ),
        ],
      ),
    );
  }

  Widget _buildChip({
    required BuildContext context,
    required String label,
    required bool selected,
    required VoidCallback onSelected,
    int? badgeCount,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ChoiceChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected
                  ? Colors.white
                  : (isDark
                      ? AppColors.darkForeground
                      : AppColors.lightForeground),
            ),
          ),
          if (badgeCount != null && badgeCount > 0) ...[
            const SizedBox(width: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: selected
                    ? Colors.white.withValues(alpha: 0.25)
                    : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$badgeCount',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: selected
                      ? Colors.white
                      : (isDark
                          ? AppColors.darkForeground
                          : AppColors.lightForeground),
                ),
              ),
            ),
          ],
        ],
      ),
      selected: selected,
      onSelected: (_) => onSelected(),
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
      showCheckmark: false,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    );
  }
}
