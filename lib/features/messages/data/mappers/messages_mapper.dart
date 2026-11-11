import '../../domain/models/conversation.dart';
import '../../domain/models/direct_message.dart';
import '../../domain/models/related_transaction.dart';
import '../dto/conversation_response.dart';
import '../dto/message_response.dart';

class MessagesMapper {
  const MessagesMapper();

  Conversation toDomainConversation(ConversationResponseDto dto) {
    return Conversation(
      id: dto.friendId,
      title: dto.friendFullName,
      avatar: dto.friendAvatar,
      lastMessageContent: dto.lastMessageContent,
      lastMessageAt: DateTime.tryParse(dto.lastMessageAt) ?? DateTime.now(),
      unreadCount: dto.unreadCount,
      isGroup: dto.isGroup,
      groupWalletName: dto.groupWalletName,
    );
  }

  RelatedTransaction toDomainRelatedTransaction(RelatedTransactionDto dto) {
    return RelatedTransaction(
      id: dto.id,
      name: dto.name,
      amount: dto.amount,
      photoUrl: dto.photoUrl,
      transactionDate: DateTime.tryParse(dto.transactionDate) ?? DateTime.now(),
      isExpense: dto.isExpense,
      groupWalletName: dto.groupWalletName,
    );
  }

  DirectMessage toDomainMessage(MessageResponseDto dto, {String currentUserId = 'me'}) {
    return DirectMessage(
      id: dto.id,
      senderId: dto.senderId,
      senderName: dto.senderName ?? (dto.senderId == currentUserId ? 'Tôi' : 'Bạn bè'),
      receiverId: dto.receiverId,
      groupId: dto.groupId,
      content: dto.content,
      type: dto.relatedTransaction != null
          ? MessageType.transactionShare
          : MessageType.text,
      relatedTransaction: dto.relatedTransaction != null
          ? toDomainRelatedTransaction(dto.relatedTransaction!)
          : null,
      isMe: dto.senderId == currentUserId,
      isRead: dto.isRead,
      createdAt: DateTime.tryParse(dto.createdAt) ?? DateTime.now(),
      reactions: dto.reactions,
    );
  }
}
