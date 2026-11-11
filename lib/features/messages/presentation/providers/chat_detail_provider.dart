import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/direct_message.dart';
import 'conversation_list_provider.dart';
import 'messages_providers.dart';

class ChatDetailState {
  const ChatDetailState({
    this.messages = const [],
    this.page = 1,
    this.hasMore = true,
    this.isLoadingMore = false,
  });

  /// Danh sách tin nhắn sắp xếp: index 0 là tin mới nhất (render ở đáy khung chat),
  /// các index tiếp theo là tin cũ hơn dần (render hướng lên trên).
  final List<DirectMessage> messages;
  final int page;
  final bool hasMore;
  final bool isLoadingMore;

  ChatDetailState copyWith({
    List<DirectMessage>? messages,
    int? page,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return ChatDetailState(
      messages: messages ?? this.messages,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

final chatDetailProvider =
    AsyncNotifierProvider.family.autoDispose<ChatDetailNotifier, ChatDetailState, String>(() {
  return ChatDetailNotifier();
});

class ChatDetailNotifier extends AutoDisposeFamilyAsyncNotifier<ChatDetailState, String> {
  @override
  Future<ChatDetailState> build(String arg) async {
    final repo = ref.read(messagesRepositoryProvider);
    // Tự động đánh dấu đã đọc
    repo.markAsRead(arg);

    final list = await repo.getMessages(arg, page: 1, limit: 30);
    return ChatDetailState(
      messages: list,
      page: 1,
      hasMore: list.length >= 30,
      isLoadingMore: false,
    );
  }

  /// Tải thêm tin nhắn cũ hơn khi cuộn lên trên (Infinite Scroll)
  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || current.isLoadingMore || !current.hasMore) return;

    state = AsyncData(current.copyWith(isLoadingMore: true));

    try {
      final repo = ref.read(messagesRepositoryProvider);
      final nextPage = current.page + 1;
      final olderMessages = await repo.getMessages(arg, page: nextPage, limit: 30);

      final combined = [...current.messages, ...olderMessages];
      state = AsyncData(current.copyWith(
        messages: combined,
        page: nextPage,
        hasMore: olderMessages.length >= 30,
        isLoadingMore: false,
      ));
    } catch (_) {
      state = AsyncData(current.copyWith(isLoadingMore: false));
    }
  }

  Future<void> sendTextMessage(String text) async {
    final currentState = state.value ?? const ChatDetailState();
    final repo = ref.read(messagesRepositoryProvider);

    // Optimistic UI: Chèn tin nhắn mới nhất vào đầu danh sách (index 0)
    final tempMsg = DirectMessage(
      id: 'temp-${DateTime.now().millisecondsSinceEpoch}',
      senderId: 'me',
      senderName: 'Tôi',
      content: text,
      isMe: true,
      createdAt: DateTime.now(),
    );

    state = AsyncData(currentState.copyWith(
      messages: [tempMsg, ...currentState.messages],
    ));

    try {
      final saved = await repo.sendMessage(conversationId: arg, content: text);
      final updated = (state.value?.messages ?? []).map((m) => m.id == tempMsg.id ? saved : m).toList();
      state = AsyncData((state.value ?? currentState).copyWith(messages: updated));
      ref.invalidate(conversationListProvider);
    } catch (e) {
      // Hoàn tác nếu lỗi
      state = AsyncData(currentState);
      rethrow;
    }
  }

  /// Thả hoặc gỡ cảm xúc trên tin nhắn
  Future<void> toggleReaction(String messageId, String emoji) async {
    final currentState = state.value;
    if (currentState == null) return;
    final currentList = currentState.messages;
    final idx = currentList.indexWhere((m) => m.id == messageId);
    if (idx == -1) return;

    final target = currentList[idx];
    final hasSame = target.reactions.contains(emoji);
    final nextReactions = hasSame
        ? target.reactions.where((e) => e != emoji).toList()
        : [...target.reactions.where((e) => e != emoji), emoji];

    final updated = List<DirectMessage>.from(currentList);
    updated[idx] = target.copyWith(reactions: nextReactions);
    state = AsyncData(currentState.copyWith(messages: updated));

    final repo = ref.read(messagesRepositoryProvider);
    try {
      if (hasSame) {
        await repo.removeReaction(messageId);
      } else {
        await repo.addReaction(messageId: messageId, emoji: emoji);
      }
    } catch (e) {
      state = AsyncData(currentState);
      rethrow;
    }
  }

  /// Thu hồi tin nhắn (chỉ người gửi mới có quyền)
  Future<void> recallMessage(String messageId) async {
    final currentState = state.value;
    if (currentState == null) return;
    final currentList = currentState.messages;
    final idx = currentList.indexWhere((m) => m.id == messageId);
    if (idx == -1) return;

    final target = currentList[idx];
    if (!target.isMe) return;

    final updated = List<DirectMessage>.from(currentList);
    updated[idx] = target.copyWith(
      content: 'Tin nhắn đã được thu hồi',
      isRecalled: true,
    );
    state = AsyncData(currentState.copyWith(messages: updated));

    final repo = ref.read(messagesRepositoryProvider);
    try {
      await repo.recallMessage(messageId);
    } catch (e) {
      state = AsyncData(currentState);
      rethrow;
    }
  }
}
