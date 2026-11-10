import 'message_response.dart';

/// DTO người tham gia hội thoại
class ConversationParticipantDto {
  const ConversationParticipantDto({
    required this.id,
    required this.displayName,
    this.avatarUrl,
    this.isOnline = false,
  });

  final String id;
  final String displayName;
  final String? avatarUrl;
  final bool isOnline;

  factory ConversationParticipantDto.fromJson(Map<String, dynamic> json) {
    return ConversationParticipantDto(
      id: json['id']?.toString() ?? (json['friendId']?.toString() ?? ''),
      displayName: json['displayName'] as String? ??
          (json['friendFullName'] as String? ??
              (json['name'] as String? ?? 'Người dùng')),
      avatarUrl: json['avatarUrl'] as String? ??
          (json['friendAvatar'] as String? ?? json['avatar'] as String?),
      isOnline: (json['isOnline'] as bool?) ?? false,
    );
  }
}

/// DTO cuộc hội thoại từ /messages/conversations
class ConversationResponse {
  const ConversationResponse({
    required this.id,
    required this.participant,
    this.lastMessage,
    this.unreadCount = 0,
    required this.updatedAt,
  });

  final String id;
  final ConversationParticipantDto participant;
  final MessageResponse? lastMessage;
  final int unreadCount;
  final DateTime updatedAt;

  factory ConversationResponse.fromJson(Map<String, dynamic> json) {
    // 1. Phục vụ response chuẩn NestJS ConversationResponseDto:
    // { friendId, friendFullName, friendAvatar, lastMessageContent, lastMessageSenderId, lastMessageAt, unreadCount }
    if (json['friendId'] != null) {
      final fId = json['friendId'].toString();
      final fName = json['friendFullName'] as String? ?? 'Bạn bè';
      final fAvatar = json['friendAvatar'] as String?;
      final lastContent = json['lastMessageContent'] as String? ?? '';
      final lastSenderId = json['lastMessageSenderId'] as String? ?? '';
      final lastAt = json['lastMessageAt'] != null
          ? DateTime.tryParse(json['lastMessageAt'].toString()) ?? DateTime.now()
          : DateTime.now();

      final participantDto = ConversationParticipantDto(
        id: fId,
        displayName: fName,
        avatarUrl: fAvatar,
      );

      final lastMsg = lastContent.isNotEmpty
          ? MessageResponse(
              id: '',
              conversationId: fId,
              senderId: lastSenderId,
              receiverId: '',
              content: lastContent,
              createdAt: lastAt,
            )
          : null;

      return ConversationResponse(
        id: fId,
        participant: participantDto,
        lastMessage: lastMsg,
        unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
        updatedAt: lastAt,
      );
    }

    // 2. Fallback cho response dạng object lồng nhau
    ConversationParticipantDto participantDto;
    if (json['participant'] is Map<String, dynamic>) {
      participantDto = ConversationParticipantDto.fromJson(
        json['participant'] as Map<String, dynamic>,
      );
    } else {
      participantDto = const ConversationParticipantDto(
        id: '',
        displayName: 'Người dùng',
      );
    }

    MessageResponse? lastMsg;
    if (json['lastMessage'] is Map<String, dynamic>) {
      lastMsg =
          MessageResponse.fromJson(json['lastMessage'] as Map<String, dynamic>);
    }

    return ConversationResponse(
      id: json['id']?.toString() ?? '',
      participant: participantDto,
      lastMessage: lastMsg,
      unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
