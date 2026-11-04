import 'mascot_enums.dart';

/// Dữ liệu input khi cập nhật cấu hình linh vật từ Settings
class MascotSettingsInput {
  const MascotSettingsInput({
    this.showMascot,
    this.mascotTone,
    this.mascotSensitivity,
  });

  final bool? showMascot;
  final MascotTone? mascotTone;
  final MascotSensitivity? mascotSensitivity;
}

