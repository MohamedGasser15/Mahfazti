// lib/core/utils/api_error_handler.dart
import 'package:dio/dio.dart';

class ApiErrorHandler {
  static String getErrorMessage(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return 'Connection timed out. Please check your internet connection.';
        case DioExceptionType.badResponse:
          final responseData = error.response?.data;
          if (responseData != null) {
            if (responseData is Map) {
              if (responseData.containsKey('message')) {
                return responseData['message'].toString();
              } else if (responseData.containsKey('error')) {
                return responseData['error'].toString();
              } else if (responseData.containsKey('errors')) {
                final errors = responseData['errors'];
                if (errors is Map) {
                  return errors.values.join('\n');
                }
              }
            } else if (responseData is String) {
              return responseData;
            }
          }
          return 'Server error (${error.response?.statusCode ?? 'unknown'})';
        case DioExceptionType.cancel:
          return 'Request was cancelled.';
        case DioExceptionType.connectionError:
          return 'No internet connection.';
        default:
          return 'An unexpected error occurred: ${error.message}';
      }
    } else if (error is FormatException) {
      return 'Invalid data format received from server.';
    } else {
      return error.toString();
    }
  }

  static bool isNetworkError(dynamic error) {
    if (error is DioException) {
      return error.type == DioExceptionType.connectionError ||
             error.type == DioExceptionType.connectionTimeout ||
             error.type == DioExceptionType.receiveTimeout ||
             error.type == DioExceptionType.sendTimeout;
    }
    return false;
  }
}