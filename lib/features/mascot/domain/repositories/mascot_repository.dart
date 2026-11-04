import '../models/current_mascot.dart';
import '../models/mascot_evolution.dart';
import '../models/mascot_settings_input.dart';
import '../models/mascot_tier.dart';

abstract class MascotRepository {
  /// Lấy thông tin linh vật AI hiện tại của người dùng
  Future<CurrentMascot> getCurrentMascot();

  /// Lấy danh sách 7 linh vật theo từng nấc thang tiến hóa
  Future<List<MascotTier>> getAllMascotTiers();

  /// Kiểm tra và kích hoạt đồng bộ tiến hóa linh vật
  Future<MascotEvolution> syncEvolution();

  /// Cập nhật cài đặt linh vật (bật/tắt, tone, sensitivity)
  Future<void> updateMascotSettings(MascotSettingsInput input);
}

