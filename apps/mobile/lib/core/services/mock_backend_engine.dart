import 'dart:convert';
import 'package:my_wallet/core/services/wallet_data_sync_service.dart';
import 'package:my_wallet/core/utils/shared_prefs.dart';
import 'package:my_wallet/features/wallet/data/models/budget_models.dart';
import 'package:my_wallet/features/wallet/data/models/category_model.dart';
import 'package:my_wallet/features/wallet/data/models/wallet_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Single Source of Truth Mock Backend Engine.
///
/// Simulates the ASP.NET Core backend in-memory with SharedPreferences persistence,
/// matching DTO contracts 1:1.
class MockBackendEngine {
  MockBackendEngine._();
  static final MockBackendEngine instance = MockBackendEngine._();

  static const String _transactionsStorageKey = 'mock_backend_transactions_v2';
  static const String _categoriesStorageKey = 'mock_backend_categories_v2';
  static const String _budgetsStorageKey = 'mock_backend_budgets_v2';

  bool _initialized = false;
  final List<WalletTransaction> _transactions = [];
  final List<Category> _categories = [];
  BudgetDto? _budget;

  /// Initialize and load saved state from SharedPreferences or initialize from seed data.
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      await SharedPrefs.setCurrency('EGP');

      // 1. Categories
      final categoriesJson = prefs.getString(_categoriesStorageKey);
      if (categoriesJson != null && categoriesJson.isNotEmpty) {
        final List list = jsonDecode(categoriesJson);
        _categories.clear();
        _categories.addAll(
          list.map((e) => Category.fromJson(e as Map<String, dynamic>)),
        );
      } else {
        _categories.clear();
        _categories.addAll(_getDefaultCategoriesSeed());
        await _saveCategories();
      }

      // 2. Transactions
      final txJson = prefs.getString(_transactionsStorageKey);
      if (txJson != null && txJson.isNotEmpty) {
        final List list = jsonDecode(txJson);
        _transactions.clear();
        _transactions.addAll(
          list.map(
            (e) => WalletTransaction.fromJson(e as Map<String, dynamic>),
          ),
        );
      } else {
        _transactions.clear();
        _transactions.addAll(_getDefaultTransactionsSeed());
        await _saveTransactions();
      }

