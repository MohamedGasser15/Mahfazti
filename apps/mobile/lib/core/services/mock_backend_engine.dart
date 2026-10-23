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
        _categories.addAll(list.map((e) => Category.fromJson(e as Map<String, dynamic>)));
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
        _transactions.addAll(list.map((e) => WalletTransaction.fromJson(e as Map<String, dynamic>)));
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
        await prefs.setString(_budgetsStorageKey, jsonEncode(_budget!.toJson()));
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
  }) async {
    await _ensureInitialized();

    // Inclusive date range comparison
    final periodTx = _transactions.where((t) {
      final d = t.transactionDate;
      return !d.isBefore(fromDate) && !d.isAfter(toDate);
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
        incomeCatMap.putIfAbsent(catId, () => _CategoryAggregator(catId, catNameAr, catNameEn)).add(tx.amount);
      } else {
        totalExpenses += tx.amount;
        expenseCatMap.putIfAbsent(catId, () => _CategoryAggregator(catId, catNameAr, catNameEn)).add(tx.amount);
      }
    }

    final expensesByCategory = expenseCatMap.values.map((agg) => agg.toCategorySummary()).toList()
      ..sort((a, b) => b.total.compareTo(a.total));

    final incomeByCategory = incomeCatMap.values.map((agg) => agg.toCategorySummary()).toList()
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
      filtered = filtered.where((t) => !t.transactionDate.isBefore(fromDate)).toList();
    }
    if (toDate != null) {
      filtered = filtered.where((t) => !t.transactionDate.isAfter(toDate)).toList();
    }
    if (type != null && type.isNotEmpty && type.toLowerCase() != 'all') {
      filtered = filtered.where((t) => t.type.toLowerCase() == type.toLowerCase()).toList();
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

    final nextId = _transactions.isEmpty ? 1 : (_transactions.map((t) => t.id).reduce((a, b) => a > b ? a : b) + 1);

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
      orElse: () => Category(id: updatedCatId, nameAr: old.categoryNameAr ?? 'أخرى', nameEn: old.categoryNameEn ?? 'Other'),
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

    final nextId = _categories.isEmpty ? 1 : (_categories.map((c) => c.id).reduce((a, b) => a > b ? a : b) + 1);
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
    return [
      // -------------------------------------------------------------
      // OCTOBER 2026 (Current Month)
      // -------------------------------------------------------------
      // Income (Deposit)
      WalletTransaction(
        id: 1001,
        title: 'راتب شهر أكتوبر',
        description: 'تحويل بنكي - راتب العمل الشهري',
        amount: 45000.0,
        transactionDate: DateTime(2026, 10, 1, 9, 0),
        type: 'Deposit',
        categoryId: 12,
        categoryNameAr: 'راتب ودخل',
        categoryNameEn: 'Salary & Income',
      ),
      // Shopping
      WalletTransaction(
        id: 1002,
        title: 'كارفور هايبر ماركت',
        description: 'مستلزمات منزل وأغذية شهرية',
        amount: 3200.0,
        transactionDate: DateTime(2026, 10, 27, 16, 30),
        type: 'Withdrawal',
        categoryId: 2,
        categoryNameAr: 'تسوق ومستلزمات',
        categoryNameEn: 'Shopping',
      ),
      WalletTransaction(
        id: 1003,
        title: 'أمازون مصر',
        description: 'شراء ملابس واحتياجات شخصية',
        amount: 2150.0,
        transactionDate: DateTime(2026, 10, 22, 14, 0),
        type: 'Withdrawal',
        categoryId: 2,
        categoryNameAr: 'تسوق ومستلزمات',
        categoryNameEn: 'Shopping',
      ),
      WalletTransaction(
        id: 1004,
        title: 'شراء عطور وهدايا',
        description: 'مول العرب',
        amount: 1045.0,
        transactionDate: DateTime(2026, 10, 15, 19, 0),
        type: 'Withdrawal',
        categoryId: 2,
        categoryNameAr: 'تسوق ومستلزمات',
        categoryNameEn: 'Shopping',
      ),
      // Food & Dining
      WalletTransaction(
        id: 1005,
        title: 'مطعم كرم الشام',
        description: 'غداء مع الأصدقاء',
        amount: 1250.0,
        transactionDate: DateTime(2026, 10, 26, 15, 30),
        type: 'Withdrawal',
        categoryId: 1,
        categoryNameAr: 'طعام ومطاعم',
        categoryNameEn: 'Food & Dining',
      ),
      WalletTransaction(
        id: 1006,
        title: 'ستاربكس كافيه',
        description: 'قهوة وكرواسون',
        amount: 280.0,
        transactionDate: DateTime(2026, 10, 21, 10, 15),
        type: 'Withdrawal',
        categoryId: 1,
        categoryNameAr: 'طعام ومطاعم',
        categoryNameEn: 'Food & Dining',
      ),
      WalletTransaction(
        id: 1007,
        title: 'بيتزا هت',
        description: 'عشاء عائلي',
        amount: 860.0,
        transactionDate: DateTime(2026, 10, 14, 20, 45),
        type: 'Withdrawal',
        categoryId: 1,
        categoryNameAr: 'طعام ومطاعم',
        categoryNameEn: 'Food & Dining',
      ),
      WalletTransaction(
        id: 1008,
        title: 'بافلو برجر',
        description: 'ساندوتشات وبطاطس',
        amount: 750.0,
        transactionDate: DateTime(2026, 10, 8, 18, 0),
        type: 'Withdrawal',
        categoryId: 1,
        categoryNameAr: 'طعام ومطاعم',
        categoryNameEn: 'Food & Dining',
      ),
      // Education
      WalletTransaction(
        id: 1009,
        title: 'دورة برمجة متقدمة',
        description: 'اشتراك منصة تعليمية',
        amount: 2200.0,
        transactionDate: DateTime(2026, 10, 19, 12, 0),
        type: 'Withdrawal',
        categoryId: 3,
        categoryNameAr: 'تعليم وتطوير',
        categoryNameEn: 'Education',
      ),
      WalletTransaction(
        id: 1010,
        title: 'كتب ومراجع',
        description: 'مكتبة الشروق',
        amount: 900.0,
        transactionDate: DateTime(2026, 10, 11, 16, 20),
        type: 'Withdrawal',
        categoryId: 3,
        categoryNameAr: 'تعليم وتطوير',
        categoryNameEn: 'Education',
      ),
      // Car Things
      WalletTransaction(
        id: 1011,
        title: 'صيانة وتغيير زيت',
        description: 'مركز صيانة غبور',
        amount: 1600.0,
        transactionDate: DateTime(2026, 10, 23, 11, 0),
        type: 'Withdrawal',
        categoryId: 4,
        categoryNameAr: 'مصاريف سيارة',
        categoryNameEn: 'Car Things',
      ),
      WalletTransaction(
        id: 1012,
        title: 'غسيل وتلميع سيارة',
        description: 'محطة وطنية',
        amount: 400.0,
        transactionDate: DateTime(2026, 10, 16, 13, 0),
        type: 'Withdrawal',
        categoryId: 4,
        categoryNameAr: 'مصاريف سيارة',
        categoryNameEn: 'Car Things',
      ),
      // Electricity & Bills
      WalletTransaction(
        id: 1013,
        title: 'فاتورة الكهرباء',
        description: 'شحن عداد كارت كهرباء',
        amount: 650.0,
        transactionDate: DateTime(2026, 10, 20, 17, 0),
        type: 'Withdrawal',
        categoryId: 5,
        categoryNameAr: 'كهرباء وفواتير',
        categoryNameEn: 'Electricity & Bills',
      ),
      WalletTransaction(
        id: 1014,
        title: 'فاتورة إنترنت WE المنزلي',
        description: 'باقة فايبر 300 ميجا',
        amount: 400.0,
        transactionDate: DateTime(2026, 10, 5, 12, 0),
        type: 'Withdrawal',
        categoryId: 5,
        categoryNameAr: 'كهرباء وفواتير',
        categoryNameEn: 'Electricity & Bills',
      ),
      // Transportation
      WalletTransaction(
        id: 1015,
        title: 'مشوار أوبر',
        description: 'توصيل التجمع الخامس',
        amount: 420.0,
        transactionDate: DateTime(2026, 10, 25, 9, 30),
        type: 'Withdrawal',
        categoryId: 6,
        categoryNameAr: 'مواصلات',
        categoryNameEn: 'Transportation',
      ),
      WalletTransaction(
        id: 1016,
        title: 'مشاوير كريم',
        description: 'تنقلات عمل',
        amount: 300.0,
        transactionDate: DateTime(2026, 10, 12, 14, 0),
        type: 'Withdrawal',
        categoryId: 6,
        categoryNameAr: 'مواصلات',
        categoryNameEn: 'Transportation',
      ),
      // Fuel
      WalletTransaction(
        id: 1017,
        title: 'بنزين 95',
        description: 'محطة تشيل آوت',
        amount: 650.0,
        transactionDate: DateTime(2026, 10, 18, 19, 30),
        type: 'Withdrawal',
        categoryId: 7,
        categoryNameAr: 'بنزين ووقود',
        categoryNameEn: 'Fuel',
      ),
      // Entertainment
      WalletTransaction(
        id: 1018,
        title: 'سينما فوكس مول مصر',
        description: 'تذاكر وفيلم جديد',
        amount: 360.0,
        transactionDate: DateTime(2026, 10, 24, 21, 0),
        type: 'Withdrawal',
        categoryId: 8,
        categoryNameAr: 'ترفيه واشتراكات',
        categoryNameEn: 'Entertainment',
      ),
      WalletTransaction(
        id: 1019,
        title: 'اشتراك نتفليكس',
        description: 'الباقة الشهرية المميزة',
        amount: 185.0,
        transactionDate: DateTime(2026, 10, 7, 2, 0),
        type: 'Withdrawal',
        categoryId: 8,
        categoryNameAr: 'ترفيه واشتراكات',
        categoryNameEn: 'Entertainment',
      ),
      // Health & Medical
      WalletTransaction(
        id: 1020,
        title: 'صيدليات العزبي',
        description: 'فيتامينات ومستلزمات صيدلية',
        amount: 350.0,
        transactionDate: DateTime(2026, 10, 17, 18, 15),
        type: 'Withdrawal',
        categoryId: 9,
        categoryNameAr: 'صحة وعناية',
        categoryNameEn: 'Health & Medical',
      ),
      // Other
      WalletTransaction(
        id: 1021,
        title: 'مصاريف متنوعة',
        description: 'نثريات واحتياجات طارئة',
        amount: 500.0,
        transactionDate: DateTime(2026, 10, 13, 11, 40),
        type: 'Withdrawal',
        categoryId: 10,
        categoryNameAr: 'أخرى ومتنوعات',
        categoryNameEn: 'Other',
      ),
      // Digital Services
      WalletTransaction(
        id: 1022,
        title: 'iCloud + Google Drive',
        description: 'تخزين سحابي شهري',
        amount: 400.0,
        transactionDate: DateTime(2026, 10, 4, 15, 0),
        type: 'Withdrawal',
        categoryId: 11,
        categoryNameAr: 'خدمات إلكترونية',
        categoryNameEn: 'Digital Services',
      ),

      // -------------------------------------------------------------
      // SEPTEMBER 2026 (Previous Month)
      // -------------------------------------------------------------
      WalletTransaction(
        id: 2001,
        title: 'راتب شهر سبتمبر',
        description: 'تحويل بنكي - راتب العمل الشهري',
        amount: 45000.0,
        transactionDate: DateTime(2026, 9, 1, 9, 0),
        type: 'Deposit',
        categoryId: 12,
        categoryNameAr: 'راتب ودخل',
        categoryNameEn: 'Salary & Income',
      ),
      WalletTransaction(
        id: 2002,
        title: 'كارفور ماركت',
        description: 'مشتريات طعام وتموين',
        amount: 4100.0,
        transactionDate: DateTime(2026, 9, 25, 17, 0),
        type: 'Withdrawal',
        categoryId: 2,
        categoryNameAr: 'تسوق ومستلزمات',
        categoryNameEn: 'Shopping',
      ),
      WalletTransaction(
        id: 2003,
        title: 'مطاعم وكافيهات',
        description: 'وجبات عائلية وخروجات',
        amount: 3650.0,
        transactionDate: DateTime(2026, 9, 20, 20, 0),
        type: 'Withdrawal',
        categoryId: 1,
        categoryNameAr: 'طعام ومطاعم',
        categoryNameEn: 'Food & Dining',
      ),
      WalletTransaction(
        id: 2004,
        title: 'مصاريف مدرسة وبداية دراسة',
        description: 'مستلزمات دراسية وكتب',
        amount: 5200.0,
        transactionDate: DateTime(2026, 9, 15, 11, 0),
        type: 'Withdrawal',
        categoryId: 3,
        categoryNameAr: 'تعليم وتطوير',
        categoryNameEn: 'Education',
      ),
      WalletTransaction(
        id: 2005,
        title: 'فواتير ومرافق سبتمبر',
        description: 'كهرباء وإنترنت ومياه',
        amount: 1150.0,
        transactionDate: DateTime(2026, 9, 10, 13, 0),
        type: 'Withdrawal',
        categoryId: 5,
        categoryNameAr: 'كهرباء وفواتير',
        categoryNameEn: 'Electricity & Bills',
      ),
      WalletTransaction(
        id: 2006,
        title: 'وقود وبنزين سبتمبر',
        description: 'تموين سيارة شهري',
        amount: 1300.0,
        transactionDate: DateTime(2026, 9, 18, 16, 0),
        type: 'Withdrawal',
        categoryId: 7,
        categoryNameAr: 'بنزين ووقود',
        categoryNameEn: 'Fuel',
      ),

      // -------------------------------------------------------------
      // AUGUST 2026 (Past Month)
      // -------------------------------------------------------------
      WalletTransaction(
        id: 3001,
        title: 'راتب شهر أغسطس',
        description: 'تحويل بنكي - راتب العمل الشهري',
        amount: 45000.0,
        transactionDate: DateTime(2026, 8, 1, 9, 0),
        type: 'Deposit',
        categoryId: 12,
        categoryNameAr: 'راتب ودخل',
        categoryNameEn: 'Salary & Income',
      ),
      WalletTransaction(
        id: 3002,
        title: 'حجز فندق وإجازة صيفية',
        description: 'إقامة مصيف الساحل الشمالي',
        amount: 12000.0,
        transactionDate: DateTime(2026, 8, 12, 12, 0),
        type: 'Withdrawal',
        categoryId: 8,
        categoryNameAr: 'ترفيه واشتراكات',
        categoryNameEn: 'Entertainment',
      ),
      WalletTransaction(
        id: 3003,
        title: 'مطاعم وأسماك',
        description: 'وجبات عائلية مصيف',
        amount: 4800.0,
        transactionDate: DateTime(2026, 8, 14, 21, 0),
        type: 'Withdrawal',
        categoryId: 1,
        categoryNameAr: 'طعام ومطاعم',
        categoryNameEn: 'Food & Dining',
      ),
      WalletTransaction(
        id: 3004,
        title: 'بنزين وسفر',
        description: 'طريق الساحل والعودة',
        amount: 2400.0,
        transactionDate: DateTime(2026, 8, 16, 18, 0),
        type: 'Withdrawal',
        categoryId: 7,
        categoryNameAr: 'بنزين ووقود',
        categoryNameEn: 'Fuel',
      ),
    ];
  }
  //#endregion
}

class _CategoryAggregator {
  final int categoryId;
  final String categoryNameAr;
  final String categoryNameEn;
  double total = 0.0;
  int count = 0;

  _CategoryAggregator(this.categoryId, this.categoryNameAr, this.categoryNameEn);

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
