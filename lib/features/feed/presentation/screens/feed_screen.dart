import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/page_header.dart';
import '../providers/feed_list_provider.dart';
import '../widgets/feed_post_card.dart';

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String _selectedCategory = 'all';
  String? _selectedFriendName;

  final List<({String key, String label})> _categories = const [
    (key: 'all', label: 'Tất cả'),
    (key: 'food', label: '🍜 Ăn uống'),
    (key: 'income', label: '💰 Thu nhập'),
    (key: 'travel', label: '✈️ Du lịch'),
    (key: 'coffee', label: '☕ Cà phê'),
    (key: 'fitness', label: '🏋️ Thể thao'),
    (key: 'shopping', label: '🛍️ Mua sắm'),
  ];

  final List<({String name, String initials, List<Color> gradient, bool isSeen})>
      _stories = const [
    (
      name: 'Trần Ngọc',
      initials: 'TN',
      gradient: [Color(0xFFF59E0B), Color(0xFFEA580C)],
      isSeen: false,
    ),
    (
      name: 'Hùng Minh',
      initials: 'HM',
      gradient: [Color(0xFF0072D6), Color(0xFF0284C7)],
      isSeen: false,
    ),
    (
      name: 'Phạm Lan',
      initials: 'PL',
      gradient: [Color(0xFF10B981), Color(0xFF059669)],
      isSeen: true,
    ),
    (
      name: 'Anh Thư',
      initials: 'AT',
      gradient: [Color(0xFFEC4899), Color(0xFFDB2777)],
      isSeen: true,
    ),
    (
      name: 'Minh Tuấn',
      initials: 'MT',
      gradient: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
      isSeen: true,
    ),
    (
      name: 'Hải Đăng',
      initials: 'HĐ',
      gradient: [Color(0xFF06B6D4), Color(0xFF0284C7)],
      isSeen: true,
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _sharePost(String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã sao chép liên kết bài đăng "$title"'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final bg = dark ? AppColors.darkBackground : AppColors.lightBackground;
    final surface = dark ? AppColors.darkSurface : Colors.white;
    final border = dark ? AppColors.darkBorder : AppColors.lightBorder;
    final foreground = dark ? AppColors.darkForeground : AppColors.lightForeground;
    final muted = dark ? AppColors.darkMuted : AppColors.lightMuted;

    final searchQuery = ref.watch(feedSearchQueryProvider);
    final feedAsync = ref.watch(feedListProvider);

    return Scaffold(
      backgroundColor: bg,
      appBar: PageHeader.subPage(
        title: 'Bảng tin tài chính',
        subtitle: 'Khoảnh khắc & chi tiêu cùng bạn bè',
        action: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                _isSearching ? Icons.close_rounded : Icons.search_rounded,
                color: foreground,
              ),
              onPressed: () {
                setState(() {
                  _isSearching = !_isSearching;
                  if (!_isSearching) {
                    _searchController.clear();
                    ref.read(feedSearchQueryProvider.notifier).state = '';
                  }
                });
              },
            ),
            IconButton(
              icon: const Icon(
                Icons.people_alt_rounded,
                color: AppColors.primary,
              ),
              tooltip: 'Danh sách bạn bè',
              onPressed: () => context.push(RoutePaths.friends),
            ),
            const SizedBox(width: 4),
            InkWell(
              onTap: () => context.push(RoutePaths.createTransaction),
              borderRadius: BorderRadius.circular(99),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6.5),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(99),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add_rounded, size: 16, color: Colors.white),
                    SizedBox(width: 4),
                    Text(
                      'Chia bill',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
      body: Column(
        children: [
          // ── Search Bar (Conditional) ──
          if (_isSearching)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                onChanged: (val) {
                  ref.read(feedSearchQueryProvider.notifier).state = val.trim();
                },
                decoration: InputDecoration(
                  hintText: 'Tìm theo bạn bè, địa điểm hoặc nội dung...',
                  prefixIcon: const Icon(Icons.search_rounded, size: 20),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            ref.read(feedSearchQueryProvider.notifier).state = '';
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: surface,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: border),
                  ),
                ),
              ),
            ),

          // ── Stories Bar (.lf-stories) ──
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: surface,
              border: Border(
                bottom: BorderSide(
                  color: border.withValues(alpha: 0.6),
                ),
              ),
            ),
            child: SizedBox(
              height: 94,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: _stories.length + 1,
                separatorBuilder: (_, __) => const SizedBox(width: 14),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _buildAddBillStory(context, dark);
                  }
                  final story = _stories[index - 1];
                  final isFilterActive = _selectedFriendName == story.name;
                  return _buildFriendStory(
                    story: story,
                    isActive: isFilterActive,
                    onTap: () {
                      setState(() {
                        if (_selectedFriendName == story.name) {
                          _selectedFriendName = null;
                        } else {
                          _selectedFriendName = story.name;
                        }
                      });
                    },
                  );
                },
              ),
            ),
          ),

          // ── Category Filter Chips (.filter-scroll) ──
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: SizedBox(
              height: 40,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final isSelected = _selectedCategory == cat.key;
                  return _buildFilterChip(
                    label: cat.label,
                    isSelected: isSelected,
                    onSelected: () {
                      setState(() {
                        _selectedCategory = cat.key;
                      });
                    },
                  );
                },
              ),
            ),
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
                        const Icon(Icons.person_pin_rounded,
                            size: 14, color: AppColors.primary),
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
                          child: const Icon(
                            Icons.close_rounded,
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
                      const Icon(Icons.error_outline_rounded,
                          size: 48, color: Colors.redAccent),
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
                        onPressed: () =>
                            ref.read(feedListProvider.notifier).refresh(),
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Thử lại'),
                      ),
                    ],
                  ),
                ),
              ),
              data: (posts) {
                // Filter posts
                final filtered = posts.where((p) {
                  // Friend filter
                  if (_selectedFriendName != null &&
                      !p.author.displayName
                          .toLowerCase()
                          .contains(_selectedFriendName!.toLowerCase())) {
                    return false;
                  }

                  // Category filter
                  if (_selectedCategory != 'all') {
                    final catName = (p.category?.name ?? '').toLowerCase();
                    final pName = p.name.toLowerCase();
                    final match = switch (_selectedCategory) {
                      'food' => catName.contains('ăn') || pName.contains('bún') || pName.contains('phở'),
                      'income' => catName.contains('thu') || pName.contains('lương'),
                      'travel' => catName.contains('du lịch') || pName.contains('đà lạt') || pName.contains('vé'),
                      'coffee' => catName.contains('cà phê') || pName.contains('coffee') || pName.contains('brew'),
                      'fitness' => catName.contains('thể thao') || pName.contains('gym'),
                      'shopping' => catName.contains('sắm') || pName.contains('mua'),
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
                    if (!matchAuthor && !matchName && !matchNote && !matchLocation) {
                      return false;
                    }
                  }

                  return true;
                }).toList();

                if (filtered.isEmpty) {
                  return _buildEmptyState(context);
                }

                return RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () =>
                      ref.read(feedListProvider.notifier).refresh(),
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 24, top: 4),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final post = filtered[index];
                      return FeedPostCard(
                        post: post,
                        onToggleReaction: (emoji) {
                          ref
                              .read(feedListProvider.notifier)
                              .toggleReaction(post.id, emoji);
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
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddBillStory(BuildContext context, bool dark) {
    return InkWell(
      onTap: () => context.push(RoutePaths.createTransaction),
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withValues(alpha: 0.1),
              border: Border.all(
                color: AppColors.primary,
                width: 2,
                style: BorderStyle.solid,
              ),
            ),
            child: const Icon(
              Icons.add_rounded,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Chia bill',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFriendStory({
    required ({String name, String initials, List<Color> gradient, bool isSeen})
        story,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final foreground = dark ? AppColors.darkForeground : AppColors.lightForeground;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 58,
            height: 58,
            padding: const EdgeInsets.all(2.5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: isActive
                  ? const LinearGradient(
                      colors: [AppColors.primary, Color(0xFF00C6FF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : (story.isSeen
                      ? const LinearGradient(
                          colors: [Color(0xFFCBD5E1), Color(0xFF94A3B8)],
                        )
                      : LinearGradient(
                          colors: story.gradient,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: story.gradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: dark ? AppColors.darkSurface : Colors.white,
                  width: 2,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                story.initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            story.name,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isActive ? FontWeight.w900 : FontWeight.w700,
              color: isActive ? AppColors.primary : foreground,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onSelected,
  }) {
    final dark = Theme.of(context).brightness == Brightness.dark;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      showCheckmark: false,
      onSelected: (_) => onSelected(),
      labelStyle: TextStyle(
        fontSize: 12.5,
        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
        color: isSelected
            ? Colors.white
            : (dark ? AppColors.darkForeground : AppColors.lightForeground),
      ),
      backgroundColor: dark ? AppColors.darkSurface : Colors.white,
      selectedColor: AppColors.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(99),
        side: BorderSide(
          color: isSelected
              ? AppColors.primary
              : (dark ? AppColors.darkBorder : AppColors.lightBorder),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final foreground = dark ? AppColors.darkForeground : AppColors.lightForeground;
    final muted = dark ? AppColors.darkMuted : AppColors.lightMuted;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.dynamic_feed_rounded,
                size: 40,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Không tìm thấy bài đăng phù hợp',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: foreground,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Hãy thử chọn danh mục khác hoặc xóa bộ lọc để xem toàn bộ bảng tin bạn bè.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                height: 1.4,
                color: muted,
              ),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                setState(() {
                  _selectedCategory = 'all';
                  _selectedFriendName = null;
                  _searchController.clear();
                  ref.read(feedSearchQueryProvider.notifier).state = '';
                });
              },
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Đặt lại bộ lọc'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Typedef để duy trì khả năng tương thích ngược
typedef SocialFeedScreen = FeedScreen;
