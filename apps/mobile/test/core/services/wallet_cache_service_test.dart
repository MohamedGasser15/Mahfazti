import 'package:flutter_test/flutter_test.dart';
import 'package:my_wallet/core/services/wallet_cache_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('WalletCacheService', () {
    final testData = {'key': 'value', 'number': 42};

    group('summary', () {
      test('getSummary returns null when no cache exists', () async {
        final result = await WalletCacheService.getSummary();
        expect(result, isNull);
      });

      test('saveSummary and getSummary round-trip', () async {
        await WalletCacheService.saveSummary(testData);
        final result = await WalletCacheService.getSummary();
        expect(result, testData);
      });
    });

    group('home', () {
      test('getHome returns null when no cache exists', () async {
        final result = await WalletCacheService.getHome();
        expect(result, isNull);
      });

      test('saveHome and getHome round-trip', () async {
        await WalletCacheService.saveHome(testData);
        final result = await WalletCacheService.getHome();
        expect(result, testData);
      });
    });

    group('budget', () {
      test('getBudget returns null when no cache exists', () async {
        final result = await WalletCacheService.getBudget();
        expect(result, isNull);
      });

      test('saveBudget and getBudget round-trip', () async {
        await WalletCacheService.saveBudget(testData);
        final result = await WalletCacheService.getBudget();
        expect(result, testData);
      });
    });

    group('transactions', () {
      test('getTransactions returns null when no cache exists', () async {
        final result = await WalletCacheService.getTransactions();
        expect(result, isNull);
      });

      test('saveTransactions and getTransactions round-trip', () async {
        await WalletCacheService.saveTransactions(testData);
        final result = await WalletCacheService.getTransactions();
        expect(result, testData);
      });

      test('saveTransactions with filterKey and getTransactions with filterKey',
          () async {
        await WalletCacheService.saveTransactions(
          testData,
          filterKey: 'cache_transactions_monthly',
        );
        final result = await WalletCacheService.getTransactions(
          filterKey: 'cache_transactions_monthly',
        );
        expect(result, testData);
      });

      test(
          'transactions with different filterKeys do not overwrite each other',
          () async {
        await WalletCacheService.saveTransactions(
          {'data': 'monthly'},
          filterKey: 'cache_transactions_monthly',
        );
        await WalletCacheService.saveTransactions(
          {'data': 'yearly'},
          filterKey: 'cache_transactions_yearly',
        );
        final monthly = await WalletCacheService.getTransactions(
          filterKey: 'cache_transactions_monthly',
        );
        final yearly = await WalletCacheService.getTransactions(
          filterKey: 'cache_transactions_yearly',
        );
        expect(monthly, {'data': 'monthly'});
        expect(yearly, {'data': 'yearly'});
      });
    });

    group('insightsCurrent', () {
      test('getInsightsCurrent returns null when no cache exists', () async {
        final result = await WalletCacheService.getInsightsCurrent();
        expect(result, isNull);
      });

      test('saveInsightsCurrent and getInsightsCurrent round-trip', () async {
        await WalletCacheService.saveInsightsCurrent(testData);
        final result = await WalletCacheService.getInsightsCurrent();
        expect(result, testData);
      });
    });

    group('insightsLast', () {
      test('getInsightsLast returns null when no cache exists', () async {
        final result = await WalletCacheService.getInsightsLast();
        expect(result, isNull);
      });

      test('saveInsightsLast and getInsightsLast round-trip', () async {
        await WalletCacheService.saveInsightsLast(testData);
        final result = await WalletCacheService.getInsightsLast();
        expect(result, testData);
      });
    });

    group('invalidate', () {
      test('invalidateAll clears all caches', () async {
        await WalletCacheService.saveSummary(testData);
        await WalletCacheService.saveHome(testData);
        await WalletCacheService.saveBudget(testData);
        await WalletCacheService.saveTransactions(testData);
        await WalletCacheService.saveInsightsCurrent(testData);
        await WalletCacheService.saveInsightsLast(testData);
        await WalletCacheService.invalidateAll();
        expect(await WalletCacheService.getSummary(), isNull);
        expect(await WalletCacheService.getHome(), isNull);
        expect(await WalletCacheService.getBudget(), isNull);
        expect(await WalletCacheService.getTransactions(), isNull);
        expect(await WalletCacheService.getInsightsCurrent(), isNull);
        expect(await WalletCacheService.getInsightsLast(), isNull);
      });

      test('invalidateSummary clears only summary', () async {
        await WalletCacheService.saveSummary(testData);
        await WalletCacheService.saveHome(testData);
        await WalletCacheService.invalidateSummary();
        expect(await WalletCacheService.getSummary(), isNull);
        expect(await WalletCacheService.getHome(), isNotNull);
      });

      test('invalidateHome clears only home', () async {
        await WalletCacheService.saveHome(testData);
        await WalletCacheService.saveBudget(testData);
        await WalletCacheService.invalidateHome();
        expect(await WalletCacheService.getHome(), isNull);
        expect(await WalletCacheService.getBudget(), isNotNull);
      });

      test('invalidateInsights clears only insights', () async {
        await WalletCacheService.saveInsightsCurrent(testData);
        await WalletCacheService.saveInsightsLast(testData);
        await WalletCacheService.saveSummary(testData);
        await WalletCacheService.invalidateInsights();
        expect(await WalletCacheService.getInsightsCurrent(), isNull);
        expect(await WalletCacheService.getInsightsLast(), isNull);
        expect(await WalletCacheService.getSummary(), isNotNull);
      });
    });
  });
}
