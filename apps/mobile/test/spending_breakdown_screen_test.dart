import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_wallet/features/wallet/presentation/screens/spending_breakdown_screen.dart';
import 'package:my_wallet/l10n/app_localizations.dart';

void main() {
  Widget buildTestWidget({required Widget child, bool isAr = false, Brightness brightness = Brightness.light}) {
    return MaterialApp(
      theme: ThemeData(
        brightness: brightness,
      ),
      locale: Locale(isAr ? 'ar' : 'en'),
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: child,
    );
  }

  testWidgets('SpendingBreakdownScreen renders breakdown chart, categories and month pill in English (Light Mode)', (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(buildTestWidget(
      child: const SpendingBreakdownScreen(currency: 'EGP'),
      isAr: false,
      brightness: Brightness.light,
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verify App Bar & Subheader
    expect(find.text('Spending Breakdown'), findsOneWidget);
    expect(find.text('All accounts'), findsOneWidget);

    // Verify Total Spent in Donut Center
    expect(find.text('Total spent'), findsOneWidget);

    // Verify Category Rows
    expect(find.text('Shopping'), findsOneWidget);
    expect(find.text('Food'), findsOneWidget);
    expect(find.text('Education'), findsOneWidget);
    expect(find.text('Car Things'), findsOneWidget);

    // Verify Month Selector Pill
    expect(find.text('October 2026'), findsOneWidget);
  });

  testWidgets('SpendingBreakdownScreen renders in Arabic (Dark Mode) with RTL', (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(buildTestWidget(
      child: const SpendingBreakdownScreen(currency: 'EGP'),
      isAr: true,
      brightness: Brightness.dark,
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verify localized text
    expect(find.text('توزيع المصروفات'), findsOneWidget);
    expect(find.text('جميع الحسابات'), findsOneWidget);
    expect(find.text('إجمالي المصروف'), findsOneWidget);
    expect(find.text('تسوق ومستلزمات'), findsOneWidget);
  });

  testWidgets('Tapping Shopping category opens transactions sheet with details', (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(buildTestWidget(
      child: const SpendingBreakdownScreen(currency: 'EGP'),
      isAr: false,
      brightness: Brightness.light,
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Tap on Shopping category
    await tester.tap(find.text('Shopping'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Verify details sheet content
    expect(find.text('21 transactions'), findsOneWidget);
    expect(find.text('EGP 6,395'), findsAtLeastNWidgets(1));
    expect(find.text('برجر'), findsOneWidget);
    expect(find.text('مخبز'), findsOneWidget);
    expect(find.text('حاجات افريكانو لجيسي'), findsOneWidget);
  });

  testWidgets('CategoryTransactionsScreen (Android page route) renders standalone with back button', (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final categories = SpendingBreakdownSeed.getCategories('EGP');
    final shopping = categories.first;

    await tester.pumpWidget(buildTestWidget(
      child: CategoryTransactionsScreen(
        category: shopping,
        currency: 'EGP',
        date: DateTime(2026, 10, 1),
      ),
      isAr: false,
      brightness: Brightness.light,
    ));
    await tester.pump();

    expect(find.text('Shopping'), findsOneWidget);
    expect(find.text('21 transactions'), findsOneWidget);
    expect(find.text('EGP 6,395'), findsOneWidget);
    expect(find.text('برجر'), findsOneWidget);
  });
}
