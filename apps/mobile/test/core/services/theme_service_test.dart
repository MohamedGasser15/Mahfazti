import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_wallet/core/services/theme_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/services.dart';
import 'package:my_wallet/core/utils/shared_prefs.dart';

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
  });

  group('ThemeService', () {
    test('init() defaults to system', () async {
      await ThemeService.init();
      expect(ThemeService.themeNotifier.value, ThemeMode.system);
    });

    test('init() loads saved light theme', () async {
      SharedPreferences.setMockInitialValues({'selected_theme': 'light'});
      await SharedPrefs.init();
      await ThemeService.init();
      expect(ThemeService.themeNotifier.value, ThemeMode.light);
    });

    test('init() loads saved dark theme', () async {
      SharedPreferences.setMockInitialValues({'selected_theme': 'dark'});
      await SharedPrefs.init();
      await ThemeService.init();
      expect(ThemeService.themeNotifier.value, ThemeMode.dark);
    });

    test('saveTheme(light) updates theme to light', () async {
      await ThemeService.saveTheme('light');
      expect(ThemeService.themeNotifier.value, ThemeMode.light);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('selected_theme'), 'light');
    });

    test('saveTheme(dark) updates theme to dark', () async {
      await ThemeService.saveTheme('dark');
      expect(ThemeService.themeNotifier.value, ThemeMode.dark);
    });

    test('saveTheme(system) updates theme to system', () async {
      await ThemeService.saveTheme('system');
      expect(ThemeService.themeNotifier.value, ThemeMode.system);
    });

    test('saveThemeMode(ThemeMode.dark) works', () async {
      await ThemeService.saveThemeMode(ThemeMode.dark);
      expect(ThemeService.themeNotifier.value, ThemeMode.dark);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('selected_theme'), 'dark');
    });

    test('saveThemeMode(ThemeMode.light) works', () async {
      await ThemeService.saveThemeMode(ThemeMode.light);
      expect(ThemeService.themeNotifier.value, ThemeMode.light);
    });

    test('saveThemeMode(ThemeMode.system) works', () async {
      await ThemeService.saveThemeMode(ThemeMode.system);
      expect(ThemeService.themeNotifier.value, ThemeMode.system);
    });

    test('getSavedTheme() returns saved value', () async {
      SharedPreferences.setMockInitialValues({'selected_theme': 'dark'});
      await SharedPrefs.init();
      final theme = await ThemeService.getSavedTheme();
      expect(theme, 'dark');
    });

    test('getSavedTheme() returns system when no saved value', () async {
      final theme = await ThemeService.getSavedTheme();
      expect(theme, 'system');
    });

    test('getCurrentThemeMode() returns saved theme mode', () async {
      SharedPreferences.setMockInitialValues({'selected_theme': 'dark'});
      await SharedPrefs.init();
      final mode = await ThemeService.getCurrentThemeMode();
      expect(mode, ThemeMode.dark);
    });

    test('getCurrentThemeMode() returns system when nothing saved', () async {
      final mode = await ThemeService.getCurrentThemeMode();
      expect(mode, ThemeMode.system);
    });
  });
}
