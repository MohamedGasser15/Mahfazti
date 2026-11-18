import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_wallet/core/constants/api_constants.dart';
import 'package:my_wallet/core/services/api_service.dart';
import 'package:my_wallet/core/utils/shared_prefs.dart';
import 'package:my_wallet/features/profile/data/repositories/profile_repository.dart';
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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final secureStorage = <String, String>{};

  setUp(() async {
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
    await SharedPrefs.init();
  });

  group('ProfileRepository currency & language', () {
    late ProfileRepository repository;

    setUp(() {
      repository = ProfileRepository();
    });

    test(
      'updateCurrency sends PUT to profile/currency and updates SharedPrefs',
      () async {
        String? capturedMethod;
        dynamic capturedData;
        ApiService().dioForTesting = _mockDio({
          ApiEndpoints.setCurrency: (options) {
            capturedMethod = options.method;
            capturedData = options.data;
            return _jsonResponse(options, {
              'success': true,
              'message': 'Success',
            });
          },
        });

        await repository.updateCurrency('EUR');

        expect(capturedMethod, 'PUT');
        expect(capturedData, {'currency': 'EUR'});
        expect(SharedPrefs.currency, 'EUR');
      },
    );

    test('updateLanguage sends PUT to profile/language', () async {
      String? capturedMethod;
      dynamic capturedData;
      ApiService().dioForTesting = _mockDio({
        ApiEndpoints.setLanguage: (options) {
          capturedMethod = options.method;
          capturedData = options.data;
          return _jsonResponse(options, {
            'success': true,
            'message': 'Success',
          });
        },
      });

      await repository.updateLanguage('ar');

      expect(capturedMethod, 'PUT');
      expect(capturedData, {'language': 'ar'});
    });
  });
}
