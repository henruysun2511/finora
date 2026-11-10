import 'message.dart';

/// Người tham gia cuộc trò chuyện
class ConversationParticipant {
  const ConversationParticipant({
    required this.id,
    required this.displayName,
    this.avatarUrl,
    this.isOnline = false,
  });

  final String id;
  final String displayName;
  final String? avatarUrl;
  final bool isOnline;
}

/// Entity biểu diễn Cuộc hội thoại (Conversation)
class Conversation {
  const Conversation({
    required this.id,
    required this.participant,
    this.lastMessage,
    this.unreadCount = 0,
    required this.updatedAt,
  });

  final String id;
  final ConversationParticipant participant;
  final Message? lastMessage;
  final int unreadCount;
  final DateTime updatedAt;

  Conversation copyWith({
    String? id,
    ConversationParticipant? participant,
    Message? lastMessage,
    int? unreadCount,
    DateTime? updatedAt,
  }) {
    return Conversation(
      id: id ?? this.id,
      participant: participant ?? this.participant,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCount: unreadCount ?? this.unreadCount,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

