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
  testWidgets('renders email text field', (tester) async {
    await tester.pumpWidget(createTestApp());
    await tester.pump();

    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('back button is rendered', (tester) async {
    await tester.pumpWidget(createTestApp());

    expect(find.byType(IconButton), findsOneWidget);
  });

  testWidgets('continue button is disabled for empty email', (tester) async {
    await tester.pumpWidget(createTestApp());
    await tester.pump();

    final continueButton = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Continue'),
    );
    expect(continueButton.onPressed, isNull);
  });

  testWidgets('shows clear button when text is entered', (tester) async {
    await tester.pumpWidget(createTestApp());
    await tester.pump();

    await tester.enterText(find.byType(TextField), 'test@example.com');
    await tester.pump();

    expect(find.byIcon(Icons.clear), findsOneWidget);
  });

  testWidgets('clears text when clear button is pressed', (tester) async {
    await tester.pumpWidget(createTestApp());
    await tester.pump();

    await tester.enterText(find.byType(TextField), 'test@example.com');
    await tester.pump();

    await tester.tap(find.byIcon(Icons.clear));
    await tester.pump();

    expect(find.byIcon(Icons.clear), findsNothing);
  });
}
