import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/ai_chat/presentation/screens/ai_chat_screen.dart';
import '../../features/analytics/presentation/screens/analytics_screen.dart';
import '../../features/analytics/presentation/screens/cashflow_report_screen.dart';
import '../../features/analytics/presentation/screens/category_report_screen.dart';
import '../../features/analytics/presentation/screens/exchange_rates_screen.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/welcome_screen.dart';
import '../../features/budgets/presentation/screens/budget_detail_screen.dart';
import '../../features/budgets/presentation/screens/budgets_screen.dart';
import '../../features/budgets/presentation/screens/create_budget_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/loans/presentation/screens/create_loan_screen.dart';
import '../../features/loans/presentation/screens/loan_detail_screen.dart';
import '../../features/loans/presentation/screens/loans_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_all_set_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_mascot_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_profile_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_wallet_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_welcome_screen.dart';
import '../../features/products/presentation/screens/product_detail_screen.dart';
import '../../features/products/presentation/screens/product_form_screen.dart';
import '../../features/products/presentation/screens/products_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/user_profile_detail_screen.dart';
import '../../features/settings/presentation/screens/ai_persona_settings_screen.dart';
import '../../features/settings/presentation/screens/category_settings_screen.dart';
import '../../features/settings/presentation/screens/notification_settings_screen.dart';
import '../../features/settings/presentation/screens/security_settings_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/social/presentation/screens/friends_screen.dart';
import '../../features/social/presentation/screens/social_chat_screen.dart';
import '../../features/social/presentation/screens/social_feed_screen.dart';
import '../../features/split_expenses/presentation/screens/create_split_expense_screen.dart';
import '../../features/split_expenses/presentation/screens/split_expense_detail_screen.dart';
import '../../features/split_expenses/presentation/screens/split_expenses_screen.dart';
import '../../features/transactions/presentation/screens/create_transaction_screen.dart';
import '../../features/recurring_transaction/presentation/screens/recurring-transaction-screen.dart' as recurring_list;
import '../../features/recurring_transaction/presentation/screens/recurring-transaction-form-screen.dart' as recurring_form;
import '../../features/transactions/presentation/screens/scan_receipt_screen.dart';
import '../../features/transactions/presentation/screens/transaction_detail_screen.dart';
import '../../features/transactions/presentation/screens/transactions_screen.dart';
import '../../features/wallets/presentation/screens/account_detail_screen.dart';
import '../../features/wallets/presentation/screens/create_account_screen.dart';
import '../../features/wallets/presentation/screens/create_shared_wallet_screen.dart';
import '../../features/wallets/presentation/screens/create_wallet_screen.dart';
import '../../features/wallets/presentation/screens/shared_wallets_screen.dart';
import '../../features/wallets/presentation/screens/transfer_screen.dart';
import '../../features/wallets/presentation/screens/wallet_detail_screen.dart';
import '../../features/wallets/presentation/screens/wallets_screen.dart';
import 'route_names.dart';
import 'scaffold_with_nav_bar.dart';

part 'app_router.g.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

