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

    print('🌐 PUT Request to: $endpoint');
    print('📦 Body: ${jsonEncode(body)}');

    final response = await _dio.put(
      endpoint,
      data: body,
      options: Options(headers: headers),
    );

    print('📥 Response Status: ${response.statusCode}');
    print('📥 Response Body: ${response.data}');

    return response;
  } on DioException catch (e) {
    print('❌ PUT Error: $e');
    if (e.response != null) {
      print('❌ Response: ${e.response?.data}');
    }
    rethrow;
  } catch (e) {
    print('❌ PUT Error: $e');
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
    
    print('🌐 DELETE Request to: $endpoint');
    if (queryParams != null) {
      print('📋 Query Params: $queryParams');
    }
    
    final response = await _dio.delete(
      endpoint,
      queryParameters: queryParams,
      options: Options(headers: headers),
    );
    
    print('📥 Response Status: ${response.statusCode}');
    print('📥 Response Body: ${response.data}');
    
    return response;
  } on DioException catch (e) {
    print('❌ DELETE Error: $e');
    if (e.response != null) {
      print('❌ Response: ${e.response?.data}');
    }
    rethrow;
  } catch (e) {
    print('❌ DELETE Error: $e');
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
      
      print('🌐 POST Request to: $endpoint');
      print('📦 Body: ${jsonEncode(body)}');
      
      final response = await _dio.post(
        endpoint,
        data: body,
        options: Options(headers: headers),
      );
      
      print('📥 Response Status: ${response.statusCode}');
      print('📥 Response Body: ${response.data}');
      
      return response;
    } on DioException catch (e) {
      print('❌ POST Error: $e');
      if (e.response != null) {
        print('❌ Response: ${e.response?.data}');
      }
      rethrow;
    } catch (e) {
      print('❌ POST Error: $e');
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
      
      print('🌐 GET Request to: $endpoint');
      if (queryParams != null) {
        print('📋 Query Params: $queryParams');
      }
      
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParams,
        options: Options(headers: headers),
      );
      
      print('📥 Response Status: ${response.statusCode}');
      print('📥 Response Body: ${response.data}');
      
      return response;
    } on DioException catch (e) {
      print('❌ GET Error: $e');
      if (e.response != null) {
        print('❌ Response: ${e.response?.data}');
      }
      rethrow;
    } catch (e) {
      print('❌ GET Error: $e');
      rethrow;
    }
  }
  
  // Helper method to handle API responses
  Map<String, dynamic> handleResponse(Response response) {
    print('🔄 Handling response: ${response.statusCode}');
    
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