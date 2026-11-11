import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/navigation/social_bottom_bar.dart';
import '../../../../core/widgets/navigation/social_tab.dart';
import '../../../../core/widgets/page_header.dart';
import '../../../messages/domain/models/conversation.dart';
import '../../../messages/presentation/screens/chat_detail_screen.dart';
import '../../domain/models/friend.dart';
import '../../domain/models/friend_request.dart';
import '../../domain/models/user_search_result.dart';
import '../providers/friends_list_provider.dart';
import '../widgets/friend_card.dart';
import '../widgets/friend_request_card.dart';
import '../widgets/friends_empty_state.dart';
import '../widgets/user_search_card.dart';

class FriendsListScreen extends ConsumerStatefulWidget {
  const FriendsListScreen({super.key});

  @override
  ConsumerState<FriendsListScreen> createState() => _FriendsListScreenState();
}

class _FriendsListScreenState extends ConsumerState<FriendsListScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final TextEditingController _friendFilterCtrl = TextEditingController();
  final TextEditingController _searchCtrl = TextEditingController();
  String _friendFilter = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _friendFilterCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  String _formatError(dynamic e) {
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map && data['message'] != null) {
        final msg = data['message'];
        if (msg is List && msg.isNotEmpty) return msg.join(', ');
        return msg.toString();
      }
    }
    return e?.toString() ?? 'Đã có lỗi xảy ra';
  }

  // ── Actions ───────────────────────────────────────────────────────────────────

  Future<void> _confirmUnfriend(BuildContext ctx, Friend friend) async {
    final confirmed = await showConfirmDialog(
      ctx,
      title: 'Hủy kết bạn',
      message:
          'Bạn có chắc muốn hủy kết bạn với ${friend.displayName}?\nHành động này không thể hoàn tác.',
      confirmText: 'Hủy kết bạn',
      icon: Icons.person_remove_rounded,
    );
    if (confirmed && ctx.mounted) {
      try {
        await ref
            .read(friendsListProvider.notifier)
            .removeFriend(friend.friendshipId, targetUserId: friend.userId);
        if (ctx.mounted) {
          AppToast.success(ctx, 'Đã hủy kết bạn với ${friend.displayName}');
        }
      } catch (e) {
        if (ctx.mounted) {
          AppToast.error(ctx, 'Hủy kết bạn thất bại: ${_formatError(e)}');
        }
      }
    }
  }

  Future<void> _confirmBlock(BuildContext ctx, Friend friend) async {
    final confirmed = await showConfirmDialog(
      ctx,
      title: 'Chặn người dùng',
      message:
          'Bạn có chắc muốn chặn ${friend.displayName}?\nSau khi chặn, người này sẽ không thể gửi tin nhắn hoặc kết nối với bạn.',
      confirmText: 'Chặn',
      icon: Icons.block_rounded,
    );
    if (confirmed && ctx.mounted) {
      try {
        await ref.read(friendsListProvider.notifier).blockUser(friend.userId);
        if (ctx.mounted) {
          AppToast.success(ctx, 'Đã chặn ${friend.displayName}');
        }
      } catch (e) {
        if (ctx.mounted) {
          AppToast.error(ctx, 'Chặn người dùng thất bại: ${_formatError(e)}');
        }
      }
    }
  }

  Future<void> _acceptRequest(BuildContext ctx, FriendRequest req) async {
    try {
      await ref.read(friendsListProvider.notifier).acceptRequest(req.friendshipId);
      if (ctx.mounted) {
        AppToast.success(ctx, 'Đã kết bạn với ${req.displayName} 🎉');
      }
    } catch (e) {
      if (ctx.mounted) {
        AppToast.error(ctx, 'Không thể chấp nhận kết bạn: ${_formatError(e)}');
      }
    }
  }

  Future<void> _rejectRequest(BuildContext ctx, FriendRequest req) async {
    try {
      await ref.read(friendsListProvider.notifier).rejectRequest(req.friendshipId);
      if (ctx.mounted) {
        AppToast.info(ctx, 'Đã từ chối lời mời từ ${req.displayName}');
      }
    } catch (e) {
      if (ctx.mounted) {
        AppToast.error(ctx, 'Từ chối lời mời thất bại: ${_formatError(e)}');
      }
    }
  }

  Future<void> _cancelSentRequest(BuildContext ctx, FriendRequest req) async {
    try {
      await ref.read(friendsListProvider.notifier).rejectRequest(req.friendshipId);
      if (ctx.mounted) {
        AppToast.info(ctx, 'Đã hủy lời mời gửi tới ${req.displayName}');
      }
    } catch (e) {
      if (ctx.mounted) {
        AppToast.error(ctx, 'Hủy lời mời thất bại: ${_formatError(e)}');
      }
    }
  }

  Future<void> _sendRequest(BuildContext ctx, UserSearchResult user) async {
    try {
      await ref.read(friendsListProvider.notifier).sendRequest(user.userId);
      if (ctx.mounted) {
        AppToast.success(ctx, 'Đã gửi lời mời kết bạn tới ${user.displayName} ✉️');
      }
    } catch (e) {
      if (ctx.mounted) {
        AppToast.error(ctx, 'Gửi lời mời kết bạn thất bại: ${_formatError(e)}');
      }
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surface = isDark ? AppColors.darkSurface : Colors.white;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final foreground = isDark ? AppColors.darkForeground : AppColors.lightForeground;
    final muted = isDark ? AppColors.darkMuted : AppColors.lightMuted;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    final friendsAsync = ref.watch(friendsListProvider);
    final pendingCount = friendsAsync.value?.pendingRequests.length ?? 0;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: bg,
        appBar: PageHeader.subPage(
          title: 'Bạn bè & Kết nối',
          subtitle: 'Quản lý kết nối Finora',
          onBack: () => context.go(RoutePaths.feed),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48),
            child: Container(
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: border, width: 1)),
              ),
              child: TabBar(
                labelColor: AppColors.primary,
                unselectedLabelColor: muted,
                indicatorColor: AppColors.primary,
                indicatorWeight: 2.5,
                labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                tabs: [
                  const Tab(text: 'Bạn bè'),
                  Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Lời mời'),
                        if (pendingCount > 0) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: AppColors.danger,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '$pendingCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const Tab(text: 'Tìm bạn'),
                ],
              ),
            ),
          ),
        ),
        body: friendsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => _buildErrorState(context, foreground, muted),
          data: (state) => TabBarView(
            children: [
              _buildFriendsTab(context, state.friends, surface, foreground, muted, border),
              _buildRequestsTab(context, state.pendingRequests, state.sentRequests, foreground, muted),
              _buildSearchTab(context, state, surface, bg, foreground, muted, border),
            ],
          ),
        ),
        bottomNavigationBar: const SocialBottomBar(currentTab: SocialTab.friends),
      ),
    );
  }

  // ── Tab 1: Danh sách bạn bè ───────────────────────────────────────────────────

  Widget _buildFriendsTab(
    BuildContext context,
    List<Friend> friends,
    Color surface,
    Color foreground,
    Color muted,
    Color border,
  ) {
    final filtered = _friendFilter.isEmpty
        ? friends
        : friends.where((f) {
            final q = _friendFilter.toLowerCase();
            return f.displayName.toLowerCase().contains(q) ||
                f.username.toLowerCase().contains(q) ||
                (f.email?.toLowerCase().contains(q) ?? false);
          }).toList();

    return Column(
      children: [
        // Search bar lọc local
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            controller: _friendFilterCtrl,
            onChanged: (v) => setState(() => _friendFilter = v.trim()),
            decoration: InputDecoration(
              hintText: 'Lọc nhanh theo tên hoặc email...',
              hintStyle: TextStyle(fontSize: 13.5, color: muted),
              prefixIcon: Icon(Icons.search_rounded, size: 20, color: muted),
              suffixIcon: _friendFilter.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear_rounded, size: 18, color: muted),
                      onPressed: () {
                        _friendFilterCtrl.clear();
                        setState(() => _friendFilter = '');
                      },
                    )
                  : null,
              filled: true,
              fillColor: surface,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
              ),
            ),
          ),
        ),

        // Đếm số lượng
        if (friends.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Text(
                  '${filtered.length} bạn bè${_friendFilter.isNotEmpty ? ' (đang lọc)' : ''}',
                  style: TextStyle(fontSize: 12, color: muted, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),

        // Danh sách
        Expanded(
          child: filtered.isEmpty
              ? FriendsEmptyState(
                  icon: Icons.people_outline_rounded,
                  title: _friendFilter.isNotEmpty ? 'Không tìm thấy bạn bè' : 'Chưa có bạn bè nào',
                  description: _friendFilter.isNotEmpty
                      ? 'Thử tìm kiếm với từ khóa khác.'
                      : 'Chuyển sang tab "Tìm bạn" để kết nối với bạn bè trên Finora.',
                  actionLabel: _friendFilter.isNotEmpty ? 'Xóa bộ lọc' : null,
                  onAction: _friendFilter.isNotEmpty
                      ? () {
                          _friendFilterCtrl.clear();
                          setState(() => _friendFilter = '');
                        }
                      : null,
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 24, top: 4),
                  itemCount: filtered.length,
                  itemBuilder: (ctx, i) {
                    final friend = filtered[i];
                    return FriendCard(
                      friend: friend,
                      onChat: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatDetailScreen(
                              conversation: Conversation(
                                id: friend.userId,
                                title: friend.displayName,
                                avatar: friend.avatar,
                                lastMessageContent: '',
                                lastMessageAt: DateTime.now(),
                              ),
                            ),
                          ),
                        );
                      },
                      onUnfriend: () => _confirmUnfriend(context, friend),
                      onBlock: () => _confirmBlock(context, friend),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // ── Tab 2: Lời mời kết bạn ───────────────────────────────────────────────────

  Widget _buildRequestsTab(
    BuildContext context,
    List<FriendRequest> pending,
    List<FriendRequest> sent,
    Color foreground,
    Color muted,
  ) {
    if (pending.isEmpty && sent.isEmpty) {
      return const FriendsEmptyState(
        icon: Icons.mail_outline_rounded,
        title: 'Không có lời mời nào',
        description: 'Lời mời kết bạn nhận được và đã gửi sẽ hiển thị ở đây.',
      );
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        // ── Lời mời nhận được ──
        if (pending.isNotEmpty) ...[
          _buildSectionHeader('Lời mời nhận được', pending.length),
          ...pending.map((req) => FriendRequestCard(
                request: req,
                onAccept: () => _acceptRequest(context, req),
                onReject: () => _rejectRequest(context, req),
              )),
        ],

        // ── Đã gửi ──
        if (sent.isNotEmpty) ...[
          _buildSectionHeader('Đã gửi', sent.length),
          ...sent.map((req) => FriendRequestCard(
                request: req,
                isSent: true,
                onCancel: () => _cancelSentRequest(context, req),
              )),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Row(
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1.5),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Tab 3: Tìm bạn ───────────────────────────────────────────────────────────

  Widget _buildSearchTab(
    BuildContext context,
    FriendsListState state,
    Color surface,
    Color bg,
    Color foreground,
    Color muted,
    Color border,
  ) {
    return Column(
      children: [
        // Search input
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
          child: TextField(
            controller: _searchCtrl,
            onChanged: (v) => ref.read(friendsListProvider.notifier).search(v),
            decoration: InputDecoration(
              hintText: 'Nhập email hoặc tên để tìm bạn...',
              hintStyle: TextStyle(fontSize: 14, color: muted),
              prefixIcon: const Icon(Icons.person_search_rounded, size: 22, color: AppColors.primary),
              suffixIcon: _searchCtrl.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear_rounded, size: 18, color: muted),
                      onPressed: () {
                        _searchCtrl.clear();
                        ref.read(friendsListProvider.notifier).search('');
                      },
                    )
                  : null,
              filled: true,
              fillColor: surface,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.primary, width: 2),
              ),
            ),
          ),
        ),

        // Trạng thái loading search
        if (state.isSearching)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                ),
                const SizedBox(width: 10),
                Text('Đang tìm kiếm...', style: TextStyle(fontSize: 13, color: muted)),
              ],
            ),
          ),

        // Kết quả tìm kiếm
        Expanded(
          child: state.searchQuery.isEmpty
              ? const FriendsEmptyState(
                  icon: Icons.person_search_rounded,
                  title: 'Tìm kiếm bạn bè',
                  description: 'Nhập tên, email hoặc số điện thoại để tìm kiếm người dùng Finora.',
                )
              : state.searchResults.isEmpty && !state.isSearching
                  ? FriendsEmptyState(
                      icon: Icons.search_off_rounded,
                      title: 'Không tìm thấy "${state.searchQuery}"',
                      description: 'Thử tìm bằng email hoặc số điện thoại chính xác hơn.',
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 32),
                      itemCount: state.searchResults.length,
                      itemBuilder: (ctx, i) {
                        final user = state.searchResults[i];
                        return UserSearchCard(
                          user: user,
                          onSendRequest: () => _sendRequest(context, user),
                          onAcceptRequest: () => _acceptRequest(
                            context,
                            FriendRequest(
                              friendshipId: user.friendshipId ?? '',
                              requesterId: user.userId,
                              requesterName: user.fullName,
                              requesterUsername: user.username,
                              requesterAvatar: user.avatar,
                              requestedAt: DateTime.now(),
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildErrorState(BuildContext context, Color foreground, Color muted) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, size: 56, color: AppColors.danger),
            const SizedBox(height: 16),
            Text('Không thể tải dữ liệu', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: foreground)),
            const SizedBox(height: 8),
            Text('Kiểm tra kết nối mạng và thử lại.', style: TextStyle(fontSize: 13, color: muted)),
            const SizedBox(height: 20),
            FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: () => ref.invalidate(friendsListProvider),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }
}
