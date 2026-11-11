class Friend {
  const Friend({
    required this.id,
    required this.fullName,
    required this.email,
    this.avatar,
    this.connectedAt,
  });

  final String id;
  final String fullName;
  final String email;
  final String? avatar;
  final DateTime? connectedAt;

  String get displayName => fullName.trim().isNotEmpty ? fullName.trim() : email;

  String get initials {
    final parts = displayName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'U';
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }
}

