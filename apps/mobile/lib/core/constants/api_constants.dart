// core/constants/api_constants.dart
class ApiEndpoints {
  // Auth
  static const String sendVerification = 'api/auth/send-verification';
  static const String verifyCode = 'api/auth/verify-code';
  static const String resendCode = 'api/auth/resend-code';
  static const String verifyAndComplete = 'api/auth/verify-complete';
  static const String logout = 'api/auth/logout';
  static const String checkEmail = 'api/auth/check-email';
  static const String recoveryCheckUser = 'api/auth/recovery/check-user';
  static const String recoveryVerifyPassword = 'api/auth/recovery/verify-password';
  static const String recoveryRequestEmailChange = 'api/auth/recovery/request-email-change';
  static const String recoveryConfirmEmailChange = 'api/auth/recovery/confirm-email-change';
  static const String forgotPasscode = 'api/auth/passcode/forgot';
  static const String resetPasscode = 'api/auth/passcode/reset';

  // Wallet
  static const String walletHome = 'api/wallet/home';
  static const String walletBalance = 'api/wallet/balance';
  static const String walletTransactions = 'api/wallet/transactions';
  static const String walletAddTransaction = 'api/wallet/transactions/add';
  static const String walletDeleteTransaction = 'api/wallet/transactions/delete';
  static const String walletSummary = 'api/wallet/summary';
  static const String budget = 'api/budget';
  static const String setCurrency = 'api/auth/set-currency';
  static const String walletUpdateTransaction = 'api/wallet/transactions/update';
  // Category
  static const String categories = 'api/Category';
  static const String categoryById = 'api/Category/';

  // Profile
  static const String profileGet = 'api/Profile/get';
  static const String profileUpdate = 'api/Profile/update';
  static const String changePassword = 'api/Profile/change-password';
  static const String hideBalancesKey = 'hideBalances';
}