import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../domain/models/message_input.dart';
import 'chat_room_state.dart';
import 'conversations_provider.dart';
import 'message_providers.dart';

class ChatRoomNotifier extends AutoDisposeFamilyAsyncNotifier<ChatRoomState, String> {
  @override
  Future<ChatRoomState> build(String arg) async {
    // arg có thể là conversationId hoặc friendId
    final repo = ref.watch(messageRepositoryProvider);
    final msgs = await repo.getMessages(conversationId: arg);
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

      // Invalidate danh sách hội thoại để cập nhật lastMessage
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
}

final chatRoomProvider = AsyncNotifierProvider.autoDispose
    .family<ChatRoomNotifier, ChatRoomState, String>(
  ChatRoomNotifier.new,
);

