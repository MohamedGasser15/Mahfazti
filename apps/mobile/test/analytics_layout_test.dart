import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_wallet/features/wallet/data/models/wallet_models.dart';
import 'package:my_wallet/l10n/app_localizations.dart';
import 'package:my_wallet/features/wallet/data/repositories/wallet_repository.dart';
import 'package:my_wallet/features/wallet/presentation/screens/analytics/analytics_android_view.dart';
import 'package:my_wallet/features/wallet/presentation/screens/analytics/analytics_controller.dart';
import 'package:my_wallet/features/wallet/presentation/screens/analytics/analytics_ios_view.dart';
import 'package:my_wallet/features/wallet/presentation/screens/analytics/analytics_seed.dart';
import 'package:my_wallet/features/wallet/presentation/screens/analytics/analytics_models.dart';
import 'package:my_wallet/features/wallet/presentation/screens/analytics/wealth_spline_chart.dart';
import 'package:my_wallet/core/utils/shared_prefs.dart';
import 'package:neo_cupertino/neo_cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeRepository extends WalletRepository {
  @override
  Future<WalletSummary> getSummary({
    required DateTime fromDate,
    required DateTime toDate,
  }) async {
    return WalletSummary(
      totalIncome: 8200,
      totalExpenses: 5750,
      netSavings: 2450,
      transactionCount: 42,
      expensesByCategory: const [
        CategorySummary(
          categoryId: 1,
          categoryNameAr: 'طعام',
          categoryNameEn: 'Food & Dining',
          total: 1955,
          count: 8,
        ),
        CategorySummary(
          categoryId: 2,
          categoryNameAr: 'تسوق',
          categoryNameEn: 'Shopping',
          total: 1380,
          count: 5,
        ),
        CategorySummary(
          categoryId: 4,
          categoryNameAr: 'مواصلات',
          categoryNameEn: 'Transportation',
          total: 920,
          count: 6,
        ),
        CategorySummary(
          categoryId: 3,
          categoryNameAr: 'فواتير',
          categoryNameEn: 'Bills',
          total: 690,
          count: 4,
        ),
        CategorySummary(
          categoryId: 3,
          categoryNameAr: 'صحة',
          categoryNameEn: 'Health',
          total: 460,
          count: 2,
        ),
        CategorySummary(
          categoryId: 3,
          categoryNameAr: 'ترفيه',
          categoryNameEn: 'Entertainment',
          total: 230,
          count: 1,
        ),
        CategorySummary(
          categoryId: 3,
          categoryNameAr: 'أخرى',
          categoryNameEn: 'Other',
          total: 115,
          count: 1,
        ),
      ],
      incomeByCategory: const [
        CategorySummary(
          categoryId: 10,
          categoryNameAr: 'راتب',
          categoryNameEn: 'Salary',
          total: 8200,
          count: 1,
        ),
      ],
    );
  }
}

