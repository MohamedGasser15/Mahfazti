// core/utils/shared_prefs.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:my_wallet/core/constants/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  static late SharedPreferences _prefs;
  static const FlutterSecureStorage _secure = FlutterSecureStorage();

  static String? _authToken;
  static String? _userData;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _authToken = await _secure.read(key: AppConstants.authTokenKey);
    _userData = await _secure.read(key: AppConstants.userDataKey);
  }

  // First Time
  static bool get isFirstTime {
    return _prefs.getBool(AppConstants.isFirstTimeKey) ?? true;
  }

  static Future<void> setFirstTime(bool value) async {
    await _prefs.setBool(AppConstants.isFirstTimeKey, value);
  }

  // Auth Token (stored securely)
  static String? get authToken => _authToken;

  static Future<void> setAuthToken(String token) async {
    _authToken = token;
    await _secure.write(key: AppConstants.authTokenKey, value: token);
  }

  static Future<void> removeAuthToken() async {
    _authToken = null;
    await _secure.delete(key: AppConstants.authTokenKey);
  }

  static Future<void> setBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }

  static const String _currencyKey = 'selected_currency';

  static String? get currency => _prefs.getString(_currencyKey);

  static Future<String?> getCurrency() async {
    return _prefs.getString(_currencyKey);
  }

  static Future<void> setCurrency(String currency) async {
    await _prefs.setString(_currencyKey, currency);
  }

  static Future<void> setSecureString(String key, String value) async {
    await _secure.write(key: key, value: value);
  }

  static Future<String?> getSecureString(String key) async {
    return await _secure.read(key: key);
  }

  static Future<void> removeSecureKey(String key) async {
    await _secure.delete(key: key);
  }

  // User Data (stored securely)
  static String? get userData => _userData;

  static Future<String?> getUserData() async => _userData;

  static Future<void> setUserData(String data) async {
    _userData = data;
    await _secure.write(key: AppConstants.userDataKey, value: data);
  }

  static Future<void> removeUserData() async {
    _userData = null;
    await _secure.delete(key: AppConstants.userDataKey);
  }

  // App Language
  static String get appLanguage {
    return _prefs.getString(AppConstants.appLanguageKey) ?? AppConstants.arabic;
  }

  static Future<void> setAppLanguage(String language) async {
    await _prefs.setString(AppConstants.appLanguageKey, language);
  }

  static Future<void> setString(String key, dynamic value) async {
    if (value is String) {
      await _prefs.setString(key, value);
    } else if (value is bool) {
      await _prefs.setBool(key, value);
    }
  }

  static String? getStringValue(String key) {
    return _prefs.getString(key);
  }

  static bool? getBoolValue(String key) {
    return _prefs.getBool(key);
  }

  static Future<void> removeKey(String key) async {
    await _prefs.remove(key);
  }
}