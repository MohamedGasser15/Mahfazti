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

  Widget buildApp({required Brightness brightness, bool isAr = true}) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HideBalanceService()),
      ],
      child: MaterialApp(
        theme: ThemeData(
          brightness: brightness,
          scaffoldBackgroundColor: brightness == Brightness.dark ? const Color(0xFF121214) : Colors.white,
        ),
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

  testWidgets('Financial Insights Grid renders all 6 redesigned cards in Arabic (Dark Mode)', (tester) async {
    tester.view.physicalSize = const Size(1200, 3600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(buildApp(brightness: Brightness.dark, isAr: true));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump();

            // Verify Section Title and Analytics link
    expect(find.text('الرؤى المالية'), findsOneWidget);
    expect(find.text('التحليلات'), findsOneWidget);

    // Verify all 6 cards exist by their headers
    expect(find.text('أعلى صرف'), findsOneWidget);
    expect(find.text('الاشتراكات'), findsOneWidget);
    expect(find.text('الميزانية'), findsOneWidget);
    expect(find.text('حركة الأموال'), findsOneWidget);
    expect(find.text('توزيع الدخل'), findsOneWidget);
    expect(find.text('الحسابات'), findsOneWidget);

    // Verify IN and OUT labels in Money Flow and Income breakdown
    expect(find.text('IN'), findsNWidgets(2));
    expect(find.text('OUT'), findsNWidgets(2));
  });

  testWidgets('Financial Insights Grid renders all 6 redesigned cards in English (Light Mode)', (tester) async {
    tester.view.physicalSize = const Size(1200, 3600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(buildApp(brightness: Brightness.light, isAr: false));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump();

            // Verify Section Title and Analytics link
    expect(find.text('Insights'), findsOneWidget);
    expect(find.text('Analytics'), findsOneWidget);

    // Verify all 6 cards exist in English
    expect(find.text('Top Spending'), findsOneWidget);
    expect(find.text('Subscriptions'), findsOneWidget);
    expect(find.text('Budget'), findsOneWidget);
    expect(find.text('Money Flow'), findsOneWidget);
    expect(find.text('Income breakdown'), findsOneWidget);
    expect(find.text('Accounts'), findsOneWidget);
  });
}
