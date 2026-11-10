class Conversation {
  const Conversation({
    required this.id,
    required this.title,
    this.avatar,
    required this.lastMessageContent,
    required this.lastMessageAt,
    this.unreadCount = 0,
    this.isGroup = false,
    this.isOnline = false,
    this.groupWalletName,
    this.membersCount,
  });

  final String id;
  final String title;
  final String? avatar;
  final String lastMessageContent;
  final DateTime lastMessageAt;
  final int unreadCount;
  final bool isGroup;
  final bool isOnline;
  final String? groupWalletName;
  final int? membersCount;

  String get initials {
    final parts = title.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'U';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }
}
