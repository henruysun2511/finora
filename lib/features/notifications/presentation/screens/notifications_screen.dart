import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:finora_mb/app/theme/app_colors.dart';
import 'package:finora_mb/core/widgets/app_toast.dart';
import 'package:finora_mb/core/widgets/page_header.dart';
import '../../domain/models/notification_filter.dart';
import '../../domain/models/notification_item.dart';
import '../providers/notification_list_provider.dart';
import '../widgets/notification_card.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final notificationsAsync = ref.watch(notificationListProvider);
    final filter = ref.watch(notificationFilterProvider);
    final unreadCountAsync = ref.watch(unreadNotificationCountProvider);
    final unreadCount = unreadCountAsync.valueOrNull ?? 0;

    final foreground =
        isDark ? AppColors.darkForeground : AppColors.lightForeground;
    final muted = isDark ? AppColors.darkMuted : AppColors.lightMuted;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: PageHeader.subPage(
        title: 'Thông báo',
        subtitle: unreadCount > 0
            ? 'Bạn có $unreadCount thông báo chưa đọc'
            : 'Tất cả thông báo đã được đọc',
        action: unreadCount > 0
            ? IconButton(
                tooltip: 'Đánh dấu tất cả đã đọc',
                onPressed: () async {
                  await ref
                      .read(notificationListProvider.notifier)
                      .markAllAsRead();
                  if (context.mounted) {
                    AppToast.success(context, 'Đã đánh dấu tất cả là đã đọc');
                  }
                },
                icon: const Icon(
                  Icons.done_all_rounded,
                  color: AppColors.primary,
                ),
              )
            : null,
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () =>
            ref.read(notificationListProvider.notifier).refresh(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            // ── Banner tóm tắt trung tâm thông báo ───────────────────────
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isDark
                      ? AppColors.darkBorder
                      : AppColors.lightBorder,
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
            ),
            const SizedBox(height: 16),

            // ── Bộ lọc Tabs (ChoiceChips theo Quy chuẩn 2 GEMINI.md) ──────
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip(
                    context: context,
                    ref: ref,
                    label: 'Tất cả',
                    selected: filter.isRead == null,
                    onSelected: () {
                      ref.read(notificationFilterProvider.notifier).state =
                          filter.copyWith(clearRead: true);
                    },
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    context: context,
                    ref: ref,
                    label: 'Chưa đọc',
                    selected: filter.isRead == false,
                    badgeCount: unreadCount > 0 ? unreadCount : null,
                    onSelected: () {
                      ref.read(notificationFilterProvider.notifier).state =
                          filter.copyWith(isRead: false);
                    },
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    context: context,
                    ref: ref,
                    label: 'Đã đọc',
                    selected: filter.isRead == true,
                    onSelected: () {
                      ref.read(notificationFilterProvider.notifier).state =
                          filter.copyWith(isRead: true);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Tiêu đề danh sách ─────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Gần đây',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: foreground,
                    ),
                  ),
                ),
                if (unreadCount > 0)
                  TextButton(
                    onPressed: () => ref
                        .read(notificationListProvider.notifier)
                        .markAllAsRead(),
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    child: Text(
                      'Đánh dấu đã đọc',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),

            // ── Danh sách NotificationCard từ Provider ────────────────────
            notificationsAsync.when(
              data: (list) {
                if (list.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 48),
                    child: Column(
                      children: [
                        Icon(
                          Icons.notifications_off_outlined,
                          size: 48,
                          color: muted,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Không có thông báo',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: foreground,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Bạn sẽ nhận được thông báo khi có biến động mới.',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: muted,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  children: list.map((item) {
                    return NotificationCard.fromItem(
                      item: item,
                      onTap: () {
                        if (!item.isRead) {
                          ref
                              .read(notificationListProvider.notifier)
                              .markAsRead(item.id);
                        }
                        if (item.actionUrl != null &&
                            item.actionUrl!.isNotEmpty) {
                          context.push(item.actionUrl!);
                        }
                      },
                      onDelete: () {
                        ref
                            .read(notificationListProvider.notifier)
                            .delete(item.id);
                      },
                    );
                  }).toList(),
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 48),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, _) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 36),
                child: Center(
                  child: Column(
                    children: [
                      const Icon(Icons.error_outline_rounded,
                          size: 40, color: AppColors.danger),
                      const SizedBox(height: 8),
                      Text('Không thể tải thông báo: $err',
                          textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: () => ref
                            .read(notificationListProvider.notifier)
                            .refresh(),
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ChoiceChip tuân thủ nghiêm ngặt Quy chuẩn 2 trong GEMINI.md
  Widget _buildFilterChip({
    required BuildContext context,
    required WidgetRef ref,
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: selected
                    ? Colors.white.withValues(alpha: 0.25)
                    : (isDark
                        ? AppColors.darkBorder
                        : AppColors.lightBorder),
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
