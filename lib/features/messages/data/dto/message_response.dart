import '../../domain/models/message_attachment.dart';

/// DTO biểu diễn cảm xúc trên tin nhắn từ NestJS
class MessageReactionDto {
  const MessageReactionDto({
    required this.emoji,
    required this.userId,
  });

  final String emoji;
  final String userId;

  factory MessageReactionDto.fromJson(Map<String, dynamic> json) {
    return MessageReactionDto(
      emoji: json['emoji'] as String? ?? 'like',
      userId: json['userId'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'emoji': emoji,
        'userId': userId,
      };
}

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
    this.isRead = false,
    this.mediaUrl,
    this.relatedTransactionId,
    this.transactionAttachment,
    this.reactions = const [],
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
  final bool isRead;
  final String? mediaUrl;
  final String? relatedTransactionId;
  final MessageTransactionAttachment? transactionAttachment;
  final List<MessageReactionDto> reactions;
  final DateTime createdAt;
  final DateTime? updatedAt;

  factory MessageResponse.fromJson(Map<String, dynamic> json) {
    final isReadBool = json['isRead'] as bool? ?? (json['status'] == 'READ');

    // Parse reactions
    final rawReactions = json['reactions'];
    final reactionsList = <MessageReactionDto>[];
    if (rawReactions is List) {
      for (final r in rawReactions) {
        if (r is Map<String, dynamic>) {
          reactionsList.add(MessageReactionDto.fromJson(r));
        }
      }
    }

    // Parse relatedTransaction / transactionAttachment
    MessageTransactionAttachment? attachment;
    if (json['relatedTransaction'] is Map<String, dynamic>) {
      final tx = json['relatedTransaction'] as Map<String, dynamic>;
      attachment = MessageTransactionAttachment(
        transactionId: tx['id']?.toString() ?? '',
        title: tx['name'] as String? ?? 'Khoảnh khắc chi tiêu',
        amount: (tx['amount'] as num?)?.toDouble() ?? 0.0,
        categoryName: tx['categoryName'] as String? ?? 'Khác',
        categoryIcon: tx['categoryIcon'] as String?,
      );
    } else if (json['transactionAttachment'] is Map<String, dynamic>) {
      attachment = MessageTransactionAttachment.fromJson(
        json['transactionAttachment'] as Map<String, dynamic>,
      );
    } else if (json['attachment'] is Map<String, dynamic>) {
      attachment = MessageTransactionAttachment.fromJson(
        json['attachment'] as Map<String, dynamic>,
      );
    }

    final relatedTxId = json['relatedTransactionId']?.toString();

    return MessageResponse(
      id: json['id']?.toString() ?? '',
      conversationId: json['conversationId']?.toString() ?? '',
      senderId: json['senderId']?.toString() ??
          (json['sender']?['id']?.toString() ?? ''),
      receiverId: json['receiverId']?.toString() ??
          (json['receiver']?['id']?.toString() ?? ''),
      content: json['content'] as String? ?? '',
      type: (json['type'] as String?) ??
          (attachment != null ? 'TRANSACTION_SHARE' : 'TEXT'),
      status: isReadBool ? 'READ' : ((json['status'] as String?) ?? 'SENT'),
      isRead: isReadBool,
      mediaUrl: json['mediaUrl'] as String?,
      relatedTransactionId: relatedTxId,
      transactionAttachment: attachment,
      reactions: reactionsList,
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
        'isRead': isRead,
        'mediaUrl': mediaUrl,
        'relatedTransactionId': relatedTransactionId,
        'transactionAttachment': transactionAttachment?.toJson(),
        'reactions': reactions.map((e) => e.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };
}
