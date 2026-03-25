// features/wallet/presentation/screens/budget_page.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_wallet/core/extensions/context_extensions.dart';
import 'package:my_wallet/core/services/message_service.dart';
import 'package:my_wallet/core/services/wallet_cache_service.dart';
import 'package:my_wallet/features/wallet/data/models/budget_models.dart';
import 'package:my_wallet/features/wallet/data/repositories/wallet_repository.dart';
import 'package:my_wallet/core/utils/shared_prefs.dart';
import 'package:shimmer/shimmer.dart';

class BudgetPage extends StatefulWidget {
  const BudgetPage({super.key});

  @override
  State<BudgetPage> createState() => _BudgetPageState();
}

class _BudgetPageState extends State<BudgetPage> {
  final WalletRepository _walletRepository = WalletRepository();
  bool _isLoading = true;
  String? _errorMessage;
  BudgetDto? _budget;

  // متغيرات العملة
  String? _currencyCode;
  bool _currencyLoaded = false;

  static const Map<String, String> currencySymbols = {
    'USD': '\$',
    'EUR': '€',
    'EGP': 'E£',
    'SAR': '﷼',
    'AED': 'د.إ',
    'KWD': 'د.ك',
  };

  @override
  void initState() {
    super.initState();
    _loadCurrency();
  }

  // ==================  Cache & API Logic (Stale-While-Revalidate) ==================
  Future<void> _loadCurrency() async {
    final code = await SharedPrefs.getCurrency();
    if (mounted) {
      setState(() {
        _currencyCode = code ?? 'USD';
        _currencyLoaded = true;
      });
      _loadBudget(); // load budget after currency
    }
  }

  /// Load budget data with cache-first strategy.
  Future<void> _loadBudget({bool forceRefresh = false}) async {
    if (!mounted) return;

    // 1. If not forced, try to get from cache
    if (!forceRefresh) {
      final cachedMap = await WalletCacheService.getBudget();
      if (cachedMap != null) {
        try {
          final cachedBudget = _budgetFromMap(cachedMap);
          setState(() {
            _budget = cachedBudget;
            _isLoading = false;
            _errorMessage = null;
          });
          // Refresh in background without blocking UI
          _refreshInBackground();
          return;
        } catch (e) {
          debugPrint('Error parsing cached budget: $e');
        }
      }
    }

    // 2. No cache or forced refresh → show shimmer and fetch from API
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    await _fetchFromApi();
  }

  /// Fetch fresh data from API and update cache.
  Future<void> _fetchFromApi({bool silent = false}) async {
    try {
      final budget = await _walletRepository.getBudget();
      final budgetMap = _budgetToMap(budget);
      await WalletCacheService.saveBudget(budgetMap);

      if (mounted && !silent) {
        setState(() {
          _budget = budget;
          _isLoading = false;
        });
      } else if (mounted && silent) {
        setState(() {
          _budget = budget;
        });
      }
    } catch (e) {
      if (mounted && !silent) {
        setState(() {
          _errorMessage = 'Failed to load budget: $e';
          _isLoading = false;
        });
      }
    }
  }

  /// Background refresh after displaying cached data.
  Future<void> _refreshInBackground() async {
    try {
      await _fetchFromApi(silent: true);
    } catch (_) {
      // Ignore background refresh errors
    }
  }

  // ==================  Data Conversion Helpers ==================
  
  Map<String, dynamic> _budgetToMap(BudgetDto budget) {
    return {
      'monthlyBudget': budget.monthlyBudget,
      'currentSpending': budget.currentSpending,
      'categoryBudgets': budget.categoryBudgets.map((cat) => {
        'categoryId': cat.categoryId,
        'categoryNameAr': cat.categoryNameAr,
        'categoryNameEn': cat.categoryNameEn,
        'budget': cat.budget,
        'spent': cat.spent,
      }).toList(),
    };
  }

  BudgetDto _budgetFromMap(Map<String, dynamic> map) {
    final categoryList = (map['categoryBudgets'] as List).map((catMap) {
    return CategoryBudgetDto(
      id: catMap['id'] ?? 0,
      categoryId: catMap['categoryId'],
      categoryNameAr: catMap['categoryNameAr'],
      categoryNameEn: catMap['categoryNameEn'],
      budget: (catMap['budget'] as num).toDouble(),
      spent: (catMap['spent'] as num).toDouble(),
    );
    }).toList();

    return BudgetDto(
      monthlyBudget: (map['monthlyBudget'] as num).toDouble(),
      currentSpending: (map['currentSpending'] as num).toDouble(),
      categoryBudgets: categoryList,
    );
  }

