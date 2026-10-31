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

  group('Property & Investment in AddAccountScreen', () {
    testWidgets('Tapping property or investment opens 6 categories', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestWidget(isAr: false));
      await tester.pumpAndSettle();

      // Find Property or investment card
      final investmentFinder = find.text('Property or investment');
      expect(investmentFinder, findsOneWidget);
      await tester.tap(investmentFinder);
      await tester.pumpAndSettle();

      // Verify the 6 categories are rendered
      expect(find.text('Money market fund'), findsOneWidget);
      expect(find.text('Apartment or land'), findsOneWidget);
      expect(find.text('Car'), findsOneWidget);
      expect(find.text('Business'), findsOneWidget);
      expect(find.text('Stocks and crypto'), findsOneWidget);
      expect(find.text('Something else you own'), findsOneWidget);
    });

    testWidgets('Arabic locale: Tapping investment opens 6 categories in Arabic', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestWidget(isAr: true));
      await tester.pumpAndSettle();

      final investmentFinder = find.text('أصول واستثمار');
      expect(investmentFinder, findsOneWidget);
      await tester.tap(investmentFinder);
      await tester.pumpAndSettle();

      expect(find.text('صندوق استثمار نقدي'), findsOneWidget);
      expect(find.text('شقة أو أرض'), findsOneWidget);
      expect(find.text('سيارة'), findsOneWidget);
      expect(find.text('مشروع أو شركة'), findsOneWidget);
      expect(find.text('أسهم وعملات رقمية'), findsOneWidget);
      expect(find.text('شيء آخر تملكه'), findsOneWidget);
    });

    testWidgets('Money Market Fund flow: yield rate screen then details', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestWidget(isAr: false));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Property or investment'));
      await tester.pumpAndSettle();

      // Tap Money market fund
      await tester.tap(find.text('Money market fund'));
      await tester.pumpAndSettle();

      // Verify What does it pay a year step
      expect(find.text('What does it pay a year?'), findsOneWidget);
      expect(
        find.text('The yearly rate the fund shows. Mahfazti adds a day of it every night.'),
        findsOneWidget,
      );
      expect(find.text('% a year'), findsOneWidget);

      // Enter yield rate
      await tester.enterText(find.byType(TextField), '22');
      await tester.pumpAndSettle();

      // Tap Continue
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Verify details step
      expect(find.text('What is it worth now?'), findsOneWidget);
      expect(find.text('Note (optional)'), findsOneWidget);
    });

    testWidgets('Apartment flow: value change radio options then details', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestWidget(isAr: true));
      await tester.pumpAndSettle();

      await tester.tap(find.text('أصول واستثمار'));
      await tester.pumpAndSettle();

      // Tap Apartment or land
      await tester.tap(find.text('شقة أو أرض'));
      await tester.pumpAndSettle();

      // Verify value change screen
      expect(find.text('هل تتغير قيمته تلقائياً؟'), findsOneWidget);
      expect(
        find.text('يمكن لمحفظتي تعديل القيمة تدريجياً كل ليلة بناءً على تقديرك، وتسجيل القيمة الفعلية في أي وقت يُلغي التقدير.'),
        findsOneWidget,
      );

      // Verify Radio 1: "No, I'll update it myself"
      expect(find.text('لا، سأقوم بتحديثه بنفسي'), findsOneWidget);
      expect(find.text('محفظتي تذكرك بتحديث القيمة'), findsOneWidget);
      expect(find.text('شهرياً'), findsOneWidget);
      expect(find.text('كل 3 شهور'), findsOneWidget);
      expect(find.text('كل 6 شهور'), findsOneWidget);
      expect(find.text('أبداً'), findsOneWidget);

      // Tap Radio 2: "Yes, about"
      await tester.tap(find.text('نعم، بنسبة تقريبية'));
      await tester.pumpAndSettle();

      expect(find.text('زيادة / صعود'), findsOneWidget);
      expect(find.text('نقصان / هبوط'), findsOneWidget);

      // Tap Continue
      await tester.tap(find.text('متابعة'));
      await tester.pumpAndSettle();

      // Verify details screen
      expect(find.text('ما هي قيمته الآن؟'), findsOneWidget);
      expect(find.text('ملاحظة (اختياري)'), findsOneWidget);
    });

    testWidgets('Stocks & Crypto flow: select platform, enter worth and invested amount, see live P&L', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestWidget(isAr: true));
      await tester.pumpAndSettle();

      await tester.tap(find.text('أصول واستثمار'));
      await tester.pumpAndSettle();

      // Tap Stocks and crypto
      await tester.tap(find.text('أسهم وعملات رقمية'));
      await tester.pumpAndSettle();

      // Verify Market / Platform selection screen
      expect(find.text('البورصة المصرية (EGX)'), findsOneWidget);
      expect(find.text('الأسهم الأمريكية والعالمية'), findsOneWidget);
      expect(find.text('العملات الرقمية (Crypto)'), findsOneWidget);
      expect(find.text('محفظة استثمارية أخرى'), findsOneWidget);

      // Tap Egyptian Stocks (EGX)
      await tester.tap(find.text('البورصة المصرية (EGX)'));
      await tester.pumpAndSettle();

      // Verify Account Details screen
      expect(find.text('ما هي قيمته الآن؟'), findsOneWidget);
      expect(find.text('إجمالي المبلغ المستثمر'), findsOneWidget);
      expect(find.text('كم مرة تريد تحديث قيمة المحفظة؟'), findsOneWidget);

      // Find the two numeric TextFields for worth and invested amount
      final textFields = find.byType(TextField);
      // textFields: [0] name, [1] worth, [2] invested amount, [3] note
      expect(textFields, findsAtLeast(3));

      // Enter worth 115000 and invested 100000
      await tester.enterText(textFields.at(1), '115000');
      await tester.enterText(textFields.at(2), '100000');
      await tester.pumpAndSettle();

      // Verify live P&L badge is rendered with gain
      expect(find.textContaining('+15,000.00'), findsOneWidget);
      expect(find.textContaining('(+15.0%)'), findsOneWidget);
      expect(find.textContaining('صافي ربح تقديري:'), findsOneWidget);
    });

    testWidgets('Entering details step (e.g. Cash or Stocks) does not autofocus any field', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestWidget(isAr: true));
      await tester.pumpAndSettle();

      // Tap Cash (كاش ونقدي) which goes directly to details step
      await tester.tap(find.text('كاش ونقدي'));
      await tester.pumpAndSettle();

      expect(find.text('بيانات الحساب'), findsOneWidget);
      // Verify no text field has keyboard focus automatically
      final focus = FocusManager.instance.primaryFocus;
      expect(focus == null || !focus.hasFocus || focus.context?.widget is! EditableText, isTrue);
    });

    test('AccountItem model serialization with propertyCategory, stocks platform, and invested amount', () {
      final account = AccountItem(
        id: 'stocks_1',
        name: 'محفظة ثندر',
        type: 'investment',
        balance: 115000.0,
        icon: Icons.show_chart_rounded,
        propertyCategory: 'stocks_crypto',
        investmentPlatform: 'egx',
        totalInvestedAmount: 100000.0,
        reminderFrequency: 'monthly',
        note: 'أسهم البورصة المصرية',
      );

      final json = account.toJson();
      expect(json['propertyCategory'], equals('stocks_crypto'));
      expect(json['investmentPlatform'], equals('egx'));
      expect(json['totalInvestedAmount'], equals(100000.0));
      expect(json['reminderFrequency'], equals('monthly'));
      expect(json['note'], equals('أسهم البورصة المصرية'));

      final reconstructed = AccountItem.fromJson(json);
      expect(reconstructed.id, equals('stocks_1'));
      expect(reconstructed.propertyCategory, equals('stocks_crypto'));
      expect(reconstructed.investmentPlatform, equals('egx'));
      expect(reconstructed.totalInvestedAmount, equals(100000.0));
      expect(reconstructed.reminderFrequency, equals('monthly'));
      expect(reconstructed.note, equals('أسهم البورصة المصرية'));
    });

    test('AccountItem model serialization with propertyCategory and yield attributes', () {
      final account = AccountItem(
        id: 'prop_1',
        name: 'Apartment New Cairo',
        type: 'investment',
        balance: 3500000.0,
        icon: Icons.apartment_rounded,
        propertyCategory: 'apartment',
        autoEstimateValue: true,
        estimateRateYearly: 12.5,
        estimateDirection: 'up',
        reminderFrequency: '3_months',
        note: 'Purchased 2024',
      );

      final json = account.toJson();
      expect(json['propertyCategory'], equals('apartment'));
      expect(json['autoEstimateValue'], isTrue);
      expect(json['estimateRateYearly'], equals(12.5));
      expect(json['estimateDirection'], equals('up'));
      expect(json['reminderFrequency'], equals('3_months'));
      expect(json['note'], equals('Purchased 2024'));

      final reconstructed = AccountItem.fromJson(json);
      expect(reconstructed.id, equals('prop_1'));
      expect(reconstructed.propertyCategory, equals('apartment'));
      expect(reconstructed.autoEstimateValue, isTrue);
      expect(reconstructed.estimateRateYearly, equals(12.5));
      expect(reconstructed.estimateDirection, equals('up'));
      expect(reconstructed.reminderFrequency, equals('3_months'));
      expect(reconstructed.note, equals('Purchased 2024'));
    });
  });
}
