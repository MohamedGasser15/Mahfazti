import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:my_wallet/core/widgets/app_back_button.dart';
import 'package:my_wallet/features/auth/presentation/screens/auth_screen.dart';
import 'package:my_wallet/features/auth/presentation/screens/login_screen.dart';
import 'package:my_wallet/features/auth/presentation/screens/register_screen.dart';
import 'package:my_wallet/l10n/app_localizations.dart';

Widget createTestApp({
  AuthMode initialMode = AuthMode.login,
  Locale locale = const Locale('en'),
}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: MediaQuery(
      data: const MediaQueryData(disableAnimations: true),
      child: AuthScreen(initialMode: initialMode),
    ),
  );
}

void main() {
  testWidgets('renders login screen initially with social options', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.textContaining('Google'), findsOneWidget);
    expect(find.textContaining('Facebook'), findsOneWidget);
    expect(find.textContaining('Sign in with email'), findsOneWidget);
  });

  testWidgets(
    'renders email and password text fields and back button on email login form',
    (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Tap to switch to email login form
      await tester.tap(find.textContaining('Sign in with email'));
      await tester.pumpAndSettle();

      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.byType(AppGlassBackButton), findsOneWidget);
    },
  );

  testWidgets('switches to register tab when tapped', (tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();

    // Tap register button in AuthModeToggle
    await tester.tap(find.text('Register').first);
    await tester.pumpAndSettle();

    expect(find.byType(RegisterScreen), findsOneWidget);
    expect(find.byType(TextFormField), findsOneWidget); // Email input in step 0
    expect(find.byType(AppGlassBackButton), findsOneWidget);
  });

  testWidgets('back button on register tab switches back to login tab', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(createTestApp(initialMode: AuthMode.register));
    await tester.pumpAndSettle();

    expect(find.byType(RegisterScreen), findsOneWidget);
    expect(find.byType(AppGlassBackButton), findsOneWidget);

    // Tap back button
    await tester.tap(find.byType(AppGlassBackButton));
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
  });
}
