import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_wallet/core/services/api_service.dart';
import 'package:my_wallet/core/services/hide_balance_service.dart';
import 'package:my_wallet/core/utils/shared_prefs.dart';
import 'package:my_wallet/features/wallet/presentation/screens/home_tab.dart';
import 'package:my_wallet/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
      (MethodCall methodCall) async => null,
    );
    await SharedPrefs.init();

    final mockDio = Dio();
    mockDio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (options.path.contains('Category')) {
          handler.resolve(Response(
            requestOptions: options,
            data: [
              {'id': 1, 'nameAr': 'طعام', 'nameEn': 'Food'},
              {'id': 2, 'nameAr': 'تسوق', 'nameEn': 'Shopping'},
            ],
            statusCode: 200,
          ));
        } else {
          handler.resolve(Response(
            requestOptions: options,
            data: {
              'balance': {
                'totalBalance': 12500.0,
                'totalDeposits': 8000.0,
                'totalWithdrawals': 4500.0,
              },
              'recentTransactions': [],
              'totalTransactionCount': 0,
            },
            statusCode: 200,
          ));
        }
      },
    ));
    ApiService().dioForTesting = mockDio;
  });

  Widget buildApp({required TargetPlatform platform, bool isAr = true}) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HideBalanceService()),
      ],
      child: MaterialApp(
        theme: ThemeData(platform: platform),
        locale: Locale(isAr ? 'ar' : 'en'),
        supportedLocales: const [Locale('ar'), Locale('en')],
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const Scaffold(body: HomeTab()),
      ),
    );
  }

  testWidgets('Add Transaction on Android opens as a full page route', (tester) async {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(buildApp(platform: TargetPlatform.android, isAr: true));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump();

    // Find the Add (+) action button
    final addBtn = find.byIcon(Icons.add_rounded).first;
    expect(addBtn, findsOneWidget);

    await tester.tap(addBtn);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump();

    // Verify "معاملة جديدة" title is present
    expect(find.text('معاملة جديدة'), findsOneWidget);

    // Verify the page route contains the 3 transaction tabs: صرف, دخل, تحويل
    expect(find.text('صرف'), findsOneWidget);
    expect(find.text('دخل'), findsOneWidget);
    expect(find.text('تحويل'), findsOneWidget);

    // Verify it is rendered inside a page route (MaterialPageRoute) that is not a ModalBottomSheetRoute
    final modalRoute = ModalRoute.of(tester.element(find.text('معاملة جديدة')));
    expect(modalRoute is MaterialPageRoute, isTrue);

    // Tapping close (X) pops the page route
    final closeBtn = find.byIcon(Icons.close_rounded);
    expect(closeBtn, findsOneWidget);
    await tester.tap(closeBtn);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump();

    // Verify we returned to HomeTab
    expect(find.text('معاملة جديدة'), findsNothing);
    expect(find.byIcon(Icons.add_rounded), findsAtLeast(1));
  });

  testWidgets('Add Transaction on iOS opens as a modal bottom sheet', (tester) async {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(buildApp(platform: TargetPlatform.iOS, isAr: true));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump();

    // Find the Add (+) action button
    final addBtn = find.byIcon(Icons.add_rounded).first;
    expect(addBtn, findsOneWidget);

    await tester.tap(addBtn);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump();

    // Verify "معاملة جديدة" is present
    expect(find.text('معاملة جديدة'), findsOneWidget);

    // On iOS, it is opened as a modal sheet (not a full MaterialPageRoute page)
    final modalRoute = ModalRoute.of(tester.element(find.text('معاملة جديدة')));
    expect(modalRoute is! MaterialPageRoute, isTrue);

    // Close button (GlassButton on iOS) pops the sheet
    final closeBtn = find.byWidgetPredicate(
      (w) => w is Icon && w.icon == Icons.close_rounded && w.size == 21.0,
    );
    expect(closeBtn, findsOneWidget);
    await tester.tap(closeBtn);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump();

    expect(find.text('معاملة جديدة'), findsNothing);
  });

  testWidgets('Add Transaction on Android handles active FocusNode safely across exit transition without disposed error', (tester) async {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(buildApp(platform: TargetPlatform.android, isAr: true));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump();

    final addBtn = find.byIcon(Icons.add_rounded).first;
    await tester.tap(addBtn);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump();

    expect(find.text('معاملة جديدة'), findsOneWidget);

    // Enter text in amount field
    final amountField = find.byType(TextFormField).first;
    await tester.enterText(amountField, '150');
    await tester.pump();

    // Enter note / description
    final noteField = find.byType(TextField).first;
    await tester.enterText(noteField, 'Test note');
    await tester.pump();

    // Request focus explicitly on note field
    await tester.tap(noteField);
    await tester.pump();

    // Now pop the page route while fields have active focus and text
    final closeBtn = find.byIcon(Icons.close_rounded);
    await tester.tap(closeBtn);

    // Step through each frame of the pop animation (50ms increments)
    for (int i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump();

    // Page must be fully closed with zero uncaught exceptions
    expect(find.text('معاملة جديدة'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
