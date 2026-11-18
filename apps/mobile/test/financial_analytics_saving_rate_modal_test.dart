import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_wallet/core/utils/shared_prefs.dart';
import 'package:my_wallet/features/wallet/data/models/category_group_model.dart';
import 'package:my_wallet/features/wallet/data/repositories/category_group_service.dart';
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

  testWidgets('Where It Goes modal displays Groups filter and aggregates spending when groups exist', (tester) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    // Setup Category Group
    await CategoryGroupService.saveGroup(
      CategoryGroup(
        id: 'living_essentials',
        name: 'Living Essentials',
        colorValue: 0xFF10B981,
        iconIndex: 1,
        createdAt: DateTime.now(),
      ),
    );
    // Map Food (id 1) and Shopping (id 2) to 'living_essentials'
    await CategoryGroupService.assignCategoryToGroup(1, 'living_essentials');
    await CategoryGroupService.assignCategoryToGroup(2, 'living_essentials');

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

    // Tap Savings rate card
    await tester.tap(find.text('Savings rate'));
    await tester.pumpAndSettle();

    // Switcher should exist: Categories & Groups
    expect(find.text('Categories'), findsOneWidget);
    expect(find.text('Groups'), findsOneWidget);

    // Tap Groups
    await tester.tap(find.text('Groups'));
    await tester.pumpAndSettle();

    // Group should be displayed along with Ungrouped
    expect(find.text('Living Essentials'), findsOneWidget);
    expect(find.text('Ungrouped'), findsOneWidget);

    // Clean up
    await CategoryGroupService.deleteGroup('living_essentials');
  });
}
