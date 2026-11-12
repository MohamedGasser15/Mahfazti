import 'dart:io' show Platform;

class AppConstants {
  static const String appName = 'محفظتي';
  static const String appVersion = '1.0.0';

  /// Whether code is currently running inside flutter test runner
  static bool get isTestingEnvironment {
    try {
      return Platform.environment.containsKey('FLUTTER_TEST') ||
          Platform.resolvedExecutable.contains('flutter_tester');
    } catch (_) {
      return false;
    }
  }

  static const String baseUrl = 'https://mahfazati.runasp.net/';

  /// When true, uses the mock backend engine.
  /// Set to false to use the live ASP.NET Core API!
  static const bool useMockBackend = false;

  // Storage Keys
  static const String isFirstTimeKey = 'isFirstTime';
  static const String authTokenKey = 'authToken';
  static const String refreshTokenKey = 'refreshToken';
  static const String userDataKey = 'userData';
  static const String appLanguageKey = 'appLanguage';
  static const String hideBalancesKey = 'hideBalances';
  static const String selectedCurrencyKey = 'selected_currency';
  static const String userPasswordKey = 'user_password';
  static const String userEmailKey = 'user_email';
  static const String tempEmailKey = 'temp_email';
  static const String tempIsLoginKey = 'temp_is_login';
  static const String verifiedEmailKey = 'verified_email';
  static const String verifiedCodeKey = 'verified_code';
  static const String isCodeVerifiedKey = 'is_code_verified';
  static const String biometricEnabledKey = 'biometric_enabled';
  static const String selectedThemeKey = 'selected_theme';

  // App Languages
  static const String arabic = 'ar';
  static const String english = 'en';
}
