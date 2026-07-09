// core/services/api_service.dart
import 'dart:convert';
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
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
    ));
    
    // Add interceptor for logging
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      requestHeader: true,
    ));
  }
  Future<Response> put(
  String endpoint,
  Map<String, dynamic> body, {
  bool requiresAuth = false,
}) async {
  try {
    final headers = <String, String>{};
    if (requiresAuth) {
      final token = SharedPrefs.authToken;
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    debugPrint('PUT Request to: $endpoint');
    debugPrint('Body: ${jsonEncode(body)}');

    final response = await _dio.put(
      endpoint,
      data: body,
      options: Options(headers: headers),
    );

    debugPrint('Response Status: ${response.statusCode}');
    debugPrint('Response Body: ${response.data}');

    return response;
  } on DioException catch (e) {
    debugPrint('PUT Error: $e');
    if (e.response != null) {
      debugPrint('Response: ${e.response?.data}');
    }
    rethrow;
  } catch (e) {
    debugPrint('PUT Error: $e');
    rethrow;
  }
}
  Future<Response> delete(
  String endpoint, {
  Map<String, dynamic>? queryParams,
  bool requiresAuth = false,
}) async {
  try {
    final headers = <String, String>{};
    if (requiresAuth) {
      final token = SharedPrefs.authToken;
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    
    debugPrint('DELETE Request to: $endpoint');
    if (queryParams != null) {
      debugPrint('Query Params: $queryParams');
    }
    
    final response = await _dio.delete(
      endpoint,
      queryParameters: queryParams,
      options: Options(headers: headers),
    );
    
    debugPrint('Response Status: ${response.statusCode}');
    debugPrint('Response Body: ${response.data}');
    
    return response;
  } on DioException catch (e) {
    debugPrint('DELETE Error: $e');
    if (e.response != null) {
      debugPrint('Response: ${e.response?.data}');
    }
    rethrow;
  } catch (e) {
    debugPrint('DELETE Error: $e');
    rethrow;
  }
}
  Future<Response> post(
    String endpoint, 
    Map<String, dynamic> body, {
    bool requiresAuth = false,
  }) async {
    try {
      final headers = <String, String>{};
      
      if (requiresAuth) {
        final token = SharedPrefs.authToken;
        if (token != null) {
          headers['Authorization'] = 'Bearer $token';
        }
      }
      
      debugPrint('POST Request to: $endpoint');
      debugPrint('Body: ${jsonEncode(body)}');
      
      final response = await _dio.post(
        endpoint,
        data: body,
        options: Options(headers: headers),
      );
      
      debugPrint('Response Status: ${response.statusCode}');
      debugPrint('Response Body: ${response.data}');
      
      return response;
    } on DioException catch (e) {
      debugPrint('POST Error: $e');
      if (e.response != null) {
        debugPrint('Response: ${e.response?.data}');
      }
      rethrow;
    } catch (e) {
      debugPrint('POST Error: $e');
      rethrow;
    }
  }
  
  Future<Response> get(
    String endpoint, {
    Map<String, dynamic>? queryParams,
    bool requiresAuth = false,
  }) async {
    try {
      final headers = <String, String>{};
      
      if (requiresAuth) {
        final token = SharedPrefs.authToken;
        if (token != null) {
          headers['Authorization'] = 'Bearer $token';
        }
      }
      
      debugPrint('GET Request to: $endpoint');
      if (queryParams != null) {
        debugPrint('Query Params: $queryParams');
      }
      
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParams,
        options: Options(headers: headers),
      );
      
      debugPrint('Response Status: ${response.statusCode}');
      debugPrint('Response Body: ${response.data}');
      
      return response;
    } on DioException catch (e) {
      debugPrint('GET Error: $e');
      if (e.response != null) {
        debugPrint('Response: ${e.response?.data}');
      }
      rethrow;
    } catch (e) {
      debugPrint('GET Error: $e');
      rethrow;
    }
  }
  
  // Helper method to handle API responses
  Map<String, dynamic> handleResponse(Response response) {
    debugPrint('Handling response: ${response.statusCode}');
    
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