import '../../../../core/widgets/mascot/mascot_model.dart';
import '../../../../core/widgets/mascot/mascot_registry.dart';
import '../../../mascot/domain/models/mascot_enums.dart';

/// Dữ liệu tổng hợp xuyên suốt luồng Onboarding 5 bước
class OnboardingData {
  const OnboardingData({
    this.name = 'Nguyễn Minh',
    this.language = 'vi',
    this.currency = 'VND',
    this.walletName = 'Ví cá nhân',
    this.walletType = 'cash',
    this.walletTypeLabel = 'Tiền mặt',
    this.balance = 5000000.0,
    this.mascotTone = MascotTone.balanced,
    this.mascotSensitivity = MascotSensitivity.anomaliesOnly,
  });

  /// 1. Hồ sơ người dùng
  final String name;
  final String language; // 'vi' | 'en'
  final String currency; // 'VND' | 'USD' | 'EUR' | 'JPY' | 'SGD'

  /// 2. Nguồn tiền & Số dư khởi điểm
  final String walletName;
  final String walletType; // 'cash' | 'bank' | 'ewallet' | 'credit'
  final String walletTypeLabel; // 'Tiền mặt' | 'Ngân hàng' | ...
  final double balance;

  /// 3. Cấu hình Trợ lý AI
  final MascotTone mascotTone;
  final MascotSensitivity mascotSensitivity;

  /// Tự động xác định linh vật AI chỉ định theo Net Worth (Số dư ban đầu)
  /// Chuẩn nghiệp vụ FINORA Evolution:
  /// < 0đ -> Ash, 0-1M -> Penny, 1M-5M -> Sage, 5M-20M -> Nora,
  /// 20M-100M -> Jade, 100M-500M -> Ruby, > 500M -> Bellingham
  MascotData get assignedMascot => MascotRegistry.resolveByBalance(balance);

  OnboardingData copyWith({
    String? name,
    String? language,
    String? currency,
    String? walletName,
    String? walletType,
    String? walletTypeLabel,
    double? balance,
    MascotTone? mascotTone,
    MascotSensitivity? mascotSensitivity,
  }) {
    return OnboardingData(
      name: name ?? this.name,
      language: language ?? this.language,
      currency: currency ?? this.currency,
      walletName: walletName ?? this.walletName,
      walletType: walletType ?? this.walletType,
      walletTypeLabel: walletTypeLabel ?? this.walletTypeLabel,
      balance: balance ?? this.balance,
      mascotTone: mascotTone ?? this.mascotTone,
      mascotSensitivity: mascotSensitivity ?? this.mascotSensitivity,
    );
  }
}

