import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/lucide_icon.dart';
import '../../domain/models/feed_post.dart';

/// Thẻ bài đăng dạng ô vuông tối giản hiển thị trong chế độ Lưới 3 cột (Grid 3x3)
class FeedGridCard extends StatelessWidget {
  const FeedGridCard({
    super.key,
    required this.post,
    this.onTap,
  });

  final FeedPost post;
  final VoidCallback? onTap;

  static const List<LinearGradient> _placeholderGradients = [
    LinearGradient(
      colors: [Color(0xFF0F4B92), Color(0xFF0284C7)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    LinearGradient(
      colors: [Color(0xFF059669), Color(0xFF10B981)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    LinearGradient(
      colors: [Color(0xFFD97706), Color(0xFFF59E0B)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    LinearGradient(
      colors: [Color(0xFF7C3AED), Color(0xFF8B5CF6)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    LinearGradient(
      colors: [Color(0xFFDB2777), Color(0xFFEC4899)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  ];

  LinearGradient _getGradient(String seed) {
    final hash = seed.hashCode.abs();
    return _placeholderGradients[hash % _placeholderGradients.length];
  }

  String _formatAmount(double amount, String currency) {
    final isNegative = amount < 0;
    final absAmount = amount.abs();

    // Rút gọn dạng 85k nếu số lớn
    if (absAmount >= 1000000) {
      final inM = (absAmount / 1000000).toStringAsFixed(1).replaceAll('.0', '');
      return '${isNegative ? '-' : '+'}${inM}M $currency';
    } else if (absAmount >= 1000) {
      final inK = (absAmount / 1000).toStringAsFixed(0);
      return '${isNegative ? '-' : '+'}${inK}k $currency';
    }

    final formatted = absAmount.toStringAsFixed(0);
    final sign = isNegative ? '-' : '+';
    return '$sign$formatted $currency';
  }

  @override
  Widget build(BuildContext context) {
    final hasPhoto = post.photoUrl != null && post.photoUrl!.trim().isNotEmpty;
    final fallbackGradient = _getGradient(post.id);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: AspectRatio(
          aspectRatio: 1.0, // Ô vuông tỷ lệ 1:1 chuẩn
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: hasPhoto ? null : fallbackGradient,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // 1. Ảnh bài đăng nếu có
                if (hasPhoto)
                  Image.network(
                    post.photoUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      decoration: BoxDecoration(gradient: fallbackGradient),
                      child: Center(
                        child: LucideIcon(
                          name: post.category?.icon ?? 'image',
                          color: Colors.white.withValues(alpha: 0.7),
                          size: 24,
                        ),
                      ),
                    ),
                  )
                else
                  // Ảnh minh họa FinTech gradient trừu tượng
                  Center(
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.16),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: LucideIcon(
                        name: post.category?.icon ?? 'sparkles',
                        color: Colors.white,
                        size: 18,
                        strokeWidth: 2.2,
                      ),
                    ),
                  ),

                // 2. Gradient scrim che mờ phía dưới để chữ sắc nét
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.25),
                          Colors.black.withValues(alpha: 0.88),
                        ],
                        stops: const [0.35, 0.65, 1.0],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),

                // 3. Top-left: Category tag badge nhỏ gọn
                if (post.category != null)
                  Positioned(
                    top: 5,
                    left: 5,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.18),
                          width: 0.6,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (post.category!.icon != null) ...[
                            LucideIcon(
                              name: post.category!.icon!,
                              size: 9,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 3),
                          ],
                          Text(
                            post.category!.name,
                            style: GoogleFonts.inter(
                              fontSize: 8.5,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // 4. Top-right: Amount hidden lock badge nếu có
                if (post.isAmountHidden)
                  Positioned(
                    top: 5,
                    right: 5,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.55),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: const LucideIcon(
                        name: 'eye-off',
                        size: 9,
                        color: Colors.white70,
                      ),
                    ),
                  ),

                // 5. Bottom Overlay: Vài thông tin cơ bản
                Positioned(
                  left: 6,
                  right: 6,
                  bottom: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Tên giao dịch
                      Text(
                        post.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          shadows: const [
                            Shadow(
                              color: Colors.black87,
                              blurRadius: 3,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 2),

                      // Số tiền & Số tim reactions
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Số tiền
                          Expanded(
                            child: Text(
                              post.isAmountHidden || post.amount == null
                                  ? '••••••'
                                  : _formatAmount(post.amount!, post.currency),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: post.isAmountHidden || post.amount == null
                                    ? Colors.white70
                                    : (post.amount! > 0
                                        ? const Color(0xFF34D399) // Emerald green
                                        : const Color(0xFFFDE047)), // Yellow/Gold
                              ),
                            ),
                          ),

                          // Lượt tim / reaction
                          if (post.reactionsCount > 0)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const LucideIcon(
                                  name: 'heart',
                                  size: 9,
                                  color: Color(0xFFF43F5E),
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  '${post.reactionsCount}',
                                  style: GoogleFonts.inter(
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                      const SizedBox(height: 2),

                      // Tác giả
                      Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primary,
                              image: post.author.avatar != null
                                  ? DecorationImage(
                                      image:
                                          NetworkImage(post.author.avatar!),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            alignment: Alignment.center,
                            child: post.author.avatar == null
                                ? Text(
                                    post.author.initials,
                                    style: const TextStyle(
                                      fontSize: 6.5,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              post.author.displayName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontSize: 8.5,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withValues(alpha: 0.85),
                              ),
                            ),
                          ),
                        ],
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
