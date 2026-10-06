import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_wallet/core/services/api_service.dart';
import 'package:my_wallet/core/services/hide_balance_service.dart';
import 'package:my_wallet/core/utils/shared_prefs.dart';
import 'package:my_wallet/features/wallet/presentation/screens/home_screen.dart';
import 'package:my_wallet/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget createTestApp() {
  return MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: ChangeNotifierProvider<HideBalanceService>(
      create: (_) => HideBalanceService(),
      child: const Scaffold(body: HomeScreen()),
    ),
  );
}

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
        handler.resolve(Response(
          requestOptions: options,
          data: options.path.contains('Category') ? <dynamic>[] : <String, dynamic>{},
          statusCode: 200,
        ));
      },
    ));
    ApiService().dioForTesting = mockDio;
  });

  testWidgets('renders HomeScreen without errors', (tester) async {
    await tester.pumpWidget(createTestApp());
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
    await tester.pump();

    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('renders page view with tabs', (tester) async {
    await tester.pumpWidget(createTestApp());
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
    await tester.pump();

    expect(find.byType(PageView), findsOneWidget);
  });

  testWidgets('Android NavigationBar places wallet on right in RTL', (tester) async {
    await tester.pumpWidget(MaterialApp(
      locale: const Locale('ar'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: ChangeNotifierProvider<HideBalanceService>(
        create: (_) => HideBalanceService(),
        child: const Scaffold(body: HomeScreen()),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
    await tester.pump();

    final walletPos = tester.getCenter(find.text('المحفظة'));
    final subsPos = tester.getCenter(find.text('الاشتراكات'));
    // In RTL, Wallet (index 0) is on the right, Subscriptions (index 3) is on the left
    expect(walletPos.dx, greaterThan(subsPos.dx));
  });
}
