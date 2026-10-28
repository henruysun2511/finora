import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  ApiConstants._();

  // ─── Cấu hình Base URL ───────────────────────────────────────────────────────
  // 1. Đọc từ file .env (BASE_URL)
  // 2. Đọc từ command line (--dart-define=BASE_URL=...)
  // 3. Fallback tự động theo nền tảng debug (Web/iOS/Windows: localhost, Android Emulator: 10.0.2.2)
  // 4. Production: https://api.finora.vn/api/v1
  static String get baseUrl {
    // 1. Đọc từ file .env
    final fromDotenv = dotenv.maybeGet('BASE_URL');
    if (fromDotenv != null && fromDotenv.trim().isNotEmpty) {
      // Tự động map localhost -> 10.0.2.2 trên Android emulator khi cấu hình .env là localhost
      if (kDebugMode &&
          defaultTargetPlatform == TargetPlatform.android &&
          fromDotenv.contains('localhost')) {
        return fromDotenv.replaceAll('localhost', '10.0.2.2');
      }
      return fromDotenv.trim();
    }

    // 2. Đọc từ --dart-define
    const fromEnv = String.fromEnvironment('BASE_URL');
    if (fromEnv.isNotEmpty) return fromEnv;

    // 3. Fallback theo nền tảng
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

  static String get socketUrl {
    final fromDotenv = dotenv.maybeGet('SOCKET_URL');
    if (fromDotenv != null && fromDotenv.trim().isNotEmpty) {
      if (kDebugMode &&
          defaultTargetPlatform == TargetPlatform.android &&
          fromDotenv.contains('localhost')) {
        return fromDotenv.replaceAll('localhost', '10.0.2.2');
      }
      return fromDotenv.trim();
    }

    const fromEnv = String.fromEnvironment('SOCKET_URL');
    if (fromEnv.isNotEmpty) return fromEnv;

    if (kDebugMode) {
      if (defaultTargetPlatform == TargetPlatform.android) {
        return 'http://10.0.2.2:3000';
      }
      return 'http://localhost:3000';
    }

    return 'https://api.finora.vn';
  }

  static Duration get connectTimeout {
    final sec = int.tryParse(dotenv.maybeGet('CONNECT_TIMEOUT_SECONDS') ?? '');
    return Duration(seconds: sec ?? 15);
  }

  static Duration get receiveTimeout {
    final sec = int.tryParse(dotenv.maybeGet('RECEIVE_TIMEOUT_SECONDS') ?? '');
    return Duration(seconds: sec ?? 15);
  }

  // ─── 1. Authentication (/auth) ──────────────────────────────────────────────
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refreshToken = '/auth/refresh-token';
  static const String changePassword = '/auth/change-password';
  static const String googleLogin = '/auth/google';
  static const String googleCallback = '/auth/google/callback';

  // ─── 2. User Profile (/users) ───────────────────────────────────────────────
  static const String profile = '/users/me';
  static const String updateProfile = '/users/profile';
  static const String uploadAvatar = '/users/avatar';
  static const String searchUsers = '/users/search';

  // ─── 3. Wallets (/wallets) ──────────────────────────────────────────────────
  static const String wallets = '/wallets';
  static String walletDetail(String id) => '/wallets/$id';
  static String walletBalance(String id) => '/wallets/$id/balance';
  static String walletAccounts(String id) => '/wallets/$id/accounts';
  static String walletTransferOwnership(String id) => '/wallets/$id/transfer-ownership';
  static String walletMembers(String walletId) => '/wallets/$walletId/members';
  static String walletMemberDetail(String walletId, String memberId) =>
      '/wallets/$walletId/members/$memberId';
  static String updateWalletMemberRole(String walletId, String memberId) =>
      '/wallets/$walletId/members/$memberId/role';

  // ─── 4. Accounts (/accounts) ────────────────────────────────────────────────
  static const String accounts = '/accounts';
  static String accountDetail(String id) => '/accounts/$id';
  static String archiveAccount(String id) => '/accounts/$id/archive';

  // ─── 5. Transfers (/transfers) ──────────────────────────────────────────────
  static const String transfers = '/transfers';
  static String transferDetail(String id) => '/transfers/$id';

  // ─── 6. Transactions (/transactions) ────────────────────────────────────────
  static const String transactions = '/transactions';
  static const String transactionSummary = '/transactions/summary';
  static const String transactionStatistics = '/transactions/statistics';
  static const String transactionExport = '/transactions/export';
  static String transactionDetail(String id) => '/transactions/$id';

  // ─── 7. Recurring Transactions (/recurring-transactions) ────────────────────
  static const String recurringTransactions = '/recurring-transactions';
  static String recurringTransactionDetail(String id) => '/recurring-transactions/$id';
  static String recurringTransactionStatus(String id) =>
      '/recurring-transactions/$id/status';

  // ─── 8. Categories (/categories) ────────────────────────────────────────────
  static const String categories = '/categories';
  static const String defaultCategories = '/categories/default';
  static String categoryDetail(String id) => '/categories/$id';

  // ─── 9. Budgets (/budgets) ──────────────────────────────────────────────────
  static const String budgets = '/budgets';
  static const String budgetOverview = '/budgets/overview';
  static String budgetDetail(String id) => '/budgets/$id';
  static String budgetStatus(String id) => '/budgets/$id/status';

  // ─── 10. Loans & Debts (/loans) ─────────────────────────────────────────────
  static const String loans = '/loans';
  static const String loansSummary = '/loans/summary';
  static String loanDetail(String id) => '/loans/$id';
  static String loanPayments(String id) => '/loans/$id/payments';
  static String loanPaymentDetail(String paymentId) => '/loans/payments/$paymentId';

  // ─── 11. Split Expenses (/splits & /transactions/:id/splits) ─────────────────
  static const String mySplits = '/splits/me';
  static String splitDetail(String id) => '/splits/$id';
  static String settleSplit(String id) => '/splits/$id/settle';
  static String transactionSplits(String transactionId) =>
      '/transactions/$transactionId/splits';

  // ─── 12. AI Chatbot (/chat) ─────────────────────────────────────────────────
  static const String chatMessages = '/chat/messages';
  static const String chatMedia = '/chat/messages/media';
  static const String chatPendingActions = '/chat/pending-actions';
  static String pendingActionDetail(String id) => '/chat/pending-actions/$id';
  static String executePendingAction(String id) => '/chat/pending-actions/$id/execute';

  // ─── 13. Mascots (/mascots) ─────────────────────────────────────────────────
  static const String mascots = '/mascots';
  static const String currentMascot = '/mascots/current';
  static const String syncMascotEvolution = '/mascots/sync-evolution';
  static const String adminMascots = '/mascots/admin';
  static String mascotDetail(String id) => '/mascots/$id';

  // ─── 14. Friends (/friends) ─────────────────────────────────────────────────
  static const String friends = '/friends';
  static const String searchFriends = '/friends/search';
  static const String friendRequests = '/friends/requests';
  static const String sentFriendRequests = '/friends/requests/sent';
  static String acceptFriendRequest(String friendshipId) =>
      '/friends/accept/$friendshipId';
  static String rejectFriendRequest(String friendshipId) =>
      '/friends/reject/$friendshipId';
  static String removeFriend(String friendshipId) => '/friends/$friendshipId';

  // ─── 15. Financial Feed (/feed) ─────────────────────────────────────────────
  static const String feed = '/feed';
  static const String myFeed = '/feed/my';
  static String feedReactions(String transactionId) =>
      '/feed/$transactionId/reactions';
  static String feedComments(String transactionId) =>
      '/feed/$transactionId/comments';
  static String feedCommentDetail(String transactionId, String commentId) =>
      '/feed/$transactionId/comments/$commentId';

  // ─── 16. P2P Messages (/messages) ───────────────────────────────────────────
  static const String conversations = '/messages/conversations';
  static const String sendP2PMessage = '/messages';
  static String conversationDetail(String id) => '/messages/conversations/$id';
  static String friendMessages(String friendId) => '/messages/$friendId';

  // ─── 17. Notifications (/notifications) ─────────────────────────────────────
  static const String notifications = '/notifications';
  static const String unreadNotificationsCount = '/notifications/unread-count';
  static const String markAllNotificationsAsRead = '/notifications/read-all';
  static String markNotificationAsRead(String id) => '/notifications/$id/read';

  // ─── 18. Dashboard & Executive Analytics (/dashboard) ───────────────────────
  static const String dashboardOverview = '/dashboard/overview';
  static const String dashboardCashFlow = '/dashboard/cash-flow';
  static const String dashboardNetWorth = '/dashboard/net-worth';

  // ─── 19. Settings & PIN Security (/settings) ────────────────────────────────
  static const String settings = '/settings';
  static const String updateMascotSettings = '/settings/mascot';
  static const String updateGeneralSettings = '/settings/general';
  static const String updateAiSettings = '/settings/ai';
  static const String updateNotificationSettings = '/settings/notifications';
  static const String setupPin = '/settings/pin/setup';
  static const String verifyPin = '/settings/pin/verify';
  static const String changePin = '/settings/pin/change';
  static const String disableAppLock = '/settings/pin/disable';
  static const String updateTransactionPin = '/settings/pin/transaction';

  // ─── 20. Exchange Rates (/exchange-rates) ───────────────────────────────────
  static const String exchangeRates = '/exchange-rates';
  static String exchangeRate(String from, String to) => '/exchange-rates/$from/$to';

  // ─── 21. Cloudinary Media (/cloudinary) ─────────────────────────────────────
  static const String cloudinaryUpload = '/cloudinary/upload';
  static const String cloudinaryDelete = '/cloudinary/media';
  static const String uploadMedia = '/cloudinary/upload'; // Alias hỗ trợ tương thích ngược

  // ─── Compatibility Aliases (Deprecated) ─────────────────────────────────────
  @Deprecated('Dùng dashboardOverview thay thế')
  static const String analytics = '/dashboard/overview';
  @Deprecated('Dùng chatMedia thay thế')
  static const String voicePhoWhisper = '/chat/messages/media';
  @Deprecated('Dùng chatMedia thay thế')
  static const String receiptVietOCR = '/chat/messages/media';
}
