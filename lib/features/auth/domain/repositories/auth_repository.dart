import '../models/auth_tokens.dart';
import '../models/login_input.dart';
import '../models/user.dart';

abstract class AuthRepository {
  /// Đăng nhập bằng username (hoặc email) và mật khẩu
  Future<User> login(LoginInput input);

  /// Đăng ký tài khoản mới
  Future<User> register({
    required String name,
    required String email,
    required String password,
  });

  /// Thu hồi token trên server và đăng xuất
  Future<void> logout();

  /// Xóa sạch phiên làm việc trên thiết bị mà không gọi API (dùng khi token đã chết)
  Future<void> clearLocalSession();

  /// Lấy thông tin người dùng hiện tại từ token đã lưu
  Future<User?> getCurrentUser();

  /// Cấp mới token khi access token hết hạn
  Future<AuthTokens> refreshToken(String refreshToken);

  /// Cập nhật thông tin cá nhân (họ tên, số điện thoại, avatar)
  Future<User> updateProfile({
    String? name,
    String? phone,
    String? avatarUrl,
  });
}
