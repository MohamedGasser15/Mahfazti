import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_wallet/core/services/api_service.dart';
import 'package:my_wallet/core/services/hide_balance_service.dart';
import 'package:my_wallet/core/utils/shared_prefs.dart';
import 'package:my_wallet/features/settings/presentation/widgets/settings_content.dart';
import 'package:my_wallet/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget createTestApp({required Function(Locale) onLocaleChanged}) {
  return MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: ChangeNotifierProvider<HideBalanceService>(
      create: (_) => HideBalanceService(),
      child: Scaffold(
        body: SettingsContent(onLocaleChanged: onLocaleChanged),
      ),
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
          data: <String, dynamic>{},
          statusCode: 200,
        ));
      },
    ));
    ApiService().dioForTesting = mockDio;

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/local_auth'),
      (MethodCall methodCall) async {
        if (methodCall.method == 'canCheckBiometrics') return false;
        if (methodCall.method == 'getAvailableBiometrics') return <dynamic>[];
        return null;
      },
    );
  });

  testWidgets('renders SettingsContent without errors', (tester) async {
    await tester.pumpWidget(createTestApp(
      onLocaleChanged: (locale) {},
    ));
    await tester.pumpAndSettle();

    expect(find.byType(SettingsContent), findsOneWidget);
  });

  testWidgets('shows app settings section', (tester) async {
    await tester.pumpWidget(createTestApp(
      onLocaleChanged: (locale) {},
    ));
    await tester.pumpAndSettle();

    expect(find.byType(SingleChildScrollView), findsOneWidget);
  });
}
