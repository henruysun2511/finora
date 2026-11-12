import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/direct_message.dart';
import 'conversation_list_provider.dart';
import 'messages_providers.dart';

final chatDetailProvider =
    AsyncNotifierProvider.family.autoDispose<ChatDetailNotifier, List<DirectMessage>, String>(() {
  return ChatDetailNotifier();
});

class ChatDetailNotifier extends AutoDisposeFamilyAsyncNotifier<List<DirectMessage>, String> {
  int _page = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;

  @override
  Future<List<DirectMessage>> build(String arg) async {
    _page = 1;
    _hasMore = true;
    _isLoadingMore = false;

    final repo = ref.read(messagesRepositoryProvider);
    // Tự động đánh dấu đã đọc
    repo.markAsRead(arg);

    final list = await repo.getMessages(arg, page: 1, limit: 30);
    _hasMore = list.length >= 30;
    return list;
  }

  /// Tải thêm tin nhắn cũ hơn khi cuộn lên trên (Infinite Scroll)
  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasMore) return;
    final currentList = state.value;
    if (currentList == null) return;

    _isLoadingMore = true;

    try {
      final repo = ref.read(messagesRepositoryProvider);
      final nextPage = _page + 1;
      final olderMessages = await repo.getMessages(arg, page: nextPage, limit: 30);

      _page = nextPage;
      _hasMore = olderMessages.length >= 30;
      _isLoadingMore = false;

      state = AsyncData([...currentList, ...olderMessages]);
    } catch (_) {
      _isLoadingMore = false;
    }
  }

  Future<void> sendTextMessage(String text) async {
    final currentList = state.value ?? [];
    final repo = ref.read(messagesRepositoryProvider);

    // Optimistic UI: chèn tin nhắn mới nhất vào đầu danh sách (index 0 - đáy khung chat)
    final tempMsg = DirectMessage(
      id: 'temp-${DateTime.now().millisecondsSinceEpoch}',
      senderId: 'me',
      senderName: 'Tôi',
      content: text,
      isMe: true,
      createdAt: DateTime.now(),
    );

    state = AsyncData([tempMsg, ...currentList]);

    try {
      final saved = await repo.sendMessage(conversationId: arg, content: text);
      final updated = (state.value ?? []).map((m) => m.id == tempMsg.id ? saved : m).toList();
      state = AsyncData(updated);
      ref.invalidate(conversationListProvider);
    } catch (e) {
      // Hoàn tác nếu lỗi
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
