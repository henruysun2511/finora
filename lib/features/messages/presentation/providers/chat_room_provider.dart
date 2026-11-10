import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../domain/models/message_input.dart';
import 'chat_room_state.dart';
import 'conversations_provider.dart';
import 'message_providers.dart';

class ChatRoomNotifier
    extends AutoDisposeFamilyAsyncNotifier<ChatRoomState, String> {
  @override
  Future<ChatRoomState> build(String arg) async {
    // arg chính là friendId của bạn bè đang chat
    final repo = ref.watch(messageRepositoryProvider);
    final msgs = await repo.getMessages(friendId: arg, conversationId: arg);

    // Tự động đánh dấu các tin nhắn từ bạn này thành đã đọc
    repo.markConversationAsRead(arg).ignore();

    return ChatRoomState(messages: msgs);
  }

  Future<bool> sendMessage(SendMessageInput input) async {
    final current = state.value;
    if (current == null || current.isSending) return false;

    state = AsyncData(current.copyWith(isSending: true, clearError: true));

    try {
      final repo = ref.read(messageRepositoryProvider);
      final sent = await repo.sendMessage(input);

      // Cập nhật tin nhắn vào danh sách hiện tại
      state = AsyncData(current.copyWith(
        messages: [...current.messages, sent],
        isSending: false,
      ));

      // Invalidate danh sách hội thoại để cập nhật tin nhắn cuối
      ref.invalidate(conversationsProvider);
      return true;
    } catch (e) {
      final msg = e is AppException ? e.message : e.toString();
      state = AsyncData(current.copyWith(
        isSending: false,
        errorMessage: msg,
      ));
      return false;
    }
  }

  /// Thu hồi tin nhắn
  Future<bool> recallMessage(String messageId) async {
    final current = state.value;
    if (current == null) return false;

    try {
      final repo = ref.read(messageRepositoryProvider);
      await repo.recallMessage(messageId);
      state = AsyncData(current.copyWith(
        messages: current.messages.where((m) => m.id != messageId).toList(),
      ));
      ref.invalidate(conversationsProvider);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Thả hoặc gỡ cảm xúc trên tin nhắn
  Future<void> toggleReaction(
      String messageId, String emoji, String currentUserId) async {
    final current = state.value;
    if (current == null) return;

    final repo = ref.read(messageRepositoryProvider);
    final msg = current.messages.firstWhere((m) => m.id == messageId);
    final hasReactedSame =
        msg.reactions.any((r) => r.userId == currentUserId && r.emoji == emoji);

    try {
      if (hasReactedSame) {
        await repo.removeReaction(messageId);
      } else {
        await repo.addReaction(messageId, emoji);
      }

      final updated =
          await repo.getMessages(friendId: arg, conversationId: arg);
      state = AsyncData(current.copyWith(messages: updated));
    } catch (_) {}
  }
}

final chatRoomProvider = AsyncNotifierProvider.autoDispose
    .family<ChatRoomNotifier, ChatRoomState, String>(
  ChatRoomNotifier.new,
);
