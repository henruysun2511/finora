class ConversationResponseDto {
  final String friendId;
  final String friendFullName;
  final String? friendAvatar;
  final String lastMessageContent;
  final String? lastMessageSenderId;
  final String lastMessageAt;
  final int unreadCount;
  final bool isGroup;
  final String? groupWalletName;

  const ConversationResponseDto({
    required this.friendId,
    required this.friendFullName,
    this.friendAvatar,
    required this.lastMessageContent,
    this.lastMessageSenderId,
    required this.lastMessageAt,
    this.unreadCount = 0,
    this.isGroup = false,
    this.groupWalletName,
  });

  factory ConversationResponseDto.fromJson(Map<String, dynamic> json) {
    return ConversationResponseDto(
      friendId: json['friendId'] as String? ?? json['id'] as String? ?? '',
      friendFullName: json['friendFullName'] as String? ?? json['title'] as String? ?? json['name'] as String? ?? '',
      friendAvatar: json['friendAvatar'] as String? ?? json['avatar'] as String?,
      lastMessageContent: json['lastMessageContent'] as String? ?? json['lastMessage'] as String? ?? '',
      lastMessageSenderId: json['lastMessageSenderId'] as String?,
      lastMessageAt: (json['lastMessageAt'] ?? json['updatedAt'] ?? DateTime.now().toIso8601String()).toString(),
      unreadCount: json['unreadCount'] as int? ?? 0,
      isGroup: json['isGroup'] as bool? ?? false,
      groupWalletName: json['groupWalletName'] as String?,
    );
  }
}
