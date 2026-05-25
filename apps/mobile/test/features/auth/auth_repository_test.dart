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

    group('sendVerification', () {
      test('sends verification code and stores temp data', () async {
        ApiService().dioForTesting = _mockDio({
          'send-verification': (options) => _jsonResponse(options, {
                'success': true,
                'message': 'Code sent',
              }),
        });

        final result = await repository.sendVerification(
          email: 'test@example.com',
          isLogin: false,
        );

        expect(result['success'], isTrue);
        expect(
            await SharedPrefs.getSecureString('temp_email'), 'test@example.com');
        expect(
            await SharedPrefs.getSecureString('temp_is_login'), 'false');
      });
    });

    group('verifyCode', () {
      test('stores verified data on success', () async {
        ApiService().dioForTesting = _mockDio({
          'verify-code': (options) => _jsonResponse(options, {
                'success': true,
                'message': 'Code verified',
              }),
        });

        final result = await repository.verifyCode(
          email: 'test@example.com',
          verificationCode: '123456',
        );

        expect(result['success'], isTrue);
        expect(
            await SharedPrefs.getSecureString('verified_email'),
            'test@example.com');
        expect(
            await SharedPrefs.getSecureString('verified_code'), '123456');
        expect(
            await SharedPrefs.getSecureString('is_code_verified'), 'true');
      });
    });

    group('completeRegistration', () {
      test('throws if code is not verified', () async {
        expect(
          () => repository.completeRegistration(
            email: 'test@example.com',
            verificationCode: '123456',
            password: 'pass',
            fullName: 'Test User',
            userName: 'testuser',
            phoneNumber: '1234567890',
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('registers user and stores token when verified', () async {
        await SharedPrefs.setBool('is_code_verified', true);
        ApiService().dioForTesting = _mockDio({
          'verify-complete': (options) => _jsonResponse(options, {
                'success': true,
                'token': 'test-token',
              }),
        });

        final result = await repository.completeRegistration(
          email: 'test@example.com',
          verificationCode: '123456',
          password: 'pass',
          fullName: 'Test User',
          userName: 'testuser',
          phoneNumber: '1234567890',
        );

        expect(result['success'], isTrue);
        expect(SharedPrefs.authToken, 'test-token');
      });
    });

    group('completeLogin', () {
      test('throws if code is not verified', () async {
        expect(
          () => repository.completeLogin(
            email: 'test@example.com',
            verificationCode: '123456',
            password: 'pass',
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('logs in user and stores token when verified', () async {
        await SharedPrefs.setSecureString('is_code_verified', 'true');
        ApiService().dioForTesting = _mockDio({
          'verify-complete': (options) => _jsonResponse(options, {
                'success': true,
                'token': 'login-token',
              }),
        });

        final result = await repository.completeLogin(
          email: 'test@example.com',
          verificationCode: '123456',
          password: 'pass',
        );

        expect(result['success'], isTrue);
        expect(SharedPrefs.authToken, 'login-token');
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
      });
    });

    group('logout', () {
      test('clears auth data on logout', () async {
        await SharedPrefs.setAuthToken('my-token');
        await SharedPrefs.setUserData('{"name":"test"}');
        ApiService().dioForTesting = _mockDio({
          'logout': (options) =>
              _jsonResponse(options, {'success': true}),
        });

        await repository.logout();

        expect(SharedPrefs.authToken, isNull);
        expect(SharedPrefs.userData, isNull);
      });
    });
  });
}
