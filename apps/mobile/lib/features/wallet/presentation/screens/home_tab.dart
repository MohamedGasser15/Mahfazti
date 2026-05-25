// features/home/presentation/screens/home_tab.dart
import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:my_wallet/core/services/hide_balance_service.dart';
import 'package:my_wallet/core/services/message_service.dart';
import 'package:my_wallet/core/services/wallet_cache_service.dart';
import 'package:my_wallet/core/utils/api_error_handler.dart';
import 'package:my_wallet/core/utils/shared_prefs.dart';
import 'package:my_wallet/features/wallet/data/models/category_model.dart';
import 'package:my_wallet/features/wallet/data/models/voice_expense_model.dart';
import 'package:my_wallet/features/wallet/data/repositories/category_repository.dart';
import 'package:my_wallet/features/wallet/presentation/widgets/voice_expense_button.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:my_wallet/core/constants/currency_constants.dart';
import 'package:my_wallet/core/extensions/context_extensions.dart';
import 'package:my_wallet/features/settings/presentation/screens/settings_screen.dart';
import 'package:my_wallet/features/wallet/data/repositories/wallet_repository.dart';
import 'package:my_wallet/features/wallet/data/models/wallet_models.dart';
import 'dart:ui' as ui;
import '../widgets/home_tab_models.dart';

part '../widgets/home_tab_dialogs.dart';
part '../widgets/home_tab_widgets.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabConcrete();
}

abstract class _HomeTabState extends State<HomeTab> {
  //#region Private Fields
  final WalletRepository _walletRepository = WalletRepository();
  bool _isLoading = true;
  WalletHomeData? _homeData;
  String? _errorMessage;
  TransactionType _selectedFilter = TransactionType.all;

  List<Category> _categories = [];
  bool _isLoadingCategories = false;

  String? _currencyCode;
  //#endregion

  //#region Lifecycle
  @override
  void initState() {
    super.initState();
    _loadCurrency().then((_) {
      _loadHomeData();
    });
    _loadCategories();
  }
  //#endregion

  //#region Data Loading
  Future<void> _loadCurrency() async {
    final code = await SharedPrefs.getCurrency();
    setState(() {
      _currencyCode = code ?? 'USD';
    });
  }
  Map<String, dynamic> _homeDataToMap(WalletHomeData data) {
    return {
      'balance': {
        'totalBalance': data.balance.totalBalance,
        'totalDeposits': data.balance.totalDeposits,
        'totalWithdrawals': data.balance.totalWithdrawals,
      },
      'recentTransactions': data.recentTransactions.map((t) => t.toJson()).toList(),
      'totalTransactionCount': data.totalTransactionCount,
    };
  }

  WalletHomeData _homeDataFromMap(Map<String, dynamic> map) {
    final balanceMap = map['balance'] as Map<String, dynamic>;
    final balance = WalletBalance(
      totalBalance: (balanceMap['totalBalance'] as num).toDouble(),
      totalDeposits: (balanceMap['totalDeposits'] as num).toDouble(),
      totalWithdrawals: (balanceMap['totalWithdrawals'] as num).toDouble(),
    );
    final transactions = (map['recentTransactions'] as List)
        .map((t) => WalletTransaction.fromJson(t))
        .toList();
    return WalletHomeData(
      balance: balance,
      recentTransactions: transactions,
      totalTransactionCount: map['totalTransactionCount'] as int,
    );
  }
  Future<void> _loadCategories() async {
    setState(() => _isLoadingCategories = true);
    try {
      final repo = CategoryRepository();
      _categories = await repo.getAllCategories();
    } catch (e) {
      final errorMsg = ApiErrorHandler.getErrorMessage(e);
      debugPrint('Error loading categories: $errorMsg');
      if (!mounted) return;
      MessageService.showError(context: context, message: '${context.l10n.failedToLoadCategories}: $errorMsg');
    } finally {
      setState(() => _isLoadingCategories = false);
    }
  }

  Future<List<WalletTransaction>> _loadAllTransactions() async {
    try {
      final response = await _walletRepository.getTransactions(pageSize: 100);
      return response.transactions;
    } catch (e) {
      final errorMsg = ApiErrorHandler.getErrorMessage(e);
      if (!mounted) return [];
      MessageService.showError(context: context, message: '${context.l10n.failedToLoadTransactions}: $errorMsg');
      return [];
    }
  }

