import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/navigation/social_bottom_bar.dart';
import '../../../../core/widgets/navigation/social_tab.dart';
import '../../../../core/widgets/page_header.dart';
import '../../../friends/domain/models/friend.dart';
import '../../../friends/presentation/providers/friends_list_provider.dart';
import '../../domain/models/conversation.dart';
import '../providers/conversation_list_provider.dart';
import '../widgets/conversation_tile.dart';
import 'chat_detail_screen.dart';

class MessagesScreen extends ConsumerStatefulWidget {
  const MessagesScreen({super.key});

  @override
  ConsumerState<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends ConsumerState<MessagesScreen> {
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.darkSurface : Colors.white;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final foreground = isDark ? AppColors.darkForeground : AppColors.lightForeground;
    final muted = isDark ? AppColors.darkMuted : AppColors.lightMuted;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    final convsAsync = ref.watch(conversationListProvider);

    return Scaffold(
      backgroundColor: bg,
      appBar: PageHeader.subPage(
        title: 'Hội thoại',
        subtitle: 'Nhắn tin cùng bạn bè',
        onBack: () => context.go(RoutePaths.feed),
        action: IconButton(
          icon: const Icon(Icons.person_add_rounded, color: AppColors.primary),
          tooltip: 'Tìm bạn mới',
          onPressed: () => context.push(RoutePaths.friends),
        ),
      ),
      body: Column(
        children: [
          // ── Search Bar ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) {
                ref.read(conversationListProvider.notifier).onSearchChanged(v);
                setState(() {});
              },
              decoration: InputDecoration(
                hintText: 'Tìm kiếm cuộc trò chuyện...',
                hintStyle: TextStyle(fontSize: 13.5, color: muted),
                prefixIcon: Icon(Icons.search_rounded, size: 20, color: muted),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear_rounded, size: 18, color: muted),
                        onPressed: () {
                          _searchCtrl.clear();
                          ref.read(conversationListProvider.notifier).onSearchChanged('');
                          setState(() {});
                        },
                      )
                    : null,
                filled: true,
                fillColor: surface,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: border)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: border)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
              ),
            ),
          ),

          // ── Conversation List ──
          Expanded(
            child: convsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(
                child: Text('Không thể tải tin nhắn: $err', style: TextStyle(color: muted)),
              ),
              data: (list) {
                if (list.isEmpty) {
                  return RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: () => ref.read(conversationListProvider.notifier).refresh(),
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(height: MediaQuery.of(context).size.height * 0.18),
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.chat_bubble_outline_rounded, size: 48, color: muted),
                                const SizedBox(height: 12),
                                Text(
                                  'Chưa có cuộc trò chuyện nào',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: foreground),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Bắt đầu nhắn tin với bạn bè hoặc kết bạn ngay!',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 13, color: muted),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () => ref.read(conversationListProvider.notifier).refresh(),
                  child: ListView.separated(
                    padding: const EdgeInsets.only(bottom: 24, top: 4),
                    itemCount: list.length,
                    separatorBuilder: (_, __) => Divider(
                      indent: 76,
                      height: 1,
                      thickness: 0.5,
                      color: border.withValues(alpha: 0.5),
                    ),
                    itemBuilder: (ctx, i) {
                      final conv = list[i];
                      return ConversationTile(
                        conversation: conv,
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatDetailScreen(conversation: conv),
                            ),
                          );
                          if (context.mounted) {
                            ref.read(conversationListProvider.notifier).refresh();
                          }
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        tooltip: 'Soạn tin nhắn mới',
        onPressed: () => _showNewChatBottomSheet(context),
        child: const Icon(Icons.edit_note_rounded, color: Colors.white, size: 28),
      ),
      bottomNavigationBar: const SocialBottomBar(currentTab: SocialTab.messages),
    );
  }

  void _showNewChatBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const _NewChatFriendsSheet(),
    );
  }
}

class _NewChatFriendsSheet extends ConsumerStatefulWidget {
  const _NewChatFriendsSheet();

