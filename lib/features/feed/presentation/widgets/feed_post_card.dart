import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/models/feed_post.dart';
import '../../domain/models/post_reaction.dart';
import '../../domain/models/reaction_emoji.dart';
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
  final void Function(ReactionEmoji emoji) onToggleReaction;
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

  void _showReactionPicker(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final dark = Theme.of(ctx).brightness == Brightness.dark;
        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: dark ? AppColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 18,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: dark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ReactionEmoji.values.map((emoji) {
              final isSelected = post.myReaction == emoji;
              return InkWell(
                onTap: () {
                  Navigator.pop(ctx);
                  onToggleReaction(emoji);
                },
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.15)
                        : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    emoji.symbol,
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
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
                  activeColor: AppColors.primary,
                  onChanged: (val) {
                    Navigator.pop(ctx);
                    onUpdatePost?.call(amountHidden: val);
                  },
                ),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.edit_note_rounded,
                      color: AppColors.primary),
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
                                          Text(
                                            ' · ',
                                            style: TextStyle(
                                              color: Colors.white
                                                  .withValues(alpha: 0.72),
                                              fontSize: 10.5,
                                            ),
                                          ),
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
                              child: const Icon(
                                Icons.more_horiz_rounded,
                                color: Colors.white,
                                size: 18,
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
                                      Icon(
                                        _getCategoryIcon(post.category!.icon),
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

          // ── 2. REACTION ROW (.lf-reaction-row) ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                _buildQuickReactChip('🔥', ReactionEmoji.love),
                const SizedBox(width: 7),
                _buildQuickReactChip('😋', ReactionEmoji.haha),
                const SizedBox(width: 7),
                _buildQuickReactChip('❤️', ReactionEmoji.love),
                const SizedBox(width: 7),
                _buildQuickReactChip('👏', ReactionEmoji.clap),
                const SizedBox(width: 7),
                _buildQuickReactChip('🦊', ReactionEmoji.mascot),
                const Spacer(),
                InkWell(
                  onTap: () async {
                    final list = await onFetchReactions();
                    if (context.mounted) {
                      PostReactionsSheet.show(context, reactions: list);
                    }
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    child: Text(
                      '${post.reactionsCount} tương tác',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: muted,
                      ),
                    ),
                  ),
                ),
              ],
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
                    if (post.myReaction != null) {
                      onToggleReaction(post.myReaction!);
                    } else {
                      onToggleReaction(ReactionEmoji.love);
                    }
                  },
                  onLongPress: () => _showReactionPicker(context),
                  borderRadius: BorderRadius.circular(99),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8.5),
                    decoration: BoxDecoration(
                      color: post.hasReacted
                          ? (dark
                              ? AppColors.primary.withValues(alpha: 0.2)
                              : const Color(0xFFFFF7ED))
                          : (dark
                              ? AppColors.darkBackground
                              : AppColors.lightBackground),
                      borderRadius: BorderRadius.circular(99),
                      border: Border.all(
                        color: post.hasReacted
                            ? (dark
                                ? AppColors.primary
                                : const Color(0xFFFFEDD5))
                            : border,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          post.myReaction?.symbol ?? '🔥',
                          style: const TextStyle(fontSize: 15),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          post.myReaction?.label ?? 'Thả tim',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: post.hasReacted
                                ? const Color(0xFFEA580C)
                                : foreground,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // Comment Button
                InkWell(
                  onTap: onOpenComments,
                  borderRadius: BorderRadius.circular(99),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8.5),
                    decoration: BoxDecoration(
                      color: dark ? AppColors.darkBackground : AppColors.lightBackground,
                      borderRadius: BorderRadius.circular(99),
                      border: Border.all(color: border),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.chat_bubble_outline_rounded, size: 15, color: foreground),
                        const SizedBox(width: 5),
                        Text('Bình luận', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: foreground)),
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
                        Icon(
                          Icons.chat_bubble_outline_rounded,
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
                        Icon(
                          Icons.share_outlined,
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

  Widget _buildQuickReactChip(String emojiSymbol, ReactionEmoji emoji) {
    return InkWell(
      onTap: () => onToggleReaction(emoji),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primary.withValues(alpha: 0.08),
        ),
        alignment: Alignment.center,
        child: Text(
          emojiSymbol,
          style: const TextStyle(fontSize: 15),
        ),
      ),
    );
  }

  Widget _buildFallbackVisual() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.auto_awesome_rounded,
          size: 64,
          color: Colors.white.withValues(alpha: 0.15),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String? icon) {
    return switch (icon?.toLowerCase()) {
      'utensils' || 'food' => Icons.restaurant_rounded,
      'wallet' || 'income' => Icons.account_balance_wallet_rounded,
      'flight' || 'travel' => Icons.flight_takeoff_rounded,
      'coffee' => Icons.local_cafe_rounded,
      'fitness' || 'gym' => Icons.fitness_center_rounded,
      'shopping' => Icons.shopping_bag_rounded,
      _ => Icons.receipt_long_rounded,
    };
  }
}
