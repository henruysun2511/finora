import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../widgets/post_card.dart';

class SocialFeedScreen extends StatefulWidget {
  const SocialFeedScreen({super.key});

  @override
  State<SocialFeedScreen> createState() => _SocialFeedScreenState();
}

class _SocialFeedScreenState extends State<SocialFeedScreen> {
  int _selectedTab = 0;
  String _searchQuery = '';

  final List<Map<String, dynamic>> _posts = [
    {
      'id': 1,
      'author': 'Minh Anh',
      'initial': 'MA',
      'time': '2 giờ trước',
      'content':
          'Yayyy! 🎉 Mình đã hoàn thành thử thách tiết kiệm 30 ngày! Mỗi ngày cố gắng một chút, cuối cùng cũng đạt được mục tiêu đầu tiên.',
      'likes': 128,
      'comments': 24,
      'amount': '3.000.000 ₫',
      'progress': 1.0,
      'category': 'Thành tựu',
      'accent': AppColors.primary,
      'trending': true,
      'following': true,
    },
    {
      'id': 2,
      'author': 'Hoàng Nam',
      'initial': 'HN',
      'time': '5 giờ trước',
      'content':
          'Một mẹo nhỏ giúp mình quản lý chi tiêu: hãy thử quy tắc 50/30/20. Chia thu nhập thành nhu cầu thiết yếu, mong muốn và tiết kiệm nhé! 💡',
      'likes': 86,
      'comments': 12,
      'amount': null,
      'progress': null,
      'category': 'Mẹo tài chính',
      'accent': AppColors.teal,
      'trending': true,
      'following': false,
    },
    {
      'id': 3,
      'author': 'Thảo Vy',
      'initial': 'TV',
      'time': 'Hôm qua',
      'content':
          'Quỹ du lịch của mình đã đạt 75%! ✈️ Mình đang cố gắng hoàn thành mục tiêu trước cuối năm.',
      'likes': 42,
      'comments': 8,
      'amount': '7.500.000 ₫',
      'progress': 0.75,
      'category': 'Thành tựu',
      'accent': AppColors.orange,
      'trending': false,
      'following': true,
    },
    {
      'id': 4,
      'author': 'Ngọc Hà',
      'initial': 'NH',
      'time': '2 ngày trước',
      'content':
          'Đừng so sánh hành trình tài chính của mình với người khác. Chỉ cần hôm nay tiến bộ hơn hôm qua là đã rất đáng tự hào rồi! 💙',
      'likes': 67,
      'comments': 15,
      'amount': null,
      'progress': null,
      'category': 'Cảm hứng',
      'accent': AppColors.violet,
      'trending': false,
      'following': false,
    },
  ];

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _createPost() {
    final controller = TextEditingController();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        final dark = theme.brightness == Brightness.dark;

        return Padding(
          padding: EdgeInsets.fromLTRB(
            18,
            8,
            18,
            MediaQuery.viewInsetsOf(sheetContext).bottom + 20,
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Tạo bài đăng',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  minLines: 4,
                  maxLines: 6,
                  maxLength: 1000,
                  decoration: InputDecoration(
                    hintText: 'Hôm nay bạn muốn chia sẻ điều gì?',
                    filled: true,
                    fillColor: dark
                        ? AppColors.darkSurface
                        : AppColors.lightBackground,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppColors.radiusMd,
                      ),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 50,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppColors.radiusMd,
                        ),
                      ),
                    ),
                    onPressed: () {
                      final content = controller.text.trim();
                      if (content.isEmpty) return;

                      setState(() {
                        _posts.insert(0, {
                          'id': DateTime.now().microsecondsSinceEpoch,
                          'author': 'Bạn',
                          'initial': 'B',
                          'time': 'Vừa xong',
                          'content': content,
                          'likes': 0,
                          'comments': 0,
                          'amount': null,
                          'progress': null,
                          'category': 'Chia sẻ',
                          'accent': AppColors.primary,
                          'trending': false,
                          'following': true,
                        });
                        _selectedTab = 0;
                        _searchQuery = '';
                      });

                      Navigator.pop(sheetContext);
                      _showMessage(
                        'Đã thêm bài đăng vào bảng tin!',
                      );
                    },
                    icon: const Icon(Icons.send_rounded),
                    label: const Text('Đăng bài'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ).whenComplete(controller.dispose);
  }

  void _openSearch() {
    showSearch<void>(
      context: context,
      delegate: _FeedSearchDelegate(
        onSearch: (value) {
          setState(() => _searchQuery = value);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;

    final background =
        dark ? AppColors.darkBackground : AppColors.lightBackground;
    final surface = dark ? AppColors.darkSurface : AppColors.lightSurface;
    final foreground =
        dark ? AppColors.darkForeground : AppColors.lightForeground;
    final muted = dark ? AppColors.darkMuted : AppColors.lightMuted;
    final border = dark ? AppColors.darkBorder : AppColors.lightBorder;

    final visiblePosts = _posts.where((post) {
      final query = _searchQuery.toLowerCase();

      final matchesSearch = query.isEmpty ||
          (post['author'] as String).toLowerCase().contains(query) ||
          (post['content'] as String).toLowerCase().contains(query);

      final matchesTab = switch (_selectedTab) {
        1 => post['trending'] == true,
        2 => post['following'] == true,
        _ => true,
      };

      return matchesSearch && matchesTab;
    }).toList();

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Bảng tin tài chính',
          style: theme.textTheme.titleLarge?.copyWith(
            color: foreground,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Tìm kiếm bài đăng',
            onPressed: _openSearch,
            icon: Icon(
              Icons.search_rounded,
              color: foreground,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createPost,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.edit_rounded),
        label: const Text('Viết bài'),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async {
                await Future.delayed(
                  const Duration(milliseconds: 400),
                );
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  18,
                  18,
                  18,
                  100,
                ),
                children: [
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                     gradient: const LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    AppColors.balanceGradStart,
    AppColors.balanceGradMid,
    AppColors.balanceGradEnd,
  ],
  stops: [0, 0.70, 1],
),
                      borderRadius: BorderRadius.circular(
                        AppColors.radiusLg,
                      ),
                     boxShadow: const [
  BoxShadow(
    color: AppColors.primaryGlow,
    blurRadius: 20,
    offset: Offset(0, 8),
  ),
],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.auto_awesome_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'FINORA COMMUNITY',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: Colors.white70,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Cùng nhau phát triển\n'
                          'tài chính thông minh',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Chia sẻ kinh nghiệm, kết nối cộng đồng '
                          'và chinh phục mục tiêu tài chính.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(
                              alpha: 0.85,
                            ),
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 18),
                        OutlinedButton.icon(
                          onPressed: _createPost,
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.primaryDark,
                            side: BorderSide.none,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppColors.radiusSm,
                              ),
                            ),
                          ),
                          icon: const Icon(
                            Icons.edit_note_rounded,
                          ),
                          label: const Text('Chia sẻ ngay'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: surface,
                      borderRadius: BorderRadius.circular(
                        AppColors.radiusLg,
                      ),
                      border: Border.all(color: border),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(
                              AppColors.radiusMd,
                            ),
                          ),
                          child: const Icon(
                            Icons.person_rounded,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: InkWell(
                            onTap: _createPost,
                            borderRadius: BorderRadius.circular(
                              AppColors.radiusSm,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                              ),
                              child: Text(
                                'Hôm nay bạn muốn chia sẻ gì?',
                                style: theme.textTheme.bodyMedium
                                    ?.copyWith(color: muted),
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Tạo bài đăng',
                          onPressed: _createPost,
                          icon: const Icon(
                            Icons.add_circle_rounded,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _filterChip(
                          'Dành cho bạn',
                          Icons.auto_awesome_rounded,
                          0,
                        ),
                        _filterChip(
                          'Xu hướng',
                          Icons.local_fire_department_rounded,
                          1,
                        ),
                        _filterChip(
                          'Đang theo dõi',
                          Icons.people_alt_rounded,
                          2,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Bài viết nổi bật',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: foreground,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      if (_searchQuery.isNotEmpty)
                        TextButton(
                          onPressed: () {
                            setState(() => _searchQuery = '');
                          },
                          child: const Text('Xóa tìm kiếm'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  if (visiblePosts.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(35),
                      decoration: BoxDecoration(
                        color: surface,
                        borderRadius: BorderRadius.circular(
                          AppColors.radiusLg,
                        ),
                        border: Border.all(color: border),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.article_outlined,
                            size: 44,
                            color: AppColors.primary,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Chưa có bài đăng phù hợp',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: foreground,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Hãy thử bộ lọc hoặc từ khóa khác.',
                            style: theme.textTheme.bodySmall
                                ?.copyWith(color: muted),
                          ),
                        ],
                      ),
                    )
                  else
                    ...visiblePosts.map(
                      (post) => PostCard(
                        key: ValueKey(post['id']),
                        author: post['author'] as String,
                        initial: post['initial'] as String,
                        time: post['time'] as String,
                        content: post['content'] as String,
                        likes: post['likes'] as int,
                        comments: post['comments'] as int,
                        amount: post['amount'] as String?,
                        progress: post['progress'] as double?,
                        category: post['category'] as String,
                        accentColor: post['accent'] as Color,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _filterChip(
    String label,
    IconData icon,
    int index,
  ) {
    final selected = _selectedTab == index;

    return Padding(
      padding: const EdgeInsets.only(right: 9),
      child: ChoiceChip(
        selected: selected,
        showCheckmark: false,
        selectedColor: AppColors.primary,
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? AppColors.darkSurface
            : AppColors.lightSurface,
        side: BorderSide(
          color: selected
              ? AppColors.primary
              : (Theme.of(context).brightness == Brightness.dark
                  ? AppColors.darkBorder
                  : AppColors.lightBorder),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppColors.radiusSm),
        ),
        avatar: Icon(
          icon,
          size: 17,
          color: selected ? Colors.white : AppColors.primary,
        ),
        label: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: selected
                    ? Colors.white
                    : (Theme.of(context).brightness == Brightness.dark
                        ? AppColors.darkForeground
                        : AppColors.lightForeground),
              ),
        ),
        onSelected: (_) {
          setState(() => _selectedTab = index);
        },
      ),
    );
  }
}

class _FeedSearchDelegate extends SearchDelegate<void> {
  _FeedSearchDelegate({required this.onSearch});

  final ValueChanged<String> onSearch;

  @override
  String get searchFieldLabel => 'Tìm bài đăng, tác giả...';

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
          onSearch('');
        },
        icon: const Icon(Icons.clear_rounded),
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () => close(context, null),
      icon: const Icon(Icons.arrow_back_rounded),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return ListTile(
      leading: const Icon(
        Icons.search_rounded,
        color: AppColors.primary,
      ),
      title: Text('Tìm kiếm "$query"'),
      onTap: () {
        onSearch(query.trim());
        close(context, null);
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return ListTile(
      leading: const Icon(
        Icons.search_rounded,
        color: AppColors.primary,
      ),
      title: Text(
        query.isEmpty ? 'Nhập từ khóa để tìm kiếm' : 'Tìm kiếm "$query"',
      ),
      onTap: () {
        onSearch(query.trim());
        close(context, null);
      },
    );
  }
}
