import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_wallet/core/utils/language_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({'selected_language': 'ar'});
  });

  group('LanguageService', () {
    test('init() loads saved locale from SharedPreferences', () async {
      await LanguageService.init();
      expect(LanguageService.localeNotifier.value, const Locale('ar', 'SA'));
    });

    group('getDeviceLocale', () {
      test('returns English when platform locale is not Arabic', () async {
        final locale = await LanguageService.getDeviceLocale();
        expect(locale, const Locale('en', 'US'));
      });
    });

    group('getSavedLocale', () {
      test('returns saved locale from SharedPreferences', () async {
        final locale = await LanguageService.getSavedLocale();
        expect(locale, const Locale('ar', 'SA'));
      });

      test('returns device locale when no saved locale', () async {
        SharedPreferences.setMockInitialValues({});
        final locale = await LanguageService.getSavedLocale();
        expect(locale, const Locale('en', 'US'));
      });
    });

    group('switchToArabic', () {
      test('switches locale to arabic and updates notifier', () async {
        SharedPreferences.setMockInitialValues({'selected_language': 'en'});
        await LanguageService.init();
        await LanguageService.switchToArabic();
        expect(
          LanguageService.localeNotifier.value,
          const Locale('ar', 'SA'),
        );
        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getString('selected_language'), 'ar');
      });
    });

    group('switchToEnglish', () {
      test('switches locale to english and updates notifier', () async {
        await LanguageService.init();
        await LanguageService.switchToEnglish();
        expect(
          LanguageService.localeNotifier.value,
          const Locale('en', 'US'),
        );
        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getString('selected_language'), 'en');
      });
    });

    group('isArabic / isEnglish', () {
      test('isArabic returns true for arabic locale', () {
        expect(LanguageService.isArabic(const Locale('ar')), isTrue);
        expect(
          LanguageService.isArabic(const Locale('ar', 'SA')),
          isTrue,
        );
      });

      test('isArabic returns false for english locale', () {
        expect(LanguageService.isArabic(const Locale('en')), isFalse);
      });

      test('isEnglish returns true for english locale', () {
        expect(LanguageService.isEnglish(const Locale('en')), isTrue);
        expect(
          LanguageService.isEnglish(const Locale('en', 'US')),
          isTrue,
        );
      });

      test('isEnglish returns false for arabic locale', () {
        expect(LanguageService.isEnglish(const Locale('ar')), isFalse);
      });
    });

    group('saveLocale', () {
      test('saveLocale updates notifier and persists', () async {
        await LanguageService.saveLocale(const Locale('ar', 'SA'));
        expect(
          LanguageService.localeNotifier.value,
          const Locale('ar', 'SA'),
        );
        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getString('selected_language'), 'ar');
      });
    });
  });
}
