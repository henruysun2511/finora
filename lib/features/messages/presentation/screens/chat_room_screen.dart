import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/lucide_icon.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/models/message_attachment.dart';
import '../../domain/models/message_enums.dart';
import '../../domain/models/message_input.dart';
import '../providers/chat_room_provider.dart';
import '../widgets/message_input_bar.dart';
import '../widgets/p2p_chat_bubble.dart';

class ChatRoomScreen extends ConsumerStatefulWidget {
  const ChatRoomScreen({
    super.key,
    required this.conversationId,
    required this.receiverId,
    required this.receiverName,
    this.receiverAvatar,
  });

  final String conversationId;
  final String receiverId;
  final String receiverName;
  final String? receiverAvatar;

  @override
  ConsumerState<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends ConsumerState<ChatRoomScreen> {
  final _scrollController = ScrollController();

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _handleSendMessage(String content, MessageTransactionAttachment? attachment) async {
    final input = SendMessageInput(
      receiverId: widget.receiverId,
      conversationId: widget.conversationId,
      content: content.isEmpty ? (attachment?.title ?? 'Đính kèm') : content,
      type: attachment != null ? MessageType.transactionShare : MessageType.text,
      transactionAttachment: attachment,
    );

    final success = await ref
        .read(chatRoomProvider(widget.conversationId).notifier)
        .sendMessage(input);

    if (success) {
      _scrollToBottom();
    } else {
      if (mounted) {
        final err = ref.read(chatRoomProvider(widget.conversationId)).value?.errorMessage;
        if (err != null) {
          AppToast.show(context, message: err, type: ToastType.error);
        }
      }
    }
  }

  PreferredSizeWidget _buildChatHeader(BuildContext context, bool isDark) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(60),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          border: Border(
            bottom: BorderSide(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                // Nút quay lại
                InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: LucideIcon(
                      name: 'arrow-left',
                      size: 18,
                      color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Avatar và trạng thái online
                Stack(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFFF59E0B), Color(0xFFEA580C)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        image: widget.receiverAvatar != null && widget.receiverAvatar!.isNotEmpty
                            ? DecorationImage(
                                image: NetworkImage(widget.receiverAvatar!),
                                fit: BoxFit.cover,
                              )
                            : null,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFF59E0B).withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: widget.receiverAvatar == null || widget.receiverAvatar!.isEmpty
                          ? Text(
                              widget.receiverName.isNotEmpty
                                  ? widget.receiverName.trim().split(' ').last.characters.first.toUpperCase()
                                  : '?',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                              ),
                            )
                          : null,
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 11,
                        height: 11,
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981),
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
                const SizedBox(width: 10),

                // Tên người nhận & trạng thái
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              widget.receiverName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w800,
                                color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          const LucideIcon(name: 'sparkles', size: 13, color: Color(0xFFF59E0B)),
                        ],
                      ),
                      const SizedBox(height: 1),
                      Row(
                        children: [
                          Container(
                            width: 5,
                            height: 5,
                            decoration: const BoxDecoration(
                              color: Color(0xFF10B981),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Đang hoạt động',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF10B981),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Hành động bảo mật FinTech
                InkWell(
                  onTap: () {
                    AppToast.show(
                      context,
                      message: 'Cuộc trò chuyện bảo mật FinTech được mã hoá đầu cuối!',
                      type: ToastType.success,
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: LucideIcon(
                      name: 'shield-check',
                      size: 17,
                      color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final chatStateAsync = ref.watch(chatRoomProvider(widget.conversationId));
    final currentUserId = ref.watch(authNotifierProvider).value?.id;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: _buildChatHeader(context, isDark),
      body: Column(
        children: [
          // Banner nhắc nhở bảo mật FinTech
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: AppColors.primaryLight.withValues(alpha: 0.6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const LucideIcon(name: 'lock', size: 14, color: AppColors.primary),
                const SizedBox(width: 6),
                Text(
                  'Cuộc trò chuyện được mã hoá riêng tư',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),

          // Danh sách tin nhắn
          Expanded(
            child: chatStateAsync.when(
              data: (state) {
                WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

                if (state.messages.isEmpty) {
                  return Center(
                    child: Text(
                      'Gửi lời chào hoặc chia sẻ hoá đơn để bắt đầu!',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.lightMuted,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: state.messages.length,
                  itemBuilder: (context, index) {
                    final msg = state.messages[index];
                    final isMine = (currentUserId != null && msg.senderId == currentUserId) ||
                        (currentUserId == null && msg.senderId == 'me');

                    return P2pChatBubble(
                      message: msg,
                      isMine: isMine,
                      onToggleReaction: (emoji) {
                        if (currentUserId != null) {
                          ref
                              .read(chatRoomProvider(widget.conversationId).notifier)
                              .toggleReaction(msg.id, emoji, currentUserId);
                        }
                      },
                      onRecall: isMine
                          ? () {
                              ref
                                  .read(chatRoomProvider(widget.conversationId).notifier)
                                  .recallMessage(msg.id);
                            }
                          : null,
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(
                child: Text('Lỗi: $err', style: const TextStyle(color: AppColors.danger)),
              ),
            ),
          ),

          // Thanh nhập tin nhắn
          MessageInputBar(
            isSending: chatStateAsync.value?.isSending ?? false,
            onSend: _handleSendMessage,
          ),
        ],
      ),
    );
  }
}
