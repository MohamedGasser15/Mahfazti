import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:cupertino_native_better/cupertino_native_better.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:my_wallet/core/constants/currency_constants.dart';
import 'package:my_wallet/core/extensions/context_extensions.dart';
import 'package:my_wallet/core/services/hide_balance_service.dart';
import 'package:my_wallet/core/services/message_service.dart';
import 'package:my_wallet/core/services/wallet_cache_service.dart';
import 'package:my_wallet/core/utils/api_error_handler.dart';
import 'package:my_wallet/core/utils/app_responsive.dart';
import 'package:my_wallet/core/utils/shared_prefs.dart';
import 'package:my_wallet/features/settings/presentation/screens/settings_screen.dart';
import 'package:my_wallet/features/wallet/data/models/category_model.dart';
import 'package:my_wallet/features/wallet/data/models/voice_expense_model.dart';
import 'package:my_wallet/features/wallet/data/models/wallet_models.dart';
import 'package:my_wallet/features/wallet/data/repositories/category_repository.dart';
import 'package:my_wallet/features/wallet/data/repositories/wallet_repository.dart';
import 'package:my_wallet/features/wallet/presentation/screens/analytics_screen.dart';
import 'package:my_wallet/features/wallet/presentation/widgets/home_tab_models.dart';
import 'package:my_wallet/features/wallet/presentation/widgets/voice_expense_button.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

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

  List<Category> _categories = [];
  String? _currencyCode;

  String _selectedAccountId = 'all';
  DateTime _startDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime _endDate = DateTime(DateTime.now().year, DateTime.now().month + 1, 0);
  bool _showAutoTrackingBanner = true;
  int _getStartedCardIndex = 0;
  final Set<String> _dismissedGetStartedCards = <String>{};
  String? _animatingDismissCardId;
  bool _isDismissingCard = false;
  PageController _getStartedPageController = PageController(viewportFraction: 0.90);
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

  @override
  void dispose() {
    _getStartedPageController.dispose();
    super.dispose();
  }
  //#endregion

  //#region Accounts Data Getter
  List<AccountItem> get _accounts {
    final balance = _homeData?.balance.totalBalance ?? 0.0;
    final income = _homeData?.balance.totalDeposits ?? 0.0;
    final expense = _homeData?.balance.totalWithdrawals ?? 0.0;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return [
      AccountItem(
        id: 'all',
        name: isAr ? 'إجمالي الحسابات' : 'All Accounts',
        type: 'all',
        balance: balance,
        income: income,
        expense: expense,
        icon: Icons.account_balance_wallet_rounded,
        isAll: true,
      ),
      AccountItem(
        id: 'cash',
        name: isAr ? 'كاش (الجيب)' : 'Cash Wallet',
        type: 'cash',
        balance: balance * 0.18,
        income: income * 0.1,
        expense: expense * 0.35,
        icon: Icons.payments_rounded,
      ),
      AccountItem(
        id: 'bank',
        name: isAr ? 'بنك مصر' : 'Banque Misr',
        type: 'bank',
        balance: balance * 0.62,
        income: income * 0.8,
        expense: expense * 0.45,
        icon: Icons.account_balance_rounded,
      ),
      AccountItem(
        id: 'ewallet',
        name: isAr ? 'فودافون كاش' : 'Vodafone Cash',
        type: 'ewallet',
        balance: balance * 0.20,
        income: income * 0.1,
        expense: expense * 0.2,
        icon: Icons.phone_iphone_rounded,
      ),
    ];
  }

  AccountItem get _selectedAccount {
    final accounts = _accounts;
    return accounts.firstWhere(
      (a) => a.id == _selectedAccountId,
      orElse: () => accounts.first,
    );
  }

  double _heroDragDistance = 0.0;
  bool _heroSlideFromLeft = false;

  void _switchToNextAccount({bool isRtl = false}) {
    final accounts = _accounts;
    if (accounts.length <= 1) return;
    final currentIndex = accounts.indexWhere((a) => a.id == _selectedAccountId);
    if (currentIndex == -1) return;
    final nextIndex = (currentIndex + 1) % accounts.length;
    HapticFeedback.selectionClick();
    setState(() {
      _heroSlideFromLeft = isRtl;
      _selectedAccountId = accounts[nextIndex].id;
    });
  }

  void _switchToPreviousAccount({bool isRtl = false}) {
    final accounts = _accounts;
    if (accounts.length <= 1) return;
    final currentIndex = accounts.indexWhere((a) => a.id == _selectedAccountId);
    if (currentIndex == -1) return;
    final prevIndex = (currentIndex - 1 + accounts.length) % accounts.length;
    HapticFeedback.selectionClick();
    setState(() {
      _heroSlideFromLeft = !isRtl;
      _selectedAccountId = accounts[prevIndex].id;
    });
  }
  //#endregion

  //#region Data Loading
  Future<void> _loadCurrency() async {
    final code = await SharedPrefs.getCurrency();
    setState(() {
      _currencyCode = code ?? 'USD';
    });
  }

  Future<void> _loadCategories() async {
    try {
      final repo = CategoryRepository();
      _categories = await repo.getAllCategories();
    } catch (e) {
      final errorMsg = ApiErrorHandler.getErrorMessage(e);
      debugPrint('Error loading categories: $errorMsg');
      if (!mounted) return;
      MessageService.showError(
        context: context,
        message: '${context.l10n.failedToLoadCategories}: $errorMsg',
      );
    }
  }

  Future<List<WalletTransaction>> _loadAllTransactions() async {
    try {
      final response = await _walletRepository.getTransactions(pageSize: 100);
      return response.transactions;
    } catch (e) {
      final errorMsg = ApiErrorHandler.getErrorMessage(e);
      if (!mounted) return [];
      MessageService.showError(
        context: context,
        message: '${context.l10n.failedToLoadTransactions}: $errorMsg',
      );
      return [];
    }
  }

  Future<void> _loadHomeData({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cached = await WalletCacheService.getHome();
      if (cached != null) {
        try {
          final cachedData = WalletHomeData.fromJson(cached);
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
      final cacheMap = data.toJson();
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
  List<WalletTransaction> get _filteredTransactions =>
      _homeData?.recentTransactions ?? [];


  String get _formattedDateRange {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final startStr = DateFormat('d MMM', isAr ? 'ar' : 'en').format(_startDate);
    final endStr = DateFormat('d MMM', isAr ? 'ar' : 'en').format(_endDate);
    return '$startStr - $endStr';
  }

  double get _totalSpentAmount {
    final account = _selectedAccount;
    return account.expense;
  }
  //#endregion

  //#region Transaction Actions
  Future<void> _deleteTransaction(WalletTransaction transaction) async {
    try {
      final success = await _walletRepository.deleteTransaction(transaction.id);

      if (success) {
        await _loadHomeData();
        if (!mounted) return;
        MessageService.showSuccess(
          context: context,
          message: context.l10n.transactionDeletedSuccess,
        );
      } else {
        if (!mounted) return;
        MessageService.showError(
          context: context,
          message: context.l10n.failedToDeleteTransaction,
        );
      }
    } catch (e) {
      if (!mounted) return;
      MessageService.showError(
        context: context,
        message: context.l10n.errorDeletingTransaction(e.toString()),
      );
    }
  }
  //#endregion

  //#region Cross-Mixin Abstract Declarations
  Widget _buildSayHeroSection(bool isDarkMode, HideBalanceService hideService);
  Widget _buildAutoTrackingBanner(bool isDarkMode);
  Widget _buildRecentTransactionsSection(bool isDarkMode);
  Widget _buildInsightsGridSection(bool isDarkMode, HideBalanceService hideService);
  Widget _buildEmptyState(bool isDarkMode);
  Widget _buildTransactionCard(WalletTransaction transaction, bool isDarkMode);
  void _showEditTransactionDialog(WalletTransaction transaction);
  void _showDeleteConfirmationDialog(WalletTransaction transaction);
  Widget _buildSkeletonLoading(bool isDarkMode);
  Widget _buildErrorWidget(bool isDarkMode);
  void _showUnifiedAddModal({VoiceExpenseResult? prefillFromVoice});
  void _showAddAccountModal();
  void _showManageAccountsModal();
  void _showAccountSwitcherModal();
  void _showAllTransactionsModal(List<WalletTransaction> transactions);
  //#endregion

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final hideService = Provider.of<HideBalanceService>(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Container(
        color: isDarkMode ? const Color(0xFF09090B) : Colors.white,
        child: RefreshIndicator(
          onRefresh: _refreshData,
          color: Colors.white,
          backgroundColor: isDarkMode ? const Color(0xFF26262E) : const Color(0xFF202026),
          child: SingleChildScrollView(
            clipBehavior: Clip.none,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Top overscroll extension: matches top of hero gradient seamlessly
                Positioned(
                  top: -1000,
                  left: -1000,
                  right: -1000,
                  height: 1000,
                  child: Container(
                    color: isDarkMode
                        ? const Color(0xFF16161B)
                        : const Color(0xFF141418),
                  ),
                ),
                ResponsiveWrapper(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Say-Style Hero Section with Atmospheric Black Gradient / Shadow (Status bar down to actions)
                      _buildSayHeroSection(isDarkMode, hideService),

                      if (_homeData == null) ...[
                        if (_isLoading)
                          _buildSkeletonLoading(isDarkMode)
                        else if (_errorMessage != null)
                          _buildErrorWidget(isDarkMode)
                        else
                          const SizedBox.shrink(),
                      ] else ...[
                        // "Get Started / Auto-Tracking" Banner Card
                        AnimatedSize(
                          duration: const Duration(milliseconds: 320),
                          curve: Curves.easeInOutCubic,
                          child: (_showAutoTrackingBanner && _dismissedGetStartedCards.length < 4)
                              ? Column(
                                  children: [
                                    _buildAutoTrackingBanner(isDarkMode),
                                    const SizedBox(height: 20),
                                  ],
                                )
                              : const SizedBox.shrink(),
                        ),

                        // Recent Transactions Section
                        _buildRecentTransactionsSection(isDarkMode),

                        const SizedBox(height: 24),

                        // Insights Grid Widgets Section
                        _buildInsightsGridSection(isDarkMode, hideService),

                        const SizedBox(height: 120),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  //#region Formatting Helpers
  String _formatAmount(double amount) {
    final symbol = currencySymbols[_currencyCode ?? 'USD'] ?? '\$';
    final formatter = NumberFormat('#,##0.00', 'en_US');
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
