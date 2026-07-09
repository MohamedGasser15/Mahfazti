import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_wallet/core/services/hide_balance_service.dart';
import 'package:my_wallet/core/utils/shared_prefs.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('HideBalanceService', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
        (MethodCall methodCall) async => null,
      );
      await SharedPrefs.init();
    });

    test('initial state is false', () {
      final service = HideBalanceService();
      expect(service.isHidden, isFalse);
    });

    test('toggle() changes value from false to true', () async {
      final service = HideBalanceService();
      await service.toggle();
      expect(service.isHidden, isTrue);
    });

    test('toggle() changes value from true to false', () async {
      SharedPreferences.setMockInitialValues({'hideBalances': true});
      await SharedPrefs.init();
      final service = HideBalanceService();
      await service.toggle();
      expect(service.isHidden, isFalse);
    });

    test('toggle() persists value to SharedPreferences', () async {
      final service = HideBalanceService();
      await service.toggle();
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('hideBalances'), isTrue);
    });

    test('toggle() notifies listeners', () async {
      final service = HideBalanceService();
      int notificationCount = 0;
      service.addListener(() {
        notificationCount++;
      });
      await service.toggle();
      expect(notificationCount, greaterThan(0));
    });

    test('setHidden(true) sets isHidden to true', () async {
      final service = HideBalanceService();
      await service.setHidden(true);
      expect(service.isHidden, isTrue);
    });

    test('setHidden(true) persists and notifies', () async {
      final service = HideBalanceService();
      int notificationCount = 0;
      service.addListener(() {
        notificationCount++;
      });
      await service.setHidden(true);
      expect(service.isHidden, isTrue);
      expect(notificationCount, greaterThan(0));
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('hideBalances'), isTrue);
    });

    test('setHidden(false) sets isHidden to false', () async {
      SharedPreferences.setMockInitialValues({'hideBalances': true});
      await SharedPrefs.init();
      final service = HideBalanceService();
      await service.setHidden(false);
      expect(service.isHidden, isFalse);
    });

    test('setHidden with same value does not notify', () async {
      final service = HideBalanceService();
      int notificationCount = 0;
      service.addListener(() {
        notificationCount++;
      });
      await service.setHidden(false);
      expect(notificationCount, 0);
    });
  });
}
