import 'related_transaction.dart';

enum MessageType {
  text,
  image,
  transactionShare,
}

class DirectMessage {
  const DirectMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    this.receiverId,
    this.groupId,
    required this.content,
    this.type = MessageType.text,
    this.relatedTransaction,
    this.isMe = false,
    this.isRead = false,
    required this.createdAt,
    this.reactions = const [],
  });

  final String id;
  final String senderId;
  final String senderName;
  final String? receiverId;
  final String? groupId;
  final String content;
  final MessageType type;
  final RelatedTransaction? relatedTransaction;
  final bool isMe;
  final bool isRead;
  final DateTime createdAt;
  final List<String> reactions;

  DirectMessage copyWith({
    String? id,
    String? senderId,
    String? senderName,
    String? receiverId,
    String? groupId,
    String? content,
    MessageType? type,
    RelatedTransaction? relatedTransaction,
    bool? isMe,
    bool? isRead,
    DateTime? createdAt,
    List<String>? reactions,
  }) {
    return DirectMessage(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      receiverId: receiverId ?? this.receiverId,
      groupId: groupId ?? this.groupId,
      content: content ?? this.content,
      type: type ?? this.type,
      relatedTransaction: relatedTransaction ?? this.relatedTransaction,
      isMe: isMe ?? this.isMe,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      reactions: reactions ?? this.reactions,
    );
  }
}
