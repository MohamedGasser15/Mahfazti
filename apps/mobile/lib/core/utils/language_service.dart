import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:my_wallet/core/constants/app_constants.dart';
import 'package:my_wallet/core/utils/shared_prefs.dart';

class LanguageService {
  static const Locale arabic = Locale('ar', 'SA');
  static const Locale english = Locale('en', 'US');

  // ValueNotifier for tracking app language changes
  static final ValueNotifier<Locale> localeNotifier = ValueNotifier<Locale>(english);

  static Future<void> init() async {
    final savedLocale = await getSavedLocale();
    localeNotifier.value = savedLocale;
  }

  static Future<Locale> getDeviceLocale() async {
    final platformLocale = PlatformDispatcher.instance.locale;
    if (platformLocale.languageCode.startsWith('ar')) {
      return arabic;
    }
    return english;
  }

  static Future<Locale> getSavedLocale() async {
    try {
      final savedLanguage = SharedPrefs.appLanguage;

      if (savedLanguage == AppConstants.arabic) return arabic;
      if (savedLanguage == AppConstants.english) return english;

      return await getDeviceLocale();
    } catch (_) {
      return english;
    }
  }

  static Future<void> saveLocale(Locale locale) async {
    try {
      await SharedPrefs.setAppLanguage(locale.languageCode);
      localeNotifier.value = locale;
    } catch (e) {
      debugPrint('Error saving locale: $e');
    }
  }

  static Future<void> switchToArabic() async {
    await saveLocale(arabic);
  }

  static Future<void> switchToEnglish() async {
    await saveLocale(english);
  }

  static bool isArabic(Locale locale) {
    return locale.languageCode == 'ar';
  }

  static bool isEnglish(Locale locale) {
    return locale.languageCode == 'en';
  }
}