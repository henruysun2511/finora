import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../domain/models/conversation.dart';
import '../providers/chat_detail_provider.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/chat_input_bar.dart';

class ChatDetailScreen extends ConsumerStatefulWidget {
  const ChatDetailScreen({super.key, required this.conversation});
  final Conversation conversation;

  @override
  ConsumerState<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends ConsumerState<ChatDetailScreen> {
  final ScrollController _scrollController = ScrollController();

  LinearGradient _avatarGradient(String seed) {
    final gradients = [
      const LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFEA580C)], begin: Alignment.topLeft, end: Alignment.bottomRight),
      const LinearGradient(colors: [Color(0xFF0072D6), Color(0xFF0284C7)], begin: Alignment.topLeft, end: Alignment.bottomRight),
      const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF059669)], begin: Alignment.topLeft, end: Alignment.bottomRight),
      const LinearGradient(colors: [Color(0xFFEC4899), Color(0xFFDB2777)], begin: Alignment.topLeft, end: Alignment.bottomRight),
      const LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)], begin: Alignment.topLeft, end: Alignment.bottomRight),
      const LinearGradient(colors: [Color(0xFF06B6D4), Color(0xFF0284C7)], begin: Alignment.topLeft, end: Alignment.bottomRight),
    ];
    return gradients[seed.hashCode.abs() % gradients.length];
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.darkSurface : Colors.white;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final foreground = isDark ? AppColors.darkForeground : AppColors.lightForeground;
    final muted = isDark ? AppColors.darkMuted : AppColors.lightMuted;

    final conv = widget.conversation;
    final messagesAsync = ref.watch(chatDetailProvider(conv.id));

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: surface,
        elevation: 0,
        scrolledUnderElevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: foreground),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: _avatarGradient(conv.id),
              ),
              alignment: Alignment.center,
              child: Text(
                conv.initials,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    conv.title,
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: foreground),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (conv.isGroup)
                    Text(
                      conv.groupWalletName != null
                          ? '${conv.groupWalletName!} · ${conv.membersCount ?? 5} thành viên'
                          : 'Nhóm thảo luận hóa đơn chia tiền',
                      style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600),
                    )
                  else if (conv.isOnline)
                    const Text(
                      'Đang hoạt động',
                      style: TextStyle(fontSize: 11, color: AppColors.success, fontWeight: FontWeight.w600),
                    )
                  else
                    Text('Trò chuyện 1-1', style: TextStyle(fontSize: 11, color: muted)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline_rounded, color: muted),
            tooltip: 'Chi tiết nhóm/ví',
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Banner Ví chung nếu là Group Chat ──
          if (conv.isGroup)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: AppColors.primary.withValues(alpha: 0.08),
              child: Row(
                children: [
                  const Icon(Icons.account_balance_wallet_rounded, size: 16, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Mọi người trong nhóm có thể gửi và xem hóa đơn chia tiền tại đây.',
                      style: TextStyle(fontSize: 12, color: foreground, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),

          // ── Messages List ──
          Expanded(
            child: messagesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(
                child: Text('Lỗi tải tin nhắn: $err', style: TextStyle(color: muted)),
              ),
              data: (messages) {
                WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

                if (messages.isEmpty) {
                  return Center(
                    child: Text(
                      'Gửi tin nhắn đầu tiên để bắt đầu! 👋',
                      style: TextStyle(fontSize: 13, color: muted),
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  itemCount: messages.length,
                  itemBuilder: (ctx, i) {
                    final msg = messages[i];
                    return ChatBubble(
                      message: msg,
                      isGroup: conv.isGroup,
                    );
                  },
                );
              },
            ),
          ),

          // ── Input Bar ──
          ChatInputBar(
            isGroup: conv.isGroup,
            onSendText: (text) {
              ref.read(chatDetailProvider(conv.id).notifier).sendTextMessage(text);
              _scrollToBottom();
            },
            onSendTransaction: ({required name, required amount, isExpense = true, groupWalletName}) {
              ref.read(chatDetailProvider(conv.id).notifier).sendTransactionShare(
                    name: name,
                    amount: amount,
                    isExpense: isExpense,
                    groupWalletName: groupWalletName,
                  );
              _scrollToBottom();
            },
          ),
        ],
      ),
    );
  }
}
