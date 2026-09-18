import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_wallet/features/auth/presentation/screens/email_screen.dart';
import 'package:my_wallet/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

Widget createTestApp() {
  return MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: const EmailScreen(),
  );
}

void main() {
  testWidgets('renders email and password text fields on login tab', (tester) async {
    await tester.pumpWidget(createTestApp());
    await tester.pump(const Duration(milliseconds: 1500));

    expect(find.byType(TextFormField), findsNWidgets(2));
  });

  testWidgets('back button is rendered', (tester) async {
    await tester.pumpWidget(createTestApp());
    await tester.pump(const Duration(milliseconds: 1500));

    expect(find.byIcon(Icons.arrow_back_ios_rounded), findsWidgets);
  });

  testWidgets('switches to register tab when tapped', (tester) async {
    await tester.pumpWidget(createTestApp());
    await tester.pump(const Duration(milliseconds: 1500));

    // Tap register tab (first occurrence is the toggle tab)
    await tester.tap(find.text('Register').first);
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsOneWidget); // Email input in step 0
  });
}
