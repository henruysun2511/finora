import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../features/feed/presentation/providers/feed_list_provider.dart';
import '../../../features/friends/presentation/providers/friends_list_provider.dart';
import '../../../features/messages/presentation/providers/conversation_list_provider.dart';
import 'social_tab.dart';
import 'social_tab_item.dart';

class SocialBottomBar extends ConsumerWidget {
  const SocialBottomBar({
    super.key,
    required this.currentTab,
    this.onTabSelected,
    this.unreadMessagesCount = 0,
    this.friendRequestsCount = 0,
  });

  final SocialTab currentTab;
  final void Function(SocialTab tab)? onTabSelected;
  final int unreadMessagesCount;
  final int friendRequestsCount;

  void _handleTabTap(BuildContext context, WidgetRef ref, SocialTab tab) {
    if (tab == SocialTab.feed) {
      ref.read(feedViewModeProvider.notifier).state = FeedViewMode.list;
    } else if (tab == SocialTab.feedGrid) {
      ref.read(feedViewModeProvider.notifier).state = FeedViewMode.grid;
    }

    if (tab == currentTab) return;

    if (onTabSelected != null) {
      onTabSelected!(tab);
    } else {
      context.go(tab.routePath);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.darkSurface : Colors.white;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    final effectiveFriendRequestsCount = friendRequestsCount > 0
        ? friendRequestsCount
        : (ref.watch(friendsListProvider).valueOrNull?.pendingRequests.length ?? 0);

    final effectiveUnreadMessagesCount = unreadMessagesCount > 0
        ? unreadMessagesCount
        : (ref.watch(conversationListProvider).valueOrNull?.fold<int>(
                0, (sum, c) => sum + (c.unreadCount > 0 ? c.unreadCount : 0)) ??
            0);

    return Container(
      decoration: BoxDecoration(
        color: surface,
        border: Border(
          top: BorderSide(color: border, width: 1.0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
            blurRadius: 16,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 54,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              SocialTabItem(
                tab: SocialTab.feed,
                isSelected: currentTab == SocialTab.feed,
                onTap: () => _handleTabTap(context, ref, SocialTab.feed),
              ),
              SocialTabItem(
                tab: SocialTab.feedGrid,
                isSelected: currentTab == SocialTab.feedGrid,
                onTap: () => _handleTabTap(context, ref, SocialTab.feedGrid),
              ),
              SocialTabItem(
                tab: SocialTab.friends,
                isSelected: currentTab == SocialTab.friends,
                badgeCount: effectiveFriendRequestsCount,
                onTap: () => _handleTabTap(context, ref, SocialTab.friends),
              ),
              SocialTabItem(
                tab: SocialTab.splitBill,
                isSelected: currentTab == SocialTab.splitBill,
                onTap: () => _handleTabTap(context, ref, SocialTab.splitBill),
              ),
              SocialTabItem(
                tab: SocialTab.messages,
                isSelected: currentTab == SocialTab.messages,
                badgeCount: effectiveUnreadMessagesCount,
                onTap: () => _handleTabTap(context, ref, SocialTab.messages),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
