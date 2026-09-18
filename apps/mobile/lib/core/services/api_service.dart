import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:my_wallet/core/constants/app_constants.dart';
import 'package:my_wallet/core/utils/shared_prefs.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  late Dio _dio;

  @visibleForTesting
  set dioForTesting(Dio value) => _dio = value;

  ApiService._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
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
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }
          return handler.next(options);
        },
      ),
    );

    // Logging (debug only)
    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          requestHeader: true,
        ),
      );
    }
  }

  Options _authOptions(bool requiresAuth) {
    return Options(extra: {'requiresAuth': requiresAuth});
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
  }) async {
    return await _dio.post(
      endpoint,
      data: body,
      options: _authOptions(requiresAuth),
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
      return {
        'success': false,
        'message': 'Empty response from server',
      };
    }

    if (data is Map<String, dynamic>) {
      return {
        'success': data['success'] ?? (statusCode == 200 || statusCode == 201),
        'message': data['message'] ?? '',
        ...data,
      };
    }

    return {
      'success': false,
      'message': data.toString(),
    };
  }
}