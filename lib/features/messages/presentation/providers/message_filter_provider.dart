import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/message_filter.dart';

class MessageFilterNotifier extends Notifier<MessageFilter> {
  @override
  MessageFilter build() => const MessageFilter();

  void setSearchQuery(String? query) {
    state = state.copyWith(searchQuery: query);
  }

  void toggleUnreadOnly() {
    state = state.copyWith(unreadOnly: !state.unreadOnly);
  }
}

final messageFilterProvider =
    NotifierProvider<MessageFilterNotifier, MessageFilter>(
  MessageFilterNotifier.new,
);

