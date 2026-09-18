class ApiEndpoints {
  // Auth
  static const String login = 'api/Auth/Login';
  static const String register = 'api/Auth/Register';
  static const String sendCode = 'api/Auth/send-code';
  static const String verifyEmail = 'api/Auth/verify-email';
  static const String forgotPassword = 'api/Auth/forgot-password';
  static const String verifyResetCode = 'api/Auth/verify-reset-code';
  static const String resetPassword = 'api/Auth/reset-password';
  static const String refresh = 'api/Auth/refresh';
  static const String revoke = 'api/Auth/revoke';
  static const String logout = 'api/Auth/logout';
  static const String checkEmail = 'api/Auth/check-email';
  static const String googleLogin = 'api/Auth/GoogleMobile';
  static const String facebookLogin = 'api/Auth/FacebookMobile';
  static const String setCurrency = 'api/Auth/set-currency';
  static const String setLanguage = 'api/Auth/set-language';

  // Wallet
  static const String walletHome = 'api/wallet/home';
  static const String walletBalance = 'api/wallet/balance';
  static const String walletTransactions = 'api/wallet/transactions';
  static const String walletAddTransaction = 'api/wallet/transactions/add';
  static const String walletUpdateTransaction = 'api/wallet/transactions/update';
  static const String walletDeleteTransaction = 'api/wallet/transactions/delete';
  static const String walletSummary = 'api/wallet/summary';
  static const String walletVoiceParse = 'api/wallet/voice-parse';
  static const String budget = 'api/budget';
  static const String budgetCategory = 'api/Budget/category';

  // Category
  static const String categories = 'api/Category';
  static const String categoryById = 'api/Category/';

  // Profile
  static const String profileGet = 'api/Profile/get';
  static const String profileUpdate = 'api/Profile/update';
  static const String changePassword = 'api/Profile/change-password';
}