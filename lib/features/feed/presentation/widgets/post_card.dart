import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/lucide_icon.dart';

class PostCard extends StatefulWidget {
  const PostCard({
    super.key,
    required this.author,
    required this.initial,
    required this.time,
    required this.content,
    required this.likes,
    required this.comments,
    this.amount,
    this.progress,
    this.category = 'Chia sẻ',
    this.accentColor = const Color(0xFFA78BFA),
  });

  final String author;
  final String initial;
  final String time;
  final String content;
  final int likes;
  final int comments;
  final String? amount;
  final double? progress;
  final String category;
  final Color accentColor;

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard>
    with SingleTickerProviderStateMixin {
  bool _liked = false;
  bool _saved = false;
  late final AnimationController _heartController;
  late final Animation<double> _heartScale;

  static const lavender = Color(0xFFA78BFA);
  static const pink = Color(0xFFFB7185);
  static const mint = Color(0xFF34BFA3);
  static const ink = Color(0xFF302B49);

  @override
  void initState() {
    super.initState();
    _heartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
    _heartScale = Tween<double>(
      begin: 1,
      end: 1.28,
    ).animate(
      CurvedAnimation(
        parent: _heartController,
        curve: Curves.easeOutBack,
      ),
    );
  }

  @override
  void dispose() {
    _heartController.dispose();
    super.dispose();
  }

  void _toggleLike() {
    setState(() => _liked = !_liked);
    if (_liked) {
      _heartController.forward().then((_) {
        if (mounted) _heartController.reverse();
      });
    } else {
      _heartController.reverse();
    }
  }

  void _showMessage(String message) {
    AppToast.info(context, message);
  }

  void _openComments() {
    final controller = TextEditingController();
    final messages = <String>[
      'Bài viết rất truyền cảm hứng! 💜',
      'Cảm ơn bạn đã chia sẻ 🌷',
    ];

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, updateSheet) {
            final bottomInset = MediaQuery.viewInsetsOf(sheetContext).bottom;

            return Padding(
              padding: EdgeInsets.only(bottom: bottomInset),
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.75,
                ),
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                decoration: BoxDecoration(
                  color: Theme.of(sheetContext).brightness == Brightness.dark
                      ? const Color(0xFF29263C)
                      : Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(30),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 42,
                      height: 5,
                      decoration: BoxDecoration(
                        color: lavender.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Bình luận 💬',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Flexible(
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: messages.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (_, index) {
                          return Container(
                            padding: const EdgeInsets.all(13),
                            decoration: BoxDecoration(
                              color: lavender.withValues(
                                alpha: 0.09,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              messages[index],
                              style: GoogleFonts.inter(
                                fontSize: 13,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: controller,
                            decoration: InputDecoration(
                              hintText: 'Viết bình luận...',
                              filled: true,
                              fillColor: lavender.withValues(
                                alpha: 0.08,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton.filled(
                          style: IconButton.styleFrom(
                            backgroundColor: lavender,
                          ),
                          onPressed: () {
                            final text = controller.text.trim();
                            if (text.isEmpty) return;
                            updateSheet(() {
                              messages.add(text);
                              controller.clear();
                            });
                          },
                          icon: const LucideIcon(name: 'send', size: 18, color: AppColors.primary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(controller.dispose);
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;

    final textColor = dark ? const Color(0xFFF4F0FF) : ink;
    final secondary = dark ? const Color(0xFFBDB7D0) : const Color(0xFF89839B);
    final surface = dark ? const Color(0xFF29263C) : Colors.white;

    final accent = widget.accentColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(27),
        border: Border.all(
          color: accent.withValues(alpha: dark ? 0.22 : 0.16),
        ),
        boxShadow: dark
            ? null
            : [
                BoxShadow(
                  color: lavender.withValues(alpha: 0.09),
                  blurRadius: 28,
                  offset: const Offset(0, 9),
                ),
              ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        accent.withValues(alpha: 0.85),
                        pink.withValues(alpha: 0.55),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    widget.initial,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              widget.author,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: textColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 5),
                          const LucideIcon(
                            name: 'shield-check',
                            size: 16,
                            color: lavender,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${widget.time} · Công khai',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: secondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Tùy chọn bài viết',
                  onPressed: () => _showMessage(
                    'Đây là bài đăng minh họa.',
                  ),
                  icon: LucideIcon(
                    name: 'more-horizontal',
                    size: 18,
                    color: secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 7,
              ),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.13),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                _categoryLabel(widget.category),
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: dark ? const Color(0xFFE4D7FF) : _darken(accent),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              widget.content,
              style: GoogleFonts.inter(
                fontSize: 13.5,
                height: 1.7,
                color: textColor,
              ),
            ),
            if (widget.amount != null) ...[
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: dark
                        ? [
                            accent.withValues(alpha: 0.23),
                            mint.withValues(alpha: 0.09),
                          ]
                        : [
                            const Color(0xFFF1EAFE),
                            const Color(0xFFE6FBF3),
                          ],
                  ),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const LucideIcon(
                          name: 'sparkles',
                          color: Color(0xFFF3B64B),
                          size: 19,
                        ),
                        const SizedBox(width: 7),
                        Text(
                          'THÀNH TỰU TIẾT KIỆM',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.7,
                            color: dark
                                ? const Color(0xFFE5D6FF)
                                : const Color(0xFF7957B8),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 11),
                    Text(
                      widget.amount!,
                      style: GoogleFonts.inter(
                        fontSize: 25,
                        fontWeight: FontWeight.w900,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 13),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: LinearProgressIndicator(
                        value: (widget.progress ?? 1).clamp(0.0, 1.0),
                        minHeight: 9,
                        backgroundColor: lavender.withValues(alpha: 0.19),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          mint,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${((widget.progress ?? 1).clamp(0.0, 1.0) * 100).round()}% mục tiêu hoàn thành ✨',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: secondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 17),
            Divider(
              height: 1,
              color: accent.withValues(alpha: 0.13),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                ScaleTransition(
                  scale: _heartScale,
                  child: _action(
                    iconName: 'heart',
                    label: '${widget.likes + (_liked ? 1 : 0)}',
                    color: _liked ? pink : secondary,
                    onPressed: _toggleLike,
                  ),
                ),
                _action(
                  iconName: 'message-circle',
                  label: '${widget.comments}',
                  color: lavender,
                  onPressed: _openComments,
                ),
                _action(
                  iconName: 'share-2',
                  label: 'Chia sẻ',
                  color: mint,
                  onPressed: () => _showMessage(
                    'Chia sẻ bài đăng sẽ được kết nối sau.',
                  ),
                ),
                const Spacer(),
                IconButton(
                  tooltip: _saved ? 'Bỏ lưu bài' : 'Lưu bài',
                  onPressed: () {
                    setState(() => _saved = !_saved);
                  },
                  icon: LucideIcon(
                    name: 'bookmark',
                    size: 20,
                    color: _saved ? const Color(0xFFF2B94B) : secondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _categoryLabel(String value) {
    switch (value) {
      case 'Thành tựu':
        return '🏆 Thành tựu';
      case 'Mẹo tài chính':
        return '💡 Mẹo tài chính';
      case 'Cảm hứng':
        return '🌷 Cảm hứng';
      default:
        return '✨ $value';
    }
  }

  Color _darken(Color color) {
    return Color.lerp(color, Colors.black, 0.24)!;
  }

  Widget _action({
    required String iconName,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return TextButton.icon(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: 5,
          vertical: 8,
        ),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      icon: LucideIcon(name: iconName, size: 18, color: color),
      label: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
