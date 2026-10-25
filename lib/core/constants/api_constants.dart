import 'package:flutter/foundation.dart';

class ApiConstants {
  ApiConstants._();

  // Cấu hình Base URL:
  // - Có thể cấu hình qua command line: --dart-define=BASE_URL=http://localhost:3000/api/v1
  // - Debug Web / iOS Simulator: http://localhost:3000/api/v1
  // - Debug Android Emulator: http://10.0.2.2:3000/api/v1
  // - Production: https://api.finora.vn/api/v1
  static String get baseUrl {
    const fromEnv = String.fromEnvironment('BASE_URL');
    if (fromEnv.isNotEmpty) return fromEnv;

    if (kDebugMode) {
      if (kIsWeb) {
        return 'http://localhost:3000/api/v1';
      }
      if (defaultTargetPlatform == TargetPlatform.android) {
        return 'http://10.0.2.2:3000/api/v1';
      }
      return 'http://localhost:3000/api/v1';
    }

    return 'https://api.finora.vn/api/v1';
  }

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refreshToken = '/auth/refresh-token';
  static const String profile = '/users/me';
  static const String updateProfile = '/users/profile';

  // Finance & AI
  static const String transactions = '/transactions';
  static const String wallets = '/wallets';
  static const String budgets = '/budgets';
  static const String categories = '/categories';
  static const String products = '/products';
  static const String analytics = '/analytics/summary';
  static const String voicePhoWhisper = '/ai/voice-input';
  static const String receiptVietOCR = '/ai/scan-receipt';
}
