import 'message_attachment.dart';
import 'message_enums.dart';

/// Dữ liệu đầu vào khi người dùng gửi tin nhắn
class SendMessageInput {
  const SendMessageInput({
    required this.receiverId,
    this.conversationId,
    required this.content,
    this.type = MessageType.text,
    this.mediaUrl,
    this.transactionAttachment,
  });

  final String receiverId;
  final String? conversationId;
  final String content;
  final MessageType type;
  final String? mediaUrl;
  final MessageTransactionAttachment? transactionAttachment;
}

