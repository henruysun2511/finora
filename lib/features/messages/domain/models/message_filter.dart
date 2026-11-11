/// Bộ lọc và tìm kiếm cuộc trò chuyện / tin nhắn
class MessageFilter {
  const MessageFilter({
    this.searchQuery,
    this.unreadOnly = false,
  });

  final String? searchQuery;
  final bool unreadOnly;

  MessageFilter copyWith({
    String? searchQuery,
    bool? unreadOnly,
  }) {
    return MessageFilter(
      searchQuery: searchQuery ?? this.searchQuery,
      unreadOnly: unreadOnly ?? this.unreadOnly,
    );
  }
}

