/// DTO gửi lên server để cập nhật cài đặt linh vật (PATCH /settings/mascot)
class UpdateMascotSettingsRequest {
  const UpdateMascotSettingsRequest({
    this.showMascot,
    this.mascotTone,
    this.mascotSensitivity,
  });

  final bool? showMascot;
  final String? mascotTone;
  final String? mascotSensitivity;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (showMascot != null) map['showMascot'] = showMascot;
    if (mascotTone != null) map['mascotTone'] = mascotTone;
    if (mascotSensitivity != null) map['mascotSensitivity'] = mascotSensitivity;
    return map;
  }
}

