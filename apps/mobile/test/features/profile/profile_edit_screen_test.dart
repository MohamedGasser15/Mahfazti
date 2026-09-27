import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_wallet/core/services/api_service.dart';
import 'package:my_wallet/core/utils/shared_prefs.dart';
import 'package:my_wallet/features/profile/presentation/screens/profile_edit_screen.dart';
import 'package:my_wallet/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget createTestProfileEditApp() {
  return const MaterialApp(
    localizationsDelegates: [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: ProfileEditScreen(),
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
          data: <String, dynamic>{
            'fullName': 'Mohamed Gasser',
            'userName': 'mgasser',
            'email': 'mgasser@example.com',
            'phoneNumber': '+201000000000',
          },
          statusCode: 200,
        ));
      },
    ));
    ApiService().dioForTesting = mockDio;
  });

  testWidgets('renders ProfileEditScreen and shows user data', (WidgetTester tester) async {
    await tester.pumpWidget(createTestProfileEditApp());
    await tester.pumpAndSettle();

    expect(find.byType(ProfileEditScreen), findsOneWidget);
    expect(find.text('Mohamed Gasser'), findsWidgets);
    expect(find.text('@mgasser'), findsNothing);
    expect(find.byIcon(Icons.camera_alt_rounded), findsNothing);
    expect(find.text('mgasser@example.com'), findsOneWidget);
  });

  testWidgets('save button enables only when changes are made', (WidgetTester tester) async {
    await tester.pumpWidget(createTestProfileEditApp());
    await tester.pumpAndSettle();

    // Find the save ElevatedButton
    final saveButtonFinder = find.byType(ElevatedButton);
    expect(saveButtonFinder, findsOneWidget);

    ElevatedButton saveButton = tester.widget(saveButtonFinder);
    // Initially disabled because no changes have been made
    expect(saveButton.onPressed, isNull);

    // Edit full name
    await tester.enterText(find.widgetWithText(TextFormField, 'Mohamed Gasser'), 'Mohamed Gasser Updated');
    await tester.pumpAndSettle();

    // Now it should be enabled
    saveButton = tester.widget(saveButtonFinder);
    expect(saveButton.onPressed, isNotNull);

    // Revert back
    await tester.enterText(find.widgetWithText(TextFormField, 'Mohamed Gasser Updated'), 'Mohamed Gasser');
    await tester.pumpAndSettle();

    // Now disabled again
    saveButton = tester.widget(saveButtonFinder);
    expect(saveButton.onPressed, isNull);
  });
}
