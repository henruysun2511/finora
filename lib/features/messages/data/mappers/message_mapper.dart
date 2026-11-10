import '../../domain/models/conversation.dart';
import '../../domain/models/message.dart';
import '../../domain/models/message_enums.dart';
import '../../domain/models/message_input.dart';
import '../dto/conversation_response.dart';
import '../dto/message_response.dart';
import '../dto/send_message_request.dart';

/// Mapper chuyển đổi qua lại giữa DTO (mạng / JSON) và Domain Entities.
class MessageMapper {
  MessageMapper._();

  static Message toDomain(MessageResponse dto) {
    return Message(
      id: dto.id,
      conversationId: dto.conversationId,
      senderId: dto.senderId,
      receiverId: dto.receiverId,
      content: dto.content,
      type: MessageType.fromValue(dto.type),
      status: MessageDeliveryStatus.fromValue(dto.status),
      isRead: dto.isRead,
      mediaUrl: dto.mediaUrl,
      transactionAttachment: dto.transactionAttachment,
      reactions: dto.reactions
          .map((r) => (emoji: r.emoji, userId: r.userId))
          .toList(),
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
    );
  }

  static Conversation toConversationDomain(ConversationResponse dto) {
    return Conversation(
      id: dto.id,
      participant: ConversationParticipant(
        id: dto.participant.id,
        displayName: dto.participant.displayName,
        avatarUrl: dto.participant.avatarUrl,
        isOnline: dto.participant.isOnline,
      ),
      lastMessage: dto.lastMessage != null ? toDomain(dto.lastMessage!) : null,
      unreadCount: dto.unreadCount,
      updatedAt: dto.updatedAt,
    );
  }

  static SendMessageRequest toRequest(SendMessageInput input) {
    return SendMessageRequest(
      receiverId: input.receiverId,
      content: input.content,
      relatedTransactionId: input.transactionAttachment?.transactionId,
    );
  }
}
