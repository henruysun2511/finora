import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/page_header.dart';
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
  });

  final String conversationId;
  final String receiverId;
  final String receiverName;

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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final chatStateAsync = ref.watch(chatRoomProvider(widget.conversationId));

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: PageHeader.subPage(
        title: widget.receiverName,
        subtitle: 'Trò chuyện bảo mật & Tế nhị',
      ),
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
                const Icon(Icons.lock_outline_rounded, size: 14, color: AppColors.primary),
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
                    return P2pChatBubble(
                      message: msg,
                      isMine: msg.isMine('me'),
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

