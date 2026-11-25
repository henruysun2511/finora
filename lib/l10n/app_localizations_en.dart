// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'FINORA';

  @override
  String get commonSave => 'Save Changes';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonEdit => 'Edit';

  @override
  String get commonCreate => 'Create New';

  @override
  String get commonConfirm => 'Confirm';

  @override
  String get commonBack => 'Back';

  @override
  String get commonSearch => 'Search...';

  @override
  String get commonFilter => 'Filter';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonClose => 'Close';

  @override
  String get commonSeeAll => 'See All';

  @override
  String get commonEmpty => 'No data available';

  @override
  String get commonLoading => 'Loading...';

  @override
  String get commonSuccess => 'Success';

  @override
  String get commonError => 'An error occurred';

  @override
  String get commonUnknown => 'Unknown';

  @override
  String get navHome => 'Home';

  @override
  String get navTransactions => 'Transactions';

  @override
  String get navBudgets => 'Budgets';

  @override
  String get navSocial => 'Feed';

  @override
  String get navProfile => 'Profile';

  @override
  String get authLogin => 'Sign In';

  @override
  String get authRegister => 'Sign Up';

  @override
  String get authLogout => 'Sign Out';

  @override
  String get authEmail => 'Email';

  @override
  String get authPassword => 'Password';

  @override
  String get authConfirmPassword => 'Confirm Password';

  @override
  String get authForgotPassword => 'Forgot password?';

  @override
  String get authGoogleSignIn => 'Continue with Google';

  @override
  String get authDontHaveAccount => 'Don\'t have an account? Sign up';

  @override
  String get authAlreadyHaveAccount => 'Already have an account? Sign in';

  @override
  String get dashboardTotalBalance => 'Total Balance';

  @override
  String get dashboardMonthlyIncome => 'Monthly Income';

  @override
  String get dashboardMonthlyExpense => 'Monthly Expense';

  @override
  String get dashboardCashflow => 'Cash Flow';

  @override
  String get dashboardMyWallets => 'Accounts & Wallets';

  @override
  String get dashboardRecentTransactions => 'Recent Transactions';

  @override
  String get dashboardSpendingAlert => 'Spending Alert';

  @override
  String get dashboardNetWorth => 'Net Worth';

  @override
  String get txAdd => 'Add Transaction';

  @override
  String get txExpense => 'Expense';

  @override
  String get txIncome => 'Income';

  @override
  String get txTransfer => 'Transfer';

  @override
  String get txAmount => 'Amount';

  @override
  String get txCategory => 'Category';

  @override
  String get txAccount => 'Account';

  @override
  String get txToAccount => 'To Account';

  @override
  String get txNote => 'Note';

  @override
  String get txDate => 'Transaction Date';

  @override
  String get txLocation => 'Location';

  @override
  String get txScanReceipt => 'AI Receipt Scanner';

  @override
  String get txAmountHidden => 'Hide amount in shared wallets';

  @override
  String get txVisibilityPrivate => 'Only Me (Private)';

  @override
  String get txVisibilityFriends => 'Friends & Shared Wallets';

  @override
  String get txSubmitSuccess => 'Transaction recorded successfully';

  @override
  String get budgetTitle => 'Budget Management';

  @override
  String get budgetCreate => 'Create Budget';

  @override
  String get budgetSpent => 'Spent';

  @override
  String get budgetLimit => 'Limit';

  @override
  String get budgetRemaining => 'Remaining';

  @override
  String get budgetExceeded => 'Budget Exceeded';

  @override
  String get loanTitle => 'Debts & Loans';

  @override
  String get loanBorrow => 'Borrow';

  @override
  String get loanLend => 'Lend';

  @override
  String get loanDueDate => 'Due Date';

  @override
  String get loanMarkPaid => 'Mark as Settled';

  @override
  String get recurringTitle => 'Recurring Transactions';

  @override
  String get recurringCreate => 'New Recurring';

  @override
  String get recurringDaily => 'Daily';

  @override
  String get recurringWeekly => 'Weekly';

  @override
  String get recurringMonthly => 'Monthly';

  @override
  String get splitTitle => 'Split Expenses';

  @override
  String get splitCreate => 'Create Split Group';

  @override
  String get splitTotal => 'Total Cost';

  @override
  String get splitSettle => 'Settle Up';

  @override
  String get feedTitle => 'Financial Feed';

  @override
  String get feedPost => 'New Post';

  @override
  String get feedComment => 'Comment';

  @override
  String get feedReact => 'React';

  @override
  String get friendsTitle => 'Friends & Social';

  @override
  String get friendsSearch => 'Find friends...';

  @override
  String get friendsRequests => 'Friend Requests';

  @override
  String get aiChatTitle => 'Nora Assistant';

  @override
  String get aiChatHint =>
      'Ask Nora about spending, receipts, or financial advice...';

  @override
  String get aiChatScanHint => 'Send receipt photo for automatic OCR scanning';

  @override
  String get settingsTitle => 'General Settings';

  @override
  String get settingsSubtitle => 'Currency, language, AI & transaction display';

  @override
  String get settingsLocalization => 'Localization & Currency';

  @override
  String get settingsCurrency => 'Primary Currency';

  @override
  String get settingsLanguage => 'Display Language';

  @override
  String get settingsPrivacy => 'Privacy & Security';

  @override
  String get settingsDefaultAmountHidden => 'Default Hide Amount';

  @override
  String get settingsDefaultVisibility => 'Default Transaction Privacy';

  @override
  String get settingsTheme => 'Theme (Light / Dark)';

  @override
  String get settingsThemeLight => 'Light Mode';

  @override
  String get settingsThemeDark => 'Dark Mode';

  @override
  String get settingsNotifications => 'Notification Preferences';

  @override
  String get settingsAiConfig => 'AI Model & API Key (Google Gemini)';

  @override
  String get settingsAiKeyPersonal => 'Using your personal API Key';

  @override
  String get settingsAiKeyDefault => 'Using Finora\'s default API Key';

  @override
  String get settingsAddAiKey => 'Add Personal API Key';

  @override
  String get settingsChangeAiKey => 'Change API Key';

  @override
  String get settingsDeleteAiKey => 'Delete API Key';

  @override
  String get settingsAppInfo => 'Application Info';

  @override
  String get settingsClearCache => 'Clear Image Cache';

  @override
  String get settingsTerms => 'Terms of Service';

  @override
  String get settingsPrivacyPolicy => 'Privacy Policy';
}
