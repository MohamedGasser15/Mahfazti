import 'package:flutter/material.dart';
import 'package:my_wallet/core/constants/app_constants.dart';
import 'package:my_wallet/core/utils/shared_prefs.dart';

class ThemeService {
  // Theme options
  static const String light = 'light';
  static const String dark = 'dark';
  static const String system = 'system';

  static ValueNotifier<ThemeMode> themeNotifier = ValueNotifier<ThemeMode>(ThemeMode.system);

  static Future<void> init() async {
    final savedTheme = await getSavedTheme();
    themeNotifier.value = _stringToThemeMode(savedTheme);
  }

  static ThemeMode _stringToThemeMode(String theme) {
    switch (theme) {
      case light:
        return ThemeMode.light;
      case dark:
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  static String _themeModeToString(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return light;
      case ThemeMode.dark:
        return dark;
      default:
        return system;
    }
  }

  static Future<void> saveTheme(String theme) async {
    await SharedPrefs.setString(AppConstants.selectedThemeKey, theme);
    themeNotifier.value = _stringToThemeMode(theme);
  }

  static Future<void> saveThemeMode(ThemeMode themeMode) async {
    final theme = _themeModeToString(themeMode);
    await saveTheme(theme);
  }

  static Future<String> getSavedTheme() async {
    return SharedPrefs.getStringValue(AppConstants.selectedThemeKey) ?? system;
  }

  static Future<ThemeMode> getCurrentThemeMode() async {
    final savedTheme = await getSavedTheme();
    return _stringToThemeMode(savedTheme);
  }
}