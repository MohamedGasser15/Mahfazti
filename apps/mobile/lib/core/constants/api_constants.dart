class ApiEndpoints {
  // Auth
  static const String login = 'api/auth/login';
  static const String register = 'api/auth/register';
  static const String sendCode = 'api/auth/registration-codes';
  static const String verifyEmail = 'api/auth/registration-codes/verify';
  static const String forgotPassword = 'api/auth/password-reset-codes';
  static const String verifyResetCode = 'api/auth/password-reset-codes/verify';
  static const String resetPassword = 'api/auth/password-reset';
  static const String refresh = 'api/auth/token/refresh';
  static const String revoke = 'api/auth/revoke';
  static const String logout = 'api/auth/logout';
  static const String checkEmail = 'api/Auth/check-email';
  static const String googleLogin = 'api/Auth/GoogleMobile';
  static const String facebookLogin = 'api/Auth/FacebookMobile';

  // Accounts & Wealth
  static const String accounts = 'api/accounts';
  static const String accountById = 'api/accounts/';
  static const String wealthSummary = 'api/accounts/wealth-summary';

  // Wallet & Transactions
  static const String walletHome = 'api/wallet/home';
  static const String walletBalance = 'api/wallet/balance';
  static const String walletTransactions = 'api/wallet/transactions';
  static const String walletAddTransaction = 'api/wallet/transactions/add';
  static const String walletUpdateTransaction =
      'api/wallet/transactions/update';
  static const String walletDeleteTransaction =
      'api/wallet/transactions/delete';
  static const String walletTransfer = 'api/wallet/transfer';
  static const String walletSummary = 'api/wallet/summary';
  static const String walletVoiceParse = 'api/wallet/voice-parse';
  static const String budget = 'api/budget';
  static const String budgetCategory = 'api/Budget/category';

  // Categories & Groups
  static const String categories = 'api/Category';
  static const String categoryById = 'api/Category/';
  static const String categoryGroups = 'api/category-groups';
  static const String categoryGroupMappings = 'api/category-groups/mappings';
  static const String categoryGroupAssign = 'api/category-groups/assign';

  // Personal Recurring Bills & Subscriptions
  static const String recurringBills = 'api/recurring-bills';

  // AI Financial Advisor & Voice
  static const String aiChat = 'api/ai/chat';
  static const String aiConversations = 'api/ai/conversations';
  static const String aiVoiceParse = 'api/ai/voice-parse';

  // Banks & Financial Institutions
  static const String banks = 'api/banks';

  // Pricing Plans (SaaS) & In-App Purchases
  static const String plans = 'api/Plans';
  static const String verifyIapSubscription = 'api/Subscriptions/verify-iap';
  static const String mySubscription = 'api/Subscriptions/current';
  static const String cancelSubscription = 'api/Subscriptions/cancel';

  // Profile & Preferences
  static const String profileGet = 'api/Profile/get';
  static const String profileUpdate = 'api/Profile/update';
  static const String changePassword = 'api/Profile/change-password';
  static const String registerFcmToken = 'api/Profile/fcm-token';
  static const String setCurrency = 'api/profile/currency';
  static const String setLanguage = 'api/profile/language';
}
