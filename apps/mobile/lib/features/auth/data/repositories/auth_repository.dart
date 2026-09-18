import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:my_wallet/core/constants/api_constants.dart';
import 'package:my_wallet/core/constants/app_constants.dart';
import 'package:my_wallet/core/services/api_service.dart';
import 'package:my_wallet/core/services/wallet_cache_service.dart';
import 'package:my_wallet/core/utils/shared_prefs.dart';

class AuthRepository {
  final ApiService _apiService = ApiService();

  /// Login with email and password
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.login,
        {
          'email': email,
          'password': password,
        },
      );

      final data = _apiService.handleResponse(response);

      if (data['success'] == true && data['data'] != null) {
        final payload = data['data'] as Map<String, dynamic>;
        final token = payload['token'] as String?;
        final refreshToken = payload['refreshToken'] as String?;
        final user = payload['user'] as Map<String, dynamic>?;

        if (token != null && token.isNotEmpty) {
          await SharedPrefs.setAuthToken(token);
        }
        if (refreshToken != null && refreshToken.isNotEmpty) {
          await SharedPrefs.setRefreshToken(refreshToken);
        }
        if (user != null) {
          await SharedPrefs.setUserData(jsonEncode(user));
          if (user['currency'] != null && (user['currency'] as String).isNotEmpty) {
            await SharedPrefs.setCurrency(user['currency']);
          }
        }
        await SharedPrefs.setString(AppConstants.userEmailKey, email);
        await SharedPrefs.setSecureString(AppConstants.userEmailKey, email);
      } else if (data['success'] == false) {
        throw Exception(data['message'] ?? 'Login failed');
      }

      return data;
    } on DioException catch (e) {
      final message = _extractDioErrorMessage(e);
      throw Exception(message);
    }
  }

  /// Send email verification code for registration
  Future<Map<String, dynamic>> sendCode({required String email}) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.sendCode,
        {'email': email},
      );
      final data = _apiService.handleResponse(response);
      if (data['success'] == false) {
        throw Exception(data['message'] ?? 'Failed to send verification code');
      }
      return data;
    } on DioException catch (e) {
      final message = _extractDioErrorMessage(e);
      throw Exception(message);
    }
  }

  /// Verify email verification code for registration
  Future<Map<String, dynamic>> verifyEmail({
    required String email,
    required String code,
  }) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.verifyEmail,
        {
          'email': email,
          'code': code,
        },
      );
      final data = _apiService.handleResponse(response);
      if (data['success'] == false) {
        throw Exception(data['message'] ?? 'Invalid verification code');
      }
      return data;
    } on DioException catch (e) {
      final message = _extractDioErrorMessage(e);
      throw Exception(message);
    }
  }

  /// Complete user registration
  Future<Map<String, dynamic>> register({
    required String fullName,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.register,
        {
          'fullName': fullName,
          'email': email,
          'password': password,
          'confirmPassword': confirmPassword,
        },
      );
      final data = _apiService.handleResponse(response);
      if (data['success'] == false) {
        throw Exception(data['message'] ?? 'Registration failed');
      }
      return data;
    } on DioException catch (e) {
      final message = _extractDioErrorMessage(e);
      throw Exception(message);
    }
  }

  /// Request forgot password code
  Future<Map<String, dynamic>> forgotPassword({required String email}) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.forgotPassword,
        {'email': email},
      );
      final data = _apiService.handleResponse(response);
      if (data['success'] == false) {
        throw Exception(data['message'] ?? 'Failed to process forgot password');
      }
      return data;
    } on DioException catch (e) {
      final message = _extractDioErrorMessage(e);
      throw Exception(message);
    }
  }

  /// Verify reset code
  Future<Map<String, dynamic>> verifyResetCode({
    required String email,
    required String code,
  }) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.verifyResetCode,
        {
          'email': email,
          'code': code,
        },
      );
      final data = _apiService.handleResponse(response);
      if (data['success'] == false) {
        throw Exception(data['message'] ?? 'Invalid reset code');
      }
      return data;
    } on DioException catch (e) {
      final message = _extractDioErrorMessage(e);
      throw Exception(message);
    }
  }

  /// Reset password with new password
  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.resetPassword,
        {
          'email': email,
          'newPassword': newPassword,
          'confirmPassword': confirmPassword,
        },
      );
      final data = _apiService.handleResponse(response);
      if (data['success'] == false) {
        throw Exception(data['message'] ?? 'Failed to reset password');
      }
      return data;
    } on DioException catch (e) {
      final message = _extractDioErrorMessage(e);
      throw Exception(message);
    }
  }

  /// Refresh tokens
  Future<bool> refreshToken() async {
    final token = SharedPrefs.authToken;
    final refreshToken = SharedPrefs.refreshToken;
    if (token == null || refreshToken == null) return false;

    try {
      final response = await _apiService.post(
        ApiEndpoints.refresh,
        {
          'accessToken': token,
          'refreshToken': refreshToken,
        },
      );
      final data = _apiService.handleResponse(response);
      if (data['success'] == true && data['data'] != null) {
        final payload = data['data'] as Map<String, dynamic>;
        final newAccessToken = payload['accessToken'] as String?;
        final newRefreshToken = payload['refreshToken'] as String?;
        if (newAccessToken != null) await SharedPrefs.setAuthToken(newAccessToken);
        if (newRefreshToken != null) await SharedPrefs.setRefreshToken(newRefreshToken);
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Check if email exists
  Future<bool> checkEmail(String email) async {
    try {
      final response = await _apiService.get(
        ApiEndpoints.checkEmail,
        queryParams: {'email': email},
      );

      final data = _apiService.handleResponse(response);
      return data['exists'] ?? (data['data']?['exists'] ?? false);
    } catch (_) {
      return false;
    }
  }

  /// Set user currency
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
    await SharedPrefs.setCurrency(currency);
  }

  /// Social login (Google / Facebook)
  Future<Map<String, dynamic>> socialLogin({
    required String provider,
    required Map<String, String?> tokenData,
  }) async {
    try {
      final endpoint = provider.toLowerCase() == 'facebook'
          ? ApiEndpoints.facebookLogin
          : ApiEndpoints.googleLogin;

      final response = await _apiService.post(
        endpoint,
        tokenData,
      );

      final data = _apiService.handleResponse(response);

      if (data['success'] == true && data['data'] != null) {
        final payload = data['data'] as Map<String, dynamic>;
        final token = payload['token'] as String?;
        final refreshToken = payload['refreshToken'] as String?;
        final user = payload['user'] as Map<String, dynamic>?;

        if (token != null && token.isNotEmpty) {
          await SharedPrefs.setAuthToken(token);
        }
        if (refreshToken != null && refreshToken.isNotEmpty) {
          await SharedPrefs.setRefreshToken(refreshToken);
        }
        if (user != null) {
          await SharedPrefs.setUserData(jsonEncode(user));
          if (user['currency'] != null && (user['currency'] as String).isNotEmpty) {
            await SharedPrefs.setCurrency(user['currency']);
          }
          if (user['email'] != null) {
            await SharedPrefs.setString(AppConstants.userEmailKey, user['email']);
            await SharedPrefs.setSecureString(AppConstants.userEmailKey, user['email']);
          }
        }
      }

      return data;
    } on DioException catch (e) {
      final message = _extractDioErrorMessage(e);
      throw Exception(message);
    }
  }

  /// Logout
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
    await SharedPrefs.removeRefreshToken();
    await SharedPrefs.removeUserData();
    await WalletCacheService.invalidateAll();
  }

  String _extractDioErrorMessage(DioException e) {
    if (e.response?.data != null) {
      final data = e.response!.data;
      if (data is Map<String, dynamic>) {
        if (data['message'] != null && (data['message'] as String).isNotEmpty) {
          return data['message'];
        }
        if (data['errors'] != null) {
          if (data['errors'] is List && (data['errors'] as List).isNotEmpty) {
            return (data['errors'] as List).first.toString();
          } else if (data['errors'] is Map) {
            final map = data['errors'] as Map;
            if (map.isNotEmpty) {
              final firstVal = map.values.first;
              if (firstVal is List && firstVal.isNotEmpty) {
                return firstVal.first.toString();
              }
              return firstVal.toString();
            }
          }
        }
      }
    }
    return e.message ?? 'An unexpected error occurred';
  }
}
