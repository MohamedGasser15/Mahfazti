import 'dart:convert';
import 'package:my_wallet/core/constants/api_constants.dart';
import 'package:my_wallet/core/constants/app_constants.dart';
import 'package:my_wallet/core/services/api_service.dart';
import 'package:my_wallet/core/services/wallet_cache_service.dart';
import 'package:my_wallet/core/utils/shared_prefs.dart';

class AuthRepository {
  final ApiService _apiService = ApiService();

  Future<Map<String, dynamic>> sendVerification({
    required String email,
    required bool isLogin,
    String? deviceName,
    String? ipAddress,
  }) async {
    final response = await _apiService.post(
      ApiEndpoints.sendVerification,
      {
        'email': email,
        'isLogin': isLogin,
        'deviceName': deviceName,
        'ipAddress': ipAddress,
      },
    );
    final data = _apiService.handleResponse(response);
    await SharedPrefs.setSecureString(AppConstants.tempEmailKey, email);
    await SharedPrefs.setSecureString(AppConstants.tempIsLoginKey, isLogin.toString());
    return data;
  }

  Future<Map<String, dynamic>> verifyCode({
    required String email,
    required String verificationCode,
  }) async {
    final response = await _apiService.post(
      ApiEndpoints.verifyCode,
      {
        'email': email,
        'verificationCode': verificationCode,
      },
    );

    final data = _apiService.handleResponse(response);

    if (data['success'] == true) {
      await SharedPrefs.setSecureString(AppConstants.verifiedEmailKey, email);
      await SharedPrefs.setSecureString(AppConstants.verifiedCodeKey, verificationCode);
      await SharedPrefs.setSecureString(AppConstants.isCodeVerifiedKey, 'true');
    }

    return data;
  }

  Future<Map<String, dynamic>> recoveryCheckUser(String emailOrUsername) async {
    final response = await _apiService.post(
      ApiEndpoints.recoveryCheckUser,
      {'emailOrUsername': emailOrUsername},
    );
    return _apiService.handleResponse(response);
  }

  Future<Map<String, dynamic>> recoveryVerifyPassword({
    required String emailOrUsername,
    required String password,
  }) async {
    final response = await _apiService.post(
      ApiEndpoints.recoveryVerifyPassword,
      {
        'emailOrUsername': emailOrUsername,
        'password': password,
      },
    );
    return _apiService.handleResponse(response);
  }

  Future<Map<String, dynamic>> recoveryRequestEmailChange({
    required String emailOrUsername,
    required String newEmail,
  }) async {
    final response = await _apiService.post(
      ApiEndpoints.recoveryRequestEmailChange,
      {
        'emailOrUsername': emailOrUsername,
        'newEmail': newEmail,
      },
    );
    return _apiService.handleResponse(response);
  }

  Future<Map<String, dynamic>> forgotPasscode({required String email}) async {
    final response = await _apiService.post(
      ApiEndpoints.forgotPasscode,
      {'email': email},
    );
    return _apiService.handleResponse(response);
  }

  Future<Map<String, dynamic>> resetPasscode({
    required String email,
    required String otpCode,
    required String newPasscode,
  }) async {
    final response = await _apiService.post(
      ApiEndpoints.resetPasscode,
      {
        'email': email,
        'otpCode': otpCode,
        'newPasscode': newPasscode,
      },
    );
    return _apiService.handleResponse(response);
  }

  Future<Map<String, dynamic>> recoveryConfirmEmailChange({
    required String emailOrUsername,
    required String newEmail,
    required String otpCode,
  }) async {
    final response = await _apiService.post(
      ApiEndpoints.recoveryConfirmEmailChange,
      {
        'emailOrUsername': emailOrUsername,
        'newEmail': newEmail,
        'otpCode': otpCode,
      },
    );
    final data = _apiService.handleResponse(response);
    if (data['success'] == true && data['token'] != null) {
      await SharedPrefs.setAuthToken(data['token']);
      if (data['user'] != null) {
        await SharedPrefs.setUserData(jsonEncode(data['user']));
      }
    }
    return data;
  }

  Future<Map<String, dynamic>> resendCode({
    required String email,
    required bool isLogin,
    String? deviceName,
    String? ipAddress,
  }) async {
    final response = await _apiService.post(
      ApiEndpoints.resendCode,
      {
        'email': email,
        'isLogin': isLogin,
        'deviceName': deviceName,
        'ipAddress': ipAddress,
      },
    );
    return _apiService.handleResponse(response);
  }

