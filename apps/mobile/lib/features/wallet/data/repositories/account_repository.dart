import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_wallet/core/constants/api_constants.dart';
import 'package:my_wallet/core/constants/app_constants.dart';
import 'package:my_wallet/core/services/api_service.dart';
import 'package:my_wallet/core/services/wallet_data_sync_service.dart';
import 'package:my_wallet/core/utils/api_error_handler.dart';
import 'package:my_wallet/features/wallet/presentation/widgets/home_tab_models.dart';

class AccountRepository {
  final ApiService _apiService = ApiService();

  static const String _customAccountsStorageKey = 'wallet_custom_accounts';

  bool get _useMock =>
      (AppConstants.useMockBackend || AppConstants.isTestingEnvironment) &&
      !_apiService.hasTestingDio;

  Future<List<AccountItem>> getAccounts() async {
    if (_useMock) {
      return _loadLocalAccounts();
    }

    try {
      final response = await _apiService.get(
        ApiEndpoints.accounts,
        requiresAuth: true,
      );

      final dynamic raw = response.data;
      final List list = raw is List
          ? raw
          : (raw is Map && raw['data'] is List
                ? raw['data']
                : (raw is Map && raw['accounts'] is List
                      ? raw['accounts']
                      : []));
      final accounts = list
          .map((e) => AccountItem.fromJson(e as Map<String, dynamic>))
          .toList();

      // Save locally as cache for offline mode
      await _cacheLocalAccounts(accounts);
      return accounts;
    } on DioException catch (e) {
      debugPrint(
        'Error getting accounts from API: ${e.message}. Using cache fallback.',
      );
      final local = await _loadLocalAccounts();
      if (local.isNotEmpty) return local;
      throw Exception(ApiErrorHandler.getErrorMessage(e));
    } catch (e) {
      debugPrint('Fallback to local accounts: $e');
      return _loadLocalAccounts();
    }
  }

  Future<AccountItem> createAccount(AccountItem account) async {
    if (_useMock) {
      final list = await _loadLocalAccounts();
      final makeMain = list.isEmpty || account.isMain;
      final normalized = makeMain ? account.copyWith(isMain: true) : account;
      if (makeMain) {
        for (var i = 0; i < list.length; i++) {
          list[i] = list[i].copyWith(isMain: false);
        }
      }
      list.add(normalized);
      await _cacheLocalAccounts(list);
      WalletDataSyncService.notifyDataChanged();
      return normalized;
    }

    try {
      final body = <String, dynamic>{
        'name': account.name,
        'type': account.type,
        'currency': account.currency,
        'balance': account.balance,
        'institutionId': account.provider,
        'accountNumber': account.accountNumber,
        'iconCode': account.icon.codePoint,
        'isMain': account.isMain,
        'excludeFromTotal': account.excludeFromTotal,
        'notificationMethod': account.notificationMethod,
        'cardNumbersJson': account.cardNumbers != null
            ? jsonEncode(account.cardNumbers)
            : null,
        'receiveAtmWithdrawals': account.receiveAtmWithdrawals,
        'creditLimit': account.creditLimit,
        'billingDay': account.billingDay,
        'dueDay': account.dueDay,
        'minPaymentPercentage': account.minPaymentPercentage,
        'autoAddInstapayFee': account.autoAddInstapayFee,
        'metalKarat': account.metalKarat,
        'metalWeightGrams': account.metalWeightGrams,
        'metalPurchasePricePerGram': account.metalPurchasePricePerGram,
        'metalPurchaseDate': account.metalPurchaseDate?.toIso8601String(),
        'autoUpdateMetalPrice': account.autoUpdateMetalPrice,
        'propertyCategory': account.propertyCategory,
        'investmentPlatform': account.investmentPlatform,
        'totalInvestedAmount': account.totalInvestedAmount,
        'annualYieldRate': account.annualYieldRate,
        'autoEstimateValue': account.autoEstimateValue,
        'note': account.note,
      };

      final response = await _apiService.post(
        ApiEndpoints.accounts,
        body,
        requiresAuth: true,
      );

      final created = AccountItem.fromJson(
        response.data as Map<String, dynamic>,
      );

      // Update local cache
      final list = await _loadLocalAccounts();
      if (created.isMain) {
        for (var i = 0; i < list.length; i++) {
          list[i] = list[i].copyWith(isMain: false);
        }
      }
      list.add(created);
      await _cacheLocalAccounts(list);

      WalletDataSyncService.notifyDataChanged();
      return created;
    } on DioException catch (e) {
      throw Exception(ApiErrorHandler.getErrorMessage(e));
    } catch (e) {
      throw Exception('Failed to create account: $e');
    }
  }

