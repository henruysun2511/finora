import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../domain/models/conversation.dart';
import '../../domain/models/message_enums.dart';

class ConversationCard extends StatelessWidget {
  const ConversationCard({
    super.key,
    required this.conversation,
    required this.onTap,
    this.onDelete,
  });

  final Conversation conversation;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final timeStr = DateFormat('HH:mm').format(conversation.updatedAt);

    String lastMessagePreview = 'Chưa có tin nhắn';
    if (conversation.lastMessage != null) {
      final msg = conversation.lastMessage!;
      if (msg.type == MessageType.transactionShare) {
        lastMessagePreview = '💳 [Chia sẻ giao dịch] ${msg.content}';
      } else if (msg.type == MessageType.moneyRequest) {
        lastMessagePreview = '💸 [Yêu cầu chuyển tiền] ${msg.content}';
      } else if (msg.type == MessageType.image) {
        lastMessagePreview = '📷 [Hình ảnh]';
      } else {
        lastMessagePreview = msg.content;
      }
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Avatar + Online status badge
            Stack(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: AppColors.primaryLight,
                  child: Text(
                    conversation.participant.displayName.isNotEmpty
                        ? conversation.participant.displayName[0].toUpperCase()
                        : '?',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                if (conversation.participant.isOnline)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 13,
                      height: 13,
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark ? AppColors.darkSurface : Colors.white,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),

            // Tên người nhận & Nội dung tin nhắn cuối
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        conversation.participant.displayName,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: conversation.unreadCount > 0
                              ? FontWeight.w700
                              : FontWeight.w600,
                          color: isDark
                              ? AppColors.darkForeground
                              : AppColors.lightForeground,
                        ),
                      ),
                      Text(
                        timeStr,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: conversation.unreadCount > 0
                              ? AppColors.primary
                              : AppColors.lightMuted,
                          fontWeight: conversation.unreadCount > 0
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          lastMessagePreview,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: conversation.unreadCount > 0
                                ? (isDark
                                    ? AppColors.darkForeground
                                    : AppColors.lightForeground)
                                : AppColors.lightMuted,
                            fontWeight: conversation.unreadCount > 0
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                      if (conversation.unreadCount > 0)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            conversation.unreadCount.toString(),
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
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
    );
  }
}

