import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_wallet/core/constants/api_constants.dart';
import 'package:my_wallet/core/services/api_service.dart';
import 'package:my_wallet/core/utils/shared_prefs.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TestHttpClientAdapter implements HttpClientAdapter {
  final Future<ResponseBody> Function(RequestOptions options) handler;
  TestHttpClientAdapter(this.handler);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
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
              default:
                return null;
            }
          },
        );

    await SharedPrefs.init();
    await SharedPrefs.setAuthToken('old_access_token');
    await SharedPrefs.setRefreshToken('valid_refresh_token');
  });

  group('ApiService Concurrent 401 Refresh', () {
    test(
      'Synchronizes concurrent 401s into single refresh call and retries all requests',
      () async {
        final apiService = ApiService();
        int refreshCallCount = 0;

        // Mock adapter for the main _dio (including retries)
        apiService.dio.httpClientAdapter = TestHttpClientAdapter((options) async {
          if (options.path.contains('protected-endpoint')) {
            final authHeader = options.headers['Authorization'] as String?;

            if (authHeader == 'Bearer old_access_token') {
              return ResponseBody.fromString(
                jsonEncode({'message': 'Unauthorized'}),
                401,
                headers: {
                  Headers.contentTypeHeader: [Headers.jsonContentType],
                },
              );
            }

            if (authHeader == 'Bearer new_refreshed_token') {
              return ResponseBody.fromString(
                jsonEncode({'success': true, 'data': 'protected_data'}),
                200,
                headers: {
                  Headers.contentTypeHeader: [Headers.jsonContentType],
                },
              );
            }
          }

          return ResponseBody.fromString('{}', 404);
        });

        // Mock dio for the refresh endpoint call inside _refreshTokenSynchronized
        final mockRefreshDio = Dio();
        mockRefreshDio.httpClientAdapter = TestHttpClientAdapter((options) async {
          if (options.path.contains(ApiEndpoints.refresh)) {
            refreshCallCount++;
            await Future.delayed(const Duration(milliseconds: 25));
            return ResponseBody.fromString(
              jsonEncode({
                'success': true,
                'data': {
                  'accessToken': 'new_refreshed_token',
                  'refreshToken': 'new_rotated_refresh_token',
                },
              }),
              200,
              headers: {
                Headers.contentTypeHeader: [Headers.jsonContentType],
              },
            );
          }
          return ResponseBody.fromString('{}', 404);
        });
        apiService.refreshDioForTesting = mockRefreshDio;

        // Fire 3 concurrent authenticated requests with old token
        final f1 = apiService.get('protected-endpoint', requiresAuth: true);
        final f2 = apiService.get('protected-endpoint', requiresAuth: true);
        final f3 = apiService.get('protected-endpoint', requiresAuth: true);

        final results = await Future.wait([f1, f2, f3]);

        // Assert only ONE refresh request was dispatched
        expect(refreshCallCount, 1);

        // Assert all 3 requests were retried and succeeded
        expect(results.length, 3);
        for (final res in results) {
          expect(res.statusCode, 200);
          expect(res.data['success'], true);
        }

        // Verify tokens updated in SharedPrefs
        expect(SharedPrefs.authToken, 'new_refreshed_token');
        expect(SharedPrefs.refreshToken, 'new_rotated_refresh_token');
      },
    );

    test('Refresh failure clears session and does not loop', () async {
      final apiService = ApiService();
      int refreshCallCount = 0;

      apiService.dio.httpClientAdapter = TestHttpClientAdapter((options) async {
        return ResponseBody.fromString(
          jsonEncode({'message': 'Unauthorized'}),
          401,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });

      final mockRefreshDio = Dio();
      mockRefreshDio.httpClientAdapter = TestHttpClientAdapter((options) async {
        refreshCallCount++;
        return ResponseBody.fromString(
          jsonEncode({'message': 'Invalid refresh token'}),
          400,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });
      apiService.refreshDioForTesting = mockRefreshDio;

      try {
        await apiService.get('protected-endpoint', requiresAuth: true);
      } catch (e) {
        expect(e, isA<DioException>());
      }

      // Assert refresh was attempted exactly once
      expect(refreshCallCount, 1);

      // Assert session tokens were wiped
      expect(SharedPrefs.authToken, isNull);
      expect(SharedPrefs.refreshToken, isNull);
    });
  });
}
