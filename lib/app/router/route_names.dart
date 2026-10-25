/// Định danh các Route Names trên toàn ứng dụng FINORA
/// Đồng bộ với device-preview, finora_be modules và tài liệu mo-ta-ui
class RouteNames {
  RouteNames._();

  // 1. Auth & Onboarding
  static const String welcome = 'welcome';
  static const String login = 'login';
  static const String register = 'register';
  static const String forgotPassword = 'forgotPassword';

  static const String onboardingWelcome = 'onboardingWelcome';
  static const String onboardingProfile = 'onboardingProfile';
  static const String onboardingWallet = 'onboardingWallet';
  static const String onboardingMascot = 'onboardingMascot';
  static const String onboardingAllSet = 'onboardingAllSet';

  // 2. Shell Tabs (Bottom Navigation)
  static const String home = 'home';
  static const String dashboard = home;
  static const String budgets = 'budgets';
  static const String aiChat = 'aiChat';
  static const String profile = 'profile';
  static const String userProfileDetail = 'userProfileDetail';

  // 3. Transactions (Giao dịch thu chi)
  static const String transactions = 'transactions';
  static const String transactionDetail = 'transactionDetail';
  static const String createTransaction = 'createTransaction';
  static const String scanReceipt = 'scanReceipt';
  static const String recurringTransactions = 'recurringTransactions';
  static const String createRecurringTransaction = 'createRecurringTransaction';

  // 4. Wallets & Accounts (Ví & Tài khoản ngân hàng)
  static const String wallets = 'wallets';
  static const String walletDetail = 'walletDetail';
  static const String createWallet = 'createWallet';
  static const String sharedWallets = 'sharedWallets';
  static const String createSharedWallet = 'createSharedWallet';
  static const String accountDetail = 'accountDetail';
  static const String createAccount = 'createAccount';
  static const String transfer = 'transfer';

  // 5. Budgets (Ngân sách)
  static const String createBudget = 'createBudget';
  static const String budgetDetail = 'budgetDetail';

  // 6. Loans & Split Expenses (Sổ nợ & Chia tiền nhóm)
  static const String loans = 'loans';
  static const String loanDetail = 'loanDetail';
  static const String createLoan = 'createLoan';
  static const String splitExpenses = 'splitExpenses';
  static const String splitExpenseDetail = 'splitExpenseDetail';
  static const String createSplitExpense = 'createSplitExpense';

  // 8. Reports & Analytics (Báo cáo & Phân tích)
  static const String analytics = 'analytics';
  static const String cashflowReport = 'cashflowReport';
  static const String categoryReport = 'categoryReport';
  static const String exchangeRates = 'exchangeRates';

  // 9. Social, Friends & Messages (Bảng tin, Bạn bè & Tin nhắn)
  static const String socialFeed = 'socialFeed';
  static const String friends = 'friends';
  static const String socialChat = 'socialChat';

  // 10. Settings & Notifications (Cài đặt & Thông báo)
  static const String notifications = 'notifications';
  static const String settings = 'settings';
  static const String securitySettings = 'securitySettings';
  static const String categorySettings = 'categorySettings';
  static const String aiPersonaSettings = 'aiPersonaSettings';
  static const String notificationSettings = 'notificationSettings';

  // 11. Sample Features (CRUD Mẫu)
  static const String products = 'products';
  static const String productDetail = 'productDetail';
  static const String createProduct = 'createProduct';
  static const String editProduct = 'editProduct';
}

/// Định danh các URL Path tương ứng
class RoutePaths {
  RoutePaths._();

  // 1. Auth & Onboarding
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';

  static const String onboardingWelcome = '/onboarding/welcome';
  static const String onboardingProfile = '/onboarding/profile';
  static const String onboardingWallet = '/onboarding/wallet';
  static const String onboardingMascot = '/onboarding/mascot';
  static const String onboardingAllSet = '/onboarding/all-set';

  // 2. Shell Tabs
  static const String home = '/home';
  static const String dashboard = home;
  static const String budgets = '/budgets';
  static const String aiChat = '/chat-ai';
  static const String profile = '/profile';
  static const String userProfileDetail = '/profile/detail';

  // 3. Transactions
  static const String transactions = '/transactions';
  static const String transactionDetail = '/transactions/:id';
  static const String createTransaction = '/transactions/create';
  static const String scanReceipt = '/transactions/scan';
  static const String recurringTransactions = '/transactions/recurring';
  static const String createRecurringTransaction = '/transactions/recurring/create';

  // 4. Wallets & Accounts
  static const String wallets = '/wallets';
  static const String walletDetail = '/wallets/:id';
  static const String createWallet = '/wallets/create';
  static const String sharedWallets = '/wallets/shared';
  static const String createSharedWallet = '/wallets/shared/create';
  static const String accountDetail = '/accounts/:id';
  static const String createAccount = '/accounts/create';
  static const String transfer = '/transfer';

  // 5. Budgets
  static const String createBudget = '/budgets/create';
  static const String budgetDetail = '/budgets/:id';

  // 6. Loans & Split Expenses
  static const String loans = '/loans';
  static const String loanDetail = '/loans/:id';
  static const String createLoan = '/loans/create';
  static const String splitExpenses = '/split-expenses';
  static const String splitExpenseDetail = '/split-expenses/:id';
  static const String createSplitExpense = '/split-expenses/create';

  // 8. Reports & Analytics
  static const String analytics = '/analytics';
  static const String cashflowReport = '/reports/cashflow';
  static const String categoryReport = '/reports/category';
  static const String exchangeRates = '/exchange-rates';

  // 9. Social, Friends & Messages
  static const String socialFeed = '/feed';
  static const String friends = '/friends';
  static const String socialChat = '/social-chat';

  // 10. Settings & Notifications
  static const String notifications = '/notifications';
  static const String settings = '/settings';
  static const String securitySettings = '/settings/security';
  static const String categorySettings = '/settings/categories';
  static const String aiPersonaSettings = '/settings/ai-persona';
  static const String notificationSettings = '/settings/notifications';

  // 11. Sample Features (CRUD Mẫu)
  static const String products = '/products';
  static const String productDetail = '/products/:id';
  static const String createProduct = '/products/create';
  static const String editProduct = '/products/:id/edit';
}
