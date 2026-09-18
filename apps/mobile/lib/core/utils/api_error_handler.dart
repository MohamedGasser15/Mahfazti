// lib/core/utils/api_error_handler.dart
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:my_wallet/core/services/message_service.dart';

class ApiErrorHandler {
  static String getErrorMessage(dynamic error, [BuildContext? context]) {
    String msg;
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          msg = 'Connection timed out. Please check your internet connection.';
          break;
        case DioExceptionType.badResponse:
          final responseData = error.response?.data;
          if (responseData != null) {
            if (responseData is Map) {
              if (responseData.containsKey('message') && responseData['message'] != null) {
                msg = responseData['message'].toString();
              } else if (responseData.containsKey('error') && responseData['error'] != null) {
                msg = responseData['error'].toString();
              } else if (responseData.containsKey('errors') && responseData['errors'] != null) {
                final errors = responseData['errors'];
                if (errors is Map && errors.isNotEmpty) {
                  final firstVal = errors.values.first;
                  if (firstVal is List && firstVal.isNotEmpty) {
                    msg = firstVal.first.toString();
                  } else {
                    msg = firstVal.toString();
                  }
                } else if (errors is List && errors.isNotEmpty) {
                  msg = errors.first.toString();
                } else {
                  msg = 'Server error (${error.response?.statusCode ?? 'unknown'})';
                }
              } else {
                msg = 'Server error (${error.response?.statusCode ?? 'unknown'})';
              }
            } else if (responseData is String && responseData.isNotEmpty) {
              msg = responseData;
            } else {
              msg = 'Server error (${error.response?.statusCode ?? 'unknown'})';
            }
          } else {
            msg = 'Server error (${error.response?.statusCode ?? 'unknown'})';
          }
          break;
        case DioExceptionType.cancel:
          msg = 'Request was cancelled.';
          break;
        case DioExceptionType.connectionError:
          msg = 'No internet connection.';
          break;
        default:
          msg = error.message != null && error.message!.isNotEmpty
              ? error.message!
              : 'An unexpected error occurred.';
      }
    } else if (error is FormatException) {
      msg = 'Invalid data format received from server.';
    } else {
      msg = error.toString();
    }

    if (context != null) {
      return MessageService.localizeMessage(context: context, rawMessage: msg);
    }
    return msg;
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