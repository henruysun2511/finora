import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/conversation.dart';
import 'messages_providers.dart';

final messageSearchQueryProvider = StateProvider.autoDispose<String>((ref) => '');

final conversationListProvider =
    AsyncNotifierProvider.autoDispose<ConversationListNotifier, List<Conversation>>(() {
  return ConversationListNotifier();
});

class ConversationListNotifier extends AutoDisposeAsyncNotifier<List<Conversation>> {
  Timer? _debounce;

  @override
  Future<List<Conversation>> build() async {
    ref.onDispose(() => _debounce?.cancel());
    final search = ref.watch(messageSearchQueryProvider);
    final repo = ref.read(messagesRepositoryProvider);
    return repo.getConversations(search: search.isNotEmpty ? search : null);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final search = ref.read(messageSearchQueryProvider);
      final repo = ref.read(messagesRepositoryProvider);
      return repo.getConversations(search: search.isNotEmpty ? search : null);
    });
  }

  void onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      ref.read(messageSearchQueryProvider.notifier).state = query.trim();
    });
  }
}
