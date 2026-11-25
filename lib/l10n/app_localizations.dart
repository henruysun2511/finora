import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi')
  ];

  /// Tên ứng dụng Finora
  ///
  /// In vi, this message translates to:
  /// **'FINORA'**
  String get appTitle;

  /// No description provided for @commonSave.
  ///
  /// In vi, this message translates to:
  /// **'Lưu thay đổi'**
  String get commonSave;

  /// No description provided for @commonCancel.
  ///
  /// In vi, this message translates to:
  /// **'Hủy'**
  String get commonCancel;

  /// No description provided for @commonDelete.
  ///
  /// In vi, this message translates to:
  /// **'Xóa'**
  String get commonDelete;

  /// No description provided for @commonEdit.
  ///
  /// In vi, this message translates to:
  /// **'Chỉnh sửa'**
  String get commonEdit;

  /// No description provided for @commonCreate.
  ///
  /// In vi, this message translates to:
  /// **'Tạo mới'**
  String get commonCreate;

  /// No description provided for @commonConfirm.
  ///
  /// In vi, this message translates to:
  /// **'Xác nhận'**
  String get commonConfirm;

  /// No description provided for @commonBack.
  ///
  /// In vi, this message translates to:
  /// **'Quay lại'**
  String get commonBack;

  /// No description provided for @commonSearch.
  ///
  /// In vi, this message translates to:
  /// **'Tìm kiếm...'**
  String get commonSearch;

  /// No description provided for @commonFilter.
  ///
  /// In vi, this message translates to:
  /// **'Bộ lọc'**
  String get commonFilter;

  /// No description provided for @commonRetry.
  ///
  /// In vi, this message translates to:
  /// **'Thử lại'**
  String get commonRetry;

  /// No description provided for @commonClose.
  ///
  /// In vi, this message translates to:
  /// **'Đóng'**
  String get commonClose;

  /// No description provided for @commonSeeAll.
  ///
  /// In vi, this message translates to:
  /// **'Xem tất cả'**
  String get commonSeeAll;

  /// No description provided for @commonEmpty.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có dữ liệu nào'**
  String get commonEmpty;

  /// No description provided for @commonLoading.
  ///
  /// In vi, this message translates to:
  /// **'Đang tải...'**
  String get commonLoading;

  /// No description provided for @commonSuccess.
  ///
  /// In vi, this message translates to:
  /// **'Thành công'**
  String get commonSuccess;

  /// No description provided for @commonError.
  ///
  /// In vi, this message translates to:
  /// **'Đã xảy ra lỗi'**
  String get commonError;

  /// No description provided for @commonUnknown.
  ///
  /// In vi, this message translates to:
  /// **'Không xác định'**
  String get commonUnknown;

  /// No description provided for @navHome.
  ///
  /// In vi, this message translates to:
  /// **'Trang chủ'**
  String get navHome;

  /// No description provided for @navTransactions.
  ///
  /// In vi, this message translates to:
  /// **'Giao dịch'**
  String get navTransactions;

  /// No description provided for @navBudgets.
  ///
  /// In vi, this message translates to:
  /// **'Ngân sách'**
  String get navBudgets;

  /// No description provided for @navSocial.
  ///
  /// In vi, this message translates to:
  /// **'Bảng tin'**
  String get navSocial;

  /// No description provided for @navProfile.
  ///
  /// In vi, this message translates to:
  /// **'Tài khoản'**
  String get navProfile;

  /// No description provided for @authLogin.
  ///
  /// In vi, this message translates to:
  /// **'Đăng nhập'**
  String get authLogin;

  /// No description provided for @authRegister.
  ///
  /// In vi, this message translates to:
  /// **'Đăng ký'**
  String get authRegister;

  /// No description provided for @authLogout.
  ///
  /// In vi, this message translates to:
  /// **'Đăng xuất'**
  String get authLogout;

  /// No description provided for @authEmail.
  ///
  /// In vi, this message translates to:
  /// **'Email'**
  String get authEmail;

  /// No description provided for @authPassword.
  ///
  /// In vi, this message translates to:
  /// **'Mật khẩu'**
  String get authPassword;

  /// No description provided for @authConfirmPassword.
  ///
  /// In vi, this message translates to:
  /// **'Xác nhận mật khẩu'**
  String get authConfirmPassword;

  /// No description provided for @authForgotPassword.
  ///
  /// In vi, this message translates to:
  /// **'Quên mật khẩu?'**
  String get authForgotPassword;

  /// No description provided for @authGoogleSignIn.
  ///
  /// In vi, this message translates to:
  /// **'Đăng nhập bằng Google'**
  String get authGoogleSignIn;

  /// No description provided for @authDontHaveAccount.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có tài khoản? Đăng ký ngay'**
  String get authDontHaveAccount;

  /// No description provided for @authAlreadyHaveAccount.
  ///
  /// In vi, this message translates to:
  /// **'Đã có tài khoản? Đăng nhập'**
  String get authAlreadyHaveAccount;

  /// No description provided for @dashboardTotalBalance.
  ///
  /// In vi, this message translates to:
  /// **'Tổng tài sản'**
  String get dashboardTotalBalance;

  /// No description provided for @dashboardMonthlyIncome.
  ///
  /// In vi, this message translates to:
  /// **'Thu nhập tháng'**
  String get dashboardMonthlyIncome;

  /// No description provided for @dashboardMonthlyExpense.
  ///
  /// In vi, this message translates to:
  /// **'Chi tiêu tháng'**
  String get dashboardMonthlyExpense;

  /// No description provided for @dashboardCashflow.
  ///
  /// In vi, this message translates to:
  /// **'Dòng tiền'**
  String get dashboardCashflow;

  /// No description provided for @dashboardMyWallets.
  ///
  /// In vi, this message translates to:
  /// **'Nguồn tiền & Ví'**
  String get dashboardMyWallets;

  /// No description provided for @dashboardRecentTransactions.
  ///
  /// In vi, this message translates to:
  /// **'Giao dịch gần đây'**
  String get dashboardRecentTransactions;

  /// No description provided for @dashboardSpendingAlert.
  ///
  /// In vi, this message translates to:
  /// **'Cảnh báo chi tiêu'**
  String get dashboardSpendingAlert;

  /// No description provided for @dashboardNetWorth.
  ///
  /// In vi, this message translates to:
  /// **'Giá trị ròng'**
  String get dashboardNetWorth;

  /// No description provided for @txAdd.
  ///
  /// In vi, this message translates to:
  /// **'Thêm giao dịch'**
  String get txAdd;

  /// No description provided for @txExpense.
  ///
  /// In vi, this message translates to:
  /// **'Khoản chi'**
  String get txExpense;

  /// No description provided for @txIncome.
  ///
  /// In vi, this message translates to:
  /// **'Khoản thu'**
  String get txIncome;

  /// No description provided for @txTransfer.
  ///
  /// In vi, this message translates to:
  /// **'Chuyển tiền'**
  String get txTransfer;

  /// No description provided for @txAmount.
  ///
  /// In vi, this message translates to:
  /// **'Số tiền'**
  String get txAmount;

  /// No description provided for @txCategory.
  ///
  /// In vi, this message translates to:
  /// **'Hạng mục'**
  String get txCategory;

  /// No description provided for @txAccount.
  ///
  /// In vi, this message translates to:
  /// **'Nguồn tiền'**
  String get txAccount;

  /// No description provided for @txToAccount.
  ///
  /// In vi, this message translates to:
  /// **'Đến tài khoản'**
  String get txToAccount;

  /// No description provided for @txNote.
  ///
  /// In vi, this message translates to:
  /// **'Ghi chú'**
  String get txNote;

  /// No description provided for @txDate.
  ///
  /// In vi, this message translates to:
  /// **'Ngày giao dịch'**
  String get txDate;

  /// No description provided for @txLocation.
  ///
  /// In vi, this message translates to:
  /// **'Địa điểm'**
  String get txLocation;

  /// No description provided for @txScanReceipt.
  ///
  /// In vi, this message translates to:
  /// **'Quét hóa đơn AI'**
  String get txScanReceipt;

  /// No description provided for @txAmountHidden.
  ///
  /// In vi, this message translates to:
  /// **'Ẩn số tiền trong ví chia sẻ'**
  String get txAmountHidden;

  /// No description provided for @txVisibilityPrivate.
  ///
  /// In vi, this message translates to:
  /// **'Chỉ mình tôi (Riêng tư)'**
  String get txVisibilityPrivate;

  /// No description provided for @txVisibilityFriends.
  ///
  /// In vi, this message translates to:
  /// **'Bạn bè & Ví chung'**
  String get txVisibilityFriends;

  /// No description provided for @txSubmitSuccess.
  ///
  /// In vi, this message translates to:
  /// **'Đã ghi nhận giao dịch thành công'**
  String get txSubmitSuccess;

  /// No description provided for @budgetTitle.
  ///
  /// In vi, this message translates to:
  /// **'Quản lý ngân sách'**
  String get budgetTitle;

  /// No description provided for @budgetCreate.
  ///
  /// In vi, this message translates to:
  /// **'Tạo ngân sách'**
  String get budgetCreate;

  /// No description provided for @budgetSpent.
  ///
  /// In vi, this message translates to:
  /// **'Đã chi'**
  String get budgetSpent;

  /// No description provided for @budgetLimit.
  ///
  /// In vi, this message translates to:
  /// **'Hạn mức'**
  String get budgetLimit;

  /// No description provided for @budgetRemaining.
  ///
  /// In vi, this message translates to:
  /// **'Còn lại'**
  String get budgetRemaining;

  /// No description provided for @budgetExceeded.
  ///
  /// In vi, this message translates to:
  /// **'Đã vượt ngân sách'**
  String get budgetExceeded;

  /// No description provided for @loanTitle.
  ///
  /// In vi, this message translates to:
  /// **'Sổ nợ & Cho vay'**
  String get loanTitle;

  /// No description provided for @loanBorrow.
  ///
  /// In vi, this message translates to:
  /// **'Đi vay'**
  String get loanBorrow;

  /// No description provided for @loanLend.
  ///
  /// In vi, this message translates to:
  /// **'Cho vay'**
  String get loanLend;

  /// No description provided for @loanDueDate.
  ///
  /// In vi, this message translates to:
  /// **'Ngày đáo hạn'**
  String get loanDueDate;

  /// No description provided for @loanMarkPaid.
  ///
  /// In vi, this message translates to:
  /// **'Đã thanh toán xong'**
  String get loanMarkPaid;

  /// No description provided for @recurringTitle.
  ///
  /// In vi, this message translates to:
  /// **'Giao dịch định kỳ'**
  String get recurringTitle;

  /// No description provided for @recurringCreate.
  ///
  /// In vi, this message translates to:
  /// **'Tạo định kỳ'**
  String get recurringCreate;

  /// No description provided for @recurringDaily.
  ///
  /// In vi, this message translates to:
  /// **'Hàng ngày'**
  String get recurringDaily;

  /// No description provided for @recurringWeekly.
  ///
  /// In vi, this message translates to:
  /// **'Hàng tuần'**
  String get recurringWeekly;

  /// No description provided for @recurringMonthly.
  ///
  /// In vi, this message translates to:
  /// **'Hàng tháng'**
  String get recurringMonthly;

  /// No description provided for @splitTitle.
  ///
  /// In vi, this message translates to:
  /// **'Chia tiền nhóm'**
  String get splitTitle;

  /// No description provided for @splitCreate.
  ///
  /// In vi, this message translates to:
  /// **'Tạo nhóm chia tiền'**
  String get splitCreate;

  /// No description provided for @splitTotal.
  ///
  /// In vi, this message translates to:
  /// **'Tổng chi phí'**
  String get splitTotal;

  /// No description provided for @splitSettle.
  ///
  /// In vi, this message translates to:
  /// **'Quyết toán'**
  String get splitSettle;

  /// No description provided for @feedTitle.
  ///
  /// In vi, this message translates to:
  /// **'Bảng tin tài chính'**
  String get feedTitle;

  /// No description provided for @feedPost.
  ///
  /// In vi, this message translates to:
  /// **'Đăng bài'**
  String get feedPost;

  /// No description provided for @feedComment.
  ///
  /// In vi, this message translates to:
  /// **'Bình luận'**
  String get feedComment;

  /// No description provided for @feedReact.
  ///
  /// In vi, this message translates to:
  /// **'Thả cảm xúc'**
  String get feedReact;

  /// No description provided for @friendsTitle.
  ///
  /// In vi, this message translates to:
  /// **'Bạn bè & Kết nối'**
  String get friendsTitle;

  /// No description provided for @friendsSearch.
  ///
  /// In vi, this message translates to:
  /// **'Tìm bạn bè...'**
  String get friendsSearch;

  /// No description provided for @friendsRequests.
  ///
  /// In vi, this message translates to:
  /// **'Lời mời kết bạn'**
  String get friendsRequests;

  /// No description provided for @aiChatTitle.
  ///
  /// In vi, this message translates to:
  /// **'Trợ lý Nora'**
  String get aiChatTitle;

  /// No description provided for @aiChatHint.
  ///
  /// In vi, this message translates to:
  /// **'Hỏi Nora về chi tiêu, hóa đơn hoặc lời khuyên...'**
  String get aiChatHint;

  /// No description provided for @aiChatScanHint.
  ///
  /// In vi, this message translates to:
  /// **'Gửi ảnh hóa đơn để quét tự động'**
  String get aiChatScanHint;

  /// No description provided for @settingsTitle.
  ///
  /// In vi, this message translates to:
  /// **'Cài đặt chung'**
  String get settingsTitle;

  /// No description provided for @settingsSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Tiền tệ, ngôn ngữ, AI & hiển thị giao dịch'**
  String get settingsSubtitle;

  /// No description provided for @settingsLocalization.
  ///
  /// In vi, this message translates to:
  /// **'Bản địa hóa & Tiền tệ'**
  String get settingsLocalization;

  /// No description provided for @settingsCurrency.
  ///
  /// In vi, this message translates to:
  /// **'Đơn vị tiền tệ chính'**
  String get settingsCurrency;

  /// No description provided for @settingsLanguage.
  ///
  /// In vi, this message translates to:
  /// **'Ngôn ngữ hiển thị'**
  String get settingsLanguage;

  /// No description provided for @settingsPrivacy.
  ///
  /// In vi, this message translates to:
  /// **'Quyền riêng tư & Bảo mật'**
  String get settingsPrivacy;

  /// No description provided for @settingsDefaultAmountHidden.
  ///
  /// In vi, this message translates to:
  /// **'Mặc định ẩn số tiền'**
  String get settingsDefaultAmountHidden;

  /// No description provided for @settingsDefaultVisibility.
  ///
  /// In vi, this message translates to:
  /// **'Quyền riêng tư giao dịch mặc định'**
  String get settingsDefaultVisibility;

  /// No description provided for @settingsTheme.
  ///
  /// In vi, this message translates to:
  /// **'Giao diện (Sáng / Tối)'**
  String get settingsTheme;

  /// No description provided for @settingsThemeLight.
  ///
  /// In vi, this message translates to:
  /// **'Chế độ sáng'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In vi, this message translates to:
  /// **'Chế độ tối'**
  String get settingsThemeDark;

  /// No description provided for @settingsNotifications.
  ///
  /// In vi, this message translates to:
  /// **'Tùy chọn thông báo'**
  String get settingsNotifications;

  /// No description provided for @settingsAiConfig.
  ///
  /// In vi, this message translates to:
  /// **'Mô hình AI & API Key (Google Gemini)'**
  String get settingsAiConfig;

  /// No description provided for @settingsAiKeyPersonal.
  ///
  /// In vi, this message translates to:
  /// **'Đang dùng API Key riêng của bạn'**
  String get settingsAiKeyPersonal;

  /// No description provided for @settingsAiKeyDefault.
  ///
  /// In vi, this message translates to:
  /// **'Đang dùng API Key mặc định của Finora'**
  String get settingsAiKeyDefault;

  /// No description provided for @settingsAddAiKey.
  ///
  /// In vi, this message translates to:
  /// **'Thêm API Key riêng'**
  String get settingsAddAiKey;

  /// No description provided for @settingsChangeAiKey.
  ///
  /// In vi, this message translates to:
  /// **'Đổi API Key'**
  String get settingsChangeAiKey;

  /// No description provided for @settingsDeleteAiKey.
  ///
  /// In vi, this message translates to:
  /// **'Xóa API Key'**
  String get settingsDeleteAiKey;

  /// No description provided for @settingsAppInfo.
  ///
  /// In vi, this message translates to:
  /// **'Thông tin ứng dụng'**
  String get settingsAppInfo;

  /// No description provided for @settingsClearCache.
  ///
  /// In vi, this message translates to:
  /// **'Xóa bộ nhớ đệm hình ảnh'**
  String get settingsClearCache;

  /// No description provided for @settingsTerms.
  ///
  /// In vi, this message translates to:
  /// **'Điều khoản sử dụng'**
  String get settingsTerms;

  /// No description provided for @settingsPrivacyPolicy.
  ///
  /// In vi, this message translates to:
  /// **'Chính sách bảo mật'**
  String get settingsPrivacyPolicy;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
