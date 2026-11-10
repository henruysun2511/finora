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
      id: json['id']?.toString() ?? '',
      displayName: json['displayName'] as String? ?? (json['name'] as String? ?? 'Người dùng'),
      avatarUrl: json['avatarUrl'] as String? ?? json['avatar'] as String?,
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
      lastMsg = MessageResponse.fromJson(json['lastMessage'] as Map<String, dynamic>);
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