  @override
  ConsumerState<_NewChatFriendsSheet> createState() => _NewChatFriendsSheetState();
}

class _NewChatFriendsSheetState extends ConsumerState<_NewChatFriendsSheet> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _filter = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surface = isDark ? AppColors.darkSurface : Colors.white;
    final foreground = isDark ? AppColors.darkForeground : AppColors.lightForeground;
    final muted = isDark ? AppColors.darkMuted : AppColors.lightMuted;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    final friendsAsync = ref.watch(friendsListProvider);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 6),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: muted.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 12, 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tin nhắn mới',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: foreground,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Chọn bạn bè để bắt đầu trò chuyện',
                        style: TextStyle(
                          fontSize: 13,
                          color: muted,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close_rounded, color: muted),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Search Box
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _filter = v.trim().toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Tìm kiếm bạn bè...',
                hintStyle: TextStyle(fontSize: 13.5, color: muted),
                prefixIcon: Icon(Icons.search_rounded, size: 20, color: muted),
                suffixIcon: _filter.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear_rounded, size: 18, color: muted),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _filter = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: isDark ? AppColors.darkBackground : const Color(0xFFF8FAFC),
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

          const SizedBox(height: 8),

          // Friends List
          Expanded(
            child: friendsAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
              error: (err, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline_rounded, size: 36, color: muted),
                      const SizedBox(height: 8),
                      Text(
                        'Không thể tải danh sách bạn bè',
                        style: TextStyle(fontSize: 14, color: muted),
                      ),
                    ],
                  ),
                ),
              ),
              data: (state) {
                final allFriends = state.friends;
                if (allFriends.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.people_outline_rounded, size: 48, color: muted),
                          const SizedBox(height: 12),
                          Text(
                            'Chưa có bạn bè nào',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: foreground,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Hãy kết bạn để có thể nhắn tin riêng tư!',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 13, color: muted),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            ),
                            icon: const Icon(Icons.person_add_rounded, size: 18),
                            label: const Text('Tìm bạn ngay', style: TextStyle(fontWeight: FontWeight.w600)),
                            onPressed: () {
                              Navigator.pop(context);
                              context.push(RoutePaths.friends);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final filteredFriends = _filter.isEmpty
                    ? allFriends
                    : allFriends.where((f) {
                        return f.displayName.toLowerCase().contains(_filter) ||
                            f.username.toLowerCase().contains(_filter) ||
                            (f.email?.toLowerCase().contains(_filter) ?? false);
                      }).toList();

                if (filteredFriends.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.search_off_rounded, size: 40, color: muted),
                          const SizedBox(height: 8),
                          Text(
                            'Không tìm thấy bạn bè phù hợp',
                            style: TextStyle(fontSize: 14, color: muted),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  itemCount: filteredFriends.length,
                  separatorBuilder: (_, __) => Divider(
                    indent: 64,
                    height: 1,
                    thickness: 0.5,
                    color: border.withValues(alpha: 0.4),
                  ),
                  itemBuilder: (ctx, i) {
                    final friend = filteredFriends[i];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      leading: CircleAvatar(
                        radius: 22,
                        backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                        backgroundImage: friend.avatar != null && friend.avatar!.isNotEmpty
                            ? NetworkImage(friend.avatar!)
                            : null,
                        child: friend.avatar == null || friend.avatar!.isEmpty
                            ? Text(
                                friend.initials,
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              )
                            : null,
                      ),
                      title: Text(
                        friend.displayName,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: foreground,
                        ),
                      ),
                      subtitle: Text(
                        '@${friend.username}',
                        style: TextStyle(fontSize: 13, color: muted),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.chat_bubble_rounded,
                          size: 18,
                          color: AppColors.primary,
                        ),
                      ),
                      onTap: () async {
                        Navigator.pop(context);
                        await Navigator.push(
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
                        if (context.mounted) {
                          ref.read(conversationListProvider.notifier).refresh();
                        }
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
