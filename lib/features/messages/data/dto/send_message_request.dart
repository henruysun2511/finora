import '../../domain/models/message_attachment.dart';

/// DTO gửi lên Backend để gửi tin nhắn mới (Khớp NestJS SendMessageDto)
class SendMessageRequest {
  const SendMessageRequest({
    required this.receiverId,
    required this.content,
    this.conversationId,
    this.type = 'TEXT',
    this.mediaUrl,
    this.transactionAttachment,
    this.replyToMessageId,
    this.relatedTransactionId,
  });

  final String receiverId;
  final String? conversationId;
  final String content;
  final String type;
  final String? mediaUrl;
  final MessageTransactionAttachment? transactionAttachment;
  final String? replyToMessageId;
  final String? relatedTransactionId;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'receiverId': receiverId,
      'content': content,
    };
    if (replyToMessageId != null && replyToMessageId!.trim().isNotEmpty) {
      map['replyToMessageId'] = replyToMessageId!.trim();
    }
    final txId = relatedTransactionId ?? transactionAttachment?.transactionId;
    if (txId != null && txId.trim().isNotEmpty && txId != 'tx_sample' && txId != 'tx_req') {
      map['relatedTransactionId'] = txId.trim();
    }
    return map;
  }
}
