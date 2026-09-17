class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://api.finora.vn/v1';

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refreshToken = '/auth/refresh';
  static const String profile = '/users/me';

  // Finance & AI
  static const String transactions = '/transactions';
  static const String wallets = '/wallets';
  static const String budget = '/budget';
  static const String analytics = '/analytics/summary';
  static const String voicePhoWhisper = '/ai/voice-input';
  static const String receiptVietOCR = '/ai/scan-receipt';
}
