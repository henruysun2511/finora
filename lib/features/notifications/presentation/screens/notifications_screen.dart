import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/page_header.dart';
import '../../wallets/presentation/providers/wallet_detail_provider.dart';
import '../../wallets/presentation/providers/wallets_overview_provider.dart';
import '../../domain/models/notification_type.dart';
import '../providers/notification_list_provider.dart';
import '../widgets/notification_banner_hero.dart';
import '../widgets/notification_card.dart';
import '../widgets/notification_empty_state.dart';
import '../widgets/notification_filter_tabs.dart';

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
            NotificationBannerHero(unreadCount: unreadCount),
            const SizedBox(height: 16),

            // ── Bộ lọc Tabs ──────
            NotificationFilterTabs(
              filter: filter,
              unreadCount: unreadCount,
              onSelectFilter: (newFilter) {
                ref.read(notificationFilterProvider.notifier).state = newFilter;
              },
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
                  return const NotificationEmptyState();
                }

                return Column(
                  children: list.map((item) {
                    final isWalletInvite =
                        item.type == NotificationType.walletInvite &&
                            !item.isRead;
                    final walletId = item.relatedEntityId ??
                        item.metadata?['walletId']?.toString();

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
                      onAccept: isWalletInvite && walletId != null
                          ? () async {
                              try {
                                await ref
                                    .read(walletDetailActionsProvider(walletId))
                                    .acceptInvite();
                                await ref
                                    .read(notificationListProvider.notifier)
                                    .markAsRead(item.id);
                                ref.invalidate(walletsOverviewProvider);
                                if (context.mounted) {
                                  AppToast.success(
                                    context,
                                    'Đã chấp nhận tham gia quỹ nhóm!',
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  AppToast.error(context, e.toString());
                                }
                              }
                            }
                          : null,
                      onReject: isWalletInvite && walletId != null
                          ? () async {
                              try {
                                await ref
                                    .read(walletDetailActionsProvider(walletId))
                                    .rejectInvite();
                                await ref
                                    .read(notificationListProvider.notifier)
                                    .markAsRead(item.id);
                                if (context.mounted) {
                                  AppToast.info(
                                    context,
                                    'Đã từ chối lời mời tham gia quỹ',
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  AppToast.error(context, e.toString());
                                }
                              }
                            }
                          : null,
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
}
