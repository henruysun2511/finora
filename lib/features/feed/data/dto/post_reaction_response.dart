class PostReactionResponseDto {
  final String userId;
  final String fullName;
  final String? avatar;
  final String emoji;
  final DateTime createdAt;

  const PostReactionResponseDto({
    required this.userId,
    required this.fullName,
    this.avatar,
    required this.emoji,
    required this.createdAt,
  });

  factory PostReactionResponseDto.fromJson(Map<String, dynamic> json) {
    return PostReactionResponseDto(
      userId: json['userId'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      avatar: json['avatar'] as String?,
      emoji: json['emoji'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

class AddReactionResponseDto {
  final bool success;
  final String emoji;

  const AddReactionResponseDto({
    required this.success,
    required this.emoji,
  });

  factory AddReactionResponseDto.fromJson(Map<String, dynamic> json) {
    return AddReactionResponseDto(
      success: json['success'] as bool? ?? true,
      emoji: json['emoji'] as String? ?? '',
    );
  }
}

