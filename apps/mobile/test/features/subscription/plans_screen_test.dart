import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_wallet/features/subscription/presentation/screens/plans_screen.dart';
import 'package:my_wallet/l10n/app_localizations.dart';

Widget _wrap(Widget child, {Locale locale = const Locale('en')}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    theme: ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF09090B),
    ),
    home: child,
  );
}

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  void sizeAsPhone(WidgetTester tester) {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
  }

  testWidgets('renders the plans screen in English', (tester) async {
    sizeAsPhone(tester);

    await tester.pumpWidget(_wrap(const PlansScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Plans & Subscriptions'), findsOneWidget);
    expect(find.text('Monthly'), findsOneWidget);
    expect(find.text('Yearly'), findsOneWidget);
    expect(find.text('MAHFAZTI PRO'), findsOneWidget);
    expect(find.text('89'), findsOneWidget);
    expect(find.text('Subscribe Now'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('Free Basic'), 250);
    await tester.pumpAndSettle();

    expect(find.text('Free Basic'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('Current Plan'), 250);
    await tester.pumpAndSettle();

    expect(find.text('Current Plan'), findsOneWidget);
  });

  testWidgets('switches between monthly and yearly billing', (tester) async {
    sizeAsPhone(tester);

    await tester.pumpWidget(_wrap(const PlansScreen()));
    await tester.pumpAndSettle();

    expect(find.text('89'), findsOneWidget);
    expect(find.text('699'), findsNothing);

    await tester.tap(find.text('Yearly'));
    await tester.pumpAndSettle();

    expect(find.text('699'), findsOneWidget);
    expect(find.text('89'), findsNothing);
  });

  testWidgets('renders the plans screen in Arabic', (tester) async {
    sizeAsPhone(tester);

    await tester.pumpWidget(
      _wrap(const PlansScreen(), locale: const Locale('ar')),
    );
    await tester.pumpAndSettle();

    expect(find.text('الباقات والاشتراكات'), findsOneWidget);
    expect(find.text('شهرياً'), findsOneWidget);
    expect(find.text('سنوياً'), findsOneWidget);
    expect(find.text('محفظتي برو'), findsOneWidget);
    expect(find.text('اشترك الآن'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('الباقة المجانية'), 250);
    await tester.pumpAndSettle();

    expect(find.text('الباقة المجانية'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('الباقة الحالية'), 250);
    await tester.pumpAndSettle();

    expect(find.text('الباقة الحالية'), findsOneWidget);
  });
}