      // 3. Budgets
      final budgetJson = prefs.getString(_budgetsStorageKey);
      if (budgetJson != null && budgetJson.isNotEmpty) {
        _budget = BudgetDto.fromJson(jsonDecode(budgetJson));
      } else {
        _budget = BudgetDto.defaultSeed();
        await _saveBudgets();
      }
    } catch (_) {
      // Fallback in case of storage read issue
      _categories.clear();
      _categories.addAll(_getDefaultCategoriesSeed());
      _transactions.clear();
      _transactions.addAll(_getDefaultTransactionsSeed());
      _budget = BudgetDto.defaultSeed();
    } finally {
      _initialized = true;
    }
  }

  Future<void> _ensureInitialized() async {
    if (!_initialized) {
      await initialize();
    }
  }

  //#region Storage Helpers
  Future<void> _saveTransactions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(_transactions.map((t) => t.toJson()).toList());
      await prefs.setString(_transactionsStorageKey, encoded);
    } catch (_) {}
  }

  Future<void> _saveCategories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(_categories.map((c) => c.toJson()).toList());
      await prefs.setString(_categoriesStorageKey, encoded);
    } catch (_) {}
  }

  Future<void> _saveBudgets() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_budget != null) {
        await prefs.setString(
          _budgetsStorageKey,
          jsonEncode(_budget!.toJson()),
        );
      }
    } catch (_) {}
  }
  //#endregion

  //#region Wallet & Summary Endpoints
  Future<WalletHomeData> getHomeData() async {
    await _ensureInitialized();

    final balance = await getBalance();
    final sorted = List<WalletTransaction>.from(_transactions)
      ..sort((a, b) => b.transactionDate.compareTo(a.transactionDate));

    return WalletHomeData(
      balance: balance,
      recentTransactions: sorted.take(5).toList(),
      totalTransactionCount: sorted.length,
    );
  }

  Future<WalletBalance> getBalance() async {
    await _ensureInitialized();

    double deposits = 0.0;
    double withdrawals = 0.0;

    for (final tx in _transactions) {
      if (tx.isDeposit) {
        deposits += tx.amount;
      } else if (tx.isWithdrawal) {
        withdrawals += tx.amount;
      }
    }

    return WalletBalance(
      totalBalance: deposits - withdrawals,
      totalDeposits: deposits,
      totalWithdrawals: withdrawals,
    );
  }

  Future<WalletSummary> getSummary({
    required DateTime fromDate,
    required DateTime toDate,
    int? accountId,
  }) async {
    await _ensureInitialized();

    // Inclusive date range comparison
    final periodTx = _transactions.where((t) {
      final d = t.transactionDate;
      return !d.isBefore(fromDate) &&
          !d.isAfter(toDate) &&
          (accountId == null || t.accountId == accountId);
    }).toList();

    double totalIncome = 0.0;
    double totalExpenses = 0.0;
    final Map<int, _CategoryAggregator> expenseCatMap = {};
    final Map<int, _CategoryAggregator> incomeCatMap = {};

    for (final tx in periodTx) {
      final catId = tx.categoryId ?? 0;
      final catNameAr = tx.categoryNameAr ?? 'أخرى';
      final catNameEn = tx.categoryNameEn ?? 'Other';

      if (tx.isDeposit) {
        totalIncome += tx.amount;
        incomeCatMap
            .putIfAbsent(
              catId,
              () => _CategoryAggregator(catId, catNameAr, catNameEn),
            )
            .add(tx.amount);
      } else {
        totalExpenses += tx.amount;
        expenseCatMap
            .putIfAbsent(
              catId,
              () => _CategoryAggregator(catId, catNameAr, catNameEn),
            )
            .add(tx.amount);
      }
    }

    final expensesByCategory =
        expenseCatMap.values.map((agg) => agg.toCategorySummary()).toList()
          ..sort((a, b) => b.total.compareTo(a.total));

    final incomeByCategory =
        incomeCatMap.values.map((agg) => agg.toCategorySummary()).toList()
          ..sort((a, b) => b.total.compareTo(a.total));

    return WalletSummary(
      totalIncome: totalIncome,
      totalExpenses: totalExpenses,
      netSavings: totalIncome - totalExpenses,
      expensesByCategory: expensesByCategory,
      incomeByCategory: incomeByCategory,
      transactionCount: periodTx.length,
    );
  }
  //#endregion

  //#region Transactions CRUD
  Future<TransactionListResponse> getTransactions({
    int page = 1,
    int pageSize = 20,
    DateTime? fromDate,
    DateTime? toDate,
    String? type,
    int? categoryId,
    String? searchQuery,
  }) async {
    await _ensureInitialized();

    var filtered = List<WalletTransaction>.from(_transactions);

    if (fromDate != null) {
      filtered = filtered
          .where((t) => !t.transactionDate.isBefore(fromDate))
          .toList();
    }
    if (toDate != null) {
      filtered = filtered
          .where((t) => !t.transactionDate.isAfter(toDate))
          .toList();
    }
    if (type != null && type.isNotEmpty && type.toLowerCase() != 'all') {
      filtered = filtered
          .where((t) => t.type.toLowerCase() == type.toLowerCase())
          .toList();
    }
    if (categoryId != null) {
      filtered = filtered.where((t) => t.categoryId == categoryId).toList();
    }
    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final q = searchQuery.trim().toLowerCase();
      filtered = filtered.where((t) {
        final title = t.title.toLowerCase();
        final desc = (t.description ?? '').toLowerCase();
        return title.contains(q) || desc.contains(q);
      }).toList();
    }

    // Sort newest first
    filtered.sort((a, b) => b.transactionDate.compareTo(a.transactionDate));

    final totalCount = filtered.length;
    final totalPages = (totalCount / pageSize).ceil();
    final startIndex = (page - 1) * pageSize;
    final pagedTransactions = startIndex < totalCount
        ? filtered.skip(startIndex).take(pageSize).toList()
        : <WalletTransaction>[];

    return TransactionListResponse(
      transactions: pagedTransactions,
      totalCount: totalCount,
      page: page,
      pageSize: pageSize,
      totalPages: totalPages > 0 ? totalPages : 1,
    );
  }

  Future<WalletTransaction> addTransaction({
    String? title,
    String? description,
    required double amount,
    required String type,
    required int categoryId,
    DateTime? transactionDate,
    bool isRecurring = false,
  }) async {
    await _ensureInitialized();

    final nextId = _transactions.isEmpty
        ? 1
        : (_transactions.map((t) => t.id).reduce((a, b) => a > b ? a : b) + 1);

    // Look up category info
    final category = _categories.firstWhere(
      (c) => c.id == categoryId,
      orElse: () => Category(id: categoryId, nameAr: 'أخرى', nameEn: 'Other'),
    );

    final newTx = WalletTransaction(
      id: nextId,
      title: title ?? (description ?? category.nameAr),
      description: description,
      amount: amount,
      transactionDate: transactionDate ?? DateTime.now(),
      type: type,
      categoryId: categoryId,
      categoryNameAr: category.nameAr,
      categoryNameEn: category.nameEn,
      isRecurring: isRecurring,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _transactions.insert(0, newTx);
    await _saveTransactions();
    WalletDataSyncService.notifyDataChanged();

    return newTx;
  }

  Future<WalletTransaction> updateTransaction({
    required int id,
    String? title,
    String? description,
    double? amount,
    String? type,
    int? categoryId,
    DateTime? transactionDate,
  }) async {
    await _ensureInitialized();

    final index = _transactions.indexWhere((t) => t.id == id);
    if (index == -1) {
      throw Exception('Transaction not found');
    }

    final old = _transactions[index];
    final updatedCatId = categoryId ?? old.categoryId ?? 1;
    final category = _categories.firstWhere(
      (c) => c.id == updatedCatId,
      orElse: () => Category(
        id: updatedCatId,
        nameAr: old.categoryNameAr ?? 'أخرى',
        nameEn: old.categoryNameEn ?? 'Other',
      ),
    );

    final updated = WalletTransaction(
      id: old.id,
      userId: old.userId,
      title: title ?? old.title,
      description: description ?? old.description,
      amount: amount ?? old.amount,
      transactionDate: transactionDate ?? old.transactionDate,
      type: type ?? old.type,
      categoryId: updatedCatId,
      categoryNameAr: category.nameAr,
      categoryNameEn: category.nameEn,
      isRecurring: old.isRecurring,
      createdAt: old.createdAt,
      updatedAt: DateTime.now(),
    );

    _transactions[index] = updated;
    await _saveTransactions();
    WalletDataSyncService.notifyDataChanged();

    return updated;
  }

  Future<bool> deleteTransaction(int id) async {
    await _ensureInitialized();

    final countBefore = _transactions.length;
    _transactions.removeWhere((t) => t.id == id);
    final removed = _transactions.length < countBefore;
    if (removed) {
      await _saveTransactions();
      WalletDataSyncService.notifyDataChanged();
    }
    return removed;
  }
  //#endregion

  //#region Categories CRUD
  Future<List<Category>> getCategories() async {
    await _ensureInitialized();
    return List<Category>.unmodifiable(_categories);
  }

  Future<Category> createCategory(String nameAr, String nameEn) async {
    await _ensureInitialized();

    final nextId = _categories.isEmpty
        ? 1
        : (_categories.map((c) => c.id).reduce((a, b) => a > b ? a : b) + 1);
    final newCat = Category(
      id: nextId,
      nameAr: nameAr,
      nameEn: nameEn,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _categories.add(newCat);
    await _saveCategories();
    WalletDataSyncService.notifyDataChanged();

    return newCat;
  }

  Future<Category> updateCategory(int id, String nameAr, String nameEn) async {
    await _ensureInitialized();

    final index = _categories.indexWhere((c) => c.id == id);
    if (index == -1) {
      throw Exception('Category not found');
    }

    final updated = Category(
      id: id,
      nameAr: nameAr,
      nameEn: nameEn,
      createdAt: _categories[index].createdAt,
      updatedAt: DateTime.now(),
    );

    _categories[index] = updated;

    // Update denormalized category names on transactions
    for (int i = 0; i < _transactions.length; i++) {
      if (_transactions[i].categoryId == id) {
        _transactions[i] = WalletTransaction(
          id: _transactions[i].id,
          userId: _transactions[i].userId,
          title: _transactions[i].title,
          description: _transactions[i].description,
          amount: _transactions[i].amount,
          transactionDate: _transactions[i].transactionDate,
          type: _transactions[i].type,
          categoryId: id,
          categoryNameAr: nameAr,
          categoryNameEn: nameEn,
          isRecurring: _transactions[i].isRecurring,
          createdAt: _transactions[i].createdAt,
          updatedAt: _transactions[i].updatedAt,
        );
      }
    }

    await _saveCategories();
    await _saveTransactions();
    WalletDataSyncService.notifyDataChanged();

    return updated;
  }

  Future<void> deleteCategory(int id) async {
    await _ensureInitialized();

    _categories.removeWhere((c) => c.id == id);
    await _saveCategories();
    WalletDataSyncService.notifyDataChanged();
  }
  //#endregion

  //#region Budgets
  Future<BudgetDto> getBudget() async {
    await _ensureInitialized();
    return _budget ?? BudgetDto.defaultSeed();
  }

  Future<void> updateMonthlyBudget(double monthlyBudget) async {
    await _ensureInitialized();
    _budget ??= BudgetDto.defaultSeed();
    _budget = _budget!.copyWith(monthlyBudget: monthlyBudget);
    await _saveBudgets();
    WalletDataSyncService.notifyDataChanged();
  }

  Future<void> updateCategoryBudget(int categoryId, double budget) async {
    await _ensureInitialized();
    _budget ??= BudgetDto.defaultSeed();

    final updatedList = _budget!.categoryBudgets.map((b) {
      if (b.categoryId == categoryId) {
        return CategoryBudgetDto(
          id: b.id,
          categoryId: b.categoryId,
          categoryNameAr: b.categoryNameAr,
          categoryNameEn: b.categoryNameEn,
          budget: budget,
          spent: b.spent,
        );
      }
      return b;
    }).toList();

    _budget = _budget!.copyWith(categoryBudgets: updatedList);
    await _saveBudgets();
    WalletDataSyncService.notifyDataChanged();
  }
  //#endregion

  //#region Default Realistic EGP Seed Data
  static List<Category> _getDefaultCategoriesSeed() {
    return [
      Category(id: 1, nameAr: 'طعام ومطاعم', nameEn: 'Food & Dining'),
      Category(id: 2, nameAr: 'تسوق ومستلزمات', nameEn: 'Shopping'),
      Category(id: 3, nameAr: 'تعليم وتطوير', nameEn: 'Education'),
      Category(id: 4, nameAr: 'مصاريف سيارة', nameEn: 'Car Things'),
      Category(id: 5, nameAr: 'كهرباء وفواتير', nameEn: 'Electricity & Bills'),
      Category(id: 6, nameAr: 'مواصلات', nameEn: 'Transportation'),
      Category(id: 7, nameAr: 'بنزين ووقود', nameEn: 'Fuel'),
      Category(id: 8, nameAr: 'ترفيه واشتراكات', nameEn: 'Entertainment'),
      Category(id: 9, nameAr: 'صحة وعناية', nameEn: 'Health & Medical'),
      Category(id: 10, nameAr: 'أخرى ومتنوعات', nameEn: 'Other'),
      Category(id: 11, nameAr: 'خدمات إلكترونية', nameEn: 'Digital Services'),
      Category(id: 12, nameAr: 'راتب ودخل', nameEn: 'Salary & Income'),
    ];
  }

  static List<WalletTransaction> _getDefaultTransactionsSeed() {
    return const <WalletTransaction>[];
  }
  //#endregion
}

class _CategoryAggregator {
  final int categoryId;
  final String categoryNameAr;
  final String categoryNameEn;
  double total = 0.0;
  int count = 0;

  _CategoryAggregator(
    this.categoryId,
    this.categoryNameAr,
    this.categoryNameEn,
  );

  void add(double amount) {
    total += amount;
    count += 1;
  }

  CategorySummary toCategorySummary() {
    return CategorySummary(
      categoryId: categoryId,
      categoryNameAr: categoryNameAr,
      categoryNameEn: categoryNameEn,
      total: total,
      count: count,
    );
  }
}
