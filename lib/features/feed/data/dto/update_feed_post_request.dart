class UpdateFeedPostRequestDto {
  final String? visibility;
  final bool? amountHidden;
  final String? note;

  const UpdateFeedPostRequestDto({
    this.visibility,
    this.amountHidden,
    this.note,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (visibility != null) map['visibility'] = visibility;
    if (amountHidden != null) map['amountHidden'] = amountHidden;
    if (note != null) map['note'] = note;
    return map;
  }
}