  Future<AccountItem> updateAccount(AccountItem account) async {
    final intId = int.tryParse(account.id);
    if (_useMock || intId == null) {
      final list = await _loadLocalAccounts();
      final wasMain = list.any((item) => item.id == account.id && item.isMain);
      final saved = account.copyWith(isMain: account.isMain || wasMain);
      if (saved.isMain) {
        for (var i = 0; i < list.length; i++) {
          if (list[i].id != saved.id) {
            list[i] = list[i].copyWith(isMain: false);
          }
        }
      }
      final idx = list.indexWhere((a) => a.id == saved.id);
      if (idx >= 0) {
        list[idx] = saved;
        await _cacheLocalAccounts(list);
      }
      WalletDataSyncService.notifyDataChanged();
      return saved;
    }

    try {
      final body = <String, dynamic>{
        'name': account.name,
        'type': account.type,
        'currency': account.currency,
        'balance': account.balance,
        'institutionId': account.provider,
        'accountNumber': account.accountNumber,
        'iconCode': account.icon.codePoint,
        'isMain': account.isMain,
        'excludeFromTotal': account.excludeFromTotal,
        'notificationMethod': account.notificationMethod,
        'cardNumbersJson': account.cardNumbers != null
            ? jsonEncode(account.cardNumbers)
            : null,
        'receiveAtmWithdrawals': account.receiveAtmWithdrawals,
        'creditLimit': account.creditLimit,
        'billingDay': account.billingDay,
        'dueDay': account.dueDay,
        'minPaymentPercentage': account.minPaymentPercentage,
        'autoAddInstapayFee': account.autoAddInstapayFee,
        'metalKarat': account.metalKarat,
        'metalWeightGrams': account.metalWeightGrams,
        'metalPurchasePricePerGram': account.metalPurchasePricePerGram,
        'metalPurchaseDate': account.metalPurchaseDate?.toIso8601String(),
        'autoUpdateMetalPrice': account.autoUpdateMetalPrice,
        'propertyCategory': account.propertyCategory,
        'investmentPlatform': account.investmentPlatform,
        'totalInvestedAmount': account.totalInvestedAmount,
        'annualYieldRate': account.annualYieldRate,
        'autoEstimateValue': account.autoEstimateValue,
        'note': account.note,
      };

      final response = await _apiService.put(
        '${ApiEndpoints.accounts}/$intId',
        body,
        requiresAuth: true,
      );

      final updated = AccountItem.fromJson(
        response.data as Map<String, dynamic>,
      );

      final list = await _loadLocalAccounts();
      if (updated.isMain) {
        for (var i = 0; i < list.length; i++) {
          if (list[i].id != updated.id) {
            list[i] = list[i].copyWith(isMain: false);
          }
        }
      }
      final idx = list.indexWhere((a) => a.id == account.id);
      if (idx >= 0) {
        list[idx] = updated;
        await _cacheLocalAccounts(list);
      }

      WalletDataSyncService.notifyDataChanged();
      return updated;
    } on DioException catch (e) {
      throw Exception(ApiErrorHandler.getErrorMessage(e));
    } catch (e) {
      throw Exception('Failed to update account: $e');
    }
  }

  Future<bool> deleteAccount(String id) async {
    final intId = int.tryParse(id);
    if (_useMock || intId == null) {
      final list = await _loadLocalAccounts();
      if (list.any((account) => account.id == id && account.isMain)) {
        throw Exception('The default account cannot be deleted.');
      }
      list.removeWhere((a) => a.id == id);
      await _cacheLocalAccounts(list);
      WalletDataSyncService.notifyDataChanged();
      return true;
    }

    try {
      final cachedAccounts = await _loadLocalAccounts();
      if (cachedAccounts.any((account) => account.id == id && account.isMain)) {
        throw Exception('The default account cannot be deleted.');
      }
      await _apiService.delete(
        '${ApiEndpoints.accounts}/$intId',
        requiresAuth: true,
      );

      final list = await _loadLocalAccounts();
      list.removeWhere((a) => a.id == id);
      await _cacheLocalAccounts(list);

      WalletDataSyncService.notifyDataChanged();
      return true;
    } on DioException catch (e) {
      throw Exception(ApiErrorHandler.getErrorMessage(e));
    } catch (e) {
      throw Exception('Failed to delete account: $e');
    }
  }

  Future<List<AccountItem>> _loadLocalAccounts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final str = prefs.getString(_customAccountsStorageKey);
      if (str == null || str.isEmpty) return [];
      final List list = jsonDecode(str);
      var accounts = list
          .map((e) => AccountItem.fromJson(e as Map<String, dynamic>))
          .toList();
      final needsMainNameUpdate = accounts.any(
        (account) => account.isMain && account.name == 'كاش البيت',
      );
      if (needsMainNameUpdate) {
        accounts = accounts
            .map(
              (account) => account.isMain && account.name == 'كاش البيت'
                  ? account.copyWith(name: 'الحساب الرئيسي')
                  : account,
            )
            .toList();
        await _cacheLocalAccounts(accounts);
      }
      return accounts;
    } catch (_) {
      return [];
    }
  }

  Future<void> _cacheLocalAccounts(List<AccountItem> accounts) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _customAccountsStorageKey,
        jsonEncode(accounts.map((a) => a.toJson()).toList()),
      );
    } catch (_) {}
  }
}
