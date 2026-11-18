import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_wallet/core/constants/api_constants.dart';
import 'package:my_wallet/core/services/api_service.dart';
import 'package:my_wallet/core/utils/shared_prefs.dart';
import 'package:my_wallet/features/auth/data/repositories/auth_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

Dio _mockDio(Map<String, Response Function(RequestOptions)> handlers) {
  final dio = Dio();
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        for (final entry in handlers.entries) {
          if (options.path.contains(entry.key)) {
            handler.resolve(entry.value(options));
            return;
          }
        }
        handler.reject(
          DioException(requestOptions: options, type: DioExceptionType.unknown),
        );
      },
    ),
  );
  return dio;
}

Response _jsonResponse(
  RequestOptions options,
  Map<String, dynamic> data, {
  int statusCode = 200,
}) {
  return Response(requestOptions: options, data: data, statusCode: statusCode);
}

String _tokenWithExpiry(DateTime expiry) {
  final payload = base64Url
      .encode(
        utf8.encode(jsonEncode({'exp': expiry.millisecondsSinceEpoch ~/ 1000})),
      )
      .replaceAll('=', '');
  return 'header.$payload.signature';
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final secureStorage = <String, String>{};

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    secureStorage.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
          (MethodCall methodCall) async {
            switch (methodCall.method) {
              case 'read':
                return secureStorage[methodCall.arguments['key']];
              case 'write':
                secureStorage[methodCall.arguments['key']] =
                    methodCall.arguments['value'];
                return null;
              case 'delete':
                secureStorage.remove(methodCall.arguments['key']);
                return null;
              case 'containsKey':
                return secureStorage.containsKey(methodCall.arguments['key']);
              case 'readAll':
                return Map<String, String>.from(secureStorage);
              case 'deleteAll':
                secureStorage.clear();
                return null;
            }
            return null;
          },
        );
  });

  group('AuthRepository', () {
    late AuthRepository repository;

    setUp(() async {
      await SharedPrefs.init();
      repository = AuthRepository();
    });

    group('login', () {
      test('logs in and saves tokens and user data', () async {
        ApiService().dioForTesting = _mockDio({
          ApiEndpoints.login: (options) => _jsonResponse(options, {
            'success': true,
            'data': {
              'token': 'mock-access-token',
              'refreshToken': 'mock-refresh-token',
              'user': {
                'id': 'u1',
                'email': 'test@example.com',
                'fullName': 'Test User',
                'currency': 'USD',
              },
            },
          }),
        });

        final result = await repository.login(
          email: 'test@example.com',
          password: 'Password123',
        );

        expect(result['success'], isTrue);
        expect(SharedPrefs.authToken, 'mock-access-token');
        expect(SharedPrefs.refreshToken, 'mock-refresh-token');
        expect(SharedPrefs.currency, 'USD');
      });
    });

    group('sendCode', () {
      test('sends code successfully', () async {
        ApiService().dioForTesting = _mockDio({
          ApiEndpoints.sendCode: (options) =>
              _jsonResponse(options, {'success': true, 'message': 'Code sent'}),
        });

        final result = await repository.sendCode(email: 'test@example.com');
        expect(result['success'], isTrue);
      });
    });

    group('verifyEmail', () {
      test('verifies email code successfully', () async {
        ApiService().dioForTesting = _mockDio({
          ApiEndpoints.verifyEmail: (options) => _jsonResponse(options, {
            'success': true,
            'message': 'Email verified',
          }),
        });

        final result = await repository.verifyEmail(
          email: 'test@example.com',
          code: '123456',
        );
        expect(result['success'], isTrue);
      });
    });

    group('register', () {
      test('registers user successfully', () async {
        ApiService().dioForTesting = _mockDio({
          ApiEndpoints.register: (options) => _jsonResponse(options, {
            'success': true,
            'message': 'User registered successfully',
          }),
        });

        final result = await repository.register(
          fullName: 'Test User',
          email: 'test@example.com',
          password: 'Password123',
          confirmPassword: 'Password123',
        );

        expect(result['success'], isTrue);
      });
    });

    group('forgotPassword & resetPassword', () {
      test('forgotPassword sends reset code', () async {
        ApiService().dioForTesting = _mockDio({
          ApiEndpoints.forgotPassword: (options) => _jsonResponse(options, {
            'success': true,
            'message': 'Reset code sent',
          }),
        });

        final result = await repository.forgotPassword(
          email: 'test@example.com',
        );
        expect(result['success'], isTrue);
      });

      test('verifyResetCode verifies reset code', () async {
        ApiService().dioForTesting = _mockDio({
          ApiEndpoints.verifyResetCode: (options) => _jsonResponse(options, {
            'success': true,
            'message': 'Code valid',
          }),
        });

        final result = await repository.verifyResetCode(
          email: 'test@example.com',
          code: '123456',
        );
        expect(result['success'], isTrue);
      });

      test('resetPassword resets password successfully', () async {
        ApiService().dioForTesting = _mockDio({
          ApiEndpoints.resetPassword: (options) => _jsonResponse(options, {
            'success': true,
            'message': 'Password reset',
          }),
        });

        final result = await repository.resetPassword(
          email: 'test@example.com',
          newPassword: 'NewPassword123',
          confirmPassword: 'NewPassword123',
        );
        expect(result['success'], isTrue);
      });

      test('resetPassword sends resetToken in body when provided', () async {
        String? sentResetToken;
        ApiService().dioForTesting = _mockDio({
          ApiEndpoints.resetPassword: (options) {
            sentResetToken = options.data['resetToken'] as String?;
            return _jsonResponse(options, {
              'success': true,
              'message': 'Password reset',
            });
          },
        });

        final result = await repository.resetPassword(
          email: 'test@example.com',
          newPassword: 'NewPassword123',
          confirmPassword: 'NewPassword123',
          resetToken: 'proof_token_123',
        );
        expect(result['success'], isTrue);
        expect(sentResetToken, 'proof_token_123');
      });
    });

    group('checkEmail', () {
      test('returns true when email exists', () async {
        ApiService().dioForTesting = _mockDio({
          'check-email': (options) => _jsonResponse(options, {'exists': true}),
        });

        final exists = await repository.checkEmail('existing@example.com');
        expect(exists, isTrue);
      });

      test('returns false when email does not exist', () async {
        ApiService().dioForTesting = _mockDio({
          'check-email': (options) => _jsonResponse(options, {'exists': false}),
        });

        final exists = await repository.checkEmail('new@example.com');
        expect(exists, isFalse);
      });
    });

    group('setUserCurrency', () {
      test(
        'sets currency successfully with PUT and updates SharedPrefs',
        () async {
          String? capturedMethod;
          dynamic capturedData;
          ApiService().dioForTesting = _mockDio({
            ApiEndpoints.setCurrency: (options) {
              capturedMethod = options.method;
              capturedData = options.data;
              return _jsonResponse(options, {'success': true});
            },
          });

          await expectLater(repository.setUserCurrency('USD'), completes);
          expect(capturedMethod, 'PUT');
          expect(capturedData, {'currency': 'USD'});
          expect(SharedPrefs.currency, 'USD');
        },
      );

      test('throws Exception on 401 unauthorized', () async {
        final dio = Dio();
        dio.interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              handler.reject(
                DioException(
                  requestOptions: options,
                  response: Response(requestOptions: options, statusCode: 401),
                  type: DioExceptionType.badResponse,
                ),
              );
            },
          ),
        );
        ApiService().dioForTesting = dio;

        expect(
          () => repository.setUserCurrency('USD'),
          throwsA(predicate((e) => e.toString().contains('401: Unauthorized'))),
        );
      });
    });

    group('setUserLanguage', () {
      test('sets language successfully with PUT', () async {
        String? capturedMethod;
        dynamic capturedData;
        ApiService().dioForTesting = _mockDio({
          ApiEndpoints.setLanguage: (options) {
            capturedMethod = options.method;
            capturedData = options.data;
            return _jsonResponse(options, {'success': true});
          },
        });

        await expectLater(repository.setUserLanguage('ar'), completes);
        expect(capturedMethod, 'PUT');
        expect(capturedData, {'language': 'ar'});
      });
    });

    group('logout', () {
      test('clears auth data on logout', () async {
        final validToken = _tokenWithExpiry(
          DateTime.now().toUtc().add(const Duration(hours: 1)),
        );
        await SharedPrefs.setAuthToken(validToken);
        await SharedPrefs.setRefreshToken('my-refresh-token');
        await SharedPrefs.setUserData('{"name":"test"}');
        final logoutRequest = Completer<RequestOptions>();
        ApiService().dioForTesting = _mockDio({
          'logout': (options) {
            logoutRequest.complete(options);
            return _jsonResponse(options, {'success': true});
          },
        });

        await repository.logout();
        final requestOptions = await logoutRequest.future;

        expect(requestOptions.headers['Authorization'], 'Bearer $validToken');
        expect(SharedPrefs.authToken, isNull);
        expect(SharedPrefs.refreshToken, isNull);
        expect(SharedPrefs.userData, isNull);
      });

      test('refreshes an expired access token before remote logout', () async {
        final expiredToken = _tokenWithExpiry(
          DateTime.now().toUtc().subtract(const Duration(minutes: 1)),
        );
        await SharedPrefs.setAuthToken(expiredToken);
        await SharedPrefs.setRefreshToken('my-refresh-token');
        final requestPaths = <String>[];
        final logoutRequest = Completer<RequestOptions>();
        ApiService().dioForTesting = _mockDio({
          'refresh': (options) {
            requestPaths.add(options.path);
            return _jsonResponse(options, {
              'success': true,
              'data': {
                'accessToken': 'fresh-token',
                'refreshToken': 'fresh-refresh-token',
              },
            });
          },
          'logout': (options) {
            requestPaths.add(options.path);
            logoutRequest.complete(options);
            return _jsonResponse(options, {'success': true});
          },
        });

        await repository.logout();
        final requestOptions = await logoutRequest.future;

        expect(requestPaths, [ApiEndpoints.refresh, ApiEndpoints.logout]);
        expect(requestOptions.headers['Authorization'], 'Bearer fresh-token');
        expect(SharedPrefs.authToken, isNull);
        expect(SharedPrefs.refreshToken, isNull);
      });
    });
  });
}
