import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_wallet/core/constants/api_constants.dart';
import 'package:my_wallet/core/constants/app_constants.dart';
import 'package:my_wallet/core/services/api_service.dart';
import 'package:my_wallet/core/services/wallet_data_sync_service.dart';
import 'package:my_wallet/features/wallet/presentation/screens/subscriptions_tab.dart';

class RecurringBillRepository {
  final ApiService _apiService = ApiService();
  static const String _storageKey = 'user_subscriptions_list';

  bool get _useMock =>
      (AppConstants.useMockBackend || AppConstants.isTestingEnvironment) &&
      !_apiService.hasTestingDio;

  Future<List<SubscriptionItem>> getSubscriptions() async {
    if (_useMock) {
      return _loadLocal();
    }

    try {
      final response = await _apiService.get(
        ApiEndpoints.recurringBills,
        requiresAuth: true,
      );

      final List list = response.data as List;
      final items = list
          .map((e) => SubscriptionItem.fromJson(e as Map<String, dynamic>))
          .toList();
      // The API is authoritative, including when the user has no bills.
      // Keeping an old cache after an empty response resurrects deleted data.
      await _saveLocal(items);
      return items;
    } catch (e) {
      debugPrint('Error getting subscriptions from API: $e. Using local.');
      final local = await _loadLocal();
      return local;
    }
  }

  Future<SubscriptionItem> createSubscription(
    SubscriptionItem item, {
    String currency = 'EGP',
  }) async {
    if (_useMock) {
      final list = await _loadLocal();
      list.add(item);
      await _saveLocal(list);
      WalletDataSyncService.notifyDataChanged();
      return item;
    }

    try {
      final body = {
        'title': item.title,
        'amount': item.amount,
        'billingCycle': item.billingCycle,
        'renewalDay': item.renewalDay,
        'iconCode': item.icon.codePoint,
        'currency': currency,
        'isActive': true,
      };

      final response = await _apiService.post(
        ApiEndpoints.recurringBills,
        body,
        requiresAuth: true,
      );

      final created = SubscriptionItem.fromJson(
        response.data as Map<String, dynamic>,
      );
      final list = await _loadLocal();
      list.removeWhere((existing) => existing.id == created.id);
      list.add(created);
      await _saveLocal(list);
      WalletDataSyncService.notifyDataChanged();
      return created;
    } catch (e) {
      debugPrint('Error creating subscription via API: $e');
      rethrow;
    }
  }

  Future<bool> deleteSubscription(String id) async {
    final intId = int.tryParse(id);
    if (!_useMock && intId != null) {
      try {
        await _apiService.delete(
          '${ApiEndpoints.recurringBills}/$intId',
          requiresAuth: true,
        );
      } catch (e) {
        debugPrint('Error deleting subscription via API: $e');
        rethrow;
      }
    }

    final list = await _loadLocal();
    list.removeWhere((item) => item.id == id);
    await _saveLocal(list);
    WalletDataSyncService.notifyDataChanged();
    return true;
  }

  Future<List<SubscriptionItem>> _loadLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw == null) return [];
      final List list = jsonDecode(raw);
      return list
          .map((e) => SubscriptionItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveLocal(List<SubscriptionItem> items) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _storageKey,
        jsonEncode(items.map((e) => e.toJson()).toList()),
      );
    } catch (_) {}
  }
}
