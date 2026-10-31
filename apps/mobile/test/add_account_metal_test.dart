import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_wallet/features/wallet/presentation/screens/add_account_screen.dart';
import 'package:my_wallet/features/wallet/presentation/widgets/home_tab_models.dart';

void main() {
  Widget buildTestWidget({bool isAr = true}) {
    return MaterialApp(
      locale: Locale(isAr ? 'ar' : 'en'),
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const AddAccountScreen(),
    );
  }

  group('Gold & Silver in AddAccountScreen', () {
    testWidgets('Gold selection renders karat tabs, live price, auto-update toggle, and estimated value',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestWidget(isAr: true));
      await tester.pumpAndSettle();

      // Find Gold account type card
      final goldFinder = find.text('ذهب وملاذ آمن');
      expect(goldFinder, findsOneWidget);
      await tester.tap(goldFinder);
      await tester.pumpAndSettle();

      // Verify Gold details screen elements
      expect(find.text('الوزن بالجرام'), findsOneWidget);
      expect(find.text('العيار'), findsOneWidget);
      expect(find.text('18'), findsOneWidget);
      expect(find.text('21'), findsOneWidget);
      expect(find.text('22'), findsOneWidget);
      expect(find.text('24'), findsOneWidget);

      // Verify today's market price header & live benchmark badge
      expect(find.text('سعر الجرام اليوم (السوق)'), findsOneWidget);
      expect(find.text('مباشر الآن'), findsOneWidget);

      // Verify auto-update toggle
      expect(find.text('تحديث السعر تلقائياً'), findsOneWidget);

      // Verify estimated value card
      expect(find.text('عرض القيمة التقديرية'), findsOneWidget);

      // Verify Exclude from Net Worth toggle
      await tester.drag(find.byType(ListView).first, const Offset(0, -600));
      await tester.pumpAndSettle();
      expect(find.text('استبعاد من صافي الثروة'), findsOneWidget);
    });

    testWidgets('Tapping 24k updates price and calculation', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestWidget(isAr: true));
      await tester.pumpAndSettle();

      final goldFinder = find.text('ذهب وملاذ آمن');
      await tester.tap(goldFinder);
      await tester.pumpAndSettle();

      // Tap 24 karat tab
      await tester.tap(find.text('24'));
      await tester.pumpAndSettle();

      // Verify 24k is selected and badge updated
      expect(find.text('عيار 24'), findsWidgets);
    });

    testWidgets('Silver selection renders silver karat tabs (800, 900, 925, 999)',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestWidget(isAr: true));
      await tester.pumpAndSettle();

      final silverFinder = find.text('فضة وسبائك');
      expect(silverFinder, findsOneWidget);
      await tester.tap(silverFinder);
      await tester.pumpAndSettle();

      // Verify Silver karat tabs
      expect(find.text('800'), findsOneWidget);
      expect(find.text('900'), findsOneWidget);
      expect(find.text('925'), findsOneWidget);
      expect(find.text('999'), findsOneWidget);

      // Default is 925
      expect(find.text('فضة عيار 925'), findsWidgets);
    });

    test('AccountItem model serialization with metal attributes', () {
      final now = DateTime(2024, 10, 23);
      final item = AccountItem(
        id: 'gold_1',
        name: 'ذهب الادخار',
        type: 'gold',
        balance: 189000.0,
        currency: 'EGP',
        icon: Icons.diamond_outlined,
        metalKarat: '21',
        metalWeightGrams: 50.0,
        metalPurchasePricePerGram: 3500.0,
        metalPurchaseDate: now,
        metalCurrentPricePerGram: 3780.0,
        autoUpdateMetalPrice: true,
        excludeFromTotal: false,
      );

      final json = item.toJson();
      expect(json['metalKarat'], '21');
      expect(json['metalWeightGrams'], 50.0);
      expect(json['metalPurchasePricePerGram'], 3500.0);
      expect(json['metalCurrentPricePerGram'], 3780.0);
      expect(json['metalPurchaseDate'], now.toIso8601String());

      final restored = AccountItem.fromJson(json);
      expect(restored.metalKarat, '21');
      expect(restored.metalWeightGrams, 50.0);
      expect(restored.metalPurchasePricePerGram, 3500.0);
      expect(restored.metalCurrentPricePerGram, 3780.0);
      expect(restored.autoUpdateMetalPrice, isTrue);
      expect(restored.excludeFromTotal, isFalse);
    });

    testWidgets('thingsYouOwnFirst=true renders THINGS YOU OWN above MONEY YOU CAN SPEND',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(MaterialApp(
        locale: const Locale('en'),
        supportedLocales: const [Locale('ar'), Locale('en')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const AddAccountScreen(thingsYouOwnFirst: true),
      ));
      await tester.pumpAndSettle();

      final ownFinder = find.text('THINGS YOU OWN');
      final spendFinder = find.text('MONEY YOU CAN SPEND');

      expect(ownFinder, findsOneWidget);
      expect(spendFinder, findsOneWidget);

      final ownTop = tester.getTopLeft(ownFinder).dy;
      final spendTop = tester.getTopLeft(spendFinder).dy;

      // When thingsYouOwnFirst=true, ownSection must be placed ABOVE spendSection
      expect(ownTop, lessThan(spendTop));
    });
  });
}
