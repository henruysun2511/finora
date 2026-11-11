import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/direct_message.dart';
import 'conversation_list_provider.dart';
import 'messages_providers.dart';

final chatDetailProvider =
    AsyncNotifierProvider.family.autoDispose<ChatDetailNotifier, List<DirectMessage>, String>(() {
  return ChatDetailNotifier();
});

class ChatDetailNotifier extends AutoDisposeFamilyAsyncNotifier<List<DirectMessage>, String> {
  @override
  Future<List<DirectMessage>> build(String arg) async {
    final repo = ref.read(messagesRepositoryProvider);
    // Tự động đánh dấu đã đọc
    repo.markAsRead(arg);
    return repo.getMessages(arg);
  }

  Future<void> sendTextMessage(String text) async {
    final currentList = state.value ?? [];
    final repo = ref.read(messagesRepositoryProvider);

    // Optimistic UI
    final tempMsg = DirectMessage(
      id: 'temp-${DateTime.now().millisecondsSinceEpoch}',
      senderId: 'me',
      senderName: 'Tôi',
      content: text,
      isMe: true,
      createdAt: DateTime.now(),
    );

    state = AsyncData([...currentList, tempMsg]);

    try {
      final saved = await repo.sendMessage(conversationId: arg, content: text);
      final updated = (state.value ?? []).map((m) => m.id == tempMsg.id ? saved : m).toList();
      state = AsyncData(updated);
      ref.invalidate(conversationListProvider);
    } catch (e) {
      // Revert if error
      state = AsyncData(currentList);
      rethrow;
    }
  }

  /// Thả hoặc gỡ cảm xúc trên tin nhắn
  Future<void> toggleReaction(String messageId, String emoji) async {
    final currentList = state.value ?? [];
    final idx = currentList.indexWhere((m) => m.id == messageId);
    if (idx == -1) return;

    final target = currentList[idx];
    final hasSame = target.reactions.contains(emoji);
    final nextReactions = hasSame
        ? target.reactions.where((e) => e != emoji).toList()
        : [...target.reactions.where((e) => e != emoji), emoji];

    final updated = List<DirectMessage>.from(currentList);
    updated[idx] = target.copyWith(reactions: nextReactions);
    state = AsyncData(updated);

    final repo = ref.read(messagesRepositoryProvider);
    try {
      if (hasSame) {
        await repo.removeReaction(messageId);
      } else {
        await repo.addReaction(messageId: messageId, emoji: emoji);
      }
    } catch (e) {
      state = AsyncData(currentList);
      rethrow;
    }
  }

  /// Thu hồi tin nhắn (chỉ người gửi mới có quyền)
  Future<void> recallMessage(String messageId) async {
    final currentList = state.value ?? [];
    final idx = currentList.indexWhere((m) => m.id == messageId);
    if (idx == -1) return;

    final target = currentList[idx];
    if (!target.isMe) return;

    final updated = List<DirectMessage>.from(currentList);
    updated[idx] = target.copyWith(
      content: 'Tin nhắn đã được thu hồi',
      isRecalled: true,
    );
    state = AsyncData(updated);

    final repo = ref.read(messagesRepositoryProvider);
    try {
      await repo.recallMessage(messageId);
    } catch (e) {
      state = AsyncData(currentList);
      rethrow;
    }
  }
}