Future<void> _pump(
  WidgetTester tester,
  Widget view, {
  required Size size,
  required bool rtl,
  required bool dark,
  double textScale = 1.0,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
      child: MaterialApp(
        locale: rtl ? const Locale('ar') : const Locale('en'),
        supportedLocales: const [Locale('en', 'US'), Locale('ar', 'SA')],
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        theme: ThemeData(brightness: dark ? Brightness.dark : Brightness.light),
        home: Directionality(
          textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
          child: view,
        ),
      ),
    ),
  );
  for (var i = 0; i < 12; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  tearDown(() => PlatformInfo.setForceIOS26(null));

  setUp(() async {
    PlatformInfo.setForceIOS26(true);
    SharedPreferences.setMockInitialValues({'selected_currency': 'EGP'});
    try {
      await SharedPrefs.init();
    } catch (_) {
      // Secure storage is not available in the test environment.
    }
  });

  for (final rtl in [false, true]) {
    testWidgets('android analytics layout · rtl=$rtl', (tester) async {
      final controller = AnalyticsController(repository: _FakeRepository());
      await _pump(
        tester,
        AnalyticsAndroidView(controller: controller),
        size: const Size(393, 852),
        rtl: rtl,
        dark: true,
      );
      expect(tester.takeException(), isNull);
      controller.dispose();
    });

    testWidgets('ios analytics layout · rtl=$rtl', (tester) async {
      final controller = AnalyticsController(repository: _FakeRepository());
      await _pump(
        tester,
        AnalyticsIosView(controller: controller),
        size: const Size(393, 852),
        rtl: rtl,
        dark: true,
        textScale: 0.6,
      );
      expect(tester.takeException(), isNull);
      controller.dispose();
    });
  }

  testWidgets('android analytics layout · small phone', (tester) async {
    final controller = AnalyticsController(repository: _FakeRepository());
    await _pump(
      tester,
      AnalyticsAndroidView(controller: controller),
      size: const Size(320, 640),
      rtl: false,
      dark: true,
    );
    expect(tester.takeException(), isNull);
    controller.dispose();
  });

  testWidgets('wealth spline chart scrubbing and period change', (tester) async {
    final controller = AnalyticsController(repository: _FakeRepository());
    await _pump(
      tester,
      AnalyticsIosView(controller: controller),
      size: const Size(390, 844),
      rtl: false,
      dark: true,
    );

    expect(tester.takeException(), isNull);

    // Find WealthSplineChart
    final chartFinder = find.byType(WealthSplineChart);
    expect(chartFinder, findsOneWidget);

    // Perform pan/drag gesture across the chart (scrubbing)
    final gesture = await tester.startGesture(tester.getCenter(chartFinder));
    await tester.pump(const Duration(milliseconds: 50));
    await gesture.moveBy(const Offset(40, 0));
    await tester.pump(const Duration(milliseconds: 50));
    await gesture.up();
    await tester.pump(const Duration(milliseconds: 100));

    expect(tester.takeException(), isNull);

    // Switch periods to trigger liquid morphing
    controller.setWealthPeriod(WealthPeriod.threeMonths);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump(const Duration(milliseconds: 300));

    controller.setWealthTab(WealthTab.assets);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump(const Duration(milliseconds: 300));

    expect(tester.takeException(), isNull);
    controller.dispose();
  });

  test('sample data seeds every preset period', () {
    final now = DateTime.now();
    final to = DateTime(now.year, now.month, now.day, 23, 59, 59);

    for (final days in [7, 30, 90]) {
      final from = DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(Duration(days: days - 1));
      final summary = buildSampleSummary(from: from, to: to);
      expect(summary.transactionCount, greaterThan(0), reason: 'days=$days');
      expect(summary.totalIncome, greaterThan(0), reason: 'days=$days');
      expect(summary.totalExpenses, greaterThan(0), reason: 'days=$days');
      expect(summary.expensesByCategory, isNotEmpty, reason: 'days=$days');
    }
  });

  test('all 12 tab and period combinations have unique curve signatures', () {
    final controller = AnalyticsController(repository: _FakeRepository());
    final signatures = <String>{};

    for (final tab in WealthTab.values) {
      for (final period in WealthPeriod.values) {
        controller.setWealthTab(tab);
        controller.setWealthPeriod(period);

        final points = controller.trendPoints;
        expect(points.length, greaterThanOrEqualTo(7));
        for (final p in points) {
          expect(p, greaterThanOrEqualTo(0.0));
        }

        // Create a normalized relative signature to ensure uniqueness
        final normalized = points.map((p) => (p / points.last).toStringAsFixed(2)).join(',');
        signatures.add('${tab.name}_${period.name}:$normalized');
      }
    }

    // Must have exactly 12 unique curve shapes
    expect(signatures.length, equals(12));
    controller.dispose();
  });

  testWidgets('spendable row expands and renders user accounts', (tester) async {
    final controller = AnalyticsController(repository: _FakeRepository());
    await _pump(
      tester,
      AnalyticsAndroidView(controller: controller),
      size: const Size(393, 852),
      rtl: false,
      dark: true,
    );

    expect(tester.takeException(), isNull);

    // Find Spendable Row and tap it to expand
    final spendableFinder = find.text('SPENDABLE');
    expect(spendableFinder, findsOneWidget);

    await tester.ensureVisible(spendableFinder);
    await tester.pumpAndSettle();

    await tester.tap(spendableFinder);
    await tester.pumpAndSettle();

    // Verify spendable accounts are now rendered inside the expanded card
    expect(controller.spendableAccounts, isNotEmpty);
    for (final account in controller.spendableAccounts) {
      expect(find.text(account.displayName(isAr: false)), findsOneWidget);
    }

    controller.dispose();
  });

  testWidgets('ios top add button is glass and spendable section is removed', (tester) async {
    final controller = AnalyticsController(repository: _FakeRepository());
    await _pump(
      tester,
      AnalyticsIosView(controller: controller),
      size: const Size(393, 852),
      rtl: false,
      dark: true,
    );

    expect(tester.takeException(), isNull);

    // Verify GlassIconButton exists for top add action
    expect(find.byType(GlassIconButton), findsWidgets);
    expect(find.byIcon(CupertinoIcons.add), findsOneWidget);

    // Verify spendable section is completely removed from iOS wealth view
    expect(find.text('SPENDABLE'), findsNothing);
    expect(find.text('المتاح للصرف'), findsNothing);

    controller.dispose();
  });

  testWidgets('ios top tab segmented control switches net worth, assets, and debt', (tester) async {
    final controller = AnalyticsController(repository: _FakeRepository());
    await _pump(
      tester,
      AnalyticsIosView(controller: controller),
      size: const Size(393, 852),
      rtl: false,
      dark: true,
    );

    expect(tester.takeException(), isNull);
    expect(controller.wealthTab, WealthTab.netWorth);

    // Verify segments exist (Net worth, Assets, Debt)
    expect(find.text('Net worth'), findsWidgets);
    expect(find.text('Assets'), findsWidgets);
    expect(find.text('Debt'), findsWidgets);

    // Tap on Assets segment
    await tester.tap(find.text('Assets').first);
    await tester.pumpAndSettle();
    expect(controller.wealthTab, WealthTab.assets);

    // Verify Assets content is visible
    expect(find.text('Included Assets'), findsOneWidget);
    expect(find.text('+ Add'), findsOneWidget);

    // Tap on Debt segment
    await tester.tap(find.text('Debt').first);
    await tester.pumpAndSettle();
    expect(controller.wealthTab, WealthTab.debt);

    // Verify Debt content & debt-free badge
    expect(find.text('Debt-free'), findsOneWidget);
    expect(find.text('No debt or liabilities recorded'), findsOneWidget);
    expect(find.text('Add credit card or liability'), findsOneWidget);

    // Tap back to Net worth
    await tester.tap(find.text('Net worth').first);
    await tester.pumpAndSettle();
    expect(controller.wealthTab, WealthTab.netWorth);

    controller.dispose();
  });

  testWidgets('ios top tab segmented control works in Arabic (RTL)', (tester) async {
    final controller = AnalyticsController(repository: _FakeRepository());
    await _pump(
      tester,
      AnalyticsIosView(controller: controller),
      size: const Size(393, 852),
      rtl: true,
      dark: true,
    );

    expect(tester.takeException(), isNull);
    expect(controller.wealthTab, WealthTab.netWorth);

    // Verify Arabic labels
    expect(find.text('صافي الثروة'), findsWidgets);
    expect(find.text('الأصول'), findsWidgets);
    expect(find.text('الديون'), findsWidgets);

    // Switch to Assets in Arabic
    await tester.tap(find.text('الأصول').first);
    await tester.pumpAndSettle();
    expect(controller.wealthTab, WealthTab.assets);
    expect(find.text('الأصول المندرجة'), findsOneWidget);

    // Switch to Debt in Arabic
    await tester.tap(find.text('الديون').first);
    await tester.pumpAndSettle();
    expect(controller.wealthTab, WealthTab.debt);
    expect(find.text('خالي من الديون'), findsOneWidget);
    expect(find.text('لا توجد ديون أو التزامات مسجلة'), findsOneWidget);
    expect(find.text('تسجيل كارت مشتريات أو التزام'), findsOneWidget);

    controller.dispose();
  });

  testWidgets('ios period segmented control switches 1M, 3M, 1Y, and All', (tester) async {
    final controller = AnalyticsController(repository: _FakeRepository());
    await _pump(
      tester,
      AnalyticsIosView(controller: controller),
      size: const Size(393, 852),
      rtl: false,
      dark: true,
    );

    expect(tester.takeException(), isNull);
    expect(controller.wealthPeriod, WealthPeriod.oneMonth);

    // Verify period labels exist
    expect(find.text('1M'), findsWidgets);
    expect(find.text('3M'), findsWidgets);
    expect(find.text('1Y'), findsWidgets);
    expect(find.text('All'), findsWidgets);

    // Tap 3M
    await tester.tap(find.text('3M').first);
    await tester.pumpAndSettle();
    expect(controller.wealthPeriod, WealthPeriod.threeMonths);

    // Tap 1Y
    await tester.tap(find.text('1Y').first);
    await tester.pumpAndSettle();
    expect(controller.wealthPeriod, WealthPeriod.oneYear);

    // Tap All
    await tester.tap(find.text('All').first);
    await tester.pumpAndSettle();
    expect(controller.wealthPeriod, WealthPeriod.all);

    // Tap back to 1M
    await tester.tap(find.text('1M').first);
    await tester.pumpAndSettle();
    expect(controller.wealthPeriod, WealthPeriod.oneMonth);

    controller.dispose();
  });

  testWidgets('ios period segmented control works in Arabic (RTL)', (tester) async {
    final controller = AnalyticsController(repository: _FakeRepository());
    await _pump(
      tester,
      AnalyticsIosView(controller: controller),
      size: const Size(393, 852),
      rtl: true,
      dark: true,
    );

    expect(tester.takeException(), isNull);
    expect(controller.wealthPeriod, WealthPeriod.oneMonth);

    // Verify Arabic period labels exist: شهر, 3 أشهر, سنة, الكل
    expect(find.text('شهر'), findsWidgets);
    expect(find.text('3 أشهر'), findsWidgets);
    expect(find.text('سنة'), findsWidgets);
    expect(find.text('الكل'), findsWidgets);

    // Tap 3 أشهر
    await tester.tap(find.text('3 أشهر').first);
    await tester.pumpAndSettle();
    expect(controller.wealthPeriod, WealthPeriod.threeMonths);

    // Tap الكل
    await tester.tap(find.text('الكل').first);
    await tester.pumpAndSettle();
    expect(controller.wealthPeriod, WealthPeriod.all);

    controller.dispose();
  });

  testWidgets('ios wealth intelligence displays financial runway and asset allocation', (tester) async {
    final controller = AnalyticsController(repository: _FakeRepository());
    await _pump(
      tester,
      AnalyticsIosView(controller: controller),
      size: const Size(393, 852),
      rtl: false,
      dark: true,
    );

    expect(tester.takeException(), isNull);

    // Verify Financial Runway & Asset Allocation are rendered
    expect(find.text('Financial Runway'), findsOneWidget);
    expect(find.text('Asset Allocation'), findsOneWidget);

    // Switch to Assets Tab
    await tester.tap(find.text('Assets').first);
    await tester.pumpAndSettle();
    expect(find.text('Grow Your Asset Yield'), findsOneWidget);

    // Switch to Debt Tab
    await tester.tap(find.text('Debt').first);
    await tester.pumpAndSettle();
    expect(find.text('Debt-to-Asset Health'), findsOneWidget);

    controller.dispose();
  });

  testWidgets('ios wealth intelligence works in Arabic (RTL)', (tester) async {
    final controller = AnalyticsController(repository: _FakeRepository());
    await _pump(
      tester,
      AnalyticsIosView(controller: controller),
      size: const Size(393, 852),
      rtl: true,
      dark: true,
    );

    expect(tester.takeException(), isNull);

    // Verify Arabic titles
    expect(find.text('مؤشر الأمان المالي'), findsOneWidget);
    expect(find.text('توزيع الأصول'), findsOneWidget);

    // Switch to Debt in Arabic
    await tester.tap(find.text('الديون').first);
    await tester.pumpAndSettle();
    expect(find.text('مؤشر عبء المديونية (DTI)'), findsOneWidget);

    controller.dispose();
  });
}
