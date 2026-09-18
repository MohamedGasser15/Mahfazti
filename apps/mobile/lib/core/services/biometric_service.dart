import 'package:local_auth/local_auth.dart';
import 'package:my_wallet/core/constants/app_constants.dart';
import 'package:my_wallet/core/utils/shared_prefs.dart';

class BiometricService {
  // Biometrics are temporarily disabled
  static Future<bool> isBiometricAvailable() async => false;

  static Future<bool> authenticateWithFallback({
    int maxAttempts = 3,
    Function()? onFallback,
  }) async {
    if (onFallback != null) {
      onFallback();
    }
    return false;
  }

  // Get available biometric types
  static Future<List<BiometricType>> getAvailableBiometrics() async => [];

  // Check if biometrics is enabled by user
  static Future<bool> isBiometricEnabled() async => false;

  // Authenticate with biometrics
  static Future<bool> authenticate() async => false;

  // Direct authentication (to enable biometric)
  static Future<bool> authenticateDirectly() async => false;

  static Future<bool> enableBiometric() async => false;

  // Disable biometrics
  static Future<void> disableBiometric() async {
    await SharedPrefs.removeSecureKey(AppConstants.biometricEnabledKey);
  }

  // Get biometric display name based on hardware
  static Future<String> getBiometricName() async => 'Biometric';

  // Check if device supports biometrics
  static Future<bool> hasBiometricSupport() async => false;
}