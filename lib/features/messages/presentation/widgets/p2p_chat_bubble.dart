import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/lucide_icon.dart';
import '../../domain/models/message.dart';
import '../../domain/models/message_enums.dart';

class P2pChatBubble extends StatelessWidget {
  const P2pChatBubble({
    super.key,
    required this.message,
    required this.isMine,
    this.onToggleReaction,
    this.onRecall,
  });

  final Message message;
  final bool isMine;
  final ValueChanged<String>? onToggleReaction;
  final VoidCallback? onRecall;

  void _showBubbleActions(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const quickEmojis = ['❤️', '👍', '😂', '😮', '😢', '🔥', '🎉'];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Thanh kéo nhẹ
                Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Dãy biểu tượng cảm xúc nhanh
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: quickEmojis.map((emoji) {
                    return InkWell(
                      onTap: () {
                        Navigator.pop(ctx);
                        onToggleReaction?.call(emoji);
                      },
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          emoji,
                          style: const TextStyle(fontSize: 26),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                if (isMine && onRecall != null) ...[
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 4),
                  ListTile(
                    leading: const LucideIcon(name: 'trash-2', size: 18, color: AppColors.danger),
                    title: Text(
                      'Thu hồi tin nhắn',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.danger,
                      ),
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    onTap: () {
                      Navigator.pop(ctx);
                      onRecall?.call();
                    },
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final timeStr = DateFormat('HH:mm').format(message.createdAt);
    final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);

    // Nhóm cảm xúc
    final reactionCounts = <String, int>{};
    for (final r in message.reactions) {
      reactionCounts[r.emoji] = (reactionCounts[r.emoji] ?? 0) + 1;
    }

    return GestureDetector(
      onLongPress: () => _showBubbleActions(context),
      child: Align(
        alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.78,
          ),
          child: Column(
            crossAxisAlignment:
                isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              // Bubble chính
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  gradient: isMine
                      ? const LinearGradient(
                          colors: [AppColors.primary, Color(0xFF005BB5)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: isMine
                      ? null
                      : (isDark ? AppColors.darkSurface : Colors.white),
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(18),
                    topRight: const Radius.circular(18),
                    bottomLeft: Radius.circular(isMine ? 18 : 4),
                    bottomRight: Radius.circular(isMine ? 4 : 18),
                  ),
                  border: isMine
                      ? Border.all(color: const Color(0xFF0055A9))
                      : Border.all(
                          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                        ),
                  boxShadow: [
                    BoxShadow(
                      color: isMine
                          ? AppColors.primary.withValues(alpha: 0.22)
                          : Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                      blurRadius: isMine ? 12 : 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment:
                      isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    // Thẻ đính kèm giao dịch chia tiền nếu có
                    if (message.transactionAttachment != null) ...[
                      Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isMine
                              ? Colors.white.withValues(alpha: 0.15)
                              : AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isMine
                                ? Colors.white.withValues(alpha: 0.25)
                                : AppColors.primary.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              message.transactionAttachment?.categoryIcon ?? '💳',
                              style: const TextStyle(fontSize: 20),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    message.transactionAttachment?.title ?? 'Giao dịch',
                                    style: AppTextStyles.titleSmall(
                                      color: isMine ? Colors.white : AppColors.primary,
                                    ),
                                  ),
                                  Text(
                                    currencyFormatter.format(message.transactionAttachment?.amount ?? 0),
                                    style: AppTextStyles.amountCard(
                                      color: isMine ? Colors.white : AppColors.danger,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Nội dung văn bản
                    Text(
                      message.content,
                      style: GoogleFonts.inter(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        height: 1.45,
                        color: isMine
                            ? Colors.white
                            : (isDark
                                ? AppColors.darkForeground
                                : AppColors.lightForeground),
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Thời gian và trạng thái đọc
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          timeStr,
                          style: GoogleFonts.inter(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: isMine
                                ? Colors.white.withValues(alpha: 0.75)
                                : AppColors.lightMuted,
                          ),
                        ),
                        if (isMine) ...[
                          const SizedBox(width: 4),
                          LucideIcon(
                            name: (message.isRead || message.status == MessageDeliveryStatus.read)
                                ? 'check-check'
                                : 'check',
                            size: 13,
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Badges biểu tượng cảm xúc (floating reactions)
              if (reactionCounts.isNotEmpty) ...[
                const SizedBox(height: 2),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: reactionCounts.entries.map((entry) {
                    return GestureDetector(
                      onTap: () => onToggleReaction?.call(entry.key),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurface : Colors.white,
                          borderRadius: BorderRadius.circular(99),
                          border: Border.all(
                            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(entry.key, style: const TextStyle(fontSize: 12)),
                            if (entry.value > 1) ...[
                              const SizedBox(width: 3),
                              Text(
                                '${entry.value}',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
