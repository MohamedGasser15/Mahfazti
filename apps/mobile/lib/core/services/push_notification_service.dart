import 'dart:async';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:my_wallet/core/constants/api_constants.dart';
import 'package:my_wallet/core/services/api_service.dart';
import 'package:my_wallet/core/utils/shared_prefs.dart';
import 'package:my_wallet/firebase_options.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (_) {}
  debugPrint(
    'Handling background notification: ${message.messageId} - ${message.notification?.title}',
  );
}

class PushNotificationService {
  static final PushNotificationService _instance =
      PushNotificationService._internal();
  factory PushNotificationService() => _instance;
  PushNotificationService._internal();

  FirebaseMessaging? _messagingInstance;
  FirebaseMessaging get _messaging =>
      _messagingInstance ??= FirebaseMessaging.instance;

  final ApiService _apiService = ApiService();
  String? _fcmToken;

  static bool get isFirebaseAvailable => Firebase.apps.isNotEmpty;

  String? get fcmToken {
    if (!isFirebaseAvailable) return null;
    return _fcmToken;
  }

  /// Initializes Firebase Cloud Messaging for Push Notifications.
  Future<void> initialize() async {
    if (!isFirebaseAvailable) return;

    try {
      // Background message handler
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // Request notification permissions (iOS & Android 13+)
      final settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      debugPrint('FCM Authorization status: ${settings.authorizationStatus}');

      // Enable foreground display for iOS
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // Listen for token refresh
      _messaging.onTokenRefresh.listen((newToken) {
        _fcmToken = newToken;
        _saveAndSyncToken(newToken);
      });

      // Token retrieval
      try {
        final token = await _messaging.getToken();
        if (token != null) {
          _fcmToken = token;
          await _saveAndSyncToken(token);
        }
      } catch (e) {
        debugPrint('Error retrieving FCM token: $e');
      }

      // Foreground message listener
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint(
          'Foreground notification received: ${message.notification?.title} - ${message.notification?.body}',
        );
      });

      // User tapped notification from background
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('Notification opened app: ${message.data}');
      });

      // Check if opened from terminated state
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        debugPrint('App launched via notification: ${initialMessage.data}');
      }
    } catch (e) {
      debugPrint('Error initializing PushNotificationService: $e');
    }
  }

  /// Saves the FCM token locally and syncs it with the backend if user is authenticated.
  Future<void> _saveAndSyncToken(String token) async {
    try {
      await SharedPrefs.setString('fcm_device_token', token);

      final authToken = SharedPrefs.authToken;
      if (authToken != null && authToken.isNotEmpty) {
        await syncTokenWithBackend(token);
      }
    } catch (e) {
      debugPrint('Error saving/syncing FCM token: $e');
    }
  }

  /// Sends the FCM token to the backend API to associate with the current user.
  Future<void> syncTokenWithBackend(String token) async {
    try {
      await _apiService.post(ApiEndpoints.registerFcmToken, {
        'fcmToken': token,
        'platform': Platform.isIOS ? 'ios' : 'android',
      }, requiresAuth: true);
      debugPrint('FCM Token successfully registered with backend');
    } catch (e) {
      debugPrint('Could not sync FCM token with backend: $e');
    }
  }
}
