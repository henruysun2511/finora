import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/page_header.dart';
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

  String _formatError(dynamic e) {
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map && data['message'] != null) {
        final msg = data['message'];
        if (msg is List && msg.isNotEmpty) return msg.join(', ');
        return msg.toString();
      }
    }
    return e?.toString() ?? 'Đã có lỗi xảy ra';
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

  void _showConversationInfo(BuildContext context) {
    final conv = widget.conversation;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.darkSurface : Colors.white;
    final foreground = isDark ? AppColors.darkForeground : AppColors.lightForeground;
    final muted = isDark ? AppColors.darkMuted : AppColors.lightMuted;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
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
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: muted.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0072D6), Color(0xFF0284C7)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    conv.initials,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  conv.title,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: foreground),
                ),
                const SizedBox(height: 4),
                Text(
                  conv.isGroup
                      ? (conv.groupWalletName ?? 'Nhóm thảo luận hóa đơn chia tiền')
                      : 'Bạn bè kết nối tài chính Finora',
                  style: TextStyle(fontSize: 13, color: muted),
                ),
                const SizedBox(height: 20),
                Divider(color: border, height: 1),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.receipt_long_rounded, color: AppColors.primary, size: 20),
                  ),
                  title: Text(
                    'Chia sẻ hóa đơn',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: foreground),
                  ),
                  subtitle: Text(
                    'Hỗ trợ đính kèm chi tiêu và chia bill vào cuộc trò chuyện',
                    style: TextStyle(fontSize: 12, color: muted),
                  ),
                ),
                if (conv.isGroup)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.account_balance_wallet_rounded, color: AppColors.success, size: 20),
                    ),
                    title: Text(
                      'Ví chung kết nối',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: foreground),
                    ),
                    subtitle: Text(
                      conv.groupWalletName ?? 'Ví quỹ nhóm',
                      style: TextStyle(fontSize: 12, color: muted),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final foreground = isDark ? AppColors.darkForeground : AppColors.lightForeground;
    final muted = isDark ? AppColors.darkMuted : AppColors.lightMuted;

    final conv = widget.conversation;
    final messagesAsync = ref.watch(chatDetailProvider(conv.id));

    final subtitle = conv.isGroup
        ? (conv.groupWalletName != null
            ? '${conv.groupWalletName!} · ${conv.membersCount ?? 5} thành viên'
            : 'Nhóm thảo luận hóa đơn')
        : (conv.isOnline ? 'Đang hoạt động' : 'Trò chuyện 1-1');

    return Scaffold(
      backgroundColor: bg,
      appBar: PageHeader.subPage(
        title: conv.title,
        subtitle: subtitle,
        onBack: () => Navigator.pop(context),
        action: IconButton(
          icon: const Icon(Icons.info_outline_rounded, color: AppColors.primary),
          tooltip: 'Thông tin',
          onPressed: () => _showConversationInfo(context),
        ),
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
                      onToggleReaction: (emoji) async {
                        try {
                          await ref.read(chatDetailProvider(conv.id).notifier).toggleReaction(msg.id, emoji);
                        } catch (e) {
                          if (context.mounted) {
                            AppToast.error(context, 'Không thể thả cảm xúc: ${_formatError(e)}');
                          }
                        }
                      },
                      onRecall: () async {
                        try {
                          await ref.read(chatDetailProvider(conv.id).notifier).recallMessage(msg.id);
                          if (context.mounted) {
                            AppToast.success(context, 'Đã thu hồi tin nhắn');
                          }
                        } catch (e) {
                          if (context.mounted) {
                            AppToast.error(context, 'Thu hồi thất bại: ${_formatError(e)}');
                          }
                        }
                      },
                    );
                  },
                );
              },
            ),
          ),

          // ── Input Bar ──
          ChatInputBar(
            isGroup: conv.isGroup,
            onSendText: (text) async {
              try {
                await ref.read(chatDetailProvider(conv.id).notifier).sendTextMessage(text);
                _scrollToBottom();
              } catch (e) {
                if (context.mounted) {
                  AppToast.error(context, 'Không thể gửi tin nhắn: ${_formatError(e)}');
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
