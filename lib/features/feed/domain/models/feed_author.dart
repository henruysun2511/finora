class FeedAuthor {
  const FeedAuthor({
    required this.id,
    required this.fullName,
    required this.username,
    this.avatar,
  });

  final String id;
  final String fullName;
  final String username;
  final String? avatar;

  String get displayName => fullName.isNotEmpty ? fullName : username;

  String get initials {
    final parts = displayName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'U';
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }
}

