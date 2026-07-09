import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_wallet/core/constants/app_constants.dart';
import 'package:my_wallet/core/utils/shared_prefs.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
      (MethodCall methodCall) async => null,
    );
  });

  group('SharedPrefs', () {
    test('init() initializes SharedPreferences', () async {
      await SharedPrefs.init();
      expect(SharedPrefs.isFirstTime, isTrue);
    });

    group('isFirstTime', () {
      test('defaults to true', () async {
        await SharedPrefs.init();
        expect(SharedPrefs.isFirstTime, isTrue);
      });

      test('setFirstTime(false) then isFirstTime returns false', () async {
        await SharedPrefs.init();
        await SharedPrefs.setFirstTime(false);
        expect(SharedPrefs.isFirstTime, isFalse);
      });
    });

    group('authToken', () {
      setUp(() {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
          (MethodCall methodCall) async {
            if (methodCall.method == 'read' &&
                methodCall.arguments['key'] == AppConstants.authTokenKey) {
              return 'test-token';
            }
            if (methodCall.method == 'write') {
              return null;
            }
            if (methodCall.method == 'delete') {
              return null;
            }
            return null;
          },
        );
      });

      test('defaults to null', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
          (MethodCall methodCall) async => null,
        );
        await SharedPrefs.init();
        expect(SharedPrefs.authToken, isNull);
      });

      test('setAuthToken then authToken returns the token', () async {
        await SharedPrefs.init();
        await SharedPrefs.setAuthToken('test-token');
        expect(SharedPrefs.authToken, 'test-token');
      });
    });

    group('userData', () {
      test('defaults to null', () async {
        await SharedPrefs.init();
        expect(SharedPrefs.userData, isNull);
      });

      test('setUserData then userData returns the data', () async {
        await SharedPrefs.init();
        await SharedPrefs.setUserData('{"name": "test"}');
        expect(SharedPrefs.userData, '{"name": "test"}');
      });
    });

    group('appLanguage', () {
      test('defaults to arabic (ar)', () async {
        await SharedPrefs.init();
        expect(SharedPrefs.appLanguage, 'ar');
      });

      test('setAppLanguage updates language', () async {
        await SharedPrefs.init();
        await SharedPrefs.setAppLanguage('en');
        expect(SharedPrefs.appLanguage, 'en');
      });
    });

    group('setString / getStringValue', () {
      test('setString stores and getStringValue retrieves string', () async {
        await SharedPrefs.init();
        await SharedPrefs.setString('test_key', 'hello');
        expect(SharedPrefs.getStringValue('test_key'), 'hello');
      });

      test('setString with bool stores and getBoolValue retrieves', () async {
        await SharedPrefs.init();
        await SharedPrefs.setString('bool_key', true);
        expect(SharedPrefs.getBoolValue('bool_key'), isTrue);
      });

      test('getStringValue returns null for missing key', () async {
        await SharedPrefs.init();
        expect(SharedPrefs.getStringValue('nonexistent'), isNull);
      });
    });

    group('setBool / getBoolValue', () {
      test('setBool stores and getBoolValue retrieves', () async {
        await SharedPrefs.init();
        await SharedPrefs.setBool('my_bool', true);
        expect(SharedPrefs.getBoolValue('my_bool'), isTrue);
      });

      test('getBoolValue returns null for missing key', () async {
        await SharedPrefs.init();
        expect(SharedPrefs.getBoolValue('nonexistent'), isNull);
      });
    });

    group('removeKey', () {
      test('removeKey removes stored value', () async {
        await SharedPrefs.init();
        await SharedPrefs.setString('temp', 'value');
        expect(SharedPrefs.getStringValue('temp'), 'value');
        await SharedPrefs.removeKey('temp');
        expect(SharedPrefs.getStringValue('temp'), isNull);
      });
    });

    group('currency', () {
      test('getCurrency returns null by default', () async {
        await SharedPrefs.init();
        final currency = await SharedPrefs.getCurrency();
        expect(currency, isNull);
      });

      test('setCurrency then getCurrency returns the value', () async {
        await SharedPrefs.init();
        await SharedPrefs.setCurrency('USD');
        final currency = await SharedPrefs.getCurrency();
        expect(currency, 'USD');
      });
    });
  });
}
