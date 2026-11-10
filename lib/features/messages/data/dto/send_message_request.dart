import '../../domain/models/message_attachment.dart';

/// DTO gửi lên Backend để gửi tin nhắn mới
class SendMessageRequest {
  const SendMessageRequest({
    required this.receiverId,
    this.conversationId,
    required this.content,
    this.type = 'TEXT',
    this.mediaUrl,
    this.transactionAttachment,
  });

  final String receiverId;
  final String? conversationId;
  final String content;
  final String type;
  final String? mediaUrl;
  final MessageTransactionAttachment? transactionAttachment;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'receiverId': receiverId,
      'content': content,
      'type': type,
    };
    if (conversationId != null) map['conversationId'] = conversationId;
    if (mediaUrl != null) map['mediaUrl'] = mediaUrl;
    if (transactionAttachment != null) {
      map['transactionAttachment'] = transactionAttachment!.toJson();
    }
    return map;
  }
}

