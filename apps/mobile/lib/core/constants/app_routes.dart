import 'package:flutter/material.dart';
import 'package:my_wallet/features/auth/presentation/screens/change_passcode_screen.dart';
import 'package:my_wallet/features/auth/presentation/screens/currency_selection_screen.dart';
import 'package:my_wallet/features/auth/presentation/screens/email_screen.dart';
import 'package:my_wallet/features/auth/presentation/screens/passcode_screen.dart';
import 'package:my_wallet/features/auth/presentation/screens/pin_screen.dart';
import 'package:my_wallet/features/auth/presentation/screens/recovery_check_user_screen.dart';
import 'package:my_wallet/features/auth/presentation/screens/recovery_new_email_screen.dart';
import 'package:my_wallet/features/auth/presentation/screens/recovery_otp_screen.dart';
import 'package:my_wallet/features/auth/presentation/screens/recovery_password_screen.dart';
import 'package:my_wallet/features/auth/presentation/screens/register_screen.dart';
import 'package:my_wallet/features/auth/presentation/screens/reset_passcode_screen.dart';
import 'package:my_wallet/features/auth/presentation/screens/set_passcode_screen.dart';
import 'package:my_wallet/features/auth/presentation/screens/verification_screen.dart';
import 'package:my_wallet/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:my_wallet/features/splash/presentation/screens/splash_screen.dart';
import 'package:my_wallet/features/wallet/presentation/screens/home_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String email = '/email';
  static const String verification = '/verification';
  static const String passcode = '/passcode';
  static const String register = '/register';
  static const String currencySelection = '/currency-selection';
  static const String home = '/home';
  static const String setPasscode = '/set-passcode';
  static const String pin = '/pin';
  static const String recoveryCheckUser = '/recovery-check-user';
  static const String recoveryPassword = '/recovery-password';
  static const String recoveryNewEmail = '/recovery-new-email';
  static const String recoveryOtp = '/recovery-otp';
  static const String changePasscode = '/change-passcode';
  static const String resetPasscode = '/reset-passcode';

  static Route<dynamic> onGenerateRoute(
    RouteSettings settings, {
    required ValueChanged<Locale> onLocaleChanged,
  }) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => SplashScreen(onLocaleChanged: onLocaleChanged),
        );

      case onboarding:
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => OnboardingScreen(onLocaleChanged: onLocaleChanged),
        );

      case email:
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => const EmailScreen(),
        );

      case verification:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => VerificationScreen(
            email: args['email'] as String? ?? '',
            isLogin: args['isLogin'] as bool? ?? false,
          ),
        );

      case passcode:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => PasscodeScreen(
            email: args['email'] as String? ?? '',
            verificationCode: args['verificationCode'] as String? ?? '',
            isLogin: args['isLogin'] as bool? ?? false,
          ),
        );

      case register:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => RegisterScreen(
            email: args['email'] as String? ?? '',
            verificationCode: args['verificationCode'] as String? ?? '',
            passcode: args['passcode'] as String? ?? '',
          ),
        );

      case currencySelection:
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => const CurrencySelectionScreen(),
        );

      case home:
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => const HomeScreen(),
        );

      case setPasscode:
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => const SetPasscodeScreen(),
        );

      case pin:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => PinScreen(
            isFirstTime: args?['isFirstTime'] as bool? ?? false,
            showBiometricFirst: args?['showBiometricFirst'] as bool? ?? true,
          ),
        );

      case recoveryCheckUser:
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => const RecoveryCheckUserScreen(),
        );

      case recoveryPassword:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => RecoveryPasswordScreen(
            emailOrUsername: args['emailOrUsername'] as String? ?? '',
          ),
        );

      case recoveryNewEmail:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => RecoveryNewEmailScreen(
            emailOrUsername: args['emailOrUsername'] as String? ?? '',
            password: args['password'] as String? ?? '',
          ),
        );

      case recoveryOtp:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => RecoveryOtpScreen(
            emailOrUsername: args['emailOrUsername'] as String? ?? '',
            newEmail: args['newEmail'] as String? ?? '',
          ),
        );

      case changePasscode:
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => const ChangePasscodeScreen(),
        );

      case resetPasscode:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => ResetPasscodeScreen(
            email: args['email'] as String? ?? '',
            otpCode: args['otpCode'] as String? ?? '',
          ),
        );

      default:
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => SplashScreen(onLocaleChanged: onLocaleChanged),
        );
    }
  }
}
