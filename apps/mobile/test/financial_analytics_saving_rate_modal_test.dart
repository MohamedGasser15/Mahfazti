import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_wallet/core/utils/shared_prefs.dart';
import 'package:my_wallet/features/wallet/presentation/screens/financial_analytics_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
      (methodCall) async => null,
    );

    SharedPreferences.setMockInitialValues({
      'selected_currency': 'EGP',
    });
    await SharedPrefs.init();
  });

  testWidgets('Tapping Savings rate card opens Where It Goes breakdown modal sheet', (tester) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('en'),
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [Locale('en'), Locale('ar')],
        home: FinancialAnalyticsScreen(),
      ),
    );

    await tester.pumpAndSettle();

    // Verify Savings rate is rendered
    expect(find.text('Savings rate'), findsOneWidget);
    expect(find.textContaining('of what you earned'), findsOneWidget);

    // Tap on the Savings rate card
    await tester.tap(find.text('Savings rate'));
    await tester.pumpAndSettle();

    // Verify the modal sheet appeared
    expect(find.text('Where it goes'), findsOneWidget);
    expect(find.textContaining('that came in'), findsOneWidget);
    expect(find.text('Shopping'), findsOneWidget);
    expect(find.text('Food'), findsOneWidget);
    expect(find.text('Education'), findsOneWidget);
    expect(find.text('Car Things'), findsOneWidget);
    expect(find.text('Electricity'), findsOneWidget);
  });
}
