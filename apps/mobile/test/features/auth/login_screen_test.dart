import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:my_wallet/core/widgets/app_back_button.dart';
import 'package:my_wallet/features/auth/presentation/screens/login_screen.dart';
import 'package:my_wallet/features/auth/presentation/widgets/social_login_section.dart';
import 'package:my_wallet/l10n/app_localizations.dart';

Widget createTestLoginApp({
  bool initialShowEmailForm = false,
  VoidCallback? onSwitchToRegister,
}) {
  return MaterialApp(
    locale: const Locale('en'),
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: MediaQuery(
      data: const MediaQueryData(disableAnimations: true),
      child: LoginScreen(
        initialShowEmailForm: initialShowEmailForm,
        onSwitchToRegister: onSwitchToRegister,
      ),
    ),
  );
}

void main() {
  testWidgets('renders standalone LoginScreen with social options first', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(createTestLoginApp());
    await tester.pumpAndSettle();

    expect(find.byType(SocialLoginSection), findsOneWidget);
    expect(find.textContaining('Continue with Google'), findsOneWidget);
    expect(find.textContaining('Continue with Facebook'), findsOneWidget);
    expect(find.textContaining('Sign in with email'), findsOneWidget);
  });

  testWidgets(
    'shows email form and back button when initialShowEmailForm is true',
    (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createTestLoginApp(initialShowEmailForm: true));
      await tester.pumpAndSettle();

      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.text('Sign in with email'), findsOneWidget);
      expect(find.byType(AppGlassBackButton), findsOneWidget);

      // Tapping back returns to social options
      await tester.tap(find.byType(AppGlassBackButton));
      await tester.pumpAndSettle();

      expect(find.byType(SocialLoginSection), findsOneWidget);
    },
  );

  testWidgets('calls onSwitchToRegister when register button tapped', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    var switched = false;
    await tester.pumpWidget(
      createTestLoginApp(onSwitchToRegister: () => switched = true),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Register'));
    await tester.pumpAndSettle();

    expect(switched, true);
  });
}
