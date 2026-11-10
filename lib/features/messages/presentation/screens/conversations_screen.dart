import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/page_header.dart';
import '../providers/conversations_provider.dart';
import '../widgets/conversation_card.dart';
import '../widgets/message_search_bar.dart';
import 'chat_room_screen.dart';

class ConversationsScreen extends ConsumerWidget {
  const ConversationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final convsAsync = ref.watch(conversationsProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: PageHeader.page(
        title: 'Tin nhắn Finora',
        subtitle: 'Trò chuyện tài chính tế nhị & Chia sẻ giao dịch',
        action: IconButton(
          icon: const Icon(Icons.mark_chat_read_outlined),
          tooltip: 'Làm mới',
          onPressed: () => ref.read(conversationsProvider.notifier).refresh(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(conversationsProvider.notifier).refresh(),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            // Ô tìm kiếm có debounce 400ms
            const MessageSearchBar(),
            const SizedBox(height: 16),

            // Danh sách hội thoại
            convsAsync.when(
              data: (items) {
                if (items.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 48),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline_rounded,
                            size: 56,
                            color: AppColors.lightMuted.withValues(alpha: 0.6),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Chưa có cuộc trò chuyện nào',
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.lightMuted,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Hãy kết nối với bạn bè để bắt đầu chia sẻ chi tiêu!',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: AppColors.lightMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final conv = items[index];
                    return Dismissible(
                      key: Key(conv.id),
                      direction: DismissDirection.endToStart,
                      confirmDismiss: (_) async {
                        return await showConfirmDialog(
                          context,
                          title: 'Xóa cuộc trò chuyện?',
                          message: 'Toàn bộ tin nhắn với người này sẽ bị xóa.',
                          confirmText: 'Xóa',
                          isDestructive: true,
                        );
                      },
                      onDismissed: (_) {
                        ref.read(conversationsProvider.notifier).deleteConversation(conv.id);
                        AppToast.show(context, message: 'Đã xóa cuộc trò chuyện', type: ToastType.info);
                      },
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(
                          color: AppColors.danger,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
                      ),
                      child: ConversationCard(
                        conversation: conv,
                        onTap: () {
                          // Đánh dấu đã đọc
                          if (conv.unreadCount > 0) {
                            ref.read(conversationsProvider.notifier).markAsRead(conv.id);
                          }

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatRoomScreen(
                                conversationId: conv.id,
                                receiverId: conv.participant.id,
                                receiverName: conv.participant.displayName,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (err, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Đã có lỗi xảy ra: $err',
                    style: const TextStyle(color: AppColors.danger),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

