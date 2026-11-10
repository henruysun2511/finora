import 'message_attachment.dart';
import 'message_enums.dart';

/// Entity thuần Domain cho một Tin nhắn (Message) giữa 2 người dùng.
/// Hoàn toàn độc lập với Flutter UI, Dio hay Data DTOs.
class Message {
  const Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.receiverId,
    required this.content,
    this.type = MessageType.text,
    this.status = MessageDeliveryStatus.sent,
    this.mediaUrl,
    this.transactionAttachment,
    required this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String conversationId;
  final String senderId;
  final String receiverId;
  final String content;
  final MessageType type;
  final MessageDeliveryStatus status;
  final String? mediaUrl;
  final MessageTransactionAttachment? transactionAttachment;
  final DateTime createdAt;
  final DateTime? updatedAt;

  /// Kiểm tra tin nhắn do chính người dùng hiện tại gửi đi hay không
  bool isMine(String currentUserId) => senderId == currentUserId;

  Message copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    String? receiverId,
    String? content,
    MessageType? type,
    MessageDeliveryStatus? status,
    String? mediaUrl,
    MessageTransactionAttachment? transactionAttachment,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Message(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      content: content ?? this.content,
      type: type ?? this.type,
      status: status ?? this.status,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      transactionAttachment: transactionAttachment ?? this.transactionAttachment,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

