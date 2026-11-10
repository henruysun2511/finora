import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../widgets/post_card.dart';

class SocialFeedScreen extends StatefulWidget {
  const SocialFeedScreen({super.key});

  @override
  State<SocialFeedScreen> createState() => _SocialFeedScreenState();
}

class _SocialFeedScreenState extends State<SocialFeedScreen> {
  int selectedTab = 0;
  String search = '';

  final List<Map<String, dynamic>> posts = [
    {
      'id': 1,
      'author': 'Minh Anh',
      'initial': 'MA',
      'time': '2 giờ trước',
      'content': '30 ngày tiết kiệm thành công! 🎉',
      'image': 'https://picsum.photos/seed/finora-coffee/800/800',
      'likes': 128,
      'comments': 24,
      'category': 'Thành tựu',
      'accent': AppColors.primary,
      'amount': '3.000.000 ₫',
      'progress': 1.0,
      'following': true,
    },
    {
      'id': 2,
      'author': 'Hoàng Nam',
      'initial': 'HN',
      'time': '5 giờ trước',
      'content': 'Một buổi chiều bình yên và một kế hoạch tài chính mới ☕',
      'image': 'https://picsum.photos/seed/finora-city/800/800',
      'likes': 86,
      'comments': 12,
      'category': 'Khoảnh khắc',
      'accent': AppColors.teal,
      'amount': null,
      'progress': null,
      'following': false,
    },
    {
      'id': 3,
      'author': 'Thảo Vy',
      'initial': 'TV',
      'time': 'Hôm qua',
      'content': 'Quỹ du lịch đã đạt 75%. Biển xanh đang chờ mình! 🌊',
      'image': 'https://picsum.photos/seed/finora-beach/800/800',
      'likes': 42,
      'comments': 8,
      'category': 'Mục tiêu',
      'accent': AppColors.orange,
      'amount': '10.000.000 ₫',
      'progress': 0.75,
      'following': true,
    },
    {
      'id': 4,
      'author': 'Ngọc Hà',
      'initial': 'NH',
      'time': '2 ngày trước',
      'content': 'Mỗi ngày một chút, tương lai sẽ tốt hơn 💙',
      'image': 'https://picsum.photos/seed/finora-sky/800/800',
      'likes': 67,
      'comments': 15,
      'category': 'Cảm hứng',
      'accent': AppColors.violet,
      'amount': null,
      'progress': null,
      'following': false,
    },
  ];

  void createPost() {
    final captionController = TextEditingController();
    final imageController = TextEditingController();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) {
        final dark = Theme.of(ctx).brightness == Brightness.dark;
        final surface =
            dark ? AppColors.darkSurface : AppColors.lightBackground;

        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            10,
            20,
            MediaQuery.viewInsetsOf(ctx).bottom + 24,
          ),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Chia sẻ khoảnh khắc',
                    style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    height: 130,
                    decoration: BoxDecoration(
                      color: surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_a_photo_rounded,
                          size: 40,
                          color: AppColors.primary,
                        ),
                        SizedBox(height: 8),
                        Text('Thêm ảnh bằng đường dẫn URL'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: imageController,
                    keyboardType: TextInputType.url,
                    decoration: InputDecoration(
                      labelText: 'URL ảnh (không bắt buộc)',
                      prefixIcon: const Icon(Icons.link_rounded),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: captionController,
                    maxLines: 3,
                    maxLength: 300,
                    decoration: InputDecoration(
                      hintText: 'Viết một lời nhắn ngắn...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 52,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () {
                        final caption = captionController.text.trim();
                        final image = imageController.text.trim();

                        if (caption.isEmpty && image.isEmpty) {
                          ScaffoldMessenger.of(ctx).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Hãy nhập ảnh hoặc lời nhắn.',
                              ),
                            ),
                          );
                          return;
                        }

                        final uri = Uri.tryParse(image);
                        final validImage = image.isEmpty ||
                            (uri != null &&
                                (uri.scheme == 'http' ||
                                    uri.scheme == 'https') &&
                                uri.host.isNotEmpty);