@Riverpod(keepAlive: true)
GoRouter appRouter(AppRouterRef ref) {
  final notifier = _AuthRefreshNotifier(ref);
  ref.onDispose(notifier.dispose);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: RoutePaths.home,
    debugLogDiagnostics: false,
    refreshListenable: notifier,
    redirect: (context, state) {
      final authState = ref.read(authNotifierProvider);

      if (authState.isLoading) return null;

      final isLoggedIn = authState.valueOrNull != null;
      final location = state.matchedLocation;
      final isOnPublicAuthPage = location == RoutePaths.login ||
          location == RoutePaths.register ||
          location == RoutePaths.welcome ||
          location == RoutePaths.forgotPassword ||
          location.startsWith('/onboarding');

      if (!isLoggedIn && !isOnPublicAuthPage) return RoutePaths.login;
      if (isLoggedIn && (location == RoutePaths.login || location == RoutePaths.register)) {
        return RoutePaths.home;
      }
      return null;
    },
    routes: [
      // ==========================================
      // 1. AUTH & ONBOARDING (Độc lập, Không Shell)
      // ==========================================
      GoRoute(
        path: RoutePaths.welcome,
        name: RouteNames.welcome,
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: RoutePaths.login,
        name: RouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RoutePaths.register,
        name: RouteNames.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: RoutePaths.forgotPassword,
        name: RouteNames.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      // Luồng Onboarding 5 bước
      GoRoute(
        path: RoutePaths.onboardingWelcome,
        name: RouteNames.onboardingWelcome,
        builder: (context, state) => const OnboardingWelcomeScreen(),
      ),
      GoRoute(
        path: RoutePaths.onboardingProfile,
        name: RouteNames.onboardingProfile,
        builder: (context, state) => const OnboardingProfileScreen(),
      ),
      GoRoute(
        path: RoutePaths.onboardingWallet,
        name: RouteNames.onboardingWallet,
        builder: (context, state) => const OnboardingWalletScreen(),
      ),
      GoRoute(
        path: RoutePaths.onboardingMascot,
        name: RouteNames.onboardingMascot,
        builder: (context, state) => const OnboardingMascotScreen(),
      ),
      GoRoute(
        path: RoutePaths.onboardingAllSet,
        name: RouteNames.onboardingAllSet,
        builder: (context, state) => const OnboardingAllSetScreen(),
      ),

      // ==========================================
      // 2. KHUNG SHELL NAVIGATION (4 Tab chính)
      // ==========================================
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNavBar(navigationShell: navigationShell);
        },
        branches: [
          // Branch 0: Trang chủ (Home)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.home,
                name: RouteNames.home,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),

          // Branch 1: Ngân sách & Sổ GD (Budgets)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.budgets,
                name: RouteNames.budgets,
                builder: (context, state) => const BudgetsScreen(),
              ),
            ],
          ),

          // Branch 2: Nora AI Chatbot (Chat AI)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.aiChat,
                name: RouteNames.aiChat,
                builder: (context, state) => const AiChatScreen(),
              ),
            ],
          ),

          // Branch 3: Cá nhân & Cài đặt (Profile)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.profile,
                name: RouteNames.profile,
                builder: (context, state) => const ProfileScreen(),
                routes: [
                  GoRoute(
                    parentNavigatorKey: _rootNavigatorKey,
                    path: 'detail',
                    name: RouteNames.userProfileDetail,
                    builder: (context, state) =>
                        const UserProfileDetailScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),

      // ==========================================
      // 3. PHÂN HỆ GIAO DỊCH (Transactions)
      // ==========================================
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.transactions,
        name: RouteNames.transactions,
        builder: (context, state) => const TransactionsScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.createTransaction,
        name: RouteNames.createTransaction,
        builder: (context, state) => const CreateTransactionScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.scanReceipt,
        name: RouteNames.scanReceipt,
        builder: (context, state) => const ScanReceiptScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.recurringTransactions,
        name: RouteNames.recurringTransactions,
        builder: (context, state) =>
            const recurring_list.RecurringTransactionsScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.createRecurringTransaction,
        name: RouteNames.createRecurringTransaction,
        builder: (context, state) =>
            const recurring_form.RecurringTransactionFormScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.transactionDetail,
        name: RouteNames.transactionDetail,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return TransactionDetailScreen(transactionId: id);
        },
      ),

      // ==========================================
      // 4. PHÂN HỆ VÍ & TÀI KHOẢN (Wallets & Accounts)
      // ==========================================
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.wallets,
        name: RouteNames.wallets,
        builder: (context, state) => const WalletsScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.createWallet,
        name: RouteNames.createWallet,
        builder: (context, state) => const CreateWalletScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.sharedWallets,
        name: RouteNames.sharedWallets,
        builder: (context, state) => const SharedWalletsScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.createSharedWallet,
        name: RouteNames.createSharedWallet,
        builder: (context, state) => const CreateSharedWalletScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.walletDetail,
        name: RouteNames.walletDetail,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return WalletDetailScreen(walletId: id);
        },
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.createAccount,
        name: RouteNames.createAccount,
        builder: (context, state) => const CreateAccountScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.accountDetail,
        name: RouteNames.accountDetail,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return AccountDetailScreen(accountId: id);
        },
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.transfer,
        name: RouteNames.transfer,
        builder: (context, state) => const TransferScreen(),
      ),

      // ==========================================
      // 5. PHÂN HỆ NGÂN SÁCH (Budgets Sub-routes)
      // ==========================================
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.createBudget,
        name: RouteNames.createBudget,
        builder: (context, state) => const CreateBudgetScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.budgetDetail,
        name: RouteNames.budgetDetail,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return BudgetDetailScreen(budgetId: id);
        },
      ),

      // ==========================================
      // 6. PHÂN HỆ SỔ NỢ & CHIA TIỀN NHÓM (Loans & Split)
      // ==========================================
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.loans,
        name: RouteNames.loans,
        builder: (context, state) => const LoansScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.createLoan,
        name: RouteNames.createLoan,
        builder: (context, state) => const CreateLoanScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.loanDetail,
        name: RouteNames.loanDetail,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return LoanDetailScreen(loanId: id);
        },
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.splitExpenses,
        name: RouteNames.splitExpenses,
        builder: (context, state) => const SplitExpensesScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.createSplitExpense,
        name: RouteNames.createSplitExpense,
        builder: (context, state) => const CreateSplitExpenseScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.splitExpenseDetail,
        name: RouteNames.splitExpenseDetail,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return SplitExpenseDetailScreen(splitId: id);
        },
      ),

      // ==========================================
      // 8. PHÂN HỆ BÁO CÁO & PHÂN TÍCH (Reports)
      // ==========================================
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.analytics,
        name: RouteNames.analytics,
        builder: (context, state) => const AnalyticsScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.cashflowReport,
        name: RouteNames.cashflowReport,
        builder: (context, state) => const CashflowReportScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.categoryReport,
        name: RouteNames.categoryReport,
        builder: (context, state) => const CategoryReportScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.exchangeRates,
        name: RouteNames.exchangeRates,
        builder: (context, state) => const ExchangeRatesScreen(),
      ),

      // ==========================================
      // 9. PHÂN HỆ XÃ HỘI, BẠN BÈ & TIN NHẮN (Social)
      // ==========================================
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.socialFeed,
        name: RouteNames.socialFeed,
        builder: (context, state) => const SocialFeedScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.friends,
        name: RouteNames.friends,
        builder: (context, state) => const FriendsScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.socialChat,
        name: RouteNames.socialChat,
        builder: (context, state) => const SocialChatScreen(),
      ),

      // ==========================================
      // 10. CÀI ĐẶT & THÔNG BÁO (Settings)
      // ==========================================
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.notifications,
        name: RouteNames.notifications,
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.settings,
        name: RouteNames.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.securitySettings,
        name: RouteNames.securitySettings,
        builder: (context, state) => const SecuritySettingsScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.categorySettings,
        name: RouteNames.categorySettings,
        builder: (context, state) => const CategorySettingsScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.aiPersonaSettings,
        name: RouteNames.aiPersonaSettings,
        builder: (context, state) => const AiPersonaSettingsScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.notificationSettings,
        name: RouteNames.notificationSettings,
        builder: (context, state) => const NotificationSettingsScreen(),
      ),

      // ==========================================
      // 11. PHÂN HỆ MẪU: QUẢN LÝ SẢN PHẨM (CRUD Product)
      // ==========================================
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.products,
        name: RouteNames.products,
        builder: (context, state) => const ProductsScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.createProduct,
        name: RouteNames.createProduct,
        builder: (context, state) => const ProductFormScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.editProduct,
        name: RouteNames.editProduct,
        builder: (context, state) {
          final id = state.pathParameters['id'];
          return ProductFormScreen(productId: id);
        },
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.productDetail,
        name: RouteNames.productDetail,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return ProductDetailScreen(productId: id);
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Không tìm thấy trang: ${state.uri}'),
      ),
    ),
  );
}

class _AuthRefreshNotifier extends ChangeNotifier {
  _AuthRefreshNotifier(Ref ref) {
    ref.listen(authNotifierProvider, (_, __) => notifyListeners());
  }
}
