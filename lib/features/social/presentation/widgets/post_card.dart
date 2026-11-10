import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';

class PostCard extends StatefulWidget {
  const PostCard({
    super.key,
    required this.author,
    required this.initial,
    required this.time,
    required this.content,
    required this.likes,
    required this.comments,
    this.imageUrl,
    this.category = 'Khoảnh khắc',
    this.accentColor = AppColors.primary,
    this.amount,
    this.progress,
  });

  final String author, initial, time, content, category;
  final String? imageUrl, amount;
  final double? progress;
  final int likes, comments;
  final Color accentColor;

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool liked = false;
  bool saved = false;
  final List<String> replies = [];

  void openComments() {
    final controller = TextEditingController();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, refresh) {
          final dark = Theme.of(ctx).brightness == Brightness.dark;
          final fg =
              dark ? AppColors.darkForeground : AppColors.lightForeground;

          return Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              10,
              20,
              MediaQuery.viewInsetsOf(ctx).bottom + 24,
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Bình luận',
                    style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 18),
                  if (replies.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(20),
                      child: Text('Chưa có bình luận mới 💬'),
                    ),
                  if (replies.isNotEmpty)
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 220),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: replies.length,
                        itemBuilder: (_, i) => ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: AppColors.primaryLight,
                            child: Icon(
                              Icons.person,
                              color: AppColors.primary,
                            ),
                          ),
                          title: const Text('Bạn'),
                          subtitle: Text(replies[i]),
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controller,
                          style: TextStyle(color: fg),
                          decoration: InputDecoration(
                            hintText: 'Viết bình luận...',
                            filled: true,
                            fillColor: dark
                                ? AppColors.darkSurface
                                : AppColors.lightBackground,
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
                          backgroundColor: AppColors.primary,
                        ),
                        onPressed: () {
                          final value = controller.text.trim();
                          if (value.isEmpty) return;
                          refresh(() => replies.add(value));
                          setState(() {});
                          controller.clear();
                        },
                        icon: const Icon(Icons.send_rounded),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ).whenComplete(controller.dispose);
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final surface = dark ? AppColors.darkSurface : AppColors.lightSurface;
    final fg = dark ? AppColors.darkForeground : AppColors.lightForeground;
    final muted = dark ? AppColors.darkMuted : AppColors.lightMuted;
    final border = dark ? AppColors.darkBorder : AppColors.lightBorder;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(AppColors.radiusLg),
        border: Border.all(color: border),
        boxShadow: dark
            ? null
            : [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.05),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: widget.accentColor.withValues(alpha: 0.14),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: widget.accentColor,
                      width: 2,
                    ),
                  ),
                  child: Text(
                    widget.initial,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: dark ? fg : widget.accentColor,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.author,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: fg,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        widget.time,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: muted,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => showMessage('Bài đăng minh họa'),
                  icon: Icon(Icons.more_horiz_rounded, color: muted),
                ),
              ],
            ),
          ),

          // Ảnh lớn theo phong cách Locket.
          AspectRatio(
            aspectRatio: 1,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        widget.accentColor.withValues(alpha: 0.45),
                        AppColors.primaryDark,
                      ],
                    ),
                  ),
                  child: widget.imageUrl == null || widget.imageUrl!.isEmpty
                      ? const Center(
                          child: Icon(
                            Icons.photo_camera_rounded,
                            color: Colors.white70,
                            size: 72,
                          ),
                        )
                      : Image.network(
                          widget.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Center(
                            child: Icon(
                              Icons.photo_camera_rounded,
                              size: 72,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                ),
                Positioned(
                  top: 14,
                  left: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.42),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      widget.category,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 15,
                  left: 15,
                  right: 15,
                  child: Text(
                    widget.content,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      height: 1.35,
                      shadows: const [
                        Shadow(
                          color: Colors.black87,
                          blurRadius: 12,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (widget.amount != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color:
                      dark ? AppColors.darkBackground : AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.emoji_events_rounded,
                      color: AppColors.orange,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Mục tiêu: ${widget.amount}',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: fg,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    if (widget.progress != null)
                      Text(
                        '${(widget.progress!.clamp(0.0, 1.0) * 100).round()}%',
                        style: const TextStyle(
                          color: AppColors.teal,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                  ],
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Row(
              children: [
                IconButton(
                  tooltip: 'Thích',
                  onPressed: () => setState(() => liked = !liked),
                  icon: Icon(
                    liked
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: liked ? AppColors.pink : fg,
                    size: 27,
                  ),
                ),
                Text(
                  '${widget.likes + (liked ? 1 : 0)}',
                  style: theme.textTheme.labelMedium,
                ),
                const SizedBox(width: 9),
                IconButton(
                  tooltip: 'Bình luận',
                  onPressed: openComments,
                  icon: Icon(
                    Icons.chat_bubble_outline_rounded,
                    color: fg,
                    size: 25,
                  ),
                ),
                Text(
                  '${widget.comments + replies.length}',
                  style: theme.textTheme.labelMedium,
                ),
                const Spacer(),
                IconButton(
                  tooltip: 'Chia sẻ',
                  onPressed: () => showMessage(
                    'Chức năng chia sẻ sẽ được kết nối sau.',
                  ),
                  icon: const Icon(
                    Icons.send_outlined,
                    color: AppColors.primary,
                  ),
                ),
                IconButton(
                  tooltip: 'Lưu bài',
                  onPressed: () => setState(() => saved = !saved),
                  icon: Icon(
                    saved
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_border_rounded,
                    color: saved ? AppColors.primary : fg,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
