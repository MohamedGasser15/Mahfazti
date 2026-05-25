import 'package:flutter_test/flutter_test.dart';
import 'package:my_wallet/core/constants/app_constants.dart';

void main() {
  group('AppConstants', () {
    test('appName has expected value', () {
      expect(AppConstants.appName, 'محفظتي');
    });

    test('appVersion has expected value', () {
      expect(AppConstants.appVersion, '1.0.0');
    });

    test('baseUrl has expected value', () {
      expect(AppConstants.baseUrl, 'https://mahfazati.runasp.net/');
    });

    test('baseUrl is a valid URL', () {
      expect(Uri.tryParse(AppConstants.baseUrl), isNotNull);
    });

    test('isFirstTimeKey is non-empty', () {
      expect(AppConstants.isFirstTimeKey.isNotEmpty, isTrue);
    });

    test('authTokenKey is non-empty', () {
      expect(AppConstants.authTokenKey.isNotEmpty, isTrue);
    });

    test('userDataKey is non-empty', () {
      expect(AppConstants.userDataKey.isNotEmpty, isTrue);
    });

    test('appLanguageKey is non-empty', () {
      expect(AppConstants.appLanguageKey.isNotEmpty, isTrue);
    });

    test('hideBalancesKey is non-empty', () {
      expect(AppConstants.hideBalancesKey.isNotEmpty, isTrue);
    });

    test('arabic has expected value', () {
      expect(AppConstants.arabic, 'ar');
    });

    test('english has expected value', () {
      expect(AppConstants.english, 'en');
    });
  });
}
