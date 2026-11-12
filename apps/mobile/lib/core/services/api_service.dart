import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:my_wallet/core/constants/api_constants.dart';
import 'package:my_wallet/core/constants/app_constants.dart';
import 'package:my_wallet/core/constants/app_routes.dart';
import 'package:my_wallet/core/services/wallet_cache_service.dart';
import 'package:my_wallet/core/utils/navigation_service.dart';
import 'package:my_wallet/core/utils/shared_prefs.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  late Dio _dio;
  bool _hasTestingDio = false;
  Future<bool>? _refreshFuture;
  bool _isLoggingOut = false;

  @visibleForTesting
  Dio? refreshDioForTesting;

  bool get hasTestingDio => _hasTestingDio;

  @visibleForTesting
  set dioForTesting(Dio value) {
    _dio = value;
    _hasTestingDio = true;
  }

  @visibleForTesting
  Dio get dio => _dio;

  ApiService._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      ),
    );

    // Auth and Language Interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          options.headers['Accept-Language'] = SharedPrefs.appLanguage;

          final requiresAuth = options.extra['requiresAuth'] == true;
          if (requiresAuth) {
            final token = SharedPrefs.authToken;
            if (token != null &&
                token.isNotEmpty &&
                !options.headers.containsKey('Authorization')) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          if (error.response?.statusCode == 401) {
            final requiresAuth =
                error.requestOptions.extra['requiresAuth'] == true;
            final skipAuthRefresh =
                error.requestOptions.extra['skipAuthRefresh'] == true;
            final isRetry = error.requestOptions.extra['isRetry'] == true;
            final path = error.requestOptions.path;
            final isAuthEndpoint =
                path.contains(ApiEndpoints.login) ||
                path.contains('Login') ||
                path.contains(ApiEndpoints.verifyEmail) ||
                path.contains('verify-email') ||
                path.contains(ApiEndpoints.sendCode) ||
                path.contains('send-code') ||
                path.contains(ApiEndpoints.refresh) ||
                path.contains('api/Auth/refresh') ||
                path.contains(ApiEndpoints.forgotPassword) ||
                path.contains('forgot-password') ||
                path.contains(ApiEndpoints.verifyResetCode) ||
                path.contains('verify-reset-code') ||
                path.contains(ApiEndpoints.resetPassword) ||
                path.contains('reset-password') ||
                path.contains(ApiEndpoints.checkEmail);

            if (requiresAuth &&
                !skipAuthRefresh &&
                !isAuthEndpoint &&
                !isRetry) {
              final refreshSuccess = await _refreshTokenSynchronized();

              if (refreshSuccess) {
                final newAccess = SharedPrefs.authToken;
                if (newAccess != null && newAccess.isNotEmpty) {
                  try {
                    // Retry original request once with new token
                    final options = error.requestOptions;
                    options.headers['Authorization'] = 'Bearer $newAccess';
                    options.extra['isRetry'] = true;

                    final clonedResponse = await _dio.fetch(options);
                    return handler.resolve(clonedResponse);
                  } catch (retryError) {
                    if (retryError is DioException) {
                      return handler.next(retryError);
                    }
                    return handler.next(error);
                  }
                }
              }

              // Refresh failed or no new token: clear session once and redirect
              await _handleAuthFailure();
            }
          }

          return handler.next(error);
        },
      ),
    );

    // Logging (debug only)
    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          // API traffic contains credentials and financial data; keep the
          // debug log to request/response metadata only.
          requestBody: false,
          responseBody: false,
          requestHeader: false,
          responseHeader: false,
        ),
      );
    }
  }

  Options _authOptions(
    bool requiresAuth, {
    bool skipAuthRefresh = false,
    String? authorizationToken,
  }) {
    return Options(
      headers: authorizationToken == null || authorizationToken.isEmpty
          ? null
          : {'Authorization': 'Bearer $authorizationToken'},
      extra: {'requiresAuth': requiresAuth, 'skipAuthRefresh': skipAuthRefresh},
    );
  }

  Future<Response> get(
    String endpoint, {
    Map<String, dynamic>? queryParams,
    bool requiresAuth = false,
  }) async {
    return await _dio.get(
      endpoint,
      queryParameters: queryParams,
      options: _authOptions(requiresAuth),
    );
  }

  Future<Response> post(
    String endpoint,
    dynamic body, {
    bool requiresAuth = false,
    bool skipAuthRefresh = false,
    String? authorizationToken,
  }) async {
    return await _dio.post(
      endpoint,
      data: body,
      options: _authOptions(
        requiresAuth,
        skipAuthRefresh: skipAuthRefresh,
        authorizationToken: authorizationToken,
      ),
    );
  }

  Future<Response> put(
    String endpoint,
    dynamic body, {
    bool requiresAuth = false,
  }) async {
    return await _dio.put(
      endpoint,
      data: body,
      options: _authOptions(requiresAuth),
    );
  }

  Future<Response> delete(
    String endpoint, {
    Map<String, dynamic>? queryParams,
    bool requiresAuth = false,
  }) async {
    return await _dio.delete(
      endpoint,
      queryParameters: queryParams,
      options: _authOptions(requiresAuth),
    );
  }

  // Helper method to parse API standard response envelopes
  Map<String, dynamic> handleResponse(Response response) {
    final statusCode = response.statusCode;
    final data = response.data;

    if (data == null) {
      return {'success': false, 'message': 'Empty response from server'};
    }

    if (data is Map<String, dynamic>) {
      return {
        'success': data['success'] ?? (statusCode == 200 || statusCode == 201),
        'message': data['message'] ?? '',
        ...data,
      };
    }

    return {'success': false, 'message': data.toString()};
  }

  Future<bool> _refreshTokenSynchronized() {
    if (_refreshFuture != null) {
      return _refreshFuture!;
    }

    final completer = Completer<bool>();
    _refreshFuture = completer.future;

    () async {
      try {
        final token = SharedPrefs.authToken;
        final refreshToken = SharedPrefs.refreshToken;

        if (token == null || refreshToken == null) {
          completer.complete(false);
          return;
        }

        final refreshDio =
            refreshDioForTesting ??
            Dio(BaseOptions(baseUrl: AppConstants.baseUrl));
        final refreshRes = await refreshDio.post(
          ApiEndpoints.refresh,
          data: {'accessToken': token, 'refreshToken': refreshToken},
        );

        if (refreshRes.statusCode == 200 && refreshRes.data != null) {
          final data = refreshRes.data;
          final payload = data['data'];
          if (payload != null) {
            final newAccess = payload['accessToken'] as String?;
            final newRefresh = payload['refreshToken'] as String?;
            if (newAccess != null && newAccess.isNotEmpty) {
              await SharedPrefs.setAuthToken(newAccess);
              if (newRefresh != null && newRefresh.isNotEmpty) {
                await SharedPrefs.setRefreshToken(newRefresh);
              }
              completer.complete(true);
              return;
            }
          }
        }
        completer.complete(false);
      } catch (_) {
        completer.complete(false);
      } finally {
        Future.microtask(() {
          _refreshFuture = null;
        });
      }
    }();

    return _refreshFuture!;
  }

  Future<void> _handleAuthFailure() async {
    if (_isLoggingOut) return;
    _isLoggingOut = true;

    try {
      await SharedPrefs.removeAuthToken();
      await SharedPrefs.removeRefreshToken();
      await SharedPrefs.removeUserData();
      await WalletCacheService.invalidateAll();

      if (NavigationService.context != null) {
        NavigationService.navigateAndRemoveUntil(AppRoutes.email);
      }
    } finally {
      _isLoggingOut = false;
    }
  }
}
