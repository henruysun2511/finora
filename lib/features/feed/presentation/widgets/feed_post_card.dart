import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/lucide_icon.dart';
import '../../domain/models/feed_post.dart';
import '../../domain/models/post_reaction.dart';
import '../../domain/models/reaction_emoji.dart';
import 'feed_reaction_picker_sheet.dart';
import 'post_reactions_sheet.dart';

class FeedPostCard extends StatelessWidget {
  const FeedPostCard({
    super.key,
    required this.post,
    required this.onToggleReaction,
    required this.onFetchReactions,
    this.onUpdatePost,
    this.onChatWithAuthor,
    this.onShare,
    this.onOpenComments,
  });

  final FeedPost post;
  final void Function({ReactionEmoji? emoji, String? symbol, String? label})
      onToggleReaction;
  final Future<List<PostReaction>> Function() onFetchReactions;
  final void Function({bool? amountHidden, String? note})? onUpdatePost;
  final VoidCallback? onChatWithAuthor;
  final VoidCallback? onShare;
  final VoidCallback? onOpenComments;

  String _formatTimeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 1) return 'Vừa xong';
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
    if (diff.inHours < 24) return '${diff.inHours} giờ trước';
    if (diff.inDays < 7) return '${diff.inDays} ngày trước';
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  LinearGradient _getAvatarGradient(String seed) {
    final hash = seed.hashCode.abs();
    final gradients = [
      const LinearGradient(
        colors: [Color(0xFFF59E0B), Color(0xFFEA580C)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      const LinearGradient(
        colors: [Color(0xFF0072D6), Color(0xFF0284C7)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      const LinearGradient(
        colors: [Color(0xFF10B981), Color(0xFF059669)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      const LinearGradient(
        colors: [Color(0xFFEC4899), Color(0xFFDB2777)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      const LinearGradient(
        colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ];
    return gradients[hash % gradients.length];
  }

  Future<void> _showReactionPickerSheet(BuildContext context) async {
    final selected = await FeedReactionPickerSheet.show(
      context,
      currentReaction: post.myReaction,
      currentSymbol: post.myReactionSymbol,
    );
    if (selected != null) {
      onToggleReaction(
        emoji: selected.emoji,
        symbol: selected.symbol,
        label: selected.label,
      );
    }
  }

  void _showPostOptions(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          decoration: BoxDecoration(
            color: dark ? AppColors.darkSurface : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Cài đặt bài đăng',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Ẩn số tiền trên Bảng tin'),
                  subtitle: const Text(
                    'Bạn bè sẽ không thấy số tiền chính xác của giao dịch này',
                    style: TextStyle(fontSize: 12),
                  ),
                  value: post.isAmountHidden,
                  activeThumbColor: AppColors.primary,
                  onChanged: (val) {
                    Navigator.pop(ctx);
                    onUpdatePost?.call(amountHidden: val);
                  },
                ),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const LucideIcon(
                    name: 'edit-3',
                    color: AppColors.primary,
                    size: 20,
                  ),
                  title: const Text('Chỉnh sửa cảm nghĩ (caption)'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _showEditNoteDialog(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEditNoteDialog(BuildContext context) {
    final controller = TextEditingController(text: post.note ?? '');
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Cập nhật cảm nghĩ'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Nhập cảm nghĩ của bạn...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Hủy'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () {
              Navigator.pop(dialogCtx);
              onUpdatePost?.call(note: controller.text.trim());
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;

    final cardBg = dark ? AppColors.darkSurface : Colors.white;
    final border = dark ? AppColors.darkBorder : AppColors.lightBorder;
    final foreground = dark ? AppColors.darkForeground : AppColors.lightForeground;
    final muted = dark ? AppColors.darkMuted : AppColors.lightMuted;
    final isPos = post.amount != null && post.amount! > 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: dark ? 0.25 : 0.05),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── 1. HERO PHOTO VISUAL AREA (.lf-photo) ──
          SizedBox(
            height: 290,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Background Image or FinTech Gradient
                if (post.photoUrl != null && post.photoUrl!.isNotEmpty)
                  Image.network(
                    post.photoUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildFallbackVisual(),
                  )
                else
                  _buildFallbackVisual(),

                // Dark Gradient Overlay (.lf-overlay)
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.55),
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.85),
                      ],
                      stops: const [0.0, 0.45, 1.0],
                    ),
                  ),
                ),

                // Top User Bar (.lf-top-bar)
                Positioned(
                  top: 14,
                  left: 14,
                  right: 14,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // User Chip (.lf-user-chip)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(99),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(5, 5, 14, 5),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.45),
                              borderRadius: BorderRadius.circular(99),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.18),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 34,
                                  height: 34,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: _getAvatarGradient(
                                      post.author.displayName,
                                    ),
                                    image: post.author.avatar != null
                                        ? DecorationImage(
                                            image: NetworkImage(
                                                post.author.avatar!),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                  ),
                                  alignment: Alignment.center,
                                  child: post.author.avatar == null
                                      ? Text(
                                          post.author.initials,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w900,
                                            fontSize: 13,
                                          ),
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      post.author.displayName,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 13,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        LucideIcon(
                                          name: 'clock',
                                          size: 10.5,
                                          color: Colors.white
                                              .withValues(alpha: 0.72),
                                          strokeWidth: 2.0,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          _formatTimeAgo(post.transactionDate),
                                          style: TextStyle(
                                            color: Colors.white
                                                .withValues(alpha: 0.72),
                                            fontWeight: FontWeight.w600,
                                            fontSize: 10.5,
                                          ),
                                        ),
                                        if (post.locationName != null) ...[
                                          const SizedBox(width: 6),
                                          LucideIcon(
                                            name: 'map-pin',
                                            size: 10.5,
                                            color: Colors.white
                                                .withValues(alpha: 0.72),
                                            strokeWidth: 2.0,
                                          ),
                                          const SizedBox(width: 3),
                                          ConstrainedBox(
                                            constraints: const BoxConstraints(
                                                maxWidth: 120),
                                            child: Text(
                                              post.locationName!,
                                              style: TextStyle(
                                                color: Colors.white
                                                    .withValues(alpha: 0.72),
                                                fontWeight: FontWeight.w600,
                                                fontSize: 10.5,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // More Button (.lf-more-btn)
                      ClipOval(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: InkWell(
                            onTap: () => _showPostOptions(context),
                            child: Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black.withValues(alpha: 0.45),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.18),
                                ),
                              ),
                              child: const Center(
                                child: LucideIcon(
                                  name: 'more-horizontal',
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Bottom Overlay Bar (.lf-bottom-bar)
                Positioned(
                  bottom: 14,
                  left: 14,
                  right: 14,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Badges Row (.lf-meta-badges)
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          // Amount Pill
                          ClipRRect(
                            borderRadius: BorderRadius.circular(99),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4.5),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.6),
                                  borderRadius: BorderRadius.circular(99),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.2),
                                  ),
                                ),
                                child: Text(
                                  post.amount != null
                                      ? (isPos
                                          ? '+${CurrencyFormatter.formatVnd(post.amount!)}'
                                          : CurrencyFormatter.formatVnd(
                                              post.amount!))
                                      : '🔒 Đã ẩn số tiền',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -0.2,
                                    color: post.amount != null
                                        ? (isPos
                                            ? const Color(0xFF4ADE80)
                                            : const Color(0xFFF87171))
                                        : Colors.white.withValues(alpha: 0.85),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Category Pill
                          if (post.category != null)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(99),
                              child: BackdropFilter(
                                filter:
                                    ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4.5),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.6),
                                    borderRadius: BorderRadius.circular(99),
                                    border: Border.all(
                                      color:
                                          Colors.white.withValues(alpha: 0.2),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      LucideIcon(
                                        name: post.category?.icon ?? 'receipt',
                                        size: 13,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        post.category!.name,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Caption (.lf-caption)
                      if (post.note != null && post.note!.isNotEmpty)
                        Text(
                          post.note!,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            height: 1.35,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Colors.black,
                                blurRadius: 4,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── 2. VIEW INTERACTIONS BAR ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
            child: post.reactionsCount > 0
                ? InkWell(
                    onTap: () {
                      PostReactionsSheet.show(
                        context,
                        onFetchReactions: onFetchReactions,
                      );
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Text(
                            'Xem danh sách tương tác',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: muted,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${post.reactionsCount}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          const Spacer(),
                          LucideIcon(
                            name: 'chevron-right',
                            size: 15,
                            color: muted,
                          ),
                        ],
                      ),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Text(
                          'Chưa có hoạt động nào',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            color: muted.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),

          // ── 3. ACTIONS BAR (.lf-actions) ──
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: border.withValues(alpha: 0.6),
                ),
              ),
            ),
            child: Row(
              children: [
                // React Button (.lf-act-btn.react)
                InkWell(
                  onTap: () {
                    if (post.hasReacted) {
                      // Đã chọn icon -> Nhấn thêm lần nữa để hủy
                      onToggleReaction();
                    } else {
                      // Chưa chọn icon -> Mở Bottom Sheet danh sách icon
                      _showReactionPickerSheet(context);
                    }
                  },
                  onLongPress: () => _showReactionPickerSheet(context),
                  borderRadius: BorderRadius.circular(99),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8.5),
                    decoration: BoxDecoration(
                      color: post.hasReacted
                          ? (dark
                              ? const Color(0xFFEA580C).withValues(alpha: 0.18)
                              : const Color(0xFFFFF7ED))
                          : (dark
                              ? AppColors.darkBackground
                              : AppColors.lightBackground),
                      borderRadius: BorderRadius.circular(99),
                      border: Border.all(
                        color: post.hasReacted
                            ? (dark
                                ? const Color(0xFFEA580C)
                                : const Color(0xFFFFEDD5))
                            : border,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (post.hasReacted) ...[
                          if (post.myReactionSymbol == '🔥' ||
                              (post.myReactionSymbol == null &&
                                  post.myReaction == ReactionEmoji.love))
                            const LucideIcon(
                              name: 'flame',
                              size: 16,
                              color: Color(0xFFEA580C),
                              strokeWidth: 2.2,
                            )
                          else
                            Text(
                              post.myReactionSymbol ??
                                  post.myReaction?.symbol ??
                                  '🔥',
                              style: const TextStyle(fontSize: 16),
                            ),
                          const SizedBox(width: 6),
                          Text(
                            post.myReactionLabel ??
                                post.myReaction?.label ??
                                'Yêu thích',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFFEA580C),
                            ),
                          ),
                        ] else ...[
                          LucideIcon(
                            name: 'flame',
                            size: 16,
                            color: foreground,
                            strokeWidth: 2.0,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Thả tim',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: foreground,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // Chat with Author Button
                InkWell(
                  onTap: onChatWithAuthor,
                  borderRadius: BorderRadius.circular(99),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8.5),
                    decoration: BoxDecoration(
                      color: dark
                          ? AppColors.darkBackground
                          : AppColors.lightBackground,
                      borderRadius: BorderRadius.circular(99),
                      border: Border.all(color: border),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        LucideIcon(
                          name: 'message-circle',
                          size: 15,
                          color: foreground,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Nhắn tin',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: foreground,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                if (onOpenComments != null) ...[
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: onOpenComments,
                    borderRadius: BorderRadius.circular(99),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8.5),
                      decoration: BoxDecoration(
                        color: dark
                            ? AppColors.darkBackground
                            : AppColors.lightBackground,
                        borderRadius: BorderRadius.circular(99),
                        border: Border.all(color: border),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          LucideIcon(
                            name: 'message-square',
                            size: 15,
                            color: foreground,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Bình luận',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: foreground,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                const Spacer(),

                // Share Button (.lf-act-btn.right)
                InkWell(
                  onTap: onShare,
                  borderRadius: BorderRadius.circular(99),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8.5),
                    decoration: BoxDecoration(
                      color: dark
                          ? AppColors.darkBackground
                          : AppColors.lightBackground,
                      borderRadius: BorderRadius.circular(99),
                      border: Border.all(color: border),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        LucideIcon(
                          name: 'share-2',
                          size: 15,
                          color: foreground,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Chia sẻ',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: foreground,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  ({List<Color> gradient, String icon, String label}) _getVisualTheme() {
    final catName = (post.category?.name ?? '').toLowerCase();
    final pName = post.name.toLowerCase();
    final catIcon = (post.category?.icon ?? '').toLowerCase();

    // 1. Ăn uống
    if (catIcon.contains('utensils') ||
        catIcon.contains('food') ||
        catName.contains('ăn') ||
        pName.contains('bún') ||
        pName.contains('phở') ||
        pName.contains('cơm') ||
        pName.contains('lẩu')) {
      return (
        gradient: const [Color(0xFF9A3412), Color(0xFFEA580C), Color(0xFFF59E0B)],
        icon: 'utensils',
        label: 'Ăn uống',
      );
    }

    // 2. Cà phê & Đồ uống
    if (catIcon.contains('coffee') ||
        catName.contains('cà phê') ||
        pName.contains('cà phê') ||
        pName.contains('coffee') ||
        pName.contains('trà sữa') ||
        pName.contains('brew')) {
      return (
        gradient: const [Color(0xFF78350F), Color(0xFF92400E), Color(0xFFD97706)],
        icon: 'coffee',
        label: 'Cà phê & Đồ uống',
      );
    }

    // 3. Thu nhập & Tiền lương
    if (catIcon.contains('banknote') ||
        catIcon.contains('wallet') ||
        catName.contains('thu') ||
        catName.contains('lương') ||
        pName.contains('lương') ||
        pName.contains('thưởng') ||
        pName.contains('tiền')) {
      return (
        gradient: const [Color(0xFF065F46), Color(0xFF059669), Color(0xFF10B981)],
        icon: 'banknote',
        label: 'Thu nhập & Tiết kiệm',
      );
    }

    // 4. Du lịch & Đi lại xa
    if (catIcon.contains('plane') ||
        catIcon.contains('flight') ||
        catName.contains('du lịch') ||
        pName.contains('du lịch') ||
        pName.contains('đà lạt') ||
        pName.contains('vé máy bay') ||
        pName.contains('tour')) {
      return (
        gradient: const [Color(0xFF0369A1), Color(0xFF0284C7), Color(0xFF06B6D4)],
        icon: 'plane',
        label: 'Du lịch & Trải nghiệm',
      );
    }

    // 5. Mua sắm
    if (catIcon.contains('shopping') ||
        catName.contains('mua') ||
        catName.contains('sắm') ||
        pName.contains('mua') ||
        pName.contains('sắm') ||
        pName.contains('shopee') ||
        pName.contains('quần áo')) {
      return (
        gradient: const [Color(0xFF9D174D), Color(0xFFDB2777), Color(0xFFEC4899)],
        icon: 'shopping-bag',
        label: 'Mua sắm',
      );
    }

    // 6. Thể thao & Gym
    if (catIcon.contains('fitness') ||
        catIcon.contains('dumbbell') ||
        catName.contains('thể thao') ||
        catName.contains('gym') ||
        pName.contains('gym') ||
        pName.contains('yoga') ||
        pName.contains('chạy bộ')) {
      return (
        gradient: const [Color(0xFF5B21B6), Color(0xFF7C3AED), Color(0xFF8B5CF6)],
        icon: 'dumbbell',
        label: 'Thể thao & Sức khỏe',
      );
    }

    // 7. Hóa đơn & Tiện ích
    if (catIcon.contains('zap') ||
        catName.contains('điện') ||
        catName.contains('nước') ||
        catName.contains('hóa đơn') ||
        pName.contains('điện') ||
        pName.contains('wifi') ||
        pName.contains('hóa đơn')) {
      return (
        gradient: const [Color(0xFF92400E), Color(0xFFD97706), Color(0xFFF59E0B)],
        icon: 'zap',
        label: 'Hóa đơn & Tiện ích',
      );
    }

    // 8. Giải trí
    if (catIcon.contains('gamepad') ||
        catName.contains('giải trí') ||
        pName.contains('phim') ||
        pName.contains('game') ||
        pName.contains('karaoke')) {
      return (
        gradient: const [Color(0xFF4C1D95), Color(0xFF6B21A8), Color(0xFF9333EA)],
        icon: 'gamepad-2',
        label: 'Giải trí',
      );
    }

    // 9. Di chuyển
    if (catIcon.contains('car') ||
        catName.contains('xe') ||
        catName.contains('xăng') ||
        pName.contains('xăng') ||
        pName.contains('grab') ||
        pName.contains('taxi')) {
      return (
        gradient: const [Color(0xFF155E75), Color(0xFF0891B2), Color(0xFF06B6D4)],
        icon: 'car',
        label: 'Di chuyển',
      );
    }

    // Mặc định: FinTech Blue
    return (
      gradient: const [Color(0xFF0F4B92), AppColors.primary, Color(0xFF0284C7)],
      icon: 'sparkles',
      label: post.category?.name ?? 'Khoảnh khắc',
    );
  }

  Widget _buildFallbackVisual() {
    final theme = _getVisualTheme();

    return Stack(
      fit: StackFit.expand,
      children: [
        // Nền Gradient đa sắc theo danh mục
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: theme.gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),

        // Vòng tròn trang trí mờ góc trên
        Positioned(
          top: -40,
          right: -40,
          child: Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.12),
            ),
          ),
        ),

        // Vòng tròn trang trí mờ góc dưới
        Positioned(
          bottom: -50,
          left: -30,
          child: Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.08),
            ),
          ),
        ),

        // Icon Lucide chìm lớn ở nền phía sau
        Positioned(
          right: 15,
          bottom: 20,
          child: Transform.rotate(
            angle: -0.15,
            child: LucideIcon(
              name: theme.icon,
              size: 140,
              color: Colors.white.withValues(alpha: 0.08),
              strokeWidth: 1.2,
            ),
          ),
        ),
      ],
    );
  }
}
