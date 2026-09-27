import 'package:flutter/material.dart';
import 'package:my_wallet/core/services/biometric_service.dart';
import 'package:my_wallet/core/utils/shared_prefs.dart';

class AppLockService extends ChangeNotifier {
  bool _isEnabled = false;
  bool _isLocked = false;
  bool _isAuthenticating = false;
  DateTime? _pausedAt;

  bool get isEnabled => _isEnabled;
  bool get isLocked => _isLocked;
  bool get isAuthenticating => _isAuthenticating;

  AppLockService() {
    _loadState();
  }

  void _loadState() {
    _isEnabled = BiometricService.isAppLockEnabled();
    // If enabled and user is logged in, start in locked state
    if (_isEnabled && SharedPrefs.authToken != null) {
      _isLocked = true;
    }
  }

  /// Toggle App Lock setting with mandatory biometric/passcode verification
  Future<bool> setAppLock(bool enable, {required String localizedReason}) async {
    // Check if device supports lock
    final isAvailable = await BiometricService.isDeviceLockAvailable();
    if (!isAvailable) {
      return false;
    }

    if (_isAuthenticating) return false;
    _isAuthenticating = true;

    try {
      final authenticated = await BiometricService.authenticate(
        localizedReason: localizedReason,
      );

      if (authenticated) {
        _isEnabled = enable;
        await BiometricService.setAppLockEnabled(enable);
        if (!enable) {
          _isLocked = false;
        }
        notifyListeners();
        return true;
      }
      return false;
    } finally {
      _isAuthenticating = false;
    }
  }

  /// Request unlock using biometric or device passcode
  Future<bool> unlock({String? localizedReason}) async {
    if (!_isEnabled || !_isLocked) {
      _isLocked = false;
      notifyListeners();
      return true;
    }

    if (_isAuthenticating) return false;
    _isAuthenticating = true;

    try {
      final success = await BiometricService.authenticate(
        localizedReason: localizedReason,
      );

      if (success) {
        _isLocked = false;
        notifyListeners();
        return true;
      }
      return false;
    } finally {
      _isAuthenticating = false;
    }
  }

  /// Lock app immediately
  void lock() {
    if (_isEnabled && SharedPrefs.authToken != null && !_isLocked) {
      _isLocked = true;
      notifyListeners();
    }
  }

  /// Called when app goes into background
  void onAppPaused() {
    _pausedAt = DateTime.now();
  }

  /// Called when app returns to foreground
  void onAppResumed({String? localizedReason}) {
    if (_isEnabled && SharedPrefs.authToken != null) {
      if (_pausedAt != null) {
        final elapsedSeconds = DateTime.now().difference(_pausedAt!).inSeconds;
        // 2-second grace period for quick notifications or permission prompts
        if (elapsedSeconds >= 2) {
          _isLocked = true;
          notifyListeners();
          unlock(localizedReason: localizedReason);
        }
      }
    }
    _pausedAt = null;
  }
}
