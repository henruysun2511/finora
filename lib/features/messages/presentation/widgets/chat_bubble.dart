import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../domain/models/direct_message.dart';
import 'chat_transaction_card.dart';

class ChatBubble extends StatelessWidget {
  const ChatBubble({
    super.key,
    required this.message,
    this.isGroup = false,
    this.onToggleReaction,
    this.onRecall,
    this.onViewTransaction,
  });

  final DirectMessage message;
  final bool isGroup;
  final void Function(String emoji)? onToggleReaction;
  final VoidCallback? onRecall;
  final VoidCallback? onViewTransaction;

  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  void _showMessageActions(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        final surface = isDark ? AppColors.darkSurface : Colors.white;
        final foreground = isDark ? AppColors.darkForeground : AppColors.lightForeground;
        final muted = isDark ? AppColors.darkMuted : AppColors.lightMuted;
        final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(top: BorderSide(color: border)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      color: muted.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // Emoji Reaction Bar
                if (!message.isRecalled) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkBackground : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: border),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: ['❤️', '👍', '😂', '😮', '😢', '👏', '😡'].map((emoji) {
                        final isSelected = message.reactions.contains(emoji);
                        return GestureDetector(
                          onTap: () {
                            Navigator.pop(ctx);
                            onToggleReaction?.call(emoji);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected
                                  ? AppColors.primary.withValues(alpha: 0.15)
                                  : Colors.transparent,
                            ),
                            child: Text(emoji, style: const TextStyle(fontSize: 24)),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // Copy Action
                if (!message.isRecalled)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.copy_rounded, color: AppColors.primary),
                    title: Text(
                      'Sao chép tin nhắn',
                      style: TextStyle(color: foreground, fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    onTap: () {
                      Navigator.pop(ctx);
                      Clipboard.setData(ClipboardData(text: message.content));
                      AppToast.success(context, 'Đã sao chép tin nhắn vào bộ nhớ tạm');
                    },
                  ),

                // Recall Action
                if (message.isMe && !message.isRecalled)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.undo_rounded, color: AppColors.danger),
                    title: const Text(
                      'Thu hồi tin nhắn',
                      style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.w700, fontSize: 14),
                    ),
                    subtitle: Text(
                      'Thu hồi trong vòng 15 phút kể từ lúc gửi',
                      style: TextStyle(color: muted, fontSize: 11),
                    ),
                    onTap: () {
                      Navigator.pop(ctx);
                      onRecall?.call();
                    },
                  ),
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
    final surface = isDark ? AppColors.darkSurface : Colors.white;
    final foreground = isDark ? AppColors.darkForeground : AppColors.lightForeground;
    final muted = isDark ? AppColors.darkMuted : AppColors.lightMuted;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    final isMe = message.isMe;

    if (message.type == MessageType.transactionShare && message.relatedTransaction != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isMe && isGroup) const SizedBox(width: 32),
            ChatTransactionCard(
              transaction: message.relatedTransaction!,
              isMe: isMe,
              time: _formatTime(message.createdAt),
              content: message.content,
              senderName: message.senderName,
              onViewDetail: onViewTransaction,
            ),
          ],
        ),
      );
    }

    final isRecalled = message.isRecalled;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe && isGroup) ...[
            Container(
              width: 26,
              height: 26,
              margin: const EdgeInsets.only(right: 6, bottom: 2),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFF0072D6), Color(0xFF0284C7)],
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                message.senderName.isNotEmpty
                    ? message.senderName.substring(0, 1).toUpperCase()
                    : '?',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 10),
              ),
            ),
          ],

          Flexible(
            child: Column(
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (!isMe && isGroup)
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 2),
                    child: Text(
                      message.senderName,
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: muted),
                    ),
                  ),

                GestureDetector(
                  onLongPress: () => _showMessageActions(context),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                        decoration: BoxDecoration(
                          color: isRecalled
                              ? (isDark ? AppColors.darkSurface : const Color(0xFFF1F5F9))
                              : (isMe ? AppColors.primary : surface),
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(18),
                            topRight: const Radius.circular(18),
                            bottomLeft: Radius.circular(isMe ? 18 : 4),
                            bottomRight: Radius.circular(isMe ? 4 : 18),
                          ),
                          border: (isMe && !isRecalled) ? null : Border.all(color: border),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: isRecalled
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.info_outline_rounded, size: 14, color: muted),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Tin nhắn đã được thu hồi',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontStyle: FontStyle.italic,
                                      color: muted,
                                    ),
                                  ),
                                ],
                              )
                            : Text(
                                message.content,
                                style: TextStyle(
                                  fontSize: 14,
                                  height: 1.35,
                                  color: isMe ? Colors.white : foreground,
                                ),
                              ),
                      ),

                      // Floating Reactions Pill
                      if (!isRecalled && message.reactions.isNotEmpty)
                        Positioned(
                          bottom: -10,
                          right: isMe ? 4 : null,
                          left: isMe ? null : 4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: border, width: 0.8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.08),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  message.reactions.take(3).join(' '),
                                  style: const TextStyle(fontSize: 12),
                                ),
                                if (message.reactions.length > 1) ...[
                                  const SizedBox(width: 3),
                                  Text(
                                    '${message.reactions.length}',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: muted,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(height: (!isRecalled && message.reactions.isNotEmpty) ? 12 : 2),
                Text(
                  _formatTime(message.createdAt),
                  style: TextStyle(fontSize: 10, color: muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