  Future<Map<String, dynamic>> completeRegistration({
    required String email,
    required String verificationCode,
    required String password,
    required String fullName,
    required String userName,
    required String phoneNumber,
  }) async {
    final isVerified = (await SharedPrefs.getSecureString(AppConstants.isCodeVerifiedKey)) == 'true' ||
        (SharedPrefs.getBoolValue(AppConstants.isCodeVerifiedKey) ?? false);
    if (!isVerified) {
      throw Exception('Please verify your code first');
    }

    final response = await _apiService.post(
      ApiEndpoints.verifyAndComplete,
      {
        'email': email,
        'verificationCode': verificationCode,
        'password': password,
        'fullName': fullName,
        'userName': userName,
        'phoneNumber': phoneNumber,
      },
    );

    final data = _apiService.handleResponse(response);

    if (data['success'] == true && data['token'] != null) {
      await SharedPrefs.setAuthToken(data['token']);
      await SharedPrefs.setSecureString(AppConstants.userEmailKey, email);
      await SharedPrefs.setString(AppConstants.userEmailKey, email);
      await SharedPrefs.setUserData(jsonEncode({
        'email': email,
        'fullName': fullName,
        'userName': userName,
        'phoneNumber': phoneNumber,
      }));
      await _cleanTempData();
    }

    return data;
  }

  Future<Map<String, dynamic>> completeLogin({
    required String email,
    required String verificationCode,
    required String password,
  }) async {
    final isVerified = await SharedPrefs.getSecureString(AppConstants.isCodeVerifiedKey);
    if (isVerified != 'true') {
      throw Exception('Please verify your code first');
    }

    final response = await _apiService.post(
      ApiEndpoints.verifyAndComplete,
      {
        'email': email,
        'verificationCode': verificationCode,
        'password': password,
        'fullName': '',
        'userName': '',
        'phoneNumber': '',
      },
    );

    final data = _apiService.handleResponse(response);

    if (data['success'] == true && data['token'] != null) {
      await SharedPrefs.setAuthToken(data['token']);
      await SharedPrefs.setSecureString(AppConstants.userEmailKey, email);
      await SharedPrefs.setString(AppConstants.userEmailKey, email);
      await SharedPrefs.setUserData(jsonEncode({
        'email': email,
      }));
      await _cleanTempData();
    }

    return data;
  }

  Future<bool> checkEmail(String email) async {
    final response = await _apiService.get(
      ApiEndpoints.checkEmail,
      queryParams: {'email': email},
    );

    final data = _apiService.handleResponse(response);
    return data['exists'] ?? false;
  }

  Future<void> _cleanTempData() async {
    await SharedPrefs.removeSecureKey(AppConstants.tempEmailKey);
    await SharedPrefs.removeSecureKey(AppConstants.tempIsLoginKey);
    await SharedPrefs.removeSecureKey(AppConstants.verifiedEmailKey);
    await SharedPrefs.removeSecureKey(AppConstants.verifiedCodeKey);
    await SharedPrefs.removeSecureKey(AppConstants.isCodeVerifiedKey);
    await SharedPrefs.removeKey(AppConstants.isCodeVerifiedKey);
  }

  Future<Map<String, dynamic>> createPasscode(String passcode) async {
    final response = await _apiService.post(
      ApiEndpoints.createPasscode,
      {
        'passcode': passcode,
        'confirmPasscode': passcode,
      },
      requiresAuth: true,
    );
    final data = _apiService.handleResponse(response);
    if (data['success'] == true) {
      await SharedPrefs.setString(AppConstants.userPasswordKey, passcode);
      await SharedPrefs.setSecureString(AppConstants.userPasswordKey, passcode);
    }
    return data;
  }

  Future<void> setUserCurrency(String currency) async {
    final response = await _apiService.post(
      ApiEndpoints.setCurrency,
      {'currency': currency},
      requiresAuth: true,
    );
    final data = _apiService.handleResponse(response);
    if (data['success'] != true) {
      throw Exception(data['message'] ?? 'Failed to set currency');
    }
  }

  Future<Map<String, dynamic>> socialLogin({
    required String provider,
    required Map<String, String?> tokenData,
  }) async {
    final response = await _apiService.post(
      _getSocialEndpoint(provider),
      tokenData,
    );

    final data = _apiService.handleResponse(response);

    if (data['success'] == true && data['token'] != null) {
      await SharedPrefs.setAuthToken(data['token']);
      if (data['user'] != null) {
        await SharedPrefs.setUserData(jsonEncode(data['user']));
      }
    }

    return data;
  }

  String _getSocialEndpoint(String provider) {
    switch (provider.toLowerCase()) {
      case 'google':
        return ApiEndpoints.googleLogin;
      case 'facebook':
        return ApiEndpoints.facebookLogin;
      default:
        throw Exception('Unknown provider: $provider');
    }
  }

  Future<void> logout() async {
    try {
      await _apiService.post(
        ApiEndpoints.logout,
        {},
        requiresAuth: true,
      );
    } catch (_) {
      // Proceed with local logout even if remote call fails
    }

    await SharedPrefs.removeAuthToken();
    await SharedPrefs.removeUserData();
    await _cleanTempData();
    await WalletCacheService.invalidateAll();
  }
}
