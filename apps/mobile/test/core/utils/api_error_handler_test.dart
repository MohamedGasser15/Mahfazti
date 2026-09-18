import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_wallet/core/utils/api_error_handler.dart';

void main() {
  group('ApiErrorHandler', () {
    group('getErrorMessage', () {
      test('returns timeout message for connectionTimeout', () {
        final error = DioException(
          requestOptions: RequestOptions(path: ''),
          type: DioExceptionType.connectionTimeout,
        );
        expect(
          ApiErrorHandler.getErrorMessage(error),
          'Connection timed out. Please check your internet connection.',
        );
      });

      test('returns timeout message for sendTimeout', () {
        final error = DioException(
          requestOptions: RequestOptions(path: ''),
          type: DioExceptionType.sendTimeout,
        );
        expect(
          ApiErrorHandler.getErrorMessage(error),
          'Connection timed out. Please check your internet connection.',
        );
      });

      test('returns timeout message for receiveTimeout', () {
        final error = DioException(
          requestOptions: RequestOptions(path: ''),
          type: DioExceptionType.receiveTimeout,
        );
        expect(
          ApiErrorHandler.getErrorMessage(error),
          'Connection timed out. Please check your internet connection.',
        );
      });

      test('returns message from response data message field', () {
        final error = DioException(
          requestOptions: RequestOptions(path: ''),
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: RequestOptions(path: ''),
            statusCode: 400,
            data: {'message': 'Invalid request'},
          ),
        );
        expect(ApiErrorHandler.getErrorMessage(error), 'Invalid request');
      });

      test('returns message from response data error field', () {
        final error = DioException(
          requestOptions: RequestOptions(path: ''),
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: RequestOptions(path: ''),
            statusCode: 500,
            data: {'error': 'Server error'},
          ),
        );
        expect(ApiErrorHandler.getErrorMessage(error), 'Server error');
      });

      test('returns first error from response data errors map', () {
        final error = DioException(
          requestOptions: RequestOptions(path: ''),
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: RequestOptions(path: ''),
            statusCode: 422,
            data: {'errors': {'field1': 'Error 1', 'field2': 'Error 2'}},
          ),
        );
        expect(ApiErrorHandler.getErrorMessage(error), 'Error 1');
      });

      test('returns status code fallback when badResponse has no data', () {
        final error = DioException(
          requestOptions: RequestOptions(path: ''),
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: RequestOptions(path: ''),
            statusCode: 500,
          ),
        );
        expect(
          ApiErrorHandler.getErrorMessage(error),
          'Server error (500)',
        );
      });

      test('returns cancel message', () {
        final error = DioException(
          requestOptions: RequestOptions(path: ''),
          type: DioExceptionType.cancel,
        );
        expect(ApiErrorHandler.getErrorMessage(error), 'Request was cancelled.');
      });

      test('returns connection error message', () {
        final error = DioException(
          requestOptions: RequestOptions(path: ''),
          type: DioExceptionType.connectionError,
        );
        expect(
          ApiErrorHandler.getErrorMessage(error),
          'No internet connection.',
        );
      });

      test('returns error message when message is present', () {
        final error = DioException(
          requestOptions: RequestOptions(path: ''),
          type: DioExceptionType.unknown,
          message: 'Something went wrong',
        );
        expect(
          ApiErrorHandler.getErrorMessage(error),
          'Something went wrong',
        );
      });

      test('returns FormatException message', () {
        final error = FormatException('Invalid format');
        expect(
          ApiErrorHandler.getErrorMessage(error),
          'Invalid data format received from server.',
        );
      });

      test('returns generic error toString', () {
        final error = Exception('Some generic error');
        expect(
          ApiErrorHandler.getErrorMessage(error),
          'Exception: Some generic error',
        );
      });
    });

    group('isNetworkError', () {
      test('returns true for connectionTimeout', () {
        final error = DioException(
          requestOptions: RequestOptions(path: ''),
          type: DioExceptionType.connectionTimeout,
        );
        expect(ApiErrorHandler.isNetworkError(error), isTrue);
      });

      test('returns true for sendTimeout', () {
        final error = DioException(
          requestOptions: RequestOptions(path: ''),
          type: DioExceptionType.sendTimeout,
        );
        expect(ApiErrorHandler.isNetworkError(error), isTrue);
      });

      test('returns true for receiveTimeout', () {
        final error = DioException(
          requestOptions: RequestOptions(path: ''),
          type: DioExceptionType.receiveTimeout,
        );
        expect(ApiErrorHandler.isNetworkError(error), isTrue);
      });

      test('returns true for connectionError', () {
        final error = DioException(
          requestOptions: RequestOptions(path: ''),
          type: DioExceptionType.connectionError,
        );
        expect(ApiErrorHandler.isNetworkError(error), isTrue);
      });

      test('returns false for cancel', () {
        final error = DioException(
          requestOptions: RequestOptions(path: ''),
          type: DioExceptionType.cancel,
        );
        expect(ApiErrorHandler.isNetworkError(error), isFalse);
      });

      test('returns false for badResponse', () {
        final error = DioException(
          requestOptions: RequestOptions(path: ''),
          type: DioExceptionType.badResponse,
        );
        expect(ApiErrorHandler.isNetworkError(error), isFalse);
      });

      test('returns false for non-DioException', () {
        expect(ApiErrorHandler.isNetworkError('string error'), isFalse);
        expect(ApiErrorHandler.isNetworkError(FormatException()), isFalse);
      });
    });
  });
}
