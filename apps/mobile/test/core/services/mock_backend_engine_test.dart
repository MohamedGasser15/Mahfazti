import 'package:flutter_test/flutter_test.dart';
import 'package:my_wallet/core/services/mock_backend_engine.dart';
import 'package:my_wallet/core/services/wallet_data_sync_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  group('MockBackendEngine', () {
    test('initializes with seed data and verifies calculations', () async {
      final engine = MockBackendEngine.instance;
      await engine.initialize();

      final homeData = await engine.getHomeData();
      expect(homeData.recentTransactions.isNotEmpty, isTrue);
      expect(homeData.totalTransactionCount, greaterThan(0));

      final balance = await engine.getBalance();
      expect(balance.totalDeposits, greaterThan(0));
      expect(balance.totalWithdrawals, greaterThan(0));
      expect(balance.totalBalance, equals(balance.totalDeposits - balance.totalWithdrawals));
    });

    test('getSummary returns accurate month breakdown for October 2026', () async {
      final engine = MockBackendEngine.instance;
      await engine.initialize();

      final octSummary = await engine.getSummary(
        fromDate: DateTime(2026, 10, 1),
        toDate: DateTime(2026, 10, 31, 23, 59, 59),
      );

      expect(octSummary.totalIncome, greaterThan(0));
      expect(octSummary.totalExpenses, greaterThan(0));
      expect(octSummary.expensesByCategory.isNotEmpty, isTrue);

      final totalFromCategories = octSummary.expensesByCategory.fold<double>(
        0.0,
        (sum, item) => sum + item.total,
      );
      expect(totalFromCategories, closeTo(octSummary.totalExpenses, 0.01));
    });

    test('addTransaction, updateTransaction, and deleteTransaction trigger WalletDataSyncService', () async {
      final engine = MockBackendEngine.instance;
      await engine.initialize();

      int syncEventCount = 0;
      final sub = WalletDataSyncService.onDataChanged.listen((_) {
        syncEventCount++;
      });

      // 1. Add Transaction
      final added = await engine.addTransaction(
        title: 'تجربة قهوة سبيشالتي',
        amount: 150.0,
        type: 'Withdrawal',
        categoryId: 1,
        transactionDate: DateTime(2026, 10, 29),
      );
      await Future<void>.delayed(Duration.zero);

      expect(added.id, greaterThan(0));
      expect(added.amount, 150.0);
      expect(syncEventCount, 1);

      // 2. Update Transaction
      final updated = await engine.updateTransaction(
        id: added.id,
        amount: 180.0,
        title: 'تجربة قهوة معدلة',
      );
      await Future<void>.delayed(Duration.zero);

      expect(updated.amount, 180.0);
      expect(syncEventCount, 2);

      // 3. Delete Transaction
      final deleted = await engine.deleteTransaction(added.id);
      await Future<void>.delayed(Duration.zero);
      expect(deleted, isTrue);
      expect(syncEventCount, 3);

      await sub.cancel();
    });

    test('Category CRUD operations work and trigger sync notifications', () async {
      final engine = MockBackendEngine.instance;
      await engine.initialize();

      int syncEventCount = 0;
      final sub = WalletDataSyncService.onDataChanged.listen((_) {
        syncEventCount++;
      });

      // 1. Create Category
      final cat = await engine.createCategory('كتب وقراءة', 'Books');
      await Future<void>.delayed(Duration.zero);
      expect(cat.id, greaterThan(0));
      expect(cat.nameAr, 'كتب وقراءة');
      expect(syncEventCount, 1);

      // 2. Update Category
      final updatedCat = await engine.updateCategory(cat.id, 'مكتبة وكتب', 'Library');
      await Future<void>.delayed(Duration.zero);
      expect(updatedCat.nameAr, 'مكتبة وكتب');
      expect(syncEventCount, 2);

      // 3. Delete Category
      await engine.deleteCategory(cat.id);
      await Future<void>.delayed(Duration.zero);
      expect(syncEventCount, 3);

      final allCats = await engine.getCategories();
      expect(allCats.any((c) => c.id == cat.id), isFalse);

      await sub.cancel();
    });
  });
}
