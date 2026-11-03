import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:finora_mb/app/theme/app_colors.dart';
import 'package:finora_mb/features/notifications/presentation/widgets/notification_card.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  int _selectedFilter = 0;

  final List<Map<String, dynamic>> _notifications = [
    {
      'title': 'Sắp vượt ngân sách!',
      'message': 'Bạn đã sử dụng 90% ngân sách ăn uống trong tháng này.',
      'time': '10 phút trước',
      'icon': Icons.account_balance_wallet_rounded,
      'isRead': false,
    },
    {
      'title': 'Khoản nợ sắp đến hạn',
      'message': 'Bạn có một khoản thanh toán cần chú ý.',
      'time': '2 giờ trước',
      'icon': Icons.event_note_rounded,
      'isRead': false,
    },
    {
      'title': 'Bí quyết quản lý chi tiêu',
      'message': 'Khám phá cách tiết kiệm và quản lý tài chính hiệu quả.',
      'time': 'Hôm qua',
      'icon': Icons.auto_stories_rounded,
      'isRead': true,
    },
  ];

  void _markAllAsRead() {
    setState(() {
      for (final item in _notifications) {
        item['isRead'] = true;
      }
    });
  }

  void _markAsRead(Map<String, dynamic> item) {
    setState(() {
      item['isRead'] = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final foreground =
        isDark ? AppColors.darkForeground : AppColors.lightForeground;

    final muted = isDark ? AppColors.darkMuted : AppColors.lightMuted;

    final unreadCount =
        _notifications.where((item) => item['isRead'] == false).length;

    final filteredNotifications = _notifications.where((item) {
      if (_selectedFilter == 1) {
        return item['isRead'] == false;
      }
      if (_selectedFilter == 2) {
        return item['isRead'] == true;
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'Thông báo',
          style: GoogleFonts.inter(
            fontSize: 21,
            fontWeight: FontWeight.w800,
            color: foreground,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Đánh dấu tất cả đã đọc',
            onPressed: unreadCount > 0 ? _markAllAsRead : null,
            icon: Icon(
              Icons.done_all_rounded,
              color: unreadCount > 0 ? AppColors.primary : muted,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(
                  alpha: isDark ? 0.16 : 0.09,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CẬP NHẬT MỚI NHẤT',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            letterSpacing: 1.1,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 9),
                        Text(
                          unreadCount == 0
                              ? 'Bạn đã xem hết thông báo'
                              : 'Bạn có $unreadCount thông báo mới',
                          style: GoogleFonts.inter(
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                            color: foreground,
                          ),
                        ),
                        const SizedBox(height: 9),
                        Text(
                          'Theo dõi ngân sách, khoản nợ và tin tức tài chính của bạn.',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            height: 1.5,
                            color: muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(
                        alpha: 0.13,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.notifications_active_rounded,
                      color: AppColors.primary,
                      size: 29,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _filterChip('Tất cả', 0, isDark),
                  _filterChip('Chưa đọc', 1, isDark),
                  _filterChip('Đã đọc', 2, isDark),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Gần đây',
                    style: GoogleFonts.inter(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: foreground,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: unreadCount > 0 ? _markAllAsRead : null,
                  child: Text(
                    'Đánh dấu đã đọc',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (filteredNotifications.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 55),
                child: Column(
                  children: [
                    Icon(
                      Icons.notifications_off_outlined,
                      size: 50,
                      color: muted,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Không có thông báo',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: foreground,
                      ),
                    ),
                  ],
                ),
              )
            else
              ...filteredNotifications.map(
                (item) => NotificationCard(
                  title: item['title'] as String,
                  message: item['message'] as String,
                  time: item['time'] as String,
                  icon: item['icon'] as IconData,
                  isRead: item['isRead'] as bool,
                  onTap: () => _markAsRead(item),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String label, int index, bool isDark) {
    final selected = _selectedFilter == index;

    return Padding(
      padding: const EdgeInsets.only(right: 9),
      child: ChoiceChip(
        label: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected
                ? Colors.white
                : (isDark
                    ? AppColors.darkForeground
                    : AppColors.lightForeground),
          ),
        ),
        selected: selected,
        onSelected: (_) {
          setState(() {
            _selectedFilter = index;
          });
        },
        selectedColor: AppColors.primary,
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        showCheckmark: false,
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 9,
        ),
      ),
    );
  }
}
