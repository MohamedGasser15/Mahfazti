import 'package:flutter/material.dart';
import 'package:my_wallet/features/auth/presentation/screens/currency_selection_screen.dart';
import 'package:my_wallet/features/auth/presentation/screens/email_screen.dart';
import 'package:my_wallet/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:my_wallet/features/splash/presentation/screens/splash_screen.dart';
import 'package:my_wallet/features/wallet/presentation/screens/home_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String email = '/email';
  static const String login = '/login';
  static const String register = '/register';
  static const String currencySelection = '/currency-selection';
  static const String home = '/home';
  static const String setPasscode = '/set-passcode';
  static const String pin = '/pin';
  static const String changePasscode = '/change-passcode';

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
      case login:
      case register:
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => const EmailScreen(),
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

      default:
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => SplashScreen(onLocaleChanged: onLocaleChanged),
        );
    }
  }
}

