class AddReactionRequestDto {
  final String emoji;

  const AddReactionRequestDto({required this.emoji});

  Map<String, dynamic> toJson() => {
    'emoji': emoji,
  };
}

