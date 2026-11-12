import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/banner_header.dart';
import '../../../../core/widgets/lucide_icon.dart';
import '../../../../core/widgets/navigation/social_bottom_bar.dart';
import '../../../../core/widgets/navigation/social_tab.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../friends/friends.dart';
import '../../../messages/domain/models/conversation.dart';
import '../../../messages/presentation/providers/conversation_list_provider.dart';
import '../../../messages/presentation/providers/messages_providers.dart';
import '../../../messages/presentation/screens/chat_detail_screen.dart';
import '../../domain/models/feed_post.dart';
import '../providers/feed_list_provider.dart';
import '../widgets/feed_category_filter_bar.dart';
import '../widgets/feed_empty_state.dart';
import '../widgets/feed_grid_card.dart';
import '../widgets/feed_post_card.dart';
import '../widgets/feed_search_bar.dart';
import '../widgets/feed_stories_bar.dart';

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'all';
  String? _selectedFriendName;

  static const List<({String key, String label, String icon})> _categories = [
    (key: 'all', label: 'Tất cả', icon: 'sparkles'),
    (key: 'food', label: 'Ăn uống', icon: 'utensils'),
    (key: 'income', label: 'Thu nhập', icon: 'banknote'),
    (key: 'travel', label: 'Du lịch', icon: 'plane'),
    (key: 'coffee', label: 'Cà phê', icon: 'coffee'),
    (key: 'fitness', label: 'Thể thao', icon: 'dumbbell'),
    (key: 'shopping', label: 'Mua sắm', icon: 'shopping-bag'),
  ];

  static const List<List<Color>> _storyGradients = [
    [Color(0xFFF59E0B), Color(0xFFEA580C)],
    [Color(0xFF0072D6), Color(0xFF0284C7)],
    [Color(0xFF10B981), Color(0xFF059669)],
    [Color(0xFFEC4899), Color(0xFFDB2777)],
    [Color(0xFF8B5CF6), Color(0xFF6366F1)],
    [Color(0xFF06B6D4), Color(0xFF0284C7)],
    [Color(0xFFF43F5E), Color(0xFFBE123C)],
  ];

  List<Color> _getStoryGradient(String seed) {
    final hash = seed.hashCode.abs();
    return _storyGradients[hash % _storyGradients.length];
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _sharePost(String title) {
    AppToast.success(context, 'Đã sao chép liên kết bài đăng "$title"');
  }

  void _resetFilter() {
    setState(() {
      _selectedCategory = 'all';
      _selectedFriendName = null;
      _searchController.clear();
      ref.read(feedSearchQueryProvider.notifier).state = '';
    });
  }

  Widget _buildHeaderButton({
    required String iconName,
    required VoidCallback onTap,
    String? tooltip,
  }) {
    final btn = Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: LucideIcon(
        name: iconName,
        size: 18,
        color: Colors.white,
        strokeWidth: 2.2,
      ),
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: tooltip != null ? Tooltip(message: tooltip, child: btn) : btn,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final bg = dark ? AppColors.darkBackground : AppColors.lightBackground;
    final foreground =
        dark ? AppColors.darkForeground : AppColors.lightForeground;
    final muted = dark ? AppColors.darkMuted : AppColors.lightMuted;

    final searchQuery = ref.watch(feedSearchQueryProvider);
    final feedAsync = ref.watch(feedListProvider);
    final friendsAsync = ref.watch(friendsListProvider);
    final viewMode = ref.watch(feedViewModeProvider);

    final friends = friendsAsync.value?.friends ?? const [];
    final stories = friends.map((f) {
      final name = f.fullName.isNotEmpty ? f.fullName : f.displayName;
      return FeedStoryItem(
        id: f.id,
        name: name,
        initials: f.initials,
        avatar: f.avatar,
        gradient: _getStoryGradient(f.id.isNotEmpty ? f.id : name),
        isSeen: true,
      );
    }).toList();

    return Scaffold(
      backgroundColor: bg,
      body: Column(
        children: [
          // ── Banner Header Hero theo chuẩn .acc-hero (không subtitle, nút màu xanh hệ thống không outline) ──
          BannerHeader(
            title: 'Bảng tin tài chính',
            subtitle: null,
            leading: _buildHeaderButton(
              iconName: 'arrow-left',
              onTap: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go(RoutePaths.home);
                }
              },
              tooltip: 'Quay lại',
            ),
            showBackButton: false,
            gradient: const LinearGradient(
              colors: [
                Color(0xFF0F4B92),
                AppColors.primary,
                Color(0xFF0284C7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            child: FeedStoriesBar(
              stories: stories,
              isLoading: friendsAsync.isLoading,
              selectedFriendName: _selectedFriendName,
              onFriendSelected: (friend) {
                setState(() => _selectedFriendName = friend);
              },
              onAddBill: () => context.push(RoutePaths.createTransaction),
              onAddFriend: () => context.push(RoutePaths.friends),
            ),
          ),

          // ── Thanh Tìm kiếm ngay trên phần lọc ──
          FeedSearchBar(
            controller: _searchController,
            onChanged: (val) {
              ref.read(feedSearchQueryProvider.notifier).state = val.trim();
            },
            onClear: () {
              _searchController.clear();
              ref.read(feedSearchQueryProvider.notifier).state = '';
            },
          ),

          // ── Category Filter Chips (.filter-scroll) ──
          FeedCategoryFilterBar(
            categories: _categories,
            selectedCategory: _selectedCategory,
            onCategorySelected: (catKey) {
              setState(() => _selectedCategory = catKey);
            },
          ),

          // ── Active Friend Filter Badge Indicator ──
          if (_selectedFriendName != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const LucideIcon(
                          name: 'user',
                          size: 14,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Đang lọc theo: $_selectedFriendName',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 6),
                        InkWell(
                          onTap: () {
                            setState(() => _selectedFriendName = null);
                          },
                          child: const LucideIcon(
                            name: 'x',
                            size: 14,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // ── Feed Post List ──
          Expanded(
            child: feedAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (err, stack) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const LucideIcon(
                        name: 'alert-circle',
                        size: 48,
                        color: Colors.redAccent,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Không thể tải Bảng tin',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: foreground,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        err.toString(),
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: muted),
                      ),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                        ),
                        onPressed: () {
                          ref.read(feedListProvider.notifier).refresh();
                          ref.read(friendsListProvider.notifier).refresh();
                        },
                        icon: const LucideIcon(
                          name: 'refresh-cw',
                          size: 16,
                          color: Colors.white,
                        ),
                        label: const Text('Thử lại'),
                      ),
                    ],
                  ),
                ),
              ),
              data: (posts) {
                final filtered = posts.where((p) {
                  // Friend filter
                  if (_selectedFriendName != null &&
                      p.author.displayName != _selectedFriendName &&
                      p.author.fullName != _selectedFriendName) {
                    return false;
                  }

                  // Category filter
                  if (_selectedCategory != 'all') {
                    final catName = (p.category?.name ?? '').toLowerCase();
                    final pName = p.name.toLowerCase();
                    final match = switch (_selectedCategory) {
                      'food' => catName.contains('ăn') ||
                          pName.contains('bún') ||
                          pName.contains('phở'),
                      'income' =>
                        catName.contains('thu') || pName.contains('lương'),
                      'travel' => catName.contains('du lịch') ||
                          pName.contains('đà lạt') ||
                          pName.contains('vé'),
                      'coffee' => catName.contains('cà phê') ||
                          pName.contains('coffee') ||
                          pName.contains('brew'),
                      'fitness' =>
                        catName.contains('thể thao') || pName.contains('gym'),
                      'shopping' =>
                        catName.contains('sắm') || pName.contains('mua'),
                      _ => true,
                    };
                    if (!match) return false;
                  }

                  // Search query filter
                  if (searchQuery.isNotEmpty) {
                    final query = searchQuery.toLowerCase();
                    final matchAuthor =
                        p.author.displayName.toLowerCase().contains(query);
                    final matchName = p.name.toLowerCase().contains(query);
                    final matchNote =
                        (p.note ?? '').toLowerCase().contains(query);
                    final matchLocation =
                        (p.locationName ?? '').toLowerCase().contains(query);
                    if (!matchAuthor &&
                        !matchName &&
                        !matchNote &&
                        !matchLocation) {
                      return false;
                    }
                  }

                  return true;
                }).toList();

                if (filtered.isEmpty) {
                  return FeedEmptyState(onResetFilter: _resetFilter);
                }

                return RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () async {
                    await Future.wait<void>([
                      ref.read(feedListProvider.notifier).refresh(),
                      ref.read(friendsListProvider.notifier).refresh(),
                    ]);
                  },
                  child: viewMode == FeedViewMode.grid
                      ? GridView.builder(
                          padding: const EdgeInsets.fromLTRB(10, 6, 10, 24),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 6,
                            mainAxisSpacing: 6,
                            childAspectRatio: 1.0,
                          ),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final post = filtered[index];
                            return FeedGridCard(
                              post: post,
                              onTap: () => _showPostDetailModal(context, post),
                            );
                          },
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.only(bottom: 24, top: 4),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final post = filtered[index];
                            return FeedPostCard(
                              post: post,
                              onToggleReaction: ({emoji, symbol, label}) {
                                ref
                                    .read(feedListProvider.notifier)
                                    .toggleReaction(
                                      post.id,
                                      emoji: emoji,
                                      symbol: symbol,
                                      label: label,
                                    );
                              },
                              onFetchReactions: () {
                                return ref
                                    .read(feedListProvider.notifier)
                                    .getReactions(post.id);
                              },
                              onUpdatePost: ({amountHidden, note}) {
                                ref.read(feedListProvider.notifier).updatePost(
                                      transactionId: post.id,
                                      amountHidden: amountHidden,
                                      note: note,
                                    );
                              },
                              onChatWithAuthor: () => _handleChatWithAuthor(post),
                              onShare: () {
                                _sharePost(post.name);
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
      bottomNavigationBar: SocialBottomBar(
        currentTab: viewMode == FeedViewMode.grid
            ? SocialTab.feedGrid
            : SocialTab.feed,
      ),
    );
  }

  /// Hiển thị Bottom Sheet chi tiết bài đăng khi chạm vào ô vuông trong chế độ Lưới
  void _showPostDetailModal(BuildContext context, FeedPost initialPost) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Consumer(
          builder: (context, ref, _) {
            final posts = ref.watch(feedListProvider).value ?? [];
            final currentPost = posts.firstWhere(
              (p) => p.id == initialPost.id,
              orElse: () => initialPost,
            );

            final isDark = Theme.of(context).brightness == Brightness.dark;
            final bg = isDark ? AppColors.darkSurface : Colors.white;

            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.88,
              ),
              decoration: BoxDecoration(
                color: bg,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: FeedPostCard(
                        post: currentPost,
                        onToggleReaction: ({emoji, symbol, label}) {
                          ref
                              .read(feedListProvider.notifier)
                              .toggleReaction(
                                currentPost.id,
                                emoji: emoji,
                                symbol: symbol,
                                label: label,
                              );
                        },
                        onFetchReactions: () {
                          return ref
                              .read(feedListProvider.notifier)
                              .getReactions(currentPost.id);
                        },
                        onUpdatePost: ({amountHidden, note}) {
                          ref.read(feedListProvider.notifier).updatePost(
                                transactionId: currentPost.id,
                                amountHidden: amountHidden,
                                note: note,
                              );
                        },
                        onChatWithAuthor: () {
                          Navigator.pop(ctx);
                          _handleChatWithAuthor(currentPost);
                        },
                        onShare: () {
                          _sharePost(currentPost.name);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _handleChatWithAuthor(FeedPost post) {
    final currentUserId = ref.read(authNotifierProvider).value?.id;
    if (currentUserId != null && currentUserId == post.author.id) {
      AppToast.info(context, 'Không thể gửi tin nhắn cho chính mình');
      return;
    }

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _FeedPostReplySheet(post: post),
    );
  }
}

class _FeedPostReplySheet extends ConsumerStatefulWidget {
  const _FeedPostReplySheet({required this.post});
  final FeedPost post;

  @override
  ConsumerState<_FeedPostReplySheet> createState() => _FeedPostReplySheetState();
}

class _FeedPostReplySheetState extends ConsumerState<_FeedPostReplySheet> {
  final TextEditingController _replyCtrl = TextEditingController();
  bool _isSending = false;

  @override
  void dispose() {
    _replyCtrl.dispose();
    super.dispose();
  }

  String _formatAmount(num? amount) {
    if (amount == null) return '0';
    if (amount >= 1000000) {
      final val = amount / 1000000;
      return '${val.toStringAsFixed(val.truncateToDouble() == val ? 0 : 1)}tr';
    }
    if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}k';
    }
    return amount.toStringAsFixed(0);
  }

  Future<void> _sendReply() async {
    final text = _replyCtrl.text.trim();
    if (text.isEmpty) {
      AppToast.warning(context, 'Vui lòng nhập nội dung tin nhắn');
      return;
    }

    setState(() => _isSending = true);

    try {
      final repo = ref.read(messagesRepositoryProvider);
      await repo.sendMessage(
        conversationId: widget.post.author.id,
        content: text,
        relatedTransactionId: widget.post.id,
      );
      ref.invalidate(conversationListProvider);

      if (mounted) {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatDetailScreen(
              conversation: Conversation(
                id: widget.post.author.id,
                title: widget.post.author.fullName,
                avatar: widget.post.author.avatar,
                lastMessageContent: text,
                lastMessageAt: DateTime.now(),
              ),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSending = false);
        AppToast.error(
          context,
          'Gửi tin nhắn thất bại: ${AppToast.extractErrorMessage(e)}',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.darkSurface : Colors.white;
    final foreground = isDark ? AppColors.darkForeground : AppColors.lightForeground;
    final muted = isDark ? AppColors.darkMuted : AppColors.lightMuted;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    final post = widget.post;
    final hasPhoto = post.photoUrl != null && post.photoUrl!.isNotEmpty;
    final viewInsets = MediaQuery.of(context).viewInsets;

    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.85,
        ),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            // Handle Bar
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 10, bottom: 8),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: muted.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Author Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 12, 10),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                    backgroundImage: post.author.avatar != null && post.author.avatar!.isNotEmpty
                        ? NetworkImage(post.author.avatar!)
                        : null,
                    child: post.author.avatar == null || post.author.avatar!.isEmpty
                        ? Text(
                            post.author.fullName.isNotEmpty
                                ? post.author.fullName.substring(0, 1).toUpperCase()
                                : 'U',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Nhắn tin cho ${post.author.fullName}',
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            color: foreground,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Phản hồi bài đăng khoảnh khắc',
                          style: TextStyle(fontSize: 11.5, color: muted),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close_rounded, size: 20, color: muted),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Mini Post Preview Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkBackground : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: border),
                ),
                child: Row(
                  children: [
                    if (hasPhoto)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          post.photoUrl!,
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 48,
                            height: 48,
                            color: AppColors.primary.withValues(alpha: 0.1),
                            child: const Icon(Icons.receipt_long_rounded, color: AppColors.primary),
                          ),
                        ),
                      )
                    else
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.receipt_long_rounded, color: AppColors.primary),
                      ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            post.name,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: foreground,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Text(
                                post.isAmountHidden
                                    ? '••••••'
                                    : '${_formatAmount(post.amount)}đ',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary,
                                ),
                              ),
                              if (post.category != null) ...[
                                const SizedBox(width: 6),
                                Text(
                                  '· ${post.category!.name}',
                                  style: TextStyle(fontSize: 11, color: muted),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Input Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _replyCtrl,
                      autofocus: true,
                      minLines: 1,
                      maxLines: 4,
                      style: TextStyle(fontSize: 14, color: foreground),
                      decoration: InputDecoration(
                        hintText: 'Nhập tin nhắn phản hồi...',
                        hintStyle: TextStyle(fontSize: 13.5, color: muted),
                        filled: true,
                        fillColor: isDark ? AppColors.darkBackground : const Color(0xFFF1F5F9),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide(color: border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide(color: border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _isSending ? null : _sendReply,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: _isSending
                          ? const Center(
                              child: SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              ),
                            )
                          : const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                    ),
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
}

/// Typedef để duy trì khả năng tương thích ngược
typedef SocialFeedScreen = FeedScreen;