  // ==================  Update Methods (Force Refresh) ==================
  
  Future<void> _updateMonthlyBudget(double newBudget) async {
    try {
      await _walletRepository.updateMonthlyBudget(newBudget);
      await _loadBudget(forceRefresh: true);
      if (mounted) {
        MessageService.showSuccess('Budget updated successfully');
      }
    } catch (e) {
      if (mounted) {
        MessageService.showError('Failed to update budget: $e');
      }
    }
  }

  Future<void> _updateCategoryBudget(int categoryId, double newBudget) async {
    try {
      await _walletRepository.updateCategoryBudget(categoryId, newBudget);
      await _loadBudget(forceRefresh: true);
      if (mounted) {
        MessageService.showSuccess('Budget updated');
      }
    } catch (e) {
      if (mounted) {
        MessageService.showError('Failed: $e');
      }
    }
  }

  // ==================  Dialog Methods (unchanged except calling new update methods) ==================
  
  void _showEditCategoryBudgetDialog(CategoryBudgetDto category) {
    if (_budget == null) return;

    final monthlyBudget = _budget!.monthlyBudget;
    final otherCategoriesTotal = _budget!.categoryBudgets
        .where((c) => c.categoryId != category.categoryId)
        .fold(0.0, (sum, c) => sum + c.budget);
    final maxAllowed = (monthlyBudget - otherCategoriesTotal).clamp(0.0, double.infinity);

    final TextEditingController budgetController = TextEditingController(
      text: _formatCurrency(category.budget).replaceAll(RegExp(r'[^0-9,]'), ''),
    );
    bool isSubmitting = false;
    String? errorText;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;

        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.black : Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        height: 4,
                        width: 40,
                        margin: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isDarkMode ? Colors.grey[800] : Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            Text(
                              'Edit ${Localizations.localeOf(context).languageCode == 'ar' ? category.categoryNameAr : category.categoryNameEn} Budget',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: isDarkMode ? Colors.white : Colors.black,
                              ),
                            ),
                            const SizedBox(height: 24),
                            TextFormField(
                              controller: budgetController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Budget Amount',
                                labelStyle: TextStyle(
                                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                ),
                                prefixIcon: Icon(
                                  Icons.attach_money,
                                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                ),
                                filled: true,
                                fillColor: isDarkMode ? Colors.grey[900] : Colors.grey[50],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                errorText: errorText,
                              ),
                              onChanged: (_) {
                                if (errorText != null) {
                                  setState(() => errorText = null);
                                }
                              },
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 8, left: 12),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Maximum allowed: ${_formatCurrency(maxAllowed)}',
                                  style: TextStyle(
                                    color: maxAllowed <= 0
                                        ? Colors.red[700]
                                        : (isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: isSubmitting ? null : () => Navigator.pop(context),
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(
                                        color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
                                      ),
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                    ),
                                    child: Text(
                                      context.l10n.cancel,
                                      style: TextStyle(
                                        color: isDarkMode ? Colors.white : Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: isSubmitting
                                        ? null
                                        : () async {
                                            final input = budgetController.text.trim();
                                            if (input.isEmpty) {
                                              setState(() => errorText = 'Please enter an amount');
                                              return;
                                            }
                                            final newBudget = double.tryParse(input);
                                            if (newBudget == null) {
                                              setState(() => errorText = 'Please enter a valid number');
                                              return;
                                            }
                                            if (newBudget < 0) {
                                              setState(() => errorText = 'Amount cannot be negative');
                                              return;
                                            }
                                            if (newBudget > maxAllowed) {
                                              setState(() => errorText = 'Amount exceeds monthly budget limit (${_formatCurrency(maxAllowed)})');
                                              return;
                                            }

                                            setState(() => isSubmitting = true);
                                            await _updateCategoryBudget(category.categoryId, newBudget);
                                            if (mounted) Navigator.pop(context);
                                          },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isDarkMode ? Colors.white : Colors.black,
                                      foregroundColor: isDarkMode ? Colors.black : Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                    ),
                                    child: isSubmitting
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : Text(context.l10n.save),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showEditBudgetDialog() {
    final TextEditingController budgetController = TextEditingController(
      text: _formatCurrency(_budget?.monthlyBudget ?? 3000).replaceAll(RegExp(r'[^0-9,]'), ''),
    );
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;

        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.black : Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        height: 4,
                        width: 40,
                        margin: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isDarkMode ? Colors.grey[800] : Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            Text(
                              context.l10n.monthlyBudget,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: isDarkMode ? Colors.white : Colors.black,
                              ),
                            ),
                            const SizedBox(height: 24),
                            TextFormField(
                              controller: budgetController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: context.l10n.monthlyBudget,
                                labelStyle: TextStyle(
                                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                ),
                                prefixIcon: Icon(
                                  Icons.attach_money,
                                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                ),
                                filled: true,
                                fillColor: isDarkMode ? Colors.grey[900] : Colors.grey[50],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: isSubmitting ? null : () => Navigator.pop(context),
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(
                                        color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
                                      ),
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                    ),
                                    child: Text(
                                      context.l10n.cancel,
                                      style: TextStyle(
                                        color: isDarkMode ? Colors.white : Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: isSubmitting
                                        ? null
                                        : () async {
                                            if (budgetController.text.isEmpty) return;
                                            final budget = double.tryParse(budgetController.text);
                                            if (budget == null || budget <= 0) return;

                                            setState(() => isSubmitting = true);
                                            await _updateMonthlyBudget(budget);
                                            if (mounted) Navigator.pop(context);
                                          },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isDarkMode ? Colors.white : Colors.black,
                                      foregroundColor: isDarkMode ? Colors.black : Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                    ),
                                    child: isSubmitting
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : Text(context.l10n.save),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ==================  Helper Functions (Currency, etc.) ==================
  
  String _formatCurrency(double amount) {
    final symbol = currencySymbols[_currencyCode] ?? '\$';
    final formatter = NumberFormat('#,##0', 'en_US');
    return '$symbol ${formatter.format(amount)}';
  }

  // ==================  Shimmer Skeleton (unchanged) ==================
  
  Widget _buildShimmerMonthlyBudgetCard(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[900] : Colors.grey[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 100,
                height: 16,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                ),
              ),
              Container(
                width: 80,
                height: 20,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 12,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(6)),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 50,
                    height: 12,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 80,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    width: 30,
                    height: 12,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 80,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: 120,
            height: 14,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(4)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerCategoryHeader(bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 100,
            height: 20,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(4)),
            ),
          ),
          Container(
            width: 120,
            height: 16,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(4)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerCategoryItem(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 120,
                  height: 16,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 4,
                  width: 150,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(2)),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                width: 100,
                height: 16,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                width: 80,
                height: 12,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          Container(
            width: 30,
            height: 30,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerTipsCard(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[900] : Colors.grey[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 100,
                  height: 16,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 200,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerLoading(bool isDarkMode) {
    return Shimmer.fromColors(
      baseColor: isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDarkMode ? Colors.grey[700]! : Colors.grey[100]!,
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: Platform.isIOS ? 110 : 40,
        ),
        child: Column(
          children: [
            _buildShimmerMonthlyBudgetCard(isDarkMode),
            _buildShimmerCategoryHeader(isDarkMode),
            Container(
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[900] : Colors.grey[50],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
                ),
              ),
              child: Column(
                children: List.generate(
                  4,
                  (index) => _buildShimmerCategoryItem(isDarkMode),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildShimmerTipsCard(isDarkMode),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ==================  Build Methods ==================
  
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDarkMode ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          context.l10n.budget,
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: isDarkMode ? Colors.white : Colors.black),
            onPressed: _budget != null ? _showEditBudgetDialog : null,
          ),
        ],
      ),
      body: _isLoading
          ? _buildShimmerLoading(isDarkMode)
          : _errorMessage != null
              ? _buildErrorState(isDarkMode)
              : _buildContent(isDarkMode),
    );
  }

  Widget _buildErrorState(bool isDarkMode) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 72, color: isDarkMode ? Colors.white70 : Colors.black54),
            const SizedBox(height: 16),
            Text(_errorMessage!, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _loadBudget(forceRefresh: true),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDarkMode ? Colors.white : Colors.black,
                foregroundColor: isDarkMode ? Colors.black : Colors.white,
              ),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(bool isDarkMode) {
    final budget = _budget!;
    final remainingBudget = budget.monthlyBudget - budget.currentSpending;
    final progress = budget.currentSpending / budget.monthlyBudget;
    final isOverBudget = budget.currentSpending > budget.monthlyBudget;

    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: Platform.isIOS ? 75 : 5,
      ),
      child: Column(
        children: [
          // Monthly Budget Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[900] : Colors.grey[50],
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isDarkMode ? Colors.grey[800]! : Colors.grey[200]!),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      context.l10n.monthlyBudget,
                      style: TextStyle(color: isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                    ),
                    Text(
                      _formatCurrency(budget.monthlyBudget),
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Stack(
                  children: [
                    Container(
                      height: 12,
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      height: 12,
                      width: MediaQuery.of(context).size.width * 0.7 * progress.clamp(0.0, 1.0),
                      decoration: BoxDecoration(
                        color: isOverBudget ? Colors.red[800] : Colors.green[800],
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(context.l10n.spent, style: TextStyle(color: isDarkMode ? Colors.grey[400] : Colors.grey[600])),
                        Text(
                          _formatCurrency(budget.currentSpending),
                          style: TextStyle(
                            color: isOverBudget ? Colors.red[800] : Colors.green[800],
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(context.l10n.left, style: TextStyle(color: isDarkMode ? Colors.grey[400] : Colors.grey[600])),
                        Text(
                          _formatCurrency(remainingBudget.abs()),
                          style: TextStyle(
                            color: remainingBudget >= 0 ? Colors.green[800] : Colors.red[800],
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  remainingBudget >= 0 ? context.l10n.underBudget : context.l10n.overBudget,
                  style: TextStyle(
                    color: remainingBudget >= 0 ? Colors.green[800] : Colors.red[800],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Category Budgets Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.l10n.categories,
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                context.l10n.monthlyBudget,
                style: TextStyle(color: isDarkMode ? Colors.grey[400] : Colors.grey[600]),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Category Budgets List
          Container(
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[900] : Colors.grey[50],
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isDarkMode ? Colors.grey[800]! : Colors.grey[200]!),
            ),
            child: Column(
              children: ([
                ...budget.categoryBudgets.where((c) => c.spent > 0),
                ...budget.categoryBudgets.where((c) => c.spent == 0),
              ]).map((cat) {
                final categoryProgress = cat.budget > 0
                    ? (cat.spent / cat.budget).clamp(0.0, 1.0)
                    : 0.0;
                final isCategoryOverBudget = cat.spent > cat.budget;
                final categoryNameForIcon = cat.categoryNameEn.isNotEmpty ? cat.categoryNameEn : cat.categoryNameAr;

                return Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
                      ),
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _getCategoryColor(categoryNameForIcon).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getCategoryIcon(categoryNameForIcon),
                        color: _getCategoryColor(categoryNameForIcon),
                        size: 20,
                      ),
                    ),
                    title: Text(
                      Localizations.localeOf(context).languageCode == 'ar'
                          ? (cat.categoryNameAr ?? cat.categoryNameEn ?? '')
                          : (cat.categoryNameEn ?? cat.categoryNameAr ?? ''),
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Stack(
                          children: [
                            Container(
                              height: 4,
                              width: MediaQuery.of(context).size.width * 0.5,
                              decoration: BoxDecoration(
                                color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 500),
                              height: 4,
                              width: (MediaQuery.of(context).size.width * 0.5) * categoryProgress,
                              decoration: BoxDecoration(
                                color: isCategoryOverBudget ? Colors.red[800] : Colors.green[800],
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${_formatCurrency(cat.spent)} / ${_formatCurrency(cat.budget)}',
                              style: TextStyle(
                                color: isDarkMode ? Colors.white : Colors.black,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              isCategoryOverBudget
                                  ? context.l10n.overBudget
                                  : '${_formatCurrency(cat.budget - cat.spent)} ${context.l10n.left}',
                              style: TextStyle(
                                color: isCategoryOverBudget ? Colors.red[800] : Colors.green[800],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: Icon(Icons.edit, size: 18, color: isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                          onPressed: () => _showEditCategoryBudgetDialog(cat),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),

          // Tips Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[900] : Colors.grey[50],
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isDarkMode ? Colors.grey[800]! : Colors.grey[200]!),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.lightbulb_outline, color: Colors.blue[800]),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.budget,
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isOverBudget
                            ? '${context.l10n.overBudget}. ${context.l10n.tryReducingExpenses}.'
                            : '${context.l10n.underBudget}. ${context.l10n.considerSaving}.',
                        style: TextStyle(
                          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Color _getCategoryColor(String? categoryName) {
    if (categoryName == null || categoryName.isEmpty) return Colors.grey;
    switch (categoryName.toLowerCase()) {
      case 'food':
        return Colors.orange;
      case 'shopping':
        return Colors.purple;
      case 'transportation':
        return Colors.blue;
      case 'entertainment':
        return Colors.pink;
      case 'bills':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String? categoryName) {
    if (categoryName == null || categoryName.isEmpty) return Icons.category;
    switch (categoryName.toLowerCase()) {
      case 'food':
        return Icons.restaurant;
      case 'shopping':
        return Icons.shopping_bag;
      case 'transportation':
        return Icons.directions_car;
      case 'entertainment':
        return Icons.movie;
      case 'bills':
        return Icons.receipt;
      default:
        return Icons.category;
    }
  }
}