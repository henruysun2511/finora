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
import '../../../friends/friends.dart';
import '../../domain/models/feed_post.dart';
import '../providers/feed_list_provider.dart';
import '../widgets/comments_bottom_sheet.dart';
import '../widgets/feed_category_filter_bar.dart';
import '../widgets/feed_empty_state.dart';
import '../widgets/feed_grid_card.dart';
import '../widgets/feed_post_card.dart';
import '../widgets/feed_search_bar.dart';
import '../widgets/feed_stories_bar.dart';
import '../widgets/share_milestone_sheet.dart';

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
            action: _buildHeaderButton(
              iconName: 'trophy',
              onTap: () => ShareMilestoneSheet.show(context),
              tooltip: 'Chia sẻ cột mốc tài chính',
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
                              onChatWithAuthor: () {
                                context.push(RoutePaths.socialChat);
                              },
                              onShare: () {
                                _sharePost(post.name);
                              },
                              onOpenComments: () {
                                CommentsBottomSheet.show(
                                  context,
                                  transactionId: post.id,
                                  postTitle: post.name,
                                );
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
                          context.push(RoutePaths.socialChat);
                        },
                        onShare: () {
                          _sharePost(currentPost.name);
                        },
                        onOpenComments: () {
                          Navigator.pop(ctx);
                          CommentsBottomSheet.show(
                            context,
                            transactionId: currentPost.id,
                            postTitle: currentPost.name,
                          );
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
}

/// Typedef để duy trì khả năng tương thích ngược
typedef SocialFeedScreen = FeedScreen;
