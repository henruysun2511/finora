import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/conversation.dart';
import 'message_filter_provider.dart';
import 'message_providers.dart';

class ConversationsNotifier extends AsyncNotifier<List<Conversation>> {
  @override
  Future<List<Conversation>> build() async {
    final filter = ref.watch(messageFilterProvider);
    final repo = ref.watch(messageRepositoryProvider);
    return repo.getConversations(filter: filter);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => build());
  }

  Future<void> markAsRead(String conversationId) async {
    await ref.read(messageRepositoryProvider).markConversationAsRead(conversationId);
    final current = state.value;
    if (current != null) {
      state = AsyncData(
        current.map((c) {
          if (c.id == conversationId) {
            return c.copyWith(unreadCount: 0);
          }
          return c;
        }).toList(),
      );
    }
  }

  Future<void> deleteConversation(String conversationId) async {
    await ref.read(messageRepositoryProvider).deleteConversation(conversationId);
    final current = state.value;
    if (current != null) {
      state = AsyncData(
        current.where((c) => c.id != conversationId).toList(),
      );
    }
  }
}

final conversationsProvider =
    AsyncNotifierProvider<ConversationsNotifier, List<Conversation>>(
  ConversationsNotifier.new,
);