                        if (!validImage) {
                          ScaffoldMessenger.of(ctx).showSnackBar(
                            const SnackBar(
                              content: Text('URL ảnh không hợp lệ.'),
                            ),
                          );
                          return;
                        }

                        setState(() {
                          posts.insert(0, {
                            'id': DateTime.now().microsecondsSinceEpoch,
                            'author': 'Bạn',
                            'initial': 'B',
                            'time': 'Vừa xong',
                            'content': caption,
                            'image': image,
                            'likes': 0,
                            'comments': 0,
                            'category': 'Khoảnh khắc',
                            'accent': AppColors.primary,
                            'amount': null,
                            'progress': null,
                            'following': true,
                          });
                          selectedTab = 0;
                          search = '';
                        });

                        Navigator.pop(ctx);
                      },
                      icon: const Icon(Icons.send_rounded),
                      label: const Text('Đăng khoảnh khắc'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ).whenComplete(() {
      captionController.dispose();
      imageController.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;

    final bg = dark ? AppColors.darkBackground : AppColors.lightBackground;
    final surface = dark ? AppColors.darkSurface : AppColors.lightSurface;
    final fg = dark ? AppColors.darkForeground : AppColors.lightForeground;
    final muted = dark ? AppColors.darkMuted : AppColors.lightMuted;
    final border = dark ? AppColors.darkBorder : AppColors.lightBorder;

    final filtered = posts.where((post) {
      final matchSearch = '${post['author']} ${post['content']}'
          .toLowerCase()
          .contains(search.toLowerCase());

      final matchTab =
          selectedTab == 0 || (selectedTab == 1 && post['following'] == true);

      return matchSearch && matchTab;
    }).toList();

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            const Icon(
              Icons.favorite_rounded,
              color: AppColors.primary,
              size: 27,
            ),
            const SizedBox(width: 9),
            Text(
              'Khoảnh khắc',
              style: theme.textTheme.titleLarge?.copyWith(
                color: fg,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Tìm kiếm',
            onPressed: () {
              showSearch<String?>(
                context: context,
                delegate: _PostSearch(),
              ).then((value) {
                if (!mounted || value == null) return;
                setState(() => search = value);
              });
            },
            icon: Icon(Icons.search_rounded, color: fg),
          ),
          IconButton(
            tooltip: 'Tạo bài đăng',
            onPressed: createPost,
            icon: const Icon(
              Icons.add_circle_rounded,
              color: AppColors.primary,
              size: 29,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: createPost,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        tooltip: 'Chia sẻ khoảnh khắc',
        child: const Icon(Icons.camera_alt_rounded, size: 28),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 650),
            child: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async {
                await Future.delayed(
                  const Duration(milliseconds: 400),
                );
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 100),
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          AppColors.balanceGradStart,
                          AppColors.balanceGradMid,
                          AppColors.balanceGradEnd,
                        ],
                        stops: [0, 0.75, 1],
                      ),
                      borderRadius: BorderRadius.circular(
                        AppColors.radiusLg,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'FINORA MOMENTS',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.3,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Lưu giữ những\nkhoảnh khắc nhỏ 💙',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  height: 1.3,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Chia sẻ hành trình cùng bạn bè.',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.photo_camera_rounded,
                          size: 65,
                          color: Colors.white70,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Bạn bè của bạn',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: fg,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Text(
                        'Đang kết nối',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: muted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 95,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _friend('Bạn', 'B', AppColors.primary, true),
                        _friend('Minh Anh', 'MA', AppColors.primary, false),
                        _friend('Hoàng Nam', 'HN', AppColors.teal, false),
                        _friend('Thảo Vy', 'TV', AppColors.orange, false),
                        _friend('Ngọc Hà', 'NH', AppColors.violet, false),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: surface,
                      borderRadius: BorderRadius.circular(
                        AppColors.radiusLg,
                      ),
                      border: Border.all(color: border),
                    ),
                    child: InkWell(
                      onTap: createPost,
                      borderRadius: BorderRadius.circular(18),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.camera_alt_rounded,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Chia sẻ khoảnh khắc của bạn...',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: muted,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.add_circle_rounded,
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      _tab('Dành cho bạn', 0),
                      const SizedBox(width: 9),
                      _tab('Đang theo dõi', 1),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Khoảnh khắc gần đây',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: fg,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      if (search.isNotEmpty)
                        TextButton(
                          onPressed: () => setState(() => search = ''),
                          child: const Text('Xóa lọc'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  if (filtered.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(30),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.photo_library_outlined,
                            color: AppColors.primary,
                            size: 45,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Chưa có khoảnh khắc phù hợp',
                            style: TextStyle(color: fg),
                          ),
                        ],
                      ),
                    )
                  else
                    ...filtered.map(
                      (post) => PostCard(
                        key: ValueKey(post['id']),
                        author: post['author'] as String,
                        initial: post['initial'] as String,
                        time: post['time'] as String,
                        content: post['content'] as String,
                        imageUrl: post['image'] as String?,
                        likes: post['likes'] as int,
                        comments: post['comments'] as int,
                        category: post['category'] as String,
                        accentColor: post['accent'] as Color,
                        amount: post['amount'] as String?,
                        progress: post['progress'] as double?,
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

  Widget _friend(
    String name,
    String initials,
    Color accent,
    bool isMe,
  ) {
    return Padding(
      padding: const EdgeInsets.only(right: 18),
      child: InkWell(
        onTap: isMe
            ? createPost
            : () {
                setState(() {
                  selectedTab = 0;
                  search = name;
                });
              },
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accent.withValues(alpha: 0.12),
                    border: Border.all(color: accent, width: 2.5),
                  ),
                  child: Text(
                    initials,
                    style: TextStyle(
                      color: accent,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                if (isMe)
                  const Positioned(
                    bottom: 0,
                    right: 0,
                    child: Icon(
                      Icons.add_circle_rounded,
                      color: AppColors.primary,
                      size: 21,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 7),
            Text(
              name,
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _tab(String label, int index) {
    final active = selectedTab == index;
    final dark = Theme.of(context).brightness == Brightness.dark;

    return ChoiceChip(
      selected: active,
      showCheckmark: false,
      label: Text(label),
      selectedColor: AppColors.primary,
      backgroundColor: dark ? AppColors.darkSurface : AppColors.lightSurface,
      labelStyle: TextStyle(
        color: active
            ? Colors.white
            : (dark ? AppColors.darkForeground : AppColors.lightForeground),
        fontWeight: FontWeight.w700,
      ),
      side: BorderSide(
        color: active
            ? AppColors.primary
            : (dark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      onSelected: (_) => setState(() => selectedTab = index),
    );
  }
}

class _PostSearch extends SearchDelegate<String?> {
  @override
  String get searchFieldLabel => 'Tìm bạn bè hoặc khoảnh khắc...';

  @override
  List<Widget> buildActions(BuildContext context) => [
        IconButton(
          onPressed: () => query = '',
          icon: const Icon(Icons.clear_rounded),
        ),
      ];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
        onPressed: () => close(context, null),
        icon: const Icon(Icons.arrow_back_rounded),
      );

  @override
  Widget buildResults(BuildContext context) => ListTile(
        leading: const Icon(
          Icons.search,
          color: AppColors.primary,
        ),
        title: Text('Tìm "$query"'),
        onTap: () => close(context, query.trim()),
      );

  @override
  Widget buildSuggestions(BuildContext context) => ListTile(
        leading: const Icon(
          Icons.search,
          color: AppColors.primary,
        ),
        title: Text(
          query.isEmpty ? 'Nhập từ khóa...' : 'Tìm "$query"',
        ),
        onTap: () => close(context, query.trim()),
      );
}
