import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class WalletCacheService {
  static const String _summaryKey = 'cache_summary';
  static const String _homeKey = 'cache_home';
  static const String _budgetKey = 'cache_budget';
  static const String _transactionsKey = 'cache_transactions';

  // ===================== SAVE =====================
  static Future<void> saveSummary(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_summaryKey, jsonEncode(data));
  }

  static Future<void> saveHome(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_homeKey, jsonEncode(data));
  }

  static Future<void> saveBudget(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_budgetKey, jsonEncode(data));
  }

static Future<void> saveTransactions(Map<String, dynamic> data, {String? filterKey}) async {
  final prefs = await SharedPreferences.getInstance();
  final key = filterKey ?? _transactionsKey;
  await prefs.setString(key, jsonEncode(data));
}

  // ===================== GET =====================
  static Future<Map<String, dynamic>?> getSummary() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_summaryKey);
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>?> getHome() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_homeKey);
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>?> getBudget() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_budgetKey);
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

static Future<Map<String, dynamic>?> getTransactions({String? filterKey}) async {
  final prefs = await SharedPreferences.getInstance();
  final key = filterKey ?? _transactionsKey;
  final raw = prefs.getString(key);
  if (raw == null) return null;
  return jsonDecode(raw) as Map<String, dynamic>;
}

  // ===================== INVALIDATE =====================
  // بنستدعيها بعد أي write operation (add/edit/delete transaction, update budget)
  static Future<void> invalidateAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_summaryKey);
    await prefs.remove(_homeKey);
    await prefs.remove(_budgetKey);
    await prefs.remove(_transactionsKey);
  }

  static Future<void> invalidateSummary() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_summaryKey);
  }

  static Future<void> invalidateHome() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_homeKey);
  }
}