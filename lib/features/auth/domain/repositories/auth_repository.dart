import '../models/auth_tokens.dart';
import '../models/forgot_password_result.dart';
import '../models/login_input.dart';
import '../models/register_input.dart';
import '../models/user.dart';

abstract class AuthRepository {
  /// Đăng nhập bằng username (hoặc email) và mật khẩu
  Future<User> login(LoginInput input);

  /// Đăng ký tài khoản mới
  Future<User> register(RegisterInput input);

  /// Đăng nhập bằng Google ID Token (Mobile)
  Future<User> loginWithGoogle(String idToken);

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

  /// Yêu cầu gửi mã OTP quên mật khẩu (30 giây) qua Email
  Future<ForgotPasswordResult> forgotPassword(String email);

  /// Xác thực mã OTP 6 số trong vòng 30 giây
  Future<String> verifyOtp(String email, String otp);

  /// Đặt lại mật khẩu mới bằng resetToken
  Future<void> resetPassword(String resetToken, String newPassword);
}


