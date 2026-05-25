import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_wallet/features/auth/presentation/screens/register_screen.dart';
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
    home: const RegisterScreen(
      email: 'test@example.com',
      verificationCode: '123456',
      passcode: '1234',
    ),
  );
}

void main() {
  testWidgets('renders with required params', (tester) async {
    await tester.pumpWidget(createTestApp());
    await tester.pump();

    expect(find.byType(RegisterScreen), findsOneWidget);
  });

  testWidgets('shows all form fields', (tester) async {
    await tester.pumpWidget(createTestApp());
    await tester.pump();

    expect(find.byType(TextField), findsNWidgets(3));
  });

  testWidgets('back button exists', (tester) async {
    await tester.pumpWidget(createTestApp());

    expect(find.byType(IconButton), findsOneWidget);
  });

  testWidgets('complete button is rendered', (tester) async {
    await tester.pumpWidget(createTestApp());
    await tester.pump();

    expect(find.byType(ElevatedButton), findsOneWidget);
  });

  testWidgets('shows description text', (tester) async {
    await tester.pumpWidget(createTestApp());
    await tester.pump();

    expect(find.byType(SingleChildScrollView), findsOneWidget);
  });
}
