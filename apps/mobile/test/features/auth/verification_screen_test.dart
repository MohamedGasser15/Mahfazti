import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_wallet/features/auth/presentation/screens/verification_screen.dart';
import 'package:my_wallet/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

Widget createTestApp({required String email, required bool isLogin}) {
  return MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: VerificationScreen(
      email: email,
      isLogin: isLogin,
    ),
  );
}

void main() {
  testWidgets('renders with email and isLogin params', (tester) async {
    await tester.pumpWidget(createTestApp(
      email: 'test@example.com',
      isLogin: false,
    ));
    await tester.pump();

    expect(find.byType(VerificationScreen), findsOneWidget);
  });

  testWidgets('shows email chip', (tester) async {
    await tester.pumpWidget(createTestApp(
      email: 'user@domain.com',
      isLogin: false,
    ));

    expect(find.text('user@domain.com'), findsOneWidget);
  });

  testWidgets('shows code input boxes', (tester) async {
    await tester.pumpWidget(createTestApp(
      email: 'test@example.com',
      isLogin: false,
    ));

    expect(find.byType(AutofillGroup), findsOneWidget);
  });

  testWidgets('renders with isLogin true', (tester) async {
    await tester.pumpWidget(createTestApp(
      email: 'test@example.com',
      isLogin: true,
    ));

    expect(find.byType(VerificationScreen), findsOneWidget);
  });

  testWidgets('back button exists', (tester) async {
    await tester.pumpWidget(createTestApp(
      email: 'test@example.com',
      isLogin: false,
    ));

    expect(find.byType(IconButton), findsOneWidget);
  });

  testWidgets('shows countdown timer', (tester) async {
    await tester.pumpWidget(createTestApp(
      email: 'test@example.com',
      isLogin: false,
    ));

    expect(find.byIcon(Icons.timer), findsOneWidget);
  });
}