  Future<void> _loadHomeData({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cached = await WalletCacheService.getHome();
      if (cached != null) {
        try {
          final cachedData = _homeDataFromMap(cached);
          setState(() {
            _homeData = cachedData;
            _isLoading = false;
            _errorMessage = null;
          });
          _refreshInBackground();
          return;
        } catch (e) {
          debugPrint('Error parsing cached home data: $e');
        }
      }
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    await _fetchHomeFromApi();
  }
  Future<void> _fetchHomeFromApi({bool silent = false}) async {
    try {
      final data = await _walletRepository.getHomeData();
      final cacheMap = _homeDataToMap(data);
      await WalletCacheService.saveHome(cacheMap);

      if (mounted && !silent) {
        setState(() {
          _homeData = data;
          _isLoading = false;
        });
      } else if (mounted && silent) {
        setState(() {
          _homeData = data;
        });
      }
    } catch (e) {
      final errorMsg = ApiErrorHandler.getErrorMessage(e);
      if (mounted && !silent) {
        setState(() {
          _errorMessage = errorMsg;
          _isLoading = false;
        });
      }
      if (!ApiErrorHandler.isNetworkError(e)) {
        if (!mounted) return;
        MessageService.showError(context: context, message: errorMsg);
      }
    }
  }

  Future<void> _refreshInBackground() async {
    try {
      await _fetchHomeFromApi(silent: true);
    } catch (_) {
      // ignore
    }
  }
  Future<void> _refreshData() async {
    await _loadHomeData(forceRefresh: true);
  }
  //#endregion

  //#region Filter Helpers
  List<TransactionFilter> get _filters => [
        TransactionFilter(type: TransactionType.all, label: context.l10n.all),
        TransactionFilter(type: TransactionType.income, label: context.l10n.income),
        TransactionFilter(type: TransactionType.expense, label: context.l10n.expense),
      ];

  List<WalletTransaction> get _filteredTransactions {
    if (_selectedFilter == TransactionType.all)
      return _homeData?.recentTransactions ?? [];

    return _homeData?.recentTransactions
            .where((t) => _selectedFilter == TransactionType.income
                ? t.isDeposit
                : t.isWithdrawal)
            .toList() ??
        [];
  }
  //#endregion

  //#region Transaction Actions
  Future<void> _deleteTransaction(WalletTransaction transaction) async {
    try {
      final success = await _walletRepository.deleteTransaction(transaction.id);

      if (success) {
        await _loadHomeData();
        if (!mounted) return;
        MessageService.showSuccess(context: context, message: context.l10n.transactionDeletedSuccess);
      } else {
        if (!mounted) return;
        MessageService.showError(context: context, message: context.l10n.failedToDeleteTransaction);
      }
    } catch (e) {
      if (!mounted) return;
      MessageService.showError(context: context, message: context.l10n.errorDeletingTransaction(e.toString()));
    }
  }
  //#endregion

  //#region Cross-Mixin Abstract Declarations
  Widget _buildEmptyState(bool isDarkMode);
  Widget _buildTransactionCard(WalletTransaction transaction, bool isDarkMode);
  void _showEditTransactionDialog(WalletTransaction transaction);
  void _showDeleteConfirmationDialog(WalletTransaction transaction);
  Widget _buildSkeletonLoading(bool isDarkMode);
  Widget _buildErrorWidget(bool isDarkMode);
  Widget _buildBlurrableNumber(double amount, TextStyle style, bool blurred);
  Widget _buildQuickAction(IconData icon, String label, VoidCallback onTap, bool isDarkMode);
  void _showAddTransactionDialog(TransactionType type, {VoiceExpenseResult? prefillFromVoice});
  void _showAllTransactionsModal(List<WalletTransaction> transactions);
  //#endregion

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final hideService = Provider.of<HideBalanceService>(context);

    return Container(
      color: isDarkMode ? Colors.black : Colors.white,
      child: SafeArea(
      bottom: false,
      child: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _refreshData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  if (_homeData == null) ...[
                    if (_isLoading)
                      _buildSkeletonLoading(isDarkMode)
                    else if (_errorMessage != null)
                      _buildErrorWidget(isDarkMode)
                    else
                      const SizedBox.shrink(),
                  ] else ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isDarkMode
                                ? [Colors.grey[900]!, Colors.grey[850]!]
                                : [Colors.white, Colors.grey[50]!],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isDarkMode ? 0.2 : 0.08),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: isDarkMode
                                          ? Colors.grey[800]
                                          : Colors.grey[200],
                                      borderRadius: BorderRadius.circular(30),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.05),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.account_balance_wallet_outlined,
                                          color: isDarkMode
                                              ? Colors.white
                                              : Colors.black,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          context.l10n.appTitle,
                                          style: TextStyle(
                                            color: isDarkMode
                                                ? Colors.white
                                                : Colors.black,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0.3,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          hideService.isHidden
                                              ? Icons.visibility_off_outlined
                                              : Icons.visibility_outlined,
                                          color: isDarkMode
                                              ? Colors.grey[400]
                                              : Colors.grey[600],
                                          size: 20,
                                        ),
                                        onPressed: hideService.toggle,
                                      ),
                                      const SizedBox(width: 8),
                                      GestureDetector(
                                        onTap: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => SettingsScreen(
                                              onLocaleChanged: (locale) {},
                                            ),
                                          ),
                                        ),
                                        child: CircleAvatar(
                                          radius: 20,
                                          backgroundColor: isDarkMode
                                              ? Colors.grey[800]
                                              : Colors.grey[200],
                                          child: Icon(
                                            Icons.person,
                                            color: isDarkMode
                                                ? Colors.white
                                                : Colors.black,
                                            size: 24,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                context.l10n.totalBalance,
                                style: TextStyle(
                                  color: isDarkMode
                                      ? Colors.grey[400]
                                      : Colors.grey[600],
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  _buildBlurrableNumber(
                                    _homeData!.balance.totalBalance,
                                    TextStyle(
                                      color: isDarkMode ? Colors.white : Colors.black,
                                      fontSize: 40,
                                      fontWeight: FontWeight.w800,
                                    ),
                                    hideService.isHidden,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                color: Colors.green.shade700,
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.arrow_downward,
                                                color: Colors.white,
                                                size: 12,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              context.l10n.income,
                                              style: TextStyle(
                                                color: Colors.green.shade800,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        _buildBlurrableNumber(
                                          _homeData!.balance.totalDeposits,
                                          TextStyle(
                                            color: Colors.green.shade800,
                                            fontSize: 24,
                                            fontWeight: FontWeight.w800,
                                          ),
                                          hideService.isHidden,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                color: Colors.red.shade700,
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.arrow_upward,
                                                color: Colors.white,
                                                size: 12,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              context.l10n.expense,
                                              style: TextStyle(
                                                color: Colors.red.shade800,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        _buildBlurrableNumber(
                                          _homeData!.balance.totalWithdrawals,
                                          TextStyle(
                                            color: Colors.red.shade800,
                                            fontSize: 24,
                                            fontWeight: FontWeight.w800,
                                          ),
                                          hideService.isHidden,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 24),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildQuickAction(
                            Icons.add, context.l10n.addDeposit,
                            () => _showAddTransactionDialog(TransactionType.income),
                            isDarkMode,
                          ),
                          _buildQuickAction(
                            Icons.remove, context.l10n.addWithdrawal,
                            () => _showAddTransactionDialog(TransactionType.expense),
                            isDarkMode,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            context.l10n.recentTransactions,
                            style: TextStyle(
                              color: isDarkMode ? Colors.white : Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (_homeData!.totalTransactionCount > 5)
                            TextButton(
                              onPressed: () async {
                                final allTransactions = await _loadAllTransactions();
                                if (!mounted) return;
                                _showAllTransactionsModal(allTransactions);
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                              ),
                              child: Text(
                                context.l10n.seeAll,
                                style: TextStyle(
                                  color: isDarkMode
                                      ? Colors.grey[400]
                                      : Colors.grey[600],
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.grey[900] : Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: _filters
                            .map(
                              (filter) => Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedFilter = filter.type;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    decoration: BoxDecoration(
                                      color: _selectedFilter == filter.type
                                          ? (isDarkMode ? Colors.black : Colors.white)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: _selectedFilter == filter.type
                                          ? [
                                              BoxShadow(
                                                color: Colors.black.withValues(alpha: 0.05),
                                                blurRadius: 4,
                                                offset: const Offset(0, 2),
                                              ),
                                            ]
                                          : null,
                                    ),
                                    child: Text(
                                      filter.label,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: _selectedFilter == filter.type
                                            ? (isDarkMode ? Colors.white : Colors.black)
                                            : (isDarkMode
                                                ? Colors.grey[400]
                                                : Colors.grey[600]),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _filteredTransactions.isEmpty
                          ? _buildEmptyState(isDarkMode)
                          : Column(
                              children: _filteredTransactions
                                  .take(5)
                                  .map((transaction) => _buildTransactionCard(transaction, isDarkMode))
                                  .toList(),
                            ),
                    ),
                    const SizedBox(height: 160),
                  ],
                ],
              ),
            ),
          ),
          Positioned(
            bottom: Platform.isIOS ? 100 : 20,
            left: 0,
            right: 0,
            child: Center(
              child: VoiceExpenseButton(
                isDarkMode: isDarkMode,
                onResult: (result) {
                  if (result.isSuccess) {
                    final type = result.transactionType == 'Deposit'
                        ? TransactionType.income
                        : TransactionType.expense;
                    _showAddTransactionDialog(type, prefillFromVoice: result);
                  } else {
                    MessageService.showError(
                        context: context, message: result.errorMessage ?? context.l10n.voiceAnalysisFailed);
                  }
                },
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }

  //#region Helper Methods
  String _formatAmount(double amount) {
    final symbol = currencySymbols[_currencyCode ?? 'USD'] ?? '\$';
    final formatter = NumberFormat('#,##0', 'en_US');
    return '$symbol ${formatter.format(amount)}';
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}${context.l10n.minutesAgo}';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}${context.l10n.hoursAgo}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}${context.l10n.daysAgo}';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
  //#endregion
}

class _HomeTabConcrete extends _HomeTabState with _HomeTabDialogs, _HomeTabWidgets {}
