import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_wallet/core/services/api_service.dart';
import 'package:my_wallet/core/utils/shared_prefs.dart';
import 'package:my_wallet/features/auth/data/repositories/auth_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

Dio _mockDio(Map<String, Response Function(RequestOptions)> handlers) {
  final dio = Dio();
  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) {
      for (final entry in handlers.entries) {
        if (options.path.contains(entry.key)) {
          handler.resolve(entry.value(options));
          return;
        }
      }
      handler.reject(DioException(
        requestOptions: options,
        type: DioExceptionType.unknown,
      ));
    },
  ));
  return dio;
}

Response _jsonResponse(RequestOptions options, Map<String, dynamic> data,
    {int statusCode = 200}) {
  return Response(requestOptions: options, data: data, statusCode: statusCode);
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
          'Login': (options) => _jsonResponse(options, {
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
          'send-code': (options) => _jsonResponse(options, {
                'success': true,
                'message': 'Code sent',
              }),
        });

        final result = await repository.sendCode(email: 'test@example.com');
        expect(result['success'], isTrue);
      });
    });

    group('verifyEmail', () {
      test('verifies email code successfully', () async {
        ApiService().dioForTesting = _mockDio({
          'verify-email': (options) => _jsonResponse(options, {
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
          'Register': (options) => _jsonResponse(options, {
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
          'forgot-password': (options) => _jsonResponse(options, {
                'success': true,
                'message': 'Reset code sent',
              }),
        });

        final result = await repository.forgotPassword(email: 'test@example.com');
        expect(result['success'], isTrue);
      });

      test('verifyResetCode verifies reset code', () async {
        ApiService().dioForTesting = _mockDio({
          'verify-reset-code': (options) => _jsonResponse(options, {
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
          'reset-password': (options) => _jsonResponse(options, {
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
    });

    group('checkEmail', () {
      test('returns true when email exists', () async {
        ApiService().dioForTesting = _mockDio({
          'check-email': (options) =>
              _jsonResponse(options, {'exists': true}),
        });

        final exists = await repository.checkEmail('existing@example.com');
        expect(exists, isTrue);
      });

      test('returns false when email does not exist', () async {
        ApiService().dioForTesting = _mockDio({
          'check-email': (options) =>
              _jsonResponse(options, {'exists': false}),
        });

        final exists =
            await repository.checkEmail('new@example.com');
        expect(exists, isFalse);
      });
    });

    group('setUserCurrency', () {
      test('sets currency successfully', () async {
        ApiService().dioForTesting = _mockDio({
          'set-currency': (options) =>
              _jsonResponse(options, {'success': true}),
        });

        await expectLater(
          repository.setUserCurrency('USD'),
          completes,
        );
        expect(SharedPrefs.currency, 'USD');
      });
    });

    group('logout', () {
      test('clears auth data on logout', () async {
        await SharedPrefs.setAuthToken('my-token');
        await SharedPrefs.setRefreshToken('my-refresh-token');
        await SharedPrefs.setUserData('{"name":"test"}');
        ApiService().dioForTesting = _mockDio({
          'logout': (options) =>
              _jsonResponse(options, {'success': true}),
        });

        await repository.logout();

        expect(SharedPrefs.authToken, isNull);
        expect(SharedPrefs.refreshToken, isNull);
        expect(SharedPrefs.userData, isNull);
      });
    });
  });
}
