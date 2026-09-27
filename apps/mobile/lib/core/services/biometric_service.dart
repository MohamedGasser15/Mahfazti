import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:my_wallet/core/constants/app_constants.dart';
import 'package:my_wallet/core/utils/shared_prefs.dart';

class BiometricService {
  static final LocalAuthentication _auth = LocalAuthentication();

  /// Check if device supports biometrics or device credentials (passcode/PIN)
  static Future<bool> isDeviceLockAvailable() async {
    try {
      final isSupported = await _auth.isDeviceSupported();
      final canCheck = await _auth.canCheckBiometrics;
      return isSupported || canCheck;
    } on PlatformException catch (e) {
      debugPrint('Error checking device lock availability: $e');
      return false;
    }
  }

  /// Check if biometrics hardware specifically is available
  static Future<bool> isBiometricAvailable() async {
    try {
      return await _auth.canCheckBiometrics;
    } on PlatformException catch (e) {
      debugPrint('Error checking biometric hardware: $e');
      return false;
    }
  }

  /// Get list of available enrolled biometrics on device
  static Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      debugPrint('Error getting available biometrics: $e');
      return [];
    }
  }

  /// Check if App Lock is enabled in user settings
  static bool isAppLockEnabled() {
    return SharedPrefs.getBoolValue(AppConstants.biometricEnabledKey) ?? false;
  }

  /// Save App Lock preference
  static Future<void> setAppLockEnabled(bool enabled) async {
    await SharedPrefs.setBool(AppConstants.biometricEnabledKey, enabled);
  }

  /// Authenticate using biometrics or device passcode/PIN fallback
  static Future<bool> authenticate({
    String? localizedReason,
    bool biometricOnly = false,
  }) async {
    try {
      final canAuth = await isDeviceLockAvailable();
      if (!canAuth) return false;

      return await _auth.authenticate(
        localizedReason: localizedReason ?? 'Authenticate to access Mahfazti',
        options: AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: biometricOnly,
          useErrorDialogs: true,
        ),
      );
    } on PlatformException catch (e) {
      debugPrint('Biometric authentication error: $e');
      return false;
    }
  }

  /// Get friendly biometric name based on available hardware
  static Future<String> getBiometricName() async {
    try {
      final biometrics = await getAvailableBiometrics();
      if (biometrics.contains(BiometricType.face)) {
        return 'Face ID';
      } else if (biometrics.contains(BiometricType.fingerprint)) {
        return 'Fingerprint';
      } else if (biometrics.contains(BiometricType.iris)) {
        return 'Iris';
      }
      return 'Device Lock';
    } catch (_) {
      return 'Device Lock';
    }
  }
}