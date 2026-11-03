import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:finora_mb/app/theme/app_colors.dart';
import 'package:finora_mb/features/social/presentation/widgets/post_card.dart';

class SocialFeedScreen extends StatefulWidget {
  const SocialFeedScreen({super.key});

  @override
  State<SocialFeedScreen> createState() => _SocialFeedScreenState();
}

class _SocialFeedScreenState extends State<SocialFeedScreen> {
  static const lavender = Color(0xFFA78BFA);
  static const pink = Color(0xFFFB91A9);
  static const mint = Color(0xFF34BFA3);
  static const yellow = Color(0xFFF4C96B);
  static const ink = Color(0xFF302B49);

  int _selectedTab = 0;
  String _searchQuery = '';

  final List<Map<String, dynamic>> _posts = [
    {
      'id': 1,
      'author': 'Minh Anh',
      'initial': 'MA',
      'time': '2 giờ trước',
      'content':
          'Yayyy! 🎉 Mình vừa hoàn thành thử thách tiết kiệm 30 ngày! Mỗi ngày chỉ cần cố gắng một chút thôi. Cảm giác đạt được mục tiêu đầu tiên thật tuyệt vời 💖',
      'likes': 128,
      'comments': 24,
      'amount': '3.000.000 ₫',
      'progress': 1.0,
      'category': 'Thành tựu',
      'accent': lavender,
      'trending': true,
      'following': true,
    },
    {
      'id': 2,
      'author': 'Hoàng Nam',
      'initial': 'HN',
      'time': '5 giờ trước',
      'content':
          'Một mẹo nhỏ giúp mình kiểm soát tiền tốt hơn: thử quy tắc 50/30/20 nhé! 🌿 Chia thu nhập thành nhu cầu thiết yếu, mong muốn và tiết kiệm. Dễ bắt đầu hơn bạn nghĩ đó.',
      'likes': 86,
      'comments': 12,
      'amount': null,
      'progress': null,
      'category': 'Mẹo tài chính',
      'accent': mint,
      'trending': true,
      'following': false,
    },
    {
      'id': 3,
      'author': 'Thảo Vy',
      'initial': 'TV',
      'time': 'Hôm qua',
      'content':
          'Quỹ du lịch của mình đã chạm mốc 75% rồi! ✈️🌸 Mình đang cố gắng để có chuyến đi thật đáng nhớ vào cuối năm.',
      'likes': 42,
      'comments': 8,
      'amount': '7.500.000 ₫',
      'progress': 0.75,
      'category': 'Thành tựu',
      'accent': pink,
      'trending': false,
      'following': true,
    },
    {
      'id': 4,
      'author': 'Ngọc Hà',
      'initial': 'NH',
      'time': '2 ngày trước',
      'content':
          'Đừng so sánh hành trình tài chính của mình với người khác nhé 🌷 Chỉ cần hôm nay tốt hơn hôm qua một chút là đã rất đáng tự hào rồi!',
      'likes': 67,
      'comments': 15,
      'amount': null,
      'progress': null,
      'category': 'Cảm hứng',
      'accent': yellow,
      'trending': false,
      'following': false,
    },
  ];

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _createPost() {
    final controller = TextEditingController();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final dark = Theme.of(sheetContext).brightness == Brightness.dark;

        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: dark ? const Color(0xFF29263C) : Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(30),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Tạo bài đăng mới 🌸',
                          style: GoogleFonts.inter(
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(sheetContext),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: controller,
                    minLines: 4,
                    maxLines: 7,
                    maxLength: 1000,
                    decoration: InputDecoration(
                      hintText: 'Hôm nay bạn muốn chia sẻ điều gì? ✨',
                      filled: true,
                      fillColor: lavender.withValues(alpha: 0.08),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
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
                            'accent': lavender,
                            'trending': false,
                            'following': true,
                          });
                          _selectedTab = 0;
                          _searchQuery = '';
                        });

                        Navigator.pop(sheetContext);
                        _showMessage(
                          'Đã thêm bài đăng vào bảng tin 💜',
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: lavender,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(17),
                        ),
                      ),
                      icon: const Icon(
                        Icons.auto_awesome_rounded,
                      ),
                      label: Text(
                        'Đăng bài',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ).whenComplete(controller.dispose);
  }

  void _openSearch() {
    showSearch<void>(
      context: context,
      delegate: _PastelSearchDelegate(
        onSearch: (value) {
          setState(() => _searchQuery = value);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;

    final foreground = dark ? const Color(0xFFF4F0FF) : ink;

    final muted = dark ? const Color(0xFFBDB7D0) : const Color(0xFF89839B);

    final surface = dark ? const Color(0xFF29263C) : Colors.white;

    final visiblePosts = _posts.where((post) {
      final search = _searchQuery.toLowerCase();
      final matchesSearch = search.isEmpty ||
          (post['author'] as String).toLowerCase().contains(search) ||
          (post['content'] as String).toLowerCase().contains(search);

      final matchesTab = switch (_selectedTab) {
        1 => post['trending'] == true,
        2 => post['following'] == true,
        _ => true,
      };

      return matchesSearch && matchesTab;
    }).toList();

    return Scaffold(
      backgroundColor:
          dark ? AppColors.darkBackground : const Color(0xFFFAF8FF),
      appBar: AppBar(
        backgroundColor: dark ? AppColors.darkSurface : const Color(0xFFFAF8FF),
        elevation: 0,
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '✦ FINORA SOCIAL',
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.4,
                color: dark ? const Color(0xFFC9B5FF) : const Color(0xFF8864C8),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              'Khám phá cộng đồng',
              style: GoogleFonts.inter(
                fontSize: 19,
                fontWeight: FontWeight.w900,
                color: foreground,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Tìm kiếm',
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
        backgroundColor: lavender,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.edit_rounded),
        label: Text(
          'Viết bài',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                16,
                16,
                16,
                100,
              ),
              children: [
                Container(
                  padding: const EdgeInsets.all(23),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: dark
                          ? [
                              const Color(0xFF58427E),
                              const Color(0xFF355D62),
                            ]
                          : [
                              const Color(0xFFE7DBFF),
                              const Color(0xFFFFE5ED),
                              const Color(0xFFE0F9EE),
                            ],
                    ),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: dark
                        ? null
                        : [
                            BoxShadow(
                              color: lavender.withValues(
                                alpha: 0.15,
                              ),
                              blurRadius: 24,
                              offset: const Offset(0, 10),
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
                            color: Color(0xFF986BD9),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'FINORA COMMUNITY',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1,
                              color: dark
                                  ? const Color(0xFFF2E9FF)
                                  : const Color(0xFF7651B3),
                            ),
                          ),
                          const Spacer(),
                          const Text(
                            '🌷 ✨',
                            style: TextStyle(fontSize: 22),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Chia sẻ niềm vui,\nlan tỏa thành công!',
                        style: GoogleFonts.inter(
                          fontSize: 23,
                          height: 1.3,
                          fontWeight: FontWeight.w900,
                          color: foreground,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Cùng nhau chinh phục những mục tiêu tài chính mỗi ngày. 💜',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          height: 1.6,
                          color: muted,
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextButton.icon(
                        onPressed: _createPost,
                        style: TextButton.styleFrom(
                          backgroundColor: dark
                              ? Colors.white.withValues(
                                  alpha: 0.13,
                                )
                              : Colors.white,
                          foregroundColor:
                              dark ? Colors.white : const Color(0xFF7955B7),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 11,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        icon: const Icon(
                          Icons.edit_note_rounded,
                          size: 19,
                        ),
                        label: Text(
                          'Chia sẻ ngay',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: BorderRadius.circular(23),
                    boxShadow: dark
                        ? null
                        : [
                            BoxShadow(
                              color: lavender.withValues(
                                alpha: 0.07,
                              ),
                              blurRadius: 18,
                              offset: const Offset(0, 6),
                            ),
                          ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 43,
                        height: 43,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [pink, lavender],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person_rounded,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 11),
                      Expanded(
                        child: InkWell(
                          onTap: _createPost,
                          borderRadius: BorderRadius.circular(15),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                            ),
                            child: Text(
                              'Hôm nay bạn muốn chia sẻ gì? 🌸',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: muted,
                              ),
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Tạo bài đăng',
                        onPressed: _createPost,
                        icon: const Icon(
                          Icons.add_circle_rounded,
                          color: mint,
                          size: 27,
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
                      _tab(
                        '✨ Dành cho bạn',
                        0,
                        lavender,
                        dark,
                      ),
                      _tab(
                        '🔥 Xu hướng',
                        1,
                        pink,
                        dark,
                      ),
                      _tab(
                        '💚 Đang theo dõi',
                        2,
                        mint,
                        dark,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 23),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Bài viết nổi bật ✨',
                        style: GoogleFonts.inter(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          color: foreground,
                        ),
                      ),
                    ),
                    if (_searchQuery.isNotEmpty)
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                        child: const Text('Xóa tìm kiếm'),
                      ),
                  ],
                ),
                const SizedBox(height: 14),
                if (visiblePosts.isEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 60,
                      horizontal: 20,
                    ),
                    decoration: BoxDecoration(
                      color: surface,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          '🌷',
                          style: TextStyle(fontSize: 48),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Chưa có bài đăng phù hợp',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: foreground,
                          ),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          'Thử một bộ lọc hoặc từ khóa khác nhé!',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: muted,
                          ),
                          textAlign: TextAlign.center,
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
    );
  }

  Widget _tab(
    String title,
    int index,
    Color accent,
    bool dark,
  ) {
    final selected = _selectedTab == index;

    return Padding(
      padding: const EdgeInsets.only(right: 9),
      child: ChoiceChip(
        label: Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: selected
                ? Colors.white
                : (dark ? const Color(0xFFF1E9FF) : const Color(0xFF5B5270)),
          ),
        ),
        selected: selected,
        onSelected: (_) {
          setState(() => _selectedTab = index);
        },
        selectedColor: accent,
        backgroundColor: accent.withValues(
          alpha: dark ? 0.16 : 0.12,
        ),
        side: BorderSide.none,
        showCheckmark: false,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 11,
          vertical: 10,
        ),
      ),
    );
  }
}

class _PastelSearchDelegate extends SearchDelegate<void> {
  _PastelSearchDelegate({required this.onSearch});

  final ValueChanged<String> onSearch;

  @override
  String get searchFieldLabel => 'Tìm bài đăng, tác giả...';

  @override
  List<Widget> buildActions(BuildContext context) => [
        IconButton(
          onPressed: () {
            query = '';
            onSearch('');
          },
          icon: const Icon(Icons.clear_rounded),
        ),
      ];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
        onPressed: () => close(context, null),
        icon: const Icon(Icons.arrow_back_rounded),
      );

  @override
  Widget buildResults(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.search_rounded),
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
      leading: const Icon(Icons.search_rounded),
      title: Text(
        query.isEmpty ? 'Nhập từ khóa để tìm bài đăng' : 'Tìm kiếm "$query"',
      ),
      onTap: () {
        onSearch(query.trim());
        close(context, null);
      },
    );
  }
}
