import '../../domain/models/message_attachment.dart';

/// DTO biểu diễn tin nhắn nhận về từ Backend NestJS
class MessageResponse {
  const MessageResponse({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.receiverId,
    required this.content,
    this.type = 'TEXT',
    this.status = 'SENT',
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
  final String type;
  final String status;
  final String? mediaUrl;
  final MessageTransactionAttachment? transactionAttachment;
  final DateTime createdAt;
  final DateTime? updatedAt;

  factory MessageResponse.fromJson(Map<String, dynamic> json) {
    MessageTransactionAttachment? attachment;
    if (json['transactionAttachment'] is Map<String, dynamic>) {
      attachment = MessageTransactionAttachment.fromJson(
        json['transactionAttachment'] as Map<String, dynamic>,
      );
    } else if (json['attachment'] is Map<String, dynamic>) {
      attachment = MessageTransactionAttachment.fromJson(
        json['attachment'] as Map<String, dynamic>,
      );
    }

    return MessageResponse(
      id: json['id']?.toString() ?? '',
      conversationId: json['conversationId']?.toString() ?? '',
      senderId: json['senderId']?.toString() ?? (json['sender']?['id']?.toString() ?? ''),
      receiverId: json['receiverId']?.toString() ?? (json['receiver']?['id']?.toString() ?? ''),
      content: json['content'] as String? ?? '',
      type: (json['type'] as String?) ?? 'TEXT',
      status: (json['status'] as String?) ?? 'SENT',
      mediaUrl: json['mediaUrl'] as String?,
      transactionAttachment: attachment,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'conversationId': conversationId,
        'senderId': senderId,
        'receiverId': receiverId,
        'content': content,
        'type': type,
        'status': status,
        'mediaUrl': mediaUrl,
        'transactionAttachment': transactionAttachment?.toJson(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };
}

