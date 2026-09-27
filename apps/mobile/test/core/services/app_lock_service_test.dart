import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_wallet/core/constants/app_constants.dart';
import 'package:my_wallet/core/services/app_lock_service.dart';
import 'package:my_wallet/core/utils/shared_prefs.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppLockService', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
        (MethodCall methodCall) async => null,
      );

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/local_auth'),
        (MethodCall methodCall) async {
          if (methodCall.method == 'isDeviceSupported') return true;
          if (methodCall.method == 'canCheckBiometrics') return true;
          if (methodCall.method == 'authenticate') return true;
          return null;
        },
      );

      await SharedPrefs.init();
    });

    test('initial state is false when no preference is saved', () {
      final service = AppLockService();
      expect(service.isEnabled, isFalse);
      expect(service.isLocked, isFalse);
    });

    test('initial state is enabled when preference is saved', () async {
      SharedPreferences.setMockInitialValues({
        AppConstants.biometricEnabledKey: true,
      });
      await SharedPrefs.init();

      final service = AppLockService();
      expect(service.isEnabled, isTrue);
    });

    test('setAppLock(true) enables app lock when authenticated', () async {
      final service = AppLockService();
      final success = await service.setAppLock(true, localizedReason: 'Test');
      expect(success, isTrue);
      expect(service.isEnabled, isTrue);
    });

    test('setAppLock(false) disables app lock and unlocks', () async {
      SharedPreferences.setMockInitialValues({
        AppConstants.biometricEnabledKey: true,
      });
      await SharedPrefs.init();

      final service = AppLockService();
      final success = await service.setAppLock(false, localizedReason: 'Test');
      expect(success, isTrue);
      expect(service.isEnabled, isFalse);
      expect(service.isLocked, isFalse);
    });

    test('lock() sets isLocked to true when enabled and token present', () async {
      SharedPreferences.setMockInitialValues({
        AppConstants.biometricEnabledKey: true,
      });
      await SharedPrefs.init();
      await SharedPrefs.setAuthToken('mock_token');

      final service = AppLockService();
      service.lock();
      expect(service.isLocked, isTrue);
    });

    test('unlock() sets isLocked to false on successful authentication', () async {
      SharedPreferences.setMockInitialValues({
        AppConstants.biometricEnabledKey: true,
      });
      await SharedPrefs.init();
      await SharedPrefs.setAuthToken('mock_token');

      final service = AppLockService();
      service.lock();
      expect(service.isLocked, isTrue);

      final unlocked = await service.unlock(localizedReason: 'Test');
      expect(unlocked, isTrue);
      expect(service.isLocked, isFalse);
    });
  });
}
