import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:my_wallet/core/constants/api_constants.dart';
import 'package:my_wallet/core/constants/app_constants.dart';
import 'package:my_wallet/core/services/api_service.dart';
import 'package:my_wallet/core/services/push_notification_service.dart';
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
      final response = await _apiService.post(ApiEndpoints.login, {
        'email': email,
        'password': password,
      });

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
          if (user['currency'] != null &&
              (user['currency'] as String).isNotEmpty) {
            await SharedPrefs.setCurrency(user['currency']);
          }
        }
        await SharedPrefs.setString(AppConstants.userEmailKey, email);
        await SharedPrefs.setSecureString(AppConstants.userEmailKey, email);
        await WalletCacheService.invalidateAll();

        final fcmToken = PushNotificationService().fcmToken;
        if (fcmToken != null && fcmToken.isNotEmpty) {
          PushNotificationService().syncTokenWithBackend(fcmToken);
        }
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
  Future<Map<String, dynamic>> sendCode({
    required String email,
    String? language,
  }) async {
    final currentLang = language ?? SharedPrefs.appLanguage;
    try {
      final response = await _apiService.post(ApiEndpoints.sendCode, {
        'email': email,
        'language': currentLang,
      });
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
      final response = await _apiService.post(ApiEndpoints.verifyEmail, {
        'email': email,
        'code': code,
      });
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
    String? preferredLanguage,
  }) async {
    final currentLang = preferredLanguage ?? SharedPrefs.appLanguage;
    try {
      final response = await _apiService.post(ApiEndpoints.register, {
        'fullName': fullName,
        'email': email,
        'password': password,
        'confirmPassword': confirmPassword,
        'preferredLanguage': currentLang,
      });
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
      final response = await _apiService.post(ApiEndpoints.forgotPassword, {
        'email': email,
      });
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
      final response = await _apiService.post(ApiEndpoints.verifyResetCode, {
        'email': email,
        'code': code,
      });
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
    String? resetToken,
  }) async {
    try {
      final response = await _apiService.post(ApiEndpoints.resetPassword, {
        'email': email,
        'newPassword': newPassword,
        'confirmPassword': confirmPassword,
        if (resetToken != null && resetToken.isNotEmpty)
          'resetToken': resetToken,
      });
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
      final response = await _apiService.post(ApiEndpoints.refresh, {
        'accessToken': token,
        'refreshToken': refreshToken,
      });
      final data = _apiService.handleResponse(response);
      if (data['success'] == true && data['data'] != null) {
        final payload = data['data'] as Map<String, dynamic>;
        final newAccessToken = payload['accessToken'] as String?;
        final newRefreshToken = payload['refreshToken'] as String?;
        if (newAccessToken != null) {
          await SharedPrefs.setAuthToken(newAccessToken);
        }
        if (newRefreshToken != null) {
          await SharedPrefs.setRefreshToken(newRefreshToken);
        }
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
    try {
      final response = await _apiService.put(ApiEndpoints.setCurrency, {
        'currency': currency,
      }, requiresAuth: true);
      final data = _apiService.handleResponse(response);
      if (data['success'] != true) {
        throw Exception(data['message'] ?? 'Failed to set currency');
      }
      await SharedPrefs.setCurrency(currency);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('401: Unauthorized');
      }
      final message = _extractDioErrorMessage(e);
      throw Exception(message);
    }
  }

  /// Set user preferred language on backend
  Future<void> setUserLanguage(String language) async {
    final response = await _apiService.put(ApiEndpoints.setLanguage, {
      'language': language,
    }, requiresAuth: true);
    final data = _apiService.handleResponse(response);
    if (data['success'] != true) {
      throw Exception(data['message'] ?? 'Failed to set language');
    }
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

      final response = await _apiService.post(endpoint, tokenData);

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
        final email = (user != null ? user['email'] : null) ?? payload['email'];
        if (email != null) {
          await SharedPrefs.setString(
            AppConstants.userEmailKey,
            email.toString(),
          );
          await SharedPrefs.setSecureString(
            AppConstants.userEmailKey,
            email.toString(),
          );
        }

        final currency =
            payload['currency'] ?? (user != null ? user['currency'] : null);
        if (currency != null && currency.toString().isNotEmpty) {
          await SharedPrefs.setCurrency(currency.toString());
        }
        await WalletCacheService.invalidateAll();

        if (user != null) {
          await SharedPrefs.setUserData(jsonEncode(user));
        } else if (email != null) {
          await SharedPrefs.setUserData(
            jsonEncode({
              'email': email,
              if (currency != null) 'currency': currency.toString(),
            }),
          );
        }

        final fcmToken = PushNotificationService().fcmToken;
        if (fcmToken != null && fcmToken.isNotEmpty) {
          PushNotificationService().syncTokenWithBackend(fcmToken);
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
    // Capture credentials before clearing local state. The logout request is
    // intentionally fire-and-forget so the user does not wait on the network.
    final accessToken = SharedPrefs.authToken;
    final refreshToken = SharedPrefs.refreshToken;
    if (accessToken != null && accessToken.isNotEmpty) {
      unawaited(_revokeRemoteSession(accessToken, refreshToken));
    }

    await Future.wait([
      SharedPrefs.removeAuthToken(),
      SharedPrefs.removeRefreshToken(),
      SharedPrefs.removeUserData(),
      WalletCacheService.invalidateAll(),
    ]);
  }

  Future<void> _revokeRemoteSession(
    String accessToken,
    String? refreshToken,
  ) async {
    var token = accessToken;

    // Logout requires an authenticated access token. Refresh first when its
    // JWT expiry is near, avoiding an expected 401 after short token lifetimes.
    if (_isAccessTokenNearExpiry(accessToken)) {
      if (refreshToken == null || refreshToken.isEmpty) return;
      final refreshedToken = await _refreshAccessTokenForLogout(
        accessToken,
        refreshToken,
      );
      if (refreshedToken == null) return;
      token = refreshedToken;
    }

    try {
      await _sendLogout(token);
    } on DioException catch (error) {
      // If the token was revoked or became invalid between the local check and
      // request, one refresh-and-logout retry still revokes the server session.
      if (error.response?.statusCode != 401 ||
          refreshToken == null ||
          refreshToken.isEmpty) {
        return;
      }

      final refreshedToken = await _refreshAccessTokenForLogout(
        accessToken,
        refreshToken,
      );
      if (refreshedToken == null) return;
      try {
        await _sendLogout(refreshedToken);
      } catch (_) {}
    } catch (_) {}
  }

  Future<void> _sendLogout(String accessToken) async {
    await _apiService.post(
      ApiEndpoints.logout,
      {},
      requiresAuth: true,
      skipAuthRefresh: true,
      authorizationToken: accessToken,
    );
  }

  Future<String?> _refreshAccessTokenForLogout(
    String accessToken,
    String refreshToken,
  ) async {
    try {
      final response = await _apiService.post(ApiEndpoints.refresh, {
        'accessToken': accessToken,
        'refreshToken': refreshToken,
      }, skipAuthRefresh: true);
      final result = _apiService.handleResponse(response);
      if (result['success'] != true ||
          result['data'] is! Map<String, dynamic>) {
        return null;
      }
      final payload = result['data'] as Map<String, dynamic>;
      final token = payload['accessToken'] as String?;
      return token == null || token.isEmpty ? null : token;
    } catch (_) {
      return null;
    }
  }

  bool _isAccessTokenNearExpiry(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return true;
      final payload =
          jsonDecode(
                utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
              )
              as Map<String, dynamic>;
      final expiry = payload['exp'];
      if (expiry is! num) return true;
      final expiryTime = DateTime.fromMillisecondsSinceEpoch(
        expiry.toInt() * 1000,
        isUtc: true,
      );
      return !expiryTime.isAfter(
        DateTime.now().toUtc().add(const Duration(seconds: 30)),
      );
    } catch (_) {
      return true;
    }
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
