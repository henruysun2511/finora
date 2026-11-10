class RelatedTransactionDto {
  final String id;
  final String name;
  final double amount;
  final String? photoUrl;
  final String transactionDate;
  final bool isExpense;
  final String? groupWalletName;

  const RelatedTransactionDto({
    required this.id,
    required this.name,
    required this.amount,
    this.photoUrl,
    required this.transactionDate,
    this.isExpense = true,
    this.groupWalletName,
  });

  factory RelatedTransactionDto.fromJson(Map<String, dynamic> json) {
    return RelatedTransactionDto(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      photoUrl: json['photoUrl'] as String?,
      transactionDate: (json['transactionDate'] ?? DateTime.now().toIso8601String()).toString(),
      isExpense: json['isExpense'] as bool? ?? true,
      groupWalletName: json['groupWalletName'] as String?,
    );
  }
}

class MessageResponseDto {
  final String id;
  final String senderId;
  final String? senderName;
  final String? receiverId;
  final String? groupId;
  final String content;
  final String? relatedTransactionId;
  final RelatedTransactionDto? relatedTransaction;
  final bool isRead;
  final List<String> reactions;
  final String createdAt;

  const MessageResponseDto({
    required this.id,
    required this.senderId,
    this.senderName,
    this.receiverId,
    this.groupId,
    required this.content,
    this.relatedTransactionId,
    this.relatedTransaction,
    this.isRead = false,
    this.reactions = const [],
    required this.createdAt,
  });

  factory MessageResponseDto.fromJson(Map<String, dynamic> json) {
    return MessageResponseDto(
      id: json['id'] as String? ?? '',
      senderId: json['senderId'] as String? ?? '',
      senderName: json['senderName'] as String?,
      receiverId: json['receiverId'] as String?,
      groupId: json['groupId'] as String?,
      content: json['content'] as String? ?? '',
      relatedTransactionId: json['relatedTransactionId'] as String?,
      relatedTransaction: json['relatedTransaction'] != null
          ? RelatedTransactionDto.fromJson(json['relatedTransaction'] as Map<String, dynamic>)
          : null,
      isRead: json['isRead'] as bool? ?? false,
      reactions: (json['reactions'] as List<dynamic>?)?.map((e) {
            if (e is Map) return (e['emoji'] ?? '').toString();
            return e.toString();
          }).toList() ??
          const [],
      createdAt: (json['createdAt'] ?? DateTime.now().toIso8601String()).toString(),
    );
  }
}
